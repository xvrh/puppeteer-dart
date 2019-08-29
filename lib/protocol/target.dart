import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';

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
      .map((event) => TargetInfo.fromJson(event.parameters['targetInfo']));

  /// Issued when a target is destroyed.
  Stream<TargetID> get onTargetDestroyed => _client.onEvent
      .where((event) => event.name == 'Target.targetDestroyed')
      .map((event) => TargetID.fromJson(event.parameters['targetId']));

  /// Issued when a target has crashed.
  Stream<TargetCrashedEvent> get onTargetCrashed => _client.onEvent
      .where((event) => event.name == 'Target.targetCrashed')
      .map((event) => TargetCrashedEvent.fromJson(event.parameters));

  /// Issued when some information about a target has changed. This only happens between
  /// `targetCreated` and `targetDestroyed`.
  Stream<TargetInfo> get onTargetInfoChanged => _client.onEvent
      .where((event) => event.name == 'Target.targetInfoChanged')
      .map((event) => TargetInfo.fromJson(event.parameters['targetInfo']));

  /// Activates (focuses) the target.
  Future<void> activateTarget(TargetID targetId) async {
    await _client.send('Target.activateTarget', {
      'targetId': targetId,
    });
  }

  /// Attaches to the target with given id.
  /// [flatten] Enables "flat" access to the session via specifying sessionId attribute in the commands.
  /// Returns: Id assigned to the session.
  Future<SessionID> attachToTarget(TargetID targetId, {bool flatten}) async {
    var result = await _client.send('Target.attachToTarget', {
      'targetId': targetId,
      if (flatten != null) 'flatten': flatten,
    });
    return SessionID.fromJson(result['sessionId']);
  }

  /// Attaches to the browser target, only uses flat sessionId mode.
  /// Returns: Id assigned to the session.
  Future<SessionID> attachToBrowserTarget() async {
    var result = await _client.send('Target.attachToBrowserTarget');
    return SessionID.fromJson(result['sessionId']);
  }

  /// Closes the target. If the target is a page that gets closed too.
  Future<bool> closeTarget(TargetID targetId) async {
    var result = await _client.send('Target.closeTarget', {
      'targetId': targetId,
    });
    return result['success'];
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
      {String bindingName}) async {
    await _client.send('Target.exposeDevToolsProtocol', {
      'targetId': targetId,
      if (bindingName != null) 'bindingName': bindingName,
    });
  }

  /// Creates a new empty BrowserContext. Similar to an incognito profile but you can have more than
  /// one.
  /// Returns: The id of the context created.
  Future<BrowserContextID> createBrowserContext() async {
    var result = await _client.send('Target.createBrowserContext');
    return BrowserContextID.fromJson(result['browserContextId']);
  }

  /// Returns all browser contexts created with `Target.createBrowserContext` method.
  /// Returns: An array of browser context ids.
  Future<List<BrowserContextID>> getBrowserContexts() async {
    var result = await _client.send('Target.getBrowserContexts');
    return (result['browserContextIds'] as List)
        .map((e) => BrowserContextID.fromJson(e))
        .toList();
  }

  /// Creates a new page.
  /// [url] The initial URL the page will be navigated to.
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
      {int width,
      int height,
      BrowserContextID browserContextId,
      bool enableBeginFrameControl,
      bool newWindow,
      bool background}) async {
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
    return TargetID.fromJson(result['targetId']);
  }

  /// Detaches session with given id.
  /// [sessionId] Session to detach.
  Future<void> detachFromTarget(
      {SessionID sessionId, @deprecated TargetID targetId}) async {
    await _client.send('Target.detachFromTarget', {
      if (sessionId != null) 'sessionId': sessionId,
      if (targetId != null) 'targetId': targetId,
    });
  }

  /// Deletes a BrowserContext. All the belonging pages will be closed without calling their
  /// beforeunload hooks.
  Future<void> disposeBrowserContext(BrowserContextID browserContextId) async {
    await _client.send('Target.disposeBrowserContext', {
      'browserContextId': browserContextId,
    });
  }

  /// Returns information about a target.
  Future<TargetInfo> getTargetInfo({TargetID targetId}) async {
    var result = await _client.send('Target.getTargetInfo', {
      if (targetId != null) 'targetId': targetId,
    });
    return TargetInfo.fromJson(result['targetInfo']);
  }

  /// Retrieves a list of available targets.
  /// Returns: The list of targets.
  Future<List<TargetInfo>> getTargets() async {
    var result = await _client.send('Target.getTargets');
    return (result['targetInfos'] as List)
        .map((e) => TargetInfo.fromJson(e))
        .toList();
  }

  /// Sends protocol message over session with given id.
  /// [sessionId] Identifier of the session.
  Future<void> sendMessageToTarget(String message,
      {SessionID sessionId, @deprecated TargetID targetId}) async {
    await _client.send('Target.sendMessageToTarget', {
      'message': message,
      if (sessionId != null) 'sessionId': sessionId,
      if (targetId != null) 'targetId': targetId,
    });
  }

  /// Controls whether to automatically attach to new targets which are considered to be related to
  /// this one. When turned on, attaches to all existing related targets as well. When turned off,
  /// automatically detaches from all currently attached targets.
  /// [autoAttach] Whether to auto-attach to related targets.
  /// [waitForDebuggerOnStart] Whether to pause new targets when attaching to them. Use `Runtime.runIfWaitingForDebugger`
  /// to run paused targets.
  /// [flatten] Enables "flat" access to the session via specifying sessionId attribute in the commands.
  Future<void> setAutoAttach(bool autoAttach, bool waitForDebuggerOnStart,
      {bool flatten}) async {
    await _client.send('Target.setAutoAttach', {
      'autoAttach': autoAttach,
      'waitForDebuggerOnStart': waitForDebuggerOnStart,
      if (flatten != null) 'flatten': flatten,
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
      'locations': locations.map((e) => e).toList(),
    });
  }
}

