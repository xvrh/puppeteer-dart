import 'dart:async';
import '../src/connection.dart';
import 'page.dart' as page;
import 'target.dart' as target;

/// The Browser domain defines methods and events for browser managing.
class BrowserApi {
  final Client _client;

  BrowserApi(this._client);

  /// Fired when page is about to start a download.
  Stream<DownloadWillBeginEvent> get onDownloadWillBegin => _client.onEvent
      .where((event) => event.name == 'Browser.downloadWillBegin')
      .map((event) => DownloadWillBeginEvent.fromJson(event.parameters));

  /// Fired when download makes progress. Last call has |done| == true.
  Stream<DownloadProgressEvent> get onDownloadProgress => _client.onEvent
      .where((event) => event.name == 'Browser.downloadProgress')
      .map((event) => DownloadProgressEvent.fromJson(event.parameters));

  /// Set permission settings for given origin.
  /// [permission] Descriptor of permission to override.
  /// [setting] Setting of the permission.
  /// [origin] Origin the permission applies to, all origins if not specified.
  /// [browserContextId] Context to override. When omitted, default browser context is used.
  Future<void> setPermission(
    PermissionDescriptor permission,
    PermissionSetting setting, {
    String? origin,
    BrowserContextID? browserContextId,
  }) async {
    await _client.send('Browser.setPermission', {
      'permission': permission,
      'setting': setting,
      if (origin != null) 'origin': origin,
      if (browserContextId != null) 'browserContextId': browserContextId,
    });
  }

  /// Grant specific permissions to the given origin and reject all others.
  /// [origin] Origin the permission applies to, all origins if not specified.
  /// [browserContextId] BrowserContext to override permissions. When omitted, default browser context is used.
  Future<void> grantPermissions(
    List<PermissionType> permissions, {
    String? origin,
    BrowserContextID? browserContextId,
  }) async {
    await _client.send('Browser.grantPermissions', {
      'permissions': [...permissions],
      if (origin != null) 'origin': origin,
      if (browserContextId != null) 'browserContextId': browserContextId,
    });
  }

  /// Reset all permission management for all origins.
  /// [browserContextId] BrowserContext to reset permissions. When omitted, default browser context is used.
  Future<void> resetPermissions({BrowserContextID? browserContextId}) async {
    await _client.send('Browser.resetPermissions', {
      if (browserContextId != null) 'browserContextId': browserContextId,
    });
  }

  /// Set the behavior when downloading a file.
  /// [behavior] Whether to allow all or deny all download requests, or use default Chrome behavior if
  /// available (otherwise deny). |allowAndName| allows download and names files according to
  /// their download guids.
  /// [browserContextId] BrowserContext to set download behavior. When omitted, default browser context is used.
  /// [downloadPath] The default path to save downloaded files to. This is required if behavior is set to 'allow'
  /// or 'allowAndName'.
  /// [eventsEnabled] Whether to emit download events (defaults to false).
  Future<void> setDownloadBehavior(
    @Enum(['deny', 'allow', 'allowAndName', 'default']) String behavior, {
    BrowserContextID? browserContextId,
    String? downloadPath,
    bool? eventsEnabled,
  }) async {
    assert(
      const ['deny', 'allow', 'allowAndName', 'default'].contains(behavior),
    );
    await _client.send('Browser.setDownloadBehavior', {
      'behavior': behavior,
      if (browserContextId != null) 'browserContextId': browserContextId,
      if (downloadPath != null) 'downloadPath': downloadPath,
      if (eventsEnabled != null) 'eventsEnabled': eventsEnabled,
    });
  }

