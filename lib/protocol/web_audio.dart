import 'dart:async';
import '../src/connection.dart';

/// This domain allows inspection of Web Audio API.
/// https://webaudio.github.io/web-audio-api/
class WebAudioApi {
  final Client _client;

  WebAudioApi(this._client);

  /// Notifies that a new BaseAudioContext has been created.
  Stream<BaseAudioContext> get onContextCreated => _client.onEvent
      .where((event) => event.name == 'WebAudio.contextCreated')
      .map((event) => BaseAudioContext.fromJson(
          event.parameters['context'] as Map<String, dynamic>));

  /// Notifies that an existing BaseAudioContext will be destroyed.
  Stream<GraphObjectId> get onContextWillBeDestroyed => _client.onEvent
      .where((event) => event.name == 'WebAudio.contextWillBeDestroyed')
      .map((event) =>
          GraphObjectId.fromJson(event.parameters['contextId'] as String));

  /// Notifies that existing BaseAudioContext has changed some properties (id stays the same)..
  Stream<BaseAudioContext> get onContextChanged => _client.onEvent
      .where((event) => event.name == 'WebAudio.contextChanged')
      .map((event) => BaseAudioContext.fromJson(
          event.parameters['context'] as Map<String, dynamic>));

  /// Notifies that the construction of an AudioListener has finished.
  Stream<AudioListener> get onAudioListenerCreated => _client.onEvent
      .where((event) => event.name == 'WebAudio.audioListenerCreated')
      .map((event) => AudioListener.fromJson(
          event.parameters['listener'] as Map<String, dynamic>));

  /// Notifies that a new AudioListener has been created.
  Stream<AudioListenerWillBeDestroyedEvent>
      get onAudioListenerWillBeDestroyed => _client.onEvent
          .where(
              (event) => event.name == 'WebAudio.audioListenerWillBeDestroyed')
          .map((event) =>
              AudioListenerWillBeDestroyedEvent.fromJson(event.parameters));

  /// Notifies that a new AudioNode has been created.
  Stream<AudioNode> get onAudioNodeCreated => _client.onEvent
      .where((event) => event.name == 'WebAudio.audioNodeCreated')
      .map((event) =>
          AudioNode.fromJson(event.parameters['node'] as Map<String, dynamic>));

  /// Notifies that an existing AudioNode has been destroyed.
  Stream<AudioNodeWillBeDestroyedEvent> get onAudioNodeWillBeDestroyed =>
      _client.onEvent
          .where((event) => event.name == 'WebAudio.audioNodeWillBeDestroyed')
          .map((event) =>
              AudioNodeWillBeDestroyedEvent.fromJson(event.parameters));

  /// Notifies that a new AudioParam has been created.
  Stream<AudioParam> get onAudioParamCreated => _client.onEvent
      .where((event) => event.name == 'WebAudio.audioParamCreated')
      .map((event) => AudioParam.fromJson(
          event.parameters['param'] as Map<String, dynamic>));

  /// Notifies that an existing AudioParam has been destroyed.
  Stream<AudioParamWillBeDestroyedEvent> get onAudioParamWillBeDestroyed =>
      _client.onEvent
          .where((event) => event.name == 'WebAudio.audioParamWillBeDestroyed')
          .map((event) =>
              AudioParamWillBeDestroyedEvent.fromJson(event.parameters));

  /// Notifies that two AudioNodes are connected.
  Stream<NodesConnectedEvent> get onNodesConnected => _client.onEvent
      .where((event) => event.name == 'WebAudio.nodesConnected')
      .map((event) => NodesConnectedEvent.fromJson(event.parameters));

  /// Notifies that AudioNodes are disconnected. The destination can be null, and it means all the outgoing connections from the source are disconnected.
  Stream<NodesDisconnectedEvent> get onNodesDisconnected => _client.onEvent
      .where((event) => event.name == 'WebAudio.nodesDisconnected')
      .map((event) => NodesDisconnectedEvent.fromJson(event.parameters));

  /// Notifies that an AudioNode is connected to an AudioParam.
  Stream<NodeParamConnectedEvent> get onNodeParamConnected => _client.onEvent
      .where((event) => event.name == 'WebAudio.nodeParamConnected')
      .map((event) => NodeParamConnectedEvent.fromJson(event.parameters));

  /// Notifies that an AudioNode is disconnected to an AudioParam.
  Stream<NodeParamDisconnectedEvent> get onNodeParamDisconnected => _client
      .onEvent
      .where((event) => event.name == 'WebAudio.nodeParamDisconnected')
      .map((event) => NodeParamDisconnectedEvent.fromJson(event.parameters));

  /// Enables the WebAudio domain and starts sending context lifetime events.
  Future<void> enable() async {
    await _client.send('WebAudio.enable');
  }

