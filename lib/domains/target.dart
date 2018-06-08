import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';

/// Supports additional targets discovery and allows to attach to them.
class TargetApi {
  final Client _client;

  TargetApi(this._client);

  /// Issued when attached to target because of auto-attach or `attachToTarget` command.
  Stream<AttachedToTargetEvent> get onAttachedToTarget => _client.onEvent
      .where((Event event) => event.name == 'Target.attachedToTarget')
      .map((Event event) =>
          new AttachedToTargetEvent.fromJson(event.parameters));

  /// Issued when detached from target for any reason (including `detachFromTarget` command). Can be
  /// issued multiple times per target if multiple sessions have been attached to it.
  Stream<DetachedFromTargetEvent> get onDetachedFromTarget => _client.onEvent
      .where((Event event) => event.name == 'Target.detachedFromTarget')
      .map((Event event) =>
          new DetachedFromTargetEvent.fromJson(event.parameters));

  /// Notifies about a new protocol message received from the session (as reported in
  /// `attachedToTarget` event).
  Stream<ReceivedMessageFromTargetEvent> get onReceivedMessageFromTarget =>
      _client.onEvent
          .where(
              (Event event) => event.name == 'Target.receivedMessageFromTarget')
          .map((Event event) =>
              new ReceivedMessageFromTargetEvent.fromJson(event.parameters));

  /// Issued when a possible inspection target is created.
  Stream<TargetInfo> get onTargetCreated => _client.onEvent
      .where((Event event) => event.name == 'Target.targetCreated')
      .map((Event event) =>
          new TargetInfo.fromJson(event.parameters['targetInfo']));

  /// Issued when a target is destroyed.
  Stream<TargetID> get onTargetDestroyed => _client.onEvent
      .where((Event event) => event.name == 'Target.targetDestroyed')
      .map(
          (Event event) => new TargetID.fromJson(event.parameters['targetId']));

  /// Issued when a target has crashed.
  Stream<TargetCrashedEvent> get onTargetCrashed => _client.onEvent
      .where((Event event) => event.name == 'Target.targetCrashed')
      .map((Event event) => new TargetCrashedEvent.fromJson(event.parameters));

  /// Issued when some information about a target has changed. This only happens between
  /// `targetCreated` and `targetDestroyed`.
  Stream<TargetInfo> get onTargetInfoChanged => _client.onEvent
      .where((Event event) => event.name == 'Target.targetInfoChanged')
      .map((Event event) =>
          new TargetInfo.fromJson(event.parameters['targetInfo']));

  /// Activates (focuses) the target.
  Future activateTarget(
    TargetID targetId,
  ) async {
    Map parameters = {
      'targetId': targetId.toJson(),
    };
    await _client.send('Target.activateTarget', parameters);
  }

  /// Attaches to the target with given id.
  /// Returns: Id assigned to the session.
  Future<SessionID> attachToTarget(
    TargetID targetId,
  ) async {
    Map parameters = {
      'targetId': targetId.toJson(),
    };
    Map result = await _client.send('Target.attachToTarget', parameters);
    return new SessionID.fromJson(result['sessionId']);
  }

  /// Closes the target. If the target is a page that gets closed too.
  Future<bool> closeTarget(
    TargetID targetId,
  ) async {
    Map parameters = {
      'targetId': targetId.toJson(),
    };
    Map result = await _client.send('Target.closeTarget', parameters);
    return result['success'];
  }

  /// Creates a new empty BrowserContext. Similar to an incognito profile but you can have more than
  /// one.
  /// Returns: The id of the context created.
  Future<BrowserContextID> createBrowserContext() async {
    Map result = await _client.send('Target.createBrowserContext');
    return new BrowserContextID.fromJson(result['browserContextId']);
  }

  /// Returns all browser contexts created with `Target.createBrowserContext` method.
  /// Returns: An array of browser context ids.
  Future<List<BrowserContextID>> getBrowserContexts() async {
    Map result = await _client.send('Target.getBrowserContexts');
    return (result['browserContextIds'] as List)
        .map((e) => new BrowserContextID.fromJson(e))
        .toList();
  }

