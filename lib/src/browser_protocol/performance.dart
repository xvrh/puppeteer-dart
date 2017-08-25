import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';

class PerformanceManager {
  final Session _client;

  PerformanceManager(this._client);

  /// Enable collecting and reporting metrics.
  Future enable() async {
    await _client.send('Performance.enable');
  }

  /// Disable collecting and reporting metrics.
  Future disable() async {
    await _client.send('Performance.disable');
  }

  /// Retrieve current values of run-time metrics.
  /// Return: Current values for run-time metrics.
  Future<List<Metric>> getMetrics() async {
    await _client.send('Performance.getMetrics');
  }
}

/// Run-time execution metric.
class Metric {
  /// Metric name.
  final String name;

  /// Metric value.
  final num value;

  Metric({
    @required this.name,
    @required this.value,
  });
  factory Metric.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'name': name.toString(),
      'value': value.toString(),
    };
    return json;
  }
}
