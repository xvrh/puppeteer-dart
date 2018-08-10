import 'dart:convert';
import 'dart:io';
import 'model.dart';
import 'update_protocol.dart' show protocols;
import 'utils/split_words.dart';
import 'utils/string_helpers.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;

main() {
  Protocol readProtocol(String fileName) {
    return Protocol.fromString(
        File.fromUri(Platform.script.resolve(fileName)).readAsStringSync());
  }

  String libPath = Platform.script.resolve('../lib').toFilePath();

  Directory targetDir = Directory(p.join(libPath, 'domains'));
  if (targetDir.existsSync()) {
    targetDir.deleteSync(recursive: true);
  }
  targetDir.createSync();

  List<Domain> domains =
      protocols.keys.map(readProtocol).expand((f) => f.domains).toList();

  for (Domain domain in domains) {
    List<ComplexType> types = domain.types;
    List<Command> commandsJson = domain.commands;
    _DomainContext context = _DomainContext(domain);

    String fileName = '${_underscoreize(domain.name)}.dart';

    List<_InternalType> internalTypes =
        types.map((json) => _InternalType(context, json)).toList();

    List<_Command> commands =
        commandsJson.map((json) => _Command(context, json)).toList();

    List<_Event> events = domain.events.map((e) => _Event(context, e)).toList();

    StringBuffer code = StringBuffer();

    //TODO(xha): sort imports
    code.writeln("import 'dart:async';");
    if (context.needsMetaPackage) {
      code.writeln("import 'package:meta/meta.dart' show required;");
    }
    code.writeln("import '../src/connection.dart';");

    for (String dependency in context.dependencies) {
      String normalizedDep = _underscoreize(dependency);
      code.writeln("import '$normalizedDep.dart' as $normalizedDep;");
    }

    code.writeln();

    String className = '${domain.name}Api';
    code.writeln(toComment(domain.description));
    if (domain.deprecated) {
      code.writeln('@deprecated');
    }
    code.writeln('class $className {');
    code.writeln('final Client _client;');
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

    _writeDartFile(p.join(targetDir.path, fileName), code.toString());
  }

  StringBuffer tabBuffer = StringBuffer();

  List<Domain> tabDomains = domains
      .where((d) =>
          !d.deprecated &&
          !const ['Target', 'SystemInfo', 'Browser', 'IO', 'Audits']
              .contains(d.name))
      .toList();

  for (Domain domain in tabDomains) {
    tabBuffer
        .writeln("import '../domains/${_underscoreize(domain.name)}.dart';");
  }
  tabBuffer.writeln("import 'connection.dart';");
  tabBuffer.writeln();
  tabBuffer.writeln('''
abstract class TabMixin {
  Session get session;
''');

  for (Domain domain in tabDomains) {
    String camelizedName = firstLetterLower(splitWords(domain.name)
        .map((w) => firstLetterUpper(w.toLowerCase()))
        .join());

    tabBuffer.writeln(toComment(domain.description, indent: 2));
    tabBuffer.writeln('${domain.name}Api get $camelizedName =>  '
        '_$camelizedName ??= ${domain.name}Api(session);');
    tabBuffer.writeln('${domain.name}Api _$camelizedName;');
    tabBuffer.writeln('');
  }
  tabBuffer.writeln('}');

  _writeDartFile(
      p.join(libPath, 'src', 'tab_mixin.dart'), tabBuffer.toString());
}

final DartFormatter _dartFormatter =
    DartFormatter(lineEnding: Platform.isWindows ? '\r\n' : '\n');

_writeDartFile(String target, String code) {
  try {
    String formattedCode = _dartFormatter.format(code);

    File(target).writeAsStringSync(formattedCode);
  } catch (_) {
    print('Error with code\n$code');
    rethrow;
  }
}

_underscoreize(String input) {
  return splitWords(input).map((String part) => part.toLowerCase()).join('_');
}

class _Command {
  final _DomainContext context;
  final Command command;
  String _code;
  _InternalType _returnType;

