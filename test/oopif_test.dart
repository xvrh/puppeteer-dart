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
    browser = await puppeteer.launch(args: ['--site-per-process']);
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

  List<Target> _oopifs() {
    return context.targets
        .where((target) => target.targetInfo.type == 'iframe')
        .toList();
  }

  test('should report oopif frames', () async {
    await page.goto('${server.prefix}/dynamic-oopif.html');
    expect(_oopifs(), hasLength(1));
    expect(page.frames, hasLength(2));
  }, skip: true);
  test('should load oopif iframes with subresources and request interception',
      () async {
    await page.setRequestInterception(true);
    page.onRequest.listen((request) => request.continueRequest());
    await page.goto('${server.prefix}/dynamic-oopif.html');
    expect(_oopifs(), hasLength(1));
  });
}
