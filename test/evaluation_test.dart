import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils/utils.dart';

// ignore_for_file: prefer_interpolation_to_compose_strings

void main() {
  late Server server;
  late Browser browser;
  late Page page;
  setUpAll(() async {
    server = await Server.create();
    browser = await puppeteer.launch(
        defaultViewport: DeviceViewport(width: 800, height: 600));
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
    server.clearRoutes();
    await page.close();
  });

  test('Evaluate simple value', () async {
    expect(await page.evaluate('true'), equals(true));
    expect(await page.evaluate('false'), equals(false));
    expect(await page.evaluate('undefined'), isNull);
    expect(await page.evaluate('null'), isNull);
    expect(await page.evaluate('1'), equals(1));
    expect(await page.evaluate('1.5'), equals(1.5));
    expect(await page.evaluate('"Hello"'), equals('Hello'));
  });

  test('Evaluate List', () async {
    expect(
        await page.evaluate('[true, false, undefined, null, 1, 1.5, "Hello"]'),
        equals([true, false, null, null, 1, 1.5, 'Hello']));
  });

  group('Page.evaluate', () {
    test('should work', () async {
      var result = await page.evaluate('() => 7 * 3');
      expect(result, equals(21));
    });
    test('should transfer BigInt', () async {
      var result = await page.evaluate('a => a', args: [BigInt.from(42)]);
      expect(result, equals(BigInt.from(42)));
    });
    test('should transfer NaN', () async {
      var result = await page.evaluate('a => a', args: [double.nan]);
      expect(result, isNaN);
    });
    test('should transfer -0', () async {
      var result = await page.evaluate('a => a', args: [-0.0]);
      expect(result, isZero);
    });
    test('should transfer Infinity', () async {
      var result =
          await page.evaluate<double>('a => a', args: [double.infinity]);
      expect(result.isInfinite, isTrue);
    });
    test('should transfer -Infinity', () async {
      var result = await page
          .evaluate<double>('a => a', args: [double.negativeInfinity]);
      expect(result.isInfinite, isTrue);
      expect(result.isNegative, isTrue);
    });
    test('should transfer arrays', () async {
      var result = await page.evaluate('a => a', args: [
        [1, 2, 3]
      ]);
      expect(result, equals([1, 2, 3]));
    });
    test('should transfer arrays as arrays, not objects', () async {
      var result = await page.evaluate('a => Array.isArray(a)', args: [
        [1, 2, 3]
      ]);
      expect(result, isTrue);
    });
    test('should modify global environment', () async {
      await page.evaluate('() => window.globalVar = 123');
      expect(await page.evaluate('globalVar'), equals(123));
    });
    test('should evaluate in the page context', () async {
      await page.goto(server.prefix + '/global-var.html');
      expect(await page.evaluate('globalVar'), equals(123));
    });
    test('should return undefined for objects with symbols', () async {
      expect(await page.evaluate("() => [Symbol('foo4')]"), isNull);
    });
    test('should work with function shorthands', () async {
      expect(await page.evaluate('(a, b) => { return a + b; }', args: [1, 2]),
          equals(3));
      expect(
          await page
              .evaluate('async (a, b) => { return a * b; }', args: [2, 4]),
          equals(8));
    });
    test('should work with unicode chars', () async {
      var result = await page.evaluate("a => a['中文字符']", args: [
        {'中文字符': 42}
      ]);
      expect(result, equals(42));
    });
    test('should throw when evaluation triggers reload', () async {
      expect(() => page.evaluate('''() => {
        location.reload();
        return new Promise(() => {});
      }'''), throwsA(anything));
    });
    test('should await promise', () async {
      var result = await page.evaluate('() => Promise.resolve(8 * 7)');
      expect(result, equals(56));
    });
    test('should work right after framenavigated', () async {
      Future<int>? frameEvaluation;
      page.onFrameNavigated.listen((frame) {
        frameEvaluation = frame.evaluate('() => 6 * 7');
      });
      await page.goto(server.emptyPage);
      expect(await frameEvaluation, equals(42));
    });
    test('should work from-inside an exposed function', () async {
      // Setup inpage callback, which calls Page.evaluate
      await page.exposeFunction('callController', (num a, num b) async {
        return await page.evaluate('(a, b) => a * b', args: [a, b]);
      });
      var result = await page.evaluate('''async () => {
      return await callController(9, 3);
      }''');
      expect(result, equals(27));
    });
    test('should reject promise with exception', () async {
      expect(() => page.evaluate('() => not_existing_object.property'),
          throwsA(predicate((e) => '$e'.contains('not_existing_object'))));
    });
    test('should support thrown strings as error messages', () async {
      expect(() => page.evaluate("() => { throw 'qwerty'; }"),
          throwsA(predicate((e) => '$e'.contains('qwerty'))));
    });
    test('should support thrown numbers as error messages', () async {
      expect(() => page.evaluate('() => { throw 100500; }'),
          throwsA(predicate((e) => '$e'.contains('100500'))));
    });
    test('should return complex objects', () async {
      var object = {'foo': 'bar!'};
      var result = await page.evaluate('a => a', args: [object]);
      expect(identical(result, object), isFalse);
      expect(result, equals(object));
    });
    test('should return BigInt', () async {
      var result = await page.evaluate('() => BigInt(42)');
      expect(result, equals(BigInt.from(42)));
    });
    test('should return NaN', () async {
      var result = await page.evaluate('() => NaN');
      expect(result, isNaN);
    });
    test('should return -0', () async {
      var result = await page.evaluate('() => -0');
      expect(result, equals(-0.0));
    });
    test('should return Infinity', () async {
      var result = await page.evaluate('() => Infinity');
      expect(result, equals(double.infinity));
    });
    test('should return -Infinity', () async {
      var result = await page.evaluate('() => -Infinity');
      expect(result, equals(double.negativeInfinity));
    });
    test('should accept "undefined" as one of multiple parameters', () async {
      var result = await page.evaluate(
          "(a, b) => Object.is(a, undefined) && Object.is(b, 'foo')",
          args: [null, 'foo']);
      expect(result, isTrue);
    });
    test('should properly serialize null fields', () async {
      expect(await page.evaluate('() => ({a: undefined})'), equals({}));
    });
    test('should return undefined for non-serializable objects', () async {
      expect(await page.evaluate('() => window'), isNull);
    });
    test('should fail for circular object', () async {
      var result = await page.evaluate('''() => {
          var a = {};
          var b = {a};
          a.b = b;
          return a;
      }''');
      expect(result, isNull);
    });
    test('should accept a string', () async {
      var result = await page.evaluate('1 + 2');
      expect(result, equals(3));
    });
    test('should accept a string with semi colons', () async {
      var result = await page.evaluate('1 + 5;');
      expect(result, equals(6));
    });
    test('should accept a string with comments', () async {
      var result = await page.evaluate('2 + 5;\n// do some math!');
      expect(result, equals(7));
    });
    test('should accept element handle as an argument', () async {
      await page.setContent('<section>42</section>');
      var element = await page.$('section');
      var text = await page.evaluate('e => e.textContent', args: [element]);
      expect(text, equals('42'));
    });
    test('should throw if underlying element was disposed', () async {
      await page.setContent('<section>39</section>');
      var element = await page.$('section');
      expect(element, isNotNull);
      await element.dispose();
      expect(() => page.evaluate('e => e.textContent', args: [element]),
          throwsA(predicate((e) => '$e'.contains('JSHandle is disposed'))));
    });
    test('should throw if elementHandles are from other frames', () async {
      await attachFrame(page, 'frame1', server.emptyPage);
      var bodyHandle = await page.frames[1].$('body');
      expect(
          () => page.evaluate('body => body.innerHTML', args: [bodyHandle]),
          throwsA(predicate((e) => '$e'.contains(
              'JSHandles can be evaluated only in the context they were created'))));
    });
    test('should simulate a user gesture', () async {
      var result = await page.evaluate('''() => {
      document.body.appendChild(document.createTextNode('test'));
          document.execCommand('selectAll');
      return document.execCommand('copy');
    }''');
      expect(result, isTrue);
    });
    test('should throw a nice error after a navigation', () async {
      var executionContext = await page.mainFrame.executionContext;

      await Future.wait([
        page.waitForNavigation(),
        executionContext.evaluate('() => window.location.reload()')
      ]);
      expect(() => executionContext.evaluate('() => null'),
          throwsA(predicate((e) => '$e'.contains('navigation'))));
    });
    test('should not throw an error when evaluation does a navigation',
        () async {
      await page.goto(server.prefix + '/one-style.html');
      var result = await page.evaluate('''() => {
    window.location = '/empty.html';
    return [42];
    }''');
      expect(result, equals([42]));
    });
    test(
        'should throw error with detailed information on exception inside promise',
        () {
      expect(() => page.evaluate('''() => new Promise(() => {
    throw new Error('Error in promise');
    })'''), throwsA(predicate((e) => '$e'.contains('Error in promise'))));
    });
  });

  group('Page.evaluateOnNewDocument', () {
    test('should evaluate before anything else on the page', () async {
      await page.evaluateOnNewDocument('''() => {
window.injected = 123;
}''');
      await page.goto(server.prefix + '/tamperable.html');
      expect(await page.evaluate('() => window.result'), equals(123));
    });
  });

  group('Frame.evaluate', () {
    test('should have different execution contexts', () async {
      await page.goto(server.emptyPage);
      await attachFrame(page, 'frame1', server.emptyPage);
      expect(page.frames.length, equals(2));
      await page.frames[0].evaluate("() => window.FOO = 'foo'");
      await page.frames[1].evaluate("() => window.FOO = 'bar'");
      expect(await page.frames[0].evaluate('() => window.FOO'), equals('foo'));
      expect(await page.frames[1].evaluate('() => window.FOO'), equals('bar'));
    });
    test('should have correct execution contexts', () async {
      await page.goto(server.prefix + '/frames/one-frame.html');
      expect(page.frames.length, equals(2));
      expect(
          await page.frames[0]
              .evaluate('() => document.body.textContent.trim()'),
          equals(''));
      expect(
          await page.frames[1]
              .evaluate('() => document.body.textContent.trim()'),
          equals("Hi, I'm frame"));
    });
    test('should execute after cross-site navigation', () async {
      await page.goto(server.emptyPage);
      var mainFrame = page.mainFrame;
      expect(await mainFrame.evaluate('() => window.location.href'),
          contains(server.hostUrl));
      await page.goto(server.crossProcessPrefix + '/empty.html');
      expect(await mainFrame.evaluate('() => window.location.href'),
          contains('127'));
    });
  });
}
