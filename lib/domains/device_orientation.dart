import 'dart:async';
import '../src/connection.dart';

class DeviceOrientationApi {
  final Client _client;

  DeviceOrientationApi(this._client);

  /// Clears the overridden Device Orientation.
  Future clearDeviceOrientationOverride() async {
    await _client.send('DeviceOrientation.clearDeviceOrientationOverride');
  }

  /// Overrides the Device Orientation.
  /// [alpha] Mock alpha
  /// [beta] Mock beta
  /// [gamma] Mock gamma
  Future setDeviceOrientationOverride(num alpha, num beta, num gamma) async {
    var parameters = <String, dynamic>{
      'alpha': alpha,
      'beta': beta,
      'gamma': gamma,
    };
    await _client.send(
        'DeviceOrientation.setDeviceOrientationOverride', parameters);
  }
}
