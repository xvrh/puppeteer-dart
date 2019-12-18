import 'package:puppeteer/puppeteer.dart';

void main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();

  // function declaration syntax
  await page.evaluate('function(x) { return x > 0; }', args: [7]);

  // shorthand syntax
  await page.evaluate('(x) => x > 0', args: [7]);

  // Multi line shorthand syntax
  await page.evaluate('''(x) => {  
    return x > 0;
  }''', args: [7]);

  // shorthand syntax with async
  await page.evaluate('''async (x) => {
    return await x;
  }''', args: [7]);

  // An expression.
  await page.evaluate('document.body');

  await browser.close();
}
