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

  group('Touchscreen', () {
    test('should tap the button', () async {
      await page.emulate(puppeteer.devices.iPhone6);
      await page.goto(server.prefix + '/input/button.html');
      await page.tap('button');
      expect(await page.evaluate('() => result'), equals('Clicked'));
    });
    test('should report touches', () async {
      await page.emulate(puppeteer.devices.iPhone6);
      await page.goto(server.prefix + '/input/touches.html');
      var button = await page.$('button');
      await button.tap();
      expect(await page.evaluate('() => getResult()'),
          equals(['Touchstart: 0', 'Touchend: 0']));
    });
  });
}
