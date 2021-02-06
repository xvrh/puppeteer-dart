import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';

void main() {
  test('Devices should find by name', () {
    expect(puppeteer.devices['iPhone 6'], equals(puppeteer.devices.iPhone6));
    expect(puppeteer.devices['iphone 6'], equals(puppeteer.devices.iPhone6));
    expect(puppeteer.devices['iphone6'], equals(puppeteer.devices.iPhone6));
    expect(puppeteer.devices['  iphone6  '], equals(puppeteer.devices.iPhone6));
    expect(puppeteer.devices['not exist'], isNull);
  });
  test('All devices has viewport', () {
    for (var device in puppeteer.devices) {
      expect(device.name, isNotNull);
      expect(device.viewport, isNotNull);
    }
  });
}
