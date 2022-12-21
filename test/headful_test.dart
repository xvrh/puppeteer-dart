import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils/utils.dart';

void main() {
  late Server server;
  setUpAll(() async {
    server = await Server.create();
  });

  tearDownAll(() async {
    await server.close();
  });

  tearDown(() async {
    server.clearRoutes();
  });

  var extensionPath = p.join('test', 'assets', 'simple-extension');
  var extensionOptions = [
    '--disable-extensions-except=$extensionPath',
    '--load-extension=$extensionPath',
  ];

  group('HEADFUL', () {
    test('background_page target type should be available', () async {
      var browserWithExtension =
          await puppeteer.launch(headless: false, args: extensionOptions);
      try {
        var page = await browserWithExtension.newPage();
        var backgroundPageTarget = browserWithExtension.targets
            .firstWhereOrNull((t) => t.type == 'background_page');
        backgroundPageTarget ??= await browserWithExtension
            .waitForTarget((target) => target.type == 'background_page');
        expect(backgroundPageTarget, isNotNull);
        await page.close();
      } finally {
        await browserWithExtension.close();
      }
    }, onPlatform: {'windows': Skip('TODO debug on windows')});
    test('target.page() should return a background_page', () async {
      var browserWithExtension =
          await puppeteer.launch(headless: false, args: extensionOptions);
      try {
        var backgroundPageTarget = browserWithExtension.targets
            .firstWhereOrNull((t) => t.type == 'background_page');
        backgroundPageTarget ??= await browserWithExtension
            .waitForTarget((target) => target.type == 'background_page');
        var page = await backgroundPageTarget.page;
        expect(await page.evaluate('() => 2 * 3'), equals(6));
        expect(await page.evaluate('() => window.MAGIC'), equals(42));
      } finally {
        await browserWithExtension.close();
      }
    }, onPlatform: {'windows': Skip('TODO debug on windows')});
    test('should have default url when launching browser', () async {
      var browser = await puppeteer.launch(args: extensionOptions);

      try {
        var pages = (await browser.pages).map((page) => page.url);
        expect(pages, equals(['about:blank']));
      } finally {
        await browser.close();
      }
    });
    test('headless should be able to read cookies written by headful',
        () async {
      var userDataDir = Directory.systemTemp.createTempSync('chrome');
      // Write a cookie in headful chrome
      var headfulBrowser = await puppeteer.launch(
          headless: false, userDataDir: userDataDir.absolute.path);
      try {
        var headfulPage = await headfulBrowser.newPage();
        await headfulPage.goto(server.emptyPage);
        await headfulPage.evaluate(
            "() => document.cookie = 'foo=true; expires=Fri, 31 Dec 9999 23:59:59 GMT'");
      } finally {
        await headfulBrowser.close();
      }

      // Read the cookie from headless chrome
      var headlessBrowser =
          await puppeteer.launch(userDataDir: userDataDir.absolute.path);
      try {
        var headlessPage = await headlessBrowser.newPage();
        await headlessPage.goto(server.emptyPage);
        var cookie = await headlessPage.evaluate('() => document.cookie');
        expect(cookie, equals('foo=true'));
      } finally {
        await headlessBrowser.close();
      }
      // This might throw. See https://github.com/GoogleChrome/puppeteer/issues/2778
      _tryDeleteDirectory(userDataDir);
    }, onPlatform: {'windows': Skip('TODO debug on windows')});
    // TODO:
    test('OOPIF: should report google.com frame', () async {
      // https://google.com is isolated by default in Chromium embedder.
      var browser = await puppeteer.launch(headless: false);
      try {
        var page = await browser.newPage();
        await page.goto(server.emptyPage);
        await page.setRequestInterception(true);
        page.onRequest.listen((r) => r.respond(body: 'YO, GOOGLE.COM'));
        await page.evaluate('''() => {
    var frame = document.createElement('iframe');
    frame.setAttribute('src', 'https://google.com/');
    document.body.appendChild(frame);
    return new Promise(x => frame.onload = x);
    }''');
        await page.waitForSelector('iframe[src="https://google.com/"]');
        var urls = page.frames.map((frame) => frame.url).toList()..sort();
        expect(urls, equals([server.emptyPage, 'https://google.com/']));
      } finally {
        await browser.close();
      }
    },
        skip:
            'Support OOOPIF. @see https://github.com/GoogleChrome/puppeteer/issues/2548');
    test('should close browser with beforeunload page', () async {
      var browser = await puppeteer.launch(headless: false);
      try {
        var page = await browser.newPage();
        await page.goto('${server.prefix}/beforeunload.html');
        // We have to interact with a page so that 'beforeunload' handlers
        // fire.
        await page.click('body');
      } finally {
        await browser.close();
      }
    });
    test('should open devtools when devtools: true option is given', () async {
      var browser = await puppeteer.launch(headless: false, devTools: true);
      try {
        var context = await browser.createIncognitoBrowserContext();
        await Future.wait([
          context.newPage(),
          browser.waitForTarget((target) => target.url.contains('devtools://')),
        ]);
      } finally {
        await browser.close();
      }
    });
  });

  group('Page.bringToFront', () {
    test('should work', () async {
      var browser = await puppeteer.launch(headless: false);
      try {
        var page1 = await browser.newPage();
        var page2 = await browser.newPage();

        await page1.bringToFront();
        expect(await page1.evaluate('() => document.visibilityState'),
            equals('visible'));
        expect(await page2.evaluate('() => document.visibilityState'),
            equals('hidden'));

        await page2.bringToFront();
        expect(await page1.evaluate('() => document.visibilityState'),
            equals('hidden'));
        expect(await page2.evaluate('() => document.visibilityState'),
            equals('visible'));

        await page1.close();
        await page2.close();
      } finally {
        await browser.close();
      }
    });
  });
}

void _tryDeleteDirectory(Directory directory) {
  try {
    directory.deleteSync(recursive: true);
  } catch (_) {}
}
