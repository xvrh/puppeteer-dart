import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'debugger.dart' as debugger;
import 'io.dart' as io;
import 'page.dart' as page;
import 'runtime.dart' as runtime;
import 'security.dart' as security;

/// Network domain allows tracking network activities of the page. It exposes information about http,
/// file, data and other requests and responses, their headers, bodies, timing, etc.
class NetworkApi {
  final Client _client;

  NetworkApi(this._client);

  /// Fired when data chunk was received over the network.
  Stream<DataReceivedEvent> get onDataReceived => _client.onEvent
      .where((Event event) => event.name == 'Network.dataReceived')
      .map((Event event) => DataReceivedEvent.fromJson(event.parameters));

  /// Fired when EventSource message is received.
  Stream<EventSourceMessageReceivedEvent> get onEventSourceMessageReceived =>
      _client.onEvent
          .where((Event event) =>
              event.name == 'Network.eventSourceMessageReceived')
          .map((Event event) =>
              EventSourceMessageReceivedEvent.fromJson(event.parameters));

  /// Fired when HTTP request has failed to load.
  Stream<LoadingFailedEvent> get onLoadingFailed => _client.onEvent
      .where((Event event) => event.name == 'Network.loadingFailed')
      .map((Event event) => LoadingFailedEvent.fromJson(event.parameters));

  /// Fired when HTTP request has finished loading.
  Stream<LoadingFinishedEvent> get onLoadingFinished => _client.onEvent
      .where((Event event) => event.name == 'Network.loadingFinished')
      .map((Event event) => LoadingFinishedEvent.fromJson(event.parameters));

  /// Details of an intercepted HTTP request, which must be either allowed, blocked, modified or
  /// mocked.
  Stream<RequestInterceptedEvent> get onRequestIntercepted => _client.onEvent
      .where((Event event) => event.name == 'Network.requestIntercepted')
      .map((Event event) => RequestInterceptedEvent.fromJson(event.parameters));

  /// Fired if request ended up loading from cache.
  Stream<RequestId> get onRequestServedFromCache => _client.onEvent
      .where((Event event) => event.name == 'Network.requestServedFromCache')
      .map((Event event) => RequestId.fromJson(event.parameters['requestId']));

  /// Fired when page is about to send HTTP request.
  Stream<RequestWillBeSentEvent> get onRequestWillBeSent => _client.onEvent
      .where((Event event) => event.name == 'Network.requestWillBeSent')
      .map((Event event) => RequestWillBeSentEvent.fromJson(event.parameters));

  /// Fired when resource loading priority is changed
  Stream<ResourceChangedPriorityEvent> get onResourceChangedPriority => _client
      .onEvent
      .where((Event event) => event.name == 'Network.resourceChangedPriority')
      .map((Event event) =>
          ResourceChangedPriorityEvent.fromJson(event.parameters));

  /// Fired when a signed exchange was received over the network
  Stream<SignedExchangeReceivedEvent> get onSignedExchangeReceived => _client
      .onEvent
      .where((Event event) => event.name == 'Network.signedExchangeReceived')
      .map((Event event) =>
          SignedExchangeReceivedEvent.fromJson(event.parameters));

  /// Fired when HTTP response is available.
  Stream<ResponseReceivedEvent> get onResponseReceived => _client.onEvent
      .where((Event event) => event.name == 'Network.responseReceived')
      .map((Event event) => ResponseReceivedEvent.fromJson(event.parameters));

  /// Fired when WebSocket is closed.
  Stream<WebSocketClosedEvent> get onWebSocketClosed => _client.onEvent
      .where((Event event) => event.name == 'Network.webSocketClosed')
      .map((Event event) => WebSocketClosedEvent.fromJson(event.parameters));

  /// Fired upon WebSocket creation.
  Stream<WebSocketCreatedEvent> get onWebSocketCreated => _client.onEvent
      .where((Event event) => event.name == 'Network.webSocketCreated')
      .map((Event event) => WebSocketCreatedEvent.fromJson(event.parameters));

  /// Fired when WebSocket message error occurs.
  Stream<WebSocketFrameErrorEvent> get onWebSocketFrameError => _client.onEvent
      .where((Event event) => event.name == 'Network.webSocketFrameError')
      .map(
          (Event event) => WebSocketFrameErrorEvent.fromJson(event.parameters));

  /// Fired when WebSocket message is received.
  Stream<WebSocketFrameReceivedEvent> get onWebSocketFrameReceived => _client
      .onEvent
      .where((Event event) => event.name == 'Network.webSocketFrameReceived')
      .map((Event event) =>
          WebSocketFrameReceivedEvent.fromJson(event.parameters));

  /// Fired when WebSocket message is sent.
  Stream<WebSocketFrameSentEvent> get onWebSocketFrameSent => _client.onEvent
      .where((Event event) => event.name == 'Network.webSocketFrameSent')
      .map((Event event) => WebSocketFrameSentEvent.fromJson(event.parameters));

  /// Fired when WebSocket handshake response becomes available.
  Stream<WebSocketHandshakeResponseReceivedEvent>
      get onWebSocketHandshakeResponseReceived => _client.onEvent
          .where((Event event) =>
              event.name == 'Network.webSocketHandshakeResponseReceived')
          .map((Event event) =>
              WebSocketHandshakeResponseReceivedEvent.fromJson(
                  event.parameters));

  /// Fired when WebSocket is about to initiate handshake.
  Stream<WebSocketWillSendHandshakeRequestEvent>
      get onWebSocketWillSendHandshakeRequest => _client.onEvent
          .where((Event event) =>
              event.name == 'Network.webSocketWillSendHandshakeRequest')
          .map((Event event) => WebSocketWillSendHandshakeRequestEvent.fromJson(
              event.parameters));

  /// Tells whether clearing browser cache is supported.
  /// Returns: True if browser cache can be cleared.
  @deprecated
  Future<bool> canClearBrowserCache() async {
    var result = await _client.send('Network.canClearBrowserCache');
    return result['result'];
  }

  /// Tells whether clearing browser cookies is supported.
  /// Returns: True if browser cookies can be cleared.
  @deprecated
  Future<bool> canClearBrowserCookies() async {
    var result = await _client.send('Network.canClearBrowserCookies');
    return result['result'];
  }

  /// Tells whether emulation of network conditions is supported.
  /// Returns: True if emulation of network conditions is supported.
  @deprecated
  Future<bool> canEmulateNetworkConditions() async {
    var result = await _client.send('Network.canEmulateNetworkConditions');
    return result['result'];
  }

  /// Clears browser cache.
  Future<void> clearBrowserCache() async {
    await _client.send('Network.clearBrowserCache');
  }

  /// Clears browser cookies.
  Future<void> clearBrowserCookies() async {
    await _client.send('Network.clearBrowserCookies');
  }

  /// Response to Network.requestIntercepted which either modifies the request to continue with any
  /// modifications, or blocks it, or completes it with the provided response bytes. If a network
  /// fetch occurs as a result which encounters a redirect an additional Network.requestIntercepted
  /// event will be sent with the same InterceptionId.
  /// [errorReason] If set this causes the request to fail with the given reason. Passing `Aborted` for requests
  /// marked with `isNavigationRequest` also cancels the navigation. Must not be set in response
  /// to an authChallenge.
  /// [rawResponse] If set the requests completes using with the provided base64 encoded raw response, including
  /// HTTP status line and headers etc... Must not be set in response to an authChallenge.
  /// [url] If set the request url will be modified in a way that's not observable by page. Must not be
  /// set in response to an authChallenge.
  /// [method] If set this allows the request method to be overridden. Must not be set in response to an
  /// authChallenge.
  /// [postData] If set this allows postData to be set. Must not be set in response to an authChallenge.
  /// [headers] If set this allows the request headers to be changed. Must not be set in response to an
  /// authChallenge.
  /// [authChallengeResponse] Response to a requestIntercepted with an authChallenge. Must not be set otherwise.
  Future<void> continueInterceptedRequest(InterceptionId interceptionId,
      {ErrorReason errorReason,
      String rawResponse,
      String url,
      String method,
      String postData,
      Headers headers,
      AuthChallengeResponse authChallengeResponse}) async {
    var parameters = <String, dynamic>{
      'interceptionId': interceptionId.toJson(),
    };
    if (errorReason != null) {
      parameters['errorReason'] = errorReason.toJson();
    }
    if (rawResponse != null) {
      parameters['rawResponse'] = rawResponse;
    }
    if (url != null) {
      parameters['url'] = url;
    }
    if (method != null) {
      parameters['method'] = method;
    }
    if (postData != null) {
      parameters['postData'] = postData;
    }
    if (headers != null) {
      parameters['headers'] = headers.toJson();
    }
    if (authChallengeResponse != null) {
      parameters['authChallengeResponse'] = authChallengeResponse.toJson();
    }
    await _client.send('Network.continueInterceptedRequest', parameters);
  }

  /// Deletes browser cookies with matching name and url or domain/path pair.
  /// [name] Name of the cookies to remove.
  /// [url] If specified, deletes all the cookies with the given name where domain and path match
  /// provided URL.
  /// [domain] If specified, deletes only cookies with the exact domain.
  /// [path] If specified, deletes only cookies with the exact path.
  Future<void> deleteCookies(String name,
      {String url, String domain, String path}) async {
    var parameters = <String, dynamic>{
      'name': name,
    };
    if (url != null) {
      parameters['url'] = url;
    }
    if (domain != null) {
      parameters['domain'] = domain;
    }
    if (path != null) {
      parameters['path'] = path;
    }
    await _client.send('Network.deleteCookies', parameters);
  }

