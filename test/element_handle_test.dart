import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils/utils.dart';

// ignore_for_file: prefer_interpolation_to_compose_strings

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

  group('ElementHandle.properties', () {
    test('propertyValue', () async {
      await page.goto(server.assetUrl('simple.html'));
      var input = await page.$('input');
      var value = await input.propertyValue('value');
      expect(value, equals('some text'));
    });

    test('non existent property returns null', () async {
      await page.goto(server.assetUrl('simple.html'));
      var input = await page.$('input');
      var value = await input.propertyValue('noexist');
      expect(value, isNull);
    });

    test('null handle', () async {
      await page.goto(server.assetUrl('simple.html'));
      var input = await page.$OrNull('no exist');
      expect(input, isNull);
    });
  });

  group('ElementHandle.boundingBox', () {
    test('should work', () async {
      await page.setViewport(DeviceViewport(width: 500, height: 500));
      await page.goto(server.assetUrl('grid.html'));
      var elementHandle = await page.$('.box:nth-of-type(13)');
      var box = await elementHandle.boundingBox;
      expect(box, equals(Rectangle(100, 50, 50, 50)));
    });
    test('should handle nested frames', () async {
      await page.setViewport(DeviceViewport(width: 500, height: 500));
      await page.goto(server.assetUrl('frames/nested-frames.html'));
      var nestedFrame = page.frames[1].childFrames[1];
      var elementHandle = await nestedFrame.$('div');
      var box = await elementHandle.boundingBox;
      expect(box, equals(Rectangle(28, 182, 264, 18)));
    });
    test('should return null for invisible elements 2', () async {
      await page.setContent('<div style="display:none">hi</div>');
      var element = await page.$('div');
      expect(await element.boundingBox, isNull);
    });
    test('should force a layout', () async {
      await page.setViewport(DeviceViewport(width: 500, height: 500));
      await page
          .setContent('<div style="width: 100px; height: 100px">hello</div>');
      var elementHandle = await page.$('div');
      await page.evaluate("element => element.style.height = '200px'",
          args: [elementHandle]);
      var box = await elementHandle.boundingBox;
      expect(box, equals(Rectangle(8, 8, 100, 200)));
    });
    test('should work with SVG nodes', () async {
      await page.setContent('''
  <svg xmlns="http://www.w3.org/2000/svg" width="500" height="500">
  <rect id="theRect" x="30" y="50" width="200" height="300"></rect>
  </svg>
  ''');
      var element = await page.$('#therect');
      var pptrBoundingBox = (await element.boundingBox)!;
      var webBoundingBox = await page.evaluate('''e => {
  var rect = e.getBoundingClientRect();
  return {x: rect.x, y: rect.y, width: rect.width, height: rect.height};
  }''', args: [element]);
      expect({
        'x': pptrBoundingBox.left,
        'y': pptrBoundingBox.top,
        'width': pptrBoundingBox.width,
        'height': pptrBoundingBox.height
      }, equals(webBoundingBox));
    });
  });

  group('ElementHandle.boxModel', () {
    test('should work', () async {
      await page.goto(server.prefix + '/resetcss.html');

      // Step 1: Add Frame and position it absolutely.
      await attachFrame(page, 'frame1', server.prefix + '/resetcss.html');
      await page.evaluate('''() => {
  var frame = document.querySelector('#frame1');
  frame.style = `
  position: absolute;
  left: 1px;
  top: 2px;
  `;
  }''');

      // Step 2: Add div and position it absolutely inside frame.
      var frame = page.frames[1];
      var divHandle = (await frame.evaluateHandle('''() => {
  var div = document.createElement('div');
  document.body.appendChild(div);
  div.style = `
  box-sizing: border-box;
  position: absolute;
  border-left: 1px solid black;
  padding-left: 2px;
  margin-left: 3px;
  left: 4px;
  top: 5px;
  width: 6px;
  height: 7px;
  `;
  return div;
  }''')).asElement!;

      // Step 3: query div's boxModel and assert box values.
      var box = await divHandle.boxModel;
      expect(box!.width, equals(6));
      expect(box.height, equals(7));
      expect(
          ElementHandle.quadToPoints(box.margin)[0],
          equals(Point(
            1 + 4, // frame.left + div.left
            2 + 5,
          )));
      expect(
          ElementHandle.quadToPoints(box.border)[0],
          equals(Point(
            1 + 4 + 3, // frame.left + div.left + div.margin-left
            2 + 5,
          )));
      expect(
          ElementHandle.quadToPoints(box.padding)[0],
          equals(Point(
            1 + 4 + 3 + 1,
            // frame.left + div.left + div.marginLeft + div.borderLeft
            2 + 5,
          )));
      expect(
          ElementHandle.quadToPoints(box.content)[0],
          equals(Point(
            1 + 4 + 3 + 1 + 2,
            // frame.left + div.left + div.marginLeft + div.borderLeft + dif.paddingLeft
            2 + 5,
          )));
    });

    test('should return null for invisible elements', () async {
      await page.setContent('<div style="display:none">hi</div>');
      var element = await page.$('div');
      expect(await element.boxModel, isNull);
    });
  });

  group('ElementHandle.contentFrame', () {
    test('should work', () async {
      await page.goto(server.emptyPage);
      await attachFrame(page, 'frame1', server.emptyPage);
      var elementHandle = await page.$('#frame1');
      var frame = await elementHandle.contentFrame;
      expect(frame, equals(page.frames[1]));
    });
  });

  group('ElementHandle.click', () {
    test('should work', () async {
      await page.goto(server.prefix + '/input/button.html');
      var button = await page.$('button');
      await button.click(delay: Duration(milliseconds: 50));
      expect(await page.evaluate('() => result'), equals('Clicked'));
    });
    test('should work for Shadow DOM v1', () async {
      await page.goto(server.prefix + '/shadow.html');
      var buttonHandle =
          await page.evaluateHandle<ElementHandle>('() => button');
      await buttonHandle.click();
      expect(await page.evaluate('() => clicked'), isTrue);
    });
    test('should work for TextNodes', () async {
      await page.goto(server.prefix + '/input/button.html');
      var buttonTextNode = await page.evaluateHandle<ElementHandle>(
          "() => document.querySelector('button').firstChild");

      expect(
          buttonTextNode.click,
          throwsA(predicate(
              (e) => '$e' == 'Exception: Node is not of type HTMLElement')));
    });
    test('should throw for detached nodes', () async {
      await page.goto(server.prefix + '/input/button.html');
      var button = await page.$('button');
      await page.evaluate('button => button.remove()', args: [button]);
      expect(
          button.click,
          throwsA(predicate(
              (e) => '$e' == 'Exception: Node is detached from document')));
    });
    test('should throw for hidden nodes', () async {
      await page.goto(server.prefix + '/input/button.html');
      var button = await page.$('button');
      await page
          .evaluate("button => button.style.display = 'none'", args: [button]);
      expect(button.click, throwsA(TypeMatcher<NodeIsNotVisibleException>()));
    });
    test('should throw for recursively hidden nodes', () async {
      await page.goto(server.prefix + '/input/button.html');
      var button = await page.$('button');
      await page.evaluate(
          "button => button.parentElement.style.display = 'none'",
          args: [button]);
      expect(button.click, throwsA(TypeMatcher<NodeIsNotVisibleException>()));
    });
    test('should throw for <br> elements', () async {
      await page.setContent('hello<br>goodbye');
      var br = await page.$('br');
      expect(br.click, throwsA(TypeMatcher<NodeIsNotVisibleException>()));
    });
  });

  group('ElementHandle.hover', () {
    test('should work', () async {
      await page.goto(server.prefix + '/input/scrollable.html');
      var button = await page.$('#button-6');
      await button.hover();
      expect(
          await page
              .evaluate("() => document.querySelector('button:hover').id"),
          equals('button-6'));
    });
  });

  group('ElementHandle.isIntersectingViewport', () {
    test('should work', () async {
      await page.goto(server.prefix + '/offscreenbuttons.html');
      for (var i = 0; i < 11; ++i) {
        var button = await page.$('#btn$i');
        // All but last button are visible.
        var visible = i < 10;
        expect(await button.isIntersectingViewport, equals(visible));
      }
    });
  });
}
