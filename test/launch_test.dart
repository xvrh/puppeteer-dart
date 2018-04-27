import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chrome_downloader.dart';
import 'package:chrome_dev_tools/domains/page.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import 'utils.dart';

main() {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);

  test('Can download and launch chrome', () async {
    String chromeExecutable = (await downloadChrome()).executablePath;

    Chrome chrome = await Chrome.launch(chromeExecutable,
        noSandboxFlag: forceNoSandboxFlag);
    try {
      //TODO(xha): replace by a local page to minimize external dependencies
      TargetID targetId =
          await chrome.targets.createTarget('https://www.github.com');
      Session session = await chrome.connection.createSession(targetId);

      PageManager page = new PageManager(session);
      String screenshot = await page.captureScreenshot();

      expect(screenshot.length, greaterThan(100));
    } finally {
      await chrome.close();
    }
  });
}