  /// Disables network tracking, prevents network events from being sent to the client.
  Future<void> disable() async {
    await _client.send('Network.disable');
  }

  /// Activates emulation of network conditions.
  /// [offline] True to emulate internet disconnection.
  /// [latency] Minimum latency from request sent to response headers received (ms).
  /// [downloadThroughput] Maximal aggregated download throughput (bytes/sec). -1 disables download throttling.
  /// [uploadThroughput] Maximal aggregated upload throughput (bytes/sec).  -1 disables upload throttling.
  /// [connectionType] Connection type if known.
  Future<void> emulateNetworkConditions(
      bool offline, num latency, num downloadThroughput, num uploadThroughput,
      {ConnectionType connectionType}) async {
    var parameters = <String, dynamic>{
      'offline': offline,
      'latency': latency,
      'downloadThroughput': downloadThroughput,
      'uploadThroughput': uploadThroughput,
    };
    if (connectionType != null) {
      parameters['connectionType'] = connectionType.toJson();
    }
    await _client.send('Network.emulateNetworkConditions', parameters);
  }

  /// Enables network tracking, network events will now be delivered to the client.
  /// [maxTotalBufferSize] Buffer size in bytes to use when preserving network payloads (XHRs, etc).
  /// [maxResourceBufferSize] Per-resource buffer size in bytes to use when preserving network payloads (XHRs, etc).
  /// [maxPostDataSize] Longest post body size (in bytes) that would be included in requestWillBeSent notification
  Future<void> enable(
      {int maxTotalBufferSize,
      int maxResourceBufferSize,
      int maxPostDataSize}) async {
    var parameters = <String, dynamic>{};
    if (maxTotalBufferSize != null) {
      parameters['maxTotalBufferSize'] = maxTotalBufferSize;
    }
    if (maxResourceBufferSize != null) {
      parameters['maxResourceBufferSize'] = maxResourceBufferSize;
    }
    if (maxPostDataSize != null) {
      parameters['maxPostDataSize'] = maxPostDataSize;
    }
    await _client.send('Network.enable', parameters);
  }

  /// Returns all browser cookies. Depending on the backend support, will return detailed cookie
  /// information in the `cookies` field.
  /// Returns: Array of cookie objects.
  Future<List<Cookie>> getAllCookies() async {
    var result = await _client.send('Network.getAllCookies');
    return (result['cookies'] as List).map((e) => Cookie.fromJson(e)).toList();
  }

  /// Returns the DER-encoded certificate.
  /// [origin] Origin to get certificate for.
  Future<List<String>> getCertificate(String origin) async {
    var parameters = <String, dynamic>{
      'origin': origin,
    };
    var result = await _client.send('Network.getCertificate', parameters);
    return (result['tableNames'] as List).map((e) => e as String).toList();
  }

  /// Returns all browser cookies for the current URL. Depending on the backend support, will return
  /// detailed cookie information in the `cookies` field.
  /// [urls] The list of URLs for which applicable cookies will be fetched
  /// Returns: Array of cookie objects.
  Future<List<Cookie>> getCookies({List<String> urls}) async {
    var parameters = <String, dynamic>{};
    if (urls != null) {
      parameters['urls'] = urls.map((e) => e).toList();
    }
    var result = await _client.send('Network.getCookies', parameters);
    return (result['cookies'] as List).map((e) => Cookie.fromJson(e)).toList();
  }

  /// Returns content served for the given request.
  /// [requestId] Identifier of the network request to get content for.
  Future<GetResponseBodyResult> getResponseBody(RequestId requestId) async {
    var parameters = <String, dynamic>{
      'requestId': requestId.toJson(),
    };
    var result = await _client.send('Network.getResponseBody', parameters);
    return GetResponseBodyResult.fromJson(result);
  }

  /// Returns post data sent with the request. Returns an error when no data was sent with the request.
  /// [requestId] Identifier of the network request to get content for.
  /// Returns: Request body string, omitting files from multipart requests
  Future<String> getRequestPostData(RequestId requestId) async {
    var parameters = <String, dynamic>{
      'requestId': requestId.toJson(),
    };
    var result = await _client.send('Network.getRequestPostData', parameters);
    return result['postData'];
  }

  /// Returns content served for the given currently intercepted request.
  /// [interceptionId] Identifier for the intercepted request to get body for.
  Future<GetResponseBodyForInterceptionResult> getResponseBodyForInterception(
      InterceptionId interceptionId) async {
    var parameters = <String, dynamic>{
      'interceptionId': interceptionId.toJson(),
    };
    var result = await _client.send(
        'Network.getResponseBodyForInterception', parameters);
    return GetResponseBodyForInterceptionResult.fromJson(result);
  }

  /// Returns a handle to the stream representing the response body. Note that after this command,
  /// the intercepted request can't be continued as is -- you either need to cancel it or to provide
  /// the response body. The stream only supports sequential read, IO.read will fail if the position
  /// is specified.
  Future<io.StreamHandle> takeResponseBodyForInterceptionAsStream(
      InterceptionId interceptionId) async {
    var parameters = <String, dynamic>{
      'interceptionId': interceptionId.toJson(),
    };
    var result = await _client.send(
        'Network.takeResponseBodyForInterceptionAsStream', parameters);
    return io.StreamHandle.fromJson(result['stream']);
  }

  /// This method sends a new XMLHttpRequest which is identical to the original one. The following
  /// parameters should be identical: method, url, async, request body, extra headers, withCredentials
  /// attribute, user, password.
  /// [requestId] Identifier of XHR to replay.
  Future<void> replayXHR(RequestId requestId) async {
    var parameters = <String, dynamic>{
      'requestId': requestId.toJson(),
    };
    await _client.send('Network.replayXHR', parameters);
  }

  /// Searches for given string in response content.
  /// [requestId] Identifier of the network response to search.
  /// [query] String to search for.
  /// [caseSensitive] If true, search is case sensitive.
  /// [isRegex] If true, treats string parameter as regex.
  /// Returns: List of search matches.
  Future<List<debugger.SearchMatch>> searchInResponseBody(
      RequestId requestId, String query,
      {bool caseSensitive, bool isRegex}) async {
    var parameters = <String, dynamic>{
      'requestId': requestId.toJson(),
      'query': query,
    };
    if (caseSensitive != null) {
      parameters['caseSensitive'] = caseSensitive;
    }
    if (isRegex != null) {
      parameters['isRegex'] = isRegex;
    }
    var result = await _client.send('Network.searchInResponseBody', parameters);
    return (result['result'] as List)
        .map((e) => debugger.SearchMatch.fromJson(e))
        .toList();
  }

  /// Blocks URLs from loading.
  /// [urls] URL patterns to block. Wildcards ('*') are allowed.
  Future<void> setBlockedURLs(List<String> urls) async {
    var parameters = <String, dynamic>{
      'urls': urls.map((e) => e).toList(),
    };
    await _client.send('Network.setBlockedURLs', parameters);
  }

  /// Toggles ignoring of service worker for each request.
  /// [bypass] Bypass service worker and load from network.
  Future<void> setBypassServiceWorker(bool bypass) async {
    var parameters = <String, dynamic>{
      'bypass': bypass,
    };
    await _client.send('Network.setBypassServiceWorker', parameters);
  }

  /// Toggles ignoring cache for each request. If `true`, cache will not be used.
  /// [cacheDisabled] Cache disabled state.
  Future<void> setCacheDisabled(bool cacheDisabled) async {
    var parameters = <String, dynamic>{
      'cacheDisabled': cacheDisabled,
    };
    await _client.send('Network.setCacheDisabled', parameters);
  }

  /// Sets a cookie with the given cookie data; may overwrite equivalent cookies if they exist.
  /// [name] Cookie name.
  /// [value] Cookie value.
  /// [url] The request-URI to associate with the setting of the cookie. This value can affect the
  /// default domain and path values of the created cookie.
  /// [domain] Cookie domain.
  /// [path] Cookie path.
  /// [secure] True if cookie is secure.
  /// [httpOnly] True if cookie is http-only.
  /// [sameSite] Cookie SameSite type.
  /// [expires] Cookie expiration date, session cookie if not set
  /// Returns: True if successfully set cookie.
  Future<bool> setCookie(String name, String value,
      {String url,
      String domain,
      String path,
      bool secure,
      bool httpOnly,
      CookieSameSite sameSite,
      TimeSinceEpoch expires}) async {
    var parameters = <String, dynamic>{
      'name': name,
      'value': value,
    };
    if (url != null) {
      parameters['url'] = url;
    }
    if (domain != null) {
      parameters['domain'] = domain;
    }
    if (path != null) {
      parameters['path'] = path;
    }
    if (secure != null) {
      parameters['secure'] = secure;
    }
    if (httpOnly != null) {
      parameters['httpOnly'] = httpOnly;
    }
    if (sameSite != null) {
      parameters['sameSite'] = sameSite.toJson();
    }
    if (expires != null) {
      parameters['expires'] = expires.toJson();
    }
    var result = await _client.send('Network.setCookie', parameters);
    return result['success'];
  }