  /// Disables the WebAudio domain.
  Future<void> disable() async {
    await _client.send('WebAudio.disable');
  }

  /// Fetch the realtime data from the registered contexts.
  Future<ContextRealtimeData> getRealtimeData(GraphObjectId contextId) async {
    var result = await _client.send('WebAudio.getRealtimeData', {
      'contextId': contextId,
    });
    return ContextRealtimeData.fromJson(
        result['realtimeData'] as Map<String, dynamic>);
  }
}

class AudioListenerWillBeDestroyedEvent {
  final GraphObjectId contextId;

  final GraphObjectId listenerId;

  AudioListenerWillBeDestroyedEvent(
      {required this.contextId, required this.listenerId});

  factory AudioListenerWillBeDestroyedEvent.fromJson(
      Map<String, dynamic> json) {
    return AudioListenerWillBeDestroyedEvent(
      contextId: GraphObjectId.fromJson(json['contextId'] as String),
      listenerId: GraphObjectId.fromJson(json['listenerId'] as String),
    );
  }
}

class AudioNodeWillBeDestroyedEvent {
  final GraphObjectId contextId;

  final GraphObjectId nodeId;

  AudioNodeWillBeDestroyedEvent(
      {required this.contextId, required this.nodeId});

  factory AudioNodeWillBeDestroyedEvent.fromJson(Map<String, dynamic> json) {
    return AudioNodeWillBeDestroyedEvent(
      contextId: GraphObjectId.fromJson(json['contextId'] as String),
      nodeId: GraphObjectId.fromJson(json['nodeId'] as String),
    );
  }
}

class AudioParamWillBeDestroyedEvent {
  final GraphObjectId contextId;

  final GraphObjectId nodeId;

  final GraphObjectId paramId;

  AudioParamWillBeDestroyedEvent(
      {required this.contextId, required this.nodeId, required this.paramId});

  factory AudioParamWillBeDestroyedEvent.fromJson(Map<String, dynamic> json) {
    return AudioParamWillBeDestroyedEvent(
      contextId: GraphObjectId.fromJson(json['contextId'] as String),
      nodeId: GraphObjectId.fromJson(json['nodeId'] as String),
      paramId: GraphObjectId.fromJson(json['paramId'] as String),
    );
  }
}

class NodesConnectedEvent {
  final GraphObjectId contextId;

  final GraphObjectId sourceId;

  final GraphObjectId destinationId;

  final num? sourceOutputIndex;

  final num? destinationInputIndex;

  NodesConnectedEvent(
      {required this.contextId,
      required this.sourceId,
      required this.destinationId,
      this.sourceOutputIndex,
      this.destinationInputIndex});

  factory NodesConnectedEvent.fromJson(Map<String, dynamic> json) {
    return NodesConnectedEvent(
      contextId: GraphObjectId.fromJson(json['contextId'] as String),
      sourceId: GraphObjectId.fromJson(json['sourceId'] as String),
      destinationId: GraphObjectId.fromJson(json['destinationId'] as String),
      sourceOutputIndex: json.containsKey('sourceOutputIndex')
          ? json['sourceOutputIndex'] as num
          : null,
      destinationInputIndex: json.containsKey('destinationInputIndex')
          ? json['destinationInputIndex'] as num
          : null,
    );
  }
}

class NodesDisconnectedEvent {
  final GraphObjectId contextId;

  final GraphObjectId sourceId;

  final GraphObjectId destinationId;

  final num? sourceOutputIndex;

  final num? destinationInputIndex;

  NodesDisconnectedEvent(
      {required this.contextId,
      required this.sourceId,
      required this.destinationId,
      this.sourceOutputIndex,
      this.destinationInputIndex});

  factory NodesDisconnectedEvent.fromJson(Map<String, dynamic> json) {
    return NodesDisconnectedEvent(
      contextId: GraphObjectId.fromJson(json['contextId'] as String),
      sourceId: GraphObjectId.fromJson(json['sourceId'] as String),
      destinationId: GraphObjectId.fromJson(json['destinationId'] as String),
      sourceOutputIndex: json.containsKey('sourceOutputIndex')
          ? json['sourceOutputIndex'] as num
          : null,
      destinationInputIndex: json.containsKey('destinationInputIndex')
          ? json['destinationInputIndex'] as num
          : null,
    );
  }
}

class NodeParamConnectedEvent {
  final GraphObjectId contextId;

  final GraphObjectId sourceId;

  final GraphObjectId destinationId;

  final num? sourceOutputIndex;

  NodeParamConnectedEvent(
      {required this.contextId,
      required this.sourceId,
      required this.destinationId,
      this.sourceOutputIndex});

