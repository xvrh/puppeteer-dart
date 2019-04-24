import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'network.dart' as network;
import 'runtime.dart' as runtime;

/// Provides access to log entries.
class LogApi {
  final Client _client;

  LogApi(this._client);

  /// Issued when new message was logged.
  Stream<LogEntry> get onEntryAdded => _client.onEvent
      .where((Event event) => event.name == 'Log.entryAdded')
      .map((Event event) => LogEntry.fromJson(event.parameters['entry']));

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
    var parameters = <String, dynamic>{
      'config': config.map((e) => e.toJson()).toList(),
    };
    await _client.send('Log.startViolationsReport', parameters);
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

  /// Timestamp when this entry was added.
  final runtime.Timestamp timestamp;

  /// URL of the resource if known.
  final String url;

  /// Line number in the resource.
  final int lineNumber;

  /// JavaScript stack trace.
  final runtime.StackTrace stackTrace;

  /// Identifier of the network request associated with this entry.
  final network.RequestId networkRequestId;

  /// Identifier of the worker associated with this entry.
  final String workerId;

  /// Call arguments.
  final List<runtime.RemoteObject> args;

  LogEntry(
      {@required this.source,
      @required this.level,
      @required this.text,
      @required this.timestamp,
      this.url,
      this.lineNumber,
      this.stackTrace,
      this.networkRequestId,
      this.workerId,
      this.args});

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      source: LogEntrySource.fromJson(json['source']),
      level: LogEntryLevel.fromJson(json['level']),
      text: json['text'],
      timestamp: runtime.Timestamp.fromJson(json['timestamp']),
      url: json.containsKey('url') ? json['url'] : null,
      lineNumber: json.containsKey('lineNumber') ? json['lineNumber'] : null,
      stackTrace: json.containsKey('stackTrace')
          ? runtime.StackTrace.fromJson(json['stackTrace'])
          : null,
      networkRequestId: json.containsKey('networkRequestId')
          ? network.RequestId.fromJson(json['networkRequestId'])
          : null,
      workerId: json.containsKey('workerId') ? json['workerId'] : null,
      args: json.containsKey('args')
          ? (json['args'] as List)
              .map((e) => runtime.RemoteObject.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'source': source,
      'level': level,
      'text': text,
      'timestamp': timestamp.toJson(),
    };
    if (url != null) {
      json['url'] = url;
    }
    if (lineNumber != null) {
      json['lineNumber'] = lineNumber;
    }
    if (stackTrace != null) {
      json['stackTrace'] = stackTrace.toJson();
    }
    if (networkRequestId != null) {
      json['networkRequestId'] = networkRequestId.toJson();
    }
    if (workerId != null) {
      json['workerId'] = workerId;
    }
    if (args != null) {
      json['args'] = args.map((e) => e.toJson()).toList();
    }
    return json;
  }
}

class LogEntrySource {
  static const LogEntrySource xml = LogEntrySource._('xml');
  static const LogEntrySource javascript = LogEntrySource._('javascript');
  static const LogEntrySource network = LogEntrySource._('network');
  static const LogEntrySource storage = LogEntrySource._('storage');
  static const LogEntrySource appcache = LogEntrySource._('appcache');
  static const LogEntrySource rendering = LogEntrySource._('rendering');
  static const LogEntrySource security = LogEntrySource._('security');
  static const LogEntrySource deprecation = LogEntrySource._('deprecation');
  static const LogEntrySource worker = LogEntrySource._('worker');
  static const LogEntrySource violation = LogEntrySource._('violation');
  static const LogEntrySource intervention = LogEntrySource._('intervention');
  static const LogEntrySource recommendation =
      LogEntrySource._('recommendation');
  static const LogEntrySource other = LogEntrySource._('other');
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

  factory LogEntrySource.fromJson(String value) => values[value];

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
  static const LogEntryLevel verbose = LogEntryLevel._('verbose');
  static const LogEntryLevel info = LogEntryLevel._('info');
  static const LogEntryLevel warning = LogEntryLevel._('warning');
  static const LogEntryLevel error = LogEntryLevel._('error');
  static const values = {
    'verbose': verbose,
    'info': info,
    'warning': warning,
    'error': error,
  };

  final String value;

  const LogEntryLevel._(this.value);

  factory LogEntryLevel.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is LogEntryLevel && other.value == value) || value == other;

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

  ViolationSetting({@required this.name, @required this.threshold});

  factory ViolationSetting.fromJson(Map<String, dynamic> json) {
    return ViolationSetting(
      name: ViolationSettingName.fromJson(json['name']),
      threshold: json['threshold'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'name': name,
      'threshold': threshold,
    };
    return json;
  }
}

class ViolationSettingName {
  static const ViolationSettingName longTask =
      ViolationSettingName._('longTask');
  static const ViolationSettingName longLayout =
      ViolationSettingName._('longLayout');
  static const ViolationSettingName blockedEvent =
      ViolationSettingName._('blockedEvent');
  static const ViolationSettingName blockedParser =
      ViolationSettingName._('blockedParser');
  static const ViolationSettingName discouragedApiUse =
      ViolationSettingName._('discouragedAPIUse');
  static const ViolationSettingName handler = ViolationSettingName._('handler');
  static const ViolationSettingName recurringHandler =
      ViolationSettingName._('recurringHandler');
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

  factory ViolationSettingName.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ViolationSettingName && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
