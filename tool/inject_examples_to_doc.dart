import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:dart_style/dart_style.dart';
import 'package:pub_semver/pub_semver.dart';

// Extrat the samples from the file test/doc_examples_test.dart and inject
// it in the source code
void main() {
  var snippets =
      extractSnippets(File('test/doc_examples_test.dart').readAsStringSync());

  for (var dartFile
      in Directory('lib/src').listSync(recursive: true).whereType<File>()) {
    var fileContent = dartFile.readAsStringSync();
    var newContent = replaceExamples(fileContent, snippets);

    if (fileContent != newContent) {
      print('Change ${dartFile.path}');
      dartFile.writeAsStringSync(newContent);
    }
  }

  if (snippets.isNotEmpty) {
    var remainingSnippets = snippets
        .map((snippet) => '${snippet.target}.${snippet.index}')
        .join(', ');
    throw Exception('Remaining snippets: $remainingSnippets');
  }
}

final _formatter = DartFormatter();

final _featureSet = FeatureSet.fromEnableFlags2(
    sdkLanguageVersion: Version(2, 12, 0), flags: []);

String replaceExamples(String sourceFile, List<CodeSnippet> snippets) {
  var unit = parseString(content: sourceFile, featureSet: _featureSet).unit;

  for (var aClass
      in unit.declarations.whereType<ClassDeclaration>().toList().reversed) {
    var className = aClass.name.name;

    for (var member in aClass.members.reversed) {
      var comment = member.documentationComment;

      if (comment != null) {
        String? memberName;
        if (member is MethodDeclaration) {
          memberName = member.name.name;
        } else if (member is ConstructorDeclaration) {
          memberName = member.name?.name;
        } else if (member is FieldDeclaration) {
          memberName = member.fields.variables.first.name.name;
        }

        if (memberName != null) {
          var newComment =
              _newComment('$className.$memberName', comment, snippets);
          sourceFile = replaceComment(sourceFile, comment, newComment);
        }
      }
    }

    var comment = aClass.documentationComment;
    if (comment != null) {
      var newComment = _newComment('$className.class', comment, snippets);
      sourceFile = replaceComment(sourceFile, comment, newComment);
    }
  }

  // We rely on the formatter to correctly re-indent the comments
  sourceFile = _formatter.format(sourceFile);

  return sourceFile;
}

final _dartExampleExtractor = RegExp(r'\`\`\`dart[\s\S]*?\`\`\`');

String _newComment(
    String target, Comment comment, List<CodeSnippet> allSnippets) {
  var lines = comment.tokens.map((t) => t.toString()).toList();

  var index = 0;
  return lines.join('\n').replaceAllMapped(_dartExampleExtractor, (match) {
    var snippet = allSnippets.firstWhereOrNull(
        (s) => s.target == target.replaceAll(r'$', 'S') && s.index == index);
    if (snippet == null) {
      throw Exception("Can't find snippet for [$target] at index $index");
    }
    ++index;
    allSnippets.remove(snippet);

    var commentedCode =
        LineSplitter.split(snippet.code).map((line) => ' /// $line').join('\n');

    return '''
```dart
$commentedCode
 /// ```''';
  });
}

String replaceComment(String file, Comment comment, String newComment) {
  var before = file.substring(0, comment.offset);
  var after = file.substring(comment.end);

  return '$before$newComment$after';
}

List<CodeSnippet> extractSnippets(String sourceCode) {
  var compilationUnit =
      parseString(content: sourceCode, featureSet: _featureSet).unit;
  var main = compilationUnit.declarations
      .whereType<FunctionDeclaration>()
      .firstWhere((c) => c.name.name == 'main');

  var mainBody = main.functionExpression.body as BlockFunctionBody;

  var results = <CodeSnippet>[];
  findGroupAndTests(sourceCode, mainBody.block, results, '');

  return results;
}

