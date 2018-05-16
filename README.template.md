# chrome_dev_tools

[![Build Status](https://travis-ci.org/xavierhainaux/chrome_dev_tools.svg?branch=master)](https://travis-ci.org/xavierhainaux/chrome_dev_tools)

A Dart library to automate the Chrome browser over the DevTools Protocol.

This is a simple 1:1 mapping with the [Chrome DevTools protocol](https://chromedevtools.github.io/devtools-protocol/).  
All the code in `lib/domains` are generated from the [browser_protocol.json]() and [js_protocol.json]().


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