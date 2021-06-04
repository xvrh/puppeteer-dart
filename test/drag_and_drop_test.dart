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
    browser = await puppeteer.launch(defaultViewport: DeviceViewport());
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

  test('should throw an exception if not enabled before usage', () async {
    await page.goto('${server.prefix}/input/drag-and-drop.html');
    var draggable = await page.$('#drag');

    try {
      await draggable.drag(Point(1, 1));
    } catch (error) {
      expect('$error', contains('Drag Interception is not enabled!'));
    }
  });
  test('should emit a dragIntercepted event when dragged', () async {
    await page.goto('${server.prefix}/input/drag-and-drop.html');
    await page.setDragInterception(true);
    var draggable = await page.$('#drag');
    var data = await draggable.drag(Point(1, 1));

    expect(data.items.length, equals(1));
    expect(await page.evaluate('() => globalThis.didDragStart'), isTrue);
  });
  test('should emit a dragEnter', () async {
    await page.goto('${server.prefix}/input/drag-and-drop.html');
    await page.setDragInterception(true);
    var draggable = await page.$('#drag');
    var data = await draggable.drag(Point(1, 1));
    var dropzone = await page.$('#drop');
    await dropzone.dragEnter(data);

    expect(await page.evaluate('() => globalThis.didDragStart'), isTrue);
    expect(await page.evaluate('() => globalThis.didDragEnter'), isTrue);
  });
  test('should emit a dragOver event', () async {
    await page.goto('${server.prefix}/input/drag-and-drop.html');
    await page.setDragInterception(true);
    var draggable = await page.$('#drag');
    var data = await draggable.drag(Point(1, 1));
    var dropzone = await page.$('#drop');
    await dropzone.dragEnter(data);
    await dropzone.dragOver(data);

    expect(await page.evaluate('() => globalThis.didDragStart'), isTrue);
    expect(await page.evaluate('() => globalThis.didDragEnter'), isTrue);
    expect(await page.evaluate('() => globalThis.didDragOver'), isTrue);
  });
  test('can be dropped', () async {
    await page.goto('${server.prefix}/input/drag-and-drop.html');
    await page.setDragInterception(true);
    var draggable = await page.$('#drag');
    var dropzone = await page.$('#drop');
    var data = await draggable.drag(Point(1, 1));
    await dropzone.dragEnter(data);
    await dropzone.dragOver(data);
    await dropzone.drop(data);

    expect(await page.evaluate('() => globalThis.didDragStart'), isTrue);
    expect(await page.evaluate('() => globalThis.didDragEnter'), isTrue);
    expect(await page.evaluate('() => globalThis.didDragOver'), isTrue);
    expect(await page.evaluate('() => globalThis.didDrop'), isTrue);
  });
  test('can be dragged and dropped with a single function', () async {
    await page.goto('${server.prefix}/input/drag-and-drop.html');
    await page.setDragInterception(true);
    var draggable = await page.$('#drag');
    var dropzone = await page.$('#drop');
    await draggable.dragAndDrop(dropzone);

    expect(await page.evaluate('() => globalThis.didDragStart'), isTrue);
    expect(await page.evaluate('() => globalThis.didDragEnter'), isTrue);
    expect(await page.evaluate('() => globalThis.didDragOver'), isTrue);
    expect(await page.evaluate('() => globalThis.didDrop'), isTrue);
  });
  test('can be disabled', () async {
    await page.goto('${server.prefix}/input/drag-and-drop.html');
    await page.setDragInterception(true);
    var draggable = await page.$('#drag');
    await draggable.drag(Point(1, 1));
    await page.setDragInterception(false);

    try {
      await draggable.drag(Point(1, 1));
    } catch (error) {
      expect('$error', contains('Drag Interception is not enabled!'));
    }
  });
}
