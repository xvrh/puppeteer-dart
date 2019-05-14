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
import 'plugin.dart';

final Logger _logger = Logger('puppeteer.launcher');

const List<String> _defaultArgs = <String>[
  '--disable-background-networking',
  '--enable-features=NetworkService,NetworkServiceInProcess',
  '--disable-background-timer-throttling',
  '--disable-backgrounding-occluded-windows',
  '--disable-breakpad',
  '--disable-client-side-phishing-detection',
  '--disable-default-apps',
  '--disable-dev-shm-usage',
  '--disable-extensions',
  '--disable-features=site-per-process,TranslateUI',
  '--disable-hang-monitor',
  '--disable-ipc-flooding-protection',
  '--disable-popup-blocking',
  '--disable-prompt-on-repost',
  '--disable-renderer-backgrounding',
  '--disable-sync',
  '--force-color-profile=srgb',
  '--disable-translate',
  '--metrics-recording-only',
  '--no-first-run',
  '--enable-automation',
  '--password-store=basic',
  '--use-mock-keychain',
  '--remote-debugging-port=0',
];

const List<String> _headlessArgs = [
  '--headless',
  '--disable-gpu',
  '--hide-scrollbars',
  '--mute-audio'
];

final puppeteer = Puppeteer._();

/// Launch or connect to a chrome instance
class Puppeteer {
  final plugins = <Plugin>[];

  Puppeteer._();

  /// Start a Chrome instance and connect to the DevTools endpoint.
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
  ///  - `ignoreHTTPSErrors`: Whether to ignore HTTPS errors during navigation.
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
  Future<Browser> launch(
      {String executablePath,
      bool headless,
      bool devTools,
      bool useTemporaryUserData,
      bool noSandboxFlag,
      DeviceViewport defaultViewport = LaunchOptions.viewportNotSpecified,
      bool ignoreHttpsErrors,
      Duration slowMo,
      List<String> args,
      Map<String, String> environment,
      List<Plugin> plugins}) async {
    useTemporaryUserData ??= true;
    devTools ??= false;
    headless ??= !devTools;
    // In docker environment we want to force the '--no-sandbox' flag automatically
    noSandboxFlag ??= Platform.environment['CHROME_FORCE_NO_SANDBOX'] == 'true';

    executablePath = await _inferExecutablePath();

    Directory userDataDir;
    if (useTemporaryUserData) {
      userDataDir = await Directory.systemTemp.createTemp('chrome_');
    }

    var chromeArgs = _defaultArgs.toList();
    if (args != null) {
      chromeArgs.addAll(args);
    }

    if (userDataDir != null) {
      chromeArgs.add('--user-data-dir=${userDataDir.path}');
    }

    if (headless) {
      chromeArgs.addAll(_headlessArgs);
    }
    if (noSandboxFlag) {
      chromeArgs.add('--no-sandbox');
    }
    if (devTools) {
      chromeArgs.add('--auto-open-devtools-for-tabs');
    }

    var launchOptions =
        LaunchOptions(args: chromeArgs, defaultViewport: defaultViewport);

    var allPlugins = plugins.toList();
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
    chromeProcess.exitCode.then((int exitCode) {
      _logger.info('Chrome exit with $exitCode.');
      if (userDataDir != null) {
        _logger.info('Clean ${userDataDir.path}');
        userDataDir.deleteSync(recursive: true);
      }
    });

    var webSocketUrl = await _waitForWebSocketUrl(chromeProcess);
    if (webSocketUrl != null) {
      var connection = await Connection.create(webSocketUrl, delay: slowMo);

      var browser = createBrowser(chromeProcess, connection,
          defaultViewport: launchOptions.computedDefaultViewport,
          closeCallback: () => _killChrome(chromeProcess),
          ignoreHttpsErrors: ignoreHttpsErrors,
          plugins: allPlugins);
      var targetFuture =
          browser.waitForTarget((target) => target.type == 'page');
      await browser.targetApi.setDiscoverTargets(true);
      await targetFuture;
      return browser;
    } else {
      throw Exception('Not able to connect to Chrome DevTools');
    }
  }

  //This methods attaches Puppeteer to an existing Chromium instance.
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
      {String browserWsEndpoint,
      String browserUrl,
      DeviceViewport defaultViewport = LaunchOptions.viewportNotSpecified,
      bool ignoreHttpsErrors,
      Duration slowMo,
      List<Plugin> plugins}) async {
    assert(
        (browserWsEndpoint != null || browserUrl != null) &&
            browserWsEndpoint != browserUrl,
        'Exactly one of browserWSEndpoint, browserURL or transport must be passed to puppeteer.connect');

    var allPlugins = plugins.toList();
    if (plugins != null) {
      allPlugins.addAll(plugins);
    }
    var connectOptions =
        LaunchOptions(args: null, defaultViewport: defaultViewport);
    for (var plugin in allPlugins) {
      connectOptions = await plugin.willLaunchBrowser(connectOptions);
    }

    Connection connection;
    if (browserWsEndpoint != null) {
      connection = await Connection.create(browserWsEndpoint, delay: slowMo);
    } else if (browserUrl != null) {
      var connectionURL = await _wsEndpoint(browserUrl);
      connection = await Connection.create(connectionURL, delay: slowMo);
    }

    var browserContextIds = await connection.targetApi.getBrowserContexts();
    return createBrowser(null, connection,
        browserContextIds: browserContextIds,
        ignoreHttpsErrors: ignoreHttpsErrors,
        defaultViewport: connectOptions.computedDefaultViewport,
        plugins: allPlugins,
        closeCallback: () =>
            connection.send('Browser.close').catchError((e) => null));
  }

  Devices get devices => devices_lib.devices;
}

Future<String> _wsEndpoint(String browserURL) async {
  var response = await read(p.url.join(browserURL, 'json/version'));
  Map decodedResponse = jsonDecode(response);

  return decodedResponse['webSocketDebuggerUrl'];
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
      return match.group(1);
    }
  }
  throw 'Websocket url not found';
}

Future<String> _inferExecutablePath() async {
  String executablePath = Platform.environment['PUPPETEER_EXECUTABLE_PATH'];
  if (executablePath != null) {
    var file = File(executablePath);
    if (!file.existsSync()) {
      executablePath = getExecutablePath(executablePath);
      if (!File(executablePath).existsSync()) {
        throw 'The environment variable contains PUPPETEER_EXECUTABLE_PATH with '
            'value (${Platform.environment['PUPPETEER_EXECUTABLE_PATH']}) but we cannot '
            'find the Chrome executable';
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
