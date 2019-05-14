import 'package:puppeteer/plugins/stealth.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils/utils.dart';

main() {
  Server server;
  Browser browser;
  BrowserContext context;
  Page page;
  setUpAll(() async {
    server = await Server.create();
    puppeteer.plugins.add(StealthPlugin());
    browser = await puppeteer.launch();
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

  test('Stealth plugin', () async {
    await page.goto(server.emptyPage);
    String ua = await page.evaluate('window.navigator.userAgent');
    expect(ua.toLowerCase(), contains('chrome'));
    expect(ua.toLowerCase(), isNot(contains('headless')));
  });
}
