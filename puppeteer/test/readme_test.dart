import 'dart:io';
import 'package:test/test.dart';
import '../tool/generate_readme.dart';

main() {
  test('The readme has been generated', () {
    String currentReadme = File('README.md').readAsStringSync();

    String expectedReadme = generateReadme();

    expect(currentReadme, equals(expectedReadme));
  });
}
