import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart' as crypto;
import 'package:puppeteer/puppeteer.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:test/test.dart';
import 'utils/utils.dart';

// ignore_for_file: prefer_interpolation_to_compose_strings

// The tests in this file are extracted by the script `tool/inject_examples_to_doc.dart`
// and injected into the documentation in the source code.
// This help to ensure that the examples provided in the code are correct.
void main() {
  late Server server;
  late Browser browser;
  late Page page;
  late Frame frame;
  setUpAll(() async {
    server = await Server.create();
    browser = await puppeteer.launch();
  });

  tearDownAll(() async {
    await server.close();
    await browser.close();
  });

  setUp(() async {
    page = await browser.newPage();
    await page.goto(server.assetUrl('doc_examples.html'));
    frame = page.mainFrame;
  });

  tearDown(() async {
    await page.close();
    server.clearRoutes();
  });

  group('Browser', () {
    test('class', () async {
      //---
      Future<void> main() async {
        var browser = await puppeteer.launch();
        var page = await browser.newPage();
        await page.goto(exampleValue(server.hostUrl, 'https://example.com'));
        await browser.close();
      }
      //---

      //ignore: await_only_futures
      await main();
    });
    test('createIncognitoBrowserContext', () async {
      //---
      Future<void> main() async {
        var browser = await puppeteer.launch();
        // Create a new incognito browser context.
        var context = await browser.createIncognitoBrowserContext();
        // Create a new page in a pristine context.
        var page = await context.newPage();
        // Do stuff
        await page.goto(exampleValue(server.hostUrl, 'https://example.com'));
        await browser.close();
      }
      //---

      //ignore: await_only_futures
      await main();
    });
    test('waitForTarget', () async {
      //---
      var newWindowTarget = browser.waitForTarget((target) =>
          target.url ==
          exampleValue('${server.hostUrl}/', 'https://example.com/'));
      await page.evaluate(
          "() => window.open('${exampleValue(server.hostUrl, 'https://example.com')}/')");
      await newWindowTarget;
      //---
      expect(newWindowTarget, isNotNull);
    });
  });
  group('BrowserContext', () {
    test('overridePermissions', () async {
      var context = browser.defaultBrowserContext;
      await context.overridePermissions(
          'https://html5demos.com', [PermissionType.geolocation]);
    });
    test('clearPermissionOverrides', () async {
      var context = browser.defaultBrowserContext;
      await context.overridePermissions(
          exampleValue(server.hostUrl, 'https://example.com'),
          [PermissionType.clipboardReadWrite]);
      // do stuff ..
      await context.clearPermissionOverrides();
    });
  });
  group('Dialog', () {
    test('class', () async {
      //----
      var browser = await puppeteer.launch();
      var page = await browser.newPage();
      page.onDialog.listen((dialog) async {
        print(dialog.message);
        await dialog.dismiss();
      });
      await page.evaluate("() => alert('1')");
      await browser.close();
      //---
    });
  });
  group('Page', () {
    group('class', () {
      test(0, () async {
        //---
        //+ import 'dart:io';
        //+ import 'package:puppeteer/puppeteer.dart';

        Future<void> main() async {
          var browser = await puppeteer.launch();
          var page = await browser.newPage();
          await page.goto(exampleValue(server.hostUrl, 'https://example.com'));
          await File(exampleValue('_screenshot.png', 'screenshot.png'))
              .writeAsBytes(await page.screenshot());
          await browser.close();
        }

        //---
        //ignore: await_only_futures
        await main();
      });
      test(1, () async {
        page.onLoad.listen((_) => print('Page loaded!'));
      });
      test(2, () async {
        void logRequest(Request interceptedRequest) {
          print('A request was made: ${interceptedRequest.url}');
        }

        var subscription = page.onRequest.listen(logRequest);
        await subscription.cancel();
      });
    });

    test('onConsole', () async {
      page.onConsole.listen((msg) {
        for (var i = 0; i < msg.args.length; ++i) {
          print('$i: ${msg.args[i]}');
        }
      });
      await page.evaluate("() => console.log('hello', 5, {foo: 'bar'})");
    });
    group('onPopup', () {
      test(0, () async {
        //----
        var popupFuture = page.onPopup.first;
        await page.click('a[target=_blank]');
        var popup = await popupFuture;
        //----
        expect(popup, isNotNull);
      });
      test(1, () async {
        //----
        var popupFuture = page.onPopup.first;
        await page.evaluate(
            "() => window.open('${exampleValue(server.hostUrl, 'https://example.com')}')");
        var popup = await popupFuture;
        //----
        expect(popup, isNotNull);
      });
    });
    test('SSeval', () async {
      //---
      var divsCounts = await page.$$eval('div', 'divs => divs.length');
      //---
      expect(divsCounts, greaterThan(0));
    });
    test('Seval', () async {
      //---
      var searchValue =
          await page.$eval('#search', 'function (el) { return el.value; }');
      var preloadHref = await page.$eval(
          'link[rel=preload]', 'function (el) { return el.href; }');
      var html = await page.$eval(
          '.main-container', 'function (e) { return e.outerHTML; }');
      //---
      expect(searchValue, isNotNull);
      expect(preloadHref, isNotNull);
      expect(html, isNotNull);
    });
    group('click', () {
      test(0, () async {
        //---
        var responseFuture = page.waitForNavigation();
        await page.click('a');
        var response = await responseFuture;
        //---
        print(response);
      });
      test(1, () async {
        await Future.wait([
          page.waitForNavigation(),
          page.click('a'),
        ]);
      });
    });
    group('clickAndWaitForNavigation', () {
      test(0, () async {
        await page.clickAndWaitForNavigation('input#submitData');
      });
      test(1, () async {
        await Future.wait([
          page.waitForNavigation(),
          page.click('input#submitData'),
        ]);
      });
    });
    test('emulate', () async {
      var iPhone = puppeteer.devices.iPhone6;

      var browser = await puppeteer.launch();
      var page = await browser.newPage();
      await page.emulate(iPhone);
      await page.goto(exampleValue(
          server.assetUrl('doc_examples.html'), 'https://example.com'));
      // other actions...
      await browser.close();
    });
    test('emulateMediaType', () async {
      expect(await page.evaluate("() => matchMedia('screen').matches"), isTrue);
      expect(await page.evaluate("() => matchMedia('print').matches"), isFalse);

      await page.emulateMediaType(MediaType.print);
      expect(
          await page.evaluate("() => matchMedia('screen').matches"), isFalse);
      expect(await page.evaluate("() => matchMedia('print').matches"), isTrue);

      await page.emulateMediaType(null);
      expect(await page.evaluate("() => matchMedia('screen').matches"), isTrue);
      expect(await page.evaluate("() => matchMedia('print').matches"), isFalse);
    });
    group('evaluate', () {
      test(0, () async {
        var result = await page.evaluate<int>('''x => {
          return Promise.resolve(8 * x);
        }''', args: [7]);
        print(result); // prints "56"
      });
      test(1, () async {
        print(await page.evaluate('1 + 2')); // prints "3"
        var x = 10;
        print(await page.evaluate('1 + $x')); // prints "11"
      });
      test(2, () async {
        var bodyHandle = await page.$('body');
        var html =
            await page.evaluate('body => body.innerHTML', args: [bodyHandle]);
        await bodyHandle.dispose();
        print(html);
      });
    });
    group('evaluateHandle', () {
      test(0, () async {
        //----
        // Get an handle for the 'document'
        var aHandle = await page.evaluateHandle('document');
        //----
        expect(aHandle, isNotNull);
      });
      test(1, () async {
        var aHandle = await page.evaluateHandle('() => document.body');
        var resultHandle = await page
            .evaluateHandle('body => body.innerHTML', args: [aHandle]);
        print(await resultHandle.jsonValue);
        await resultHandle.dispose();
      });
    });
    test('evaluateOnNewDocument', () async {
      var preloadFile = File('test/assets/preload.js').readAsStringSync();
      await page.evaluateOnNewDocument(preloadFile);
    });
    group('exposeFunction', () {
      test(0, () async {
        //----
        //+import 'dart:convert';
        //+import 'package:puppeteer/puppeteer.dart';
        //+import 'package:crypto/crypto.dart' as crypto;

        Future<void> main() async {
          var browser = await puppeteer.launch();
          var page = await browser.newPage();
          page.onConsole.listen((msg) => print(msg.text));
          await page.exposeFunction(
              'md5',
              (String text) =>
                  crypto.md5.convert(utf8.encode(text)).toString());
          await page.evaluate(r'''async () => {
            // use window.md5 to compute hashes
            const myString = 'PUPPETEER';
            const myHash = await window.md5(myString);
            console.log(`md5 of ${myString} is ${myHash}`);
          }''');
          await browser.close();
        }
        //----

        //ignore: await_only_futures
        await main();
      });
      test(1, () async {
        //----
        //+import 'dart:io';
        //+import 'package:puppeteer/puppeteer.dart';

        Future<void> main() async {
          var browser = await puppeteer.launch();
          var page = await browser.newPage();
          page.onConsole.listen((msg) => print(msg.text));
          await page.exposeFunction('readfile', (String path) async {
            return File(path).readAsString();
          });
          await page.evaluate('''async () => {
            // use window.readfile to read contents of a file
            const content = await window.readfile('test/assets/simple.json');
            console.log(content);
          }''');
          await browser.close();
        }
        //---

        //ignore: await_only_futures
        await main();
      });
    });
    test('pdf', () async {
      // Generates a PDF with 'screen' media type.
      await page.emulateMediaType(MediaType.screen);
      await page.pdf(
          output: File(exampleValue('_page.pdf', 'page.pdf')).openWrite());
    });
    test('queryObjects', () async {
      // There is a bug currently with queryObjects if the page has navigated
      // before.
      // https://github.com/GoogleChrome/puppeteer/issues/4263
      // https://bugs.chromium.org/p/chromium/issues/detail?id=952057
      // So we create a fresh browser for this test
      var browser = await puppeteer.launch();
      var page = await browser.newPage();

      //----
      // Create a Map object
      await page.evaluate('() => window.map = new Map()');
      // Get a handle to the Map object prototype
      var mapPrototype = await page.evaluateHandle('() => Map.prototype');
      // Query all map instances into an array
      var mapInstances = await page.queryObjects(mapPrototype);
      // Count amount of map objects in heap
      var count =
          await page.evaluate('maps => maps.length', args: [mapInstances]);
      await mapInstances.dispose();
      await mapPrototype.dispose();
      //----

      print(count);
      await browser.close();
    });
    test('select', () async {
      await page.select('select#colors', ['blue']); // single selection
      await page.select(
          'select#colors', ['red', 'green', 'blue']); // multiple selections
    });
    test('setGeolocation', () async {
      await page.setGeolocation(latitude: 59.95, longitude: 30.31667);
    });
    test('setRequestInterception', () async {
      var browser = await puppeteer.launch();
      var page = await browser.newPage();
      await page.setRequestInterception(true);
      page.onRequest.listen((interceptedRequest) {
        if (interceptedRequest.url.endsWith('.png') ||
            interceptedRequest.url.endsWith('.jpg')) {
          interceptedRequest.abort();
        } else {
          interceptedRequest.continueRequest();
        }
      });
      await page.goto(exampleValue(server.hostUrl, 'https://example.com'));
      await browser.close();
    });
    test('type', () async {
      // Types instantly
      await page.type('#mytextarea', 'Hello');

      // Types slower, like a user
      await page.type('#mytextarea', 'World',
          delay: Duration(milliseconds: 100));
    });
    group('waitForFunction', () {
      test(0, () async {
        //---
        //+import 'package:puppeteer/puppeteer.dart';

        Future<void> main() async {
          var browser = await puppeteer.launch();
          var page = await browser.newPage();
          var watchDog = page.waitForFunction('window.innerWidth < 100');
          await page.setViewport(DeviceViewport(width: 50, height: 50));
          await watchDog;
          await browser.close();
        }
        //---

        //ignore: await_only_futures
        await main();
      });
      test(1, () async {
        var selector = '.foo';
        await page.waitForFunction(
            'selector => !!document.querySelector(selector)',
            args: [selector]);
      });
    });
    test('waitForNavigation', () async {
      await Future.wait([
        // The future completes after navigation has finished
        page.waitForNavigation(),
        // Clicking the link will indirectly cause a navigation
        page.click('a.my-link'),
      ]);
    });
    test('waitForRequest', () async {
      //---
      var firstRequest = page
          .waitForRequest(exampleValue(server.hostUrl, 'https://example.com'));

      // You can achieve the same effect (and more powerful) with the `onRequest`
      // stream.
      var finalRequest = page.onRequest
          .where((request) =>
              request.url.startsWith(
                  exampleValue(server.hostUrl, 'https://example.com')) &&
              request.method == 'GET')
          .first
          .timeout(Duration(seconds: 30));

      await page.goto(exampleValue(server.hostUrl, 'https://example.com'));
      await Future.wait([firstRequest, finalRequest]);
      //----
    });
    test('waitForSelector', () async {
      //---
      //+import 'package:puppeteer/puppeteer.dart';

      Future<void> main() async {
        var browser = await puppeteer.launch();
        var page = await browser.newPage();
        var watchImg = page.waitForSelector('img');
        await page.goto(exampleValue(
            server.assetUrl('doc_examples_2.html'), 'https://example.com'));
        var image = await watchImg;
        print(await image!.propertyValue('src'));
        await browser.close();
      }
      //---

      //ignore: await_only_futures
      await main();
    });
    test('waitForXPath', () async {
      //---
      //+import 'package:puppeteer/puppeteer.dart';

      Future<void> main() async {
        var browser = await puppeteer.launch();
        var page = await browser.newPage();
        var watchImg = page.waitForXPath('//img');
        await page.goto(exampleValue(
            server.assetUrl('doc_examples_2.html'), 'https://example.com'));
        var image = await watchImg;
        print(await image!.propertyValue('src'));
        await browser.close();
      }
      //---

      //ignore: await_only_futures
      await main();
    });
    test('waitForFileChooser', () async {
      await page.goto(server.assetUrl('doc_examples_3.html'));
      //------
      var futureFileChooser = page.waitForFileChooser();
      // some button that triggers file selection
      await page.click('#upload-file-button');
      var fileChooser = await futureFileChooser;

      await fileChooser.accept(
          [File(exampleValue('test/assets/file-to-upload.txt', 'myfile.pdf'))]);
      //----
    });
  });
  group('Frame', () {
    group('class', () {
      test(0, () async {
        void dumpFrameTree(Frame frame, String indent) {
          print(indent + frame.url);
          for (var child in frame.childFrames) {
            dumpFrameTree(child, indent + '  ');
          }
        }

        var browser = await puppeteer.launch();
        var page = await browser.newPage();
        await page.goto(exampleValue(server.hostUrl, 'https://example.com'));
        dumpFrameTree(page.mainFrame, '');
        await browser.close();
      });
      test(1, () async {
        var frame = page.frames.firstWhere((frame) => frame.name == 'myframe');
        var text = await frame.$eval('.selector', 'el => el.textContent');
        print(text);
      });
    });
    test('Seval', () async {
      //---
      var searchValue =
          await frame.$eval('#search', 'function (el) { return el.value; }');
      var preloadHref = await frame.$eval(
          'link[rel=preload]', 'function (el) { return el.href; }');
      var html = await frame.$eval(
          '.main-container', 'function (e) { return e.outerHTML; }');
      //---
      expect(searchValue, isNotNull);
      expect(preloadHref, isNotNull);
      expect(html, isNotNull);
    });
    test('SSeval', () async {
      //---
      var divsCounts = await frame.$$eval('div', 'divs => divs.length');
      //---
      expect(divsCounts, greaterThan(0));
    });
    test('click', () async {
      var frame = page.mainFrame;
      //---
      var responseFuture = page.waitForNavigation();
      await frame.click('a');
      var response = await responseFuture;
      //---
      expect(response, isNotNull);
    });
    group('evaluate', () {
      test(0, () async {
        var result = await frame.evaluate<int>('''x => {
          return Promise.resolve(8 * x);
        }''', args: [7]);
        print(result); // prints "56"
      });
      test(1, () async {
        print(await frame.evaluate('1 + 2')); // prints "3"
        var x = 10;
        print(await frame.evaluate('1 + $x')); // prints "11"
      });
      test(2, () async {
        var bodyHandle = await frame.$('body');
        var html =
            await frame.evaluate('body => body.innerHTML', args: [bodyHandle]);
        await bodyHandle.dispose();
        print(html);
      });
    });
    group('evaluateHandle', () {
      test(0, () async {
        //----
        // Get an handle for the 'document'
        var aHandle = await frame.evaluateHandle('document');
        //----
        expect(aHandle, isNotNull);
      });
      test(1, () async {
        var aHandle = await frame.evaluateHandle('() => document.body');
        var resultHandle = await frame
            .evaluateHandle('body => body.innerHTML', args: [aHandle]);
        print(await resultHandle.jsonValue);
        await resultHandle.dispose();
      });
    });
    test('select', () async {
      await frame.select('select#colors', ['blue']); // single selection
      await frame.select(
          'select#colors', ['red', 'green', 'blue']); // multiple selections
    });
    test('type', () async {
      // Types instantly
      await frame.type('#mytextarea', 'Hello');

      // Types slower, like a user
      await frame.type('#mytextarea', 'World',
          delay: Duration(milliseconds: 100));
    });
    group('waitForFunction', () {
      test(0, () async {
        //---
        //+import 'package:puppeteer/puppeteer.dart';

        Future<void> main() async {
          var browser = await puppeteer.launch();
          var page = await browser.newPage();
          var watchDog =
              page.mainFrame.waitForFunction('window.innerWidth < 100');
          await page.setViewport(DeviceViewport(width: 50, height: 50));
          await watchDog;
          await browser.close();
        }
        //---

        //ignore: await_only_futures
        await main();
      });
      test(1, () async {
        var selector = '.foo';
        await page.mainFrame.waitForFunction(
            'selector => !!document.querySelector(selector)',
            args: [selector]);
      });
    });
    test('waitForSelector', () async {
      //---
      //+import 'package:puppeteer/puppeteer.dart';

      Future<void> main() async {
        var browser = await puppeteer.launch();
        var page = await browser.newPage();
        var watchImg = page.mainFrame.waitForSelector('img');
        await page.goto(exampleValue(
            server.assetUrl('doc_examples_2.html'), 'https://example.com'));
        var image = await watchImg;
        print(await image!.propertyValue('src'));
        await browser.close();
      }
      //---

      //ignore: await_only_futures
      await main();
    });
    test('waitForXPath', () async {
      //---
      //+import 'package:puppeteer/puppeteer.dart';

      Future<void> main() async {
        var browser = await puppeteer.launch();
        var page = await browser.newPage();
        var watchImg = page.mainFrame.waitForXPath('//img');
        await page.goto(exampleValue(
            server.assetUrl('doc_examples_2.html'), 'https://example.com'));
        var image = await watchImg;
        print(await image!.propertyValue('src'));
        await browser.close();
      }
      //---

      //ignore: await_only_futures
      await main();
    });
  });
  group('Keyboard', () {
    group('class', () {
      test(0, () async {
        var input = await page.$('input');
        await input.focus();
        //----
        await page.keyboard.type('Hello World!');
        await page.keyboard.press(Key.arrowLeft);
        await page.keyboard.down(Key.shift);
        for (var i = 0; i < ' World'.length; i++) {
          await page.keyboard.press(Key.arrowLeft);
        }
        await page.keyboard.up(Key.shift);
        await page.keyboard.press(Key.backspace);
        // Result text will end up saying 'Hello!'
        //----
        expect(await input.propertyValue('value'), equals('Hello!'));
      });
      test(1, () async {
        var input = await page.$('input');
        await input.focus();
        //----
        await page.keyboard.down(Key.shift);
        await page.keyboard.press(Key.keyA, text: 'A');
        await page.keyboard.up(Key.shift);
        //----
        expect(await input.propertyValue('value'), equals('A'));
      });
    });
    test('sendCharacter', () async {
      var input = await page.$('input');
      await input.focus();
      //----
      await page.keyboard.sendCharacter('嗨');
      //----
      expect(await input.propertyValue('value'), equals('嗨'));
    });
    test('type', () async {
      var input = await page.$('input');
      await input.focus();
      //----
      // Types instantly
      await page.keyboard.type('Hello');

      // Types slower, like a user
      await page.keyboard.type('World', delay: Duration(milliseconds: 10));
      //----
      expect(await input.propertyValue('value'), equals('HelloWorld'));
    });
  });
  group('Mouse', () {
    test('class', () async {
      // Using ‘page.mouse’ to trace a 100x100 square.
      await page.mouse.move(Point(0, 0));
      await page.mouse.down();
      await page.mouse.move(Point(0, 100));
      await page.mouse.move(Point(100, 100));
      await page.mouse.move(Point(100, 0));
      await page.mouse.move(Point(0, 0));
      await page.mouse.up();
    });
    test('wheel', () async {
      await page.goto(exampleValue('${server.assetUrl('input/wheel.html')}',
          r'https://mdn.mozillademos.org/en-US/docs/Web/API/Element/wheel_event$samples/Scaling_an_element_via_the_wheel?revision=1587366'));
      var elem = await page.$('div');
      var boundingBox = (await elem.boundingBox)!;
      await page.mouse.move(Point(boundingBox.left + boundingBox.width / 2,
          boundingBox.top + boundingBox.height / 2));
      await page.mouse.wheel(deltaY: -100);
    });
  });
  group('ExecutionContext', () {
    group('evaluate', () {
      test(0, () async {
        var executionContext = await page.mainFrame.executionContext;
        var result =
            await executionContext.evaluate('() => Promise.resolve(8 * 7)');
        print(result); // prints "56"
      });
      test(1, () async {
        var executionContext = await page.mainFrame.executionContext;
        //----
        print(await executionContext.evaluate('1 + 2')); // prints "3"
        //---
      });
    });
    group('evaluateHandle', () {
      test(0, () async {
        //---
        var context = await page.mainFrame.executionContext;
        var aHandle =
            await context.evaluateHandle('() => Promise.resolve(self)');
        print(aHandle); // Handle for the global object.
        //---
        expect(aHandle, isNotNull);
      });
      test(1, () async {
        var context = await page.mainFrame.executionContext;
        //---
        var aHandle =
            await context.evaluateHandle('1 + 2'); // Handle for the '3' object.
        //----
        expect(aHandle, isNotNull);
      });
      test(2, () async {
        var context = await page.mainFrame.executionContext;
        //---
        var aHandle = await context.evaluateHandle('() => document.body');
        var resultHandle = await context
            .evaluateHandle('body => body.innerHTML', args: [aHandle]);
        print(await resultHandle.jsonValue); // prints body's innerHTML
        await aHandle.dispose();
        await resultHandle.dispose();
      });
    });
  });
  group('JsHandle', () {
    test('class', () async {
      //---
      var windowHandle = await page.evaluateHandle('() => window');
      //---
      expect(windowHandle, isNotNull);
    });
    test('evaluate', () async {
      server.setRoute('feed.html', (request) {
        return shelf.Response(404, body: '''
<div class="tweet">
  <div class="retweets">10</div>
</div>
        ''', headers: {'content-type': 'text/html'});
      });
      await page.goto(server.assetUrl('feed.html'));
      //---
      var tweetHandle = await page.$('.tweet .retweets');
      expect(await tweetHandle.evaluate('node => node.innerText'), '10');
      //---
    });
    test('properties', () async {
      //----
      var handle = await page.evaluateHandle('() => ({window, document})');
      var properties = await handle.properties;
      var windowHandle = properties['window'];
      var documentHandle = properties['document'] as ElementHandle;
      await handle.dispose();
      //----
      expect(windowHandle, isNotNull);
      expect(documentHandle, isNotNull);
    });
  });
  group('ElementHandle', () {
    test('class', () async {
      //---
      //+import 'package:puppeteer/puppeteer.dart';

      Future<void> main() async {
        var browser = await puppeteer.launch();

        var page = await browser.newPage();
        await page.goto(exampleValue(
            server.assetUrl('doc_examples.html'), 'https://example.com'));
        var hrefElement = await page.$('a');
        await hrefElement.click();

        await browser.close();
      }
      //---

      //ignore: await_only_futures
      await main();
    });
    test('SSeval', () async {
      server.setRoute('feed.html', (request) {
        return shelf.Response(404, body: '''
<div class="feed">
  <div class="tweet">Hello!</div>
  <div class="tweet">Hi!</div>
</div>
        ''', headers: {'content-type': 'text/html'});
      });
      await page.goto(server.assetUrl('feed.html'));
      //---
      var feedHandle = await page.$('.feed');
      expect(
          await feedHandle.$$eval(
              '.tweet', 'nodes => nodes.map(n => n.innerText)'),
          equals(['Hello!', 'Hi!']));
      //---
    });
    test('Seval', () async {
      server.setRoute('feed.html', (request) {
        return shelf.Response(404, body: '''
<div class="tweet">
  <div class="like">100</div>
  <div class="retweets">10</div>
</div>
        ''', headers: {'content-type': 'text/html'});
      });
      await page.goto(server.assetUrl('feed.html'));
      //---
      var tweetHandle = await page.$('.tweet');
      expect(await tweetHandle.$eval('.like', 'node => node.innerText'),
          equals('100'));
      expect(await tweetHandle.$eval('.retweets', 'node => node.innerText'),
          equals('10'));
      //--
    });
    group('type', () {
      test(0, () async {
        var elementHandle = await page.$('input');
        //---
        await elementHandle.type('Hello'); // Types instantly

        // Types slower, like a user
        await elementHandle.type('World', delay: Duration(milliseconds: 100));

        ///---
      });
      test(1, () async {
        var elementHandle = await page.$('input');
        await elementHandle.type('some text');
        await elementHandle.press(Key.enter);
      });
    });
    test('select', () async {
      var handle = await page.$('select');
      //---
      await handle.select(['blue']); // single selection
      await handle.select(['red', 'green', 'blue']); // multiple selections
      //---
    });
  });
  group('Request', () {
    test('continueRequest', () async {
      //---
      await page.setRequestInterception(true);
      page.onRequest.listen((request) {
        // Override headers
        var headers = Map<String, String>.from(request.headers)
          ..['foo'] = 'bar'
          ..remove('origin');
        request.continueRequest(headers: headers);
      });
      //---
      await page.goto(server.assetUrl('simple.html'));
    });
    test('failure', () async {
      page.onRequestFailed.listen((request) {
        print(request.url + ' ' + request.failure!);
      });
    });
    group('redirectChain', () {
      test(0, () async {
        server.setRoute('empty2.html', (request) {
          return shelf.Response.found('empty.html');
        });
        server.setRoute('empty.html', (request) {
          return shelf.Response.ok('');
        });
        //---
        var response = await page.goto(
            exampleValue(server.assetUrl('empty2.html'), 'http://example.com'));
        var chain = response.request.redirectChain;
        expect(chain, hasLength(1));
        expect(
            chain[0].url,
            equals(exampleValue(
                server.assetUrl('empty2.html'), 'http://example.com')));
        //--
      });
      test(1, () async {
        var response = await page.goto(exampleValue(
            server.assetUrl('doc_examples.html'), 'https://example.com'));
        var chain = response.request.redirectChain;
        expect(chain, isEmpty);
      });
    });
    test('respond', () async {
      await page.setRequestInterception(true);
      page.onRequest.listen((request) {
        request.respond(
            status: 404, contentType: 'text/plain', body: 'Not Found!');
      });
    });
  });
  group('Worker', () {
    test('class', () async {
      page.onWorkerCreated
          .listen((worker) => print('Worker created: ${worker.url}'));
      page.onWorkerDestroyed
          .listen((worker) => print('Worker destroyed: ${worker.url}'));
      print('Current workers:');
      for (var worker in page.workers) {
        print('  ${worker.url}');
      }
    });
  });
  group('Coverage', () {
    test('class', () async {
      //---
      // Enable both JavaScript and CSS coverage
      await Future.wait(
          [page.coverage.startJSCoverage(), page.coverage.startCSSCoverage()]);
      // Navigate to page
      await page.goto(exampleValue(
          server.assetUrl('doc_examples.html'), 'https://example.com'));
      // Disable both JavaScript and CSS coverage
      var jsCoverage = await page.coverage.stopJSCoverage();
      var cssCoverage = await page.coverage.stopCSSCoverage();
      var totalBytes = 0;
      var usedBytes = 0;
      var coverage = [...jsCoverage, ...cssCoverage];
      for (var entry in coverage) {
        totalBytes += entry.text.length;
        for (var range in entry.ranges) {
          usedBytes += range.end - range.start - 1;
        }
      }
      print('Bytes used: ${usedBytes / totalBytes * 100}%');
      //---
      expect(usedBytes, greaterThan(0));
      expect(totalBytes, greaterThan(0));
    });
  });
  group('Tracing', () {
    test('class', () async {
      //----
      await page.tracing.start();
      await page.goto(exampleValue(
          server.assetUrl('doc_examples.html'), 'https://www.google.com'));
      await page.tracing
          .stop(File(exampleValue('_trace.json', 'trace.json')).openWrite());
      //---
      expect(File('_trace.json').existsSync(), isTrue);
    });
  });
  group('Accessibility', () {
    group('snapshot', () {
      test(0, () async {
        var snapshot = await page.accessibility.snapshot();
        print(snapshot);
      });
      test(1, () async {
        AXNode? findFocusedNode(AXNode node) {
          if (node.focused) return node;
          for (var child in node.children) {
            var foundNode = findFocusedNode(child);
            return foundNode;
          }
          return null;
        }

        var snapshot = await page.accessibility.snapshot();
        var node = findFocusedNode(snapshot);
        print(node?.name);
      });
    });
  });
  group('FileChooser', () {
    test('class', () async {
      await page.goto(server.assetUrl('doc_examples_3.html'));
      //------
      var futureFileChooser = page.waitForFileChooser();
      // some button that triggers file selection
      await page.click('#upload-file-button');
      var fileChooser = await futureFileChooser;

      await fileChooser.accept(
          [File(exampleValue('test/assets/file-to-upload.txt', 'myfile.pdf'))]);
      //----
    });
  });
}
