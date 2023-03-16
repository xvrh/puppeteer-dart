import 'dart:async';
import '../src/connection.dart';

class DeviceAccessApi {
  final Client _client;

  DeviceAccessApi(this._client);

  /// A device request opened a user prompt to select a device. Respond with the
  /// selectPrompt or cancelPrompt command.
  Stream<DeviceRequestPromptedEvent> get onDeviceRequestPrompted => _client
      .onEvent
      .where((event) => event.name == 'DeviceAccess.deviceRequestPrompted')
      .map((event) => DeviceRequestPromptedEvent.fromJson(event.parameters));

  /// Enable events in this domain.
  Future<void> enable() async {
    await _client.send('DeviceAccess.enable');
  }

  /// Disable events in this domain.
  Future<void> disable() async {
    await _client.send('DeviceAccess.disable');
  }

  /// Select a device in response to a DeviceAccess.deviceRequestPrompted event.
  Future<void> selectPrompt(RequestId id, DeviceId deviceId) async {
    await _client.send('DeviceAccess.selectPrompt', {
      'id': id,
      'deviceId': deviceId,
    });
  }

  /// Cancel a prompt in response to a DeviceAccess.deviceRequestPrompted event.
  Future<void> cancelPrompt(RequestId id) async {
    await _client.send('DeviceAccess.cancelPrompt', {
      'id': id,
    });
  }
}

class DeviceRequestPromptedEvent {
  final RequestId id;

  final List<PromptDevice> devices;

  DeviceRequestPromptedEvent({required this.id, required this.devices});

  factory DeviceRequestPromptedEvent.fromJson(Map<String, dynamic> json) {
    return DeviceRequestPromptedEvent(
      id: RequestId.fromJson(json['id'] as String),
      devices: (json['devices'] as List)
          .map((e) => PromptDevice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Device request id.
class RequestId {
  final String value;

  RequestId(this.value);

  factory RequestId.fromJson(String value) => RequestId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is RequestId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// A device id.
class DeviceId {
  final String value;

  DeviceId(this.value);

  factory DeviceId.fromJson(String value) => DeviceId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is DeviceId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Device information displayed in a user prompt to select a device.
class PromptDevice {
  final DeviceId id;

  /// Display name as it appears in a device request user prompt.
  final String name;

  PromptDevice({required this.id, required this.name});

  factory PromptDevice.fromJson(Map<String, dynamic> json) {
    return PromptDevice(
      id: DeviceId.fromJson(json['id'] as String),
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toJson(),
      'name': name,
    };
  }
}
