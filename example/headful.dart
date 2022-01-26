import 'package:puppeteer/puppeteer.dart';

void main() async {
  var browser = await puppeteer.launch(headless: false);
  // Do something...
  await browser.newPage();
  await browser.close();
}
