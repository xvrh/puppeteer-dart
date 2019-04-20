import 'dart:io';

import 'package:puppeteer/puppeteer.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';
import 'package:test/test.dart';

main() {
  HttpServer server;
  Page tab;
  Browser chrome;
  setUpAll(() async {
    var handler = createStaticHandler('test/assets');
    server = await io.serve(handler, 'localhost', 0);

    chrome = await Browser.start();
  });

  tearDownAll(() async {
    await chrome.close();
    await server.close(force: true);
  });

  setUp(() async {
    tab = await chrome.newPage();
    await tab.goto('http://localhost:${server.port}/empty.html');
  });

  tearDown(() async {
    await tab.close();
  });

  test('Evaluate simple value', () async {
    expect(await tab.evaluate('true'), equals(true));
    expect(await tab.evaluate('false'), equals(false));
    expect(await tab.evaluate('undefined'), equals(null));
    expect(await tab.evaluate('null'), equals(null));
    expect(await tab.evaluate('1'), equals(1));
    expect(await tab.evaluate('1.5'), equals(1.5));
    expect(await tab.evaluate('"Hello"'), equals('Hello'));
  });

  test('Evaluate List', () async {
    expect(
        await tab.evaluate('[true, false, undefined, null, 1, 1.5, "Hello"]'),
        equals([true, false, null, null, 1, 1.5, "Hello"]));
  });

}
