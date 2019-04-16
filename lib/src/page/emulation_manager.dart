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
}

final _portrait =
    ScreenOrientation(angle: 0, type: ScreenOrientationType.portraitPrimary);
final _landscape =
    ScreenOrientation(angle: 90, type: ScreenOrientationType.landscapePrimary);

class EmulationManager {
  final Tab tab;
  bool _emulatingMobile = false;
  bool _hasTouch = false;

  EmulationManager(this.tab);

  Future<bool> emulateViewport(DeviceViewport viewport) async {
    var screenOrientation = viewport.isLandscape ? _landscape : _portrait;

    await Future.wait([
      tab.emulation.setDeviceMetricsOverride(viewport.width, viewport.height,
          viewport.deviceScaleFactor, viewport.isMobile,
          screenOrientation: screenOrientation),
      tab.emulation.setTouchEmulationEnabled(viewport.hasTouch),
    ]);

    var reloadNeeded =
        _emulatingMobile != viewport.isMobile || _hasTouch != viewport.hasTouch;
    _emulatingMobile = viewport.isMobile;
    _hasTouch = viewport.hasTouch;
    return reloadNeeded;
  }
}
