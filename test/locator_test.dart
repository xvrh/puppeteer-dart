import 'dart:async';
import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils/utils.dart';

// Ported from upstream Puppeteer test/src/locator.test.ts.
//
// Adaptations to this repo:
// - `locator.on(LocatorEvent.Action, cb)` becomes `locator.onAction(cb)`.
// - Puppeteer-specific selectors (`::-p-text`, `::-p-xpath`) are not yet
//   implemented (they are a separate, later batch), so tests use the
//   equivalent CSS selectors.
// - `AbortController`/`AbortSignal` becomes an optional `Future<void> signal`
//   that aborts the action when it completes.
// - The upstream fake-timer timeout tests use small real timeouts here.
// - `FunctionLocator` (`page.locator(func)`) is intentionally out of scope for
//   this batch.

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

  group('Locator', () {
    test('should work with a frame', () async {
      await page.setViewport(DeviceViewport(width: 500, height: 500));
      await page.setContent(
        "<button onclick=\"this.innerText = 'clicked';\">test</button>",
      );
      var willClick = false;
      await page.mainFrame
          .locator('button')
          .onAction(() => willClick = true)
          .click();
      var button = await page.$('button');
      var text = await button.evaluate('el => el.innerText');
      expect(text, 'clicked');
      expect(willClick, isTrue);
    });

    test('should work without preconditions', () async {
      await page.setViewport(DeviceViewport(width: 500, height: 500));
      await page.setContent(
        "<button onclick=\"this.innerText = 'clicked';\">test</button>",
      );
      var willClick = false;
      await page
          .locator('button')
          .setEnsureElementIsInTheViewport(false)
          .setTimeout(Duration.zero)
          .setVisibility(null)
          .setWaitForEnabled(false)
          .setWaitForStableBoundingBox(false)
          .onAction(() => willClick = true)
          .click();
      var button = await page.$('button');
      var text = await button.evaluate('el => el.innerText');
      expect(text, 'clicked');
      expect(willClick, isTrue);
    });

    group('Locator.click', () {
      test('should work', () async {
        await page.setViewport(DeviceViewport(width: 500, height: 500));
        await page.setContent(
          "<button onclick=\"this.innerText = 'clicked';\">test</button>",
        );
        var willClick = false;
        await page.locator('button').onAction(() => willClick = true).click();
        var button = await page.$('button');
        var text = await button.evaluate('el => el.innerText');
        expect(text, 'clicked');
        expect(willClick, isTrue);
      });

      test('should work for multiple selectors', () async {
        await page.setViewport(DeviceViewport(width: 500, height: 500));
        await page.setContent(
          "<button onclick=\"this.innerText = 'clicked';\">test</button>",
        );
        var clicked = false;
        // Upstream uses `::-p-text(test), ::-p-xpath(/button)`; the equivalent
        // CSS union selector is used here.
        await page
            .locator('#nope, button')
            .onAction(() => clicked = true)
            .click();
        var button = await page.$('button');
        var text = await button.evaluate('el => el.innerText');
        expect(text, 'clicked');
        expect(clicked, isTrue);
      });

      test('should work if the element is out of viewport', () async {
        await page.setViewport(DeviceViewport(width: 500, height: 500));
        await page.setContent(
          '<button style="margin-top: 600px;" '
          "onclick=\"this.innerText = 'clicked';\">test</button>",
        );
        await page.locator('button').click();
        var button = await page.$('button');
        var text = await button.evaluate('el => el.innerText');
        expect(text, 'clicked');
      });

      test('should work with element handles', () async {
        await page.setViewport(DeviceViewport(width: 500, height: 500));
        await page.setContent(
          '<button style="margin-top: 600px;" '
          "onclick=\"this.innerText = 'clicked';\">test</button>",
        );
        var button = await page.$('button');
        await button.asLocator().click();
        var text = await button.evaluate('el => el.innerText');
        expect(text, 'clicked');
      });

      test('should work if the element becomes visible later', () async {
        await page.setViewport(DeviceViewport(width: 500, height: 500));
        await page.setContent(
          '<button style="display: none;" '
          "onclick=\"this.innerText = 'clicked';\">test</button>",
        );
        var button = await page.$('button');
        var result = page.locator('button').click();
        expect(await button.evaluate('el => el.innerText'), 'test');
        await button.evaluate("el => el.style.display = 'block'");
        await result;
        expect(await button.evaluate('el => el.innerText'), 'clicked');
      });

      test('should work if the element becomes enabled later', () async {
        await page.setViewport(DeviceViewport(width: 500, height: 500));
        await page.setContent(
          "<button disabled onclick=\"this.innerText = 'clicked';\">test</button>",
        );
        var button = await page.$('button');
        var result = page.locator('button').click();
        expect(await button.evaluate('el => el.innerText'), 'test');
        await button.evaluate('el => el.disabled = false');
        await result;
        expect(await button.evaluate('el => el.innerText'), 'clicked');
      });

      test('should work if multiple conditions are satisfied later', () async {
        await page.setViewport(DeviceViewport(width: 500, height: 500));
        await page.setContent(
          '<button style="margin-top: 600px;" style="display: none;" disabled '
          "onclick=\"this.innerText = 'clicked';\">test</button>",
        );
        var button = await page.$('button');
        var result = page.locator('button').click();
        expect(await button.evaluate('el => el.innerText'), 'test');
        await button.evaluate(
          "el => { el.disabled = false; el.style.display = 'block'; }",
        );
        await result;
        expect(await button.evaluate('el => el.innerText'), 'clicked');
      });

      test('should time out', () async {
        page.defaultTimeout = Duration(milliseconds: 500);
        await page.setViewport(DeviceViewport(width: 500, height: 500));
        await page.setContent(
          '<button style="display: none;" '
          "onclick=\"this.innerText = 'clicked';\">test</button>",
        );
        await expectLater(
          page.locator('button').click(),
          throwsA(isA<TimeoutException>()),
        );
      });

      test('can be aborted', () async {
        page.defaultTimeout = Duration(seconds: 5);
        await page.setViewport(DeviceViewport(width: 500, height: 500));
        await page.setContent(
          '<button style="display: none;" '
          "onclick=\"this.innerText = 'clicked';\">test</button>",
        );
        var abort = Completer<void>();
        var result = page.locator('button').click(signal: abort.future);
        Timer(Duration(milliseconds: 200), abort.complete);
        await expectLater(result, throwsA(isA<LocatorAbortedException>()));
      });

      test('should work with a frame', () async {
        await page.setViewport(DeviceViewport(width: 500, height: 500));
        await page.setContent(
          '<iframe src="data:text/html,'
          "<button onclick=&quot;this.innerText = 'clicked';&quot;>test</button>"
          '"></iframe>',
        );
        var frame = await page.waitForFrame(
          (frame) => frame.url.startsWith('data'),
        );
        var willClick = false;
        await frame.locator('button').onAction(() => willClick = true).click();
        var button = await frame.$('button');
        var text = await button.evaluate('el => el.innerText');
        expect(text, 'clicked');
        expect(willClick, isTrue);
      });
    });

    group('Locator.hover', () {
      test('should work', () async {
        await page.setViewport(DeviceViewport(width: 500, height: 500));
        await page.setContent(
          "<button onmouseenter=\"this.innerText = 'hovered';\">test</button>",
        );
        var hovered = false;
        await page.locator('button').onAction(() => hovered = true).hover();
        var button = await page.$('button');
        var text = await button.evaluate('el => el.innerText');
        expect(text, 'hovered');
        expect(hovered, isTrue);
      });
    });

    group('Locator.scroll', () {
      test('should work', () async {
        await page.setViewport(DeviceViewport(width: 500, height: 500));
        await page.setContent(
          '<div style="height: 500px; width: 500px; overflow: scroll;">'
          '<div style="height: 1000px; width: 1000px;">test</div></div>',
        );
        var scrolled = false;
        await page
            .locator('div')
            .onAction(() => scrolled = true)
            .scroll(scrollTop: 500, scrollLeft: 500);
        var scrollable = await page.$('div');
        var scroll = await scrollable.evaluate(
          "el => el.scrollTop + ' ' + el.scrollLeft",
        );
        expect(scroll, '500 500');
        expect(scrolled, isTrue);
      });
    });

    group('Locator.fill', () {
      test('should work for textarea', () async {
        await page.setContent('<textarea></textarea>');
        var filled = false;
        await page
            .locator('textarea')
            .onAction(() => filled = true)
            .fill('test');
        expect(
          await page.evaluate(
            "() => document.querySelector('textarea').value === 'test'",
          ),
          isTrue,
        );
        expect(filled, isTrue);
      });

      test('should work for selects', () async {
        await page.setContent(
          '<select>'
          '<option value="value1">Option 1</option>'
          '<option value="value2">Option 2</option>'
          '</select>',
        );
        var filled = false;
        await page
            .locator('select')
            .onAction(() => filled = true)
            .fill('value2');
        expect(
          await page.evaluate(
            "() => document.querySelector('select').value === 'value2'",
          ),
          isTrue,
        );
        expect(filled, isTrue);
      });

      test('should work for inputs', () async {
        await page.setContent('<input />');
        await page.locator('input').fill('test');
        expect(
          await page.evaluate(
            "() => document.querySelector('input').value === 'test'",
          ),
          isTrue,
        );
      });

      test('should work if the input becomes enabled later', () async {
        await page.setContent('<input disabled />');
        var input = await page.$('input');
        var result = page.locator('input').fill('test');
        expect(await input.evaluate('el => el.value'), '');
        await input.evaluate('el => el.disabled = false');
        await result;
        expect(await input.evaluate('el => el.value'), 'test');
      });

      test('should work for contenteditable', () async {
        await page.setContent('<div contenteditable="true"></div>');
        await page.locator('div').fill('test');
        expect(
          await page.evaluate(
            "() => document.querySelector('div').innerText === 'test'",
          ),
          isTrue,
        );
      });

      test('should work for pre-filled inputs', () async {
        await page.setContent('<input value="te" />');
        await page.locator('input').fill('test');
        expect(
          await page.evaluate(
            "() => document.querySelector('input').value === 'test'",
          ),
          isTrue,
        );
      });

      test('should override pre-filled inputs', () async {
        await page.setContent('<input value="wrong prefix" />');
        await page.locator('input').fill('test');
        expect(
          await page.evaluate(
            "() => document.querySelector('input').value === 'test'",
          ),
          isTrue,
        );
      });

      test('should work for non-text inputs', () async {
        await page.setContent('<input type="color" />');
        await page.locator('input').fill('#333333');
        expect(
          await page.evaluate(
            "() => document.querySelector('input').value === '#333333'",
          ),
          isTrue,
        );
      });

      test('should work for large text', () async {
        await page.setContent('<textarea></textarea>');
        var largeText = 'a' * 1000;
        await page.locator('textarea').fill(largeText);
        expect(
          await page.evaluate(
            '() => document.querySelector("textarea").value.length === 1000',
          ),
          isTrue,
        );
      });

      test('should work with a custom typing threshold', () async {
        await page.setContent('<input />');
        var text = 'abc';
        // threshold is 10, so it should type it.
        await page.locator('input').fill(text, typingThreshold: 10);
        expect(
          await page.evaluate('() => document.querySelector("input").value'),
          text,
        );

        await page.setContent('<input />');
        // threshold is 2, so it should fill it directly.
        await page.locator('input').fill(text, typingThreshold: 2);
        expect(
          await page.evaluate('() => document.querySelector("input").value'),
          text,
        );
      });

      test('should work for checkboxes', () async {
        await page.setContent('<input type="checkbox" />');

        await page.locator('input').fill(true);
        expect(
          await page.evaluate(
            "() => document.querySelector('input').checked === true",
          ),
          isTrue,
        );

        await page.locator('input').fill(false);
        expect(
          await page.evaluate(
            "() => document.querySelector('input').checked === true",
          ),
          isFalse,
        );
      });

      test('should work for radio buttons', () async {
        await page.setContent('<input type="radio" />');
        await page.locator('input').fill(true);
        expect(
          await page.evaluate(
            "() => document.querySelector('input').checked === true",
          ),
          isTrue,
        );
      });

      test('should work for custom ARIA checkboxes', () async {
        await page.setContent(
          '<div role="checkbox" style="width: 100px; height: 100px;" '
          'onclick="this.setAttribute(\'aria-checked\', '
          "this.getAttribute('aria-checked') !== 'true')\" "
          'aria-checked="false"></div>',
        );

        await page.locator('[role="checkbox"]').fill(true);
        expect(
          await page.evaluate(
            "() => document.querySelector('[role=\"checkbox\"]')"
            ".getAttribute('aria-checked') === 'true'",
          ),
          isTrue,
        );

        await page.locator('[role="checkbox"]').fill(false);
        expect(
          await page.evaluate(
            "() => document.querySelector('[role=\"checkbox\"]')"
            ".getAttribute('aria-checked') === 'false'",
          ),
          isTrue,
        );
      });

      test('should work for custom ARIA mixed checkboxes', () async {
        await page.setContent(
          '<div role="checkbox" style="width: 100px; height: 100px;" '
          'onclick="const next = {\'mixed\': \'true\', \'true\': \'false\', '
          "'false': 'true'}; this.setAttribute('aria-checked', "
          "next[this.getAttribute('aria-checked')])\" "
          'aria-checked="mixed"></div>',
        );

        await page.locator('[role="checkbox"]').fill(true);
        expect(
          await page.evaluate(
            "() => document.querySelector('[role=\"checkbox\"]')"
            ".getAttribute('aria-checked') === 'true'",
          ),
          isTrue,
        );

        await page.locator('[role="checkbox"]').fill(false);
        expect(
          await page.evaluate(
            "() => document.querySelector('[role=\"checkbox\"]')"
            ".getAttribute('aria-checked') === 'false'",
          ),
          isTrue,
        );
      });
    });

    group('Locator.race', () {
      test('races multiple locators', () async {
        await page.setViewport(DeviceViewport(width: 500, height: 500));
        await page.setContent(
          '<button onclick="window.count++;">test</button>',
        );
        await page.evaluate('() => { window.count = 0; }');
        await Locator.race([
          page.locator('button'),
          page.locator('button'),
        ]).click();
        var count = await page.evaluate('() => globalThis.count');
        expect(count, 1);
      });

      test('can be aborted', () async {
        await page.setViewport(DeviceViewport(width: 500, height: 500));
        await page.setContent(
          '<button style="display: none;" '
          "onclick=\"this.innerText = 'clicked';\">test</button>",
        );
        var abort = Completer<void>();
        var result = Locator.race([
          page.locator('button'),
          page.locator('button'),
        ]).setTimeout(Duration(seconds: 5)).click(signal: abort.future);
        Timer(Duration(milliseconds: 200), abort.complete);
        await expectLater(result, throwsA(isA<LocatorAbortedException>()));
      });

      test('should time out when all locators do not match', () async {
        await page.setContent('<button>test</button>');
        var result = Locator.race([
          page.locator('not-found'),
          page.locator('not-found'),
        ]).setTimeout(Duration(milliseconds: 500)).click();
        await expectLater(result, throwsA(isA<TimeoutException>()));
      });

      test('should not time out when one of the locators matches', () async {
        await page.setContent('<button>test</button>');
        var result = Locator.race([
          page.locator('not-found'),
          page.locator('button'),
        ]).click();
        await expectLater(result, completes);
      });
    });

    group('Locator.map', () {
      test('should work', () async {
        await page.setContent('<div>test</div>');
        expect(
          await page
              .locator('div')
              .map("element => element.getAttribute('clickable')")
              .wait(),
          isNull,
        );
        await page.evaluate(
          "() => document.querySelector('div').setAttribute('clickable', 'true')",
        );
        expect(
          await page
              .locator('div')
              .map("element => element.getAttribute('clickable')")
              .wait(),
          'true',
        );
      });

      test('should work with throws', () async {
        await page.setContent('<div>test</div>');
        var result = page.locator('div').map('''element => {
  const clickable = element.getAttribute('clickable');
  if (!clickable) {
    throw new Error('Missing `clickable` as an attribute');
  }
  return clickable;
}''').wait();
        await page.evaluate(
          "() => document.querySelector('div').setAttribute('clickable', 'true')",
        );
        expect(await result, 'true');
      });

      test('should work with expect', () async {
        await page.setContent('<div>test</div>');
        var result = page
            .locator('div')
            .filter("element => element.getAttribute('clickable') !== null")
            .map("element => element.getAttribute('clickable')")
            .wait();
        await page.evaluate(
          "() => document.querySelector('div').setAttribute('clickable', 'true')",
        );
        expect(await result, 'true');
      });
    });

    group('Locator.filter', () {
      test('should resolve as soon as the predicate matches', () async {
        page.defaultTimeout = Duration(seconds: 5);
        await page.setContent('<div>test</div>');
        var result = page
            .locator('div')
            .setTimeout(Duration(seconds: 5))
            .filter("element => element.getAttribute('clickable') === 'true'")
            .filter("element => element.getAttribute('clickable') === 'true'")
            .hover();
        Timer(Duration(milliseconds: 200), () async {
          await page.evaluate(
            "() => document.querySelector('div').setAttribute('clickable', 'true')",
          );
        });
        await expectLater(result, completes);
      });
    });

    group('Locator.wait', () {
      test('should work', () async {
        unawaited(
          page.setContent('''
<script>
  setTimeout(() => {
    const element = document.createElement('div');
    element.innerText = 'test2';
    document.body.append(element);
  }, 50);
</script>
'''),
        );
        // This shouldn't throw.
        await page.locator('div').wait();
      });
    });

    group('Locator.waitHandle', () {
      test('should work', () async {
        unawaited(
          page.setContent('''
<script>
  setTimeout(() => {
    const element = document.createElement('div');
    element.innerText = 'test2';
    document.body.append(element);
  }, 50);
</script>
'''),
        );
        expect(await page.locator('div').waitHandle(), isNotNull);
      });
    });

    group('Locator.clone', () {
      test('should work', () async {
        var locator = page.locator('div');
        var clone = locator.clone();
        expect(locator, isNot(same(clone)));
      });

      test('should work internally with delegated locators', () async {
        var locator = page.locator('div');
        var delegatedLocators = [
          locator.map('div => div.textContent'),
          locator.filter('div => div.textContent.length === 0'),
        ];
        for (var delegatedLocator in delegatedLocators) {
          delegatedLocator = delegatedLocator.setTimeout(
            Duration(milliseconds: 500),
          );
          expect(delegatedLocator.timeout, isNot(locator.timeout));
        }
      });
    });
  });
}
