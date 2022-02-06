import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'code_style/fix_import_order.dart';
import 'download_protocol_from_repo.dart' as protocols_from_repo;
import 'model.dart';
import 'utils/escape_dart_string.dart';
import 'utils/split_words.dart';
import 'utils/string_helpers.dart';

Protocol _readProtocol(String fileName) {
  return Protocol.fromString(
      File.fromUri(Platform.script.resolve(p.posix.join('json', fileName)))
          .readAsStringSync());
}

const _useFromChrome = true;
const protocolFromChromeFile = 'protocol_from_chrome.json';

void main() {
  List<String> protocolFiles;
  if (_useFromChrome) {
    protocolFiles = [protocolFromChromeFile];
  } else {
    protocolFiles = protocols_from_repo.protocols.keys.toList();
  }

  var libPath = Platform.script.resolve('../lib').toFilePath();

  var targetDir = Directory(p.join(libPath, 'protocol'));
  if (targetDir.existsSync()) {
    targetDir.deleteSync(recursive: true);
  }
  targetDir.createSync();

  var domains =
      protocolFiles.map(_readProtocol).expand((f) => f.domains).toList();

  _applyTemporaryFixes(domains);

  for (var domain in domains) {
    var types = domain.types;
    var commandsJson = domain.commands;
    var context = _DomainContext(domain, domains);

    var fileName = '${_underscoreize(domain.name)}.dart';

    var internalTypes = <_InternalType>[];
    for (var type in types) {
      internalTypes.add(_InternalType(context, type));
      internalTypes.addAll(type.properties
          .where((p) => p.enumValues != null)
          .map((p) => _InternalType(
              context,
              ComplexType(
                  id: type.rawId + firstLetterUpper(p.name),
                  type: p.type!,
                  enums: p.enumValues))));
    }

    var commands = commandsJson.map((json) => _Command(context, json)).toList();

    var events = <_Event>[];
    for (var event in domain.events) {
      var eventType = _Event(context, event);
      events.add(eventType);
      internalTypes.addAll(event.parameters
          .where((p) => p.enumValues != null)
          .map((p) => _InternalType(
              context,
              ComplexType(
                  id: (eventType._typeName ?? '') + firstLetterUpper(p.name),
                  type: p.type!,
                  enums: p.enumValues))));
    }

    var code = StringBuffer();

    code.writeln("import 'dart:async';");
    code.writeln("import '../src/connection.dart';");

    for (var dependency in context.dependencies) {
      var normalizedDep = _underscoreize(dependency);
      code.writeln("import '$normalizedDep.dart' as $normalizedDep;");
    }

    code.writeln();

    var className = '${domain.name}Api';
    code.writeln(toComment(domain.description));
    if (domain.deprecated) {
      code.writeln(
          '@Deprecated(${escapeDartString(deprecatedDocumentation(domain.description) ?? 'This domain is deprecated')})');
    }
    code
      ..writeln('class $className {')
      ..writeln('final Client _client;')
      ..writeln()
      ..writeln('$className(this._client);')
      ..writeln();

    for (var event in events) {
      code.writeln(event.code);
      code.writeln();
    }

    for (var command in commands) {
      code.writeln(command.code);
    }

    code.writeln('}');

    for (var event in events.where((c) => c.complexTypeCode != null)) {
      code.writeln(event.complexTypeCode);
    }

    for (var command in commands.where((c) => c.returnTypeCode != null)) {
      code.writeln(command.returnTypeCode);
    }

    for (var type in internalTypes) {
      code.writeln(type.code);
    }

    var finalCode = code.toString().replaceAll('dynamic?', 'dynamic');

    _writeDartFile(p.join(targetDir.path, fileName), finalCode);
  }

  var tabBuffer = StringBuffer();

  var tabDomains = domains.where((d) => !d.deprecated).toList();

  for (var domain in tabDomains) {
    tabBuffer.writeln("import '${_underscoreize(domain.name)}.dart';");
  }
  tabBuffer.writeln("import '../src/connection.dart';");
  tabBuffer.writeln();
  tabBuffer.writeln('''
class DevTools {
  final Client client;
  
  DevTools(this.client);
''');

  for (var domain in tabDomains) {
    var camelizedName = firstLetterLower(_camelizeName(domain.name));

    tabBuffer.writeln(toComment(domain.description, indent: 2));
    tabBuffer.writeln('${domain.name}Api get $camelizedName =>  '
        '_$camelizedName ??= ${domain.name}Api(client);');
    tabBuffer.writeln('${domain.name}Api? _$camelizedName;');
    tabBuffer.writeln('');
  }
  tabBuffer.writeln('}');

  _writeDartFile(
      p.join(libPath, 'protocol', 'dev_tools.dart'), tabBuffer.toString());
}

