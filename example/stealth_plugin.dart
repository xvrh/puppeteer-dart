import 'dart:io';
import 'package:puppeteer/plugins/stealth.dart';
import 'package:puppeteer/puppeteer.dart';

void main() async {
  puppeteer.plugins.add(StealthPlugin());

  var browser = await puppeteer.launch();
  var page = await browser.newPage();

  await page.goto('https://bot.sannysoft.com/');
  await Future.delayed(Duration(seconds: 5));
  File('example/_stealth.png')
      .writeAsBytesSync(await page.screenshot(fullPage: true));

  await browser.close();
}
