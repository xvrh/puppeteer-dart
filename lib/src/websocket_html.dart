import 'dart:js_interop';
import 'package:web/web.dart' as html;
import 'websocket.dart';

Future<WebSocket> connectWebsocket(String url) async {
  var innerWebSocket = html.WebSocket(url);
  if (innerWebSocket.readyState != html.WebSocket.OPEN) {
    await innerWebSocket.onOpen.first;
  }
  return _Websocket(innerWebSocket);
}

class _Websocket implements WebSocket {
  final html.WebSocket _socket;

  _Websocket(this._socket);

  @override
  Future<void> get done => _socket.onClose.first;

  @override
  Stream<String> get events =>
      _socket.onMessage.map((m) => (m.data! as JSString).toDart);

  @override
  void add(String message) {
    _socket.send(message.toJS);
  }

  String? _closeReason;
  @override
  Future<void> close(String reason) async {
    _closeReason = reason;
    return _socket.close(1000, reason);
  }

  @override
  String? get closeReason => _closeReason;
}
