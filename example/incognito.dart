import 'dart:async';
import 'dart:io';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chrome_downloader.dart';
import 'package:logging/logging.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf/shelf_io.dart' as io;

main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  var handler = createStaticHandler('example');
  HttpServer server = await io.serve(handler, 'localhost', 0);

  try {
    String chromeExecutable = (await downloadChrome()).executablePath;
    Chrome chrome = await Chrome.start(chromeExecutable);

    String pageUrl = 'http://localhost:${server.port}/html/incognito.html';
    try {
      Tab normalTab1 = await chrome.newTab(pageUrl);
      Tab normalTab2 = await chrome.newTab(pageUrl);
      Tab incognitoTab1 = await chrome.newTab(pageUrl, incognito: true);

      await Future.wait([
        normalTab1.waitUntilNetworkIdle(),
        normalTab2.waitUntilNetworkIdle(),
        incognitoTab1.waitUntilNetworkIdle(),
      ]);

      await normalTab1.runtime
          .evaluate('window.localStorage.setItem("name", "xavier")');

      var itemValue = await normalTab2.runtime
          .evaluate('window.localStorage.getItem("name")', returnByValue: true);
      assert(itemValue.result.value == 'xavier');

      var incognitoValue = await incognitoTab1.runtime
          .evaluate('window.localStorage.getItem("name")', returnByValue: true);
      assert(incognitoValue.result.value == null);

      print('${itemValue.result.value} vs ${incognitoValue.result.value}');
    } finally {
      await chrome.close();
    }
  } finally {
    await server.close(force: true);
  }
}
