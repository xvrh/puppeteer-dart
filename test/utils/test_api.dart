// copy from https://github.com/dart-lang/test/blob/master/pkgs/test_api/lib/test_api.dart

import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';

void testFailsFirefox(description, dynamic Function() body,
    {String testOn,
    Timeout timeout,
    skip,
    tags,
    Map<String, dynamic> onPlatform,
    int retry}) {
  test(description.toString(), body,
      testOn: testOn,
      timeout: timeout,
      skip: isPuppeteerFirefox ? true : skip,
      onPlatform: onPlatform,
      tags: tags,
      retry: retry);
}

// tests which original puppeteer doesn't skip.
void testFailsFirefoxFIXME(description, dynamic Function() body,
    {String testOn,
    Timeout timeout,
    skip,
    tags,
    Map<String, dynamic> onPlatform,
    int retry}) {
  test(description.toString(), body,
      testOn: testOn,
      timeout: timeout,
      skip: isPuppeteerFirefox ? true : skip,
      onPlatform: onPlatform,
      tags: tags,
      retry: retry);
}

void groupFailsFirefox(description, dynamic Function() body,
    {String testOn,
    Timeout timeout,
    skip,
    tags,
    Map<String, dynamic> onPlatform,
    int retry}) {
  group(description.toString(), body,
      testOn: testOn,
      timeout: timeout,
      skip: isPuppeteerFirefox ? true : skip,
      tags: tags,
      onPlatform: onPlatform,
      retry: retry);
}

void groupChromeOnly(description, dynamic Function() body,
    {String testOn,
    Timeout timeout,
    skip,
    tags,
    Map<String, dynamic> onPlatform,
    int retry}) {
  group(description.toString(), body,
      testOn: testOn,
      timeout: timeout,
      skip: isPuppeteerFirefox ? true : skip,
      tags: tags,
      onPlatform: onPlatform,
      retry: retry);
}
