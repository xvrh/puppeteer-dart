import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'dom.dart' as dom;
import 'page.dart' as page;
import 'network.dart' as network;

/// This domain emulates different environments for the page.
class EmulationApi {
  final Client _client;

  EmulationApi(this._client);

  /// Notification sent after the virtual time budget for the current VirtualTimePolicy has run out.
  Stream get onVirtualTimeBudgetExpired => _client.onEvent.where(
      (Event event) => event.name == 'Emulation.virtualTimeBudgetExpired');

  /// Tells whether emulation is supported.
  /// Returns: True if emulation is supported.
  Future<bool> canEmulate() async {
    var result = await _client.send('Emulation.canEmulate');
    return result['result'];
  }

  /// Clears the overriden device metrics.
  Future<void> clearDeviceMetricsOverride() async {
    await _client.send('Emulation.clearDeviceMetricsOverride');
  }

  /// Clears the overriden Geolocation Position and Error.
  Future<void> clearGeolocationOverride() async {
    await _client.send('Emulation.clearGeolocationOverride');
  }

  /// Requests that page scale factor is reset to initial values.
  Future<void> resetPageScaleFactor() async {
    await _client.send('Emulation.resetPageScaleFactor');
  }

  /// Enables or disables simulating a focused and active page.
  /// [enabled] Whether to enable to disable focus emulation.
  Future<void> setFocusEmulationEnabled(bool enabled) async {
    var parameters = <String, dynamic>{
      'enabled': enabled,
    };
    await _client.send('Emulation.setFocusEmulationEnabled', parameters);
  }

  /// Enables CPU throttling to emulate slow CPUs.
  /// [rate] Throttling rate as a slowdown factor (1 is no throttle, 2 is 2x slowdown, etc).
  Future<void> setCPUThrottlingRate(num rate) async {
    var parameters = <String, dynamic>{
      'rate': rate,
    };
    await _client.send('Emulation.setCPUThrottlingRate', parameters);
  }

  /// Sets or clears an override of the default background color of the frame. This override is used
  /// if the content does not specify one.
  /// [color] RGBA of the default background color. If not specified, any existing override will be
  /// cleared.
  Future<void> setDefaultBackgroundColorOverride({dom.RGBA color}) async {
    var parameters = <String, dynamic>{};
    if (color != null) {
      parameters['color'] = color.toJson();
    }
    await _client.send(
        'Emulation.setDefaultBackgroundColorOverride', parameters);
  }

