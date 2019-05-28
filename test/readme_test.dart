import 'dart:io';
import 'package:test/test.dart';
import '../tool/generate_readme.dart';

main() {
  test('The readme has been generated', () {
    var currentReadme = File('README.md').readAsStringSync();

    var expectedReadme = generateReadme();

    expect(currentReadme, equals(expectedReadme));
  });
}
