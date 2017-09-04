import 'dart:async';
// ignore: unused_import
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'runtime.dart' as runtime;

class HeapProfilerDomain {
  final Client _client;

  HeapProfilerDomain(this._client);

  Stream<String> get onAddHeapSnapshotChunk => _client.onEvent
      .where((Event event) => event.name == 'HeapProfiler.addHeapSnapshotChunk')
      .map((Event event) => event.parameters['chunk'] as String);

  Stream get onResetProfiles => _client.onEvent
      .where((Event event) => event.name == 'HeapProfiler.resetProfiles');

  Stream<ReportHeapSnapshotProgressEvent> get onReportHeapSnapshotProgress =>
      _client.onEvent
          .where((Event event) =>
              event.name == 'HeapProfiler.reportHeapSnapshotProgress')
          .map((Event event) =>
              new ReportHeapSnapshotProgressEvent.fromJson(event.parameters));

  /// If heap objects tracking has been started then backend regularly sends a current value for last seen object id and corresponding timestamp. If the were changes in the heap since last event then one or more heapStatsUpdate events will be sent before a new lastSeenObjectId event.
  Stream<LastSeenObjectIdEvent> get onLastSeenObjectId => _client.onEvent
      .where((Event event) => event.name == 'HeapProfiler.lastSeenObjectId')
      .map((Event event) =>
          new LastSeenObjectIdEvent.fromJson(event.parameters));

  /// If heap objects tracking has been started then backend may send update for one or more fragments
  Stream<List<int>> get onHeapStatsUpdate => _client.onEvent
      .where((Event event) => event.name == 'HeapProfiler.heapStatsUpdate')
      .map((Event event) => (event.parameters['statsUpdate'] as List)
          .map((e) => e as int)
          .toList());

  Future enable() async {
    await _client.send('HeapProfiler.enable');
  }

  Future disable() async {
    await _client.send('HeapProfiler.disable');
  }

  Future startTrackingHeapObjects({
    bool trackAllocations,
  }) async {
    Map parameters = {};
    if (trackAllocations != null) {
      parameters['trackAllocations'] = trackAllocations;
    }
    await _client.send('HeapProfiler.startTrackingHeapObjects', parameters);
  }

  /// [reportProgress] If true 'reportHeapSnapshotProgress' events will be generated while snapshot is being taken when the tracking is stopped.
  Future stopTrackingHeapObjects({
    bool reportProgress,
  }) async {
    Map parameters = {};
    if (reportProgress != null) {
      parameters['reportProgress'] = reportProgress;
    }
    await _client.send('HeapProfiler.stopTrackingHeapObjects', parameters);
  }

  /// [reportProgress] If true 'reportHeapSnapshotProgress' events will be generated while snapshot is being taken.
  Future takeHeapSnapshot({
    bool reportProgress,
  }) async {
    Map parameters = {};
    if (reportProgress != null) {
      parameters['reportProgress'] = reportProgress;
    }
    await _client.send('HeapProfiler.takeHeapSnapshot', parameters);
  }

  Future collectGarbage() async {
    await _client.send('HeapProfiler.collectGarbage');
  }

  /// [objectGroup] Symbolic group name that can be used to release multiple objects.
  /// Return: Evaluation result.
  Future<runtime.RemoteObject> getObjectByHeapObjectId(
    HeapSnapshotObjectId objectId, {
    String objectGroup,
  }) async {
    Map parameters = {
      'objectId': objectId.toJson(),
    };
    if (objectGroup != null) {
      parameters['objectGroup'] = objectGroup;
    }
    Map result =
        await _client.send('HeapProfiler.getObjectByHeapObjectId', parameters);
    return new runtime.RemoteObject.fromJson(result['result']);
  }

  /// Enables console to refer to the node with given id via $x (see Command Line API for more details $x functions).
  /// [heapObjectId] Heap snapshot object id to be accessible by means of $x command line API.
  Future addInspectedHeapObject(
    HeapSnapshotObjectId heapObjectId,
  ) async {
    Map parameters = {
      'heapObjectId': heapObjectId.toJson(),
    };
    await _client.send('HeapProfiler.addInspectedHeapObject', parameters);
  }

