import 'dart:io';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:logging/logging.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:test/test.dart';
import 'package:shelf/shelf_io.dart' as io;

main() async {
  /*Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);*/

  HttpServer server;
  Chrome chrome;
  Page page;
  String serverPrefix;
  var handler = createStaticHandler('test/assets');
  server = await io.serve(handler, 'localhost', 0);

  chrome = await Chrome.start();
  serverPrefix = 'http://localhost:${server.port}/';
  page = await chrome.newPage();
  await page.goto('${serverPrefix}empty.html');

  try {
    var result = await page.waitForFunction(Js.expression('true'), []);
    //expect(await result.jsonValue, isTrue);
    //var watchdog = await page.waitForSelector('body');
    print('Yes');
    print(await page.title);
  } finally {
    await chrome.close();
    await server.close(force: true);
  }

}
