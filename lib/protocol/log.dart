import 'dart:async';
import '../src/connection.dart';
import 'network.dart' as network;
import 'runtime.dart' as runtime;

/// Provides access to log entries.
class LogApi {
  final Client _client;

  LogApi(this._client);

  /// Issued when new message was logged.
  Stream<LogEntry> get onEntryAdded => _client.onEvent
      .where((event) => event.name == 'Log.entryAdded')
      .map((event) =>
          LogEntry.fromJson(event.parameters['entry'] as Map<String, dynamic>));

  /// Clears the log.
  Future<void> clear() async {
    await _client.send('Log.clear');
  }

  /// Disables log domain, prevents further log entries from being reported to the client.
  Future<void> disable() async {
    await _client.send('Log.disable');
  }

  /// Enables log domain, sends the entries collected so far to the client by means of the
  /// `entryAdded` notification.
  Future<void> enable() async {
    await _client.send('Log.enable');
  }

  /// start violation reporting.
  /// [config] Configuration for violations.
  Future<void> startViolationsReport(List<ViolationSetting> config) async {
    await _client.send('Log.startViolationsReport', {
      'config': [...config],
    });
  }

  /// Stop violation reporting.
  Future<void> stopViolationsReport() async {
    await _client.send('Log.stopViolationsReport');
  }
}

/// Log entry.
class LogEntry {
  /// Log entry source.
  final LogEntrySource source;

  /// Log entry severity.
  final LogEntryLevel level;

  /// Logged text.
  final String text;

  final LogEntryCategory? category;

  /// Timestamp when this entry was added.
  final runtime.Timestamp timestamp;

  /// URL of the resource if known.
  final String? url;

  /// Line number in the resource.
  final int? lineNumber;

  /// JavaScript stack trace.
  final runtime.StackTraceData? stackTrace;

  /// Identifier of the network request associated with this entry.
  final network.RequestId? networkRequestId;

  /// Identifier of the worker associated with this entry.
  final String? workerId;

  /// Call arguments.
  final List<runtime.RemoteObject>? args;

  LogEntry(
      {required this.source,
      required this.level,
      required this.text,
      this.category,
      required this.timestamp,
      this.url,
      this.lineNumber,
      this.stackTrace,
      this.networkRequestId,
      this.workerId,
      this.args});

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      source: LogEntrySource.fromJson(json['source'] as String),
      level: LogEntryLevel.fromJson(json['level'] as String),
      text: json['text'] as String,
      category: json.containsKey('category')
          ? LogEntryCategory.fromJson(json['category'] as String)
          : null,
      timestamp: runtime.Timestamp.fromJson(json['timestamp'] as num),
      url: json.containsKey('url') ? json['url'] as String : null,
      lineNumber:
          json.containsKey('lineNumber') ? json['lineNumber'] as int : null,
      stackTrace: json.containsKey('stackTrace')
          ? runtime.StackTraceData.fromJson(
              json['stackTrace'] as Map<String, dynamic>)
          : null,
      networkRequestId: json.containsKey('networkRequestId')
          ? network.RequestId.fromJson(json['networkRequestId'] as String)
          : null,
      workerId:
          json.containsKey('workerId') ? json['workerId'] as String : null,
      args: json.containsKey('args')
          ? (json['args'] as List)
              .map((e) =>
                  runtime.RemoteObject.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'level': level,
      'text': text,
      'timestamp': timestamp.toJson(),
      if (category != null) 'category': category,
      if (url != null) 'url': url,
      if (lineNumber != null) 'lineNumber': lineNumber,
      if (stackTrace != null) 'stackTrace': stackTrace!.toJson(),
      if (networkRequestId != null)
        'networkRequestId': networkRequestId!.toJson(),
      if (workerId != null) 'workerId': workerId,
      if (args != null) 'args': args!.map((e) => e.toJson()).toList(),
    };
  }
}

class LogEntrySource {
  static const xml = LogEntrySource._('xml');
  static const javascript = LogEntrySource._('javascript');
  static const network = LogEntrySource._('network');
  static const storage = LogEntrySource._('storage');
  static const appcache = LogEntrySource._('appcache');
  static const rendering = LogEntrySource._('rendering');
  static const security = LogEntrySource._('security');
  static const deprecation = LogEntrySource._('deprecation');
  static const worker = LogEntrySource._('worker');
  static const violation = LogEntrySource._('violation');
  static const intervention = LogEntrySource._('intervention');
  static const recommendation = LogEntrySource._('recommendation');
  static const other = LogEntrySource._('other');
  static const values = {
    'xml': xml,
    'javascript': javascript,
    'network': network,
    'storage': storage,
    'appcache': appcache,
    'rendering': rendering,
    'security': security,
    'deprecation': deprecation,
    'worker': worker,
    'violation': violation,
    'intervention': intervention,
    'recommendation': recommendation,
    'other': other,
  };

  final String value;

  const LogEntrySource._(this.value);

  factory LogEntrySource.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is LogEntrySource && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class LogEntryLevel {
  static const verbose = LogEntryLevel._('verbose');
  static const info = LogEntryLevel._('info');
  static const warning = LogEntryLevel._('warning');
  static const error = LogEntryLevel._('error');
  static const values = {
    'verbose': verbose,
    'info': info,
    'warning': warning,
    'error': error,
  };

  final String value;

  const LogEntryLevel._(this.value);

  factory LogEntryLevel.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is LogEntryLevel && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class LogEntryCategory {
  static const cors = LogEntryCategory._('cors');
  static const values = {
    'cors': cors,
  };

  final String value;

  const LogEntryCategory._(this.value);

  factory LogEntryCategory.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is LogEntryCategory && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Violation configuration setting.
class ViolationSetting {
  /// Violation type.
  final ViolationSettingName name;

  /// Time threshold to trigger upon.
  final num threshold;

  ViolationSetting({required this.name, required this.threshold});

  factory ViolationSetting.fromJson(Map<String, dynamic> json) {
    return ViolationSetting(
      name: ViolationSettingName.fromJson(json['name'] as String),
      threshold: json['threshold'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'threshold': threshold,
    };
  }
}

class ViolationSettingName {
  static const longTask = ViolationSettingName._('longTask');
  static const longLayout = ViolationSettingName._('longLayout');
  static const blockedEvent = ViolationSettingName._('blockedEvent');
  static const blockedParser = ViolationSettingName._('blockedParser');
  static const discouragedApiUse = ViolationSettingName._('discouragedAPIUse');
  static const handler = ViolationSettingName._('handler');
  static const recurringHandler = ViolationSettingName._('recurringHandler');
  static const values = {
    'longTask': longTask,
    'longLayout': longLayout,
    'blockedEvent': blockedEvent,
    'blockedParser': blockedParser,
    'discouragedAPIUse': discouragedApiUse,
    'handler': handler,
    'recurringHandler': recurringHandler,
  };

  final String value;

  const ViolationSettingName._(this.value);

  factory ViolationSettingName.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ViolationSettingName && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
