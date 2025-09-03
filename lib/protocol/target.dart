import 'dart:async';
import '../src/connection.dart';
import 'browser.dart' as browser;
import 'page.dart' as page;

/// Supports additional targets discovery and allows to attach to them.
class TargetApi {
  final Client _client;

  TargetApi(this._client);

  /// Issued when attached to target because of auto-attach or `attachToTarget` command.
  Stream<AttachedToTargetEvent> get onAttachedToTarget => _client.onEvent
      .where((event) => event.name == 'Target.attachedToTarget')
      .map((event) => AttachedToTargetEvent.fromJson(event.parameters));

  /// Issued when detached from target for any reason (including `detachFromTarget` command). Can be
  /// issued multiple times per target if multiple sessions have been attached to it.
  Stream<DetachedFromTargetEvent> get onDetachedFromTarget => _client.onEvent
      .where((event) => event.name == 'Target.detachedFromTarget')
      .map((event) => DetachedFromTargetEvent.fromJson(event.parameters));

  /// Notifies about a new protocol message received from the session (as reported in
  /// `attachedToTarget` event).
  Stream<ReceivedMessageFromTargetEvent> get onReceivedMessageFromTarget =>
      _client.onEvent
          .where((event) => event.name == 'Target.receivedMessageFromTarget')
          .map(
            (event) =>
                ReceivedMessageFromTargetEvent.fromJson(event.parameters),
          );

  /// Issued when a possible inspection target is created.
  Stream<TargetInfo> get onTargetCreated => _client.onEvent
      .where((event) => event.name == 'Target.targetCreated')
      .map(
        (event) => TargetInfo.fromJson(
          event.parameters['targetInfo'] as Map<String, dynamic>,
        ),
      );

  /// Issued when a target is destroyed.
  Stream<TargetID> get onTargetDestroyed => _client.onEvent
      .where((event) => event.name == 'Target.targetDestroyed')
      .map(
        (event) => TargetID.fromJson(event.parameters['targetId'] as String),
      );

  /// Issued when a target has crashed.
  Stream<TargetCrashedEvent> get onTargetCrashed => _client.onEvent
      .where((event) => event.name == 'Target.targetCrashed')
      .map((event) => TargetCrashedEvent.fromJson(event.parameters));

  /// Issued when some information about a target has changed. This only happens between
  /// `targetCreated` and `targetDestroyed`.
  Stream<TargetInfo> get onTargetInfoChanged => _client.onEvent
      .where((event) => event.name == 'Target.targetInfoChanged')
      .map(
        (event) => TargetInfo.fromJson(
          event.parameters['targetInfo'] as Map<String, dynamic>,
        ),
      );

  /// Activates (focuses) the target.
  Future<void> activateTarget(TargetID targetId) async {
    await _client.send('Target.activateTarget', {'targetId': targetId});
  }

  /// Attaches to the target with given id.
  /// [flatten] Enables "flat" access to the session via specifying sessionId attribute in the commands.
  /// We plan to make this the default, deprecate non-flattened mode,
  /// and eventually retire it. See crbug.com/991325.
  /// Returns: Id assigned to the session.
  Future<SessionID> attachToTarget(TargetID targetId, {bool? flatten}) async {
    var result = await _client.send('Target.attachToTarget', {
      'targetId': targetId,
      if (flatten != null) 'flatten': flatten,
    });
    return SessionID.fromJson(result['sessionId'] as String);
  }

  /// Attaches to the browser target, only uses flat sessionId mode.
  /// Returns: Id assigned to the session.
  Future<SessionID> attachToBrowserTarget() async {
    var result = await _client.send('Target.attachToBrowserTarget');
    return SessionID.fromJson(result['sessionId'] as String);
  }

  /// Closes the target. If the target is a page that gets closed too.
  /// Returns: Always set to true. If an error occurs, the response indicates protocol error.
  Future<bool> closeTarget(TargetID targetId) async {
    var result = await _client.send('Target.closeTarget', {
      'targetId': targetId,
    });
    return result['success'] as bool;
  }

