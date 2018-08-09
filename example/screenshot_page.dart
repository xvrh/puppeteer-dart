import 'dart:convert';
import 'dart:io';
import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'utils.dart';

main() {
  chromeTab('https://www.github.com', (Tab tab) async {
    // A small helper to wait until the network is quiet
    await tab.waitUntilNetworkIdle();

    var pageMetrics = await tab.page.getLayoutMetrics();

    // Set page size to the content size
    await tab.emulation.setDeviceMetricsOverride(pageMetrics.contentSize.width,
        pageMetrics.contentSize.height, 1, false);

    // Capture the screenshot
    String screenshot = await tab.page.captureScreenshot();

    // Save it to a file
    await new File.fromUri(Platform.script.resolve('_github.png'))
        .writeAsBytes(base64.decode(screenshot));
  });
}
