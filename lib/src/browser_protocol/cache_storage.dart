import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';

class CacheStorageManager {
  final Session _client;

  CacheStorageManager(this._client);

  /// Requests cache names.
  /// [securityOrigin] Security origin.
  /// Return: Caches for the security origin.
  Future<List<Cache>> requestCacheNames(
    String securityOrigin,
  ) async {
    Map parameters = {
      'securityOrigin': securityOrigin.toString(),
    };
    await _client.send('CacheStorage.requestCacheNames', parameters);
  }

  /// Requests data from cache.
  /// [cacheId] ID of cache to get entries from.
  /// [skipCount] Number of records to skip.
  /// [pageSize] Number of records to fetch.
  Future<RequestEntriesResult> requestEntries(
    CacheId cacheId,
    int skipCount,
    int pageSize,
  ) async {
    Map parameters = {
      'cacheId': cacheId.toJson(),
      'skipCount': skipCount.toString(),
      'pageSize': pageSize.toString(),
    };
    await _client.send('CacheStorage.requestEntries', parameters);
  }

  /// Deletes a cache.
  /// [cacheId] Id of cache for deletion.
  Future deleteCache(
    CacheId cacheId,
  ) async {
    Map parameters = {
      'cacheId': cacheId.toJson(),
    };
    await _client.send('CacheStorage.deleteCache', parameters);
  }

  /// Deletes a cache entry.
  /// [cacheId] Id of cache where the entry will be deleted.
  /// [request] URL spec of the request.
  Future deleteEntry(
    CacheId cacheId,
    String request,
  ) async {
    Map parameters = {
      'cacheId': cacheId.toJson(),
      'request': request.toString(),
    };
    await _client.send('CacheStorage.deleteEntry', parameters);
  }

  /// Fetches cache entry.
  /// [cacheId] Id of cache that contains the enty.
  /// [requestURL] URL spec of the request.
  /// Return: Response read from the cache.
  Future<CachedResponse> requestCachedResponse(
    CacheId cacheId,
    String requestURL,
  ) async {
    Map parameters = {
      'cacheId': cacheId.toJson(),
      'requestURL': requestURL.toString(),
    };
    await _client.send('CacheStorage.requestCachedResponse', parameters);
  }
}

class RequestEntriesResult {
  /// Array of object store data entries.
  final List<DataEntry> cacheDataEntries;

  /// If true, there are more entries to fetch in the given range.
  final bool hasMore;

  RequestEntriesResult({
    @required this.cacheDataEntries,
    @required this.hasMore,
  });
}

/// Unique identifier of the Cache object.
class CacheId {
  final String value;

  CacheId(this.value);

  String toJson() => value;
}

/// Data entry.
class DataEntry {
  /// Request url spec.
  final String request;

  /// Response status text.
  final String response;

  /// Number of seconds since epoch.
  final num responseTime;

  DataEntry({
    @required this.request,
    @required this.response,
    @required this.responseTime,
  });

  Map toJson() {
    Map json = {
      'request': request.toString(),
      'response': response.toString(),
      'responseTime': responseTime.toString(),
    };
    return json;
  }
}

/// Cache identifier.
class Cache {
  /// An opaque unique id of the cache.
  final CacheId cacheId;

  /// Security origin of the cache.
  final String securityOrigin;

  /// The name of the cache.
  final String cacheName;

  Cache({
    @required this.cacheId,
    @required this.securityOrigin,
    @required this.cacheName,
  });

  Map toJson() {
    Map json = {
      'cacheId': cacheId.toJson(),
      'securityOrigin': securityOrigin.toString(),
      'cacheName': cacheName.toString(),
    };
    return json;
  }
}

/// Cached response
class CachedResponse {
  /// Response headers
  final Object headers;

  /// Entry content, base64-encoded.
  final String body;

  CachedResponse({
    @required this.headers,
    @required this.body,
  });

  Map toJson() {
    Map json = {
      'headers': headers.toJson(),
      'body': body.toString(),
    };
    return json;
  }
}
