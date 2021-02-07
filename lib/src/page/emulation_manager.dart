import '../../protocol/dev_tools.dart';
import '../../protocol/emulation.dart';

class Device {
  final String name;
  final String _userAgentTemplate;
  final DeviceViewport viewport;

  const Device(this.name, {required this.viewport, required String userAgent})
      : _userAgentTemplate = userAgent;

  String userAgent(String chromeVersion) =>
      _userAgentTemplate.replaceAll('%s', chromeVersion);

  @override
  bool operator ==(other) =>
      other is Device &&
      other.name == name &&
      other._userAgentTemplate == _userAgentTemplate &&
      other.viewport == viewport;

  @override
  int get hashCode =>
      name.hashCode + _userAgentTemplate.hashCode + viewport.hashCode;
}

class DeviceViewport {
  final int width, height;
  final num deviceScaleFactor;
  final bool isMobile;
  final bool isLandscape;
  final bool hasTouch;

  const DeviceViewport(
      {this.width = 1280,
      this.height = 1024,
      this.deviceScaleFactor = 1,
      this.isMobile = false,
      this.isLandscape = false,
      this.hasTouch = false});

  DeviceViewport copyWith(
      {int? width,
      int? height,
      num? deviceScaleFactor,
      bool? isMobile,
      bool? isLandscape,
      bool? hasTouch}) {
    return DeviceViewport(
      width: width ?? this.width,
      height: height ?? this.height,
      deviceScaleFactor: deviceScaleFactor ?? this.deviceScaleFactor,
      isMobile: isMobile ?? this.isMobile,
      isLandscape: isLandscape ?? this.isLandscape,
      hasTouch: hasTouch ?? this.hasTouch,
    );
  }

  @override
  bool operator ==(other) =>
      other is DeviceViewport &&
      other.width == width &&
      other.height == height &&
      other.deviceScaleFactor == deviceScaleFactor &&
      other.isMobile == isMobile &&
      other.isLandscape == isLandscape &&
      other.hasTouch == hasTouch;

  @override
  int get hashCode =>
      width.hashCode +
      height.hashCode +
      deviceScaleFactor.hashCode +
      isMobile.hashCode +
      isLandscape.hashCode +
      hasTouch.hashCode;
}

class EmulationManager {
  static final portrait =
      ScreenOrientation(angle: 0, type: ScreenOrientationType.portraitPrimary);
  static final landscape = ScreenOrientation(
      angle: 90, type: ScreenOrientationType.landscapePrimary);

  final DevTools devTools;
  bool _emulatingMobile = false;
  bool _hasTouch = false;

  EmulationManager(this.devTools);

  Future<bool> emulateViewport(DeviceViewport viewport) async {
    var screenOrientation = viewport.isLandscape ? landscape : portrait;

    await Future.wait([
      devTools.emulation.setDeviceMetricsOverride(viewport.width,
          viewport.height, viewport.deviceScaleFactor, viewport.isMobile,
          screenOrientation: screenOrientation),
      devTools.emulation.setTouchEmulationEnabled(viewport.hasTouch),
    ]);

    var reloadNeeded =
        _emulatingMobile != viewport.isMobile || _hasTouch != viewport.hasTouch;
    _emulatingMobile = viewport.isMobile;
    _hasTouch = viewport.hasTouch;
    return reloadNeeded;
  }
}
