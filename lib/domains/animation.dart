import 'dart:async';
// ignore: unused_import
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'dom.dart' as dom;
import 'runtime.dart' as runtime;

class AnimationDomain {
  final Client _client;

  AnimationDomain(this._client);

  /// Event for when an animation has been cancelled.
  Stream<String> get onAnimationCanceled => _client.onEvent
      .where((Event event) => event.name == 'Animation.animationCanceled')
      .map((Event event) => event.parameters['id'] as String);

  /// Event for each animation that has been created.
  Stream<String> get onAnimationCreated => _client.onEvent
      .where((Event event) => event.name == 'Animation.animationCreated')
      .map((Event event) => event.parameters['id'] as String);

  /// Event for animation that has been started.
  Stream<Animation> get onAnimationStarted => _client.onEvent
      .where((Event event) => event.name == 'Animation.animationStarted')
      .map((Event event) =>
          new Animation.fromJson(event.parameters['animation']));

  /// Disables animation domain notifications.
  Future disable() async {
    await _client.send('Animation.disable');
  }

  /// Enables animation domain notifications.
  Future enable() async {
    await _client.send('Animation.enable');
  }

  /// Returns the current time of the an animation.
  /// [id] Id of animation.
  /// Return: Current time of the page.
  Future<num> getCurrentTime(
    String id,
  ) async {
    Map parameters = {
      'id': id,
    };
    Map result = await _client.send('Animation.getCurrentTime', parameters);
    return result['currentTime'];
  }

  /// Gets the playback rate of the document timeline.
  /// Return: Playback rate for animations on page.
  Future<num> getPlaybackRate() async {
    Map result = await _client.send('Animation.getPlaybackRate');
    return result['playbackRate'];
  }

  /// Releases a set of animations to no longer be manipulated.
  /// [animations] List of animation ids to seek.
  Future releaseAnimations(
    List<String> animations,
  ) async {
    Map parameters = {
      'animations': animations.map((e) => e).toList(),
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
      'animationId': animationId,
    };
    Map result = await _client.send('Animation.resolveAnimation', parameters);
    return new runtime.RemoteObject.fromJson(result['remoteObject']);
  }

  /// Seek a set of animations to a particular time within each animation.
  /// [animations] List of animation ids to seek.
  /// [currentTime] Set the current time of each animation.
  Future seekAnimations(
    List<String> animations,
    num currentTime,
  ) async {
    Map parameters = {
      'animations': animations.map((e) => e).toList(),
      'currentTime': currentTime,
    };
    await _client.send('Animation.seekAnimations', parameters);
  }

  /// Sets the paused state of a set of animations.
  /// [animations] Animations to set the pause state of.
  /// [paused] Paused state to set to.
  Future setPaused(
    List<String> animations,
    bool paused,
  ) async {
    Map parameters = {
      'animations': animations.map((e) => e).toList(),
      'paused': paused,
    };
    await _client.send('Animation.setPaused', parameters);
  }

  /// Sets the playback rate of the document timeline.
  /// [playbackRate] Playback rate for animations on page
  Future setPlaybackRate(
    num playbackRate,
  ) async {
    Map parameters = {
      'playbackRate': playbackRate,
    };
    await _client.send('Animation.setPlaybackRate', parameters);
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
      'animationId': animationId,
      'duration': duration,
      'delay': delay,
    };
    await _client.send('Animation.setTiming', parameters);
  }
}

/// Animation instance.
class Animation {
  /// `Animation`'s id.
  final String id;

  /// `Animation`'s name.
  final String name;

  /// `Animation`'s internal paused state.
  final bool pausedState;

  /// `Animation`'s play state.
  final String playState;

  /// `Animation`'s playback rate.
  final num playbackRate;

  /// `Animation`'s start time.
  final num startTime;

  /// `Animation`'s current time.
  final num currentTime;

  /// Animation type of `Animation`.
  final String type;

  /// `Animation`'s source animation node.
  final AnimationEffect source;

  /// A unique ID for `Animation` representing the sources that triggered this CSS
  /// animation/transition.
  final String cssId;

