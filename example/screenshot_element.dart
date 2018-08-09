import 'dart:convert';
import 'dart:io';
import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/domains/page.dart';
import 'package:chrome_dev_tools/domains/runtime.dart';
import 'utils.dart';

main() {
  chromeTab('https://www.github.com', (Tab tab) async {
    // A small helper to wait until the network is quiet
    await tab.waitUntilNetworkIdle();

    // Execute some Javascript to get the rectangle that we want to capture
    EvaluateResult result = await tab.runtime.evaluate(
        '''document.querySelector('form[action="/join"]').getBoundingClientRect();''');

    // Convert the `EvaluateResult` to a Map with all the javascript properties
    Map rect = await tab.remoteObjectProperties(result.result);

    Viewport clip = new Viewport(
        x: rect['x'],
        y: rect['y'],
        width: rect['width'],
        height: rect['height'],
        scale: 1);

    // Capture the screenshot with the clip region
    String screenshot = await tab.page.captureScreenshot(clip: clip);

    // Save it to a file
    await new File.fromUri(Platform.script.resolve('_github_form.png'))
        .writeAsBytes(base64.decode(screenshot));
  });
}
