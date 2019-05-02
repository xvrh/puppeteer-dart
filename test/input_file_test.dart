import 'dart:io';
import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils.dart';

main() {
  Server server;
  Browser browser;
  Page page;
  setUpAll(() async {
    server = await Server.create();
    browser = await puppeteer.launch();
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

  group('input', () {
    test('should upload the file', () async {
      await page.goto(server.prefix + '/input/fileupload.html');
      var filePath = File('test/file-to-upload.txt');
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
