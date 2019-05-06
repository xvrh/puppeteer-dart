import 'dart:io';
import 'package:dart_style/dart_style.dart';
import 'download_protocol_from_repo.dart' show protocols;

final RegExp _importRegex = RegExp(r"import '([^']+)';\r?\n");
final RegExp _ignoreForFileRegex =
    RegExp(r"^// ignore_for_file:.*$", multiLine: true);

final DartFormatter _dartFormatter =
    DartFormatter(lineEnding: Platform.isWindows ? '\r\n' : '\n');

main() {
  File('README.md').writeAsStringSync(generateReadme());
}

String generateReadme() {
  String template = File('README.template.md').readAsStringSync();

  String readme = template.replaceAllMapped(_importRegex, (Match match) {
    String filePath = match.group(1);

    String fileContent = File(filePath).readAsStringSync();
    fileContent = fileContent.replaceAll(_ignoreForFileRegex, '');

    fileContent = _dartFormatter.format(fileContent);

    return fileContent;
  });

  for (String protocolName in protocols.keys) {
    readme = readme.replaceAll(
        '[$protocolName]()', '[$protocolName](${protocols[protocolName]})');
  }

  return readme;
}
