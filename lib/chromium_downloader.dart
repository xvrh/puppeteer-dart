import 'dart:async';
import 'dart:io';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';

const int _lastRevision = 497674;

Future<ChromiumPath> downloadChromium(
    {int revision: _lastRevision, String cachePath}) async {
  cachePath ??= p.join(Directory.systemTemp.path, 'local-chromium');

  Directory revisionDirectory =
      new Directory(p.join(cachePath, revision.toString()));
  if (!revisionDirectory.existsSync()) {
    revisionDirectory.createSync(recursive: true);
  }

  String executablePath = _executablePath(revisionDirectory.path);

  File executableFile = new File(executablePath);

  if (!executableFile.existsSync()) {
    String url = _downloadURLs(revision);
    String zipPath = p.join(cachePath, '${revision}_${p.basename(url)}');
    await _downloadFile(url, zipPath);
    _unzip(zipPath, revisionDirectory.path);
    new File(zipPath).deleteSync();
  }

  assert(executableFile.existsSync());
  return new ChromiumPath(
      folderPath: revisionDirectory.path,
      executablePath: executableFile.path,
      revision: revision);
}

Future _downloadFile(String url, String output) async {
  http.Client client = new http.Client();
  http.StreamedResponse response =
      await client.send(new http.Request('get', Uri.parse(url)));
  await response.stream.pipe(new File(output).openWrite());
}

void _unzip(String path, String targetPath) {
  Directory targetDirectory = new Directory(targetPath);
  if (targetDirectory.existsSync()) {
    targetDirectory.deleteSync(recursive: true);
  }

  List<int> bytes = new File(path).readAsBytesSync();
  Archive archive = new ZipDecoder().decodeBytes(bytes);

  for (ArchiveFile file in archive) {
    String filename = file.name;
    List<int> data = file.content;
    if (data.isNotEmpty) {
      new File(p.join(targetPath, filename))
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    }
  }
}

String _downloadURLs(int revision) {
  if (Platform.isWindows) {
    return 'https://storage.googleapis.com/chromium-browser-snapshots/Win_x64/$revision/chrome-win32.zip';
  } else if (Platform.isLinux) {
    return 'https://storage.googleapis.com/chromium-browser-snapshots/Linux_x64/$revision/chrome-linux.zip';
  } else if (Platform.isMacOS) {
    return 'https://storage.googleapis.com/chromium-browser-snapshots/Mac/$revision/chrome-mac.zip';
  } else {
    throw new UnsupportedError(
        "Can't download chromium for platform ${Platform.operatingSystem}");
  }
}

String _executablePath(String revisionPath) {
  if (Platform.isWindows) {
    return p.join(revisionPath, 'chrome-win32', 'chrome.exe');
  } else if (Platform.isLinux) {
    return p.join(revisionPath, 'chrome-linux', 'chrome');
  } else if (Platform.isMacOS) {
    return p.join(revisionPath, 'chrome-mac', 'Chromium.app', 'Contents',
        'MacOS', 'Chromium');
  } else {
    throw new UnsupportedError('Unknown platform ${Platform.operatingSystem}');
  }
}

class ChromiumPath {
  final String executablePath;
  final String folderPath;
  final int revision;

  ChromiumPath(
      {@required this.executablePath,
      @required this.folderPath,
      @required this.revision});
}
