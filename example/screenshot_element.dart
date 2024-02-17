import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

void main() async {
  // Start the browser and go to a web page
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.goto('https://pub.dev/documentation/puppeteer/latest/',
      wait: Until.networkIdle);

  // Select an element on the page
  var form = await page.$('input[id="search-box"]');

  // Take a screenshot of the element
  var screenshot = await form.screenshot();

  // Save it to a file
  await File('example/_element.png').writeAsBytes(screenshot);

  await browser.close();
}
