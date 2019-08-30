import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'target.dart' as target;

/// The Browser domain defines methods and events for browser managing.
class BrowserApi {
  final Client _client;

  BrowserApi(this._client);

  /// Set permission settings for given origin.
  /// [origin] Origin the permission applies to.
  /// [permission] Descriptor of permission to override.
  /// [setting] Setting of the permission.
  /// [browserContextId] Context to override. When omitted, default browser context is used.
  Future<void> setPermission(
      String origin, PermissionDescriptor permission, PermissionSetting setting,
      {target.TargetID browserContextId}) async {
    await _client.send('Browser.setPermission', {
      'origin': origin,
      'permission': permission,
      'setting': setting,
      if (browserContextId != null) 'browserContextId': browserContextId,
    });
  }

  /// Grant specific permissions to the given origin and reject all others.
  /// [browserContextId] BrowserContext to override permissions. When omitted, default browser context is used.
  Future<void> grantPermissions(String origin, List<PermissionType> permissions,
      {target.BrowserContextID browserContextId}) async {
    await _client.send('Browser.grantPermissions', {
      'origin': origin,
      'permissions': [...permissions],
      if (browserContextId != null) 'browserContextId': browserContextId,
    });
  }

  /// Reset all permission management for all origins.
  /// [browserContextId] BrowserContext to reset permissions. When omitted, default browser context is used.
  Future<void> resetPermissions(
      {target.BrowserContextID browserContextId}) async {
    await _client.send('Browser.resetPermissions', {
      if (browserContextId != null) 'browserContextId': browserContextId,
    });
  }

  /// Close browser gracefully.
  Future<void> close() async {
    await _client.send('Browser.close');
  }

  /// Crashes browser on the main thread.
  Future<void> crash() async {
    await _client.send('Browser.crash');
  }

  /// Crashes GPU process.
  Future<void> crashGpuProcess() async {
    await _client.send('Browser.crashGpuProcess');
  }

  /// Returns version information.
  Future<GetVersionResult> getVersion() async {
    var result = await _client.send('Browser.getVersion');
    return GetVersionResult.fromJson(result);
  }

  /// Returns the command line switches for the browser process if, and only if
  /// --enable-automation is on the commandline.
  /// Returns: Commandline parameters
  Future<List<String>> getBrowserCommandLine() async {
    var result = await _client.send('Browser.getBrowserCommandLine');
    return (result['arguments'] as List).map((e) => e as String).toList();
  }

