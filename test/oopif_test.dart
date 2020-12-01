import 'package:puppeteer/puppeteer.dart';
import 'package:puppeteer/src/target.dart';
import 'package:test/test.dart';
import 'utils/test_api.dart';
import 'utils/utils.dart';

void main() {
  Server server;
  Browser browser;
  BrowserContext context;
  Page page;
  setUpAll(() async {
    server = await Server.create();
    browser = await puppeteer.launch(args: ['--site-per-process']);
  });

  tearDownAll(() async {
    await server.close();
    await browser.close();
    browser = null;
  });

  setUp(() async {
    context = await browser.createIncognitoBrowserContext();
    page = await context.newPage();
  });

  tearDown(() async {
    server.clearRoutes();
    await context.close();
    page = null;
  });

  List<Target> _oopifs() {
    return context.targets
        .where((target) => target.targetInfo.type == 'iframe')
        .toList();
  }

  groupChromeOnly('OOPIF', () {
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
  });
}
