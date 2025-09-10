import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart';

final _downloaderFile = File('lib/src/downloader.dart');
final _variablePrefix = 'const _lastVersion = ';
final _versionExtractor = RegExp("$_variablePrefix'([^']+)';");
String _replaceVersion(String version) => "$_variablePrefix'$version';";

void main() async {
  var stableVersion = await _getVersionAndRevisionForStable();
  var currentVersion = await _readCurrentVersion();

  if (stableVersion != currentVersion) {
    await _updateCurrentVersion(stableVersion);
    setOutput('commit', 'roll to Chrome $stableVersion');
  }
}

Future<String> _getVersionAndRevisionForStable() async {
  var result = await read(
    Uri.parse(
      'https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions.json',
    ),
  );
  var json = jsonDecode(result);
  //ignore: avoid_dynamic_calls
  var version = json['channels']['Stable']['version'] as String;

  return version;
}

Future<String> _readCurrentVersion() async {
  var content = await _downloaderFile.readAsString();

  return _versionExtractor.firstMatch(content)!.group(1)!;
}

Future<void> _updateCurrentVersion(String newVersion) async {
  var content = await _downloaderFile.readAsString();
  var newContent = content.replaceFirst(
    _versionExtractor,
    _replaceVersion(newVersion),
  );
  await _downloaderFile.writeAsString(newContent);
}

// Inline code from https://github.com/axel-op/github_actions_toolkit.dart

final _eol = () {
  if (Platform.isWindows) return '\r\n';
  if (Platform.isMacOS) return '\r';
  return '\n';
}();

/// Sets an action's output parameter.
///
/// Optionally, you can also declare output parameters in an action's metadata file.
/// For more information,
/// see "[Metadata syntax for GitHub Actions.](https://help.github.com/en/articles/metadata-syntax-for-github-actions#outputs)"
void setOutput(String name, String value) {
  final file = Platform.environment['GITHUB_OUTPUT'];
  if (file != null) {
    _appendToFile(file, _prepareKeyValueMessage(name, value));
  } else {
    _echo('set-output', value, {'name': name});
  }
}

void _echo(String command, [String? message, Map<String, String>? parameters]) {
  final sb = StringBuffer('::$command');
  final params = parameters?.entries
      .map((e) => '${e.key}=${e.value}')
      .join(',');
  if (params != null && params.isNotEmpty) sb.write(' $params');
  sb.write('::');
  if (message != null) sb.write(message);
  stdout.writeln(sb.toString());
}

void _appendToFile(String filePath, String value) {
  final file = File(filePath);
  if (!file.existsSync()) {
    throw Exception('Missing file at path: $file');
  }
  file.writeAsStringSync('$value$_eol', mode: FileMode.append);
}

String _prepareKeyValueMessage(String key, String value) {
  final delimiter =
      'ghadelimiter_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1000000)}';
  if (key.contains(delimiter) || value.contains(delimiter)) {
    throw Exception(
      'Neither the key nor the value of a command should contain the delimiter',
    );
  }
  return '$key<<$delimiter$_eol$value$_eol$delimiter';
}
