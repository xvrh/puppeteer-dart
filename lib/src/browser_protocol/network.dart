/// Network domain allows tracking network activities of the page. It exposes information about http, file, data and other requests and responses, their headers, bodies, timing, etc.

import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';
import 'security.dart' as security;
import 'page.dart' as page;
import '../runtime.dart' as runtime;

class NetworkManager {
  final Session _client;

  NetworkManager(this._client);

  /// Enables network tracking, network events will now be delivered to the client.
  /// [maxTotalBufferSize] Buffer size in bytes to use when preserving network payloads (XHRs, etc).
  /// [maxResourceBufferSize] Per-resource buffer size in bytes to use when preserving network payloads (XHRs, etc).
  Future enable({
    int maxTotalBufferSize,
    int maxResourceBufferSize,
  }) async {
    Map parameters = {};
    if (maxTotalBufferSize != null) {
      parameters['maxTotalBufferSize'] = maxTotalBufferSize.toString();
    }
    if (maxResourceBufferSize != null) {
      parameters['maxResourceBufferSize'] = maxResourceBufferSize.toString();
    }
    await _client.send('Network.enable', parameters);
  }

  /// Disables network tracking, prevents network events from being sent to the client.
  Future disable() async {
    await _client.send('Network.disable');
  }

  /// Allows overriding user agent with the given string.
  /// [userAgent] User agent to use.
  Future setUserAgentOverride(
    String userAgent,
  ) async {
    Map parameters = {
      'userAgent': userAgent.toString(),
    };
    await _client.send('Network.setUserAgentOverride', parameters);
  }

  /// Specifies whether to always send extra HTTP headers with the requests from this page.
  /// [headers] Map with extra HTTP headers.
  Future setExtraHTTPHeaders(
    Headers headers,
  ) async {
    Map parameters = {
      'headers': headers.toJson(),
    };
    await _client.send('Network.setExtraHTTPHeaders', parameters);
  }

  /// Returns content served for the given request.
  /// [requestId] Identifier of the network request to get content for.
  Future<GetResponseBodyResult> getResponseBody(
    RequestId requestId,
  ) async {
    Map parameters = {
      'requestId': requestId.toJson(),
    };
    await _client.send('Network.getResponseBody', parameters);
  }

  /// Blocks URLs from loading.
  /// [urls] URL patterns to block. Wildcards ('*') are allowed.
  Future setBlockedURLs(
    List<String> urls,
  ) async {
    Map parameters = {
      'urls': urls.map((e) => e.toString()).toList(),
    };
    await _client.send('Network.setBlockedURLs', parameters);
  }

  /// This method sends a new XMLHttpRequest which is identical to the original one. The following parameters should be identical: method, url, async, request body, extra headers, withCredentials attribute, user, password.
  /// [requestId] Identifier of XHR to replay.
  Future replayXHR(
    RequestId requestId,
  ) async {
    Map parameters = {
      'requestId': requestId.toJson(),
    };
    await _client.send('Network.replayXHR', parameters);
  }

  /// Tells whether clearing browser cache is supported.
  /// Return: True if browser cache can be cleared.
  Future<bool> canClearBrowserCache() async {
    await _client.send('Network.canClearBrowserCache');
  }

  /// Clears browser cache.
  Future clearBrowserCache() async {
    await _client.send('Network.clearBrowserCache');
  }

  /// Tells whether clearing browser cookies is supported.
  /// Return: True if browser cookies can be cleared.
  Future<bool> canClearBrowserCookies() async {
    await _client.send('Network.canClearBrowserCookies');
  }

  /// Clears browser cookies.
  Future clearBrowserCookies() async {
    await _client.send('Network.clearBrowserCookies');
  }

  /// Returns all browser cookies for the current URL. Depending on the backend support, will return detailed cookie information in the <code>cookies</code> field.
  /// [urls] The list of URLs for which applicable cookies will be fetched
  /// Return: Array of cookie objects.
  Future<List<Cookie>> getCookies({
    List<String> urls,
  }) async {
    Map parameters = {};
    if (urls != null) {
      parameters['urls'] = urls.map((e) => e.toString()).toList();
    }
    await _client.send('Network.getCookies', parameters);
  }

