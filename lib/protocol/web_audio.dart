import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';

/// This domain allows inspection of Web Audio API.
/// https://webaudio.github.io/web-audio-api/
class WebAudioApi {
  final Client _client;

  WebAudioApi(this._client);

  /// Notifies that a new BaseAudioContext has been created.
  Stream<BaseAudioContext> get onContextCreated => _client.onEvent
      .where((Event event) => event.name == 'WebAudio.contextCreated')
      .map((Event event) =>
          BaseAudioContext.fromJson(event.parameters['context']));

  /// Notifies that existing BaseAudioContext has been destroyed.
  Stream<ContextId> get onContextDestroyed => _client.onEvent
      .where((Event event) => event.name == 'WebAudio.contextDestroyed')
      .map((Event event) => ContextId.fromJson(event.parameters['contextId']));

  /// Notifies that existing BaseAudioContext has changed some properties (id stays the same)..
  Stream<BaseAudioContext> get onContextChanged => _client.onEvent
      .where((Event event) => event.name == 'WebAudio.contextChanged')
      .map((Event event) =>
          BaseAudioContext.fromJson(event.parameters['context']));

  /// Enables the WebAudio domain and starts sending context lifetime events.
  Future<void> enable() async {
    await _client.send('WebAudio.enable');
  }

  /// Disables the WebAudio domain.
  Future<void> disable() async {
    await _client.send('WebAudio.disable');
  }

  /// Fetch the realtime data from the registered contexts.
  Future<ContextRealtimeData> getRealtimeData(ContextId contextId) async {
    var parameters = <String, dynamic>{
      'contextId': contextId.toJson(),
    };
    var result = await _client.send('WebAudio.getRealtimeData', parameters);
    return ContextRealtimeData.fromJson(result['realtimeData']);
  }
}

/// Context's UUID in string
class ContextId {
  final String value;

  ContextId(this.value);

  factory ContextId.fromJson(String value) => ContextId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ContextId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Enum of BaseAudioContext types
class ContextType {
  static const realtime = ContextType._('realtime');
  static const offline = ContextType._('offline');
  static const values = {
    'realtime': realtime,
    'offline': offline,
  };

  final String value;

  const ContextType._(this.value);

  factory ContextType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ContextType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Enum of AudioContextState from the spec
class ContextState {
  static const suspended = ContextState._('suspended');
  static const running = ContextState._('running');
  static const closed = ContextState._('closed');
  static const values = {
    'suspended': suspended,
    'running': running,
    'closed': closed,
  };

  final String value;

  const ContextState._(this.value);

  factory ContextState.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ContextState && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Fields in AudioContext that change in real-time. These are not updated
/// on OfflineAudioContext.
class ContextRealtimeData {
  /// The current context time in second in BaseAudioContext.
  final num currentTime;

  /// The time spent on rendering graph divided by render qunatum duration,
  /// and multiplied by 100. 100 means the audio renderer reached the full
  /// capacity and glitch may occur.
  final num renderCapacity;

  ContextRealtimeData({this.currentTime, this.renderCapacity});

  factory ContextRealtimeData.fromJson(Map<String, dynamic> json) {
    return ContextRealtimeData(
      currentTime: json.containsKey('currentTime') ? json['currentTime'] : null,
      renderCapacity:
          json.containsKey('renderCapacity') ? json['renderCapacity'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};
    if (currentTime != null) {
      json['currentTime'] = currentTime;
    }
    if (renderCapacity != null) {
      json['renderCapacity'] = renderCapacity;
    }
    return json;
  }
}

/// Protocol object for BaseAudioContext
class BaseAudioContext {
  final ContextId contextId;

  final ContextType contextType;

  final ContextState contextState;

  final ContextRealtimeData realtimeData;

  /// Platform-dependent callback buffer size.
  final num callbackBufferSize;

  /// Number of output channels supported by audio hardware in use.
  final num maxOutputChannelCount;

  /// Context sample rate.
  final num sampleRate;

  BaseAudioContext(
      {@required this.contextId,
      @required this.contextType,
      @required this.contextState,
      this.realtimeData,
      @required this.callbackBufferSize,
      @required this.maxOutputChannelCount,
      @required this.sampleRate});

  factory BaseAudioContext.fromJson(Map<String, dynamic> json) {
    return BaseAudioContext(
      contextId: ContextId.fromJson(json['contextId']),
      contextType: ContextType.fromJson(json['contextType']),
      contextState: ContextState.fromJson(json['contextState']),
      realtimeData: json.containsKey('realtimeData')
          ? ContextRealtimeData.fromJson(json['realtimeData'])
          : null,
      callbackBufferSize: json['callbackBufferSize'],
      maxOutputChannelCount: json['maxOutputChannelCount'],
      sampleRate: json['sampleRate'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'contextId': contextId.toJson(),
      'contextType': contextType.toJson(),
      'contextState': contextState.toJson(),
      'callbackBufferSize': callbackBufferSize,
      'maxOutputChannelCount': maxOutputChannelCount,
      'sampleRate': sampleRate,
    };
    if (realtimeData != null) {
      json['realtimeData'] = realtimeData.toJson();
    }
    return json;
  }
}
