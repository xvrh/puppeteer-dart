import 'dart:convert';
import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils/utils.dart';

void main() {
  late Server server;
  late Browser browser;
  late BrowserContext context;
  late Page page;
  setUpAll(() async {
    server = await Server.create();
    browser = await puppeteer.launch();
  });

  tearDownAll(() async {
    await server.close();
    await browser.close();
  });

  setUp(() async {
    context = await browser.createIncognitoBrowserContext();
    page = await context.newPage();
  });

  tearDown(() async {
    server.clearRoutes();
    await context.close();
  });

  group('Page.evaluateHandle', () {
    test('should work', () async {
      var windowHandle = await page.evaluateHandle('() => window');
      expect(windowHandle, isNotNull);
    });
    test('should accept object handle as an argument', () async {
      var navigatorHandle = await page.evaluateHandle('() => navigator');
      var text =
          await page.evaluate('e => e.userAgent', args: [navigatorHandle]);
      expect(text, contains('Mozilla'));
    });
    test('should accept object handle to primitive types', () async {
      var aHandle = await page.evaluateHandle('() => 5');
      var isFive = await page.evaluate('e => Object.is(e, 5)', args: [aHandle]);
      expect(isFive, isTrue);
    });
    test('should warn on nested object handles', () async {
      var aHandle = await page.evaluateHandle('() => document.body');
      expect(
          () => page.evaluateHandle("opts => opts.elem.querySelector('p')",
                  args: [
                    {'elem': aHandle}
                  ]),
          throwsA(TypeMatcher<JsonUnsupportedObjectError>()));
    });
    test('should accept object handle to unserializable value', () async {
      var aHandle = await page.evaluateHandle('() => Infinity');
      expect(
          await page.evaluate('e => Object.is(e, Infinity)', args: [aHandle]),
          isTrue);
    });
    test('should use the same JS wrappers', () async {
      var aHandle = await page.evaluateHandle('''() => {
  window.FOO = 123;
  return window;
  }''');
      expect(await page.evaluate('e => e.FOO', args: [aHandle]), equals(123));
    });
    test('should work with primitives', () async {
      var aHandle = await page.evaluateHandle('''() => {
  window.FOO = 123;
  return window;
  }''');
      expect(await page.evaluate('e => e.FOO', args: [aHandle]), equals(123));
    });
  });

  group('JSHandle.getProperty', () {
    test('should work', () async {
      var aHandle = await page.evaluateHandle('''() => ({
  one: 1,
  two: 2,
  three: 3
  })''');
      var twoHandle = await aHandle.property('two');
      expect(await twoHandle.jsonValue, equals(2));
    });
  });

  group('JSHandle.jsonValue', () {
    test('should work', () async {
      var aHandle = await page.evaluateHandle("() => ({foo: 'bar'})");
      var json = await aHandle.jsonValue;
      expect(json, equals({'foo': 'bar'}));
    });
    test('should not work with dates', () async {
      var dateHandle = await page
          .evaluateHandle("() => new Date('2017-09-26T00:00:00.000Z')");
      var json = await dateHandle.jsonValue;
      expect(json, equals({}));
    });
    test('should throw for circular objects', () async {
      var windowHandle = await page.evaluateHandle('window');
      expect(
          () => windowHandle.jsonValue,
          throwsA(
              predicate((e) => '$e' == 'Object reference chain is too long')));
    });
  });

  group('JSHandle.getProperties', () {
    test('should work', () async {
      var aHandle = await page.evaluateHandle("""() => ({
  foo: 'bar'
  })""");
      var properties = await aHandle.properties;
      var foo = properties['foo'];
      expect(foo, isNotNull);
      expect(await foo!.jsonValue, equals('bar'));
    });
    test('should return even non-own properties', () async {
      var aHandle = await page.evaluateHandle("""() => {
  class A {
  constructor() {
  this.a = '1';
  }
  }
  class B extends A {
  constructor() {
  super();
  this.b = '2';
  }
  }
  return new B();
  }""");
      var properties = await aHandle.properties;
      expect(await properties['a']!.jsonValue, equals('1'));
      expect(await properties['b']!.jsonValue, equals('2'));
    });
  });

  group('JSHandle.asElement', () {
    test('should work', () async {
      var aHandle = await page.evaluateHandle('() => document.body');
      var element = aHandle.asElement;
      expect(element, isNotNull);
    });
    test('should return null for non-elements', () async {
      var aHandle = await page.evaluateHandle('() => 2');
      var element = aHandle.asElement;
      expect(element, isNull);
    });
    test('should return ElementHandle for TextNodes', () async {
      await page.setContent('<div>ee!</div>');
      var aHandle = await page
          .evaluateHandle("() => document.querySelector('div').firstChild");
      var element = aHandle.asElement;
      expect(element, isNotNull);
      expect(
          await page.evaluate('e => e.nodeType === HTMLElement.TEXT_NODE',
              args: [element]),
          isTrue);
    });
    test('should work with nullified Node', () async {
      await page.setContent('<section>test</section>');
      await page.evaluate('() => delete Node');
      var handle =
          await page.evaluateHandle("() => document.querySelector('section')");
      var element = handle.asElement;
      expect(element, isNotNull);
    });
  });

  group('JSHandle.toString', () {
    test('should work for primitives', () async {
      var numberHandle = await page.evaluateHandle('() => 2');
      expect(numberHandle.toString(), equals('JSHandle:2'));
      var stringHandle = await page.evaluateHandle("() => 'a'");
      expect(stringHandle.toString(), equals('JSHandle:a'));
    });
    test('should work for complicated objects', () async {
      var aHandle = await page.evaluateHandle('() => window');
      expect(aHandle.toString(), equals('JSHandle@object'));
    });
    test('should work with different subtypes', () async {
      expect((await page.evaluateHandle('(function(){})')).toString(),
          equals('JSHandle@function'));
      expect(
          (await page.evaluateHandle('12')).toString(), equals('JSHandle:12'));
      expect((await page.evaluateHandle('true')).toString(),
          equals('JSHandle:true'));
      expect((await page.evaluateHandle('undefined')).toString(),
          equals('JSHandle:null'));
      expect((await page.evaluateHandle('"foo"')).toString(),
          equals('JSHandle:foo'));
      expect((await page.evaluateHandle('Symbol()')).toString(),
          equals('JSHandle@symbol'));
      expect((await page.evaluateHandle('new Map()')).toString(),
          equals('JSHandle@map'));
      expect((await page.evaluateHandle('new Set()')).toString(),
          equals('JSHandle@set'));
      expect((await page.evaluateHandle('[]')).toString(),
          equals('JSHandle@array'));
      expect((await page.evaluateHandle('null')).toString(),
          equals('JSHandle:null'));
      expect((await page.evaluateHandle('/foo/')).toString(),
          equals('JSHandle@regexp'));
      expect((await page.evaluateHandle('document.body')).toString(),
          equals('JSHandle@node'));
      expect((await page.evaluateHandle('new Date()')).toString(),
          equals('JSHandle@date'));
      expect((await page.evaluateHandle('new WeakMap()')).toString(),
          equals('JSHandle@weakmap'));
      expect((await page.evaluateHandle('new WeakSet()')).toString(),
          equals('JSHandle@weakset'));
      expect((await page.evaluateHandle('new Error()')).toString(),
          equals('JSHandle@error'));
      expect((await page.evaluateHandle('new Int32Array()')).toString(),
          equals('JSHandle@typedarray'));
      expect((await page.evaluateHandle('new Proxy({}, {})')).toString(),
          equals('JSHandle@proxy'));
    });
  });
}
