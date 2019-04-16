import 'dart:io';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chrome_downloader.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:test/test.dart';
import 'package:shelf/shelf_io.dart' as io;

main() {
  HttpServer server;
  Tab tab;
  Chrome chrome;
  setUpAll(() async {
    var handler = createStaticHandler('test/data');
    server = await io.serve(handler, 'localhost', 0);

    chrome = await Chrome.start((await downloadChrome()).executablePath);
    tab = await chrome.newTab('http://localhost:${server.port}/empty.html');
  });

  tearDownAll(() async {
    await chrome.close();
    await server.close(force: true);
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

  test('Evaluate Map', () async {
    expect(await tab.evaluate('{ "a": 1 }'), equals({"a": 1}));
    expect(
        await tab.evaluate(
            '{ "a": 1, "b": true, "c": false, "d" : null, "e": 1.5, "f": "Hello" }'),
        equals({
          "a": 1,
          "b": true,
          "c": false,
          "d": null,
          "e": 1.5,
          "f": "Hello"
        }));
  });

  test('Evaluate deep object', () async {
    expect(
        await tab.evaluate('{ "a": {"b": 1} }'),
        equals({
          "a": {"b": 1}
        }));
  });

  test('Get document title', () async {
    expect(await tab.evaluate('document.title'), equals('The title'));
  });
}
