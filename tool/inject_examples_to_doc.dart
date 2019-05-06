import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:analyzer/analyzer.dart'; // ignore: deprecated_member_use
import 'package:dart_style/dart_style.dart';

// Extrat the samples from the file test/doc_examples_test.dart and inject
// it in the source code
main() {
  var snippets =
      extractSnippets(File('test/doc_examples_test.dart').readAsStringSync());

  for (File dartFile
      in Directory('lib/src').listSync(recursive: true).whereType<File>()) {
    String fileContent = dartFile.readAsStringSync();
    String newContent = replaceExamples(fileContent, snippets);

    if (fileContent != newContent) {
      print('Change ${dartFile.path}');
      dartFile.writeAsStringSync(newContent);
    }
  }

  if (snippets.isNotEmpty) {
    var remainingSnippets = snippets
        .map((snippet) => '${snippet.target}.${snippet.index}')
        .join(', ');
    throw 'Remaining snippets: $remainingSnippets';
  }
}

final _formatter = DartFormatter();

String replaceExamples(String sourceFile, List<CodeSnippet> snippets) {
  var unit = parseCompilationUnit(sourceFile);

  for (var aClass
      in unit.declarations.whereType<ClassDeclaration>().toList().reversed) {
    String className = aClass.name.name;

    for (var member in aClass.members.reversed) {
      var comment = member.documentationComment;

      if (comment != null) {
        String memberName;
        if (member is MethodDeclaration) {
          memberName = member.name.name;
        } else if (member is ConstructorDeclaration) {
          memberName = member.name.name;
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
  List<String> lines = comment.tokens.map((t) => t.toString()).toList();

  int index = 0;
  return lines.join('\n').replaceAllMapped(_dartExampleExtractor, (match) {
    CodeSnippet snippet = allSnippets.firstWhere(
        (s) => s.target == target.replaceAll(r'$', 'S') && s.index == index,
        orElse: () => null);
    if (snippet == null) {
      throw "Can't find snippet for [$target] at index $index";
    }
    ++index;
    allSnippets.remove(snippet);

    String commentedCode =
        LineSplitter.split(snippet.code).map((line) => ' /// $line').join('\n');

    return '''
```dart
$commentedCode
 /// ```''';
  });
}

String replaceComment(String file, Comment comment, String newComment) {
  String before = file.substring(0, comment.offset);
  String after = file.substring(comment.end);

  return '$before$newComment$after';
}

List<CodeSnippet> extractSnippets(String sourceCode) {
  var compilationUnit = parseCompilationUnit(sourceCode);
  var main = compilationUnit.declarations
      .whereType<FunctionDeclaration>()
      .firstWhere((c) => c.name.name == 'main');

  BlockFunctionBody mainBody = main.functionExpression.body;

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
      StringLiteral groupName = expression.argumentList.arguments[0];
      FunctionExpression innerBlock = expression.argumentList.arguments[1];
      BlockFunctionBody innerBody = innerBlock.body;

      findGroupAndTests(fileCode, innerBody.block, snippets,
          _joinPrefix(namePrefix, groupName.stringValue));
    } else if (methodName == 'test') {
      FunctionExpression innerBlock = expression.argumentList.arguments[1];
      BlockFunctionBody innerBody = innerBlock.body;
      String code = _extractCode(fileCode.substring(
          innerBody.block.offset + 1, innerBody.block.end - 1));
      Literal firstArgument = expression.argumentList.arguments[0];
      if (firstArgument is StringLiteral) {
        snippets.add(CodeSnippet(
            _joinPrefix(namePrefix, firstArgument.stringValue), code));
      } else {
        IntegerLiteral indexArgument = firstArgument;
        snippets.add(CodeSnippet(namePrefix, code, index: indexArgument.value));
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
$code
}''';
    var compilation = parseCompilationUnit(code);
    var replacerVisitor = _ExampleReplacerVisitor();
    compilation.visitChildren(replacerVisitor);
    code = replacerVisitor.replace(code);
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

class _ExampleReplacerVisitor extends RecursiveAstVisitor {
  final _nodesToReplace = <AstNode, String>{};
  InterpolationExpression _stringInterpolation;

  @override
  visitInterpolationExpression(node) {
    _stringInterpolation = node;
    super.visitInterpolationExpression(node);
    _stringInterpolation = null;
  }

  @override
  visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'exampleValue') {
      var argument = node.argumentList.arguments[1];

      String targetValue;
      if (_stringInterpolation != null) {
        StringLiteral literal = argument;
        targetValue = literal.stringValue;
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
      String before = code.substring(0, node.offset);
      String after = code.substring(node.end);
      String newValue = _nodesToReplace[node];

      code = '$before$newValue$after';
    }
    return code;
  }
}
