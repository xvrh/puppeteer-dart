import 'package:logging/logging.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';

import '../utils.dart';

main() {
  Logger.root.onRecord.listen(print);

  Server server;
  Browser browser;
  Page page;
  setUpAll(() async {
    server = await Server.create();
    browser = await Browser.start();
  });

  tearDownAll(() async {
    await browser.close();
    await server.close();
  });

  setUp(() async {
    page = await browser.newPage();
    await page.goto(server.emptyPage);
  });

  tearDown(() async {
    await page.close();
  });

  test('Go to', () async {
    await page.goto(server.assetUrl('simple.html'));
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
    await page.goto(server.emptyPage);
    expect(found, isFalse);
    await page.goto(server.assetUrl('grid.html'));
    var handle = await waitFor;
    expect(found, isTrue);
    expect(await handle.propertyValue('className'), equals('box'));
  });

  test('should wait for an xpath', () async {
    var found = false;
    var waitFor = page.waitForXPath('//div').then((handle) => found = true);
    await page.goto(server.emptyPage);
    expect(found, isFalse);
    await page.goto(server.assetUrl('grid.html'));
    await waitFor;
    expect(found, isTrue);
  });

  final addElement =
      //language=js
      'function _(tag) {return document.body.appendChild(document.createElement(tag));}';

  test('should immediately resolve promise if node exists', () async {
    await page.goto(server.emptyPage);
    await page.waitForSelector('*');
    await page.evaluate(addElement, args: ['div']);
    await page.waitForSelector('div');
  });

  test('should resolve promise when node is added', () async {
    await page.goto(server.emptyPage);
    var watchdog = page.waitForSelector('div');
    await page.evaluate(addElement, args: ['br']);
    await page.evaluate(addElement, args: ['div']);
    var eHandle = await watchdog;
    var tagName = await eHandle.propertyValue('tagName');
    expect(tagName, equals('DIV'));
  });

  test('should work with multiline body', () async {
    var result = await page.waitForFunction(
        //language=js
        '''
function _() {
  return (() => true)();
}
''', []);
    expect(await result.jsonValue, isTrue);
  });

  test('should wait for predicate', () async {
    await Future.wait([
      page.waitForFunction(
          //language=js
          '() => window.innerWidth < 100',
          []),
      page.setViewport(DeviceViewport(width: 10, height: 10)),
    ]);
  });
}
