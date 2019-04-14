import 'dart:io';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chrome_downloader.dart';
import 'package:chrome_dev_tools/src/page.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:test/test.dart';
import 'package:shelf/shelf_io.dart' as io;


main() {
  HttpServer server;
  Chrome chrome;
  Page page;
  setUpAll(() async {
    var handler = createStaticHandler('test/data');
    server = await io.serve(handler, 'localhost', 0);

    chrome = await Chrome.start((await downloadChrome()).executablePath);
    page = await chrome.newPage('http://localhost:${server.port}/empty.html');
  });

  tearDownAll(() async {
    await chrome.close();
    await server.close(force: true);
  });

  test('Go to', () async {
    await page.goto('simple.html');
    var input = await page.$('#one-input');
    expect(await input.properties['value'], equals('some text'));
  });
}