class AttachedToTargetEvent {
  /// Identifier assigned to the session used to send/receive messages.
  final SessionID sessionId;

  final TargetInfo targetInfo;

  final bool waitingForDebugger;

  AttachedToTargetEvent(
      {@required this.sessionId,
      @required this.targetInfo,
      @required this.waitingForDebugger});

  factory AttachedToTargetEvent.fromJson(Map<String, dynamic> json) {
    return AttachedToTargetEvent(
      sessionId: SessionID.fromJson(json['sessionId']),
      targetInfo: TargetInfo.fromJson(json['targetInfo']),
      waitingForDebugger: json['waitingForDebugger'],
    );
  }
}

class DetachedFromTargetEvent {
  /// Detached session identifier.
  final SessionID sessionId;

  DetachedFromTargetEvent({@required this.sessionId});

  factory DetachedFromTargetEvent.fromJson(Map<String, dynamic> json) {
    return DetachedFromTargetEvent(
      sessionId: SessionID.fromJson(json['sessionId']),
    );
  }
}

class ReceivedMessageFromTargetEvent {
  /// Identifier of a session which sends a message.
  final SessionID sessionId;

  final String message;

  ReceivedMessageFromTargetEvent(
      {@required this.sessionId, @required this.message});

  factory ReceivedMessageFromTargetEvent.fromJson(Map<String, dynamic> json) {
    return ReceivedMessageFromTargetEvent(
      sessionId: SessionID.fromJson(json['sessionId']),
      message: json['message'],
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
      {@required this.targetId,
      @required this.status,
      @required this.errorCode});

  factory TargetCrashedEvent.fromJson(Map<String, dynamic> json) {
    return TargetCrashedEvent(
      targetId: TargetID.fromJson(json['targetId']),
      status: json['status'],
      errorCode: json['errorCode'],
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

class BrowserContextID {
  final String value;

  BrowserContextID(this.value);

  factory BrowserContextID.fromJson(String value) => BrowserContextID(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is BrowserContextID && other.value == value) || value == other;

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
  final TargetID openerId;

  final BrowserContextID browserContextId;

  TargetInfo(
      {@required this.targetId,
      @required this.type,
      @required this.title,
      @required this.url,
      @required this.attached,
      this.openerId,
      this.browserContextId});

  factory TargetInfo.fromJson(Map<String, dynamic> json) {
    return TargetInfo(
      targetId: TargetID.fromJson(json['targetId']),
      type: json['type'],
      title: json['title'],
      url: json['url'],
      attached: json['attached'],
      openerId: json.containsKey('openerId')
          ? TargetID.fromJson(json['openerId'])
          : null,
      browserContextId: json.containsKey('browserContextId')
          ? BrowserContextID.fromJson(json['browserContextId'])
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
      if (openerId != null) 'openerId': openerId.toJson(),
      if (browserContextId != null)
        'browserContextId': browserContextId.toJson(),
    };
  }
}

class RemoteLocation {
  final String host;

  final int port;

  RemoteLocation({@required this.host, @required this.port});

  factory RemoteLocation.fromJson(Map<String, dynamic> json) {
    return RemoteLocation(
      host: json['host'],
      port: json['port'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'port': port,
    };
  }
}