  /// Get Chrome histograms.
  /// [query] Requested substring in name. Only histograms which have query as a
  /// substring in their name are extracted. An empty or absent query returns
  /// all histograms.
  /// [delta] If true, retrieve delta since last call.
  /// Returns: Histograms.
  Future<List<Histogram>> getHistograms({String query, bool delta}) async {
    var result = await _client.send('Browser.getHistograms', {
      if (query != null) 'query': query,
      if (delta != null) 'delta': delta,
    });
    return (result['histograms'] as List)
        .map((e) => Histogram.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get a Chrome histogram by name.
  /// [name] Requested histogram name.
  /// [delta] If true, retrieve delta since last call.
  /// Returns: Histogram.
  Future<Histogram> getHistogram(String name, {bool delta}) async {
    var result = await _client.send('Browser.getHistogram', {
      'name': name,
      if (delta != null) 'delta': delta,
    });
    return Histogram.fromJson(result['histogram'] as Map<String, dynamic>);
  }

  /// Get position and size of the browser window.
  /// [windowId] Browser window id.
  /// Returns: Bounds information of the window. When window state is 'minimized', the restored window
  /// position and size are returned.
  Future<Bounds> getWindowBounds(WindowID windowId) async {
    var result = await _client.send('Browser.getWindowBounds', {
      'windowId': windowId,
    });
    return Bounds.fromJson(result['bounds'] as Map<String, dynamic>);
  }

  /// Get the browser window that contains the devtools target.
  /// [targetId] Devtools agent host id. If called as a part of the session, associated targetId is used.
  Future<GetWindowForTargetResult> getWindowForTarget(
      {target.TargetID targetId}) async {
    var result = await _client.send('Browser.getWindowForTarget', {
      if (targetId != null) 'targetId': targetId,
    });
    return GetWindowForTargetResult.fromJson(result);
  }

  /// Set position and/or size of the browser window.
  /// [windowId] Browser window id.
  /// [bounds] New window bounds. The 'minimized', 'maximized' and 'fullscreen' states cannot be combined
  /// with 'left', 'top', 'width' or 'height'. Leaves unspecified fields unchanged.
  Future<void> setWindowBounds(WindowID windowId, Bounds bounds) async {
    await _client.send('Browser.setWindowBounds', {
      'windowId': windowId,
      'bounds': bounds,
    });
  }

  /// Set dock tile details, platform-specific.
  /// [image] Png encoded image.
  Future<void> setDockTile({String badgeLabel, String image}) async {
    await _client.send('Browser.setDockTile', {
      if (badgeLabel != null) 'badgeLabel': badgeLabel,
      if (image != null) 'image': image,
    });
  }
}

class GetVersionResult {
  /// Protocol version.
  final String protocolVersion;

  /// Product name.
  final String product;

  /// Product revision.
  final String revision;

  /// User-Agent.
  final String userAgent;

  /// V8 version.
  final String jsVersion;

  GetVersionResult(
      {@required this.protocolVersion,
      @required this.product,
      @required this.revision,
      @required this.userAgent,
      @required this.jsVersion});

  factory GetVersionResult.fromJson(Map<String, dynamic> json) {
    return GetVersionResult(
      protocolVersion: json['protocolVersion'] as String,
      product: json['product'] as String,
      revision: json['revision'] as String,
      userAgent: json['userAgent'] as String,
      jsVersion: json['jsVersion'] as String,
    );
  }
}

class GetWindowForTargetResult {
  /// Browser window id.
  final WindowID windowId;

  /// Bounds information of the window. When window state is 'minimized', the restored window
  /// position and size are returned.
  final Bounds bounds;

  GetWindowForTargetResult({@required this.windowId, @required this.bounds});

  factory GetWindowForTargetResult.fromJson(Map<String, dynamic> json) {
    return GetWindowForTargetResult(
      windowId: WindowID.fromJson(json['windowId'] as int),
      bounds: Bounds.fromJson(json['bounds'] as Map<String, dynamic>),
    );
  }
}

class WindowID {
  final int value;

  WindowID(this.value);

  factory WindowID.fromJson(int value) => WindowID(value);

  int toJson() => value;

  @override
  bool operator ==(other) =>
      (other is WindowID && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// The state of the browser window.
class WindowState {
  static const normal = WindowState._('normal');
  static const minimized = WindowState._('minimized');
  static const maximized = WindowState._('maximized');
  static const fullscreen = WindowState._('fullscreen');
  static const values = {
    'normal': normal,
    'minimized': minimized,
    'maximized': maximized,
    'fullscreen': fullscreen,
  };

  final String value;

  const WindowState._(this.value);

  factory WindowState.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is WindowState && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Browser window bounds information
class Bounds {
  /// The offset from the left edge of the screen to the window in pixels.
  final int left;

  /// The offset from the top edge of the screen to the window in pixels.
  final int top;

  /// The window width in pixels.
  final int width;

  /// The window height in pixels.
  final int height;

  /// The window state. Default to normal.
  final WindowState windowState;

  Bounds({this.left, this.top, this.width, this.height, this.windowState});

  factory Bounds.fromJson(Map<String, dynamic> json) {
    return Bounds(
      left: json.containsKey('left') ? json['left'] as int : null,
      top: json.containsKey('top') ? json['top'] as int : null,
      width: json.containsKey('width') ? json['width'] as int : null,
      height: json.containsKey('height') ? json['height'] as int : null,
      windowState: json.containsKey('windowState')
          ? WindowState.fromJson(json['windowState'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (left != null) 'left': left,
      if (top != null) 'top': top,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (windowState != null) 'windowState': windowState.toJson(),
    };
  }
}

class PermissionType {
  static const accessibilityEvents = PermissionType._('accessibilityEvents');
  static const audioCapture = PermissionType._('audioCapture');
  static const backgroundSync = PermissionType._('backgroundSync');
  static const backgroundFetch = PermissionType._('backgroundFetch');
  static const clipboardRead = PermissionType._('clipboardRead');
  static const clipboardWrite = PermissionType._('clipboardWrite');
  static const durableStorage = PermissionType._('durableStorage');
  static const flash = PermissionType._('flash');
  static const geolocation = PermissionType._('geolocation');
  static const midi = PermissionType._('midi');
  static const midiSysex = PermissionType._('midiSysex');
  static const notifications = PermissionType._('notifications');
  static const paymentHandler = PermissionType._('paymentHandler');
  static const periodicBackgroundSync =
      PermissionType._('periodicBackgroundSync');
  static const protectedMediaIdentifier =
      PermissionType._('protectedMediaIdentifier');
  static const sensors = PermissionType._('sensors');
  static const videoCapture = PermissionType._('videoCapture');
  static const idleDetection = PermissionType._('idleDetection');
  static const wakeLockScreen = PermissionType._('wakeLockScreen');
  static const wakeLockSystem = PermissionType._('wakeLockSystem');
  static const values = {
    'accessibilityEvents': accessibilityEvents,
    'audioCapture': audioCapture,
    'backgroundSync': backgroundSync,
    'backgroundFetch': backgroundFetch,
    'clipboardRead': clipboardRead,
    'clipboardWrite': clipboardWrite,
    'durableStorage': durableStorage,
    'flash': flash,
    'geolocation': geolocation,
    'midi': midi,
    'midiSysex': midiSysex,
    'notifications': notifications,
    'paymentHandler': paymentHandler,
    'periodicBackgroundSync': periodicBackgroundSync,
    'protectedMediaIdentifier': protectedMediaIdentifier,
    'sensors': sensors,
    'videoCapture': videoCapture,
    'idleDetection': idleDetection,
    'wakeLockScreen': wakeLockScreen,
    'wakeLockSystem': wakeLockSystem,
  };

  final String value;

  const PermissionType._(this.value);

  factory PermissionType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is PermissionType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class PermissionSetting {
  static const granted = PermissionSetting._('granted');
  static const denied = PermissionSetting._('denied');
  static const prompt = PermissionSetting._('prompt');
  static const values = {
    'granted': granted,
    'denied': denied,
    'prompt': prompt,
  };

  final String value;

  const PermissionSetting._(this.value);

  factory PermissionSetting.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is PermissionSetting && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Definition of PermissionDescriptor defined in the Permissions API:
/// https://w3c.github.io/permissions/#dictdef-permissiondescriptor.
class PermissionDescriptor {
  /// Name of permission.
  /// See https://cs.chromium.org/chromium/src/third_party/blink/renderer/modules/permissions/permission_descriptor.idl for valid permission names.
  final String name;

  /// For "midi" permission, may also specify sysex control.
  final bool sysex;

  /// For "push" permission, may specify userVisibleOnly.
  /// Note that userVisibleOnly = true is the only currently supported type.
  final bool userVisibleOnly;

  /// For "wake-lock" permission, must specify type as either "screen" or "system".
  final String type;

  PermissionDescriptor(
      {@required this.name, this.sysex, this.userVisibleOnly, this.type});

  factory PermissionDescriptor.fromJson(Map<String, dynamic> json) {
    return PermissionDescriptor(
      name: json['name'] as String,
      sysex: json.containsKey('sysex') ? json['sysex'] as bool : null,
      userVisibleOnly: json.containsKey('userVisibleOnly')
          ? json['userVisibleOnly'] as bool
          : null,
      type: json.containsKey('type') ? json['type'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (sysex != null) 'sysex': sysex,
      if (userVisibleOnly != null) 'userVisibleOnly': userVisibleOnly,
      if (type != null) 'type': type,
    };
  }
}

/// Chrome histogram bucket.
class Bucket {
  /// Minimum value (inclusive).
  final int low;

  /// Maximum value (exclusive).
  final int high;

  /// Number of samples.
  final int count;

  Bucket({@required this.low, @required this.high, @required this.count});

  factory Bucket.fromJson(Map<String, dynamic> json) {
    return Bucket(
      low: json['low'] as int,
      high: json['high'] as int,
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'low': low,
      'high': high,
      'count': count,
    };
  }
}

/// Chrome histogram.
class Histogram {
  /// Name.
  final String name;

  /// Sum of sample values.
  final int sum;

  /// Total number of samples.
  final int count;

  /// Buckets.
  final List<Bucket> buckets;

  Histogram(
      {@required this.name,
      @required this.sum,
      @required this.count,
      @required this.buckets});

  factory Histogram.fromJson(Map<String, dynamic> json) {
    return Histogram(
      name: json['name'] as String,
      sum: json['sum'] as int,
      count: json['count'] as int,
      buckets: (json['buckets'] as List)
          .map((e) => Bucket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sum': sum,
      'count': count,
      'buckets': buckets.map((e) => e.toJson()).toList(),
    };
  }
}
