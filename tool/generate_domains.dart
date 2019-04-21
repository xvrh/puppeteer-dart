import 'dart:convert';
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;

import 'download_protocol_from_repo.dart' as protocols_from_repo;
import 'model.dart';
import 'utils/split_words.dart';
import 'utils/string_helpers.dart';

Protocol _readProtocol(String fileName) {
  return Protocol.fromString(
      File.fromUri(Platform.script.resolve(p.posix.join('json', fileName)))
          .readAsStringSync());
}

const _useFromChrome = false;
const protocolFromChromeFile = 'protocol_from_chrome.json';

main() {
  List<String> protocolFiles;
  if (_useFromChrome) {
    protocolFiles = [protocolFromChromeFile];
  } else {
    protocolFiles = protocols_from_repo.protocols.keys.toList();
  }

  String libPath = Platform.script.resolve('../lib').toFilePath();

  Directory targetDir = Directory(p.join(libPath, 'protocol'));
  if (targetDir.existsSync()) {
    targetDir.deleteSync(recursive: true);
  }
  targetDir.createSync();

  List<Domain> domains =
      protocolFiles.map(_readProtocol).expand((f) => f.domains).toList();

  for (Domain domain in domains) {
    List<ComplexType> types = domain.types;
    List<Command> commandsJson = domain.commands;
    _DomainContext context = _DomainContext(domain);

    String fileName = '${_underscoreize(domain.name)}.dart';

    List<_InternalType> internalTypes = [];
    for (var type in types) {
      internalTypes.add(_InternalType(context, type));
      internalTypes.addAll(type.properties
          .where((p) => p.enumValues != null)
          .map((p) => _InternalType(
              context,
              ComplexType(
                  id: type.id + firstLetterUpper(p.name),
                  type: p.type,
                  enums: p.enumValues))));
    }

    List<_Command> commands =
        commandsJson.map((json) => _Command(context, json)).toList();

    List<_Event> events = [];
    for (var event in domain.events) {
      _Event eventType = _Event(context, event);
      events.add(eventType);
      internalTypes.addAll(event.parameters
          .where((p) => p.enumValues != null)
          .map((p) => _InternalType(
              context,
              ComplexType(
                  id: eventType._typeName + firstLetterUpper(p.name),
                  type: p.type,
                  enums: p.enumValues))));
    }

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

  List<Domain> tabDomains = domains.where((d) => !d.deprecated).toList();

  for (Domain domain in tabDomains) {
    tabBuffer.writeln("import '${_underscoreize(domain.name)}.dart';");
  }
  tabBuffer.writeln("import '../src/connection.dart';");
  tabBuffer.writeln();
  tabBuffer.writeln('''
class DevTools {
  final Client client;
  
  DevTools(this.client);
''');

  for (Domain domain in tabDomains) {
    String camelizedName = firstLetterLower(_camelizeName(domain.name));

    tabBuffer.writeln(toComment(domain.description, indent: 2));
    tabBuffer.writeln('${domain.name}Api get $camelizedName =>  '
        '_$camelizedName ??= ${domain.name}Api(client);');
    tabBuffer.writeln('${domain.name}Api _$camelizedName;');
    tabBuffer.writeln('');
  }
  tabBuffer.writeln('}');

  _writeDartFile(
      p.join(libPath, 'protocol', 'dev_tools.dart'), tabBuffer.toString());
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

String _underscoreize(String input) {
  return splitWords(input).map((String part) => part.toLowerCase()).join('_');
}

String _camelizeName(String input) {
  return splitWords(input).map((w) => firstLetterUpper(w.toLowerCase())).join();
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
        'Future${returnTypeName != null ? '<$returnTypeName>' : '<void>'} $name(');
    List<Parameter> optionals = parameters.where((p) => p.optional).toList();
    List<Parameter> requireds =
        parameters.where((p) => !optionals.contains(p)).toList();

    String enumList(List<String> enumValues) =>
        '[' + enumValues.map((e) => "'$e'").join(', ') + ']';

    String toParameter(Parameter parameter) {
      String enumAttribute = '';
      if (parameter.enumValues != null) {
        enumAttribute = '@Enum(${enumList(parameter.enumValues)})';
      }

      return '$enumAttribute ${parameter.deprecatedAttribute} ${context.getPropertyType(parameter)} ${parameter.normalizedName}';
    }

    var requiredParametersCode = <String>[];
    for (Parameter parameter in requireds) {
      requiredParametersCode.add(toParameter(parameter));
    }
    code.writeln(requiredParametersCode.join(','));
    if (optionals.isNotEmpty) {
      var optionalParametersCode = optionals.map(toParameter);

      if (requiredParametersCode.isNotEmpty) {
        code.writeln(',');
      }
      code.writeln('{${optionalParametersCode.join(',')}}');
    }
    code.writeln(') async {');

    for (var parameter in parameters) {
      if (parameter.enumValues != null) {
        String optionalCode =
            parameter.optional ? '${parameter.normalizedName} == null || ' : '';
        code.writeln(
            'assert($optionalCode const ${enumList(parameter.enumValues)}.contains(${parameter.normalizedName}));');
      }
    }

    if (parameters.isNotEmpty) {
      code.writeln('var parameters = <String, dynamic>{');
      for (Parameter parameter in requireds) {
        code.writeln("'${parameter.name}' : ${_toJsonCode(parameter)},");
      }
      code.writeln('};');

      for (Parameter parameter in optionals) {
        code.writeln('if (${parameter.normalizedName} != null) {');
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
  String _typeName;

  _Event(this.context, this.event) {
    String name = event.name;
    List<Parameter> parameters = event.parameters;

    StringBuffer code = StringBuffer();

    if (parameters.isNotEmpty) {
      if (parameters.length == 1) {
        Parameter firstReturn = parameters.first;
        _typeName = context.getPropertyType(firstReturn);
      } else {
        _typeName = '${firstLetterUpper(name)}Event';
        ComplexType returnJson =
            ComplexType(id: _typeName, properties: parameters);
        _complexType =
            _InternalType(context, returnJson, generateToJson: false);
      }
    }

    code.writeln(toComment(event.description, indent: 2));

    String streamName = 'on${firstLetterUpper(name)}';
    code.writeln(
        'Stream${_typeName != null ? '<$_typeName>' : ''} get $streamName => '
        "_client.onEvent.where((Event event) => event.name == '${context.domain.name}.$name')");

    if (parameters.isNotEmpty) {
      String mapCode;
      if (parameters.length == 1) {
        Parameter parameter = parameters.first;
        if (isRawType(_typeName)) {
          mapCode = "event.parameters['${parameter.name}'] as $_typeName";
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
              "$_typeName.fromJson(event.parameters['${parameter.name}'])";
        }
      } else {
        mapCode = '$_typeName.fromJson(event.parameters)';
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

const List<String> jsonTypes = [
  'string',
  'boolean',
  'number',
  'integer',
  'object',
  'any'
];

String _toJsonCode(Parameter parameter) {
  String name = parameter.normalizedName;
  String type = parameter.type;

  if (type != null && jsonTypes.contains(type)) {
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
              "static const $id $normalizedValue = $id._('$enumValue');");
        }

        code.writeln('static const values = {');
        for (String enumValue in enumValues) {
          String normalizedValue = _normalizeEnumValue(enumValue);
          code.writeln("'$enumValue': $normalizedValue,");
        }
        code.writeln('};');
      }
    }

    for (Parameter property in properties.where((p) => !p.deprecated)) {
      code.writeln(toComment(property.description, indent: 2));

      String typeName = _propertyTypeName(property);
      code.writeln('final $typeName ${property.normalizedName};');
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
      Parameter singleParameter = properties.single;
      if (context.isList(singleParameter)) {
        code.writeln(
            'factory $id.fromJson(List<dynamic> value) => $id(${context.getPropertyType(singleParameter)}.from(value));');
      } else {
        code.writeln(
            'factory $id.fromJson(${context.getPropertyType(singleParameter)} value) => $id(value);');
      }
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

    if (!hasProperties) {
      //TODO(xha): generate operator== and hashcode also for complex type?
      code.writeln();
      code.writeln('@override');
      code.writeln(
          'bool operator ==(other) => (other is $id && other.value == value) || value == other;');
      code.writeln();
      code.writeln('@override');
      code.writeln('int get hashCode => value.hashCode;');
      code.writeln();

      //TODO(xha): generate a readable toString() method for the complex type
      code.writeln('@override');
      code.writeln('String toString() => value.toString();');
    }

    code.writeln('}');

    _code = code.toString();
  }

  String _propertyTypeName(Parameter property) {
    if (property.enumValues != null) {
      return type.id + firstLetterUpper(property.name);
    } else {
      return context.getPropertyType(property);
    }
  }

  static String _normalizeEnumValue(String input) {
    input = _sanitizeName(input);
    String normalizedValue = firstLetterLower(_camelizeName(input));
    normalizedValue = preventKeywords(normalizedValue);

    return normalizedValue;
  }

  String _fromJsonCode(Parameter parameter, String jsonParameter,
      {bool withAs = false}) {
    String type = parameter.type;

    if (type != null &&
        jsonTypes.contains(type) &&
        parameter.enumValues == null) {
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
    String typeName = _propertyTypeName(parameter);
    return "$typeName.fromJson($jsonParameter)";
  }

  String get code => _code;
}

class _DomainContext {
  final Domain domain;
  final Set<String> dependencies = {};
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

  bool isList(Typed parameter) => parameter.type == 'array';

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
