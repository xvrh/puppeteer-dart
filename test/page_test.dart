import 'dart:async';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:puppeteer/devices.dart' as devices;
import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils.dart';

main() {
  Logger.root.onRecord.listen(print);

  Server server;
  Browser browser;
  BrowserContext context;
  Page page;
  setUpAll(() async {
    server = await Server.create();
  });

  tearDownAll(() async {
    await server.close();
  });

  setUp(() async {
    browser = await Browser.start();
    context = await browser.createIncognitoBrowserContext();
    page = await context.newPage();
  });

  tearDown(() async {
    await page.close();
    page = null;
    await browser.close();
    browser = null;
    server.clearRoutes();
  });

  group('Page.close', () {
    test('should reject all promises when page is closed', () async {
      var newPage = await context.newPage();
      var error;
      await Future.wait([
        newPage
            .evaluate('() => new Promise(r => {})')
            .catchError((e) => error = e),
        newPage.close(),
      ]);
      expect(error, TypeMatcher<TargetClosedException>());
    });
    test('should not be visible in browser.pages', () async {
      var newPage = await browser.newPage();
      expect(await browser.pages, contains(newPage));
      await newPage.close();
      expect(await browser.pages, isNot(contains(newPage)));
    });
    test('should run beforeunload if asked for', () async {
      var newPage = await context.newPage();
      await newPage.goto(server.prefix + '/beforeunload.html');
      // We have to interact with a page so that 'beforeunload' handlers
      // fire.
      await newPage.click('body');
      var pageClosingPromise = newPage.close(runBeforeUnload: true);
      var dialog = await newPage.onDialog.first;
      expect(dialog.type, equals(DialogType.beforeunload));
      expect(dialog.defaultValue, equals(''));
      expect(dialog.message, equals(''));
      await dialog.accept();
      await pageClosingPromise;
    });
    test('should *not* run beforeunload by default', () async {
      var newPage = await context.newPage();
      await newPage.goto(server.prefix + '/beforeunload.html');
      // We have to interact with a page so that 'beforeunload' handlers
      // fire.
      await newPage.click('body');
      await newPage.close();
    });
    test('should set the page close state', () async {
      var newPage = await context.newPage();
      expect(newPage.isClosed, isFalse);
      await newPage.close();
      expect(newPage.isClosed, isTrue);
    });
  });
  group('Page.Events.Load', () {
    test('should fire when expected', () async {
      await Future.wait([
        page.goto('about:blank'),
        page.onLoad.first,
      ]);
    });
  });
  group('Async stacks', () {
    test('should work', () async {
      server.setRoute('my-page', (request) {
        return Response(204);
      });
      Exception error;
      await page.goto(server.hostUrl + '/my-page').catchError((e, s) {
        error = e;
        return null;
      });
      expect(error, isNotNull);
    });
  });
  group('Page.Events.error', () {
    test('should throw when page crashes', () async {
      var onErrorFuture = page.onError.first;

      //TODO(xha): navigation should terminate in case of target crashed
      // ignore: unawaited_futures
      page.goto('chrome://crash').catchError((_) => null);
      var error = await onErrorFuture;
      expect(error.message, equals('Page crashed!'));
    });
  });
  group('Page.Events.Popup', () {
    test('should work', () async {
      var dialogFuture = page.onPopup.first;
      await page.evaluate("() => window.open('about:blank')");
      var popup = await dialogFuture;
      expect(await page.evaluate('() => !!window.opener'), isFalse);
      expect(await popup.evaluate('() => !!window.opener'), isTrue);
    });
    test('should work with noopener', () async {
      var dialogFuture = page.onPopup.first;
      await page.evaluate("() => window.open('about:blank', null, 'noopener')");
      var popup = await dialogFuture;
      expect(await page.evaluate('() => !!window.opener'), isFalse);
      expect(await popup.evaluate('() => !!window.opener'), isFalse);
    });
    test('should work with clicking target=_blank', () async {
      await page.goto(server.emptyPage);
      await page.setContent('<a target=_blank href="/one-style.html">yo</a>');
      var popupFuture = page.onPopup.first;
      await page.click('a');
      var popup = await popupFuture;
      expect(await page.evaluate('() => !!window.opener'), isFalse);
      expect(await popup.evaluate('() => !!window.opener'), isTrue);
    });
    test('should work with fake-clicking target=_blank and rel=noopener',
        () async {
      await page.goto(server.emptyPage);
      await page.setContent(
          '<a target=_blank rel=noopener href="/one-style.html">yo</a>');
      var popupFuture = page.onPopup.first;
      await page.$eval('a', 'a => a.click()');
      var popup = await popupFuture;
      expect(await page.evaluate('() => !!window.opener'), isFalse);
      expect(await popup.evaluate('() => !!window.opener'), isFalse);
    });
    test('should work with clicking target=_blank and rel=noopener', () async {
      await page.goto(server.emptyPage);
      await page.setContent(
          '<a target=_blank rel=noopener href="/one-style.html">yo</a>');
      var popupFuture = page.onPopup.first;
      await page.click('a');
      var popup = await popupFuture;
      expect(await page.evaluate('() => !!window.opener'), isFalse);
      expect(await popup.evaluate('() => !!window.opener'), isFalse);
    });
  });
  group('BrowserContext.overridePermissions', () {
    Future<String> getPermission(Page page, PermissionType permission) {
      return page.evaluate(
          'name => navigator.permissions.query({name}).then(result => result.state)',
          args: [permission.value]);
    }

    test('should be prompt by default', () async {
      await page.goto(server.emptyPage);
      expect(await getPermission(page, PermissionType.geolocation),
          equals('prompt'));
    });
    test('should deny permission when not listed', () async {
      await page.goto(server.emptyPage);
      await context.overridePermissions(server.emptyPage, []);
      expect(await getPermission(page, PermissionType.geolocation),
          equals('denied'));
    });
    test('should grant permission when listed', () async {
      await page.goto(server.emptyPage);
      await context
          .overridePermissions(server.emptyPage, [PermissionType.geolocation]);
      expect(await getPermission(page, PermissionType.geolocation),
          equals('granted'));
    });
    test('should reset permissions', () async {
      await page.goto(server.emptyPage);
      await context
          .overridePermissions(server.emptyPage, [PermissionType.geolocation]);
      expect(await getPermission(page, PermissionType.geolocation),
          equals('granted'));
      await context.clearPermissionOverrides();
      expect(await getPermission(page, PermissionType.geolocation),
          equals('prompt'));
    });
    test('should trigger permission onchange', () async {
      await page.goto(server.emptyPage);
      await page.evaluate('''() => {
        window.events = [];
        return navigator.permissions.query({name: 'geolocation'}).then(function(result) {
          window.events.push(result.state);
          result.onchange = function() {
            window.events.push(result.state);
          };
        });
      }
''');

      expect(await page.evaluate('() => window.events'), equals(['prompt']));
      await context.overridePermissions(server.emptyPage, []);
      expect(await page.evaluate('() => window.events'),
          equals(['prompt', 'denied']));
      await context
          .overridePermissions(server.emptyPage, [PermissionType.geolocation]);
      expect(await page.evaluate('() => window.events'),
          equals(['prompt', 'denied', 'granted']));
      await context.clearPermissionOverrides();
      expect(await page.evaluate('() => window.events'),
          equals(['prompt', 'denied', 'granted', 'prompt']));
    });
    test('should isolate permissions between browser contexs', () async {
      await page.goto(server.emptyPage);
      var otherContext = await browser.createIncognitoBrowserContext();
      var otherPage = await otherContext.newPage();
      await otherPage.goto(server.emptyPage);
      expect(await getPermission(page, PermissionType.geolocation),
          equals('prompt'));
      expect(await getPermission(otherPage, PermissionType.geolocation),
          equals('prompt'));

      await context.overridePermissions(server.emptyPage, []);
      await otherContext
          .overridePermissions(server.emptyPage, [PermissionType.geolocation]);
      expect(await getPermission(page, PermissionType.geolocation),
          equals('denied'));
      expect(await getPermission(otherPage, PermissionType.geolocation),
          equals('granted'));

      await context.clearPermissionOverrides();
      expect(await getPermission(page, PermissionType.geolocation),
          equals('prompt'));
      expect(await getPermission(otherPage, PermissionType.geolocation),
          equals('granted'));

      await otherContext.close();
    });
  });
  group('Page.setGeolocation', () {
    test('should work', () async {
      await context
          .overridePermissions(server.prefix, [PermissionType.geolocation]);
      await page.goto(server.emptyPage);
      await page.setGeolocation(longitude: 10, latitude: 10);
      var geolocation = await page.evaluate(
          '''() => new Promise(resolve => navigator.geolocation.getCurrentPosition(position => {
      resolve({latitude: position.coords.latitude, longitude: position.coords.longitude});
      }))''');
      expect(geolocation, equals({'latitude': 10, 'longitude': 10}));
    });
    test('should throw when invalid longitude', () async {
      expect(() => page.setGeolocation(longitude: 200, latitude: 10),
          throwsA(TypeMatcher<AssertionError>()));
    });
  });
  group('Page.setOfflineMode', () {
    test('should work', () async {
      await page.setOfflineMode(true);
      expect(() => page.goto(server.emptyPage), throwsA(anything));
      await page.setOfflineMode(false);
      var response = await page.reload();
      expect(response.status, equals(200));
    },
        //TODO(xha): test is flaky when running the whole suite
        skip: true);
    test('should emulate navigator.onLine', () async {
      expect(await page.evaluate('() => window.navigator.onLine'), isTrue);
      await page.setOfflineMode(true);
      expect(await page.evaluate('() => window.navigator.onLine'), isFalse);
      await page.setOfflineMode(false);
      expect(await page.evaluate('() => window.navigator.onLine'), isTrue);
    });
  });

  group('ExecutionContext.queryObjects', () {
    test('should work', () async {
      // Instantiate an object
      await page.evaluate("() => window.set = new Set(['hello', 'world'])");
      var prototypeHandle = await page.evaluateHandle('() => Set.prototype');
      var objectsHandle = await page.queryObjects(prototypeHandle);
      var count = await page
          .evaluate('objects => objects.length', args: [objectsHandle]);
      expect(count, equals(1));
      var values = await page.evaluate(
          'objects => Array.from(objects[0].values())',
          args: [objectsHandle]);
      expect(values, equals(['hello', 'world']));
    });
    test('should work for non-blank page', () async {
      // Instantiate an object
      await page.goto(server.emptyPage);
      await page.evaluate("() => window.set = new Set(['hello', 'world'])");
      var prototypeHandle = await page.evaluateHandle('() => Set.prototype');
      var objectsHandle = await page.queryObjects(prototypeHandle);
      var count = await page
          .evaluate('objects => objects.length', args: [objectsHandle]);
      expect(count, equals(1));
    }, skip: true);
    test('should fail for disposed handles', () async {
      var prototypeHandle =
          await page.evaluateHandle('() => HTMLBodyElement.prototype');
      await prototypeHandle.dispose();
      expect(
          () => page.queryObjects(prototypeHandle),
          throwsA(predicate(
              (e) => '$e' == 'Exception: Prototype JSHandle is disposed!')));
    });
    test('should fail primitive values as prototypes', () async {
      var prototypeHandle = await page.evaluateHandle('() => 42');
      expect(
          () => page.queryObjects(prototypeHandle),
          throwsA(predicate((e) =>
              '$e' ==
              'Exception: Prototype JSHandle must not be referencing primitive value')));
    });
  });
  group('Page.Events.Console', () {
    test('should work', () async {
      var message = await waitFutures(page.onConsole.first,
          [page.evaluate("() => console.log('hello', 5, {foo: 'bar'})")]);
      expect(message.text, equals('hello 5 JSHandle@object'));
      expect(message.type, equals('log'));
      expect(await message.args[0].jsonValue, equals('hello'));
      expect(await message.args[1].jsonValue, equals(5));
      expect(await message.args[2].jsonValue, equals({'foo': 'bar'}));
    });
    test('should work for different console API calls', () async {
      var messages = <ConsoleMessage>[];
      page.onConsole.listen(messages.add);

      // All console events will be reported before `page.evaluate` is finished.
      await page.evaluate('''() => {
      // A pair of time/timeEnd generates only one Console API call.
      console.time('calling console.time');
      console.timeEnd('calling console.time');
      console.trace('calling console.trace');
      console.dir('calling console.dir');
      console.warn('calling console.warn');
      console.error('calling console.error');
      console.log(Promise.resolve('should not wait until resolved!'));
      }''');
      expect(messages.map((msg) => msg.type),
          equals(['timeEnd', 'trace', 'dir', 'warning', 'error', 'log']));
      expect(messages[0].text, contains('calling console.time'));
      expect(
          messages.skip(1).map((msg) => msg.text),
          equals([
            'calling console.trace',
            'calling console.dir',
            'calling console.warn',
            'calling console.error',
            'JSHandle@promise',
          ]));
    });
    test('should not fail for window object', () async {
      var message = await waitFutures(
          page.onConsole.first, [page.evaluate('() => console.error(window)')]);
      expect(message.text, equals('JSHandle@object'));
    });
    test('should trigger correct Log', () async {
      await page.goto('about:blank');
      var message = await waitFutures(page.onConsole.first, [
        page.evaluate('async url => fetch(url).catch(e => {})',
            args: [server.emptyPage])
      ]);
      expect(message.text, contains('Access-Control-Allow-Origin'));
      expect(message.type, equals('error'));
    });
    test('should have location when fetch fails', () async {
      // The point of this test is to make sure that we report console messages from
      // Log domain: https://vanilla.aslushnikov.com/?Log.entryAdded
      await page.goto(server.emptyPage);
      var message = await waitFutures(page.onConsole.first,
          [page.setContent("<script>fetch('http://wat');</script>")]);
      expect(message.text, contains('ERR_NAME_NOT_RESOLVED'));
      expect(message.type, equals('error'));
      expect(message.url, equals('http://wat/'));
      expect(message.lineNumber, isNull);
    });
    test('should have location for console API calls', () async {
      await page.goto(server.emptyPage);
      var message = await waitFutures(page.onConsole.first,
          [page.goto(server.prefix + '/consolelog.html')]);
      expect(message.text, equals('yellow'));
      expect(message.type, equals('log'));
      expect(message.url, equals(server.prefix + '/consolelog.html'));
      expect(message.lineNumber, equals(7));
      expect(message.columnNumber, equals(14));
    });
    // @see https://github.com/GoogleChrome/puppeteer/issues/3865
    test('should not throw when there are console messages in detached iframes',
        () async {
      await page.goto(server.emptyPage);
      await page.evaluate('''async () => {
      // 1. Create a popup that Puppeteer is not connected to.
      var win = window.open(window.location.href, 'Title', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=780,height=200,top=0,left=0');
      await new Promise(x => win.onload = x);
      // 2. In this popup, create an iframe that console.logs a message.
      win.document.body.innerHTML = "<iframe src='/consolelog.html'></iframe>";
      var frame = win.document.querySelector('iframe');
      await new Promise(x => frame.onload = x);
      // 3. After that, remove the iframe.
      frame.remove();
      }''');
      var popupTarget = page.browserContext.targets
          .firstWhere((target) => target != page.target);
      // 4. Connect to the popup and make sure it doesn't throw.
      await popupTarget.page;
    });
  });
  group('Page.Events.DOMContentLoaded', () {
    test('should fire when expected', () async {
      Future blankFuture = page.goto('about:blank');
      await page.onDomContentLoaded.first;
      await blankFuture;
    });
  });
  group('Page.waitForRequest', () {
    test('should work', () async {
      await page.goto(server.emptyPage);
      var request = await waitFutures(
          page.waitForRequest(server.prefix + '/digits/2.png'), [
        page.evaluate('''() => {
      fetch('${server.prefix}/digits/1.png');
      fetch('${server.prefix}/digits/2.png');
      fetch('${server.prefix}/digits/3.png');
      }''')
      ]);
      expect(request.url, equals(server.prefix + '/digits/2.png'));
    });
    test('should work with predicate', () async {
      await page.goto(server.emptyPage);
      var request = await waitFutures(
          page.frameManager.networkManager.onRequest
              .where(
                  (request) => request.url == server.prefix + '/digits/2.png')
              .first,
          [
            page.evaluate('''() => {
      fetch('${server.prefix}/digits/1.png');
      fetch('${server.prefix}/digits/2.png');
      fetch('${server.prefix}/digits/3.png');
      }''')
          ]);
      expect(request.url, equals(server.prefix + '/digits/2.png'));
    });
  });
  group('Page.waitForResponse', () {
    test('should work', () async {
      await page.goto(server.emptyPage);
      var response = await waitFutures(
          page.waitForResponse(server.prefix + '/digits/2.png'), [
        page.evaluate('''() => {
      fetch('${server.prefix}/digits/1.png');
      fetch('${server.prefix}/digits/2.png');
      fetch('${server.prefix}/digits/3.png');
      }''')
      ]);
      expect(response.url, equals(server.prefix + '/digits/2.png'));
    });
  });
  group('Page.exposeFunction', () {
    test('should work', () async {
      await page.exposeFunction('compute', (num a, num b) {
        return a * b;
      });
      var result = await page.evaluate('''async () => {
      return await compute(9, 4);
      }''');
      expect(result, equals(36));
    });
    test('should throw exception in page context', () async {
      await page.exposeFunction('woof', () {
        throw Exception('WOOF WOOF');
      });
      Map<String, dynamic> result = await page.evaluate('''async () => {
      try {
        await woof();
      } catch (e) {
        return {message: e.message, stack: e.stack};
      }
      }''');
      expect(result['message'], equals('Exception: WOOF WOOF'));
      expect(result['stack'], contains('page_test.dart'));
    });
    test('should be callable from-inside evaluateOnNewDocument', () async {
      var called = false;
      await page.exposeFunction('woof', () {
        called = true;
      });
      await page.evaluateOnNewDocument('() => woof()');
      await page.reload();
      await Future.delayed(Duration(milliseconds: 10));
      expect(called, isTrue);
    });
    test('should survive navigation', () async {
      await page.exposeFunction('compute', (num a, num b) {
        return a * b;
      });

      await page.goto(server.emptyPage);
      var result = await page.evaluate('''async () => {
      return await compute(9, 4);
      }''');
      expect(result, equals(36));
    });
    test('should await returned promise', () async {
      await page.exposeFunction('compute', (num a, num b) {
        return Future.value(a * b);
      });

      var result = await page.evaluate('''async () => {
      return await compute(3, 5);
      }''');
      expect(result, equals(15));
    });
    test('should work on frames', () async {
      await page.exposeFunction('compute', (num a, num b) {
        return Future.value(a * b);
      });

      await page.goto(server.prefix + '/frames/nested-frames.html');
      var frame = page.frames[1];
      var result = await frame.evaluate('''async () => {
      return await compute(3, 5);
      }''');
      expect(result, equals(15));
    });
    test('should work on frames before navigation', () async {
      await page.goto(server.prefix + '/frames/nested-frames.html');
      await page.exposeFunction('compute', (num a, num b) {
        return Future.value(a * b);
      });

      var frame = page.frames[1];
      var result = await frame.evaluate('''async () => {
      return await compute(3, 5);
      }''');
      expect(result, equals(15));
    });
  });

  group('Page.Events.PageError', () {
    test('should fire', () async {
      var error = await waitFutures(page.onError.first, [
        page.goto(server.prefix + '/error.html'),
      ]);
      expect(error.message, contains('Fancy'));
    });
  });

  group('Page.setUserAgent', () {
    test('should work', () async {
      expect(await page.evaluate('() => navigator.userAgent'),
          contains('Mozilla'));
      await page.setUserAgent('foobar');
      var request =
          await waitFutures(server.waitForRequest('assets/empty.html'), [
        page.goto(server.emptyPage),
      ]);
      expect(request.headers['user-agent'], equals('foobar'));
    });
    test('should work for subframes', () async {
      expect(await page.evaluate('() => navigator.userAgent'),
          contains('Mozilla'));
      await page.setUserAgent('foobar');
      var request =
          await waitFutures(server.waitForRequest('assets/empty.html'), [
        attachFrame(page, 'frame1', server.emptyPage),
      ]);
      expect(request.headers['user-agent'], equals('foobar'));
    });
    test('should emulate device user-agent', () async {
      await page.goto(server.prefix + '/mobile.html');
      expect(await page.evaluate('() => navigator.userAgent'),
          isNot(contains('iPhone')));
      await page.setUserAgent(devices.iPhone6.userAgent('75'));
      expect(
          await page.evaluate('() => navigator.userAgent'), contains('iPhone'));
    });
  });

  group('Page.setContent', () {
    var expectedOutput =
        '<html><head></head><body><div>hello</div></body></html>';
    test('should work', () async {
      await page.setContent('<div>hello</div>');
      var result = await page.content;
      expect(result, equals(expectedOutput));
    });
    test('should work with doctype', () async {
      var doctype = '<!DOCTYPE html>';
      await page.setContent('$doctype<div>hello</div>');
      var result = await page.content;
      expect(result, equals('$doctype$expectedOutput'));
    });
    test('should work with HTML 4 doctype', () async {
      var doctype = '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" '
          '"http://www.w3.org/TR/html4/strict.dtd">';
      await page.setContent('$doctype<div>hello</div>');
      var result = await page.content;
      expect(result, equals('$doctype$expectedOutput'));
    });
    test('should respect timeout', () async {
      var imgPath = 'img.png';
      // stall for image
      server.setRoute(imgPath, (req) {
        return Future.delayed(
            Duration(seconds: 3000), () => Response.notFound(''));
      });
      expect(
          () => page.setContent(
              '<img src="${server.hostUrl + '/' + imgPath}"></img>',
              timeout: Duration(milliseconds: 1)),
          throwsA(TypeMatcher<TimeoutException>()));
    });
    test('should respect default navigation timeout', () async {
      page.defaultTimeout = Duration(milliseconds: 1);
      var imgPath = 'img.png';
      // stall for image
      server.setRoute(imgPath, (req) {
        return Future.delayed(Duration(seconds: 3000));
      });
      expect(
          () => page.setContent(
              '<img src="${server.hostUrl + '/' + imgPath}"></img>'),
          throwsA(TypeMatcher<TimeoutException>()));
    });
    test('should await resources to load', () async {
      var imgPath = 'img.png';
      Completer<Response> imgResponse;
      server.setRoute(imgPath, (req) {
        imgResponse = Completer();
        return imgResponse.future;
      });
      var loaded = false;
      var contentPromise = page
          .setContent('<img src="${server.hostUrl + '/' + imgPath}"></img>')
          .then((_) {
        loaded = true;
      });
      await server.waitForRequest(imgPath);
      expect(loaded, isFalse);
      imgResponse.complete(Response.found(''));
      await contentPromise;
    });
    test('should work fast enough', () async {
      for (var i = 0; i < 20; ++i) await page.setContent('<div>yo</div>');
    });
  });

  group('Page.addScriptTag', () {
    test('should throw an error if no options are provided', () async {
      expect(() => page.addScriptTag(), throwsA(TypeMatcher<AssertionError>()));
    });

    test('should work with a url', () async {
      await page.goto(server.emptyPage);
      var scriptHandle = await page.addScriptTag(url: 'injectedfile.js');
      expect(scriptHandle.asElement, isNotNull);
      expect(await page.evaluate('() => __injected'), equals(42));
    });

    test('should work with a url and type=module', () async {
      await page.goto(server.emptyPage);
      await page.addScriptTag(url: 'es6/es6import.js', type: 'module');
      expect(await page.evaluate('() => __es6injected'), equals(42));
    });

    test('should work with a path and type=module', () async {
      await page.goto(server.emptyPage);
      await page.addScriptTag(
          file: File('test/assets/es6/es6pathimport.js'), type: 'module');
      await page.waitForFunction('window.__es6injected');
      expect(await page.evaluate('() => __es6injected'), equals(42));
    },
        //TODO(xha): debug
        skip: true);

    test('should work with a content and type=module', () async {
      await page.goto(server.emptyPage);
      await page.addScriptTag(
          content:
              "import num from '/assets/es6/es6module.js';window.__es6injected = num;",
          type: 'module');
      await page.waitForFunction('window.__es6injected');
      expect(await page.evaluate('() => __es6injected'), equals(42));
    },
        // TODO(xha): debug
        skip: true);

    test('should throw an error if loading from url fail', () async {
      await page.goto(server.emptyPage);
      expect(() => page.addScriptTag(url: '/nonexistfile.js'),
          throwsA(predicate((e) => '$e'.contains('Evaluation failed'))));
    });

    test('should work with a path', () async {
      await page.goto(server.emptyPage);
      var scriptHandle =
          await page.addScriptTag(file: File('test/assets/injectedfile.js'));
      expect(scriptHandle.asElement, isNotNull);
      expect(await page.evaluate('() => __injected'), equals(42));
    });

    test('should include sourcemap when path is provided', () async {
      await page.goto(server.emptyPage);
      await page.addScriptTag(file: File('test/assets/injectedfile.js'));
      var result = await page.evaluate('() => __injectedError.stack');
      expect(result, contains('assets/injectedfile.js'));
    });

    test('should work with content', () async {
      await page.goto(server.emptyPage);
      var scriptHandle =
          await page.addScriptTag(content: 'window.__injected = 35;');
      expect(scriptHandle.asElement, isNotNull);
      expect(await page.evaluate('() => __injected'), equals(35));
    });

    test('should throw when added with content to the CSP page', () async {
      await page.goto(server.prefix + '/csp.html');
      expect(() => page.addScriptTag(content: 'window.__injected = 35;'),
          throwsA(anything));
    });

    test('should throw when added with URL to the CSP page', () async {
      await page.goto(server.prefix + '/csp.html');
      expect(
          () => page.addScriptTag(
              url: server.crossProcessPrefix + '/injectedfile.js'),
          throwsA(anything));
    });
  });

  group('Page.addStyleTag', () {
    test('should throw an error if no options are provided', () async {
      expect(() => page.addStyleTag(), throwsA(TypeMatcher<AssertionError>()));
    });

    test('should work with a url', () async {
      await page.goto(server.emptyPage);
      var styleHandle = await page.addStyleTag(url: 'injectedstyle.css');
      expect(styleHandle.asElement, isNotNull);
      expect(
          await page.evaluate(
              "window.getComputedStyle(document.querySelector('body')).getPropertyValue('background-color')"),
          equals('rgb(255, 0, 0)'));
    });

    test('should throw an error if loading from url fail', () async {
      await page.goto(server.emptyPage);
      expect(
          () => page.addStyleTag(url: '/nonexistfile.js'), throwsA(anything));
    });

    test('should work with a path', () async {
      await page.goto(server.emptyPage);
      var styleHandle =
          await page.addStyleTag(file: File('test/assets/injectedstyle.css'));
      expect(styleHandle.asElement, isNotNull);
      expect(
          await page.evaluate(
              "window.getComputedStyle(document.querySelector('body')).getPropertyValue('background-color')"),
          equals('rgb(255, 0, 0)'));
    });

    test('should include sourcemap when path is provided', () async {
      await page.goto(server.emptyPage);
      await page.addStyleTag(file: File('test/assets/injectedstyle.css'));
      var styleHandle = await page.$('style');
      var styleContent =
          await page.evaluate('style => style.innerHTML', args: [styleHandle]);
      expect(styleContent, contains('assets/injectedstyle.css'));
    });

    test('should work with content', () async {
      await page.goto(server.emptyPage);
      var styleHandle =
          await page.addStyleTag(content: 'body { background-color: green; }');
      expect(styleHandle.asElement, isNotNull);
      expect(
          await page.evaluate(
              "window.getComputedStyle(document.querySelector('body')).getPropertyValue('background-color')"),
          equals('rgb(0, 128, 0)'));
    });

    test('should throw when added with content to the CSP page', () async {
      await page.goto(server.prefix + '/csp.html');
      expect(
          () => page.addStyleTag(content: 'body { background-color: green; }'),
          throwsA(anything));
    });

    test('should throw when added with URL to the CSP page', () async {
      await page.goto(server.prefix + '/csp.html');
      expect(
          () => page.addStyleTag(
              url: server.crossProcessPrefix + '/injectedstyle.css'),
          throwsA(anything));
    });
  });

  group('Page.url', () {
    test('should work', () async {
      expect(page.url, equals('about:blank'));
      await page.goto(server.emptyPage);
      expect(page.url, equals(server.emptyPage));
    });
  });

  group('Page.setJavaScriptEnabled', () {
    test('should work', () async {
      await page.setJavaScriptEnabled(false);
      await page
          .goto('data:text/html, <script>var something = "forbidden"</script>');
      expect(() => page.evaluate('something'),
          throwsA(predicate((e) => '$e'.contains('something is not defined'))));

      await page.setJavaScriptEnabled(true);
      await page
          .goto('data:text/html, <script>var something = "forbidden"</script>');
      expect(await page.evaluate('something'), equals('forbidden'));
    });
  });

  // Printing to pdf is currently only supported in headless
  group('Page.pdf', () {
    test('should be able to save file', () async {
      var result = await page.pdf();
      expect(result.length, greaterThan(0));
    });
  });

  group('Page.title', () {
    test('should return the page title', () async {
      await page.goto(server.prefix + '/title.html');
      expect(await page.title, equals('Woof-Woof'));
    });
  });

  group('Page.select', () {
    test('should select single option', () async {
      await page.goto(server.prefix + '/input/select.html');
      await page.select('select', ['blue']);
      expect(await page.evaluate('() => result.onInput'), equals(['blue']));
      expect(await page.evaluate('() => result.onChange'), equals(['blue']));
    });
    test('should select only first option', () async {
      await page.goto(server.prefix + '/input/select.html');
      await page.select('select', ['blue', 'green', 'red']);
      expect(await page.evaluate('() => result.onInput'), equals(['blue']));
      expect(await page.evaluate('() => result.onChange'), equals(['blue']));
    });
    test('should select multiple options', () async {
      await page.goto(server.prefix + '/input/select.html');
      await page.evaluate('() => makeMultiple()');
      await page.select('select', ['blue', 'green', 'red']);
      expect(await page.evaluate('() => result.onInput'),
          equals(['blue', 'green', 'red']));
      expect(await page.evaluate('() => result.onChange'),
          equals(['blue', 'green', 'red']));
    });
    test('should respect event bubbling', () async {
      await page.goto(server.prefix + '/input/select.html');
      await page.select('select', ['blue']);
      expect(await page.evaluate('() => result.onBubblingInput'),
          equals(['blue']));
      expect(await page.evaluate('() => result.onBubblingChange'),
          equals(['blue']));
    });
    test('should throw when element is not a <select>', () async {
      await page.goto(server.prefix + '/input/select.html');
      expect(
          () => page.select('body', ['']),
          throwsA(predicate(
              (e) => '$e'.contains('Element is not a <select> element.'))));
    });
    test('should return [] on no matched values', () async {
      await page.goto(server.prefix + '/input/select.html');
      var result = await page.select('select', ['42', 'abc']);
      expect(result, isEmpty);
    });
    test('should return an array of matched values', () async {
      await page.goto(server.prefix + '/input/select.html');
      await page.evaluate('() => makeMultiple()');
      var result = await page.select('select', ['blue', 'black', 'magenta']);
      expect(result.every(['blue', 'black', 'magenta'].contains), isTrue);
    });
    test('should return an array of one element when multiple is not set',
        () async {
      await page.goto(server.prefix + '/input/select.html');
      var result =
          await page.select('select', ['42', 'blue', 'black', 'magenta']);
      expect(result, hasLength(1));
    });
    test('should return [] on no values', () async {
      await page.goto(server.prefix + '/input/select.html');
      var result = await page.select('select', []);
      expect(result, isEmpty);
    });
    test(
        'should deselect all options when passed no values for a multiple select',
        () async {
      await page.goto(server.prefix + '/input/select.html');
      await page.evaluate('() => makeMultiple()');
      await page.select('select', ['blue', 'black', 'magenta']);
      await page.select('select', []);
      expect(
          await page.$eval('select',
              'select => Array.from(select.options).every(option => !option.selected)'),
          isTrue);
    });
    test(
        'should deselect all options when passed no values for a select without multiple',
        () async {
      await page.goto(server.prefix + '/input/select.html');
      await page.select('select', ['blue', 'black', 'magenta']);
      await page.select('select', []);
      expect(
          await page.$eval('select',
              'select => Array.from(select.options).every(option => !option.selected)'),
          isTrue);
    });
    // @see https://github.com/GoogleChrome/puppeteer/issues/3327
    test('should work when re-defining top-level Event class', () async {
      await page.goto(server.prefix + '/input/select.html');
      await page.evaluate('() => window.Event = null');
      await page.select('select', ['blue']);
      expect(await page.evaluate('() => result.onInput'), equals(['blue']));
      expect(await page.evaluate('() => result.onChange'), equals(['blue']));
    });
  });

  group('Page.Events.Close', () {
    test('should work with window.close', () async {
      var newPageFuture =
          context.onTargetCreated.first.then((target) => target.page);
      await page
          .evaluate("() => window['newPage'] = window.open('about:blank')");
      var newPage = await newPageFuture;
      var closedFuture = newPage.onClose;
      await page.evaluate("() => window['newPage'].close()");
      await closedFuture;
    });
    test('should work with page.close', () async {
      var newPage = await context.newPage();
      var closedFuture = newPage.onClose;
      await newPage.close();
      await closedFuture;
    });
  });

  group('Page.browser', () {
    test('should return the correct browser instance', () async {
      expect(page.browser, equals(browser));
    });
  });

  group('Page.browserContext', () {
    test('should return the correct browser instance', () async {
      expect(page.browserContext, equals(context));
    });
  });
}
