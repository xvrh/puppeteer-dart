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
import 'example/example.dart';
```

### Generate a PDF from a page

```dart
import 'example/print_to_pdf.dart';
```

### Take a screenshot of a complete HTML page

```dart
import 'example/screenshot_page.dart';
```

### Take a screenshot of a specific node in the page
```dart
import 'example/screenshot_element.dart';
```

### Interact with the page and scrap content
```dart
import 'example/search.dart';
```

### Create a static version of a Single Page Application
```dart
import 'example/capture_spa.dart';
```

### Capture a screencast of the page
The screencast feature is not part of the Puppeteer API.
This example uses the low-level protocol API to send the commands to the browser.

```dart
import 'example/screencast.dart';
```

### Launch with visible window
By default, puppeteer launch Chromium in "headless" mode, the browser is invisible.
For better development & debugging, you can force "headful" mode with parameter `headless: false`

```dart
import 'example/headful.dart';
```


### Low-level DevTools protocol
This package contains a fully typed API of the [Chrome DevTools protocol](https://chromedevtools.github.io/devtools-protocol/).
The code is generated from the [JSON Schema](https://github.com/ChromeDevTools/devtools-protocol) provided by Chrome.

With this API you have access to the entire capabilities of Chrome DevTools.

The code is in `lib/protocol`
```dart
import 'example/dev_tools_protocol.dart';
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
import 'example/execute_javascript.dart';
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
