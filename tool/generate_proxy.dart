import 'dart:convert';
import 'dart:io';

import 'utils/split_words.dart';
import 'utils/string_helpers.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;

final DartFormatter _dartFormatter =
    new DartFormatter(lineEnding: Platform.isWindows ? '\r\n' : '\n');

// TODO(xha): lundi
//  - script pour updater automatiquement le protocol (inspector & v8) (garder 2 fichiers distincts)
//  - lire les 2 fichiers dans ce script
//  - Terminer génération de code pour le fromJson
//  - Terminer génération de code pour les events: (close, _onEvent() => dispatch).
//  - Reprendre le code pour lancer chrome, se connecter en WebSocket.
//  - Binder l'envoie et la lecture du JSON pour forwarder au bonnes targets.
//  - Faire quelques tests avec chrome normal pour l'impression PDF
// Autres idées où ça peut servir:
//  - remplacer le webdriver pour les tests
//  - faire une capture d'écran d'un élément html (exemple, un label)
//  -
main() {
  // Generate Dart classes for the protocol defined here:
  // https://chromium.googlesource.com/chromium/src/+/master/third_party/WebKit/Source/core/inspector/browser_protocol.json
  //https://github.com/cyrus-and/chrome-remote-interface

  File jsonFile =
      new File.fromUri(Platform.script.resolve('b2.json'));

  //TODO(xha): use an intermediate model instead of raw json.
  Map json = JSON.decode(jsonFile.readAsStringSync());

  Directory targetDir = new Directory.fromUri(
      Platform.script.resolve('../lib/src/browser_protocol'));
  if (targetDir.existsSync()) {
    targetDir.deleteSync(recursive: true);
  }
  targetDir.createSync();

  List domains = json['domains'];

  for (Map domain in domains) {
    String domainName = domain['domain'];
    List types = domain['types'] ?? const [];
    List commandsJson = domain['commands'] ?? const [];
    List eventsJson = domain['events'] ?? const [];

    String fileName = '${_underscoreize(domainName)}.dart';

    List<_InternalType> internalTypes =
        types.map((json) => new _InternalType(json)).toList();

    List<_Command> commands =
        commandsJson.map((json) => new _Command(domainName, json)).toList();

    List<_Event> events =
        eventsJson.map((json) => new _Event(domainName, json)).toList();

    StringBuffer code = new StringBuffer();

    code.writeln(_toComment(domain['description']));
    code.writeln();

    //TODO(xha): sort imports
    code.writeln("import 'dart:async';");
    code.writeln("import 'package:meta/meta.dart' show required;");
    code.writeln("import '../connection.dart';");

    Set<String> dependencies = new Set<String>();
    dependencies.addAll(internalTypes.expand((i) => i.dependencies));
    dependencies.addAll(commands.expand((c) => c.dependencies));
    dependencies.addAll(events.expand((c) => c.dependencies));

    for (String dependency in dependencies) {
      String normalizedDep = _underscoreize(dependency);
      String prefix = '';
      if (const ['Runtime', 'Debugger'].contains(dependency)) {
        prefix = '../';
      }
      code.writeln("import '$prefix$normalizedDep.dart' as $normalizedDep;");
    }

    String className = '${domainName}Manager';
    code.writeln('class $className {');
    code.writeln('final Session _client;');
    code.writeln();
    code.writeln('$className(this._client);');
    code.writeln();

    for (_Event event in events) {
      code.writeln(event.code);
      code.writeln();
    }

    for (_Command command in commands) {
      code.writeln(command.code);
    }

    code.writeln('}');

    for (_Event event in events.where((c) => c.complexTypeCode != null)) {
      code.writeln(event.complexTypeCode);
    }

    for (_Command command in commands.where((c) => c.returnTypeCode != null)) {
      code.writeln(command.returnTypeCode);
    }

    for (_InternalType type in internalTypes) {
      code.writeln(type.code);
    }

    try {
      String formattedCode = _dartFormatter.format(code.toString());

      new File(p.join(targetDir.path, fileName))
          .writeAsStringSync(formattedCode);
    } catch (_) {
      print('Error with code\n$code');
      rethrow;
    }
  }
}

_underscoreize(String input) {
  return splitWords(input).map((String part) => part.toLowerCase()).join('_');
}

class _Command extends _PropertyBag {
  final String domain;
  final Map json;
  String _code;
  _InternalType _returnType;

