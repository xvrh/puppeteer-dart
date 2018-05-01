# chrome_dev_tools

[![Build Status](https://travis-ci.org/xavierhainaux/chrome_dev_tools.svg?branch=master)](https://travis-ci.org/xavierhainaux/chrome_dev_tools)

A Dart library to control Chrome over the DevTools Protocol.

This is a simple 1:1 mapping with the [Chrome DevTools protocol](https://chromedevtools.github.io/devtools-protocol/).  
All the code in `lib/domains` are generated from the [browser_protocol.json](https://chromium.googlesource.com/chromium/src/+/master/third_party/blink/renderer/core/inspector/browser_protocol-1.3.json) and [js_protocol.json](https://chromium.googlesource.com/v8/v8/+/master/src/inspector/js_protocol.json).


## Usage
- [Launch chrome](#launch)  
- [Generate a PDF from an HTML page](#pdf)  
- [Take a screenshot of a page](#screenshot_page)  
- [Take a screenshot of an element in a page](#screenshot_element)  
- [Create a static version of a Single Page Application](#spa)  

<a name="launch"></a>
### Launch Chrome

Download the last revision of chrome and launch it.
```dart
import 'example/example.dart';
```

<a name="pdf"></a>
### Generate a PDF from a page

```dart
import 'example/print_to_pdf.dart';
```

<a name="screenshot"></a>
### Take a screenshot

<a name="screenshot_page"></a>
Screenshot the complete HTML page
```dart
import 'example/screenshot_page.dart';
```

<a name="screenshot_element"></a>
Screenshot a specific node in the page
```dart
import 'example/screenshot_element.dart';
```

<a name="spa"></a>
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