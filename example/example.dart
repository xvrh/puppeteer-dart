import 'package:puppeteer/puppeteer.dart';

void main() async {
  // Download the Chromium binaries, launch it and connect to the "DevTools"
  var browser = await puppeteer.launch();

  // Open a new tab
  var myPage = await browser.newPage();

  // Go to a page and wait to be fully loaded
  await myPage.goto('https://pub.dev/packages/puppeteer',
      wait: Until.networkIdle);

  // Do something... See other examples
  await myPage.screenshot();
  await myPage.pdf();
  await myPage.evaluate('() => document.title');

  // Gracefully close the browser's process
  await browser.close();
}
