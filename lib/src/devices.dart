import 'dart:collection';
import 'package:collection/collection.dart';
import 'page/emulation_manager.dart' show Device, DeviceViewport;

class Devices with IterableMixin<Device> {
  final blackberryPlayBook = Device(
    'Blackberry PlayBook',
    userAgent:
        'Mozilla/5.0 (PlayBook; U; RIM Tablet OS 2.1.0; en-US) AppleWebKit/536.2+ (KHTML like Gecko) Version/7.2.1.0 Safari/536.2+',
    viewport: DeviceViewport(
      width: 600,
      height: 1024,
      deviceScaleFactor: 1,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final blackberryPlayBookLandscape = Device(
    'Blackberry PlayBook landscape',
    userAgent:
        'Mozilla/5.0 (PlayBook; U; RIM Tablet OS 2.1.0; en-US) AppleWebKit/536.2+ (KHTML like Gecko) Version/7.2.1.0 Safari/536.2+',
    viewport: DeviceViewport(
      width: 1024,
      height: 600,
      deviceScaleFactor: 1,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final blackBerryZ30 = Device(
    'BlackBerry Z30',
    userAgent:
        'Mozilla/5.0 (BB10; Touch) AppleWebKit/537.10+ (KHTML, like Gecko) Version/10.0.9.2372 Mobile Safari/537.10+',
    viewport: DeviceViewport(
      width: 360,
      height: 640,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final blackBerryZ30Landscape = Device(
    'BlackBerry Z30 landscape',
    userAgent:
        'Mozilla/5.0 (BB10; Touch) AppleWebKit/537.10+ (KHTML, like Gecko) Version/10.0.9.2372 Mobile Safari/537.10+',
    viewport: DeviceViewport(
      width: 640,
      height: 360,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final galaxyNote3 = Device(
    'Galaxy Note 3',
    userAgent:
        'Mozilla/5.0 (Linux; U; Android 4.3; en-us; SM-N900T Build/JSS15J) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30',
    viewport: DeviceViewport(
      width: 360,
      height: 640,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final galaxyNote3Landscape = Device(
    'Galaxy Note 3 landscape',
    userAgent:
        'Mozilla/5.0 (Linux; U; Android 4.3; en-us; SM-N900T Build/JSS15J) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30',
    viewport: DeviceViewport(
      width: 640,
      height: 360,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final galaxyNoteII = Device(
    'Galaxy Note II',
    userAgent:
        'Mozilla/5.0 (Linux; U; Android 4.1; en-us; GT-N7100 Build/JRO03C) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30',
    viewport: DeviceViewport(
      width: 360,
      height: 640,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final galaxyNoteIILandscape = Device(
    'Galaxy Note II landscape',
    userAgent:
        'Mozilla/5.0 (Linux; U; Android 4.1; en-us; GT-N7100 Build/JRO03C) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30',
    viewport: DeviceViewport(
      width: 640,
      height: 360,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final galaxySIII = Device(
    'Galaxy S III',
    userAgent:
        'Mozilla/5.0 (Linux; U; Android 4.0; en-us; GT-I9300 Build/IMM76D) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30',
    viewport: DeviceViewport(
      width: 360,
      height: 640,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final galaxySIIILandscape = Device(
    'Galaxy S III landscape',
    userAgent:
        'Mozilla/5.0 (Linux; U; Android 4.0; en-us; GT-I9300 Build/IMM76D) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30',
    viewport: DeviceViewport(
      width: 640,
      height: 360,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final galaxyS5 = Device(
    'Galaxy S5',
    userAgent:
        'Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 360,
      height: 640,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final galaxyS5Landscape = Device(
    'Galaxy S5 landscape',
    userAgent:
        'Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 640,
      height: 360,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final galaxyS8 = Device(
    'Galaxy S8',
    userAgent:
        'Mozilla/5.0 (Linux; Android 7.0; SM-G950U Build/NRD90M) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.84 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 360,
      height: 740,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final galaxyS8Landscape = Device(
    'Galaxy S8 landscape',
    userAgent:
        'Mozilla/5.0 (Linux; Android 7.0; SM-G950U Build/NRD90M) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.84 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 740,
      height: 360,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final galaxyS9 = Device(
    'Galaxy S9+',
    userAgent:
        'Mozilla/5.0 (Linux; Android 8.0.0; SM-G965U Build/R16NW) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.111 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 320,
      height: 658,
      deviceScaleFactor: 4.5,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final galaxyS9Landscape = Device(
    'Galaxy S9+ landscape',
    userAgent:
        'Mozilla/5.0 (Linux; Android 8.0.0; SM-G965U Build/R16NW) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.111 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 658,
      height: 320,
      deviceScaleFactor: 4.5,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final galaxyTabS4 = Device(
    'Galaxy Tab S4',
    userAgent:
        'Mozilla/5.0 (Linux; Android 8.1.0; SM-T837A) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.80 Safari/537.36',
    viewport: DeviceViewport(
      width: 712,
      height: 1138,
      deviceScaleFactor: 2.25,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final galaxyTabS4Landscape = Device(
    'Galaxy Tab S4 landscape',
    userAgent:
        'Mozilla/5.0 (Linux; Android 8.1.0; SM-T837A) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.80 Safari/537.36',
    viewport: DeviceViewport(
      width: 1138,
      height: 712,
      deviceScaleFactor: 2.25,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPad = Device(
    'iPad',
    userAgent:
        'Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1',
    viewport: DeviceViewport(
      width: 768,
      height: 1024,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPadLandscape = Device(
    'iPad landscape',
    userAgent:
        'Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1',
    viewport: DeviceViewport(
      width: 1024,
      height: 768,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPadGen6 = Device(
    'iPad (gen 6)',
    userAgent:
        'Mozilla/5.0 (iPad; CPU OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 768,
      height: 1024,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPadGen6Landscape = Device(
    'iPad (gen 6) landscape',
    userAgent:
        'Mozilla/5.0 (iPad; CPU OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 1024,
      height: 768,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPadGen7 = Device(
    'iPad (gen 7)',
    userAgent:
        'Mozilla/5.0 (iPad; CPU OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 810,
      height: 1080,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPadGen7Landscape = Device(
    'iPad (gen 7) landscape',
    userAgent:
        'Mozilla/5.0 (iPad; CPU OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 1080,
      height: 810,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPadMini = Device(
    'iPad Mini',
    userAgent:
        'Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1',
    viewport: DeviceViewport(
      width: 768,
      height: 1024,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPadMiniLandscape = Device(
    'iPad Mini landscape',
    userAgent:
        'Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1',
    viewport: DeviceViewport(
      width: 1024,
      height: 768,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPadPro = Device(
    'iPad Pro',
    userAgent:
        'Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1',
    viewport: DeviceViewport(
      width: 1024,
      height: 1366,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPadProLandscape = Device(
    'iPad Pro landscape',
    userAgent:
        'Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1',
    viewport: DeviceViewport(
      width: 1366,
      height: 1024,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPadPro11 = Device(
    'iPad Pro 11',
    userAgent:
        'Mozilla/5.0 (iPad; CPU OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 834,
      height: 1194,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPadPro11Landscape = Device(
    'iPad Pro 11 landscape',
    userAgent:
        'Mozilla/5.0 (iPad; CPU OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 1194,
      height: 834,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhone4 = Device(
    'iPhone 4',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_2 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Version/7.0 Mobile/11D257 Safari/9537.53',
    viewport: DeviceViewport(
      width: 320,
      height: 480,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhone4Landscape = Device(
    'iPhone 4 landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_2 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Version/7.0 Mobile/11D257 Safari/9537.53',
    viewport: DeviceViewport(
      width: 480,
      height: 320,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhone5 = Device(
    'iPhone 5',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
    viewport: DeviceViewport(
      width: 320,
      height: 568,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhone5Landscape = Device(
    'iPhone 5 landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
    viewport: DeviceViewport(
      width: 568,
      height: 320,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhone6 = Device(
    'iPhone 6',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1',
    viewport: DeviceViewport(
      width: 375,
      height: 667,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhone6Landscape = Device(
    'iPhone 6 landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1',
    viewport: DeviceViewport(
      width: 667,
      height: 375,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhone6Plus = Device(
    'iPhone 6 Plus',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1',
    viewport: DeviceViewport(
      width: 414,
      height: 736,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhone6PlusLandscape = Device(
    'iPhone 6 Plus landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1',
    viewport: DeviceViewport(
      width: 736,
      height: 414,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhone7 = Device(
    'iPhone 7',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1',
    viewport: DeviceViewport(
      width: 375,
      height: 667,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhone7Landscape = Device(
    'iPhone 7 landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1',
    viewport: DeviceViewport(
      width: 667,
      height: 375,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhone7Plus = Device(
    'iPhone 7 Plus',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1',
    viewport: DeviceViewport(
      width: 414,
      height: 736,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhone7PlusLandscape = Device(
    'iPhone 7 Plus landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1',
    viewport: DeviceViewport(
      width: 736,
      height: 414,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhone8 = Device(
    'iPhone 8',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1',
    viewport: DeviceViewport(
      width: 375,
      height: 667,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhone8Landscape = Device(
    'iPhone 8 landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1',
    viewport: DeviceViewport(
      width: 667,
      height: 375,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhone8Plus = Device(
    'iPhone 8 Plus',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1',
    viewport: DeviceViewport(
      width: 414,
      height: 736,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhone8PlusLandscape = Device(
    'iPhone 8 Plus landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1',
    viewport: DeviceViewport(
      width: 736,
      height: 414,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhoneSE = Device(
    'iPhone SE',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
    viewport: DeviceViewport(
      width: 320,
      height: 568,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhoneSELandscape = Device(
    'iPhone SE landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
    viewport: DeviceViewport(
      width: 568,
      height: 320,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhoneX = Device(
    'iPhone X',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1',
    viewport: DeviceViewport(
      width: 375,
      height: 812,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhoneXLandscape = Device(
    'iPhone X landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1',
    viewport: DeviceViewport(
      width: 812,
      height: 375,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhoneXR = Device(
    'iPhone XR',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 414,
      height: 896,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhoneXRLandscape = Device(
    'iPhone XR landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 896,
      height: 414,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhone11 = Device(
    'iPhone 11',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 13_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 414,
      height: 828,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhone11Landscape = Device(
    'iPhone 11 landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 13_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 828,
      height: 414,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhone11Pro = Device(
    'iPhone 11 Pro',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 13_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 375,
      height: 812,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhone11ProLandscape = Device(
    'iPhone 11 Pro landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 13_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 812,
      height: 375,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhone11ProMax = Device(
    'iPhone 11 Pro Max',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 13_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 414,
      height: 896,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhone11ProMaxLandscape = Device(
    'iPhone 11 Pro Max landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 13_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 896,
      height: 414,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhone12 = Device(
    'iPhone 12',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 14_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 390,
      height: 844,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhone12Landscape = Device(
    'iPhone 12 landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 14_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 844,
      height: 390,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhone12Pro = Device(
    'iPhone 12 Pro',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 14_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 390,
      height: 844,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhone12ProLandscape = Device(
    'iPhone 12 Pro landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 14_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 844,
      height: 390,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhone12ProMax = Device(
    'iPhone 12 Pro Max',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 14_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 428,
      height: 926,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhone12ProMaxLandscape = Device(
    'iPhone 12 Pro Max landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 14_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 926,
      height: 428,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhone12Mini = Device(
    'iPhone 12 Mini',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 14_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 375,
      height: 812,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhone12MiniLandscape = Device(
    'iPhone 12 Mini landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 14_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 812,
      height: 375,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhone13 = Device(
    'iPhone 13',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 390,
      height: 844,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhone13Landscape = Device(
    'iPhone 13 landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 844,
      height: 390,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhone13Pro = Device(
    'iPhone 13 Pro',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 390,
      height: 844,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhone13ProLandscape = Device(
    'iPhone 13 Pro landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 844,
      height: 390,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhone13ProMax = Device(
    'iPhone 13 Pro Max',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 428,
      height: 926,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhone13ProMaxLandscape = Device(
    'iPhone 13 Pro Max landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 926,
      height: 428,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final iPhone13Mini = Device(
    'iPhone 13 Mini',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 375,
      height: 812,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final iPhone13MiniLandscape = Device(
    'iPhone 13 Mini landscape',
    userAgent:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1',
    viewport: DeviceViewport(
      width: 812,
      height: 375,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final jioPhone2 = Device(
    'JioPhone 2',
    userAgent:
        'Mozilla/5.0 (Mobile; LYF/F300B/LYF-F300B-001-01-15-130718-i;Android; rv:48.0) Gecko/48.0 Firefox/48.0 KAIOS/2.5',
    viewport: DeviceViewport(
      width: 240,
      height: 320,
      deviceScaleFactor: 1,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final jioPhone2Landscape = Device(
    'JioPhone 2 landscape',
    userAgent:
        'Mozilla/5.0 (Mobile; LYF/F300B/LYF-F300B-001-01-15-130718-i;Android; rv:48.0) Gecko/48.0 Firefox/48.0 KAIOS/2.5',
    viewport: DeviceViewport(
      width: 320,
      height: 240,
      deviceScaleFactor: 1,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final kindleFireHDX = Device(
    'Kindle Fire HDX',
    userAgent:
        'Mozilla/5.0 (Linux; U; en-us; KFAPWI Build/JDQ39) AppleWebKit/535.19 (KHTML, like Gecko) Silk/3.13 Safari/535.19 Silk-Accelerated=true',
    viewport: DeviceViewport(
      width: 800,
      height: 1280,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final kindleFireHDXLandscape = Device(
    'Kindle Fire HDX landscape',
    userAgent:
        'Mozilla/5.0 (Linux; U; en-us; KFAPWI Build/JDQ39) AppleWebKit/535.19 (KHTML, like Gecko) Silk/3.13 Safari/535.19 Silk-Accelerated=true',
    viewport: DeviceViewport(
      width: 1280,
      height: 800,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final lGOptimusL70 = Device(
    'LG Optimus L70',
    userAgent:
        'Mozilla/5.0 (Linux; U; Android 4.4.2; en-us; LGMS323 Build/KOT49I.MS32310c) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/75.0.3765.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 384,
      height: 640,
      deviceScaleFactor: 1.25,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final lGOptimusL70Landscape = Device(
    'LG Optimus L70 landscape',
    userAgent:
        'Mozilla/5.0 (Linux; U; Android 4.4.2; en-us; LGMS323 Build/KOT49I.MS32310c) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/75.0.3765.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 640,
      height: 384,
      deviceScaleFactor: 1.25,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final microsoftLumia550 = Device(
    'Microsoft Lumia 550',
    userAgent:
        'Mozilla/5.0 (Windows Phone 10.0; Android 4.2.1; Microsoft; Lumia 550) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Mobile Safari/537.36 Edge/14.14263',
    viewport: DeviceViewport(
      width: 640,
      height: 360,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final microsoftLumia950 = Device(
    'Microsoft Lumia 950',
    userAgent:
        'Mozilla/5.0 (Windows Phone 10.0; Android 4.2.1; Microsoft; Lumia 950) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Mobile Safari/537.36 Edge/14.14263',
    viewport: DeviceViewport(
      width: 360,
      height: 640,
      deviceScaleFactor: 4,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final microsoftLumia950Landscape = Device(
    'Microsoft Lumia 950 landscape',
    userAgent:
        'Mozilla/5.0 (Windows Phone 10.0; Android 4.2.1; Microsoft; Lumia 950) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Mobile Safari/537.36 Edge/14.14263',
    viewport: DeviceViewport(
      width: 640,
      height: 360,
      deviceScaleFactor: 4,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final nexus10 = Device(
    'Nexus 10',
    userAgent:
        'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 10 Build/MOB31T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Safari/537.36',
    viewport: DeviceViewport(
      width: 800,
      height: 1280,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final nexus10Landscape = Device(
    'Nexus 10 landscape',
    userAgent:
        'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 10 Build/MOB31T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Safari/537.36',
    viewport: DeviceViewport(
      width: 1280,
      height: 800,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final nexus4 = Device(
    'Nexus 4',
    userAgent:
        'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 384,
      height: 640,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final nexus4Landscape = Device(
    'Nexus 4 landscape',
    userAgent:
        'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 640,
      height: 384,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final nexus5 = Device(
    'Nexus 5',
    userAgent:
        'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 360,
      height: 640,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final nexus5Landscape = Device(
    'Nexus 5 landscape',
    userAgent:
        'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 640,
      height: 360,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final nexus5X = Device(
    'Nexus 5X',
    userAgent:
        'Mozilla/5.0 (Linux; Android 8.0.0; Nexus 5X Build/OPR4.170623.006) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 412,
      height: 732,
      deviceScaleFactor: 2.625,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final nexus5XLandscape = Device(
    'Nexus 5X landscape',
    userAgent:
        'Mozilla/5.0 (Linux; Android 8.0.0; Nexus 5X Build/OPR4.170623.006) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 732,
      height: 412,
      deviceScaleFactor: 2.625,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final nexus6 = Device(
    'Nexus 6',
    userAgent:
        'Mozilla/5.0 (Linux; Android 7.1.1; Nexus 6 Build/N6F26U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 412,
      height: 732,
      deviceScaleFactor: 3.5,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final nexus6Landscape = Device(
    'Nexus 6 landscape',
    userAgent:
        'Mozilla/5.0 (Linux; Android 7.1.1; Nexus 6 Build/N6F26U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 732,
      height: 412,
      deviceScaleFactor: 3.5,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final nexus6P = Device(
    'Nexus 6P',
    userAgent:
        'Mozilla/5.0 (Linux; Android 8.0.0; Nexus 6P Build/OPP3.170518.006) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 412,
      height: 732,
      deviceScaleFactor: 3.5,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final nexus6PLandscape = Device(
    'Nexus 6P landscape',
    userAgent:
        'Mozilla/5.0 (Linux; Android 8.0.0; Nexus 6P Build/OPP3.170518.006) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 732,
      height: 412,
      deviceScaleFactor: 3.5,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final nexus7 = Device(
    'Nexus 7',
    userAgent:
        'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 7 Build/MOB30X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Safari/537.36',
    viewport: DeviceViewport(
      width: 600,
      height: 960,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final nexus7Landscape = Device(
    'Nexus 7 landscape',
    userAgent:
        'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 7 Build/MOB30X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Safari/537.36',
    viewport: DeviceViewport(
      width: 960,
      height: 600,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final nokiaLumia520 = Device(
    'Nokia Lumia 520',
    userAgent:
        'Mozilla/5.0 (compatible; MSIE 10.0; Windows Phone 8.0; Trident/6.0; IEMobile/10.0; ARM; Touch; NOKIA; Lumia 520)',
    viewport: DeviceViewport(
      width: 320,
      height: 533,
      deviceScaleFactor: 1.5,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final nokiaLumia520Landscape = Device(
    'Nokia Lumia 520 landscape',
    userAgent:
        'Mozilla/5.0 (compatible; MSIE 10.0; Windows Phone 8.0; Trident/6.0; IEMobile/10.0; ARM; Touch; NOKIA; Lumia 520)',
    viewport: DeviceViewport(
      width: 533,
      height: 320,
      deviceScaleFactor: 1.5,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final nokiaN9 = Device(
    'Nokia N9',
    userAgent:
        'Mozilla/5.0 (MeeGo; NokiaN9) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13',
    viewport: DeviceViewport(
      width: 480,
      height: 854,
      deviceScaleFactor: 1,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final nokiaN9Landscape = Device(
    'Nokia N9 landscape',
    userAgent:
        'Mozilla/5.0 (MeeGo; NokiaN9) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13',
    viewport: DeviceViewport(
      width: 854,
      height: 480,
      deviceScaleFactor: 1,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final pixel2 = Device(
    'Pixel 2',
    userAgent:
        'Mozilla/5.0 (Linux; Android 8.0; Pixel 2 Build/OPD3.170816.012) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 411,
      height: 731,
      deviceScaleFactor: 2.625,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final pixel2Landscape = Device(
    'Pixel 2 landscape',
    userAgent:
        'Mozilla/5.0 (Linux; Android 8.0; Pixel 2 Build/OPD3.170816.012) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 731,
      height: 411,
      deviceScaleFactor: 2.625,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final pixel2XL = Device(
    'Pixel 2 XL',
    userAgent:
        'Mozilla/5.0 (Linux; Android 8.0.0; Pixel 2 XL Build/OPD1.170816.004) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 411,
      height: 823,
      deviceScaleFactor: 3.5,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final pixel2XLLandscape = Device(
    'Pixel 2 XL landscape',
    userAgent:
        'Mozilla/5.0 (Linux; Android 8.0.0; Pixel 2 XL Build/OPD1.170816.004) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3765.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 823,
      height: 411,
      deviceScaleFactor: 3.5,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final pixel3 = Device(
    'Pixel 3',
    userAgent:
        'Mozilla/5.0 (Linux; Android 9; Pixel 3 Build/PQ1A.181105.017.A1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.158 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 393,
      height: 786,
      deviceScaleFactor: 2.75,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final pixel3Landscape = Device(
    'Pixel 3 landscape',
    userAgent:
        'Mozilla/5.0 (Linux; Android 9; Pixel 3 Build/PQ1A.181105.017.A1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.158 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 786,
      height: 393,
      deviceScaleFactor: 2.75,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final pixel4 = Device(
    'Pixel 4',
    userAgent:
        'Mozilla/5.0 (Linux; Android 10; Pixel 4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 353,
      height: 745,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final pixel4Landscape = Device(
    'Pixel 4 landscape',
    userAgent:
        'Mozilla/5.0 (Linux; Android 10; Pixel 4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 745,
      height: 353,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final pixel4a5G = Device(
    'Pixel 4a (5G)',
    userAgent:
        'Mozilla/5.0 (Linux; Android 11; Pixel 4a (5G)) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4812.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 353,
      height: 745,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final pixel4a5GLandscape = Device(
    'Pixel 4a (5G) landscape',
    userAgent:
        'Mozilla/5.0 (Linux; Android 11; Pixel 4a (5G)) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4812.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 745,
      height: 353,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final pixel5 = Device(
    'Pixel 5',
    userAgent:
        'Mozilla/5.0 (Linux; Android 11; Pixel 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4812.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 393,
      height: 851,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final pixel5Landscape = Device(
    'Pixel 5 landscape',
    userAgent:
        'Mozilla/5.0 (Linux; Android 11; Pixel 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4812.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 851,
      height: 393,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  final motoG4 = Device(
    'Moto G4',
    userAgent:
        'Mozilla/5.0 (Linux; Android 7.0; Moto G (4)) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4812.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 360,
      height: 640,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: false,
    ),
  );

  final motoG4Landscape = Device(
    'Moto G4 landscape',
    userAgent:
        'Mozilla/5.0 (Linux; Android 7.0; Moto G (4)) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4812.0 Mobile Safari/537.36',
    viewport: DeviceViewport(
      width: 640,
      height: 360,
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true,
      isLandscape: true,
    ),
  );

  late final Map<String, Device> _all;
  Devices._() {
    _all = CanonicalizedMap<String, String, Device>.from({
      'Blackberry PlayBook': blackberryPlayBook,
      'Blackberry PlayBook landscape': blackberryPlayBookLandscape,
      'BlackBerry Z30': blackBerryZ30,
      'BlackBerry Z30 landscape': blackBerryZ30Landscape,
      'Galaxy Note 3': galaxyNote3,
      'Galaxy Note 3 landscape': galaxyNote3Landscape,
      'Galaxy Note II': galaxyNoteII,
      'Galaxy Note II landscape': galaxyNoteIILandscape,
      'Galaxy S III': galaxySIII,
      'Galaxy S III landscape': galaxySIIILandscape,
      'Galaxy S5': galaxyS5,
      'Galaxy S5 landscape': galaxyS5Landscape,
      'Galaxy S8': galaxyS8,
      'Galaxy S8 landscape': galaxyS8Landscape,
      'Galaxy S9+': galaxyS9,
      'Galaxy S9+ landscape': galaxyS9Landscape,
      'Galaxy Tab S4': galaxyTabS4,
      'Galaxy Tab S4 landscape': galaxyTabS4Landscape,
      'iPad': iPad,
      'iPad landscape': iPadLandscape,
      'iPad (gen 6)': iPadGen6,
      'iPad (gen 6) landscape': iPadGen6Landscape,
      'iPad (gen 7)': iPadGen7,
      'iPad (gen 7) landscape': iPadGen7Landscape,
      'iPad Mini': iPadMini,
      'iPad Mini landscape': iPadMiniLandscape,
      'iPad Pro': iPadPro,
      'iPad Pro landscape': iPadProLandscape,
      'iPad Pro 11': iPadPro11,
      'iPad Pro 11 landscape': iPadPro11Landscape,
      'iPhone 4': iPhone4,
      'iPhone 4 landscape': iPhone4Landscape,
      'iPhone 5': iPhone5,
      'iPhone 5 landscape': iPhone5Landscape,
      'iPhone 6': iPhone6,
      'iPhone 6 landscape': iPhone6Landscape,
      'iPhone 6 Plus': iPhone6Plus,
      'iPhone 6 Plus landscape': iPhone6PlusLandscape,
      'iPhone 7': iPhone7,
      'iPhone 7 landscape': iPhone7Landscape,
      'iPhone 7 Plus': iPhone7Plus,
      'iPhone 7 Plus landscape': iPhone7PlusLandscape,
      'iPhone 8': iPhone8,
      'iPhone 8 landscape': iPhone8Landscape,
      'iPhone 8 Plus': iPhone8Plus,
      'iPhone 8 Plus landscape': iPhone8PlusLandscape,
      'iPhone SE': iPhoneSE,
      'iPhone SE landscape': iPhoneSELandscape,
      'iPhone X': iPhoneX,
      'iPhone X landscape': iPhoneXLandscape,
      'iPhone XR': iPhoneXR,
      'iPhone XR landscape': iPhoneXRLandscape,
      'iPhone 11': iPhone11,
      'iPhone 11 landscape': iPhone11Landscape,
      'iPhone 11 Pro': iPhone11Pro,
      'iPhone 11 Pro landscape': iPhone11ProLandscape,
      'iPhone 11 Pro Max': iPhone11ProMax,
      'iPhone 11 Pro Max landscape': iPhone11ProMaxLandscape,
      'iPhone 12': iPhone12,
      'iPhone 12 landscape': iPhone12Landscape,
      'iPhone 12 Pro': iPhone12Pro,
      'iPhone 12 Pro landscape': iPhone12ProLandscape,
      'iPhone 12 Pro Max': iPhone12ProMax,
      'iPhone 12 Pro Max landscape': iPhone12ProMaxLandscape,
      'iPhone 12 Mini': iPhone12Mini,
      'iPhone 12 Mini landscape': iPhone12MiniLandscape,
      'iPhone 13': iPhone13,
      'iPhone 13 landscape': iPhone13Landscape,
      'iPhone 13 Pro': iPhone13Pro,
      'iPhone 13 Pro landscape': iPhone13ProLandscape,
      'iPhone 13 Pro Max': iPhone13ProMax,
      'iPhone 13 Pro Max landscape': iPhone13ProMaxLandscape,
      'iPhone 13 Mini': iPhone13Mini,
      'iPhone 13 Mini landscape': iPhone13MiniLandscape,
      'JioPhone 2': jioPhone2,
      'JioPhone 2 landscape': jioPhone2Landscape,
      'Kindle Fire HDX': kindleFireHDX,
      'Kindle Fire HDX landscape': kindleFireHDXLandscape,
      'LG Optimus L70': lGOptimusL70,
      'LG Optimus L70 landscape': lGOptimusL70Landscape,
      'Microsoft Lumia 550': microsoftLumia550,
      'Microsoft Lumia 950': microsoftLumia950,
      'Microsoft Lumia 950 landscape': microsoftLumia950Landscape,
      'Nexus 10': nexus10,
      'Nexus 10 landscape': nexus10Landscape,
      'Nexus 4': nexus4,
      'Nexus 4 landscape': nexus4Landscape,
      'Nexus 5': nexus5,
      'Nexus 5 landscape': nexus5Landscape,
      'Nexus 5X': nexus5X,
      'Nexus 5X landscape': nexus5XLandscape,
      'Nexus 6': nexus6,
      'Nexus 6 landscape': nexus6Landscape,
      'Nexus 6P': nexus6P,
      'Nexus 6P landscape': nexus6PLandscape,
      'Nexus 7': nexus7,
      'Nexus 7 landscape': nexus7Landscape,
      'Nokia Lumia 520': nokiaLumia520,
      'Nokia Lumia 520 landscape': nokiaLumia520Landscape,
      'Nokia N9': nokiaN9,
      'Nokia N9 landscape': nokiaN9Landscape,
      'Pixel 2': pixel2,
      'Pixel 2 landscape': pixel2Landscape,
      'Pixel 2 XL': pixel2XL,
      'Pixel 2 XL landscape': pixel2XLLandscape,
      'Pixel 3': pixel3,
      'Pixel 3 landscape': pixel3Landscape,
      'Pixel 4': pixel4,
      'Pixel 4 landscape': pixel4Landscape,
      'Pixel 4a (5G)': pixel4a5G,
      'Pixel 4a (5G) landscape': pixel4a5GLandscape,
      'Pixel 5': pixel5,
      'Pixel 5 landscape': pixel5Landscape,
      'Moto G4': motoG4,
      'Moto G4 landscape': motoG4Landscape,
    }, (key) => key.replaceAll(' ', '').toLowerCase());
  }

  Device? operator [](String name) => _all[name];

  @override
  Iterator<Device> get iterator => _all.values.iterator;
}

final devices = Devices._();
