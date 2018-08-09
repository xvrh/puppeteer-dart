import 'dart:convert';

class Protocol {
  final List<Domain> domains;

  Protocol.fromJson(Map json)
      : domains = (json['domains'] as List)
            .map((j) => new Domain.fromJson(j))
            .toList();

  factory Protocol.fromString(String protocol) =>
      new Protocol.fromJson(JSON.decode(protocol));
}

class Domain {
  final String name;
  final String description;
  final List<ComplexType> types;
  final List<Command> commands;
  final List<Event> events;
  final bool deprecated;

  Domain.fromJson(Map json)
      : name = json['domain'],
        description = json['description'],
        types = json.containsKey('types')
            ? (json['types'] as List)
                .map((j) => new ComplexType.fromJson(j))
                .toList()
            : const [],
        commands = json.containsKey('commands')
            ? (json['commands'] as List)
                .map((j) => new Command.fromJson(j))
                .toList()
            : const [],
        events = json.containsKey('events')
            ? (json['events'] as List)
                .map((j) => new Event.fromJson(j))
                .toList()
            : const [],
        deprecated = json['deprecated'] ?? false;
}

class ComplexType {
  final String id;
  final String description;
  final String type;
  final List<Parameter> properties;
  final List<String> enums;
  final ListItems items;

  ComplexType(
      {this.id,
      this.properties: const [],
      this.description,
      this.type,
      this.enums,
      this.items});

  ComplexType.fromJson(Map json)
      : id = json['id'],
        description = json['description'],
        type = json['type'],
        properties = json.containsKey('properties')
            ? (json['properties'] as List)
                .map((j) => new Parameter.fromJson(j))
                .toList()
            : const [],
        enums = json['enum'],
        items = json.containsKey('items')
            ? new ListItems.fromJson(json['items'])
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
                .map((j) => new Parameter.fromJson(j))
                .toList()
            : const [],
        returns = json.containsKey('returns')
            ? (json['returns'] as List)
                .map((j) => new Parameter.fromJson(j))
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
                .map((j) => new Parameter.fromJson(j))
                .toList()
            : const [];
}

class Parameter implements Typed {
  final String name;
  final String description;
  final bool optional;
  final bool deprecated;
  final ListItems items;

  @override
  final String type;

  @override
  final String ref;

  Parameter(
      {this.name,
      this.description,
      this.type,
      this.ref,
      this.optional: false,
      this.deprecated: false,
      this.items});

  Parameter.fromJson(Map json)
      : name = json['name'],
        description = json['description'],
        type = json['type'],
        ref = json[r'$ref'],
        optional = json['optional'] ?? false,
        deprecated = json['deprecated'] ?? false,
        items = json.containsKey('items')
            ? new ListItems.fromJson(json['items'])
            : null;

  String get normalizedName => preventKeywords(name);

  String get deprecatedAttribute => deprecated ? '@deprecated' : '';
}

class ListItems implements Typed {
  @override
  final String type;

  @override
  final String ref;

  ListItems.fromJson(Map json)
      : type = json['type'],
        ref = json[r'$ref'];
}

abstract class Typed {
  String get type;
  String get ref;
}

String preventKeywords(String input) {
  if (const ['new', 'default', 'continue', 'this'].contains(input)) {
    return '$input\$';
  } else {
    return input;
  }
}
