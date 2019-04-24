import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import 'browser.dart';
import 'connection.dart';
import 'downloader.dart';
import 'page/emulation_manager.dart';

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

Future<Browser> launch(
    {String executablePath,
    bool headless = true,
    bool useTemporaryUserData = false,
    bool noSandboxFlag,
    DeviceViewport defaultViewport,
    bool ignoreHttpsErrors}) async {
  // In docker environment we want to force the '--no-sandbox' flag automatically
  noSandboxFlag ??= Platform.environment['CHROME_FORCE_NO_SANDBOX'] == 'true';

  executablePath = await _inferExecutablePath();

  Directory userDataDir;
  if (useTemporaryUserData) {
    userDataDir = await Directory.systemTemp.createTemp('chrome_');
  }

  List<String> chromeArgs = _defaultArgs.toList();
  if (userDataDir != null) {
    chromeArgs.add('--user-data-dir=${userDataDir.path}');
  }

  if (headless) {
    chromeArgs.addAll(_headlessArgs);
  }
  if (noSandboxFlag) {
    chromeArgs.add('--no-sandbox');
  }

  _logger.info('Start $executablePath with $chromeArgs');
  Process chromeProcess = await Process.start(executablePath, chromeArgs);

  // ignore: unawaited_futures
  chromeProcess.exitCode.then((int exitCode) {
    _logger.info('Chrome exit with $exitCode.');
    if (userDataDir != null) {
      _logger.info('Clean ${userDataDir.path}');
      userDataDir.deleteSync(recursive: true);
    }
  });

  String webSocketUrl = await _waitForWebSocketUrl(chromeProcess);
  if (webSocketUrl != null) {
    Connection connection = await Connection.create(webSocketUrl);

    Browser browser = createBrowser(connection,
        defaultViewport: defaultViewport,
        closeCallback: () => _killChrome(chromeProcess),
        ignoreHttpsErrors: ignoreHttpsErrors);
    Future targetFuture =
        browser.waitForTarget((target) => target.type == 'page');
    await browser.targetApi.setDiscoverTargets(true);
    await targetFuture;
    return browser;
  } else {
    throw Exception('Not able to connect to Chrome DevTools');
  }
}

Future _killChrome(Process process) {
  if (Platform.isWindows) {
    // Allow a clean exit on Windows.
    // With `process.kill`, it seems that chrome retain a lock on the user-data directory
    Process.runSync('taskkill', ['/pid', process.pid.toString(), '/T', '/F']);
  } else {
    process.kill(ProcessSignal.sigint);
  }

  return process.exitCode;
}

final RegExp _devToolRegExp = RegExp(r'^DevTools listening on (ws:\/\/.*)$');

Future _waitForWebSocketUrl(Process chromeProcess) async {
  await for (String line in chromeProcess.stderr
      .transform(Utf8Decoder())
      .transform(LineSplitter())) {
    _logger.warning('[Chrome stderr]: $line');
    Match match = _devToolRegExp.firstMatch(line);
    if (match != null) {
      return match.group(1);
    }
  }
}

Future<String> _inferExecutablePath() async {
  String executablePath = Platform.environment['puppeteer_PATH'];
  if (executablePath != null) {
    File file = File(executablePath);
    if (!file.existsSync()) {
      executablePath = getExecutablePath(executablePath);
      if (!File(executablePath).existsSync()) {
        throw 'The environment variable contains puppeteer_PATH with '
            'value (${Platform.environment['puppeteer_PATH']}) but we cannot '
            'find the Chrome executable';
      }
    }
    return executablePath;
  } else {
    // We download locally a version of chromium and use it.
    return (await downloadChrome()).executablePath;
  }
}
