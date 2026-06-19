@Timeout.factor(4)
// On Windows the Chrome download fails to rename its `.downloading` temp dir
// (OS Error 183 — the dir is locked/already exists), so this test is broken on
// Windows runners. Downloading every platform's Chrome is still exercised on
// Linux and macOS.
@OnPlatform({
  'windows': Skip('Chrome download .downloading rename collides on Windows'),
})
library;

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:puppeteer/src/downloader.dart';
import 'package:test/test.dart';

void main() {
  var platformsToTest = Platform.isWindows
      ? [BrowserPlatform.windows32, BrowserPlatform.windows64]
      : BrowserPlatform.values;
  for (var platform in platformsToTest) {
    test('Download on ${platform.name}', () async {
      var info = await downloadChrome(platform: platform);
      expect(File(info.executablePath).lengthSync(), greaterThan(0));
      expect(
        p.join(info.folderPath, getExecutablePath(platform)),
        info.executablePath,
      );
    });
  }
}
