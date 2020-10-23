import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import '../puppeteer.dart';
import 'browser.dart';
import 'connection.dart';
import 'devices.dart';
import 'devices.dart' as devices_lib;
import 'downloader.dart';
import 'page/emulation_manager.dart';

final bool isPuppeteerFirefox =
    Platform.environment['PUPPETEER_PRODUCT'] == 'firefox';

final Logger _logger = Logger('puppeteer.launcher_firefox');

final puppeteerFirefox = PuppeteerFirefox._();

/// Launch or connect to a firefox instance
class PuppeteerFirefox {
  PuppeteerFirefox._();

  /// This method starts a Firefox instance and connects to the DevTools endpoint.
  ///
  /// If [executablePath] is not provided and no environment variable
  /// `PUPPETEER_EXECUTABLE_PATH` is present, it will download the Chromium binaries
  /// in a local folder (.local-chromium by default).
  ///
  /// ```
  /// main() async {
  ///   var browser = await puppeteer.launch();
  ///   await browser.close();
  /// }
  /// ```
  ///
  /// Parameters:
  ///  - `ignoreHttpsErrors`: Whether to ignore HTTPS errors during navigation.
  ///     Defaults to `false`.
  ///  - `headless`: Whether to run browser in [headless mode](https://developers.google.com/web/updates/2017/04/headless-chrome).
  ///     Defaults to `true` unless the `devtools` option is `true`.
  ///  - `executablePath`: Path to a Firefox executable to run instead of the bundled Firefox.
  ///  - `slowMo` Slows down Puppeteer operations by the specified duration.
  ///     Useful so that you can see what is going on.
  ///  - `defaultViewport`: Sets a consistent viewport for each page.
  ///     Defaults to an 1280x1024 viewport. `null` disables the default viewport.
  ///  - `args` Additional arguments to pass to the browser instance. The list
  ///    of Chromium flags can be found [here](http://peter.sh/experiments/chromium-command-line-switches/).
  ///  - `environment` Specify environment variables that will be visible to the browser.
  ///     Defaults to `Platform.environment`.
  ///  - `devtools` Whether to auto-open a DevTools panel for each tab. If this
  ///     option is `true`, the `headless` option will be set `false`.
  ///  - `ignoreDefaultArgs` <[boolean]|[List]<[string]>> If `true`, then do not
  ///     use [`puppeteer.defaultArgs()`]. If a list is given, then filter out
  ///     the given default arguments. Dangerous option; use with care. Defaults to `false`.
  ///  - `userDataDir` <[string]> Path to a [User Data Directory](https://chromium.googlesource.com/chromium/src/+/master/docs/user_data_dir.md).
  ///  - `timeout` Maximum time to wait for the browser instance to start. Defaults to 30 seconds.
  Future<Browser> launch(
      {String executablePath,
      bool headless,
      bool devTools,
      String userDataDir,
      DeviceViewport defaultViewport = LaunchOptions.viewportNotSpecified,
      bool ignoreHttpsErrors,
      Duration slowMo,
      List<String> args,
      /* bool | List */ dynamic ignoreDefaultArgs,
      Map<String, String> environment,
      Duration timeout}) async {
    devTools ??= false;
    headless ??= !devTools;
    timeout ??= Duration(seconds: 30);

    var firefoxArgs = <String>[];
    final defaultArguments = defaultArgs(
      args: args,
      userDataDir: userDataDir,
      devTools: devTools,
      headless: headless,
    );
    if (ignoreDefaultArgs == null || ignoreDefaultArgs == false) {
      firefoxArgs.addAll(defaultArguments);
    } else if (ignoreDefaultArgs is List) {
      firefoxArgs.addAll(
          defaultArguments.where((arg) => !ignoreDefaultArgs.contains(arg)));
    } else if (args != null) {
      firefoxArgs.addAll(args);
    }

    if (!firefoxArgs.any((a) => a.startsWith('--remote-debugging-'))) {
      firefoxArgs.add('--remote-debugging-port=0');
    }

    Directory temporaryUserDataDir;
    if (!firefoxArgs.contains('-profile') &&
        !firefoxArgs.contains('--profile')) {
      temporaryUserDataDir = await _createProfile();
      firefoxArgs.add('--profile');
      firefoxArgs.add(temporaryUserDataDir.path);
    }

    executablePath ??= await _inferExecutablePath();

    var launchOptions =
        LaunchOptions(args: firefoxArgs, defaultViewport: defaultViewport);

    _logger.info('Start $executablePath with $firefoxArgs');
    final firefoxProcess = await Process.start(
        executablePath, launchOptions.args,
        environment: environment);

    // ignore: unawaited_futures
    var firefoxProcessExit = firefoxProcess.exitCode.then((exitCode) {
      _logger.info('Firefox exit with $exitCode.');
      if (temporaryUserDataDir != null) {
        try {
          _logger.info('Clean ${temporaryUserDataDir.path}');
          temporaryUserDataDir.deleteSync(recursive: true);
        } catch (error) {
          _logger.info('Delete temporary file failed', error);
        }
      }
    });

    var webSocketUrl = await _waitForWebSocketUrl(firefoxProcess)
        .timeout(timeout, onTimeout: () => null);
    if (webSocketUrl != null) {
      var connection = await Connection.create(webSocketUrl, delay: slowMo);

      var browser = createBrowser(
        firefoxProcess,
        connection,
        defaultViewport: launchOptions.computedDefaultViewport,
        closeCallback: () async {
          if (temporaryUserDataDir != null) {
            await _killFirefox(firefoxProcess);
          } else {
            // If there is a custom data-directory we need to give firefox a chance
            // to save the last data
            // Attempt to close firefox gracefully
            await connection.send('Browser.close').catchError((error) async {
              await _killFirefox(firefoxProcess);
            });
          }

          return firefoxProcessExit;
        },
        ignoreHttpsErrors: ignoreHttpsErrors,
        plugins: [],
      );
      final targetFuture =
          browser.waitForTarget((target) => target.type == 'page');
      await browser.targetApi.setDiscoverTargets(true);
      await targetFuture;
      return browser;
    } else {
      throw Exception('Not able to connect to Chrome DevTools');
    }
  }

