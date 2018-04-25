# chrome_dev_tools

A Dart library to control Chrome over the DevTools Protocol.

This is a simple 1:1 mapping with the [Chrome DevTools protocol](https://chromedevtools.github.io/devtools-protocol/).  
All the code in `lib/domains` are generated from the [browser_protocol.json](https://chromium.googlesource.com/chromium/src/+/master/third_party/blink/renderer/core/inspector/browser_protocol-1.3.json) and [js_protocol.json](https://chromium.googlesource.com/v8/v8/+/master/src/inspector/js_protocol.json).


## Usage

### Launch Chromium

Download the last revision of chromium and launch it.
```dart
import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chromium_downloader.dart';
import 'package:logging/logging.dart';

main() async {
  // Setup a logger to output the chrome protocol
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);
  
  // Download a version of Chromium in a cache folder.
  // `downloadChromium` optionally take `revision` and `cacheFolder` to specify
  // the particular version of Chromium and the cache folder where to download
  // the binaries.
  String chromeExecutable = (await downloadChromium()).executablePath;
  
  // Or just use an absolute path to an existing version of Chrome
  chromeExecutable = r'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

  // Launch the `Chromium` process and connect to the DevTools
  // By default it is start in `headless` mode
  Chromium chromium = await Chromium.launch(chromeExecutable);

  // Open a new tab
  await chromium.targets.createTarget('https://www.github.com');
  
  // Do something (see examples bellow).

  // Kill the process
  await chromium.close();
}
```

### Generate a PDF from a page

```dart
import 'dart:convert';
import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/domains/emulation.dart';
import 'package:chrome_dev_tools/domains/page.dart';
import 'package:chrome_dev_tools/domains/target.dart';
import 'package:chrome_dev_tools/src/wait_until.dart';

main() async {
  // Launch Chromium, see previous example
  Chromium chromium; // ....
  
  // Open github in a new tab
  TargetID targetId = await chromium.targets.createTarget(
      'https://www.github.com');
  Session session = await chromium.connection.createSession(targetId);

  // Force the "screen" media. Then CSS "@media print" won't change the look
  EmulationManager emulation = new EmulationManager(session);
  await emulation.setEmulatedMedia('screen');

  // A small helper to wait until the network is quiet
  await waitUntilNetworkIdle(session);

  // Capture the PDF and convert it to a List of bytes.
  PageManager page = new PageManager(session);
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
  // Launch chrome, open a page, wait for network. See previous examples
  Session session; // ...

  RuntimeManager runtime = new RuntimeManager(session);
  
  // Execute some Javascript to get the rectangle that we want to capture
  var result = await runtime.evaluate(
      '''document.querySelector('form[action="/join"]').getBoundingClientRect();''');

  // Helper to convert a "RemoteObject" to a Map
  Map rect = await getProperties(session, result.result);

  Viewport clip = new Viewport(
      x: rect['x'],
      y: rect['y'],
      width: rect['width'],
      height: rect['height'],
      scale: 1);

  PageManager page = new PageManager(session);
  
  // Capture the screenshot with the clip region
  String screenshot = await page.captureScreenshot(clip: clip);

  // Save it to a file
  await new File.fromUri(Platform.script.resolve('_github_form.png'))
      .writeAsBytes(BASE64.decode(screenshot));

  await chromium.close();
}

```
### Create a static version of a Single Page Application
```dart
main() async {
  // Launch chrome, open a page, wait for network. See previous examples
  Session session; //...
  
  // Take a snapshot of the DOM of the current page
  DOMSnapshotManager dom = new DOMSnapshotManager(session);
  var result = await dom.getSnapshot([]);

  // Iterate the nodes and output some html.
  // This example needs a lot more work
  // Or see alternative way directly in javascript in example/capture_spa_with_javascript.dart
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
