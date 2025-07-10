import 'dart:async';
import '../src/connection.dart';

/// This domain allows configuring virtual Bluetooth devices to test
/// the web-bluetooth API.
class BluetoothEmulationApi {
  final Client _client;

  BluetoothEmulationApi(this._client);

  /// Event for when a GATT operation of |type| to the peripheral with |address|
  /// happened.
  Stream<GattOperationReceivedEvent> get onGattOperationReceived => _client
      .onEvent
      .where(
        (event) => event.name == 'BluetoothEmulation.gattOperationReceived',
      )
      .map((event) => GattOperationReceivedEvent.fromJson(event.parameters));

  /// Event for when a characteristic operation of |type| to the characteristic
  /// respresented by |characteristicId| happened. |data| and |writeType| is
  /// expected to exist when |type| is write.
  Stream<CharacteristicOperationReceivedEvent>
  get onCharacteristicOperationReceived => _client.onEvent
      .where(
        (event) =>
            event.name == 'BluetoothEmulation.characteristicOperationReceived',
      )
      .map(
        (event) =>
            CharacteristicOperationReceivedEvent.fromJson(event.parameters),
      );

  /// Event for when a descriptor operation of |type| to the descriptor
  /// respresented by |descriptorId| happened. |data| is expected to exist when
  /// |type| is write.
  Stream<DescriptorOperationReceivedEvent> get onDescriptorOperationReceived =>
      _client.onEvent
          .where(
            (event) =>
                event.name == 'BluetoothEmulation.descriptorOperationReceived',
          )
          .map(
            (event) =>
                DescriptorOperationReceivedEvent.fromJson(event.parameters),
          );

  /// Enable the BluetoothEmulation domain.
  /// [state] State of the simulated central.
  /// [leSupported] If the simulated central supports low-energy.
  Future<void> enable(CentralState state, bool leSupported) async {
    await _client.send('BluetoothEmulation.enable', {
      'state': state,
      'leSupported': leSupported,
    });
  }

  /// Set the state of the simulated central.
  /// [state] State of the simulated central.
  Future<void> setSimulatedCentralState(CentralState state) async {
    await _client.send('BluetoothEmulation.setSimulatedCentralState', {
      'state': state,
    });
  }

  /// Disable the BluetoothEmulation domain.
  Future<void> disable() async {
    await _client.send('BluetoothEmulation.disable');
  }

  /// Simulates a peripheral with |address|, |name| and |knownServiceUuids|
  /// that has already been connected to the system.
  Future<void> simulatePreconnectedPeripheral(
    String address,
    String name,
    List<ManufacturerData> manufacturerData,
    List<String> knownServiceUuids,
  ) async {
    await _client.send('BluetoothEmulation.simulatePreconnectedPeripheral', {
      'address': address,
      'name': name,
      'manufacturerData': [...manufacturerData],
      'knownServiceUuids': [...knownServiceUuids],
    });
  }

  /// Simulates an advertisement packet described in |entry| being received by
  /// the central.
  Future<void> simulateAdvertisement(ScanEntry entry) async {
    await _client.send('BluetoothEmulation.simulateAdvertisement', {
      'entry': entry,
    });
  }

  /// Simulates the response code from the peripheral with |address| for a
  /// GATT operation of |type|. The |code| value follows the HCI Error Codes from
  /// Bluetooth Core Specification Vol 2 Part D 1.3 List Of Error Codes.
  Future<void> simulateGATTOperationResponse(
    String address,
    GATTOperationType type,
    int code,
  ) async {
    await _client.send('BluetoothEmulation.simulateGATTOperationResponse', {
      'address': address,
      'type': type,
      'code': code,
    });
  }

  /// Simulates the response from the characteristic with |characteristicId| for a
  /// characteristic operation of |type|. The |code| value follows the Error
  /// Codes from Bluetooth Core Specification Vol 3 Part F 3.4.1.1 Error Response.
  /// The |data| is expected to exist when simulating a successful read operation
  /// response.
  Future<void> simulateCharacteristicOperationResponse(
    String characteristicId,
    CharacteristicOperationType type,
    int code, {
    String? data,
  }) async {
    await _client
        .send('BluetoothEmulation.simulateCharacteristicOperationResponse', {
          'characteristicId': characteristicId,
          'type': type,
          'code': code,
          if (data != null) 'data': data,
        });
  }

  /// Simulates the response from the descriptor with |descriptorId| for a
  /// descriptor operation of |type|. The |code| value follows the Error
  /// Codes from Bluetooth Core Specification Vol 3 Part F 3.4.1.1 Error Response.
  /// The |data| is expected to exist when simulating a successful read operation
  /// response.
  Future<void> simulateDescriptorOperationResponse(
    String descriptorId,
    DescriptorOperationType type,
    int code, {
    String? data,
  }) async {
    await _client
        .send('BluetoothEmulation.simulateDescriptorOperationResponse', {
          'descriptorId': descriptorId,
          'type': type,
          'code': code,
          if (data != null) 'data': data,
        });
  }

