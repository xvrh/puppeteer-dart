import 'dart:async';
import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils/utils.dart';

// ignore_for_file: prefer_interpolation_to_compose_strings

void main() {
  late Server server;
  late Browser browser;
  setUpAll(() async {
    server = await Server.create();
  });

  tearDownAll(() async {
    await server.close();
  });

  setUp(() async {
    browser = await puppeteer.launch();
  });

  tearDown(() async {
    await browser.close();
  });

  group('BrowserContext', () {
    test('should have default context', () async {
      expect(browser.browserContexts, hasLength(1));
      var defaultContext = browser.browserContexts[0];
      expect(defaultContext.isIncognito, isFalse);
      expect(() => defaultContext.close(),
          throwsA(predicate((e) => '$e'.contains('cannot be closed'))));
      expect(browser.defaultBrowserContext, equals(defaultContext));
    });
    test('should create new incognito context', () async {
      expect(browser.browserContexts, hasLength(1));
      var context = await browser.createIncognitoBrowserContext();
      expect(context.isIncognito, isTrue);
      expect(browser.browserContexts, hasLength(2));
      expect(browser.browserContexts, contains(context));
      await context.close();
      expect(browser.browserContexts, hasLength(1));
    });
    test('should close all belonging targets once closing context', () async {
      expect(await browser.pages, hasLength(1));

      var context = await browser.createIncognitoBrowserContext();
      await context.newPage();
      expect(await browser.pages, hasLength(2));
      expect(await context.pages, hasLength(1));

      await context.close();
      expect(await browser.pages, hasLength(1));
    });
    test('window.open should use parent tab context', () async {
      var context = await browser.createIncognitoBrowserContext();
      var page = await context.newPage();
      await page.goto(server.emptyPage);

      var popupTargetFuture = browser.onTargetCreated.first;
      await page
          .evaluate('(url) => window.open(url)', args: [server.emptyPage]);
      var popupTarget = await popupTargetFuture;

      expect(popupTarget.browserContext, equals(context));
      await context.close();
    });
    test('should fire target events', () async {
      var context = await browser.createIncognitoBrowserContext();
      var events = [];
      context.onTargetCreated
          .listen((target) => events.add('CREATED: ' + target.url));
      context.onTargetChanged
          .listen((target) => events.add('CHANGED: ' + target.url));
      context.onTargetDestroyed
          .listen((target) => events.add('DESTROYED: ' + target.url));
      var page = await context.newPage();
      await page.goto(server.emptyPage);
      Future targetDestroyFuture = context.onTargetDestroyed.first;
      await page.close();
      await targetDestroyFuture;
      expect(
          events,
          equals([
            'CREATED: about:blank',
            'CHANGED: ${server.emptyPage}',
            'DESTROYED: ${server.emptyPage}'
          ]));
      await context.close();
    });
    test('should wait for a target', () async {
      var context = await browser.createIncognitoBrowserContext();
      var resolved = false;
      var targetPromise =
          context.waitForTarget((target) => target.url == server.emptyPage);
      // ignore: unawaited_futures
      targetPromise.then((_) => resolved = true);
      var page = await context.newPage();
      expect(resolved, isFalse);
      await page.goto(server.emptyPage);
      var target = await targetPromise;
      expect(await target.page, equals(page));
      await context.close();
    });
    test('should timeout waiting for a non-existent target', () async {
      var context = await browser.createIncognitoBrowserContext();
      expect(
          () => context.waitForTarget(
              (target) => target.url == server.emptyPage,
              timeout: Duration(milliseconds: 1)),
          throwsA(TypeMatcher<TimeoutException>()));
      await context.close();
    });
    test('should isolate localStorage and cookies', () async {
      // Create two incognito contexts.
      var context1 = await browser.createIncognitoBrowserContext();
      var context2 = await browser.createIncognitoBrowserContext();
      expect(context1.targets, isEmpty);
      expect(context2.targets, isEmpty);

      // Create a page in first incognito context.
      var page1 = await context1.newPage();
      await page1.goto(server.emptyPage);
      await page1.evaluate('''() => {
  localStorage.setItem('name', 'page1');
  document.cookie = 'name=page1';
  }''');

      expect(context1.targets, hasLength(1));
      expect(context2.targets, isEmpty);

      // Create a page in second incognito context.
      var page2 = await context2.newPage();
      await page2.goto(server.emptyPage);
      await page2.evaluate('''() => {
  localStorage.setItem('name', 'page2');
  document.cookie = 'name=page2';
  }''');

      expect(context1.targets, hasLength(1));
      expect(context1.targets[0], equals(page1.target));
      expect(context2.targets, hasLength(1));
      expect(context2.targets[0], equals(page2.target));

      // Make sure pages don't share localstorage or cookies.
      expect(await page1.evaluate("() => localStorage.getItem('name')"),
          equals('page1'));
      expect(
          await page1.evaluate('() => document.cookie'), equals('name=page1'));
      expect(await page2.evaluate("() => localStorage.getItem('name')"),
          equals('page2'));
      expect(
          await page2.evaluate('() => document.cookie'), equals('name=page2'));

      // Cleanup contexts.
      await Future.wait([context1.close(), context2.close()]);
      expect(browser.browserContexts, hasLength(1));
    });
  });
}
