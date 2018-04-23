/// This domain emulates different environments for the page.

import 'dart:async';
// ignore: unused_import
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'page.dart' as page;
import 'runtime.dart' as runtime;
import 'dom.dart' as dom;

class EmulationManager {
  final Client _client;

  EmulationManager(this._client);

  /// Notification sent after the virtual time budget for the current
  /// VirtualTimePolicy has run out.
  Stream get onVirtualTimeBudgetExpired => _client.onEvent.where(
      (Event event) => event.name == 'Emulation.virtualTimeBudgetExpired');

  /// Notification sent after the virtual time has advanced.
  Stream<num> get onVirtualTimeAdvanced => _client.onEvent
      .where((Event event) => event.name == 'Emulation.virtualTimeAdvanced')
      .map((Event event) => event.parameters['virtualTimeElapsed'] as num);

  /// Notification sent after the virtual time has paused.
  Stream<num> get onVirtualTimePaused => _client.onEvent
      .where((Event event) => event.name == 'Emulation.virtualTimePaused')
      .map((Event event) => event.parameters['virtualTimeElapsed'] as num);

  /// Overrides the values of device screen dimensions (window.screen.width,
  /// window.screen.height, window.innerWidth, window.innerHeight, and
  /// "device-width"/"device-height"-related CSS media query results).
  /// [width] Overriding width value in pixels (minimum 0, maximum 10000000). 0
  /// disables the override.
  /// [height] Overriding height value in pixels (minimum 0, maximum 10000000). 0
  /// disables the override.
  /// [deviceScaleFactor] Overriding device scale factor value. 0 disables the
  /// override.
  /// [mobile] Whether to emulate mobile device. This includes viewport meta tag,
  /// overlay scrollbars, text autosizing and more.
  /// [scale] Scale to apply to resulting view image.
  /// [screenWidth] Overriding screen width value in pixels (minimum 0, maximum
  /// 10000000).
  /// [screenHeight] Overriding screen height value in pixels (minimum 0, maximum
  /// 10000000).
  /// [positionX] Overriding view X position on screen in pixels (minimum 0,
  /// maximum 10000000).
  /// [positionY] Overriding view Y position on screen in pixels (minimum 0,
  /// maximum 10000000).
  /// [dontSetVisibleSize] Do not set visible view size, rely upon explicit
  /// setVisibleSize call.
  /// [screenOrientation] Screen orientation override.
  /// [viewport] If set, the visible area of the page will be overridden to this
  /// viewport. This viewport change is not observed by the page, e.g.
  /// viewport-relative elements do not change positions.
  Future setDeviceMetricsOverride(
    int width,
    int height,
    num deviceScaleFactor,
    bool mobile, {
    num scale,
    int screenWidth,
    int screenHeight,
    int positionX,
    int positionY,
    bool dontSetVisibleSize,
    ScreenOrientation screenOrientation,
    page.Viewport viewport,
  }) async {
    Map parameters = {
      'width': width,
      'height': height,
      'deviceScaleFactor': deviceScaleFactor,
      'mobile': mobile,
    };
    if (scale != null) {
      parameters['scale'] = scale;
    }
    if (screenWidth != null) {
      parameters['screenWidth'] = screenWidth;
    }
    if (screenHeight != null) {
      parameters['screenHeight'] = screenHeight;
    }
    if (positionX != null) {
      parameters['positionX'] = positionX;
    }
    if (positionY != null) {
      parameters['positionY'] = positionY;
    }
    if (dontSetVisibleSize != null) {
      parameters['dontSetVisibleSize'] = dontSetVisibleSize;
    }
    if (screenOrientation != null) {
      parameters['screenOrientation'] = screenOrientation.toJson();
    }
    if (viewport != null) {
      parameters['viewport'] = viewport.toJson();
    }
    await _client.send('Emulation.setDeviceMetricsOverride', parameters);
  }

  /// Clears the overriden device metrics.
  Future clearDeviceMetricsOverride() async {
    await _client.send('Emulation.clearDeviceMetricsOverride');
  }

  /// Requests that page scale factor is reset to initial values.
  Future resetPageScaleFactor() async {
    await _client.send('Emulation.resetPageScaleFactor');
  }

  /// Sets a specified page scale factor.
  /// [pageScaleFactor] Page scale factor.
  Future setPageScaleFactor(
    num pageScaleFactor,
  ) async {
    Map parameters = {
      'pageScaleFactor': pageScaleFactor,
    };
    await _client.send('Emulation.setPageScaleFactor', parameters);
  }

  /// Resizes the frame/viewport of the page. Note that this does not affect the
  /// frame's container (e.g. browser window). Can be used to produce screenshots
  /// of the specified size. Not supported on Android.
  /// [width] Frame width (DIP).
  /// [height] Frame height (DIP).
  Future setVisibleSize(
    int width,
    int height,
  ) async {
    Map parameters = {
      'width': width,
      'height': height,
    };
    await _client.send('Emulation.setVisibleSize', parameters);
  }

  /// Switches script execution in the page.
  /// [value] Whether script execution should be disabled in the page.
  Future setScriptExecutionDisabled(
    bool value,
  ) async {
    Map parameters = {
      'value': value,
    };
    await _client.send('Emulation.setScriptExecutionDisabled', parameters);
  }

  /// Overrides the Geolocation Position or Error. Omitting any of the parameters
  /// emulates position unavailable.
  /// [latitude] Mock latitude
  /// [longitude] Mock longitude
  /// [accuracy] Mock accuracy
  Future setGeolocationOverride({
    num latitude,
    num longitude,
    num accuracy,
  }) async {
    Map parameters = {};
    if (latitude != null) {
      parameters['latitude'] = latitude;
    }
    if (longitude != null) {
      parameters['longitude'] = longitude;
    }
    if (accuracy != null) {
      parameters['accuracy'] = accuracy;
    }
    await _client.send('Emulation.setGeolocationOverride', parameters);
  }

