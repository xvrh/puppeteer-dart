# Puppeteer in Dart

[![Build Status](https://travis-ci.org/xvrh/puppeteer.svg?branch=master)](https://travis-ci.org/xvrh/puppeteer-dart)

A Dart library to automate the Chrome browser over the DevTools Protocol.

This is a port of the [Puppeteer](https://pptr.dev/) Node.JS library in the Dart language.

###### What can I do?

Most things that you can do manually in the browser can be done using Puppeteer! Here are a few examples to get you started:

* Generate screenshots and PDFs of pages.
* Crawl a SPA (Single-Page Application) and generate pre-rendered content (i.e. "SSR" (Server-Side Rendering)).
* Automate form submission, UI testing, keyboard input, etc.
* Create an up-to-date, automated testing environment. Run your tests directly in the latest version of Chrome using the latest JavaScript and browser features.

## Usage
* [Launch chrome](#launch-chrome)
* [Generate a PDF from an HTML page](#generate-a-pdf-from-a-page)
* [Take a screenshot of a page](#take-a-screenshot-of-a-complete-html-page)
* [Take a screenshot of an element in a page](#take-a-screenshot-of-a-specific-node-in-the-page)
* [Create a static version of a Single Page Application](#create-a-static-version-of-a-single-page-application)

### Launch Chrome

Download the last revision of chrome and launch it.
```dart
import 'package:logging/logging.dart';
import 'package:puppeteer/chrome_downloader.dart';
import 'package:puppeteer/puppeteer.dart';

main() async {
  // Setup a logger if you want to see the raw chrome protocol
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);

  // Download a version of Chrome in a cache folder.
  // This is done by default when we don't provide a [executablePath] to
  // [Browser.start]
  var chromePath = (await downloadChrome()).executablePath;

  // You can specify the cache location and a specific version of chrome
  var chromePath2 =
      await downloadChrome(cachePath: '.chrome', revision: 650583);

  // Or just use an absolute path to an existing version of Chrome
  var chromePath3 =
      r'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

  // Start the `Chrome` process and connect to the DevTools
  // By default it is start in `headless` mode
  var chrome = await Browser.start(executablePath: chromePath);

  // Open a new tab
  var myPage = await chrome.newPage();

  // Go to a page and wait to be fully loaded
  await myPage.goto('https://www.github.com', waitUntil: WaitUntil.networkIdle);

  // Do something... See other examples

  // Kill the process
  await chrome.close();
}
```

### Generate a PDF from a page

```dart
import 'dart:io';

import 'package:puppeteer/puppeteer.dart';

main() async {
  // Start the browser and go to a web page
  var browser = await Browser.start();
  var page = await browser.newPage();
  await page.goto('https://www.github.com', waitUntil: WaitUntil.networkIdle);

  // Force the "screen" media or some CSS @media print can change the look
  await page.emulateMedia('screen');

  // Capture the PDF and convert it to a List of bytes.
  var pdf = await page.pdf(
      format: PaperFormat.a4, printBackground: true, pageRanges: '1');

  // Save the bytes in a file
  await File('example/_github.pdf').writeAsBytes(pdf);

  await browser.close();
}
```

### Take a screenshot of a complete HTML page

```dart
import 'dart:io';

import 'package:puppeteer/puppeteer.dart';

main() async {
  // Start the browser and go to a web page
  var browser = await Browser.start();
  var page = await browser.newPage();
  await page.goto('https://www.github.com', waitUntil: WaitUntil.networkIdle);

  // Take a screenshot of the page
  var screenshot = await page.screenshot();

  // Save it to a file
  await File('example/_github_form.png').writeAsBytes(screenshot);

  await browser.close();
}
```

### Take a screenshot of a specific node in the page
```dart
import 'dart:io';

import 'package:puppeteer/puppeteer.dart';

main() async {
  // Start the browser and go to a web page
  var browser = await Browser.start();
  var page = await browser.newPage();
  await page.goto('https://www.github.com', waitUntil: WaitUntil.networkIdle);

  // Select an element on the page
  var form = await page.$('form[action="/join"]');

  // Take a screenshot of the element
  var screenshot = await form.screenshot();

  // Save it to a file
  await File('example/_github_form.png').writeAsBytes(screenshot);

  await browser.close();
}
```

### Create a static version of a Single Page Application
```dart
import 'package:puppeteer/puppeteer.dart';

main() async {
  var browser = await Browser.start();
  var page = await browser.newPage();
  await page.goto('https://www.w3.org');

  // Either use the helper to get the content
  var pageContent = await page.content;
  print(pageContent);

  // Or get the content directly by executing some Javascript
  var pageContent2 = await page.evaluate('document.documentElement.outerHTML');
  print(pageContent2);

  await browser.close();
}
```

### Low-level raw DevTools protocol
This package contains a fully typed API of the [Chrome DevTools protocol](https://chromedevtools.github.io/devtools-protocol/).
The code is generated from the [JSON Schema](https://github.com/ChromeDevTools/devtools-protocol) provided by Chrome.

With this API you have access to the entire capabilities of Chrome DevTools.

You access this API is located in `lib/protocol`
```dart
 // Create a chrome's tab
 var page = chrome.newPage();

 // You access the entire information from ChromeDevTools protocol.
 // This is important to access information not exposed by the Puppeteer API
 // Be aware that this is a low-level, complex API.

 // Example domains

 // Manage network
 page.devTools.network.enable();
 page.devTools.network.onRequest.listen((resquest) {
    // handle
 });

 // Start recording screen-cast
 // Get memory informations
 // Manage the JavaScript debugger
```

You can find more example of using this API in `example/protocol`. The generated code is in `lib/domains`.


## Related work
 * [chrome-remote-interface](https://github.com/cyrus-and/chrome-remote-interface)
 * [puppeteer](https://github.com/GoogleChrome/puppeteer)
 * [webkit_inspection_protocol](https://github.com/google/webkit_inspection_protocol.dart)
 * [dart webdriver](https://github.com/google/webdriver.dart)