  /// Overrides the values of device screen dimensions (window.screen.width, window.screen.height,
  /// window.innerWidth, window.innerHeight, and "device-width"/"device-height"-related CSS media
  /// query results).
  /// [width] Overriding width value in pixels (minimum 0, maximum 10000000). 0 disables the override.
  /// [height] Overriding height value in pixels (minimum 0, maximum 10000000). 0 disables the override.
  /// [deviceScaleFactor] Overriding device scale factor value. 0 disables the override.
  /// [mobile] Whether to emulate mobile device. This includes viewport meta tag, overlay scrollbars, text
  /// autosizing and more.
  /// [scale] Scale to apply to resulting view image.
  /// [screenWidth] Overriding screen width value in pixels (minimum 0, maximum 10000000).
  /// [screenHeight] Overriding screen height value in pixels (minimum 0, maximum 10000000).
  /// [positionX] Overriding view X position on screen in pixels (minimum 0, maximum 10000000).
  /// [positionY] Overriding view Y position on screen in pixels (minimum 0, maximum 10000000).
  /// [dontSetVisibleSize] Do not set visible view size, rely upon explicit setVisibleSize call.
  /// [screenOrientation] Screen orientation override.
  /// [viewport] If set, the visible area of the page will be overridden to this viewport. This viewport
  /// change is not observed by the page, e.g. viewport-relative elements do not change positions.
  Future<void> setDeviceMetricsOverride(
      int width, int height, num deviceScaleFactor, bool mobile,
      {num scale,
      int screenWidth,
      int screenHeight,
      int positionX,
      int positionY,
      bool dontSetVisibleSize,
      ScreenOrientation screenOrientation,
      page.Viewport viewport}) async {
    var parameters = <String, dynamic>{
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

  /// [hidden] Whether scrollbars should be always hidden.
  Future<void> setScrollbarsHidden(bool hidden) async {
    var parameters = <String, dynamic>{
      'hidden': hidden,
    };
    await _client.send('Emulation.setScrollbarsHidden', parameters);
  }

  /// [disabled] Whether document.coookie API should be disabled.
  Future<void> setDocumentCookieDisabled(bool disabled) async {
    var parameters = <String, dynamic>{
      'disabled': disabled,
    };
    await _client.send('Emulation.setDocumentCookieDisabled', parameters);
  }

  /// [enabled] Whether touch emulation based on mouse input should be enabled.
  /// [configuration] Touch/gesture events configuration. Default: current platform.
  Future<void> setEmitTouchEventsForMouse(bool enabled,
      {@Enum(['mobile', 'desktop']) String configuration}) async {
    assert(configuration == null ||
        const ['mobile', 'desktop'].contains(configuration));
    var parameters = <String, dynamic>{
      'enabled': enabled,
    };
    if (configuration != null) {
      parameters['configuration'] = configuration;
    }
    await _client.send('Emulation.setEmitTouchEventsForMouse', parameters);
  }

  /// Emulates the given media for CSS media queries.
  /// [media] Media type to emulate. Empty string disables the override.
  Future<void> setEmulatedMedia(String media) async {
    var parameters = <String, dynamic>{
      'media': media,
    };
    await _client.send('Emulation.setEmulatedMedia', parameters);
  }

  /// Overrides the Geolocation Position or Error. Omitting any of the parameters emulates position
  /// unavailable.
  /// [latitude] Mock latitude
  /// [longitude] Mock longitude
  /// [accuracy] Mock accuracy
  Future<void> setGeolocationOverride(
      {num latitude, num longitude, num accuracy}) async {
    var parameters = <String, dynamic>{};
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

  /// Overrides value returned by the javascript navigator object.
  /// [platform] The platform navigator.platform should return.
  @deprecated
  Future<void> setNavigatorOverrides(String platform) async {
    var parameters = <String, dynamic>{
      'platform': platform,
    };
    await _client.send('Emulation.setNavigatorOverrides', parameters);
  }

  /// Sets a specified page scale factor.
  /// [pageScaleFactor] Page scale factor.
  Future<void> setPageScaleFactor(num pageScaleFactor) async {
    var parameters = <String, dynamic>{
      'pageScaleFactor': pageScaleFactor,
    };
    await _client.send('Emulation.setPageScaleFactor', parameters);
  }

  /// Switches script execution in the page.
  /// [value] Whether script execution should be disabled in the page.
  Future<void> setScriptExecutionDisabled(bool value) async {
    var parameters = <String, dynamic>{
      'value': value,
    };
    await _client.send('Emulation.setScriptExecutionDisabled', parameters);
  }

  /// Enables touch on platforms which do not support them.
  /// [enabled] Whether the touch event emulation should be enabled.
  /// [maxTouchPoints] Maximum touch points supported. Defaults to one.
  Future<void> setTouchEmulationEnabled(bool enabled,
      {int maxTouchPoints}) async {
    var parameters = <String, dynamic>{
      'enabled': enabled,
    };
    if (maxTouchPoints != null) {
      parameters['maxTouchPoints'] = maxTouchPoints;
    }
    await _client.send('Emulation.setTouchEmulationEnabled', parameters);
  }

  /// Turns on virtual time for all frames (replacing real-time with a synthetic time source) and sets
  /// the current virtual time policy.  Note this supersedes any previous time budget.
  /// [budget] If set, after this many virtual milliseconds have elapsed virtual time will be paused and a
  /// virtualTimeBudgetExpired event is sent.
  /// [maxVirtualTimeTaskStarvationCount] If set this specifies the maximum number of tasks that can be run before virtual is forced
  /// forwards to prevent deadlock.
  /// [waitForNavigation] If set the virtual time policy change should be deferred until any frame starts navigating.
  /// Note any previous deferred policy change is superseded.
  /// [initialVirtualTime] If set, base::Time::Now will be overriden to initially return this value.
  /// Returns: Absolute timestamp at which virtual time was first enabled (up time in milliseconds).
  Future<num> setVirtualTimePolicy(VirtualTimePolicy policy,
      {num budget,
      int maxVirtualTimeTaskStarvationCount,
      bool waitForNavigation,
      network.TimeSinceEpoch initialVirtualTime}) async {
    var parameters = <String, dynamic>{
      'policy': policy.toJson(),
    };
    if (budget != null) {
      parameters['budget'] = budget;
    }
    if (maxVirtualTimeTaskStarvationCount != null) {
      parameters['maxVirtualTimeTaskStarvationCount'] =
          maxVirtualTimeTaskStarvationCount;
    }
    if (waitForNavigation != null) {
      parameters['waitForNavigation'] = waitForNavigation;
    }
    if (initialVirtualTime != null) {
      parameters['initialVirtualTime'] = initialVirtualTime.toJson();
    }
    var result =
        await _client.send('Emulation.setVirtualTimePolicy', parameters);
    return result['virtualTimeTicksBase'];
  }

  /// Resizes the frame/viewport of the page. Note that this does not affect the frame's container
  /// (e.g. browser window). Can be used to produce screenshots of the specified size. Not supported
  /// on Android.
  /// [width] Frame width (DIP).
  /// [height] Frame height (DIP).
  @deprecated
  Future<void> setVisibleSize(int width, int height) async {
    var parameters = <String, dynamic>{
      'width': width,
      'height': height,
    };
    await _client.send('Emulation.setVisibleSize', parameters);
  }

  /// Allows overriding user agent with the given string.
  /// [userAgent] User agent to use.
  /// [acceptLanguage] Browser langugage to emulate.
  /// [platform] The platform navigator.platform should return.
  Future<void> setUserAgentOverride(String userAgent,
      {String acceptLanguage, String platform}) async {
    var parameters = <String, dynamic>{
      'userAgent': userAgent,
    };
    if (acceptLanguage != null) {
      parameters['acceptLanguage'] = acceptLanguage;
    }
    if (platform != null) {
      parameters['platform'] = platform;
    }
    await _client.send('Emulation.setUserAgentOverride', parameters);
  }
}

/// Screen orientation.
class ScreenOrientation {
  /// Orientation type.
  final ScreenOrientationType type;

  /// Orientation angle.
  final int angle;

  ScreenOrientation({@required this.type, @required this.angle});

  factory ScreenOrientation.fromJson(Map<String, dynamic> json) {
    return ScreenOrientation(
      type: ScreenOrientationType.fromJson(json['type']),
      angle: json['angle'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'type': type,
      'angle': angle,
    };
    return json;
  }
}

class ScreenOrientationType {
  static const ScreenOrientationType portraitPrimary =
      ScreenOrientationType._('portraitPrimary');
  static const ScreenOrientationType portraitSecondary =
      ScreenOrientationType._('portraitSecondary');
  static const ScreenOrientationType landscapePrimary =
      ScreenOrientationType._('landscapePrimary');
  static const ScreenOrientationType landscapeSecondary =
      ScreenOrientationType._('landscapeSecondary');
  static const values = {
    'portraitPrimary': portraitPrimary,
    'portraitSecondary': portraitSecondary,
    'landscapePrimary': landscapePrimary,
    'landscapeSecondary': landscapeSecondary,
  };

  final String value;

  const ScreenOrientationType._(this.value);

  factory ScreenOrientationType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ScreenOrientationType && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// advance: If the scheduler runs out of immediate work, the virtual time base may fast forward to
/// allow the next delayed task (if any) to run; pause: The virtual time base may not advance;
/// pauseIfNetworkFetchesPending: The virtual time base may not advance if there are any pending
/// resource fetches.
class VirtualTimePolicy {
  static const VirtualTimePolicy advance = VirtualTimePolicy._('advance');
  static const VirtualTimePolicy pause = VirtualTimePolicy._('pause');
  static const VirtualTimePolicy pauseIfNetworkFetchesPending =
      VirtualTimePolicy._('pauseIfNetworkFetchesPending');
  static const values = {
    'advance': advance,
    'pause': pause,
    'pauseIfNetworkFetchesPending': pauseIfNetworkFetchesPending,
  };

  final String value;

  const VirtualTimePolicy._(this.value);

  factory VirtualTimePolicy.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is VirtualTimePolicy && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
