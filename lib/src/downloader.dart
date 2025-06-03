import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

const _lastVersion = '137.0.7151.68';

class DownloadedBrowserInfo {
  final String executablePath;
  final String folderPath;
  final String version;

  DownloadedBrowserInfo({
    required this.executablePath,
    required this.folderPath,
    required this.version,
  });
}

///
/// Downloads the chrome revision specified by [revision] to the [cachePath] directory.
/// ```dart
/// await downloadChrome(
///   version: '112.0.5615.121',
///   cachePath: '.local-chrome',
///   onDownloadProgress: (received, total) {
///     print('downloaded $received of $total bytes');
///   });
/// ```
Future<DownloadedBrowserInfo> downloadChrome({
  String? version,
  String? cachePath,
  void Function(int received, int total)? onDownloadProgress,
  BrowserPlatform? platform,
}) async {
  version ??= _lastVersion;
  cachePath ??= '.local-chrome';
  platform ??= BrowserPlatform.current;

  var revisionDirectory = Directory(p.join(cachePath, version));
  if (!revisionDirectory.existsSync()) {
    revisionDirectory.createSync(recursive: true);
  }

  var exePath = p.join(revisionDirectory.path, getExecutablePath(platform));

  var executableFile = File(exePath);

  if (!executableFile.existsSync()) {
    var url = _downloadUrl(platform, version);
    var zipPath = p.join(revisionDirectory.path, p.url.basename(url));
    await _downloadFile(url, zipPath, onDownloadProgress);
    _unzip(zipPath, revisionDirectory.path);
    File(zipPath).deleteSync();
  }

  if (!executableFile.existsSync()) {
    throw Exception("$exePath doesn't exist");
  }

  if (!Platform.isWindows) {
    await Process.run('chmod', ['+x', executableFile.absolute.path]);
  }

  if (Platform.isMacOS) {
    final chromeAppPath = executableFile.absolute.parent.parent.parent.path;

    await Process.run('xattr', ['-d', 'com.apple.quarantine', chromeAppPath]);
  }

  return DownloadedBrowserInfo(
    folderPath: revisionDirectory.path,
    executablePath: executableFile.path,
    version: version,
  );
}

Future<void> _downloadFile(
  String url,
  String output,
  void Function(int, int)? onReceiveProgress,
) async {
  final client = http.Client();
  final response = await client.send(http.Request('get', Uri.parse(url)));
  final totalBytes = response.contentLength ?? 0;
  final outputFile = File(output);
  var receivedBytes = 0;

  await response.stream
      .map((s) {
        receivedBytes += s.length;
        onReceiveProgress?.call(receivedBytes, totalBytes);
        return s;
      })
      .pipe(outputFile.openWrite());

  client.close();
  if (!outputFile.existsSync() || outputFile.lengthSync() == 0) {
    throw Exception('File was not downloaded from $url to $output');
  }
}

void _unzip(String path, String targetPath) {
  if (!Platform.isWindows) {
    // The _simpleUnzip doesn't support symlinks so we prefer a native command
    Process.runSync('unzip', [path, '-d', targetPath]);
  } else {
    try {
      var result = Process.runSync('tar', ['-xf', path, '-C', targetPath]);
      if (result.exitCode != 0) {
        throw Exception('Failed to unzip chrome binaries:\n${result.stderr}');
      }
    } on ProcessException {
      _simpleUnzip(path, targetPath);
    }
  }
}

//TODO(xha): implement a more complete unzip
//https://github.com/maxogden/extract-zip/blob/master/index.js
void _simpleUnzip(String path, String targetPath) {
  var targetDirectory = Directory(targetPath);
  if (targetDirectory.existsSync()) {
    targetDirectory.deleteSync(recursive: true);
  }

  var bytes = File(path).readAsBytesSync();
  var archive = ZipDecoder().decodeBytes(bytes);

  for (var file in archive) {
    var filename = file.name;
    var data = file.content as List<int>;
    if (data.isNotEmpty) {
      File(p.join(targetPath, filename))
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    }
  }
}

const _baseUrl = 'https://storage.googleapis.com/chrome-for-testing-public';

String _downloadUrl(BrowserPlatform platform, String version) {
  return '$_baseUrl/$version/${platform.folder}/chrome-${platform.folder}.zip';
}

String getExecutablePath(BrowserPlatform platform) {
  return switch (platform) {
    BrowserPlatform.macArm64 || BrowserPlatform.macX64 => p.join(
      'chrome-${platform.folder}',
      'Google Chrome for Testing.app',
      'Contents',
      'MacOS',
      'Google Chrome for Testing',
    ),
    BrowserPlatform.linux64 => p.join('chrome-${platform.folder}', 'chrome'),
    BrowserPlatform.windows32 || BrowserPlatform.windows64 => p.join(
      'chrome-${platform.folder}',
      'chrome.exe',
    ),
  };
}

enum BrowserPlatform {
  macArm64._('macos_arm64', 'mac-arm64'),
  macX64._('macos_x64', 'mac-x64'),
  linux64._('linux_x64', 'linux64'),
  windows32._('windows_ia32', 'win32'),
  windows64._('windows_x64', 'win64');

  final String dartPlatform;
  final String folder;

  const BrowserPlatform._(this.dartPlatform, this.folder);

  factory BrowserPlatform.fromDartPlatform(String versionStringFull) {
    final split = versionStringFull.split('"');
    if (split.length < 2) {
      throw FormatException(
        "Unknown version from Platform.version '$versionStringFull'.",
      );
    }
    final versionString = split[1];
    return values.firstWhere(
      (e) => e.dartPlatform == versionString,
      orElse:
          () =>
              throw FormatException(
                "Unknown '$versionString' from Platform.version"
                " '$versionStringFull'.",
              ),
    );
  }

  static final BrowserPlatform current = BrowserPlatform.fromDartPlatform(
    Platform.version,
  );
}
