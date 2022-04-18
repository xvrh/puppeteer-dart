import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class RevisionInfo {
  final String executablePath;
  final String folderPath;
  final int revision;

  RevisionInfo(
      {required this.executablePath,
      required this.folderPath,
      required this.revision});
}

const int _lastRevision = 982053;

Future<RevisionInfo> downloadChrome({int? revision, String? cachePath}) async {
  revision ??= _lastRevision;
  cachePath ??= '.local-chromium';

  var revisionDirectory = Directory(p.join(cachePath, '$revision'));
  if (!revisionDirectory.existsSync()) {
    revisionDirectory.createSync(recursive: true);
  }

  var exePath = getExecutablePath(revisionDirectory.path);

  var executableFile = File(exePath);

  if (!executableFile.existsSync()) {
    var url = _downloadUrl(revision);
    var zipPath = p.join(cachePath, '${revision}_${p.url.basename(url)}');
    await _downloadFile(url, zipPath);
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
      revision: revision);
}

Future _downloadFile(String url, String output) async {
  var client = http.Client();
  var response = await client.send(http.Request('get', Uri.parse(url)));
  var ouputFile = File(output);
  await response.stream.pipe(ouputFile.openWrite());
  client.close();

  if (!ouputFile.existsSync() || ouputFile.lengthSync() == 0) {
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

const _baseUrl = 'https://storage.googleapis.com/chromium-browser-snapshots';

String _downloadUrl(int revision) {
  if (Platform.isWindows) {
    return '$_baseUrl/Win_x64/$revision/chrome-win.zip';
  } else if (Platform.isLinux) {
    return '$_baseUrl/Linux_x64/$revision/chrome-linux.zip';
  } else if (Platform.isMacOS) {
    return '$_baseUrl/Mac/$revision/chrome-mac.zip';
  } else {
    throw UnsupportedError(
        "Can't download chrome for platform ${Platform.operatingSystem}");
  }
}

String getExecutablePath(String revisionPath) {
  if (Platform.isWindows) {
    return p.join(revisionPath, 'chrome-win', 'chrome.exe');
  } else if (Platform.isLinux) {
    return p.join(revisionPath, 'chrome-linux', 'chrome');
  } else if (Platform.isMacOS) {
    return p.join(revisionPath, 'chrome-mac', 'Chromium.app', 'Contents',
        'MacOS', 'Chromium');
  } else {
    throw UnsupportedError('Unknown platform ${Platform.operatingSystem}');
  }
}
