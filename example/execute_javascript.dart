import 'package:puppeteer/puppeteer.dart';

main() async {
  var page = await (await Browser.start()).newPage();

  // function declaration syntax
  await page.evaluate('function(x) { return x > 0; }', args: [7]);

  // shorthand syntax
  await page.evaluate('(x) => x > 0', args: [7]);

  // Multi line shorthand syntax
  await page.evaluate('''(x) => {  
    return x > 0;
  }''', args: [7]);

  // shorthand syntax with async
  await page.evaluate('''async (conf) => {
    return await fetch(conf);
  }''', args: ['config.js']);

  // An expression.
  await page.evaluate('document.body');
}
