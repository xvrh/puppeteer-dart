## 3.19.0
- Update to Chrome 138.0.7204.94.

## 3.18.0
- Update to Chrome 135.0.7049.95.

## 3.17.0
- Update to Chrome 133.0.6943.53.

## 3.16.0
- Update to Chrome 131.0.6778.204

## 3.15.0
- Update to Chrome 129.0.6668.58
- Change close code for websocket in web to 1000

## 3.14.0
- Update to Chrome 128.0.6613.137

## 3.13.0
- Update to Chrome 127.0.6533.119

## 3.12.0
- Update to Chrome 126.0.6478.126

## 3.11.0
- Update to Chrome 125.0.6422.60
- Fix navigation error

## 3.10.0
- Update to Chrome 124.0.6367.201
- Small bug fix

## 3.9.0
- Update to Chrome 123.0.6312.122

## 3.8.0
- Update to Chrome 122.0.6261.69

## 3.7.0
- Update to Chrome 121.0.6167.184
- Requires Dart 3.3.0

## 3.6.0
- Update to Chrome 119.0.6045.105
- Fix new lints from package:lints v3.0.0

## 3.5.0
- Update to Chrome 118.0.5993.70

## 3.4.1
- Update to Chrome 117.0.5938.92

## 3.4.0
- Update to Chrome 117

## 3.3.0
- Update to Chrome 116
- Require Dart 3.1.0

## 3.2.0
- Update to Chrome 115

## 3.1.1
- Update to Chrome 114.0.5735.133
- Widen constraint on dependency `package:http`

## 3.1.0
- Update to Chrome 114
- Fix a bug on Windows when a relative directory was passed to `userDataDir`

## 3.0.0
- Download "Chrome for Testing" instead of Chromium.
- Update to Chrome 113
- Cache the browser binaries by default in `.local-chrome` instead of `.local-chromium`
- Replace `int revision` parameter with `String version` in `downloadChrome`
- Require minimum Dart `3.0.0` version.

## 2.24.0
- Update to Chromium 112

## 2.23.0
- Update to Chromium 111
- Check for null child node/Ids in Accessibility

## 2.22.0
- Add additional screenshot parameters
- Add `onDownloadProgress` callback on `downloadChrome` function

## 2.21.0
- Update to Chromium 110

## 2.20.0
- Fixed a bug: `page.waitForSelector('#selector', timeout: Duration.zero)` throws instantly instead of disabling timeout #210.
- Internal refactor of target management to use auto discover feature of Chromium.

## 2.19.0
- Update to Chromium 109
- Adds a setter for the TargetInfo type

## 2.18.0
- Expose `Worker` class
- Update the default arguments used to launch the chromium process

## 2.17.0
- Update to Chromium 108

## 2.16.0
- Upgrade `package:petitparser` to version 5.1.0
- Fix some lint rules

## 2.15.0
- Allow `puppeteer.connect` to be called on the Web platform (Dart code compiled to JavaScript).

## 2.14.0
- Update to Chromium 107

## 2.13.0
- Fix a bug during request interception. In `NetworkManager.continueRequest` original headers were discarded.

## 2.12.0
- Update to Chromium 105

## 2.11.0
- Update to Chromium 104

## 2.10.0
- Update to Chromium 103
- Use dart enhanced `enums` for all enumerations in the protocol 

## 2.9.0
- Update to Chromium 102

## 2.8.0
- Update to Chromium 101

## 2.7.0
- Update to Chromium 100
- Resolving browser paths in windows

## 2.6.0
- Update to Chromium 99

## 2.5.0
- Add `BrowserPath` to have access to installed browser executable path.
```dart
var browser = await puppeteer.launch(executablePath: BrowserPath.chromeCanary);
```

- Fix bug to make current version work with chrome stable 96

## 2.4.0
- Update Chromium to version 97

## 2.3.0
- Update Chromium to version 93

## 2.2.1
- Make `defaultViewport` nullable in the `connect` method.

## 2.2.0
- Update Chromium to version 92
- Add drag-and-drop support

## 2.1.0
- Update Chromium to version 91

