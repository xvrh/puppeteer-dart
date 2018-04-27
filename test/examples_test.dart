import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

// Test all the dart scripts in the example/ folder.
main() {
  for (File exampleFile in new Directory('example').listSync().where((f) =>
      f is File &&
      f.path.endsWith('.dart') &&
      !p.basename(f.path).startsWith('_'))) {
    String fileName = p.basenameWithoutExtension(exampleFile.path);
    test('Text example $fileName', () {
      var result = Process
          .runSync(Platform.resolvedExecutable, [exampleFile.absolute.path]);
      if (result.exitCode != 0) {
        print(result.stdout);
        print(result.stderr);
        fail('Exit code is ${result.exitCode}');
      }
    });
  }
}
