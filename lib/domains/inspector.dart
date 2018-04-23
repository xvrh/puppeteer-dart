import 'dart:async';
// ignore: unused_import
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';

class InspectorDomain {
  final Client _client;

  InspectorDomain(this._client);

  /// Fired when remote debugging connection is about to be terminated. Contains
  /// detach reason.
  Stream<String> get onDetached => _client.onEvent
      .where((Event event) => event.name == 'Inspector.detached')
      .map((Event event) => event.parameters['reason'] as String);

  /// Fired when debugging target has crashed
  Stream get onTargetCrashed => _client.onEvent
      .where((Event event) => event.name == 'Inspector.targetCrashed');

  /// Enables inspector domain notifications.
  Future enable() async {
    await _client.send('Inspector.enable');
  }

  /// Disables inspector domain notifications.
  Future disable() async {
    await _client.send('Inspector.disable');
  }
}
