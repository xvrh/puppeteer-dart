import 'dart:io';

import 'package:puppeteer/puppeteer.dart';

main() async {
  // Start the browser and go to a web page
  var browser = await Browser.start();
  var page = await browser.newPage();
  await page.goto('https://www.github.com', waitUntil: WaitUntil.networkIdle);

  // Force the "screen" media or some CSS @media print can change the look
  await page.emulateMedia('screen');

  // Capture the PDF and convert it to a List of bytes.
  var pdf = await page.pdf(
      format: PaperFormat.a4, printBackground: true, pageRanges: '1');

  // Save the bytes in a file
  await File('example/_github.pdf').writeAsBytes(pdf);

  await browser.close();
}
