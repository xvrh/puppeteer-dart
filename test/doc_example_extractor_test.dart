import 'package:test/test.dart';
import '../tool/inject_examples_to_doc.dart';

void main() {
  test('Extract snippets', () {
    var snippets = extractSnippets(_testFileCode);

    expect(snippets[0].target, equals('Browser.class'));
    expect(snippets[0].code, equals(r'''
main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.goto('https://example.com');
  await browser.close();
}'''));

    expect(snippets[1].target, equals('Browser.createIncognitoBrowserContext'));
    expect(snippets[1].code, equals(r'''
var browser = await puppeteer.launch();
// Create a new incognito browser context.
var context = await browser.createIncognitoBrowserContext();
// Create a new page in a pristine context.
var page = await context.newPage();
// Do stuff
await page.goto('https://example.com');
await browser.close();'''));

    expect(snippets[4].target, equals('Page.class'));
    expect(snippets[4].index, equals(0));
    expect(snippets[4].code, equals(r'''
import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.goto('https://example.com');
  await File('screenshot.png').writeAsBytes(await page.screenshot());
  await browser.close();
}'''));

    expect(snippets[5].target, equals('Page.class'));
    expect(snippets[5].index, equals(1));
    expect(snippets[5].code,
        equals("page.onLoad.listen((_) => print('Page loaded!'));"));

    expect(snippets[8].target, equals('Frame.Seval'));
    expect(snippets[8].code, equals(r'''
var searchValue =
    await frame.$eval('#search', 'function (el) { return el.value; }');
var preloadHref = await frame.$eval(
    'link[rel=preload]', 'function (el) { return el.href; }');
var html = await frame.$eval(
    '.main-container', 'function (e) { return e.outerHTML; }');'''));
  });

  test('Replace examples', () {
    var snippets = extractSnippets(_testFileCode);

    var results = replaceExamples(_libCode, snippets);

    expect(results, equals(_expectedLibCode));
  });

  test('Replace simple exampleValue', () {
    expect(CodeSnippet.fixCode(r'''
await page.goto(exampleValue(server.hostUrl, 'https://example.com'));
await browser.close();
    '''), equals(r'''
await page.goto('https://example.com');
await browser.close();'''));
  });

  test('Replace import', () {
    expect(CodeSnippet.fixCode(r'''
//+import 'dart:io';
//+import 'package:puppeteer/puppeteer.dart';

main() async {
  var browser = await puppeteer.launch();
}
    '''), equals(r'''
import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

main() async {
  var browser = await puppeteer.launch();
}'''));
  });

  test('Replace exampleValue remove string interpolation', () {
    expect(CodeSnippet.fixCode(r'''
await page.evaluate("() => window.open('${exampleValue(server.hostUrl, 'https://example.com')}/')");
    '''), equals(r'''
await page.evaluate("() => window.open('https://example.com/')");'''));
  });
}

final _testFileCode = r'''
import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';

import 'utils/utils.dart';

main() {
  Server server;
  Browser browser;
  Page page;
  setUpAll(() async {
    server = await Server.create();
    browser = await puppeteer.launch();
  });

  group('Browser', () {
    test('class', () async {
      //---
      main() async {
        var browser = await puppeteer.launch();
        var page = await browser.newPage();
        await page.goto('https://example.com');
        await browser.close();
      }
      //---

      await main();
    });
    test('createIncognitoBrowserContext', () async {
      var browser = await puppeteer.launch();
      // Create a new incognito browser context.
      var context = await browser.createIncognitoBrowserContext();
      // Create a new page in a pristine context.
      var page = await context.newPage();
      // Do stuff
      await page.goto('https://example.com');
      await browser.close();
    });
    test('waitForTarget', () async {
      //---
      await page.evaluate("() => window.open('https://www.example.com/')");
      var newWindowTarget = await browser
          .waitForTarget((target) => target.url == 'https://www.example.com/');
      //---
      newWindowTarget.toString();
    });
  });
  group('Dialog', () {
    test('class', () async {
      var browser = await puppeteer.launch();
      var page = await browser.newPage();
      page.onDialog.listen((dialog) async {
        print(dialog.message);
        await dialog.dismiss();
        await browser.close();
      });
      await page.evaluate("() => alert('1')");
    });
  });
  group('Page', () {
    group('class', () {
      test(0, () async {
      //---
      //+import 'dart:io';
      //+import 'package:puppeteer/puppeteer.dart';

      main() async {
        var browser = await puppeteer.launch();
        var page = await browser.newPage();
        await page.goto('https://example.com');
        await File('screenshot.png').writeAsBytes(await page.screenshot());
        await browser.close();
      }

      //---
      await main();
      });
      test(1, () async {
        page.onLoad.listen((_) => print('Page loaded!'));
      });
      test(2, () async {
        logRequest(Request interceptedRequest) {
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
  group('Frame', () {
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
''';

final _libCode = '''
import 'dart:async';

/// A Browser is created when Puppeteer connects to a Chromium instance, either
/// through puppeteer.launch or puppeteer.connect.
///
/// An example of using a Browser to create a Page:
///
/// ```dart
/// main() {
///   var browser = await puppeteer.launch();
///   var page = await browser.newPage();
///   await page.goto('http://example.com');
///   await browser.close();
/// }
/// ```
class Browser {
  final Connection connection;

  /// Emitted when a target is created, for example when a new page is opened by
  /// [window.open](https://developer.mozilla.org/en-US/docs/Web/API/Window/open)
  /// or [Browser.newPage].
  Stream<Target> get onTargetCreated => _onTargetCreatedController.stream;

  /// Creates a new incognito browser context. This won't share cookies/cache
  /// with other browser contexts.
  ///
  /// ```dart
  /// createIncognitoBrowserContext example
  /// ```
  Future<BrowserContext> createIncognitoBrowserContext() async {
    var browserContextId = await targetApi.createBrowserContext();
    var context = BrowserContext(connection, this, browserContextId);
    _contexts[browserContextId] = context;
    return context;
  }
}
''';

final _expectedLibCode = '''
import 'dart:async';

/// A Browser is created when Puppeteer connects to a Chromium instance, either
/// through puppeteer.launch or puppeteer.connect.
///
/// An example of using a Browser to create a Page:
///
/// ```dart
/// main() async {
///   var browser = await puppeteer.launch();
///   var page = await browser.newPage();
///   await page.goto('https://example.com');
///   await browser.close();
/// }
/// ```
class Browser {
  final Connection connection;

  /// Emitted when a target is created, for example when a new page is opened by
  /// [window.open](https://developer.mozilla.org/en-US/docs/Web/API/Window/open)
  /// or [Browser.newPage].
  Stream<Target> get onTargetCreated => _onTargetCreatedController.stream;

  /// Creates a new incognito browser context. This won't share cookies/cache
  /// with other browser contexts.
  ///
  /// ```dart
  /// var browser = await puppeteer.launch();
  /// // Create a new incognito browser context.
  /// var context = await browser.createIncognitoBrowserContext();
  /// // Create a new page in a pristine context.
  /// var page = await context.newPage();
  /// // Do stuff
  /// await page.goto('https://example.com');
  /// await browser.close();
  /// ```
  Future<BrowserContext> createIncognitoBrowserContext() async {
    var browserContextId = await targetApi.createBrowserContext();
    var context = BrowserContext(connection, this, browserContextId);
    _contexts[browserContextId] = context;
    return context;
  }
}
''';