  _Command(this.domain, this.json) {
    String name = json['name'];
    List parameters = json['parameters'] ?? const [];
    List returns = json['returns'];

    StringBuffer code = new StringBuffer();

    //TODO(xha): create a CommentBuilder to simplify and better manage the spacings between groups.
    code.writeln(_toComment(json['description']));
    for (Map parameter in parameters) {
      String description = parameter['description'];
      if (description != null && description.isNotEmpty) {
        code.writeln(_toComment('[${parameter['name']}] $description'));
      }
    }
    if (returns != null && returns.length == 1) {
      String description = returns[0]['description'];
      if (description != null && description.isNotEmpty) {
        code.writeln(_toComment('Return: ${description}'));
      }
    }

    String returnTypeName;
    if (returns != null && returns.isNotEmpty) {
      if (returns.length == 1) {
        Map firstReturn = returns.first;
        returnTypeName = _getPropertyType(firstReturn);
      } else {
        returnTypeName = '${firstLetterUpper(name)}Result';
        Map returnJson = {'id': returnTypeName};
        returnJson['properties'] = returns;
        _returnType = new _InternalType(returnJson, generateToJson: false);
        dependencies.addAll(_returnType.dependencies);
      }
    }

    code.writeln(
        'Future${returnTypeName != null ? '<$returnTypeName>':''} $name(');
    List optionals = parameters.where((p) => p['optional'] == true).toList();
    List requireds = parameters.where((p) => !optionals.contains(p)).toList();

    for (Map parameter in requireds) {
      code.writeln('${_getPropertyType(parameter)} ${parameter['name']}, ');
    }
    if (optionals.isNotEmpty) {
      code.writeln('{');
      for (Map parameter in optionals) {
        code.writeln('${_getPropertyType(parameter)} ${parameter['name']}, ');
      }
      code.writeln('}');
    }
    code.writeln(') async {');

    if (parameters.isNotEmpty) {
      code.writeln('Map parameters = {');
      for (Map parameter in requireds) {
        code.writeln("'${parameter['name']}' : ${_toJsonCode(parameter)},");
      }
      code.writeln('};');

      for (Map parameter in optionals) {
        code.writeln('if (${parameter['name']} != null) {');
        code.writeln(
            "parameters['${parameter['name']}'] = ${_toJsonCode(parameter)};");
        code.writeln('}');
      }
    }

    code.writeln(" await _client.send('$domain.$name'");
    if (parameters.isNotEmpty) {
      code.writeln(', parameters');
    }

    code.writeln(');');
    code.writeln('}');

    _code = code.toString();
  }

  String get code => _code;

  String get returnTypeCode => _returnType?.code;
}

class _Event extends _PropertyBag {
  final String domain;
  final Map json;
  String _code;
  _InternalType _complexType;

  _Event(this.domain, this.json) {
    String name = json['name'];
    List parameters = json['parameters'] ?? const [];

    StringBuffer code = new StringBuffer();

    String streamTypeName;
    if (parameters != null && parameters.isNotEmpty) {
      if (parameters.length == 1) {
        Map firstReturn = parameters.first;
        streamTypeName = _getPropertyType(firstReturn);
      } else {
        streamTypeName = '${firstLetterUpper(name)}Result';
        Map returnJson = {'id': streamTypeName};
        returnJson['properties'] = parameters;
        _complexType = new _InternalType(returnJson, generateToJson: false);
        dependencies.addAll(_complexType.dependencies);
      }
    }

    code.writeln(
        'final StreamController${streamTypeName != null ? '<$streamTypeName>':''} _$name '
        '= new StreamController${streamTypeName != null ? '<$streamTypeName>':''}.broadcast();');

    //TODO(xha): create a CommentBuilder to simplify and better manage the spacings between groups.
    code.writeln(_toComment(json['description']));

    String streamName = 'on${firstLetterUpper(name)}';
    code.writeln(
        'Stream${streamTypeName != null ? '<$streamTypeName>':''} get $streamName => _$name.stream;');

    _code = code.toString();
  }

  String get code => _code;

  String get complexTypeCode => _complexType?.code;
}

String _toJsonCode(Map parameter) {
  String name = parameter['name'];
  String type = parameter['type'];

  if (type != null &&
      const ['string', 'boolean', 'number', 'integer', 'object']
          .contains(type)) {
    return name;
  } else if (type == 'array') {
    Map elementParameter = {'name': 'e'};
    elementParameter.addAll(parameter['items']);
    return '$name.map((e) => ${_toJsonCode(elementParameter)}).toList()';
  }
  return '$name.toJson()';
}

class _InternalType extends _PropertyBag {
  final Set<String> dependencies = new Set();
  final Map json;
  final bool generateToJson;
  String _code;

