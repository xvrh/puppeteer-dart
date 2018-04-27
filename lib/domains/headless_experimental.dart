/// This domain provides experimental commands only supported in headless mode.

import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'runtime.dart' as runtime;

class HeadlessExperimentalManager {
  final Client _client;

  HeadlessExperimentalManager(this._client);

  /// Issued when the target starts or stops needing BeginFrames.
  Stream<bool> get onNeedsBeginFramesChanged => _client.onEvent
      .where((Event event) =>
          event.name == 'HeadlessExperimental.needsBeginFramesChanged')
      .map((Event event) => event.parameters['needsBeginFrames'] as bool);

  /// Issued when the main frame has first submitted a frame to the browser. May
  /// only be fired while a BeginFrame is in flight. Before this event,
  /// screenshotting requests may fail.
  Stream get onMainFrameReadyForScreenshots =>
      _client.onEvent.where((Event event) =>
          event.name == 'HeadlessExperimental.mainFrameReadyForScreenshots');

  /// Enables headless events for the target.
  Future enable() async {
    await _client.send('HeadlessExperimental.enable');
  }

  /// Disables headless events for the target.
  Future disable() async {
    await _client.send('HeadlessExperimental.disable');
  }

  /// Sends a BeginFrame to the target and returns when the frame was completed.
  /// Optionally captures a screenshot from the resulting frame. Requires that the
  /// target was created with enabled BeginFrameControl.
  /// [frameTime] Timestamp of this BeginFrame (milliseconds since epoch). If not
  /// set, the current time will be used.
  /// [deadline] Deadline of this BeginFrame (milliseconds since epoch). If not
  /// set, the deadline will be calculated from the frameTime and interval.
  /// [interval] The interval between BeginFrames that is reported to the
  /// compositor, in milliseconds. Defaults to a 60 frames/second interval, i.e.
  /// about 16.666 milliseconds.
  /// [screenshot] If set, a screenshot of the frame will be captured and returned
  /// in the response. Otherwise, no screenshot will be captured.
  Future<BeginFrameResult> beginFrame({
    runtime.Timestamp frameTime,
    runtime.Timestamp deadline,
    num interval,
    ScreenshotParams screenshot,
  }) async {
    Map parameters = {};
    if (frameTime != null) {
      parameters['frameTime'] = frameTime.toJson();
    }
    if (deadline != null) {
      parameters['deadline'] = deadline.toJson();
    }
    if (interval != null) {
      parameters['interval'] = interval;
    }
    if (screenshot != null) {
      parameters['screenshot'] = screenshot.toJson();
    }
    Map result =
        await _client.send('HeadlessExperimental.beginFrame', parameters);
    return new BeginFrameResult.fromJson(result);
  }
}

class BeginFrameResult {
  /// Whether the BeginFrame resulted in damage and, thus, a new frame was
  /// committed to the display.
  final bool hasDamage;

  /// Whether the main frame submitted a new display frame in response to this
  /// BeginFrame.
  final bool mainFrameContentUpdated;

  /// Base64-encoded image data of the screenshot, if one was requested and
  /// successfully taken.
  final String screenshotData;

  BeginFrameResult({
    @required this.hasDamage,
    @required this.mainFrameContentUpdated,
    this.screenshotData,
  });

  factory BeginFrameResult.fromJson(Map json) {
    return new BeginFrameResult(
      hasDamage: json['hasDamage'],
      mainFrameContentUpdated: json['mainFrameContentUpdated'],
      screenshotData:
          json.containsKey('screenshotData') ? json['screenshotData'] : null,
    );
  }
}

/// Encoding options for a screenshot.
class ScreenshotParams {
  /// Image compression format (defaults to png).
  final String format;

  /// Compression quality from range [0..100] (jpeg only).
  final int quality;

  ScreenshotParams({
    this.format,
    this.quality,
  });

  factory ScreenshotParams.fromJson(Map json) {
    return new ScreenshotParams(
      format: json.containsKey('format') ? json['format'] : null,
      quality: json.containsKey('quality') ? json['quality'] : null,
    );
  }

  Map toJson() {
    Map json = {};
    if (format != null) {
      json['format'] = format;
    }
    if (quality != null) {
      json['quality'] = quality;
    }
    return json;
  }
}
