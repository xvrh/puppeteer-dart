import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

void main() async {
  // Start the browser and go to a web page
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.goto('https://pub.dev/packages/puppeteer',
      wait: Until.networkIdle);

  // For this example, we force the "screen" media-type because sometime
  // CSS rules with "@media print" can change the look of the page.
  await page.emulateMediaType(MediaType.screen);

  // Capture the PDF and save it to a file.
  await page.pdf(
      format: PaperFormat.a4,
      printBackground: true,
      pageRanges: '1',
      output: File('example/_dart.pdf').openWrite());
  await browser.close();
}
