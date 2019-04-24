import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

main() async {
  // Start the browser and go to a web page
  var browser = await Browser.start();
  var page = await browser.newPage();
  await page.goto('https://www.github.com', wait: Until.networkIdle);

  // Select an element on the page
  var form = await page.$('form[action="/join"]');

  // Take a screenshot of the element
  var screenshot = await form.screenshot();

  // Save it to a file
  await File('example/_github_form.png').writeAsBytes(screenshot);

  await browser.close();
}
