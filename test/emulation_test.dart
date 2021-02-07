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

  group('Page.viewport', () {
    test('should get the proper viewport size', () async {
      expect(page.viewport, equals(DeviceViewport(width: 800, height: 600)));
      await page.setViewport(DeviceViewport(width: 123, height: 456));
      expect(page.viewport, equals(DeviceViewport(width: 123, height: 456)));
    });
    test('should support mobile emulation', () async {
      await page.goto(server.prefix + '/mobile.html');
      expect(await page.evaluate('() => window.innerWidth'), equals(800));
      await page.setViewport(puppeteer.devices.iPhone6.viewport);
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
      await page.setViewport(puppeteer.devices.iPhone6.viewport);
      expect(await page.evaluate("() => 'ontouchstart' in window"), isTrue);
      expect(await page.evaluate(dispatchTouch), equals('Received touch'));
      await page.setViewport(DeviceViewport(width: 100, height: 100));
      expect(await page.evaluate("() => 'ontouchstart' in window"), isFalse);
    });
    test('should be detectable by Modernizr', () async {
      await page.goto(server.prefix + '/detect-touch.html');
      expect(await page.evaluate('() => document.body.textContent.trim()'),
          equals('NO'));
      await page.setViewport(puppeteer.devices.iPhone6.viewport);
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
      await page.setViewport(puppeteer.devices.iPhone6Landscape.viewport);
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
      await page.emulate(puppeteer.devices.iPhone6);
      expect(await page.evaluate('() => window.innerWidth'), equals(375));
      expect(
          await page.evaluate('() => navigator.userAgent'), contains('iPhone'));
    });
    test('should support clicking', () async {
      await page.emulate(puppeteer.devices.iPhone6);
      await page.goto(server.prefix + '/input/button.html');
      var button = await page.$('button');
      await page.evaluate("button => button.style.marginTop = '200px'",
          args: [button]);
      await button.click();
      expect(await page.evaluate('() => result'), equals('Clicked'));
    });
  });

  group('Page.emulateMediaType', () {
    test('should work', () async {
      expect(await page.evaluate("() => window.matchMedia('screen').matches"),
          isTrue);
      expect(await page.evaluate("() => window.matchMedia('print').matches"),
          isFalse);
      await page.emulateMediaType(MediaType.print);
      expect(await page.evaluate("() => window.matchMedia('screen').matches"),
          isFalse);
      expect(await page.evaluate("() => window.matchMedia('print').matches"),
          isTrue);
      await page.emulateMediaType(null);
      expect(await page.evaluate("() => window.matchMedia('screen').matches"),
          isTrue);
      expect(await page.evaluate("() => window.matchMedia('print').matches"),
          isFalse);
    });
    test('should throw in case of bad argument', () async {
      // ignore: deprecated_member_use_from_same_package
      expect(() => page.emulateMedia('bad'), throwsA(anything));
    });
  });

  group('Page.emulateMediaFeatures', () {
    test('should work ddd', () async {
      await page
          .emulateMediaFeatures([MediaFeature.prefersReducedMotion('reduce')]);
      expect(
          await page.evaluate(
              "() => matchMedia('(prefers-reduced-motion: reduce)').matches"),
          isTrue);
      expect(
          await page.evaluate(
              "() => matchMedia('(prefers-reduced-motion: no-preference)').matches"),
          isFalse);
      await page
          .emulateMediaFeatures([MediaFeature.prefersColorsScheme('light')]);
      expect(
          await page.evaluate(
              "() => matchMedia('(prefers-color-scheme: light)').matches"),
          isTrue);
      expect(
          await page.evaluate(
              "() => matchMedia('(prefers-color-scheme: dark)').matches"),
          isFalse);
      expect(
          await page.evaluate(
              "() => matchMedia('(prefers-color-scheme: no-preference)').matches"),
          isFalse);
      await page
          .emulateMediaFeatures([MediaFeature.prefersColorsScheme('dark')]);
      expect(
          await page.evaluate(
              "() => matchMedia('(prefers-color-scheme: dark)').matches"),
          isTrue);
      expect(
          await page.evaluate(
              "() => matchMedia('(prefers-color-scheme: light)').matches"),
          isFalse);
      expect(
          await page.evaluate(
              "() => matchMedia('(prefers-color-scheme: no-preference)').matches"),
          isFalse);
      await page.emulateMediaFeatures([
        MediaFeature.prefersReducedMotion('reduce'),
        MediaFeature.prefersColorsScheme('light')
      ]);
      expect(
          await page.evaluate(
              "() => matchMedia('(prefers-reduced-motion: reduce)').matches"),
          isTrue);
      expect(
          await page.evaluate(
              "() => matchMedia('(prefers-reduced-motion: no-preference)').matches"),
          isFalse);
      expect(
          await page.evaluate(
              "() => matchMedia('(prefers-color-scheme: light)').matches"),
          isTrue);
      expect(
          await page.evaluate(
              "() => matchMedia('(prefers-color-scheme: dark)').matches"),
          isFalse);
      expect(
          await page.evaluate(
              "() => matchMedia('(prefers-color-scheme: no-preference)').matches"),
          isFalse);
    }, skip: 'This is not working in headless and flaky in headful');

    test('should not interfer with emulateMediaType', () async {
      await page.emulateMediaType(MediaType.print);
      expect(await page.evaluate("() => window.matchMedia('screen').matches"),
          isFalse);
      await page
          .emulateMediaFeatures([MediaFeature.prefersColorsScheme('dark')]);
      expect(
          await page.evaluate(
              "() => matchMedia('(prefers-color-scheme: dark)').matches"),
          isTrue);

      await page.emulateMediaFeatures(null);
      expect(
          await page.evaluate(
              "() => matchMedia('(prefers-color-scheme: dark)').matches"),
          isFalse);
      expect(await page.evaluate("() => window.matchMedia('screen').matches"),
          isFalse);

      await page.emulateMediaType(null);
      expect(await page.evaluate("() => window.matchMedia('screen').matches"),
          isTrue);

      await page
          .emulateMediaFeatures([MediaFeature.prefersColorsScheme('dark')]);
      expect(
          await page.evaluate(
              "() => matchMedia('(prefers-color-scheme: dark)').matches"),
          isTrue);
      await page.emulateMediaType(null);
      expect(
          await page.evaluate(
              "() => matchMedia('(prefers-color-scheme: dark)').matches"),
          isTrue);
    }, skip: 'This is not working in headless and flaky in headful');
  });

  group('Page.emulateTimezone', () {
    test('should work', () async {
      await page.evaluate('''() => {
      globalThis.date = new Date(1479579154987);
      }''');
      await page.emulateTimezone('America/Jamaica');
      expect(await page.evaluate('() => date.toString()'),
          equals('Sat Nov 19 2016 13:12:34 GMT-0500 (Eastern Standard Time)'));

      await page.emulateTimezone('Pacific/Honolulu');
      expect(
          await page.evaluate('() => date.toString()'),
          equals(
              'Sat Nov 19 2016 08:12:34 GMT-1000 (Hawaii-Aleutian Standard Time)'));

      await page.emulateTimezone('America/Buenos_Aires');
      expect(
          await page.evaluate('() => date.toString()'),
          equals(
              'Sat Nov 19 2016 15:12:34 GMT-0300 (Argentina Standard Time)'));

      await page.emulateTimezone('Europe/Berlin');
      expect(
          await page.evaluate('() => date.toString()'),
          equals(
              'Sat Nov 19 2016 19:12:34 GMT+0100 (Central European Standard Time)'));
    });

    test('should throw for invalid timezone IDs', () async {
      expect(
          () => page.emulateTimezone('Foo/Bar'),
          throwsA(
              predicate((e) => '$e'.contains('Invalid timezone ID: Foo/Bar'))));
      expect(
          () => page.emulateTimezone('Baz/Qux'),
          throwsA(
              predicate((e) => '$e'.contains('Invalid timezone ID: Baz/Qux'))));
    });
  });
}
