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
          ConsoleMessage.fromJson(event.parameters['message']));

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
  final String url;

  /// Line number in the resource that generated this message (1-based).
  final int line;

  /// Column number in the resource that generated this message (1-based).
  final int column;

  ConsoleMessage(
      {@required this.source,
      @required this.level,
      @required this.text,
      this.url,
      this.line,
      this.column});

  factory ConsoleMessage.fromJson(Map<String, dynamic> json) {
    return ConsoleMessage(
      source: ConsoleMessageSource.fromJson(json['source']),
      level: ConsoleMessageLevel.fromJson(json['level']),
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

class ConsoleMessageSource {
  static const ConsoleMessageSource xml = ConsoleMessageSource._('xml');
  static const ConsoleMessageSource javascript =
      ConsoleMessageSource._('javascript');
  static const ConsoleMessageSource network = ConsoleMessageSource._('network');
  static const ConsoleMessageSource consoleApi =
      ConsoleMessageSource._('console-api');
  static const ConsoleMessageSource storage = ConsoleMessageSource._('storage');
  static const ConsoleMessageSource appcache =
      ConsoleMessageSource._('appcache');
  static const ConsoleMessageSource rendering =
      ConsoleMessageSource._('rendering');
  static const ConsoleMessageSource security =
      ConsoleMessageSource._('security');
  static const ConsoleMessageSource other = ConsoleMessageSource._('other');
  static const ConsoleMessageSource deprecation =
      ConsoleMessageSource._('deprecation');
  static const ConsoleMessageSource worker = ConsoleMessageSource._('worker');
  static const values = {
    'xml': xml,
    'javascript': javascript,
    'network': network,
    'console-api': consoleApi,
    'storage': storage,
    'appcache': appcache,
    'rendering': rendering,
    'security': security,
    'other': other,
    'deprecation': deprecation,
    'worker': worker,
  };

  final String value;

  const ConsoleMessageSource._(this.value);

  factory ConsoleMessageSource.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ConsoleMessageSource && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class ConsoleMessageLevel {
  static const ConsoleMessageLevel log = ConsoleMessageLevel._('log');
  static const ConsoleMessageLevel warning = ConsoleMessageLevel._('warning');
  static const ConsoleMessageLevel error = ConsoleMessageLevel._('error');
  static const ConsoleMessageLevel debug = ConsoleMessageLevel._('debug');
  static const ConsoleMessageLevel info = ConsoleMessageLevel._('info');
  static const values = {
    'log': log,
    'warning': warning,
    'error': error,
    'debug': debug,
    'info': info,
  };

  final String value;

  const ConsoleMessageLevel._(this.value);

  factory ConsoleMessageLevel.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ConsoleMessageLevel && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