  /// Clears the overriden Geolocation Position and Error.
  Future clearGeolocationOverride() async {
    await _client.send('Emulation.clearGeolocationOverride');
  }

  /// Enables touch on platforms which do not support them.
  /// [enabled] Whether the touch event emulation should be enabled.
  /// [maxTouchPoints] Maximum touch points supported. Defaults to one.
  Future setTouchEmulationEnabled(
    bool enabled, {
    int maxTouchPoints,
  }) async {
    Map parameters = {
      'enabled': enabled,
    };
    if (maxTouchPoints != null) {
      parameters['maxTouchPoints'] = maxTouchPoints;
    }
    await _client.send('Emulation.setTouchEmulationEnabled', parameters);
  }

  /// [enabled] Whether touch emulation based on mouse input should be enabled.
  /// [configuration] Touch/gesture events configuration. Default: current
  /// platform.
  Future setEmitTouchEventsForMouse(
    bool enabled, {
    String configuration,
  }) async {
    Map parameters = {
      'enabled': enabled,
    };
    if (configuration != null) {
      parameters['configuration'] = configuration;
    }
    await _client.send('Emulation.setEmitTouchEventsForMouse', parameters);
  }

  /// Emulates the given media for CSS media queries.
  /// [media] Media type to emulate. Empty string disables the override.
  Future setEmulatedMedia(
    String media,
  ) async {
    Map parameters = {
      'media': media,
    };
    await _client.send('Emulation.setEmulatedMedia', parameters);
  }

  /// Enables CPU throttling to emulate slow CPUs.
  /// [rate] Throttling rate as a slowdown factor (1 is no throttle, 2 is 2x
  /// slowdown, etc).
  Future setCPUThrottlingRate(
    num rate,
  ) async {
    Map parameters = {
      'rate': rate,
    };
    await _client.send('Emulation.setCPUThrottlingRate', parameters);
  }

  /// Tells whether emulation is supported.
  /// Return: True if emulation is supported.
  Future<bool> canEmulate() async {
    Map result = await _client.send('Emulation.canEmulate');
    return result['result'];
  }

  /// Turns on virtual time for all frames (replacing real-time with a synthetic
  /// time source) and sets the current virtual time policy.  Note this supersedes
  /// any previous time budget.
  /// [budget] If set, after this many virtual milliseconds have elapsed virtual
  /// time will be paused and a virtualTimeBudgetExpired event is sent.
  /// [maxVirtualTimeTaskStarvationCount] If set this specifies the maximum number
  /// of tasks that can be run before virtual is forced forwards to prevent
  /// deadlock.
  /// Return: Absolute timestamp at which virtual time was first enabled
  /// (milliseconds since epoch).
  Future<runtime.Timestamp> setVirtualTimePolicy(
    VirtualTimePolicy policy, {
    num budget,
    int maxVirtualTimeTaskStarvationCount,
  }) async {
    Map parameters = {
      'policy': policy.toJson(),
    };
    if (budget != null) {
      parameters['budget'] = budget;
    }
    if (maxVirtualTimeTaskStarvationCount != null) {
      parameters['maxVirtualTimeTaskStarvationCount'] =
          maxVirtualTimeTaskStarvationCount;
    }
    Map result =
        await _client.send('Emulation.setVirtualTimePolicy', parameters);
    return new runtime.Timestamp.fromJson(result['virtualTimeBase']);
  }

  /// Overrides value returned by the javascript navigator object.
  /// [platform] The platform navigator.platform should return.
  Future setNavigatorOverrides(
    String platform,
  ) async {
    Map parameters = {
      'platform': platform,
    };
    await _client.send('Emulation.setNavigatorOverrides', parameters);
  }

  /// Sets or clears an override of the default background color of the frame.
  /// This override is used if the content does not specify one.
  /// [color] RGBA of the default background color. If not specified, any existing
  /// override will be cleared.
  Future setDefaultBackgroundColorOverride({
    dom.RGBA color,
  }) async {
    Map parameters = {};
    if (color != null) {
      parameters['color'] = color.toJson();
    }
    await _client.send(
        'Emulation.setDefaultBackgroundColorOverride', parameters);
  }
}

/// Screen orientation.
class ScreenOrientation {
  /// Orientation type.
  final String type;

  /// Orientation angle.
  final int angle;

  ScreenOrientation({
    @required this.type,
    @required this.angle,
  });

  factory ScreenOrientation.fromJson(Map json) {
    return new ScreenOrientation(
      type: json['type'],
      angle: json['angle'],
    );
  }

  Map toJson() {
    Map json = {
      'type': type,
      'angle': angle,
    };
    return json;
  }
}

/// advance: If the scheduler runs out of immediate work, the virtual time base
/// may fast forward to allow the next delayed task (if any) to run; pause: The
/// virtual time base may not advance; pauseIfNetworkFetchesPending: The virtual
/// time base may not advance if there are any pending resource fetches.
class VirtualTimePolicy {
  static const VirtualTimePolicy advance = const VirtualTimePolicy._('advance');
  static const VirtualTimePolicy pause = const VirtualTimePolicy._('pause');
  static const VirtualTimePolicy pauseIfNetworkFetchesPending =
      const VirtualTimePolicy._('pauseIfNetworkFetchesPending');
  static const values = const {
    'advance': advance,
    'pause': pause,
    'pauseIfNetworkFetchesPending': pauseIfNetworkFetchesPending,
  };

  final String value;

  const VirtualTimePolicy._(this.value);

  factory VirtualTimePolicy.fromJson(String value) => values[value];

  String toJson() => value;

  String toString() => value.toString();
}
