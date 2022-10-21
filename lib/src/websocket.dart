import 'websocket_io.dart' if (dart.library.html) 'websocket_html.dart' as ws;

abstract class WebSocket {
  static Future<WebSocket> connect(String url) {
    return ws.connectWebsocket(url);
  }

  Stream<String> get events;

  void add(String message);

  Future<void> get done;

  Future<void> close(String reason);

  String? get closeReason;
}