  /// Adds a service with |serviceUuid| to the peripheral with |address|.
  /// Returns: An identifier that uniquely represents this service.
  Future<String> addService(String address, String serviceUuid) async {
    var result = await _client.send('BluetoothEmulation.addService', {
      'address': address,
      'serviceUuid': serviceUuid,
    });
    return result['serviceId'] as String;
  }

  /// Removes the service respresented by |serviceId| from the simulated central.
  Future<void> removeService(String serviceId) async {
    await _client.send('BluetoothEmulation.removeService', {
      'serviceId': serviceId,
    });
  }

  /// Adds a characteristic with |characteristicUuid| and |properties| to the
  /// service represented by |serviceId|.
  /// Returns: An identifier that uniquely represents this characteristic.
  Future<String> addCharacteristic(
    String serviceId,
    String characteristicUuid,
    CharacteristicProperties properties,
  ) async {
    var result = await _client.send('BluetoothEmulation.addCharacteristic', {
      'serviceId': serviceId,
      'characteristicUuid': characteristicUuid,
      'properties': properties,
    });
    return result['characteristicId'] as String;
  }

  /// Removes the characteristic respresented by |characteristicId| from the
  /// simulated central.
  Future<void> removeCharacteristic(String characteristicId) async {
    await _client.send('BluetoothEmulation.removeCharacteristic', {
      'characteristicId': characteristicId,
    });
  }

  /// Adds a descriptor with |descriptorUuid| to the characteristic respresented
  /// by |characteristicId|.
  /// Returns: An identifier that uniquely represents this descriptor.
  Future<String> addDescriptor(
    String characteristicId,
    String descriptorUuid,
  ) async {
    var result = await _client.send('BluetoothEmulation.addDescriptor', {
      'characteristicId': characteristicId,
      'descriptorUuid': descriptorUuid,
    });
    return result['descriptorId'] as String;
  }

  /// Removes the descriptor with |descriptorId| from the simulated central.
  Future<void> removeDescriptor(String descriptorId) async {
    await _client.send('BluetoothEmulation.removeDescriptor', {
      'descriptorId': descriptorId,
    });
  }

  /// Simulates a GATT disconnection from the peripheral with |address|.
  Future<void> simulateGATTDisconnection(String address) async {
    await _client.send('BluetoothEmulation.simulateGATTDisconnection', {
      'address': address,
    });
  }
}

class GattOperationReceivedEvent {
  final String address;

  final GATTOperationType type;

  GattOperationReceivedEvent({required this.address, required this.type});

  factory GattOperationReceivedEvent.fromJson(Map<String, dynamic> json) {
    return GattOperationReceivedEvent(
      address: json['address'] as String,
      type: GATTOperationType.fromJson(json['type'] as String),
    );
  }
}

class CharacteristicOperationReceivedEvent {
  final String characteristicId;

  final CharacteristicOperationType type;

  final String? data;

  final CharacteristicWriteType? writeType;

  CharacteristicOperationReceivedEvent({
    required this.characteristicId,
    required this.type,
    this.data,
    this.writeType,
  });

  factory CharacteristicOperationReceivedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return CharacteristicOperationReceivedEvent(
      characteristicId: json['characteristicId'] as String,
      type: CharacteristicOperationType.fromJson(json['type'] as String),
      data: json.containsKey('data') ? json['data'] as String : null,
      writeType: json.containsKey('writeType')
          ? CharacteristicWriteType.fromJson(json['writeType'] as String)
          : null,
    );
  }
}

class DescriptorOperationReceivedEvent {
  final String descriptorId;

  final DescriptorOperationType type;

  final String? data;

  DescriptorOperationReceivedEvent({
    required this.descriptorId,
    required this.type,
    this.data,
  });

  factory DescriptorOperationReceivedEvent.fromJson(Map<String, dynamic> json) {
    return DescriptorOperationReceivedEvent(
      descriptorId: json['descriptorId'] as String,
      type: DescriptorOperationType.fromJson(json['type'] as String),
      data: json.containsKey('data') ? json['data'] as String : null,
    );
  }
}

/// Indicates the various states of Central.
enum CentralState {
  absent('absent'),
  poweredOff('powered-off'),
  poweredOn('powered-on');

  final String value;

  const CentralState(this.value);

  factory CentralState.fromJson(String value) =>
      CentralState.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Indicates the various types of GATT event.
enum GATTOperationType {
  connection('connection'),
  discovery('discovery');

  final String value;

  const GATTOperationType(this.value);

  factory GATTOperationType.fromJson(String value) =>
      GATTOperationType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Indicates the various types of characteristic write.
enum CharacteristicWriteType {
  writeDefaultDeprecated('write-default-deprecated'),
  writeWithResponse('write-with-response'),
  writeWithoutResponse('write-without-response');

  final String value;

  const CharacteristicWriteType(this.value);

  factory CharacteristicWriteType.fromJson(String value) =>
      CharacteristicWriteType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Indicates the various types of characteristic operation.
enum CharacteristicOperationType {
  read('read'),
  write('write'),
  subscribeToNotifications('subscribe-to-notifications'),
  unsubscribeFromNotifications('unsubscribe-from-notifications');