  /// Returns all browser cookies. Depending on the backend support, will return detailed cookie information in the <code>cookies</code> field.
  /// Return: Array of cookie objects.
  Future<List<Cookie>> getAllCookies() async {
    await _client.send('Network.getAllCookies');
  }

  /// Deletes browser cookies with matching name and url or domain/path pair.
  /// [name] Name of the cookies to remove.
  /// [url] If specified, deletes all the cookies with the given name where domain and path match provided URL.
  /// [domain] If specified, deletes only cookies with the exact domain.
  /// [path] If specified, deletes only cookies with the exact path.
  Future deleteCookies(
    String name, {
    String url,
    String domain,
    String path,
  }) async {
    Map parameters = {
      'name': name.toString(),
    };
    if (url != null) {
      parameters['url'] = url.toString();
    }
    if (domain != null) {
      parameters['domain'] = domain.toString();
    }
    if (path != null) {
      parameters['path'] = path.toString();
    }
    await _client.send('Network.deleteCookies', parameters);
  }

  /// Sets a cookie with the given cookie data; may overwrite equivalent cookies if they exist.
  /// [name] Cookie name.
  /// [value] Cookie value.
  /// [url] The request-URI to associate with the setting of the cookie. This value can affect the default domain and path values of the created cookie.
  /// [domain] Cookie domain.
  /// [path] Cookie path.
  /// [secure] True if cookie is secure.
  /// [httpOnly] True if cookie is http-only.
  /// [sameSite] Cookie SameSite type.
  /// [expires] Cookie expiration date, session cookie if not set
  /// Return: True if successfully set cookie.
  Future<bool> setCookie(
    String name,
    String value, {
    String url,
    String domain,
    String path,
    bool secure,
    bool httpOnly,
    CookieSameSite sameSite,
    TimeSinceEpoch expires,
  }) async {
    Map parameters = {
      'name': name.toString(),
      'value': value.toString(),
    };
    if (url != null) {
      parameters['url'] = url.toString();
    }
    if (domain != null) {
      parameters['domain'] = domain.toString();
    }
    if (path != null) {
      parameters['path'] = path.toString();
    }
    if (secure != null) {
      parameters['secure'] = secure.toString();
    }
    if (httpOnly != null) {
      parameters['httpOnly'] = httpOnly.toString();
    }
    if (sameSite != null) {
      parameters['sameSite'] = sameSite.toJson();
    }
    if (expires != null) {
      parameters['expires'] = expires.toJson();
    }
    await _client.send('Network.setCookie', parameters);
  }

  /// Sets given cookies.
  /// [cookies] Cookies to be set.
  Future setCookies(
    List<CookieParam> cookies,
  ) async {
    Map parameters = {
      'cookies': cookies.map((e) => e.toJson()).toList(),
    };
    await _client.send('Network.setCookies', parameters);
  }

  /// Tells whether emulation of network conditions is supported.
  /// Return: True if emulation of network conditions is supported.
  Future<bool> canEmulateNetworkConditions() async {
    await _client.send('Network.canEmulateNetworkConditions');
  }

  /// Activates emulation of network conditions.
  /// [offline] True to emulate internet disconnection.
  /// [latency] Additional latency (ms).
  /// [downloadThroughput] Maximal aggregated download throughput.
  /// [uploadThroughput] Maximal aggregated upload throughput.
  /// [connectionType] Connection type if known.
  Future emulateNetworkConditions(
    bool offline,
    num latency,
    num downloadThroughput,
    num uploadThroughput, {
    ConnectionType connectionType,
  }) async {
    Map parameters = {
      'offline': offline.toString(),
      'latency': latency.toString(),
      'downloadThroughput': downloadThroughput.toString(),
      'uploadThroughput': uploadThroughput.toString(),
    };
    if (connectionType != null) {
      parameters['connectionType'] = connectionType.toJson();
    }
    await _client.send('Network.emulateNetworkConditions', parameters);
  }

  /// Toggles ignoring cache for each request. If <code>true</code>, cache will not be used.
  /// [cacheDisabled] Cache disabled state.
  Future setCacheDisabled(
    bool cacheDisabled,
  ) async {
    Map parameters = {
      'cacheDisabled': cacheDisabled.toString(),
    };
    await _client.send('Network.setCacheDisabled', parameters);
  }

