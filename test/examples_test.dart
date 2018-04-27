import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'utils.dart';

// Test all the dart scripts in the example/ folder.
main() {
  var envVariables = {};
  if (forceNoSandboxFlag) {
    envVariables['CHROME_FORCE_NO_SANDBOX'] = 'true';
  }
  for (File exampleFile in new Directory('example').listSync().where((f) =>
      f is File &&
      f.path.endsWith('.dart') &&
      !p.basename(f.path).startsWith('_'))) {
    String fileName = p.basenameWithoutExtension(exampleFile.path);
    test('Text example $fileName', () {
      var result = Process.runSync(
          Platform.resolvedExecutable, [exampleFile.absolute.path],
          environment: envVariables);
      if (result.exitCode != 0) {
        print(result.stdout);
        print(result.stderr);
        fail('Exit code is ${result.exitCode}');
      }
    });
  }
}
