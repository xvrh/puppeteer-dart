import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

const _lastVersion = '148.0.7778.97';

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

/// Returns the default cache directory used by [downloadChrome] when no
/// `cachePath` is provided.
///
/// When a Dart package config is available at runtime (the normal case for
/// `dart test`, `flutter test`, `dart run`, `flutter run`, …), this resolves
/// to `<workspace-root>/.dart_tool/puppeteer/local-chrome` per Dart's
/// project-specific tool caching convention. In a workspace this is the
/// workspace root, so all member packages share a single Chrome download.
///
/// When no package config is available — which is the case for AOT-compiled
/// executables — this falls back to an OS-appropriate user cache directory.
String defaultBrowserCachePath() {
  final config = Isolate.packageConfigSync;
  if (config != null) {
    return config.resolve('puppeteer/local-chrome/').toFilePath();
  }
  return userBrowserCachePath();
}

/// Returns a machine-wide cache directory under the OS user cache, suitable
/// for sharing a single Chrome installation across multiple Dart projects or
/// git worktrees.
///
/// macOS: `~/Library/Caches/puppeteer/local-chrome`
/// Linux: `$XDG_CACHE_HOME/puppeteer/local-chrome` (or `~/.cache/...`)
/// Windows: `%LOCALAPPDATA%\puppeteer\local-chrome`
String userBrowserCachePath() {
  final env = Platform.environment;
  if (Platform.isMacOS) {
    final home = env['HOME'];
    if (home != null && home.isNotEmpty) {
      return p.join(home, 'Library', 'Caches', 'puppeteer', 'local-chrome');
    }
  } else if (Platform.isWindows) {
    final localAppData = env['LOCALAPPDATA'];
    if (localAppData != null && localAppData.isNotEmpty) {
      return p.join(localAppData, 'puppeteer', 'local-chrome');
    }
  } else {
    // Linux / other POSIX.
    final xdgCache = env['XDG_CACHE_HOME'];
    if (xdgCache != null && xdgCache.isNotEmpty) {
      return p.join(xdgCache, 'puppeteer', 'local-chrome');
    }
    final home = env['HOME'];
    if (home != null && home.isNotEmpty) {
      return p.join(home, '.cache', 'puppeteer', 'local-chrome');
    }
  }
  // Last resort: temp dir. Not ideal (potentially wiped on reboot) but better
  // than failing.
  return p.join(Directory.systemTemp.path, 'puppeteer', 'local-chrome');
}

///
/// Downloads the chrome revision specified by [version] to the [cachePath]
/// directory.
///
/// ```dart
/// await downloadChrome(
///   version: '112.0.5615.121',
///   cachePath: '.local-chrome',
///   onDownloadProgress: (received, total) {
///     print('downloaded $received of $total bytes');
///   });
/// ```
///
/// When [cachePath] is omitted, the default location is
/// `.dart_tool/puppeteer/local-chrome/` under the current Dart project (or
/// workspace root). For executables compiled to AOT — where the package
/// config isn't available at runtime — the default falls back to an OS
/// user cache directory (e.g. `~/Library/Caches/puppeteer` on macOS,
/// `~/.cache/puppeteer` on Linux, `%LOCALAPPDATA%\puppeteer` on Windows).
///
/// Concurrent calls (within the same isolate, across isolates in the same VM,
/// and across separate processes) are coordinated so that only one actually
/// downloads and unzips Chrome. Other callers wait for the in-flight download
/// to finish, then return a path to the same shared installation.
Future<DownloadedBrowserInfo> downloadChrome({
  String? version,
  String? cachePath,
  void Function(int received, int total)? onDownloadProgress,
  BrowserPlatform? platform,
}) async {
  version ??= _lastVersion;
  cachePath ??= defaultBrowserCachePath();
  platform ??= BrowserPlatform.current;

  final platformLocal = platform;
  return ensureBrowserDownloaded(
    cachePath: cachePath,
    version: version,
    executableRelPath: getExecutablePath(platformLocal),
    download: (partialDir) async {
      final url = _downloadUrl(platformLocal, version!);
      final zipPath = p.join(partialDir, p.url.basename(url));
      await _downloadFile(url, zipPath, onDownloadProgress);
      _unzip(zipPath, partialDir);
      File(zipPath).deleteSync();

      final exePath = p.join(partialDir, getExecutablePath(platformLocal));
      final executableFile = File(exePath);
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
    },
  );
}

