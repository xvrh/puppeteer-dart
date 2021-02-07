import '../../protocol/performance.dart';

class Metrics {
  final Map<String?, num?> values;

  Metrics(this.values);

  factory Metrics.fromBrowser(List<Metric> metrics) =>
      Metrics({for (var m in metrics) m.name: m.value});

  /// The timestamp when the metrics sample was taken.
  num? get timestamp => values['Timestamp'];

  /// Number of documents in the page.
  int? get documents => values['Documents'] as int?;

  /// Number of frames in the page.
  int? get frames => values['Frames'] as int?;

  /// Number of events in the page.
  int? get jsEventListeners => values['JSEventListeners'] as int?;

  /// Number of DOM nodes in the page.
  int? get nodes => values['Nodes'] as int?;

  /// Total number of full or partial page layout.
  int? get layoutCount => values['LayoutCount'] as int?;

  /// Total number of page style recalculations.
  int? get recalcStyleCount => values['RecalcStyleCount'] as int?;

  /// Combined durations of all page layouts.
  num? get layoutDuration => values['LayoutDuration'];

  /// Combined duration of all page style recalculations.
  num? get recalcStyleDuration => values['RecalcStyleDuration'];

  /// Combined duration of JavaScript execution.
  num? get scriptDuration => values['ScriptDuration'];

  /// Combined duration of all tasks performed by the browser.
  num? get taskDuration => values['TaskDuration'];

  /// Used JavaScript heap size.
  int? get jsHeapUsedSize => values['JSHeapUsedSize'] as int?;

  /// Total JavaScript heap size.
  int? get jsHeapTotalSize => values['JSHeapTotalSize'] as int?;

  @override
  String toString() => values.toString();
}

class MetricsEvent {
  final String? title;
  final Metrics metrics;

  MetricsEvent(this.title, this.metrics);
}
