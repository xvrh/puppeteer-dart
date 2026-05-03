import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:puppeteer/src/downloader.dart';
import 'package:test/test.dart';

void main() {
  group('ensureBrowserDownloaded', () {
    late Directory tmp;

    setUp(() {
      tmp = Directory.systemTemp.createTempSync('puppeteer-conc-');
    });

    tearDown(() {
      if (tmp.existsSync()) {
        tmp.deleteSync(recursive: true);
      }
    });

    test('fast path: returns immediately when executable exists', () async {
      final versionDir = Directory(p.join(tmp.path, '1.0.0', 'chrome'));
      versionDir.createSync(recursive: true);
      File(p.join(versionDir.path, 'exe')).writeAsStringSync('binary');

      var downloadCalled = false;
      final info = await ensureBrowserDownloaded(
        cachePath: tmp.path,
        version: '1.0.0',
        executableRelPath: p.join('chrome', 'exe'),
        download: (_) async {
          downloadCalled = true;
        },
      );

      expect(downloadCalled, isFalse);
      expect(File(info.executablePath).existsSync(), isTrue);
      expect(info.version, '1.0.0');
    });

    test('concurrent calls in same isolate share a single download', () async {
      var downloadCount = 0;
      Future<DownloadedBrowserInfo> call() => ensureBrowserDownloaded(
            cachePath: tmp.path,
            version: '1.2.3',
            executableRelPath: p.join('chrome', 'exe'),
            download: (partialDir) async {
              downloadCount++;
              await Future<void>.delayed(const Duration(milliseconds: 100));
              Directory(p.join(partialDir, 'chrome')).createSync(recursive: true);
              File(p.join(partialDir, 'chrome', 'exe')).writeAsStringSync('binary');
            },
          );

      final results = await Future.wait([call(), call(), call(), call(), call()]);

      expect(downloadCount, 1, reason: 'Future cache should dedupe concurrent calls');
      for (final r in results) {
        expect(File(r.executablePath).existsSync(), isTrue);
        expect(r.executablePath, results.first.executablePath);
      }
    });

    test('cross-process concurrent download deduplicates', () async {
      final logDir = Directory(p.join(tmp.path, '_log'))..createSync();
      final barrier = File(p.join(tmp.path, '_go'));
      final workerScript = p.join(
        Directory.current.path,
        'test',
        'utils',
        'concurrent_download_worker.dart',
      );

      const workerCount = 4;
      final processes = await Future.wait(List.generate(
        workerCount,
        (i) => Process.start(
          Platform.executable,
          [workerScript, tmp.path, logDir.path, i.toString(), barrier.path],
        ),
      ));

      // Wait until every worker reports "ready" before flipping the barrier,
      // so they all hit ensureBrowserDownloaded near-simultaneously.
      final outputs = List.generate(workerCount, (_) => StringBuffer());
      final readyFutures = <Future<void>>[];
      for (var i = 0; i < workerCount; i++) {
        final lines = processes[i].stdout
            .transform(const SystemEncoding().decoder)
            .transform(const LineSplitter())
            .asBroadcastStream();
        final readyCompleter = Completer<void>();
        lines.listen((line) {
          if (line == 'ready' && !readyCompleter.isCompleted) {
            readyCompleter.complete();
          } else {
            outputs[i].writeln(line);
          }
        }, onDone: () {
          if (!readyCompleter.isCompleted) {
            readyCompleter.complete();
          }
        });
        readyFutures.add(readyCompleter.future);
      }
      await Future.wait(readyFutures);

      barrier.writeAsStringSync('go');

      final exitCodes = await Future.wait(processes.map((p) => p.exitCode));
      for (var i = 0; i < workerCount; i++) {
        expect(exitCodes[i], 0, reason: 'worker $i exited non-zero');
      }

      final downloadCount = logDir.listSync().length;
      expect(downloadCount, 1,
          reason: 'Exactly one process should do the actual download');

      final paths = outputs.map((b) => b.toString().trim()).toSet();
      expect(paths.length, 1,
          reason: 'All workers should report the same path; got $paths');
      expect(File(paths.single).existsSync(), isTrue);
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('atomic rename: <version> never visible until download completes',
        () async {
      final versionPath = p.join(tmp.path, '1.0.0');
      var sawIncomplete = false;
      final completer = Completer<void>();

      final downloadFuture = ensureBrowserDownloaded(
        cachePath: tmp.path,
        version: '1.0.0',
        executableRelPath: p.join('chrome', 'exe'),
        download: (partialDir) async {
          // Inside the partial dir, create the executable then signal.
          Directory(p.join(partialDir, 'chrome')).createSync(recursive: true);
          File(p.join(partialDir, 'chrome', 'exe')).writeAsStringSync('binary');
          // While this download "runs", the version directory must not exist yet.
          if (Directory(versionPath).existsSync()) {
            sawIncomplete = true;
          }
          completer.complete();
          await Future<void>.delayed(const Duration(milliseconds: 50));
        },
      );

      await completer.future;
      // At this point the download callback is mid-flight (not yet renamed).
      expect(Directory(versionPath).existsSync(), isFalse,
          reason: 'version dir must not exist until download completes');

      await downloadFuture;
      expect(Directory(versionPath).existsSync(), isTrue);
      expect(sawIncomplete, isFalse);
    });

    test('stale lock file is recovered after staleThreshold', () async {
      File(p.join(tmp.path, '1.0.0.downloading.lock')).createSync();
      // Wait so the lock file's mtime is older than the staleThreshold below.
      await Future<void>.delayed(const Duration(milliseconds: 100));

      var downloadRan = false;
      final info = await ensureBrowserDownloaded(
        cachePath: tmp.path,
        version: '1.0.0',
        executableRelPath: p.join('chrome', 'exe'),
        download: (partialDir) async {
          downloadRan = true;
          Directory(p.join(partialDir, 'chrome')).createSync(recursive: true);
          File(p.join(partialDir, 'chrome', 'exe')).writeAsStringSync('binary');
        },
        staleThreshold: const Duration(milliseconds: 50),
        waitTimeout: const Duration(seconds: 5),
      );

      expect(downloadRan, isTrue);
      expect(File(info.executablePath).existsSync(), isTrue);
    });

    test('owner failure: waiter retries when .downloading disappears without exe',
        () async {
      // Simulate: one caller fails (callback throws), another caller succeeds.
      final firstFailed = Completer<void>();

      final failingCall = ensureBrowserDownloaded(
        cachePath: tmp.path,
        version: '1.0.0',
        executableRelPath: p.join('chrome', 'exe'),
        download: (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          firstFailed.complete();
          throw StateError('simulated owner failure');
        },
      );

      // Wait until the failing call is in progress, then start a second call.
      // Since both are in the same isolate, the Future cache will return the
      // same Future to both — so we need to start the second call AFTER the
      // first one's Future has been removed from the cache (i.e., after it
      // throws). Awaiting the failing call's error first achieves that.
      await expectLater(failingCall, throwsStateError);

      // Now the .downloading dir should be cleaned up by the owner before it
      // released. A subsequent call should succeed.
      final info = await ensureBrowserDownloaded(
        cachePath: tmp.path,
        version: '1.0.0',
        executableRelPath: p.join('chrome', 'exe'),
        download: (partialDir) async {
          Directory(p.join(partialDir, 'chrome')).createSync(recursive: true);
          File(p.join(partialDir, 'chrome', 'exe')).writeAsStringSync('binary');
        },
      );

      expect(File(info.executablePath).existsSync(), isTrue);
      expect(firstFailed.isCompleted, isTrue);
    });
  });
}