/// Coordinates a browser download into [cachePath]/[version], ensuring at most
/// one caller (across isolates and processes) actually runs [download].
///
/// Coordination uses the filesystem so it works across processes: the owning
/// caller creates a `<version>.downloading` directory (atomic mkdir), runs
/// [download] inside it, then atomically renames it to `<version>`. Other
/// concurrent callers detect the existing directory and poll until the
/// executable appears (or until the dir is cleaned up after a failure).
///
/// [staleThreshold] guards against orphaned `<version>.downloading` directories
/// left behind by a crashed prior caller; if the directory's mtime is older
/// than this, it is removed and ownership is retried.
///
/// [waitTimeout] caps the total time a waiter will block.
Future<DownloadedBrowserInfo> ensureBrowserDownloaded({
  required String cachePath,
  required String version,
  required String executableRelPath,
  required Future<void> Function(String partialDir) download,
  Duration waitTimeout = const Duration(minutes: 15),
  Duration staleThreshold = const Duration(minutes: 15),
  Duration pollInterval = const Duration(milliseconds: 100),
}) {
  final key = '$cachePath|$version|$executableRelPath';
  final existing = _inFlightDownloads[key];
  if (existing != null) return existing;
  final future = _runEnsureDownloaded(
    cachePath: cachePath,
    version: version,
    executableRelPath: executableRelPath,
    download: download,
    waitTimeout: waitTimeout,
    staleThreshold: staleThreshold,
    pollInterval: pollInterval,
  );
  _inFlightDownloads[key] = future;
  // Use whenComplete to clear the cache entry whether the download succeeded
  // or failed. The Future returned by whenComplete is intentionally ignored
  // to avoid an "unhandled error" warning if the download throws — error
  // handling is the caller's responsibility on `future` itself.
  future.whenComplete(() {
    if (identical(_inFlightDownloads[key], future)) {
      _inFlightDownloads.remove(key);
    }
  }).ignore();
  return future;
}

final Map<String, Future<DownloadedBrowserInfo>> _inFlightDownloads = {};

Future<DownloadedBrowserInfo> _runEnsureDownloaded({
  required String cachePath,
  required String version,
  required String executableRelPath,
  required Future<void> Function(String partialDir) download,
  required Duration waitTimeout,
  required Duration staleThreshold,
  required Duration pollInterval,
}) async {
  final versionDir = Directory(p.join(cachePath, version));
  final exeFile = File(p.join(versionDir.path, executableRelPath));
  final downloadingDir = Directory(p.join(cachePath, '$version.downloading'));
  // Lock file is the atomic mutex. File.createSync(exclusive: true) maps to
  // O_CREAT|O_EXCL on POSIX and CREATE_NEW on Windows, both atomic across
  // processes and isolates.
  final lockFile = File(p.join(cachePath, '$version.downloading.lock'));

  DownloadedBrowserInfo result() => DownloadedBrowserInfo(
        executablePath: exeFile.path,
        folderPath: versionDir.path,
        version: version,
      );

  if (exeFile.existsSync()) return result();

  Directory(cachePath).createSync(recursive: true);

  final deadline = DateTime.now().add(waitTimeout);

  while (true) {
    if (exeFile.existsSync()) return result();
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException(
        'Timed out waiting for browser download to ${versionDir.path}. '
        'If a previous download crashed, delete ${lockFile.path} to retry.',
      );
    }

    var weOwn = false;
    try {
      lockFile.createSync(exclusive: true);
      weOwn = true;
    } on PathExistsException {
      // Another caller holds the lock — fall through to the waiter path.
    }

    if (weOwn) {
      try {
        // Clean any leftover state from a prior failed attempt.
        _safeDelete(downloadingDir);
        if (versionDir.existsSync() && !exeFile.existsSync()) {
          // <version>/ exists without exe — anomalous (rename is atomic).
          // Clean it up so our atomic rename below can succeed.
          _safeDelete(versionDir);
        }
        downloadingDir.createSync(recursive: true);

        await download(downloadingDir.path);
        final partialExe = File(p.join(downloadingDir.path, executableRelPath));
        if (!partialExe.existsSync()) {
          throw Exception(
            'Download callback completed but executable was not produced at '
            "'$executableRelPath' inside '${downloadingDir.path}'.",
          );
        }

        try {
          await downloadingDir.rename(versionDir.path);
        } on FileSystemException {
          if (versionDir.existsSync() && exeFile.existsSync()) {
            _safeDelete(downloadingDir);
          } else {
            rethrow;
          }
        }
        return result();
      } finally {
        _safeDelete(downloadingDir); // no-op if rename succeeded
        try {
          if (lockFile.existsSync()) lockFile.deleteSync();
        } on FileSystemException {
          // ignore
        }
      }
    }

    // Waiter path: poll until exe appears, lock disappears, or it goes stale.
    while (true) {
      if (DateTime.now().isAfter(deadline)) {
        throw TimeoutException(
          'Timed out waiting for another process to finish downloading '
          'browser to ${versionDir.path}. If a previous download crashed, '
          'delete ${lockFile.path} to retry.',
        );
      }
      await Future<void>.delayed(pollInterval);
      if (exeFile.existsSync()) return result();
      if (!lockFile.existsSync()) break;
      if (_isStaleFile(lockFile, staleThreshold)) {
        try {
          lockFile.deleteSync();
        } on FileSystemException {
          // Another caller already cleaned it up.
        }
        break;
      }
    }
  }
}

bool _isStaleFile(File f, Duration threshold) {
  try {
    final mtime = f.statSync().modified;
    return DateTime.now().difference(mtime) > threshold;
  } on FileSystemException {
    return false;
  }
}

void _safeDelete(FileSystemEntity entity) {
  try {
    if (entity is Directory) {
      if (entity.existsSync()) entity.deleteSync(recursive: true);
    } else if (entity is File) {
      if (entity.existsSync()) entity.deleteSync();
    }
  } on FileSystemException {
    // Ignore: another caller likely cleaned it up.
  }
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
      orElse: () => throw FormatException(
        "Unknown '$versionString' from Platform.version"
        " '$versionStringFull'.",
      ),
    );
  }

  static final BrowserPlatform current = BrowserPlatform.fromDartPlatform(
    Platform.version,
  );
}