  /// Toggles ignoring of service worker for each request.
  /// [bypass] Bypass service worker and load from network.
  Future setBypassServiceWorker(
    bool bypass,
  ) async {
    Map parameters = {
      'bypass': bypass.toString(),
    };
    await _client.send('Network.setBypassServiceWorker', parameters);
  }

  /// For testing.
  /// [maxTotalSize] Maximum total buffer size.
  /// [maxResourceSize] Maximum per-resource size.
  Future setDataSizeLimitsForTest(
    int maxTotalSize,
    int maxResourceSize,
  ) async {
    Map parameters = {
      'maxTotalSize': maxTotalSize.toString(),
      'maxResourceSize': maxResourceSize.toString(),
    };
    await _client.send('Network.setDataSizeLimitsForTest', parameters);
  }

  /// Returns the DER-encoded certificate.
  /// [origin] Origin to get certificate for.
  Future<List<String>> getCertificate(
    String origin,
  ) async {
    Map parameters = {
      'origin': origin.toString(),
    };
    await _client.send('Network.getCertificate', parameters);
  }

  /// [enabled] Whether or not HTTP requests should be intercepted and Network.requestIntercepted events sent.
  Future setRequestInterceptionEnabled(
    bool enabled,
  ) async {
    Map parameters = {
      'enabled': enabled.toString(),
    };
    await _client.send('Network.setRequestInterceptionEnabled', parameters);
  }

  /// Response to Network.requestIntercepted which either modifies the request to continue with any modifications, or blocks it, or completes it with the provided response bytes. If a network fetch occurs as a result which encounters a redirect an additional Network.requestIntercepted event will be sent with the same InterceptionId.
  /// [errorReason] If set this causes the request to fail with the given reason. Passing <code>Aborted</code> for requests marked with <code>isNavigationRequest</code> also cancels the navigation. Must not be set in response to an authChallenge.
  /// [rawResponse] If set the requests completes using with the provided base64 encoded raw response, including HTTP status line and headers etc... Must not be set in response to an authChallenge.
  /// [url] If set the request url will be modified in a way that's not observable by page. Must not be set in response to an authChallenge.
  /// [method] If set this allows the request method to be overridden. Must not be set in response to an authChallenge.
  /// [postData] If set this allows postData to be set. Must not be set in response to an authChallenge.
  /// [headers] If set this allows the request headers to be changed. Must not be set in response to an authChallenge.
  /// [authChallengeResponse] Response to a requestIntercepted with an authChallenge. Must not be set otherwise.
  Future continueInterceptedRequest(
    InterceptionId interceptionId, {
    ErrorReason errorReason,
    String rawResponse,
    String url,
    String method,
    String postData,
    Headers headers,
    AuthChallengeResponse authChallengeResponse,
  }) async {
    Map parameters = {
      'interceptionId': interceptionId.toJson(),
    };
    if (errorReason != null) {
      parameters['errorReason'] = errorReason.toJson();
    }
    if (rawResponse != null) {
      parameters['rawResponse'] = rawResponse.toString();
    }
    if (url != null) {
      parameters['url'] = url.toString();
    }
    if (method != null) {
      parameters['method'] = method.toString();
    }
    if (postData != null) {
      parameters['postData'] = postData.toString();
    }
    if (headers != null) {
      parameters['headers'] = headers.toJson();
    }
    if (authChallengeResponse != null) {
      parameters['authChallengeResponse'] = authChallengeResponse.toJson();
    }
    await _client.send('Network.continueInterceptedRequest', parameters);
  }
}

class GetResponseBodyResult {
  /// Response body.
  final String body;

  /// True, if content was sent as base64.
  final bool base64Encoded;

  GetResponseBodyResult({
    @required this.body,
    @required this.base64Encoded,
  });
}

/// Unique loader identifier.
class LoaderId {
  final String value;

  LoaderId(this.value);

  String toJson() => value;
}

/// Unique request identifier.
class RequestId {
  final String value;

  RequestId(this.value);

  String toJson() => value;
}

/// Unique intercepted request identifier.
class InterceptionId {
  final String value;

  InterceptionId(this.value);

  String toJson() => value;
}

