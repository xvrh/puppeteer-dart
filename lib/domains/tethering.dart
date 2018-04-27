/// The Tethering domain defines methods and events for browser port binding.

import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';

class TetheringManager {
  final Client _client;

  TetheringManager(this._client);

  /// Informs that port was successfully bound and got a specified connection
  /// id.
  Stream<AcceptedEvent> get onAccepted => _client.onEvent
      .where((Event event) => event.name == 'Tethering.accepted')
      .map((Event event) => new AcceptedEvent.fromJson(event.parameters));

  /// Request browser port binding.
  /// [port] Port number to bind.
  Future bind(
    int port,
  ) async {
    Map parameters = {
      'port': port,
    };
    await _client.send('Tethering.bind', parameters);
  }

  /// Request browser port unbinding.
  /// [port] Port number to unbind.
  Future unbind(
    int port,
  ) async {
    Map parameters = {
      'port': port,
    };
    await _client.send('Tethering.unbind', parameters);
  }
}

class AcceptedEvent {
  /// Port number that was successfully bound.
  final int port;

  /// Connection id to be used.
  final String connectionId;

  AcceptedEvent({
    @required this.port,
    @required this.connectionId,
  });

  factory AcceptedEvent.fromJson(Map json) {
    return new AcceptedEvent(
      port: json['port'],
      connectionId: json['connectionId'],
    );
  }
}
