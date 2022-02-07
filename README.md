# Puppeteer in Dart

A Dart library to automate the Chrome browser over the DevTools Protocol.

This is a port of the [Puppeteer Node.JS library](https://pptr.dev/) in the [Dart language](https://www.dartlang.org/).

[![pub package](https://img.shields.io/pub/v/puppeteer.svg)](https://pub.dartlang.org/packages/puppeteer)
[![Build Status](https://github.com/xvrh/puppeteer-dart/workflows/Build/badge.svg?branch=master)](https://github.com/xvrh/puppeteer-dart)
[![Coverage Status](https://coveralls.io/repos/github/xvrh/puppeteer-dart/badge.svg?branch=master)](https://coveralls.io/github/xvrh/puppeteer-dart?branch=master)

###### What can I do?

Most things that you can do manually in the browser can be done using Puppeteer! Here are a few examples to get you started:

* Generate screenshots and PDFs of pages.
* Crawl a SPA (Single-Page Application) and generate pre-rendered content (i.e. "SSR" (Server-Side Rendering)).
* Automate form submission, UI testing, keyboard input, etc.
* Create an up-to-date, automated testing environment. Run your tests directly in the latest version of Chrome using the latest JavaScript and browser features.

###### Flutter
See [limitations with Flutter](#limitations-with-flutter) section.

## API

* See the full API in a single-page document: [doc/api.md](doc/api.md)
* See the Dart Doc for this package: [API reference](https://pub.dartlang.org/documentation/puppeteer/latest/puppeteer/puppeteer-library.html)
* The Dart version of Puppeteer is very similar to the original Javascript code. Every sample available for Puppeteer Node.JS could be converted in Dart very easily. 

## Examples
* [Launch chrome](#launch-chrome)
* [Generate a PDF from an HTML page](#generate-a-pdf-from-a-page)
* [Take a screenshot of a page](#take-a-screenshot-of-a-complete-html-page)
* [Take a screenshot of an element in a page](#take-a-screenshot-of-a-specific-node-in-the-page)
* [Create a static version of a Single Page Application](#create-a-static-version-of-a-single-page-application)
* [Capture a screencast of the page](#capture-a-screencast-of-the-page)
* [Execute JavaScript code](#execute-javascript-code)

### Launch Chrome

Download the last revision of chrome and launch it.
```dart
import 'package:puppeteer/puppeteer.dart';

void main() async {
  // Download the Chromium binaries, launch it and connect to the "DevTools"
  var browser = await puppeteer.launch();

  // Open a new tab
  var myPage = await browser.newPage();

  // Go to a page and wait to be fully loaded
  await myPage.goto('https://dart.dev', wait: Until.networkIdle);

  // Do something... See other examples
  await myPage.screenshot();
  await myPage.pdf();
  await myPage.evaluate('() => document.title');

  // Gracefully close the browser's process
  await browser.close();
}
```

### Generate a PDF from a page

```dart
import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

void main() async {
  // Start the browser and go to a web page
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.goto('https://dart.dev', wait: Until.networkIdle);

  // For this example, we force the "screen" media-type because sometime
  // CSS rules with "@media print" can change the look of the page.
  await page.emulateMediaType(MediaType.screen);

  // Capture the PDF and save it to a file.
  await page.pdf(
      format: PaperFormat.a4,
      printBackground: true,
      pageRanges: '1',
      output: File('example/_dart.pdf').openWrite());
  await browser.close();
}
```

### Take a screenshot of a complete HTML page

```dart
import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

void main() async {
  // Start the browser and go to a web page
  var browser = await puppeteer.launch();
  var page = await browser.newPage();

  // Setup the dimensions and user-agent of a particular phone
  await page.emulate(puppeteer.devices.pixel2XL);

  await page.goto('https://dart.dev', wait: Until.networkIdle);

  // Take a screenshot of the page
  var screenshot = await page.screenshot();

  // Save it to a file
  await File('example/_github.png').writeAsBytes(screenshot);

  await browser.close();
}
```

### Take a screenshot of a specific node in the page
```dart
import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

void main() async {
  // Start the browser and go to a web page
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.goto('https://stackoverflow.com/', wait: Until.networkIdle);

  // Select an element on the page
  var form = await page.$('input[name="q"]');

  // Take a screenshot of the element
  var screenshot = await form.screenshot();

  // Save it to a file
  await File('example/_element.png').writeAsBytes(screenshot);

  await browser.close();
}
```

### Interact with the page and scrap content
```dart
import 'package:puppeteer/puppeteer.dart';

void main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();

  await page.goto('https://developers.google.com/web/',
      wait: Until.networkIdle);

  // Type into search box.
  await page.type('.devsite-search-field', 'Headless Chrome');

  // Wait for suggest overlay to appear and click "show all results".
  var allResultsSelector = '.devsite-suggest-all-results';
  await page.waitForSelector(allResultsSelector);
  await page.click(allResultsSelector);

  // Wait for the results page to load and display the results.
  const resultsSelector = '.gsc-results .gsc-thumbnail-inside a.gs-title';
  await page.waitForSelector(resultsSelector);

  // Extract the results from the page.
  var links = await page.evaluate(r'''resultsSelector => {
  const anchors = Array.from(document.querySelectorAll(resultsSelector));
  return anchors.map(anchor => {
    const title = anchor.textContent.split('|')[0].trim();
    return `${title} - ${anchor.href}`;
  });
}''', args: [resultsSelector]);
  print(links.join('\n'));

  await browser.close();
}
```

### Create a static version of a Single Page Application
```dart
import 'package:puppeteer/puppeteer.dart';

void main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.goto('https://w3c.github.io/');

  // Either use the helper to get the content
  var pageContent = await page.content;
  print(pageContent);

  // Or get the content directly by executing some Javascript
  var pageContent2 = await page.evaluate('document.documentElement.outerHTML');
  print(pageContent2);

  await browser.close();
}
```

### Capture a screencast of the page
The screencast feature is not part of the Puppeteer API.
This example uses the low-level protocol API to send the commands to the browser.

```dart
import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as image;
import 'package:puppeteer/puppeteer.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

void main() async {
  // Start a local web server and open the page
  var server =
      await io.serve(createStaticHandler('example/html'), 'localhost', 0);
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.goto('http://localhost:${server.port}/rubiks_cube/index.html');

  // On each frame, decode the image and use the "image" package to create an
  // animated gif.
  var animation = image.Animation();
  page.devTools.page.onScreencastFrame.listen((event) {
    var frame = image.decodePng(base64.decode(event.data));
    if (frame != null) {
      animation.addFrame(frame);
    }
  });

  // For this example, we change the CSS animations speed.
  await page.devTools.animation.setPlaybackRate(240);

  // Start the screencast
  await page.devTools.page.startScreencast(maxWidth: 150, maxHeight: 150);

  // Wait a few seconds and stop the screencast.
  await Future.delayed(Duration(seconds: 3));
  await page.devTools.page.stopScreencast();

  // Encode all the frames in an animated Gif file.
  File('example/_rubkis_cube.gif')
      .writeAsBytesSync(image.GifEncoder().encodeAnimation(animation)!);

  // Alternatively, we can save all the frames on disk and use ffmpeg to convert
  // it to a video file. (for example: ffmpeg -i frames/%3d.png -r 10 output.mp4)

  await browser.close();
  await server.close(force: true);
}
```

### Launch with visible window
By default, puppeteer launch Chromium in "headless" mode, the browser is invisible.
For better development & debugging, you can force "headful" mode with parameter `headless: false`

```dart
import 'package:puppeteer/puppeteer.dart';

void main() async {
  var browser = await puppeteer.launch(headless: false);
  // Do something...
  await browser.newPage();
  await browser.close();
}
```


### Low-level DevTools protocol
This package contains a fully typed API of the [Chrome DevTools protocol](https://chromedevtools.github.io/devtools-protocol/).
The code is generated from the [JSON Schema](https://github.com/ChromeDevTools/devtools-protocol) provided by Chrome.

With this API you have access to the entire capabilities of Chrome DevTools.

The code is in `lib/protocol`
```dart
import 'package:puppeteer/puppeteer.dart';

void main() async {
  var browser = await puppeteer.launch();
  // Create a chrome's tab
  var page = await browser.newPage();

  // You can access the entire Chrome DevTools protocol.
  // This is useful to access information not exposed by the Puppeteer API
  // Be aware that this is a low-level, complex API.
  // Documentation of the protocol: https://chromedevtools.github.io/devtools-protocol/

  // Examples:

  // Start a screencast
  await page.devTools.page.startScreencast();

  // Change the animation speed for the document
  await page.devTools.animation.setPlaybackRate(10);

  // Access the memory information for the page
  await page.devTools.memory.getDOMCounters();

  // Go to https://chromedevtools.github.io/devtools-protocol/ to read more about
  // the protocol and use the code in `lib/protocol`.

  await browser.close();
}
```

### Execute JavaScript code
The Puppeteer API exposes several functions to run some Javascript code in the browser.

Like in this example from the official Node.JS library:
```js
test(async () => {
  const result = await page.evaluate(x => {
    return Promise.resolve(8 * x);
  }, 7);
});
```

In the Dart port, you have to pass the JavaScript code as a string.
The example above will be written as:
```dart
main() async {
  var result = await page.evaluate('''x => {
    return Promise.resolve(8 * x);
  }''', args: [7]);
}
```

The javascript code can be:
- A function declaration (in the classical form with the `function` keyword
 or with the shorthand format (`() => `))
- An expression. In which case you cannot pass any arguments to the `evaluate` method.

```dart
import 'package:puppeteer/puppeteer.dart';

void main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();

  // function declaration syntax
  await page.evaluate('function(x) { return x > 0; }', args: [7]);

  // shorthand syntax
  await page.evaluate('(x) => x > 0', args: [7]);

  // Multi line shorthand syntax
  await page.evaluate('''(x) => {  
    return x > 0;
  }''', args: [7]);

  // shorthand syntax with async
  await page.evaluate('''async (x) => {
    return await x;
  }''', args: [7]);

  // An expression.
  await page.evaluate('document.body');

  await browser.close();
}
```

If you are using IntellJ (or Webstorm), you can enable the syntax highlighter and the code-analyzer
for the Javascript snippet with a comment like `// language=js` before the string.

```dart
main() {
  page.evaluate(
  //language=js
  '''function _(x) {
    return x > 0;
  }''', args: [7]);
}
```

Note: In a future version, we can imagine writing the code in Dart and it would be compiled to javascript transparently 
 (with ddc or dart2js).

## Limitations with Flutter

This library does 2 things:

1) Download the chromium binaries and launch a Chromium process.
2) Connect to this process with Websocket and send json commands to control the browser.

Due to limitations on mobile platforms (iOS and Android), **it is not possible to launch an external Chromium process on iOS and Android**.
So, step 1) does not work on mobile.

You can still use `puppeteer-dart` on Flutter either with:
- Flutter on Desktop (macOS, windows, Linux)
- Flutter on mobile BUT with the actual Chrome instance running on a server and accessed from the mobile app using puppeteer.connect

> The pub.dev website reports that this library works with Android and iOS. The supported platform list is 
> detected automatically and can't be manually modified to express the current limitations.

## Related work
 * [chrome-remote-interface](https://github.com/cyrus-and/chrome-remote-interface)
 * [puppeteer](https://github.com/GoogleChrome/puppeteer)
 * [webkit_inspection_protocol](https://github.com/google/webkit_inspection_protocol.dart)
 * [dart webdriver](https://github.com/google/webdriver.dart)
