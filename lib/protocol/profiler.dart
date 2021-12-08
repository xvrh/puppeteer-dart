import 'dart:async';
import '../src/connection.dart';
import 'debugger.dart' as debugger;
import 'runtime.dart' as runtime;

class ProfilerApi {
  final Client _client;

  ProfilerApi(this._client);

  Stream<ConsoleProfileFinishedEvent> get onConsoleProfileFinished => _client
      .onEvent
      .where((event) => event.name == 'Profiler.consoleProfileFinished')
      .map((event) => ConsoleProfileFinishedEvent.fromJson(event.parameters));

  /// Sent when new profile recording is started using console.profile() call.
  Stream<ConsoleProfileStartedEvent> get onConsoleProfileStarted => _client
      .onEvent
      .where((event) => event.name == 'Profiler.consoleProfileStarted')
      .map((event) => ConsoleProfileStartedEvent.fromJson(event.parameters));

  /// Reports coverage delta since the last poll (either from an event like this, or from
  /// `takePreciseCoverage` for the current isolate. May only be sent if precise code
  /// coverage has been started. This event can be trigged by the embedder to, for example,
  /// trigger collection of coverage data immediately at a certain point in time.
  Stream<PreciseCoverageDeltaUpdateEvent> get onPreciseCoverageDeltaUpdate =>
      _client.onEvent
          .where((event) => event.name == 'Profiler.preciseCoverageDeltaUpdate')
          .map((event) =>
              PreciseCoverageDeltaUpdateEvent.fromJson(event.parameters));

  Future<void> disable() async {
    await _client.send('Profiler.disable');
  }

  Future<void> enable() async {
    await _client.send('Profiler.enable');
  }

