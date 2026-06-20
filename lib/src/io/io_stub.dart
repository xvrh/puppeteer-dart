/// Web/WASM stub for the subset of `dart:io` used by this package.
///
/// These types exist so `package:puppeteer/puppeteer.dart` compiles to WASM.
/// Only `connect()` and DevTools-protocol page interaction are usable on the
/// web; anything that needs a real filesystem or a child process throws
/// [UnsupportedError]. Path-only helpers (`File.path`, `File.absolute`,
/// `parent`) work so callers can still build/inspect paths.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

Never _unsupported(String what) =>
    throw UnsupportedError('$what is not supported on the web/WASM platform');

class Platform {
  Platform._();

  static Map<String, String> get environment =>
      _unsupported('Platform.environment');
  static bool get isWindows => false;
  static bool get isMacOS => false;
  static bool get isLinux => false;
  static String get operatingSystem => _unsupported('Platform.operatingSystem');
  static String get version => _unsupported('Platform.version');
  static String get resolvedExecutable =>
      _unsupported('Platform.resolvedExecutable');
  static String get pathSeparator => '/';
  static int get numberOfProcessors =>
      _unsupported('Platform.numberOfProcessors');
}

class OSError {
  final String message;
  final int errorCode;
  const OSError([this.message = '', this.errorCode = 0]);
  @override
  String toString() => 'OS Error: $message, errno = $errorCode';
}

class IOException implements Exception {}

class FileSystemException implements IOException {
  final String message;
  final String? path;
  final OSError? osError;
  const FileSystemException([this.message = '', this.path, this.osError]);
  @override
  String toString() =>
      'FileSystemException: $message${path == null ? '' : ', path = $path'}';
}

class PathExistsException extends FileSystemException {
  const PathExistsException([super.message, super.path, super.osError]);
}

class PathNotFoundException extends FileSystemException {
  const PathNotFoundException([super.message, super.path, super.osError]);
}

class ProcessException implements IOException {
  final String executable;
  final List<String> arguments;
  final String message;
  final int errorCode;
  const ProcessException(
    this.executable,
    this.arguments, [
    this.message = '',
    this.errorCode = 0,
  ]);
  @override
  String toString() => 'ProcessException: $message';
}

abstract class FileSystemEntity {
  String get path;
  FileSystemEntity get absolute;
  Directory get parent => Directory(path);
  bool existsSync() => false;
  Future<bool> exists() async => false;
  void deleteSync({bool recursive = false}) => _unsupported('delete');
  Future<FileSystemEntity> delete({bool recursive = false}) =>
      _unsupported('delete');
  FileStat statSync() => _unsupported('statSync');

  static bool isFileSync(String path) => false;
  static bool isDirectorySync(String path) => false;
}

class File extends FileSystemEntity {
  @override
  final String path;
  File(this.path);

  @override
  File get absolute => this;

  Future<String> readAsString({Encoding encoding = utf8}) =>
      _unsupported('File.readAsString');
  String readAsStringSync({Encoding encoding = utf8}) =>
      _unsupported('File.readAsStringSync');
  Future<Uint8List> readAsBytes() => _unsupported('File.readAsBytes');
  Uint8List readAsBytesSync() => _unsupported('File.readAsBytesSync');
  Stream<List<int>> openRead([int? start, int? end]) =>
      _unsupported('File.openRead');
  IOSink openWrite({
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
  }) => _unsupported('File.openWrite');
  Future<File> writeAsBytes(
    List<int> bytes, {
    FileMode mode = FileMode.write,
    bool flush = false,
  }) => _unsupported('File.writeAsBytes');
  void writeAsBytesSync(
    List<int> bytes, {
    FileMode mode = FileMode.write,
    bool flush = false,
  }) => _unsupported('File.writeAsBytesSync');
  Future<File> writeAsString(
    String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) => _unsupported('File.writeAsString');
  Future<File> create({bool recursive = false, bool exclusive = false}) =>
      _unsupported('File.create');
  void createSync({bool recursive = false, bool exclusive = false}) =>
      _unsupported('File.createSync');
  @override
  Future<File> delete({bool recursive = false}) => _unsupported('File.delete');
  Future<File> rename(String newPath) => _unsupported('File.rename');
  File renameSync(String newPath) => _unsupported('File.renameSync');
  Future<int> length() => _unsupported('File.length');
  int lengthSync() => _unsupported('File.lengthSync');
}

class Directory extends FileSystemEntity {
  @override
  final String path;
  Directory(this.path);

  static Directory get current => _unsupported('Directory.current');
  static Directory get systemTemp => _unsupported('Directory.systemTemp');

  @override
  Directory get absolute => this;
  void createSync({bool recursive = false}) =>
      _unsupported('Directory.createSync');
  Future<Directory> create({bool recursive = false}) =>
      _unsupported('Directory.create');
  Directory createTempSync([String? prefix]) =>
      _unsupported('Directory.createTempSync');
  Future<Directory> createTemp([String? prefix]) =>
      _unsupported('Directory.createTemp');
  @override
  Future<Directory> delete({bool recursive = false}) =>
      _unsupported('Directory.delete');
  List<FileSystemEntity> listSync({
    bool recursive = false,
    bool followLinks = true,
  }) => _unsupported('Directory.listSync');
  Future<Directory> rename(String newPath) => _unsupported('Directory.rename');
}

class FileStat {
  DateTime get modified => _unsupported('FileStat.modified');
  int get size => _unsupported('FileStat.size');
}

class FileMode {
  final int mode;
  const FileMode._(this.mode);
  static const read = FileMode._(0);
  static const write = FileMode._(1);
  static const append = FileMode._(2);
  static const writeOnly = FileMode._(3);
  static const writeOnlyAppend = FileMode._(4);
}

class ProcessSignal {
  final String _name;
  const ProcessSignal._(this._name);
  static const sigkill = ProcessSignal._('SIGKILL');
  static const sigterm = ProcessSignal._('SIGTERM');
  @override
  String toString() => _name;
}

class ProcessResult {
  final int pid;
  final int exitCode;
  final dynamic stdout;
  final dynamic stderr;
  ProcessResult(this.pid, this.exitCode, this.stdout, this.stderr);
}

abstract class Process {
  int get pid;
  Future<int> get exitCode;
  Stream<List<int>> get stdout;
  Stream<List<int>> get stderr;
  IOSink get stdin;
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]);

  static Future<Process> start(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool runInShell = false,
  }) => _unsupported('Process.start');
  static Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool runInShell = false,
  }) => _unsupported('Process.run');
  static ProcessResult runSync(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool runInShell = false,
  }) => _unsupported('Process.runSync');
}

/// Minimal [IOSink]-compatible interface: a `Sink<List<int>>` that is also a
/// `StringSink`, matching the `dart:io` surface the package relies on.
abstract class IOSink implements StreamSink<List<int>>, StringSink {
  Encoding encoding = utf8;
}

IOSink get stdout => _unsupported('stdout');
IOSink get stderr => _unsupported('stderr');

int exitCode = 0;

/// No package config is available on the web/WASM platform.
Uri? packageConfigSync() => null;
