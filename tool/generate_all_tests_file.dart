import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:dart_style/dart_style.dart';

main() {
  var allFiles = Directory('test')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('_test.dart'))
      .map((file) => p.relative(file.path, from: 'test'))
      .toList();

  var buffer = StringBuffer();
  buffer.writeln("import 'package:test/test.dart';");
  for (var file in allFiles) {
    buffer.writeln("import '$file' as ${file.replaceAll('.dart', '')};");
  }

  buffer.writeln('main() {');
  for (var file
      in allFiles.map((fileName) => fileName.replaceAll('.dart', ''))) {
    buffer.writeln("group('$file', $file.main);");
  }
  buffer.writeln('}');

  File('test/_all_tests.dart')
      .writeAsStringSync(DartFormatter().format(buffer.toString()));
}
