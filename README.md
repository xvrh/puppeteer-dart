# chrome_dev_tools

A Dart library to control Chrome over the DevTools Protocol.

This is a simple 1:1 mapping with the [Chrome DevTools protocol](https://chromedevtools.github.io/devtools-protocol/).  
All the code in `lib/domains` are generated from the [browser_protocol.json](https://chromium.googlesource.com/chromium/src/+/master/third_party/WebKit/Source/core/inspector/browser_protocol.json) and [js_protocol.json](https://chromium.googlesource.com/v8/v8/+/master/src/inspector/js_protocol.json).


## Usage

### Launch Chromium

Download the last revision of chromium and launch it.
```dart
import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chromium_downloader.dart';

main() async {
  // Download a version of Chromium in a cache folder.
  // Depending of your OS, you may need to add some execution permission.
  String chromeExecutable = (await downloadChromium(revision: 497674)).executablePath;

  // Launch a process and connect to the DevTools
  Chromium chromium = await Chromium.launch(chromeExecutable, headless: true);

  // Open a new tab
  await chromium.targets.createTarget('https://www.github.com');

  // Kill the process
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


  // Capture the PDF and convert it to a List of bytes.
  PageDomain page = new PageDomain(session);
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
import 'dart:convert';
import 'dart:io';
import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chromium_downloader.dart';
import 'package:chrome_dev_tools/domains/page.dart';
import 'package:chrome_dev_tools/domains/runtime.dart';
import 'package:chrome_dev_tools/src/remote_object.dart';
import 'package:chrome_dev_tools/src/wait_until.dart';

main() async {
  Session session; // ...

  await waitUntilNetworkIdle(session);

  RuntimeDomain runtime = new RuntimeDomain(session);
  var result = await runtime.evaluate(
      '''document.querySelector('form[action="/join"]').getBoundingClientRect();''');

  Map rect = await getProperties(session, result.result);

  Viewport clip = new Viewport(
      x: rect['x'],
      y: rect['y'],
      width: rect['width'],
      height: rect['height'],
      scale: 1);

  PageDomain page = new PageDomain(session);
  String screenshot = await page.captureScreenshot(clip: clip);

  await new File.fromUri(Platform.script.resolve('_github_form.png'))
      .writeAsBytes(BASE64.decode(screenshot));

  await chromium.close();
}

```
### Create a static version of a Single Page Application
```dart
main() async {
  Session session; //...
  
  // Take a snapshot of the DOM of the current page
  DOMSnapshotDomain dom = new DOMSnapshotDomain(session);
  var result = await dom.getSnapshot([]);

  // Iterate the nodes and output some html.
  // This example needs a lot more work
  for (DOMNode node in result.domNodes) {
    String nodeString = '<${node.nodeName}';
    if (node.attributes != null) {
      nodeString +=
          ' ${node.attributes.map((n) => '${n.name}=${n.value}').toList()}';
    }
    nodeString += '>';
    print(nodeString);
  }
}
```

## Related work
 * [chrome-remote-interface](https://github.com/cyrus-and/chrome-remote-interface)
 * [puppeteer](https://github.com/GoogleChrome/puppeteer)
