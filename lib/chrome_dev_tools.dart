import 'dart:async';
import 'dart:io';
import 'package:chrome_dev_tools/src/connection.dart';
import 'package:chrome_dev_tools/domains/page.dart';
import 'package:chrome_dev_tools/domains/target.dart';
import 'dart:convert';
import 'package:logging/logging.dart';
export 'src/connection.dart' show Connection, Session;

final Logger _logger = new Logger('chrome_dev_tools');

const List<String> _defaultArgs = const <String>[
  '--disable-background-networking',
  '--disable-background-timer-throttling',
  '--disable-client-side-phishing-detection',
  '--disable-default-apps',
  '--disable-hang-monitor',
  '--disable-popup-blocking',
  '--disable-prompt-on-repost',
  '--disable-sync',
  '--enable-automation',
  '--enable-devtools-experiments',
  '--metrics-recording-only',
  '--no-first-run',
  '--password-store=basic',
  '--remote-debugging-port=0',
  '--safebrowsing-disable-auto-update',
  '--use-mock-keychain',
  '--disable-extensions',
];

class Chrome {
  final Process _process;
  final Connection connection;

  Chrome._(this._process, this.connection);

  static final RegExp _devToolRegExp =
      new RegExp(r'^DevTools listening on (ws:\/\/.*)$');
  static Future<Chrome> launch(String binary,
      {bool headless: true, bool useTemporaryUserData: true}) async {
    Directory userDataDir;
    if (useTemporaryUserData) {
      userDataDir = await Directory.systemTemp.createTemp('chrome_');
    }

    List<String> chromeArgs = _defaultArgs.toList();
    if (userDataDir != null) {
      chromeArgs.add('--user-data-dir=${userDataDir.path}');
    }

    if (headless) {
      chromeArgs.addAll(
          ['--headless', '--disable-gpu', '--hide-scrollbars', '--mute-audio']);
    }

    _logger.info('Start $binary with $chromeArgs');
    Process chromeProcess = await Process.start(binary, chromeArgs);

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

  static Future _waitForWebSocketUrl(Process chromeProcess) async {
    await for (String line in chromeProcess.stderr
        .transform(new Utf8Decoder())
        .transform(new LineSplitter())) {
      _logger.warning('Chrome $line');
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

  Future get onClose => _process.exitCode;

  void kill() {
    if (Platform.isWindows) {
      // Allow a clean exit on Windows.
      // With `process.kill`, it seems that chrome retain a lock on the user-data directory
      Process
          .runSync('taskkill', ['/pid', _process.pid.toString(), '/T', '/F']);
    } else {
      _process.kill(ProcessSignal.SIGINT);
    }
  }
}
