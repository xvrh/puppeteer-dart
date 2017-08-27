/// The Tethering domain defines methods and events for browser port binding.

import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';

class TetheringManager {
  final Session _client;

  TetheringManager(this._client);

  final StreamController<AcceptedResult> _accepted =
      new StreamController<AcceptedResult>.broadcast();

  /// Informs that port was successfully bound and got a specified connection id.
  Stream<AcceptedResult> get onAccepted => _accepted.stream;

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

class AcceptedResult {
  /// Port number that was successfully bound.
  final int port;

  /// Connection id to be used.
  final String connectionId;

  AcceptedResult({
    @required this.port,
    @required this.connectionId,
  });

  factory AcceptedResult.fromJson(Map json) {
    return new AcceptedResult(
      port: json['port'],
      connectionId: json['connectionId'],
    );
  }
}
