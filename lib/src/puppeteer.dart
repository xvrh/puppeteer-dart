import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'browser.dart';
import 'connection.dart';
import 'devices.dart';
import 'devices.dart' as devices_lib;
import 'downloader.dart';
import 'page/emulation_manager.dart';
import 'plugin.dart';

final Logger _logger = Logger('puppeteer.launcher');

final List<String> _defaultArgs = <String>[
  '--disable-background-networking',
  '--enable-features=NetworkService,NetworkServiceInProcess',
  '--disable-background-timer-throttling',
  '--disable-backgrounding-occluded-windows',
  '--disable-breakpad',
  '--disable-client-side-phishing-detection',
  '--disable-component-extensions-with-background-pages',
  '--disable-default-apps',
  '--disable-dev-shm-usage',
  '--disable-extensions',
  '--disable-features=Translate',
  '--disable-hang-monitor',
  '--disable-ipc-flooding-protection',
  '--disable-popup-blocking',
  '--disable-prompt-on-repost',
  '--disable-renderer-backgrounding',
  '--disable-sync',
  '--force-color-profile=srgb',
  '--metrics-recording-only',
  '--no-first-run',
  '--enable-automation',
  '--password-store=basic',
  '--use-mock-keychain',
];

final List<String> _headlessArgs = [
  '--headless',
  '--hide-scrollbars',
  '--mute-audio',
];

final puppeteer = Puppeteer._();

/// Launch or connect to a chrome instance
class Puppeteer {
  final plugins = <Plugin>[];

  Puppeteer._();