  factory NodeParamConnectedEvent.fromJson(Map<String, dynamic> json) {
    return NodeParamConnectedEvent(
      contextId: GraphObjectId.fromJson(json['contextId'] as String),
      sourceId: GraphObjectId.fromJson(json['sourceId'] as String),
      destinationId: GraphObjectId.fromJson(json['destinationId'] as String),
      sourceOutputIndex: json.containsKey('sourceOutputIndex')
          ? json['sourceOutputIndex'] as num
          : null,
    );
  }
}

class NodeParamDisconnectedEvent {
  final GraphObjectId contextId;

  final GraphObjectId sourceId;

  final GraphObjectId destinationId;

  final num? sourceOutputIndex;

  NodeParamDisconnectedEvent(
      {required this.contextId,
      required this.sourceId,
      required this.destinationId,
      this.sourceOutputIndex});

  factory NodeParamDisconnectedEvent.fromJson(Map<String, dynamic> json) {
    return NodeParamDisconnectedEvent(
      contextId: GraphObjectId.fromJson(json['contextId'] as String),
      sourceId: GraphObjectId.fromJson(json['sourceId'] as String),
      destinationId: GraphObjectId.fromJson(json['destinationId'] as String),
      sourceOutputIndex: json.containsKey('sourceOutputIndex')
          ? json['sourceOutputIndex'] as num
          : null,
    );
  }
}

/// An unique ID for a graph object (AudioContext, AudioNode, AudioParam) in Web Audio API
class GraphObjectId {
  final String value;

  GraphObjectId(this.value);

  factory GraphObjectId.fromJson(String value) => GraphObjectId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is GraphObjectId && other.value == value) || value == other;

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

  factory ContextType.fromJson(String value) => values[value]!;

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

  factory ContextState.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ContextState && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Enum of AudioNode types
class NodeType {
  final String value;

  NodeType(this.value);