void _writeDartFile(String target, String code) {
  try {
    var formattedCode = reorderImports(code);
    File(target).writeAsStringSync(formattedCode);
  } catch (e) {
    print('Error with code\n$code\n$e');
    rethrow;
  }
}

String _underscoreize(String input) {
  return splitWords(input).map((part) => part.toLowerCase()).join('_');
}

String _camelizeName(String input) {
  return splitWords(input).map((w) => firstLetterUpper(w.toLowerCase())).join();
}

class _Command {
  final _DomainContext context;
  final Command command;
  String? _code;
  _InternalType? _returnType;

  _Command(this.context, this.command) {
    var name = command.name;
    var parameters = command.parameters;
    var returns = command.returns;

    var code = StringBuffer();

    //TODO(xha): create a CommentBuilder to simplify and better manage the spacings between groups.
    code.writeln(toComment(command.description, indent: 2));
    for (var parameter in parameters.where((p) => !p.deprecated)) {
      var description = parameter.description;
      if (description != null && description.isNotEmpty) {
        code.writeln(toComment('[${parameter.name}] $description', indent: 2));
      }
    }
    if (returns.length == 1) {
      var description = returns[0].description;
      if (description != null && description.isNotEmpty) {
        code.writeln(toComment('Returns: $description', indent: 2));
      }
    }

    if (command.deprecated) {
      code.writeln(
          '@Deprecated(${escapeDartString(deprecatedDocumentation(command.description) ?? 'This command is deprecated')})');
    }

    String? returnTypeName;
    if (returns.isNotEmpty) {
      if (returns.length == 1) {
        var firstReturn = returns.first;
        returnTypeName = context.getPropertyType(firstReturn);
      } else {
        returnTypeName = '${firstLetterUpper(name)}Result';
        var returnJson = ComplexType(id: returnTypeName, properties: returns);
        _returnType = _InternalType(context, returnJson, generateToJson: false);
      }
    }

    code.writeln(
        'Future${returnTypeName != null ? '<$returnTypeName>' : '<void>'} $name(');
    var optionals = parameters.where((p) => p.optional).toList();
    var requireds = parameters.where((p) => !optionals.contains(p)).toList();

    String enumList(List<String> enumValues) =>
        '[${enumValues.map((e) => "'$e'").join(', ')}]';

    String toParameter(Parameter parameter) {
      var enumAttribute = '';
      if (parameter.enumValues != null) {
        enumAttribute = '@Enum(${enumList(parameter.enumValues!)})';
      }

      return '$enumAttribute ${parameter.deprecatedAttribute} ${context.getPropertyType(parameter)}${parameter.optional ? '?' : ''} ${parameter.normalizedName}';
    }

    var requiredParametersCode = <String>[];
    for (var parameter in requireds) {
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
        var optionalCode =
            parameter.optional ? '${parameter.normalizedName} == null || ' : '';
        code.writeln(
            'assert($optionalCode const ${enumList(parameter.enumValues!)}.contains(${parameter.normalizedName}));');
      }
    }

    var sendCode = " await _client.send('${context.domain.name}.$name'";
    if (parameters.isNotEmpty) {
      sendCode += ', {';
      for (var parameter in requireds) {
        sendCode +=
            "'${parameter.name}' : ${_toJsonCode(parameter, needsExplicitToJson: false, isLocalVariable: true)},";
      }
      for (var parameter in optionals) {
        sendCode += 'if (${parameter.normalizedName} != null)';
        sendCode +=
            "'${parameter.name}' : ${_toJsonCode(parameter, needsExplicitToJson: false, isLocalVariable: true)},";
      }

      sendCode += '}';
    }
    sendCode += ');';

