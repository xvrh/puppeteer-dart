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
      'securityOrigin': securityOrigin,
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
      'skipCount': skipCount,
      'pageSize': pageSize,
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
      'request': request,
    };
    await _client.send('CacheStorage.deleteEntry', parameters);
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

  factory RequestEntriesResult.fromJson(Map json) {
    return new RequestEntriesResult(
      cacheDataEntries: (json['cacheDataEntries'] as List)
          .map((e) => new DataEntry.fromJson(e))
          .toList(),
      hasMore: json['hasMore'],
    );
  }
}

/// Unique identifier of the Cache object.
class CacheId {
  final String value;

  CacheId(this.value);

  factory CacheId.fromJson(String value) => new CacheId(value);

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

  factory DataEntry.fromJson(Map json) {
    return new DataEntry(
      request: json['request'],
      response: json['response'],
      responseTime: json['responseTime'],
    );
  }

  Map toJson() {
    Map json = {
      'request': request,
      'response': response,
      'responseTime': responseTime,
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

  factory Cache.fromJson(Map json) {
    return new Cache(
      cacheId: new CacheId.fromJson(json['cacheId']),
      securityOrigin: json['securityOrigin'],
      cacheName: json['cacheName'],
    );
  }

  Map toJson() {
    Map json = {
      'cacheId': cacheId.toJson(),
      'securityOrigin': securityOrigin,
      'cacheName': cacheName,
    };
    return json;
  }
}
