import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:puppeteer/src/downloader.dart';

/// Worker script for the cross-process concurrency test.
///
/// Args: `<cachePath> <logDir> <workerId> <barrierFile>`
///
/// 1. Prints "ready" and waits for `barrierFile` to appear (so the parent test
///    can release all workers simultaneously and they actually race).
/// 2. Calls [ensureBrowserDownloaded] with a fake download callback that
///    records itself by creating a file in `logDir`. Counting files in
///    `logDir` tells the parent how many workers actually did the download.
Future<void> main(List<String> args) async {
  final cachePath = args[0];
  final logDir = args[1];
  final workerId = args[2];
  final barrierFile = File(args[3]);

  stdout.writeln('ready');
  while (!barrierFile.existsSync()) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  final info = await ensureBrowserDownloaded(
    cachePath: cachePath,
    version: '1.2.3',
    executableRelPath: p.join('chrome', 'exe'),
    download: (partialDir) async {
      File(
        p.join(logDir, 'download-$workerId-${DateTime.now().microsecondsSinceEpoch}'),
      ).writeAsStringSync('downloaded by $workerId');
      // Long enough that any concurrent worker reaching createSync after us
      // will hit EEXIST and become a waiter.
      await Future<void>.delayed(const Duration(seconds: 2));
      Directory(p.join(partialDir, 'chrome')).createSync(recursive: true);
      File(p.join(partialDir, 'chrome', 'exe')).writeAsStringSync('fake binary');
    },
  );

  stdout.writeln(info.executablePath);
}
