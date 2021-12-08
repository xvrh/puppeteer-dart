import 'dart:async';
import '../src/connection.dart';
import 'dom.dart' as dom;
import 'runtime.dart' as runtime;

class AnimationApi {
  final Client _client;

  AnimationApi(this._client);

  /// Event for when an animation has been cancelled.
  Stream<String> get onAnimationCanceled => _client.onEvent
      .where((event) => event.name == 'Animation.animationCanceled')
      .map((event) => event.parameters['id'] as String);

  /// Event for each animation that has been created.
  Stream<String> get onAnimationCreated => _client.onEvent
      .where((event) => event.name == 'Animation.animationCreated')
      .map((event) => event.parameters['id'] as String);

  /// Event for animation that has been started.
  Stream<Animation> get onAnimationStarted => _client.onEvent
      .where((event) => event.name == 'Animation.animationStarted')
      .map((event) => Animation.fromJson(
          event.parameters['animation'] as Map<String, dynamic>));

  /// Disables animation domain notifications.
  Future<void> disable() async {
    await _client.send('Animation.disable');
  }

  /// Enables animation domain notifications.
  Future<void> enable() async {
    await _client.send('Animation.enable');
  }

  /// Returns the current time of the an animation.
  /// [id] Id of animation.
  /// Returns: Current time of the page.
  Future<num> getCurrentTime(String id) async {
    var result = await _client.send('Animation.getCurrentTime', {
      'id': id,
    });
    return result['currentTime'] as num;
  }

  /// Gets the playback rate of the document timeline.
  /// Returns: Playback rate for animations on page.
  Future<num> getPlaybackRate() async {
    var result = await _client.send('Animation.getPlaybackRate');
    return result['playbackRate'] as num;
  }

  /// Releases a set of animations to no longer be manipulated.
  /// [animations] List of animation ids to seek.
  Future<void> releaseAnimations(List<String> animations) async {
    await _client.send('Animation.releaseAnimations', {
      'animations': [...animations],
    });
  }

  /// Gets the remote object of the Animation.
  /// [animationId] Animation id.
  /// Returns: Corresponding remote object.
  Future<runtime.RemoteObject> resolveAnimation(String animationId) async {
    var result = await _client.send('Animation.resolveAnimation', {
      'animationId': animationId,
    });
    return runtime.RemoteObject.fromJson(
        result['remoteObject'] as Map<String, dynamic>);
  }

  /// Seek a set of animations to a particular time within each animation.
  /// [animations] List of animation ids to seek.
  /// [currentTime] Set the current time of each animation.
  Future<void> seekAnimations(List<String> animations, num currentTime) async {
    await _client.send('Animation.seekAnimations', {
      'animations': [...animations],
      'currentTime': currentTime,
    });
  }

  /// Sets the paused state of a set of animations.
  /// [animations] Animations to set the pause state of.
  /// [paused] Paused state to set to.
  Future<void> setPaused(List<String> animations, bool paused) async {
    await _client.send('Animation.setPaused', {
      'animations': [...animations],
      'paused': paused,
    });
  }

  /// Sets the playback rate of the document timeline.
  /// [playbackRate] Playback rate for animations on page
  Future<void> setPlaybackRate(num playbackRate) async {
    await _client.send('Animation.setPlaybackRate', {
      'playbackRate': playbackRate,
    });
  }

