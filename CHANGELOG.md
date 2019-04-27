# Changelog

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
