import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import '../protocol/target.dart';

abstract class Client {
  Future<Map<String, dynamic>> send(String method,
      [Map<String, dynamic>? parameters]);

  Stream<Event> get onEvent;
}

class Event {
  final String name;
  final Map<String, dynamic> parameters;

  Event._(this.name, this.parameters);
}

/// An annotation to tag some API parameters with the accepted values.
/// This is purely for documentation purpose until Dart support something like
/// "String Literal Types" from TypeScript.
class Enum {
  const Enum(List<String> values);
}

class Connection implements Client {
  final Logger _logger = Logger('connection');
  static int _lastId = 0;
  final WebSocket _webSocket;
  final String url;
  final Map<int, _Message> _messagesInFly = {};
  final Map<String, Session> sessions = {};
  final StreamController<Event> _eventController =
      StreamController<Event>.broadcast(sync: true);
  late final _targetApi = TargetApi(this);
  final List<StreamSubscription> _subscriptions = [];
  final Duration? _delay;

  Connection._(this._webSocket, this.url, {Duration? delay}) : _delay = delay {
    _subscriptions
        .add(_webSocket.cast<String>().listen(_onMessage, onError: (error) {
      print('Websocket error: $error');
    }));

    _webSocket.done.then((_) => _onClose(
        'Websocket.done(code: ${_webSocket.closeCode}, reason: ${_webSocket.closeReason})'));
  }

  TargetApi get targetApi => _targetApi;

  static Future<Connection> create(String url,
      {required Duration? delay}) async {
    return Connection._(await WebSocket.connect(url), url, delay: delay);
  }

  @override
  Stream<Event> get onEvent => _eventController.stream;

  @override
  Future<Map<String, dynamic>> send(String method,
      [Map<String, dynamic>? parameters]) {
    var id = _rawSend(method, parameters);
    var message = _Message(method);
    _messagesInFly[id] = message;

    return message.completer.future;
  }

  int _rawSend(String method, Map<String, dynamic>? parameters,
      {SessionID? sessionId}) {
    var id = ++_lastId;
    var message = _encodeMessage(id, method, parameters, sessionId: sessionId);

    _logger.finer('SEND ► $message');
    _webSocket.add(message);

    return id;
  }

  Future<Session> createSession(TargetInfo targetInfo) async {
    var sessionId =
        await _targetApi.attachToTarget(targetInfo.targetId, flatten: true);

    var session = sessions[sessionId.value]!;
    return session;
  }

  Future<void> _onMessage(String message) async {
    if (_delay != null) {
      await Future.delayed(_delay!);
    }
    if (_eventController.isClosed) return;

    var object = jsonDecode(message) as Map<String, dynamic>;
    var id = object['id'] as int?;
    var method = object['method'] as String?;
    var sessionId = object['sessionId'] as String?;
    if (method == 'Target.attachedToTarget') {
      var params = AttachedToTargetEvent.fromJson(
          object['params'] as Map<String, dynamic>);
      var sessionId = params.sessionId;
      var session =
          Session(this, sessionId, targetType: params.targetInfo.type);
      sessions[sessionId.value] = session;
    } else if (method == 'Target.detachedFromTarget') {
      var params = DetachedFromTargetEvent.fromJson(
          object['params'] as Map<String, dynamic>);
      var session = sessions[params.sessionId.value];
      if (session != null) {
        session.dispose(reason: 'Target.detachedFromTarget');
        sessions.remove(params.sessionId.value);
      }
    }
    if (sessionId != null) {
      var session = sessions[sessionId];
      if (session != null) {
        _logger.finer('◀ RECV $message');

        session._onMessage(object);
      }
    } else if (id != null) {
      _logger.finer('◀ RECV $id $message');

      var messageInFly = _messagesInFly.remove(id)!;

      var error = object['error'] as Map<String, dynamic>?;
      if (error != null) {
        messageInFly.completer
            .completeError(ServerException(error['message'] as String));
      } else {
        messageInFly.completer
            .complete(object['result'] as Map<String, dynamic>?);
      }
    } else {
      var method = object['method'] as String;
      var params = object['params'] as Map<String, dynamic>;

      _logger.finer('◀ EVENT $message');

      _eventController.add(Event._(method, params));
    }
  }

  void _onClose(String reason) {
    if (_eventController.isClosed) return;

    _eventController.close();
    for (var message in _messagesInFly.values) {
      message.completer
          .completeError(TargetClosedException(message.method, reason: reason));
    }
    _messagesInFly.clear();

    for (var session in sessions.values) {
      session.dispose(reason: 'Connection.dispose(reason: $reason)');
    }
    sessions.clear();

    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
  }

  Future dispose(String reason) async {
    _onClose(reason);
    await _webSocket.close(WebSocketStatus.normalClosure, 'Connection.dispose');
  }

  bool get isClosed => _eventController.isClosed;

  Future get disconnected => _webSocket.done;
}

String _encodeMessage(int id, String method, Map<String, dynamic>? parameters,
    {SessionID? sessionId}) {
  var message = {
    'id': id,
    'method': method,
    'params': parameters,
  };
  if (sessionId != null) {
    message['sessionId'] = sessionId.value;
  }
  return jsonEncode(message);
}

class Session implements Client {
  final SessionID sessionId;
  final Connection connection;
  final String? targetType;
  final _messagesInFly = <int, _Message>{};
  final _eventController = StreamController<Event>.broadcast(sync: true);
  final _onClose = Completer<void>();

  Session(this.connection, this.sessionId, {required this.targetType});

  @override
  Future<Map<String, dynamic>> send(String method,
      [Map<String, dynamic>? parameters]) {
    if (_eventController.isClosed) {
      throw Exception(
          'Protocol error ($method): Session closed. Most likely the $targetType has been closed.');
    }
    var id = connection._rawSend(method, parameters, sessionId: sessionId);

    var message = _Message(method);
    _messagesInFly[id] = message;

    return message.completer.future;
  }

  @override
  Stream<Event> get onEvent => _eventController.stream;

  Future<void> get closed => _onClose.future;

  void _onMessage(Map object) {
    var id = object['id'] as int?;
    if (id != null) {
      var message = _messagesInFly.remove(id);
      var error = object['error'] as Map<String, dynamic>?;
      if (error != null) {
        message!.completer
            .completeError(ServerException(error['message'] as String));
      } else {
        message!.completer.complete(object['result'] as Map<String, dynamic>?);
      }
    } else {
      _eventController.add(Event._(object['method'] as String,
          object['params'] as Map<String, dynamic>));
    }
  }

  bool get isClosed => _onClose.isCompleted;

  Future<void> detach() async {
    await connection.targetApi.detachFromTarget(sessionId: sessionId);
  }

  void dispose({required String reason}) {
    if (_eventController.isClosed) return;

    _eventController.close();
    for (var message in _messagesInFly.values) {
      message.completer
          .completeError(TargetClosedException(message.method, reason: reason));
    }
    _messagesInFly.clear();
    _onClose.complete();
  }
}

class ServerException implements Exception {
  final String message;

  ServerException(this.message);

  @override
  String toString() => message;

  static bool Function(T) matcher<T>(String message) =>
      (e) => e is ServerException && e.message == message;
}

class _Message {
  final completer = Completer<Map<String, dynamic>>();
  final String method;

  _Message(this.method);
}

class TargetClosedException implements Exception {
  final String method;
  final String reason;

  TargetClosedException(this.method, {required this.reason});

  @override
  String toString() =>
      'TargetClosedException(method: $method, reason: $reason)';
}
