import 'dart:async';
import '../src/connection.dart';
import 'browser.dart' as browser;
import 'network.dart' as network;
import 'page.dart' as page;

class StorageApi {
  final Client _client;

  StorageApi(this._client);

  /// A cache's contents have been modified.
  Stream<CacheStorageContentUpdatedEvent> get onCacheStorageContentUpdated =>
      _client.onEvent
          .where((event) => event.name == 'Storage.cacheStorageContentUpdated')
          .map(
            (event) =>
                CacheStorageContentUpdatedEvent.fromJson(event.parameters),
          );

  /// A cache has been added/deleted.
  Stream<CacheStorageListUpdatedEvent> get onCacheStorageListUpdated => _client
      .onEvent
      .where((event) => event.name == 'Storage.cacheStorageListUpdated')
      .map((event) => CacheStorageListUpdatedEvent.fromJson(event.parameters));

  /// The origin's IndexedDB object store has been modified.
  Stream<IndexedDBContentUpdatedEvent> get onIndexedDBContentUpdated => _client
      .onEvent
      .where((event) => event.name == 'Storage.indexedDBContentUpdated')
      .map((event) => IndexedDBContentUpdatedEvent.fromJson(event.parameters));

  /// The origin's IndexedDB database list has been modified.
  Stream<IndexedDBListUpdatedEvent> get onIndexedDBListUpdated => _client
      .onEvent
      .where((event) => event.name == 'Storage.indexedDBListUpdated')
      .map((event) => IndexedDBListUpdatedEvent.fromJson(event.parameters));

  Stream<StorageBucketInfo> get onStorageBucketCreatedOrUpdated => _client
      .onEvent
      .where((event) => event.name == 'Storage.storageBucketCreatedOrUpdated')
      .map(
        (event) => StorageBucketInfo.fromJson(
          event.parameters['bucketInfo'] as Map<String, dynamic>,
        ),
      );

  Stream<String> get onStorageBucketDeleted => _client.onEvent
      .where((event) => event.name == 'Storage.storageBucketDeleted')
      .map((event) => event.parameters['bucketId'] as String);

  /// Returns a storage key given a frame id.
  /// Deprecated. Please use Storage.getStorageKey instead.
  @Deprecated('use Storage.getStorageKey instead')
  Future<SerializedStorageKey> getStorageKeyForFrame(
    page.FrameId frameId,
  ) async {
    var result = await _client.send('Storage.getStorageKeyForFrame', {
      'frameId': frameId,
    });
    return SerializedStorageKey.fromJson(result['storageKey'] as String);
  }

  /// Returns storage key for the given frame. If no frame ID is provided,
  /// the storage key of the target executing this command is returned.
  Future<SerializedStorageKey> getStorageKey({page.FrameId? frameId}) async {
    var result = await _client.send('Storage.getStorageKey', {
      'frameId': ?frameId,
    });
    return SerializedStorageKey.fromJson(result['storageKey'] as String);
  }

  /// Clears storage for origin.
  /// [origin] Security origin.
  /// [storageTypes] Comma separated list of StorageType to clear.
  Future<void> clearDataForOrigin(String origin, String storageTypes) async {
    await _client.send('Storage.clearDataForOrigin', {
      'origin': origin,
      'storageTypes': storageTypes,
    });
  }

  /// Clears storage for storage key.
  /// [storageKey] Storage key.
  /// [storageTypes] Comma separated list of StorageType to clear.
  Future<void> clearDataForStorageKey(
    String storageKey,
    String storageTypes,
  ) async {
    await _client.send('Storage.clearDataForStorageKey', {
      'storageKey': storageKey,
      'storageTypes': storageTypes,
    });
  }

