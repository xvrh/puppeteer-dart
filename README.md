# chrome_dev_tools

A Dart library to control Chrome over the DevTools Protocol.

This is a simple 1:1 mapping with the [Chrome DevTools protocol](https://chromedevtools.github.io/devtools-protocol/).  
All the code in `lib/domains` are generated from the [browser_protocol.json](browser_protocol.json) and [js_protocol.json](js_protocol.json).


## Usage

### Launch Chromium

Download the last revision of chromium and launch it.
```dart
import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chromium_downloader.dart';

main() async {
  // Download Chromium if necessary. You can also specify the cache folder and a specific revision.
  String chromeExecutable = await downloadChromium();

  // Launch a process and connect to the DevTools
  Chromium chromium = await Chromium.launch(chromeExecutable, headless: true);

  // Open a new tab
  await chromium.targets.createTarget('https://www.github.com');

  // Kill the process and delete the user-data directory
  await chromium.close();
}
```

### Generate a PDf from a page

```dart
import 'dart:convert';
import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/domains/emulation.dart';
import 'package:chrome_dev_tools/domains/page.dart';
import 'package:chrome_dev_tools/domains/target.dart';
import 'package:chrome_dev_tools/src/wait_until.dart';

main() async {
  Chromium chromium; // ....
  
  // Open github in a new tab
  TargetID targetId = await chromium.targets.createTarget(
      'https://www.github.com');
  Session session = await chromium.connection.createSession(targetId);

  // Force the "screen" media. Then CSS "@media print" won't change the look
  EmulationDomain emulation = new EmulationDomain(session);
  await emulation.setEmulatedMedia('screen');

  // A small helper to wait until the network is quite
  await waitUntilNetworkIdle(session);

  PageDomain page = new PageDomain(session);
  // Capture the PDF and convert it to a List of bytes.
  List<int> pdf = BASE64.decode(await page.printToPDF(
      pageRanges: '1',
      landscape: true,
      printBackground: true,
      marginBottom: 0,
      marginLeft: 0,
      marginRight: 0,
      marginTop: 0));
}
```

### Take a screenshot of an element.
```dart
main() async {
  Session session; // ....
  
  RuntimeDomain runtime = new RuntimeDomain(session);
  
  // Evaluate a Javascript expression to get the absolute bounds of a specific element 
  var result = await runtime.evaluate(
      '''document.querySelector('form[action="/join"]').getBoundingClientRect();''');
  var object = await runtime.getProperties(result.result.objectId);

  num getNum(String propertyName) {
    return object.result.firstWhere((p) => p.name == propertyName).value.value;
  }

  Viewport clip = new Viewport(
      x: getNum('x'),
      y: getNum('y'),
      width: getNum('width'),
      height: getNum('height'),
      scale: 1);

  PageDomain page = new PageDomain(session);
  
  // Capture a zone of the page.
  String screenshot = await page.captureScreenshot(clip: clip);

  // Save it in a file
  await new File.fromUri(Platform.script.resolve('_github_form.png'))
      .writeAsBytes(BASE64.decode(screenshot));
}
```
### Create a static version of a Single Page Application
TODO


## Related work
 * [chrome-remote-interface](https://github.com/cyrus-and/chrome-remote-interface)
 * [puppeteer](https://github.com/GoogleChrome/puppeteer)

[browser_protocol.json]: https://chromium.googlesource.com/chromium/src/+/master/third_party/WebKit/Source/core/inspector/browser_protocol.json
[js_protocol.json]: https://chromium.googlesource.com/v8/v8/+/master/src/inspector/js_protocol.json