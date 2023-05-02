import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

const _lastVersion = '112.0.5615.121';

class RevisionInfo {
  final String executablePath;
  final String folderPath;
  final String version;

  RevisionInfo(
      {required this.executablePath,
      required this.folderPath,
      required this.version});
}

///
/// Downloads the chrome revision specified by [revision] to the [cachePath] directory.
/// ```dart
/// await downloadChrome(
///   revision: 1083080,
///   cachePath: '.local-chromium',
///   onDownloadProgress: (received, total) {
///     print('downloaded $received of $total bytes');
///   });
/// ```
Future<RevisionInfo> downloadChrome({
  String? version,
  String? cachePath,
  void Function(int received, int total)? onDownloadProgress,
}) async {
  version ??= _lastVersion;
  cachePath ??= '.local-chromium';

  var revisionDirectory = Directory(p.join(cachePath, version));
  if (!revisionDirectory.existsSync()) {
    revisionDirectory.createSync(recursive: true);
  }

  var exePath = getExecutablePath(revisionDirectory.path);

  var executableFile = File(exePath);

  if (!executableFile.existsSync()) {
    var url = _downloadUrl(version);
    var zipPath = p.join(cachePath, '${version}_${p.url.basename(url)}');
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

  return RevisionInfo(
      folderPath: revisionDirectory.path,
      executablePath: executableFile.path,
      version: version);
}

Future _downloadFile(
  String url,
  String output,
  void Function(int, int)? onReceiveProgress,
) async {
  final client = http.Client();
  final response = await client.send(http.Request('get', Uri.parse(url)));
  final totalBytes = response.contentLength ?? 0;
  final outputFile = File(output);
  var receivedBytes = 0;

  await response.stream.map((s) {
    receivedBytes += s.length;
    onReceiveProgress?.call(receivedBytes, totalBytes);
    return s;
  }).pipe(outputFile.openWrite());

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
    _simpleUnzip(path, targetPath);
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

const _baseUrl = 'https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing';

String _downloadUrl(String version) {
  if (Platform.isWindows) {
    return '$_baseUrl/$version/win64/chrome-win64.zip';
  } else if (Platform.isLinux) {
    return '$_baseUrl/$version/linux64/chrome-linux64.zip';
  } else if (Platform.isMacOS) {
    return '$_baseUrl/$version/mac-x64/chrome-mac-x64.zip';
  } else {
    throw UnsupportedError(
        "Can't download chrome for platform ${Platform.operatingSystem}");
  }
}

String getExecutablePath(String revisionPath) {
  if (Platform.isWindows) {
    return p.join(revisionPath, 'chrome-win64', 'chrome.exe');
  } else if (Platform.isLinux) {
    return p.join(revisionPath, 'chrome-linux64', 'chrome');
  } else if (Platform.isMacOS) {
    return p.join(
        revisionPath,
        'chrome-mac-x64',
        'Google Chrome for Testing.app',
        'Contents',
        'MacOS',
        'Google Chrome for Testing');
  } else {
    throw UnsupportedError('Unknown platform ${Platform.operatingSystem}');
  }
}
