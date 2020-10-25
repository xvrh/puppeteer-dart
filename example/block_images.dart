import 'dart:io';
import 'package:logging/logging.dart';
import 'package:puppeteer/puppeteer.dart';

void main() async {
  final logger = Logger('example.block_images');

  if (isPuppeteerFirefox) {
    logger.warning('block_images cannot be executed on Firefox.');
    logger.warning(
        'Firefox currently does not support intercepting request/response');
    return;
  }
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
