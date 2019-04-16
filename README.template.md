# chrome_dev_tools

[![Build Status](https://travis-ci.org/xvrh/chrome_dev_tools.svg?branch=master)](https://travis-ci.org/xvrh/chrome_dev_tools)

A Dart library to automate the Chrome browser over the DevTools Protocol.

This package exposes 2 main APIs: the raw DevTools protocol and a high-level Puppeteer-like API.

#### Low-level raw API
The low level API is a simple 1:1 mapping with the [Chrome DevTools protocol](https://chromedevtools.github.io/devtools-protocol/).  
The code is generated from the [JSON Schema](https://github.com/ChromeDevTools/devtools-protocol) provided by Chrome.

This is the API exposed on the `Tab` class. With this API you have the whole power of the ChromeDevTools.
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
This API is built on top of the raw protocol and exposes an easier-to-use API to automate common browser tasks.
This is the API exposed on the `Page` class.

The API is a Dart port of the Node.JS library: [Puppeteer](https://pptr.dev/).

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
