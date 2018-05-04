import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import '../domains/target.dart';

abstract class Client {
  Future<Map> send(String method, [Map parameters]);
  Stream<Event> get onEvent;
}

class Event {
  final String name;
  final Map parameters;

  Event._(this.name, this.parameters);
}

class Connection implements Client {
  final Logger _logger = new Logger('connection');
  static int _lastId = 0;
  final WebSocket _webSocket;
  final Map<int, Completer> _completers = {};
  final List<Session> _sessions = [];
  final StreamController<Event> _eventController =
      new StreamController<Event>.broadcast();
  TargetManager _targets;
  final List<StreamSubscription> _subscriptions = [];

  Connection._(this._webSocket) {
    _subscriptions.add(_webSocket.listen(_onMessage));

    _targets = new TargetManager(this);

    _subscriptions.add(_targets.onReceivedMessageFromTarget
        .listen((ReceivedMessageFromTargetEvent e) {
      Session session = _getSession(e.sessionId);
      session._onMessage(e.message);
    }));
    _subscriptions
        .add(_targets.onDetachedFromTarget.listen((DetachedFromTargetEvent e) {
      Session session = _getSession(e.sessionId);
      session._onClosed();
      _sessions.remove(session);
    }));
  }

  TargetManager get targets => _targets;

  Session _getSession(SessionID sessionId) =>
      _sessions.firstWhere((s) => s.sessionId.value == sessionId.value);

  static Future<Connection> create(String url) async {
    WebSocket webSocket = await WebSocket.connect(url);

    return new Connection._(webSocket);
  }

  @override
  Stream<Event> get onEvent => _eventController.stream;

  @override
  Future<Map> send(String method, [Map parameters]) {
    int id = ++_lastId;
    String message = _encodeMessage(id, method, parameters);

    _logger.fine('SEND ► $message');

    Completer completer = new Completer();
    _completers[id] = completer;
    _webSocket.add(message);

    return completer.future;
  }

  Future<Session> createSession(TargetID targetId, {BrowserContextID browserContextID}) async {
    SessionID sessionId = await _targets.attachToTarget(targetId);
    Session session = new Session._(_targets, targetId, sessionId, browserContextID: browserContextID);
    _sessions.add(session);

    return session;
  }

  _onMessage(String message) {
    Map object = JSON.decode(message);
    int id = object['id'];
    if (id != null) {
      _logger.fine('◀ RECV $message');

      Completer completer = _completers.remove(id);
      assert(completer != null);

      Map error = object['error'];
      if (error != null) {
        completer.completeError(new Exception(error['message']));
      } else {
        completer.complete(object['result']);
      }
    } else {
      String method = object['method'];
      Map params = object['params'];

      _logger.fine('◀ EVENT $message');

      _eventController.add(new Event._(method, params));
    }
  }

  Future dispose() async {
    await _eventController.close();
    for (Completer completer in _completers.values) {
      completer.completeError(new Exception('Target closed'));
    }
    _completers.clear();

    for (Session session in _sessions) {
      session._onClosed();
    }
    _sessions.clear();

    for (StreamSubscription subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _webSocket.close();
  }
}

String _encodeMessage(int id, String method, Map parameters) {
  return JSON.encode({
    'id': id,
    'method': method,
    'params': parameters,
  });
}

class Session implements Client {
  static int _lastId = 0;
  final TargetID targetID;
  final SessionID sessionId;
  final TargetManager _targetManager;
  final BrowserContextID _browserContextID;
  final Map<int, Completer> _completers = {};
  final StreamController<Event> _eventController =
      new StreamController<Event>.broadcast();

  Session._(this._targetManager, this.targetID, this.sessionId, {BrowserContextID browserContextID}): _browserContextID = browserContextID;

  @override
  Future<Map> send(String method, [Map parameters]) {
    if (_eventController.isClosed) {
      throw new Exception('Session closed');
    }
    int id = ++_lastId;
    String message = _encodeMessage(id, method, parameters);

    Completer completer = new Completer();
    _completers[id] = completer;

    _targetManager.sendMessageToTarget(message, sessionId: sessionId);

    return completer.future;
  }

  @override
  Stream<Event> get onEvent => _eventController.stream;

  _onMessage(String message) {
    Map object = JSON.decode(message);

    int id = object['id'];
    if (id != null) {
      Completer completer = _completers.remove(id);
      Map error = object['error'];
      if (error != null) {
        completer.completeError(new Exception(error['message']));
      } else {
        completer.complete(object['result']);
      }
    } else {
      _eventController.add(new Event._(object['method'], object['params']));
    }
  }

  _onClosed() {
    _eventController.close();
    for (Completer completer in _completers.values) {
      completer.completeError(new Exception('Target closed'));
    }
    _completers.clear();
  }

  Future close() async {
    await _targetManager.closeTarget(targetID);
    if (_browserContextID != null) {
      await _targetManager.disposeBrowserContext(_browserContextID);
    }
  }
}
