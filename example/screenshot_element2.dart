import 'dart:convert';
import 'dart:io';
import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/domains/page.dart';
import 'package:chrome_dev_tools/domains/runtime.dart';
import 'utils.dart';

main() {
  chromePage((Page page) async {

    await page.goto('https://www.github.com', waitUntil: WaitUntil.networkIdle);

    var form = await page.$('form[action="/join"]');

    var screenshot = await form.screenshot(omitBackground: true);

    // Save it to a file
    await File.fromUri(Platform.script.resolve('_github_form.png'))
        .writeAsBytes(screenshot);
  });
}
