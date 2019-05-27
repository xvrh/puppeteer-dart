import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'io.dart' as io;

class TracingApi {
  final Client _client;

  TracingApi(this._client);

  Stream<BufferUsageEvent> get onBufferUsage => _client.onEvent
      .where((event) => event.name == 'Tracing.bufferUsage')
      .map((event) => BufferUsageEvent.fromJson(event.parameters));

  /// Contains an bucket of collected trace events. When tracing is stopped collected events will be
  /// send as a sequence of dataCollected events followed by tracingComplete event.
  Stream<List<Map>> get onDataCollected => _client.onEvent
      .where((event) => event.name == 'Tracing.dataCollected')
      .map((event) =>
          (event.parameters['value'] as List).map((e) => e as Map).toList());

  /// Signals that tracing is stopped and there is no trace buffers pending flush, all data were
  /// delivered via dataCollected events.
  Stream<TracingCompleteEvent> get onTracingComplete => _client.onEvent
      .where((event) => event.name == 'Tracing.tracingComplete')
      .map((event) => TracingCompleteEvent.fromJson(event.parameters));

  /// Stop trace events collection.
  Future<void> end() async {
    await _client.send('Tracing.end');
  }

  /// Gets supported tracing categories.
  /// Returns: A list of supported tracing categories.
  Future<List<String>> getCategories() async {
    var result = await _client.send('Tracing.getCategories');
    return (result['categories'] as List).map((e) => e as String).toList();
  }

  /// Record a clock sync marker in the trace.
  /// [syncId] The ID of this clock sync marker
  Future<void> recordClockSyncMarker(String syncId) async {
    var parameters = <String, dynamic>{
      'syncId': syncId,
    };
    await _client.send('Tracing.recordClockSyncMarker', parameters);
  }

  /// Request a global memory dump.
  Future<RequestMemoryDumpResult> requestMemoryDump() async {
    var result = await _client.send('Tracing.requestMemoryDump');
    return RequestMemoryDumpResult.fromJson(result);
  }

  /// Start trace events collection.
  /// [bufferUsageReportingInterval] If set, the agent will issue bufferUsage events at this interval, specified in milliseconds
  /// [transferMode] Whether to report trace events as series of dataCollected events or to save trace to a
  /// stream (defaults to `ReportEvents`).
  /// [streamFormat] Trace data format to use. This only applies when using `ReturnAsStream`
  /// transfer mode (defaults to `json`).
  /// [streamCompression] Compression format to use. This only applies when using `ReturnAsStream`
  /// transfer mode (defaults to `none`)
  Future<void> start(
      {@deprecated String categories,
      @deprecated String options,
      num bufferUsageReportingInterval,
      @Enum(['ReportEvents', 'ReturnAsStream']) String transferMode,
      StreamFormat streamFormat,
      StreamCompression streamCompression,
      TraceConfig traceConfig}) async {
    assert(transferMode == null ||
        const ['ReportEvents', 'ReturnAsStream'].contains(transferMode));
    var parameters = <String, dynamic>{};
    if (categories != null) {
      parameters['categories'] = categories;
    }
    if (options != null) {
      parameters['options'] = options;
    }
    if (bufferUsageReportingInterval != null) {
      parameters['bufferUsageReportingInterval'] = bufferUsageReportingInterval;
    }
    if (transferMode != null) {
      parameters['transferMode'] = transferMode;
    }
    if (streamFormat != null) {
      parameters['streamFormat'] = streamFormat.toJson();
    }
    if (streamCompression != null) {
      parameters['streamCompression'] = streamCompression.toJson();
    }
    if (traceConfig != null) {
      parameters['traceConfig'] = traceConfig.toJson();
    }
    await _client.send('Tracing.start', parameters);
  }
}

class BufferUsageEvent {
  /// A number in range [0..1] that indicates the used size of event buffer as a fraction of its
  /// total size.
  final num percentFull;

  /// An approximate number of events in the trace log.
  final num eventCount;

  /// A number in range [0..1] that indicates the used size of event buffer as a fraction of its
  /// total size.
  final num value;

  BufferUsageEvent({this.percentFull, this.eventCount, this.value});

  factory BufferUsageEvent.fromJson(Map<String, dynamic> json) {
    return BufferUsageEvent(
      percentFull: json.containsKey('percentFull') ? json['percentFull'] : null,
      eventCount: json.containsKey('eventCount') ? json['eventCount'] : null,
      value: json.containsKey('value') ? json['value'] : null,
    );
  }
}

class TracingCompleteEvent {
  /// A handle of the stream that holds resulting trace data.
  final io.StreamHandle stream;

  /// Trace data format of returned stream.
  final StreamFormat traceFormat;

  /// Compression format of returned stream.
  final StreamCompression streamCompression;

  TracingCompleteEvent({this.stream, this.traceFormat, this.streamCompression});

  factory TracingCompleteEvent.fromJson(Map<String, dynamic> json) {
    return TracingCompleteEvent(
      stream: json.containsKey('stream')
          ? io.StreamHandle.fromJson(json['stream'])
          : null,
      traceFormat: json.containsKey('traceFormat')
          ? StreamFormat.fromJson(json['traceFormat'])
          : null,
      streamCompression: json.containsKey('streamCompression')
          ? StreamCompression.fromJson(json['streamCompression'])
          : null,
    );
  }
}