  /// Sets given cookies.
  /// [cookies] Cookies to be set.
  Future<void> setCookies(List<CookieParam> cookies) async {
    var parameters = <String, dynamic>{
      'cookies': cookies.map((e) => e.toJson()).toList(),
    };
    await _client.send('Network.setCookies', parameters);
  }

  /// For testing.
  /// [maxTotalSize] Maximum total buffer size.
  /// [maxResourceSize] Maximum per-resource size.
  Future<void> setDataSizeLimitsForTest(
      int maxTotalSize, int maxResourceSize) async {
    var parameters = <String, dynamic>{
      'maxTotalSize': maxTotalSize,
      'maxResourceSize': maxResourceSize,
    };
    await _client.send('Network.setDataSizeLimitsForTest', parameters);
  }

  /// Specifies whether to always send extra HTTP headers with the requests from this page.
  /// [headers] Map with extra HTTP headers.
  Future<void> setExtraHTTPHeaders(Headers headers) async {
    var parameters = <String, dynamic>{
      'headers': headers.toJson(),
    };
    await _client.send('Network.setExtraHTTPHeaders', parameters);
  }

  /// Sets the requests to intercept that match the provided patterns and optionally resource types.
  /// [patterns] Requests matching any of these patterns will be forwarded and wait for the corresponding
  /// continueInterceptedRequest call.
  Future<void> setRequestInterception(List<RequestPattern> patterns) async {
    var parameters = <String, dynamic>{
      'patterns': patterns.map((e) => e.toJson()).toList(),
    };
    await _client.send('Network.setRequestInterception', parameters);
  }

  /// Allows overriding user agent with the given string.
  /// [userAgent] User agent to use.
  /// [acceptLanguage] Browser langugage to emulate.
  /// [platform] The platform navigator.platform should return.
  Future<void> setUserAgentOverride(String userAgent,
      {String acceptLanguage, String platform}) async {
    var parameters = <String, dynamic>{
      'userAgent': userAgent,
    };
    if (acceptLanguage != null) {
      parameters['acceptLanguage'] = acceptLanguage;
    }
    if (platform != null) {
      parameters['platform'] = platform;
    }
    await _client.send('Network.setUserAgentOverride', parameters);
  }
}

class DataReceivedEvent {
  /// Request identifier.
  final RequestId requestId;

  /// Timestamp.
  final MonotonicTime timestamp;

  /// Data chunk length.
  final int dataLength;

  /// Actual bytes received (might be less than dataLength for compressed encodings).
  final int encodedDataLength;

  DataReceivedEvent(
      {@required this.requestId,
      @required this.timestamp,
      @required this.dataLength,
      @required this.encodedDataLength});

  factory DataReceivedEvent.fromJson(Map<String, dynamic> json) {
    return DataReceivedEvent(
      requestId: RequestId.fromJson(json['requestId']),
      timestamp: MonotonicTime.fromJson(json['timestamp']),
      dataLength: json['dataLength'],
      encodedDataLength: json['encodedDataLength'],
    );
  }
}

class EventSourceMessageReceivedEvent {
  /// Request identifier.
  final RequestId requestId;

  /// Timestamp.
  final MonotonicTime timestamp;

  /// Message type.
  final String eventName;

  /// Message identifier.
  final String eventId;

  /// Message content.
  final String data;

  EventSourceMessageReceivedEvent(
      {@required this.requestId,
      @required this.timestamp,
      @required this.eventName,
      @required this.eventId,
      @required this.data});

  factory EventSourceMessageReceivedEvent.fromJson(Map<String, dynamic> json) {
    return EventSourceMessageReceivedEvent(
      requestId: RequestId.fromJson(json['requestId']),
      timestamp: MonotonicTime.fromJson(json['timestamp']),
      eventName: json['eventName'],
      eventId: json['eventId'],
      data: json['data'],
    );
  }
}

class LoadingFailedEvent {
  /// Request identifier.
  final RequestId requestId;

  /// Timestamp.
  final MonotonicTime timestamp;

  /// Resource type.
  final ResourceType type;

  /// User friendly error message.
  final String errorText;

  /// True if loading was canceled.
  final bool canceled;

  /// The reason why loading was blocked, if any.
  final BlockedReason blockedReason;

  LoadingFailedEvent(
      {@required this.requestId,
      @required this.timestamp,
      @required this.type,
      @required this.errorText,
      this.canceled,
      this.blockedReason});

  factory LoadingFailedEvent.fromJson(Map<String, dynamic> json) {
    return LoadingFailedEvent(
      requestId: RequestId.fromJson(json['requestId']),
      timestamp: MonotonicTime.fromJson(json['timestamp']),
      type: ResourceType.fromJson(json['type']),
      errorText: json['errorText'],
      canceled: json.containsKey('canceled') ? json['canceled'] : null,
      blockedReason: json.containsKey('blockedReason')
          ? BlockedReason.fromJson(json['blockedReason'])
          : null,
    );
  }
}

class LoadingFinishedEvent {
  /// Request identifier.
  final RequestId requestId;

  /// Timestamp.
  final MonotonicTime timestamp;

  /// Total number of bytes received for this request.
  final num encodedDataLength;

  /// Set when 1) response was blocked by Cross-Origin Read Blocking and also
  /// 2) this needs to be reported to the DevTools console.
  final bool shouldReportCorbBlocking;

  LoadingFinishedEvent(
      {@required this.requestId,
      @required this.timestamp,
      @required this.encodedDataLength,
      this.shouldReportCorbBlocking});

  factory LoadingFinishedEvent.fromJson(Map<String, dynamic> json) {
    return LoadingFinishedEvent(
      requestId: RequestId.fromJson(json['requestId']),
      timestamp: MonotonicTime.fromJson(json['timestamp']),
      encodedDataLength: json['encodedDataLength'],
      shouldReportCorbBlocking: json.containsKey('shouldReportCorbBlocking')
          ? json['shouldReportCorbBlocking']
          : null,
    );
  }
}

class RequestInterceptedEvent {
  /// Each request the page makes will have a unique id, however if any redirects are encountered
  /// while processing that fetch, they will be reported with the same id as the original fetch.
  /// Likewise if HTTP authentication is needed then the same fetch id will be used.
  final InterceptionId interceptionId;

  final RequestData request;

  /// The id of the frame that initiated the request.
  final page.FrameId frameId;

  /// How the requested resource will be used.
  final ResourceType resourceType;

  /// Whether this is a navigation request, which can abort the navigation completely.
  final bool isNavigationRequest;

  /// Set if the request is a navigation that will result in a download.
  /// Only present after response is received from the server (i.e. HeadersReceived stage).
  final bool isDownload;

  /// Redirect location, only sent if a redirect was intercepted.
  final String redirectUrl;

  /// Details of the Authorization Challenge encountered. If this is set then
  /// continueInterceptedRequest must contain an authChallengeResponse.
  final AuthChallenge authChallenge;

  /// Response error if intercepted at response stage or if redirect occurred while intercepting
  /// request.
  final ErrorReason responseErrorReason;

  /// Response code if intercepted at response stage or if redirect occurred while intercepting
  /// request or auth retry occurred.
  final int responseStatusCode;

  /// Response headers if intercepted at the response stage or if redirect occurred while
  /// intercepting request or auth retry occurred.
  final Headers responseHeaders;

  /// If the intercepted request had a corresponding requestWillBeSent event fired for it, then
  /// this requestId will be the same as the requestId present in the requestWillBeSent event.
  final RequestId requestId;

  RequestInterceptedEvent(
      {@required this.interceptionId,
      @required this.request,
      @required this.frameId,
      @required this.resourceType,
      @required this.isNavigationRequest,
      this.isDownload,
      this.redirectUrl,
      this.authChallenge,
      this.responseErrorReason,
      this.responseStatusCode,
      this.responseHeaders,
      this.requestId});

  factory RequestInterceptedEvent.fromJson(Map<String, dynamic> json) {
    return RequestInterceptedEvent(
      interceptionId: InterceptionId.fromJson(json['interceptionId']),
      request: RequestData.fromJson(json['request']),
      frameId: page.FrameId.fromJson(json['frameId']),
      resourceType: ResourceType.fromJson(json['resourceType']),
      isNavigationRequest: json['isNavigationRequest'],
      isDownload: json.containsKey('isDownload') ? json['isDownload'] : null,
      redirectUrl: json.containsKey('redirectUrl') ? json['redirectUrl'] : null,
      authChallenge: json.containsKey('authChallenge')
          ? AuthChallenge.fromJson(json['authChallenge'])
          : null,
      responseErrorReason: json.containsKey('responseErrorReason')
          ? ErrorReason.fromJson(json['responseErrorReason'])
          : null,
      responseStatusCode: json.containsKey('responseStatusCode')
          ? json['responseStatusCode']
          : null,
      responseHeaders: json.containsKey('responseHeaders')
          ? Headers.fromJson(json['responseHeaders'])
          : null,
      requestId: json.containsKey('requestId')
          ? RequestId.fromJson(json['requestId'])
          : null,
    );
  }
}

class RequestWillBeSentEvent {
  /// Request identifier.
  final RequestId requestId;

  /// Loader identifier. Empty string if the request is fetched from worker.
  final LoaderId loaderId;

  /// URL of the document this request is loaded for.
  final String documentURL;

  /// Request data.
  final RequestData request;

  /// Timestamp.
  final MonotonicTime timestamp;

