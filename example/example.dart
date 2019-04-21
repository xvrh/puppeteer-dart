import 'package:puppeteer/puppeteer.dart';

main() async {
  // Start the `Chrome` process and connect to the DevTools
  // By default it is start in `headless` mode
  var browser = await Browser.start();

  // Open a new tab
  var myPage = await browser.newPage();

  // Go to a page and wait to be fully loaded
  await myPage.goto('https://www.github.com', wait: Until.networkIdle);

  // Do something... See other examples
  await myPage.screenshot();
  await myPage.pdf();
  await myPage.evaluate('() => document.title');

  // Kill the process
  await browser.close();
}