## 2.0.0
- Migrate to null-safety
- Update Chromium to version 90

## 1.22.0
- Update Chromium to version 87

## 1.21.0
- Update Chromium to version 87

## 1.20.1
- Fix `Browser.close()` error

## 1.20.0
- Update Chromium to version 86

## 1.19.0
- Update Chromium to version 85

## 1.18.0
- Update Chromium to version 84
- Add `Mouse.wheel`

## 1.17.0
- Update Chromium to version 81
- Revert change to `uploadFile` implementation.

## 1.16.1
- Fix a bug with the new `uploadFile` implementation.

## 1.16.0
- Update to chromium 722234

## 1.15.1
- Expose `ClientError` class
- (internal) Revert previous change in `jsHandle.uploadFile`

## 1.15.0
- Add element.select and element.evaluate for consistency
- Prepare jsHandle.uploadFile for CDP Page.handleFileChooser removal

## 1.14.1
- Export class `Target` in `puppeteer.dart`

## 1.14.0
- Update Chrome to version 79
- Add `Page.emulateTimezone` and `Page.emulateMediaFeatures`
- Deprecate `Page.emulateMedia` in profit of `Page.emulatedMediaType`
- Fix a "Concurrent modification error" when navigating from a page with iframes.

## 1.13.0
- Fix a NullPointerException in NetworkManager
- (internal) Add more tests for headful mode
- (internal) Remove all implicit casts (preparation for nnbd)

## 1.12.0
- Fix bug in `puppeteer.connect()`
- Add the same capabilities that pupeeteer Node.JS to `puppeteer.launch` for the management of the flags passed to Chromium.
- Add `userDataDir` to `puppeteer.launch` to allow managing the user data directory.
  By default, we now use a temporary data directory in the system temp folder.
- Add more tests for launching and connecting to chromium

## 1.11.0
- Update Chromium version to 686378

## 1.10.0
- Introduce file chooser interception
- Update Chromium version to 674921

## 1.9.0
- Update Chromium version to 672088
- Update dependencies
- Fixes for Dart 2.4.0

## 1.8.0+1
- Fix regression in `page.tracing`

## 1.8.0
- Update Chromium version to 669486
- Add an `IOSink` [output] parameter to [Page.pdf] as an alternative to returning the whole PDF bytes in memory.

## 1.7.3
- Update Chromium version to 666595
- Remove --disable-gpu flag passed to Chromium on Windows

## 1.7.2
- Update Chromium version to 662092

## 1.7.1
- Enable more Dart lints

## 1.7.0
- Add `page.ccessibility` feature
- Update default Chromium version to 662092

## 1.6.0
- Add `puppeteer.connect` to connect to an existing Chromium instance
- Add `slowMo` parameter for `puppeteer.launch` et `puppeteer.connect` to slow down communications with the browser.
- Create `Worker` from service_worker and shared_worker.
- Use a default viewport of 1280x1024 by default (allow to pass null to disable the default).
- Add a small "plugin" system
- Add the `StealthPlugin` to automatically applies various techniques to make detection of headless puppeteer harder.
- Add `Page.clickAndWaitForNavigation` for convenience.
- Add `Page.coverage` feature
- Add `Page.metrics` feature
- Add `Page.tracing` feature

## 1.5.0
- Rename classes `Frame`, `Request` & `Response` to match the puppeteer API
- Add Worker class
- Add more test for the network API

## 1.4.0
- Add more unit tests and more documentation
- Fix bugs in request interception

## 1.3.0
- Add more unit tests and more documentation
- Update default chromium
- Add example for screencast
- Fix bugs

## 1.2.1

- Add some documentation and examples in the source code (still work in
progress: not all classes are documented yet).

## 1.2.0

- Start a browser with `puppeteer.launch` instead of
`Browser.start` to align with the puppeteer API
- Add a list of all the devices from chrome:
Accessible with: `page.emulate(puppeteer.devices.iPhone6)`
- Add tests

## 1.1.0

- Add some unit tests from the Puppeteer/Node.JS project and fix some bugs.

## 1.0.0

- Initial port of Puppeteer in Dart
