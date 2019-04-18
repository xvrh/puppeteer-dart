import 'package:chrome_dev_tools/domains/domains.dart';
import 'package:chrome_dev_tools/src/tab.dart';
import 'package:chrome_dev_tools/domains/emulation.dart';
import 'package:meta/meta.dart';

class Device {
  final String name;
  final String _userAgentTemplate;
  final DeviceViewport viewport;

  const Device(this.name, {@required this.viewport, @required String userAgent})
      : _userAgentTemplate = userAgent,
        assert(name != null),
        assert(viewport != null),
        assert(userAgent != null);

  String userAgent(String chromeVersion) =>
      _userAgentTemplate.replaceAll('%s', chromeVersion);
}

class DeviceViewport {
  final int width, height;
  final num deviceScaleFactor;
  final bool isMobile;
  final bool isLandscape;
  final bool hasTouch;

  const DeviceViewport(
      {this.width: 800,
      this.height: 600,
      this.deviceScaleFactor: 1,
      this.isMobile: false,
      this.isLandscape: false,
      this.hasTouch: false})
      : assert(width != null),
        assert(height != null);

  DeviceViewport copyWith(
      {int width,
      int height,
      num deviceScaleFactor,
      bool isMobile,
      bool isLandscape,
      bool hasTouch}) {
    return DeviceViewport(
      width: width ?? this.width,
      height: height ?? this.height,
      deviceScaleFactor: deviceScaleFactor ?? this.deviceScaleFactor,
      isMobile: isMobile ?? this.isMobile,
      isLandscape: isLandscape ?? this.isLandscape,
      hasTouch: hasTouch ?? this.hasTouch,
    );
  }
}

class EmulationManager {
  static final portrait =
  ScreenOrientation(angle: 0, type: ScreenOrientationType.portraitPrimary);
  static final landscape = ScreenOrientation(
      angle: 90, type: ScreenOrientationType.landscapePrimary);

  final Domains domains;
  bool _emulatingMobile = false;
  bool _hasTouch = false;


  EmulationManager(this.domains);

  Future<bool> emulateViewport(DeviceViewport viewport) async {
    var screenOrientation = viewport.isLandscape ? landscape : portrait;

    await Future.wait([
      domains.emulation.setDeviceMetricsOverride(viewport.width, viewport.height,
          viewport.deviceScaleFactor, viewport.isMobile,
          screenOrientation: screenOrientation),
      domains.emulation.setTouchEmulationEnabled(viewport.hasTouch),
    ]);

    var reloadNeeded =
        _emulatingMobile != viewport.isMobile || _hasTouch != viewport.hasTouch;
    _emulatingMobile = viewport.isMobile;
    _hasTouch = viewport.hasTouch;
    return reloadNeeded;
  }
}
