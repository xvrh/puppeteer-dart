import 'dart:async';
import '../src/connection.dart';
import 'dom.dart' as dom;
import 'network.dart' as network;
import 'page.dart' as page;

/// Reporting of performance timeline events, as specified in
/// https://w3c.github.io/performance-timeline/#dom-performanceobserver.
class PerformanceTimelineApi {
  final Client _client;

  PerformanceTimelineApi(this._client);

  /// Sent when a performance timeline event is added. See reportPerformanceTimeline method.
  Stream<TimelineEvent> get onTimelineEventAdded => _client.onEvent
      .where((event) => event.name == 'PerformanceTimeline.timelineEventAdded')
      .map((event) => TimelineEvent.fromJson(
          event.parameters['event'] as Map<String, dynamic>));

  /// Previously buffered events would be reported before method returns.
  /// See also: timelineEventAdded
  /// [eventTypes] The types of event to report, as specified in
  /// https://w3c.github.io/performance-timeline/#dom-performanceentry-entrytype
  /// The specified filter overrides any previous filters, passing empty
  /// filter disables recording.
  /// Note that not all types exposed to the web platform are currently supported.
  Future<void> enable(List<String> eventTypes) async {
    await _client.send('PerformanceTimeline.enable', {
      'eventTypes': [...eventTypes],
    });
  }
}

/// See https://github.com/WICG/LargestContentfulPaint and largest_contentful_paint.idl
class LargestContentfulPaint {
  final network.TimeSinceEpoch renderTime;

  final network.TimeSinceEpoch loadTime;

  /// The number of pixels being painted.
  final num size;

  /// The id attribute of the element, if available.
  final String? elementId;

  /// The URL of the image (may be trimmed).
  final String? url;

  final dom.BackendNodeId? nodeId;

  LargestContentfulPaint(
      {required this.renderTime,
      required this.loadTime,
      required this.size,
      this.elementId,
      this.url,
      this.nodeId});

  factory LargestContentfulPaint.fromJson(Map<String, dynamic> json) {
    return LargestContentfulPaint(
      renderTime: network.TimeSinceEpoch.fromJson(json['renderTime'] as num),
      loadTime: network.TimeSinceEpoch.fromJson(json['loadTime'] as num),
      size: json['size'] as num,
      elementId:
          json.containsKey('elementId') ? json['elementId'] as String : null,
      url: json.containsKey('url') ? json['url'] as String : null,
      nodeId: json.containsKey('nodeId')
          ? dom.BackendNodeId.fromJson(json['nodeId'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'renderTime': renderTime.toJson(),
      'loadTime': loadTime.toJson(),
      'size': size,
      if (elementId != null) 'elementId': elementId,
      if (url != null) 'url': url,
      if (nodeId != null) 'nodeId': nodeId!.toJson(),
    };
  }
}

class LayoutShiftAttribution {
  final dom.Rect previousRect;

  final dom.Rect currentRect;

  final dom.BackendNodeId? nodeId;

  LayoutShiftAttribution(
      {required this.previousRect, required this.currentRect, this.nodeId});

  factory LayoutShiftAttribution.fromJson(Map<String, dynamic> json) {
    return LayoutShiftAttribution(
      previousRect:
          dom.Rect.fromJson(json['previousRect'] as Map<String, dynamic>),
      currentRect:
          dom.Rect.fromJson(json['currentRect'] as Map<String, dynamic>),
      nodeId: json.containsKey('nodeId')
          ? dom.BackendNodeId.fromJson(json['nodeId'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'previousRect': previousRect.toJson(),
      'currentRect': currentRect.toJson(),
      if (nodeId != null) 'nodeId': nodeId!.toJson(),
    };
  }
}

/// See https://wicg.github.io/layout-instability/#sec-layout-shift and layout_shift.idl
class LayoutShift {
  /// Score increment produced by this event.
  final num value;

  final bool hadRecentInput;

  final network.TimeSinceEpoch lastInputTime;

  final List<LayoutShiftAttribution> sources;

  LayoutShift(
      {required this.value,
      required this.hadRecentInput,
      required this.lastInputTime,
      required this.sources});

  factory LayoutShift.fromJson(Map<String, dynamic> json) {
    return LayoutShift(
      value: json['value'] as num,
      hadRecentInput: json['hadRecentInput'] as bool? ?? false,
      lastInputTime:
          network.TimeSinceEpoch.fromJson(json['lastInputTime'] as num),
      sources: (json['sources'] as List)
          .map(
              (e) => LayoutShiftAttribution.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'hadRecentInput': hadRecentInput,
      'lastInputTime': lastInputTime.toJson(),
      'sources': sources.map((e) => e.toJson()).toList(),
    };
  }
}

class TimelineEvent {
  /// Identifies the frame that this event is related to. Empty for non-frame targets.
  final page.FrameId frameId;

  /// The event type, as specified in https://w3c.github.io/performance-timeline/#dom-performanceentry-entrytype
  /// This determines which of the optional "details" fiedls is present.
  final String type;

  /// Name may be empty depending on the type.
  final String name;

  /// Time in seconds since Epoch, monotonically increasing within document lifetime.
  final network.TimeSinceEpoch time;

  /// Event duration, if applicable.
  final num? duration;

  final LargestContentfulPaint? lcpDetails;

  final LayoutShift? layoutShiftDetails;

  TimelineEvent(
      {required this.frameId,
      required this.type,
      required this.name,
      required this.time,
      this.duration,
      this.lcpDetails,
      this.layoutShiftDetails});

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      frameId: page.FrameId.fromJson(json['frameId'] as String),
      type: json['type'] as String,
      name: json['name'] as String,
      time: network.TimeSinceEpoch.fromJson(json['time'] as num),
      duration: json.containsKey('duration') ? json['duration'] as num : null,
      lcpDetails: json.containsKey('lcpDetails')
          ? LargestContentfulPaint.fromJson(
              json['lcpDetails'] as Map<String, dynamic>)
          : null,
      layoutShiftDetails: json.containsKey('layoutShiftDetails')
          ? LayoutShift.fromJson(
              json['layoutShiftDetails'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frameId': frameId.toJson(),
      'type': type,
      'name': name,
      'time': time.toJson(),
      if (duration != null) 'duration': duration,
      if (lcpDetails != null) 'lcpDetails': lcpDetails!.toJson(),
      if (layoutShiftDetails != null)
        'layoutShiftDetails': layoutShiftDetails!.toJson(),
    };
  }
}