/// Network level fetch failure reason.
class ErrorReason {
  static const ErrorReason failed = const ErrorReason._('Failed');
  static const ErrorReason aborted = const ErrorReason._('Aborted');
  static const ErrorReason timedOut = const ErrorReason._('TimedOut');
  static const ErrorReason accessDenied = const ErrorReason._('AccessDenied');
  static const ErrorReason connectionClosed =
      const ErrorReason._('ConnectionClosed');
  static const ErrorReason connectionReset =
      const ErrorReason._('ConnectionReset');
  static const ErrorReason connectionRefused =
      const ErrorReason._('ConnectionRefused');
  static const ErrorReason connectionAborted =
      const ErrorReason._('ConnectionAborted');
  static const ErrorReason connectionFailed =
      const ErrorReason._('ConnectionFailed');
  static const ErrorReason nameNotResolved =
      const ErrorReason._('NameNotResolved');
  static const ErrorReason internetDisconnected =
      const ErrorReason._('InternetDisconnected');
  static const ErrorReason addressUnreachable =
      const ErrorReason._('AddressUnreachable');

  final String value;

  const ErrorReason._(this.value);

  String toJson() => value;
}

/// UTC time in seconds, counted from January 1, 1970.
class TimeSinceEpoch {
  final num value;

  TimeSinceEpoch(this.value);

  num toJson() => value;
}

/// Monotonically increasing time in seconds since an arbitrary point in the past.
class MonotonicTime {
  final num value;

  MonotonicTime(this.value);

  num toJson() => value;
}

/// Request / response headers as keys / values of JSON object.
class Headers {
  final Object value;

  Headers(this.value);

  Object toJson() => value;
}

/// Loading priority of a resource request.
class ConnectionType {
  static const ConnectionType none = const ConnectionType._('none');
  static const ConnectionType cellular2g = const ConnectionType._('cellular2g');
  static const ConnectionType cellular3g = const ConnectionType._('cellular3g');
  static const ConnectionType cellular4g = const ConnectionType._('cellular4g');
  static const ConnectionType bluetooth = const ConnectionType._('bluetooth');
  static const ConnectionType ethernet = const ConnectionType._('ethernet');
  static const ConnectionType wifi = const ConnectionType._('wifi');
  static const ConnectionType wimax = const ConnectionType._('wimax');
  static const ConnectionType other = const ConnectionType._('other');

  final String value;

  const ConnectionType._(this.value);

  String toJson() => value;
}

/// Represents the cookie's 'SameSite' status: https://tools.ietf.org/html/draft-west-first-party-cookies
class CookieSameSite {
  static const CookieSameSite strict = const CookieSameSite._('Strict');
  static const CookieSameSite lax = const CookieSameSite._('Lax');

  final String value;

  const CookieSameSite._(this.value);

  String toJson() => value;
}

/// Timing information for the request.
class ResourceTiming {
  /// Timing's requestTime is a baseline in seconds, while the other numbers are ticks in milliseconds relatively to this requestTime.
  final num requestTime;

  /// Started resolving proxy.
  final num proxyStart;

  /// Finished resolving proxy.
  final num proxyEnd;

  /// Started DNS address resolve.
  final num dnsStart;

  /// Finished DNS address resolve.
  final num dnsEnd;

  /// Started connecting to the remote host.
  final num connectStart;

  /// Connected to the remote host.
  final num connectEnd;

  /// Started SSL handshake.
  final num sslStart;

  /// Finished SSL handshake.
  final num sslEnd;

  /// Started running ServiceWorker.
  final num workerStart;

  /// Finished Starting ServiceWorker.
  final num workerReady;

  /// Started sending request.
  final num sendStart;

  /// Finished sending request.
  final num sendEnd;

  /// Time the server started pushing request.
  final num pushStart;

  /// Time the server finished pushing request.
  final num pushEnd;

  /// Finished receiving response headers.
  final num receiveHeadersEnd;

  ResourceTiming({
    @required this.requestTime,
    @required this.proxyStart,
    @required this.proxyEnd,
    @required this.dnsStart,
    @required this.dnsEnd,
    @required this.connectStart,
    @required this.connectEnd,
    @required this.sslStart,
    @required this.sslEnd,
    @required this.workerStart,
    @required this.workerReady,
    @required this.sendStart,
    @required this.sendEnd,
    @required this.pushStart,
    @required this.pushEnd,
    @required this.receiveHeadersEnd,
  });

