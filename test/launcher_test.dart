import 'dart:async';
import 'dart:io';
import 'package:puppeteer/puppeteer.dart';
import 'package:shelf/shelf.dart' as shelf;
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
  group('Puppeteer', () {
    group('Browser.disconnect', () {
      test('should reject navigation when browser closes', () async {
        server.setRoute('/one-style.css', (request) {
          return Completer<shelf.Response>().future;
        });
        var browser = await puppeteer.launch();
        try {
          var remote =
              await puppeteer.connect(browserWsEndpoint: browser.wsEndpoint);
          var page = await remote.newPage();
          var navigationPromise = page
              .goto('${server.prefix}/one-style.html',
                  timeout: const Duration(seconds: 60000))
              .then<dynamic>((e) => e)
              .catchError((e) => e);
          await server.waitForRequest('/one-style.css');
          remote.disconnect();
          var error = await navigationPromise;
          expect(
              error.toString(),
              equals(
                  'Exception: Navigation failed because browser has disconnected!'));
        } finally {
          await browser.close();
        }
      });
      test('should reject waitForSelector when browser closes', () async {
        server.setRoute(
            '/empty.html', (request) => Completer<shelf.Response>().future);
        var browser = await puppeteer.launch();
        var remote =
            await puppeteer.connect(browserWsEndpoint: browser.wsEndpoint);
        var page = await remote.newPage();
        var watchdog = page
            .waitForSelector('div',
                timeout: const Duration(milliseconds: 60000))
            .then<dynamic>((e) => e)
            .catchError((e) => e);
        remote.disconnect();
        var error = await watchdog;
        expect(error.toString(), contains('Protocol error'));
        await browser.close();
      });
    });
    group('Browser.close', () {
      test('should terminate network waiters', () async {
        var browser = await puppeteer.launch();
        var remote =
            await puppeteer.connect(browserWsEndpoint: browser.wsEndpoint);
        var newPage = await remote.newPage();
        var results = await Future.wait<dynamic>([
          newPage
              .waitForRequest(server.emptyPage)
              .then<dynamic>((e) => e)
              .catchError((e) => e),
          newPage
              .waitForResponse(server.emptyPage)
              .then<dynamic>((e) => e)
              .catchError((e) => e),
          browser.close()
        ]);
        for (var i = 0; i < 2; i++) {
          var message = results[i].message;
          expect(message, contains('No element'));
          expect(message, isNot(contains('Timeout')));
        }
      });
    });
    group('Puppeteer.launch', () {
      test('should reject all promises when browser is closed', () async {
        var browser = await puppeteer.launch();
        var page = await browser.newPage();
        var neverResolves =
            page.evaluate('() => new Promise(r => {})').catchError((e) => e);
        await browser.close();
        var error = await neverResolves;
        expect(error, isA<TargetClosedException>());
      });
      test('should reject if executable path is invalid', () {
        expect(() => puppeteer.launch(executablePath: 'random-invalid-path'),
            throwsA(predicate((e) => '$e'.contains('ProcessException: '))));
      });
      test('userDataDir option', () async {
        var userDataDir = Directory.systemTemp.createTempSync('chrome');
        var browser = await puppeteer.launch(userDataDir: userDataDir.path);
        // Open a page to make sure its functional.
        await browser.newPage();
        expect(
            userDataDir.listSync(recursive: true), hasLength(greaterThan(0)));
        await browser.close();
        expect(
            userDataDir.listSync(recursive: true), hasLength(greaterThan(0)));
        _tryDeleteDirectory(userDataDir);
      });
      test('userDataDir argument', () async {
        var userDataDir = Directory.systemTemp.createTempSync('chrome');
        var args = ['--user-data-dir=${userDataDir.path}'];

        var browser = await puppeteer.launch(args: args);
        await browser.newPage();
        expect(
            userDataDir.listSync(recursive: true), hasLength(greaterThan(0)));
        await browser.close();
        expect(
            userDataDir.listSync(recursive: true), hasLength(greaterThan(0)));
        _tryDeleteDirectory(userDataDir);
      });
      test('userDataDir option should restore state', () async {
        var userDataDir = Directory.systemTemp.createTempSync('chrome');
        try {
          var browser =
              await puppeteer.launch(userDataDir: userDataDir.absolute.path);
          var page = await browser.newPage();
          await page.goto(server.emptyPage);
          await page.evaluate("() => localStorage.hey = 'hello'");
          await browser.close();

          var browser2 =
              await puppeteer.launch(userDataDir: userDataDir.absolute.path);
          var page2 = await browser2.newPage();
          await page2.goto(server.emptyPage);
          expect(
              await page2.evaluate('() => localStorage.hey'), equals('hello'));
          await browser2.close();
        } finally {
          _tryDeleteDirectory(userDataDir);
        }
      });
      test('userDataDir option should restore cookies', () async {
        var userDataDir = Directory.systemTemp.createTempSync('chrome');
        try {
          var browser = await puppeteer.launch(userDataDir: userDataDir.path);
          var page = await browser.newPage();
          await page.goto(server.emptyPage);
          await page.evaluate(
              "() => document.cookie = 'doSomethingOnlyOnce=true; expires=Fri, 31 Dec 9999 23:59:59 GMT'");
          await browser.close();

          var browser2 = await puppeteer.launch(userDataDir: userDataDir.path);
          var page2 = await browser2.newPage();
          await page2.goto(server.emptyPage);
          expect(await page2.evaluate('() => document.cookie'),
              equals('doSomethingOnlyOnce=true'));
          await browser2.close();
        } finally {
          _tryDeleteDirectory(userDataDir);
        }
      }, onPlatform: {
        'windows': Skip(
            'This mysteriously fails on Windows. See https://github.com/GoogleChrome/puppeteer/issues/4111')
      });
      test('should return the default arguments', () {
        expect(puppeteer.defaultArgs(), contains('--no-first-run'));
        expect(puppeteer.defaultArgs(), contains('--headless'));
        expect(puppeteer.defaultArgs(headless: false),
            isNot(contains('--headless')));
        expect(puppeteer.defaultArgs(userDataDir: 'foo'),
            contains('--user-data-dir=foo'));
      });
      test('should work with no default arguments', () async {
        var browser = await puppeteer.launch(ignoreDefaultArgs: true);
        var page = await browser.newPage();
        expect(await page.evaluate('11 * 11'), equals(121));
        await page.close();
        await browser.close();
      }, skip: 'manual test, it launchs a browser headful');
      test('should filter out ignored default arguments', () async {
        //TODO(xha): implement the feature and find a way to test it;
      });
      test('should have default url when launching browser', () async {
        var browser = await puppeteer.launch();
        var pages = (await browser.pages).map((page) => page.url);
        expect(pages, equals(['about:blank']));
        await browser.close();
      });
      test('should have custom url when launching browser', () async {
        var browser = await puppeteer.launch(args: [server.emptyPage]);
        var pages = await browser.pages;
        expect(pages.length, equals(1));
        if (pages[0].url != server.emptyPage) {
          await pages[0].waitForNavigation();
        }
        expect(pages[0].url, equals(server.emptyPage));
        await browser.close();
      });
      test('should set the default viewport', () async {
        var browser = await puppeteer.launch(
            defaultViewport: DeviceViewport(width: 456, height: 789));
        var page = await browser.newPage();
        expect(await page.evaluate('window.innerWidth'), equals(456));
        expect(await page.evaluate('window.innerHeight'), equals(789));
        await browser.close();
      });
      test('should disable the default viewport', () async {
        var browser = await puppeteer.launch(defaultViewport: null);
        var page = await browser.newPage();
        expect(page.viewport, isNull);
        await browser.close();
      });
      test('should take fullPage screenshots when defaultViewport is null',
          () async {
        var browser = await puppeteer.launch(defaultViewport: null);
        var page = await browser.newPage();
        await page.goto('${server.prefix}/grid.html');
        var screenshot = await page.screenshot(fullPage: true);
        expect(screenshot, isNotNull);
        await browser.close();
      });
    });
    group('Puppeteer.connect', () {
      test('should be able to connect multiple times to the same browser',
          () async {
        var originalBrowser = await puppeteer.launch();
        var browser = await puppeteer.connect(
            browserWsEndpoint: originalBrowser.wsEndpoint);
        var page = await browser.newPage();
        expect(await page.evaluate('() => 7 * 8'), equals(56));
        browser.disconnect();

        var secondPage = await originalBrowser.newPage();
        expect(await secondPage.evaluate('() => 7 * 6'), equals(42),
            reason: 'original browser should still work');
        await originalBrowser.close();
      });
      test('should be able to close remote browser', () async {
        var originalBrowser = await puppeteer.launch();
        var remoteBrowser = await puppeteer.connect(
            browserWsEndpoint: originalBrowser.wsEndpoint);
        await Future.wait([
          originalBrowser.disconnected,
          remoteBrowser.close(),
        ]);
      });

      test('should support ignoreHTTPSErrors option', () async {
        //TODO(xha): enable once we support https server
      });
      test('should be able to reconnect to a disconnected browser', () async {
        var originalBrowser = await puppeteer.launch();
        var browserWsEndpoint = originalBrowser.wsEndpoint;
        var page = await originalBrowser.newPage();
        await page.goto('${server.prefix}/frames/nested-frames.html');
        originalBrowser.disconnect();

        var browser =
            await puppeteer.connect(browserWsEndpoint: browserWsEndpoint);
        var pages = await browser.pages;
        var restoredPage = pages.firstWhere(
            (page) => page.url == '${server.prefix}/frames/nested-frames.html');
        expect(
            dumpFrames(restoredPage.mainFrame),
            equals([
              'http://<host>/frames/nested-frames.html',
              '    http://<host>/frames/two-frames.html (2frames)',
              '        http://<host>/frames/frame.html (uno)',
              '        http://<host>/frames/frame.html (dos)',
              '    http://<host>/frames/frame.html (aframe)',
            ]));
        expect(await restoredPage.evaluate('() => 7 * 8'), equals(56));
        await browser.close();
      });
    });
    // @see https://github.com/GoogleChrome/puppeteer/issues/4197#issuecomment-481793410
    test('should be able to connect to the same page simultaneously', () async {
      var browserOne = await puppeteer.launch();
      var browserTwo =
          await puppeteer.connect(browserWsEndpoint: browserOne.wsEndpoint);
      var pages = await Future.wait([
        browserOne.onTargetCreated.first.then((target) => target.page),
        browserTwo.newPage(),
      ]);
      expect(await pages[0].evaluate('() => 7 * 8'), equals(56));
      expect(await pages[1].evaluate('() => 7 * 6'), equals(42));
      await browserOne.close();
    });
  });

  group('Browser target events', () {
    test('should work', () async {
      var browser = await puppeteer.launch();
      var events = [];
      browser.onTargetCreated.listen((_) => events.add('CREATED'));
      browser.onTargetChanged.listen((_) => events.add('CHANGED'));
      browser.onTargetDestroyed.listen((_) => events.add('DESTROYED'));
      var page = await browser.newPage();
      await page.goto(server.emptyPage);
      await page.close();
      expect(events, equals(['CREATED', 'CHANGED', 'DESTROYED']));
      await browser.close();
    });
  });

  group('Browser.Events.disconnected', () {
    test(
        'should be emitted when: browser gets closed, disconnected or underlying websocket gets closed',
        () async {
      var originalBrowser = await puppeteer.launch();
      var browserWSEndpoint = originalBrowser.wsEndpoint;
      var remoteBrowser1 =
          await puppeteer.connect(browserWsEndpoint: browserWSEndpoint);
      var remoteBrowser2 =
          await puppeteer.connect(browserWsEndpoint: browserWSEndpoint);

      var disconnectedOriginal = 0;
      var disconnectedRemote1 = 0;
      var disconnectedRemote2 = 0;
      originalBrowser.disconnected
          .asStream()
          .listen((_) => ++disconnectedOriginal);
      remoteBrowser1.disconnected
          .asStream()
          .listen((_) => ++disconnectedRemote1);
      remoteBrowser2.disconnected
          .asStream()
          .listen((_) => ++disconnectedRemote2);

      var disconnectedFuture = remoteBrowser2.disconnected;
      remoteBrowser2.disconnect();
      await disconnectedFuture;

      expect(disconnectedOriginal, equals(0));
      expect(disconnectedRemote1, equals(0));
      expect(disconnectedRemote2, equals(1));

      await Future.wait([
        remoteBrowser1.disconnected,
        originalBrowser.disconnected,
        originalBrowser.close(),
      ]);

      expect(disconnectedOriginal, equals(1));
      expect(disconnectedRemote1, equals(1));
      expect(disconnectedRemote2, equals(1));
    });
  });
}

void _tryDeleteDirectory(Directory directory) {
  try {
    directory.deleteSync(recursive: true);
  } catch (_) {}
}
