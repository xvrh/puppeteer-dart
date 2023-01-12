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

  group('Page.Events.Dialog', () {
    test('should fire', () async {
      page.onDialog.listen((dialog) {
        expect(dialog.type, DialogType.alert);
        expect(dialog.defaultValue, '');
        expect(dialog.message, 'yo');
        dialog.accept();
      });
      await page.evaluate("() => alert('yo')");
    });
    test('should allow accepting prompts', () async {
      page.onDialog.listen((dialog) {
        expect(dialog.type, DialogType.prompt);
        expect(dialog.defaultValue, 'yes.');
        expect(dialog.message, 'question?');
        dialog.accept(promptText: 'answer!');
      });
      var result = await page.evaluate("() => prompt('question?', 'yes.')");
      expect(result, 'answer!');
    });
    test('should dismiss the prompt', () async {
      page.onDialog.listen((dialog) {
        dialog.dismiss();
      });
      var result = await page.evaluate("() => prompt('question?')");
      expect(result, isNull);
    });
  });
}
