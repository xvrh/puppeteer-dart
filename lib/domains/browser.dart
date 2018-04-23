/// The Browser domain defines methods and events for browser managing.

import 'dart:async';
// ignore: unused_import
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'target.dart' as target;

class BrowserDomain {
  final Client _client;

  BrowserDomain(this._client);

  /// Close browser gracefully.
  Future close() async {
    await _client.send('Browser.close');
  }

  /// Returns version information.
  Future<GetVersionResult> getVersion() async {
    Map result = await _client.send('Browser.getVersion');
    return new GetVersionResult.fromJson(result);
  }

  /// Returns the command line switches for the browser process if, and only if
  /// --enable-automation is on the commandline.
  /// Return: Commandline parameters
  Future<List<String>> getBrowserCommandLine() async {
    Map result = await _client.send('Browser.getBrowserCommandLine');
    return (result['arguments'] as List).map((e) => e as String).toList();
  }

  /// Get Chrome histograms.
  /// [query] Requested substring in name. Only histograms which have query as a
  /// substring in their name are extracted. An empty or absent query returns
  /// all histograms.
  /// Return: Histograms.
  Future<List<Histogram>> getHistograms({
    String query,
  }) async {
    Map parameters = {};
    if (query != null) {
      parameters['query'] = query;
    }
    Map result = await _client.send('Browser.getHistograms', parameters);
    return (result['histograms'] as List)
        .map((e) => new Histogram.fromJson(e))
        .toList();
  }

  /// Get a Chrome histogram by name.
  /// [name] Requested histogram name.
  /// Return: Histogram.
  Future<Histogram> getHistogram(
    String name,
  ) async {
    Map parameters = {
      'name': name,
    };
    Map result = await _client.send('Browser.getHistogram', parameters);
    return new Histogram.fromJson(result['histogram']);
  }

  /// Get position and size of the browser window.
  /// [windowId] Browser window id.
  /// Return: Bounds information of the window. When window state is 'minimized', the restored window
  /// position and size are returned.
  Future<Bounds> getWindowBounds(
    WindowID windowId,
  ) async {
    Map parameters = {
      'windowId': windowId.toJson(),
    };
    Map result = await _client.send('Browser.getWindowBounds', parameters);
    return new Bounds.fromJson(result['bounds']);
  }

  /// Get the browser window that contains the devtools target.
  /// [targetId] Devtools agent host id.
  Future<GetWindowForTargetResult> getWindowForTarget(
    target.TargetID targetId,
  ) async {
    Map parameters = {
      'targetId': targetId.toJson(),
    };
    Map result = await _client.send('Browser.getWindowForTarget', parameters);
    return new GetWindowForTargetResult.fromJson(result);
  }

  /// Set position and/or size of the browser window.
  /// [windowId] Browser window id.
  /// [bounds] New window bounds. The 'minimized', 'maximized' and 'fullscreen' states cannot be combined
  /// with 'left', 'top', 'width' or 'height'. Leaves unspecified fields unchanged.
  Future setWindowBounds(
    WindowID windowId,
    Bounds bounds,
  ) async {
    Map parameters = {
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

  GetVersionResult({
    @required this.protocolVersion,
    @required this.product,
    @required this.revision,
    @required this.userAgent,
    @required this.jsVersion,
  });

  factory GetVersionResult.fromJson(Map json) {
    return new GetVersionResult(
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

  GetWindowForTargetResult({
    @required this.windowId,
    @required this.bounds,
  });

  factory GetWindowForTargetResult.fromJson(Map json) {
    return new GetWindowForTargetResult(
      windowId: new WindowID.fromJson(json['windowId']),
      bounds: new Bounds.fromJson(json['bounds']),
    );
  }
}

class WindowID {
  final int value;

  WindowID(this.value);

  factory WindowID.fromJson(int value) => new WindowID(value);

  int toJson() => value;

  bool operator ==(other) => other is WindowID && other.value == value;

  int get hashCode => value.hashCode;

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

  Bounds({
    this.left,
    this.top,
    this.width,
    this.height,
    this.windowState,
  });

  factory Bounds.fromJson(Map json) {
    return new Bounds(
      left: json.containsKey('left') ? json['left'] : null,
      top: json.containsKey('top') ? json['top'] : null,
      width: json.containsKey('width') ? json['width'] : null,
      height: json.containsKey('height') ? json['height'] : null,
      windowState: json.containsKey('windowState')
          ? new WindowState.fromJson(json['windowState'])
          : null,
    );
  }

  Map toJson() {
    Map json = {};
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

  Bucket({
    @required this.low,
    @required this.high,
    @required this.count,
  });

  factory Bucket.fromJson(Map json) {
    return new Bucket(
      low: json['low'],
      high: json['high'],
      count: json['count'],
    );
  }

  Map toJson() {
    Map json = {
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

  Histogram({
    @required this.name,
    @required this.sum,
    @required this.count,
    @required this.buckets,
  });

  factory Histogram.fromJson(Map json) {
    return new Histogram(
      name: json['name'],
      sum: json['sum'],
      count: json['count'],
      buckets:
          (json['buckets'] as List).map((e) => new Bucket.fromJson(e)).toList(),
    );
  }

  Map toJson() {
    Map json = {
      'name': name,
      'sum': sum,
      'count': count,
      'buckets': buckets.map((e) => e.toJson()).toList(),
    };
    return json;
  }
}
