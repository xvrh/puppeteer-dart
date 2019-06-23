import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

main() async {
  // Start the browser and go to a web page
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.goto('https://www.github.com', wait: Until.networkIdle);

  // Force the "screen" media or some CSS @media print can change the look
  await page.emulateMedia('screen');

  // Capture the PDF and save it to a file.
  await page.pdf(
      format: PaperFormat.a4,
      printBackground: true,
      pageRanges: '1',
      output: File('example/_github.pdf').openWrite());
  await browser.close();
}
