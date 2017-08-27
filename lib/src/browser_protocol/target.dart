/// Supports additional targets discovery and allows to attach to them.

import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';

class TargetManager {
  final Session _client;

  TargetManager(this._client);

  final StreamController<TargetInfo> _targetCreated =
      new StreamController<TargetInfo>.broadcast();

  /// Issued when a possible inspection target is created.
  Stream<TargetInfo> get onTargetCreated => _targetCreated.stream;

  final StreamController<TargetInfo> _targetInfoChanged =
      new StreamController<TargetInfo>.broadcast();

  /// Issued when some information about a target has changed. This only happens between <code>targetCreated</code> and <code>targetDestroyed</code>.
  Stream<TargetInfo> get onTargetInfoChanged => _targetInfoChanged.stream;

  final StreamController<TargetID> _targetDestroyed =
      new StreamController<TargetID>.broadcast();

  /// Issued when a target is destroyed.
  Stream<TargetID> get onTargetDestroyed => _targetDestroyed.stream;

  final StreamController<AttachedToTargetResult> _attachedToTarget =
      new StreamController<AttachedToTargetResult>.broadcast();

  /// Issued when attached to target because of auto-attach or <code>attachToTarget</code> command.
  Stream<AttachedToTargetResult> get onAttachedToTarget =>
      _attachedToTarget.stream;

  final StreamController<TargetID> _detachedFromTarget =
      new StreamController<TargetID>.broadcast();

  /// Issued when detached from target for any reason (including <code>detachFromTarget</code> command).
  Stream<TargetID> get onDetachedFromTarget => _detachedFromTarget.stream;

  final StreamController<ReceivedMessageFromTargetResult>
      _receivedMessageFromTarget =
      new StreamController<ReceivedMessageFromTargetResult>.broadcast();

  /// Notifies about new protocol message from attached target.
  Stream<ReceivedMessageFromTargetResult> get onReceivedMessageFromTarget =>
      _receivedMessageFromTarget.stream;

  /// Controls whether to discover available targets and notify via <code>targetCreated/targetInfoChanged/targetDestroyed</code> events.
  /// [discover] Whether to discover available targets.
  Future setDiscoverTargets(
    bool discover,
  ) async {
    Map parameters = {
      'discover': discover,
    };
    await _client.send('Target.setDiscoverTargets', parameters);
  }

  /// Controls whether to automatically attach to new targets which are considered to be related to this one. When turned on, attaches to all existing related targets as well. When turned off, automatically detaches from all currently attached targets.
  /// [autoAttach] Whether to auto-attach to related targets.
  /// [waitForDebuggerOnStart] Whether to pause new targets when attaching to them. Use <code>Runtime.runIfWaitingForDebugger</code> to run paused targets.
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

  /// [value] Whether to attach to frames.
  Future setAttachToFrames(
    bool value,
  ) async {
    Map parameters = {
      'value': value,
    };
    await _client.send('Target.setAttachToFrames', parameters);
  }

  /// Enables target discovery for the specified locations, when <code>setDiscoverTargets</code> was set to <code>true</code>.
  /// [locations] List of remote locations.
  Future setRemoteLocations(
    List<RemoteLocation> locations,
  ) async {
    Map parameters = {
      'locations': locations.map((e) => e.toJson()).toList(),
    };
    await _client.send('Target.setRemoteLocations', parameters);
  }

  /// Sends protocol message to the target with given id.
  Future sendMessageToTarget(
    TargetID targetId,
    String message,
  ) async {
    Map parameters = {
      'targetId': targetId.toJson(),
      'message': message,
    };
    await _client.send('Target.sendMessageToTarget', parameters);
  }

  /// Returns information about a target.
  Future<TargetInfo> getTargetInfo(
    TargetID targetId,
  ) async {
    Map parameters = {
      'targetId': targetId.toJson(),
    };
    await _client.send('Target.getTargetInfo', parameters);
  }

