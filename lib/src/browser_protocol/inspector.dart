import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';

class InspectorManager {
  final Session _client;

  InspectorManager(this._client);

  /// Enables inspector domain notifications.
  Future enable() async {
    await _client.send('Inspector.enable');
  }

  /// Disables inspector domain notifications.
  Future disable() async {
    await _client.send('Inspector.disable');
  }
}
