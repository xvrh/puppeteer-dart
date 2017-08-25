import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';
import 'dom.dart' as dom;
import '../runtime.dart' as runtime;

class AnimationManager {
  final Session _client;

  AnimationManager(this._client);

  /// Enables animation domain notifications.
  Future enable() async {
    await _client.send('Animation.enable');
  }

  /// Disables animation domain notifications.
  Future disable() async {
    await _client.send('Animation.disable');
  }

  /// Gets the playback rate of the document timeline.
  /// Return: Playback rate for animations on page.
  Future<num> getPlaybackRate() async {
    await _client.send('Animation.getPlaybackRate');
  }

  /// Sets the playback rate of the document timeline.
  /// [playbackRate] Playback rate for animations on page
  Future setPlaybackRate(
    num playbackRate,
  ) async {
    Map parameters = {
      'playbackRate': playbackRate.toString(),
    };
    await _client.send('Animation.setPlaybackRate', parameters);
  }

  /// Returns the current time of the an animation.
  /// [id] Id of animation.
  /// Return: Current time of the page.
  Future<num> getCurrentTime(
    String id,
  ) async {
    Map parameters = {
      'id': id.toString(),
    };
    await _client.send('Animation.getCurrentTime', parameters);
  }

  /// Sets the paused state of a set of animations.
  /// [animations] Animations to set the pause state of.
  /// [paused] Paused state to set to.
  Future setPaused(
    List<String> animations,
    bool paused,
  ) async {
    Map parameters = {
      'animations': animations.map((e) => e.toString()).toList(),
      'paused': paused.toString(),
    };
    await _client.send('Animation.setPaused', parameters);
  }

  /// Sets the timing of an animation node.
  /// [animationId] Animation id.
  /// [duration] Duration of the animation.
  /// [delay] Delay of the animation.
  Future setTiming(
    String animationId,
    num duration,
    num delay,
  ) async {
    Map parameters = {
      'animationId': animationId.toString(),
      'duration': duration.toString(),
      'delay': delay.toString(),
    };
    await _client.send('Animation.setTiming', parameters);
  }

  /// Seek a set of animations to a particular time within each animation.
  /// [animations] List of animation ids to seek.
  /// [currentTime] Set the current time of each animation.
  Future seekAnimations(
    List<String> animations,
    num currentTime,
  ) async {
    Map parameters = {
      'animations': animations.map((e) => e.toString()).toList(),
      'currentTime': currentTime.toString(),
    };
    await _client.send('Animation.seekAnimations', parameters);
  }

  /// Releases a set of animations to no longer be manipulated.
  /// [animations] List of animation ids to seek.
  Future releaseAnimations(
    List<String> animations,
  ) async {
    Map parameters = {
      'animations': animations.map((e) => e.toString()).toList(),
    };
    await _client.send('Animation.releaseAnimations', parameters);
  }

  /// Gets the remote object of the Animation.
  /// [animationId] Animation id.
  /// Return: Corresponding remote object.
  Future<runtime.RemoteObject> resolveAnimation(
    String animationId,
  ) async {
    Map parameters = {
      'animationId': animationId.toString(),
    };
    await _client.send('Animation.resolveAnimation', parameters);
  }
}

/// Animation instance.
class Animation {
  /// <code>Animation</code>'s id.
  final String id;

  /// <code>Animation</code>'s name.
  final String name;

  /// <code>Animation</code>'s internal paused state.
  final bool pausedState;

  /// <code>Animation</code>'s play state.
  final String playState;

  /// <code>Animation</code>'s playback rate.
  final num playbackRate;

  /// <code>Animation</code>'s start time.
  final num startTime;

  /// <code>Animation</code>'s current time.
  final num currentTime;

  /// <code>Animation</code>'s source animation node.
  final AnimationEffect source;

  /// Animation type of <code>Animation</code>.
  final String type;

  /// A unique ID for <code>Animation</code> representing the sources that triggered this CSS animation/transition.
  final String cssId;

  Animation({
    @required this.id,
    @required this.name,
    @required this.pausedState,
    @required this.playState,
    @required this.playbackRate,
    @required this.startTime,
    @required this.currentTime,
    @required this.source,
    @required this.type,
    this.cssId,
  });

  Map toJson() {
    Map json = {
      'id': id.toString(),
      'name': name.toString(),
      'pausedState': pausedState.toString(),
      'playState': playState.toString(),
      'playbackRate': playbackRate.toString(),
      'startTime': startTime.toString(),
      'currentTime': currentTime.toString(),
      'source': source.toJson(),
      'type': type.toString(),
    };
    if (cssId != null) {
      json['cssId'] = cssId.toString();
    }
    return json;
  }
}

/// AnimationEffect instance
class AnimationEffect {
  /// <code>AnimationEffect</code>'s delay.
  final num delay;

  /// <code>AnimationEffect</code>'s end delay.
  final num endDelay;

  /// <code>AnimationEffect</code>'s iteration start.
  final num iterationStart;

  /// <code>AnimationEffect</code>'s iterations.
  final num iterations;

  /// <code>AnimationEffect</code>'s iteration duration.
  final num duration;

  /// <code>AnimationEffect</code>'s playback direction.
  final String direction;

  /// <code>AnimationEffect</code>'s fill mode.
  final String fill;

  /// <code>AnimationEffect</code>'s target node.
  final dom.BackendNodeId backendNodeId;

  /// <code>AnimationEffect</code>'s keyframes.
  final KeyframesRule keyframesRule;

  /// <code>AnimationEffect</code>'s timing function.
  final String easing;

  AnimationEffect({
    @required this.delay,
    @required this.endDelay,
    @required this.iterationStart,
    @required this.iterations,
    @required this.duration,
    @required this.direction,
    @required this.fill,
    @required this.backendNodeId,
    this.keyframesRule,
    @required this.easing,
  });

  Map toJson() {
    Map json = {
      'delay': delay.toString(),
      'endDelay': endDelay.toString(),
      'iterationStart': iterationStart.toString(),
      'iterations': iterations.toString(),
      'duration': duration.toString(),
      'direction': direction.toString(),
      'fill': fill.toString(),
      'backendNodeId': backendNodeId.toJson(),
      'easing': easing.toString(),
    };
    if (keyframesRule != null) {
      json['keyframesRule'] = keyframesRule.toJson();
    }
    return json;
  }
}

/// Keyframes Rule
class KeyframesRule {
  /// CSS keyframed animation's name.
  final String name;

  /// List of animation keyframes.
  final List<KeyframeStyle> keyframes;

  KeyframesRule({
    this.name,
    @required this.keyframes,
  });

  Map toJson() {
    Map json = {
      'keyframes': keyframes.map((e) => e.toJson()).toList(),
    };
    if (name != null) {
      json['name'] = name.toString();
    }
    return json;
  }
}

/// Keyframe Style
class KeyframeStyle {
  /// Keyframe's time offset.
  final String offset;

  /// <code>AnimationEffect</code>'s timing function.
  final String easing;

  KeyframeStyle({
    @required this.offset,
    @required this.easing,
  });

  Map toJson() {
    Map json = {
      'offset': offset.toString(),
      'easing': easing.toString(),
    };
    return json;
  }
}
