import 'dart:async';
// ignore: unused_import
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'runtime.dart' as runtime;
import 'debugger.dart' as debugger;

class ProfilerDomain {
  final Client _client;

  ProfilerDomain(this._client);

  Stream<ConsoleProfileFinishedEvent> get onConsoleProfileFinished => _client
      .onEvent
      .where((Event event) => event.name == 'Profiler.consoleProfileFinished')
      .map((Event event) =>
          new ConsoleProfileFinishedEvent.fromJson(event.parameters));

  /// Sent when new profile recording is started using console.profile() call.
  Stream<ConsoleProfileStartedEvent> get onConsoleProfileStarted => _client
      .onEvent
      .where((Event event) => event.name == 'Profiler.consoleProfileStarted')
      .map((Event event) =>
          new ConsoleProfileStartedEvent.fromJson(event.parameters));

  Future disable() async {
    await _client.send('Profiler.disable');
  }

  Future enable() async {
    await _client.send('Profiler.enable');
  }

  /// Collect coverage data for the current isolate. The coverage data may be incomplete due to
  /// garbage collection.
  /// Return: Coverage data for the current isolate.
  Future<List<ScriptCoverage>> getBestEffortCoverage() async {
    Map result = await _client.send('Profiler.getBestEffortCoverage');
    return (result['result'] as List)
        .map((e) => new ScriptCoverage.fromJson(e))
        .toList();
  }

  /// Changes CPU profiler sampling interval. Must be called before CPU profiles recording started.
  /// [interval] New sampling interval in microseconds.
  Future setSamplingInterval(
    int interval,
  ) async {
    Map parameters = {
      'interval': interval,
    };
    await _client.send('Profiler.setSamplingInterval', parameters);
  }

  Future start() async {
    await _client.send('Profiler.start');
  }

  /// Enable precise code coverage. Coverage data for JavaScript executed before enabling precise code
  /// coverage may be incomplete. Enabling prevents running optimized code and resets execution
  /// counters.
  /// [callCount] Collect accurate call counts beyond simple 'covered' or 'not covered'.
  /// [detailed] Collect block-based coverage.
  Future startPreciseCoverage({
    bool callCount,
    bool detailed,
  }) async {
    Map parameters = {};
    if (callCount != null) {
      parameters['callCount'] = callCount;
    }
    if (detailed != null) {
      parameters['detailed'] = detailed;
    }
    await _client.send('Profiler.startPreciseCoverage', parameters);
  }

  /// Enable type profile.
  Future startTypeProfile() async {
    await _client.send('Profiler.startTypeProfile');
  }

  /// Return: Recorded profile.
  Future<Profile> stop() async {
    Map result = await _client.send('Profiler.stop');
    return new Profile.fromJson(result['profile']);
  }

  /// Disable precise code coverage. Disabling releases unnecessary execution count records and allows
  /// executing optimized code.
  Future stopPreciseCoverage() async {
    await _client.send('Profiler.stopPreciseCoverage');
  }

  /// Disable type profile. Disabling releases type profile data collected so far.
  Future stopTypeProfile() async {
    await _client.send('Profiler.stopTypeProfile');
  }

  /// Collect coverage data for the current isolate, and resets execution counters. Precise code
  /// coverage needs to have started.
  /// Return: Coverage data for the current isolate.
  Future<List<ScriptCoverage>> takePreciseCoverage() async {
    Map result = await _client.send('Profiler.takePreciseCoverage');
    return (result['result'] as List)
        .map((e) => new ScriptCoverage.fromJson(e))
        .toList();
  }

  /// Collect type profile.
  /// Return: Type profile for all scripts since startTypeProfile() was turned on.
  Future<List<ScriptTypeProfile>> takeTypeProfile() async {
    Map result = await _client.send('Profiler.takeTypeProfile');
    return (result['result'] as List)
        .map((e) => new ScriptTypeProfile.fromJson(e))
        .toList();
  }
}

class ConsoleProfileFinishedEvent {
  final String id;

