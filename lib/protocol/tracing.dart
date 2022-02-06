import 'dart:async';
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
  Stream<List<Map<String, dynamic>>> get onDataCollected => _client.onEvent
      .where((event) => event.name == 'Tracing.dataCollected')
      .map((event) => (event.parameters['value'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList());

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
    await _client.send('Tracing.recordClockSyncMarker', {
      'syncId': syncId,
    });
  }

  /// Request a global memory dump.
  /// [deterministic] Enables more deterministic results by forcing garbage collection
  /// [levelOfDetail] Specifies level of details in memory dump. Defaults to "detailed".
  Future<RequestMemoryDumpResult> requestMemoryDump(
      {bool? deterministic, MemoryDumpLevelOfDetail? levelOfDetail}) async {
    var result = await _client.send('Tracing.requestMemoryDump', {
      if (deterministic != null) 'deterministic': deterministic,
      if (levelOfDetail != null) 'levelOfDetail': levelOfDetail,
    });
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
  /// [perfettoConfig] Base64-encoded serialized perfetto.protos.TraceConfig protobuf message
  /// When specified, the parameters `categories`, `options`, `traceConfig`
  /// are ignored.
  /// [tracingBackend] Backend type (defaults to `auto`)
  Future<void> start(
      {@Deprecated('This parameter is deprecated') String? categories,
      @Deprecated('This parameter is deprecated') String? options,
      num? bufferUsageReportingInterval,
      @Enum(['ReportEvents', 'ReturnAsStream']) String? transferMode,
      StreamFormat? streamFormat,
      StreamCompression? streamCompression,
      TraceConfig? traceConfig,
      String? perfettoConfig,
      TracingBackend? tracingBackend}) async {
    assert(transferMode == null ||
        const ['ReportEvents', 'ReturnAsStream'].contains(transferMode));
    await _client.send('Tracing.start', {
      if (categories != null) 'categories': categories,
      if (options != null) 'options': options,
      if (bufferUsageReportingInterval != null)
        'bufferUsageReportingInterval': bufferUsageReportingInterval,
      if (transferMode != null) 'transferMode': transferMode,
      if (streamFormat != null) 'streamFormat': streamFormat,
      if (streamCompression != null) 'streamCompression': streamCompression,
      if (traceConfig != null) 'traceConfig': traceConfig,
      if (perfettoConfig != null) 'perfettoConfig': perfettoConfig,
      if (tracingBackend != null) 'tracingBackend': tracingBackend,
    });
  }
}

class BufferUsageEvent {
  /// A number in range [0..1] that indicates the used size of event buffer as a fraction of its
  /// total size.
  final num? percentFull;

  /// An approximate number of events in the trace log.
  final num? eventCount;

  /// A number in range [0..1] that indicates the used size of event buffer as a fraction of its
  /// total size.
  final num? value;

  BufferUsageEvent({this.percentFull, this.eventCount, this.value});

  factory BufferUsageEvent.fromJson(Map<String, dynamic> json) {
    return BufferUsageEvent(
      percentFull:
          json.containsKey('percentFull') ? json['percentFull'] as num : null,
      eventCount:
          json.containsKey('eventCount') ? json['eventCount'] as num : null,
      value: json.containsKey('value') ? json['value'] as num : null,
    );
  }
}

class TracingCompleteEvent {
  /// Indicates whether some trace data is known to have been lost, e.g. because the trace ring
  /// buffer wrapped around.
  final bool dataLossOccurred;

  /// A handle of the stream that holds resulting trace data.
  final io.StreamHandle? stream;

  /// Trace data format of returned stream.
  final StreamFormat? traceFormat;

  /// Compression format of returned stream.
  final StreamCompression? streamCompression;

  TracingCompleteEvent(
      {required this.dataLossOccurred,
      this.stream,
      this.traceFormat,
      this.streamCompression});

  factory TracingCompleteEvent.fromJson(Map<String, dynamic> json) {
    return TracingCompleteEvent(
      dataLossOccurred: json['dataLossOccurred'] as bool? ?? false,
      stream: json.containsKey('stream')
          ? io.StreamHandle.fromJson(json['stream'] as String)
          : null,
      traceFormat: json.containsKey('traceFormat')
          ? StreamFormat.fromJson(json['traceFormat'] as String)
          : null,
      streamCompression: json.containsKey('streamCompression')
          ? StreamCompression.fromJson(json['streamCompression'] as String)
          : null,
    );
  }
}

class RequestMemoryDumpResult {
  /// GUID of the resulting global memory dump.
  final String dumpGuid;

  /// True iff the global memory dump succeeded.
  final bool success;

  RequestMemoryDumpResult({required this.dumpGuid, required this.success});

  factory RequestMemoryDumpResult.fromJson(Map<String, dynamic> json) {
    return RequestMemoryDumpResult(
      dumpGuid: json['dumpGuid'] as String,
      success: json['success'] as bool? ?? false,
    );
  }
}

/// Configuration for memory dump. Used only when "memory-infra" category is enabled.
class MemoryDumpConfig {
  final Map<String, dynamic> value;

  MemoryDumpConfig(this.value);

  factory MemoryDumpConfig.fromJson(Map<String, dynamic> value) =>
      MemoryDumpConfig(value);

  Map<String, dynamic> toJson() => value;

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
  final TraceConfigRecordMode? recordMode;

  /// Turns on JavaScript stack sampling.
  final bool? enableSampling;

  /// Turns on system tracing.
  final bool? enableSystrace;

  /// Turns on argument filter.
  final bool? enableArgumentFilter;

  /// Included category filters.
  final List<String>? includedCategories;

  /// Excluded category filters.
  final List<String>? excludedCategories;

  /// Configuration to synthesize the delays in tracing.
  final List<String>? syntheticDelays;

  /// Configuration for memory dump triggers. Used only when "memory-infra" category is enabled.
  final MemoryDumpConfig? memoryDumpConfig;

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
          ? TraceConfigRecordMode.fromJson(json['recordMode'] as String)
          : null,
      enableSampling: json.containsKey('enableSampling')
          ? json['enableSampling'] as bool
          : null,
      enableSystrace: json.containsKey('enableSystrace')
          ? json['enableSystrace'] as bool
          : null,
      enableArgumentFilter: json.containsKey('enableArgumentFilter')
          ? json['enableArgumentFilter'] as bool
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
          ? MemoryDumpConfig.fromJson(
              json['memoryDumpConfig'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (recordMode != null) 'recordMode': recordMode,
      if (enableSampling != null) 'enableSampling': enableSampling,
      if (enableSystrace != null) 'enableSystrace': enableSystrace,
      if (enableArgumentFilter != null)
        'enableArgumentFilter': enableArgumentFilter,
      if (includedCategories != null)
        'includedCategories': [...?includedCategories],
      if (excludedCategories != null)
        'excludedCategories': [...?excludedCategories],
      if (syntheticDelays != null) 'syntheticDelays': [...?syntheticDelays],
      if (memoryDumpConfig != null)
        'memoryDumpConfig': memoryDumpConfig!.toJson(),
    };
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

  factory TraceConfigRecordMode.fromJson(String value) => values[value]!;

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

  factory StreamFormat.fromJson(String value) => values[value]!;

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

  factory StreamCompression.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is StreamCompression && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Details exposed when memory request explicitly declared.
/// Keep consistent with memory_dump_request_args.h and
/// memory_instrumentation.mojom
class MemoryDumpLevelOfDetail {
  static const background = MemoryDumpLevelOfDetail._('background');
  static const light = MemoryDumpLevelOfDetail._('light');
  static const detailed = MemoryDumpLevelOfDetail._('detailed');
  static const values = {
    'background': background,
    'light': light,
    'detailed': detailed,
  };

  final String value;

  const MemoryDumpLevelOfDetail._(this.value);

  factory MemoryDumpLevelOfDetail.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is MemoryDumpLevelOfDetail && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Backend type to use for tracing. `chrome` uses the Chrome-integrated
/// tracing service and is supported on all platforms. `system` is only
/// supported on Chrome OS and uses the Perfetto system tracing service.
/// `auto` chooses `system` when the perfettoConfig provided to Tracing.start
/// specifies at least one non-Chrome data source; otherwise uses `chrome`.
class TracingBackend {
  static const auto = TracingBackend._('auto');
  static const chrome = TracingBackend._('chrome');
  static const system = TracingBackend._('system');
  static const values = {
    'auto': auto,
    'chrome': chrome,
    'system': system,
  };

  final String value;

  const TracingBackend._(this.value);

  factory TracingBackend.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is TracingBackend && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
