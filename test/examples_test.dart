import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

// Test all the dart scripts in the example/ folder.
main() {
  for (File exampleFile in Directory('example').listSync().where((f) =>
      f is File &&
      f.path.endsWith('.dart') &&
      !p.basename(f.path).startsWith('_'))) {
    String fileContent = exampleFile.readAsStringSync();

    if (fileContent.contains('main()')) {
      test('Text example/${p.basename(exampleFile.path)}', () {
        var result = Process.runSync(Platform.resolvedExecutable,
            ['--enable-asserts', exampleFile.absolute.path]);
        if (result.exitCode != 0) {
          print(result.stdout);
          print(result.stderr);
          fail('Exit code is ${result.exitCode}');
        }
      });
    }
  }
}
