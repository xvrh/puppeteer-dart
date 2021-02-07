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

  group('Page.click', () {
    test('should click the button', () async {
      await page.goto(server.prefix + '/input/button.html');
      await page.click('button');
      expect(await page.evaluate('() => result'), equals('Clicked'));
    });
    test('should click the button if window.Node is removed', () async {
      await page.goto(server.prefix + '/input/button.html');
      await page.evaluate('() => delete window.Node');
      await page.click('button');
      expect(await page.evaluate('() => result'), equals('Clicked'));
    });
    // @see https://github.com/GoogleChrome/puppeteer/issues/4281
    test('should click on a span with an inline element inside', () async {
      await page.setContent('''
  <style>
  span::before {
  content: 'q';
  }
  </style>
  <span onclick='javascript:window.CLICKED=42'></span>
  ''');
      await page.click('span');
      expect(await page.evaluate('() => window.CLICKED'), equals(42));
    });
    test('should click the button after navigation ', () async {
      await page.goto(server.prefix + '/input/button.html');
      await page.click('button');
      await page.goto(server.prefix + '/input/button.html');
      await page.click('button');
      expect(await page.evaluate('() => result'), equals('Clicked'));
    });
    test('should click with disabled javascript', () async {
      await page.setJavaScriptEnabled(false);
      await page.goto(server.prefix + '/wrappedlink.html');
      await Future.wait([page.click('a'), page.waitForNavigation()]);
      expect(page.url, equals(server.prefix + '/wrappedlink.html#clicked'));
    });
    test('should click when one of inline box children is outside of viewport',
        () async {
      await page.setContent('''
  <style>
  i {
  position: absolute;
  top: -1000px;
  }
  </style>
  <span onclick='javascript:window.CLICKED = 42;'><i>woof</i><b>doggo</b></span>
  ''');
      await page.click('span');
      expect(await page.evaluate('() => window.CLICKED'), equals(42));
    });
    test('should select the text by triple clicking', () async {
      await page.goto(server.prefix + '/input/textarea.html');
      await page.focus('textarea');
      var text =
          'This is the text that we are going to try to select. Let\'s see how it goes.';
      await page.keyboard.type(text);
      await page.click('textarea');
      await page.click('textarea', clickCount: 2);
      await page.click('textarea', clickCount: 3);
      expect(await page.evaluate('''() => {
  var textarea = document.querySelector('textarea');
  return textarea.value.substring(textarea.selectionStart, textarea.selectionEnd);
  }'''), equals(text));
    });
    test('should click offscreen buttons', () async {
      await page.goto(server.prefix + '/offscreenbuttons.html');
      var messages = [];
      page.onConsole.listen((message) {
        messages.add(message.text);
      });
      for (var i = 0; i < 11; ++i) {
        // We might've scrolled to click a button - reset to (0, 0).
        await page.evaluate('() => window.scrollTo(0, 0)');
        await page.click('#btn$i');
      }
      expect(
          messages,
          equals([
            'button #0 clicked',
            'button #1 clicked',
            'button #2 clicked',
            'button #3 clicked',
            'button #4 clicked',
            'button #5 clicked',
            'button #6 clicked',
            'button #7 clicked',
            'button #8 clicked',
            'button #9 clicked',
            'button #10 clicked'
          ]));
    });

    test('should click wrapped links', () async {
      await page.goto(server.prefix + '/wrappedlink.html');
      await page.click('a');
      expect(await page.evaluate('() => window.__clicked'), isTrue);
    });

    test('should click on checkbox input and toggle', () async {
      await page.goto(server.prefix + '/input/checkbox.html');
      expect(await page.evaluate('() => result.check'), isNull);
      await page.click('input#agree');
      expect(await page.evaluate('() => result.check'), isTrue);
      expect(
          await page.evaluate('() => result.events'),
          equals([
            'mouseover',
            'mouseenter',
            'mousemove',
            'mousedown',
            'mouseup',
            'click',
            'input',
            'change',
          ]));
      await page.click('input#agree');
      expect(await page.evaluate('() => result.check'), isFalse);
    });

    test('should click on checkbox label and toggle', () async {
      await page.goto(server.prefix + '/input/checkbox.html');
      expect(await page.evaluate('() => result.check'), isNull);
      await page.click('label[for="agree"]');
      expect(await page.evaluate('() => result.check'), isTrue);
      expect(
          await page.evaluate('() => result.events'),
          equals([
            'click',
            'input',
            'change',
          ]));
      await page.click('label[for="agree"]');
      expect(await page.evaluate('() => result.check'), isFalse);
    });

    test('should fail to click a missing button', () async {
      await page.goto(server.prefix + '/input/button.html');
      expect(
          () => page.click('button.does-not-exist'),
          throwsA(predicate((e) => '$e'
              .contains('No node found for selector: button.does-not-exist'))));
    });
    // @see https://github.com/GoogleChrome/puppeteer/issues/161
    test('should not hang with touch-enabled viewports', () async {
      await page.setViewport(puppeteer.devices.iPhone6.viewport);
      await page.mouse.down();
      await page.mouse.move(Point(100, 10));
      await page.mouse.up();
    });
    test('should scroll and click the button', () async {
      await page.goto(server.prefix + '/input/scrollable.html');
      await page.click('#button-5');
      expect(
          await page.evaluate(
              "() => document.querySelector('#button-5').textContent"),
          equals('clicked'));
      await page.click('#button-80');
      expect(
          await page.evaluate(
              "() => document.querySelector('#button-80').textContent"),
          equals('clicked'));
    });
    test('should double click the button', () async {
      await page.goto(server.prefix + '/input/button.html');
      await page.evaluate('''() => {
  window.double = false;
  var button = document.querySelector('button');
  button.addEventListener('dblclick', event => {
    window.double = true;
  });
}''');
      var button = await page.$('button');
      await button.click(clickCount: 2);
      expect(await page.evaluate('double'), isTrue);
      expect(await page.evaluate('result'), equals('Clicked'));
    });
    test('should click a partially obscured button', () async {
      await page.goto(server.prefix + '/input/button.html');
      await page.evaluate('''() => {
  var button = document.querySelector('button');
  button.textContent = 'Some really long text that will go offscreen';
  button.style.position = 'absolute';
  button.style.left = '368px';
  }''');
      await page.click('button');
      expect(await page.evaluate('() => window.result'), equals('Clicked'));
    });
    test('should click a rotated button', () async {
      await page.goto(server.prefix + '/input/rotatedButton.html');
      await page.click('button');
      expect(await page.evaluate('() => result'), equals('Clicked'));
    });
    test('should fire contextmenu event on right click', () async {
      await page.goto(server.prefix + '/input/scrollable.html');
      await page.click('#button-8', button: MouseButton.right);
      expect(
          await page.evaluate(
              "() => document.querySelector('#button-8').textContent"),
          equals('context menu'));
    });
    // @see https://github.com/GoogleChrome/puppeteer/issues/206
    test('should click links which cause navigation', () async {
      await page.setContent('<a href="${server.emptyPage}">empty.html</a>');
      // This await should not hang.
      await page.click('a');
    });
    test('should click the button inside an iframe', () async {
      await page.goto(server.emptyPage);
      await page
          .setContent('<div style="width:100px;height:100px">spacer</div>');
      await attachFrame(
          page, 'button-test', server.prefix + '/input/button.html');
      var frame = page.frames[1];
      var button = await frame.$('button');
      await button.click();
      expect(await frame.evaluate('() => window.result'), equals('Clicked'));
    });
    // @see https://github.com/GoogleChrome/puppeteer/issues/4110
    test('should click the button with fixed position inside an iframe',
        () async {
      await page.goto(server.emptyPage);
      await page.setViewport(DeviceViewport(width: 500, height: 500));
      await page
          .setContent('<div style="width:100px;height:2000px">spacer</div>');
      await attachFrame(page, 'button-test',
          server.crossProcessPrefix + '/input/button.html');
      var frame = page.frames[1];
      await frame.$eval(
          'button', "button => button.style.setProperty('position', 'fixed')");
      await frame.click('button');
      expect(await frame.evaluate('() => window.result'), equals('Clicked'));
    }, skip: true);
    test('should click the button with deviceScaleFactor set', () async {
      await page.goto(server.emptyPage);
      await page.setViewport(
          DeviceViewport(width: 400, height: 400, deviceScaleFactor: 5));
      expect(await page.evaluate('() => window.devicePixelRatio'), equals(5));
      await page
          .setContent('<div style="width:100px;height:100px">spacer</div>');
      await attachFrame(
          page, 'button-test', server.prefix + '/input/button.html');
      var frame = page.frames[1];
      var button = await frame.$('button');
      await button.click();
      expect(await frame.evaluate('() => window.result'), equals('Clicked'));
    });
  });
}
