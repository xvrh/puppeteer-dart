# chrome_dev_tools

[![Build Status](https://travis-ci.org/xavierhainaux/chrome_dev_tools.svg?branch=master)](https://travis-ci.org/xavierhainaux/chrome_dev_tools)

A Dart library to control Chrome over the DevTools Protocol.

This is a simple 1:1 mapping with the [Chrome DevTools protocol](https://chromedevtools.github.io/devtools-protocol/).  
All the code in `lib/domains` are generated from the [browser_protocol.json](https://chromium.googlesource.com/chromium/src/+/master/third_party/blink/renderer/core/inspector/browser_protocol-1.3.json) and [js_protocol.json](https://chromium.googlesource.com/v8/v8/+/master/src/inspector/js_protocol.json).


## Usage

### Launch Chrome

Download the last revision of chrome and launch it.
```dart
import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chrome_downloader.dart';
import 'package:logging/logging.dart';

main() async {
  // Setup a logger if you want to see the raw chrome protocol
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);

  // Download a version of Chrome in a cache folder.
  String chromePath = (await downloadChrome()).executablePath;

  // You can specify the cache location and a specific version of chrome
  var chromePath2 =
      await downloadChrome(cachePath: '.chrome', revision: 497674);

  // Or just use an absolute path to an existing version of Chrome
  String chromePath3 =
      r'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

  // Start the `Chrome` process and connect to the DevTools
  // By default it is start in `headless` mode
  Chrome chrome = await Chrome.start(chromePath);

  // Open a new tab
  Tab myTab = await chrome.newTab('https://www.github.com');

  // Do something (see example/ folder).

  // Kill the process
  await chrome.close();
}
```

### Generate a PDF from a page

```dart
import 'dart:convert';
import 'dart:io';
import 'package:chrome_dev_tools/chrome_dev_tools.dart';

import 'utils.dart';

main() async {
  await withTab('https://www.github.com', (Tab tab) async {
    // Force the "screen" media or some CSS @media print can change the look
    await tab.emulation.setEmulatedMedia('screen');

    // A small helper to wait until the network is quiet
    await tab.waitUntilNetworkIdle();

    // Capture the PDF and convert it to a List of bytes.
    List<int> pdf = BASE64.decode(await tab.page.printToPDF(
        pageRanges: '1',
        landscape: true,
        printBackground: true,
        marginBottom: 0,
        marginLeft: 0,
        marginRight: 0,
        marginTop: 0));

    // Save the bytes in a file
    await new File.fromUri(Platform.script.resolve('_github.pdf'))
        .writeAsBytes(pdf);
  });
}
```

### Take a screenshot of an element.
```dart
import 'dart:convert';
import 'dart:io';
import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/domains/page.dart';
import 'package:chrome_dev_tools/domains/runtime.dart';

import 'utils.dart';

main() async {
  await withTab('https://www.github.com', (Tab tab) async {
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
        .writeAsBytes(BASE64.decode(screenshot));
  });
}
```

### Create a static version of a Single Page Application
```dart
import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/domains/dom_snapshot.dart';

import 'utils.dart';

main() async {
  await withTab('https://www.google.com', (Tab tab) async {
    // A small helper to wait until the network is quiet
    await tab.waitUntilNetworkIdle();

    // Take a snapshot of the DOM of the current page
    GetSnapshotResult result = await tab.domSnapshot.getSnapshot([]);

    // Iterate the nodes and output some HTML.
    for (DOMNode node in result.domNodes) {
      String nodeString = '<${node.nodeName}';
      if (node.attributes != null) {
        nodeString +=
            ' ${node.attributes.map((n) => '${n.name}=${n.value}').toList()}';
      }
      nodeString += '>';
      print(nodeString);
    }
  });
}
```

## Related work
 * [chrome-remote-interface](https://github.com/cyrus-and/chrome-remote-interface)
 * [puppeteer](https://github.com/GoogleChrome/puppeteer)
 * [webkit_inspection_protocol](https://github.com/google/webkit_inspection_protocol.dart)