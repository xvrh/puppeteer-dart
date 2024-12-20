import 'dart:async';
import '../src/connection.dart';

/// This domain allows configuring virtual Bluetooth devices to test
/// the web-bluetooth API.
class BluetoothEmulationApi {
  final Client _client;

  BluetoothEmulationApi(this._client);

  /// Enable the BluetoothEmulation domain.
  /// [state] State of the simulated central.
  Future<void> enable(CentralState state) async {
    await _client.send('BluetoothEmulation.enable', {'state': state});
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
      uuids:
          json.containsKey('uuids')
              ? (json['uuids'] as List).map((e) => e as String).toList()
              : null,
      appearance:
          json.containsKey('appearance') ? json['appearance'] as int : null,
      txPower: json.containsKey('txPower') ? json['txPower'] as int : null,
      manufacturerData:
          json.containsKey('manufacturerData')
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
