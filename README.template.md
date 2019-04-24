# Puppeteer in Dart

[![Build Status](https://travis-ci.org/xvrh/puppeteer-dart.svg?branch=master)](https://travis-ci.org/xvrh/puppeteer-dart)

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

### Low-level DevTools protocol
This package contains a fully typed API of the [Chrome DevTools protocol](https://chromedevtools.github.io/devtools-protocol/).
The code is generated from the [JSON Schema](https://github.com/ChromeDevTools/devtools-protocol) provided by Chrome.

With this API you have access to the entire capabilities of Chrome DevTools.

The code is in `lib/protocol`
```dart
import 'example/dev_tools_protocol.dart';
```

### Execute JavaScript code
A lot of the Puppeteer API exposes functions to run some javascript code in the browser.

Example in Node.JS:
```js
test(async () => {
  const result = await page.evaluate(x => {
    return Promise.resolve(8 * x);
  }, 7);
});
```

As of now, in the Dart port, you have to pass the JavaScript code as a string.
The example above is written as:
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

If you are using IntellJ (or Webstorm), you can enable syntax highlighting and code-analyzer
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

Note: In a future version, we can image to compile the dart code to javascript on the fly before 
sending it to the browser (with ddc or dart2js). 

## Related work
 * [chrome-remote-interface](https://github.com/cyrus-and/chrome-remote-interface)
 * [puppeteer](https://github.com/GoogleChrome/puppeteer)
 * [webkit_inspection_protocol](https://github.com/google/webkit_inspection_protocol.dart)
 * [dart webdriver](https://github.com/google/webdriver.dart)
