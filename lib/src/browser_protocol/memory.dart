import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';

class MemoryManager {
  final Session _client;

  MemoryManager(this._client);

  Future<GetDOMCountersResult> getDOMCounters() async {
    await _client.send('Memory.getDOMCounters');
  }

  /// Enable/disable suppressing memory pressure notifications in all processes.
  /// [suppressed] If true, memory pressure notifications will be suppressed.
  Future setPressureNotificationsSuppressed(
    bool suppressed,
  ) async {
    Map parameters = {
      'suppressed': suppressed,
    };
    await _client.send('Memory.setPressureNotificationsSuppressed', parameters);
  }

  /// Simulate a memory pressure notification in all processes.
  /// [level] Memory pressure level of the notification.
  Future simulatePressureNotification(
    PressureLevel level,
  ) async {
    Map parameters = {
      'level': level.toJson(),
    };
    await _client.send('Memory.simulatePressureNotification', parameters);
  }
}

class GetDOMCountersResult {
  final int documents;

  final int nodes;

  final int jsEventListeners;

  GetDOMCountersResult({
    @required this.documents,
    @required this.nodes,
    @required this.jsEventListeners,
  });

  factory GetDOMCountersResult.fromJson(Map json) {
    return new GetDOMCountersResult(
      documents: json['documents'],
      nodes: json['nodes'],
      jsEventListeners: json['jsEventListeners'],
    );
  }
}

/// Memory pressure level.
class PressureLevel {
  static const PressureLevel moderate = const PressureLevel._('moderate');
  static const PressureLevel critical = const PressureLevel._('critical');
  static const values = const {
    'moderate': moderate,
    'critical': critical,
  };

  final String value;

  const PressureLevel._(this.value);

  factory PressureLevel.fromJson(String value) => values[value];

  String toJson() => value;
}