  /// Inject object to the target's main frame that provides a communication
  /// channel with browser target.
  ///
  /// Injected object will be available as `window[bindingName]`.
  ///
  /// The object has the following API:
  /// - `binding.send(json)` - a method to send messages over the remote debugging protocol
  /// - `binding.onmessage = json => handleMessage(json)` - a callback that will be called for the protocol notifications and command responses.
  /// [bindingName] Binding name, 'cdp' if not specified.
  /// [inheritPermissions] If true, inherits the current root session's permissions (default: false).
  Future<void> exposeDevToolsProtocol(
    TargetID targetId, {
    String? bindingName,
    bool? inheritPermissions,
  }) async {
    await _client.send('Target.exposeDevToolsProtocol', {
      'targetId': targetId,
      if (bindingName != null) 'bindingName': bindingName,
      if (inheritPermissions != null) 'inheritPermissions': inheritPermissions,
    });
  }

  /// Creates a new empty BrowserContext. Similar to an incognito profile but you can have more than
  /// one.
  /// [disposeOnDetach] If specified, disposes this context when debugging session disconnects.
  /// [proxyServer] Proxy server, similar to the one passed to --proxy-server
  /// [proxyBypassList] Proxy bypass list, similar to the one passed to --proxy-bypass-list
  /// [originsWithUniversalNetworkAccess] An optional list of origins to grant unlimited cross-origin access to.
  /// Parts of the URL other than those constituting origin are ignored.
  /// Returns: The id of the context created.
  Future<browser.BrowserContextID> createBrowserContext({
    bool? disposeOnDetach,
    String? proxyServer,
    String? proxyBypassList,
    List<String>? originsWithUniversalNetworkAccess,
  }) async {
    var result = await _client.send('Target.createBrowserContext', {
      if (disposeOnDetach != null) 'disposeOnDetach': disposeOnDetach,
      if (proxyServer != null) 'proxyServer': proxyServer,
      if (proxyBypassList != null) 'proxyBypassList': proxyBypassList,
      if (originsWithUniversalNetworkAccess != null)
        'originsWithUniversalNetworkAccess': [
          ...originsWithUniversalNetworkAccess,
        ],
    });
    return browser.BrowserContextID.fromJson(
      result['browserContextId'] as String,
    );
  }

  /// Returns all browser contexts created with `Target.createBrowserContext` method.
  /// Returns: An array of browser context ids.
  Future<List<browser.BrowserContextID>> getBrowserContexts() async {
    var result = await _client.send('Target.getBrowserContexts');
    return (result['browserContextIds'] as List)
        .map((e) => browser.BrowserContextID.fromJson(e as String))
        .toList();
  }

  /// Creates a new page.
  /// [url] The initial URL the page will be navigated to. An empty string indicates about:blank.
  /// [left] Frame left origin in DIP (requires newWindow to be true or headless shell).
  /// [top] Frame top origin in DIP (requires newWindow to be true or headless shell).
  /// [width] Frame width in DIP (requires newWindow to be true or headless shell).
  /// [height] Frame height in DIP (requires newWindow to be true or headless shell).
  /// [windowState] Frame window state (requires newWindow to be true or headless shell).
  /// Default is normal.
  /// [browserContextId] The browser context to create the page in.
  /// [enableBeginFrameControl] Whether BeginFrames for this target will be controlled via DevTools (headless shell only,
  /// not supported on MacOS yet, false by default).
  /// [newWindow] Whether to create a new Window or Tab (false by default, not supported by headless shell).
  /// [background] Whether to create the target in background or foreground (false by default, not supported
  /// by headless shell).
  /// [forTab] Whether to create the target of type "tab".
  /// [hidden] Whether to create a hidden target. The hidden target is observable via protocol, but not
  /// present in the tab UI strip. Cannot be created with `forTab: true`, `newWindow: true` or
  /// `background: false`. The life-time of the tab is limited to the life-time of the session.
  /// Returns: The id of the page opened.
  Future<TargetID> createTarget(
    String url, {
    int? left,
    int? top,
    int? width,
    int? height,
    WindowState? windowState,
    browser.BrowserContextID? browserContextId,
    bool? enableBeginFrameControl,
    bool? newWindow,
    bool? background,
    bool? forTab,
    bool? hidden,
  }) async {
    var result = await _client.send('Target.createTarget', {
      'url': url,
      if (left != null) 'left': left,
      if (top != null) 'top': top,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (windowState != null) 'windowState': windowState,
      if (browserContextId != null) 'browserContextId': browserContextId,
      if (enableBeginFrameControl != null)
        'enableBeginFrameControl': enableBeginFrameControl,
      if (newWindow != null) 'newWindow': newWindow,
      if (background != null) 'background': background,
      if (forTab != null) 'forTab': forTab,
      if (hidden != null) 'hidden': hidden,
    });
    return TargetID.fromJson(result['targetId'] as String);
  }

