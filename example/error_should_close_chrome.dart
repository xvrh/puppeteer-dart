

import 'dart:io';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';

main() async {
  Chrome chrome = await Chrome.start();

  Page page = await chrome.newPage();

  await page.goto('https://google.com');

  var s = await page.screenshot();
  await File('example/_f.png').writeAsBytes(s);

  await chrome.close();
}
