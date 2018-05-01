import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chrome_downloader.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import 'utils.dart';

main() {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);

  test('Can download and start chrome', () async {
    String chromeExecutable = (await downloadChrome()).executablePath;

    Chrome chrome =
        await Chrome.start(chromeExecutable, noSandboxFlag: forceNoSandboxFlag);
    try {
      //TODO(xha): replace with a local page to minimize external dependencies
      Tab tab = await chrome.newTab('https://www.github.com');

      String screenshot = await tab.page.captureScreenshot();

      expect(screenshot.length, greaterThan(100));
    } finally {
      await chrome.close();
    }
  });
}
