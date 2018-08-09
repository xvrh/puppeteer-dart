import 'dart:async';
import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chrome_downloader.dart';
import 'package:logging/logging.dart';

typedef _Callback(Tab tab);

Future chromeTab(String url, _Callback callback,
    {bool setupLogger = true}) async {
  if (setupLogger) {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen(print);
  }

  String chromeExecutable = (await downloadChrome()).executablePath;
  Chrome chrome = await Chrome.start(chromeExecutable);
  Tab tab = await chrome.newTab(url);

  try {
    await callback(tab);
  } finally {
    await chrome.close();
  }
}
