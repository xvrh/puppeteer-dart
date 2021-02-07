import 'dart:async';
import '../src/connection.dart';

class MemoryApi {
  final Client _client;

  MemoryApi(this._client);

  Future<GetDOMCountersResult> getDOMCounters() async {
    var result = await _client.send('Memory.getDOMCounters');
    return GetDOMCountersResult.fromJson(result);
  }

  Future<void> prepareForLeakDetection() async {
    await _client.send('Memory.prepareForLeakDetection');
  }

  /// Simulate OomIntervention by purging V8 memory.
  Future<void> forciblyPurgeJavaScriptMemory() async {
    await _client.send('Memory.forciblyPurgeJavaScriptMemory');
  }

  /// Enable/disable suppressing memory pressure notifications in all processes.
  /// [suppressed] If true, memory pressure notifications will be suppressed.
  Future<void> setPressureNotificationsSuppressed(bool suppressed) async {
    await _client.send('Memory.setPressureNotificationsSuppressed', {
      'suppressed': suppressed,
    });
  }

  /// Simulate a memory pressure notification in all processes.
  /// [level] Memory pressure level of the notification.
  Future<void> simulatePressureNotification(PressureLevel level) async {
    await _client.send('Memory.simulatePressureNotification', {
      'level': level,
    });
  }

  /// Start collecting native memory profile.
  /// [samplingInterval] Average number of bytes between samples.
  /// [suppressRandomness] Do not randomize intervals between samples.
  Future<void> startSampling(
      {int? samplingInterval, bool? suppressRandomness}) async {
    await _client.send('Memory.startSampling', {
      if (samplingInterval != null) 'samplingInterval': samplingInterval,
      if (suppressRandomness != null) 'suppressRandomness': suppressRandomness,
    });
  }

  /// Stop collecting native memory profile.
  Future<void> stopSampling() async {
    await _client.send('Memory.stopSampling');
  }

  /// Retrieve native memory allocations profile
  /// collected since renderer process startup.
  Future<SamplingProfile> getAllTimeSamplingProfile() async {
    var result = await _client.send('Memory.getAllTimeSamplingProfile');
    return SamplingProfile.fromJson(result['profile'] as Map<String, dynamic>);
  }

  /// Retrieve native memory allocations profile
  /// collected since browser process startup.
  Future<SamplingProfile> getBrowserSamplingProfile() async {
    var result = await _client.send('Memory.getBrowserSamplingProfile');
    return SamplingProfile.fromJson(result['profile'] as Map<String, dynamic>);
  }

  /// Retrieve native memory allocations profile collected since last
  /// `startSampling` call.
  Future<SamplingProfile> getSamplingProfile() async {
    var result = await _client.send('Memory.getSamplingProfile');
    return SamplingProfile.fromJson(result['profile'] as Map<String, dynamic>);
  }
}

class GetDOMCountersResult {
  final int documents;

  final int nodes;

  final int jsEventListeners;

  GetDOMCountersResult(
      {required this.documents,
      required this.nodes,
      required this.jsEventListeners});

  factory GetDOMCountersResult.fromJson(Map<String, dynamic> json) {
    return GetDOMCountersResult(
      documents: json['documents'] as int,
      nodes: json['nodes'] as int,
      jsEventListeners: json['jsEventListeners'] as int,
    );
  }
}

/// Memory pressure level.
class PressureLevel {
  static const moderate = PressureLevel._('moderate');
  static const critical = PressureLevel._('critical');
  static const values = {
    'moderate': moderate,
    'critical': critical,
  };

  final String value;

  const PressureLevel._(this.value);

  factory PressureLevel.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is PressureLevel && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Heap profile sample.
class SamplingProfileNode {
  /// Size of the sampled allocation.
  final num size;

  /// Total bytes attributed to this sample.
  final num total;

  /// Execution stack at the point of allocation.
  final List<String> stack;

  SamplingProfileNode(
      {required this.size, required this.total, required this.stack});

  factory SamplingProfileNode.fromJson(Map<String, dynamic> json) {
    return SamplingProfileNode(
      size: json['size'] as num,
      total: json['total'] as num,
      stack: (json['stack'] as List).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'total': total,
      'stack': [...stack],
    };
  }
}

/// Array of heap profile samples.
class SamplingProfile {
  final List<SamplingProfileNode> samples;

  final List<Module> modules;

  SamplingProfile({required this.samples, required this.modules});

  factory SamplingProfile.fromJson(Map<String, dynamic> json) {
    return SamplingProfile(
      samples: (json['samples'] as List)
          .map((e) => SamplingProfileNode.fromJson(e as Map<String, dynamic>))
          .toList(),
      modules: (json['modules'] as List)
          .map((e) => Module.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'samples': samples.map((e) => e.toJson()).toList(),
      'modules': modules.map((e) => e.toJson()).toList(),
    };
  }
}

/// Executable module information
class Module {
  /// Name of the module.
  final String name;

  /// UUID of the module.
  final String uuid;

  /// Base address where the module is loaded into memory. Encoded as a decimal
  /// or hexadecimal (0x prefixed) string.
  final String baseAddress;

  /// Size of the module in bytes.
  final num size;

  Module(
      {required this.name,
      required this.uuid,
      required this.baseAddress,
      required this.size});

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      name: json['name'] as String,
      uuid: json['uuid'] as String,
      baseAddress: json['baseAddress'] as String,
      size: json['size'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'uuid': uuid,
      'baseAddress': baseAddress,
      'size': size,
    };
  }
}
