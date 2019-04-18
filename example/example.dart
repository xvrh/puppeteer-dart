import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chrome_downloader.dart';
import 'package:logging/logging.dart';

// ignore_for_file: unused_local_variable

main() async {
  // Setup a logger if you want to see the raw chrome protocol
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);

  // Download a version of Chrome in a cache folder.
  String chromePath = (await downloadChrome()).executablePath;

  // You can specify the cache location and a specific version of chrome
  var chromePath2 =
      await downloadChrome(cachePath: '.chrome', revision: 497674);

  // Or just use an absolute path to an existing version of Chrome
  String chromePath3 =
      r'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

  // Start the `Chrome` process and connect to the DevTools
  // By default it is start in `headless` mode
  Chrome chrome = await Chrome.start(executablePath: chromePath);

  // Open a new tab
  Tab myTab = await chrome.newTab('https://www.github.com');

  // Do something (see example/ folder).

  // Kill the process
  await chrome.close();
}
