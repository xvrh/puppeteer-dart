import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'runtime.dart' as runtime;

/// This domain provides experimental commands only supported in headless mode.
class HeadlessExperimentalApi {
  final Client _client;

  HeadlessExperimentalApi(this._client);

  /// Issued when the target starts or stops needing BeginFrames.
  Stream<bool> get onNeedsBeginFramesChanged => _client.onEvent
      .where((Event event) =>
          event.name == 'HeadlessExperimental.needsBeginFramesChanged')
      .map((Event event) => event.parameters['needsBeginFrames'] as bool);

  /// Sends a BeginFrame to the target and returns when the frame was completed. Optionally captures a
  /// screenshot from the resulting frame. Requires that the target was created with enabled
  /// BeginFrameControl. Designed for use with --run-all-compositor-stages-before-draw, see also
  /// https://goo.gl/3zHXhB for more background.
  /// [frameTime] Timestamp of this BeginFrame (milliseconds since epoch). If not set, the current time will
  /// be used unless frameTicks is specified.
  /// [frameTimeTicks] Timestamp of this BeginFrame in Renderer TimeTicks (milliseconds of uptime). If not set,
  /// the current time will be used unless frameTime is specified.
  /// [deadline] Deadline of this BeginFrame (milliseconds since epoch). If not set, the deadline will be
  /// calculated from the frameTime and interval unless deadlineTicks is specified.
  /// [deadlineTicks] Deadline of this BeginFrame in Renderer TimeTicks  (milliseconds of uptime). If not set,
  /// the deadline will be calculated from the frameTime and interval unless deadline is specified.
  /// [interval] The interval between BeginFrames that is reported to the compositor, in milliseconds.
  /// Defaults to a 60 frames/second interval, i.e. about 16.666 milliseconds.
  /// [noDisplayUpdates] Whether updates should not be committed and drawn onto the display. False by default. If
  /// true, only side effects of the BeginFrame will be run, such as layout and animations, but
  /// any visual updates may not be visible on the display or in screenshots.
  /// [screenshot] If set, a screenshot of the frame will be captured and returned in the response. Otherwise,
  /// no screenshot will be captured. Note that capturing a screenshot can fail, for example,
  /// during renderer initialization. In such a case, no screenshot data will be returned.
  Future<BeginFrameResult> beginFrame({
    runtime.Timestamp frameTime,
    num frameTimeTicks,
    runtime.Timestamp deadline,
    num deadlineTicks,
    num interval,
    bool noDisplayUpdates,
    ScreenshotParams screenshot,
  }) async {
    Map parameters = {};
    if (frameTime != null) {
      parameters['frameTime'] = frameTime.toJson();
    }
    if (frameTimeTicks != null) {
      parameters['frameTimeTicks'] = frameTimeTicks;
    }
    if (deadline != null) {
      parameters['deadline'] = deadline.toJson();
    }
    if (deadlineTicks != null) {
      parameters['deadlineTicks'] = deadlineTicks;
    }
    if (interval != null) {
      parameters['interval'] = interval;
    }
    if (noDisplayUpdates != null) {
      parameters['noDisplayUpdates'] = noDisplayUpdates;
    }
    if (screenshot != null) {
      parameters['screenshot'] = screenshot.toJson();
    }
    Map result =
        await _client.send('HeadlessExperimental.beginFrame', parameters);
    return new BeginFrameResult.fromJson(result);
  }

  /// Puts the browser into deterministic mode.  Only effective for subsequently created web contents.
  /// Only supported in headless mode.  Once set there's no way of leaving deterministic mode.
  /// [initialDate] Number of seconds since the Epoch
  Future enterDeterministicMode({
    num initialDate,
  }) async {
    Map parameters = {};
    if (initialDate != null) {
      parameters['initialDate'] = initialDate;
    }
    await _client.send(
        'HeadlessExperimental.enterDeterministicMode', parameters);
  }

  /// Disables headless events for the target.
  Future disable() async {
    await _client.send('HeadlessExperimental.disable');
  }

  /// Enables headless events for the target.
  Future enable() async {
    await _client.send('HeadlessExperimental.enable');
  }
}

class BeginFrameResult {
  /// Whether the BeginFrame resulted in damage and, thus, a new frame was committed to the
  /// display. Reported for diagnostic uses, may be removed in the future.
  final bool hasDamage;

  /// Base64-encoded image data of the screenshot, if one was requested and successfully taken.
  final String screenshotData;

  BeginFrameResult({
    @required this.hasDamage,
    this.screenshotData,
  });

  factory BeginFrameResult.fromJson(Map json) {
    return new BeginFrameResult(
      hasDamage: json['hasDamage'],
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
