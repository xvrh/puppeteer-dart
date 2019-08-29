import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';

class PerformanceApi {
  final Client _client;

  PerformanceApi(this._client);

  /// Current values of the metrics.
  Stream<MetricsEvent> get onMetrics => _client.onEvent
      .where((event) => event.name == 'Performance.metrics')
      .map((event) => MetricsEvent.fromJson(event.parameters));

  /// Disable collecting and reporting metrics.
  Future<void> disable() async {
    await _client.send('Performance.disable');
  }

  /// Enable collecting and reporting metrics.
  Future<void> enable() async {
    await _client.send('Performance.enable');
  }

  /// Sets time domain to use for collecting and reporting duration metrics.
  /// Note that this must be called before enabling metrics collection. Calling
  /// this method while metrics collection is enabled returns an error.
  /// [timeDomain] Time domain
  Future<void> setTimeDomain(
      @Enum(['timeTicks', 'threadTicks']) String timeDomain) async {
    assert(const ['timeTicks', 'threadTicks'].contains(timeDomain));
    await _client.send('Performance.setTimeDomain', {
      'timeDomain': timeDomain,
    });
  }

  /// Retrieve current values of run-time metrics.
  /// Returns: Current values for run-time metrics.
  Future<List<Metric>> getMetrics() async {
    var result = await _client.send('Performance.getMetrics');
    return (result['metrics'] as List).map((e) => Metric.fromJson(e)).toList();
  }
}

class MetricsEvent {
  /// Current values of the metrics.
  final List<Metric> metrics;

  /// Timestamp title.
  final String title;

  MetricsEvent({@required this.metrics, @required this.title});

  factory MetricsEvent.fromJson(Map<String, dynamic> json) {
    return MetricsEvent(
      metrics:
          (json['metrics'] as List).map((e) => Metric.fromJson(e)).toList(),
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

  Metric({@required this.name, @required this.value});

  factory Metric.fromJson(Map<String, dynamic> json) {
    return Metric(
      name: json['name'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}