  /// This method attaches Puppeteer to an existing Chromium instance.
  ///
  /// Parameters:
  ///  - `browserWSEndpoint`: a browser websocket endpoint to connect to.
  ///  - `browserURL`:  a browser url to connect to, in format `http://${host}:${port}`.
  ///     Use interchangeably with `browserWSEndpoint` to let Puppeteer fetch it
  ///     from [metadata endpoint](https://chromedevtools.github.io/devtools-protocol/#how-do-i-access-the-browser-target).
  ///  - `ignoreHTTPSErrors`: Whether to ignore HTTPS errors during navigation. Defaults to `false`.
  ///  - `defaultViewport`: Sets a consistent viewport for each page. Defaults to
  ///     an 1280x1024 viewport.  `null` disables the default viewport.
  ///  - `slowMo`: Slows down Puppeteer operations by the specified amount of milliseconds.
  ///     Useful so that you can see what is going on.
  Future<Browser> connect({
    String browserWsEndpoint,
    String browserUrl,
    DeviceViewport defaultViewport = LaunchOptions.viewportNotSpecified,
    bool ignoreHttpsErrors,
    Duration slowMo,
  }) async {
    assert(
        (browserWsEndpoint != null || browserUrl != null) &&
            browserWsEndpoint != browserUrl,
        'Exactly one of browserWSEndpoint, browserURL or transport must be passed to puppeteer.connect');

    var connectOptions =
        LaunchOptions(args: null, defaultViewport: defaultViewport);

    Connection connection;
    if (browserWsEndpoint != null) {
      connection = await Connection.create(browserWsEndpoint, delay: slowMo);
    } else if (browserUrl != null) {
      var connectionURL = await _wsEndpoint(browserUrl);
      connection = await Connection.create(connectionURL, delay: slowMo);
    }

    var browserContextIds = await connection.targetApi.getBrowserContexts();
    var browser = createBrowser(null, connection,
        browserContextIds: browserContextIds,
        ignoreHttpsErrors: ignoreHttpsErrors,
        defaultViewport: connectOptions.computedDefaultViewport,
        plugins: [],
        closeCallback: () =>
            connection.send('Browser.close').catchError((e) => null));
    await browser.targetApi.setDiscoverTargets(true);
    return browser;
  }