  /// Returns all browser cookies.
  /// [browserContextId] Browser context to use when called on the browser endpoint.
  /// Returns: Array of cookie objects.
  Future<List<network.Cookie>> getCookies({
    browser.BrowserContextID? browserContextId,
  }) async {
    var result = await _client.send('Storage.getCookies', {
      'browserContextId': ?browserContextId,
    });
    return (result['cookies'] as List)
        .map((e) => network.Cookie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Sets given cookies.
  /// [cookies] Cookies to be set.
  /// [browserContextId] Browser context to use when called on the browser endpoint.
  Future<void> setCookies(
    List<network.CookieParam> cookies, {
    browser.BrowserContextID? browserContextId,
  }) async {
    await _client.send('Storage.setCookies', {
      'cookies': [...cookies],
      'browserContextId': ?browserContextId,
    });
  }

  /// Clears cookies.
  /// [browserContextId] Browser context to use when called on the browser endpoint.
  Future<void> clearCookies({
    browser.BrowserContextID? browserContextId,
  }) async {
    await _client.send('Storage.clearCookies', {
      'browserContextId': ?browserContextId,
    });
  }

  /// Returns usage and quota in bytes.
  /// [origin] Security origin.
  Future<GetUsageAndQuotaResult> getUsageAndQuota(String origin) async {
    var result = await _client.send('Storage.getUsageAndQuota', {
      'origin': origin,
    });
    return GetUsageAndQuotaResult.fromJson(result);
  }

  /// Override quota for the specified origin
  /// [origin] Security origin.
  /// [quotaSize] The quota size (in bytes) to override the original quota with.
  /// If this is called multiple times, the overridden quota will be equal to
  /// the quotaSize provided in the final call. If this is called without
  /// specifying a quotaSize, the quota will be reset to the default value for
  /// the specified origin. If this is called multiple times with different
  /// origins, the override will be maintained for each origin until it is
  /// disabled (called without a quotaSize).
  Future<void> overrideQuotaForOrigin(String origin, {num? quotaSize}) async {
    await _client.send('Storage.overrideQuotaForOrigin', {
      'origin': origin,
      'quotaSize': ?quotaSize,
    });
  }

  /// Registers origin to be notified when an update occurs to its cache storage list.
  /// [origin] Security origin.
  Future<void> trackCacheStorageForOrigin(String origin) async {
    await _client.send('Storage.trackCacheStorageForOrigin', {
      'origin': origin,
    });
  }

  /// Registers storage key to be notified when an update occurs to its cache storage list.
  /// [storageKey] Storage key.
  Future<void> trackCacheStorageForStorageKey(String storageKey) async {
    await _client.send('Storage.trackCacheStorageForStorageKey', {
      'storageKey': storageKey,
    });
  }

  /// Registers origin to be notified when an update occurs to its IndexedDB.
  /// [origin] Security origin.
  Future<void> trackIndexedDBForOrigin(String origin) async {
    await _client.send('Storage.trackIndexedDBForOrigin', {'origin': origin});
  }

  /// Registers storage key to be notified when an update occurs to its IndexedDB.
  /// [storageKey] Storage key.
  Future<void> trackIndexedDBForStorageKey(String storageKey) async {
    await _client.send('Storage.trackIndexedDBForStorageKey', {
      'storageKey': storageKey,
    });
  }

  /// Unregisters origin from receiving notifications for cache storage.
  /// [origin] Security origin.
  Future<void> untrackCacheStorageForOrigin(String origin) async {
    await _client.send('Storage.untrackCacheStorageForOrigin', {
      'origin': origin,
    });
  }

  /// Unregisters storage key from receiving notifications for cache storage.
  /// [storageKey] Storage key.
  Future<void> untrackCacheStorageForStorageKey(String storageKey) async {
    await _client.send('Storage.untrackCacheStorageForStorageKey', {
      'storageKey': storageKey,
    });
  }

  /// Unregisters origin from receiving notifications for IndexedDB.
  /// [origin] Security origin.
  Future<void> untrackIndexedDBForOrigin(String origin) async {
    await _client.send('Storage.untrackIndexedDBForOrigin', {'origin': origin});
  }

  /// Unregisters storage key from receiving notifications for IndexedDB.
  /// [storageKey] Storage key.
  Future<void> untrackIndexedDBForStorageKey(String storageKey) async {
    await _client.send('Storage.untrackIndexedDBForStorageKey', {
      'storageKey': storageKey,
    });
  }

  /// Returns the number of stored Trust Tokens per issuer for the
  /// current browsing context.
  Future<List<TrustTokens>> getTrustTokens() async {
    var result = await _client.send('Storage.getTrustTokens');
    return (result['tokens'] as List)
        .map((e) => TrustTokens.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Removes all Trust Tokens issued by the provided issuerOrigin.
  /// Leaves other stored data, including the issuer's Redemption Records, intact.
  /// Returns: True if any tokens were deleted, false otherwise.
  Future<bool> clearTrustTokens(String issuerOrigin) async {
    var result = await _client.send('Storage.clearTrustTokens', {
      'issuerOrigin': issuerOrigin,
    });
    return result['didDeleteTokens'] as bool;
  }

  /// Set tracking for a storage key's buckets.
  Future<void> setStorageBucketTracking(String storageKey, bool enable) async {
    await _client.send('Storage.setStorageBucketTracking', {
      'storageKey': storageKey,
      'enable': enable,
    });
  }

  /// Deletes the Storage Bucket with the given storage key and bucket name.
  Future<void> deleteStorageBucket(StorageBucket bucket) async {
    await _client.send('Storage.deleteStorageBucket', {'bucket': bucket});
  }

  /// Deletes state for sites identified as potential bounce trackers, immediately.
  Future<List<String>> runBounceTrackingMitigations() async {
    var result = await _client.send('Storage.runBounceTrackingMitigations');
    return (result['deletedSites'] as List).map((e) => e as String).toList();
  }

  /// Returns the effective Related Website Sets in use by this profile for the browser
  /// session. The effective Related Website Sets will not change during a browser session.
  Future<List<RelatedWebsiteSet>> getRelatedWebsiteSets() async {
    var result = await _client.send('Storage.getRelatedWebsiteSets');
    return (result['sets'] as List)
        .map((e) => RelatedWebsiteSet.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class CacheStorageContentUpdatedEvent {
  /// Origin to update.
  final String origin;

  /// Storage key to update.
  final String storageKey;

  /// Storage bucket to update.
  final String bucketId;

  /// Name of cache in origin.
  final String cacheName;

  CacheStorageContentUpdatedEvent({
    required this.origin,
    required this.storageKey,
    required this.bucketId,
    required this.cacheName,
  });

  factory CacheStorageContentUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return CacheStorageContentUpdatedEvent(
      origin: json['origin'] as String,
      storageKey: json['storageKey'] as String,
      bucketId: json['bucketId'] as String,
      cacheName: json['cacheName'] as String,
    );
  }
}

class CacheStorageListUpdatedEvent {
  /// Origin to update.
  final String origin;

  /// Storage key to update.
  final String storageKey;

  /// Storage bucket to update.
  final String bucketId;

  CacheStorageListUpdatedEvent({
    required this.origin,
    required this.storageKey,
    required this.bucketId,
  });

  factory CacheStorageListUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return CacheStorageListUpdatedEvent(
      origin: json['origin'] as String,
      storageKey: json['storageKey'] as String,
      bucketId: json['bucketId'] as String,
    );
  }
}

class IndexedDBContentUpdatedEvent {
  /// Origin to update.
  final String origin;

  /// Storage key to update.
  final String storageKey;

  /// Storage bucket to update.
  final String bucketId;

  /// Database to update.
  final String databaseName;

  /// ObjectStore to update.
  final String objectStoreName;

  IndexedDBContentUpdatedEvent({
    required this.origin,
    required this.storageKey,
    required this.bucketId,
    required this.databaseName,
    required this.objectStoreName,
  });

  factory IndexedDBContentUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return IndexedDBContentUpdatedEvent(
      origin: json['origin'] as String,
      storageKey: json['storageKey'] as String,
      bucketId: json['bucketId'] as String,
      databaseName: json['databaseName'] as String,
      objectStoreName: json['objectStoreName'] as String,
    );
  }
}

class IndexedDBListUpdatedEvent {
  /// Origin to update.
  final String origin;

  /// Storage key to update.
  final String storageKey;

  /// Storage bucket to update.
  final String bucketId;

  IndexedDBListUpdatedEvent({
    required this.origin,
    required this.storageKey,
    required this.bucketId,
  });

  factory IndexedDBListUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return IndexedDBListUpdatedEvent(
      origin: json['origin'] as String,
      storageKey: json['storageKey'] as String,
      bucketId: json['bucketId'] as String,
    );
  }
}

class GetUsageAndQuotaResult {
  /// Storage usage (bytes).
  final num usage;

  /// Storage quota (bytes).
  final num quota;

  /// Whether or not the origin has an active storage quota override
  final bool overrideActive;

  /// Storage usage per type (bytes).
  final List<UsageForType> usageBreakdown;

  GetUsageAndQuotaResult({
    required this.usage,
    required this.quota,
    required this.overrideActive,
    required this.usageBreakdown,
  });

  factory GetUsageAndQuotaResult.fromJson(Map<String, dynamic> json) {
    return GetUsageAndQuotaResult(
      usage: json['usage'] as num,
      quota: json['quota'] as num,
      overrideActive: json['overrideActive'] as bool? ?? false,
      usageBreakdown: (json['usageBreakdown'] as List)
          .map((e) => UsageForType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

extension type SerializedStorageKey(String value) {
  factory SerializedStorageKey.fromJson(String value) =>
      SerializedStorageKey(value);

  String toJson() => value;
}

/// Enum of possible storage types.
enum StorageType {
  cookies('cookies'),
  fileSystems('file_systems'),
  indexeddb('indexeddb'),
  localStorage('local_storage'),
  shaderCache('shader_cache'),
  websql('websql'),
  serviceWorkers('service_workers'),
  cacheStorage('cache_storage'),
  storageBuckets('storage_buckets'),
  all('all'),
  other('other');

  final String value;

  const StorageType(this.value);

  factory StorageType.fromJson(String value) =>
      StorageType.values.firstWhere((e) => e.value == value);

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

  UsageForType({required this.storageType, required this.usage});

  factory UsageForType.fromJson(Map<String, dynamic> json) {
    return UsageForType(
      storageType: StorageType.fromJson(json['storageType'] as String),
      usage: json['usage'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {'storageType': storageType.toJson(), 'usage': usage};
  }
}

/// Pair of issuer origin and number of available (signed, but not used) Trust
/// Tokens from that issuer.
class TrustTokens {
  final String issuerOrigin;

  final num count;

  TrustTokens({required this.issuerOrigin, required this.count});

  factory TrustTokens.fromJson(Map<String, dynamic> json) {
    return TrustTokens(
      issuerOrigin: json['issuerOrigin'] as String,
      count: json['count'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {'issuerOrigin': issuerOrigin, 'count': count};
  }
}

enum StorageBucketsDurability {
  relaxed('relaxed'),
  strict('strict');

  final String value;

  const StorageBucketsDurability(this.value);

  factory StorageBucketsDurability.fromJson(String value) =>
      StorageBucketsDurability.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class StorageBucket {
  final SerializedStorageKey storageKey;

  /// If not specified, it is the default bucket of the storageKey.
  final String? name;

  StorageBucket({required this.storageKey, this.name});

  factory StorageBucket.fromJson(Map<String, dynamic> json) {
    return StorageBucket(
      storageKey: SerializedStorageKey.fromJson(json['storageKey'] as String),
      name: json.containsKey('name') ? json['name'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'storageKey': storageKey.toJson(), if (name != null) 'name': name};
  }
}

class StorageBucketInfo {
  final StorageBucket bucket;

  final String id;

  final network.TimeSinceEpoch expiration;

  /// Storage quota (bytes).
  final num quota;

  final bool persistent;

  final StorageBucketsDurability durability;

  StorageBucketInfo({
    required this.bucket,
    required this.id,
    required this.expiration,
    required this.quota,
    required this.persistent,
    required this.durability,
  });

  factory StorageBucketInfo.fromJson(Map<String, dynamic> json) {
    return StorageBucketInfo(
      bucket: StorageBucket.fromJson(json['bucket'] as Map<String, dynamic>),
      id: json['id'] as String,
      expiration: network.TimeSinceEpoch.fromJson(json['expiration'] as num),
      quota: json['quota'] as num,
      persistent: json['persistent'] as bool? ?? false,
      durability: StorageBucketsDurability.fromJson(
        json['durability'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket.toJson(),
      'id': id,
      'expiration': expiration.toJson(),
      'quota': quota,
      'persistent': persistent,
      'durability': durability.toJson(),
    };
  }
}

/// A single Related Website Set object.
class RelatedWebsiteSet {
  /// The primary site of this set, along with the ccTLDs if there is any.
  final List<String> primarySites;

  /// The associated sites of this set, along with the ccTLDs if there is any.
  final List<String> associatedSites;

  /// The service sites of this set, along with the ccTLDs if there is any.
  final List<String> serviceSites;

  RelatedWebsiteSet({
    required this.primarySites,
    required this.associatedSites,
    required this.serviceSites,
  });

  factory RelatedWebsiteSet.fromJson(Map<String, dynamic> json) {
    return RelatedWebsiteSet(
      primarySites: (json['primarySites'] as List)
          .map((e) => e as String)
          .toList(),
      associatedSites: (json['associatedSites'] as List)
          .map((e) => e as String)
          .toList(),
      serviceSites: (json['serviceSites'] as List)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primarySites': [...primarySites],
      'associatedSites': [...associatedSites],
      'serviceSites': [...serviceSites],
    };
  }
}
