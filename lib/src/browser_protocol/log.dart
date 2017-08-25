/// Provides access to log entries.

import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';
import '../runtime.dart' as runtime;
import 'network.dart' as network;

class LogManager {
  final Session _client;

  LogManager(this._client);

  /// Enables log domain, sends the entries collected so far to the client by means of the <code>entryAdded</code> notification.
  Future enable() async {
    await _client.send('Log.enable');
  }

  /// Disables log domain, prevents further log entries from being reported to the client.
  Future disable() async {
    await _client.send('Log.disable');
  }

  /// Clears the log.
  Future clear() async {
    await _client.send('Log.clear');
  }

  /// start violation reporting.
  /// [config] Configuration for violations.
  Future startViolationsReport(
    List<ViolationSetting> config,
  ) async {
    Map parameters = {
      'config': config.map((e) => e.toJson()).toList(),
    };
    await _client.send('Log.startViolationsReport', parameters);
  }

  /// Stop violation reporting.
  Future stopViolationsReport() async {
    await _client.send('Log.stopViolationsReport');
  }
}

/// Log entry.
class LogEntry {
  /// Log entry source.
  final String source;

  /// Log entry severity.
  final String level;

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

  LogEntry({
    @required this.source,
    @required this.level,
    @required this.text,
    @required this.timestamp,
    this.url,
    this.lineNumber,
    this.stackTrace,
    this.networkRequestId,
    this.workerId,
  });

  Map toJson() {
    Map json = {
      'source': source.toString(),
      'level': level.toString(),
      'text': text.toString(),
      'timestamp': timestamp.toJson(),
    };
    if (url != null) {
      json['url'] = url.toString();
    }
    if (lineNumber != null) {
      json['lineNumber'] = lineNumber.toString();
    }
    if (stackTrace != null) {
      json['stackTrace'] = stackTrace.toJson();
    }
    if (networkRequestId != null) {
      json['networkRequestId'] = networkRequestId.toJson();
    }
    if (workerId != null) {
      json['workerId'] = workerId.toString();
    }
    return json;
  }
}

/// Violation configuration setting.
class ViolationSetting {
  /// Violation type.
  final String name;

  /// Time threshold to trigger upon.
  final num threshold;

  ViolationSetting({
    @required this.name,
    @required this.threshold,
  });

  Map toJson() {
    Map json = {
      'name': name.toString(),
      'threshold': threshold.toString(),
    };
    return json;
  }
}