  Animation({
    @required this.id,
    @required this.name,
    @required this.pausedState,
    @required this.playState,
    @required this.playbackRate,
    @required this.startTime,
    @required this.currentTime,
    @required this.type,
    this.source,
    this.cssId,
  });

  factory Animation.fromJson(Map json) {
    return new Animation(
      id: json['id'],
      name: json['name'],
      pausedState: json['pausedState'],
      playState: json['playState'],
      playbackRate: json['playbackRate'],
      startTime: json['startTime'],
      currentTime: json['currentTime'],
      type: json['type'],
      source: json.containsKey('source')
          ? new AnimationEffect.fromJson(json['source'])
          : null,
      cssId: json.containsKey('cssId') ? json['cssId'] : null,
    );
  }

  Map toJson() {
    Map json = {
      'id': id,
      'name': name,
      'pausedState': pausedState,
      'playState': playState,
      'playbackRate': playbackRate,
      'startTime': startTime,
      'currentTime': currentTime,
      'type': type,
    };
    if (source != null) {
      json['source'] = source.toJson();
    }
    if (cssId != null) {
      json['cssId'] = cssId;
    }
    return json;
  }
}

/// AnimationEffect instance
class AnimationEffect {
  /// `AnimationEffect`'s delay.
  final num delay;

  /// `AnimationEffect`'s end delay.
  final num endDelay;

  /// `AnimationEffect`'s iteration start.
  final num iterationStart;

  /// `AnimationEffect`'s iterations.
  final num iterations;

  /// `AnimationEffect`'s iteration duration.
  final num duration;

  /// `AnimationEffect`'s playback direction.
  final String direction;

  /// `AnimationEffect`'s fill mode.
  final String fill;

  /// `AnimationEffect`'s target node.
  final dom.BackendNodeId backendNodeId;

  /// `AnimationEffect`'s keyframes.
  final KeyframesRule keyframesRule;

  /// `AnimationEffect`'s timing function.
  final String easing;

  AnimationEffect({
    @required this.delay,
    @required this.endDelay,
    @required this.iterationStart,
    @required this.iterations,
    @required this.duration,
    @required this.direction,
    @required this.fill,
    this.backendNodeId,
    this.keyframesRule,
    @required this.easing,
  });

  factory AnimationEffect.fromJson(Map json) {
    return new AnimationEffect(
      delay: json['delay'],
      endDelay: json['endDelay'],
      iterationStart: json['iterationStart'],
      iterations: json['iterations'],
      duration: json['duration'],
      direction: json['direction'],
      fill: json['fill'],
      backendNodeId: json.containsKey('backendNodeId')
          ? new dom.BackendNodeId.fromJson(json['backendNodeId'])
          : null,
      keyframesRule: json.containsKey('keyframesRule')
          ? new KeyframesRule.fromJson(json['keyframesRule'])
          : null,
      easing: json['easing'],
    );
  }

  Map toJson() {
    Map json = {
      'delay': delay,
      'endDelay': endDelay,
      'iterationStart': iterationStart,
      'iterations': iterations,
      'duration': duration,
      'direction': direction,
      'fill': fill,
      'easing': easing,
    };
    if (backendNodeId != null) {
      json['backendNodeId'] = backendNodeId.toJson();
    }
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

  factory KeyframesRule.fromJson(Map json) {
    return new KeyframesRule(
      name: json.containsKey('name') ? json['name'] : null,
      keyframes: (json['keyframes'] as List)
          .map((e) => new KeyframeStyle.fromJson(e))
          .toList(),
    );
  }

  Map toJson() {
    Map json = {
      'keyframes': keyframes.map((e) => e.toJson()).toList(),
    };
    if (name != null) {
      json['name'] = name;
    }
    return json;
  }
}

/// Keyframe Style
class KeyframeStyle {
  /// Keyframe's time offset.
  final String offset;

  /// `AnimationEffect`'s timing function.
  final String easing;

  KeyframeStyle({
    @required this.offset,
    @required this.easing,
  });

  factory KeyframeStyle.fromJson(Map json) {
    return new KeyframeStyle(
      offset: json['offset'],
      easing: json['easing'],
    );
  }

  Map toJson() {
    Map json = {
      'offset': offset,
      'easing': easing,
    };
    return json;
  }
}
