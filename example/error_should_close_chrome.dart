

import 'dart:io';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';

import 'utils.dart';

main() async {

  //setupLogger();
  Chrome chrome = await Chrome.start();

  print((await chrome.browser.getVersion()).product.split('/').last);

  var page =await chrome.newPage();

  page.onError.listen((_) {}, onDone: () {
    print('Closed');
  });
  //await Future.delayed(Duration(milliseconds: 100));
  try {
    List results = await Future.wait([
      chrome.close(),
    ]);
    print(results.length);
    print('End');
  } catch (e) {
    print('Error $e');
  }
  await Future.delayed(Duration(milliseconds: 100));
}
