import 'dart:io';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chrome_downloader.dart';
import 'package:logging/logging.dart';

main() async {
  // Setup a logger to output the chrome protocol
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);

  // Download a version of Chrome in a cache folder.
  // `downloadChrome` optionally take `revision` and `cacheFolder` to specify
  // the particular version of Chrome and the cache folder where to download
  // the binaries.
  String chromeExecutable = (await downloadChrome()).executablePath;

  if (Platform.isMacOS) {
    // Or just use an absolute path to an existing version of Chrome
    chromeExecutable =
        r'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
  }

  // Launch the `Chrome` process and connect to the DevTools
  // By default it is start in `headless` mode
  Chrome chrome = await Chrome.launch(chromeExecutable);

  // Open a new tab
  await chrome.targets.createTarget('https://www.github.com');

  // Do something (see examples bellow).

  // Kill the process
  await chrome.close();
}