  _Command(this.context, this.command) {
    String name = command.name;
    List<Parameter> parameters = command.parameters;
    List<Parameter> returns = command.returns;

    StringBuffer code = StringBuffer();

    //TODO(xha): create a CommentBuilder to simplify and better manage the spacings between groups.
    code.writeln(toComment(command.description, indent: 2));
    for (Parameter parameter in parameters.where((p) => !p.deprecated)) {
      String description = parameter.description;
      if (description != null && description.isNotEmpty) {
        code.writeln(toComment('[${parameter.name}] $description', indent: 2));
      }
    }
    if (returns.length == 1) {
      String description = returns[0].description;
      if (description != null && description.isNotEmpty) {
        code.writeln(toComment('Returns: $description', indent: 2));
      }
    }

    if (command.deprecated) {
      code.writeln('@deprecated');
    }

    String returnTypeName;
    if (returns.isNotEmpty) {
      if (returns.length == 1) {
        Parameter firstReturn = returns.first;
        returnTypeName = context.getPropertyType(firstReturn);
      } else {
        returnTypeName = '${firstLetterUpper(name)}Result';
        ComplexType returnJson =
            ComplexType(id: returnTypeName, properties: returns);
        _returnType = _InternalType(context, returnJson, generateToJson: false);
      }
    }

    code.writeln(
        'Future${returnTypeName != null ? '<$returnTypeName>' : ''} $name(');
    List<Parameter> optionals = parameters.where((p) => p.optional).toList();
    List<Parameter> requireds =
        parameters.where((p) => !optionals.contains(p)).toList();

    var requiredParametersCode = <String>[];
    for (Parameter parameter in requireds) {
      requiredParametersCode.add(
          '${parameter.deprecatedAttribute} ${context.getPropertyType(parameter)} ${parameter.normalizedName}');
    }
    code.writeln(requiredParametersCode.join(','));
    if (optionals.isNotEmpty) {
      var optionalParametersCode = optionals.map((p) =>
          '${p.deprecatedAttribute} ${context.getPropertyType(p)} ${p.normalizedName}');

      if (requiredParametersCode.isNotEmpty) {
        code.writeln(',');
      }
      code.writeln('{${optionalParametersCode.join(',')}}');
    }
    code.writeln(') async {');

    if (parameters.isNotEmpty) {
      code.writeln('var parameters = <String, dynamic>{');
      for (Parameter parameter in requireds) {
        code.writeln("'${parameter.name}' : ${_toJsonCode(parameter)},");
      }
      code.writeln('};');

      for (Parameter parameter in optionals) {
        if (parameter.deprecated) {
          //TODO(xha): it shouldn't be necessary: https://github.com/dart-lang/sdk/issues/30084
          code.writeln('    // ignore: deprecated_member_use');
        }
        code.writeln('if (${parameter.normalizedName} != null) {');
        if (parameter.deprecated) {
          //TODO(xha): it shouldn't be necessary: https://github.com/dart-lang/sdk/issues/30084
          code.writeln('      // ignore: deprecated_member_use');
        }
        code.writeln(
            "parameters['${parameter.name}'] = ${_toJsonCode(parameter)};");
        code.writeln('}');
      }
    }

    String sendCode = " await _client.send('${context.domain.name}.$name'";
    if (parameters.isNotEmpty) {
      sendCode += ', parameters';
    }
    sendCode += ');';

    if (returns.isNotEmpty) {
      sendCode = 'var result = $sendCode\n';
      if (returns.length == 1) {
        Parameter returnParameter = returns.first;
        if (isRawType(returnTypeName)) {
          sendCode += "return result['${returnParameter.name}'];";
        } else if (returnParameter.type == 'array') {
          Parameter elementParameter = Parameter(
              name: 'e',
              type: returnParameter.items.type,
              ref: returnParameter.items.ref);
          String paramType = context.getPropertyType(elementParameter);
          String mapCode;
          if (isRawType(paramType)) {
            mapCode = 'e as $paramType';
          } else {
            mapCode =
                '${context.getPropertyType(elementParameter)}.fromJson(e)';
          }

          sendCode +=
              "return (result['${returnParameter.name}'] as List).map((e) => $mapCode).toList();";
        } else {
          sendCode +=
              "return $returnTypeName.fromJson(result['${returnParameter.name}']);";
        }
      } else {
        sendCode += 'return $returnTypeName.fromJson(result);';
      }
    }

    code.writeln(sendCode);

    code.writeln('}');

    _code = code.toString();
  }

  String get code => _code;

  String get returnTypeCode => _returnType?.code;
}

class _Event {
  final _DomainContext context;
  final Event event;
  String _code;
  _InternalType _complexType;

