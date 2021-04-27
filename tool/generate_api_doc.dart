import 'dart:io';
import 'dart:math';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';
import 'utils/string_helpers.dart';

final classesOrder = [
  'Puppeteer',
  'Browser',
  'BrowserContext',
  'Page',
  'Worker',
  'Accessibility',
  'Keyboard',
  'Mouse',
  'Touchscreen',
  'Tracing',
  'Dialog',
  'ConsoleMessage',
  'Frame',
  'ExecutionContext',
  'JsHandle',
  'ElementHandle',
  'Request',
  'Response',
  'Coverage',
  'FileChooser',
];

void main() {
  var classes = <Class>[];
  for (var dartFile in Directory('lib/src')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))) {
    var fileContent = dartFile.readAsStringSync();

    var unit = parseString(
        content: fileContent,
        featureSet: FeatureSet.fromEnableFlags2(
            sdkLanguageVersion: Version(2, 12, 0), flags: [])).unit;

    classes.addAll(unit.declarations
        .whereType<ClassDeclaration>()
        .where((declaration) => declaration.documentationComment != null)
        .map(Class.fromDeclaration));
  }

  var buffer = StringBuffer();
  buffer.writeln('# Puppeteer API');
  buffer.writeln();
  buffer.writeln('##### Table of Contents');
  buffer.writeln();
  for (var className in classesOrder) {
    var clas = classes.firstWhere((c) => c.name == className);

    buffer.writeln('- [${clas.shortTitle}](#${toLink(clas.title)})');

    for (var method in clas.methods) {
      buffer.writeln('  * [${method.shortTitle}](#${toLink(method.title)})');
    }
  }

  buffer.writeln();

  for (var className in classesOrder) {
    var clas = classes.firstWhere((c) => c.name == className);

    buffer.writeln('### ${clas.title}');
    buffer.writeln(clas.documentation);
    buffer.writeln();

    for (var method in clas.methods) {
      buffer.writeln('#### ${method.title}');
      buffer.writeln(method.documentation);
      buffer.writeln();
      buffer.writeln('```dart');
      buffer.writeln(method.fullSignature);
      buffer.writeln('```');
      buffer.writeln();
    }
  }
  print(buffer.toString());

  File('doc/api.md').writeAsStringSync(buffer.toString());
}

String readComment(Comment? comment) =>
    comment?.tokens
        .map((t) => t.toString().substring(min(t.length, 4)))
        .toList()
        .join('\n') ??
    '';

final _nonAlphaNum = RegExp(r'[^a-zA-Z0-9_ ]');
String toLink(String title) =>
    title.replaceAll(_nonAlphaNum, '').replaceAll(' ', '-').toLowerCase();

String _escapeBracket(String input) => input.replaceAll('<', r'\<');

class Class {
  final String name;
  final String documentation;
  final List<Method> methods = [];

  Class(this.name, this.documentation);

  static Class fromDeclaration(ClassDeclaration declaration) {
    var clas = Class(
        declaration.name.name, readComment(declaration.documentationComment));

    clas.methods.addAll(declaration.members
        .where((member) => member.documentationComment != null)
        .map((member) => Method.fromClassMember(clas, member))
        .whereNotNull());

    clas.methods.sort((m1, m2) => m1.name.compareTo(m2.name));

    return clas;
  }

  String get title => 'class: $name';
  String get shortTitle => 'class: $name';

  @override
  String toString() => '$name';
}

class Method {
  final Class parent;
  final String name;
  final String title, shortTitle, fullSignature;
  final String documentation;

  Method(this.parent, this.name, this.documentation,
      {required this.title,
      required this.shortTitle,
      required this.fullSignature});

  static Method? fromClassMember(Class parent, ClassMember member) {
    String name;
    String title, shortTitle, fullSignature;
    if (member is MethodDeclaration) {
      name = member.name.name;
      if (member.isGetter) {
        title = '${firstLetterLower(parent.name)}.$name';
        fullSignature =
            '${firstLetterLower(parent.name)}.$name → ${member.returnType}';
      } else {
        var parameters = _escapeBracket(member.parameters.toString());
        if (parameters.length > 40) {
          parameters = '(...)';
        }
        title = '${firstLetterLower(parent.name)}.$name$parameters';
        fullSignature =
            '${firstLetterLower(parent.name)}.$name${member.parameters} → ${member.returnType} ';
      }
      shortTitle = '${firstLetterLower(parent.name)}.$name';
    } else if (member is FieldDeclaration) {
      name = member.fields.variables.first.name.name;
      title = '${firstLetterLower(parent.name)}.$name';
      shortTitle = '${firstLetterLower(parent.name)}.$name';
      fullSignature =
          '${firstLetterLower(parent.name)}.$name → ${member.fields.type}';
    } else {
      return null;
    }

    return Method(parent, name, readComment(member.documentationComment),
        title: title, shortTitle: shortTitle, fullSignature: fullSignature);
  }

  @override
  String toString() => '$name';
}