  final String value;

  const CharacteristicOperationType(this.value);

  factory CharacteristicOperationType.fromJson(String value) =>
      CharacteristicOperationType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Indicates the various types of descriptor operation.
enum DescriptorOperationType {
  read('read'),
  write('write');

  final String value;

  const DescriptorOperationType(this.value);

  factory DescriptorOperationType.fromJson(String value) =>
      DescriptorOperationType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Stores the manufacturer data
class ManufacturerData {
  /// Company identifier
  /// https://bitbucket.org/bluetooth-SIG/public/src/main/assigned_numbers/company_identifiers/company_identifiers.yaml
  /// https://usb.org/developers
  final int key;

  /// Manufacturer-specific data
  final String data;

  ManufacturerData({required this.key, required this.data});

  factory ManufacturerData.fromJson(Map<String, dynamic> json) {
    return ManufacturerData(
      key: json['key'] as int,
      data: json['data'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'key': key, 'data': data};
  }
}

/// Stores the byte data of the advertisement packet sent by a Bluetooth device.
class ScanRecord {
  final String? name;

  final List<String>? uuids;

  /// Stores the external appearance description of the device.
  final int? appearance;

  /// Stores the transmission power of a broadcasting device.
  final int? txPower;

  /// Key is the company identifier and the value is an array of bytes of
  /// manufacturer specific data.
  final List<ManufacturerData>? manufacturerData;

  ScanRecord({
    this.name,
    this.uuids,
    this.appearance,
    this.txPower,
    this.manufacturerData,
  });

  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      name: json.containsKey('name') ? json['name'] as String : null,
      uuids: json.containsKey('uuids')
          ? (json['uuids'] as List).map((e) => e as String).toList()
          : null,
      appearance: json.containsKey('appearance')
          ? json['appearance'] as int
          : null,
      txPower: json.containsKey('txPower') ? json['txPower'] as int : null,
      manufacturerData: json.containsKey('manufacturerData')
          ? (json['manufacturerData'] as List)
                .map(
                  (e) => ManufacturerData.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (uuids != null) 'uuids': [...?uuids],
      if (appearance != null) 'appearance': appearance,
      if (txPower != null) 'txPower': txPower,
      if (manufacturerData != null)
        'manufacturerData': manufacturerData!.map((e) => e.toJson()).toList(),
    };
  }
}

/// Stores the advertisement packet information that is sent by a Bluetooth device.
class ScanEntry {
  final String deviceAddress;

  final int rssi;

  final ScanRecord scanRecord;

  ScanEntry({
    required this.deviceAddress,
    required this.rssi,
    required this.scanRecord,
  });

  factory ScanEntry.fromJson(Map<String, dynamic> json) {
    return ScanEntry(
      deviceAddress: json['deviceAddress'] as String,
      rssi: json['rssi'] as int,
      scanRecord: ScanRecord.fromJson(
        json['scanRecord'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceAddress': deviceAddress,
      'rssi': rssi,
      'scanRecord': scanRecord.toJson(),
    };
  }
}

/// Describes the properties of a characteristic. This follows Bluetooth Core
/// Specification BT 4.2 Vol 3 Part G 3.3.1. Characteristic Properties.
class CharacteristicProperties {
  final bool? broadcast;

  final bool? read;

  final bool? writeWithoutResponse;

  final bool? write;

  final bool? notify;

  final bool? indicate;

  final bool? authenticatedSignedWrites;

  final bool? extendedProperties;

  CharacteristicProperties({
    this.broadcast,
    this.read,
    this.writeWithoutResponse,
    this.write,
    this.notify,
    this.indicate,
    this.authenticatedSignedWrites,
    this.extendedProperties,
  });

  factory CharacteristicProperties.fromJson(Map<String, dynamic> json) {
    return CharacteristicProperties(
      broadcast: json.containsKey('broadcast')
          ? json['broadcast'] as bool
          : null,
      read: json.containsKey('read') ? json['read'] as bool : null,
      writeWithoutResponse: json.containsKey('writeWithoutResponse')
          ? json['writeWithoutResponse'] as bool
          : null,
      write: json.containsKey('write') ? json['write'] as bool : null,
      notify: json.containsKey('notify') ? json['notify'] as bool : null,
      indicate: json.containsKey('indicate') ? json['indicate'] as bool : null,
      authenticatedSignedWrites: json.containsKey('authenticatedSignedWrites')
          ? json['authenticatedSignedWrites'] as bool
          : null,
      extendedProperties: json.containsKey('extendedProperties')
          ? json['extendedProperties'] as bool
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (broadcast != null) 'broadcast': broadcast,
      if (read != null) 'read': read,
      if (writeWithoutResponse != null)
        'writeWithoutResponse': writeWithoutResponse,
      if (write != null) 'write': write,
      if (notify != null) 'notify': notify,
      if (indicate != null) 'indicate': indicate,
      if (authenticatedSignedWrites != null)
        'authenticatedSignedWrites': authenticatedSignedWrites,
      if (extendedProperties != null) 'extendedProperties': extendedProperties,
    };
  }
}
