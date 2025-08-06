import 'dart:async';
import '../src/connection.dart';
import 'browser.dart' as browser;
import 'network.dart' as network;
import 'page.dart' as page;
import 'target.dart' as target;

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

  /// One of the interest groups was accessed. Note that these events are global
  /// to all targets sharing an interest group store.
  Stream<InterestGroupAccessedEvent> get onInterestGroupAccessed => _client
      .onEvent
      .where((event) => event.name == 'Storage.interestGroupAccessed')
      .map((event) => InterestGroupAccessedEvent.fromJson(event.parameters));

  /// An auction involving interest groups is taking place. These events are
  /// target-specific.
  Stream<InterestGroupAuctionEventOccurredEvent>
  get onInterestGroupAuctionEventOccurred => _client.onEvent
      .where(
        (event) => event.name == 'Storage.interestGroupAuctionEventOccurred',
      )
      .map(
        (event) =>
            InterestGroupAuctionEventOccurredEvent.fromJson(event.parameters),
      );

  /// Specifies which auctions a particular network fetch may be related to, and
  /// in what role. Note that it is not ordered with respect to
  /// Network.requestWillBeSent (but will happen before loadingFinished
  /// loadingFailed).
  Stream<InterestGroupAuctionNetworkRequestCreatedEvent>
  get onInterestGroupAuctionNetworkRequestCreated => _client.onEvent
      .where(
        (event) =>
            event.name == 'Storage.interestGroupAuctionNetworkRequestCreated',
      )
      .map(
        (event) => InterestGroupAuctionNetworkRequestCreatedEvent.fromJson(
          event.parameters,
        ),
      );

  /// Shared storage was accessed by the associated page.
  /// The following parameters are included in all events.
  Stream<SharedStorageAccessedEvent> get onSharedStorageAccessed => _client
      .onEvent
      .where((event) => event.name == 'Storage.sharedStorageAccessed')
      .map((event) => SharedStorageAccessedEvent.fromJson(event.parameters));

  /// A shared storage run or selectURL operation finished its execution.
  /// The following parameters are included in all events.
  Stream<SharedStorageWorkletOperationExecutionFinishedEvent>
  get onSharedStorageWorkletOperationExecutionFinished => _client.onEvent
      .where(
        (event) =>
            event.name ==
            'Storage.sharedStorageWorkletOperationExecutionFinished',
      )
      .map(
        (event) => SharedStorageWorkletOperationExecutionFinishedEvent.fromJson(
          event.parameters,
        ),
      );

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

  Stream<AttributionReportingSourceRegisteredEvent>
  get onAttributionReportingSourceRegistered => _client.onEvent
      .where(
        (event) => event.name == 'Storage.attributionReportingSourceRegistered',
      )
      .map(
        (event) => AttributionReportingSourceRegisteredEvent.fromJson(
          event.parameters,
        ),
      );

  Stream<AttributionReportingTriggerRegisteredEvent>
  get onAttributionReportingTriggerRegistered => _client.onEvent
      .where(
        (event) =>
            event.name == 'Storage.attributionReportingTriggerRegistered',
      )
      .map(
        (event) => AttributionReportingTriggerRegisteredEvent.fromJson(
          event.parameters,
        ),
      );

  Stream<AttributionReportingReportSentEvent>
  get onAttributionReportingReportSent => _client.onEvent
      .where((event) => event.name == 'Storage.attributionReportingReportSent')
      .map(
        (event) =>
            AttributionReportingReportSentEvent.fromJson(event.parameters),
      );

  Stream<AttributionReportingVerboseDebugReportSentEvent>
  get onAttributionReportingVerboseDebugReportSent => _client.onEvent
      .where(
        (event) =>
            event.name == 'Storage.attributionReportingVerboseDebugReportSent',
      )
      .map(
        (event) => AttributionReportingVerboseDebugReportSentEvent.fromJson(
          event.parameters,
        ),
      );

  /// Returns a storage key given a frame id.
  Future<SerializedStorageKey> getStorageKeyForFrame(
    page.FrameId frameId,
  ) async {
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
      if (browserContextId != null) 'browserContextId': browserContextId,
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
      if (browserContextId != null) 'browserContextId': browserContextId,
    });
  }

  /// Clears cookies.
  /// [browserContextId] Browser context to use when called on the browser endpoint.
  Future<void> clearCookies({
    browser.BrowserContextID? browserContextId,
  }) async {
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

  /// Gets details for a named interest group.
  /// Returns: This largely corresponds to:
  /// https://wicg.github.io/turtledove/#dictdef-generatebidinterestgroup
  /// but has absolute expirationTime instead of relative lifetimeMs and
  /// also adds joiningOrigin.
  Future<Map<String, dynamic>> getInterestGroupDetails(
    String ownerOrigin,
    String name,
  ) async {
    var result = await _client.send('Storage.getInterestGroupDetails', {
      'ownerOrigin': ownerOrigin,
      'name': name,
    });
    return result['details'] as Map<String, dynamic>;
  }

  /// Enables/Disables issuing of interestGroupAccessed events.
  Future<void> setInterestGroupTracking(bool enable) async {
    await _client.send('Storage.setInterestGroupTracking', {'enable': enable});
  }

  /// Enables/Disables issuing of interestGroupAuctionEventOccurred and
  /// interestGroupAuctionNetworkRequestCreated.
  Future<void> setInterestGroupAuctionTracking(bool enable) async {
    await _client.send('Storage.setInterestGroupAuctionTracking', {
      'enable': enable,
    });
  }

  /// Gets metadata for an origin's shared storage.
  Future<SharedStorageMetadata> getSharedStorageMetadata(
    String ownerOrigin,
  ) async {
    var result = await _client.send('Storage.getSharedStorageMetadata', {
      'ownerOrigin': ownerOrigin,
    });
    return SharedStorageMetadata.fromJson(
      result['metadata'] as Map<String, dynamic>,
    );
  }

  /// Gets the entries in an given origin's shared storage.
  Future<List<SharedStorageEntry>> getSharedStorageEntries(
    String ownerOrigin,
  ) async {
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
    String ownerOrigin,
    String key,
    String value, {
    bool? ignoreIfPresent,
  }) async {
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
    await _client.send('Storage.setSharedStorageTracking', {'enable': enable});
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

  /// https://wicg.github.io/attribution-reporting-api/
  /// [enabled] If enabled, noise is suppressed and reports are sent immediately.
  Future<void> setAttributionReportingLocalTestingMode(bool enabled) async {
    await _client.send('Storage.setAttributionReportingLocalTestingMode', {
      'enabled': enabled,
    });
  }

  /// Enables/disables issuing of Attribution Reporting events.
  Future<void> setAttributionReportingTracking(bool enable) async {
    await _client.send('Storage.setAttributionReportingTracking', {
      'enable': enable,
    });
  }

  /// Sends all pending Attribution Reports immediately, regardless of their
  /// scheduled report time.
  /// Returns: The number of reports that were sent.
  Future<int> sendPendingAttributionReports() async {
    var result = await _client.send('Storage.sendPendingAttributionReports');
    return result['numSent'] as int;
  }

  /// Returns the effective Related Website Sets in use by this profile for the browser
  /// session. The effective Related Website Sets will not change during a browser session.
  Future<List<RelatedWebsiteSet>> getRelatedWebsiteSets() async {
    var result = await _client.send('Storage.getRelatedWebsiteSets');
    return (result['sets'] as List)
        .map((e) => RelatedWebsiteSet.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns the list of URLs from a page and its embedded resources that match
  /// existing grace period URL pattern rules.
  /// https://developers.google.com/privacy-sandbox/cookies/temporary-exceptions/grace-period
  /// [firstPartyUrl] The URL of the page currently being visited.
  /// [thirdPartyUrls] The list of embedded resource URLs from the page.
  /// Returns: Array of matching URLs. If there is a primary pattern match for the first-
  /// party URL, only the first-party URL is returned in the array.
  Future<List<String>> getAffectedUrlsForThirdPartyCookieMetadata(
    String firstPartyUrl,
    List<String> thirdPartyUrls,
  ) async {
    var result = await _client.send(
      'Storage.getAffectedUrlsForThirdPartyCookieMetadata',
      {
        'firstPartyUrl': firstPartyUrl,
        'thirdPartyUrls': [...thirdPartyUrls],
      },
    );
    return (result['matchedUrls'] as List).map((e) => e as String).toList();
  }

  Future<void> setProtectedAudienceKAnonymity(
    String owner,
    String name,
    List<String> hashes,
  ) async {
    await _client.send('Storage.setProtectedAudienceKAnonymity', {
      'owner': owner,
      'name': name,
      'hashes': [...hashes],
    });
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

class InterestGroupAccessedEvent {
  final network.TimeSinceEpoch accessTime;

  final InterestGroupAccessType type;

  final String ownerOrigin;

  final String name;

  /// For topLevelBid/topLevelAdditionalBid, and when appropriate,
  /// win and additionalBidWin
  final String? componentSellerOrigin;

  /// For bid or somethingBid event, if done locally and not on a server.
  final num? bid;

  final String? bidCurrency;

  /// For non-global events --- links to interestGroupAuctionEvent
  final InterestGroupAuctionId? uniqueAuctionId;

  InterestGroupAccessedEvent({
    required this.accessTime,
    required this.type,
    required this.ownerOrigin,
    required this.name,
    this.componentSellerOrigin,
    this.bid,
    this.bidCurrency,
    this.uniqueAuctionId,
  });

  factory InterestGroupAccessedEvent.fromJson(Map<String, dynamic> json) {
    return InterestGroupAccessedEvent(
      accessTime: network.TimeSinceEpoch.fromJson(json['accessTime'] as num),
      type: InterestGroupAccessType.fromJson(json['type'] as String),
      ownerOrigin: json['ownerOrigin'] as String,
      name: json['name'] as String,
      componentSellerOrigin: json.containsKey('componentSellerOrigin')
          ? json['componentSellerOrigin'] as String
          : null,
      bid: json.containsKey('bid') ? json['bid'] as num : null,
      bidCurrency: json.containsKey('bidCurrency')
          ? json['bidCurrency'] as String
          : null,
      uniqueAuctionId: json.containsKey('uniqueAuctionId')
          ? InterestGroupAuctionId.fromJson(json['uniqueAuctionId'] as String)
          : null,
    );
  }
}

class InterestGroupAuctionEventOccurredEvent {
  final network.TimeSinceEpoch eventTime;

  final InterestGroupAuctionEventType type;

  final InterestGroupAuctionId uniqueAuctionId;

  /// Set for child auctions.
  final InterestGroupAuctionId? parentAuctionId;

  /// Set for started and configResolved
  final Map<String, dynamic>? auctionConfig;

  InterestGroupAuctionEventOccurredEvent({
    required this.eventTime,
    required this.type,
    required this.uniqueAuctionId,
    this.parentAuctionId,
    this.auctionConfig,
  });

  factory InterestGroupAuctionEventOccurredEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return InterestGroupAuctionEventOccurredEvent(
      eventTime: network.TimeSinceEpoch.fromJson(json['eventTime'] as num),
      type: InterestGroupAuctionEventType.fromJson(json['type'] as String),
      uniqueAuctionId: InterestGroupAuctionId.fromJson(
        json['uniqueAuctionId'] as String,
      ),
      parentAuctionId: json.containsKey('parentAuctionId')
          ? InterestGroupAuctionId.fromJson(json['parentAuctionId'] as String)
          : null,
      auctionConfig: json.containsKey('auctionConfig')
          ? json['auctionConfig'] as Map<String, dynamic>
          : null,
    );
  }
}

class InterestGroupAuctionNetworkRequestCreatedEvent {
  final InterestGroupAuctionFetchType type;

  final network.RequestId requestId;

  /// This is the set of the auctions using the worklet that issued this
  /// request.  In the case of trusted signals, it's possible that only some of
  /// them actually care about the keys being queried.
  final List<InterestGroupAuctionId> auctions;

  InterestGroupAuctionNetworkRequestCreatedEvent({
    required this.type,
    required this.requestId,
    required this.auctions,
  });

  factory InterestGroupAuctionNetworkRequestCreatedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return InterestGroupAuctionNetworkRequestCreatedEvent(
      type: InterestGroupAuctionFetchType.fromJson(json['type'] as String),
      requestId: network.RequestId.fromJson(json['requestId'] as String),
      auctions: (json['auctions'] as List)
          .map((e) => InterestGroupAuctionId.fromJson(e as String))
          .toList(),
    );
  }
}

class SharedStorageAccessedEvent {
  /// Time of the access.
  final network.TimeSinceEpoch accessTime;

  /// Enum value indicating the access scope.
  final SharedStorageAccessScope scope;

  /// Enum value indicating the Shared Storage API method invoked.
  final SharedStorageAccessMethod method;

  /// DevTools Frame Token for the primary frame tree's root.
  final page.FrameId mainFrameId;

  /// Serialization of the origin owning the Shared Storage data.
  final String ownerOrigin;

  /// Serialization of the site owning the Shared Storage data.
  final String ownerSite;

  /// The sub-parameters wrapped by `params` are all optional and their
  /// presence/absence depends on `type`.
  final SharedStorageAccessParams params;

  SharedStorageAccessedEvent({
    required this.accessTime,
    required this.scope,
    required this.method,
    required this.mainFrameId,
    required this.ownerOrigin,
    required this.ownerSite,
    required this.params,
  });

  factory SharedStorageAccessedEvent.fromJson(Map<String, dynamic> json) {
    return SharedStorageAccessedEvent(
      accessTime: network.TimeSinceEpoch.fromJson(json['accessTime'] as num),
      scope: SharedStorageAccessScope.fromJson(json['scope'] as String),
      method: SharedStorageAccessMethod.fromJson(json['method'] as String),
      mainFrameId: page.FrameId.fromJson(json['mainFrameId'] as String),
      ownerOrigin: json['ownerOrigin'] as String,
      ownerSite: json['ownerSite'] as String,
      params: SharedStorageAccessParams.fromJson(
        json['params'] as Map<String, dynamic>,
      ),
    );
  }
}

class SharedStorageWorkletOperationExecutionFinishedEvent {
  /// Time that the operation finished.
  final network.TimeSinceEpoch finishedTime;

  /// Time, in microseconds, from start of shared storage JS API call until
  /// end of operation execution in the worklet.
  final int executionTime;

  /// Enum value indicating the Shared Storage API method invoked.
  final SharedStorageAccessMethod method;

  /// ID of the operation call.
  final String operationId;

  /// Hex representation of the DevTools token used as the TargetID for the
  /// associated shared storage worklet.
  final target.TargetID workletTargetId;

  /// DevTools Frame Token for the primary frame tree's root.
  final page.FrameId mainFrameId;

  /// Serialization of the origin owning the Shared Storage data.
  final String ownerOrigin;

  SharedStorageWorkletOperationExecutionFinishedEvent({
    required this.finishedTime,
    required this.executionTime,
    required this.method,
    required this.operationId,
    required this.workletTargetId,
    required this.mainFrameId,
    required this.ownerOrigin,
  });

  factory SharedStorageWorkletOperationExecutionFinishedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return SharedStorageWorkletOperationExecutionFinishedEvent(
      finishedTime: network.TimeSinceEpoch.fromJson(
        json['finishedTime'] as num,
      ),
      executionTime: json['executionTime'] as int,
      method: SharedStorageAccessMethod.fromJson(json['method'] as String),
      operationId: json['operationId'] as String,
      workletTargetId: target.TargetID.fromJson(
        json['workletTargetId'] as String,
      ),
      mainFrameId: page.FrameId.fromJson(json['mainFrameId'] as String),
      ownerOrigin: json['ownerOrigin'] as String,
    );
  }
}

class AttributionReportingSourceRegisteredEvent {
  final AttributionReportingSourceRegistration registration;

  final AttributionReportingSourceRegistrationResult result;

  AttributionReportingSourceRegisteredEvent({
    required this.registration,
    required this.result,
  });

  factory AttributionReportingSourceRegisteredEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttributionReportingSourceRegisteredEvent(
      registration: AttributionReportingSourceRegistration.fromJson(
        json['registration'] as Map<String, dynamic>,
      ),
      result: AttributionReportingSourceRegistrationResult.fromJson(
        json['result'] as String,
      ),
    );
  }
}

class AttributionReportingTriggerRegisteredEvent {
  final AttributionReportingTriggerRegistration registration;

  final AttributionReportingEventLevelResult eventLevel;

  final AttributionReportingAggregatableResult aggregatable;

  AttributionReportingTriggerRegisteredEvent({
    required this.registration,
    required this.eventLevel,
    required this.aggregatable,
  });

  factory AttributionReportingTriggerRegisteredEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttributionReportingTriggerRegisteredEvent(
      registration: AttributionReportingTriggerRegistration.fromJson(
        json['registration'] as Map<String, dynamic>,
      ),
      eventLevel: AttributionReportingEventLevelResult.fromJson(
        json['eventLevel'] as String,
      ),
      aggregatable: AttributionReportingAggregatableResult.fromJson(
        json['aggregatable'] as String,
      ),
    );
  }
}

