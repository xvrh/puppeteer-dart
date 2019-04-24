import 'package:logging/logging.dart';
import 'package:puppeteer/devices.dart' as devices;
import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils.dart';

main() {
  Logger.root.onRecord.listen(print);

  Server server;
  Browser browser;
  Page page;
  setUpAll(() async {
    server = await Server.create();
    browser = await Browser.start(
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
    await page.close();
    page = null;
  });

  group('Page.viewport', () {
    test('should get the proper viewport size', () async {
      expect(page.viewport, equals(DeviceViewport(width: 800, height: 600)));
      await page.setViewport(DeviceViewport(width: 123, height: 456));
      expect(page.viewport, equals(DeviceViewport(width: 123, height: 456)));
    });
    test('should support mobile emulation', () async {
      await page.goto(server.prefix + '/mobile.html');
      expect(await page.evaluate('() => window.innerWidth'), equals(800));
      await page.setViewport(devices.iPhone6.viewport);
      expect(await page.evaluate('() => window.innerWidth'), equals(375));
      await page.setViewport(DeviceViewport(width: 400, height: 300));
      expect(await page.evaluate('() => window.innerWidth'), equals(400));
    });
    test('should support touch emulation', () async {
      var dispatchTouch = '''function dispatchTouch() {
        let fulfill;
        const promise = new Promise(x => fulfill = x);
        window.ontouchstart = function(e) {
          fulfill('Received touch');
        };
        window.dispatchEvent(new Event('touchstart'));

        fulfill('Did not receive touch');

        return promise;
      }''';

      await page.goto(server.prefix + '/mobile.html');
      expect(await page.evaluate("() => 'ontouchstart' in window"), isFalse);
      await page.setViewport(devices.iPhone6.viewport);
      expect(await page.evaluate("() => 'ontouchstart' in window"), isTrue);
      expect(await page.evaluate(dispatchTouch), equals('Received touch'));
      await page.setViewport(DeviceViewport(width: 100, height: 100));
      expect(await page.evaluate("() => 'ontouchstart' in window"), isFalse);
    });
    test('should be detectable by Modernizr', () async {
      await page.goto(server.prefix + '/detect-touch.html');
      expect(await page.evaluate('() => document.body.textContent.trim()'),
          equals('NO'));
      await page.setViewport(devices.iPhone6.viewport);
      await page.goto(server.prefix + '/detect-touch.html');
      expect(await page.evaluate('() => document.body.textContent.trim()'),
          equals('YES'));
    });
    test('should detect touch when applying viewport with touches', () async {
      await page
          .setViewport(DeviceViewport(width: 800, height: 600, hasTouch: true));
      await page.addScriptTag(url: server.prefix + '/modernizr.js');
      expect(await page.evaluate('() => Modernizr.touchevents'), isTrue);
    });
    test('should support landscape emulation', () async {
      await page.goto(server.prefix + '/mobile.html');
      await page.setViewport(devices.iPhone6Landscape.viewport);
      expect(await page.evaluate('() => screen.orientation.type'),
          equals('landscape-primary'));
      await page.setViewport(DeviceViewport(width: 100, height: 100));
      expect(await page.evaluate('() => screen.orientation.type'),
          equals('portrait-primary'));
    });
  });

  group('Page.emulate', () {
    test('should work', () async {
      await page.goto(server.prefix + '/mobile.html');
      await page.emulate(devices.iPhone6);
      expect(await page.evaluate('() => window.innerWidth'), equals(375));
      expect(
          await page.evaluate('() => navigator.userAgent'), contains('iPhone'));
    });
    test('should support clicking', () async {
      await page.emulate(devices.iPhone6);
      await page.goto(server.prefix + '/input/button.html');
      var button = await page.$('button');
      await page.evaluate("button => button.style.marginTop = '200px'",
          args: [button]);
      await button.click();
      expect(await page.evaluate('() => result'), equals('Clicked'));
    });
  });

  group('Page.emulateMedia', () {
    test('should work', () async {
      expect(await page.evaluate("() => window.matchMedia('screen').matches"),
          isTrue);
      expect(await page.evaluate("() => window.matchMedia('print').matches"),
          isFalse);
      await page.emulateMedia('print');
      expect(await page.evaluate("() => window.matchMedia('screen').matches"),
          isFalse);
      expect(await page.evaluate("() => window.matchMedia('print').matches"),
          isTrue);
      await page.emulateMedia(null);
      expect(await page.evaluate("() => window.matchMedia('screen').matches"),
          isTrue);
      expect(await page.evaluate("() => window.matchMedia('print').matches"),
          isFalse);
    });
    test('should throw in case of bad argument', () async {
      expect(() => page.emulateMedia('bad'), throwsA(anything));
    });
  });
}