void findGroupAndTests(String fileCode, Block block, List<CodeSnippet> snippets,
    String namePrefix) {
  for (var expression in block.statements
      .whereType<ExpressionStatement>()
      .map((s) => s.expression)
      .whereType<MethodInvocation>()) {
    var methodName = expression.methodName.name;
    if (methodName == 'group') {
      var groupName = expression.argumentList.arguments[0] as StringLiteral;
      var innerBlock =
          expression.argumentList.arguments[1] as FunctionExpression;
      var innerBody = innerBlock.body as BlockFunctionBody;

      findGroupAndTests(fileCode, innerBody.block, snippets,
          _joinPrefix(namePrefix, groupName.stringValue!));
    } else if (methodName == 'test') {
      var innerBlock =
          expression.argumentList.arguments[1] as FunctionExpression;
      var innerBody = innerBlock.body as BlockFunctionBody;
      var code = _extractCode(fileCode.substring(
          innerBody.block.offset + 1, innerBody.block.end - 1));
      var firstArgument = expression.argumentList.arguments[0] as Literal;
      if (firstArgument is StringLiteral) {
        snippets.add(CodeSnippet(
            _joinPrefix(namePrefix, firstArgument.stringValue!), code));
      } else {
        var indexArgument = firstArgument as IntegerLiteral;
        snippets
            .add(CodeSnippet(namePrefix, code, index: indexArgument.value!));
      }
    }
  }
}

String _extractCode(String content) {
  var lines = LineSplitter.split(content);
  bool isBlockStarter(String line) => line.trim().startsWith('//--');
  if (lines.any(isBlockStarter)) {
    lines = lines
        .skipWhile((l) => !isBlockStarter(l))
        .skip(1)
        .takeWhile((l) => !isBlockStarter(l))
        .toList();
  } else {
    lines = lines.skipWhile((l) => l.trim().isEmpty).toList();
  }

  return lines.join('\n');
}

String _joinPrefix(String prefix, String newArgument) {
  return prefix.isNotEmpty ? '$prefix.$newArgument' : newArgument;
}

class CodeSnippet {
  final String target;
  final String code;
  final int index;

  CodeSnippet(this.target, String code, {this.index = 0})
      : code = fixCode(code);

  static String fixCode(String code) {
    code = '''
main() async {
${LineSplitter.split(code).map((line) => '  $line').join('\n')}
}''';
    var compilation = parseString(content: code, featureSet: _featureSet).unit;
    var replacerVisitor = _ExampleReplacerVisitor();
    compilation.visitChildren(replacerVisitor);
    code = replacerVisitor.replace(code);
    code = code.replaceAll('Future<void> main()', 'void main()');
    code = _formatter.format(code);
    var lines = LineSplitter.split(code).skip(1);
    lines = lines.take(lines.length - 1);

    lines = lines.join('\n').trimRight().split('\n');

    code = lines.map((line) => line.substring(min(line.length, 2))).join('\n');

    return code.replaceAll('//+', '');
  }

  @override
  String toString() => 'Snippet(target: $target, index: $index, code: \n$code)';
}

class _ExampleReplacerVisitor extends RecursiveAstVisitor<void> {
  final _nodesToReplace = <AstNode, String>{};
  InterpolationExpression? _stringInterpolation;

  @override
  void visitInterpolationExpression(node) {
    _stringInterpolation = node;
    super.visitInterpolationExpression(node);
    _stringInterpolation = null;
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'exampleValue') {
      var argument = node.argumentList.arguments[1];

      String targetValue;
      if (_stringInterpolation != null) {
        var literal = argument as StringLiteral;
        targetValue = literal.stringValue!;
      } else {
        targetValue = argument.toString();
      }

      _nodesToReplace[_stringInterpolation ?? node] = targetValue;
    } else {
      super.visitMethodInvocation(node);
    }
  }

  String replace(String code) {
    for (var node in _nodesToReplace.keys.toList().reversed) {
      var before = code.substring(0, node.offset);
      var after = code.substring(node.end);
      var newValue = _nodesToReplace[node];

      code = '$before$newValue$after';
    }
    return code;
  }
}