class AttributionReportingReportSentEvent {
  final String url;

  final Map<String, dynamic> body;

  final AttributionReportingReportResult result;

  /// If result is `sent`, populated with net/HTTP status.
  final int? netError;

  final String? netErrorName;

  final int? httpStatusCode;

  AttributionReportingReportSentEvent({
    required this.url,
    required this.body,
    required this.result,
    this.netError,
    this.netErrorName,
    this.httpStatusCode,
  });

  factory AttributionReportingReportSentEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttributionReportingReportSentEvent(
      url: json['url'] as String,
      body: json['body'] as Map<String, dynamic>,
      result: AttributionReportingReportResult.fromJson(
        json['result'] as String,
      ),
      netError: json.containsKey('netError') ? json['netError'] as int : null,
      netErrorName: json.containsKey('netErrorName')
          ? json['netErrorName'] as String
          : null,
      httpStatusCode: json.containsKey('httpStatusCode')
          ? json['httpStatusCode'] as int
          : null,
    );
  }
}

class AttributionReportingVerboseDebugReportSentEvent {
  final String url;

  final List<Map<String, dynamic>>? body;

  final int? netError;

  final String? netErrorName;

  final int? httpStatusCode;

  AttributionReportingVerboseDebugReportSentEvent({
    required this.url,
    this.body,
    this.netError,
    this.netErrorName,
    this.httpStatusCode,
  });

  factory AttributionReportingVerboseDebugReportSentEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttributionReportingVerboseDebugReportSentEvent(
      url: json['url'] as String,
      body: json.containsKey('body')
          ? (json['body'] as List)
                .map((e) => e as Map<String, dynamic>)
                .toList()
          : null,
      netError: json.containsKey('netError') ? json['netError'] as int : null,
      netErrorName: json.containsKey('netErrorName')
          ? json['netErrorName'] as String
          : null,
      httpStatusCode: json.containsKey('httpStatusCode')
          ? json['httpStatusCode'] as int
          : null,
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
  interestGroups('interest_groups'),
  sharedStorage('shared_storage'),
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

/// Protected audience interest group auction identifier.
extension type InterestGroupAuctionId(String value) {
  factory InterestGroupAuctionId.fromJson(String value) =>
      InterestGroupAuctionId(value);

  String toJson() => value;
}

/// Enum of interest group access types.
enum InterestGroupAccessType {
  join('join'),
  leave('leave'),
  update('update'),
  loaded('loaded'),
  bid('bid'),
  win('win'),
  additionalBid('additionalBid'),
  additionalBidWin('additionalBidWin'),
  topLevelBid('topLevelBid'),
  topLevelAdditionalBid('topLevelAdditionalBid'),
  clear('clear');

  final String value;

  const InterestGroupAccessType(this.value);

  factory InterestGroupAccessType.fromJson(String value) =>
      InterestGroupAccessType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Enum of auction events.
enum InterestGroupAuctionEventType {
  started('started'),
  configResolved('configResolved');

  final String value;

  const InterestGroupAuctionEventType(this.value);

  factory InterestGroupAuctionEventType.fromJson(String value) =>
      InterestGroupAuctionEventType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Enum of network fetches auctions can do.
enum InterestGroupAuctionFetchType {
  bidderJs('bidderJs'),
  bidderWasm('bidderWasm'),
  sellerJs('sellerJs'),
  bidderTrustedSignals('bidderTrustedSignals'),
  sellerTrustedSignals('sellerTrustedSignals');

  final String value;

  const InterestGroupAuctionFetchType(this.value);

  factory InterestGroupAuctionFetchType.fromJson(String value) =>
      InterestGroupAuctionFetchType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Enum of shared storage access scopes.
enum SharedStorageAccessScope {
  window('window'),
  sharedStorageWorklet('sharedStorageWorklet'),
  protectedAudienceWorklet('protectedAudienceWorklet'),
  header('header');

  final String value;

  const SharedStorageAccessScope(this.value);

  factory SharedStorageAccessScope.fromJson(String value) =>
      SharedStorageAccessScope.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Enum of shared storage access methods.
enum SharedStorageAccessMethod {
  addModule('addModule'),
  createWorklet('createWorklet'),
  selectUrl('selectURL'),
  run('run'),
  batchUpdate('batchUpdate'),
  set('set'),
  append('append'),
  delete('delete'),
  clear('clear'),
  get('get'),
  keys('keys'),
  values$('values'),
  entries('entries'),
  length('length'),
  remainingBudget('remainingBudget');

  final String value;

  const SharedStorageAccessMethod(this.value);

  factory SharedStorageAccessMethod.fromJson(String value) =>
      SharedStorageAccessMethod.values.firstWhere((e) => e.value == value);

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
    return {'key': key, 'value': value};
  }
}

/// Details for an origin's shared storage.
class SharedStorageMetadata {
  /// Time when the origin's shared storage was last created.
  final network.TimeSinceEpoch creationTime;

  /// Number of key-value pairs stored in origin's shared storage.
  final int length;

  /// Current amount of bits of entropy remaining in the navigation budget.
  final num remainingBudget;

  /// Total number of bytes stored as key-value pairs in origin's shared
  /// storage.
  final int bytesUsed;

  SharedStorageMetadata({
    required this.creationTime,
    required this.length,
    required this.remainingBudget,
    required this.bytesUsed,
  });

  factory SharedStorageMetadata.fromJson(Map<String, dynamic> json) {
    return SharedStorageMetadata(
      creationTime: network.TimeSinceEpoch.fromJson(
        json['creationTime'] as num,
      ),
      length: json['length'] as int,
      remainingBudget: json['remainingBudget'] as num,
      bytesUsed: json['bytesUsed'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creationTime': creationTime.toJson(),
      'length': length,
      'remainingBudget': remainingBudget,
      'bytesUsed': bytesUsed,
    };
  }
}

/// Represents a dictionary object passed in as privateAggregationConfig to
/// run or selectURL.
class SharedStoragePrivateAggregationConfig {
  /// The chosen aggregation service deployment.
  final String? aggregationCoordinatorOrigin;

  /// The context ID provided.
  final String? contextId;

  /// Configures the maximum size allowed for filtering IDs.
  final int filteringIdMaxBytes;

  /// The limit on the number of contributions in the final report.
  final int? maxContributions;

  SharedStoragePrivateAggregationConfig({
    this.aggregationCoordinatorOrigin,
    this.contextId,
    required this.filteringIdMaxBytes,
    this.maxContributions,
  });

  factory SharedStoragePrivateAggregationConfig.fromJson(
    Map<String, dynamic> json,
  ) {
    return SharedStoragePrivateAggregationConfig(
      aggregationCoordinatorOrigin:
          json.containsKey('aggregationCoordinatorOrigin')
          ? json['aggregationCoordinatorOrigin'] as String
          : null,
      contextId: json.containsKey('contextId')
          ? json['contextId'] as String
          : null,
      filteringIdMaxBytes: json['filteringIdMaxBytes'] as int,
      maxContributions: json.containsKey('maxContributions')
          ? json['maxContributions'] as int
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filteringIdMaxBytes': filteringIdMaxBytes,
      if (aggregationCoordinatorOrigin != null)
        'aggregationCoordinatorOrigin': aggregationCoordinatorOrigin,
      if (contextId != null) 'contextId': contextId,
      if (maxContributions != null) 'maxContributions': maxContributions,
    };
  }
}

/// Pair of reporting metadata details for a candidate URL for `selectURL()`.
class SharedStorageReportingMetadata {
  final String eventType;

  final String reportingUrl;

  SharedStorageReportingMetadata({
    required this.eventType,
    required this.reportingUrl,
  });

  factory SharedStorageReportingMetadata.fromJson(Map<String, dynamic> json) {
    return SharedStorageReportingMetadata(
      eventType: json['eventType'] as String,
      reportingUrl: json['reportingUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'eventType': eventType, 'reportingUrl': reportingUrl};
  }
}

/// Bundles a candidate URL with its reporting metadata.
class SharedStorageUrlWithMetadata {
  /// Spec of candidate URL.
  final String url;

  /// Any associated reporting metadata.
  final List<SharedStorageReportingMetadata> reportingMetadata;

  SharedStorageUrlWithMetadata({
    required this.url,
    required this.reportingMetadata,
  });

  factory SharedStorageUrlWithMetadata.fromJson(Map<String, dynamic> json) {
    return SharedStorageUrlWithMetadata(
      url: json['url'] as String,
      reportingMetadata: (json['reportingMetadata'] as List)
          .map(
            (e) => SharedStorageReportingMetadata.fromJson(
              e as Map<String, dynamic>,
            ),
          )
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
  /// Present only for SharedStorageAccessMethods: addModule and
  /// createWorklet.
  final String? scriptSourceUrl;

  /// String denoting "context-origin", "script-origin", or a custom
  /// origin to be used as the worklet's data origin.
  /// Present only for SharedStorageAccessMethod: createWorklet.
  final String? dataOrigin;

  /// Name of the registered operation to be run.
  /// Present only for SharedStorageAccessMethods: run and selectURL.
  final String? operationName;

  /// ID of the operation call.
  /// Present only for SharedStorageAccessMethods: run and selectURL.
  final String? operationId;

  /// Whether or not to keep the worket alive for future run or selectURL
  /// calls.
  /// Present only for SharedStorageAccessMethods: run and selectURL.
  final bool? keepAlive;

  /// Configures the private aggregation options.
  /// Present only for SharedStorageAccessMethods: run and selectURL.
  final SharedStoragePrivateAggregationConfig? privateAggregationConfig;

  /// The operation's serialized data in bytes (converted to a string).
  /// Present only for SharedStorageAccessMethods: run and selectURL.
  /// TODO(crbug.com/401011862): Consider updating this parameter to binary.
  final String? serializedData;

  /// Array of candidate URLs' specs, along with any associated metadata.
  /// Present only for SharedStorageAccessMethod: selectURL.
  final List<SharedStorageUrlWithMetadata>? urlsWithMetadata;

  /// Spec of the URN:UUID generated for a selectURL call.
  /// Present only for SharedStorageAccessMethod: selectURL.
  final String? urnUuid;

  /// Key for a specific entry in an origin's shared storage.
  /// Present only for SharedStorageAccessMethods: set, append, delete, and
  /// get.
  final String? key;

  /// Value for a specific entry in an origin's shared storage.
  /// Present only for SharedStorageAccessMethods: set and append.
  final String? value;

  /// Whether or not to set an entry for a key if that key is already present.
  /// Present only for SharedStorageAccessMethod: set.
  final bool? ignoreIfPresent;

  /// A number denoting the (0-based) order of the worklet's
  /// creation relative to all other shared storage worklets created by
  /// documents using the current storage partition.
  /// Present only for SharedStorageAccessMethods: addModule, createWorklet.
  final int? workletOrdinal;

  /// Hex representation of the DevTools token used as the TargetID for the
  /// associated shared storage worklet.
  /// Present only for SharedStorageAccessMethods: addModule, createWorklet,
  /// run, selectURL, and any other SharedStorageAccessMethod when the
  /// SharedStorageAccessScope is sharedStorageWorklet.
  final target.TargetID? workletTargetId;

  /// Name of the lock to be acquired, if present.
  /// Optionally present only for SharedStorageAccessMethods: batchUpdate,
  /// set, append, delete, and clear.
  final String? withLock;

  /// If the method has been called as part of a batchUpdate, then this
  /// number identifies the batch to which it belongs.
  /// Optionally present only for SharedStorageAccessMethods:
  /// batchUpdate (required), set, append, delete, and clear.
  final String? batchUpdateId;

  /// Number of modifier methods sent in batch.
  /// Present only for SharedStorageAccessMethod: batchUpdate.
  final int? batchSize;

  SharedStorageAccessParams({
    this.scriptSourceUrl,
    this.dataOrigin,
    this.operationName,
    this.operationId,
    this.keepAlive,
    this.privateAggregationConfig,
    this.serializedData,
    this.urlsWithMetadata,
    this.urnUuid,
    this.key,
    this.value,
    this.ignoreIfPresent,
    this.workletOrdinal,
    this.workletTargetId,
    this.withLock,
    this.batchUpdateId,
    this.batchSize,
  });

  factory SharedStorageAccessParams.fromJson(Map<String, dynamic> json) {
    return SharedStorageAccessParams(
      scriptSourceUrl: json.containsKey('scriptSourceUrl')
          ? json['scriptSourceUrl'] as String
          : null,
      dataOrigin: json.containsKey('dataOrigin')
          ? json['dataOrigin'] as String
          : null,
      operationName: json.containsKey('operationName')
          ? json['operationName'] as String
          : null,
      operationId: json.containsKey('operationId')
          ? json['operationId'] as String
          : null,
      keepAlive: json.containsKey('keepAlive')
          ? json['keepAlive'] as bool
          : null,
      privateAggregationConfig: json.containsKey('privateAggregationConfig')
          ? SharedStoragePrivateAggregationConfig.fromJson(
              json['privateAggregationConfig'] as Map<String, dynamic>,
            )
          : null,
      serializedData: json.containsKey('serializedData')
          ? json['serializedData'] as String
          : null,
      urlsWithMetadata: json.containsKey('urlsWithMetadata')
          ? (json['urlsWithMetadata'] as List)
                .map(
                  (e) => SharedStorageUrlWithMetadata.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : null,
      urnUuid: json.containsKey('urnUuid') ? json['urnUuid'] as String : null,
      key: json.containsKey('key') ? json['key'] as String : null,
      value: json.containsKey('value') ? json['value'] as String : null,
      ignoreIfPresent: json.containsKey('ignoreIfPresent')
          ? json['ignoreIfPresent'] as bool
          : null,
      workletOrdinal: json.containsKey('workletOrdinal')
          ? json['workletOrdinal'] as int
          : null,
      workletTargetId: json.containsKey('workletTargetId')
          ? target.TargetID.fromJson(json['workletTargetId'] as String)
          : null,
      withLock: json.containsKey('withLock')
          ? json['withLock'] as String
          : null,
      batchUpdateId: json.containsKey('batchUpdateId')
          ? json['batchUpdateId'] as String
          : null,
      batchSize: json.containsKey('batchSize')
          ? json['batchSize'] as int
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (scriptSourceUrl != null) 'scriptSourceUrl': scriptSourceUrl,
      if (dataOrigin != null) 'dataOrigin': dataOrigin,
      if (operationName != null) 'operationName': operationName,
      if (operationId != null) 'operationId': operationId,
      if (keepAlive != null) 'keepAlive': keepAlive,
      if (privateAggregationConfig != null)
        'privateAggregationConfig': privateAggregationConfig!.toJson(),
      if (serializedData != null) 'serializedData': serializedData,
      if (urlsWithMetadata != null)
        'urlsWithMetadata': urlsWithMetadata!.map((e) => e.toJson()).toList(),
      if (urnUuid != null) 'urnUuid': urnUuid,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (ignoreIfPresent != null) 'ignoreIfPresent': ignoreIfPresent,
      if (workletOrdinal != null) 'workletOrdinal': workletOrdinal,
      if (workletTargetId != null) 'workletTargetId': workletTargetId!.toJson(),
      if (withLock != null) 'withLock': withLock,
      if (batchUpdateId != null) 'batchUpdateId': batchUpdateId,
      if (batchSize != null) 'batchSize': batchSize,
    };
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

enum AttributionReportingSourceType {
  navigation('navigation'),
  event('event');

  final String value;

  const AttributionReportingSourceType(this.value);

  factory AttributionReportingSourceType.fromJson(String value) =>
      AttributionReportingSourceType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

extension type UnsignedInt64AsBase10(String value) {
  factory UnsignedInt64AsBase10.fromJson(String value) =>
      UnsignedInt64AsBase10(value);

  String toJson() => value;
}

extension type UnsignedInt128AsBase16(String value) {
  factory UnsignedInt128AsBase16.fromJson(String value) =>
      UnsignedInt128AsBase16(value);

  String toJson() => value;
}

extension type SignedInt64AsBase10(String value) {
  factory SignedInt64AsBase10.fromJson(String value) =>
      SignedInt64AsBase10(value);

  String toJson() => value;
}

class AttributionReportingFilterDataEntry {
  final String key;

  final List<String> values;

  AttributionReportingFilterDataEntry({
    required this.key,
    required this.values,
  });

  factory AttributionReportingFilterDataEntry.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttributionReportingFilterDataEntry(
      key: json['key'] as String,
      values: (json['values'] as List).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'values': [...values],
    };
  }
}

class AttributionReportingFilterConfig {
  final List<AttributionReportingFilterDataEntry> filterValues;

  /// duration in seconds
  final int? lookbackWindow;

  AttributionReportingFilterConfig({
    required this.filterValues,
    this.lookbackWindow,
  });

  factory AttributionReportingFilterConfig.fromJson(Map<String, dynamic> json) {
    return AttributionReportingFilterConfig(
      filterValues: (json['filterValues'] as List)
          .map(
            (e) => AttributionReportingFilterDataEntry.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      lookbackWindow: json.containsKey('lookbackWindow')
          ? json['lookbackWindow'] as int
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filterValues': filterValues.map((e) => e.toJson()).toList(),
      if (lookbackWindow != null) 'lookbackWindow': lookbackWindow,
    };
  }
}

class AttributionReportingFilterPair {
  final List<AttributionReportingFilterConfig> filters;

  final List<AttributionReportingFilterConfig> notFilters;

  AttributionReportingFilterPair({
    required this.filters,
    required this.notFilters,
  });

  factory AttributionReportingFilterPair.fromJson(Map<String, dynamic> json) {
    return AttributionReportingFilterPair(
      filters: (json['filters'] as List)
          .map(
            (e) => AttributionReportingFilterConfig.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      notFilters: (json['notFilters'] as List)
          .map(
            (e) => AttributionReportingFilterConfig.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filters': filters.map((e) => e.toJson()).toList(),
      'notFilters': notFilters.map((e) => e.toJson()).toList(),
    };
  }
}

class AttributionReportingAggregationKeysEntry {
  final String key;

  final UnsignedInt128AsBase16 value;

  AttributionReportingAggregationKeysEntry({
    required this.key,
    required this.value,
  });

  factory AttributionReportingAggregationKeysEntry.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttributionReportingAggregationKeysEntry(
      key: json['key'] as String,
      value: UnsignedInt128AsBase16.fromJson(json['value'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'key': key, 'value': value.toJson()};
  }
}

class AttributionReportingEventReportWindows {
  /// duration in seconds
  final int start;

  /// duration in seconds
  final List<int> ends;

  AttributionReportingEventReportWindows({
    required this.start,
    required this.ends,
  });

  factory AttributionReportingEventReportWindows.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttributionReportingEventReportWindows(
      start: json['start'] as int,
      ends: (json['ends'] as List).map((e) => e as int).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'ends': [...ends],
    };
  }
}

enum AttributionReportingTriggerDataMatching {
  exact('exact'),
  modulus('modulus');

  final String value;

  const AttributionReportingTriggerDataMatching(this.value);

  factory AttributionReportingTriggerDataMatching.fromJson(String value) =>
      AttributionReportingTriggerDataMatching.values.firstWhere(
        (e) => e.value == value,
      );

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class AttributionReportingAggregatableDebugReportingData {
  final UnsignedInt128AsBase16 keyPiece;

  /// number instead of integer because not all uint32 can be represented by
  /// int
  final num value;

  final List<String> types;

  AttributionReportingAggregatableDebugReportingData({
    required this.keyPiece,
    required this.value,
    required this.types,
  });

  factory AttributionReportingAggregatableDebugReportingData.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttributionReportingAggregatableDebugReportingData(
      keyPiece: UnsignedInt128AsBase16.fromJson(json['keyPiece'] as String),
      value: json['value'] as num,
      types: (json['types'] as List).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyPiece': keyPiece.toJson(),
      'value': value,
      'types': [...types],
    };
  }
}

class AttributionReportingAggregatableDebugReportingConfig {
  /// number instead of integer because not all uint32 can be represented by
  /// int, only present for source registrations
  final num? budget;

  final UnsignedInt128AsBase16 keyPiece;

  final List<AttributionReportingAggregatableDebugReportingData> debugData;

  final String? aggregationCoordinatorOrigin;

  AttributionReportingAggregatableDebugReportingConfig({
    this.budget,
    required this.keyPiece,
    required this.debugData,
    this.aggregationCoordinatorOrigin,
  });

  factory AttributionReportingAggregatableDebugReportingConfig.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttributionReportingAggregatableDebugReportingConfig(
      budget: json.containsKey('budget') ? json['budget'] as num : null,
      keyPiece: UnsignedInt128AsBase16.fromJson(json['keyPiece'] as String),
      debugData: (json['debugData'] as List)
          .map(
            (e) => AttributionReportingAggregatableDebugReportingData.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      aggregationCoordinatorOrigin:
          json.containsKey('aggregationCoordinatorOrigin')
          ? json['aggregationCoordinatorOrigin'] as String
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyPiece': keyPiece.toJson(),
      'debugData': debugData.map((e) => e.toJson()).toList(),
      if (budget != null) 'budget': budget,
      if (aggregationCoordinatorOrigin != null)
        'aggregationCoordinatorOrigin': aggregationCoordinatorOrigin,
    };
  }
}

class AttributionScopesData {
  final List<String> values;

  /// number instead of integer because not all uint32 can be represented by
  /// int
  final num limit;

  final num maxEventStates;

  AttributionScopesData({
    required this.values,
    required this.limit,
    required this.maxEventStates,
  });

  factory AttributionScopesData.fromJson(Map<String, dynamic> json) {
    return AttributionScopesData(
      values: (json['values'] as List).map((e) => e as String).toList(),
      limit: json['limit'] as num,
      maxEventStates: json['maxEventStates'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'values': [...values],
      'limit': limit,
      'maxEventStates': maxEventStates,
    };
  }
}

class AttributionReportingNamedBudgetDef {
  final String name;

  final int budget;

  AttributionReportingNamedBudgetDef({
    required this.name,
    required this.budget,
  });

  factory AttributionReportingNamedBudgetDef.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttributionReportingNamedBudgetDef(
      name: json['name'] as String,
      budget: json['budget'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'budget': budget};
  }
}

class AttributionReportingSourceRegistration {
  final network.TimeSinceEpoch time;

  /// duration in seconds
  final int expiry;

  /// number instead of integer because not all uint32 can be represented by
  /// int
  final List<num> triggerData;

  final AttributionReportingEventReportWindows eventReportWindows;

  /// duration in seconds
  final int aggregatableReportWindow;

  final AttributionReportingSourceType type;

  final String sourceOrigin;

  final String reportingOrigin;

  final List<String> destinationSites;

  final UnsignedInt64AsBase10 eventId;

  final SignedInt64AsBase10 priority;

  final List<AttributionReportingFilterDataEntry> filterData;

  final List<AttributionReportingAggregationKeysEntry> aggregationKeys;

  final UnsignedInt64AsBase10? debugKey;

  final AttributionReportingTriggerDataMatching triggerDataMatching;

  final SignedInt64AsBase10 destinationLimitPriority;

  final AttributionReportingAggregatableDebugReportingConfig
  aggregatableDebugReportingConfig;

  final AttributionScopesData? scopesData;

  final int maxEventLevelReports;

  final List<AttributionReportingNamedBudgetDef> namedBudgets;

  final bool debugReporting;

  final num eventLevelEpsilon;

  AttributionReportingSourceRegistration({
    required this.time,
    required this.expiry,
    required this.triggerData,
    required this.eventReportWindows,
    required this.aggregatableReportWindow,
    required this.type,
    required this.sourceOrigin,
    required this.reportingOrigin,
    required this.destinationSites,
    required this.eventId,
    required this.priority,
    required this.filterData,
    required this.aggregationKeys,
    this.debugKey,
    required this.triggerDataMatching,
    required this.destinationLimitPriority,
    required this.aggregatableDebugReportingConfig,
    this.scopesData,
    required this.maxEventLevelReports,
    required this.namedBudgets,
    required this.debugReporting,
    required this.eventLevelEpsilon,
  });

  factory AttributionReportingSourceRegistration.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttributionReportingSourceRegistration(
      time: network.TimeSinceEpoch.fromJson(json['time'] as num),
      expiry: json['expiry'] as int,
      triggerData: (json['triggerData'] as List).map((e) => e as num).toList(),
      eventReportWindows: AttributionReportingEventReportWindows.fromJson(
        json['eventReportWindows'] as Map<String, dynamic>,
      ),
      aggregatableReportWindow: json['aggregatableReportWindow'] as int,
      type: AttributionReportingSourceType.fromJson(json['type'] as String),
      sourceOrigin: json['sourceOrigin'] as String,
      reportingOrigin: json['reportingOrigin'] as String,
      destinationSites: (json['destinationSites'] as List)
          .map((e) => e as String)
          .toList(),
      eventId: UnsignedInt64AsBase10.fromJson(json['eventId'] as String),
      priority: SignedInt64AsBase10.fromJson(json['priority'] as String),
      filterData: (json['filterData'] as List)
          .map(
            (e) => AttributionReportingFilterDataEntry.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      aggregationKeys: (json['aggregationKeys'] as List)
          .map(
            (e) => AttributionReportingAggregationKeysEntry.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      debugKey: json.containsKey('debugKey')
          ? UnsignedInt64AsBase10.fromJson(json['debugKey'] as String)
          : null,
      triggerDataMatching: AttributionReportingTriggerDataMatching.fromJson(
        json['triggerDataMatching'] as String,
      ),
      destinationLimitPriority: SignedInt64AsBase10.fromJson(
        json['destinationLimitPriority'] as String,
      ),
      aggregatableDebugReportingConfig:
          AttributionReportingAggregatableDebugReportingConfig.fromJson(
            json['aggregatableDebugReportingConfig'] as Map<String, dynamic>,
          ),
      scopesData: json.containsKey('scopesData')
          ? AttributionScopesData.fromJson(
              json['scopesData'] as Map<String, dynamic>,
            )
          : null,
      maxEventLevelReports: json['maxEventLevelReports'] as int,
      namedBudgets: (json['namedBudgets'] as List)
          .map(
            (e) => AttributionReportingNamedBudgetDef.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      debugReporting: json['debugReporting'] as bool? ?? false,
      eventLevelEpsilon: json['eventLevelEpsilon'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toJson(),
      'expiry': expiry,
      'triggerData': [...triggerData],
      'eventReportWindows': eventReportWindows.toJson(),
      'aggregatableReportWindow': aggregatableReportWindow,
      'type': type.toJson(),
      'sourceOrigin': sourceOrigin,
      'reportingOrigin': reportingOrigin,
      'destinationSites': [...destinationSites],
      'eventId': eventId.toJson(),
      'priority': priority.toJson(),
      'filterData': filterData.map((e) => e.toJson()).toList(),
      'aggregationKeys': aggregationKeys.map((e) => e.toJson()).toList(),
      'triggerDataMatching': triggerDataMatching.toJson(),
      'destinationLimitPriority': destinationLimitPriority.toJson(),
      'aggregatableDebugReportingConfig': aggregatableDebugReportingConfig
          .toJson(),
      'maxEventLevelReports': maxEventLevelReports,
      'namedBudgets': namedBudgets.map((e) => e.toJson()).toList(),
      'debugReporting': debugReporting,
      'eventLevelEpsilon': eventLevelEpsilon,
      if (debugKey != null) 'debugKey': debugKey!.toJson(),
      if (scopesData != null) 'scopesData': scopesData!.toJson(),
    };
  }
}

enum AttributionReportingSourceRegistrationResult {
  success('success'),
  internalError('internalError'),
  insufficientSourceCapacity('insufficientSourceCapacity'),
  insufficientUniqueDestinationCapacity(
    'insufficientUniqueDestinationCapacity',
  ),
  excessiveReportingOrigins('excessiveReportingOrigins'),
  prohibitedByBrowserPolicy('prohibitedByBrowserPolicy'),
  successNoised('successNoised'),
  destinationReportingLimitReached('destinationReportingLimitReached'),
  destinationGlobalLimitReached('destinationGlobalLimitReached'),
  destinationBothLimitsReached('destinationBothLimitsReached'),
  reportingOriginsPerSiteLimitReached('reportingOriginsPerSiteLimitReached'),
  exceedsMaxChannelCapacity('exceedsMaxChannelCapacity'),
  exceedsMaxScopesChannelCapacity('exceedsMaxScopesChannelCapacity'),
  exceedsMaxTriggerStateCardinality('exceedsMaxTriggerStateCardinality'),
  exceedsMaxEventStatesLimit('exceedsMaxEventStatesLimit'),
  destinationPerDayReportingLimitReached(
    'destinationPerDayReportingLimitReached',
  );

  final String value;

  const AttributionReportingSourceRegistrationResult(this.value);

  factory AttributionReportingSourceRegistrationResult.fromJson(String value) =>
      AttributionReportingSourceRegistrationResult.values.firstWhere(
        (e) => e.value == value,
      );

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum AttributionReportingSourceRegistrationTimeConfig {
  include('include'),
  exclude('exclude');

  final String value;

  const AttributionReportingSourceRegistrationTimeConfig(this.value);

  factory AttributionReportingSourceRegistrationTimeConfig.fromJson(
    String value,
  ) => AttributionReportingSourceRegistrationTimeConfig.values.firstWhere(
    (e) => e.value == value,
  );

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class AttributionReportingAggregatableValueDictEntry {
  final String key;

  /// number instead of integer because not all uint32 can be represented by
  /// int
  final num value;

  final UnsignedInt64AsBase10 filteringId;

  AttributionReportingAggregatableValueDictEntry({
    required this.key,
    required this.value,
    required this.filteringId,
  });

  factory AttributionReportingAggregatableValueDictEntry.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttributionReportingAggregatableValueDictEntry(
      key: json['key'] as String,
      value: json['value'] as num,
      filteringId: UnsignedInt64AsBase10.fromJson(
        json['filteringId'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'key': key, 'value': value, 'filteringId': filteringId.toJson()};
  }
}

class AttributionReportingAggregatableValueEntry {
  final List<AttributionReportingAggregatableValueDictEntry> values;

  final AttributionReportingFilterPair filters;

  AttributionReportingAggregatableValueEntry({
    required this.values,
    required this.filters,
  });

  factory AttributionReportingAggregatableValueEntry.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttributionReportingAggregatableValueEntry(
      values: (json['values'] as List)
          .map(
            (e) => AttributionReportingAggregatableValueDictEntry.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      filters: AttributionReportingFilterPair.fromJson(
        json['filters'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'values': values.map((e) => e.toJson()).toList(),
      'filters': filters.toJson(),
    };
  }
}

class AttributionReportingEventTriggerData {
  final UnsignedInt64AsBase10 data;

  final SignedInt64AsBase10 priority;

  final UnsignedInt64AsBase10? dedupKey;

  final AttributionReportingFilterPair filters;

  AttributionReportingEventTriggerData({
    required this.data,
    required this.priority,
    this.dedupKey,
    required this.filters,
  });

  factory AttributionReportingEventTriggerData.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttributionReportingEventTriggerData(
      data: UnsignedInt64AsBase10.fromJson(json['data'] as String),
      priority: SignedInt64AsBase10.fromJson(json['priority'] as String),
      dedupKey: json.containsKey('dedupKey')
          ? UnsignedInt64AsBase10.fromJson(json['dedupKey'] as String)
          : null,
      filters: AttributionReportingFilterPair.fromJson(
        json['filters'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'priority': priority.toJson(),
      'filters': filters.toJson(),
      if (dedupKey != null) 'dedupKey': dedupKey!.toJson(),
    };
  }
}

class AttributionReportingAggregatableTriggerData {
  final UnsignedInt128AsBase16 keyPiece;

  final List<String> sourceKeys;

  final AttributionReportingFilterPair filters;

  AttributionReportingAggregatableTriggerData({
    required this.keyPiece,
    required this.sourceKeys,
    required this.filters,
  });

  factory AttributionReportingAggregatableTriggerData.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttributionReportingAggregatableTriggerData(
      keyPiece: UnsignedInt128AsBase16.fromJson(json['keyPiece'] as String),
      sourceKeys: (json['sourceKeys'] as List).map((e) => e as String).toList(),
      filters: AttributionReportingFilterPair.fromJson(
        json['filters'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyPiece': keyPiece.toJson(),
      'sourceKeys': [...sourceKeys],
      'filters': filters.toJson(),
    };
  }
}

class AttributionReportingAggregatableDedupKey {
  final UnsignedInt64AsBase10? dedupKey;

  final AttributionReportingFilterPair filters;

  AttributionReportingAggregatableDedupKey({
    this.dedupKey,
    required this.filters,
  });

  factory AttributionReportingAggregatableDedupKey.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttributionReportingAggregatableDedupKey(
      dedupKey: json.containsKey('dedupKey')
          ? UnsignedInt64AsBase10.fromJson(json['dedupKey'] as String)
          : null,
      filters: AttributionReportingFilterPair.fromJson(
        json['filters'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filters': filters.toJson(),
      if (dedupKey != null) 'dedupKey': dedupKey!.toJson(),
    };
  }
}

class AttributionReportingNamedBudgetCandidate {
  final String? name;

  final AttributionReportingFilterPair filters;

  AttributionReportingNamedBudgetCandidate({this.name, required this.filters});

  factory AttributionReportingNamedBudgetCandidate.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttributionReportingNamedBudgetCandidate(
      name: json.containsKey('name') ? json['name'] as String : null,
      filters: AttributionReportingFilterPair.fromJson(
        json['filters'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'filters': filters.toJson(), if (name != null) 'name': name};
  }
}

class AttributionReportingTriggerRegistration {
  final AttributionReportingFilterPair filters;

  final UnsignedInt64AsBase10? debugKey;

  final List<AttributionReportingAggregatableDedupKey> aggregatableDedupKeys;

  final List<AttributionReportingEventTriggerData> eventTriggerData;

  final List<AttributionReportingAggregatableTriggerData>
  aggregatableTriggerData;

  final List<AttributionReportingAggregatableValueEntry> aggregatableValues;

  final int aggregatableFilteringIdMaxBytes;

  final bool debugReporting;

  final String? aggregationCoordinatorOrigin;

  final AttributionReportingSourceRegistrationTimeConfig
  sourceRegistrationTimeConfig;

  final String? triggerContextId;

  final AttributionReportingAggregatableDebugReportingConfig
  aggregatableDebugReportingConfig;

  final List<String> scopes;

  final List<AttributionReportingNamedBudgetCandidate> namedBudgets;

  AttributionReportingTriggerRegistration({
    required this.filters,
    this.debugKey,
    required this.aggregatableDedupKeys,
    required this.eventTriggerData,
    required this.aggregatableTriggerData,
    required this.aggregatableValues,
    required this.aggregatableFilteringIdMaxBytes,
    required this.debugReporting,
    this.aggregationCoordinatorOrigin,
    required this.sourceRegistrationTimeConfig,
    this.triggerContextId,
    required this.aggregatableDebugReportingConfig,
    required this.scopes,
    required this.namedBudgets,
  });

  factory AttributionReportingTriggerRegistration.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttributionReportingTriggerRegistration(
      filters: AttributionReportingFilterPair.fromJson(
        json['filters'] as Map<String, dynamic>,
      ),
      debugKey: json.containsKey('debugKey')
          ? UnsignedInt64AsBase10.fromJson(json['debugKey'] as String)
          : null,
      aggregatableDedupKeys: (json['aggregatableDedupKeys'] as List)
          .map(
            (e) => AttributionReportingAggregatableDedupKey.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      eventTriggerData: (json['eventTriggerData'] as List)
          .map(
            (e) => AttributionReportingEventTriggerData.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      aggregatableTriggerData: (json['aggregatableTriggerData'] as List)
          .map(
            (e) => AttributionReportingAggregatableTriggerData.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      aggregatableValues: (json['aggregatableValues'] as List)
          .map(
            (e) => AttributionReportingAggregatableValueEntry.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      aggregatableFilteringIdMaxBytes:
          json['aggregatableFilteringIdMaxBytes'] as int,
      debugReporting: json['debugReporting'] as bool? ?? false,
      aggregationCoordinatorOrigin:
          json.containsKey('aggregationCoordinatorOrigin')
          ? json['aggregationCoordinatorOrigin'] as String
          : null,
      sourceRegistrationTimeConfig:
          AttributionReportingSourceRegistrationTimeConfig.fromJson(
            json['sourceRegistrationTimeConfig'] as String,
          ),
      triggerContextId: json.containsKey('triggerContextId')
          ? json['triggerContextId'] as String
          : null,
      aggregatableDebugReportingConfig:
          AttributionReportingAggregatableDebugReportingConfig.fromJson(
            json['aggregatableDebugReportingConfig'] as Map<String, dynamic>,
          ),
      scopes: (json['scopes'] as List).map((e) => e as String).toList(),
      namedBudgets: (json['namedBudgets'] as List)
          .map(
            (e) => AttributionReportingNamedBudgetCandidate.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filters': filters.toJson(),
      'aggregatableDedupKeys': aggregatableDedupKeys
          .map((e) => e.toJson())
          .toList(),
      'eventTriggerData': eventTriggerData.map((e) => e.toJson()).toList(),
      'aggregatableTriggerData': aggregatableTriggerData
          .map((e) => e.toJson())
          .toList(),
      'aggregatableValues': aggregatableValues.map((e) => e.toJson()).toList(),
      'aggregatableFilteringIdMaxBytes': aggregatableFilteringIdMaxBytes,
      'debugReporting': debugReporting,
      'sourceRegistrationTimeConfig': sourceRegistrationTimeConfig.toJson(),
      'aggregatableDebugReportingConfig': aggregatableDebugReportingConfig
          .toJson(),
      'scopes': [...scopes],
      'namedBudgets': namedBudgets.map((e) => e.toJson()).toList(),
      if (debugKey != null) 'debugKey': debugKey!.toJson(),
      if (aggregationCoordinatorOrigin != null)
        'aggregationCoordinatorOrigin': aggregationCoordinatorOrigin,
      if (triggerContextId != null) 'triggerContextId': triggerContextId,
    };
  }
}

enum AttributionReportingEventLevelResult {
  success('success'),
  successDroppedLowerPriority('successDroppedLowerPriority'),
  internalError('internalError'),
  noCapacityForAttributionDestination('noCapacityForAttributionDestination'),
  noMatchingSources('noMatchingSources'),
  deduplicated('deduplicated'),
  excessiveAttributions('excessiveAttributions'),
  priorityTooLow('priorityTooLow'),
  neverAttributedSource('neverAttributedSource'),
  excessiveReportingOrigins('excessiveReportingOrigins'),
  noMatchingSourceFilterData('noMatchingSourceFilterData'),
  prohibitedByBrowserPolicy('prohibitedByBrowserPolicy'),
  noMatchingConfigurations('noMatchingConfigurations'),
  excessiveReports('excessiveReports'),
  falselyAttributedSource('falselyAttributedSource'),
  reportWindowPassed('reportWindowPassed'),
  notRegistered('notRegistered'),
  reportWindowNotStarted('reportWindowNotStarted'),
  noMatchingTriggerData('noMatchingTriggerData');

  final String value;

  const AttributionReportingEventLevelResult(this.value);

  factory AttributionReportingEventLevelResult.fromJson(String value) =>
      AttributionReportingEventLevelResult.values.firstWhere(
        (e) => e.value == value,
      );

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum AttributionReportingAggregatableResult {
  success('success'),
  internalError('internalError'),
  noCapacityForAttributionDestination('noCapacityForAttributionDestination'),
  noMatchingSources('noMatchingSources'),
  excessiveAttributions('excessiveAttributions'),
  excessiveReportingOrigins('excessiveReportingOrigins'),
  noHistograms('noHistograms'),
  insufficientBudget('insufficientBudget'),
  insufficientNamedBudget('insufficientNamedBudget'),
  noMatchingSourceFilterData('noMatchingSourceFilterData'),
  notRegistered('notRegistered'),
  prohibitedByBrowserPolicy('prohibitedByBrowserPolicy'),
  deduplicated('deduplicated'),
  reportWindowPassed('reportWindowPassed'),
  excessiveReports('excessiveReports');

  final String value;

  const AttributionReportingAggregatableResult(this.value);

  factory AttributionReportingAggregatableResult.fromJson(String value) =>
      AttributionReportingAggregatableResult.values.firstWhere(
        (e) => e.value == value,
      );

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum AttributionReportingReportResult {
  sent('sent'),
  prohibited('prohibited'),
  failedToAssemble('failedToAssemble'),
  expired('expired');

  final String value;

  const AttributionReportingReportResult(this.value);

  factory AttributionReportingReportResult.fromJson(String value) =>
      AttributionReportingReportResult.values.firstWhere(
        (e) => e.value == value,
      );

  String toJson() => value;

  @override
  String toString() => value.toString();
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
