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

  group(r'Page.$eval', () {
    test('should work', () async {
      await page.setContent('<section id="testAttribute">43543</section>');
      var idAttribute = await page.$eval('section', 'e => e.id');
      expect(idAttribute, equals('testAttribute'));
    });
    test('should accept arguments', () async {
      await page.setContent('<section>hello</section>');
      var text = await page.$eval(
          'section', '(e, suffix) => e.textContent + suffix',
          args: [' world!']);
      expect(text, equals('hello world!'));
    });
    test('should accept ElementHandles as arguments', () async {
      await page.setContent('<section>hello</section><div> world</div>');
      var divHandle = await page.$('div');
      var text = await page.$eval(
          'section', '(e, div) => e.textContent + div.textContent',
          args: [divHandle]);
      expect(text, equals('hello world'));
    });
    test('should throw error if no element is found', () async {
      expect(
          () => page.$eval('section', 'e => e.id'),
          throwsA(predicate((e) =>
              '$e' ==
              'Exception: Error: failed to find element matching selector "section"')));
    });
  });

  group(r'Page.$$eval', () {
    test('should work', () async {
      await page
          .setContent('<div>hello</div><div>beautiful</div><div>world!</div>');
      var divsCount = await page.$$eval('div', 'divs => divs.length');
      expect(divsCount, equals(3));
    });
  });

  group(r'Page.$', () {
    test('should query existing element', () async {
      await page.setContent('<section>test</section>');
      var element = await page.$('section');
      expect(element, isNotNull);
    });
    test('should return null for non-existing element', () async {
      var element = await page.$OrNull('non-existing-element');
      expect(element, isNull);
    });
  });

  group(r'Page.$$', () {
    test('should query existing elements', () async {
      await page.setContent('<div>A</div><br/><div>B</div>');
      var elements = await page.$$('div');
      expect(elements.length, equals(2));
      var promises = elements.map(
          (element) => page.evaluate('e => e.textContent', args: [element]));
      expect(await Future.wait(promises), equals(['A', 'B']));
    });
    test('should return empty array if nothing is found', () async {
      await page.goto(server.emptyPage);
      var elements = await page.$$('div');
      expect(elements, isEmpty);
    });
  });

  group(r'Path.$x', () {
    test('should query existing element', () async {
      await page.setContent('<section>test</section>');
      var elements = await page.$x('/html/body/section');
      expect(elements[0], isNotNull);
      expect(elements.length, equals(1));
    });
    test('should return empty array for non-existing element', () async {
      var element = await page.$x('/html/body/non-existing-element');
      expect(element, isEmpty);
    });
    test('should return multiple elements', () async {
      await page.setContent('<div></div><div></div>');
      var elements = await page.$x('/html/body/div');
      expect(elements, hasLength(2));
    });
  });

  group(r'ElementHandle.$', () {
    test('should query existing element', () async {
      await page.goto(server.prefix + '/playground.html');
      await page.setContent(
          '<html><body><div class="second"><div class="inner">A</div></div></body></html>');
      var html = await page.$('html');
      var second = await html.$('.second');
      var inner = await second.$('.inner');
      var content = await page.evaluate('e => e.textContent', args: [inner]);
      expect(content, equals('A'));
    });

    test('should return null for non-existing element', () async {
      await page.setContent(
          '<html><body><div class="second"><div class="inner">B</div></div></body></html>');
      var html = await page.$('html');
      var second = await html.$OrNull('.third');
      expect(second, isNull);
    });
  });
  group(r'ElementHandle.$eval', () {
    test('should work', () async {
      await page.setContent(
          '<html><body><div class="tweet"><div class="like">100</div><div class="retweets">10</div></div></body></html>');
      var tweet = await page.$('.tweet');
      var content = await tweet.$eval('.like', 'node => node.innerText');
      expect(content, equals('100'));
    });

    test('should retrieve content from subtree', () async {
      var htmlContent =
          '<div class="a">not-a-child-div</div><div id="myId"><div class="a">a-child-div</div></div>';
      await page.setContent(htmlContent);
      var elementHandle = await page.$('#myId');
      var content = await elementHandle.$eval('.a', 'node => node.innerText');
      expect(content, equals('a-child-div'));
    });

    test('should throw in case of missing selector', () async {
      var htmlContent =
          '<div class="a">not-a-child-div</div><div id="myId"></div>';
      await page.setContent(htmlContent);
      var elementHandle = await page.$('#myId');
      expect(
          () => elementHandle.$eval('.a', 'node => node.innerText'),
          throwsA(predicate((e) =>
              '$e' ==
              'Exception: Error: failed to find element matching selector ".a"')));
    });
  });
  group(r'ElementHandle.$$eval', () {
    test('should work', () async {
      await page.setContent(
          '<html><body><div class="tweet"><div class="like">100</div><div class="like">10</div></div></body></html>');
      var tweet = await page.$('.tweet');
      var content =
          await tweet.$$eval('.like', 'nodes => nodes.map(n => n.innerText)');
      expect(content, equals(['100', '10']));
    });

    test('should retrieve content from subtree', () async {
      var htmlContent =
          '<div class="a">not-a-child-div</div><div id="myId"><div class="a">a1-child-div</div><div class="a">a2-child-div</div></div>';
      await page.setContent(htmlContent);
      var elementHandle = await page.$('#myId');
      var content = await elementHandle.$$eval(
          '.a', 'nodes => nodes.map(n => n.innerText)');
      expect(content, equals(['a1-child-div', 'a2-child-div']));
    });

    test('should not throw in case of missing selector', () async {
      var htmlContent =
          '<div class="a">not-a-child-div</div><div id="myId"></div>';
      await page.setContent(htmlContent);
      var elementHandle = await page.$('#myId');
      var nodesLength =
          await elementHandle.$$eval('.a', 'nodes => nodes.length');
      expect(nodesLength, equals(0));
    });
  });

  group(r'ElementHandle.$$', () {
    test('should query existing elements', () async {
      await page.setContent(
          '<html><body><div>A</div><br/><div>B</div></body></html>');
      var html = await page.$('html');
      var elements = await html.$$('div');
      expect(elements.length, equals(2));
      var promises = elements.map(
          (element) => page.evaluate('e => e.textContent', args: [element]));
      expect(await Future.wait(promises), equals(['A', 'B']));
    });

    test('should return empty array for non-existing elements', () async {
      await page.setContent(
          '<html><body><span>A</span><br/><span>B</span></body></html>');
      var html = await page.$('html');
      var elements = await html.$$('div');
      expect(elements, isEmpty);
    });
  });

  group(r'ElementHandle.$x', () {
    test('should query existing element', () async {
      await page.goto(server.prefix + '/playground.html');
      await page.setContent(
          '<html><body><div class="second"><div class="inner">A</div></div></body></html>');
      var html = await page.$('html');
      var second = await html.$x("./body/div[contains(@class, 'second')]");
      var inner = await second[0].$x("./div[contains(@class, 'inner')]");
      var content = await page.evaluate('e => e.textContent', args: [inner[0]]);
      expect(content, equals('A'));
    });

    test('should return null for non-existing element', () async {
      await page.setContent(
          '<html><body><div class="second"><div class="inner">B</div></div></body></html>');
      var html = await page.$('html');
      var second = await html.$x("/div[contains(@class, 'third')]");
      expect(second, isEmpty);
    });
  });
}
