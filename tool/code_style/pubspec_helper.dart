import 'dart:io';
import 'package:path/path.dart' as p;

List<File> findPubspecs(Directory root, {bool pubspecLock = false}) {
  return findPackages(root, 'pubspec' + (pubspecLock ? '.lock' : '.yaml'));
}

List<File> findPackages(Directory root, String fileName) {
  return _findPubspecs(root, fileName);
}

List<File> _findPubspecs(Directory root, String file) {
  List<File> results = [];
  List<FileSystemEntity> entities = root.listSync();
  bool hasPubspec = false;
  for (File entity in entities.where((FileSystemEntity f) => f is File)) {
    if (p.basename(entity.path) == file) {
      hasPubspec = true;
      results.add(entity);
    }
  }

  for (Directory dir
      in entities.where((FileSystemEntity f) => f is Directory)) {
    String dirName = p.basename(dir.path);

    if (!dirName.startsWith('.') &&
        !dirName.startsWith('_') &&
        (!hasPubspec || !const ['web', 'lib', 'test'].contains(dirName))) {
      results.addAll(_findPubspecs(dir, file));
    }
  }
  return results;
}