  Map toJson() {
    Map json = {
      'requestTime': requestTime.toString(),
      'proxyStart': proxyStart.toString(),
      'proxyEnd': proxyEnd.toString(),
      'dnsStart': dnsStart.toString(),
      'dnsEnd': dnsEnd.toString(),
      'connectStart': connectStart.toString(),
      'connectEnd': connectEnd.toString(),
      'sslStart': sslStart.toString(),
      'sslEnd': sslEnd.toString(),
      'workerStart': workerStart.toString(),
      'workerReady': workerReady.toString(),
      'sendStart': sendStart.toString(),
      'sendEnd': sendEnd.toString(),
      'pushStart': pushStart.toString(),
      'pushEnd': pushEnd.toString(),
      'receiveHeadersEnd': receiveHeadersEnd.toString(),
    };
    return json;
  }
}

/// Loading priority of a resource request.
class ResourcePriority {
  static const ResourcePriority veryLow = const ResourcePriority._('VeryLow');
  static const ResourcePriority low = const ResourcePriority._('Low');
  static const ResourcePriority medium = const ResourcePriority._('Medium');
  static const ResourcePriority high = const ResourcePriority._('High');
  static const ResourcePriority veryHigh = const ResourcePriority._('VeryHigh');

  final String value;

  const ResourcePriority._(this.value);

  String toJson() => value;
}

/// HTTP request data.
class Request {
  /// Request URL.
  final String url;

  /// HTTP request method.
  final String method;

  /// HTTP request headers.
  final Headers headers;

  /// HTTP POST request data.
  final String postData;

  /// The mixed content type of the request.
  final security.MixedContentType mixedContentType;

  /// Priority of the resource request at the time request is sent.
  final ResourcePriority initialPriority;

  /// The referrer policy of the request, as defined in https://www.w3.org/TR/referrer-policy/
  final String referrerPolicy;

  /// Whether is loaded via link preload.
  final bool isLinkPreload;

  Request({
    @required this.url,
    @required this.method,
    @required this.headers,
    this.postData,
    this.mixedContentType,
    @required this.initialPriority,
    @required this.referrerPolicy,
    this.isLinkPreload,
  });

  Map toJson() {
    Map json = {
      'url': url.toString(),
      'method': method.toString(),
      'headers': headers.toJson(),
      'initialPriority': initialPriority.toJson(),
      'referrerPolicy': referrerPolicy.toString(),
    };
    if (postData != null) {
      json['postData'] = postData.toString();
    }
    if (mixedContentType != null) {
      json['mixedContentType'] = mixedContentType.toJson();
    }
    if (isLinkPreload != null) {
      json['isLinkPreload'] = isLinkPreload.toString();
    }
    return json;
  }
}

/// Details of a signed certificate timestamp (SCT).
class SignedCertificateTimestamp {
  /// Validation status.
  final String status;

  /// Origin.
  final String origin;

  /// Log name / description.
  final String logDescription;

  /// Log ID.
  final String logId;

  /// Issuance date.
  final TimeSinceEpoch timestamp;

  /// Hash algorithm.
  final String hashAlgorithm;

  /// Signature algorithm.
  final String signatureAlgorithm;

  /// Signature data.
  final String signatureData;

  SignedCertificateTimestamp({
    @required this.status,
    @required this.origin,
    @required this.logDescription,
    @required this.logId,
    @required this.timestamp,
    @required this.hashAlgorithm,
    @required this.signatureAlgorithm,
    @required this.signatureData,
  });

  Map toJson() {
    Map json = {
      'status': status.toString(),
      'origin': origin.toString(),
      'logDescription': logDescription.toString(),
      'logId': logId.toString(),
      'timestamp': timestamp.toJson(),
      'hashAlgorithm': hashAlgorithm.toString(),
      'signatureAlgorithm': signatureAlgorithm.toString(),
      'signatureData': signatureData.toString(),
    };
    return json;
  }
}

/// Security details about a request.
class SecurityDetails {
  /// Protocol name (e.g. "TLS 1.2" or "QUIC").
  final String protocol;

  /// Key Exchange used by the connection, or the empty string if not applicable.
  final String keyExchange;

  /// (EC)DH group used by the connection, if applicable.
  final String keyExchangeGroup;

  /// Cipher name.
  final String cipher;

  /// TLS MAC. Note that AEAD ciphers do not have separate MACs.
  final String mac;

