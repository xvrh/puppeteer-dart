import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:puppeteer/puppeteer.dart';
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
          if (isPuppeteerFirefox) {
            // Some examples are not executable on Firefox.
            // just print it
            print('Exit code is ${result.exitCode}');
          } else {
            fail('Exit code is ${result.exitCode}');
          }
        }
      });
    }
  }
}
