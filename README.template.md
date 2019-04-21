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

### Create a static version of a Single Page Application
```dart
import 'example/capture_spa.dart';
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