  /// Collect coverage data for the current isolate. The coverage data may be incomplete due to
  /// garbage collection.
  /// Returns: Coverage data for the current isolate.
  Future<List<ScriptCoverage>> getBestEffortCoverage() async {
    var result = await _client.send('Profiler.getBestEffortCoverage');
    return (result['result'] as List)
        .map((e) => ScriptCoverage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Changes CPU profiler sampling interval. Must be called before CPU profiles recording started.
  /// [interval] New sampling interval in microseconds.
  Future<void> setSamplingInterval(int interval) async {
    await _client.send('Profiler.setSamplingInterval', {
      'interval': interval,
    });
  }

  Future<void> start() async {
    await _client.send('Profiler.start');
  }

  /// Enable precise code coverage. Coverage data for JavaScript executed before enabling precise code
  /// coverage may be incomplete. Enabling prevents running optimized code and resets execution
  /// counters.
  /// [callCount] Collect accurate call counts beyond simple 'covered' or 'not covered'.
  /// [detailed] Collect block-based coverage.
  /// [allowTriggeredUpdates] Allow the backend to send updates on its own initiative
  /// Returns: Monotonically increasing time (in seconds) when the coverage update was taken in the backend.
  Future<num> startPreciseCoverage(
      {bool? callCount, bool? detailed, bool? allowTriggeredUpdates}) async {
    var result = await _client.send('Profiler.startPreciseCoverage', {
      if (callCount != null) 'callCount': callCount,
      if (detailed != null) 'detailed': detailed,
      if (allowTriggeredUpdates != null)
        'allowTriggeredUpdates': allowTriggeredUpdates,
    });
    return result['timestamp'] as num;
  }

  /// Enable type profile.
  Future<void> startTypeProfile() async {
    await _client.send('Profiler.startTypeProfile');
  }

  /// Returns: Recorded profile.
  Future<Profile> stop() async {
    var result = await _client.send('Profiler.stop');
    return Profile.fromJson(result['profile'] as Map<String, dynamic>);
  }

  /// Disable precise code coverage. Disabling releases unnecessary execution count records and allows
  /// executing optimized code.
  Future<void> stopPreciseCoverage() async {
    await _client.send('Profiler.stopPreciseCoverage');
  }

  /// Disable type profile. Disabling releases type profile data collected so far.
  Future<void> stopTypeProfile() async {
    await _client.send('Profiler.stopTypeProfile');
  }

  /// Collect coverage data for the current isolate, and resets execution counters. Precise code
  /// coverage needs to have started.
  Future<TakePreciseCoverageResult> takePreciseCoverage() async {
    var result = await _client.send('Profiler.takePreciseCoverage');
    return TakePreciseCoverageResult.fromJson(result);
  }

  /// Collect type profile.
  /// Returns: Type profile for all scripts since startTypeProfile() was turned on.
  Future<List<ScriptTypeProfile>> takeTypeProfile() async {
    var result = await _client.send('Profiler.takeTypeProfile');
    return (result['result'] as List)
        .map((e) => ScriptTypeProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class ConsoleProfileFinishedEvent {
  final String id;

  /// Location of console.profileEnd().
  final debugger.Location location;

  final Profile profile;

  /// Profile title passed as an argument to console.profile().
  final String? title;

  ConsoleProfileFinishedEvent(
      {required this.id,
      required this.location,
      required this.profile,
      this.title});

  factory ConsoleProfileFinishedEvent.fromJson(Map<String, dynamic> json) {
    return ConsoleProfileFinishedEvent(
      id: json['id'] as String,
      location:
          debugger.Location.fromJson(json['location'] as Map<String, dynamic>),
      profile: Profile.fromJson(json['profile'] as Map<String, dynamic>),
      title: json.containsKey('title') ? json['title'] as String : null,
    );
  }
}

class ConsoleProfileStartedEvent {
  final String id;

  /// Location of console.profile().
  final debugger.Location location;

  /// Profile title passed as an argument to console.profile().
  final String? title;

  ConsoleProfileStartedEvent(
      {required this.id, required this.location, this.title});

  factory ConsoleProfileStartedEvent.fromJson(Map<String, dynamic> json) {
    return ConsoleProfileStartedEvent(
      id: json['id'] as String,
      location:
          debugger.Location.fromJson(json['location'] as Map<String, dynamic>),
      title: json.containsKey('title') ? json['title'] as String : null,
    );
  }
}

class PreciseCoverageDeltaUpdateEvent {
  /// Monotonically increasing time (in seconds) when the coverage update was taken in the backend.
  final num timestamp;

  /// Identifier for distinguishing coverage events.
  final String occasion;

  /// Coverage data for the current isolate.
  final List<ScriptCoverage> result;

  PreciseCoverageDeltaUpdateEvent(
      {required this.timestamp, required this.occasion, required this.result});

  factory PreciseCoverageDeltaUpdateEvent.fromJson(Map<String, dynamic> json) {
    return PreciseCoverageDeltaUpdateEvent(
      timestamp: json['timestamp'] as num,
      occasion: json['occasion'] as String,
      result: (json['result'] as List)
          .map((e) => ScriptCoverage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TakePreciseCoverageResult {
  /// Coverage data for the current isolate.
  final List<ScriptCoverage> result;

  /// Monotonically increasing time (in seconds) when the coverage update was taken in the backend.
  final num timestamp;

  TakePreciseCoverageResult({required this.result, required this.timestamp});

  factory TakePreciseCoverageResult.fromJson(Map<String, dynamic> json) {
    return TakePreciseCoverageResult(
      result: (json['result'] as List)
          .map((e) => ScriptCoverage.fromJson(e as Map<String, dynamic>))
          .toList(),
      timestamp: json['timestamp'] as num,
    );
  }
}

/// Profile node. Holds callsite information, execution statistics and child nodes.
class ProfileNode {
  /// Unique id of the node.
  final int id;

  /// Function location.
  final runtime.CallFrame callFrame;

  /// Number of samples where this node was on top of the call stack.
  final int? hitCount;

  /// Child node ids.
  final List<int>? children;

  /// The reason of being not optimized. The function may be deoptimized or marked as don't
  /// optimize.
  final String? deoptReason;

  /// An array of source position ticks.
  final List<PositionTickInfo>? positionTicks;

  ProfileNode(
      {required this.id,
      required this.callFrame,
      this.hitCount,
      this.children,
      this.deoptReason,
      this.positionTicks});

  factory ProfileNode.fromJson(Map<String, dynamic> json) {
    return ProfileNode(
      id: json['id'] as int,
      callFrame:
          runtime.CallFrame.fromJson(json['callFrame'] as Map<String, dynamic>),
      hitCount: json.containsKey('hitCount') ? json['hitCount'] as int : null,
      children: json.containsKey('children')
          ? (json['children'] as List).map((e) => e as int).toList()
          : null,
      deoptReason: json.containsKey('deoptReason')
          ? json['deoptReason'] as String
          : null,
      positionTicks: json.containsKey('positionTicks')
          ? (json['positionTicks'] as List)
              .map((e) => PositionTickInfo.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'callFrame': callFrame.toJson(),
      if (hitCount != null) 'hitCount': hitCount,
      if (children != null) 'children': [...?children],
      if (deoptReason != null) 'deoptReason': deoptReason,
      if (positionTicks != null)
        'positionTicks': positionTicks!.map((e) => e.toJson()).toList(),
    };
  }
}

/// Profile.
class Profile {
  /// The list of profile nodes. First item is the root node.
  final List<ProfileNode> nodes;

  /// Profiling start timestamp in microseconds.
  final num startTime;

  /// Profiling end timestamp in microseconds.
  final num endTime;

  /// Ids of samples top nodes.
  final List<int>? samples;

  /// Time intervals between adjacent samples in microseconds. The first delta is relative to the
  /// profile startTime.
  final List<int>? timeDeltas;

  Profile(
      {required this.nodes,
      required this.startTime,
      required this.endTime,
      this.samples,
      this.timeDeltas});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      nodes: (json['nodes'] as List)
          .map((e) => ProfileNode.fromJson(e as Map<String, dynamic>))
          .toList(),
      startTime: json['startTime'] as num,
      endTime: json['endTime'] as num,
      samples: json.containsKey('samples')
          ? (json['samples'] as List).map((e) => e as int).toList()
          : null,
      timeDeltas: json.containsKey('timeDeltas')
          ? (json['timeDeltas'] as List).map((e) => e as int).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nodes': nodes.map((e) => e.toJson()).toList(),
      'startTime': startTime,
      'endTime': endTime,
      if (samples != null) 'samples': [...?samples],
      if (timeDeltas != null) 'timeDeltas': [...?timeDeltas],
    };
  }
}

/// Specifies a number of samples attributed to a certain source position.
class PositionTickInfo {
  /// Source line number (1-based).
  final int line;

  /// Number of samples attributed to the source line.
  final int ticks;

  PositionTickInfo({required this.line, required this.ticks});

  factory PositionTickInfo.fromJson(Map<String, dynamic> json) {
    return PositionTickInfo(
      line: json['line'] as int,
      ticks: json['ticks'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line': line,
      'ticks': ticks,
    };
  }
}

/// Coverage data for a source range.
class CoverageRange {
  /// JavaScript script source offset for the range start.
  final int startOffset;

  /// JavaScript script source offset for the range end.
  final int endOffset;

  /// Collected execution count of the source range.
  final int count;

  CoverageRange(
      {required this.startOffset,
      required this.endOffset,
      required this.count});

  factory CoverageRange.fromJson(Map<String, dynamic> json) {
    return CoverageRange(
      startOffset: json['startOffset'] as int,
      endOffset: json['endOffset'] as int,
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startOffset': startOffset,
      'endOffset': endOffset,
      'count': count,
    };
  }
}

/// Coverage data for a JavaScript function.
class FunctionCoverage {
  /// JavaScript function name.
  final String functionName;

  /// Source ranges inside the function with coverage data.
  final List<CoverageRange> ranges;

  /// Whether coverage data for this function has block granularity.
  final bool isBlockCoverage;

  FunctionCoverage(
      {required this.functionName,
      required this.ranges,
      required this.isBlockCoverage});

  factory FunctionCoverage.fromJson(Map<String, dynamic> json) {
    return FunctionCoverage(
      functionName: json['functionName'] as String,
      ranges: (json['ranges'] as List)
          .map((e) => CoverageRange.fromJson(e as Map<String, dynamic>))
          .toList(),
      isBlockCoverage: json['isBlockCoverage'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'functionName': functionName,
      'ranges': ranges.map((e) => e.toJson()).toList(),
      'isBlockCoverage': isBlockCoverage,
    };
  }
}

/// Coverage data for a JavaScript script.
class ScriptCoverage {
  /// JavaScript script id.
  final runtime.ScriptId scriptId;

  /// JavaScript script name or url.
  final String url;

  /// Functions contained in the script that has coverage data.
  final List<FunctionCoverage> functions;

  ScriptCoverage(
      {required this.scriptId, required this.url, required this.functions});

  factory ScriptCoverage.fromJson(Map<String, dynamic> json) {
    return ScriptCoverage(
      scriptId: runtime.ScriptId.fromJson(json['scriptId'] as String),
      url: json['url'] as String,
      functions: (json['functions'] as List)
          .map((e) => FunctionCoverage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scriptId': scriptId.toJson(),
      'url': url,
      'functions': functions.map((e) => e.toJson()).toList(),
    };
  }
}

/// Describes a type collected during runtime.
class TypeObject {
  /// Name of a type collected with type profiling.
  final String name;

  TypeObject({required this.name});

  factory TypeObject.fromJson(Map<String, dynamic> json) {
    return TypeObject(
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

/// Source offset and types for a parameter or return value.
class TypeProfileEntry {
  /// Source offset of the parameter or end of function for return values.
  final int offset;

  /// The types for this parameter or return value.
  final List<TypeObject> types;

  TypeProfileEntry({required this.offset, required this.types});

  factory TypeProfileEntry.fromJson(Map<String, dynamic> json) {
    return TypeProfileEntry(
      offset: json['offset'] as int,
      types: (json['types'] as List)
          .map((e) => TypeObject.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offset': offset,
      'types': types.map((e) => e.toJson()).toList(),
    };
  }
}

/// Type profile data collected during runtime for a JavaScript script.
class ScriptTypeProfile {
  /// JavaScript script id.
  final runtime.ScriptId scriptId;

  /// JavaScript script name or url.
  final String url;

  /// Type profile entries for parameters and return values of the functions in the script.
  final List<TypeProfileEntry> entries;

  ScriptTypeProfile(
      {required this.scriptId, required this.url, required this.entries});

  factory ScriptTypeProfile.fromJson(Map<String, dynamic> json) {
    return ScriptTypeProfile(
      scriptId: runtime.ScriptId.fromJson(json['scriptId'] as String),
      url: json['url'] as String,
      entries: (json['entries'] as List)
          .map((e) => TypeProfileEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scriptId': scriptId.toJson(),
      'url': url,
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }
}
