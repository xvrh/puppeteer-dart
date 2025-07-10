@Timeout.factor(4)
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
