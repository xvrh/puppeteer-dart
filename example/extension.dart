import 'package:puppeteer/puppeteer.dart';

void main() async {
  var browser = await puppeteer.launch(extensions: ['example/extension']);
  var extension = (await browser.extensions).values.single;
  var origin = 'chrome-extension://${extension.id}';

  // The extension's service worker
  var serviceWorker = await browser.waitForTarget(
    (t) => t.type == 'service_worker' && t.url.startsWith(origin),
  );
  print(serviceWorker.url);

  // Click the extension's toolbar icon and get its popup
  var page = await browser.newPage();
  var popupTarget = browser.waitForTarget((t) => t.url == '$origin/popup.html');
  await page.triggerExtensionAction(extension);
  var popup = await (await popupTarget).page;
  var title = await popup.waitForSelector('h1');
  print(await title!.evaluate('e => e.textContent'));
  print(await popup.evaluate('() => chrome.runtime.getManifest().name'));

  await browser.close();
}
