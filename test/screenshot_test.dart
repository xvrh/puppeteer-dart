import 'dart:async';
import 'dart:convert';
import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils/utils.dart';
import 'utils/utils_golden.dart';

// ignore_for_file: prefer_interpolation_to_compose_strings

void main() {
  late Server server;
  late Browser browser;
  late BrowserContext context;
  late Page page;
  setUpAll(() async {
    server = await Server.create();
    browser = await puppeteer.launch(
        defaultViewport: DeviceViewport(deviceScaleFactor: 1));
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

  group('Page.screenshot', () {
    test('should work', () async {
      await page.setViewport(
          DeviceViewport(width: 500, height: 500, deviceScaleFactor: 1));
      await page.goto(server.prefix + '/grid.html');
      var screenshot = await page.screenshot();
      expect(screenshot, equalsGolden('test/golden/screenshot-sanity.png'));
    });
    test('should clip rect', () async {
      await page.setViewport(
          DeviceViewport(width: 500, height: 500, deviceScaleFactor: 1));
      await page.goto(server.prefix + '/grid.html');
      var screenshot =
          await page.screenshot(clip: Rectangle(50, 100, 150, 100));
      expect(screenshot, equalsGolden('test/golden/screenshot-clip-rect.png'));
    });
    test('should get screenshot bigger than the viewport', () async {
      await page.setViewport(
          DeviceViewport(width: 50, height: 50, deviceScaleFactor: 1));
      await page.goto(server.prefix + '/grid.html');
      var screenshot = await page.screenshot(clip: Rectangle(25, 25, 100, 100));
      expect(screenshot,
          equalsGolden('test/golden/screenshot-offscreen-clip.png'));
    });
    test('should run in parallel', () async {
      await page.setViewport(
          DeviceViewport(width: 500, height: 500, deviceScaleFactor: 1));
      await page.goto(server.prefix + '/grid.html');
      var promises = <Future>[];
      for (var i = 0; i < 3; ++i) {
        promises.add(page.screenshot(clip: Rectangle(50 * i, 0, 50, 50)));
      }
      var screenshots = await Future.wait(promises);
      expect(screenshots[1], equalsGolden('test/golden/grid-cell-1.png'));
    });
    test('should take fullPage screenshots', () async {
      await page.setViewport(
          DeviceViewport(width: 500, height: 500, deviceScaleFactor: 1));
      await page.goto(server.prefix + '/grid.html');
      var screenshot = await page.screenshot(fullPage: true);
      expect(
          screenshot, equalsGolden('test/golden/screenshot-grid-fullpage.png'));
    });
    test('should run in parallel in multiple pages', () async {
      var N = 2;
      var pages = await Future.wait(List.filled(N, 0).map((_) async {
        var page = await context.newPage();
        await page.goto(server.prefix + '/grid.html');
        return page;
      }));
      var promises = <Future>[];
      for (var i = 0; i < N; ++i) {
        promises.add(pages[i].screenshot(clip: Rectangle(50 * i, 0, 50, 50)));
      }
      var screenshots = await Future.wait(promises);
      for (var i = 0; i < N; ++i) {
        expect(screenshots[i], equalsGolden('test/golden/grid-cell-$i.png'));
      }
      await Future.wait(pages.map((page) => page.close()));
    });
    test('should allow transparency', () async {
      await page.setViewport(
          DeviceViewport(width: 100, height: 100, deviceScaleFactor: 1));
      await page.goto(server.emptyPage);
      var screenshot = await page.screenshot(omitBackground: true);
      expect(screenshot, equalsGolden('test/golden/transparent.png'));
    });
    test('should render white background on jpeg file', () async {
      await page.setViewport(
          DeviceViewport(width: 100, height: 100, deviceScaleFactor: 1));
      await page.goto(server.emptyPage);
      var screenshot = await page.screenshot(
          omitBackground: true, format: ScreenshotFormat.jpeg);
      expect(screenshot, equalsGolden('test/golden/white.jpg'));
    });
    test('should work with odd clip size on Retina displays', () async {
      await page.setViewport(puppeteer.devices.laptopWithHiDPIScreen.viewport);
      var screenshot = await page.screenshot(clip: Rectangle(0, 0, 11, 11));
      expect(
          screenshot, equalsGolden('test/golden/screenshot-clip-odd-size.png'));
    });
    test('should return base64', () async {
      await page.setViewport(
          DeviceViewport(width: 500, height: 500, deviceScaleFactor: 1));
      await page.goto(server.prefix + '/grid.html');
      var screenshot = await page.screenshotBase64();
      expect(base64Decode(screenshot),
          equalsGolden('test/golden/screenshot-sanity.png'));
    });
  }, tags: ['golden']);

  group('ElementHandle.screenshot', () {
    test('should work', () async {
      await page.setViewport(
          DeviceViewport(width: 500, height: 500, deviceScaleFactor: 1));
      await page.goto(server.prefix + '/grid.html');
      await page.evaluate('() => window.scrollBy(50, 100)');
      var elementHandle = await page.$('.box:nth-of-type(3)');
      var screenshot = await elementHandle.screenshot();
      expect(screenshot,
          equalsGolden('test/golden/screenshot-element-bounding-box.png'));
    });
    test('should take into account padding and border', () async {
      await page.setViewport(DeviceViewport(width: 500, height: 500));
      await page.setContent('''
      something above
      <style>div {
      border: 2px solid blue;
      background: green;
      width: 50px;
      height: 50px;
      }
      </style>
      <div></div>
      ''');
      await Future.delayed(const Duration(milliseconds: 200));
      await page.devTools.animation.setPlaybackRate(12);
      var elementHandle = await page.$('div');
      var screenshot = await elementHandle.screenshot();
      expect(screenshot,
          equalsGolden('test/golden/screenshot-element-padding-border.png'));
    });
    test('should capture full element when larger than viewport', () async {
      await page.setViewport(
          DeviceViewport(width: 500, height: 500, deviceScaleFactor: 1));

      await page.setContent('''
      something above
      <style>
      div.to-screenshot {
      border: 1px solid blue;
      width: 600px;
      height: 600px;
      margin-left: 50px;
      }
          ::-webkit-scrollbar{
      display: none;
      }
      </style>
      <div class="to-screenshot"></div>
      ''');
      var elementHandle = await page.$('div.to-screenshot');
      var screenshot = await elementHandle.screenshot();
      expect(
          screenshot,
          equalsGolden(
              'test/golden/screenshot-element-larger-than-viewport.png'));

      expect(
          await page.evaluate(
              '() => ({ w: window.innerWidth, h: window.innerHeight })'),
          equals({'w': 500, 'h': 500}));
    });
    test('should scroll element into view', () async {
      await page.setViewport(
          DeviceViewport(width: 500, height: 500, deviceScaleFactor: 1));
      await page.setContent('''
      something above
      <style>div.above {
      border: 2px solid blue;
      background: red;
      height: 1500px;
      }
      div.to-screenshot {
      border: 2px solid blue;
      background: green;
      width: 50px;
      height: 50px;
      }
      </style>
      <div class="above"></div>
      <div class="to-screenshot"></div>
      ''');
      var elementHandle = await page.$('div.to-screenshot');
      var screenshot = await elementHandle.screenshot();
      expect(
          screenshot,
          equalsGolden(
              'test/golden/screenshot-element-scrolled-into-view.png'));
    });
    test('should work with a rotated element', () async {
      await page.setViewport(
          DeviceViewport(width: 500, height: 500, deviceScaleFactor: 1));
      await page.setContent('''<div style="position:absolute;
      top: 100px;
      left: 100px;
      width: 100px;
      height: 100px;
      background: green;
      transform: rotate(200deg);">&nbsp;</div>''');
      var elementHandle = await page.$('div');
      var screenshot = await elementHandle.screenshot();
      expect(screenshot,
          equalsGolden('test/golden/screenshot-element-rotate.png'));
    });
    test('should fail to screenshot a detached element', () async {
      await page.setContent('<h1>remove this</h1>');
      var elementHandle = await page.$('h1');
      await page.evaluate('element => element.remove()', args: [elementHandle]);
      expect(
          () => elementHandle.screenshot(),
          throwsA(predicate((e) => '$e'
              .contains('Node is either not visible or not an HTMLElement'))));
    });
    test('should not hang with zero width/height element', () async {
      await page.setContent('<div style="width: 50px; height: 0"></div>');
      var div = await page.$('div');
      expect(() => div.screenshot(),
          throwsA(predicate((e) => '$e'.contains('Node has 0 height.'))));
    });
    test('should work for an element with fractional dimensions', () async {
      await page.setContent(
          '<div style="width:48.51px;height:19.8px;border:1px solid black;"></div>');
      var elementHandle = await page.$('div');
      var screenshot = await elementHandle.screenshot();
      expect(screenshot,
          equalsGolden('test/golden/screenshot-element-fractional.png'));
    });
    test('should work for an element with an offset', () async {
      await page.setContent(
          '<div style="position:absolute; top: 10.3px; left: 20.4px;width:50.3px;height:20.2px;border:1px solid black;"></div>');
      var elementHandle = await page.$('div');
      var screenshot = await elementHandle.screenshot();
      expect(screenshot,
          equalsGolden('test/golden/screenshot-element-fractional-offset.png'));
    });
  }, tags: ['golden']);
}
