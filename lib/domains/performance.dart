import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';

class PerformanceManager {
  final Client _client;

  PerformanceManager(this._client);

  /// Current values of the metrics.
  Stream<MetricsEvent> get onMetrics => _client.onEvent
      .where((Event event) => event.name == 'Performance.metrics')
      .map((Event event) => new MetricsEvent.fromJson(event.parameters));

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
    Map result = await _client.send('Performance.getMetrics');
    return (result['metrics'] as List)
        .map((e) => new Metric.fromJson(e))
        .toList();
  }
}

class MetricsEvent {
  /// Current values of the metrics.
  final List<Metric> metrics;

  /// Timestamp title.
  final String title;

  MetricsEvent({
    @required this.metrics,
    @required this.title,
  });

  factory MetricsEvent.fromJson(Map json) {
    return new MetricsEvent(
      metrics:
          (json['metrics'] as List).map((e) => new Metric.fromJson(e)).toList(),
      title: json['title'],
    );
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

  factory Metric.fromJson(Map json) {
    return new Metric(
      name: json['name'],
      value: json['value'],
    );
  }

  Map toJson() {
    Map json = {
      'name': name,
      'value': value,
    };
    return json;
  }
}
