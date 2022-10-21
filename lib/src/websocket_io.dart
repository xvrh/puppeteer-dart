import 'dart:io' as io;
import 'websocket.dart';

Future<WebSocket> connectWebsocket(String url) async {
  return _Websocket(await io.WebSocket.connect(url));
}

class _Websocket implements WebSocket {
  final io.WebSocket _socket;

  _Websocket(this._socket);

  @override
  Future<void> get done => _socket.done;

  @override
  Stream<String> get events => _socket.cast<String>();

  @override
  void add(String message) {
    _socket.add(message);
  }

  @override
  Future<void> close(String reason) {
    return _socket.close(io.WebSocketStatus.normalClosure, reason);
  }

  @override
  String? get closeReason => _socket.closeReason;
}
