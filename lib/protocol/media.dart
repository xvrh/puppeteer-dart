import 'dart:async';
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

  /// Send a list of any messages that need to be delivered.
  Stream<PlayerMessagesLoggedEvent> get onPlayerMessagesLogged =>
      _client.onEvent
          .where((event) => event.name == 'Media.playerMessagesLogged')
          .map((event) => PlayerMessagesLoggedEvent.fromJson(event.parameters));

  /// Send a list of any errors that need to be delivered.
  Stream<PlayerErrorsRaisedEvent> get onPlayerErrorsRaised => _client.onEvent
      .where((event) => event.name == 'Media.playerErrorsRaised')
      .map((event) => PlayerErrorsRaisedEvent.fromJson(event.parameters));

  /// Called whenever a player is created, or when a new agent joins and receives
  /// a list of active players. If an agent is restored, it will receive the full
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
      {required this.playerId, required this.properties});

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

  PlayerEventsAddedEvent({required this.playerId, required this.events});

  factory PlayerEventsAddedEvent.fromJson(Map<String, dynamic> json) {
    return PlayerEventsAddedEvent(
      playerId: PlayerId.fromJson(json['playerId'] as String),
      events: (json['events'] as List)
          .map((e) => PlayerEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PlayerMessagesLoggedEvent {
  final PlayerId playerId;

  final List<PlayerMessage> messages;

  PlayerMessagesLoggedEvent({required this.playerId, required this.messages});

  factory PlayerMessagesLoggedEvent.fromJson(Map<String, dynamic> json) {
    return PlayerMessagesLoggedEvent(
      playerId: PlayerId.fromJson(json['playerId'] as String),
      messages: (json['messages'] as List)
          .map((e) => PlayerMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PlayerErrorsRaisedEvent {
  final PlayerId playerId;

  final List<PlayerError> errors;

  PlayerErrorsRaisedEvent({required this.playerId, required this.errors});

  factory PlayerErrorsRaisedEvent.fromJson(Map<String, dynamic> json) {
    return PlayerErrorsRaisedEvent(
      playerId: PlayerId.fromJson(json['playerId'] as String),
      errors: (json['errors'] as List)
          .map((e) => PlayerError.fromJson(e as Map<String, dynamic>))
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

/// Have one type per entry in MediaLogRecord::Type
/// Corresponds to kMessage
class PlayerMessage {
  /// Keep in sync with MediaLogMessageLevel
  /// We are currently keeping the message level 'error' separate from the
  /// PlayerError type because right now they represent different things,
  /// this one being a DVLOG(ERROR) style log message that gets printed
  /// based on what log level is selected in the UI, and the other is a
  /// representation of a media::PipelineStatus object. Soon however we're
  /// going to be moving away from using PipelineStatus for errors and
  /// introducing a new error type which should hopefully let us integrate
  /// the error log level into the PlayerError type.
  final PlayerMessageLevel level;

  final String message;

  PlayerMessage({required this.level, required this.message});

  factory PlayerMessage.fromJson(Map<String, dynamic> json) {
    return PlayerMessage(
      level: PlayerMessageLevel.fromJson(json['level'] as String),
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'message': message,
    };
  }
}

class PlayerMessageLevel {
  static const error = PlayerMessageLevel._('error');
  static const warning = PlayerMessageLevel._('warning');
  static const info = PlayerMessageLevel._('info');
  static const debug = PlayerMessageLevel._('debug');
  static const values = {
    'error': error,
    'warning': warning,
    'info': info,
    'debug': debug,
  };

  final String value;

  const PlayerMessageLevel._(this.value);

  factory PlayerMessageLevel.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is PlayerMessageLevel && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Corresponds to kMediaPropertyChange
class PlayerProperty {
  final String name;

  final String value;

  PlayerProperty({required this.name, required this.value});

  factory PlayerProperty.fromJson(Map<String, dynamic> json) {
    return PlayerProperty(
      name: json['name'] as String,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}

/// Corresponds to kMediaEventTriggered
class PlayerEvent {
  final Timestamp timestamp;

  final String value;

  PlayerEvent({required this.timestamp, required this.value});

  factory PlayerEvent.fromJson(Map<String, dynamic> json) {
    return PlayerEvent(
      timestamp: Timestamp.fromJson(json['timestamp'] as num),
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toJson(),
      'value': value,
    };
  }
}

/// Corresponds to kMediaError
class PlayerError {
  final PlayerErrorType type;

  /// When this switches to using media::Status instead of PipelineStatus
  /// we can remove "errorCode" and replace it with the fields from
  /// a Status instance. This also seems like a duplicate of the error
  /// level enum - there is a todo bug to have that level removed and
  /// use this instead. (crbug.com/1068454)
  final String errorCode;

  PlayerError({required this.type, required this.errorCode});

  factory PlayerError.fromJson(Map<String, dynamic> json) {
    return PlayerError(
      type: PlayerErrorType.fromJson(json['type'] as String),
      errorCode: json['errorCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'errorCode': errorCode,
    };
  }
}

class PlayerErrorType {
  static const pipelineError = PlayerErrorType._('pipeline_error');
  static const mediaError = PlayerErrorType._('media_error');
  static const values = {
    'pipeline_error': pipelineError,
    'media_error': mediaError,
  };

  final String value;

  const PlayerErrorType._(this.value);

  factory PlayerErrorType.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is PlayerErrorType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
