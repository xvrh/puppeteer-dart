import 'package:puppeteer/puppeteer.dart';

void main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.goto('https://w3c.github.io/');

  // Either use the helper to get the content
  var pageContent = await page.content;
  print(pageContent);

  // Or get the content directly by executing some Javascript
  var pageContent2 = await page.evaluate('document.documentElement.outerHTML');
  print(pageContent2);

  await browser.close();
}
