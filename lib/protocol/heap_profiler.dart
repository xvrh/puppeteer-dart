import 'dart:async';
import '../src/connection.dart';
import 'runtime.dart' as runtime;

class HeapProfilerApi {
  final Client _client;

  HeapProfilerApi(this._client);

  Stream<String> get onAddHeapSnapshotChunk => _client.onEvent
      .where((event) => event.name == 'HeapProfiler.addHeapSnapshotChunk')
      .map((event) => event.parameters['chunk'] as String);

  /// If heap objects tracking has been started then backend may send update for one or more fragments
  Stream<List<int>> get onHeapStatsUpdate => _client.onEvent
      .where((event) => event.name == 'HeapProfiler.heapStatsUpdate')
      .map((event) => (event.parameters['statsUpdate'] as List)
          .map((e) => e as int)
          .toList());

  /// If heap objects tracking has been started then backend regularly sends a current value for last
  /// seen object id and corresponding timestamp. If the were changes in the heap since last event
  /// then one or more heapStatsUpdate events will be sent before a new lastSeenObjectId event.
  Stream<LastSeenObjectIdEvent> get onLastSeenObjectId => _client.onEvent
      .where((event) => event.name == 'HeapProfiler.lastSeenObjectId')
      .map((event) => LastSeenObjectIdEvent.fromJson(event.parameters));

  Stream<ReportHeapSnapshotProgressEvent> get onReportHeapSnapshotProgress =>
      _client.onEvent
          .where((event) =>
              event.name == 'HeapProfiler.reportHeapSnapshotProgress')
          .map((event) =>
              ReportHeapSnapshotProgressEvent.fromJson(event.parameters));

  Stream get onResetProfiles => _client.onEvent
      .where((event) => event.name == 'HeapProfiler.resetProfiles');

  /// Enables console to refer to the node with given id via $x (see Command Line API for more details
  /// $x functions).
  /// [heapObjectId] Heap snapshot object id to be accessible by means of $x command line API.
  Future<void> addInspectedHeapObject(HeapSnapshotObjectId heapObjectId) async {
    await _client.send('HeapProfiler.addInspectedHeapObject', {
      'heapObjectId': heapObjectId,
    });
  }

  Future<void> collectGarbage() async {
    await _client.send('HeapProfiler.collectGarbage');
  }

  Future<void> disable() async {
    await _client.send('HeapProfiler.disable');
  }

  Future<void> enable() async {
    await _client.send('HeapProfiler.enable');
  }

  /// [objectId] Identifier of the object to get heap object id for.
  /// Returns: Id of the heap snapshot object corresponding to the passed remote object id.
  Future<HeapSnapshotObjectId> getHeapObjectId(
      runtime.RemoteObjectId objectId) async {
    var result = await _client.send('HeapProfiler.getHeapObjectId', {
      'objectId': objectId,
    });
    return HeapSnapshotObjectId.fromJson(
        result['heapSnapshotObjectId'] as String);
  }

  /// [objectGroup] Symbolic group name that can be used to release multiple objects.
  /// Returns: Evaluation result.
  Future<runtime.RemoteObject> getObjectByHeapObjectId(
      HeapSnapshotObjectId objectId,
      {String? objectGroup}) async {
    var result = await _client.send('HeapProfiler.getObjectByHeapObjectId', {
      'objectId': objectId,
      if (objectGroup != null) 'objectGroup': objectGroup,
    });
    return runtime.RemoteObject.fromJson(
        result['result'] as Map<String, dynamic>);
  }

  /// Returns: Return the sampling profile being collected.
  Future<SamplingHeapProfile> getSamplingProfile() async {
    var result = await _client.send('HeapProfiler.getSamplingProfile');
    return SamplingHeapProfile.fromJson(
        result['profile'] as Map<String, dynamic>);
  }

  /// [samplingInterval] Average sample interval in bytes. Poisson distribution is used for the intervals. The
  /// default value is 32768 bytes.
  Future<void> startSampling({num? samplingInterval}) async {
    await _client.send('HeapProfiler.startSampling', {
      if (samplingInterval != null) 'samplingInterval': samplingInterval,
    });
  }

  Future<void> startTrackingHeapObjects({bool? trackAllocations}) async {
    await _client.send('HeapProfiler.startTrackingHeapObjects', {
      if (trackAllocations != null) 'trackAllocations': trackAllocations,
    });
  }

  /// Returns: Recorded sampling heap profile.
  Future<SamplingHeapProfile> stopSampling() async {
    var result = await _client.send('HeapProfiler.stopSampling');
    return SamplingHeapProfile.fromJson(
        result['profile'] as Map<String, dynamic>);
  }

