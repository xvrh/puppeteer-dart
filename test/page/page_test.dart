import 'dart:io';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chrome_downloader.dart';
import 'package:chrome_dev_tools/src/page.dart';
import 'package:logging/logging.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:test/test.dart';
import 'package:shelf/shelf_io.dart' as io;


main() {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);


  HttpServer server;
  Chrome chrome;
  Page page;
  String serverPrefix;
  setUpAll(() async {
    var handler = createStaticHandler('test/data');
    server = await io.serve(handler, 'localhost', 0);

    chrome = await Chrome.start((await downloadChrome()).executablePath);
    serverPrefix = 'http://localhost:${server.port}/';
    page = await chrome.newPage('${serverPrefix}empty.html');
  });

  tearDownAll(() async {
    await chrome.close();
    await server.close(force: true);
  });

  test('Go to', () async {
    await page.goto('${serverPrefix}simple.html');
    var input = await page.$('#one-input');
    expect(await (await input.property('value')).jsonValue, equals('some text'));
    expect(await input.propertyValue('value'), equals('some text'));
  });
}
