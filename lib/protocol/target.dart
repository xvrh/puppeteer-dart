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
          .map((event) =>
              ReceivedMessageFromTargetEvent.fromJson(event.parameters));

  /// Issued when a possible inspection target is created.
  Stream<TargetInfo> get onTargetCreated => _client.onEvent
      .where((event) => event.name == 'Target.targetCreated')
      .map((event) => TargetInfo.fromJson(
          event.parameters['targetInfo'] as Map<String, dynamic>));

  /// Issued when a target is destroyed.
  Stream<TargetID> get onTargetDestroyed => _client.onEvent
      .where((event) => event.name == 'Target.targetDestroyed')
      .map(
          (event) => TargetID.fromJson(event.parameters['targetId'] as String));

  /// Issued when a target has crashed.
  Stream<TargetCrashedEvent> get onTargetCrashed => _client.onEvent
      .where((event) => event.name == 'Target.targetCrashed')
      .map((event) => TargetCrashedEvent.fromJson(event.parameters));

  /// Issued when some information about a target has changed. This only happens between
  /// `targetCreated` and `targetDestroyed`.
  Stream<TargetInfo> get onTargetInfoChanged => _client.onEvent
      .where((event) => event.name == 'Target.targetInfoChanged')
      .map((event) => TargetInfo.fromJson(
          event.parameters['targetInfo'] as Map<String, dynamic>));

  /// Activates (focuses) the target.
  Future<void> activateTarget(TargetID targetId) async {
    await _client.send('Target.activateTarget', {
      'targetId': targetId,
    });
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
  /// The object has the follwing API:
  /// - `binding.send(json)` - a method to send messages over the remote debugging protocol
  /// - `binding.onmessage = json => handleMessage(json)` - a callback that will be called for the protocol notifications and command responses.
  /// [bindingName] Binding name, 'cdp' if not specified.
  Future<void> exposeDevToolsProtocol(TargetID targetId,
      {String? bindingName}) async {
    await _client.send('Target.exposeDevToolsProtocol', {
      'targetId': targetId,
      if (bindingName != null) 'bindingName': bindingName,
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
  Future<browser.BrowserContextID> createBrowserContext(
      {bool? disposeOnDetach,
      String? proxyServer,
      String? proxyBypassList,
      List<String>? originsWithUniversalNetworkAccess}) async {
    var result = await _client.send('Target.createBrowserContext', {
      if (disposeOnDetach != null) 'disposeOnDetach': disposeOnDetach,
      if (proxyServer != null) 'proxyServer': proxyServer,
      if (proxyBypassList != null) 'proxyBypassList': proxyBypassList,
      if (originsWithUniversalNetworkAccess != null)
        'originsWithUniversalNetworkAccess': [
          ...originsWithUniversalNetworkAccess
        ],
    });
    return browser.BrowserContextID.fromJson(
        result['browserContextId'] as String);
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
  /// [width] Frame width in DIP (headless chrome only).
  /// [height] Frame height in DIP (headless chrome only).
  /// [browserContextId] The browser context to create the page in.
  /// [enableBeginFrameControl] Whether BeginFrames for this target will be controlled via DevTools (headless chrome only,
  /// not supported on MacOS yet, false by default).
  /// [newWindow] Whether to create a new Window or Tab (chrome-only, false by default).
  /// [background] Whether to create the target in background or foreground (chrome-only,
  /// false by default).
  /// Returns: The id of the page opened.
  Future<TargetID> createTarget(String url,
      {int? width,
      int? height,
      browser.BrowserContextID? browserContextId,
      bool? enableBeginFrameControl,
      bool? newWindow,
      bool? background}) async {
    var result = await _client.send('Target.createTarget', {
      'url': url,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (browserContextId != null) 'browserContextId': browserContextId,
      if (enableBeginFrameControl != null)
        'enableBeginFrameControl': enableBeginFrameControl,
      if (newWindow != null) 'newWindow': newWindow,
      if (background != null) 'background': background,
    });
    return TargetID.fromJson(result['targetId'] as String);
  }

  /// Detaches session with given id.
  /// [sessionId] Session to detach.
  Future<void> detachFromTarget(
      {SessionID? sessionId,
      @Deprecated('This parameter is deprecated') TargetID? targetId}) async {
    await _client.send('Target.detachFromTarget', {
      if (sessionId != null) 'sessionId': sessionId,
      if (targetId != null) 'targetId': targetId,
    });
  }

  /// Deletes a BrowserContext. All the belonging pages will be closed without calling their
  /// beforeunload hooks.
  Future<void> disposeBrowserContext(
      browser.BrowserContextID browserContextId) async {
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
  /// Returns: The list of targets.
  Future<List<TargetInfo>> getTargets() async {
    var result = await _client.send('Target.getTargets');
    return (result['targetInfos'] as List)
        .map((e) => TargetInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Sends protocol message over session with given id.
  /// Consider using flat mode instead; see commands attachToTarget, setAutoAttach,
  /// and crbug.com/991325.
  /// [sessionId] Identifier of the session.
  @Deprecated('This command is deprecated')
  Future<void> sendMessageToTarget(String message,
      {SessionID? sessionId,
      @Deprecated('This parameter is deprecated') TargetID? targetId}) async {
    await _client.send('Target.sendMessageToTarget', {
      'message': message,
      if (sessionId != null) 'sessionId': sessionId,
      if (targetId != null) 'targetId': targetId,
    });
  }

  /// Controls whether to automatically attach to new targets which are considered to be related to
  /// this one. When turned on, attaches to all existing related targets as well. When turned off,
  /// automatically detaches from all currently attached targets.
  /// This also clears all targets added by `autoAttachRelated` from the list of targets to watch
  /// for creation of related targets.
  /// [autoAttach] Whether to auto-attach to related targets.
  /// [waitForDebuggerOnStart] Whether to pause new targets when attaching to them. Use `Runtime.runIfWaitingForDebugger`
  /// to run paused targets.
  /// [flatten] Enables "flat" access to the session via specifying sessionId attribute in the commands.
  /// We plan to make this the default, deprecate non-flattened mode,
  /// and eventually retire it. See crbug.com/991325.
  Future<void> setAutoAttach(bool autoAttach, bool waitForDebuggerOnStart,
      {bool? flatten}) async {
    await _client.send('Target.setAutoAttach', {
      'autoAttach': autoAttach,
      'waitForDebuggerOnStart': waitForDebuggerOnStart,
      if (flatten != null) 'flatten': flatten,
    });
  }

  /// Adds the specified target to the list of targets that will be monitored for any related target
  /// creation (such as child frames, child workers and new versions of service worker) and reported
  /// through `attachedToTarget`. The specified target is also auto-attached.
  /// This cancels the effect of any previous `setAutoAttach` and is also cancelled by subsequent
  /// `setAutoAttach`. Only available at the Browser target.
  /// [waitForDebuggerOnStart] Whether to pause new targets when attaching to them. Use `Runtime.runIfWaitingForDebugger`
  /// to run paused targets.
  Future<void> autoAttachRelated(
      TargetID targetId, bool waitForDebuggerOnStart) async {
    await _client.send('Target.autoAttachRelated', {
      'targetId': targetId,
      'waitForDebuggerOnStart': waitForDebuggerOnStart,
    });
  }

  /// Controls whether to discover available targets and notify via
  /// `targetCreated/targetInfoChanged/targetDestroyed` events.
  /// [discover] Whether to discover available targets.
  Future<void> setDiscoverTargets(bool discover) async {
    await _client.send('Target.setDiscoverTargets', {
      'discover': discover,
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
}

class AttachedToTargetEvent {
  /// Identifier assigned to the session used to send/receive messages.
  final SessionID sessionId;

  final TargetInfo targetInfo;

  final bool waitingForDebugger;

  AttachedToTargetEvent(
      {required this.sessionId,
      required this.targetInfo,
      required this.waitingForDebugger});

  factory AttachedToTargetEvent.fromJson(Map<String, dynamic> json) {
    return AttachedToTargetEvent(
      sessionId: SessionID.fromJson(json['sessionId'] as String),
      targetInfo:
          TargetInfo.fromJson(json['targetInfo'] as Map<String, dynamic>),
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

  ReceivedMessageFromTargetEvent(
      {required this.sessionId, required this.message});

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

  TargetCrashedEvent(
      {required this.targetId, required this.status, required this.errorCode});

  factory TargetCrashedEvent.fromJson(Map<String, dynamic> json) {
    return TargetCrashedEvent(
      targetId: TargetID.fromJson(json['targetId'] as String),
      status: json['status'] as String,
      errorCode: json['errorCode'] as int,
    );
  }
}

class TargetID {
  final String value;

  TargetID(this.value);

  factory TargetID.fromJson(String value) => TargetID(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is TargetID && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Unique identifier of attached debugging session.
class SessionID {
  final String value;

  SessionID(this.value);

  factory SessionID.fromJson(String value) => SessionID(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is SessionID && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class TargetInfo {
  final TargetID targetId;

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

  TargetInfo(
      {required this.targetId,
      required this.type,
      required this.title,
      required this.url,
      required this.attached,
      this.openerId,
      required this.canAccessOpener,
      this.openerFrameId,
      this.browserContextId});

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
              json['browserContextId'] as String)
          : null,
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
    };
  }
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
    return {
      'host': host,
      'port': port,
    };
  }
}
