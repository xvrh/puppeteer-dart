import 'dart:convert';
import 'dart:io';
import 'package:github_actions_toolkit/github_actions_toolkit.dart' as gaction;
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
    gaction.setOutput('commit', 'roll to Chrome $stableVersion');
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
