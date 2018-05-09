import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';

class StorageManager {
  final Client _client;

  StorageManager(this._client);

  /// A cache's contents have been modified.
  Stream<CacheStorageContentUpdatedEvent> get onCacheStorageContentUpdated =>
      _client.onEvent
          .where((Event event) =>
              event.name == 'Storage.cacheStorageContentUpdated')
          .map((Event event) =>
              new CacheStorageContentUpdatedEvent.fromJson(event.parameters));

  /// A cache has been added/deleted.
  Stream<String> get onCacheStorageListUpdated => _client.onEvent
      .where((Event event) => event.name == 'Storage.cacheStorageListUpdated')
      .map((Event event) => event.parameters['origin'] as String);

  /// The origin's IndexedDB object store has been modified.
  Stream<IndexedDBContentUpdatedEvent> get onIndexedDBContentUpdated => _client
      .onEvent
      .where((Event event) => event.name == 'Storage.indexedDBContentUpdated')
      .map((Event event) =>
          new IndexedDBContentUpdatedEvent.fromJson(event.parameters));

  /// The origin's IndexedDB database list has been modified.
  Stream<String> get onIndexedDBListUpdated => _client.onEvent
      .where((Event event) => event.name == 'Storage.indexedDBListUpdated')
      .map((Event event) => event.parameters['origin'] as String);

  /// Clears storage for origin.
  /// [origin] Security origin.
  /// [storageTypes] Comma separated origin names.
  Future clearDataForOrigin(
    String origin,
    String storageTypes,
  ) async {
    Map parameters = {
      'origin': origin,
      'storageTypes': storageTypes,
    };
    await _client.send('Storage.clearDataForOrigin', parameters);
  }

  /// Returns usage and quota in bytes.
  /// [origin] Security origin.
  Future<GetUsageAndQuotaResult> getUsageAndQuota(
    String origin,
  ) async {
    Map parameters = {
      'origin': origin,
    };
    Map result = await _client.send('Storage.getUsageAndQuota', parameters);
    return new GetUsageAndQuotaResult.fromJson(result);
  }

  /// Registers origin to be notified when an update occurs to its cache storage list.
  /// [origin] Security origin.
  Future trackCacheStorageForOrigin(
    String origin,
  ) async {
    Map parameters = {
      'origin': origin,
    };
    await _client.send('Storage.trackCacheStorageForOrigin', parameters);
  }

  /// Registers origin to be notified when an update occurs to its IndexedDB.
  /// [origin] Security origin.
  Future trackIndexedDBForOrigin(
    String origin,
  ) async {
    Map parameters = {
      'origin': origin,
    };
    await _client.send('Storage.trackIndexedDBForOrigin', parameters);
  }

  /// Unregisters origin from receiving notifications for cache storage.
  /// [origin] Security origin.
  Future untrackCacheStorageForOrigin(
    String origin,
  ) async {
    Map parameters = {
      'origin': origin,
    };
    await _client.send('Storage.untrackCacheStorageForOrigin', parameters);
  }

  /// Unregisters origin from receiving notifications for IndexedDB.
  /// [origin] Security origin.
  Future untrackIndexedDBForOrigin(
    String origin,
  ) async {
    Map parameters = {
      'origin': origin,
    };
    await _client.send('Storage.untrackIndexedDBForOrigin', parameters);
  }
}

class CacheStorageContentUpdatedEvent {
  /// Origin to update.
  final String origin;

  /// Name of cache in origin.
  final String cacheName;

  CacheStorageContentUpdatedEvent({
    @required this.origin,
    @required this.cacheName,
  });

  factory CacheStorageContentUpdatedEvent.fromJson(Map json) {
    return new CacheStorageContentUpdatedEvent(
      origin: json['origin'],
      cacheName: json['cacheName'],
    );
  }
}

class IndexedDBContentUpdatedEvent {
  /// Origin to update.
  final String origin;

  /// Database to update.
  final String databaseName;

  /// ObjectStore to update.
  final String objectStoreName;

  IndexedDBContentUpdatedEvent({
    @required this.origin,
    @required this.databaseName,
    @required this.objectStoreName,
  });

  factory IndexedDBContentUpdatedEvent.fromJson(Map json) {
    return new IndexedDBContentUpdatedEvent(
      origin: json['origin'],
      databaseName: json['databaseName'],
      objectStoreName: json['objectStoreName'],
    );
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

  factory GetUsageAndQuotaResult.fromJson(Map json) {
    return new GetUsageAndQuotaResult(
      usage: json['usage'],
      quota: json['quota'],
      usageBreakdown: (json['usageBreakdown'] as List)
          .map((e) => new UsageForType.fromJson(e))
          .toList(),
    );
  }
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
  static const values = const {
    'appcache': appcache,
    'cookies': cookies,
    'file_systems': fileSystems,
    'indexeddb': indexeddb,
    'local_storage': localStorage,
    'shader_cache': shaderCache,
    'websql': websql,
    'service_workers': serviceWorkers,
    'cache_storage': cacheStorage,
    'all': all,
    'other': other,
  };

  final String value;

  const StorageType._(this.value);

  factory StorageType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  String toString() => value.toString();
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

  factory UsageForType.fromJson(Map json) {
    return new UsageForType(
      storageType: new StorageType.fromJson(json['storageType']),
      usage: json['usage'],
    );
  }

  Map toJson() {
    Map json = {
      'storageType': storageType.toJson(),
      'usage': usage,
    };
    return json;
  }
}
