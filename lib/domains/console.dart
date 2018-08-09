import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';

/// This domain is deprecated - use Runtime or Log instead.
@deprecated
class ConsoleApi {
  final Client _client;

  ConsoleApi(this._client);

  /// Issued when new console message is added.
  Stream<ConsoleMessage> get onMessageAdded => _client.onEvent
      .where((Event event) => event.name == 'Console.messageAdded')
      .map((Event event) =>
          new ConsoleMessage.fromJson(event.parameters['message']));

  /// Does nothing.
  Future clearMessages() async {
    await _client.send('Console.clearMessages');
  }

  /// Disables console domain, prevents further console messages from being reported to the client.
  Future disable() async {
    await _client.send('Console.disable');
  }

  /// Enables console domain, sends the messages collected so far to the client by means of the
  /// `messageAdded` notification.
  Future enable() async {
    await _client.send('Console.enable');
  }
}

/// Console message.
class ConsoleMessage {
  /// Message source.
  final String source;

  /// Message severity.
  final String level;

  /// Message text.
  final String text;

  /// URL of the message origin.
  final String url;

  /// Line number in the resource that generated this message (1-based).
  final int line;

  /// Column number in the resource that generated this message (1-based).
  final int column;

  ConsoleMessage({
    @required this.source,
    @required this.level,
    @required this.text,
    this.url,
    this.line,
    this.column,
  });

  factory ConsoleMessage.fromJson(Map<String, dynamic> json) {
    return new ConsoleMessage(
      source: json['source'],
      level: json['level'],
      text: json['text'],
      url: json.containsKey('url') ? json['url'] : null,
      line: json.containsKey('line') ? json['line'] : null,
      column: json.containsKey('column') ? json['column'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'source': source,
      'level': level,
      'text': text,
    };
    if (url != null) {
      json['url'] = url;
    }
    if (line != null) {
      json['line'] = line;
    }
    if (column != null) {
      json['column'] = column;
    }
    return json;
  }
}
