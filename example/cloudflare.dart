import 'dart:io';
import 'package:puppeteer/plugins/stealth.dart';
import 'package:puppeteer/puppeteer.dart';

void main() async {
  puppeteer.plugins.add(StealthPlugin());

  var browser = await puppeteer.launch(headless: false, userDataDir: "./userdata/");
  var page = await browser.newPage();

  await page.goto('https://bot.sannysoft.com/');
  page = await browser.newPage();
  await page.goto('https://voiranime.com/');
  await Future.delayed(Duration(seconds: 500));

  await browser.close();
}