  /// [objectId] Identifier of the object to get heap object id for.
  /// Return: Id of the heap snapshot object corresponding to the passed remote object id.
  Future<HeapSnapshotObjectId> getHeapObjectId(
    runtime.RemoteObjectId objectId,
  ) async {
    Map parameters = {
      'objectId': objectId.toJson(),
    };
    Map result = await _client.send('HeapProfiler.getHeapObjectId', parameters);
    return new HeapSnapshotObjectId.fromJson(result['heapSnapshotObjectId']);
  }

  /// [samplingInterval] Average sample interval in bytes. Poisson distribution is used for the intervals. The default value is 32768 bytes.
  Future startSampling({
    num samplingInterval,
  }) async {
    Map parameters = {};
    if (samplingInterval != null) {
      parameters['samplingInterval'] = samplingInterval;
    }
    await _client.send('HeapProfiler.startSampling', parameters);
  }

  /// Return: Recorded sampling heap profile.
  Future<SamplingHeapProfile> stopSampling() async {
    Map result = await _client.send('HeapProfiler.stopSampling');
    return new SamplingHeapProfile.fromJson(result['profile']);
  }
}

class ReportHeapSnapshotProgressEvent {
  final int done;

  final int total;

  final bool finished;

  ReportHeapSnapshotProgressEvent({
    @required this.done,
    @required this.total,
    this.finished,
  });

  factory ReportHeapSnapshotProgressEvent.fromJson(Map json) {
    return new ReportHeapSnapshotProgressEvent(
      done: json['done'],
      total: json['total'],
      finished: json.containsKey('finished') ? json['finished'] : null,
    );
  }
}

class LastSeenObjectIdEvent {
  final int lastSeenObjectId;

  final num timestamp;

  LastSeenObjectIdEvent({
    @required this.lastSeenObjectId,
    @required this.timestamp,
  });

  factory LastSeenObjectIdEvent.fromJson(Map json) {
    return new LastSeenObjectIdEvent(
      lastSeenObjectId: json['lastSeenObjectId'],
      timestamp: json['timestamp'],
    );
  }
}

/// Heap snapshot object id.
class HeapSnapshotObjectId {
  final String value;

  HeapSnapshotObjectId(this.value);

  factory HeapSnapshotObjectId.fromJson(String value) =>
      new HeapSnapshotObjectId(value);

  String toJson() => value;

  bool operator ==(other) =>
      other is HeapSnapshotObjectId && other.value == value;

  int get hashCode => value.hashCode;

  String toString() => value.toString();
}

/// Sampling Heap Profile node. Holds callsite information, allocation statistics and child nodes.
class SamplingHeapProfileNode {
  /// Function location.
  final runtime.CallFrame callFrame;

  /// Allocations size in bytes for the node excluding children.
  final num selfSize;

  /// Child nodes.
  final List<SamplingHeapProfileNode> children;

  SamplingHeapProfileNode({
    @required this.callFrame,
    @required this.selfSize,
    @required this.children,
  });

  factory SamplingHeapProfileNode.fromJson(Map json) {
    return new SamplingHeapProfileNode(
      callFrame: new runtime.CallFrame.fromJson(json['callFrame']),
      selfSize: json['selfSize'],
      children: (json['children'] as List)
          .map((e) => new SamplingHeapProfileNode.fromJson(e))
          .toList(),
    );
  }

  Map toJson() {
    Map json = {
      'callFrame': callFrame.toJson(),
      'selfSize': selfSize,
      'children': children.map((e) => e.toJson()).toList(),
    };
    return json;
  }
}

/// Profile.
class SamplingHeapProfile {
  final SamplingHeapProfileNode head;

  SamplingHeapProfile({
    @required this.head,
  });

  factory SamplingHeapProfile.fromJson(Map json) {
    return new SamplingHeapProfile(
      head: new SamplingHeapProfileNode.fromJson(json['head']),
    );
  }

  Map toJson() {
    Map json = {
      'head': head.toJson(),
    };
    return json;
  }
}