  _InternalType(this.json, {this.generateToJson: true}) {
    String id = json['id'];
    String type = json['type'];

    StringBuffer code = new StringBuffer();

    code.writeln(_toComment(json['description']));
    code.writeln('class $id {');

    List properties = [];
    List jsonProperties = json['properties'];
    bool hasProperties = jsonProperties != null;
    List<String> enumValues = json['enum'];
    bool isEnum = false;
    if (hasProperties) {
      properties.addAll(jsonProperties);
    } else {
      properties.add({'name': 'value', 'type': type, 'items': json['items']});

      if (enumValues != null) {
        isEnum = true;
        for (String enumValue in enumValues) {
          String normalizedValue = _normalizeEnumValue(enumValue);

          code.writeln(
              "static const $id $normalizedValue = const $id._('$enumValue');");
        }

        code.writeln('static const values = const {');
        for (String enumValue in enumValues) {
          String normalizedValue = _normalizeEnumValue(enumValue);
          code.writeln("'$enumValue': $normalizedValue,");
        }
        code.writeln('};');
      }
    }

    for (Map property in properties) {
      code.writeln(_toComment(property['description']));
      code.writeln('final ${_getPropertyType(property)} ${property['name']};');
      code.writeln('');
    }

    List optionals = properties.where((p) => p['optional'] == true).toList();
    List requireds = properties.where((p) => !optionals.contains(p)).toList();

    if (hasProperties) {
      code.writeln('$id({');
      for (Map property in properties) {
        bool isOptional = property['optional'] == true;
        code.writeln(
            '${!isOptional ? '@required ' : ''}this.${property['name']},');
      }
      code.writeln('});');
    } else if (isEnum) {
      code.writeln('const $id._(this.value);');
    } else {
      code.writeln('$id(this.value);');
    }

    code.writeln();
    if (hasProperties) {
      code.writeln('factory $id.fromJson(Map json) {');
      code.writeln('return new $id(');
      for (Map property in properties) {
        String propertyName = property['name'];
        String instantiateCode =
            _fromJsonCode(property, "json['$propertyName']");
        if (property['optional'] == true) {
          instantiateCode =
              "json.containsKey('$propertyName') ? $instantiateCode : null";
        }

        code.writeln("$propertyName:  $instantiateCode,");
      }
      code.writeln(');');
      code.writeln('}');
    } else if (isEnum) {
      code.writeln('factory $id.fromJson(String value) => values[value];');
    } else {
      code.writeln(
          'factory $id.fromJson(${_getPropertyType(properties.first)} value) => new $id(value);');
    }

    //TODO(xha): il ne faut pas générer une méthode toJson pour les types qui sont
    // des types de retour.
    // Pour ça, avant de faire la génération, on parcour tous les parameters des commands
    // et tous les returns des commandes récursivement pour trouver les types.
    // On les catégorise ensuite en 2 groupes
    if (generateToJson) {
      code.writeln('');
      if (hasProperties) {
        code.writeln('Map toJson() {');
        code.writeln('Map json = {');
        for (Map property in requireds) {
          code.writeln("'${property['name']}': ${_toJsonCode(property)},");
        }
        code.writeln('};');
        for (Map property in optionals) {
          code.writeln('if (${property['name']} != null) {');
          code.writeln(
              "json['${property['name']}'] = ${_toJsonCode(property)};");
          code.writeln('}');
        }
        code.writeln('return json;');
        code.writeln('}');
      } else {
        code.writeln(
            '${_getPropertyType(properties.first)} toJson() => value;');
      }
    }

    code.writeln('}');

    _code = code.toString();
  }

  static String _normalizeEnumValue(String input) {
    String normalizedValue = splitWords(input).map(firstLetterUpper).join('');
    normalizedValue = firstLetterLower(normalizedValue);
    normalizedValue = _preventKeywords(normalizedValue);

    return normalizedValue;
  }

  String _fromJsonCode(Map parameter, String jsonParameter,
      {bool withAs: false}) {
    String type = parameter['type'];

    if (type != null &&
        const ['string', 'boolean', 'number', 'integer', 'object', 'any']
            .contains(type)) {
      if (withAs) {
        return '$jsonParameter as ${_getPropertyType(parameter)}';
      } else {
        return jsonParameter;
      }
    } else if (type == 'array') {
      Map elementParameter = {'name': 'e'};
      elementParameter.addAll(parameter['items']);
      return "($jsonParameter as List).map((e) => ${_fromJsonCode(elementParameter, 'e', withAs: true)}).toList()";
    }
    return "new ${_getPropertyType(parameter)}.fromJson($jsonParameter)";
  }

  String get code => _code;
}

class _PropertyBag {
  final Set<String> dependencies = new Set();

  String _getPropertyType(Map propertyJson) {
    String type = propertyJson['type'];

    if (type == null) {
      type = propertyJson[r'$ref'];
      assert(type != null);

      if (type.contains('.')) {
        List typeAndDomain = type.split('.');
        String domain = typeAndDomain[0];
        dependencies.add(domain);

        return '${_underscoreize(domain)}.${typeAndDomain[1]}';
      }
    }

    if (type == 'integer') return 'int';
    if (type == 'number') return 'num';
    if (type == 'string') return 'String';
    if (type == 'boolean') return 'bool';
    if (type == 'array') {
      Map items = propertyJson['items'];
      String innerType = _getPropertyType(items);

      return 'List<$innerType>';
    }
    if (type == 'any') return 'dynamic';
    if (type == 'object') return 'Map';
    return type;
  }
}

String _toComment(String comment) {
  if (comment != null && comment.isNotEmpty) {
    //TODO(xha): handle multi-lines comments and auto-split after 80 characters
    return '/// $comment';
  } else {
    return '';
  }
}

String _preventKeywords(String input) {
  if (const ['new', 'default', 'continue'].contains(input)) {
    return '$input\$';
  } else if (input == '0') {
return 'zero';
  } else if (input == '-Infinity') {
    return 'minusInfinity';
  }else


    return input;
  }