  _Event(this.context, this.event) {
    String name = event.name;
    List<Parameter> parameters = event.parameters;

    StringBuffer code = StringBuffer();

    String streamTypeName;
    if (parameters.isNotEmpty) {
      if (parameters.length == 1) {
        Parameter firstReturn = parameters.first;
        streamTypeName = context.getPropertyType(firstReturn);
      } else {
        streamTypeName = '${firstLetterUpper(name)}Event';
        ComplexType returnJson =
            ComplexType(id: streamTypeName, properties: parameters);
        _complexType =
            _InternalType(context, returnJson, generateToJson: false);
      }
    }

    code.writeln(toComment(event.description, indent: 2));

    String streamName = 'on${firstLetterUpper(name)}';
    code.writeln(
        'Stream${streamTypeName != null ? '<$streamTypeName>' : ''} get $streamName => '
        "_client.onEvent.where((Event event) => event.name == '${context.domain.name}.$name')");

    if (parameters.isNotEmpty) {
      String mapCode;
      if (parameters.length == 1) {
        Parameter parameter = parameters.first;
        if (isRawType(streamTypeName)) {
          mapCode = "event.parameters['${parameter.name}'] as $streamTypeName";
        } else if (parameter.type == 'array') {
          Parameter elementParameter = Parameter(
              name: 'e', type: parameter.items.type, ref: parameter.items.ref);
          String paramType = context.getPropertyType(elementParameter);
          String insideCode;
          if (isRawType(paramType)) {
            insideCode = 'e as $paramType';
          } else {
            insideCode =
                '${context.getPropertyType(elementParameter)}.fromJson(e)';
          }

          mapCode =
              "(event.parameters['${parameter.name}'] as List).map((e) => $insideCode).toList()";
        } else {
          mapCode =
              "$streamTypeName.fromJson(event.parameters['${parameter.name}'])";
        }
      } else {
        mapCode = '$streamTypeName.fromJson(event.parameters)';
      }
      assert(mapCode != null);
      code.writeln('.map((Event event) => $mapCode)');
    }

    code.writeln(';');

    _code = code.toString();
  }

  String get code => _code;

  String get complexTypeCode => _complexType?.code;
}

String _toJsonCode(Parameter parameter) {
  String name = parameter.normalizedName;
  String type = parameter.type;

  if (type != null &&
      const ['string', 'boolean', 'number', 'integer', 'object']
          .contains(type)) {
    return name;
  } else if (type == 'array') {
    Parameter elementParameter = Parameter(
        name: 'e', type: parameter.items.type, ref: parameter.items.ref);
    return '$name.map((e) => ${_toJsonCode(elementParameter)}).toList()';
  }
  return '$name.toJson()';
}

class _InternalType {
  final _DomainContext context;
  final ComplexType type;
  final bool generateToJson;
  String _code;

