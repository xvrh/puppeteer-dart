import 'package:logging/logging.dart';
import 'package:puppeteer/puppeteer.dart';

// ignore_for_file: unused_local_variable

void main() async {
  // Setup a logger if you want to see the raw chrome protocol
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);

  // Download a version of Chrome in a cache folder.
  // This is done by default when we don't provide a [executablePath] to
  // [Browser.start]
  var chromePath = (await downloadChrome()).executablePath;

  // You can specify the cache location and a specific version of chrome
  var chromePath2 =
      await downloadChrome(cachePath: '.chrome', revision: 650583);

  // Or just use an absolute path to an existing version of Chrome
  var chromePath3 =
      r'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

  // Start the `Chrome` process and connect to the DevTools
  // By default it is start in `headless` mode
  var chrome = await puppeteer.launch(executablePath: chromePath);
  try {
    // Open a new tab
    var myPage = await chrome.newPage();

    // Go to a page and wait to be fully loaded
    await myPage.goto('https://pub.dev/packages/puppeteer',
        wait: Until.networkIdle);

    // Do something... See other examples

  } finally {
    // Close the browser process
    // You should always ensure that your script close the process even in case
    // of error. Here, we wrap it in a try/finally block.
    await chrome.close();
  }
}