  /// Certificate ID value.
  final security.CertificateId certificateId;

  /// Certificate subject name.
  final String subjectName;

  /// Subject Alternative Name (SAN) DNS names and IP addresses.
  final List<String> sanList;

  /// Name of the issuing CA.
  final String issuer;

  /// Certificate valid from date.
  final TimeSinceEpoch validFrom;

  /// Certificate valid to (expiration) date
  final TimeSinceEpoch validTo;

  /// List of signed certificate timestamps (SCTs).
  final List<SignedCertificateTimestamp> signedCertificateTimestampList;

  SecurityDetails({
    @required this.protocol,
    @required this.keyExchange,
    this.keyExchangeGroup,
    @required this.cipher,
    this.mac,
    @required this.certificateId,
    @required this.subjectName,
    @required this.sanList,
    @required this.issuer,
    @required this.validFrom,
    @required this.validTo,
    @required this.signedCertificateTimestampList,
  });

  Map toJson() {
    Map json = {
      'protocol': protocol.toString(),
      'keyExchange': keyExchange.toString(),
      'cipher': cipher.toString(),
      'certificateId': certificateId.toJson(),
      'subjectName': subjectName.toString(),
      'sanList': sanList.map((e) => e.toString()).toList(),
      'issuer': issuer.toString(),
      'validFrom': validFrom.toJson(),
      'validTo': validTo.toJson(),
      'signedCertificateTimestampList':
          signedCertificateTimestampList.map((e) => e.toJson()).toList(),
    };
    if (keyExchangeGroup != null) {
      json['keyExchangeGroup'] = keyExchangeGroup.toString();
    }
    if (mac != null) {
      json['mac'] = mac.toString();
    }
    return json;
  }
}

/// The reason why request was blocked.
class BlockedReason {
  static const BlockedReason csp = const BlockedReason._('csp');
  static const BlockedReason mixedContent =
      const BlockedReason._('mixed-content');
  static const BlockedReason origin = const BlockedReason._('origin');
  static const BlockedReason inspector = const BlockedReason._('inspector');
  static const BlockedReason subresourceFilter =
      const BlockedReason._('subresource-filter');
  static const BlockedReason other = const BlockedReason._('other');

  final String value;

  const BlockedReason._(this.value);

  String toJson() => value;
}

/// HTTP response data.
class Response {
  /// Response URL. This URL can be different from CachedResource.url in case of redirect.
  final String url;

  /// HTTP response status code.
  final num status;

  /// HTTP response status text.
  final String statusText;

  /// HTTP response headers.
  final Headers headers;

  /// HTTP response headers text.
  final String headersText;

  /// Resource mimeType as determined by the browser.
  final String mimeType;

  /// Refined HTTP request headers that were actually transmitted over the network.
  final Headers requestHeaders;

  /// HTTP request headers text.
  final String requestHeadersText;

  /// Specifies whether physical connection was actually reused for this request.
  final bool connectionReused;

  /// Physical connection id that was actually used for this request.
  final num connectionId;

  /// Remote IP address.
  final String remoteIPAddress;

  /// Remote port.
  final int remotePort;

  /// Specifies that the request was served from the disk cache.
  final bool fromDiskCache;

  /// Specifies that the request was served from the ServiceWorker.
  final bool fromServiceWorker;

  /// Total number of bytes received for this request so far.
  final num encodedDataLength;

  /// Timing information for the given request.
  final ResourceTiming timing;

  /// Protocol used to fetch this request.
  final String protocol;

  /// Security state of the request resource.
  final security.SecurityState securityState;

  /// Security details for the request.
  final SecurityDetails securityDetails;

  Response({
    @required this.url,
    @required this.status,
    @required this.statusText,
    @required this.headers,
    this.headersText,
    @required this.mimeType,
    this.requestHeaders,
    this.requestHeadersText,
    @required this.connectionReused,
    @required this.connectionId,
    this.remoteIPAddress,
    this.remotePort,
    this.fromDiskCache,
    this.fromServiceWorker,
    @required this.encodedDataLength,
    this.timing,
    this.protocol,
    @required this.securityState,
    this.securityDetails,
  });

