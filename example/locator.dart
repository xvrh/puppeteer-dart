import 'package:puppeteer/puppeteer.dart';

void main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();

  await page.setContent('''
    <input name="q" />
    <button type="button" onclick="this.textContent = 'Clicked!'">Search</button>
  ''');

  // A locator auto-waits for the element to be visible, stable and enabled,
  // then retries the whole action until it succeeds or the timeout elapses.
  await page.locator('input[name="q"]').fill('Headless Chrome');
  await page.locator('button').click();

  // Puppeteer-specific selectors work anywhere a selector is accepted, e.g.
  // matching by visible text.
  var button = await page.$('::-p-text(Clicked!)');
  print(await button.evaluate('e => e.textContent'));

  await browser.close();
}