  /// Activates (focuses) the target.
  Future activateTarget(
    TargetID targetId,
  ) async {
    Map parameters = {
      'targetId': targetId.toJson(),
    };
    await _client.send('Target.activateTarget', parameters);
  }

  /// Closes the target. If the target is a page that gets closed too.
  Future<bool> closeTarget(
    TargetID targetId,
  ) async {
    Map parameters = {
      'targetId': targetId.toJson(),
    };
    await _client.send('Target.closeTarget', parameters);
  }

  /// Attaches to the target with given id.
  /// Return: Whether attach succeeded.
  Future<bool> attachToTarget(
    TargetID targetId,
  ) async {
    Map parameters = {
      'targetId': targetId.toJson(),
    };
    await _client.send('Target.attachToTarget', parameters);
  }

  /// Detaches from the target with given id.
  Future detachFromTarget(
    TargetID targetId,
  ) async {
    Map parameters = {
      'targetId': targetId.toJson(),
    };
    await _client.send('Target.detachFromTarget', parameters);
  }

  /// Creates a new empty BrowserContext. Similar to an incognito profile but you can have more than one.
  /// Return: The id of the context created.
  Future<BrowserContextID> createBrowserContext() async {
    await _client.send('Target.createBrowserContext');
  }

  /// Deletes a BrowserContext, will fail of any open page uses it.
  Future<bool> disposeBrowserContext(
    BrowserContextID browserContextId,
  ) async {
    Map parameters = {
      'browserContextId': browserContextId.toJson(),
    };
    await _client.send('Target.disposeBrowserContext', parameters);
  }

  /// Creates a new page.
  /// [url] The initial URL the page will be navigated to.
  /// [width] Frame width in DIP (headless chrome only).
  /// [height] Frame height in DIP (headless chrome only).
  /// [browserContextId] The browser context to create the page in (headless chrome only).
  /// Return: The id of the page opened.
  Future<TargetID> createTarget(
    String url, {
    int width,
    int height,
    BrowserContextID browserContextId,
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
    await _client.send('Target.createTarget', parameters);
  }

  /// Retrieves a list of available targets.
  /// Return: The list of targets.
  Future<List<TargetInfo>> getTargets() async {
    await _client.send('Target.getTargets');
  }
}

class AttachedToTargetResult {
  final TargetInfo targetInfo;

  final bool waitingForDebugger;

  AttachedToTargetResult({
    @required this.targetInfo,
    @required this.waitingForDebugger,
  });

  factory AttachedToTargetResult.fromJson(Map json) {
    return new AttachedToTargetResult(
      targetInfo: new TargetInfo.fromJson(json['targetInfo']),
      waitingForDebugger: json['waitingForDebugger'],
    );
  }
}

class ReceivedMessageFromTargetResult {
  final TargetID targetId;

  final String message;

  ReceivedMessageFromTargetResult({
    @required this.targetId,
    @required this.message,
  });

  factory ReceivedMessageFromTargetResult.fromJson(Map json) {
    return new ReceivedMessageFromTargetResult(
      targetId: new TargetID.fromJson(json['targetId']),
      message: json['message'],
    );
  }
}

class TargetID {
  final String value;

  TargetID(this.value);

  factory TargetID.fromJson(String value) => new TargetID(value);

  String toJson() => value;
}

class BrowserContextID {
  final String value;

  BrowserContextID(this.value);

  factory BrowserContextID.fromJson(String value) =>
      new BrowserContextID(value);

  String toJson() => value;
}

class TargetInfo {
  final TargetID targetId;

  final String type;

  final String title;

  final String url;

  /// Whether the target has an attached client.
  final bool attached;

  TargetInfo({
    @required this.targetId,
    @required this.type,
    @required this.title,
    @required this.url,
    @required this.attached,
  });

  factory TargetInfo.fromJson(Map json) {
    return new TargetInfo(
      targetId: new TargetID.fromJson(json['targetId']),
      type: json['type'],
      title: json['title'],
      url: json['url'],
      attached: json['attached'],
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