  Devices get devices => devices_lib.devices;

  List<String> defaultArgs({
    bool devTools,
    bool headless,
    List<String> args,
    String userDataDir,
  }) {
    devTools ??= false;
    headless ??= !devTools;

    return [
      '--no-remote',
      '--foreground',
      if (Platform.isWindows) '--wait-for-browser',
      if (userDataDir != null) '--profile',
      if (userDataDir != null) userDataDir,
      if (headless) '--headless',
      if (devTools) '--devtools',
      if (args == null || args.every((a) => a.startsWith('-'))) 'about:blank',
      ...?args
    ];
  }

  Future<Directory> _createProfile() async {
    final profileDir =
        await Directory.systemTemp.createTemp('puppeteer_dev_firefox_profile-');
    const server = 'dummy.test';
    const defaultPreferences = <String, dynamic>{
      // Make sure Shield doesn't hit the network.
      'app.normandy.api_url': '',
      // Disable Firefox old build background check
      'app.update.checkInstallTime': false,
      // Disable automatically upgrading Firefox
      'app.update.disabledForTesting': true,

      // Increase the APZ content response timeout to 1 minute
      'apz.content_response_timeout': 60000,

      // Prevent various error message on the console
      // jest-puppeteer asserts that no error message is emitted by the console
      'browser.contentblocking.features.standard':
          '-tp,tpPrivate,cookieBehavior0,-cm,-fp',

      // Enable the dump function: which sends messages to the system
      // console
      // https://bugzilla.mozilla.org/show_bug.cgi?id=1543115
      'browser.dom.window.dump.enabled': true,
      // Disable topstories
      'browser.newtabpage.activity-stream.feeds.system.topstories': false,
      // Always display a blank page
      'browser.newtabpage.enabled': false,
      // Background thumbnails in particular cause grief: and disabling
      // thumbnails in general cannot hurt
      'browser.pagethumbnails.capturing_disabled': true,

      // Disable safebrowsing components.
      'browser.safebrowsing.blockedURIs.enabled': false,
      'browser.safebrowsing.downloads.enabled': false,
      'browser.safebrowsing.malware.enabled': false,
      'browser.safebrowsing.passwords.enabled': false,
      'browser.safebrowsing.phishing.enabled': false,

      // Disable updates to search engines.
      'browser.search.update': false,
      // Do not restore the last open set of tabs if the browser has crashed
      'browser.sessionstore.resume_from_crash': false,
      // Skip check for default browser on startup
      'browser.shell.checkDefaultBrowser': false,

      // Disable newtabpage
      'browser.startup.homepage': 'about:blank',
      // Do not redirect user when a milstone upgrade of Firefox is detected
      'browser.startup.homepage_override.mstone': 'ignore',
      // Start with a blank page about:blank
      'browser.startup.page': 0,

      // Do not allow background tabs to be zombified on Android: otherwise for
      // tests that open additional tabs: the test harness tab itself might get
      // unloaded
      'browser.tabs.disableBackgroundZombification': false,
      // Do not warn when closing all other open tabs
      'browser.tabs.warnOnCloseOtherTabs': false,
      // Do not warn when multiple tabs will be opened
      'browser.tabs.warnOnOpen': false,

      // Disable the UI tour.
      'browser.uitour.enabled': false,
      // Turn off search suggestions in the location bar so as not to trigger
      // network connections.
      'browser.urlbar.suggest.searches': false,
      // Disable first run splash page on Windows 10
      'browser.usedOnWindows10.introURL': '',
      // Do not warn on quitting Firefox
      'browser.warnOnQuit': false,

      // Defensively disable data reporting systems
      'datareporting.healthreport.documentServerURI':
          'http://$server/dummy/healthreport/',
      'datareporting.healthreport.logging.consoleEnabled': false,
      'datareporting.healthreport.service.enabled': false,
      'datareporting.healthreport.service.firstRun': false,
      'datareporting.healthreport.uploadEnabled': false,

      // Do not show datareporting policy notifications which can interfere with tests
      'datareporting.policy.dataSubmissionEnabled': false,
      'datareporting.policy.dataSubmissionPolicyBypassNotification': true,

      // DevTools JSONViewer sometimes fails to load dependencies with its require.js.
      // This doesn't affect Puppeteer but spams console (Bug 1424372)
      'devtools.jsonview.enabled': false,

      // Disable popup-blocker
      'dom.disable_open_during_load': false,

      // Enable the support for File object creation in the content process
      // Required for |Page.setFileInputFiles| protocol method.
      'dom.file.createInChild': true,

      // Disable the ProcessHangMonitor
      'dom.ipc.reportProcessHangs': false,

      // Disable slow script dialogues
      'dom.max_chrome_script_run_time': 0,
      'dom.max_script_run_time': 0,

      // Only load extensions from the application and user profile
      // AddonManager.SCOPE_PROFILE + AddonManager.SCOPE_APPLICATION
      'extensions.autoDisableScopes': 0,
      'extensions.enabledScopes': 5,

      // Disable metadata caching for installed add-ons by default
      'extensions.getAddons.cache.enabled': false,

      // Disable installing any distribution extensions or add-ons.
      'extensions.installDistroAddons': false,

      // Disabled screenshots extension
      'extensions.screenshots.disabled': true,

      // Turn off extension updates so they do not bother tests
      'extensions.update.enabled': false,

      // Turn off extension updates so they do not bother tests
      'extensions.update.notifyUser': false,

      // Make sure opening about:addons will not hit the network
      'extensions.webservice.discoverURL': 'http://$server/dummy/discoveryURL',

      // Allow the application to have focus even it runs in the background
      'focusmanager.testmode': true,
      // Disable useragent updates
      'general.useragent.updates.enabled': false,
      // Always use network provider for geolocation tests so we bypass the
      // macOS dialog raised by the corelocation provider
      'geo.provider.testing': true,
      // Do not scan Wifi
      'geo.wifi.scan': false,
      // No hang monitor
      'hangmonitor.timeout': 0,
      // Show chrome errors and warnings in the error console
      'javascript.options.showInConsole': true,

      // Disable download and usage of OpenH264: and Widevine plugins
      'media.gmp-manager.updateEnabled': false,
      // Prevent various error message on the console
      // jest-puppeteer asserts that no error message is emitted by the console
      'network.cookie.cookieBehavior': 0,

      // Do not prompt for temporary redirects
      'network.http.prompt-temp-redirect': false,

      // Disable speculative connections so they are not reported as leaking
      // when they are hanging around
      'network.http.speculative-parallel-limit': 0,

      // Do not automatically switch between offline and online
      'network.manage-offline-status': false,

      // Make sure SNTP requests do not hit the network
      'network.sntp.pools': server,

      // Disable Flash.
      'plugin.state.flash': 0,

      'privacy.trackingprotection.enabled': false,

      // Enable Remote Agent
      // https://bugzilla.mozilla.org/show_bug.cgi?id=1544393
      'remote.enabled': true,

      // Don't do network connections for mitm priming
      'security.certerrors.mitm.priming.enabled': false,
      // Local documents have access to all other local documents,
      // including directory listings
      'security.fileuri.strict_origin_policy': false,
      // Do not wait for the notification button security delay
      'security.notification_enable_delay': 0,

      // Ensure blocklist updates do not hit the network
      'services.settings.server': 'http://$server/dummy/blocklist/',

      // Do not automatically fill sign-in forms with known usernames and
      // passwords
      'signon.autofillForms': false,
      // Disable password capture, so that tests that include forms are not
      // influenced by the presence of the persistent doorhanger notification
      'signon.rememberSignons': false,

      // Disable first-run welcome page
      'startup.homepage_welcome_url': 'about:blank',

      // Disable first-run welcome page
      'startup.homepage_welcome_url.additional': '',

      // Disable browser animations (tabs, fullscreen, sliding alerts)
      'toolkit.cosmeticAnimations.enabled': false,

      // Prevent starting into safe mode after application crashes
      'toolkit.startup.max_resumed_crashes': -1,
    };

    final userJS = <String>[];
    defaultPreferences.forEach((key, value) {
      userJS.add('user_pref(${jsonEncode(key)}, ${jsonEncode(value)});');
    });
    await File('${profileDir.path}/user.js').writeAsString(userJS.join('\n'));
    await File('${profileDir.path}/prefs.js').writeAsString('');

    return profileDir;
  }
}

