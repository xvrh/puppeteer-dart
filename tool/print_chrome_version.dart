import 'package:puppeteer/puppeteer.dart';

void main() async {
  var browser = await puppeteer.launch();
  var version = await browser.version;
  print('Version: $version');
}
