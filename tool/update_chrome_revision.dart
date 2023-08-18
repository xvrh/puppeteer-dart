import 'dart:convert';
import 'dart:io';

import 'package:github_actions_toolkit/github_actions_toolkit.dart' as gaction;
import 'package:http/http.dart';
import 'package:pub_semver/pub_semver.dart';

final _downloaderFile = File('lib/src/downloader.dart');
final _variablePrefix = 'const _lastVersion = ';
final _versionExtractor = RegExp("$_variablePrefix'([^']+)';");
String _replaceVersion(Version version) => "$_variablePrefix'$version';";

void main() async {
  var stableVersion = await _getVersionAndRevisionForStable();
  var currentVersion = await _readCurrentVersion();

  if (stableVersion > currentVersion) {
    var message = 'roll to Chrome $stableVersion';
    gaction.setOutput('commit', message);

    await _updateCurrentVersion(stableVersion);
  } else {
    print('No update needed. Current: $currentVersion, stable: $stableVersion');
  }
}

Future<Version> _getVersionAndRevisionForStable() async {
  var result = await read(Uri.parse(
      'https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions.json'));
  var json = jsonDecode(result);
  //ignore: avoid_dynamic_calls
  var version = json['channels']['Stable']['version'] as String;

  return Version.parse(version);
}

Future<Version> _readCurrentVersion() async {
  var content = await _downloaderFile.readAsString();

  var versionString = _versionExtractor.firstMatch(content)!.group(1)!;
  return Version.parse(versionString);
}


Future<void> _updateCurrentVersion(Version newVersion) async {
  var content = await _downloaderFile.readAsString();
  var newContent = content.replaceFirstMapped(content, (match) {
    return _replaceVersion(newVersion);
  });
  await _downloaderFile.writeAsString(newContent);
}
