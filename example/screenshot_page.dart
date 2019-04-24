import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

main() async {
  // Start the browser and go to a web page
  var browser = await Browser.start();
  var page = await browser.newPage();
  await page.goto('https://www.github.com', wait: Until.networkIdle);

  // Take a screenshot of the page
  var screenshot = await page.screenshot();

  // Save it to a file
  await File('example/_github_form.png').writeAsBytes(screenshot);

  await browser.close();
}
