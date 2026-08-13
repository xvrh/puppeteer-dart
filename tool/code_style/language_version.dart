import 'dart:io';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

/// The language version of this package, the one `dart format` derives from the
/// `sdk` constraint in pubspec.yaml.
///
/// The generators run `package:dart_style` themselves, so they must format at
/// that same version. `DartFormatter.latestLanguageVersion` follows the
/// dart_style release instead, and a newer language version is formatted
/// differently — the generated code would no longer agree with `dart format`.
final Version packageLanguageVersion = _readPackageLanguageVersion();

Version _readPackageLanguageVersion() {
  var pubspec = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
  var sdkConstraint = (pubspec['environment'] as YamlMap)['sdk'] as String;
  var minimum = (VersionConstraint.parse(sdkConstraint) as VersionRange).min!;

  return Version(minimum.major, minimum.minor, 0);
}
