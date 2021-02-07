import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils/utils.dart';

void main() {
  late Server server;
  late Browser browser;
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

  group('Browser.process', () {
    test('should return child_process instance', () async {
      var process = browser.process!;
      expect(process.pid, greaterThan(0));
    });
    test('should not return child_process for remote browser', () async {
      var browserWsEndpoint = browser.wsEndpoint;
      var remoteBrowser =
          await puppeteer.connect(browserWsEndpoint: browserWsEndpoint);
      expect(remoteBrowser.process, isNull);
      remoteBrowser.disconnect();
    });
  });

  group('Browser.isConnected', () {
    test('should set the browser connected state', () async {
      var browserWSEndpoint = browser.wsEndpoint;
      var newBrowser =
          await puppeteer.connect(browserWsEndpoint: browserWSEndpoint);
      expect(newBrowser.isConnected, isTrue);
      newBrowser.disconnect();
      expect(newBrowser.isConnected, isFalse);
    });
  });
}
