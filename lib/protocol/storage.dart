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
          .map((event) =>
              CacheStorageContentUpdatedEvent.fromJson(event.parameters));

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
  Stream<IndexedDBListUpdatedEvent> get onIndexedDBListUpdated =>
      _client.onEvent
          .where((event) => event.name == 'Storage.indexedDBListUpdated')
          .map((event) => IndexedDBListUpdatedEvent.fromJson(event.parameters));

  /// One of the interest groups was accessed by the associated page.
  Stream<InterestGroupAccessedEvent> get onInterestGroupAccessed => _client
      .onEvent
      .where((event) => event.name == 'Storage.interestGroupAccessed')
      .map((event) => InterestGroupAccessedEvent.fromJson(event.parameters));

  /// Shared storage was accessed by the associated page.
  /// The following parameters are included in all events.
  Stream<SharedStorageAccessedEvent> get onSharedStorageAccessed => _client
      .onEvent
      .where((event) => event.name == 'Storage.sharedStorageAccessed')
      .map((event) => SharedStorageAccessedEvent.fromJson(event.parameters));

  Stream<StorageBucketInfo> get onStorageBucketCreatedOrUpdated => _client
      .onEvent
      .where((event) => event.name == 'Storage.storageBucketCreatedOrUpdated')
      .map((event) => StorageBucketInfo.fromJson(
          event.parameters['bucket'] as Map<String, dynamic>));

  Stream<String> get onStorageBucketDeleted => _client.onEvent
      .where((event) => event.name == 'Storage.storageBucketDeleted')
      .map((event) => event.parameters['bucketId'] as String);

  /// Returns a storage key given a frame id.
  Future<SerializedStorageKey> getStorageKeyForFrame(
      page.FrameId frameId) async {
    var result = await _client.send('Storage.getStorageKeyForFrame', {
      'frameId': frameId,
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
      String storageKey, String storageTypes) async {
    await _client.send('Storage.clearDataForStorageKey', {
      'storageKey': storageKey,
      'storageTypes': storageTypes,
    });
  }

  /// Returns all browser cookies.
  /// [browserContextId] Browser context to use when called on the browser endpoint.
  /// Returns: Array of cookie objects.
  Future<List<network.Cookie>> getCookies(
      {browser.BrowserContextID? browserContextId}) async {
    var result = await _client.send('Storage.getCookies', {
      if (browserContextId != null) 'browserContextId': browserContextId,
    });
    return (result['cookies'] as List)
        .map((e) => network.Cookie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Sets given cookies.
  /// [cookies] Cookies to be set.
  /// [browserContextId] Browser context to use when called on the browser endpoint.
  Future<void> setCookies(List<network.CookieParam> cookies,
      {browser.BrowserContextID? browserContextId}) async {
    await _client.send('Storage.setCookies', {
      'cookies': [...cookies],
      if (browserContextId != null) 'browserContextId': browserContextId,
    });
  }

  /// Clears cookies.
  /// [browserContextId] Browser context to use when called on the browser endpoint.
  Future<void> clearCookies(
      {browser.BrowserContextID? browserContextId}) async {
    await _client.send('Storage.clearCookies', {
      if (browserContextId != null) 'browserContextId': browserContextId,
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
      if (quotaSize != null) 'quotaSize': quotaSize,
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
    await _client.send('Storage.trackIndexedDBForOrigin', {
      'origin': origin,
    });
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
    await _client.send('Storage.untrackIndexedDBForOrigin', {
      'origin': origin,
    });
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

  /// Gets details for a named interest group.
  Future<InterestGroupDetails> getInterestGroupDetails(
      String ownerOrigin, String name) async {
    var result = await _client.send('Storage.getInterestGroupDetails', {
      'ownerOrigin': ownerOrigin,
      'name': name,
    });
    return InterestGroupDetails.fromJson(
        result['details'] as Map<String, dynamic>);
  }

  /// Enables/Disables issuing of interestGroupAccessed events.
  Future<void> setInterestGroupTracking(bool enable) async {
    await _client.send('Storage.setInterestGroupTracking', {
      'enable': enable,
    });
  }

  /// Gets metadata for an origin's shared storage.
  Future<SharedStorageMetadata> getSharedStorageMetadata(
      String ownerOrigin) async {
    var result = await _client.send('Storage.getSharedStorageMetadata', {
      'ownerOrigin': ownerOrigin,
    });
    return SharedStorageMetadata.fromJson(
        result['metadata'] as Map<String, dynamic>);
  }

  /// Gets the entries in an given origin's shared storage.
  Future<List<SharedStorageEntry>> getSharedStorageEntries(
      String ownerOrigin) async {
    var result = await _client.send('Storage.getSharedStorageEntries', {
      'ownerOrigin': ownerOrigin,
    });
    return (result['entries'] as List)
        .map((e) => SharedStorageEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Sets entry with `key` and `value` for a given origin's shared storage.
  /// [ignoreIfPresent] If `ignoreIfPresent` is included and true, then only sets the entry if
  /// `key` doesn't already exist.
  Future<void> setSharedStorageEntry(
      String ownerOrigin, String key, String value,
      {bool? ignoreIfPresent}) async {
    await _client.send('Storage.setSharedStorageEntry', {
      'ownerOrigin': ownerOrigin,
      'key': key,
      'value': value,
      if (ignoreIfPresent != null) 'ignoreIfPresent': ignoreIfPresent,
    });
  }

  /// Deletes entry for `key` (if it exists) for a given origin's shared storage.
  Future<void> deleteSharedStorageEntry(String ownerOrigin, String key) async {
    await _client.send('Storage.deleteSharedStorageEntry', {
      'ownerOrigin': ownerOrigin,
      'key': key,
    });
  }

  /// Clears all entries for a given origin's shared storage.
  Future<void> clearSharedStorageEntries(String ownerOrigin) async {
    await _client.send('Storage.clearSharedStorageEntries', {
      'ownerOrigin': ownerOrigin,
    });
  }

  /// Resets the budget for `ownerOrigin` by clearing all budget withdrawals.
  Future<void> resetSharedStorageBudget(String ownerOrigin) async {
    await _client.send('Storage.resetSharedStorageBudget', {
      'ownerOrigin': ownerOrigin,
    });
  }

  /// Enables/disables issuing of sharedStorageAccessed events.
  Future<void> setSharedStorageTracking(bool enable) async {
    await _client.send('Storage.setSharedStorageTracking', {
      'enable': enable,
    });
  }

  /// Set tracking for a storage key's buckets.
  Future<void> setStorageBucketTracking(String storageKey, bool enable) async {
    await _client.send('Storage.setStorageBucketTracking', {
      'storageKey': storageKey,
      'enable': enable,
    });
  }

  /// Deletes the Storage Bucket with the given storage key and bucket name.
  Future<void> deleteStorageBucket(String storageKey, String bucketName) async {
    await _client.send('Storage.deleteStorageBucket', {
      'storageKey': storageKey,
      'bucketName': bucketName,
    });
  }

  /// Deletes state for sites identified as potential bounce trackers, immediately.
  Future<List<String>> runBounceTrackingMitigations() async {
    var result = await _client.send('Storage.runBounceTrackingMitigations');
    return (result['deletedSites'] as List).map((e) => e as String).toList();
  }
}

class CacheStorageContentUpdatedEvent {
  /// Origin to update.
  final String origin;

  /// Storage key to update.
  final String storageKey;

  /// Name of cache in origin.
  final String cacheName;

  CacheStorageContentUpdatedEvent(
      {required this.origin,
      required this.storageKey,
      required this.cacheName});

  factory CacheStorageContentUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return CacheStorageContentUpdatedEvent(
      origin: json['origin'] as String,
      storageKey: json['storageKey'] as String,
      cacheName: json['cacheName'] as String,
    );
  }
}

class CacheStorageListUpdatedEvent {
  /// Origin to update.
  final String origin;

  /// Storage key to update.
  final String storageKey;

  CacheStorageListUpdatedEvent(
      {required this.origin, required this.storageKey});

  factory CacheStorageListUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return CacheStorageListUpdatedEvent(
      origin: json['origin'] as String,
      storageKey: json['storageKey'] as String,
    );
  }
}

class IndexedDBContentUpdatedEvent {
  /// Origin to update.
  final String origin;

  /// Storage key to update.
  final String storageKey;

  /// Database to update.
  final String databaseName;

  /// ObjectStore to update.
  final String objectStoreName;

  IndexedDBContentUpdatedEvent(
      {required this.origin,
      required this.storageKey,
      required this.databaseName,
      required this.objectStoreName});

  factory IndexedDBContentUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return IndexedDBContentUpdatedEvent(
      origin: json['origin'] as String,
      storageKey: json['storageKey'] as String,
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

  IndexedDBListUpdatedEvent({required this.origin, required this.storageKey});

  factory IndexedDBListUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return IndexedDBListUpdatedEvent(
      origin: json['origin'] as String,
      storageKey: json['storageKey'] as String,
    );
  }
}

class InterestGroupAccessedEvent {
  final network.TimeSinceEpoch accessTime;

  final InterestGroupAccessType type;

  final String ownerOrigin;

  final String name;

  InterestGroupAccessedEvent(
      {required this.accessTime,
      required this.type,
      required this.ownerOrigin,
      required this.name});

  factory InterestGroupAccessedEvent.fromJson(Map<String, dynamic> json) {
    return InterestGroupAccessedEvent(
      accessTime: network.TimeSinceEpoch.fromJson(json['accessTime'] as num),
      type: InterestGroupAccessType.fromJson(json['type'] as String),
      ownerOrigin: json['ownerOrigin'] as String,
      name: json['name'] as String,
    );
  }
}

class SharedStorageAccessedEvent {
  /// Time of the access.
  final network.TimeSinceEpoch accessTime;

  /// Enum value indicating the Shared Storage API method invoked.
  final SharedStorageAccessType type;

  /// DevTools Frame Token for the primary frame tree's root.
  final page.FrameId mainFrameId;

  /// Serialized origin for the context that invoked the Shared Storage API.
  final String ownerOrigin;

  /// The sub-parameters warapped by `params` are all optional and their
  /// presence/absence depends on `type`.
  final SharedStorageAccessParams params;

  SharedStorageAccessedEvent(
      {required this.accessTime,
      required this.type,
      required this.mainFrameId,
      required this.ownerOrigin,
      required this.params});

  factory SharedStorageAccessedEvent.fromJson(Map<String, dynamic> json) {
    return SharedStorageAccessedEvent(
      accessTime: network.TimeSinceEpoch.fromJson(json['accessTime'] as num),
      type: SharedStorageAccessType.fromJson(json['type'] as String),
      mainFrameId: page.FrameId.fromJson(json['mainFrameId'] as String),
      ownerOrigin: json['ownerOrigin'] as String,
      params: SharedStorageAccessParams.fromJson(
          json['params'] as Map<String, dynamic>),
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

  GetUsageAndQuotaResult(
      {required this.usage,
      required this.quota,
      required this.overrideActive,
      required this.usageBreakdown});

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

class SerializedStorageKey {
  final String value;

  SerializedStorageKey(this.value);

  factory SerializedStorageKey.fromJson(String value) =>
      SerializedStorageKey(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is SerializedStorageKey && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Enum of possible storage types.
enum StorageType {
  appcache('appcache'),
  cookies('cookies'),
  fileSystems('file_systems'),
  indexeddb('indexeddb'),
  localStorage('local_storage'),
  shaderCache('shader_cache'),
  websql('websql'),
  serviceWorkers('service_workers'),
  cacheStorage('cache_storage'),
  interestGroups('interest_groups'),
  sharedStorage('shared_storage'),
  storageBuckets('storage_buckets'),
  all('all'),
  other('other'),
  ;

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
    return {
      'storageType': storageType.toJson(),
      'usage': usage,
    };
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
    return {
      'issuerOrigin': issuerOrigin,
      'count': count,
    };
  }
}

/// Enum of interest group access types.
enum InterestGroupAccessType {
  join('join'),
  leave('leave'),
  update('update'),
  loaded('loaded'),
  bid('bid'),
  win('win'),
  ;

  final String value;

  const InterestGroupAccessType(this.value);

  factory InterestGroupAccessType.fromJson(String value) =>
      InterestGroupAccessType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Ad advertising element inside an interest group.
class InterestGroupAd {
  final String renderUrl;

  final String? metadata;

  InterestGroupAd({required this.renderUrl, this.metadata});

  factory InterestGroupAd.fromJson(Map<String, dynamic> json) {
    return InterestGroupAd(
      renderUrl: json['renderUrl'] as String,
      metadata:
          json.containsKey('metadata') ? json['metadata'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'renderUrl': renderUrl,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// The full details of an interest group.
class InterestGroupDetails {
  final String ownerOrigin;

  final String name;

  final network.TimeSinceEpoch expirationTime;

  final String joiningOrigin;

  final String? biddingUrl;

  final String? biddingWasmHelperUrl;

  final String? updateUrl;

  final String? trustedBiddingSignalsUrl;

  final List<String> trustedBiddingSignalsKeys;

  final String? userBiddingSignals;

  final List<InterestGroupAd> ads;

  final List<InterestGroupAd> adComponents;

  InterestGroupDetails(
      {required this.ownerOrigin,
      required this.name,
      required this.expirationTime,
      required this.joiningOrigin,
      this.biddingUrl,
      this.biddingWasmHelperUrl,
      this.updateUrl,
      this.trustedBiddingSignalsUrl,
      required this.trustedBiddingSignalsKeys,
      this.userBiddingSignals,
      required this.ads,
      required this.adComponents});

  factory InterestGroupDetails.fromJson(Map<String, dynamic> json) {
    return InterestGroupDetails(
      ownerOrigin: json['ownerOrigin'] as String,
      name: json['name'] as String,
      expirationTime:
          network.TimeSinceEpoch.fromJson(json['expirationTime'] as num),
      joiningOrigin: json['joiningOrigin'] as String,
      biddingUrl:
          json.containsKey('biddingUrl') ? json['biddingUrl'] as String : null,
      biddingWasmHelperUrl: json.containsKey('biddingWasmHelperUrl')
          ? json['biddingWasmHelperUrl'] as String
          : null,
      updateUrl:
          json.containsKey('updateUrl') ? json['updateUrl'] as String : null,
      trustedBiddingSignalsUrl: json.containsKey('trustedBiddingSignalsUrl')
          ? json['trustedBiddingSignalsUrl'] as String
          : null,
      trustedBiddingSignalsKeys: (json['trustedBiddingSignalsKeys'] as List)
          .map((e) => e as String)
          .toList(),
      userBiddingSignals: json.containsKey('userBiddingSignals')
          ? json['userBiddingSignals'] as String
          : null,
      ads: (json['ads'] as List)
          .map((e) => InterestGroupAd.fromJson(e as Map<String, dynamic>))
          .toList(),
      adComponents: (json['adComponents'] as List)
          .map((e) => InterestGroupAd.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerOrigin': ownerOrigin,
      'name': name,
      'expirationTime': expirationTime.toJson(),
      'joiningOrigin': joiningOrigin,
      'trustedBiddingSignalsKeys': [...trustedBiddingSignalsKeys],
      'ads': ads.map((e) => e.toJson()).toList(),
      'adComponents': adComponents.map((e) => e.toJson()).toList(),
      if (biddingUrl != null) 'biddingUrl': biddingUrl,
      if (biddingWasmHelperUrl != null)
        'biddingWasmHelperUrl': biddingWasmHelperUrl,
      if (updateUrl != null) 'updateUrl': updateUrl,
      if (trustedBiddingSignalsUrl != null)
        'trustedBiddingSignalsUrl': trustedBiddingSignalsUrl,
      if (userBiddingSignals != null) 'userBiddingSignals': userBiddingSignals,
    };
  }
}

/// Enum of shared storage access types.
enum SharedStorageAccessType {
  documentAddModule('documentAddModule'),
  documentSelectUrl('documentSelectURL'),
  documentRun('documentRun'),
  documentSet('documentSet'),
  documentAppend('documentAppend'),
  documentDelete('documentDelete'),
  documentClear('documentClear'),
  workletSet('workletSet'),
  workletAppend('workletAppend'),
  workletDelete('workletDelete'),
  workletClear('workletClear'),
  workletGet('workletGet'),
  workletKeys('workletKeys'),
  workletEntries('workletEntries'),
  workletLength('workletLength'),
  workletRemainingBudget('workletRemainingBudget'),
  ;

  final String value;

  const SharedStorageAccessType(this.value);

  factory SharedStorageAccessType.fromJson(String value) =>
      SharedStorageAccessType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Struct for a single key-value pair in an origin's shared storage.
class SharedStorageEntry {
  final String key;

  final String value;

  SharedStorageEntry({required this.key, required this.value});

  factory SharedStorageEntry.fromJson(Map<String, dynamic> json) {
    return SharedStorageEntry(
      key: json['key'] as String,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }
}

/// Details for an origin's shared storage.
class SharedStorageMetadata {
  final network.TimeSinceEpoch creationTime;

  final int length;

  final num remainingBudget;

  SharedStorageMetadata(
      {required this.creationTime,
      required this.length,
      required this.remainingBudget});

  factory SharedStorageMetadata.fromJson(Map<String, dynamic> json) {
    return SharedStorageMetadata(
      creationTime:
          network.TimeSinceEpoch.fromJson(json['creationTime'] as num),
      length: json['length'] as int,
      remainingBudget: json['remainingBudget'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creationTime': creationTime.toJson(),
      'length': length,
      'remainingBudget': remainingBudget,
    };
  }
}

/// Pair of reporting metadata details for a candidate URL for `selectURL()`.
class SharedStorageReportingMetadata {
  final String eventType;

  final String reportingUrl;

  SharedStorageReportingMetadata(
      {required this.eventType, required this.reportingUrl});

  factory SharedStorageReportingMetadata.fromJson(Map<String, dynamic> json) {
    return SharedStorageReportingMetadata(
      eventType: json['eventType'] as String,
      reportingUrl: json['reportingUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType,
      'reportingUrl': reportingUrl,
    };
  }
}

/// Bundles a candidate URL with its reporting metadata.
class SharedStorageUrlWithMetadata {
  /// Spec of candidate URL.
  final String url;

  /// Any associated reporting metadata.
  final List<SharedStorageReportingMetadata> reportingMetadata;

  SharedStorageUrlWithMetadata(
      {required this.url, required this.reportingMetadata});

  factory SharedStorageUrlWithMetadata.fromJson(Map<String, dynamic> json) {
    return SharedStorageUrlWithMetadata(
      url: json['url'] as String,
      reportingMetadata: (json['reportingMetadata'] as List)
          .map((e) => SharedStorageReportingMetadata.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'reportingMetadata': reportingMetadata.map((e) => e.toJson()).toList(),
    };
  }
}

/// Bundles the parameters for shared storage access events whose
/// presence/absence can vary according to SharedStorageAccessType.
class SharedStorageAccessParams {
  /// Spec of the module script URL.
  /// Present only for SharedStorageAccessType.documentAddModule.
  final String? scriptSourceUrl;

  /// Name of the registered operation to be run.
  /// Present only for SharedStorageAccessType.documentRun and
  /// SharedStorageAccessType.documentSelectURL.
  final String? operationName;

  /// The operation's serialized data in bytes (converted to a string).
  /// Present only for SharedStorageAccessType.documentRun and
  /// SharedStorageAccessType.documentSelectURL.
  final String? serializedData;

  /// Array of candidate URLs' specs, along with any associated metadata.
  /// Present only for SharedStorageAccessType.documentSelectURL.
  final List<SharedStorageUrlWithMetadata>? urlsWithMetadata;

  /// Key for a specific entry in an origin's shared storage.
  /// Present only for SharedStorageAccessType.documentSet,
  /// SharedStorageAccessType.documentAppend,
  /// SharedStorageAccessType.documentDelete,
  /// SharedStorageAccessType.workletSet,
  /// SharedStorageAccessType.workletAppend,
  /// SharedStorageAccessType.workletDelete, and
  /// SharedStorageAccessType.workletGet.
  final String? key;

  /// Value for a specific entry in an origin's shared storage.
  /// Present only for SharedStorageAccessType.documentSet,
  /// SharedStorageAccessType.documentAppend,
  /// SharedStorageAccessType.workletSet, and
  /// SharedStorageAccessType.workletAppend.
  final String? value;

  /// Whether or not to set an entry for a key if that key is already present.
  /// Present only for SharedStorageAccessType.documentSet and
  /// SharedStorageAccessType.workletSet.
  final bool? ignoreIfPresent;

  SharedStorageAccessParams(
      {this.scriptSourceUrl,
      this.operationName,
      this.serializedData,
      this.urlsWithMetadata,
      this.key,
      this.value,
      this.ignoreIfPresent});

  factory SharedStorageAccessParams.fromJson(Map<String, dynamic> json) {
    return SharedStorageAccessParams(
      scriptSourceUrl: json.containsKey('scriptSourceUrl')
          ? json['scriptSourceUrl'] as String
          : null,
      operationName: json.containsKey('operationName')
          ? json['operationName'] as String
          : null,
      serializedData: json.containsKey('serializedData')
          ? json['serializedData'] as String
          : null,
      urlsWithMetadata: json.containsKey('urlsWithMetadata')
          ? (json['urlsWithMetadata'] as List)
              .map((e) => SharedStorageUrlWithMetadata.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : null,
      key: json.containsKey('key') ? json['key'] as String : null,
      value: json.containsKey('value') ? json['value'] as String : null,
      ignoreIfPresent: json.containsKey('ignoreIfPresent')
          ? json['ignoreIfPresent'] as bool
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (scriptSourceUrl != null) 'scriptSourceUrl': scriptSourceUrl,
      if (operationName != null) 'operationName': operationName,
      if (serializedData != null) 'serializedData': serializedData,
      if (urlsWithMetadata != null)
        'urlsWithMetadata': urlsWithMetadata!.map((e) => e.toJson()).toList(),
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (ignoreIfPresent != null) 'ignoreIfPresent': ignoreIfPresent,
    };
  }
}

enum StorageBucketsDurability {
  relaxed('relaxed'),
  strict('strict'),
  ;

  final String value;

  const StorageBucketsDurability(this.value);

  factory StorageBucketsDurability.fromJson(String value) =>
      StorageBucketsDurability.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class StorageBucketInfo {
  final SerializedStorageKey storageKey;

  final String id;

  final String name;

  final bool isDefault;

  final network.TimeSinceEpoch expiration;

  /// Storage quota (bytes).
  final num quota;

  final bool persistent;

  final StorageBucketsDurability durability;

  StorageBucketInfo(
      {required this.storageKey,
      required this.id,
      required this.name,
      required this.isDefault,
      required this.expiration,
      required this.quota,
      required this.persistent,
      required this.durability});

  factory StorageBucketInfo.fromJson(Map<String, dynamic> json) {
    return StorageBucketInfo(
      storageKey: SerializedStorageKey.fromJson(json['storageKey'] as String),
      id: json['id'] as String,
      name: json['name'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      expiration: network.TimeSinceEpoch.fromJson(json['expiration'] as num),
      quota: json['quota'] as num,
      persistent: json['persistent'] as bool? ?? false,
      durability:
          StorageBucketsDurability.fromJson(json['durability'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storageKey': storageKey.toJson(),
      'id': id,
      'name': name,
      'isDefault': isDefault,
      'expiration': expiration.toJson(),
      'quota': quota,
      'persistent': persistent,
      'durability': durability.toJson(),
    };
  }
}
