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
    browser = await puppeteer.launch(defaultViewport: DeviceViewport());
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

  Future<Rectangle> getDimensions() => page.evaluate<Map>('''
function dimensions() {
  const rect = document.querySelector('textarea').getBoundingClientRect();
  return {
    x: rect.left,
    y: rect.top,
    width: rect.width,
    height: rect.height
  };
}
''').then((result) => Rectangle(
        result['x'] as num,
        result['y'] as num,
        result['width'] as num,
        result['height'] as num,
      ));

  group('Mouse', () {
    test('should click the document', () async {
      await page.evaluate('''() => {
  window.clickPromise = new Promise(resolve => {
    document.addEventListener('click', event => {
      resolve({
        type: event.type,
        detail: event.detail,
        clientX: event.clientX,
        clientY: event.clientY,
        isTrusted: event.isTrusted,
        button: event.button
      });
    });
  });
}''');
      await page.mouse.click(Point(50, 60));
      var event = await page.evaluate<Map>('() => window.clickPromise');
      expect(event['type'], equals('click'));
      expect(event['detail'], equals(1));
      expect(event['clientX'], equals(50));
      expect(event['clientY'], equals(60));
      expect(event['isTrusted'], isTrue);
      expect(event['button'], equals(0));
    });
    test('should resize the textarea', () async {
      await page.goto('${server.prefix}/input/textarea.html');
      var dimensions = await getDimensions();
      var mouse = page.mouse;
      await mouse.move(Point(dimensions.left + dimensions.width - 4,
          dimensions.top + dimensions.height - 4));
      await mouse.down();
      await mouse.move(Point(dimensions.left + dimensions.width + 100,
          dimensions.top + dimensions.height + 100));
      await mouse.up();
      var newDimensions = await getDimensions();
      expect(newDimensions.width, equals((dimensions.width + 104).round()));
      expect(newDimensions.height, equals((dimensions.height + 104).round()));
    });
    test('should select the text with mouse', () async {
      await page.goto('${server.prefix}/input/textarea.html');
      await page.focus('textarea');
      var text =
          'This is the text that we are going to try to select. Let\'s see how it goes.';
      await page.keyboard.type(text);
      // Firefox needs an extra frame here after typing or it will fail to set the scrollTop
      await page.evaluate('() => new Promise(requestAnimationFrame)');
      await page
          .evaluate("() => document.querySelector('textarea').scrollTop = 0");
      var dimensions = await getDimensions();
      await page.mouse.move(Point(dimensions.left + 2, dimensions.top + 2));
      await page.mouse.down();
      await page.mouse.move(Point(100, 100));
      await page.mouse.up();
      expect(await page.evaluate('''() => {
      var textarea = document.querySelector('textarea');
      return textarea.value.substring(textarea.selectionStart, textarea.selectionEnd);
      }'''), equals(text));
    });
    test('should trigger hover state', () async {
      await page.goto('${server.prefix}/input/scrollable.html');
      await page.hover('#button-6');
      expect(
          await page
              .evaluate("() => document.querySelector('button:hover').id"),
          equals('button-6'));
      await page.hover('#button-2');
      expect(
          await page
              .evaluate("() => document.querySelector('button:hover').id"),
          equals('button-2'));
      await page.hover('#button-91');
      expect(
          await page
              .evaluate("() => document.querySelector('button:hover').id"),
          equals('button-91'));
    });
    test('should trigger hover state with removed window.Node', () async {
      await page.goto('${server.prefix}/input/scrollable.html');
      await page.evaluate('() => delete window.Node');
      await page.hover('#button-6');
      expect(
          await page
              .evaluate("() => document.querySelector('button:hover').id"),
          equals('button-6'));
    });
    test('should set modifier keys on click', () async {
      await page.goto('${server.prefix}/input/scrollable.html');
      await page.evaluate(
          "() => document.querySelector('#button-3').addEventListener('mousedown', e => window.lastEvent = e, true)");
      var modifiers = {
        Key.shift: 'shiftKey',
        Key.control: 'ctrlKey',
        Key.alt: 'altKey',
        Key.meta: 'metaKey'
      };
      for (var modifier in modifiers.keys) {
        await page.keyboard.down(modifier);
        await page.click('#button-3');
        if ((await page.evaluate('mod => window.lastEvent[mod]',
                args: [modifiers[modifier]])) ==
            null) {
          throw Exception('${modifiers[modifier]} should be true');
        }
        await page.keyboard.up(modifier);
      }
      await page.click('#button-3');
      for (var modifier in modifiers.keys) {
        if ((await page.evaluate('mod => window.lastEvent[mod]',
                    args: [modifiers[modifier]]) ??
                false) !=
            false) {
          throw Exception('${modifiers[modifier]} should be false');
        }
      }
    });
    test('should send mouse wheel events', () async {
      await page.goto('${server.prefix}/input/wheel.html');
      var elem = await page.$('div');
      var boundingBoxBefore = (await elem.boundingBox)!;
      expect(boundingBoxBefore.width, 115);
      expect(boundingBoxBefore.height, 115);

      await page.mouse.move(Point(
          boundingBoxBefore.left + boundingBoxBefore.width / 2,
          boundingBoxBefore.top + boundingBoxBefore.height / 2));

      await page.mouse.wheel(deltaY: -100);
      var boundingBoxAfter = (await elem.boundingBox)!;
      expect([230, 345].contains(boundingBoxAfter.width), isTrue);
      expect([230, 345].contains(boundingBoxAfter.height), isTrue);
    });
    test('should tween mouse movement', () async {
      await page.mouse.move(Point(100, 100));
      await page.evaluate('''() => {
      window.result = [];
          document.addEventListener('mousemove', event => {
          window.result.push([event.clientX, event.clientY]);
          });
    }''');
      await page.mouse.move(Point(200, 300), steps: 5);
      expect(
          await page.evaluate('result'),
          equals([
            [120, 140],
            [140, 180],
            [160, 220],
            [180, 260],
            [200, 300]
          ]));
    });
    test('should work with mobile viewports and cross process navigations',
        () async {
      await page.goto(server.emptyPage);
      await page
          .setViewport(DeviceViewport(width: 360, height: 640, isMobile: true));
      await page.goto('${server.crossProcessPrefix}/mobile.html');
      await page.evaluate('''() => {
      document.addEventListener('click', event => {
        window.result = {
          x: event.clientX, y: event.clientY
        };
      });
    }''');

      await page.mouse.click(Point(30, 40));

      expect(await page.evaluate('result'), equals({'x': 30, 'y': 40}));
    });
  });
}