  /// Sets the timing of an animation node.
  /// [animationId] Animation id.
  /// [duration] Duration of the animation.
  /// [delay] Delay of the animation.
  Future<void> setTiming(String animationId, num duration, num delay) async {
    await _client.send('Animation.setTiming', {
      'animationId': animationId,
      'duration': duration,
      'delay': delay,
    });
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
  final AnimationType type;

  /// `Animation`'s source animation node.
  final AnimationEffect? source;

  /// A unique ID for `Animation` representing the sources that triggered this CSS
  /// animation/transition.
  final String? cssId;

  Animation(
      {required this.id,
      required this.name,
      required this.pausedState,
      required this.playState,
      required this.playbackRate,
      required this.startTime,
      required this.currentTime,
      required this.type,
      this.source,
      this.cssId});

  factory Animation.fromJson(Map<String, dynamic> json) {
    return Animation(
      id: json['id'] as String,
      name: json['name'] as String,
      pausedState: json['pausedState'] as bool? ?? false,
      playState: json['playState'] as String,
      playbackRate: json['playbackRate'] as num,
      startTime: json['startTime'] as num,
      currentTime: json['currentTime'] as num,
      type: AnimationType.fromJson(json['type'] as String),
      source: json.containsKey('source')
          ? AnimationEffect.fromJson(json['source'] as Map<String, dynamic>)
          : null,
      cssId: json.containsKey('cssId') ? json['cssId'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pausedState': pausedState,
      'playState': playState,
      'playbackRate': playbackRate,
      'startTime': startTime,
      'currentTime': currentTime,
      'type': type,
      if (source != null) 'source': source!.toJson(),
      if (cssId != null) 'cssId': cssId,
    };
  }
}

class AnimationType {
  static const cssTransition = AnimationType._('CSSTransition');
  static const cssAnimation = AnimationType._('CSSAnimation');
  static const webAnimation = AnimationType._('WebAnimation');
  static const values = {
    'CSSTransition': cssTransition,
    'CSSAnimation': cssAnimation,
    'WebAnimation': webAnimation,
  };

  final String value;

  const AnimationType._(this.value);

  factory AnimationType.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is AnimationType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
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
  final dom.BackendNodeId? backendNodeId;

  /// `AnimationEffect`'s keyframes.
  final KeyframesRule? keyframesRule;

  /// `AnimationEffect`'s timing function.
  final String easing;

  AnimationEffect(
      {required this.delay,
      required this.endDelay,
      required this.iterationStart,
      required this.iterations,
      required this.duration,
      required this.direction,
      required this.fill,
      this.backendNodeId,
      this.keyframesRule,
      required this.easing});

  factory AnimationEffect.fromJson(Map<String, dynamic> json) {
    return AnimationEffect(
      delay: json['delay'] as num,
      endDelay: json['endDelay'] as num,
      iterationStart: json['iterationStart'] as num,
      iterations: json['iterations'] as num,
      duration: json['duration'] as num,
      direction: json['direction'] as String,
      fill: json['fill'] as String,
      backendNodeId: json.containsKey('backendNodeId')
          ? dom.BackendNodeId.fromJson(json['backendNodeId'] as int)
          : null,
      keyframesRule: json.containsKey('keyframesRule')
          ? KeyframesRule.fromJson(
              json['keyframesRule'] as Map<String, dynamic>)
          : null,
      easing: json['easing'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'delay': delay,
      'endDelay': endDelay,
      'iterationStart': iterationStart,
      'iterations': iterations,
      'duration': duration,
      'direction': direction,
      'fill': fill,
      'easing': easing,
      if (backendNodeId != null) 'backendNodeId': backendNodeId!.toJson(),
      if (keyframesRule != null) 'keyframesRule': keyframesRule!.toJson(),
    };
  }
}

/// Keyframes Rule
class KeyframesRule {
  /// CSS keyframed animation's name.
  final String? name;

  /// List of animation keyframes.
  final List<KeyframeStyle> keyframes;

  KeyframesRule({this.name, required this.keyframes});

  factory KeyframesRule.fromJson(Map<String, dynamic> json) {
    return KeyframesRule(
      name: json.containsKey('name') ? json['name'] as String : null,
      keyframes: (json['keyframes'] as List)
          .map((e) => KeyframeStyle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyframes': keyframes.map((e) => e.toJson()).toList(),
      if (name != null) 'name': name,
    };
  }
}

/// Keyframe Style
class KeyframeStyle {
  /// Keyframe's time offset.
  final String offset;

  /// `AnimationEffect`'s timing function.
  final String easing;

  KeyframeStyle({required this.offset, required this.easing});

  factory KeyframeStyle.fromJson(Map<String, dynamic> json) {
    return KeyframeStyle(
      offset: json['offset'] as String,
      easing: json['easing'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offset': offset,
      'easing': easing,
    };
  }
}