  Map toJson() {
    Map json = {
      'url': url.toString(),
      'status': status.toString(),
      'statusText': statusText.toString(),
      'headers': headers.toJson(),
      'mimeType': mimeType.toString(),
      'connectionReused': connectionReused.toString(),
      'connectionId': connectionId.toString(),
      'securityState': securityState.toJson(),
    };
    if (headersText != null) {
      json['headersText'] = headersText.toString();
    }
    if (requestHeaders != null) {
      json['requestHeaders'] = requestHeaders.toJson();
    }
    if (requestHeadersText != null) {
      json['requestHeadersText'] = requestHeadersText.toString();
    }
    if (remoteIPAddress != null) {
      json['remoteIPAddress'] = remoteIPAddress.toString();
    }
    if (remotePort != null) {
      json['remotePort'] = remotePort.toString();
    }
    if (fromDiskCache != null) {
      json['fromDiskCache'] = fromDiskCache.toString();
    }
    if (fromServiceWorker != null) {
      json['fromServiceWorker'] = fromServiceWorker.toString();
    }
    if (timing != null) {
      json['timing'] = timing.toJson();
    }
    if (protocol != null) {
      json['protocol'] = protocol.toString();
    }
    if (securityDetails != null) {
      json['securityDetails'] = securityDetails.toJson();
    }
    return json;
  }
}

/// WebSocket request data.
class WebSocketRequest {
  /// HTTP request headers.
  final Headers headers;

  WebSocketRequest({
    @required this.headers,
  });

  Map toJson() {
    Map json = {
      'headers': headers.toJson(),
    };
    return json;
  }
}

/// WebSocket response data.
class WebSocketResponse {
  /// HTTP response status code.
  final num status;

  /// HTTP response status text.
  final String statusText;

  /// HTTP response headers.
  final Headers headers;

  /// HTTP response headers text.
  final String headersText;

  /// HTTP request headers.
  final Headers requestHeaders;

  /// HTTP request headers text.
  final String requestHeadersText;

  WebSocketResponse({
    @required this.status,
    @required this.statusText,
    @required this.headers,
    this.headersText,
    this.requestHeaders,
    this.requestHeadersText,
  });

  Map toJson() {
    Map json = {
      'status': status.toString(),
      'statusText': statusText.toString(),
      'headers': headers.toJson(),
    };
    if (headersText != null) {
      json['headersText'] = headersText.toString();
    }
    if (requestHeaders != null) {
      json['requestHeaders'] = requestHeaders.toJson();
    }
    if (requestHeadersText != null) {
      json['requestHeadersText'] = requestHeadersText.toString();
    }
    return json;
  }
}

/// WebSocket frame data.
class WebSocketFrame {
  /// WebSocket frame opcode.
  final num opcode;

  /// WebSocke frame mask.
  final bool mask;

  /// WebSocke frame payload data.
  final String payloadData;

  WebSocketFrame({
    @required this.opcode,
    @required this.mask,
    @required this.payloadData,
  });

  Map toJson() {
    Map json = {
      'opcode': opcode.toString(),
      'mask': mask.toString(),
      'payloadData': payloadData.toString(),
    };
    return json;
  }
}

/// Information about the cached resource.
class CachedResource {
  /// Resource URL. This is the url of the original network request.
  final String url;

  /// Type of this resource.
  final page.ResourceType type;

  /// Cached response data.
  final Response response;

  /// Cached response body size.
  final num bodySize;

  CachedResource({
    @required this.url,
    @required this.type,
    this.response,
    @required this.bodySize,
  });

  Map toJson() {
    Map json = {
      'url': url.toString(),
      'type': type.toJson(),
      'bodySize': bodySize.toString(),
    };
    if (response != null) {
      json['response'] = response.toJson();
    }
    return json;
  }
}

/// Information about the request initiator.
class Initiator {
  /// Type of this initiator.
  final String type;

  /// Initiator JavaScript stack trace, set for Script only.
  final runtime.StackTrace stack;

  /// Initiator URL, set for Parser type or for Script type (when script is importing module).
  final String url;

  /// Initiator line number, set for Parser type or for Script type (when script is importing module) (0-based).
  final num lineNumber;

  Initiator({
    @required this.type,
    this.stack,
    this.url,
    this.lineNumber,
  });

  Map toJson() {
    Map json = {
      'type': type.toString(),
    };
    if (stack != null) {
      json['stack'] = stack.toJson();
    }
    if (url != null) {
      json['url'] = url.toString();
    }
    if (lineNumber != null) {
      json['lineNumber'] = lineNumber.toString();
    }
    return json;
  }
}

