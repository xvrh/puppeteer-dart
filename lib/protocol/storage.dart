import 'dart:async';
import '../src/connection.dart';
import 'browser.dart' as browser;
import 'network.dart' as network;

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
  Stream<String> get onCacheStorageListUpdated => _client.onEvent
      .where((event) => event.name == 'Storage.cacheStorageListUpdated')
      .map((event) => event.parameters['origin'] as String);

  /// The origin's IndexedDB object store has been modified.
  Stream<IndexedDBContentUpdatedEvent> get onIndexedDBContentUpdated => _client
      .onEvent
      .where((event) => event.name == 'Storage.indexedDBContentUpdated')
      .map((event) => IndexedDBContentUpdatedEvent.fromJson(event.parameters));

  /// The origin's IndexedDB database list has been modified.
  Stream<String> get onIndexedDBListUpdated => _client.onEvent
      .where((event) => event.name == 'Storage.indexedDBListUpdated')
      .map((event) => event.parameters['origin'] as String);

  /// One of the interest groups was accessed by the associated page.
  Stream<InterestGroupAccessedEvent> get onInterestGroupAccessed => _client
      .onEvent
      .where((event) => event.name == 'Storage.interestGroupAccessed')
      .map((event) => InterestGroupAccessedEvent.fromJson(event.parameters));

  /// Clears storage for origin.
  /// [origin] Security origin.
  /// [storageTypes] Comma separated list of StorageType to clear.
  Future<void> clearDataForOrigin(String origin, String storageTypes) async {
    await _client.send('Storage.clearDataForOrigin', {
      'origin': origin,
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

  /// Registers origin to be notified when an update occurs to its IndexedDB.
  /// [origin] Security origin.
  Future<void> trackIndexedDBForOrigin(String origin) async {
    await _client.send('Storage.trackIndexedDBForOrigin', {
      'origin': origin,
    });
  }

  /// Unregisters origin from receiving notifications for cache storage.
  /// [origin] Security origin.
  Future<void> untrackCacheStorageForOrigin(String origin) async {
    await _client.send('Storage.untrackCacheStorageForOrigin', {
      'origin': origin,
    });
  }

  /// Unregisters origin from receiving notifications for IndexedDB.
  /// [origin] Security origin.
  Future<void> untrackIndexedDBForOrigin(String origin) async {
    await _client.send('Storage.untrackIndexedDBForOrigin', {
      'origin': origin,
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
}

class CacheStorageContentUpdatedEvent {
  /// Origin to update.
  final String origin;

  /// Name of cache in origin.
  final String cacheName;

  CacheStorageContentUpdatedEvent(
      {required this.origin, required this.cacheName});

  factory CacheStorageContentUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return CacheStorageContentUpdatedEvent(
      origin: json['origin'] as String,
      cacheName: json['cacheName'] as String,
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

  IndexedDBContentUpdatedEvent(
      {required this.origin,
      required this.databaseName,
      required this.objectStoreName});

  factory IndexedDBContentUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return IndexedDBContentUpdatedEvent(
      origin: json['origin'] as String,
      databaseName: json['databaseName'] as String,
      objectStoreName: json['objectStoreName'] as String,
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

/// Enum of possible storage types.
class StorageType {
  static const appcache = StorageType._('appcache');
  static const cookies = StorageType._('cookies');
  static const fileSystems = StorageType._('file_systems');
  static const indexeddb = StorageType._('indexeddb');
  static const localStorage = StorageType._('local_storage');
  static const shaderCache = StorageType._('shader_cache');
  static const websql = StorageType._('websql');
  static const serviceWorkers = StorageType._('service_workers');
  static const cacheStorage = StorageType._('cache_storage');
  static const interestGroups = StorageType._('interest_groups');
  static const all = StorageType._('all');
  static const other = StorageType._('other');
  static const values = {
    'appcache': appcache,
    'cookies': cookies,
    'file_systems': fileSystems,
    'indexeddb': indexeddb,
    'local_storage': localStorage,
    'shader_cache': shaderCache,
    'websql': websql,
    'service_workers': serviceWorkers,
    'cache_storage': cacheStorage,
    'interest_groups': interestGroups,
    'all': all,
    'other': other,
  };

  final String value;

  const StorageType._(this.value);

  factory StorageType.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is StorageType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

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
class InterestGroupAccessType {
  static const join = InterestGroupAccessType._('join');
  static const leave = InterestGroupAccessType._('leave');
  static const update = InterestGroupAccessType._('update');
  static const bid = InterestGroupAccessType._('bid');
  static const win = InterestGroupAccessType._('win');
  static const values = {
    'join': join,
    'leave': leave,
    'update': update,
    'bid': bid,
    'win': win,
  };

  final String value;

  const InterestGroupAccessType._(this.value);

  factory InterestGroupAccessType.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is InterestGroupAccessType && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

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
