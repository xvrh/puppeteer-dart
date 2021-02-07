import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

// Test all the dart scripts in the example/ folder.
void main() {
  for (var exampleFile in Directory('example')
      .listSync()
      .whereType<File>()
      .where((f) =>
          f.path.endsWith('.dart') && !p.basename(f.path).startsWith('_'))) {
    var fileContent = exampleFile.readAsStringSync();

    if (fileContent.contains('main()')) {
      test('Text example/${p.basename(exampleFile.path)}', () {
        var result = Process.runSync(Platform.resolvedExecutable,
            ['--enable-asserts', exampleFile.absolute.path]);
        if (result.exitCode != 0) {
          print(result.stdout);
          print(result.stderr);
          fail('Exit code is ${result.exitCode}');
        }
      },
          // Don't test some examples that are too complex and not reliable
          skip: const ['search.dart'].contains(p.basename(exampleFile.path))
              ? 'Skip'
              : null);
    }
  }
}
