import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';

class StorageManager {
  final Session _client;

  StorageManager(this._client);

  /// Clears storage for origin.
  /// [origin] Security origin.
  /// [storageTypes] Comma separated origin names.
  Future clearDataForOrigin(
    String origin,
    String storageTypes,
  ) async {
    Map parameters = {
      'origin': origin.toString(),
      'storageTypes': storageTypes.toString(),
    };
    await _client.send('Storage.clearDataForOrigin', parameters);
  }

  /// Returns usage and quota in bytes.
  /// [origin] Security origin.
  Future<GetUsageAndQuotaResult> getUsageAndQuota(
    String origin,
  ) async {
    Map parameters = {
      'origin': origin.toString(),
    };
    await _client.send('Storage.getUsageAndQuota', parameters);
  }

  /// Registers origin to be notified when an update occurs to its cache storage list.
  /// [origin] Security origin.
  Future trackCacheStorageForOrigin(
    String origin,
  ) async {
    Map parameters = {
      'origin': origin.toString(),
    };
    await _client.send('Storage.trackCacheStorageForOrigin', parameters);
  }

  /// Unregisters origin from receiving notifications for cache storage.
  /// [origin] Security origin.
  Future untrackCacheStorageForOrigin(
    String origin,
  ) async {
    Map parameters = {
      'origin': origin.toString(),
    };
    await _client.send('Storage.untrackCacheStorageForOrigin', parameters);
  }
}

class GetUsageAndQuotaResult {
  /// Storage usage (bytes).
  final num usage;

  /// Storage quota (bytes).
  final num quota;

  /// Storage usage per type (bytes).
  final List<UsageForType> usageBreakdown;

  GetUsageAndQuotaResult({
    @required this.usage,
    @required this.quota,
    @required this.usageBreakdown,
  });
}

/// Enum of possible storage types.
class StorageType {
  static const StorageType appcache = const StorageType._('appcache');
  static const StorageType cookies = const StorageType._('cookies');
  static const StorageType fileSystems = const StorageType._('file_systems');
  static const StorageType indexeddb = const StorageType._('indexeddb');
  static const StorageType localStorage = const StorageType._('local_storage');
  static const StorageType shaderCache = const StorageType._('shader_cache');
  static const StorageType websql = const StorageType._('websql');
  static const StorageType serviceWorkers =
      const StorageType._('service_workers');
  static const StorageType cacheStorage = const StorageType._('cache_storage');
  static const StorageType all = const StorageType._('all');
  static const StorageType other = const StorageType._('other');

  final String value;

  const StorageType._(this.value);

  String toJson() => value;
}

/// Usage for a storage type.
class UsageForType {
  /// Name of storage type.
  final StorageType storageType;

  /// Storage usage (bytes).
  final num usage;

  UsageForType({
    @required this.storageType,
    @required this.usage,
  });

  Map toJson() {
    Map json = {
      'storageType': storageType.toJson(),
      'usage': usage.toString(),
    };
    return json;
  }
}
