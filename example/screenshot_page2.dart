import 'dart:convert';
import 'dart:io';
import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'utils.dart';

main() {
  chromePage((Page page) async {
    await page.goto('https://www.github.com', waitUntil: WaitUntil.networkIdle);

    var screenshot = await page.screenshot(fullPage: true);

    // Save it to a file
    await File.fromUri(Platform.script.resolve('_github.png'))
        .writeAsBytes(screenshot);
  });
}
