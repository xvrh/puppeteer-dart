import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils/utils.dart';

// Ported from upstream Puppeteer test/src/queryhandler.test.ts.
//
// Adaptations to this repo:
// - The `/p-selectors.html` server fixture is inlined via `setContent`.
// - ARIA selectors (`::-p-aria` / `aria/`), custom query handlers and the
//   `:hover` case are out of scope for this batch and not ported.

const _pSelectorsFixture = '''
<div id="a">hello <button id="b">world</button>
    <span id="f"></span>
    <div id="c"></div>
</div>
<a>My name is Jun (pronounced like "June")</a>
<script>
    const topShadow = document.querySelector('#c');
    topShadow.attachShadow({ mode: "open" });
    topShadow.shadowRoot.innerHTML = `shadow dom<div id="d"></div>`;
    const innerShadow = topShadow.shadowRoot.querySelector('#d');
    innerShadow.attachShadow({ mode: "open" });
    innerShadow.shadowRoot.innerHTML = `<a id="e">deep text</a>`;
</script>
''';

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

  Future<void> setUpShadow() async {
    await page.setContent('''
<script>
 const div = document.createElement('div');
 const shadowRoot = div.attachShadow({mode: 'open'});
 const div1 = document.createElement('div');
 div1.textContent = 'Hello';
 div1.className = 'foo';
 const div2 = document.createElement('div');
 div2.textContent = 'World';
 div2.className = 'foo';
 shadowRoot.appendChild(div1);
 shadowRoot.appendChild(div2);
 document.documentElement.appendChild(div);
 </script>
''');
  }

  group('Pierce selectors', () {
    test('should find first element in shadow', () async {
      await setUpShadow();
      var div = await page.$('pierce/.foo');
      expect(await div.evaluate('e => e.textContent'), 'Hello');
    });
    test('should find all elements in shadow', () async {
      await setUpShadow();
      var divs = await page.$$('pierce/.foo');
      var text = await Future.wait(
        divs.map((d) => d.evaluate('e => e.textContent')),
      );
      expect(text.join(' '), 'Hello World');
    });
    test('should find first child element', () async {
      await setUpShadow();
      var parent = await page.$('html > div');
      var child = await parent.$('pierce/div');
      expect(await child.evaluate('e => e.textContent'), 'Hello');
    });
    test('should find all child elements', () async {
      await setUpShadow();
      var parent = await page.$('html > div');
      var children = await parent.$$('pierce/div');
      var text = await Future.wait(
        children.map((d) => d.evaluate('e => e.textContent')),
      );
      expect(text.join(' '), 'Hello World');
    });
  });

  group('Text selectors', () {
    group('in Page', () {
      test('should query existing element', () async {
        await page.setContent('<section>test</section>');
        expect(await page.$('text/test'), isNotNull);
        expect(await page.$$('text/test'), hasLength(1));
      });
      test('should return empty array for non-existing element', () async {
        expect(await page.$OrNull('text/test'), isNull);
        expect(await page.$$('text/test'), hasLength(0));
      });
      test('should return first element', () async {
        await page.setContent('<div id="1">a</div> <div>a</div>');
        var element = await page.$('text/a');
        expect(await element.evaluate('e => e.id'), '1');
      });
      test('should return multiple elements', () async {
        await page.setContent('<div>a</div> <div>a</div>');
        expect(await page.$$('text/a'), hasLength(2));
      });
      test('should pierce shadow DOM', () async {
        await page.evaluate('''() => {
          const div = document.createElement('div');
          const shadow = div.attachShadow({mode: 'open'});
          const diva = document.createElement('div');
          shadow.append(diva);
          const divb = document.createElement('div');
          shadow.append(divb);
          diva.innerHTML = 'a';
          divb.innerHTML = 'b';
          document.body.append(div);
        }''');
        var element = await page.$('text/a');
        expect(await element.evaluate('e => e.textContent'), 'a');
      });
      test('should query deeply nested text', () async {
        await page.setContent('<div><div>a</div><div>b</div></div>');
        var element = await page.$('text/a');
        expect(await element.evaluate('e => e.textContent'), 'a');
      });
      test('should query inputs', () async {
        await page.setContent('<input value="a" />');
        var element = await page.$('text/a');
        expect(await element.evaluate('e => e.value'), 'a');
      });
      test('should not query radio', () async {
        await page.setContent('<radio value="a"></radio>');
        expect(await page.$OrNull('text/a'), isNull);
      });
      test('should query text spanning multiple elements', () async {
        await page.setContent('<div><span>a</span> <span>b</span></div>');
        var element = await page.$('text/a b');
        expect(await element.evaluate('e => e.textContent'), 'a b');
      });
    });
    group('in ElementHandles', () {
      test('should query existing element', () async {
        await page.setContent('<div class="a"><span>a</span></div>');
        var elementHandle = await page.$('div');
        expect(await elementHandle.$OrNull('text/a'), isNotNull);
        expect(await elementHandle.$$('text/a'), hasLength(1));
      });
      test('should return null for non-existing element', () async {
        await page.setContent('<div class="a"></div>');
        var elementHandle = await page.$('div');
        expect(await elementHandle.$OrNull('text/a'), isNull);
        expect(await elementHandle.$$('text/a'), hasLength(0));
      });
    });
  });

  group('XPath selectors', () {
    group('in Page', () {
      test('should query existing element', () async {
        await page.setContent('<section>test</section>');
        expect(await page.$('xpath/html/body/section'), isNotNull);
        expect(await page.$$('xpath/html/body/section'), hasLength(1));
      });
      test('should return empty array for non-existing element', () async {
        expect(await page.$OrNull('xpath/html/body/non-existing'), isNull);
        expect(await page.$$('xpath/html/body/non-existing'), hasLength(0));
      });
      test('should return first element', () async {
        await page.setContent('<div>a</div> <div></div>');
        var element = await page.$('xpath/html/body/div');
        expect(await element.evaluate("e => e.textContent === 'a'"), isTrue);
      });
      test('should return multiple elements', () async {
        await page.setContent('<div></div> <div></div>');
        expect(await page.$$('xpath/html/body/div'), hasLength(2));
      });
    });
    group('in ElementHandles', () {
      test('should query existing element', () async {
        await page.setContent('<div class="a">a<span></span></div>');
        var elementHandle = await page.$('div');
        expect(await elementHandle.$OrNull('xpath/span'), isNotNull);
        expect(await elementHandle.$$('xpath/span'), hasLength(1));
      });
      test('should return null for non-existing element', () async {
        await page.setContent('<div class="a">a</div>');
        var elementHandle = await page.$('div');
        expect(await elementHandle.$OrNull('xpath/span'), isNull);
        expect(await elementHandle.$$('xpath/span'), hasLength(0));
      });
    });
  });

  group('P selectors', () {
    test('should work with CSS selectors', () async {
      await page.setContent(_pSelectorsFixture);
      var element = await page.$('div > button');
      expect(await element.evaluate("e => e.id === 'b'"), isTrue);
    });

    test('should work with puppeteer pseudo classes', () async {
      await page.setContent(_pSelectorsFixture);
      var element = await page.$('button::-p-text(world)');
      expect(await element.evaluate("e => e.id === 'b'"), isTrue);
    });

    test('should work with deep combinators', () async {
      await page.setContent(_pSelectorsFixture);
      {
        var element = await page.$('div >>>> div');
        expect(await element.evaluate("e => e.id === 'c'"), isTrue);
      }
      {
        var elements = await page.$$('div >>> div');
        expect(await elements[1].evaluate("e => e.id === 'd'"), isTrue);
      }
      {
        var elements = await page.$$('#c >>>> div');
        expect(await elements[0].evaluate("e => e.id === 'd'"), isTrue);
      }
      {
        var elements = await page.$$('#c >>> div');
        expect(await elements[0].evaluate("e => e.id === 'd'"), isTrue);
      }
    });

    test('should work with text selectors', () async {
      await page.setContent(_pSelectorsFixture);
      var element = await page.$('div ::-p-text(world)');
      expect(await element.evaluate("e => e.id === 'b'"), isTrue);
    });

    test('should work with XPath selectors', () async {
      await page.setContent(_pSelectorsFixture);
      var element = await page.$('div ::-p-xpath(//button)');
      expect(await element.evaluate("e => e.id === 'b'"), isTrue);
    });

    test('should work with selector lists', () async {
      await page.setContent(_pSelectorsFixture);
      var elements = await page.$$('div, ::-p-text(world)');
      expect(elements, hasLength(3));
    });

    test('should match querySelector* ordering', () async {
      await page.setContent(_pSelectorsFixture);
      for (var list in _permute(['div', 'button', 'span'])) {
        var selector = list
            .map((s) => s == 'button' ? '::-p-text(world)' : s)
            .join(',');
        var elements = await page.$$(selector);
        var ids = await Future.wait(
          elements.map((e) => e.evaluate<String>('e => e.id')),
        );
        expect(ids.join(','), 'a,b,f,c');
      }
    });

    test('should not have duplicate elements from selector lists', () async {
      await page.setContent(_pSelectorsFixture);
      var elements = await page.$$('::-p-text(world), button');
      expect(elements, hasLength(1));
    });

    test('should handle escapes', () async {
      await page.setContent(_pSelectorsFixture);
      expect(
        await page.$OrNull(
          r':scope >>> ::-p-text(My name is Jun \(pronounced like "June"\))',
        ),
        isNotNull,
      );
      expect(
        await page.$OrNull(
          r':scope >>> ::-p-text("My name is Jun (pronounced like \"June\")")',
        ),
        isNotNull,
      );
      expect(
        await page.$OrNull(
          r':scope >>> ::-p-text(My name is Jun \(pronounced like "June"\)")',
        ),
        isNull,
      );
    });

    test('::-p-aria throws a clear error (not yet supported)', () async {
      await page.setContent(_pSelectorsFixture);
      expect(
        () => page.$OrNull('::-p-aria(world)'),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('Locator integration', () {
    test('clicks an element matched by a P-selector', () async {
      await page.setViewport(DeviceViewport(width: 500, height: 500));
      await page.setContent(
        "<button onclick=\"this.innerText = 'clicked';\">test</button>",
      );
      await page.locator('::-p-text(test), ::-p-xpath(/button)').click();
      var button = await page.$('button');
      expect(await button.evaluate('e => e.innerText'), 'clicked');
    });
  });
}

List<List<T>> _permute<T>(List<T> inputs) {
  var results = <List<T>>[];
  for (var i = 0; i < inputs.length; i++) {
    var rest = [...inputs.sublist(0, i), ...inputs.sublist(i + 1)];
    var permutations = _permute(rest);
    if (permutations.isEmpty) {
      results.add([inputs[i]]);
    } else {
      for (var part in permutations) {
        results.add([inputs[i], ...part]);
      }
    }
  }
  return results;
}
