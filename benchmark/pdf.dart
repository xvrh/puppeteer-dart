import 'package:puppeteer/puppeteer.dart';

void main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.goto('https://news.ycombinator.com',
      wait: Until.networkAlmostIdle);

  var watch = Stopwatch()..start();
  await page.pdf(format: PaperFormat.letter);
  print('${watch.elapsedMilliseconds}ms');

  await browser.close();
}
