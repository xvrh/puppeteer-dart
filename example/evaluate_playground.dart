

import 'dart:io';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:logging/logging.dart';

import 'utils.dart';

main() async {
  Logger.root.onRecord.listen(print);

  var browser = await Browser.start();
  var page = await browser.newPage();

  var result = await page.evaluate(Js.function('''
() => true;
  '''));
  print(result);

  await browser.close();
}