class RequestMemoryDumpResult {
  /// GUID of the resulting global memory dump.
  final String dumpGuid;

  /// True iff the global memory dump succeeded.
  final bool success;

  RequestMemoryDumpResult({@required this.dumpGuid, @required this.success});

  factory RequestMemoryDumpResult.fromJson(Map<String, dynamic> json) {
    return RequestMemoryDumpResult(
      dumpGuid: json['dumpGuid'],
      success: json['success'],
    );
  }
}

/// Configuration for memory dump. Used only when "memory-infra" category is enabled.
class MemoryDumpConfig {
  final Map value;

  MemoryDumpConfig(this.value);

  factory MemoryDumpConfig.fromJson(Map value) => MemoryDumpConfig(value);

  Map toJson() => value;

  @override
  bool operator ==(other) =>
      (other is MemoryDumpConfig && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class TraceConfig {
  /// Controls how the trace buffer stores data.
  final TraceConfigRecordMode recordMode;

  /// Turns on JavaScript stack sampling.
  final bool enableSampling;

  /// Turns on system tracing.
  final bool enableSystrace;

  /// Turns on argument filter.
  final bool enableArgumentFilter;

  /// Included category filters.
  final List<String> includedCategories;

  /// Excluded category filters.
  final List<String> excludedCategories;

  /// Configuration to synthesize the delays in tracing.
  final List<String> syntheticDelays;

  /// Configuration for memory dump triggers. Used only when "memory-infra" category is enabled.
  final MemoryDumpConfig memoryDumpConfig;

  TraceConfig(
      {this.recordMode,
      this.enableSampling,
      this.enableSystrace,
      this.enableArgumentFilter,
      this.includedCategories,
      this.excludedCategories,
      this.syntheticDelays,
      this.memoryDumpConfig});

  factory TraceConfig.fromJson(Map<String, dynamic> json) {
    return TraceConfig(
      recordMode: json.containsKey('recordMode')
          ? TraceConfigRecordMode.fromJson(json['recordMode'])
          : null,
      enableSampling:
          json.containsKey('enableSampling') ? json['enableSampling'] : null,
      enableSystrace:
          json.containsKey('enableSystrace') ? json['enableSystrace'] : null,
      enableArgumentFilter: json.containsKey('enableArgumentFilter')
          ? json['enableArgumentFilter']
          : null,
      includedCategories: json.containsKey('includedCategories')
          ? (json['includedCategories'] as List)
              .map((e) => e as String)
              .toList()
          : null,
      excludedCategories: json.containsKey('excludedCategories')
          ? (json['excludedCategories'] as List)
              .map((e) => e as String)
              .toList()
          : null,
      syntheticDelays: json.containsKey('syntheticDelays')
          ? (json['syntheticDelays'] as List).map((e) => e as String).toList()
          : null,
      memoryDumpConfig: json.containsKey('memoryDumpConfig')
          ? MemoryDumpConfig.fromJson(json['memoryDumpConfig'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};
    if (recordMode != null) {
      json['recordMode'] = recordMode;
    }
    if (enableSampling != null) {
      json['enableSampling'] = enableSampling;
    }
    if (enableSystrace != null) {
      json['enableSystrace'] = enableSystrace;
    }
    if (enableArgumentFilter != null) {
      json['enableArgumentFilter'] = enableArgumentFilter;
    }
    if (includedCategories != null) {
      json['includedCategories'] = includedCategories.map((e) => e).toList();
    }
    if (excludedCategories != null) {
      json['excludedCategories'] = excludedCategories.map((e) => e).toList();
    }
    if (syntheticDelays != null) {
      json['syntheticDelays'] = syntheticDelays.map((e) => e).toList();
    }
    if (memoryDumpConfig != null) {
      json['memoryDumpConfig'] = memoryDumpConfig.toJson();
    }
    return json;
  }
}

class TraceConfigRecordMode {
  static const recordUntilFull = TraceConfigRecordMode._('recordUntilFull');
  static const recordContinuously =
      TraceConfigRecordMode._('recordContinuously');
  static const recordAsMuchAsPossible =
      TraceConfigRecordMode._('recordAsMuchAsPossible');
  static const echoToConsole = TraceConfigRecordMode._('echoToConsole');
  static const values = {
    'recordUntilFull': recordUntilFull,
    'recordContinuously': recordContinuously,
    'recordAsMuchAsPossible': recordAsMuchAsPossible,
    'echoToConsole': echoToConsole,
  };

  final String value;

  const TraceConfigRecordMode._(this.value);

  factory TraceConfigRecordMode.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is TraceConfigRecordMode && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Data format of a trace. Can be either the legacy JSON format or the
/// protocol buffer format. Note that the JSON format will be deprecated soon.
class StreamFormat {
  static const json = StreamFormat._('json');
  static const proto = StreamFormat._('proto');
  static const values = {
    'json': json,
    'proto': proto,
  };

  final String value;

  const StreamFormat._(this.value);

  factory StreamFormat.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is StreamFormat && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Compression type to use for traces returned via streams.
class StreamCompression {
  static const none = StreamCompression._('none');
  static const gzip = StreamCompression._('gzip');
  static const values = {
    'none': none,
    'gzip': gzip,
  };

  final String value;

  const StreamCompression._(this.value);

  factory StreamCompression.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is StreamCompression && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
