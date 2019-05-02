import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils.dart';

main() {
  Server server;
  Browser browser;
  setUpAll(() async {
    server = await Server.create();
    browser = await puppeteer.launch();
  });

  tearDownAll(() async {
    await browser.close();
    await server.close();
  });

  tearDown(() {
    server.clearRoutes();
  });

  group('Browser.version', () {
    test('should return whether we are in headless', () async {
      var version = await browser.version;
      expect(version.length, greaterThan(0));
      expect(version.startsWith('Headless'), isTrue);
    });
  });

  group('Browser.userAgent', () {
    test('should include WebKit', () async {
      var userAgent = await browser.userAgent;
      expect(userAgent.length, greaterThan(0));
      expect(userAgent, contains('WebKit'));
    });
  });

  group('Browser.target', () {
    test('should return browser target', () async {
      var target = browser.target;
      expect(target.type, equals('browser'));
    });
  });
}
