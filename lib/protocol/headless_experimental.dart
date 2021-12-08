import 'dart:async';
import '../src/connection.dart';

/// This domain provides experimental commands only supported in headless mode.
class HeadlessExperimentalApi {
  final Client _client;

  HeadlessExperimentalApi(this._client);

  /// Issued when the target starts or stops needing BeginFrames.
  /// Deprecated. Issue beginFrame unconditionally instead and use result from
  /// beginFrame to detect whether the frames were suppressed.
  Stream<bool> get onNeedsBeginFramesChanged => _client.onEvent
      .where((event) =>
          event.name == 'HeadlessExperimental.needsBeginFramesChanged')
      .map((event) => event.parameters['needsBeginFrames'] as bool);

  /// Sends a BeginFrame to the target and returns when the frame was completed. Optionally captures a
  /// screenshot from the resulting frame. Requires that the target was created with enabled
  /// BeginFrameControl. Designed for use with --run-all-compositor-stages-before-draw, see also
  /// https://goo.gl/3zHXhB for more background.
  /// [frameTimeTicks] Timestamp of this BeginFrame in Renderer TimeTicks (milliseconds of uptime). If not set,
  /// the current time will be used.
  /// [interval] The interval between BeginFrames that is reported to the compositor, in milliseconds.
  /// Defaults to a 60 frames/second interval, i.e. about 16.666 milliseconds.
  /// [noDisplayUpdates] Whether updates should not be committed and drawn onto the display. False by default. If
  /// true, only side effects of the BeginFrame will be run, such as layout and animations, but
  /// any visual updates may not be visible on the display or in screenshots.
  /// [screenshot] If set, a screenshot of the frame will be captured and returned in the response. Otherwise,
  /// no screenshot will be captured. Note that capturing a screenshot can fail, for example,
  /// during renderer initialization. In such a case, no screenshot data will be returned.
  Future<BeginFrameResult> beginFrame(
      {num? frameTimeTicks,
      num? interval,
      bool? noDisplayUpdates,
      ScreenshotParams? screenshot}) async {
    var result = await _client.send('HeadlessExperimental.beginFrame', {
      if (frameTimeTicks != null) 'frameTimeTicks': frameTimeTicks,
      if (interval != null) 'interval': interval,
      if (noDisplayUpdates != null) 'noDisplayUpdates': noDisplayUpdates,
      if (screenshot != null) 'screenshot': screenshot,
    });
    return BeginFrameResult.fromJson(result);
  }

  /// Disables headless events for the target.
  Future<void> disable() async {
    await _client.send('HeadlessExperimental.disable');
  }

  /// Enables headless events for the target.
  Future<void> enable() async {
    await _client.send('HeadlessExperimental.enable');
  }
}

class BeginFrameResult {
  /// Whether the BeginFrame resulted in damage and, thus, a new frame was committed to the
  /// display. Reported for diagnostic uses, may be removed in the future.
  final bool hasDamage;

  /// Base64-encoded image data of the screenshot, if one was requested and successfully taken.
  final String? screenshotData;

  BeginFrameResult({required this.hasDamage, this.screenshotData});

  factory BeginFrameResult.fromJson(Map<String, dynamic> json) {
    return BeginFrameResult(
      hasDamage: json['hasDamage'] as bool? ?? false,
      screenshotData: json.containsKey('screenshotData')
          ? json['screenshotData'] as String
          : null,
    );
  }
}

/// Encoding options for a screenshot.
class ScreenshotParams {
  /// Image compression format (defaults to png).
  final ScreenshotParamsFormat? format;

  /// Compression quality from range [0..100] (jpeg only).
  final int? quality;

  ScreenshotParams({this.format, this.quality});

  factory ScreenshotParams.fromJson(Map<String, dynamic> json) {
    return ScreenshotParams(
      format: json.containsKey('format')
          ? ScreenshotParamsFormat.fromJson(json['format'] as String)
          : null,
      quality: json.containsKey('quality') ? json['quality'] as int : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (format != null) 'format': format,
      if (quality != null) 'quality': quality,
    };
  }
}

class ScreenshotParamsFormat {
  static const jpeg = ScreenshotParamsFormat._('jpeg');
  static const png = ScreenshotParamsFormat._('png');
  static const values = {
    'jpeg': jpeg,
    'png': png,
  };

  final String value;

  const ScreenshotParamsFormat._(this.value);

  factory ScreenshotParamsFormat.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ScreenshotParamsFormat && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
