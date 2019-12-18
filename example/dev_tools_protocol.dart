import 'package:puppeteer/puppeteer.dart';

void main() async {
  var browser = await puppeteer.launch();
  // Create a chrome's tab
  var page = await browser.newPage();

  // You can access the entire Chrome DevTools protocol.
  // This is useful to access information not exposed by the Puppeteer API
  // Be aware that this is a low-level, complex API.
  // Documentation of the protocol: https://chromedevtools.github.io/devtools-protocol/

  // Examples:

  // Start a screencast
  await page.devTools.page.startScreencast();

  // Change the animation speed for the document
  await page.devTools.animation.setPlaybackRate(10);

  // Access the memory information for the page
  await page.devTools.memory.getDOMCounters();

  // Go to https://chromedevtools.github.io/devtools-protocol/ to read more about
  // the protocol and use the code in `lib/protocol`.

  await browser.close();
}
