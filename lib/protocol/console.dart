import 'dart:async';
import '../src/connection.dart';

/// This domain is deprecated - use Runtime or Log instead.
@Deprecated('use Runtime or Log instead')
class ConsoleApi {
  final Client _client;

  ConsoleApi(this._client);

  /// Issued when new console message is added.
  Stream<ConsoleMessage> get onMessageAdded => _client.onEvent
      .where((event) => event.name == 'Console.messageAdded')
      .map(
        (event) => ConsoleMessage.fromJson(
          event.parameters['message'] as Map<String, dynamic>,
        ),
      );

  /// Does nothing.
  Future<void> clearMessages() async {
    await _client.send('Console.clearMessages');
  }

  /// Disables console domain, prevents further console messages from being reported to the client.
  Future<void> disable() async {
    await _client.send('Console.disable');
  }

  /// Enables console domain, sends the messages collected so far to the client by means of the
  /// `messageAdded` notification.
  Future<void> enable() async {
    await _client.send('Console.enable');
  }
}

/// Console message.
class ConsoleMessage {
  /// Message source.
  final ConsoleMessageSource source;

  /// Message severity.
  final ConsoleMessageLevel level;

  /// Message text.
  final String text;

  /// URL of the message origin.
  final String? url;

  /// Line number in the resource that generated this message (1-based).
  final int? line;

  /// Column number in the resource that generated this message (1-based).
  final int? column;

  ConsoleMessage({
    required this.source,
    required this.level,
    required this.text,
    this.url,
    this.line,
    this.column,
  });

  factory ConsoleMessage.fromJson(Map<String, dynamic> json) {
    return ConsoleMessage(
      source: ConsoleMessageSource.fromJson(json['source'] as String),
      level: ConsoleMessageLevel.fromJson(json['level'] as String),
      text: json['text'] as String,
      url: json.containsKey('url') ? json['url'] as String : null,
      line: json.containsKey('line') ? json['line'] as int : null,
      column: json.containsKey('column') ? json['column'] as int : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'level': level,
      'text': text,
      if (url != null) 'url': url,
      if (line != null) 'line': line,
      if (column != null) 'column': column,
    };
  }
}

enum ConsoleMessageSource {
  xml('xml'),
  javascript('javascript'),
  network('network'),
  consoleApi('console-api'),
  storage('storage'),
  appcache('appcache'),
  rendering('rendering'),
  security('security'),
  other('other'),
  deprecation('deprecation'),
  worker('worker');

  final String value;

  const ConsoleMessageSource(this.value);

  factory ConsoleMessageSource.fromJson(String value) =>
      ConsoleMessageSource.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum ConsoleMessageLevel {
  log('log'),
  warning('warning'),
  error('error'),
  debug('debug'),
  info('info');

  final String value;

  const ConsoleMessageLevel(this.value);

  factory ConsoleMessageLevel.fromJson(String value) =>
      ConsoleMessageLevel.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}