Future<String> _wsEndpoint(String browserURL) async {
  var response = await read(p.url.join(browserURL, 'json/version'));
  var decodedResponse = jsonDecode(response) as Map<String, dynamic>;

  return decodedResponse['webSocketDebuggerUrl'] as String;
}

Future _killFirefox(Process process) {
  if (Platform.isWindows) {
    // Allow a clean exit on Windows.
    // With `process.kill`, it seems that firefox retain a lock on the user-data directory
    Process.runSync('taskkill', ['/pid', process.pid.toString(), '/T', '/F']);
  } else {
    process.kill(ProcessSignal.sigkill);
  }

  return process.exitCode;
}

final _devToolRegExp = RegExp(r'^DevTools listening on (ws:\/\/.*)$');

Future<String> _waitForWebSocketUrl(Process firefoxProcess) async {
  await for (String line in firefoxProcess.stderr
      .transform(Utf8Decoder())
      .transform(LineSplitter())) {
    _logger.warning('[Firefox stderr]: $line');
    var match = _devToolRegExp.firstMatch(line);
    if (match != null) {
      return match.group(1);
    }
  }
  throw Exception('Websocket url not found');
}

Future<String> _inferExecutablePath() async {
  var executablePath = Platform.environment['PUPPETEER_EXECUTABLE_PATH'];
  if (executablePath != null) {
    var file = File(executablePath);
    if (!file.existsSync()) {
      executablePath = getExecutablePath(executablePath);
      if (!File(executablePath).existsSync()) {
        throw Exception(
            'The environment variable contains PUPPETEER_EXECUTABLE_PATH with '
            'value (${Platform.environment['PUPPETEER_EXECUTABLE_PATH']}) but we cannot '
            'find the Firefox executable');
      }
    }
    return executablePath;
  } else {
    // We download locally a version of firefox and use it.
    return (await downloadFirefox()).executablePath;
  }
}

class LaunchOptions {
  static const DeviceViewport viewportNotSpecified = DeviceViewport(width: -1);
  static const DeviceViewport viewportNotOverride = DeviceViewport(width: -2);
  final List<String> args;
  final DeviceViewport defaultViewport;

  LaunchOptions({@required this.args, @required this.defaultViewport});

  LaunchOptions replace(
      {List<String> args,
      DeviceViewport defaultViewport = viewportNotOverride}) {
    return LaunchOptions(
        args: args ?? this.args,
        defaultViewport: identical(defaultViewport, viewportNotOverride)
            ? this.defaultViewport
            : defaultViewport);
  }

  DeviceViewport get computedDefaultViewport =>
      identical(defaultViewport, LaunchOptions.viewportNotSpecified)
          ? DeviceViewport()
          : defaultViewport;
}
