import 'dart:convert';
import 'dart:io';

import 'package:puppeteer_dart/utils/split_words.dart';
import 'package:puppeteer_dart/utils/string_helpers.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;

final DartFormatter _dartFormatter =
    new DartFormatter(lineEnding: Platform.isWindows ? '\r\n' : '\n');

main() {
  // Generate Dart classes for the protocol defined here:
  // https://chromium.googlesource.com/chromium/src/+/master/third_party/WebKit/Source/core/inspector/browser_protocol.json

  File jsonFile =
      new File.fromUri(Platform.script.resolve('browser_protocol.json'));
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

    String fileName = '${_underscoreize(domainName)}.dart';

    List<_InternalType> internalTypes =
        types.map((json) => new _InternalType(json)).toList();

    List<_Command> commands =
        commandsJson.map((json) => new _Command(domainName, json)).toList();

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

    for (_Command command in commands) {
      code.writeln(command.code);
    }

    code.writeln('}');

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

String _toJsonCode(Map parameter) {
  String name = parameter['name'];
  String type = parameter['type'];

  String method = 'toJson';
  if (type != null &&
      const ['string', 'boolean', 'number', 'integer'].contains(type)) {
    method = 'toString';
  } else if (type == 'array') {
    Map elementParameter = {'name': 'e'};
    elementParameter.addAll(parameter['items']);
    return '$name.map((e) => ${_toJsonCode(elementParameter)}).toList()';
  }
  return '$name.$method()';
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
    bool isEnum = false;
    if (hasProperties) {
      properties.addAll(jsonProperties);
    } else {
      properties.add({'name': 'value', 'type': type, 'items': json['items']});

      List<String> enumValues = json['enum'];
      if (enumValues != null) {
        isEnum = true;
        for (String enumValue in enumValues) {
          String normalizedValue =
              splitWords(enumValue).map(firstLetterUpper).join('');
          normalizedValue = firstLetterLower(normalizedValue);
          normalizedValue = _preventKeywords(normalizedValue);

          code.writeln(
              "static const $id $normalizedValue = const $id._('$enumValue');");
        }
      }
    }

    for (Map property in properties) {
      code.writeln(_toComment(property['description']));
      code.writeln('final ${_getPropertyType(property)} ${property['name']};');
      code.writeln('');
    }

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

    if (hasProperties) {
      code.writeln('factory $id.fromJson(Map json) {');

      code.writeln('}');
    } else if (isEnum) {
      code.writeln('factory $id.fromJson(String value) => const {}[value];');
    } else {
      code.writeln('factory $id.fromJson(${_getPropertyType(properties.first)} value) => new $id(value);');
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
        for (Map property in properties.where((p) => p['optional'] == null)) {
          code.writeln("'${property['name']}': ${_toJsonCode(property)},");
        }
        code.writeln('};');
        for (Map property in properties.where((p) => p['optional'] == true)) {
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
  } else {
    return input;
  }
}
