import 'package:puppeteer/puppeteer.dart';

void main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();

  // Define a window.onCustomEvent function on the page.
  await page.exposeFunction('onCustomEvent', (Map e) {
    print('${e['type']} fired');
  });

  // Attach an event listener to page to capture a custom event on page load/navigation.
  Future<void> listenFor(type) {
    return page.evaluateOnNewDocument('''type => {
      document.addEventListener(type, e => {
        window.onCustomEvent({type, detail: e.detail});
      });
    }''', args: [type]);
  }

  // Listen for "app-ready" custom event on page load.
  await listenFor('app-ready');

  await page.goto('https://www.chromestatus.com/features',
      wait: Until.networkIdle);

  await browser.close();
}
