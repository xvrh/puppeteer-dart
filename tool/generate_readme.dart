import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:dart_style/dart_style.dart';
import 'download_protocol_from_repo.dart' show protocols;

final RegExp _importRegex = RegExp(r"import '([^']+)';\r?\n");
final RegExp _ignoreForFileRegex =
    RegExp(r'^// ignore_for_file:.*$', multiLine: true);

final DartFormatter _dartFormatter =
    DartFormatter(lineEnding: Platform.isWindows ? '\r\n' : '\n');

void main() {
  File('README.md').writeAsStringSync(generateReadme());
}

String generateReadme() {
  var template = File('README.template.md').readAsStringSync();

  var readme = template.replaceAllMapped(_importRegex, (match) {
    var filePath = match.group(1)!;

    var fileContent = File(filePath).readAsStringSync();
    fileContent = fileContent.replaceAll(_ignoreForFileRegex, '');

    fileContent = _dartFormatter.format(fileContent);

    return fileContent;
  });

  for (var protocolName in protocols.keys) {
    readme = readme.replaceAll(
        '[$protocolName]()', '[$protocolName](${protocols[protocolName]})');
  }

  return readme;
}
