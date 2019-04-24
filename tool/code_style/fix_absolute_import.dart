import 'dart:io';
// ignore: deprecated_member_use
import 'package:analyzer/analyzer.dart';
import 'package:path/path.dart' as p;
import 'dart_project.dart';

// A script that replace all absolute imports to relative one
// import 'package:slot/src/my_slot.dart' => 'import '../my_slot.dart';
void main() {
  String root = Directory.current.path;

  for (DartProject project in getSubOrContainingProjects(root)) {
    for (DartFile dartFile in project.getDartFiles().where(
        (DartFile dartFile) =>
            dartFile.normalizedRelativePath.startsWith('lib/'))) {
      fixFile(dartFile);
    }
  }
}

bool fixFile(DartFile dartFile) {
  String content = dartFile.file.readAsStringSync();
  String newContent = fixCode(dartFile, content);

  if (content != newContent) {
    dartFile.file.writeAsStringSync(newContent);
    return true;
  }
  return false;
}

String fixCode(DartFile dartFile, String content) {
  try {
    String newContent = content;

    CompilationUnit unit = parseCompilationUnit(content);

    for (NamespaceDirective directive in unit.directives.reversed
        .where((Directive directive) => directive is NamespaceDirective)) {
      String uriValue = directive.uri.stringValue;
      String absolutePrefix = 'package:${dartFile.project.packageName}/';
      if (uriValue.startsWith(absolutePrefix)) {
        String absoluteImportFromLib = uriValue.replaceAll(absolutePrefix, '');
        String thisFilePath = dartFile.relativePath.substring('lib/'.length);
        String relativePath = p
            .relative(absoluteImportFromLib, from: p.dirname(thisFilePath))
            .replaceAll('\\', '/');

        String directiveContent =
            directive.uri.toString().replaceAll(uriValue, relativePath);

        newContent = newContent.replaceRange(directive.uri.offset,
            directive.uri.offset + directive.uri.length, directiveContent);
      }
    }

    return newContent;
  } catch (e) {
    print(
        'Error while parsing file package:${dartFile.project.packageName}/${dartFile.relativePath}');
    rethrow;
  }
}
