/// The SystemInfo domain defines methods and events for querying low-level system information.

import 'dart:async';
// ignore: unused_import
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';

class SystemInfoDomain {
  final Client _client;

  SystemInfoDomain(this._client);

  /// Returns information about the system.
  Future<GetInfoResult> getInfo() async {
    Map result = await _client.send('SystemInfo.getInfo');
    return new GetInfoResult.fromJson(result);
  }
}

class GetInfoResult {
  /// Information about the GPUs on the system.
  final GPUInfo gpu;

  /// A platform-dependent description of the model of the machine. On Mac OS, this is, for example, 'MacBookPro'. Will be the empty string if not supported.
  final String modelName;

  /// A platform-dependent description of the version of the machine. On Mac OS, this is, for example, '10.1'. Will be the empty string if not supported.
  final String modelVersion;

  /// The command line string used to launch the browser. Will be the empty string if not supported.
  final String commandLine;

  GetInfoResult({
    @required this.gpu,
    @required this.modelName,
    @required this.modelVersion,
    @required this.commandLine,
  });

  factory GetInfoResult.fromJson(Map json) {
    return new GetInfoResult(
      gpu: new GPUInfo.fromJson(json['gpu']),
      modelName: json['modelName'],
      modelVersion: json['modelVersion'],
      commandLine: json['commandLine'],
    );
  }
}

/// Describes a single graphics processor (GPU).
class GPUDevice {
  /// PCI ID of the GPU vendor, if available; 0 otherwise.
  final num vendorId;

  /// PCI ID of the GPU device, if available; 0 otherwise.
  final num deviceId;

  /// String description of the GPU vendor, if the PCI ID is not available.
  final String vendorString;

  /// String description of the GPU device, if the PCI ID is not available.
  final String deviceString;

  GPUDevice({
    @required this.vendorId,
    @required this.deviceId,
    @required this.vendorString,
    @required this.deviceString,
  });

  factory GPUDevice.fromJson(Map json) {
    return new GPUDevice(
      vendorId: json['vendorId'],
      deviceId: json['deviceId'],
      vendorString: json['vendorString'],
      deviceString: json['deviceString'],
    );
  }

  Map toJson() {
    Map json = {
      'vendorId': vendorId,
      'deviceId': deviceId,
      'vendorString': vendorString,
      'deviceString': deviceString,
    };
    return json;
  }
}

/// Provides information about the GPU(s) on the system.
class GPUInfo {
  /// The graphics devices on the system. Element 0 is the primary GPU.
  final List<GPUDevice> devices;

  /// An optional dictionary of additional GPU related attributes.
  final Map auxAttributes;

  /// An optional dictionary of graphics features and their status.
  final Map featureStatus;

  /// An optional array of GPU driver bug workarounds.
  final List<String> driverBugWorkarounds;

  GPUInfo({
    @required this.devices,
    this.auxAttributes,
    this.featureStatus,
    @required this.driverBugWorkarounds,
  });

  factory GPUInfo.fromJson(Map json) {
    return new GPUInfo(
      devices: (json['devices'] as List)
          .map((e) => new GPUDevice.fromJson(e))
          .toList(),
      auxAttributes:
          json.containsKey('auxAttributes') ? json['auxAttributes'] : null,
      featureStatus:
          json.containsKey('featureStatus') ? json['featureStatus'] : null,
      driverBugWorkarounds: (json['driverBugWorkarounds'] as List)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map toJson() {
    Map json = {
      'devices': devices.map((e) => e.toJson()).toList(),
      'driverBugWorkarounds': driverBugWorkarounds.map((e) => e).toList(),
    };
    if (auxAttributes != null) {
      json['auxAttributes'] = auxAttributes;
    }
    if (featureStatus != null) {
      json['featureStatus'] = featureStatus;
    }
    return json;
  }
}