/// Cookie object
class Cookie {
  /// Cookie name.
  final String name;

  /// Cookie value.
  final String value;

  /// Cookie domain.
  final String domain;

  /// Cookie path.
  final String path;

  /// Cookie expiration date as the number of seconds since the UNIX epoch.
  final num expires;

  /// Cookie size.
  final int size;

  /// True if cookie is http-only.
  final bool httpOnly;

  /// True if cookie is secure.
  final bool secure;

  /// True in case of session cookie.
  final bool session;

  /// Cookie SameSite type.
  final CookieSameSite sameSite;

  Cookie({
    @required this.name,
    @required this.value,
    @required this.domain,
    @required this.path,
    @required this.expires,
    @required this.size,
    @required this.httpOnly,
    @required this.secure,
    @required this.session,
    this.sameSite,
  });

  Map toJson() {
    Map json = {
      'name': name.toString(),
      'value': value.toString(),
      'domain': domain.toString(),
      'path': path.toString(),
      'expires': expires.toString(),
      'size': size.toString(),
      'httpOnly': httpOnly.toString(),
      'secure': secure.toString(),
      'session': session.toString(),
    };
    if (sameSite != null) {
      json['sameSite'] = sameSite.toJson();
    }
    return json;
  }
}

/// Cookie parameter object
class CookieParam {
  /// Cookie name.
  final String name;

  /// Cookie value.
  final String value;

  /// The request-URI to associate with the setting of the cookie. This value can affect the default domain and path values of the created cookie.
  final String url;

  /// Cookie domain.
  final String domain;

  /// Cookie path.
  final String path;

  /// True if cookie is secure.
  final bool secure;

  /// True if cookie is http-only.
  final bool httpOnly;

  /// Cookie SameSite type.
  final CookieSameSite sameSite;

  /// Cookie expiration date, session cookie if not set
  final TimeSinceEpoch expires;

  CookieParam({
    @required this.name,
    @required this.value,
    this.url,
    this.domain,
    this.path,
    this.secure,
    this.httpOnly,
    this.sameSite,
    this.expires,
  });

  Map toJson() {
    Map json = {
      'name': name.toString(),
      'value': value.toString(),
    };
    if (url != null) {
      json['url'] = url.toString();
    }
    if (domain != null) {
      json['domain'] = domain.toString();
    }
    if (path != null) {
      json['path'] = path.toString();
    }
    if (secure != null) {
      json['secure'] = secure.toString();
    }
    if (httpOnly != null) {
      json['httpOnly'] = httpOnly.toString();
    }
    if (sameSite != null) {
      json['sameSite'] = sameSite.toJson();
    }
    if (expires != null) {
      json['expires'] = expires.toJson();
    }
    return json;
  }
}

/// Authorization challenge for HTTP status code 401 or 407.
class AuthChallenge {
  /// Source of the authentication challenge.
  final String source;

  /// Origin of the challenger.
  final String origin;

  /// The authentication scheme used, such as basic or digest
  final String scheme;

  /// The realm of the challenge. May be empty.
  final String realm;

  AuthChallenge({
    this.source,
    @required this.origin,
    @required this.scheme,
    @required this.realm,
  });

  Map toJson() {
    Map json = {
      'origin': origin.toString(),
      'scheme': scheme.toString(),
      'realm': realm.toString(),
    };
    if (source != null) {
      json['source'] = source.toString();
    }
    return json;
  }
}

/// Response to an AuthChallenge.
class AuthChallengeResponse {
  /// The decision on what to do in response to the authorization challenge.  Default means deferring to the default behavior of the net stack, which will likely either the Cancel authentication or display a popup dialog box.
  final String response;

  /// The username to provide, possibly empty. Should only be set if response is ProvideCredentials.
  final String username;

  /// The password to provide, possibly empty. Should only be set if response is ProvideCredentials.
  final String password;

  AuthChallengeResponse({
    @required this.response,
    this.username,
    this.password,
  });

  Map toJson() {
    Map json = {
      'response': response.toString(),
    };
    if (username != null) {
      json['username'] = username.toString();
    }
    if (password != null) {
      json['password'] = password.toString();
    }
    return json;
  }
}