  /// Cancel a download if in progress
  /// [guid] Global unique identifier of the download.
  /// [browserContextId] BrowserContext to perform the action in. When omitted, default browser context is used.
  Future<void> cancelDownload(
    String guid, {
    BrowserContextID? browserContextId,
  }) async {
    await _client.send('Browser.cancelDownload', {
      'guid': guid,
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
  /// [delta] If true, retrieve delta since last delta call.
  /// Returns: Histograms.
  Future<List<Histogram>> getHistograms({String? query, bool? delta}) async {
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
  /// [delta] If true, retrieve delta since last delta call.
  /// Returns: Histogram.
  Future<Histogram> getHistogram(String name, {bool? delta}) async {
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
  Future<GetWindowForTargetResult> getWindowForTarget({
    target.TargetID? targetId,
  }) async {
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

  /// Set size of the browser contents resizing browser window as necessary.
  /// [windowId] Browser window id.
  /// [width] The window contents width in DIP. Assumes current width if omitted.
  /// Must be specified if 'height' is omitted.
  /// [height] The window contents height in DIP. Assumes current height if omitted.
  /// Must be specified if 'width' is omitted.
  Future<void> setContentsSize(
    WindowID windowId, {
    int? width,
    int? height,
  }) async {
    await _client.send('Browser.setContentsSize', {
      'windowId': windowId,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
    });
  }

  /// Set dock tile details, platform-specific.
  /// [image] Png encoded image.
  Future<void> setDockTile({String? badgeLabel, String? image}) async {
    await _client.send('Browser.setDockTile', {
      if (badgeLabel != null) 'badgeLabel': badgeLabel,
      if (image != null) 'image': image,
    });
  }

  /// Invoke custom browser commands used by telemetry.
  Future<void> executeBrowserCommand(BrowserCommandId commandId) async {
    await _client.send('Browser.executeBrowserCommand', {
      'commandId': commandId,
    });
  }

  /// Allows a site to use privacy sandbox features that require enrollment
  /// without the site actually being enrolled. Only supported on page targets.
  Future<void> addPrivacySandboxEnrollmentOverride(String url) async {
    await _client.send('Browser.addPrivacySandboxEnrollmentOverride', {
      'url': url,
    });
  }

  /// Configures encryption keys used with a given privacy sandbox API to talk
  /// to a trusted coordinator.  Since this is intended for test automation only,
  /// coordinatorOrigin must be a .test domain. No existing coordinator
  /// configuration for the origin may exist.
  /// [browserContextId] BrowserContext to perform the action in. When omitted, default browser
  /// context is used.
  Future<void> addPrivacySandboxCoordinatorKeyConfig(
    PrivacySandboxAPI api,
    String coordinatorOrigin,
    String keyConfig, {
    BrowserContextID? browserContextId,
  }) async {
    await _client.send('Browser.addPrivacySandboxCoordinatorKeyConfig', {
      'api': api,
      'coordinatorOrigin': coordinatorOrigin,
      'keyConfig': keyConfig,
      if (browserContextId != null) 'browserContextId': browserContextId,
    });
  }
}

class DownloadWillBeginEvent {
  /// Id of the frame that caused the download to begin.
  final page.FrameId frameId;

  /// Global unique identifier of the download.
  final String guid;

  /// URL of the resource being downloaded.
  final String url;

  /// Suggested file name of the resource (the actual name of the file saved on disk may differ).
  final String suggestedFilename;

  DownloadWillBeginEvent({
    required this.frameId,
    required this.guid,
    required this.url,
    required this.suggestedFilename,
  });

  factory DownloadWillBeginEvent.fromJson(Map<String, dynamic> json) {
    return DownloadWillBeginEvent(
      frameId: page.FrameId.fromJson(json['frameId'] as String),
      guid: json['guid'] as String,
      url: json['url'] as String,
      suggestedFilename: json['suggestedFilename'] as String,
    );
  }
}

class DownloadProgressEvent {
  /// Global unique identifier of the download.
  final String guid;

  /// Total expected bytes to download.
  final num totalBytes;

  /// Total bytes received.
  final num receivedBytes;

  /// Download status.
  final DownloadProgressEventState state;

  /// If download is "completed", provides the path of the downloaded file.
  /// Depending on the platform, it is not guaranteed to be set, nor the file
  /// is guaranteed to exist.
  final String? filePath;

  DownloadProgressEvent({
    required this.guid,
    required this.totalBytes,
    required this.receivedBytes,
    required this.state,
    this.filePath,
  });

  factory DownloadProgressEvent.fromJson(Map<String, dynamic> json) {
    return DownloadProgressEvent(
      guid: json['guid'] as String,
      totalBytes: json['totalBytes'] as num,
      receivedBytes: json['receivedBytes'] as num,
      state: DownloadProgressEventState.fromJson(json['state'] as String),
      filePath: json.containsKey('filePath')
          ? json['filePath'] as String
          : null,
    );
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
    required this.protocolVersion,
    required this.product,
    required this.revision,
    required this.userAgent,
    required this.jsVersion,
  });

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

  GetWindowForTargetResult({required this.windowId, required this.bounds});

  factory GetWindowForTargetResult.fromJson(Map<String, dynamic> json) {
    return GetWindowForTargetResult(
      windowId: WindowID.fromJson(json['windowId'] as int),
      bounds: Bounds.fromJson(json['bounds'] as Map<String, dynamic>),
    );
  }
}

extension type BrowserContextID(String value) {
  factory BrowserContextID.fromJson(String value) => BrowserContextID(value);

  String toJson() => value;
}

extension type WindowID(int value) {
  factory WindowID.fromJson(int value) => WindowID(value);

  int toJson() => value;
}

/// The state of the browser window.
enum WindowState {
  normal('normal'),
  minimized('minimized'),
  maximized('maximized'),
  fullscreen('fullscreen');

  final String value;

  const WindowState(this.value);

  factory WindowState.fromJson(String value) =>
      WindowState.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Browser window bounds information
class Bounds {
  /// The offset from the left edge of the screen to the window in pixels.
  final int? left;

  /// The offset from the top edge of the screen to the window in pixels.
  final int? top;

  /// The window width in pixels.
  final int? width;

  /// The window height in pixels.
  final int? height;

  /// The window state. Default to normal.
  final WindowState? windowState;

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
      if (windowState != null) 'windowState': windowState!.toJson(),
    };
  }
}

enum PermissionType {
  ar('ar'),
  audioCapture('audioCapture'),
  automaticFullscreen('automaticFullscreen'),
  backgroundFetch('backgroundFetch'),
  backgroundSync('backgroundSync'),
  cameraPanTiltZoom('cameraPanTiltZoom'),
  capturedSurfaceControl('capturedSurfaceControl'),
  clipboardReadWrite('clipboardReadWrite'),
  clipboardSanitizedWrite('clipboardSanitizedWrite'),
  displayCapture('displayCapture'),
  durableStorage('durableStorage'),
  geolocation('geolocation'),
  handTracking('handTracking'),
  idleDetection('idleDetection'),
  keyboardLock('keyboardLock'),
  localFonts('localFonts'),
  localNetworkAccess('localNetworkAccess'),
  midi('midi'),
  midiSysex('midiSysex'),
  nfc('nfc'),
  notifications('notifications'),
  paymentHandler('paymentHandler'),
  periodicBackgroundSync('periodicBackgroundSync'),
  pointerLock('pointerLock'),
  protectedMediaIdentifier('protectedMediaIdentifier'),
  sensors('sensors'),
  smartCard('smartCard'),
  speakerSelection('speakerSelection'),
  storageAccess('storageAccess'),
  topLevelStorageAccess('topLevelStorageAccess'),
  videoCapture('videoCapture'),
  vr('vr'),
  wakeLockScreen('wakeLockScreen'),
  wakeLockSystem('wakeLockSystem'),
  webAppInstallation('webAppInstallation'),
  webPrinting('webPrinting'),
  windowManagement('windowManagement');

  final String value;

  const PermissionType(this.value);

  factory PermissionType.fromJson(String value) =>
      PermissionType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum PermissionSetting {
  granted('granted'),
  denied('denied'),
  prompt('prompt');

  final String value;

  const PermissionSetting(this.value);

  factory PermissionSetting.fromJson(String value) =>
      PermissionSetting.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Definition of PermissionDescriptor defined in the Permissions API:
/// https://w3c.github.io/permissions/#dom-permissiondescriptor.
class PermissionDescriptor {
  /// Name of permission.
  /// See https://cs.chromium.org/chromium/src/third_party/blink/renderer/modules/permissions/permission_descriptor.idl for valid permission names.
  final String name;

  /// For "midi" permission, may also specify sysex control.
  final bool? sysex;

  /// For "push" permission, may specify userVisibleOnly.
  /// Note that userVisibleOnly = true is the only currently supported type.
  final bool? userVisibleOnly;

  /// For "clipboard" permission, may specify allowWithoutSanitization.
  final bool? allowWithoutSanitization;

  /// For "fullscreen" permission, must specify allowWithoutGesture:true.
  final bool? allowWithoutGesture;

  /// For "camera" permission, may specify panTiltZoom.
  final bool? panTiltZoom;

  PermissionDescriptor({
    required this.name,
    this.sysex,
    this.userVisibleOnly,
    this.allowWithoutSanitization,
    this.allowWithoutGesture,
    this.panTiltZoom,
  });

  factory PermissionDescriptor.fromJson(Map<String, dynamic> json) {
    return PermissionDescriptor(
      name: json['name'] as String,
      sysex: json.containsKey('sysex') ? json['sysex'] as bool : null,
      userVisibleOnly: json.containsKey('userVisibleOnly')
          ? json['userVisibleOnly'] as bool
          : null,
      allowWithoutSanitization: json.containsKey('allowWithoutSanitization')
          ? json['allowWithoutSanitization'] as bool
          : null,
      allowWithoutGesture: json.containsKey('allowWithoutGesture')
          ? json['allowWithoutGesture'] as bool
          : null,
      panTiltZoom: json.containsKey('panTiltZoom')
          ? json['panTiltZoom'] as bool
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (sysex != null) 'sysex': sysex,
      if (userVisibleOnly != null) 'userVisibleOnly': userVisibleOnly,
      if (allowWithoutSanitization != null)
        'allowWithoutSanitization': allowWithoutSanitization,
      if (allowWithoutGesture != null)
        'allowWithoutGesture': allowWithoutGesture,
      if (panTiltZoom != null) 'panTiltZoom': panTiltZoom,
    };
  }
}

/// Browser command ids used by executeBrowserCommand.
enum BrowserCommandId {
  openTabSearch('openTabSearch'),
  closeTabSearch('closeTabSearch'),
  openGlic('openGlic');

  final String value;

  const BrowserCommandId(this.value);

  factory BrowserCommandId.fromJson(String value) =>
      BrowserCommandId.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Chrome histogram bucket.
class Bucket {
  /// Minimum value (inclusive).
  final int low;

  /// Maximum value (exclusive).
  final int high;

  /// Number of samples.
  final int count;

  Bucket({required this.low, required this.high, required this.count});

  factory Bucket.fromJson(Map<String, dynamic> json) {
    return Bucket(
      low: json['low'] as int,
      high: json['high'] as int,
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'low': low, 'high': high, 'count': count};
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
    required this.name,
    required this.sum,
    required this.count,
    required this.buckets,
  });

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

enum PrivacySandboxAPI {
  biddingAndAuctionServices('BiddingAndAuctionServices'),
  trustedKeyValue('TrustedKeyValue');

  final String value;

  const PrivacySandboxAPI(this.value);

  factory PrivacySandboxAPI.fromJson(String value) =>
      PrivacySandboxAPI.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum DownloadProgressEventState {
  inProgress('inProgress'),
  completed('completed'),
  canceled('canceled');

  final String value;

  const DownloadProgressEventState(this.value);

  factory DownloadProgressEventState.fromJson(String value) =>
      DownloadProgressEventState.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}
