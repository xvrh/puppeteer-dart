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

  List<Target> oopifs() {
    return context.targets
        .where((target) => target.targetInfo.type == 'iframe')
        .toList();
  }

  test('should report oopif frames', () async {
    await page.goto('${server.prefix}/dynamic-oopif.html');
    expect(oopifs(), hasLength(1));
    expect(page.frames, hasLength(2));
  }, skip: true);

  test(
    'should load oopif iframes with subresources and request interception',
    () async {
      var framePromise = page.waitForFrame((frame) {
        return frame.url.endsWith('/oopif.html');
      });
      page.onRequest.listen((request) {
        request.continueRequest();
      });
      await page.setRequestInterception(true);
      var requestPromise = page.onRequest.where((request) {
        return request.url.contains('requestFromOOPIF');
      }).first;
      await page.goto('${server.prefix}/dynamic-oopif.html');
      var frame = await framePromise;
      var request = await requestPromise;
      expect(oopifs(), hasLength(1));
      expect(request.frame, frame);
    },
    skip:
        'There is probably a bug in the frame_manager, the oopif is not detected',
  );
}