  /// Timestamp.
  final TimeSinceEpoch wallTime;

  /// Request initiator.
  final Initiator initiator;

  /// Redirect response data.
  final ResponseData redirectResponse;

  /// Type of this resource.
  final ResourceType type;

  /// Frame identifier.
  final page.FrameId frameId;

  /// Whether the request is initiated by a user gesture. Defaults to false.
  final bool hasUserGesture;

  RequestWillBeSentEvent(
      {@required this.requestId,
      @required this.loaderId,
      @required this.documentURL,
      @required this.request,
      @required this.timestamp,
      @required this.wallTime,
      @required this.initiator,
      this.redirectResponse,
      this.type,
      this.frameId,
      this.hasUserGesture});

  factory RequestWillBeSentEvent.fromJson(Map<String, dynamic> json) {
    return RequestWillBeSentEvent(
      requestId: RequestId.fromJson(json['requestId']),
      loaderId: LoaderId.fromJson(json['loaderId']),
      documentURL: json['documentURL'],
      request: RequestData.fromJson(json['request']),
      timestamp: MonotonicTime.fromJson(json['timestamp']),
      wallTime: TimeSinceEpoch.fromJson(json['wallTime']),
      initiator: Initiator.fromJson(json['initiator']),
      redirectResponse: json.containsKey('redirectResponse')
          ? ResponseData.fromJson(json['redirectResponse'])
          : null,
      type:
          json.containsKey('type') ? ResourceType.fromJson(json['type']) : null,
      frameId: json.containsKey('frameId')
          ? page.FrameId.fromJson(json['frameId'])
          : null,
      hasUserGesture:
          json.containsKey('hasUserGesture') ? json['hasUserGesture'] : null,
    );
  }
}

class ResourceChangedPriorityEvent {
  /// Request identifier.
  final RequestId requestId;

  /// New priority
  final ResourcePriority newPriority;

  /// Timestamp.
  final MonotonicTime timestamp;

  ResourceChangedPriorityEvent(
      {@required this.requestId,
      @required this.newPriority,
      @required this.timestamp});

  factory ResourceChangedPriorityEvent.fromJson(Map<String, dynamic> json) {
    return ResourceChangedPriorityEvent(
      requestId: RequestId.fromJson(json['requestId']),
      newPriority: ResourcePriority.fromJson(json['newPriority']),
      timestamp: MonotonicTime.fromJson(json['timestamp']),
    );
  }
}

class SignedExchangeReceivedEvent {
  /// Request identifier.
  final RequestId requestId;

  /// Information about the signed exchange response.
  final SignedExchangeInfo info;

  SignedExchangeReceivedEvent({@required this.requestId, @required this.info});

  factory SignedExchangeReceivedEvent.fromJson(Map<String, dynamic> json) {
    return SignedExchangeReceivedEvent(
      requestId: RequestId.fromJson(json['requestId']),
      info: SignedExchangeInfo.fromJson(json['info']),
    );
  }
}

class ResponseReceivedEvent {
  /// Request identifier.
  final RequestId requestId;

  /// Loader identifier. Empty string if the request is fetched from worker.
  final LoaderId loaderId;

  /// Timestamp.
  final MonotonicTime timestamp;

  /// Resource type.
  final ResourceType type;

  /// Response data.
  final ResponseData response;

  /// Frame identifier.
  final page.FrameId frameId;

  ResponseReceivedEvent(
      {@required this.requestId,
      @required this.loaderId,
      @required this.timestamp,
      @required this.type,
      @required this.response,
      this.frameId});

  factory ResponseReceivedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseReceivedEvent(
      requestId: RequestId.fromJson(json['requestId']),
      loaderId: LoaderId.fromJson(json['loaderId']),
      timestamp: MonotonicTime.fromJson(json['timestamp']),
      type: ResourceType.fromJson(json['type']),
      response: ResponseData.fromJson(json['response']),
      frameId: json.containsKey('frameId')
          ? page.FrameId.fromJson(json['frameId'])
          : null,
    );
  }
}

class WebSocketClosedEvent {
  /// Request identifier.
  final RequestId requestId;

  /// Timestamp.
  final MonotonicTime timestamp;

  WebSocketClosedEvent({@required this.requestId, @required this.timestamp});

  factory WebSocketClosedEvent.fromJson(Map<String, dynamic> json) {
    return WebSocketClosedEvent(
      requestId: RequestId.fromJson(json['requestId']),
      timestamp: MonotonicTime.fromJson(json['timestamp']),
    );
  }
}

class WebSocketCreatedEvent {
  /// Request identifier.
  final RequestId requestId;

  /// WebSocket request URL.
  final String url;

  /// Request initiator.
  final Initiator initiator;

  WebSocketCreatedEvent(
      {@required this.requestId, @required this.url, this.initiator});

  factory WebSocketCreatedEvent.fromJson(Map<String, dynamic> json) {
    return WebSocketCreatedEvent(
      requestId: RequestId.fromJson(json['requestId']),
      url: json['url'],
      initiator: json.containsKey('initiator')
          ? Initiator.fromJson(json['initiator'])
          : null,
    );
  }
}

class WebSocketFrameErrorEvent {
  /// Request identifier.
  final RequestId requestId;

  /// Timestamp.
  final MonotonicTime timestamp;

  /// WebSocket error message.
  final String errorMessage;

  WebSocketFrameErrorEvent(
      {@required this.requestId,
      @required this.timestamp,
      @required this.errorMessage});

  factory WebSocketFrameErrorEvent.fromJson(Map<String, dynamic> json) {
    return WebSocketFrameErrorEvent(
      requestId: RequestId.fromJson(json['requestId']),
      timestamp: MonotonicTime.fromJson(json['timestamp']),
      errorMessage: json['errorMessage'],
    );
  }
}

class WebSocketFrameReceivedEvent {
  /// Request identifier.
  final RequestId requestId;

  /// Timestamp.
  final MonotonicTime timestamp;

  /// WebSocket response data.
  final WebSocketFrame response;

  WebSocketFrameReceivedEvent(
      {@required this.requestId,
      @required this.timestamp,
      @required this.response});

  factory WebSocketFrameReceivedEvent.fromJson(Map<String, dynamic> json) {
    return WebSocketFrameReceivedEvent(
      requestId: RequestId.fromJson(json['requestId']),
      timestamp: MonotonicTime.fromJson(json['timestamp']),
      response: WebSocketFrame.fromJson(json['response']),
    );
  }
}

class WebSocketFrameSentEvent {
  /// Request identifier.
  final RequestId requestId;

  /// Timestamp.
  final MonotonicTime timestamp;

  /// WebSocket response data.
  final WebSocketFrame response;

  WebSocketFrameSentEvent(
      {@required this.requestId,
      @required this.timestamp,
      @required this.response});

  factory WebSocketFrameSentEvent.fromJson(Map<String, dynamic> json) {
    return WebSocketFrameSentEvent(
      requestId: RequestId.fromJson(json['requestId']),
      timestamp: MonotonicTime.fromJson(json['timestamp']),
      response: WebSocketFrame.fromJson(json['response']),
    );
  }
}

class WebSocketHandshakeResponseReceivedEvent {
  /// Request identifier.
  final RequestId requestId;

  /// Timestamp.
  final MonotonicTime timestamp;

  /// WebSocket response data.
  final WebSocketResponse response;

  WebSocketHandshakeResponseReceivedEvent(
      {@required this.requestId,
      @required this.timestamp,
      @required this.response});

  factory WebSocketHandshakeResponseReceivedEvent.fromJson(
      Map<String, dynamic> json) {
    return WebSocketHandshakeResponseReceivedEvent(
      requestId: RequestId.fromJson(json['requestId']),
      timestamp: MonotonicTime.fromJson(json['timestamp']),
      response: WebSocketResponse.fromJson(json['response']),
    );
  }
}

class WebSocketWillSendHandshakeRequestEvent {
  /// Request identifier.
  final RequestId requestId;

  /// Timestamp.
  final MonotonicTime timestamp;

  /// UTC Timestamp.
  final TimeSinceEpoch wallTime;

  /// WebSocket request data.
  final WebSocketRequest request;

  WebSocketWillSendHandshakeRequestEvent(
      {@required this.requestId,
      @required this.timestamp,
      @required this.wallTime,
      @required this.request});

  factory WebSocketWillSendHandshakeRequestEvent.fromJson(
      Map<String, dynamic> json) {
    return WebSocketWillSendHandshakeRequestEvent(
      requestId: RequestId.fromJson(json['requestId']),
      timestamp: MonotonicTime.fromJson(json['timestamp']),
      wallTime: TimeSinceEpoch.fromJson(json['wallTime']),
      request: WebSocketRequest.fromJson(json['request']),
    );
  }
}

class GetResponseBodyResult {
  /// Response body.
  final String body;

  /// True, if content was sent as base64.
  final bool base64Encoded;

  GetResponseBodyResult({@required this.body, @required this.base64Encoded});

  factory GetResponseBodyResult.fromJson(Map<String, dynamic> json) {
    return GetResponseBodyResult(
      body: json['body'],
      base64Encoded: json['base64Encoded'],
    );
  }
}

class GetResponseBodyForInterceptionResult {
  /// Response body.
  final String body;

  /// True, if content was sent as base64.
  final bool base64Encoded;

