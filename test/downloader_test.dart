import 'dart:io';
import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';

void main() {
  test('Download to path', () async {
    var revision = await downloadChrome(cachePath: '.local-chromium-test');

    expect(revision.executablePath, contains('.local-chromium-test'));
    expect(File(revision.executablePath).existsSync(), isTrue);

    var browser =
        await puppeteer.launch(executablePath: revision.executablePath);
    var page = await browser.newPage();
    await page.close();
    await browser.close();
  }, timeout: Timeout.factor(4));
}
