import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chromium_downloader.dart';
import 'package:chrome_dev_tools/domains/page.dart';
import 'package:test/test.dart';

main() {
  test('Can download and launch chromium', () async {
    String chromeExecutable = (await downloadChromium()).executablePath;

    Chromium chromium = await Chromium.launch(chromeExecutable);
    try {
      //TODO(xha): replace by a local page
      TargetID targetId =
          await chromium.targets.createTarget('https://www.github.com');
      Session session = await chromium.connection.createSession(targetId);

      PageManager page = new PageManager(session);
      String screenshot = await page.captureScreenshot();

      expect(screenshot, isNotEmpty);
    } finally {
      await chromium.close();
    }
  });
}
