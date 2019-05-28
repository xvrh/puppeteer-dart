import 'dart:io';
import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils/utils.dart';

// ignore_for_file: prefer_interpolation_to_compose_strings

main() {
  Server server;
  Browser browser;
  BrowserContext context;
  Page page;
  setUpAll(() async {
    server = await Server.create();
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

  group('input', () {
    test('should upload the file', () async {
      await page.goto(server.prefix + '/input/fileupload.html');
      var filePath = File('test/assets/file-to-upload.txt');
      var input = await page.$('input');
      await input.uploadFile([filePath]);
      expect(await page.evaluate('e => e.files[0].name', args: [input]),
          equals('file-to-upload.txt'));
      expect(await page.evaluate('''e => {
      var reader = new FileReader();
      var promise = new Promise(fulfill => reader.onload = fulfill);
      reader.readAsText(e.files[0]);
      return promise.then(() => reader.result);
      }''', args: [input]), equals('contents of the file'));
    });
  });
}
