import 'dart:collection';
import 'package:collection/collection.dart';
import 'page/emulation_manager.dart' show Device, DeviceViewport;

class Devices with IterableMixin<Device> {
  final iPhone4 = Device('iPhone 4',
      userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_2 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Version/7.0 Mobile/11D257 Safari/9537.53',
      viewport: DeviceViewport(
          width: 320,
          height: 480,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final iPhone4Landscape = Device('iPhone 4',
      userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_2 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Version/7.0 Mobile/11D257 Safari/9537.53',
      viewport: DeviceViewport(
          width: 480,
          height: 320,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final iPhone5 = Device('iPhone 5',
      userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
      viewport: DeviceViewport(
          width: 320,
          height: 568,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final iPhone5Landscape = Device('iPhone 5',
      userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
      viewport: DeviceViewport(
          width: 568,
          height: 320,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final iPhoneSE = Device('iPhone SE',
      userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
      viewport: DeviceViewport(
          width: 320,
          height: 568,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final iPhoneSELandscape = Device('iPhone SE',
      userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
      viewport: DeviceViewport(
          width: 568,
          height: 320,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final iPhone6 = Device('iPhone 6',
      userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1',
      viewport: DeviceViewport(
          width: 375,
          height: 667,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final iPhone6Landscape = Device('iPhone 6',
      userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1',
      viewport: DeviceViewport(
          width: 667,
          height: 375,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final iPhone7 = Device('iPhone 7',
      userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1',
      viewport: DeviceViewport(
          width: 375,
          height: 667,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final iPhone7Landscape = Device('iPhone 7',
      userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1',
      viewport: DeviceViewport(
          width: 667,
          height: 375,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final iPhone8 = Device('iPhone 8',
      userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1',
      viewport: DeviceViewport(
          width: 375,
          height: 667,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final iPhone8Landscape = Device('iPhone 8',
      userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1',
      viewport: DeviceViewport(
          width: 667,
          height: 375,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final iPhone678Plus = Device('iPhone 6/7/8 Plus',
      userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1',
      viewport: DeviceViewport(
          width: 414,
          height: 736,
          deviceScaleFactor: 3,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final iPhone678PlusLandscape = Device('iPhone 6/7/8 Plus',
      userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1',
      viewport: DeviceViewport(
          width: 736,
          height: 414,
          deviceScaleFactor: 3,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final iPhoneX = Device('iPhone X',
      userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1',
      viewport: DeviceViewport(
          width: 375,
          height: 812,
          deviceScaleFactor: 3,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final iPhoneXLandscape = Device('iPhone X',
      userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1',
      viewport: DeviceViewport(
          width: 812,
          height: 375,
          deviceScaleFactor: 3,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final blackBerryZ30 = Device('BlackBerry Z30',
      userAgent:
          'Mozilla/5.0 (BB10; Touch) AppleWebKit/537.10+ (KHTML, like Gecko) Version/10.0.9.2372 Mobile Safari/537.10+',
      viewport: DeviceViewport(
          width: 360,
          height: 640,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final blackBerryZ30Landscape = Device('BlackBerry Z30',
      userAgent:
          'Mozilla/5.0 (BB10; Touch) AppleWebKit/537.10+ (KHTML, like Gecko) Version/10.0.9.2372 Mobile Safari/537.10+',
      viewport: DeviceViewport(
          width: 640,
          height: 360,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final nexus4 = Device('Nexus 4',
      userAgent:
          'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 384,
          height: 640,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final nexus4Landscape = Device('Nexus 4',
      userAgent:
          'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 640,
          height: 384,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final nexus5 = Device('Nexus 5',
      userAgent:
          'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 360,
          height: 640,
          deviceScaleFactor: 3,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final nexus5Landscape = Device('Nexus 5',
      userAgent:
          'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 640,
          height: 360,
          deviceScaleFactor: 3,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final nexus5X = Device('Nexus 5X',
      userAgent:
          'Mozilla/5.0 (Linux; Android 8.0.0; Nexus 5X Build/OPR4.170623.006) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 412,
          height: 732,
          deviceScaleFactor: 2.625,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final nexus5XLandscape = Device('Nexus 5X',
      userAgent:
          'Mozilla/5.0 (Linux; Android 8.0.0; Nexus 5X Build/OPR4.170623.006) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 732,
          height: 412,
          deviceScaleFactor: 2.625,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final nexus6 = Device('Nexus 6',
      userAgent:
          'Mozilla/5.0 (Linux; Android 7.1.1; Nexus 6 Build/N6F26U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 412,
          height: 732,
          deviceScaleFactor: 3.5,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final nexus6Landscape = Device('Nexus 6',
      userAgent:
          'Mozilla/5.0 (Linux; Android 7.1.1; Nexus 6 Build/N6F26U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 732,
          height: 412,
          deviceScaleFactor: 3.5,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final nexus6P = Device('Nexus 6P',
      userAgent:
          'Mozilla/5.0 (Linux; Android 8.0.0; Nexus 6P Build/OPP3.170518.006) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 412,
          height: 732,
          deviceScaleFactor: 3.5,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final nexus6PLandscape = Device('Nexus 6P',
      userAgent:
          'Mozilla/5.0 (Linux; Android 8.0.0; Nexus 6P Build/OPP3.170518.006) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 732,
          height: 412,
          deviceScaleFactor: 3.5,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final pixel2 = Device('Pixel 2',
      userAgent:
          'Mozilla/5.0 (Linux; Android 8.0; Pixel 2 Build/OPD3.170816.012) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 411,
          height: 731,
          deviceScaleFactor: 2.625,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final pixel2Landscape = Device('Pixel 2',
      userAgent:
          'Mozilla/5.0 (Linux; Android 8.0; Pixel 2 Build/OPD3.170816.012) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 731,
          height: 411,
          deviceScaleFactor: 2.625,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final pixel2XL = Device('Pixel 2 XL',
      userAgent:
          'Mozilla/5.0 (Linux; Android 8.0.0; Pixel 2 XL Build/OPD1.170816.004) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 411,
          height: 823,
          deviceScaleFactor: 3.5,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final pixel2XLLandscape = Device('Pixel 2 XL',
      userAgent:
          'Mozilla/5.0 (Linux; Android 8.0.0; Pixel 2 XL Build/OPD1.170816.004) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 823,
          height: 411,
          deviceScaleFactor: 3.5,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final lGOptimusL70 = Device('LG Optimus L70',
      userAgent:
          'Mozilla/5.0 (Linux; U; Android 4.4.2; en-us; LGMS323 Build/KOT49I.MS32310c) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 384,
          height: 640,
          deviceScaleFactor: 1.25,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final lGOptimusL70Landscape = Device('LG Optimus L70',
      userAgent:
          'Mozilla/5.0 (Linux; U; Android 4.4.2; en-us; LGMS323 Build/KOT49I.MS32310c) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 640,
          height: 384,
          deviceScaleFactor: 1.25,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final nokiaN9 = Device('Nokia N9',
      userAgent:
          'Mozilla/5.0 (MeeGo; NokiaN9) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13',
      viewport: DeviceViewport(
          width: 480,
          height: 854,
          deviceScaleFactor: 1,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final nokiaN9Landscape = Device('Nokia N9',
      userAgent:
          'Mozilla/5.0 (MeeGo; NokiaN9) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13',
      viewport: DeviceViewport(
          width: 854,
          height: 480,
          deviceScaleFactor: 1,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final nokiaLumia520 = Device('Nokia Lumia 520',
      userAgent:
          'Mozilla/5.0 (compatible; MSIE 10.0; Windows Phone 8.0; Trident/6.0; IEMobile/10.0; ARM; Touch; NOKIA; Lumia 520)',
      viewport: DeviceViewport(
          width: 320,
          height: 533,
          deviceScaleFactor: 1.5,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final nokiaLumia520Landscape = Device('Nokia Lumia 520',
      userAgent:
          'Mozilla/5.0 (compatible; MSIE 10.0; Windows Phone 8.0; Trident/6.0; IEMobile/10.0; ARM; Touch; NOKIA; Lumia 520)',
      viewport: DeviceViewport(
          width: 533,
          height: 320,
          deviceScaleFactor: 1.5,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final microsoftLumia550 = Device('Microsoft Lumia 550',
      userAgent:
          'Mozilla/5.0 (Windows Phone 10.0; Android 4.2.1; Microsoft; Lumia 550) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Mobile Safari/537.36 Edge/14.14263',
      viewport: DeviceViewport(
          width: 640,
          height: 360,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final microsoftLumia550Landscape = Device('Microsoft Lumia 550',
      userAgent:
          'Mozilla/5.0 (Windows Phone 10.0; Android 4.2.1; Microsoft; Lumia 550) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Mobile Safari/537.36 Edge/14.14263',
      viewport: DeviceViewport(
          width: 640,
          height: 360,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final microsoftLumia950 = Device('Microsoft Lumia 950',
      userAgent:
          'Mozilla/5.0 (Windows Phone 10.0; Android 4.2.1; Microsoft; Lumia 950) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Mobile Safari/537.36 Edge/14.14263',
      viewport: DeviceViewport(
          width: 360,
          height: 640,
          deviceScaleFactor: 4,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final microsoftLumia950Landscape = Device('Microsoft Lumia 950',
      userAgent:
          'Mozilla/5.0 (Windows Phone 10.0; Android 4.2.1; Microsoft; Lumia 950) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Mobile Safari/537.36 Edge/14.14263',
      viewport: DeviceViewport(
          width: 640,
          height: 360,
          deviceScaleFactor: 4,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final galaxySIII = Device('Galaxy S III',
      userAgent:
          'Mozilla/5.0 (Linux; U; Android 4.0; en-us; GT-I9300 Build/IMM76D) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30',
      viewport: DeviceViewport(
          width: 360,
          height: 640,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final galaxySIIILandscape = Device('Galaxy S III',
      userAgent:
          'Mozilla/5.0 (Linux; U; Android 4.0; en-us; GT-I9300 Build/IMM76D) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30',
      viewport: DeviceViewport(
          width: 640,
          height: 360,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final galaxyS5 = Device('Galaxy S5',
      userAgent:
          'Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 360,
          height: 640,
          deviceScaleFactor: 3,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final galaxyS5Landscape = Device('Galaxy S5',
      userAgent:
          'Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 640,
          height: 360,
          deviceScaleFactor: 3,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final jioPhone2 = Device('JioPhone 2',
      userAgent:
          'Mozilla/5.0 (Mobile; LYF/F300B/LYF-F300B-001-01-15-130718-i;Android; rv:48.0) Gecko/48.0 Firefox/48.0 KAIOS/2.5',
      viewport: DeviceViewport(
          width: 240,
          height: 320,
          deviceScaleFactor: 1,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final jioPhone2Landscape = Device('JioPhone 2',
      userAgent:
          'Mozilla/5.0 (Mobile; LYF/F300B/LYF-F300B-001-01-15-130718-i;Android; rv:48.0) Gecko/48.0 Firefox/48.0 KAIOS/2.5',
      viewport: DeviceViewport(
          width: 320,
          height: 240,
          deviceScaleFactor: 1,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final kindleFireHDX = Device('Kindle Fire HDX',
      userAgent:
          'Mozilla/5.0 (Linux; U; en-us; KFAPWI Build/JDQ39) AppleWebKit/535.19 (KHTML, like Gecko) Silk/3.13 Safari/535.19 Silk-Accelerated=true',
      viewport: DeviceViewport(
          width: 800,
          height: 1280,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final kindleFireHDXLandscape = Device('Kindle Fire HDX',
      userAgent:
          'Mozilla/5.0 (Linux; U; en-us; KFAPWI Build/JDQ39) AppleWebKit/535.19 (KHTML, like Gecko) Silk/3.13 Safari/535.19 Silk-Accelerated=true',
      viewport: DeviceViewport(
          width: 1280,
          height: 800,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final iPadMini = Device('iPad Mini',
      userAgent:
          'Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1',
      viewport: DeviceViewport(
          width: 768,
          height: 1024,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final iPadMiniLandscape = Device('iPad Mini',
      userAgent:
          'Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1',
      viewport: DeviceViewport(
          width: 1024,
          height: 768,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final iPad = Device('iPad',
      userAgent:
          'Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1',
      viewport: DeviceViewport(
          width: 768,
          height: 1024,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final iPadLandscape = Device('iPad',
      userAgent:
          'Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1',
      viewport: DeviceViewport(
          width: 1024,
          height: 768,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final iPadPro = Device('iPad Pro',
      userAgent:
          'Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1',
      viewport: DeviceViewport(
          width: 1024,
          height: 1366,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final iPadProLandscape = Device('iPad Pro',
      userAgent:
          'Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1',
      viewport: DeviceViewport(
          width: 1366,
          height: 1024,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final blackberryPlayBook = Device('Blackberry PlayBook',
      userAgent:
          'Mozilla/5.0 (PlayBook; U; RIM Tablet OS 2.1.0; en-US) AppleWebKit/536.2+ (KHTML like Gecko) Version/7.2.1.0 Safari/536.2+',
      viewport: DeviceViewport(
          width: 600,
          height: 1024,
          deviceScaleFactor: 1,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final blackberryPlayBookLandscape = Device('Blackberry PlayBook',
      userAgent:
          'Mozilla/5.0 (PlayBook; U; RIM Tablet OS 2.1.0; en-US) AppleWebKit/536.2+ (KHTML like Gecko) Version/7.2.1.0 Safari/536.2+',
      viewport: DeviceViewport(
          width: 1024,
          height: 600,
          deviceScaleFactor: 1,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final nexus10 = Device('Nexus 10',
      userAgent:
          'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 10 Build/MOB31T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Safari/537.36',
      viewport: DeviceViewport(
          width: 800,
          height: 1280,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final nexus10Landscape = Device('Nexus 10',
      userAgent:
          'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 10 Build/MOB31T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Safari/537.36',
      viewport: DeviceViewport(
          width: 1280,
          height: 800,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final nexus7 = Device('Nexus 7',
      userAgent:
          'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 7 Build/MOB30X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Safari/537.36',
      viewport: DeviceViewport(
          width: 600,
          height: 960,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final nexus7Landscape = Device('Nexus 7',
      userAgent:
          'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 7 Build/MOB30X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Safari/537.36',
      viewport: DeviceViewport(
          width: 960,
          height: 600,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final galaxyNote3 = Device('Galaxy Note 3',
      userAgent:
          'Mozilla/5.0 (Linux; U; Android 4.3; en-us; SM-N900T Build/JSS15J) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30',
      viewport: DeviceViewport(
          width: 360,
          height: 640,
          deviceScaleFactor: 3,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final galaxyNote3Landscape = Device('Galaxy Note 3',
      userAgent:
          'Mozilla/5.0 (Linux; U; Android 4.3; en-us; SM-N900T Build/JSS15J) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30',
      viewport: DeviceViewport(
          width: 640,
          height: 360,
          deviceScaleFactor: 3,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final galaxyNoteII = Device('Galaxy Note II',
      userAgent:
          'Mozilla/5.0 (Linux; U; Android 4.1; en-us; GT-N7100 Build/JRO03C) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30',
      viewport: DeviceViewport(
          width: 360,
          height: 640,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final galaxyNoteIILandscape = Device('Galaxy Note II',
      userAgent:
          'Mozilla/5.0 (Linux; U; Android 4.1; en-us; GT-N7100 Build/JRO03C) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30',
      viewport: DeviceViewport(
          width: 640,
          height: 360,
          deviceScaleFactor: 2,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final laptopWithTouch = Device('Laptop with touch',
      userAgent: '',
      viewport: DeviceViewport(
          width: 950,
          height: 1280,
          deviceScaleFactor: 1,
          isMobile: false,
          hasTouch: true,
          isLandscape: false));

  final laptopWithTouchLandscape = Device('Laptop with touch',
      userAgent: '',
      viewport: DeviceViewport(
          width: 1280,
          height: 950,
          deviceScaleFactor: 1,
          isMobile: false,
          hasTouch: true,
          isLandscape: true));

  final laptopWithHiDPIScreen = Device('Laptop with HiDPI screen',
      userAgent: '',
      viewport: DeviceViewport(
          width: 900,
          height: 1440,
          deviceScaleFactor: 2,
          isMobile: false,
          hasTouch: false,
          isLandscape: false));

  final laptopWithHiDPIScreenLandscape = Device('Laptop with HiDPI screen',
      userAgent: '',
      viewport: DeviceViewport(
          width: 1440,
          height: 900,
          deviceScaleFactor: 2,
          isMobile: false,
          hasTouch: false,
          isLandscape: true));

  final laptopWithMDPIScreen = Device('Laptop with MDPI screen',
      userAgent: '',
      viewport: DeviceViewport(
          width: 800,
          height: 1280,
          deviceScaleFactor: 1,
          isMobile: false,
          hasTouch: false,
          isLandscape: false));

  final laptopWithMDPIScreenLandscape = Device('Laptop with MDPI screen',
      userAgent: '',
      viewport: DeviceViewport(
          width: 1280,
          height: 800,
          deviceScaleFactor: 1,
          isMobile: false,
          hasTouch: false,
          isLandscape: true));

  final motoG4 = Device('Moto G4',
      userAgent:
          'Mozilla/5.0 (Linux; Android 6.0.1; Moto G (4)) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 360,
          height: 640,
          deviceScaleFactor: 3,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final motoG4Landscape = Device('Moto G4',
      userAgent:
          'Mozilla/5.0 (Linux; Android 6.0.1; Moto G (4)) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 640,
          height: 360,
          deviceScaleFactor: 3,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final surfaceDuo = Device('Surface Duo',
      userAgent:
          'Mozilla/5.0 (Linux; Android 8.0; Pixel 2 Build/OPD3.170816.012) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 540,
          height: 720,
          deviceScaleFactor: 2.5,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final surfaceDuoLandscape = Device('Surface Duo',
      userAgent:
          'Mozilla/5.0 (Linux; Android 8.0; Pixel 2 Build/OPD3.170816.012) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 720,
          height: 540,
          deviceScaleFactor: 2.5,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  final galaxyFold = Device('Galaxy Fold',
      userAgent:
          'Mozilla/5.0 (Linux; Android 8.0; Pixel 2 Build/OPD3.170816.012) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 280,
          height: 653,
          deviceScaleFactor: 3,
          isMobile: true,
          hasTouch: true,
          isLandscape: false));

  final galaxyFoldLandscape = Device('Galaxy Fold',
      userAgent:
          'Mozilla/5.0 (Linux; Android 8.0; Pixel 2 Build/OPD3.170816.012) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%s Mobile Safari/537.36',
      viewport: DeviceViewport(
          width: 653,
          height: 280,
          deviceScaleFactor: 3,
          isMobile: true,
          hasTouch: true,
          isLandscape: true));

  late final Map<String, Device> _all;
  Devices._() {
    _all = CanonicalizedMap<String, String, Device>.from({
      'iPhone 4': iPhone4,
      'iPhone 4 Landscape': iPhone4Landscape,
      'iPhone 5': iPhone5,
      'iPhone 5 Landscape': iPhone5Landscape,
      'iPhone SE': iPhoneSE,
      'iPhone SE Landscape': iPhoneSELandscape,
      'iPhone 6': iPhone6,
      'iPhone 6 Landscape': iPhone6Landscape,
      'iPhone 7': iPhone7,
      'iPhone 7 Landscape': iPhone7Landscape,
      'iPhone 8': iPhone8,
      'iPhone 8 Landscape': iPhone8Landscape,
      'iPhone 6/7/8 Plus': iPhone678Plus,
      'iPhone 6/7/8 Plus Landscape': iPhone678PlusLandscape,
      'iPhone X': iPhoneX,
      'iPhone X Landscape': iPhoneXLandscape,
      'BlackBerry Z30': blackBerryZ30,
      'BlackBerry Z30 Landscape': blackBerryZ30Landscape,
      'Nexus 4': nexus4,
      'Nexus 4 Landscape': nexus4Landscape,
      'Nexus 5': nexus5,
      'Nexus 5 Landscape': nexus5Landscape,
      'Nexus 5X': nexus5X,
      'Nexus 5X Landscape': nexus5XLandscape,
      'Nexus 6': nexus6,
      'Nexus 6 Landscape': nexus6Landscape,
      'Nexus 6P': nexus6P,
      'Nexus 6P Landscape': nexus6PLandscape,
      'Pixel 2': pixel2,
      'Pixel 2 Landscape': pixel2Landscape,
      'Pixel 2 XL': pixel2XL,
      'Pixel 2 XL Landscape': pixel2XLLandscape,
      'LG Optimus L70': lGOptimusL70,
      'LG Optimus L70 Landscape': lGOptimusL70Landscape,
      'Nokia N9': nokiaN9,
      'Nokia N9 Landscape': nokiaN9Landscape,
      'Nokia Lumia 520': nokiaLumia520,
      'Nokia Lumia 520 Landscape': nokiaLumia520Landscape,
      'Microsoft Lumia 550': microsoftLumia550,
      'Microsoft Lumia 550 Landscape': microsoftLumia550Landscape,
      'Microsoft Lumia 950': microsoftLumia950,
      'Microsoft Lumia 950 Landscape': microsoftLumia950Landscape,
      'Galaxy S III': galaxySIII,
      'Galaxy S III Landscape': galaxySIIILandscape,
      'Galaxy S5': galaxyS5,
      'Galaxy S5 Landscape': galaxyS5Landscape,
      'JioPhone 2': jioPhone2,
      'JioPhone 2 Landscape': jioPhone2Landscape,
      'Kindle Fire HDX': kindleFireHDX,
      'Kindle Fire HDX Landscape': kindleFireHDXLandscape,
      'iPad Mini': iPadMini,
      'iPad Mini Landscape': iPadMiniLandscape,
      'iPad': iPad,
      'iPad Landscape': iPadLandscape,
      'iPad Pro': iPadPro,
      'iPad Pro Landscape': iPadProLandscape,
      'Blackberry PlayBook': blackberryPlayBook,
      'Blackberry PlayBook Landscape': blackberryPlayBookLandscape,
      'Nexus 10': nexus10,
      'Nexus 10 Landscape': nexus10Landscape,
      'Nexus 7': nexus7,
      'Nexus 7 Landscape': nexus7Landscape,
      'Galaxy Note 3': galaxyNote3,
      'Galaxy Note 3 Landscape': galaxyNote3Landscape,
      'Galaxy Note II': galaxyNoteII,
      'Galaxy Note II Landscape': galaxyNoteIILandscape,
      'Laptop with touch': laptopWithTouch,
      'Laptop with touch Landscape': laptopWithTouchLandscape,
      'Laptop with HiDPI screen': laptopWithHiDPIScreen,
      'Laptop with HiDPI screen Landscape': laptopWithHiDPIScreenLandscape,
      'Laptop with MDPI screen': laptopWithMDPIScreen,
      'Laptop with MDPI screen Landscape': laptopWithMDPIScreenLandscape,
      'Moto G4': motoG4,
      'Moto G4 Landscape': motoG4Landscape,
      'Surface Duo': surfaceDuo,
      'Surface Duo Landscape': surfaceDuoLandscape,
      'Galaxy Fold': galaxyFold,
      'Galaxy Fold Landscape': galaxyFoldLandscape,
    }, (key) => key.replaceAll(' ', '').toLowerCase());
  }

  Device? operator [](String name) => _all[name];

  @override
  Iterator<Device> get iterator => _all.values.iterator;
}

final devices = Devices._();
