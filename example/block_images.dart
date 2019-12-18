import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

void main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.setRequestInterception(true);
  page.onRequest.listen((request) {
    if (request.resourceType == ResourceType.image) {
      request.abort();
    } else {
      request.continueRequest();
    }
  });
  await page.goto('https://news.google.com/news/');
  var screenshot = await page.screenshot(fullPage: true);
  await File('_news.png').writeAsBytes(screenshot);

  await browser.close();
}
