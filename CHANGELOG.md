# Changelog

# 1.12.0 (2019-08-28)
- Fix bug in `puppeteer.connect()`
- Add the same capabilities that pupeeteer Node.JS to `puppeteer.launch` for the management of the flags passed to Chromium.
- Add `userDataDir` to `puppeteer.launch` to allow managing the user data directory.
  By default, we now use a temporary data directory in the system temp folder.
- Add more tests for launching and connecting to chromium

# 1.11.0 (2019-08-15)
- Update Chromium version to 686378

# 1.10.0 (2019-07-26)
- Introduce file chooser interception
- Update Chromium version to 674921

# 1.9.0 (2019-06-30)
- Update Chromium version to 672088
- Update dependencies
- Fixes for Dart 2.4.0

## 1.8.0+1 (2019-06-22)
- Fix regression in `page.tracing`

## 1.8.0 (2019-06-22)
- Update Chromium version to 669486
- Add an `IOSink` [output] parameter to [Page.pdf] as an alternative to returning the whole PDF bytes in memory.

## 1.7.3 (2019-06-06)
- Update Chromium version to 666595
- Remove --disable-gpu flag passed to Chromium on Windows

## 1.7.2 (2019-06-05)
- Update Chromium version to 662092

## 1.7.1 (2019-05-27)
- Enable more Dart lints

## 1.7.0 (2019-05-27)
- Add `page.ccessibility` feature
- Update default Chromium version to 662092

## 1.6.0 (2019-05-15)
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

## 1.5.0 (2019-05-07)
- Rename classes `Frame`, `Request` & `Response` to match the puppeteer API
- Add Worker class
- Add more test for the network API

## 1.4.0 (2019-05-04)
- Add more unit tests and more documentation
- Fix bugs in request interception

## 1.3.0 (2019-05-02)
- Add more unit tests and more documentation
- Update default chromium
- Add example for screencast
- Fix bugs

## 1.2.1 (2019-04-27)

- Add some documentation and examples in the source code (still work in
progress: not all classes are documented yet).

## 1.2.0 (2019-04-24)

- Start a browser with `puppeteer.launch` instead of
`Browser.start` to align with the puppeteer API
- Add a list of all the devices from chrome:
Accessible with: `page.emulate(puppeteer.devices.iPhone6)`
- Add tests

## 1.1.0 (2019-04-22)

- Add some unit tests from the Puppeteer/Node.JS project and fix some bugs.

## 1.0.0 (2019-04-21)

- Initial port of Puppeteer in Dart