  factory NodeType.fromJson(String value) => NodeType(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is NodeType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Enum of AudioNode::ChannelCountMode from the spec
class ChannelCountMode {
  static const clampedMax = ChannelCountMode._('clamped-max');
  static const explicit = ChannelCountMode._('explicit');
  static const max = ChannelCountMode._('max');
  static const values = {
    'clamped-max': clampedMax,
    'explicit': explicit,
    'max': max,
  };

  final String value;

  const ChannelCountMode._(this.value);

  factory ChannelCountMode.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ChannelCountMode && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Enum of AudioNode::ChannelInterpretation from the spec
class ChannelInterpretation {
  static const discrete = ChannelInterpretation._('discrete');
  static const speakers = ChannelInterpretation._('speakers');
  static const values = {
    'discrete': discrete,
    'speakers': speakers,
  };

  final String value;

  const ChannelInterpretation._(this.value);

  factory ChannelInterpretation.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ChannelInterpretation && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Enum of AudioParam types
class ParamType {
  final String value;

  ParamType(this.value);

  factory ParamType.fromJson(String value) => ParamType(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ParamType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Enum of AudioParam::AutomationRate from the spec
class AutomationRate {
  static const aRate = AutomationRate._('a-rate');
  static const kRate = AutomationRate._('k-rate');
  static const values = {
    'a-rate': aRate,
    'k-rate': kRate,
  };

  final String value;

  const AutomationRate._(this.value);

  factory AutomationRate.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is AutomationRate && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Fields in AudioContext that change in real-time.
class ContextRealtimeData {
  /// The current context time in second in BaseAudioContext.
  final num currentTime;

  /// The time spent on rendering graph divided by render quantum duration,
  /// and multiplied by 100. 100 means the audio renderer reached the full
  /// capacity and glitch may occur.
  final num renderCapacity;

  /// A running mean of callback interval.
  final num callbackIntervalMean;

  /// A running variance of callback interval.
  final num callbackIntervalVariance;

  ContextRealtimeData(
      {required this.currentTime,
      required this.renderCapacity,
      required this.callbackIntervalMean,
      required this.callbackIntervalVariance});

  factory ContextRealtimeData.fromJson(Map<String, dynamic> json) {
    return ContextRealtimeData(
      currentTime: json['currentTime'] as num,
      renderCapacity: json['renderCapacity'] as num,
      callbackIntervalMean: json['callbackIntervalMean'] as num,
      callbackIntervalVariance: json['callbackIntervalVariance'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentTime': currentTime,
      'renderCapacity': renderCapacity,
      'callbackIntervalMean': callbackIntervalMean,
      'callbackIntervalVariance': callbackIntervalVariance,
    };
  }
}

/// Protocol object for BaseAudioContext
class BaseAudioContext {
  final GraphObjectId contextId;

  final ContextType contextType;

  final ContextState contextState;

  final ContextRealtimeData? realtimeData;

  /// Platform-dependent callback buffer size.
  final num callbackBufferSize;

  /// Number of output channels supported by audio hardware in use.
  final num maxOutputChannelCount;

  /// Context sample rate.
  final num sampleRate;

  BaseAudioContext(
      {required this.contextId,
      required this.contextType,
      required this.contextState,
      this.realtimeData,
      required this.callbackBufferSize,
      required this.maxOutputChannelCount,
      required this.sampleRate});

  factory BaseAudioContext.fromJson(Map<String, dynamic> json) {
    return BaseAudioContext(
      contextId: GraphObjectId.fromJson(json['contextId'] as String),
      contextType: ContextType.fromJson(json['contextType'] as String),
      contextState: ContextState.fromJson(json['contextState'] as String),
      realtimeData: json.containsKey('realtimeData')
          ? ContextRealtimeData.fromJson(
              json['realtimeData'] as Map<String, dynamic>)
          : null,
      callbackBufferSize: json['callbackBufferSize'] as num,
      maxOutputChannelCount: json['maxOutputChannelCount'] as num,
      sampleRate: json['sampleRate'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contextId': contextId.toJson(),
      'contextType': contextType.toJson(),
      'contextState': contextState.toJson(),
      'callbackBufferSize': callbackBufferSize,
      'maxOutputChannelCount': maxOutputChannelCount,
      'sampleRate': sampleRate,
      if (realtimeData != null) 'realtimeData': realtimeData!.toJson(),
    };
  }
}

/// Protocol object for AudioListener
class AudioListener {
  final GraphObjectId listenerId;

  final GraphObjectId contextId;

  AudioListener({required this.listenerId, required this.contextId});

  factory AudioListener.fromJson(Map<String, dynamic> json) {
    return AudioListener(
      listenerId: GraphObjectId.fromJson(json['listenerId'] as String),
      contextId: GraphObjectId.fromJson(json['contextId'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listenerId': listenerId.toJson(),
      'contextId': contextId.toJson(),
    };
  }
}

/// Protocol object for AudioNode
class AudioNode {
  final GraphObjectId nodeId;

  final GraphObjectId contextId;

  final NodeType nodeType;

  final num numberOfInputs;

  final num numberOfOutputs;

  final num channelCount;

  final ChannelCountMode channelCountMode;

  final ChannelInterpretation channelInterpretation;

  AudioNode(
      {required this.nodeId,
      required this.contextId,
      required this.nodeType,
      required this.numberOfInputs,
      required this.numberOfOutputs,
      required this.channelCount,
      required this.channelCountMode,
      required this.channelInterpretation});

  factory AudioNode.fromJson(Map<String, dynamic> json) {
    return AudioNode(
      nodeId: GraphObjectId.fromJson(json['nodeId'] as String),
      contextId: GraphObjectId.fromJson(json['contextId'] as String),
      nodeType: NodeType.fromJson(json['nodeType'] as String),
      numberOfInputs: json['numberOfInputs'] as num,
      numberOfOutputs: json['numberOfOutputs'] as num,
      channelCount: json['channelCount'] as num,
      channelCountMode:
          ChannelCountMode.fromJson(json['channelCountMode'] as String),
      channelInterpretation: ChannelInterpretation.fromJson(
          json['channelInterpretation'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nodeId': nodeId.toJson(),
      'contextId': contextId.toJson(),
      'nodeType': nodeType.toJson(),
      'numberOfInputs': numberOfInputs,
      'numberOfOutputs': numberOfOutputs,
      'channelCount': channelCount,
      'channelCountMode': channelCountMode.toJson(),
      'channelInterpretation': channelInterpretation.toJson(),
    };
  }
}

/// Protocol object for AudioParam
class AudioParam {
  final GraphObjectId paramId;

  final GraphObjectId nodeId;

  final GraphObjectId contextId;

  final ParamType paramType;

  final AutomationRate rate;

  final num defaultValue;

  final num minValue;

  final num maxValue;

  AudioParam(
      {required this.paramId,
      required this.nodeId,
      required this.contextId,
      required this.paramType,
      required this.rate,
      required this.defaultValue,
      required this.minValue,
      required this.maxValue});

  factory AudioParam.fromJson(Map<String, dynamic> json) {
    return AudioParam(
      paramId: GraphObjectId.fromJson(json['paramId'] as String),
      nodeId: GraphObjectId.fromJson(json['nodeId'] as String),
      contextId: GraphObjectId.fromJson(json['contextId'] as String),
      paramType: ParamType.fromJson(json['paramType'] as String),
      rate: AutomationRate.fromJson(json['rate'] as String),
      defaultValue: json['defaultValue'] as num,
      minValue: json['minValue'] as num,
      maxValue: json['maxValue'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paramId': paramId.toJson(),
      'nodeId': nodeId.toJson(),
      'contextId': contextId.toJson(),
      'paramType': paramType.toJson(),
      'rate': rate.toJson(),
      'defaultValue': defaultValue,
      'minValue': minValue,
      'maxValue': maxValue,
    };
  }
}
