import 'dart:async';
import '../src/connection.dart';
import 'network.dart' as network;
import 'storage.dart' as storage;

class FileSystemApi {
  final Client _client;

  FileSystemApi(this._client);

  /// Returns: Returns the directory object at the path.
  Future<Directory> getDirectory(
    BucketFileSystemLocator bucketFileSystemLocator,
  ) async {
    var result = await _client.send('FileSystem.getDirectory', {
      'bucketFileSystemLocator': bucketFileSystemLocator,
    });
    return Directory.fromJson(result['directory'] as Map<String, dynamic>);
  }
}

class File {
  final String name;

  /// Timestamp
  final network.TimeSinceEpoch lastModified;

  /// Size in bytes
  final num size;

  final String type;

  File({
    required this.name,
    required this.lastModified,
    required this.size,
    required this.type,
  });

  factory File.fromJson(Map<String, dynamic> json) {
    return File(
      name: json['name'] as String,
      lastModified: network.TimeSinceEpoch.fromJson(
        json['lastModified'] as num,
      ),
      size: json['size'] as num,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastModified': lastModified.toJson(),
      'size': size,
      'type': type,
    };
  }
}

class Directory {
  final String name;

  final List<String> nestedDirectories;

  /// Files that are directly nested under this directory.
  final List<File> nestedFiles;

  Directory({
    required this.name,
    required this.nestedDirectories,
    required this.nestedFiles,
  });

  factory Directory.fromJson(Map<String, dynamic> json) {
    return Directory(
      name: json['name'] as String,
      nestedDirectories: (json['nestedDirectories'] as List)
          .map((e) => e as String)
          .toList(),
      nestedFiles: (json['nestedFiles'] as List)
          .map((e) => File.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nestedDirectories': [...nestedDirectories],
      'nestedFiles': nestedFiles.map((e) => e.toJson()).toList(),
    };
  }
}

class BucketFileSystemLocator {
  /// Storage key
  final storage.SerializedStorageKey storageKey;

  /// Bucket name. Not passing a `bucketName` will retrieve the default Bucket. (https://developer.mozilla.org/en-US/docs/Web/API/Storage_API#storage_buckets)
  final String? bucketName;

  /// Path to the directory using each path component as an array item.
  final List<String> pathComponents;

  BucketFileSystemLocator({
    required this.storageKey,
    this.bucketName,
    required this.pathComponents,
  });

  factory BucketFileSystemLocator.fromJson(Map<String, dynamic> json) {
    return BucketFileSystemLocator(
      storageKey: storage.SerializedStorageKey.fromJson(
        json['storageKey'] as String,
      ),
      bucketName: json.containsKey('bucketName')
          ? json['bucketName'] as String
          : null,
      pathComponents: (json['pathComponents'] as List)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storageKey': storageKey.toJson(),
      'pathComponents': [...pathComponents],
      if (bucketName != null) 'bucketName': bucketName,
    };
  }
}
