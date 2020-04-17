import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';

/// This domain allows detailed inspection of media elements
class MediaApi {
  final Client _client;

  MediaApi(this._client);

  /// This can be called multiple times, and can be used to set / override /
  /// remove player properties. A null propValue indicates removal.
  Stream<PlayerPropertiesChangedEvent> get onPlayerPropertiesChanged => _client
      .onEvent
      .where((event) => event.name == 'Media.playerPropertiesChanged')
      .map((event) => PlayerPropertiesChangedEvent.fromJson(event.parameters));

  /// Send events as a list, allowing them to be batched on the browser for less
  /// congestion. If batched, events must ALWAYS be in chronological order.
  Stream<PlayerEventsAddedEvent> get onPlayerEventsAdded => _client.onEvent
      .where((event) => event.name == 'Media.playerEventsAdded')
      .map((event) => PlayerEventsAddedEvent.fromJson(event.parameters));

  /// Called whenever a player is created, or when a new agent joins and recieves
  /// a list of active players. If an agent is restored, it will recieve the full
  /// list of player ids and all events again.
  Stream<List<PlayerId>> get onPlayersCreated => _client.onEvent
      .where((event) => event.name == 'Media.playersCreated')
      .map((event) => (event.parameters['players'] as List)
          .map((e) => PlayerId.fromJson(e as String))
          .toList());

  /// Enables the Media domain
  Future<void> enable() async {
    await _client.send('Media.enable');
  }

  /// Disables the Media domain.
  Future<void> disable() async {
    await _client.send('Media.disable');
  }
}

class PlayerPropertiesChangedEvent {
  final PlayerId playerId;

  final List<PlayerProperty> properties;

  PlayerPropertiesChangedEvent(
      {@required this.playerId, @required this.properties});

  factory PlayerPropertiesChangedEvent.fromJson(Map<String, dynamic> json) {
    return PlayerPropertiesChangedEvent(
      playerId: PlayerId.fromJson(json['playerId'] as String),
      properties: (json['properties'] as List)
          .map((e) => PlayerProperty.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PlayerEventsAddedEvent {
  final PlayerId playerId;

  final List<PlayerEvent> events;

  PlayerEventsAddedEvent({@required this.playerId, @required this.events});

  factory PlayerEventsAddedEvent.fromJson(Map<String, dynamic> json) {
    return PlayerEventsAddedEvent(
      playerId: PlayerId.fromJson(json['playerId'] as String),
      events: (json['events'] as List)
          .map((e) => PlayerEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Players will get an ID that is unique within the agent context.
class PlayerId {
  final String value;

  PlayerId(this.value);

  factory PlayerId.fromJson(String value) => PlayerId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is PlayerId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class Timestamp {
  final num value;

  Timestamp(this.value);

  factory Timestamp.fromJson(num value) => Timestamp(value);

  num toJson() => value;

  @override
  bool operator ==(other) =>
      (other is Timestamp && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Player Property type
class PlayerProperty {
  final String name;

  final String value;

  PlayerProperty({@required this.name, this.value});

  factory PlayerProperty.fromJson(Map<String, dynamic> json) {
    return PlayerProperty(
      name: json['name'] as String,
      value: json.containsKey('value') ? json['value'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (value != null) 'value': value,
    };
  }
}

/// Break out events into different types
class PlayerEventType {
  static const errorEvent = PlayerEventType._('errorEvent');
  static const triggeredEvent = PlayerEventType._('triggeredEvent');
  static const messageEvent = PlayerEventType._('messageEvent');
  static const values = {
    'errorEvent': errorEvent,
    'triggeredEvent': triggeredEvent,
    'messageEvent': messageEvent,
  };

  final String value;

  const PlayerEventType._(this.value);

  factory PlayerEventType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is PlayerEventType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class PlayerEvent {
  final PlayerEventType type;

  /// Events are timestamped relative to the start of the player creation
  /// not relative to the start of playback.
  final Timestamp timestamp;

  final String name;

  final String value;

  PlayerEvent(
      {@required this.type,
      @required this.timestamp,
      @required this.name,
      @required this.value});

  factory PlayerEvent.fromJson(Map<String, dynamic> json) {
    return PlayerEvent(
      type: PlayerEventType.fromJson(json['type'] as String),
      timestamp: Timestamp.fromJson(json['timestamp'] as num),
      name: json['name'] as String,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      'timestamp': timestamp.toJson(),
      'name': name,
      'value': value,
    };
  }
}
