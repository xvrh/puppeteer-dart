import 'dart:convert';
import 'dart:io';
// ignore: deprecated_member_use
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:dart_style/dart_style.dart';
import 'dart_project.dart';

void main() {
  for (DartProject project
      in getSubOrContainingProjects(Directory.current.path)) {
    for (DartFile dartFile in project.getDartFiles()) {
      try {
        fixFile(dartFile);
      } catch (e, s) {
        print('Error while fixing ${dartFile.path}\n$e\n$s');
        rethrow;
      }
    }
  }
}

bool fixFile(DartFile dartFile) {
  String content = dartFile.file.readAsStringSync();

  String newContent = reorderImports(content);

  if (content != newContent) {
    dartFile.file.writeAsStringSync(newContent);
    return true;
  }
  return false;
}

final DartFormatter _dartFormatter = DartFormatter(fixes: StyleFix.all);

final String newLineChar = Platform.isWindows ? '\r\n' : '\n';

String reorderImports(String source) {
  return _reorderImports(source, parseCompilationUnit(source));
}

String _reorderImports(String content, CompilationUnit unit) {
  List<_WholeDirective> wholeDirectives = [];
  List<ImportDirective> imports = <ImportDirective>[];
  List<ExportDirective> exports = <ExportDirective>[];
  List<PartDirective> parts = <PartDirective>[];

  int minOffset = 0, maxOffset = 0;
  int lastOffset = 0;
  bool isFirst = true;
  for (Directive directive in unit.directives) {
    if (directive is UriBasedDirective) {
      int offset, length;
      if (isFirst) {
        isFirst = false;

        // C'est très fragile mais on essaye de faire que les attributs @TestOn
        // reste toujours en premier. Les autres attributs restent attaché à leur import (ex: @MirrorUsed)
        Token token = directive.metadata?.beginToken ??
            directive.firstTokenAfterCommentAndMetadata;

        bool hasTestMeta = _testContains(directive.metadata.toString(),
            ['@TestOn', '@Skip', '@Timeout', '@OnPlatform', '@Tags']);
        if (hasTestMeta) {
          token = directive.firstTokenAfterCommentAndMetadata;
        }
        offset = token.offset;
        length =
            (directive.endToken.offset + directive.endToken.length) - offset;
        minOffset = offset;
        maxOffset = length + offset;
      } else {
        offset = lastOffset;
        length =
            directive.endToken.offset + directive.endToken.length - lastOffset;
      }

      maxOffset = offset + length;
      lastOffset = maxOffset;

      _WholeDirective wholeDirective =
          _WholeDirective(directive, offset, length);
      wholeDirectives.add(wholeDirective);

      if (directive is ImportDirective) {
        imports.add(directive);
      } else if (directive is ExportDirective) {
        exports.add(directive);
      } else {
        parts.add(directive);
      }
    }
  }

  imports.sort(_compare);
  exports.sort(_compare);
  parts.sort(_compare);

  String contentBefore = content.substring(0, minOffset);
  String reorderedContent = '';

  String _writeBlock(List<UriBasedDirective> directives) {
    String result = '';
    for (UriBasedDirective directive in directives) {
      _WholeDirective wholeDirective = wholeDirectives.firstWhere(
          (_WholeDirective wholeDirective) =>
              wholeDirective.directive == directive);
      String directiveString = content.substring(wholeDirective.countedOffset,
          wholeDirective.countedOffset + wholeDirective.countedLength);

      String normalizedDirective = directive.toString().replaceAll('"', "'");
      directiveString =
          directiveString.replaceAll(directive.toString(), normalizedDirective);

      result += directiveString;
    }
    return result + '$newLineChar$newLineChar';
  }

  reorderedContent += _removeBlankLines(_writeBlock(imports));
  reorderedContent += _removeBlankLines(_writeBlock(exports));
  reorderedContent += _removeBlankLines(_writeBlock(parts));

  String contentAfter = content.substring(maxOffset);

  String newContent = contentBefore + reorderedContent + contentAfter;

  newContent = _dartFormatter.format(newContent);

  return newContent;
}

bool _testContains(String stringToTest, List<String> searchs) {
  for (String s in searchs) {
    if (stringToTest.contains(s)) return true;
  }
  return false;
}

String _removeBlankLines(String content) {
  List<String> lines = LineSplitter.split(content).toList();
  List<String> result = [];
  int i = 0;
  for (String line in lines) {
    if (i == 0 || line.trim().isNotEmpty) {
      result.add(line);
    }
    ++i;
  }

  return newLineChar + result.join(newLineChar);
}

int _compare(UriBasedDirective directive1, UriBasedDirective directive2) {
  String uri1 = directive1.uri.stringValue;
  String uri2 = directive2.uri.stringValue;

  if (uri1.contains(':') && !uri2.contains(':')) {
    return -1;
  } else if (!uri1.contains(':') && uri2.contains(':')) {
    return 1;
  } else {
    return uri1.compareTo(uri2);
  }
}

class _WholeDirective {
  final UriBasedDirective directive;
  final int countedOffset;
  final int countedLength;

  _WholeDirective(this.directive, this.countedOffset, this.countedLength);
}
