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
  Stream<PlayerMessagesLoggedEvent> get onPlayerMessagesLogged => _client
      .onEvent
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
      .map(
        (event) => (event.parameters['players'] as List)
            .map((e) => PlayerId.fromJson(e as String))
            .toList(),
      );

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

  PlayerPropertiesChangedEvent({
    required this.playerId,
    required this.properties,
  });

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
extension type PlayerId(String value) {
  factory PlayerId.fromJson(String value) => PlayerId(value);

  String toJson() => value;
}

extension type Timestamp(num value) {
  factory Timestamp.fromJson(num value) => Timestamp(value);

  num toJson() => value;
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
    return {'level': level, 'message': message};
  }
}

enum PlayerMessageLevel {
  error('error'),
  warning('warning'),
  info('info'),
  debug('debug');

  final String value;

  const PlayerMessageLevel(this.value);

  factory PlayerMessageLevel.fromJson(String value) =>
      PlayerMessageLevel.values.firstWhere((e) => e.value == value);

  String toJson() => value;

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
    return {'name': name, 'value': value};
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
    return {'timestamp': timestamp.toJson(), 'value': value};
  }
}

/// Represents logged source line numbers reported in an error.
/// NOTE: file and line are from chromium c++ implementation code, not js.
class PlayerErrorSourceLocation {
  final String file;

  final int line;

  PlayerErrorSourceLocation({required this.file, required this.line});

  factory PlayerErrorSourceLocation.fromJson(Map<String, dynamic> json) {
    return PlayerErrorSourceLocation(
      file: json['file'] as String,
      line: json['line'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'file': file, 'line': line};
  }
}

/// Corresponds to kMediaError
class PlayerError {
  final String errorType;

  /// Code is the numeric enum entry for a specific set of error codes, such
  /// as PipelineStatusCodes in media/base/pipeline_status.h
  final int code;

  /// A trace of where this error was caused / where it passed through.
  final List<PlayerErrorSourceLocation> stack;

  /// Errors potentially have a root cause error, ie, a DecoderError might be
  /// caused by an WindowsError
  final List<PlayerError> cause;

  /// Extra data attached to an error, such as an HRESULT, Video Codec, etc.
  final Map<String, dynamic> data;

  PlayerError({
    required this.errorType,
    required this.code,
    required this.stack,
    required this.cause,
    required this.data,
  });

  factory PlayerError.fromJson(Map<String, dynamic> json) {
    return PlayerError(
      errorType: json['errorType'] as String,
      code: json['code'] as int,
      stack: (json['stack'] as List)
          .map(
            (e) =>
                PlayerErrorSourceLocation.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      cause: (json['cause'] as List)
          .map((e) => PlayerError.fromJson(e as Map<String, dynamic>))
          .toList(),
      data: json['data'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'errorType': errorType,
      'code': code,
      'stack': stack.map((e) => e.toJson()).toList(),
      'cause': cause.map((e) => e.toJson()).toList(),
      'data': data,
    };
  }
}
