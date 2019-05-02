import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart' as crypto;
import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils.dart';

// The tests in this file are extracted by the script `tool/inject_examples_to_doc.dart`
// and injected into the documentation in the source code.
// This help to ensure that the examples provided in the code are correct.
main() {
  Server server;
  Browser browser;
  Page page;
  PageFrame frame;
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
  });

  group('Browser', () {
    test('class', () async {
      //---
      main() async {
        var browser = await puppeteer.launch();
        var page = await browser.newPage();
        await page.goto(server.hostUrl);
        await browser.close();
      }
      //---

      await main();
    });
    test('createIncognitoBrowserContext', () async {
      //---
      main() async {
        var browser = await puppeteer.launch();
        // Create a new incognito browser context.
        var context = await browser.createIncognitoBrowserContext();
        // Create a new page in a pristine context.
        var page = await context.newPage();
        // Do stuff
        await page.goto(server.hostUrl);
        await browser.close();
      }
      //---

      await main();
    });
    test('waitForTarget', () async {
      //---
      var newWindowTarget =
          browser.waitForTarget((target) => target.url == '${server.hostUrl}/');
      await page.evaluate("() => window.open('${server.hostUrl}/')");
      await newWindowTarget;
      //---
      newWindowTarget.toString();
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
      await context
          .overridePermissions(server.hostUrl, [PermissionType.clipboardRead]);
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

        main() async {
          var browser = await puppeteer.launch();
          var page = await browser.newPage();
          await page.goto(server.hostUrl);
          await File('_screenshot.png').writeAsBytes(await page.screenshot());
          await browser.close();
        }

        //---
        await main();
      });
      test(1, () async {
        page.onLoad.listen((_) => print('Page loaded!'));
      });
      test(2, () async {
        logRequest(NetworkRequest interceptedRequest) {
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
        Page popup = await popupFuture;
        //----
        popup.toString();
      });
      test(1, () async {
        //----
        var popupFuture = page.onPopup.first;
        await page.evaluate("() => window.open('${server.hostUrl}')");
        Page popup = await popupFuture;
        //----
        popup.toString();
      });
    });
    test('SSeval', () async {
      //---
      var divsCounts = await page.$$eval('div', 'divs => divs.length');
      //---
      print(divsCounts);
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
      searchValue.toString();
      preloadHref.toString();
      html.toString();
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
    test('emulate', () async {
      var iPhone = puppeteer.devices.iPhone6;

      var browser = await puppeteer.launch();
      var page = await browser.newPage();
      await page.emulate(iPhone);
      await page.goto(server.docExamplesUrl);
      // other actions...
      await browser.close();
    });
    group('evaluate', () {
      test(0, () async {
        int result = await page.evaluate('''x => {
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
        aHandle.toString();
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

        main() async {
          var browser = await puppeteer.launch();
          var page = await browser.newPage();
          page.onConsole.listen((msg) => print(msg.text));
          await page.exposeFunction('md5',
              (text) => crypto.md5.convert(utf8.encode(text)).toString());
          await page.evaluate(r'''async () => {
            // use window.md5 to compute hashes
            const myString = 'PUPPETEER';
            const myHash = await window.md5(myString);
            console.log(`md5 of ${myString} is ${myHash}`);
          }''');
          await browser.close();
        }
        //----

        await main();
      });
      test(1, () async {
        //----
        //+import 'dart:io';
        //+import 'package:puppeteer/puppeteer.dart';

        main() async {
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

        await main();
      });
    });
    test('pdf', () async {
      // Generates a PDF with 'screen' media type.
      await page.emulateMedia('screen');
      var pdfBytes = await page.pdf();
      await File('_page.pdf').writeAsBytes(pdfBytes);
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
      await page.goto(server.hostUrl);
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

        main() async {
          var browser = await puppeteer.launch();
          var page = await browser.newPage();
          var watchDog = page.waitForFunction('window.innerWidth < 100');
          await page.setViewport(DeviceViewport(width: 50, height: 50));
          await watchDog;
          await browser.close();
        }
        //---

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
      var firstRequest = page.waitForRequest(server.hostUrl);

      // You can achieve the same effect (and more powerful) with the `onRequest`
      // stream.
      var finalRequest = page.onRequest
          .where((request) =>
              request.url.startsWith(server.hostUrl) && request.method == 'GET')
          .first
          .timeout(Duration(seconds: 30));

      await page.goto(server.hostUrl);
      await Future.wait([firstRequest, finalRequest]);
      //----
    });
    test('waitForSelector', () async {
      //---
      //+import 'package:puppeteer/puppeteer.dart';

      main() async {
        var browser = await puppeteer.launch();
        var page = await browser.newPage();
        var watchImg = page.waitForSelector('img');
        await page.goto(server.docExamples2Url);
        var image = await watchImg;
        print(await image.propertyValue('src'));
        await browser.close();
      }
      //---

      await main();
    });
    test('waitForXPath', () async {
      //---
      //+import 'package:puppeteer/puppeteer.dart';

      main() async {
        var browser = await puppeteer.launch();
        var page = await browser.newPage();
        var watchImg = page.waitForXPath('//img');
        await page.goto(server.docExamples2Url);
        var image = await watchImg;
        print(await image.propertyValue('src'));
        await browser.close();
      }
      //---

      await main();
    });
  });
  group('PageFrame', () {
    group('class', () {
      test(0, () async {
        dumpFrameTree(PageFrame frame, String indent) {
          print(indent + frame.url);
          for (var child in frame.childFrames) {
            dumpFrameTree(child, indent + '  ');
          }
        }

        var browser = await puppeteer.launch();
        var page = await browser.newPage();
        await page.goto(server.hostUrl);
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
      searchValue.toString();
      preloadHref.toString();
      html.toString();
    });
    test('SSeval', () async {
      //---
      var divsCounts = await frame.$$eval('div', 'divs => divs.length');
      //---
      print(divsCounts);
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
  });
}
