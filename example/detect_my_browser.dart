import 'dart:io';

import 'package:logging/logging.dart';
import 'package:puppeteer/puppeteer.dart';

Future<void> main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  final browser = await puppeteerFirefox.launch(
    headless: false,
    executablePath: '/Applications/Firefox Nightly.app/Contents/MacOS/firefox',
  );
  final myPage = await browser.newPage();

  // Go to a page and wait to be fully loaded
  await myPage.goto('https://www.google.com');

  // Do something... See other examples
  await myPage.click('input[name="q"]');
  await myPage.keyboard.type('puppeteer');

  await Future.wait([
    myPage.waitForNavigation(),
    myPage.keyboard.press(Key.enter),
  ]);

  await File('_google-puppeteer.png').writeAsBytes(await myPage.screenshot());

  await myPage.goto('https://detectmybrowser.com/');

  await File('_detect-my-browser.png').writeAsBytes(await myPage.screenshot());

  // Gracefully close the browser's process
  await browser.close();
}
