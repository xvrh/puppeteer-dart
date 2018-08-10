import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'target.dart' as target;

/// The Browser domain defines methods and events for browser managing.
class BrowserApi {
  final Client _client;

  BrowserApi(this._client);

  /// Close browser gracefully.
  Future close() async {
    await _client.send('Browser.close');
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
    var parameters = <String, dynamic>{};
    if (query != null) {
      parameters['query'] = query;
    }
    if (delta != null) {
      parameters['delta'] = delta;
    }
    var result = await _client.send('Browser.getHistograms', parameters);
    return (result['histograms'] as List)
        .map((e) => Histogram.fromJson(e))
        .toList();
  }

  /// Get a Chrome histogram by name.
  /// [name] Requested histogram name.
  /// [delta] If true, retrieve delta since last call.
  /// Returns: Histogram.
  Future<Histogram> getHistogram(String name, {bool delta}) async {
    var parameters = <String, dynamic>{
      'name': name,
    };
    if (delta != null) {
      parameters['delta'] = delta;
    }
    var result = await _client.send('Browser.getHistogram', parameters);
    return Histogram.fromJson(result['histogram']);
  }

  /// Get position and size of the browser window.
  /// [windowId] Browser window id.
  /// Returns: Bounds information of the window. When window state is 'minimized', the restored window
  /// position and size are returned.
  Future<Bounds> getWindowBounds(WindowID windowId) async {
    var parameters = <String, dynamic>{
      'windowId': windowId.toJson(),
    };
    var result = await _client.send('Browser.getWindowBounds', parameters);
    return Bounds.fromJson(result['bounds']);
  }

  /// Get the browser window that contains the devtools target.
  /// [targetId] Devtools agent host id.
  Future<GetWindowForTargetResult> getWindowForTarget(
      target.TargetID targetId) async {
    var parameters = <String, dynamic>{
      'targetId': targetId.toJson(),
    };
    var result = await _client.send('Browser.getWindowForTarget', parameters);
    return GetWindowForTargetResult.fromJson(result);
  }

  /// Set position and/or size of the browser window.
  /// [windowId] Browser window id.
  /// [bounds] New window bounds. The 'minimized', 'maximized' and 'fullscreen' states cannot be combined
  /// with 'left', 'top', 'width' or 'height'. Leaves unspecified fields unchanged.
  Future setWindowBounds(WindowID windowId, Bounds bounds) async {
    var parameters = <String, dynamic>{
      'windowId': windowId.toJson(),
      'bounds': bounds.toJson(),
    };
    await _client.send('Browser.setWindowBounds', parameters);
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
      protocolVersion: json['protocolVersion'],
      product: json['product'],
      revision: json['revision'],
      userAgent: json['userAgent'],
      jsVersion: json['jsVersion'],
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
      windowId: WindowID.fromJson(json['windowId']),
      bounds: Bounds.fromJson(json['bounds']),
    );
  }
}

class WindowID {
  final int value;

  WindowID(this.value);

  factory WindowID.fromJson(int value) => WindowID(value);

  int toJson() => value;

  @override
  bool operator ==(other) => other is WindowID && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// The state of the browser window.
class WindowState {
  static const WindowState normal = const WindowState._('normal');
  static const WindowState minimized = const WindowState._('minimized');
  static const WindowState maximized = const WindowState._('maximized');
  static const WindowState fullscreen = const WindowState._('fullscreen');
  static const values = const {
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
      left: json.containsKey('left') ? json['left'] : null,
      top: json.containsKey('top') ? json['top'] : null,
      width: json.containsKey('width') ? json['width'] : null,
      height: json.containsKey('height') ? json['height'] : null,
      windowState: json.containsKey('windowState')
          ? WindowState.fromJson(json['windowState'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};
    if (left != null) {
      json['left'] = left;
    }
    if (top != null) {
      json['top'] = top;
    }
    if (width != null) {
      json['width'] = width;
    }
    if (height != null) {
      json['height'] = height;
    }
    if (windowState != null) {
      json['windowState'] = windowState.toJson();
    }
    return json;
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
      low: json['low'],
      high: json['high'],
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'low': low,
      'high': high,
      'count': count,
    };
    return json;
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
      name: json['name'],
      sum: json['sum'],
      count: json['count'],
      buckets:
          (json['buckets'] as List).map((e) => Bucket.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'name': name,
      'sum': sum,
      'count': count,
      'buckets': buckets.map((e) => e.toJson()).toList(),
    };
    return json;
  }
}