  /// This method starts a Chrome instance and connects to the DevTools endpoint.
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
  ///  - `executablePath`: Path to a Chromium or Chrome executable to run instead
  ///     of the bundled Chromium. . **BEWARE**: Puppeteer is only
  ///     [guaranteed to work](https://github.com/GoogleChrome/puppeteer/#q-why-doesnt-puppeteer-vxxx-work-with-chromium-vyyy)
  ///     with the bundled Chromium, use at your own risk.
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
      {String? executablePath,
      bool? headless,
      bool? devTools,
      String? userDataDir,
      bool? noSandboxFlag,
      DeviceViewport? defaultViewport = LaunchOptions.viewportNotSpecified,
      bool? ignoreHttpsErrors,
      Duration? slowMo,
      List<String>? args,
      /* bool | List */ dynamic ignoreDefaultArgs,
      Map<String, String>? environment,
      List<Plugin>? plugins,
      Duration? timeout}) async {
    devTools ??= false;
    headless ??= !devTools;
    timeout ??= Duration(seconds: 30);

    var chromeArgs = <String>[];
    var defaultArguments = defaultArgs(
        args: args,
        userDataDir: userDataDir,
        devTools: devTools,
        headless: headless,
        noSandboxFlag: noSandboxFlag);
    if (ignoreDefaultArgs == null) {
      chromeArgs.addAll(defaultArguments);
    } else if (ignoreDefaultArgs is List) {
      chromeArgs.addAll(
          defaultArguments.where((arg) => !ignoreDefaultArgs.contains(arg)));
    } else if (args != null) {
      chromeArgs.addAll(args);
    }

    if (!chromeArgs.any((a) => a.startsWith('--remote-debugging-'))) {
      chromeArgs.add('--remote-debugging-port=0');
    }

    Directory? temporaryUserDataDir;
    if (!chromeArgs.any((a) => a.startsWith('--user-data-dir'))) {
      temporaryUserDataDir =
          await Directory.systemTemp.createTemp('puppeteer_dev_profile-');
      chromeArgs.add('--user-data-dir=${temporaryUserDataDir.path}');
    }

    executablePath ??= await _inferExecutablePath();

    var launchOptions =
        LaunchOptions(args: chromeArgs, defaultViewport: defaultViewport);

    var allPlugins = this.plugins.toList();
    if (plugins != null) {
      allPlugins.addAll(plugins);
    }
    for (var plugin in allPlugins) {
      launchOptions = await plugin.willLaunchBrowser(launchOptions);
    }

    _logger.info('Start $executablePath with $chromeArgs');
    var chromeProcess = await Process.start(executablePath, launchOptions.args,
        environment: environment);

    // ignore: unawaited_futures
    var chromeProcessExit = chromeProcess.exitCode.then((exitCode) {
      _logger.info('Chrome exit with $exitCode.');
      if (temporaryUserDataDir != null) {
        try {
          _logger.info('Clean ${temporaryUserDataDir.path}');
          temporaryUserDataDir.deleteSync(recursive: true);
        } catch (error) {
          _logger.info('Delete temporary file failed', error);
        }
      }
    });

    var webSocketUrl = await _waitForWebSocketUrl(chromeProcess)
        .then<String?>((f) => f)
        .timeout(timeout, onTimeout: () => null);
    if (webSocketUrl != null) {
      var connection = await Connection.create(webSocketUrl, delay: slowMo);

      var browser = createBrowser(chromeProcess, connection,
          defaultViewport: launchOptions.computedDefaultViewport,
          closeCallback: () async {
        if (temporaryUserDataDir != null) {
          await _killChrome(chromeProcess);
        } else {
          // If there is a custom data-directory we need to give chrome a chance
          // to save the last data
          // Attempt to close chrome gracefully
          await connection.send('Browser.close').catchError((error) async {
            await _killChrome(chromeProcess);
          });
        }

        return chromeProcessExit;
      }, ignoreHttpsErrors: ignoreHttpsErrors, plugins: allPlugins);
      var targetFuture =
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
  Future<Browser> connect(
      {String? browserWsEndpoint,
      String? browserUrl,
      DeviceViewport? defaultViewport = LaunchOptions.viewportNotSpecified,
      bool? ignoreHttpsErrors,
      Duration? slowMo,
      List<Plugin>? plugins}) async {
    assert(
        (browserWsEndpoint != null || browserUrl != null) &&
            browserWsEndpoint != browserUrl,
        'Exactly one of browserWSEndpoint, browserURL or transport must be passed to puppeteer.connect');

    var allPlugins = this.plugins.toList();
    if (plugins != null) {
      allPlugins.addAll(plugins);
    }
    var connectOptions =
        LaunchOptions(args: null, defaultViewport: defaultViewport);
    for (var plugin in allPlugins) {
      connectOptions = await plugin.willLaunchBrowser(connectOptions);
    }

    Connection? connection;
    if (browserWsEndpoint != null) {
      connection = await Connection.create(browserWsEndpoint, delay: slowMo);
    } else if (browserUrl != null) {
      var connectionURL = await _wsEndpoint(browserUrl);
      connection = await Connection.create(connectionURL, delay: slowMo);
    }

    var browserContextIds = await connection!.targetApi.getBrowserContexts();
    var browser = createBrowser(null, connection,
        browserContextIds: browserContextIds,
        ignoreHttpsErrors: ignoreHttpsErrors,
        defaultViewport: connectOptions.computedDefaultViewport,
        plugins: allPlugins, closeCallback: () async {
      try {
        await connection!.send('Browser.close');
      } catch (e) {
        // ignore
      }
    });
    await browser.targetApi.setDiscoverTargets(true);
    return browser;
  }

  Devices get devices => devices_lib.devices;

  List<String> defaultArgs(
      {bool? devTools,
      bool? headless,
      List<String>? args,
      String? userDataDir,
      bool? noSandboxFlag}) {
    devTools ??= false;
    headless ??= !devTools;
    // In docker environment we want to force the '--no-sandbox' flag automatically
    noSandboxFlag ??= Platform.environment['CHROME_FORCE_NO_SANDBOX'] == 'true';

    return [
      ..._defaultArgs,
      if (userDataDir != null) '--user-data-dir=$userDataDir',
      if (noSandboxFlag) '--no-sandbox',
      if (devTools) '--auto-open-devtools-for-tabs',
      if (headless) ..._headlessArgs,
      if (args == null || args.every((a) => a.startsWith('-'))) 'about:blank',
      ...?args
    ];
  }
}

Future<String> _wsEndpoint(String browserURL) async {
  var response = await read(Uri.parse(p.url.join(browserURL, 'json/version')));
  var decodedResponse = jsonDecode(response) as Map<String, dynamic>;

  return decodedResponse['webSocketDebuggerUrl'] as String;
}

Future _killChrome(Process process) {
  if (Platform.isWindows) {
    // Allow a clean exit on Windows.
    // With `process.kill`, it seems that chrome retain a lock on the user-data directory
    Process.runSync('taskkill', ['/pid', process.pid.toString(), '/T', '/F']);
  } else {
    process.kill(ProcessSignal.sigkill);
  }

  return process.exitCode;
}

final _devToolRegExp = RegExp(r'^DevTools listening on (ws:\/\/.*)$');

Future<String> _waitForWebSocketUrl(Process chromeProcess) async {
  await for (String line in chromeProcess.stderr
      .transform(Utf8Decoder())
      .transform(LineSplitter())) {
    _logger.warning('[Chrome stderr]: $line');
    var match = _devToolRegExp.firstMatch(line);
    if (match != null) {
      return match.group(1)!;
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
            'find the Chrome executable');
      }
    }
    return executablePath;
  } else {
    // We download locally a version of chromium and use it.
    return (await downloadChrome()).executablePath;
  }
}

class LaunchOptions {
  static const DeviceViewport viewportNotSpecified = DeviceViewport(width: -1);
  static const DeviceViewport viewportNotOverride = DeviceViewport(width: -2);
  final List<String> args;
  final DeviceViewport? defaultViewport;

  LaunchOptions({required List<String>? args, required this.defaultViewport})
      : args = args ?? [];

  LaunchOptions replace(
      {List<String>? args,
      DeviceViewport? defaultViewport = viewportNotOverride}) {
    return LaunchOptions(
        args: args ?? this.args,
        defaultViewport: identical(defaultViewport, viewportNotOverride)
            ? this.defaultViewport
            : defaultViewport);
  }

  DeviceViewport? get computedDefaultViewport =>
      identical(defaultViewport, LaunchOptions.viewportNotSpecified)
          ? DeviceViewport()
          : defaultViewport;
}
