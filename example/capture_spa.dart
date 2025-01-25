import 'package:puppeteer/puppeteer.dart';

void main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.goto('https://pub.dev/documentation/puppeteer/latest/');

  // Either use the helper to get the content
  var pageContent = await page.content;
  print(pageContent);

  // Or get the content directly by executing some Javascript
  var pageContent2 = await page.evaluate<String>(
    'document.documentElement.outerHTML',
  );
  print(pageContent2);

  await browser.close();
}
