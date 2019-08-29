import 'dart:convert';

final _aliases = {
  'Request': 'RequestData',
  'Response': 'ResponseData',
  'Frame': 'FrameInfo',
  'AXNode': 'AXNodeData',
  'StackTrace': 'StackTraceData',
};

class Protocol {
  final List<Domain> domains;

  Protocol.fromJson(Map<String, dynamic> json)
      : domains =
            (json['domains'] as List).map((j) => Domain.fromJson(j as Map<String, dynamic>)).toList();

  factory Protocol.fromString(String protocol) =>
      Protocol.fromJson(jsonDecode(protocol) as Map<String, dynamic>);
}

class Domain {
  final String name;
  final String description;
  final List<ComplexType> types;
  final List<Command> commands;
  final List<Event> events;
  final bool deprecated;

  Domain.fromJson(Map json)
      : name = json['domain'] as String,
        description = json['description'] as String,
        types = json.containsKey('types')
            ? (json['types'] as List)
                .map((j) => ComplexType.fromJson(j as Map<String, dynamic>, json['domain'] as String))
                .toList()
            : const [],
        commands = json.containsKey('commands')
            ? (json['commands'] as List)
                .map((j) => Command.fromJson(j as Map<String, dynamic>))
                .toList()
            : const [],
        events = json.containsKey('events')
            ? (json['events'] as List).map((j) => Event.fromJson(j as Map<String, dynamic>)).toList()
            : const [],
        deprecated = json['deprecated'] as bool ?? false;
}

class ComplexType {
  final String id;
  final String rawId;
  final String description;
  final String type;
  final List<Parameter> properties;
  final List<String> enums;
  final ListItems items;

  ComplexType(
      {String id,
      this.properties = const [],
      this.description,
      this.type,
      this.enums,
      this.items})
      : id = _aliases[id] ?? id,
        rawId = id;

  ComplexType.fromJson(Map json, String domain)
      : id = _aliases[json['id']] ?? json['id'],
        rawId = json['id'],
        description = json['description'],
        type = json['type'],
        properties = json.containsKey('properties')
            ? (json['properties'] as List)
                .map((j) => Parameter.fromJson(j))
                .toList()
            : const [],
        enums = (json['enum'] as List)?.cast<String>(),
        items = json.containsKey('items')
            ? ListItems.fromJson(json['items'])
            : null;
}

class Command {
  final String name;
  final String description;
  final List<Parameter> parameters;
  final List<Parameter> returns;
  final bool deprecated;

  Command.fromJson(Map json)
      : name = json['name'],
        description = json['description'],
        deprecated = json['deprecated'] ?? false,
        parameters = json.containsKey('parameters')
            ? (json['parameters'] as List)
                .map((j) => Parameter.fromJson(j))
                .toList()
            : const [],
        returns = json.containsKey('returns')
            ? (json['returns'] as List)
                .map((j) => Parameter.fromJson(j))
                .toList()
            : const [];
}

class Event {
  final String name;
  final String description;
  final List<Parameter> parameters;

  Event.fromJson(Map json)
      : name = json['name'],
        description = json['description'],
        parameters = json.containsKey('parameters')
            ? (json['parameters'] as List)
                .map((j) => Parameter.fromJson(j))
                .toList()
            : const [];
}

String _ref(String ref) {
  if (ref == null) return null;

  var alias = _aliases[ref];
  if (alias != null) {
    return alias;
  } else {
    if (ref.contains('.')) {
      var splits = ref.split('.');
      var domain = splits.first;
      var singleRef = splits.last;

      var aliasedRef = _aliases[singleRef];
      if (aliasedRef != null) {
        return '$domain.$aliasedRef';
      }
    }

    return ref;
  }
}

class Parameter implements Typed {
  final String name;
  final String description;
  final bool optional;
  final bool deprecated;
  final ListItems items;
  final List<String> enumValues;

  @override
  final String type;

  @override
  final String ref;

  Parameter(
      {this.name,
      this.description,
      this.type,
      String ref,
      this.optional = false,
      this.deprecated = false,
      this.items,
      this.enumValues})
      : ref = _ref(ref);

  Parameter.fromJson(Map json)
      : name = json['name'],
        description = json['description'],
        type = json['type'],
        ref = _ref(json[r'$ref']),
        optional = json['optional'] ?? false,
        deprecated = json['deprecated'] ?? false,
        items = json.containsKey('items')
            ? ListItems.fromJson(json['items'])
            : null,
        enumValues = json.containsKey('enum')
            ? (json['enum'] as List).cast<String>()
            : null;

  String get normalizedName => preventKeywords(name);

  String get deprecatedAttribute => deprecated ? '@deprecated' : '';
}

class ListItems implements Typed {
  @override
  final String type;

  @override
  final String ref;

  ListItems.fromJson(Map<String, dynamic> json)
      : type = json['type'] as String,
        ref = _ref(json[r'$ref'] as String);
}

abstract class Typed {
  String get type;
  String get ref;
}

const Set<String> _dartKeywords = {
  'abstract', 'deferred', 'if', 'super',
  'as', 'do', 'implements', 'switch',
  'assert', 'dynamic', 'import', 'sync',
  'async', 'else', 'in', 'this',
  'enum', 'is', 'throw',
  'await', 'export', 'library', 'true',
  'break', 'external', 'new', 'try',
  'case', 'extends', 'null', 'typedef',
  'catch', 'factory', 'operator', 'var',
  'class', 'false', 'part', 'void',
  'const', 'final', 'rethrow', 'while',
  'continue', 'finally', 'return', 'with',
  'covariant', 'for', 'yield',
  'default', 'static' //
};

String preventKeywords(String input) {
  if (_dartKeywords.contains(input)) {
    return '$input\$';
  } else {
    return input;
  }
}
