import 'dart:async';
import 'package:meta/meta.dart' show required;
import 'src/connection.dart';

class CacheStorageApi {
  final Client _client;

  CacheStorageApi(this._client);

  /// Deletes a cache.
  /// [cacheId] Id of cache for deletion.
  Future<void> deleteCache(CacheId cacheId) async {
    var parameters = <String, dynamic>{
      'cacheId': cacheId.toJson(),
    };
    await _client.send('CacheStorage.deleteCache', parameters);
  }

  /// Deletes a cache entry.
  /// [cacheId] Id of cache where the entry will be deleted.
  /// [request] URL spec of the request.
  Future<void> deleteEntry(CacheId cacheId, String request) async {
    var parameters = <String, dynamic>{
      'cacheId': cacheId.toJson(),
      'request': request,
    };
    await _client.send('CacheStorage.deleteEntry', parameters);
  }

  /// Requests cache names.
  /// [securityOrigin] Security origin.
  /// Returns: Caches for the security origin.
  Future<List<Cache>> requestCacheNames(String securityOrigin) async {
    var parameters = <String, dynamic>{
      'securityOrigin': securityOrigin,
    };
    var result =
        await _client.send('CacheStorage.requestCacheNames', parameters);
    return (result['caches'] as List).map((e) => Cache.fromJson(e)).toList();
  }

  /// Fetches cache entry.
  /// [cacheId] Id of cache that contains the entry.
  /// [requestURL] URL spec of the request.
  /// [requestHeaders] headers of the request.
  /// Returns: Response read from the cache.
  Future<CachedResponse> requestCachedResponse(
      CacheId cacheId, String requestURL, List<Header> requestHeaders) async {
    var parameters = <String, dynamic>{
      'cacheId': cacheId.toJson(),
      'requestURL': requestURL,
      'requestHeaders': requestHeaders.map((e) => e.toJson()).toList(),
    };
    var result =
        await _client.send('CacheStorage.requestCachedResponse', parameters);
    return CachedResponse.fromJson(result['response']);
  }

  /// Requests data from cache.
  /// [cacheId] ID of cache to get entries from.
  /// [skipCount] Number of records to skip.
  /// [pageSize] Number of records to fetch.
  /// [pathFilter] If present, only return the entries containing this substring in the path
  Future<RequestEntriesResult> requestEntries(
      CacheId cacheId, int skipCount, int pageSize,
      {String pathFilter}) async {
    var parameters = <String, dynamic>{
      'cacheId': cacheId.toJson(),
      'skipCount': skipCount,
      'pageSize': pageSize,
    };
    if (pathFilter != null) {
      parameters['pathFilter'] = pathFilter;
    }
    var result = await _client.send('CacheStorage.requestEntries', parameters);
    return RequestEntriesResult.fromJson(result);
  }
}

class RequestEntriesResult {
  /// Array of object store data entries.
  final List<DataEntry> cacheDataEntries;

  /// Count of returned entries from this storage. If pathFilter is empty, it
  /// is the count of all entries from this storage.
  final num returnCount;

  RequestEntriesResult(
      {@required this.cacheDataEntries, @required this.returnCount});

  factory RequestEntriesResult.fromJson(Map<String, dynamic> json) {
    return RequestEntriesResult(
      cacheDataEntries: (json['cacheDataEntries'] as List)
          .map((e) => DataEntry.fromJson(e))
          .toList(),
      returnCount: json['returnCount'],
    );
  }
}

/// Unique identifier of the Cache object.
class CacheId {
  final String value;

  CacheId(this.value);

  factory CacheId.fromJson(String value) => CacheId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CacheId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// type of HTTP response cached
class CachedResponseType {
  static const basic = CachedResponseType._('basic');
  static const cors = CachedResponseType._('cors');
  static const default$ = CachedResponseType._('default');
  static const error = CachedResponseType._('error');
  static const opaqueResponse = CachedResponseType._('opaqueResponse');
  static const opaqueRedirect = CachedResponseType._('opaqueRedirect');
  static const values = {
    'basic': basic,
    'cors': cors,
    'default': default$,
    'error': error,
    'opaqueResponse': opaqueResponse,
    'opaqueRedirect': opaqueRedirect,
  };

  final String value;

  const CachedResponseType._(this.value);

  factory CachedResponseType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CachedResponseType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Data entry.
class DataEntry {
  /// Request URL.
  final String requestURL;

  /// Request method.
  final String requestMethod;

  /// Request headers
  final List<Header> requestHeaders;

  /// Number of seconds since epoch.
  final num responseTime;

  /// HTTP response status code.
  final int responseStatus;

  /// HTTP response status text.
  final String responseStatusText;

  /// HTTP response type
  final CachedResponseType responseType;

  /// Response headers
  final List<Header> responseHeaders;

  DataEntry(
      {@required this.requestURL,
      @required this.requestMethod,
      @required this.requestHeaders,
      @required this.responseTime,
      @required this.responseStatus,
      @required this.responseStatusText,
      @required this.responseType,
      @required this.responseHeaders});

  factory DataEntry.fromJson(Map<String, dynamic> json) {
    return DataEntry(
      requestURL: json['requestURL'],
      requestMethod: json['requestMethod'],
      requestHeaders: (json['requestHeaders'] as List)
          .map((e) => Header.fromJson(e))
          .toList(),
      responseTime: json['responseTime'],
      responseStatus: json['responseStatus'],
      responseStatusText: json['responseStatusText'],
      responseType: CachedResponseType.fromJson(json['responseType']),
      responseHeaders: (json['responseHeaders'] as List)
          .map((e) => Header.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'requestURL': requestURL,
      'requestMethod': requestMethod,
      'requestHeaders': requestHeaders.map((e) => e.toJson()).toList(),
      'responseTime': responseTime,
      'responseStatus': responseStatus,
      'responseStatusText': responseStatusText,
      'responseType': responseType.toJson(),
      'responseHeaders': responseHeaders.map((e) => e.toJson()).toList(),
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

  Cache(
      {@required this.cacheId,
      @required this.securityOrigin,
      @required this.cacheName});

  factory Cache.fromJson(Map<String, dynamic> json) {
    return Cache(
      cacheId: CacheId.fromJson(json['cacheId']),
      securityOrigin: json['securityOrigin'],
      cacheName: json['cacheName'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'cacheId': cacheId.toJson(),
      'securityOrigin': securityOrigin,
      'cacheName': cacheName,
    };
    return json;
  }
}

class Header {
  final String name;

  final String value;

  Header({@required this.name, @required this.value});

  factory Header.fromJson(Map<String, dynamic> json) {
    return Header(
      name: json['name'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'name': name,
      'value': value,
    };
    return json;
  }
}

/// Cached response
class CachedResponse {
  /// Entry content, base64-encoded.
  final String body;

  CachedResponse({@required this.body});

  factory CachedResponse.fromJson(Map<String, dynamic> json) {
    return CachedResponse(
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'body': body,
    };
    return json;
  }
}
