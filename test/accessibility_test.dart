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

  group('Accessibility', () {
    test('should work', () async {
      await page.setContent('''
      <head>
      <title>Accessibility Test</title>
      </head>
      <body>
      <div>Hello World</div>
      <h1>Inputs</h1>
      <input placeholder="Empty input" autofocus />
      <input placeholder="readonly input" readonly />
      <input placeholder="disabled input" disabled />
      <input aria-label="Input with whitespace" value="  " />
      <input value="value only" />
      <input aria-placeholder="placeholder" value="and a value" />
      <div aria-hidden="true" id="desc">This is a description!</div>
      <input aria-placeholder="placeholder" value="and a value" aria-describedby="desc" />
      <select>
      <option>First Option</option>
      <option>Second Option</option>
      </select>
      </body>''');

      await page.focus('[placeholder="Empty input"]');
      var golden =
          AXNode(role: 'RootWebArea', name: 'Accessibility Test', children: [
        AXNode(role: 'StaticText', name: 'Hello World'),
        AXNode(role: 'heading', name: 'Inputs', level: 1),
        AXNode(role: 'textbox', name: 'Empty input', focused: true),
        AXNode(role: 'textbox', name: 'readonly input', readonly: true),
        AXNode(role: 'textbox', name: 'disabled input', disabled: true),
        AXNode(role: 'textbox', name: 'Input with whitespace', value: '  '),
        AXNode(role: 'textbox', name: '', value: 'value only'),
        AXNode(role: 'textbox', name: 'placeholder', value: 'and a value'),
        AXNode(
            role: 'textbox',
            name: 'placeholder',
            value: 'and a value',
            description: 'This is a description!'),
        AXNode(
            role: 'combobox',
            name: '',
            value: 'First Option',
            hasPopup: 'menu',
            children: [
              AXNode(role: 'menuitem', name: 'First Option', selected: true),
              AXNode(role: 'menuitem', name: 'Second Option')
            ])
      ]);
      expect(await page.accessibility.snapshot(), equals(golden));
    });
    test('should report uninteresting nodes', () async {
      await page.setContent('<textarea>hi</textarea>');
      await page.focus('textarea');
      var golden = AXNode(
          role: 'textbox',
          name: '',
          value: 'hi',
          focused: true,
          multiLine: true,
          children: [
            AXNode(
                role: 'generic',
                name: '',
                children: [AXNode(role: 'StaticText', name: 'hi')])
          ]);
      expect(
          findFocusedNode(
              await page.accessibility.snapshot(interestingOnly: false)),
          equals(golden));
    });
    test('roledescription', () async {
      await page
          .setContent('<div tabIndex=-1 aria-roledescription="foo">Hi</div>');
      var snapshot = await page.accessibility.snapshot();
      //// See https://chromium-review.googlesource.com/c/chromium/src/+/3088862
      expect(snapshot.children[0].roleDescription, isNull);
    });
    test('orientation', () async {
      await page.setContent(
          '<a href="" role="slider" aria-orientation="vertical">11</a>');
      var snapshot = await page.accessibility.snapshot();
      expect(snapshot.children[0].orientation, equals('vertical'));
    });
    test('autocomplete', () async {
      await page.setContent('<input type="number" aria-autocomplete="list" />');
      var snapshot = await page.accessibility.snapshot();
      expect(snapshot.children[0].autocomplete, equals('list'));
    });
    test('multiselectable', () async {
      await page.setContent(
          '<div role="grid" tabIndex=-1 aria-multiselectable=true>hey</div>');
      var snapshot = await page.accessibility.snapshot();
      expect(snapshot.children[0].multiSelectable, equals(true));
    });
    test('keyshortcuts', () async {
      await page.setContent(
          '<div role="grid" tabIndex=-1 aria-keyshortcuts="foo">hey</div>');
      var snapshot = await page.accessibility.snapshot();
      expect(snapshot.children[0].keyShortcuts, equals('foo'));
    });
    group('filtering children of leaf nodes', () {
      test('should not report text nodes inside controls', () async {
        await page.setContent('''
    <div role="tablist">
    <div role="tab" aria-selected="true"><b>Tab1</b></div>
    <div role="tab">Tab2</div>
    </div>''');
        var golden = AXNode(role: 'RootWebArea', name: '', children: [
          AXNode(role: 'tab', name: 'Tab1', selected: true),
          AXNode(role: 'tab', name: 'Tab2')
        ]);
        expect(await page.accessibility.snapshot(), equals(golden));
      });
      test('rich text editable fields should have children', () async {
        await page.setContent('''
    <div contenteditable="true">
    Edit this image: <img src="fakeimage.png" alt="my fake image">
    </div>''');
        var golden = AXNode(
            role: 'generic',
            name: '',
            value: 'Edit this image: ',
            children: [
              AXNode(role: 'StaticText', name: 'Edit this image:'),
              AXNode(role: 'img', name: 'my fake image')
            ]);
        var snapshot = await page.accessibility.snapshot();
        expect(snapshot.children[0], equals(golden));
      });
      test('rich text editable fields with role should have children',
          () async {
        await page.setContent('''
    <div contenteditable="true" role='textbox'>
    Edit this image: <img src="fakeimage.png" alt="my fake image">
    </div>''');
        var golden = AXNode(
            role: 'textbox',
            name: '',
            value: 'Edit this image: ',
            children: [
              AXNode(role: 'StaticText', name: 'Edit this image:'),
              AXNode(role: 'img', name: 'my fake image')
            ],
            multiLine: true);
        var snapshot = await page.accessibility.snapshot();
        expect(snapshot.children[0], equals(golden));
      });
      group('plaintext contenteditable', () {
        test(
            'plain text field with tabindex and without role should not have content',
            () async {
          await page.setContent('''
    <div contenteditable="plaintext-only" tabIndex=0>Edit this image:<img src="fakeimage.png" alt="my fake image"></div>''');
          var snapshot = await page.accessibility.snapshot();
          expect(
              snapshot.children[0],
              equals(AXNode(
                  role: 'generic', name: '', value: 'Edit this image:')));
        });
      });
      test(
          'non editable textbox with role and tabIndex and label should not have children',
          () async {
        await page.setContent('''
    <div role="textbox" tabIndex=0 aria-checked="true" aria-label="my favorite textbox">
    this is the inner content
    <img alt="yo" src="fakeimg.png">
    </div>''');
        var golden = AXNode(
            role: 'textbox',
            name: 'my favorite textbox',
            value: 'this is the inner content ');
        var snapshot = await page.accessibility.snapshot();
        expect(snapshot.children[0], equals(golden));
      });
      test('checkbox with and tabIndex and label should not have children',
          () async {
        await page.setContent('''
    <div role="checkbox" tabIndex=0 aria-checked="true" aria-label="my favorite checkbox">
    this is the inner content
    <img alt="yo" src="fakeimg.png">
    </div>''');
        var golden = AXNode(
            role: 'checkbox',
            name: 'my favorite checkbox',
            checked: AXNode.stateTrue);
        var snapshot = await page.accessibility.snapshot();
        expect(snapshot.children[0], equals(golden));
      });
      test('checkbox without label should not have children', () async {
        await page.setContent('''
    <div role="checkbox" aria-checked="true">
    this is the inner content
    <img alt="yo" src="fakeimg.png">
    </div>''');
        var golden = AXNode(
            role: 'checkbox',
            name: 'this is the inner content yo',
            checked: AXNode.stateTrue);
        var snapshot = await page.accessibility.snapshot();
        expect(snapshot.children[0], equals(golden));
      });

      group('root option', () {
        test('should work a button', () async {
          await page.setContent('<button>My Button</button>');

          var button = await page.$('button');
          expect(await page.accessibility.snapshot(root: button),
              equals(AXNode(role: 'button', name: 'My Button')));
        });
        test('should work an input', () async {
          await page.setContent('<input title="My Input" value="My Value">');

          var input = await page.$('input');
          expect(await page.accessibility.snapshot(root: input),
              AXNode(role: 'textbox', name: 'My Input', value: 'My Value'));
        });
        test('should work a menu', () async {
          await page.setContent('''
    <div role="menu" title="My Menu">
    <div role="menuitem">First Item</div>
    <div role="menuitem">Second Item</div>
    <div role="menuitem">Third Item</div>
    </div>
    ''');

          var menu = await page.$('div[role="menu"]');
          expect(
              await page.accessibility.snapshot(root: menu),
              equals(AXNode(
                  role: 'menu',
                  name: 'My Menu',
                  orientation: 'vertical',
                  children: [
                    AXNode(role: 'menuitem', name: 'First Item'),
                    AXNode(role: 'menuitem', name: 'Second Item'),
                    AXNode(role: 'menuitem', name: 'Third Item')
                  ])));
        });
        test('should return null when the element is no longer in DOM',
            () async {
          await page.setContent('<button>My Button</button>');
          var button = await page.$('button');
          await page.$eval('button', 'button => button.remove()');
          expect(await page.accessibility.snapshot(root: button), AXNode.empty);
        });
        test('should support the interestingOnly option', () async {
          await page.setContent('<div><button>My Button</button></div>');
          var div = await page.$('div');
          expect(await page.accessibility.snapshot(root: div), AXNode.empty);
          expect(
            await page.accessibility
                .snapshot(root: div, interestingOnly: false),
            equals(
              AXNode(
                role: 'generic',
                name: '',
                children: [
                  AXNode(
                    role: 'button',
                    name: 'My Button',
                    children: [
                      AXNode(role: 'StaticText', name: 'My Button'),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      });
    });
  });
}

AXNode? findFocusedNode(AXNode node) {
  if (node.focused) return node;
  for (var child in node.children) {
    var focusedChild = findFocusedNode(child);
    if (focusedChild != null) return focusedChild;
  }
  return null;
}
