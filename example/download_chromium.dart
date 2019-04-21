import 'dart:io';

import 'package:puppeteer/chrome_downloader.dart';

main() async {
  ChromePath chromePath = await downloadChrome(
      cachePath: Platform.script.resolve('.chrome').toFilePath());
  print(chromePath.executablePath);
}
