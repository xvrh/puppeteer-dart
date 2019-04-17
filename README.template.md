# chrome_dev_tools

[![Build Status](https://travis-ci.org/xvrh/chrome_dev_tools.svg?branch=master)](https://travis-ci.org/xvrh/chrome_dev_tools)

A Dart library to automate the Chrome browser over the DevTools Protocol.

This package exposes 2 main APIs: the raw DevTools protocol and a high-level Puppeteer-like API.

#### Low-level raw API
The low-level API is a simple one-to-one mapping with the [Chrome DevTools protocol](https://chromedevtools.github.io/devtools-protocol/).  
The code is generated from the [JSON Schema](https://github.com/ChromeDevTools/devtools-protocol) provided by Chrome.

With this API you have entire control to automate Chrome in a fully typed environment.
However this API can be a bit hard to use and require to write some helper functions for common tasks.

You access this API through the `Tab` class. 
```dart
 // Create a chrome's tab
 var tab = chrome.newTab();
 // You can access the entire information from ChromeDevTools protocol
 // This is a low level/complex API
 
 // Manage network
 tab.network.enable();
 tab.network.onRequest.listen((resquest) {
   
 });
 
 // Start recording screen-cast
 // Get memory informations
 // Manage the JavaScript debugger
```

You can find more example of using this API in `example/protocol`. The generated code is in `lib/domains`.

#### High-level API
This API is built on top of the raw protocol and exposes an easy-to-use API.
This is the API exposed on the `Page` class.

The API is a Dart port of the Node.JS library: [Puppeteer](https://pptr.dev/).

```dart
- go to page
- type in element
- click button
- capture screenshot
- save pdf
- go back
```

You can find more example of using this API in the `example` folder.

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
Or more simply
```dart
import 'example/capture_spa_with_javascript.dart';
```

## Related work
 * [chrome-remote-interface](https://github.com/cyrus-and/chrome-remote-interface)
 * [puppeteer](https://github.com/GoogleChrome/puppeteer)
 * [webkit_inspection_protocol](https://github.com/google/webkit_inspection_protocol.dart)
 * [dart webdriver](https://github.com/google/webdriver.dart)