  /// Creates a new page.
  /// [url] The initial URL the page will be navigated to.
  /// [width] Frame width in DIP (headless chrome only).
  /// [height] Frame height in DIP (headless chrome only).
  /// [browserContextId] The browser context to create the page in.
  /// [enableBeginFrameControl] Whether BeginFrames for this target will be controlled via DevTools (headless chrome only,
  /// not supported on MacOS yet, false by default).
  /// Returns: The id of the page opened.
  Future<TargetID> createTarget(
    String url, {
    int width,
    int height,
    BrowserContextID browserContextId,
    bool enableBeginFrameControl,
  }) async {
    Map parameters = {
      'url': url,
    };
    if (width != null) {
      parameters['width'] = width;
    }
    if (height != null) {
      parameters['height'] = height;
    }
    if (browserContextId != null) {
      parameters['browserContextId'] = browserContextId.toJson();
    }
    if (enableBeginFrameControl != null) {
      parameters['enableBeginFrameControl'] = enableBeginFrameControl;
    }
    Map result = await _client.send('Target.createTarget', parameters);
    return new TargetID.fromJson(result['targetId']);
  }

  /// Detaches session with given id.
  /// [sessionId] Session to detach.
  Future detachFromTarget({
    SessionID sessionId,
    @deprecated TargetID targetId,
  }) async {
    Map parameters = {};
    if (sessionId != null) {
      parameters['sessionId'] = sessionId.toJson();
    }
    // ignore: deprecated_member_use
    if (targetId != null) {
      // ignore: deprecated_member_use
      parameters['targetId'] = targetId.toJson();
    }
    await _client.send('Target.detachFromTarget', parameters);
  }

  /// Deletes a BrowserContext. All the belonging pages will be closed without calling their
  /// beforeunload hooks.
  Future disposeBrowserContext(
    BrowserContextID browserContextId,
  ) async {
    Map parameters = {
      'browserContextId': browserContextId.toJson(),
    };
    await _client.send('Target.disposeBrowserContext', parameters);
  }

  /// Returns information about a target.
  Future<TargetInfo> getTargetInfo(
    TargetID targetId,
  ) async {
    Map parameters = {
      'targetId': targetId.toJson(),
    };
    Map result = await _client.send('Target.getTargetInfo', parameters);
    return new TargetInfo.fromJson(result['targetInfo']);
  }

  /// Retrieves a list of available targets.
  /// Returns: The list of targets.
  Future<List<TargetInfo>> getTargets() async {
    Map result = await _client.send('Target.getTargets');
    return (result['targetInfos'] as List)
        .map((e) => new TargetInfo.fromJson(e))
        .toList();
  }

  /// Sends protocol message over session with given id.
  /// [sessionId] Identifier of the session.
  Future sendMessageToTarget(
    String message, {
    SessionID sessionId,
    @deprecated TargetID targetId,
  }) async {
    Map parameters = {
      'message': message,
    };
    if (sessionId != null) {
      parameters['sessionId'] = sessionId.toJson();
    }
    // ignore: deprecated_member_use
    if (targetId != null) {
      // ignore: deprecated_member_use
      parameters['targetId'] = targetId.toJson();
    }
    await _client.send('Target.sendMessageToTarget', parameters);
  }

  /// Controls whether to automatically attach to new targets which are considered to be related to
  /// this one. When turned on, attaches to all existing related targets as well. When turned off,
  /// automatically detaches from all currently attached targets.
  /// [autoAttach] Whether to auto-attach to related targets.
  /// [waitForDebuggerOnStart] Whether to pause new targets when attaching to them. Use `Runtime.runIfWaitingForDebugger`
  /// to run paused targets.
  Future setAutoAttach(
    bool autoAttach,
    bool waitForDebuggerOnStart,
  ) async {
    Map parameters = {
      'autoAttach': autoAttach,
      'waitForDebuggerOnStart': waitForDebuggerOnStart,
    };
    await _client.send('Target.setAutoAttach', parameters);
  }

  /// Controls whether to discover available targets and notify via
  /// `targetCreated/targetInfoChanged/targetDestroyed` events.
  /// [discover] Whether to discover available targets.
  Future setDiscoverTargets(
    bool discover,
  ) async {
    Map parameters = {
      'discover': discover,
    };
    await _client.send('Target.setDiscoverTargets', parameters);
  }

