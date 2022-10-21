import 'package:puppeteer/puppeteer.dart';
import 'dart:html';

void main() async {
  var endpoint = document.body!.attributes['x-puppeteer-endpoint'];
  print("Got endpoint: $endpoint");
  var browser = await puppeteer.connect(browserWsEndpoint: endpoint);

  var currentPage = await browser.targets.firstWhere((t) => t.url.endsWith('/index.html')).page;
  print("Got page ${await currentPage.title} ${browser.targets.length}");
  await currentPage.evaluate('''
() => {  
    console.log("Hello from puppeteer in js");
  }  
''');
}