import 'dart:io';
import 'package:path/path.dart' as p;

class BrowserPath {
  static final _chrome = _BrowserPath(
    'chrome-stable',
    windows: _windowsPaths('Chrome'),
    macOS: _macOsPath('Google Chrome'),
    linux: _linuxPath('chrome'),
  );
  static final _chromeBeta = _BrowserPath(
    'chrome-beta',
    windows: _windowsPaths('Chrome Beta'),
    macOS: _macOsPath('Google Chrome Beta'),
    linux: _linuxPath('chrome-beta'),
  );
  static final _chromeDev = _BrowserPath(
    'chrome-dev',
    windows: _windowsPaths('Chrome Dev'),
    macOS: _macOsPath('Google Chrome Dev'),
    linux: _linuxPath('chrome-unstable'),
  );
  static final _chromeCanary = _BrowserPath(
    'chrome-canary',
    windows: _windowsPaths('Chrome SxS'),
    macOS: _macOsPath('Google Chrome Canary'),
    linux: [],
  );

  static String get chrome => _chrome.forPlatform;
  static String get chromeBeta => _chromeBeta.forPlatform;
  static String get chromeDev => _chromeDev.forPlatform;
  static String get chromeCanary => _chromeCanary.forPlatform;
}

List<String> _linuxPath(String folder) => ['/opt/google/$folder/chrome'];

List<String> _macOsPath(String folder) =>
    ['/Applications/$folder.app/Contents/MacOS/$folder'];

List<String> _windowsPaths(String folder) {
  var paths = <String>[];
  for (var envName in const [
    'LOCALAPPDATA',
    'PROGRAMFILES',
    'PROGRAMFILES(X86)'
  ]) {
    var env = Platform.environment[envName];
    if (env != null) {
      paths.add(p.join(env, 'Google\\$folder\\Application\\chrome.exe'));
    }
  }
  return paths;
}

class _BrowserPath {
  final String name;
  final List<String> windows;
  final List<String> linux;
  final List<String> macOS;

  _BrowserPath(this.name,
      {required this.windows, required this.linux, required this.macOS});

  List<String> get _possiblePaths {
    if (Platform.isLinux) {
      return linux;
    } else if (Platform.isMacOS) {
      return macOS;
    } else if (Platform.isWindows) {
      return windows;
    } else {
      throw Exception(
          'The platform ${Platform.operatingSystem} is not supported');
    }
  }

  String get forPlatform {
    var possiblePaths = _possiblePaths;
    for (var possiblePath in possiblePaths) {
      if (FileSystemEntity.isFileSync(possiblePath)) {
        return possiblePath;
      }
    }
    throw Exception(
        'Chrome $name is not installed on the system ${Platform.operatingSystem}');
  }
}
