import 'dart:convert';
import 'dart:io';
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

  group('JSCoverage', () {
    test('should work', () async {
      await page.coverage.startJSCoverage();
      await page.goto(server.prefix + '/jscoverage/simple.html',
          wait: Until.networkIdle);
      var coverage = await page.coverage.stopJSCoverage();
      expect(coverage.length, equals(1));
      expect(coverage[0].url, contains('/jscoverage/simple.html'));
      expect(
          coverage[0].ranges,
          equals([
            Range(0, 17),
            Range(35, 61),
          ]));
    });
    test('should report sourceURLs', () async {
      await page.coverage.startJSCoverage();
      await page.goto(server.prefix + '/jscoverage/sourceurl.html');
      var coverage = await page.coverage.stopJSCoverage();
      expect(coverage.length, equals(1));
      expect(coverage[0].url, equals('nicename.js'));
    });
    test('should ignore eval() scripts by default', () async {
      await page.coverage.startJSCoverage();
      await page.goto(server.prefix + '/jscoverage/eval.html');
      var coverage = await page.coverage.stopJSCoverage();
      expect(coverage.length, equals(1));
    });
    test('shouldnt ignore eval() scripts if reportAnonymousScripts is true',
        () async {
      await page.coverage.startJSCoverage(reportAnonymousScripts: true);
      await page.goto(server.prefix + '/jscoverage/eval.html');
      var coverage = await page.coverage.stopJSCoverage();
      expect(
          coverage.firstWhere((entry) => entry.url.startsWith('debugger://')),
          isNotNull);
      expect(coverage.length, equals(2));
    });
    test(
        'should ignore pptr internal scripts if reportAnonymousScripts is true',
        () async {
      await page.coverage.startJSCoverage(reportAnonymousScripts: true);
      await page.goto(server.emptyPage);
      await page.evaluate('console.log("foo")');
      await page.evaluate("() => console.log('bar')");
      var coverage = await page.coverage.stopJSCoverage();
      expect(coverage.length, equals(0));
    });
    test('should report multiple scripts', () async {
      await page.coverage.startJSCoverage();
      await page.goto(server.prefix + '/jscoverage/multiple.html');
      var coverage = await page.coverage.stopJSCoverage();
      expect(coverage.length, equals(2));
      coverage.sort((a, b) => a.url.compareTo(b.url));
      expect(coverage[0].url, contains('/jscoverage/script1.js'));
      expect(coverage[1].url, contains('/jscoverage/script2.js'));
    });
    test('should report right ranges', () async {
      await page.coverage.startJSCoverage();
      await page.goto(server.prefix + '/jscoverage/ranges.html');
      var coverage = await page.coverage.stopJSCoverage();
      expect(coverage.length, equals(1));
      var entry = coverage[0];
      expect(entry.ranges.length, equals(1));
      var range = entry.ranges[0];
      expect(entry.text.substring(range.start, range.end),
          equals("console.log('used!');"));
    });
    test('should report scripts that have no coverage', () async {
      await page.coverage.startJSCoverage();
      await page.goto(server.prefix + '/jscoverage/unused.html');
      var coverage = await page.coverage.stopJSCoverage();
      expect(coverage.length, equals(1));
      var entry = coverage[0];
      expect(entry.url, contains('unused.html'));
      expect(entry.ranges.length, equals(0));
    });
    test('should work with conditionals', () async {
      await page.coverage.startJSCoverage();
      await page.goto(server.prefix + '/jscoverage/involved.html');
      var coverage = await page.coverage.stopJSCoverage();

      var formattedCoverage = JsonEncoder.withIndent('  ')
          .convert(coverage)
          .replaceAll(RegExp(r':\d+/'), ':<PORT>/');
      expect(
          normalizeNewLines(formattedCoverage),
          equals(normalizeNewLines(
              File('test/golden/jscoverage-involved.txt').readAsStringSync())));
    });
    group('resetOnNavigation', () {
      test('should report scripts across navigations when disabled', () async {
        await page.coverage.startJSCoverage(resetOnNavigation: false);
        await page.goto(server.prefix + '/jscoverage/multiple.html');
        await page.goto(server.emptyPage);
        var coverage = await page.coverage.stopJSCoverage();
        expect(coverage.length, equals(2));
      });
      test('should NOT report scripts across navigations when enabled',
          () async {
        await page.coverage.startJSCoverage(); // Enabled by default.
        await page.goto(server.prefix + '/jscoverage/multiple.html');
        await page.goto(server.emptyPage);
        var coverage = await page.coverage.stopJSCoverage();
        expect(coverage.length, equals(0));
      });
    });
  });

  group('CSSCoverage', () {
    test('should work', () async {
      await page.coverage.startCSSCoverage();
      await page.goto(server.prefix + '/csscoverage/simple.html');
      var coverage = await page.coverage.stopCSSCoverage();
      expect(coverage.length, equals(1));
      expect(coverage[0].url, contains('/csscoverage/simple.html'));
      expect(coverage[0].ranges, equals([Range(1, 22)]));
      var range = coverage[0].ranges[0];
      expect(coverage[0].text.substring(range.start, range.end),
          equals('div { color: green; }'));
    });
    test('should report sourceURLs', () async {
      await page.coverage.startCSSCoverage();
      await page.goto(server.prefix + '/csscoverage/sourceurl.html');
      var coverage = await page.coverage.stopCSSCoverage();
      expect(coverage.length, equals(1));
      expect(coverage[0].url, equals('nicename.css'));
    });
    test('should report multiple stylesheets', () async {
      await page.coverage.startCSSCoverage();
      await page.goto(server.prefix + '/csscoverage/multiple.html');
      var coverage = await page.coverage.stopCSSCoverage();
      expect(coverage.length, equals(2));
      coverage.sort((a, b) => a.url.compareTo(b.url));
      expect(coverage[0].url, contains('/csscoverage/stylesheet1.css'));
      expect(coverage[1].url, contains('/csscoverage/stylesheet2.css'));
    });
    test('should report stylesheets that have no coverage', () async {
      await page.coverage.startCSSCoverage();
      await page.goto(server.prefix + '/csscoverage/unused.html');
      var coverage = await page.coverage.stopCSSCoverage();
      expect(coverage.length, equals(1));
      expect(coverage[0].url, equals('unused.css'));
      expect(coverage[0].ranges.length, equals(0));
    });
    test('should work with media queries', () async {
      await page.coverage.startCSSCoverage();
      await page.goto(server.prefix + '/csscoverage/media.html');
      var coverage = await page.coverage.stopCSSCoverage();
      expect(coverage.length, equals(1));
      expect(coverage[0].url, contains('/csscoverage/media.html'));
      expect(coverage[0].ranges, equals([Range(17, 38)]));
    });
    test('should work with complicated usecases', () async {
      await page.coverage.startCSSCoverage();
      await page.goto(server.prefix + '/csscoverage/involved.html');
      var coverage = await page.coverage.stopCSSCoverage();
      var formattedCoverage = JsonEncoder.withIndent('  ')
          .convert(coverage)
          .replaceAll(RegExp(r':\d+/'), ':<PORT>/');
      expect(
          normalizeNewLines(formattedCoverage),
          equals(normalizeNewLines(File('test/golden/csscoverage-involved.txt')
              .readAsStringSync())));
    });
    test('should ignore injected stylesheets', () async {
      await page.coverage.startCSSCoverage();
      await page.addStyleTag(content: 'body { margin: 10px;}');
      // trigger style recalc
      var margin = await page
          .evaluate('() => window.getComputedStyle(document.body).margin');
      expect(margin, equals('10px'));
      var coverage = await page.coverage.stopCSSCoverage();
      expect(coverage.length, equals(0));
    });
    group('resetOnNavigation', () {
      test('should report stylesheets across navigations', () async {
        await page.coverage.startCSSCoverage(resetOnNavigation: false);
        await page.goto(server.prefix + '/csscoverage/multiple.html');
        await page.goto(server.emptyPage);
        var coverage = await page.coverage.stopCSSCoverage();
        expect(coverage.length, equals(2));
      });
      test('should NOT report scripts across navigations', () async {
        await page.coverage.startCSSCoverage(); // Enabled by default.
        await page.goto(server.prefix + '/csscoverage/multiple.html');
        await page.goto(server.emptyPage);
        var coverage = await page.coverage.stopCSSCoverage();
        expect(coverage.length, equals(0));
      });
    });
    test('should work with a recently loaded stylesheet', () async {
      await page.coverage.startCSSCoverage();
      await page.evaluate('''async url => {
document.body.textContent = 'hello, world';

var link = document.createElement('link');
link.rel = 'stylesheet';
link.href = url;
document.head.appendChild(link);
await new Promise(x => link.onload = x);
}''', args: [server.prefix + '/csscoverage/stylesheet1.css']);
      var coverage = await page.coverage.stopCSSCoverage();
      expect(coverage.length, equals(1));
    });
  });
}
