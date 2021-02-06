import 'dart:async';
import '../src/connection.dart';

/// The Tethering domain defines methods and events for browser port binding.
class TetheringApi {
  final Client _client;

  TetheringApi(this._client);

  /// Informs that port was successfully bound and got a specified connection id.
  Stream<AcceptedEvent> get onAccepted => _client.onEvent
      .where((event) => event.name == 'Tethering.accepted')
      .map((event) => AcceptedEvent.fromJson(event.parameters));

  /// Request browser port binding.
  /// [port] Port number to bind.
  Future<void> bind(int port) async {
    await _client.send('Tethering.bind', {
      'port': port,
    });
  }

  /// Request browser port unbinding.
  /// [port] Port number to unbind.
  Future<void> unbind(int port) async {
    await _client.send('Tethering.unbind', {
      'port': port,
    });
  }
}

class AcceptedEvent {
  /// Port number that was successfully bound.
  final int port;

  /// Connection id to be used.
  final String connectionId;

  AcceptedEvent({required this.port, required this.connectionId});

  factory AcceptedEvent.fromJson(Map<String, dynamic> json) {
    return AcceptedEvent(
      port: json['port'] as int,
      connectionId: json['connectionId'] as String,
    );
  }
}
