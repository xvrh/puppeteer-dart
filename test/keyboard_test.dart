import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils/utils.dart';

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
  test('Can find key', () {
    expect(Key.allKeys['Meta'], equals(Key.meta));
    expect(Key.allKeys['meta'], equals(Key.meta));
    expect(Key.allKeys[' meta '], equals(Key.meta));
    expect(Key.allKeys['Control'], equals(Key.control));
    expect(Key.allKeys['notexist'], isNull);
    expect(Key.allKeys[''], isNull);
    expect(Key.allKeys[null], isNull);

    for (var key in Key.allKeys.values) {
      expect(key.toString(), isNotNull);
    }
  });

  test('Can type into a textarea', () async {
    await page.goto(server.emptyPage);
    await page.evaluate(
        //language=js
        '''
function _() {
  var textarea = document.createElement('textarea');
  document.body.appendChild(textarea);
  textarea.focus();
}
''');
    var text = 'Hello world. éàê^';
    await page.keyboard.type(text);
    expect(await page.evaluate('document.querySelector("textarea").value'),
        equals(text));
  });
  test('Press the metaKey', () async {
    await page.evaluate(
        //language=js
        '''
function _() {
  window.keyPromise = new Promise(resolve => document.addEventListener('keydown', event => resolve(event.key)));
}
''');
    await page.keyboard.press(Key.meta);
    expect(await page.evaluate('keyPromise'), equals('Meta'));
  });
  test('should move with the arrow keys', () async {
    await page.goto(server.assetUrl('input/textarea.html'));
    await page.type('textarea', 'Hello World!');
    expect(
        await page.evaluate("() => document.querySelector('textarea').value"),
        equals('Hello World!'));
    for (var i = 0; i < 'World!'.length; i++) {
      await page.keyboard.press(Key.arrowLeft);
    }
    await page.keyboard.type('inserted ');
    expect(
        await page.evaluate("() => document.querySelector('textarea').value"),
        equals('Hello inserted World!'));
    await page.keyboard.down(Key.shift);
    for (var i = 0; i < 'inserted '.length; i++) {
      await page.keyboard.press(Key.arrowLeft);
    }
    await page.keyboard.up(Key.shift);
    await page.keyboard.press(Key.backspace);
    expect(
        await page.evaluate("() => document.querySelector('textarea').value"),
        equals('Hello World!'));
  });
  test('should send a character with sendCharacter', () async {
    await page.goto(server.assetUrl('input/textarea.html'));
    await page.focus('textarea');
    await page.keyboard.sendCharacter('嗨');
    var textareaValue =
        'function() { return document.querySelector("textarea").value; }';
    expect(await page.evaluate(textareaValue), equals('嗨'));
    await page.evaluate(
        'function() { window.addEventListener("keydown", e => e.preventDefault(), true); }');
    await page.keyboard.sendCharacter('a');
    expect(await page.evaluate(textareaValue), equals('嗨a'));
  });
  test('should report multiple modifiers', () async {
    await page.goto(server.assetUrl('input/keyboard.html'));
    var keyboard = page.keyboard;
    await keyboard.down(Key.control);
    var getResult = '() => getResult()';
    expect(await page.evaluate(getResult),
        equals('Keydown: Control ControlLeft 17 [Control]'));
    await keyboard.down(Key.alt);
    expect(await page.evaluate(getResult),
        equals('Keydown: Alt AltLeft 18 [Alt Control]'));
    await keyboard.down(Key.semicolon);
    expect(await page.evaluate(getResult),
        equals('Keydown: ; Semicolon 186 [Alt Control]'));
    await keyboard.up(Key.semicolon);
    expect(await page.evaluate(getResult),
        equals('Keyup: ; Semicolon 186 [Alt Control]'));
    await keyboard.up(Key.control);
    expect(await page.evaluate(getResult),
        equals('Keyup: Control ControlLeft 17 [Alt]'));
    await keyboard.up(Key.alt);
    expect(await page.evaluate(getResult), equals('Keyup: Alt AltLeft 18 []'));
  });
  test('should send proper codes while typing', () async {
    await page.goto(server.assetUrl('input/keyboard.html'));
    await page.keyboard.type('!');
    expect(
        await page.evaluate('() => getResult()'),
        equals([
          'Keydown: ! Digit1 49 []',
          'Keypress: ! Digit1 33 33 []',
          'Keyup: ! Digit1 49 []'
        ].join('\n')));
    await page.keyboard.type('^');
    expect(
        await page.evaluate('() => getResult()'),
        equals([
          'Keydown: ^ Digit6 54 []',
          'Keypress: ^ Digit6 94 94 []',
          'Keyup: ^ Digit6 54 []'
        ].join('\n')));
  });
  test('should send proper codes while typing with shift', () async {
    await page.goto(server.assetUrl('input/keyboard.html'));
    var keyboard = page.keyboard;
    await keyboard.down(Key.shift);
    await page.keyboard.type('~');
    expect(
        await page.evaluate('() => getResult()'),
        equals([
          'Keydown: Shift ShiftLeft 16 [Shift]',
          'Keydown: ~ Backquote 192 [Shift]', // 192 is ` keyCode
          'Keypress: ~ Backquote 126 126 [Shift]', // 126 is ~ charCode
          'Keyup: ~ Backquote 192 [Shift]'
        ].join('\n')));
    await keyboard.up(Key.shift);
  });
  test('should not type canceled events', () async {
    await page.goto(server.assetUrl('input/textarea.html'));

    await page.focus('textarea');
    await page.evaluate('''() => {
        window.addEventListener('keydown', event => {
          event.stopPropagation();
          event.stopImmediatePropagation();
          if (event.key === 'l')
            event.preventDefault();
          if (event.key === 'o')
            event.preventDefault();
        }, false);
      }
 ''');
    await page.keyboard.type('Hello World!');
    expect(await page.evaluate('() => textarea.value'), equals('He Wrd!'));
  });
  test('should specify repeat property', () async {
    await page.goto(server.assetUrl('input/textarea.html'));
    await page.focus('textarea');
    await page.evaluate(
        "() => document.querySelector('textarea').addEventListener('keydown', e => window.lastEvent = e, true)");
    await page.keyboard.down(Key.keyA);
    expect(await page.evaluate('() => window.lastEvent.repeat'), isFalse);
    await page.keyboard.press(Key.keyA);
    expect(await page.evaluate('() => window.lastEvent.repeat'), isTrue);

    await page.keyboard.down(Key.keyB);
    expect(await page.evaluate('() => window.lastEvent.repeat'), isFalse);
    await page.keyboard.down(Key.keyB);
    expect(await page.evaluate('() => window.lastEvent.repeat'), isTrue);

    await page.keyboard.up(Key.keyA);
    await page.keyboard.down(Key.keyA);
    expect(await page.evaluate('() => window.lastEvent.repeat'), isFalse);
  });
  test('should type all kinds of characters', () async {
    await page.goto(server.assetUrl('input/textarea.html'));
    await page.focus('textarea');
    var text = 'This text goes onto two lines.\nThis character is 嗨.';
    await page.keyboard.type(text);
    expect(await page.evaluate('result'), equals(text));
  });
  test('should specify location', () async {
    await page.goto(server.assetUrl('input/textarea.html'));
    await page.evaluate('''() => {
  window.addEventListener('keydown', event => window.keyLocation = event.location, true);
  }''');
    var textarea = await page.$('textarea');

    await textarea.press(Key.digit5);
    expect(await page.evaluate('keyLocation'), equals(0));

    await textarea.press(Key.controlLeft);
    expect(await page.evaluate('keyLocation'), equals(1));

    await textarea.press(Key.controlRight);
    expect(await page.evaluate('keyLocation'), equals(2));

    await textarea.press(Key.numpadSubtract);
    expect(await page.evaluate('keyLocation'), equals(3));
  });
  test('Type emoji', () async {
    await page.goto(server.assetUrl('input/textarea.html'));
    await page.type('textarea', '👹 Tokyo street Japan 🇯🇵');
    expect(await page.$eval('textarea', '(textarea) => textarea.value'),
        equals('👹 Tokyo street Japan 🇯🇵'));
  });
  test('should type emoji into an iframe', () async {
    await page.goto(server.emptyPage);
    await attachFrame(
        page, 'emoji-test', server.assetUrl('input/textarea.html'));
    var frame = page.frames[1];
    var textarea = await frame.$('textarea');
    await textarea.type('👹 Tokyo street Japan 🇯🇵');
    expect(await frame.$eval('textarea', '(textarea)=>textarea.value'),
        equals('👹 Tokyo street Japan 🇯🇵'));
  });
}