    if (returns.isNotEmpty) {
      sendCode = 'var result = $sendCode\n';
      if (returns.length == 1) {
        var returnParameter = returns.first;
        if (isRawType(returnTypeName)) {
          sendCode +=
              "return result['${returnParameter.name}'] as $returnTypeName;";
        } else if (returnParameter.type == 'array') {
          var elementParameter = Parameter(
              name: 'e',
              type: returnParameter.items!.type,
              ref: returnParameter.items!.ref);
          var paramType = context.getPropertyType(elementParameter);
          String mapCode;
          if (isRawType(paramType)) {
            mapCode = 'e as $paramType';
          } else {
            var cast = _castForParameter(context, elementParameter);
            mapCode =
                '${context.getPropertyType(elementParameter)}.fromJson(e as $cast)';
          }

          sendCode +=
              "return (result['${returnParameter.name}'] as List).map((e) => $mapCode).toList();";
        } else {
          var cast = _castForParameter(context, returnParameter);
          sendCode +=
              "return $returnTypeName.fromJson(result['${returnParameter.name}'] as $cast);";
        }
      } else {
        sendCode += 'return $returnTypeName.fromJson(result);';
      }
    }

    code.writeln(sendCode);

    code.writeln('}');

    _code = code.toString();
  }

  String? get code => _code;

  String? get returnTypeCode => _returnType?.code;
}

class _Event {
  final _DomainContext context;
  final Event event;
  String? _code;
  _InternalType? _complexType;
  String? _typeName;

  _Event(this.context, this.event) {
    var name = event.name;
    var parameters = event.parameters;

    var code = StringBuffer();

    if (parameters.isNotEmpty) {
      if (parameters.length == 1) {
        var firstReturn = parameters.first;
        _typeName = context.getPropertyType(firstReturn);
      } else {
        _typeName = '${firstLetterUpper(name)}Event';
        var returnJson = ComplexType(id: _typeName!, properties: parameters);
        _complexType =
            _InternalType(context, returnJson, generateToJson: false);
      }
    }

    code.writeln(toComment(event.description, indent: 2));

    var streamName = 'on${firstLetterUpper(name)}';
    code.writeln(
        'Stream${_typeName != null ? '<$_typeName>' : ''} get $streamName => '
        "_client.onEvent.where((event) => event.name == '${context.domain.name}.$name')");

    if (parameters.isNotEmpty) {
      String mapCode;
      if (parameters.length == 1) {
        var parameter = parameters.first;
        if (isRawType(_typeName)) {
          mapCode = "event.parameters['${parameter.name}'] as $_typeName";
        } else if (parameter.type == 'array') {
          var elementParameter = Parameter(
              name: 'e',
              type: parameter.items!.type,
              ref: parameter.items!.ref);
          var paramType = context.getPropertyType(elementParameter);
          String insideCode;
          if (isRawType(paramType)) {
            insideCode = 'e as $paramType';
          } else {
            var cast = _castForParameter(context, elementParameter);
            insideCode =
                '${context.getPropertyType(elementParameter)}.fromJson(e as $cast)';
          }

          mapCode =
              "(event.parameters['${parameter.name}'] as List).map((e) => $insideCode).toList()";
        } else {
          var cast = _castForParameter(context, parameter);
          assert(_typeName != null && _typeName!.isNotEmpty);
          mapCode =
              "$_typeName.fromJson(event.parameters['${parameter.name}'] as $cast)";
        }
      } else {
        assert(_typeName != null && _typeName!.isNotEmpty);
        mapCode = '$_typeName.fromJson(event.parameters)';
      }
      code.writeln('.map((event) => $mapCode)');
    }

    code.writeln(';');

    _code = code.toString();
  }

  String? get code => _code;

  String? get complexTypeCode => _complexType?.code;
}

const List<String> jsonTypes = [
  'string',
  'boolean',
  'number',
  'integer',
  'object',
  'any',
  'binary',
];

String? _toJsonCode(Parameter parameter,
    {bool needsExplicitToJson = true, bool isLocalVariable = false}) {
  var name = parameter.normalizedName;
  var type = parameter.type;
  var forceNonNull = parameter.optional ? '!' : '';

  if (jsonTypes.contains(type)) {
    return name;
  } else if (type == 'array') {
    var elementParameter = Parameter(
        name: 'e', type: parameter.items!.type, ref: parameter.items!.ref);
    var code =
        '$name$forceNonNull.map((e) => ${_toJsonCode(elementParameter, needsExplicitToJson: needsExplicitToJson, isLocalVariable: true)}).toList()';
    if (code == '$name.map((e) => e).toList()') {
      return '[...$name]';
    } else if (code == '$name!.map((e) => e).toList()') {
      return '[...${isLocalVariable ? '' : '?'}$name]';
    } else {
      return code;
    }
  }
  if (needsExplicitToJson) {
    return '$name$forceNonNull.toJson()';
  } else {
    return name;
  }
}

