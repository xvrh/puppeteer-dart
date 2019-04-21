import 'package:puppeteer/puppeteer.dart';

main() async {
  var browser = await Browser.start();
  var page = await browser.newPage();
  await page.goto('https://www.w3.org');

  // Either use the helper to get the content
  var pageContent = await page.content;
  print(pageContent);

  // Or get the content directly by executing some Javascript
  var pageContent2 = await page.evaluate('document.documentElement.outerHTML');
  print(pageContent2);

  await browser.close();
}
