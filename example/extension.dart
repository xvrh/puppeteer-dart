import 'package:puppeteer/puppeteer.dart';

void main() async {
  var browser = await puppeteer.launch(extensions: ['example/extension']);
  var extension = (await browser.extensions).values.single;
  var origin = 'chrome-extension://${extension.id}';

  // Run code in the extension's service worker
  var serviceWorkerTarget = await browser.waitForTarget(
    (t) => t.type == 'service_worker' && t.url.startsWith(origin),
  );
  var serviceWorker = (await serviceWorkerTarget.worker)!;
  print(
    await serviceWorker.evaluate('() => chrome.runtime.getManifest().name'),
  );

  // Click the extension's toolbar icon and get its popup
  var page = await browser.newPage();
  var popupTarget = browser.waitForTarget((t) => t.url == '$origin/popup.html');
  await page.triggerExtensionAction(extension);
  var popup = await (await popupTarget).page;
  var title = await popup.waitForSelector('h1');
  print(await title!.evaluate('e => e.textContent'));

  await browser.close();
}
