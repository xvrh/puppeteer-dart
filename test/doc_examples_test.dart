import 'dart:io';
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
  setUpAll(() async {
    server = await Server.create();
  });

  tearDownAll(() async {
    await server.close();
  });

  setUp(() async {
    browser = await puppeteer.launch();
    page = await browser.newPage();
  });

  tearDown(() async {
    await browser.close();
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
  });
  group('PageFrame', () {
    test('Seval', () async {
      await page.goto(server.assetUrl('doc_examples.html'));
      var frame = page.mainFrame;
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
  });
}
