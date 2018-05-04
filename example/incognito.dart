import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chrome_downloader.dart';
import 'package:logging/logging.dart';

main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  String chromeExecutable = (await downloadChrome()).executablePath;
  Chrome chrome = await Chrome.start(chromeExecutable);
  try {
    List<Tab> tabs = [];
    for (int i = 0; i < 3; i++) {
      tabs.add(await chrome.newTab('https://www.google.com', incognito: true));
    }

    await Future.wait(tabs.map((t) => t.waitUntilNetworkIdle()));

    int i = 0;
    for (Tab tab in tabs) {
      String screenshot = await tab.page.captureScreenshot();

      // Save it to a file
      await new File.fromUri(Platform.script.resolve('_google_$i.png'))
          .writeAsBytes(BASE64.decode(screenshot));
      ++i;

      await tab.close();
    }
  } finally {
    await chrome.close();
  }
}
