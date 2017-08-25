/// The Tethering domain defines methods and events for browser port binding.

import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';

class TetheringManager {
  final Session _client;

  TetheringManager(this._client);

  /// Request browser port binding.
  /// [port] Port number to bind.
  Future bind(
    int port,
  ) async {
    Map parameters = {
      'port': port.toString(),
    };
    await _client.send('Tethering.bind', parameters);
  }

  /// Request browser port unbinding.
  /// [port] Port number to unbind.
  Future unbind(
    int port,
  ) async {
    Map parameters = {
      'port': port.toString(),
    };
    await _client.send('Tethering.unbind', parameters);
  }
}
