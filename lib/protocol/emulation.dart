import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'dom.dart' as dom;
import 'network.dart' as network;
import 'page.dart' as page;

/// This domain emulates different environments for the page.
class EmulationApi {
  final Client _client;

  EmulationApi(this._client);

  /// Notification sent after the virtual time budget for the current VirtualTimePolicy has run out.
  Stream get onVirtualTimeBudgetExpired => _client.onEvent
      .where((event) => event.name == 'Emulation.virtualTimeBudgetExpired');

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
    await _client.send('Emulation.setFocusEmulationEnabled', {
      'enabled': enabled,
    });
  }

  /// Enables CPU throttling to emulate slow CPUs.
  /// [rate] Throttling rate as a slowdown factor (1 is no throttle, 2 is 2x slowdown, etc).
  Future<void> setCPUThrottlingRate(num rate) async {
    await _client.send('Emulation.setCPUThrottlingRate', {
      'rate': rate,
    });
  }

  /// Sets or clears an override of the default background color of the frame. This override is used
  /// if the content does not specify one.
  /// [color] RGBA of the default background color. If not specified, any existing override will be
  /// cleared.
  Future<void> setDefaultBackgroundColorOverride({dom.RGBA color}) async {
    await _client.send('Emulation.setDefaultBackgroundColorOverride', {
      if (color != null) 'color': color,
    });
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
    await _client.send('Emulation.setDeviceMetricsOverride', {
      'width': width,
      'height': height,
      'deviceScaleFactor': deviceScaleFactor,
      'mobile': mobile,
      if (scale != null) 'scale': scale,
      if (screenWidth != null) 'screenWidth': screenWidth,
      if (screenHeight != null) 'screenHeight': screenHeight,
      if (positionX != null) 'positionX': positionX,
      if (positionY != null) 'positionY': positionY,
      if (dontSetVisibleSize != null) 'dontSetVisibleSize': dontSetVisibleSize,
      if (screenOrientation != null) 'screenOrientation': screenOrientation,
      if (viewport != null) 'viewport': viewport,
    });
  }

  /// [hidden] Whether scrollbars should be always hidden.
  Future<void> setScrollbarsHidden(bool hidden) async {
    await _client.send('Emulation.setScrollbarsHidden', {
      'hidden': hidden,
    });
  }

  /// [disabled] Whether document.coookie API should be disabled.
  Future<void> setDocumentCookieDisabled(bool disabled) async {
    await _client.send('Emulation.setDocumentCookieDisabled', {
      'disabled': disabled,
    });
  }

  /// [enabled] Whether touch emulation based on mouse input should be enabled.
  /// [configuration] Touch/gesture events configuration. Default: current platform.
  Future<void> setEmitTouchEventsForMouse(bool enabled,
      {@Enum(['mobile', 'desktop']) String configuration}) async {
    assert(configuration == null ||
        const ['mobile', 'desktop'].contains(configuration));
    await _client.send('Emulation.setEmitTouchEventsForMouse', {
      'enabled': enabled,
      if (configuration != null) 'configuration': configuration,
    });
  }

  /// Emulates the given media for CSS media queries.
  /// [media] Media type to emulate. Empty string disables the override.
  Future<void> setEmulatedMedia(String media) async {
    await _client.send('Emulation.setEmulatedMedia', {
      'media': media,
    });
  }

  /// Overrides the Geolocation Position or Error. Omitting any of the parameters emulates position
  /// unavailable.
  /// [latitude] Mock latitude
  /// [longitude] Mock longitude
  /// [accuracy] Mock accuracy
  Future<void> setGeolocationOverride(
      {num latitude, num longitude, num accuracy}) async {
    await _client.send('Emulation.setGeolocationOverride', {
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
    });
  }

  /// Overrides value returned by the javascript navigator object.
  /// [platform] The platform navigator.platform should return.
  @deprecated
  Future<void> setNavigatorOverrides(String platform) async {
    await _client.send('Emulation.setNavigatorOverrides', {
      'platform': platform,
    });
  }

  /// Sets a specified page scale factor.
  /// [pageScaleFactor] Page scale factor.
  Future<void> setPageScaleFactor(num pageScaleFactor) async {
    await _client.send('Emulation.setPageScaleFactor', {
      'pageScaleFactor': pageScaleFactor,
    });
  }

  /// Switches script execution in the page.
  /// [value] Whether script execution should be disabled in the page.
  Future<void> setScriptExecutionDisabled(bool value) async {
    await _client.send('Emulation.setScriptExecutionDisabled', {
      'value': value,
    });
  }

  /// Enables touch on platforms which do not support them.
  /// [enabled] Whether the touch event emulation should be enabled.
  /// [maxTouchPoints] Maximum touch points supported. Defaults to one.
  Future<void> setTouchEmulationEnabled(bool enabled,
      {int maxTouchPoints}) async {
    await _client.send('Emulation.setTouchEmulationEnabled', {
      'enabled': enabled,
      if (maxTouchPoints != null) 'maxTouchPoints': maxTouchPoints,
    });
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
    var result = await _client.send('Emulation.setVirtualTimePolicy', {
      'policy': policy,
      if (budget != null) 'budget': budget,
      if (maxVirtualTimeTaskStarvationCount != null)
        'maxVirtualTimeTaskStarvationCount': maxVirtualTimeTaskStarvationCount,
      if (waitForNavigation != null) 'waitForNavigation': waitForNavigation,
      if (initialVirtualTime != null) 'initialVirtualTime': initialVirtualTime,
    });
    return result['virtualTimeTicksBase'];
  }

  /// Overrides default host system timezone with the specified one.
  /// [timezoneId] The timezone identifier. If empty, disables the override and
  /// restores default host system timezone.
  Future<void> setTimezoneOverride(String timezoneId) async {
    await _client.send('Emulation.setTimezoneOverride', {
      'timezoneId': timezoneId,
    });
  }

  /// Resizes the frame/viewport of the page. Note that this does not affect the frame's container
  /// (e.g. browser window). Can be used to produce screenshots of the specified size. Not supported
  /// on Android.
  /// [width] Frame width (DIP).
  /// [height] Frame height (DIP).
  @deprecated
  Future<void> setVisibleSize(int width, int height) async {
    await _client.send('Emulation.setVisibleSize', {
      'width': width,
      'height': height,
    });
  }

  /// Allows overriding user agent with the given string.
  /// [userAgent] User agent to use.
  /// [acceptLanguage] Browser langugage to emulate.
  /// [platform] The platform navigator.platform should return.
  Future<void> setUserAgentOverride(String userAgent,
      {String acceptLanguage, String platform}) async {
    await _client.send('Emulation.setUserAgentOverride', {
      'userAgent': userAgent,
      if (acceptLanguage != null) 'acceptLanguage': acceptLanguage,
      if (platform != null) 'platform': platform,
    });
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
    return {
      'type': type,
      'angle': angle,
    };
  }
}

class ScreenOrientationType {
  static const portraitPrimary = ScreenOrientationType._('portraitPrimary');
  static const portraitSecondary = ScreenOrientationType._('portraitSecondary');
  static const landscapePrimary = ScreenOrientationType._('landscapePrimary');
  static const landscapeSecondary =
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
  static const advance = VirtualTimePolicy._('advance');
  static const pause = VirtualTimePolicy._('pause');
  static const pauseIfNetworkFetchesPending =
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