  /// [reportProgress] If true 'reportHeapSnapshotProgress' events will be generated while snapshot is being taken
  /// when the tracking is stopped.
  /// [captureNumericValue] If true, numerical values are included in the snapshot
  Future<void> stopTrackingHeapObjects(
      {bool? reportProgress,
      bool? treatGlobalObjectsAsRoots,
      bool? captureNumericValue}) async {
    await _client.send('HeapProfiler.stopTrackingHeapObjects', {
      if (reportProgress != null) 'reportProgress': reportProgress,
      if (treatGlobalObjectsAsRoots != null)
        'treatGlobalObjectsAsRoots': treatGlobalObjectsAsRoots,
      if (captureNumericValue != null)
        'captureNumericValue': captureNumericValue,
    });
  }

  /// [reportProgress] If true 'reportHeapSnapshotProgress' events will be generated while snapshot is being taken.
  /// [treatGlobalObjectsAsRoots] If true, a raw snapshot without artificial roots will be generated
  /// [captureNumericValue] If true, numerical values are included in the snapshot
  Future<void> takeHeapSnapshot(
      {bool? reportProgress,
      bool? treatGlobalObjectsAsRoots,
      bool? captureNumericValue}) async {
    await _client.send('HeapProfiler.takeHeapSnapshot', {
      if (reportProgress != null) 'reportProgress': reportProgress,
      if (treatGlobalObjectsAsRoots != null)
        'treatGlobalObjectsAsRoots': treatGlobalObjectsAsRoots,
      if (captureNumericValue != null)
        'captureNumericValue': captureNumericValue,
    });
  }
}

class LastSeenObjectIdEvent {
  final int lastSeenObjectId;

  final num timestamp;

  LastSeenObjectIdEvent(
      {required this.lastSeenObjectId, required this.timestamp});

  factory LastSeenObjectIdEvent.fromJson(Map<String, dynamic> json) {
    return LastSeenObjectIdEvent(
      lastSeenObjectId: json['lastSeenObjectId'] as int,
      timestamp: json['timestamp'] as num,
    );
  }
}

class ReportHeapSnapshotProgressEvent {
  final int done;

  final int total;

  final bool? finished;

  ReportHeapSnapshotProgressEvent(
      {required this.done, required this.total, this.finished});

  factory ReportHeapSnapshotProgressEvent.fromJson(Map<String, dynamic> json) {
    return ReportHeapSnapshotProgressEvent(
      done: json['done'] as int,
      total: json['total'] as int,
      finished: json.containsKey('finished') ? json['finished'] as bool : null,
    );
  }
}

/// Heap snapshot object id.
class HeapSnapshotObjectId {
  final String value;

  HeapSnapshotObjectId(this.value);

  factory HeapSnapshotObjectId.fromJson(String value) =>
      HeapSnapshotObjectId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is HeapSnapshotObjectId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Sampling Heap Profile node. Holds callsite information, allocation statistics and child nodes.
class SamplingHeapProfileNode {
  /// Function location.
  final runtime.CallFrame callFrame;

  /// Allocations size in bytes for the node excluding children.
  final num selfSize;

  /// Node id. Ids are unique across all profiles collected between startSampling and stopSampling.
  final int id;

  /// Child nodes.
  final List<SamplingHeapProfileNode> children;

  SamplingHeapProfileNode(
      {required this.callFrame,
      required this.selfSize,
      required this.id,
      required this.children});

  factory SamplingHeapProfileNode.fromJson(Map<String, dynamic> json) {
    return SamplingHeapProfileNode(
      callFrame:
          runtime.CallFrame.fromJson(json['callFrame'] as Map<String, dynamic>),
      selfSize: json['selfSize'] as num,
      id: json['id'] as int,
      children: (json['children'] as List)
          .map((e) =>
              SamplingHeapProfileNode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'callFrame': callFrame.toJson(),
      'selfSize': selfSize,
      'id': id,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}

/// A single sample from a sampling profile.
class SamplingHeapProfileSample {
  /// Allocation size in bytes attributed to the sample.
  final num size;

  /// Id of the corresponding profile tree node.
  final int nodeId;

  /// Time-ordered sample ordinal number. It is unique across all profiles retrieved
  /// between startSampling and stopSampling.
  final num ordinal;

  SamplingHeapProfileSample(
      {required this.size, required this.nodeId, required this.ordinal});

  factory SamplingHeapProfileSample.fromJson(Map<String, dynamic> json) {
    return SamplingHeapProfileSample(
      size: json['size'] as num,
      nodeId: json['nodeId'] as int,
      ordinal: json['ordinal'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'nodeId': nodeId,
      'ordinal': ordinal,
    };
  }
}

/// Sampling profile.
class SamplingHeapProfile {
  final SamplingHeapProfileNode head;

  final List<SamplingHeapProfileSample> samples;

  SamplingHeapProfile({required this.head, required this.samples});

  factory SamplingHeapProfile.fromJson(Map<String, dynamic> json) {
    return SamplingHeapProfile(
      head: SamplingHeapProfileNode.fromJson(
          json['head'] as Map<String, dynamic>),
      samples: (json['samples'] as List)
          .map((e) =>
              SamplingHeapProfileSample.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'head': head.toJson(),
      'samples': samples.map((e) => e.toJson()).toList(),
    };
  }
}
