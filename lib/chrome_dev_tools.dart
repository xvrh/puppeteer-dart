import 'dart:async';
import 'dart:io';
import 'package:chrome_dev_tools/src/connection.dart';
import 'package:chrome_dev_tools/domains/page.dart';
import 'package:chrome_dev_tools/domains/target.dart';
import 'dart:convert';
import 'package:logging/logging.dart';
export 'src/connection.dart' show Connection, Session;
export 'domains/target.dart';

final Logger _logger = new Logger('chrome_dev_tools');

const List<String> _defaultArgs = const <String>[
  '--disable-background-networking',
  '--disable-background-timer-throttling',
  '--disable-client-side-phishing-detection',
  '--disable-default-apps',
  '--disable-dev-shm-usage',
  '--disable-extensions',
  '--disable-hang-monitor',
  '--disable-popup-blocking',
  '--disable-prompt-on-repost',
  '--disable-sync',
  '--disable-translate',
  '--metrics-recording-only',
  '--no-first-run',
  '--safebrowsing-disable-auto-update',
  '--enable-automation',
  '--password-store=basic',
  '--use-mock-keychain',
  '--remote-debugging-port=0',
];

const List<String> _headlessArgs = const [
  '--headless',
  '--disable-gpu',
  '--hide-scrollbars',
  '--mute-audio'
];

class Chrome {
  final Process process;
  final Connection connection;

  Chrome._(this.process, this.connection);

  static Future<Chrome> launch(String chromeExecutable,
      {bool headless: true,
      bool useTemporaryUserData: false,
      bool noSandboxFlag}) async {
    // In docker environment we want to force the '--no-sandbox' flag automatically
    noSandboxFlag ??= Platform.environment['CHROME_FORCE_NO_SANDBOX'] == 'true';

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

    _logger.info('Start $chromeExecutable with $chromeArgs');
    Process chromeProcess = await Process.start(chromeExecutable, chromeArgs);

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

      return new Chrome._(chromeProcess, connection);
    } else {
      throw new Exception('Not able to connect to Chrome DevTools');
    }
  }

  static final RegExp _devToolRegExp =
      new RegExp(r'^DevTools listening on (ws:\/\/.*)$');
  static Future _waitForWebSocketUrl(Process chromeProcess) async {
    await for (String line in chromeProcess.stderr
        .transform(new Utf8Decoder())
        .transform(new LineSplitter())) {
      _logger.warning('[Chrome stderr]: $line');
      Match match = _devToolRegExp.firstMatch(line);
      if (match != null) {
        return match.group(1);
      }
    }
  }

  TargetManager get targets => connection.targets;

  Future<PageManager> newPage() async {
    TargetID targetId = await connection.targets.createTarget('about:blank');
    Session client = await connection.createSession(targetId);

    return new PageManager(client);
  }

  Future closeAllTabs() async {
    for (TargetInfo target in await targets.getTargets()) {
      await targets.closeTarget(target.targetId);
    }
  }

  Future<int> close() {
    if (Platform.isWindows) {
      // Allow a clean exit on Windows.
      // With `process.kill`, it seems that chrome retain a lock on the user-data directory
      Process.runSync('taskkill', ['/pid', process.pid.toString(), '/T', '/F']);
    } else {
      process.kill(ProcessSignal.SIGINT);
    }

    return process.exitCode;
  }
}
