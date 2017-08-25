import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';

class TracingManager {
  final Session _client;

  TracingManager(this._client);

  /// Start trace events collection.
  /// [categories] Category/tag filter
  /// [options] Tracing options
  /// [bufferUsageReportingInterval] If set, the agent will issue bufferUsage events at this interval, specified in milliseconds
  /// [transferMode] Whether to report trace events as series of dataCollected events or to save trace to a stream (defaults to <code>ReportEvents</code>).
  Future start({
    String categories,
    String options,
    num bufferUsageReportingInterval,
    String transferMode,
    TraceConfig traceConfig,
  }) async {
    Map parameters = {};
    if (categories != null) {
      parameters['categories'] = categories.toString();
    }
    if (options != null) {
      parameters['options'] = options.toString();
    }
    if (bufferUsageReportingInterval != null) {
      parameters['bufferUsageReportingInterval'] =
          bufferUsageReportingInterval.toString();
    }
    if (transferMode != null) {
      parameters['transferMode'] = transferMode.toString();
    }
    if (traceConfig != null) {
      parameters['traceConfig'] = traceConfig.toJson();
    }
    await _client.send('Tracing.start', parameters);
  }

  /// Stop trace events collection.
  Future end() async {
    await _client.send('Tracing.end');
  }

  /// Gets supported tracing categories.
  /// Return: A list of supported tracing categories.
  Future<List<String>> getCategories() async {
    await _client.send('Tracing.getCategories');
  }

  /// Request a global memory dump.
  Future<RequestMemoryDumpResult> requestMemoryDump() async {
    await _client.send('Tracing.requestMemoryDump');
  }

  /// Record a clock sync marker in the trace.
  /// [syncId] The ID of this clock sync marker
  Future recordClockSyncMarker(
    String syncId,
  ) async {
    Map parameters = {
      'syncId': syncId.toString(),
    };
    await _client.send('Tracing.recordClockSyncMarker', parameters);
  }
}

class RequestMemoryDumpResult {
  /// GUID of the resulting global memory dump.
  final String dumpGuid;

  /// True iff the global memory dump succeeded.
  final bool success;

  RequestMemoryDumpResult({
    @required this.dumpGuid,
    @required this.success,
  });
  factory RequestMemoryDumpResult.fromJson(Map json) {}
}

/// Configuration for memory dump. Used only when "memory-infra" category is enabled.
class MemoryDumpConfig {
  final Map value;

  MemoryDumpConfig(this.value);
  factory MemoryDumpConfig.fromJson(Map value) => new MemoryDumpConfig(value);

  Map toJson() => value;
}

class TraceConfig {
  /// Controls how the trace buffer stores data.
  final String recordMode;

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

  TraceConfig({
    this.recordMode,
    this.enableSampling,
    this.enableSystrace,
    this.enableArgumentFilter,
    this.includedCategories,
    this.excludedCategories,
    this.syntheticDelays,
    this.memoryDumpConfig,
  });
  factory TraceConfig.fromJson(Map json) {}

  Map toJson() {
    Map json = {};
    if (recordMode != null) {
      json['recordMode'] = recordMode.toString();
    }
    if (enableSampling != null) {
      json['enableSampling'] = enableSampling.toString();
    }
    if (enableSystrace != null) {
      json['enableSystrace'] = enableSystrace.toString();
    }
    if (enableArgumentFilter != null) {
      json['enableArgumentFilter'] = enableArgumentFilter.toString();
    }
    if (includedCategories != null) {
      json['includedCategories'] =
          includedCategories.map((e) => e.toString()).toList();
    }
    if (excludedCategories != null) {
      json['excludedCategories'] =
          excludedCategories.map((e) => e.toString()).toList();
    }
    if (syntheticDelays != null) {
      json['syntheticDelays'] =
          syntheticDelays.map((e) => e.toString()).toList();
    }
    if (memoryDumpConfig != null) {
      json['memoryDumpConfig'] = memoryDumpConfig.toJson();
    }
    return json;
  }
}