  /// Enables target discovery for the specified locations, when `setDiscoverTargets` was set to
  /// `true`.
  /// [locations] List of remote locations.
  Future setRemoteLocations(
    List<RemoteLocation> locations,
  ) async {
    Map parameters = {
      'locations': locations.map((e) => e.toJson()).toList(),
    };
    await _client.send('Target.setRemoteLocations', parameters);
  }
}

class AttachedToTargetEvent {
  /// Identifier assigned to the session used to send/receive messages.
  final SessionID sessionId;

  final TargetInfo targetInfo;

  final bool waitingForDebugger;

  AttachedToTargetEvent({
    @required this.sessionId,
    @required this.targetInfo,
    @required this.waitingForDebugger,
  });

  factory AttachedToTargetEvent.fromJson(Map json) {
    return new AttachedToTargetEvent(
      sessionId: new SessionID.fromJson(json['sessionId']),
      targetInfo: new TargetInfo.fromJson(json['targetInfo']),
      waitingForDebugger: json['waitingForDebugger'],
    );
  }
}

class DetachedFromTargetEvent {
  /// Detached session identifier.
  final SessionID sessionId;

  DetachedFromTargetEvent({
    @required this.sessionId,
  });

  factory DetachedFromTargetEvent.fromJson(Map json) {
    return new DetachedFromTargetEvent(
      sessionId: new SessionID.fromJson(json['sessionId']),
    );
  }
}

class ReceivedMessageFromTargetEvent {
  /// Identifier of a session which sends a message.
  final SessionID sessionId;

  final String message;

  ReceivedMessageFromTargetEvent({
    @required this.sessionId,
    @required this.message,
  });

  factory ReceivedMessageFromTargetEvent.fromJson(Map json) {
    return new ReceivedMessageFromTargetEvent(
      sessionId: new SessionID.fromJson(json['sessionId']),
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

  TargetCrashedEvent({
    @required this.targetId,
    @required this.status,
    @required this.errorCode,
  });

  factory TargetCrashedEvent.fromJson(Map json) {
    return new TargetCrashedEvent(
      targetId: new TargetID.fromJson(json['targetId']),
      status: json['status'],
      errorCode: json['errorCode'],
    );
  }
}

class TargetID {
  final String value;

  TargetID(this.value);

  factory TargetID.fromJson(String value) => new TargetID(value);

  String toJson() => value;

  @override
  bool operator ==(other) => other is TargetID && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Unique identifier of attached debugging session.
class SessionID {
  final String value;

  SessionID(this.value);

  factory SessionID.fromJson(String value) => new SessionID(value);

  String toJson() => value;

  @override
  bool operator ==(other) => other is SessionID && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class BrowserContextID {
  final String value;

  BrowserContextID(this.value);

  factory BrowserContextID.fromJson(String value) =>
      new BrowserContextID(value);

  String toJson() => value;

  @override
  bool operator ==(other) => other is BrowserContextID && other.value == value;

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

  TargetInfo({
    @required this.targetId,
    @required this.type,
    @required this.title,
    @required this.url,
    @required this.attached,
    this.openerId,
    this.browserContextId,
  });

  factory TargetInfo.fromJson(Map json) {
    return new TargetInfo(
      targetId: new TargetID.fromJson(json['targetId']),
      type: json['type'],
      title: json['title'],
      url: json['url'],
      attached: json['attached'],
      openerId: json.containsKey('openerId')
          ? new TargetID.fromJson(json['openerId'])
          : null,
      browserContextId: json.containsKey('browserContextId')
          ? new BrowserContextID.fromJson(json['browserContextId'])
          : null,
    );
  }

  Map toJson() {
    Map json = {
      'targetId': targetId.toJson(),
      'type': type,
      'title': title,
      'url': url,
      'attached': attached,
    };
    if (openerId != null) {
      json['openerId'] = openerId.toJson();
    }
    if (browserContextId != null) {
      json['browserContextId'] = browserContextId.toJson();
    }
    return json;
  }
}

class RemoteLocation {
  final String host;

  final int port;

  RemoteLocation({
    @required this.host,
    @required this.port,
  });

  factory RemoteLocation.fromJson(Map json) {
    return new RemoteLocation(
      host: json['host'],
      port: json['port'],
    );
  }

  Map toJson() {
    Map json = {
      'host': host,
      'port': port,
    };
    return json;
  }
}
