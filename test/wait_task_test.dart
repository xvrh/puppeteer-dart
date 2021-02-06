import 'dart:async';
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

  group('Page.waitFor', () {
    test('should wait for selector', () async {
      var found = false;
      var waitFor = page.waitForSelector('div').then((_) => found = true);
      await page.goto(server.emptyPage);
      expect(found, isFalse);
      await page.goto(server.prefix + '/grid.html');
      await waitFor;
      expect(found, isTrue);
    });
    test('should wait for an xpath', () async {
      var found = false;
      var waitFor = page.waitForXPath('//div').then((_) => found = true);
      await page.goto(server.emptyPage);
      expect(found, isFalse);
      await page.goto(server.prefix + '/grid.html');
      await waitFor;
      expect(found, isTrue);
    });
    test('should wait for predicate', () async {
      await Future.wait([
        page.waitForFunction('() => window.innerWidth < 100'),
        page.setViewport(DeviceViewport(width: 10, height: 10)),
      ]);
    });
    test('should wait for predicate with arguments', () async {
      await page.waitForFunction('(arg1, arg2) => arg1 != arg2', args: [1, 2]);
    });
  });

  group('Frame.waitForFunction', () {
    test('should accept a string', () async {
      var watchdog = page.waitForFunction('window.__FOO === 1');
      await page.evaluate('() => window.__FOO = 1');
      await watchdog;
    });
    test('should work when resolved right before execution context disposal',
        () async {
      await page.evaluateOnNewDocument('() => window.__RELOADED = true');
      await page.waitForFunction('''() => {
  if (!window.__RELOADED)
    window.location.reload();
  return true;
}''');
    });
    test('should poll on interval', () async {
      var success = false;
      var startTime = DateTime.now();
      var polling = 100;
      var watchdog = page
          .waitForFunction("() => window.__FOO === 'hit'",
              polling: Polling.interval(Duration(milliseconds: polling)))
          .then((_) => success = true);
      await page.evaluate("() => window.__FOO = 'hit'");
      expect(success, isFalse);
      await page.evaluate(
          "() => document.body.appendChild(document.createElement('div'))");
      await watchdog;
      expect(DateTime.now().difference(startTime),
          isNot(lessThan(Duration(milliseconds: polling ~/ 2))));
    });
    test('should poll on mutation', () async {
      var success = false;
      var watchdog = page
          .waitForFunction("() => window.__FOO === 'hit'",
              polling: Polling.mutation)
          .then((_) => success = true);
      await page.evaluate("() => window.__FOO = 'hit'");
      expect(success, isFalse);
      await page.evaluate(
          "() => document.body.appendChild(document.createElement('div'))");
      await watchdog;
    });
    test('should poll on raf', () async {
      var watchdog = page.waitForFunction("() => window.__FOO === 'hit'",
          polling: Polling.everyFrame);
      await page.evaluate("() => window.__FOO = 'hit'");
      await watchdog;
    });
    test('should return the success value as a JSHandle', () async {
      expect(
          await (await page.waitForFunction('() => 5')).jsonValue, equals(5));
    });
    test('should return the window as a success value', () async {
      expect(await page.waitForFunction('() => window'), isNotNull);
    });
    test('should accept ElementHandle arguments', () async {
      await page.setContent('<div></div>');
      var div = await page.$('div');
      var resolved = false;
      var waitForFunction = page.waitForFunction(
          'element => !element.parentElement',
          args: [div]).then((_) => resolved = true);
      expect(resolved, isFalse);
      await page.evaluate('element => element.remove()', args: [div]);
      await waitForFunction;
    });
    test('should respect timeout', () async {
      expect(
          () => page.waitForFunction('false',
              timeout: Duration(milliseconds: 10)),
          throwsA(TypeMatcher<TimeoutException>()));
    });
    test('should respect default timeout', () async {
      page.defaultTimeout = Duration(milliseconds: 1);
      expect(
          () => page.waitForFunction('false',
              timeout: Duration(milliseconds: 10)),
          throwsA(TypeMatcher<TimeoutException>()));
    });
    test('should disable timeout when its set to 0', () async {
      var watchdog = page.waitForFunction('''() => {
  window.__counter = (window.__counter || 0) + 1;
  return window.__injected;
  }''', polling: Polling.interval(Duration(milliseconds: 10)));
      await page.waitForFunction('() => window.__counter > 10');
      await page.evaluate('() => window.__injected = true');
      await watchdog;
    });
    test('should survive cross-process navigation', () async {
      var fooFound = false;
      var waitForFunction = page
          .waitForFunction('window.__FOO === 1')
          .then((_) => fooFound = true);
      await page.goto(server.emptyPage);
      expect(fooFound, isFalse);
      await page.reload();
      expect(fooFound, isFalse);
      await page.goto(server.crossProcessPrefix + '/grid.html');
      expect(fooFound, isFalse);
      await page.evaluate('() => window.__FOO = 1');
      await waitForFunction;
      expect(fooFound, isTrue);
    });
    test('should survive navigations', () async {
      var watchdog = page.waitForFunction('() => window.__done');
      await page.goto(server.emptyPage);
      await page.goto(server.prefix + '/consolelog.html');
      await page.evaluate('() => window.__done = true');
      await watchdog;
    });
  });

  group('Frame.waitForSelector', () {
    var addElement =
        'tag => document.body.appendChild(document.createElement(tag))';

    test('should immediately resolve promise if node exists', () async {
      await page.goto(server.emptyPage);
      var frame = page.mainFrame;
      await frame.waitForSelector('*');
      await frame.evaluate(addElement, args: ['div']);
      await frame.waitForSelector('div');
    });

    test('should work with removed MutationObserver', () async {
      await page.evaluate('() => delete window.MutationObserver');
      var handle = await waitFutures(page.waitForSelector('.zombo'), [
        page.setContent("<div class='zombo'>anything</div>"),
      ]);
      expect(await page.evaluate('x => x.textContent', args: [handle]),
          equals('anything'));
    });

    test('should resolve promise when node is added', () async {
      await page.goto(server.emptyPage);
      var frame = page.mainFrame;
      var watchdog = frame.waitForSelector('div');
      await frame.evaluate(addElement, args: ['br']);
      await frame.evaluate(addElement, args: ['div']);
      var eHandle = await watchdog;
      var tagName = await eHandle!.property('tagName').then((e) => e.jsonValue);
      expect(tagName, equals('DIV'));
    });

    test('should work when node is added through innerHTML', () async {
      await page.goto(server.emptyPage);
      var watchdog = page.waitForSelector('h3 div');
      await page.evaluate(addElement, args: ['span']);
      await page.evaluate(
          "() => document.querySelector('span').innerHTML = '<h3><div></div></h3>'");
      await watchdog;
    });

    test('Page.waitForSelector is shortcut for main frame', () async {
      await page.goto(server.emptyPage);
      await attachFrame(page, 'frame1', server.emptyPage);
      var otherFrame = page.frames[1];
      var watchdog = page.waitForSelector('div');
      await otherFrame.evaluate(addElement, args: ['div']);
      await page.evaluate(addElement, args: ['div']);
      var eHandle = await watchdog;
      expect(eHandle!.executionContext.frame, equals(page.mainFrame));
    });

    test('should run in specified frame', () async {
      await attachFrame(page, 'frame1', server.emptyPage);
      await attachFrame(page, 'frame2', server.emptyPage);
      var frame1 = page.frames[1];
      var frame2 = page.frames[2];
      var waitForSelectorPromise = frame2.waitForSelector('div');
      await frame1.evaluate(addElement, args: ['div']);
      await frame2.evaluate(addElement, args: ['div']);
      var eHandle = await waitForSelectorPromise;
      expect(eHandle!.executionContext.frame, equals(frame2));
    });

    test('should throw when frame is detached', () async {
      await attachFrame(page, 'frame1', server.emptyPage);
      var frame = page.frames[1];
      dynamic waitError;
      var waitPromise = frame
          .waitForSelector('.box')
          .then<ElementHandle?>((e) => e)
          .catchError((e) {
        waitError = e;
        return null;
      });
      await detachFrame(page, 'frame1');
      await waitPromise;
      expect(waitError, isNotNull);
      expect(waitError.toString(),
          contains('waitForFunction failed: frame got detached.'));
    });
    test('should survive cross-process navigation', () async {
      var boxFound = false;
      var waitForSelector =
          page.waitForSelector('.box').then((_) => boxFound = true);
      await page.goto(server.emptyPage);
      expect(boxFound, isFalse);
      await page.reload();
      expect(boxFound, isFalse);
      await page.goto(server.crossProcessPrefix + '/grid.html');
      await waitForSelector;
      expect(boxFound, isTrue);
    });
    test('should wait for visible', () async {
      var divFound = false;
      var waitForSelector = page
          .waitForSelector('div', visible: true)
          .then((_) => divFound = true);
      await page.setContent(
          "<div style='display: none; visibility: hidden;'>1</div>");
      expect(divFound, isFalse);
      await page.evaluate(
          "() => document.querySelector('div').style.removeProperty('display')");
      expect(divFound, isFalse);
      await page.evaluate(
          "() => document.querySelector('div').style.removeProperty('visibility')");
      expect(await waitForSelector, isTrue);
      expect(divFound, isTrue);
    });
    test('should wait for visible recursively', () async {
      var divVisible = false;
      var waitForSelector = page
          .waitForSelector('div#inner', visible: true)
          .then((_) => divVisible = true);
      await page.setContent(
          """<div style='display: none; visibility: hidden;'><div id="inner">hi</div></div>""");
      expect(divVisible, isFalse);
      await page.evaluate(
          "() => document.querySelector('div').style.removeProperty('display')");
      expect(divVisible, isFalse);
      await page.evaluate(
          "() => document.querySelector('div').style.removeProperty('visibility')");
      expect(await waitForSelector, isTrue);
      expect(divVisible, isTrue);
    });
    test('hidden should wait for visibility: hidden', () async {
      var divHidden = false;
      await page.setContent("<div style='display: block;'></div>");
      var waitForSelector = page
          .waitForSelector('div', hidden: true)
          .then((_) => divHidden = true);
      await page.waitForSelector('div'); // do a round trip
      expect(divHidden, isFalse);
      await page.evaluate(
          "() => document.querySelector('div').style.setProperty('visibility', 'hidden')");
      expect(await waitForSelector, isTrue);
      expect(divHidden, isTrue);
    });
    test('hidden should wait for display: none', () async {
      var divHidden = false;
      await page.setContent("<div style='display: block;'></div>");
      var waitForSelector = page
          .waitForSelector('div', hidden: true)
          .then((_) => divHidden = true);
      await page.waitForSelector('div'); // do a round trip
      expect(divHidden, isFalse);
      await page.evaluate(
          "() => document.querySelector('div').style.setProperty('display', 'none')");
      expect(await waitForSelector, isTrue);
      expect(divHidden, isTrue);
    });
    test('hidden should wait for removal', () async {
      await page.setContent('<div></div>');
      var divRemoved = false;
      var waitForSelector = page
          .waitForSelector('div', hidden: true)
          .then((_) => divRemoved = true);
      await page.waitForSelector('div'); // do a round trip
      expect(divRemoved, isFalse);
      await page.evaluate("() => document.querySelector('div').remove()");
      expect(await waitForSelector, isTrue);
      expect(divRemoved, isTrue);
    });
    test('should return null if waiting to hide non-existing element',
        () async {
      var handle = await page.waitForSelector('non-existing', hidden: true);
      expect(handle, isNull);
    });
    test('should respect timeout', () async {
      expect(
          () =>
              page.waitForSelector('div', timeout: Duration(milliseconds: 10)),
          throwsA(TypeMatcher<TimeoutException>()));
    });
    test(
        'should have an error message specifically for awaiting an element to be hidden',
        () async {
      await page.setContent('<div></div>');
      expect(
          () => page.waitForSelector('div',
              hidden: true, timeout: Duration(milliseconds: 10)),
          throwsA(TypeMatcher<TimeoutException>()));
    });

    test('should respond to node attribute mutation', () async {
      var divFound = false;
      var waitForSelector =
          page.waitForSelector('.zombo').then((_) => divFound = true);
      await page.setContent("<div class='notZombo'></div>");
      expect(divFound, isFalse);
      await page
          .evaluate("() => document.querySelector('div').className = 'zombo'");
      expect(await waitForSelector, isTrue);
    });
    test('should return the element handle', () async {
      var waitForSelector = page.waitForSelector('.zombo');
      await page.setContent("<div class='zombo'>anything</div>");
      expect(
          await page
              .evaluate('x => x.textContent', args: [await waitForSelector]),
          equals('anything'));
    });
  });

  group('Frame.waitForXPath', () {
    var addElement =
        'tag => document.body.appendChild(document.createElement(tag))';

    test('should support some fancy xpath', () async {
      await page.setContent('<p>red herring</p><p>hello  world  </p>');
      var waitForXPath =
          page.waitForXPath('//p[normalize-space(.)="hello world"]');
      expect(
          await page.evaluate('x => x.textContent', args: [await waitForXPath]),
          equals('hello  world  '));
    });
    test('should run in specified frame', () async {
      await attachFrame(page, 'frame1', server.emptyPage);
      await attachFrame(page, 'frame2', server.emptyPage);
      var frame1 = page.frames[1];
      var frame2 = page.frames[2];
      var waitForXPathPromise = frame2.waitForXPath('//div');
      await frame1.evaluate(addElement, args: ['div']);
      await frame2.evaluate(addElement, args: ['div']);
      var eHandle = await waitForXPathPromise;
      expect(eHandle!.executionContext.frame, equals(frame2));
    });
    test('should throw when frame is detached', () async {
      await attachFrame(page, 'frame1', server.emptyPage);
      var frame = page.frames[1];
      dynamic waitError;
      var waitPromise = frame.waitForXPath('//*[@class="box"]').catchError((e) {
        waitError = e;
        return null;
      });
      await detachFrame(page, 'frame1');
      await waitPromise;
      expect(waitError, isNotNull);
      expect('$waitError',
          contains('waitForFunction failed: frame got detached.'));
    });
    test('hidden should wait for display: none', () async {
      var divHidden = false;
      await page.setContent("<div style='display: block;'></div>");
      var waitForXPath = page
          .waitForXPath('//div', hidden: true)
          .then((_) => divHidden = true);
      await page.waitForXPath('//div'); // do a round trip
      expect(divHidden, isFalse);
      await page.evaluate(
          "() => document.querySelector('div').style.setProperty('display', 'none')");
      expect(await waitForXPath, isTrue);
      expect(divHidden, isTrue);
    });
    test('should return the element handle', () async {
      var waitForXPath = page.waitForXPath('//*[@class="zombo"]');
      await page.setContent("<div class='zombo'>anything</div>");
      expect(
          await page.evaluate('x => x.textContent', args: [await waitForXPath]),
          equals('anything'));
    });
    test('should allow you to select a text node', () async {
      await page.setContent('<div>some text</div>');
      var text = await page.waitForXPath('//div/text()');
      expect(await (await text!.property('nodeType')).jsonValue, equals(3));
    });
    test('should allow you to select an element with single slash', () async {
      await page.setContent('<div>some text</div>');
      var waitForXPath = page.waitForXPath('/html/body/div');
      expect(
          await page.evaluate('x => x.textContent', args: [await waitForXPath]),
          equals('some text'));
    });
  });
}
