import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:puppeteer/src/downloader.dart';
import 'package:test/test.dart';

void main() {
  test('defaultBrowserCachePath points under .dart_tool/puppeteer when '
      'running inside a Dart project', () {
    final path = defaultBrowserCachePath();

    expect(path, isNotNull);
    expect(p.isAbsolute(path), isTrue,
        reason: 'expected absolute path, got: $path');

    // When running via `dart test`, Isolate.packageConfigSync is set, so we
    // should resolve to the workspace's .dart_tool/puppeteer/local-chrome.
    final segments = p.split(path);
    final dartToolIdx = segments.lastIndexOf('.dart_tool');
    expect(dartToolIdx, isNot(-1),
        reason: 'expected ".dart_tool" segment in path: $path');
    expect(segments.sublist(dartToolIdx),
        equals(['.dart_tool', 'puppeteer', 'local-chrome']));
  });

  test("default path resolves under this project's .dart_tool", () {
    final path = defaultBrowserCachePath();
    final projectDartTool = Directory(
      p.join(Directory.current.path, '.dart_tool'),
    );
    // The path should be under the project root's .dart_tool (in this repo
    // there's no parent workspace, so packageConfig resolves to our own).
    expect(p.isWithin(projectDartTool.path, path), isTrue,
        reason:
            '$path should be inside ${projectDartTool.path}');
  });
}
