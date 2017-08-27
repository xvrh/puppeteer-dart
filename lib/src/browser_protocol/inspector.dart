import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';

class InspectorManager {
  final Session _client;

  InspectorManager(this._client);

  final StreamController<String> _detached =
      new StreamController<String>.broadcast();

  /// Fired when remote debugging connection is about to be terminated. Contains detach reason.
  Stream<String> get onDetached => _detached.stream;

  final StreamController _targetCrashed = new StreamController.broadcast();

  /// Fired when debugging target has crashed
  Stream get onTargetCrashed => _targetCrashed.stream;

  /// Enables inspector domain notifications.
  Future enable() async {
    await _client.send('Inspector.enable');
  }

  /// Disables inspector domain notifications.
  Future disable() async {
    await _client.send('Inspector.disable');
  }
}
