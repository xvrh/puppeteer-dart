import 'dart:io';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/src/page/emulation_manager.dart';
import 'package:logging/logging.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:test/test.dart';
import 'package:shelf/shelf_io.dart' as io;

main() {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);

  HttpServer server;
  Browser chrome;
  Page page;
  String serverPrefix;
  setUpAll(() async {
    var handler = createStaticHandler('test/assets');
    server = await io.serve(handler, 'localhost', 0);

    chrome = await Browser.start();
    serverPrefix = 'http://localhost:${server.port}/';
    page = await chrome.newPage();
  });

  tearDownAll(() async {
    await chrome.close();
    await server.close(force: true);
  });

  test('Go to', () async {
    await page.goto('${serverPrefix}simple.html');
    var input = await page.$('#one-input');
    expect(
        await (await input.property('value')).jsonValue, equals('some text'));
    expect(await input.propertyValue('value'), equals('some text'));
  });

  test('Wait for selector', () async {
    var found = false;
    var waitFor = page.waitForSelector('div').then((handle) {
      found = true;
      return handle;
    });
    await page.goto('${serverPrefix}empty.html');
    expect(found, isFalse);
    await page.goto('${serverPrefix}grid.html');
    var handle = await waitFor;
    expect(found, isTrue);
    expect(await handle.propertyValue('className'), equals('box'));
  });

  test('should wait for an xpath', () async {
    var found = false;
    var waitFor = page.waitForXPath('//div').then((handle) => found = true);
    await page.goto('${serverPrefix}empty.html');
    expect(found, isFalse);
    await page.goto('${serverPrefix}grid.html');
    await waitFor;
    expect(found, isTrue);
  });

  final Js addElement = Js.function(
      //language=js
      'function _(tag) {return document.body.appendChild(document.createElement(tag));}');

  test('should immediately resolve promise if node exists', () async {
    await page.goto('${serverPrefix}empty.html');
    await page.waitForSelector('*');
    await page.evaluate(addElement, args: ['div']);
    await page.waitForSelector('div');
  });

  test('should resolve promise when node is added', () async {
    await page.goto('${serverPrefix}empty.html');
    var watchdog = page.waitForSelector('div');
    await page.evaluate(addElement, args: ['br']);
    await page.evaluate(addElement, args: ['div']);
    var eHandle = await watchdog;
    var tagName = await eHandle.propertyValue('tagName');
    expect(tagName, equals('DIV'));
  });

  test('should work with multiline body', () async {
    var result = await page.waitForFunction(Js.function(
        //language=js
        '''
function _() {
  return (() => true)();
}
'''), []);
    expect(await result.jsonValue, isTrue);
  });

  test('should wait for predicate', () async {
    await Future.wait([
      page.waitForFunction(
          //language=js
          Js.function('function _() {return window.innerWidth < 100;}'), []),
      page.setViewport(DeviceViewport(width: 10, height: 10)),
    ]);
  });
}
