import 'dart:io';
import 'package:chrome_dev_tools/chromium_downloader.dart';

main() async {
  String chromiumPath = await downloadChromium(
      cachePath: Platform.script.resolve('.chromium').toFilePath(),
      revision: 497674);
  print(chromiumPath);
}
