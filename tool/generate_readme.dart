import 'dart:io';

import 'package:dart_style/dart_style.dart';

final RegExp _importRegex = new RegExp(r"import '([^']+)';\r?\n");
final RegExp _ignoreForFileRegex =
    new RegExp(r"^// ignore_for_file:.*$", multiLine: true);

final DartFormatter _dartFormatter =
    new DartFormatter(lineEnding: Platform.isWindows ? '\r\n' : '\n');

main() {
  new File('README.md').writeAsStringSync(generateReadme());
}

String generateReadme() {
  String template = new File('README.template.md').readAsStringSync();

  String readme = template.replaceAllMapped(_importRegex, (Match match) {
    String filePath = match.group(1);

    String fileContent = new File(filePath).readAsStringSync();
    fileContent = fileContent.replaceAll(_ignoreForFileRegex, '');

    fileContent = _dartFormatter.format(fileContent);

    return fileContent;
  });
  return readme;
}