  GetResponseBodyForInterceptionResult(
      {@required this.body, @required this.base64Encoded});

  factory GetResponseBodyForInterceptionResult.fromJson(
      Map<String, dynamic> json) {
    return GetResponseBodyForInterceptionResult(
      body: json['body'],
      base64Encoded: json['base64Encoded'],
    );
  }
}

/// Resource type as it was perceived by the rendering engine.
class ResourceType {
  static const document = ResourceType._('Document');
  static const stylesheet = ResourceType._('Stylesheet');
  static const image = ResourceType._('Image');
  static const media = ResourceType._('Media');
  static const font = ResourceType._('Font');
  static const script = ResourceType._('Script');
  static const textTrack = ResourceType._('TextTrack');
  static const xhr = ResourceType._('XHR');
  static const fetch = ResourceType._('Fetch');
  static const eventSource = ResourceType._('EventSource');
  static const webSocket = ResourceType._('WebSocket');
  static const manifest = ResourceType._('Manifest');
  static const signedExchange = ResourceType._('SignedExchange');
  static const ping = ResourceType._('Ping');
  static const cspViolationReport = ResourceType._('CSPViolationReport');
  static const other = ResourceType._('Other');
  static const values = {
    'Document': document,
    'Stylesheet': stylesheet,
    'Image': image,
    'Media': media,
    'Font': font,
    'Script': script,
    'TextTrack': textTrack,
    'XHR': xhr,
    'Fetch': fetch,
    'EventSource': eventSource,
    'WebSocket': webSocket,
    'Manifest': manifest,
    'SignedExchange': signedExchange,
    'Ping': ping,
    'CSPViolationReport': cspViolationReport,
    'Other': other,
  };

  final String value;

  const ResourceType._(this.value);

  factory ResourceType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ResourceType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Unique loader identifier.
class LoaderId {
  final String value;

  LoaderId(this.value);

  factory LoaderId.fromJson(String value) => LoaderId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is LoaderId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Unique request identifier.
class RequestId {
  final String value;

  RequestId(this.value);

  factory RequestId.fromJson(String value) => RequestId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is RequestId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Unique intercepted request identifier.
class InterceptionId {
  final String value;

  InterceptionId(this.value);

  factory InterceptionId.fromJson(String value) => InterceptionId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is InterceptionId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Network level fetch failure reason.
class ErrorReason {
  static const failed = ErrorReason._('Failed');
  static const aborted = ErrorReason._('Aborted');
  static const timedOut = ErrorReason._('TimedOut');
  static const accessDenied = ErrorReason._('AccessDenied');
  static const connectionClosed = ErrorReason._('ConnectionClosed');
  static const connectionReset = ErrorReason._('ConnectionReset');
  static const connectionRefused = ErrorReason._('ConnectionRefused');
  static const connectionAborted = ErrorReason._('ConnectionAborted');
  static const connectionFailed = ErrorReason._('ConnectionFailed');
  static const nameNotResolved = ErrorReason._('NameNotResolved');
  static const internetDisconnected = ErrorReason._('InternetDisconnected');
  static const addressUnreachable = ErrorReason._('AddressUnreachable');
  static const blockedByClient = ErrorReason._('BlockedByClient');
  static const blockedByResponse = ErrorReason._('BlockedByResponse');
  static const values = {
    'Failed': failed,
    'Aborted': aborted,
    'TimedOut': timedOut,
    'AccessDenied': accessDenied,
    'ConnectionClosed': connectionClosed,
    'ConnectionReset': connectionReset,
    'ConnectionRefused': connectionRefused,
    'ConnectionAborted': connectionAborted,
    'ConnectionFailed': connectionFailed,
    'NameNotResolved': nameNotResolved,
    'InternetDisconnected': internetDisconnected,
    'AddressUnreachable': addressUnreachable,
    'BlockedByClient': blockedByClient,
    'BlockedByResponse': blockedByResponse,
  };

  final String value;

  const ErrorReason._(this.value);

  factory ErrorReason.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ErrorReason && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// UTC time in seconds, counted from January 1, 1970.
class TimeSinceEpoch {
  final num value;

  TimeSinceEpoch(this.value);

  factory TimeSinceEpoch.fromJson(num value) => TimeSinceEpoch(value);

  num toJson() => value;