  _InternalType(this.context, this.type, {this.generateToJson = true}) {
    String id = type.id;

    StringBuffer code = StringBuffer();

    code.writeln(toComment(type.description));
    code.writeln('class $id {');

    List<Parameter> properties = [];
    List<Parameter> jsonProperties = type.properties;
    bool hasProperties = jsonProperties.isNotEmpty;
    List<String> enumValues = type.enums;
    bool isEnum = false;
    if (hasProperties) {
      properties.addAll(jsonProperties);
    } else {
      properties
          .add(Parameter(name: 'value', type: type.type, items: type.items));

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

    for (Parameter property in properties.where((p) => !p.deprecated)) {
      code.writeln(toComment(property.description, indent: 2));
      code.writeln(
          'final ${context.getPropertyType(property)} ${property.normalizedName};');
      code.writeln('');
    }

    List<Parameter> optionals = properties.where((p) => p.optional).toList();
    List<Parameter> requireds =
        properties.where((p) => !optionals.contains(p)).toList();

    if (hasProperties) {
      var parametersCode = <String>[];
      for (Parameter property in properties.where((p) => !p.deprecated)) {
        bool isOptional = property.optional;
        parametersCode.add(
            '${isOptional ? '' : '@required '}this.${property.normalizedName}');
        if (!isOptional) {
          context.useMetaPackage();
        }
      }
      code.writeln('$id({${parametersCode.join(',')}});');
    } else if (isEnum) {
      code.writeln('const $id._(this.value);');
    } else {
      code.writeln('$id(this.value);');
    }

    code.writeln();
    if (hasProperties) {
      code.writeln('factory $id.fromJson(Map<String, dynamic> json) {');
      code.writeln('return $id(');
      for (Parameter property in properties.where((p) => !p.deprecated)) {
        String propertyName = property.name;
        String instantiateCode =
            _fromJsonCode(property, "json['$propertyName']");
        if (property.optional) {
          instantiateCode =
              "json.containsKey('$propertyName') ? $instantiateCode : null";
        }

        code.writeln("${property.normalizedName}:  $instantiateCode,");
      }
      code.writeln(');');
      code.writeln('}');
    } else if (isEnum) {
      code.writeln('factory $id.fromJson(String value) => values[value];');
    } else {
      code.writeln(
          'factory $id.fromJson(${context.getPropertyType(properties.first)} value) => $id(value);');
    }

    if (generateToJson) {
      code.writeln('');
      if (hasProperties) {
        code.writeln('Map<String, dynamic> toJson() {');
        code.writeln('var json = <String, dynamic>{');
        for (Parameter property in requireds) {
          code.writeln("'${property.name}': ${_toJsonCode(property)},");
        }
        code.writeln('};');
        for (Parameter property in optionals) {
          code.writeln('if (${property.normalizedName} != null) {');
          code.writeln("json['${property.name}'] = ${_toJsonCode(property)};");
          code.writeln('}');
        }
        code.writeln('return json;');
        code.writeln('}');
      } else {
        code.writeln(
            '${context.getPropertyType(properties.first)} toJson() => value;');
      }
    }

    if (!hasProperties && enumValues == null) {
      //TODO(xha): generate operator== and hashcode also for complex type?
      code.writeln();
      code.writeln('@override');
      code.writeln(
          'bool operator ==(other) => other is $id && other.value == value;');
      code.writeln();
      code.writeln('@override');
      code.writeln('int get hashCode => value.hashCode;');
    }

    if (!hasProperties) {
      code.writeln();
      code.writeln('@override');
      code.writeln('String toString() => value.toString();');
    }
    //TODO(xha): generate a readable toString() method for the complex type

    code.writeln('}');

    _code = code.toString();
  }

  static String _normalizeEnumValue(String input) {
    input = _sanitizeName(input);
    String normalizedValue = splitWords(input).map(firstLetterUpper).join('');
    normalizedValue = firstLetterLower(normalizedValue);
    normalizedValue = preventKeywords(normalizedValue);

    return normalizedValue;
  }

  String _fromJsonCode(Parameter parameter, String jsonParameter,
      {bool withAs = false}) {
    String type = parameter.type;

    if (type != null &&
        const ['string', 'boolean', 'number', 'integer', 'object', 'any']
            .contains(type)) {
      if (withAs) {
        return '$jsonParameter as ${context.getPropertyType(parameter)}';
      } else {
        return jsonParameter;
      }
    } else if (type == 'array') {
      Parameter elementParameter = Parameter(
          name: 'e', type: parameter.items.type, ref: parameter.items.ref);
      return "($jsonParameter as List).map((e) => ${_fromJsonCode(elementParameter, 'e', withAs: true)}).toList()";
    }
    return "${context.getPropertyType(parameter)}.fromJson($jsonParameter)";
  }

  String get code => _code;
}

class _DomainContext {
  final Domain domain;
  final Set<String> dependencies = Set();
  bool _useMetaPackage = false;

  _DomainContext(this.domain);

  String getPropertyType(Typed parameter) {
    String type = parameter.type;

    if (type == null) {
      type = parameter.ref;
      assert(type != null);

      if (type.contains('.')) {
        List<String> typeAndDomain = type.split('.');
        String domain = typeAndDomain[0];
        dependencies.add(domain);

        return '${_underscoreize(domain)}.${typeAndDomain[1]}';
      }
    }

    if (type == 'integer') return 'int';
    if (type == 'number') return 'num';
    if (type == 'string') return 'String';
    if (type == 'boolean') return 'bool';
    if (type == 'any') return 'dynamic';
    if (type == 'object') return 'Map';
    if (type == 'array') {
      if (parameter is Parameter) {
        ListItems items = parameter.items;
        String innerType = getPropertyType(items);

        return 'List<$innerType>';
      } else {
        assert(false);
      }
    }

    return type;
  }

  bool get needsMetaPackage => _useMetaPackage;
  useMetaPackage() {
    _useMetaPackage = true;
  }
}

bool isRawType(String type) =>
    const ['int', 'num', 'String', 'bool', 'dynamic', 'Map'].contains(type);

String toComment(String comment, {int indent = 0}) {
  if (comment != null && comment.isNotEmpty) {
    comment = comment.replaceAll('<code>', '`').replaceAll('</code>', '`');

    const String docStarter = '/// ';

    List<String> commentLines = LineSplitter.split(comment).toList();

    return commentLines
        .map((line) => '${' ' * indent}$docStarter$line')
        .join('\n');
  } else {
    return '';
  }
}

String _sanitizeName(String input) {
  if (input == '-0') {
    return 'negativeZero';
  } else if (input == '-Infinity') {
    return 'negativeInfinity';
  }
  return input;
}