class _InternalType {
  final _DomainContext context;
  final ComplexType type;
  final bool generateToJson;
  String? _code;

  _InternalType(this.context, this.type, {this.generateToJson = true}) {
    var id = type.id;

    var code = StringBuffer();

    code.writeln(toComment(type.description));
    code.writeln('class $id {');

    var properties = <Parameter>[];
    var jsonProperties = type.properties;
    var hasProperties = jsonProperties.isNotEmpty;
    var enumValues = type.enums;
    var isEnum = false;
    if (hasProperties) {
      properties.addAll(jsonProperties);
    } else {
      properties
          .add(Parameter(name: 'value', type: type.type, items: type.items));

      if (enumValues != null) {
        isEnum = true;
        for (var enumValue in enumValues) {
          var normalizedValue = _normalizeEnumValue(enumValue);

          code.writeln("static const $normalizedValue = $id._('$enumValue');");
        }

        code.writeln('static const values = {');
        for (var enumValue in enumValues) {
          var normalizedValue = _normalizeEnumValue(enumValue);
          code.writeln("'$enumValue': $normalizedValue,");
        }
        code.writeln('};');
      }
    }

    for (var property in properties.where((p) => !p.deprecated)) {
      code.writeln(toComment(property.description, indent: 2));

      var typeName = _propertyTypeName(property);
      var isOptional = property.optional;
      code.writeln(
          'final $typeName${isOptional ? '?' : ''} ${property.normalizedName};');
      code.writeln('');
    }

    var optionals = properties.where((p) => p.optional).toList();
    var requireds = properties.where((p) => !optionals.contains(p)).toList();

    if (hasProperties) {
      var parametersCode = <String>[];
      for (var property in properties.where((p) => !p.deprecated)) {
        var isOptional = property.optional;
        parametersCode.add(
            '${isOptional ? '' : 'required '}this.${property.normalizedName}');
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
      for (var property in properties.where((p) => !p.deprecated)) {
        var propertyName = property.name;
        var instantiateCode =
            _fromJsonCode(property, "json['$propertyName']", withAs: true);
        if (property.optional) {
          instantiateCode =
              "json.containsKey('$propertyName') ? $instantiateCode : null";
        }

        code.writeln('${property.normalizedName}:  $instantiateCode,');
      }
      code.writeln(');');
      code.writeln('}');
    } else if (isEnum) {
      code.writeln('factory $id.fromJson(String value) => values[value]!;');
    } else {
      var singleParameter = properties.single;
      if (context.isList(singleParameter)) {
        var listItem = singleParameter.items!;
        if (!isRawType(listItem.type)) {
          var elementParameter = Parameter(
              name: 'e',
              type: singleParameter.items!.type,
              ref: singleParameter.items!.ref);
          code.writeln(
              'factory $id.fromJson(List<dynamic> value) => $id(value.map((e) => ${_fromJsonCode(elementParameter, 'e', withAs: true)}).toList());');
        } else {
          code.writeln(
              'factory $id.fromJson(List<dynamic> value) => $id(${context.getPropertyType(singleParameter)}.from(value));');
        }
      } else {
        code.writeln(
            'factory $id.fromJson(${context.getPropertyType(singleParameter)} value) => $id(value);');
      }
    }

    if (generateToJson) {
      code.writeln('');
      if (hasProperties) {
        code.writeln('Map<String, dynamic> toJson() {');
        code.writeln('return {');
        for (var property in requireds.where((p) => !p.deprecated)) {
          code.writeln("'${property.name}': ${_toJsonCode(property)},");
        }
        for (var property in optionals.where((p) => !p.deprecated)) {
          code.writeln('if (${property.normalizedName} != null) ');
          code.writeln("'${property.name}' : ${_toJsonCode(property)},");
        }
        code.writeln('};}');
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
      return type.rawId + firstLetterUpper(property.name);
    } else {
      return context.getPropertyType(property);
    }
  }

  static String? _normalizeEnumValue(String input) {
    input = _sanitizeName(input);
    String? normalizedValue = firstLetterLower(_camelizeName(input));
    normalizedValue = preventKeywords(normalizedValue);

    return normalizedValue;
  }

  String _fromJsonCode(Parameter parameter, String jsonParameter,
      {bool withAs = false}) {
    var type = parameter.type;

    if (jsonTypes.contains(type) && parameter.enumValues == null) {
      if (withAs) {
        var propertyType = context.getPropertyType(parameter);
        if (!parameter.optional && propertyType == 'bool') {
          return '$jsonParameter as $propertyType? ?? false';
        }
        return '$jsonParameter as $propertyType';
      } else {
        assert(jsonParameter.isNotEmpty);
        return jsonParameter;
      }
    } else if (type == 'array') {
      var elementParameter = Parameter(
          name: 'e', type: parameter.items!.type, ref: parameter.items!.ref);
      return "($jsonParameter as List).map((e) => ${_fromJsonCode(elementParameter, 'e', withAs: true)}).toList()";
    }
    var typeName = _propertyTypeName(parameter);
    var cast = _castForParameter(context, parameter);
    assert(typeName.isNotEmpty);
    return '$typeName.fromJson($jsonParameter as $cast)';
  }

  String? get code => _code;
}

class _DomainContext {
  final Domain domain;
  final List<Domain> allDomains;
  final Set<String> dependencies = {};

  _DomainContext(this.domain, this.allDomains);

  ComplexType findComplexType(String type) {
    String typeName;
    Domain domain;
    if (type.contains('.')) {
      var typeAndDomain = type.split('.');
      var domainName = typeAndDomain[0];
      domain = allDomains.singleWhere((d) => d.name == domainName);
      typeName = typeAndDomain[1];
    } else {
      domain = this.domain;
      typeName = type;
    }
    return domain.types.singleWhere((t) => t.id == typeName,
        orElse: () => throw Exception('$type not found'));
  }

  String getPropertyType(Typed parameter) {
    var type = parameter.type;

    if (type == null) {
      type = parameter.ref;
      assert(type != null);

      if (type!.contains('.')) {
        var typeAndDomain = type.split('.');
        var domain = typeAndDomain[0];
        dependencies.add(domain);

        return '${_underscoreize(domain)}.${typeAndDomain[1]}';
      }
    }

    if (type == 'integer') return 'int';
    if (type == 'number') return 'num';
    if (type == 'string') return 'String';
    if (type == 'boolean') return 'bool';
    if (type == 'any') return 'dynamic';
    if (type == 'object') return 'Map<String, dynamic>';
    if (type == 'binary') return 'String';
    if (type == 'array') {
      if (parameter is Parameter) {
        var items = parameter.items;
        if (items != null) {
          var innerType = getPropertyType(items);

          return 'List<$innerType>';
        } else {
          return 'List';
        }
      } else {
        assert(false);
      }
    }

    return type;
  }

  bool isList(Typed parameter) => parameter.type == 'array';
}

bool isRawType(String? type) => const [
      'int',
      'num',
      'String',
      'bool',
      'dynamic',
      'Map<String, dynamic>'
    ].contains(type);

String toComment(String? comment, {int indent = 0}) {
  if (comment != null && comment.isNotEmpty) {
    comment = comment.replaceAll('<code>', '`').replaceAll('</code>', '`');

    const docStarter = '/// ';

    var commentLines = LineSplitter.split(comment).toList();

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

String _castForParameter(_DomainContext context, Parameter parameter) {
  if (parameter.enumValues != null) {
    return 'String';
  } else {
    var complexType = context.findComplexType(parameter.ref!);
    if (complexType.enums != null) {
      return 'String';
    } else if (complexType.properties.isNotEmpty) {
      return 'Map<String, dynamic>';
    } else {
      var parameter = Parameter(name: 'value', type: complexType.type);
      return context.getPropertyType(parameter);
    }
  }
}

String? deprecatedDocumentation(String? description) {
  if (description == null) return null;

  var useInsteadExtractor = RegExp(r'Use (.*) instead', caseSensitive: false);
  var match = useInsteadExtractor.firstMatch(description);
  if (match != null) {
    return match.group(0);
  }
  var split = description.split('Deprecated,');
  if (split.length > 1) {
    return split[1].trim();
  }
  return null;
}

void _applyTemporaryFixes(List<Domain> domains) {
  var accessibilityDomain =
      domains.firstWhere((e) => e.name == 'Accessibility');
  var axPropertyName =
      accessibilityDomain.types.firstWhere((e) => e.id == 'AXPropertyName');
  var axPropertyNameEnums = axPropertyName.enums!;
  var newAxPropertyNames = const [
    'uninteresting',
    'ariaHiddenElement',
    'ariaHiddenSubtree',
    'notRendered',
  ];
  assert(!newAxPropertyNames.any((e) => axPropertyNameEnums.contains(e)));
  axPropertyNameEnums.addAll(newAxPropertyNames);
}