  @override
  bool operator ==(other) =>
      (other is TimeSinceEpoch && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Monotonically increasing time in seconds since an arbitrary point in the past.
class MonotonicTime {
  final num value;

  MonotonicTime(this.value);

  factory MonotonicTime.fromJson(num value) => MonotonicTime(value);

  num toJson() => value;

  @override
  bool operator ==(other) =>
      (other is MonotonicTime && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Request / response headers as keys / values of JSON object.
class Headers {
  final Map value;

  Headers(this.value);

  factory Headers.fromJson(Map value) => Headers(value);

  Map toJson() => value;

  @override
  bool operator ==(other) =>
      (other is Headers && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// The underlying connection technology that the browser is supposedly using.
class ConnectionType {
  static const none = ConnectionType._('none');
  static const cellular2g = ConnectionType._('cellular2g');
  static const cellular3g = ConnectionType._('cellular3g');
  static const cellular4g = ConnectionType._('cellular4g');
  static const bluetooth = ConnectionType._('bluetooth');
  static const ethernet = ConnectionType._('ethernet');
  static const wifi = ConnectionType._('wifi');
  static const wimax = ConnectionType._('wimax');
  static const other = ConnectionType._('other');
  static const values = {
    'none': none,
    'cellular2g': cellular2g,
    'cellular3g': cellular3g,
    'cellular4g': cellular4g,
    'bluetooth': bluetooth,
    'ethernet': ethernet,
    'wifi': wifi,
    'wimax': wimax,
    'other': other,
  };

  final String value;

  const ConnectionType._(this.value);

  factory ConnectionType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ConnectionType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Represents the cookie's 'SameSite' status:
/// https://tools.ietf.org/html/draft-west-first-party-cookies
class CookieSameSite {
  static const strict = CookieSameSite._('Strict');
  static const lax = CookieSameSite._('Lax');
  static const extended = CookieSameSite._('Extended');
  static const none = CookieSameSite._('None');
  static const values = {
    'Strict': strict,
    'Lax': lax,
    'Extended': extended,
    'None': none,
  };

  final String value;

  const CookieSameSite._(this.value);

  factory CookieSameSite.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CookieSameSite && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Timing information for the request.
class ResourceTiming {
  /// Timing's requestTime is a baseline in seconds, while the other numbers are ticks in
  /// milliseconds relatively to this requestTime.
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

  ResourceTiming(
      {@required this.requestTime,
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
      @required this.receiveHeadersEnd});

  factory ResourceTiming.fromJson(Map<String, dynamic> json) {
    return ResourceTiming(
      requestTime: json['requestTime'],
      proxyStart: json['proxyStart'],
      proxyEnd: json['proxyEnd'],
      dnsStart: json['dnsStart'],
      dnsEnd: json['dnsEnd'],
      connectStart: json['connectStart'],
      connectEnd: json['connectEnd'],
      sslStart: json['sslStart'],
      sslEnd: json['sslEnd'],
      workerStart: json['workerStart'],
      workerReady: json['workerReady'],
      sendStart: json['sendStart'],
      sendEnd: json['sendEnd'],
      pushStart: json['pushStart'],
      pushEnd: json['pushEnd'],
      receiveHeadersEnd: json['receiveHeadersEnd'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'requestTime': requestTime,
      'proxyStart': proxyStart,
      'proxyEnd': proxyEnd,
      'dnsStart': dnsStart,
      'dnsEnd': dnsEnd,
      'connectStart': connectStart,
      'connectEnd': connectEnd,
      'sslStart': sslStart,
      'sslEnd': sslEnd,
      'workerStart': workerStart,
      'workerReady': workerReady,
      'sendStart': sendStart,
      'sendEnd': sendEnd,
      'pushStart': pushStart,
      'pushEnd': pushEnd,
      'receiveHeadersEnd': receiveHeadersEnd,
    };
    return json;
  }
}

/// Loading priority of a resource request.
class ResourcePriority {
  static const veryLow = ResourcePriority._('VeryLow');
  static const low = ResourcePriority._('Low');
  static const medium = ResourcePriority._('Medium');
  static const high = ResourcePriority._('High');
  static const veryHigh = ResourcePriority._('VeryHigh');
  static const values = {
    'VeryLow': veryLow,
    'Low': low,
    'Medium': medium,
    'High': high,
    'VeryHigh': veryHigh,
  };

  final String value;

  const ResourcePriority._(this.value);

  factory ResourcePriority.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ResourcePriority && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// HTTP request data.
class RequestData {
  /// Request URL (without fragment).
  final String url;

  /// Fragment of the requested URL starting with hash, if present.
  final String urlFragment;

  /// HTTP request method.
  final String method;

  /// HTTP request headers.
  final Headers headers;

  /// HTTP POST request data.
  final String postData;

  /// True when the request has POST data. Note that postData might still be omitted when this flag is true when the data is too long.
  final bool hasPostData;

  /// The mixed content type of the request.
  final security.MixedContentType mixedContentType;

  /// Priority of the resource request at the time request is sent.
  final ResourcePriority initialPriority;

  /// The referrer policy of the request, as defined in https://www.w3.org/TR/referrer-policy/
  final RequestReferrerPolicy referrerPolicy;

  /// Whether is loaded via link preload.
  final bool isLinkPreload;

  RequestData(
      {@required this.url,
      this.urlFragment,
      @required this.method,
      @required this.headers,
      this.postData,
      this.hasPostData,
      this.mixedContentType,
      @required this.initialPriority,
      @required this.referrerPolicy,
      this.isLinkPreload});

  factory RequestData.fromJson(Map<String, dynamic> json) {
    return RequestData(
      url: json['url'],
      urlFragment: json.containsKey('urlFragment') ? json['urlFragment'] : null,
      method: json['method'],
      headers: Headers.fromJson(json['headers']),
      postData: json.containsKey('postData') ? json['postData'] : null,
      hasPostData: json.containsKey('hasPostData') ? json['hasPostData'] : null,
      mixedContentType: json.containsKey('mixedContentType')
          ? security.MixedContentType.fromJson(json['mixedContentType'])
          : null,
      initialPriority: ResourcePriority.fromJson(json['initialPriority']),
      referrerPolicy: RequestReferrerPolicy.fromJson(json['referrerPolicy']),
      isLinkPreload:
          json.containsKey('isLinkPreload') ? json['isLinkPreload'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'url': url,
      'method': method,
      'headers': headers.toJson(),
      'initialPriority': initialPriority.toJson(),
      'referrerPolicy': referrerPolicy,
    };
    if (urlFragment != null) {
      json['urlFragment'] = urlFragment;
    }
    if (postData != null) {
      json['postData'] = postData;
    }
    if (hasPostData != null) {
      json['hasPostData'] = hasPostData;
    }
    if (mixedContentType != null) {
      json['mixedContentType'] = mixedContentType.toJson();
    }
    if (isLinkPreload != null) {
      json['isLinkPreload'] = isLinkPreload;
    }
    return json;
  }
}

class RequestReferrerPolicy {
  static const unsafeUrl = RequestReferrerPolicy._('unsafe-url');
  static const noReferrerWhenDowngrade =
      RequestReferrerPolicy._('no-referrer-when-downgrade');
  static const noReferrer = RequestReferrerPolicy._('no-referrer');
  static const origin = RequestReferrerPolicy._('origin');
  static const originWhenCrossOrigin =
      RequestReferrerPolicy._('origin-when-cross-origin');
  static const sameOrigin = RequestReferrerPolicy._('same-origin');
  static const strictOrigin = RequestReferrerPolicy._('strict-origin');
  static const strictOriginWhenCrossOrigin =
      RequestReferrerPolicy._('strict-origin-when-cross-origin');
  static const values = {
    'unsafe-url': unsafeUrl,
    'no-referrer-when-downgrade': noReferrerWhenDowngrade,
    'no-referrer': noReferrer,
    'origin': origin,
    'origin-when-cross-origin': originWhenCrossOrigin,
    'same-origin': sameOrigin,
    'strict-origin': strictOrigin,
    'strict-origin-when-cross-origin': strictOriginWhenCrossOrigin,
  };

  final String value;

  const RequestReferrerPolicy._(this.value);

  factory RequestReferrerPolicy.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is RequestReferrerPolicy && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
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

  SignedCertificateTimestamp(
      {@required this.status,
      @required this.origin,
      @required this.logDescription,
      @required this.logId,
      @required this.timestamp,
      @required this.hashAlgorithm,
      @required this.signatureAlgorithm,
      @required this.signatureData});

  factory SignedCertificateTimestamp.fromJson(Map<String, dynamic> json) {
    return SignedCertificateTimestamp(
      status: json['status'],
      origin: json['origin'],
      logDescription: json['logDescription'],
      logId: json['logId'],
      timestamp: TimeSinceEpoch.fromJson(json['timestamp']),
      hashAlgorithm: json['hashAlgorithm'],
      signatureAlgorithm: json['signatureAlgorithm'],
      signatureData: json['signatureData'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'status': status,
      'origin': origin,
      'logDescription': logDescription,
      'logId': logId,
      'timestamp': timestamp.toJson(),
      'hashAlgorithm': hashAlgorithm,
      'signatureAlgorithm': signatureAlgorithm,
      'signatureData': signatureData,
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

  /// Whether the request complied with Certificate Transparency policy
  final CertificateTransparencyCompliance certificateTransparencyCompliance;

  SecurityDetails(
      {@required this.protocol,
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
      @required this.certificateTransparencyCompliance});

  factory SecurityDetails.fromJson(Map<String, dynamic> json) {
    return SecurityDetails(
      protocol: json['protocol'],
      keyExchange: json['keyExchange'],
      keyExchangeGroup: json.containsKey('keyExchangeGroup')
          ? json['keyExchangeGroup']
          : null,
      cipher: json['cipher'],
      mac: json.containsKey('mac') ? json['mac'] : null,
      certificateId: security.CertificateId.fromJson(json['certificateId']),
      subjectName: json['subjectName'],
      sanList: (json['sanList'] as List).map((e) => e as String).toList(),
      issuer: json['issuer'],
      validFrom: TimeSinceEpoch.fromJson(json['validFrom']),
      validTo: TimeSinceEpoch.fromJson(json['validTo']),
      signedCertificateTimestampList:
          (json['signedCertificateTimestampList'] as List)
              .map((e) => SignedCertificateTimestamp.fromJson(e))
              .toList(),
      certificateTransparencyCompliance:
          CertificateTransparencyCompliance.fromJson(
              json['certificateTransparencyCompliance']),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'protocol': protocol,
      'keyExchange': keyExchange,
      'cipher': cipher,
      'certificateId': certificateId.toJson(),
      'subjectName': subjectName,
      'sanList': sanList.map((e) => e).toList(),
      'issuer': issuer,
      'validFrom': validFrom.toJson(),
      'validTo': validTo.toJson(),
      'signedCertificateTimestampList':
          signedCertificateTimestampList.map((e) => e.toJson()).toList(),
      'certificateTransparencyCompliance':
          certificateTransparencyCompliance.toJson(),
    };
    if (keyExchangeGroup != null) {
      json['keyExchangeGroup'] = keyExchangeGroup;
    }
    if (mac != null) {
      json['mac'] = mac;
    }
    return json;
  }
}

/// Whether the request complied with Certificate Transparency policy.
class CertificateTransparencyCompliance {
  static const unknown = CertificateTransparencyCompliance._('unknown');
  static const notCompliant =
      CertificateTransparencyCompliance._('not-compliant');
  static const compliant = CertificateTransparencyCompliance._('compliant');
  static const values = {
    'unknown': unknown,
    'not-compliant': notCompliant,
    'compliant': compliant,
  };

  final String value;

  const CertificateTransparencyCompliance._(this.value);

  factory CertificateTransparencyCompliance.fromJson(String value) =>
      values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CertificateTransparencyCompliance && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// The reason why request was blocked.
class BlockedReason {
  static const other = BlockedReason._('other');
  static const csp = BlockedReason._('csp');
  static const mixedContent = BlockedReason._('mixed-content');
  static const origin = BlockedReason._('origin');
  static const inspector = BlockedReason._('inspector');
  static const subresourceFilter = BlockedReason._('subresource-filter');
  static const contentType = BlockedReason._('content-type');
  static const collapsedByClient = BlockedReason._('collapsed-by-client');
  static const values = {
    'other': other,
    'csp': csp,
    'mixed-content': mixedContent,
    'origin': origin,
    'inspector': inspector,
    'subresource-filter': subresourceFilter,
    'content-type': contentType,
    'collapsed-by-client': collapsedByClient,
  };

  final String value;

  const BlockedReason._(this.value);

  factory BlockedReason.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is BlockedReason && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// HTTP response data.
class ResponseData {
  /// Response URL. This URL can be different from CachedResource.url in case of redirect.
  final String url;

  /// HTTP response status code.
  final int status;

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

  ResponseData(
      {@required this.url,
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
      this.securityDetails});

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      url: json['url'],
      status: json['status'],
      statusText: json['statusText'],
      headers: Headers.fromJson(json['headers']),
      headersText: json.containsKey('headersText') ? json['headersText'] : null,
      mimeType: json['mimeType'],
      requestHeaders: json.containsKey('requestHeaders')
          ? Headers.fromJson(json['requestHeaders'])
          : null,
      requestHeadersText: json.containsKey('requestHeadersText')
          ? json['requestHeadersText']
          : null,
      connectionReused: json['connectionReused'],
      connectionId: json['connectionId'],
      remoteIPAddress:
          json.containsKey('remoteIPAddress') ? json['remoteIPAddress'] : null,
      remotePort: json.containsKey('remotePort') ? json['remotePort'] : null,
      fromDiskCache:
          json.containsKey('fromDiskCache') ? json['fromDiskCache'] : null,
      fromServiceWorker: json.containsKey('fromServiceWorker')
          ? json['fromServiceWorker']
          : null,
      encodedDataLength: json['encodedDataLength'],
      timing: json.containsKey('timing')
          ? ResourceTiming.fromJson(json['timing'])
          : null,
      protocol: json.containsKey('protocol') ? json['protocol'] : null,
      securityState: security.SecurityState.fromJson(json['securityState']),
      securityDetails: json.containsKey('securityDetails')
          ? SecurityDetails.fromJson(json['securityDetails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'url': url,
      'status': status,
      'statusText': statusText,
      'headers': headers.toJson(),
      'mimeType': mimeType,
      'connectionReused': connectionReused,
      'connectionId': connectionId,
      'encodedDataLength': encodedDataLength,
      'securityState': securityState.toJson(),
    };
    if (headersText != null) {
      json['headersText'] = headersText;
    }
    if (requestHeaders != null) {
      json['requestHeaders'] = requestHeaders.toJson();
    }
    if (requestHeadersText != null) {
      json['requestHeadersText'] = requestHeadersText;
    }
    if (remoteIPAddress != null) {
      json['remoteIPAddress'] = remoteIPAddress;
    }
    if (remotePort != null) {
      json['remotePort'] = remotePort;
    }
    if (fromDiskCache != null) {
      json['fromDiskCache'] = fromDiskCache;
    }
    if (fromServiceWorker != null) {
      json['fromServiceWorker'] = fromServiceWorker;
    }
    if (timing != null) {
      json['timing'] = timing.toJson();
    }
    if (protocol != null) {
      json['protocol'] = protocol;
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

  WebSocketRequest({@required this.headers});

  factory WebSocketRequest.fromJson(Map<String, dynamic> json) {
    return WebSocketRequest(
      headers: Headers.fromJson(json['headers']),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'headers': headers.toJson(),
    };
    return json;
  }
}

/// WebSocket response data.
class WebSocketResponse {
  /// HTTP response status code.
  final int status;

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

  WebSocketResponse(
      {@required this.status,
      @required this.statusText,
      @required this.headers,
      this.headersText,
      this.requestHeaders,
      this.requestHeadersText});

  factory WebSocketResponse.fromJson(Map<String, dynamic> json) {
    return WebSocketResponse(
      status: json['status'],
      statusText: json['statusText'],
      headers: Headers.fromJson(json['headers']),
      headersText: json.containsKey('headersText') ? json['headersText'] : null,
      requestHeaders: json.containsKey('requestHeaders')
          ? Headers.fromJson(json['requestHeaders'])
          : null,
      requestHeadersText: json.containsKey('requestHeadersText')
          ? json['requestHeadersText']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'status': status,
      'statusText': statusText,
      'headers': headers.toJson(),
    };
    if (headersText != null) {
      json['headersText'] = headersText;
    }
    if (requestHeaders != null) {
      json['requestHeaders'] = requestHeaders.toJson();
    }
    if (requestHeadersText != null) {
      json['requestHeadersText'] = requestHeadersText;
    }
    return json;
  }
}

/// WebSocket message data. This represents an entire WebSocket message, not just a fragmented frame as the name suggests.
class WebSocketFrame {
  /// WebSocket message opcode.
  final num opcode;

  /// WebSocket message mask.
  final bool mask;

  /// WebSocket message payload data.
  /// If the opcode is 1, this is a text message and payloadData is a UTF-8 string.
  /// If the opcode isn't 1, then payloadData is a base64 encoded string representing binary data.
  final String payloadData;

  WebSocketFrame(
      {@required this.opcode, @required this.mask, @required this.payloadData});

  factory WebSocketFrame.fromJson(Map<String, dynamic> json) {
    return WebSocketFrame(
      opcode: json['opcode'],
      mask: json['mask'],
      payloadData: json['payloadData'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'opcode': opcode,
      'mask': mask,
      'payloadData': payloadData,
    };
    return json;
  }
}

/// Information about the cached resource.
class CachedResource {
  /// Resource URL. This is the url of the original network request.
  final String url;

  /// Type of this resource.
  final ResourceType type;

  /// Cached response data.
  final ResponseData response;

  /// Cached response body size.
  final num bodySize;

  CachedResource(
      {@required this.url,
      @required this.type,
      this.response,
      @required this.bodySize});

  factory CachedResource.fromJson(Map<String, dynamic> json) {
    return CachedResource(
      url: json['url'],
      type: ResourceType.fromJson(json['type']),
      response: json.containsKey('response')
          ? ResponseData.fromJson(json['response'])
          : null,
      bodySize: json['bodySize'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'url': url,
      'type': type.toJson(),
      'bodySize': bodySize,
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
  final InitiatorType type;

  /// Initiator JavaScript stack trace, set for Script only.
  final runtime.StackTrace stack;

  /// Initiator URL, set for Parser type or for Script type (when script is importing module) or for SignedExchange type.
  final String url;

  /// Initiator line number, set for Parser type or for Script type (when script is importing
  /// module) (0-based).
  final num lineNumber;

  Initiator({@required this.type, this.stack, this.url, this.lineNumber});

  factory Initiator.fromJson(Map<String, dynamic> json) {
    return Initiator(
      type: InitiatorType.fromJson(json['type']),
      stack: json.containsKey('stack')
          ? runtime.StackTrace.fromJson(json['stack'])
          : null,
      url: json.containsKey('url') ? json['url'] : null,
      lineNumber: json.containsKey('lineNumber') ? json['lineNumber'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'type': type,
    };
    if (stack != null) {
      json['stack'] = stack.toJson();
    }
    if (url != null) {
      json['url'] = url;
    }
    if (lineNumber != null) {
      json['lineNumber'] = lineNumber;
    }
    return json;
  }
}

class InitiatorType {
  static const parser = InitiatorType._('parser');
  static const script = InitiatorType._('script');
  static const preload = InitiatorType._('preload');
  static const signedExchange = InitiatorType._('SignedExchange');
  static const other = InitiatorType._('other');
  static const values = {
    'parser': parser,
    'script': script,
    'preload': preload,
    'SignedExchange': signedExchange,
    'other': other,
  };

  final String value;

  const InitiatorType._(this.value);

  factory InitiatorType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is InitiatorType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
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

  Cookie(
      {@required this.name,
      @required this.value,
      @required this.domain,
      @required this.path,
      @required this.expires,
      @required this.size,
      @required this.httpOnly,
      @required this.secure,
      @required this.session,
      this.sameSite});

  factory Cookie.fromJson(Map<String, dynamic> json) {
    return Cookie(
      name: json['name'],
      value: json['value'],
      domain: json['domain'],
      path: json['path'],
      expires: json['expires'],
      size: json['size'],
      httpOnly: json['httpOnly'],
      secure: json['secure'],
      session: json['session'],
      sameSite: json.containsKey('sameSite')
          ? CookieSameSite.fromJson(json['sameSite'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'name': name,
      'value': value,
      'domain': domain,
      'path': path,
      'expires': expires,
      'size': size,
      'httpOnly': httpOnly,
      'secure': secure,
      'session': session,
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

  /// The request-URI to associate with the setting of the cookie. This value can affect the
  /// default domain and path values of the created cookie.
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

  CookieParam(
      {@required this.name,
      @required this.value,
      this.url,
      this.domain,
      this.path,
      this.secure,
      this.httpOnly,
      this.sameSite,
      this.expires});

  factory CookieParam.fromJson(Map<String, dynamic> json) {
    return CookieParam(
      name: json['name'],
      value: json['value'],
      url: json.containsKey('url') ? json['url'] : null,
      domain: json.containsKey('domain') ? json['domain'] : null,
      path: json.containsKey('path') ? json['path'] : null,
      secure: json.containsKey('secure') ? json['secure'] : null,
      httpOnly: json.containsKey('httpOnly') ? json['httpOnly'] : null,
      sameSite: json.containsKey('sameSite')
          ? CookieSameSite.fromJson(json['sameSite'])
          : null,
      expires: json.containsKey('expires')
          ? TimeSinceEpoch.fromJson(json['expires'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'name': name,
      'value': value,
    };
    if (url != null) {
      json['url'] = url;
    }
    if (domain != null) {
      json['domain'] = domain;
    }
    if (path != null) {
      json['path'] = path;
    }
    if (secure != null) {
      json['secure'] = secure;
    }
    if (httpOnly != null) {
      json['httpOnly'] = httpOnly;
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
  final AuthChallengeSource source;

  /// Origin of the challenger.
  final String origin;

  /// The authentication scheme used, such as basic or digest
  final String scheme;

  /// The realm of the challenge. May be empty.
  final String realm;

  AuthChallenge(
      {this.source,
      @required this.origin,
      @required this.scheme,
      @required this.realm});

  factory AuthChallenge.fromJson(Map<String, dynamic> json) {
    return AuthChallenge(
      source: json.containsKey('source')
          ? AuthChallengeSource.fromJson(json['source'])
          : null,
      origin: json['origin'],
      scheme: json['scheme'],
      realm: json['realm'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'origin': origin,
      'scheme': scheme,
      'realm': realm,
    };
    if (source != null) {
      json['source'] = source;
    }
    return json;
  }
}

class AuthChallengeSource {
  static const server = AuthChallengeSource._('Server');
  static const proxy = AuthChallengeSource._('Proxy');
  static const values = {
    'Server': server,
    'Proxy': proxy,
  };

  final String value;

  const AuthChallengeSource._(this.value);

  factory AuthChallengeSource.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is AuthChallengeSource && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Response to an AuthChallenge.
class AuthChallengeResponse {
  /// The decision on what to do in response to the authorization challenge.  Default means
  /// deferring to the default behavior of the net stack, which will likely either the Cancel
  /// authentication or display a popup dialog box.
  final AuthChallengeResponseResponse response;

  /// The username to provide, possibly empty. Should only be set if response is
  /// ProvideCredentials.
  final String username;

  /// The password to provide, possibly empty. Should only be set if response is
  /// ProvideCredentials.
  final String password;

  AuthChallengeResponse(
      {@required this.response, this.username, this.password});

  factory AuthChallengeResponse.fromJson(Map<String, dynamic> json) {
    return AuthChallengeResponse(
      response: AuthChallengeResponseResponse.fromJson(json['response']),
      username: json.containsKey('username') ? json['username'] : null,
      password: json.containsKey('password') ? json['password'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'response': response,
    };
    if (username != null) {
      json['username'] = username;
    }
    if (password != null) {
      json['password'] = password;
    }
    return json;
  }
}

class AuthChallengeResponseResponse {
  static const default$ = AuthChallengeResponseResponse._('Default');
  static const cancelAuth = AuthChallengeResponseResponse._('CancelAuth');
  static const provideCredentials =
      AuthChallengeResponseResponse._('ProvideCredentials');
  static const values = {
    'Default': default$,
    'CancelAuth': cancelAuth,
    'ProvideCredentials': provideCredentials,
  };

  final String value;

  const AuthChallengeResponseResponse._(this.value);

  factory AuthChallengeResponseResponse.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is AuthChallengeResponseResponse && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Stages of the interception to begin intercepting. Request will intercept before the request is
/// sent. Response will intercept after the response is received.
class InterceptionStage {
  static const request = InterceptionStage._('Request');
  static const headersReceived = InterceptionStage._('HeadersReceived');
  static const values = {
    'Request': request,
    'HeadersReceived': headersReceived,
  };

  final String value;

  const InterceptionStage._(this.value);

  factory InterceptionStage.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is InterceptionStage && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Request pattern for interception.
class RequestPattern {
  /// Wildcards ('*' -> zero or more, '?' -> exactly one) are allowed. Escape character is
  /// backslash. Omitting is equivalent to "*".
  final String urlPattern;

  /// If set, only requests for matching resource types will be intercepted.
  final ResourceType resourceType;

  /// Stage at wich to begin intercepting requests. Default is Request.
  final InterceptionStage interceptionStage;

  RequestPattern({this.urlPattern, this.resourceType, this.interceptionStage});

  factory RequestPattern.fromJson(Map<String, dynamic> json) {
    return RequestPattern(
      urlPattern: json.containsKey('urlPattern') ? json['urlPattern'] : null,
      resourceType: json.containsKey('resourceType')
          ? ResourceType.fromJson(json['resourceType'])
          : null,
      interceptionStage: json.containsKey('interceptionStage')
          ? InterceptionStage.fromJson(json['interceptionStage'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};
    if (urlPattern != null) {
      json['urlPattern'] = urlPattern;
    }
    if (resourceType != null) {
      json['resourceType'] = resourceType.toJson();
    }
    if (interceptionStage != null) {
      json['interceptionStage'] = interceptionStage.toJson();
    }
    return json;
  }
}

/// Information about a signed exchange signature.
/// https://wicg.github.io/webpackage/draft-yasskin-httpbis-origin-signed-exchanges-impl.html#rfc.section.3.1
class SignedExchangeSignature {
  /// Signed exchange signature label.
  final String label;

  /// The hex string of signed exchange signature.
  final String signature;

  /// Signed exchange signature integrity.
  final String integrity;

  /// Signed exchange signature cert Url.
  final String certUrl;

  /// The hex string of signed exchange signature cert sha256.
  final String certSha256;

  /// Signed exchange signature validity Url.
  final String validityUrl;

  /// Signed exchange signature date.
  final int date;

  /// Signed exchange signature expires.
  final int expires;

  /// The encoded certificates.
  final List<String> certificates;

  SignedExchangeSignature(
      {@required this.label,
      @required this.signature,
      @required this.integrity,
      this.certUrl,
      this.certSha256,
      @required this.validityUrl,
      @required this.date,
      @required this.expires,
      this.certificates});

  factory SignedExchangeSignature.fromJson(Map<String, dynamic> json) {
    return SignedExchangeSignature(
      label: json['label'],
      signature: json['signature'],
      integrity: json['integrity'],
      certUrl: json.containsKey('certUrl') ? json['certUrl'] : null,
      certSha256: json.containsKey('certSha256') ? json['certSha256'] : null,
      validityUrl: json['validityUrl'],
      date: json['date'],
      expires: json['expires'],
      certificates: json.containsKey('certificates')
          ? (json['certificates'] as List).map((e) => e as String).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'label': label,
      'signature': signature,
      'integrity': integrity,
      'validityUrl': validityUrl,
      'date': date,
      'expires': expires,
    };
    if (certUrl != null) {
      json['certUrl'] = certUrl;
    }
    if (certSha256 != null) {
      json['certSha256'] = certSha256;
    }
    if (certificates != null) {
      json['certificates'] = certificates.map((e) => e).toList();
    }
    return json;
  }
}

/// Information about a signed exchange header.
/// https://wicg.github.io/webpackage/draft-yasskin-httpbis-origin-signed-exchanges-impl.html#cbor-representation
class SignedExchangeHeader {
  /// Signed exchange request URL.
  final String requestUrl;

  /// Signed exchange response code.
  final int responseCode;

  /// Signed exchange response headers.
  final Headers responseHeaders;

  /// Signed exchange response signature.
  final List<SignedExchangeSignature> signatures;

  SignedExchangeHeader(
      {@required this.requestUrl,
      @required this.responseCode,
      @required this.responseHeaders,
      @required this.signatures});

  factory SignedExchangeHeader.fromJson(Map<String, dynamic> json) {
    return SignedExchangeHeader(
      requestUrl: json['requestUrl'],
      responseCode: json['responseCode'],
      responseHeaders: Headers.fromJson(json['responseHeaders']),
      signatures: (json['signatures'] as List)
          .map((e) => SignedExchangeSignature.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'requestUrl': requestUrl,
      'responseCode': responseCode,
      'responseHeaders': responseHeaders.toJson(),
      'signatures': signatures.map((e) => e.toJson()).toList(),
    };
    return json;
  }
}

/// Field type for a signed exchange related error.
class SignedExchangeErrorField {
  static const signatureSig = SignedExchangeErrorField._('signatureSig');
  static const signatureIntegrity =
      SignedExchangeErrorField._('signatureIntegrity');
  static const signatureCertUrl =
      SignedExchangeErrorField._('signatureCertUrl');
  static const signatureCertSha256 =
      SignedExchangeErrorField._('signatureCertSha256');
  static const signatureValidityUrl =
      SignedExchangeErrorField._('signatureValidityUrl');
  static const signatureTimestamps =
      SignedExchangeErrorField._('signatureTimestamps');
  static const values = {
    'signatureSig': signatureSig,
    'signatureIntegrity': signatureIntegrity,
    'signatureCertUrl': signatureCertUrl,
    'signatureCertSha256': signatureCertSha256,
    'signatureValidityUrl': signatureValidityUrl,
    'signatureTimestamps': signatureTimestamps,
  };

  final String value;

  const SignedExchangeErrorField._(this.value);

  factory SignedExchangeErrorField.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is SignedExchangeErrorField && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Information about a signed exchange response.
class SignedExchangeError {
  /// Error message.
  final String message;

  /// The index of the signature which caused the error.
  final int signatureIndex;

  /// The field which caused the error.
  final SignedExchangeErrorField errorField;

  SignedExchangeError(
      {@required this.message, this.signatureIndex, this.errorField});

  factory SignedExchangeError.fromJson(Map<String, dynamic> json) {
    return SignedExchangeError(
      message: json['message'],
      signatureIndex:
          json.containsKey('signatureIndex') ? json['signatureIndex'] : null,
      errorField: json.containsKey('errorField')
          ? SignedExchangeErrorField.fromJson(json['errorField'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'message': message,
    };
    if (signatureIndex != null) {
      json['signatureIndex'] = signatureIndex;
    }
    if (errorField != null) {
      json['errorField'] = errorField.toJson();
    }
    return json;
  }
}

/// Information about a signed exchange response.
class SignedExchangeInfo {
  /// The outer response of signed HTTP exchange which was received from network.
  final ResponseData outerResponse;

  /// Information about the signed exchange header.
  final SignedExchangeHeader header;

  /// Security details for the signed exchange header.
  final SecurityDetails securityDetails;

  /// Errors occurred while handling the signed exchagne.
  final List<SignedExchangeError> errors;

  SignedExchangeInfo(
      {@required this.outerResponse,
      this.header,
      this.securityDetails,
      this.errors});

  factory SignedExchangeInfo.fromJson(Map<String, dynamic> json) {
    return SignedExchangeInfo(
      outerResponse: ResponseData.fromJson(json['outerResponse']),
      header: json.containsKey('header')
          ? SignedExchangeHeader.fromJson(json['header'])
          : null,
      securityDetails: json.containsKey('securityDetails')
          ? SecurityDetails.fromJson(json['securityDetails'])
          : null,
      errors: json.containsKey('errors')
          ? (json['errors'] as List)
              .map((e) => SignedExchangeError.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'outerResponse': outerResponse.toJson(),
    };
    if (header != null) {
      json['header'] = header.toJson();
    }
    if (securityDetails != null) {
      json['securityDetails'] = securityDetails.toJson();
    }
    if (errors != null) {
      json['errors'] = errors.map((e) => e.toJson()).toList();
    }
    return json;
  }
}