  /// Location of console.profileEnd().
  final debugger.Location location;

  final Profile profile;

  /// Profile title passed as an argument to console.profile().
  final String title;

  ConsoleProfileFinishedEvent({
    @required this.id,
    @required this.location,
    @required this.profile,
    this.title,
  });

  factory ConsoleProfileFinishedEvent.fromJson(Map json) {
    return new ConsoleProfileFinishedEvent(
      id: json['id'],
      location: new debugger.Location.fromJson(json['location']),
      profile: new Profile.fromJson(json['profile']),
      title: json.containsKey('title') ? json['title'] : null,
    );
  }
}

class ConsoleProfileStartedEvent {
  final String id;

  /// Location of console.profile().
  final debugger.Location location;

  /// Profile title passed as an argument to console.profile().
  final String title;

  ConsoleProfileStartedEvent({
    @required this.id,
    @required this.location,
    this.title,
  });

  factory ConsoleProfileStartedEvent.fromJson(Map json) {
    return new ConsoleProfileStartedEvent(
      id: json['id'],
      location: new debugger.Location.fromJson(json['location']),
      title: json.containsKey('title') ? json['title'] : null,
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
  final int hitCount;

  /// Child node ids.
  final List<int> children;

  /// The reason of being not optimized. The function may be deoptimized or marked as don't
  /// optimize.
  final String deoptReason;

  /// An array of source position ticks.
  final List<PositionTickInfo> positionTicks;

  ProfileNode({
    @required this.id,
    @required this.callFrame,
    this.hitCount,
    this.children,
    this.deoptReason,
    this.positionTicks,
  });

  factory ProfileNode.fromJson(Map json) {
    return new ProfileNode(
      id: json['id'],
      callFrame: new runtime.CallFrame.fromJson(json['callFrame']),
      hitCount: json.containsKey('hitCount') ? json['hitCount'] : null,
      children: json.containsKey('children')
          ? (json['children'] as List).map((e) => e as int).toList()
          : null,
      deoptReason: json.containsKey('deoptReason') ? json['deoptReason'] : null,
      positionTicks: json.containsKey('positionTicks')
          ? (json['positionTicks'] as List)
              .map((e) => new PositionTickInfo.fromJson(e))
              .toList()
          : null,
    );
  }

  Map toJson() {
    Map json = {
      'id': id,
      'callFrame': callFrame.toJson(),
    };
    if (hitCount != null) {
      json['hitCount'] = hitCount;
    }
    if (children != null) {
      json['children'] = children.map((e) => e).toList();
    }
    if (deoptReason != null) {
      json['deoptReason'] = deoptReason;
    }
    if (positionTicks != null) {
      json['positionTicks'] = positionTicks.map((e) => e.toJson()).toList();
    }
    return json;
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
  final List<int> samples;

  /// Time intervals between adjacent samples in microseconds. The first delta is relative to the
  /// profile startTime.
  final List<int> timeDeltas;

  Profile({
    @required this.nodes,
    @required this.startTime,
    @required this.endTime,
    this.samples,
    this.timeDeltas,
  });

  factory Profile.fromJson(Map json) {
    return new Profile(
      nodes: (json['nodes'] as List)
          .map((e) => new ProfileNode.fromJson(e))
          .toList(),
      startTime: json['startTime'],
      endTime: json['endTime'],
      samples: json.containsKey('samples')
          ? (json['samples'] as List).map((e) => e as int).toList()
          : null,
      timeDeltas: json.containsKey('timeDeltas')
          ? (json['timeDeltas'] as List).map((e) => e as int).toList()
          : null,
    );
  }

  Map toJson() {
    Map json = {
      'nodes': nodes.map((e) => e.toJson()).toList(),
      'startTime': startTime,
      'endTime': endTime,
    };
    if (samples != null) {
      json['samples'] = samples.map((e) => e).toList();
    }
    if (timeDeltas != null) {
      json['timeDeltas'] = timeDeltas.map((e) => e).toList();
    }
    return json;
  }
}

/// Specifies a number of samples attributed to a certain source position.
class PositionTickInfo {
  /// Source line number (1-based).
  final int line;

  /// Number of samples attributed to the source line.
  final int ticks;

  PositionTickInfo({
    @required this.line,
    @required this.ticks,
  });

  factory PositionTickInfo.fromJson(Map json) {
    return new PositionTickInfo(
      line: json['line'],
      ticks: json['ticks'],
    );
  }

  Map toJson() {
    Map json = {
      'line': line,
      'ticks': ticks,
    };
    return json;
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

  CoverageRange({
    @required this.startOffset,
    @required this.endOffset,
    @required this.count,
  });

  factory CoverageRange.fromJson(Map json) {
    return new CoverageRange(
      startOffset: json['startOffset'],
      endOffset: json['endOffset'],
      count: json['count'],
    );
  }

  Map toJson() {
    Map json = {
      'startOffset': startOffset,
      'endOffset': endOffset,
      'count': count,
    };
    return json;
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

  FunctionCoverage({
    @required this.functionName,
    @required this.ranges,
    @required this.isBlockCoverage,
  });

  factory FunctionCoverage.fromJson(Map json) {
    return new FunctionCoverage(
      functionName: json['functionName'],
      ranges: (json['ranges'] as List)
          .map((e) => new CoverageRange.fromJson(e))
          .toList(),
      isBlockCoverage: json['isBlockCoverage'],
    );
  }

  Map toJson() {
    Map json = {
      'functionName': functionName,
      'ranges': ranges.map((e) => e.toJson()).toList(),
      'isBlockCoverage': isBlockCoverage,
    };
    return json;
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

  ScriptCoverage({
    @required this.scriptId,
    @required this.url,
    @required this.functions,
  });

  factory ScriptCoverage.fromJson(Map json) {
    return new ScriptCoverage(
      scriptId: new runtime.ScriptId.fromJson(json['scriptId']),
      url: json['url'],
      functions: (json['functions'] as List)
          .map((e) => new FunctionCoverage.fromJson(e))
          .toList(),
    );
  }

  Map toJson() {
    Map json = {
      'scriptId': scriptId.toJson(),
      'url': url,
      'functions': functions.map((e) => e.toJson()).toList(),
    };
    return json;
  }
}

/// Describes a type collected during runtime.
class TypeObject {
  /// Name of a type collected with type profiling.
  final String name;

  TypeObject({
    @required this.name,
  });

  factory TypeObject.fromJson(Map json) {
    return new TypeObject(
      name: json['name'],
    );
  }

  Map toJson() {
    Map json = {
      'name': name,
    };
    return json;
  }
}

/// Source offset and types for a parameter or return value.
class TypeProfileEntry {
  /// Source offset of the parameter or end of function for return values.
  final int offset;

  /// The types for this parameter or return value.
  final List<TypeObject> types;

  TypeProfileEntry({
    @required this.offset,
    @required this.types,
  });

  factory TypeProfileEntry.fromJson(Map json) {
    return new TypeProfileEntry(
      offset: json['offset'],
      types: (json['types'] as List)
          .map((e) => new TypeObject.fromJson(e))
          .toList(),
    );
  }

  Map toJson() {
    Map json = {
      'offset': offset,
      'types': types.map((e) => e.toJson()).toList(),
    };
    return json;
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

  ScriptTypeProfile({
    @required this.scriptId,
    @required this.url,
    @required this.entries,
  });

  factory ScriptTypeProfile.fromJson(Map json) {
    return new ScriptTypeProfile(
      scriptId: new runtime.ScriptId.fromJson(json['scriptId']),
      url: json['url'],
      entries: (json['entries'] as List)
          .map((e) => new TypeProfileEntry.fromJson(e))
          .toList(),
    );
  }

  Map toJson() {
    Map json = {
      'scriptId': scriptId.toJson(),
      'url': url,
      'entries': entries.map((e) => e.toJson()).toList(),
    };
    return json;
  }
}
