import 'package:logging/logging.dart';
import 'package:puppeteer/devices.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils.dart';

main() {
  Logger.root.onRecord.listen(print);

  Server server;
  Browser browser;
  Page page;
  setUpAll(() async {
    server = await Server.create();
    browser = await Browser.start();
  });

  tearDownAll(() async {
    await browser.close();
    await server.close();
  });

  setUp(() async {
    page = await browser.newPage();
    await page.goto(server.emptyPage);
  });

  tearDown(() async {
    await page.close();
    page = null;
  });

  group('Touchscreen', () {
    test('should tap the button', () async {
      await page.emulate(iPhone6);
      await page.goto(server.prefix + '/input/button.html');
      await page.tap('button');
      expect(await page.evaluate('() => result'), equals('Clicked'));
    });
    test('should report touches', () async {
      await page.emulate(iPhone6);
      await page.goto(server.prefix + '/input/touches.html');
      var button = await page.$('button');
      await button.tap();
      expect(await page.evaluate('() => getResult()'),
          equals(['Touchstart: 0', 'Touchend: 0']));
    });
  });
}
