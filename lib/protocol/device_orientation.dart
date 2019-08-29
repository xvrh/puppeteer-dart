import 'dart:async';
import '../src/connection.dart';

class DeviceOrientationApi {
  final Client _client;

  DeviceOrientationApi(this._client);

  /// Clears the overridden Device Orientation.
  Future<void> clearDeviceOrientationOverride() async {
    await _client.send('DeviceOrientation.clearDeviceOrientationOverride');
  }

  /// Overrides the Device Orientation.
  /// [alpha] Mock alpha
  /// [beta] Mock beta
  /// [gamma] Mock gamma
  Future<void> setDeviceOrientationOverride(
      num alpha, num beta, num gamma) async {
    await _client.send('DeviceOrientation.setDeviceOrientationOverride', {
      'alpha': alpha,
      'beta': beta,
      'gamma': gamma,
    });
  }
}
