import 'package:logging/logging.dart';
import 'package:puppeteer/chrome_downloader.dart';
import 'package:puppeteer/puppeteer.dart';

// ignore_for_file: unused_local_variable

main() async {
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
  var chrome = await Browser.start(executablePath: chromePath);

  // Open a new tab
  var myPage = await chrome.newPage();

  // Go to a page and wait to be fully loaded
  await myPage.goto('https://www.github.com', waitUntil: WaitUntil.networkIdle);

  // Do something... See other examples

  // Kill the process
  await chrome.close();
}