  /// Detaches session with given id.
  /// [sessionId] Session to detach.
  Future<void> detachFromTarget({
    SessionID? sessionId,
    @Deprecated('This parameter is deprecated') TargetID? targetId,
  }) async {
    await _client.send('Target.detachFromTarget', {
      if (sessionId != null) 'sessionId': sessionId,
      if (targetId != null) 'targetId': targetId,
    });
  }

  /// Deletes a BrowserContext. All the belonging pages will be closed without calling their
  /// beforeunload hooks.
  Future<void> disposeBrowserContext(
    browser.BrowserContextID browserContextId,
  ) async {
    await _client.send('Target.disposeBrowserContext', {
      'browserContextId': browserContextId,
    });
  }

  /// Returns information about a target.
  Future<TargetInfo> getTargetInfo({TargetID? targetId}) async {
    var result = await _client.send('Target.getTargetInfo', {
      if (targetId != null) 'targetId': targetId,
    });
    return TargetInfo.fromJson(result['targetInfo'] as Map<String, dynamic>);
  }

  /// Retrieves a list of available targets.
  /// [filter] Only targets matching filter will be reported. If filter is not specified
  /// and target discovery is currently enabled, a filter used for target discovery
  /// is used for consistency.
  /// Returns: The list of targets.
  Future<List<TargetInfo>> getTargets({TargetFilter? filter}) async {
    var result = await _client.send('Target.getTargets', {
      if (filter != null) 'filter': filter,
    });
    return (result['targetInfos'] as List)
        .map((e) => TargetInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Sends protocol message over session with given id.
  /// Consider using flat mode instead; see commands attachToTarget, setAutoAttach,
  /// and crbug.com/991325.
  /// [sessionId] Identifier of the session.
  @Deprecated('This command is deprecated')
  Future<void> sendMessageToTarget(
    String message, {
    SessionID? sessionId,
    @Deprecated('This parameter is deprecated') TargetID? targetId,
  }) async {
    await _client.send('Target.sendMessageToTarget', {
      'message': message,
      if (sessionId != null) 'sessionId': sessionId,
      if (targetId != null) 'targetId': targetId,
    });
  }

  /// Controls whether to automatically attach to new targets which are considered
  /// to be directly related to this one (for example, iframes or workers).
  /// When turned on, attaches to all existing related targets as well. When turned off,
  /// automatically detaches from all currently attached targets.
  /// This also clears all targets added by `autoAttachRelated` from the list of targets to watch
  /// for creation of related targets.
  /// You might want to call this recursively for auto-attached targets to attach
  /// to all available targets.
  /// [autoAttach] Whether to auto-attach to related targets.
  /// [waitForDebuggerOnStart] Whether to pause new targets when attaching to them. Use `Runtime.runIfWaitingForDebugger`
  /// to run paused targets.
  /// [flatten] Enables "flat" access to the session via specifying sessionId attribute in the commands.
  /// We plan to make this the default, deprecate non-flattened mode,
  /// and eventually retire it. See crbug.com/991325.
  /// [filter] Only targets matching filter will be attached.
  Future<void> setAutoAttach(
    bool autoAttach,
    bool waitForDebuggerOnStart, {
    bool? flatten,
    TargetFilter? filter,
  }) async {
    await _client.send('Target.setAutoAttach', {
      'autoAttach': autoAttach,
      'waitForDebuggerOnStart': waitForDebuggerOnStart,
      if (flatten != null) 'flatten': flatten,
      if (filter != null) 'filter': filter,
    });
  }

  /// Adds the specified target to the list of targets that will be monitored for any related target
  /// creation (such as child frames, child workers and new versions of service worker) and reported
  /// through `attachedToTarget`. The specified target is also auto-attached.
  /// This cancels the effect of any previous `setAutoAttach` and is also cancelled by subsequent
  /// `setAutoAttach`. Only available at the Browser target.
  /// [waitForDebuggerOnStart] Whether to pause new targets when attaching to them. Use `Runtime.runIfWaitingForDebugger`
  /// to run paused targets.
  /// [filter] Only targets matching filter will be attached.
  Future<void> autoAttachRelated(
    TargetID targetId,
    bool waitForDebuggerOnStart, {
    TargetFilter? filter,
  }) async {
    await _client.send('Target.autoAttachRelated', {
      'targetId': targetId,
      'waitForDebuggerOnStart': waitForDebuggerOnStart,
      if (filter != null) 'filter': filter,
    });
  }

  /// Controls whether to discover available targets and notify via
  /// `targetCreated/targetInfoChanged/targetDestroyed` events.
  /// [discover] Whether to discover available targets.
  /// [filter] Only targets matching filter will be attached. If `discover` is false,
  /// `filter` must be omitted or empty.
  Future<void> setDiscoverTargets(bool discover, {TargetFilter? filter}) async {
    await _client.send('Target.setDiscoverTargets', {
      'discover': discover,
      if (filter != null) 'filter': filter,
    });
  }

  /// Enables target discovery for the specified locations, when `setDiscoverTargets` was set to
  /// `true`.
  /// [locations] List of remote locations.
  Future<void> setRemoteLocations(List<RemoteLocation> locations) async {
    await _client.send('Target.setRemoteLocations', {
      'locations': [...locations],
    });
  }

  /// Opens a DevTools window for the target.
  /// [targetId] This can be the page or tab target ID.
  /// Returns: The targetId of DevTools page target.
  Future<TargetID> openDevTools(TargetID targetId) async {
    var result = await _client.send('Target.openDevTools', {
      'targetId': targetId,
    });
    return TargetID.fromJson(result['targetId'] as String);
  }
}

class AttachedToTargetEvent {
  /// Identifier assigned to the session used to send/receive messages.
  final SessionID sessionId;

  final TargetInfo targetInfo;

  final bool waitingForDebugger;

  AttachedToTargetEvent({
    required this.sessionId,
    required this.targetInfo,
    required this.waitingForDebugger,
  });

  factory AttachedToTargetEvent.fromJson(Map<String, dynamic> json) {
    return AttachedToTargetEvent(
      sessionId: SessionID.fromJson(json['sessionId'] as String),
      targetInfo: TargetInfo.fromJson(
        json['targetInfo'] as Map<String, dynamic>,
      ),
      waitingForDebugger: json['waitingForDebugger'] as bool? ?? false,
    );
  }
}

class DetachedFromTargetEvent {
  /// Detached session identifier.
  final SessionID sessionId;

  DetachedFromTargetEvent({required this.sessionId});

  factory DetachedFromTargetEvent.fromJson(Map<String, dynamic> json) {
    return DetachedFromTargetEvent(
      sessionId: SessionID.fromJson(json['sessionId'] as String),
    );
  }
}

class ReceivedMessageFromTargetEvent {
  /// Identifier of a session which sends a message.
  final SessionID sessionId;

  final String message;

  ReceivedMessageFromTargetEvent({
    required this.sessionId,
    required this.message,
  });

  factory ReceivedMessageFromTargetEvent.fromJson(Map<String, dynamic> json) {
    return ReceivedMessageFromTargetEvent(
      sessionId: SessionID.fromJson(json['sessionId'] as String),
      message: json['message'] as String,
    );
  }
}

class TargetCrashedEvent {
  final TargetID targetId;

  /// Termination status type.
  final String status;

  /// Termination error code.
  final int errorCode;

  TargetCrashedEvent({
    required this.targetId,
    required this.status,
    required this.errorCode,
  });

  factory TargetCrashedEvent.fromJson(Map<String, dynamic> json) {
    return TargetCrashedEvent(
      targetId: TargetID.fromJson(json['targetId'] as String),
      status: json['status'] as String,
      errorCode: json['errorCode'] as int,
    );
  }
}

extension type TargetID(String value) {
  factory TargetID.fromJson(String value) => TargetID(value);

  String toJson() => value;
}

/// Unique identifier of attached debugging session.
extension type SessionID(String value) {
  factory SessionID.fromJson(String value) => SessionID(value);

  String toJson() => value;
}

class TargetInfo {
  final TargetID targetId;

  /// List of types: https://source.chromium.org/chromium/chromium/src/+/main:content/browser/devtools/devtools_agent_host_impl.cc?ss=chromium&q=f:devtools%20-f:out%20%22::kTypeTab%5B%5D%22
  final String type;

  final String title;

  final String url;

  /// Whether the target has an attached client.
  final bool attached;

  /// Opener target Id
  final TargetID? openerId;

  /// Whether the target has access to the originating window.
  final bool canAccessOpener;

  /// Frame id of originating window (is only set if target has an opener).
  final page.FrameId? openerFrameId;

  final browser.BrowserContextID? browserContextId;

  /// Provides additional details for specific target types. For example, for
  /// the type of "page", this may be set to "prerender".
  final String? subtype;

  TargetInfo({
    required this.targetId,
    required this.type,
    required this.title,
    required this.url,
    required this.attached,
    this.openerId,
    required this.canAccessOpener,
    this.openerFrameId,
    this.browserContextId,
    this.subtype,
  });

  factory TargetInfo.fromJson(Map<String, dynamic> json) {
    return TargetInfo(
      targetId: TargetID.fromJson(json['targetId'] as String),
      type: json['type'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      attached: json['attached'] as bool? ?? false,
      openerId: json.containsKey('openerId')
          ? TargetID.fromJson(json['openerId'] as String)
          : null,
      canAccessOpener: json['canAccessOpener'] as bool? ?? false,
      openerFrameId: json.containsKey('openerFrameId')
          ? page.FrameId.fromJson(json['openerFrameId'] as String)
          : null,
      browserContextId: json.containsKey('browserContextId')
          ? browser.BrowserContextID.fromJson(
              json['browserContextId'] as String,
            )
          : null,
      subtype: json.containsKey('subtype') ? json['subtype'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetId': targetId.toJson(),
      'type': type,
      'title': title,
      'url': url,
      'attached': attached,
      'canAccessOpener': canAccessOpener,
      if (openerId != null) 'openerId': openerId!.toJson(),
      if (openerFrameId != null) 'openerFrameId': openerFrameId!.toJson(),
      if (browserContextId != null)
        'browserContextId': browserContextId!.toJson(),
      if (subtype != null) 'subtype': subtype,
    };
  }
}

/// A filter used by target query/discovery/auto-attach operations.
class FilterEntry {
  /// If set, causes exclusion of matching targets from the list.
  final bool? exclude;

  /// If not present, matches any type.
  final String? type;

  FilterEntry({this.exclude, this.type});

  factory FilterEntry.fromJson(Map<String, dynamic> json) {
    return FilterEntry(
      exclude: json.containsKey('exclude') ? json['exclude'] as bool : null,
      type: json.containsKey('type') ? json['type'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (exclude != null) 'exclude': exclude,
      if (type != null) 'type': type,
    };
  }
}

/// The entries in TargetFilter are matched sequentially against targets and
/// the first entry that matches determines if the target is included or not,
/// depending on the value of `exclude` field in the entry.
/// If filter is not specified, the one assumed is
/// [{type: "browser", exclude: true}, {type: "tab", exclude: true}, {}]
/// (i.e. include everything but `browser` and `tab`).
extension type TargetFilter(List<FilterEntry> value) {
  factory TargetFilter.fromJson(List<dynamic> value) => TargetFilter(
    value.map((e) => FilterEntry.fromJson(e as Map<String, dynamic>)).toList(),
  );

  List<FilterEntry> toJson() => value;
}

class RemoteLocation {
  final String host;

  final int port;

  RemoteLocation({required this.host, required this.port});

  factory RemoteLocation.fromJson(Map<String, dynamic> json) {
    return RemoteLocation(
      host: json['host'] as String,
      port: json['port'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'host': host, 'port': port};
  }
}

/// The state of the target window.
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
