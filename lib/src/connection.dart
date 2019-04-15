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

class Enum {
  const Enum(List<String> values);
}

class Connection implements Client {
  final Logger _logger = Logger('connection');
  static int _lastId = 0;
  final WebSocket _webSocket;
  final String url;
  final Map<int, Completer> _completers = {};
  final List<Session> _sessions = [];
  final StreamController<Event> _eventController =
      StreamController<Event>.broadcast();
  TargetApi _targetApi;
  final List<StreamSubscription> _subscriptions = [];

  Connection._(this._webSocket, this.url) {
    _subscriptions.add(_webSocket.listen(_onMessage));

    _targetApi = TargetApi(this);

    _subscriptions.add(_targetApi.onReceivedMessageFromTarget
        .listen((ReceivedMessageFromTargetEvent e) {
      Session session = _getSession(e.sessionId);
      session._onMessage(e.message);
    }));
    _subscriptions
        .add(_targetApi.onDetachedFromTarget.listen((DetachedFromTargetEvent e) {
      Session session = _getSession(e.sessionId);
      session._onClosed();
      _sessions.remove(session);
    }));
  }

  TargetApi get targetApi => _targetApi;

  Session _getSession(SessionID sessionId) =>
      _sessions.firstWhere((s) => s.sessionId.value == sessionId.value);

  static Future<Connection> create(String url) async {
    WebSocket webSocket = await WebSocket.connect(url);

    return Connection._(webSocket, url);
  }

  @override
  Stream<Event> get onEvent => _eventController.stream;

  @override
  Future<Map> send(String method, [Map parameters]) {
    int id = ++_lastId;
    String message = _encodeMessage(id, method, parameters);

    _logger.fine('SEND ► $message');

    var completer = Completer<Map>();
    _completers[id] = completer;
    _webSocket.add(message);

    return completer.future;
  }

  Future<Session> createSession(TargetID targetId,
      {BrowserContextID browserContextID}) async {
    SessionID sessionId = await _targetApi.attachToTarget(targetId);
    Session session = Session(_targetApi, sessionId);
    _sessions.add(session);

    return session;
  }

  _onMessage(messageArg) {
    String message = messageArg;
    Map object = jsonDecode(message);
    int id = object['id'];
    if (id != null) {
      _logger.fine('◀ RECV $message');

      Completer completer = _completers.remove(id);
      assert(completer != null);

      Map error = object['error'];
      if (error != null) {
        completer.completeError(ServerException(error['message']));
      } else {
        completer.complete(object['result']);
      }
    } else {
      String method = object['method'];
      Map params = object['params'];

      _logger.fine('◀ EVENT $message');

      _eventController.add(Event._(method, params));
    }
  }

  Future dispose() async {
    await _eventController.close();
    for (Completer completer in _completers.values) {
      completer.completeError(TargetClosedException());
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

String _encodeMessage(int id, String method, Map<String, dynamic> parameters) {
  return jsonEncode({
    'id': id,
    'method': method,
    'params': parameters,
  });
}

class Session implements Client {
  static int _lastId = 0;
  final SessionID sessionId;
  final TargetApi targetApi;
  final Map<int, Completer> _completers = {};
  final StreamController<Event> _eventController =
      StreamController<Event>.broadcast();
  final Completer _onClose = Completer();

  Session(this.targetApi, this.sessionId);

  @override
  Future<Map> send(String method, [Map parameters]) {
    if (_eventController.isClosed) {
      throw Exception('Session closed');
    }
    int id = ++_lastId;
    String message = _encodeMessage(id, method, parameters);

    var completer = Completer<Map>();
    _completers[id] = completer;

    targetApi.sendMessageToTarget(message, sessionId: sessionId);

    return completer.future;
  }

  @override
  Stream<Event> get onEvent => _eventController.stream;

  _onMessage(String message) {
    Map object = jsonDecode(message);

    int id = object['id'];
    if (id != null) {
      Completer completer = _completers.remove(id);
      Map error = object['error'];
      if (error != null) {
        completer.completeError(ServerException(error['message']));
      } else {
        completer.complete(object['result']);
      }
    } else {
      _eventController.add(Event._(object['method'], object['params']));
    }
  }

  Future get onClose => _onClose.future;

  bool get isClosed => _onClose.isCompleted;

  _onClosed() {
    _eventController.close();
    for (Completer completer in _completers.values) {
      completer.completeError(TargetClosedException());
    }
    _completers.clear();
    _onClose.complete();
  }
}

class ServerException implements Exception {
  final String message;

  ServerException(this.message);

  @override
  toString() => message;
}

class TargetClosedException implements Exception {
}