import 'dart:io';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;

void main() {
  var allFiles = Directory('test')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('_test.dart'))
      .map((file) => p.relative(file.path, from: 'test'))
      .toList();
  allFiles.sort();

  var buffer = StringBuffer();
  buffer.writeln("import 'package:test/test.dart';");
  for (var file in allFiles) {
    buffer.writeln("import '$file' as ${file.replaceAll('.dart', '')};");
  }

  buffer.writeln('void main() {');
  for (var file
      in allFiles.map((fileName) => fileName.replaceAll('.dart', ''))) {
    buffer.writeln("group('$file', $file.main);");
  }
  buffer.writeln('}');

  File('test/test_all.dart')
      .writeAsStringSync(DartFormatter().format(buffer.toString()));
}
