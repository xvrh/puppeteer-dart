import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'debugger.dart' as debugger;
import 'emulation.dart' as emulation;
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
      .where((event) => event.name == 'Network.dataReceived')
      .map((event) => DataReceivedEvent.fromJson(event.parameters));

  /// Fired when EventSource message is received.
  Stream<EventSourceMessageReceivedEvent> get onEventSourceMessageReceived =>
      _client.onEvent
          .where((event) => event.name == 'Network.eventSourceMessageReceived')
          .map((event) =>
              EventSourceMessageReceivedEvent.fromJson(event.parameters));

  /// Fired when HTTP request has failed to load.
  Stream<LoadingFailedEvent> get onLoadingFailed => _client.onEvent
      .where((event) => event.name == 'Network.loadingFailed')
      .map((event) => LoadingFailedEvent.fromJson(event.parameters));

  /// Fired when HTTP request has finished loading.
  Stream<LoadingFinishedEvent> get onLoadingFinished => _client.onEvent
      .where((event) => event.name == 'Network.loadingFinished')
      .map((event) => LoadingFinishedEvent.fromJson(event.parameters));

  /// Details of an intercepted HTTP request, which must be either allowed, blocked, modified or
  /// mocked.
  /// Deprecated, use Fetch.requestPaused instead.
  Stream<RequestInterceptedEvent> get onRequestIntercepted => _client.onEvent
      .where((event) => event.name == 'Network.requestIntercepted')
      .map((event) => RequestInterceptedEvent.fromJson(event.parameters));

  /// Fired if request ended up loading from cache.
  Stream<RequestId> get onRequestServedFromCache => _client.onEvent
      .where((event) => event.name == 'Network.requestServedFromCache')
      .map((event) =>
          RequestId.fromJson(event.parameters['requestId'] as String));

  /// Fired when page is about to send HTTP request.
  Stream<RequestWillBeSentEvent> get onRequestWillBeSent => _client.onEvent
      .where((event) => event.name == 'Network.requestWillBeSent')
      .map((event) => RequestWillBeSentEvent.fromJson(event.parameters));

  /// Fired when resource loading priority is changed
  Stream<ResourceChangedPriorityEvent> get onResourceChangedPriority => _client
      .onEvent
      .where((event) => event.name == 'Network.resourceChangedPriority')
      .map((event) => ResourceChangedPriorityEvent.fromJson(event.parameters));

  /// Fired when a signed exchange was received over the network
  Stream<SignedExchangeReceivedEvent> get onSignedExchangeReceived => _client
      .onEvent
      .where((event) => event.name == 'Network.signedExchangeReceived')
      .map((event) => SignedExchangeReceivedEvent.fromJson(event.parameters));

  /// Fired when HTTP response is available.
  Stream<ResponseReceivedEvent> get onResponseReceived => _client.onEvent
      .where((event) => event.name == 'Network.responseReceived')
      .map((event) => ResponseReceivedEvent.fromJson(event.parameters));

  /// Fired when WebSocket is closed.
  Stream<WebSocketClosedEvent> get onWebSocketClosed => _client.onEvent
      .where((event) => event.name == 'Network.webSocketClosed')
      .map((event) => WebSocketClosedEvent.fromJson(event.parameters));

  /// Fired upon WebSocket creation.
  Stream<WebSocketCreatedEvent> get onWebSocketCreated => _client.onEvent
      .where((event) => event.name == 'Network.webSocketCreated')
      .map((event) => WebSocketCreatedEvent.fromJson(event.parameters));

  /// Fired when WebSocket message error occurs.
  Stream<WebSocketFrameErrorEvent> get onWebSocketFrameError => _client.onEvent
      .where((event) => event.name == 'Network.webSocketFrameError')
      .map((event) => WebSocketFrameErrorEvent.fromJson(event.parameters));

  /// Fired when WebSocket message is received.
  Stream<WebSocketFrameReceivedEvent> get onWebSocketFrameReceived => _client
      .onEvent
      .where((event) => event.name == 'Network.webSocketFrameReceived')
      .map((event) => WebSocketFrameReceivedEvent.fromJson(event.parameters));

  /// Fired when WebSocket message is sent.
  Stream<WebSocketFrameSentEvent> get onWebSocketFrameSent => _client.onEvent
      .where((event) => event.name == 'Network.webSocketFrameSent')
      .map((event) => WebSocketFrameSentEvent.fromJson(event.parameters));

  /// Fired when WebSocket handshake response becomes available.
  Stream<WebSocketHandshakeResponseReceivedEvent>
      get onWebSocketHandshakeResponseReceived => _client.onEvent
          .where((event) =>
              event.name == 'Network.webSocketHandshakeResponseReceived')
          .map((event) => WebSocketHandshakeResponseReceivedEvent.fromJson(
              event.parameters));

  /// Fired when WebSocket is about to initiate handshake.
  Stream<WebSocketWillSendHandshakeRequestEvent>
      get onWebSocketWillSendHandshakeRequest => _client.onEvent
          .where((event) =>
              event.name == 'Network.webSocketWillSendHandshakeRequest')
          .map((event) => WebSocketWillSendHandshakeRequestEvent.fromJson(
              event.parameters));

  /// Fired when additional information about a requestWillBeSent event is available from the
  /// network stack. Not every requestWillBeSent event will have an additional
  /// requestWillBeSentExtraInfo fired for it, and there is no guarantee whether requestWillBeSent
  /// or requestWillBeSentExtraInfo will be fired first for the same request.
  Stream<RequestWillBeSentExtraInfoEvent> get onRequestWillBeSentExtraInfo =>
      _client.onEvent
          .where((event) => event.name == 'Network.requestWillBeSentExtraInfo')
          .map((event) =>
              RequestWillBeSentExtraInfoEvent.fromJson(event.parameters));

  /// Fired when additional information about a responseReceived event is available from the network
  /// stack. Not every responseReceived event will have an additional responseReceivedExtraInfo for
  /// it, and responseReceivedExtraInfo may be fired before or after responseReceived.
  Stream<ResponseReceivedExtraInfoEvent> get onResponseReceivedExtraInfo =>
      _client.onEvent
          .where((event) => event.name == 'Network.responseReceivedExtraInfo')
          .map((event) =>
              ResponseReceivedExtraInfoEvent.fromJson(event.parameters));

  /// Tells whether clearing browser cache is supported.
  /// Returns: True if browser cache can be cleared.
  @deprecated
  Future<bool> canClearBrowserCache() async {
    var result = await _client.send('Network.canClearBrowserCache');
    return result['result'] as bool;
  }

  /// Tells whether clearing browser cookies is supported.
  /// Returns: True if browser cookies can be cleared.
  @deprecated
  Future<bool> canClearBrowserCookies() async {
    var result = await _client.send('Network.canClearBrowserCookies');
    return result['result'] as bool;
  }

  /// Tells whether emulation of network conditions is supported.
  /// Returns: True if emulation of network conditions is supported.
  @deprecated
  Future<bool> canEmulateNetworkConditions() async {
    var result = await _client.send('Network.canEmulateNetworkConditions');
    return result['result'] as bool;
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
  /// Deprecated, use Fetch.continueRequest, Fetch.fulfillRequest and Fetch.failRequest instead.
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
  @deprecated
  Future<void> continueInterceptedRequest(InterceptionId interceptionId,
      {ErrorReason errorReason,
      String rawResponse,
      String url,
      String method,
      String postData,
      Headers headers,
      AuthChallengeResponse authChallengeResponse}) async {
    await _client.send('Network.continueInterceptedRequest', {
      'interceptionId': interceptionId,
      if (errorReason != null) 'errorReason': errorReason,
      if (rawResponse != null) 'rawResponse': rawResponse,
      if (url != null) 'url': url,
      if (method != null) 'method': method,
      if (postData != null) 'postData': postData,
      if (headers != null) 'headers': headers,
      if (authChallengeResponse != null)
        'authChallengeResponse': authChallengeResponse,
    });
  }

  /// Deletes browser cookies with matching name and url or domain/path pair.
  /// [name] Name of the cookies to remove.
  /// [url] If specified, deletes all the cookies with the given name where domain and path match
  /// provided URL.
  /// [domain] If specified, deletes only cookies with the exact domain.
  /// [path] If specified, deletes only cookies with the exact path.
  Future<void> deleteCookies(String name,
      {String url, String domain, String path}) async {
    await _client.send('Network.deleteCookies', {
      'name': name,
      if (url != null) 'url': url,
      if (domain != null) 'domain': domain,
      if (path != null) 'path': path,
    });
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
    await _client.send('Network.emulateNetworkConditions', {
      'offline': offline,
      'latency': latency,
      'downloadThroughput': downloadThroughput,
      'uploadThroughput': uploadThroughput,
      if (connectionType != null) 'connectionType': connectionType,
    });
  }

  /// Enables network tracking, network events will now be delivered to the client.
  /// [maxTotalBufferSize] Buffer size in bytes to use when preserving network payloads (XHRs, etc).
  /// [maxResourceBufferSize] Per-resource buffer size in bytes to use when preserving network payloads (XHRs, etc).
  /// [maxPostDataSize] Longest post body size (in bytes) that would be included in requestWillBeSent notification
  Future<void> enable(
      {int maxTotalBufferSize,
      int maxResourceBufferSize,
      int maxPostDataSize}) async {
    await _client.send('Network.enable', {
      if (maxTotalBufferSize != null) 'maxTotalBufferSize': maxTotalBufferSize,
      if (maxResourceBufferSize != null)
        'maxResourceBufferSize': maxResourceBufferSize,
      if (maxPostDataSize != null) 'maxPostDataSize': maxPostDataSize,
    });
  }

  /// Returns all browser cookies. Depending on the backend support, will return detailed cookie
  /// information in the `cookies` field.
  /// Returns: Array of cookie objects.
  Future<List<Cookie>> getAllCookies() async {
    var result = await _client.send('Network.getAllCookies');
    return (result['cookies'] as List)
        .map((e) => Cookie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns the DER-encoded certificate.
  /// [origin] Origin to get certificate for.
  Future<List<String>> getCertificate(String origin) async {
    var result = await _client.send('Network.getCertificate', {
      'origin': origin,
    });
    return (result['tableNames'] as List).map((e) => e as String).toList();
  }

  /// Returns all browser cookies for the current URL. Depending on the backend support, will return
  /// detailed cookie information in the `cookies` field.
  /// [urls] The list of URLs for which applicable cookies will be fetched
  /// Returns: Array of cookie objects.
  Future<List<Cookie>> getCookies({List<String> urls}) async {
    var result = await _client.send('Network.getCookies', {
      if (urls != null) 'urls': [...urls],
    });
    return (result['cookies'] as List)
        .map((e) => Cookie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns content served for the given request.
  /// [requestId] Identifier of the network request to get content for.
  Future<GetResponseBodyResult> getResponseBody(RequestId requestId) async {
    var result = await _client.send('Network.getResponseBody', {
      'requestId': requestId,
    });
    return GetResponseBodyResult.fromJson(result);
  }

  /// Returns post data sent with the request. Returns an error when no data was sent with the request.
  /// [requestId] Identifier of the network request to get content for.
  /// Returns: Request body string, omitting files from multipart requests
  Future<String> getRequestPostData(RequestId requestId) async {
    var result = await _client.send('Network.getRequestPostData', {
      'requestId': requestId,
    });
    return result['postData'] as String;
  }

  /// Returns content served for the given currently intercepted request.
  /// [interceptionId] Identifier for the intercepted request to get body for.
  Future<GetResponseBodyForInterceptionResult> getResponseBodyForInterception(
      InterceptionId interceptionId) async {
    var result = await _client.send('Network.getResponseBodyForInterception', {
      'interceptionId': interceptionId,
    });
    return GetResponseBodyForInterceptionResult.fromJson(result);
  }

  /// Returns a handle to the stream representing the response body. Note that after this command,
  /// the intercepted request can't be continued as is -- you either need to cancel it or to provide
  /// the response body. The stream only supports sequential read, IO.read will fail if the position
  /// is specified.
  Future<io.StreamHandle> takeResponseBodyForInterceptionAsStream(
      InterceptionId interceptionId) async {
    var result =
        await _client.send('Network.takeResponseBodyForInterceptionAsStream', {
      'interceptionId': interceptionId,
    });
    return io.StreamHandle.fromJson(result['stream'] as String);
  }

  /// This method sends a new XMLHttpRequest which is identical to the original one. The following
  /// parameters should be identical: method, url, async, request body, extra headers, withCredentials
  /// attribute, user, password.
  /// [requestId] Identifier of XHR to replay.
  Future<void> replayXHR(RequestId requestId) async {
    await _client.send('Network.replayXHR', {
      'requestId': requestId,
    });
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
    var result = await _client.send('Network.searchInResponseBody', {
      'requestId': requestId,
      'query': query,
      if (caseSensitive != null) 'caseSensitive': caseSensitive,
      if (isRegex != null) 'isRegex': isRegex,
    });
    return (result['result'] as List)
        .map((e) => debugger.SearchMatch.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Blocks URLs from loading.
  /// [urls] URL patterns to block. Wildcards ('*') are allowed.
  Future<void> setBlockedURLs(List<String> urls) async {
    await _client.send('Network.setBlockedURLs', {
      'urls': [...urls],
    });
  }

  /// Toggles ignoring of service worker for each request.
  /// [bypass] Bypass service worker and load from network.
  Future<void> setBypassServiceWorker(bool bypass) async {
    await _client.send('Network.setBypassServiceWorker', {
      'bypass': bypass,
    });
  }

  /// Toggles ignoring cache for each request. If `true`, cache will not be used.
  /// [cacheDisabled] Cache disabled state.
  Future<void> setCacheDisabled(bool cacheDisabled) async {
    await _client.send('Network.setCacheDisabled', {
      'cacheDisabled': cacheDisabled,
    });
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
  /// [priority] Cookie Priority type.
  /// Returns: True if successfully set cookie.
  Future<bool> setCookie(String name, String value,
      {String url,
      String domain,
      String path,
      bool secure,
      bool httpOnly,
      CookieSameSite sameSite,
      TimeSinceEpoch expires,
      CookiePriority priority}) async {
    var result = await _client.send('Network.setCookie', {
      'name': name,
      'value': value,
      if (url != null) 'url': url,
      if (domain != null) 'domain': domain,
      if (path != null) 'path': path,
      if (secure != null) 'secure': secure,
      if (httpOnly != null) 'httpOnly': httpOnly,
      if (sameSite != null) 'sameSite': sameSite,
      if (expires != null) 'expires': expires,
      if (priority != null) 'priority': priority,
    });
    return result['success'] as bool;
  }

  /// Sets given cookies.
  /// [cookies] Cookies to be set.
  Future<void> setCookies(List<CookieParam> cookies) async {
    await _client.send('Network.setCookies', {
      'cookies': [...cookies],
    });
  }

  /// For testing.
  /// [maxTotalSize] Maximum total buffer size.
  /// [maxResourceSize] Maximum per-resource size.
  Future<void> setDataSizeLimitsForTest(
      int maxTotalSize, int maxResourceSize) async {
    await _client.send('Network.setDataSizeLimitsForTest', {
      'maxTotalSize': maxTotalSize,
      'maxResourceSize': maxResourceSize,
    });
  }

  /// Specifies whether to always send extra HTTP headers with the requests from this page.
  /// [headers] Map with extra HTTP headers.
  Future<void> setExtraHTTPHeaders(Headers headers) async {
    await _client.send('Network.setExtraHTTPHeaders', {
      'headers': headers,
    });
  }

  /// Sets the requests to intercept that match the provided patterns and optionally resource types.
  /// Deprecated, please use Fetch.enable instead.
  /// [patterns] Requests matching any of these patterns will be forwarded and wait for the corresponding
  /// continueInterceptedRequest call.
  @deprecated
  Future<void> setRequestInterception(List<RequestPattern> patterns) async {
    await _client.send('Network.setRequestInterception', {
      'patterns': [...patterns],
    });
  }

  /// Allows overriding user agent with the given string.
  /// [userAgent] User agent to use.
  /// [acceptLanguage] Browser langugage to emulate.
  /// [platform] The platform navigator.platform should return.
  /// [userAgentMetadata] To be sent in Sec-CH-UA-* headers and returned in navigator.userAgentData
  Future<void> setUserAgentOverride(String userAgent,
      {String acceptLanguage,
      String platform,
      emulation.UserAgentMetadata userAgentMetadata}) async {
    await _client.send('Network.setUserAgentOverride', {
      'userAgent': userAgent,
      if (acceptLanguage != null) 'acceptLanguage': acceptLanguage,
      if (platform != null) 'platform': platform,
      if (userAgentMetadata != null) 'userAgentMetadata': userAgentMetadata,
    });
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
      requestId: RequestId.fromJson(json['requestId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      dataLength: json['dataLength'] as int,
      encodedDataLength: json['encodedDataLength'] as int,
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
      requestId: RequestId.fromJson(json['requestId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      eventName: json['eventName'] as String,
      eventId: json['eventId'] as String,
      data: json['data'] as String,
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
      requestId: RequestId.fromJson(json['requestId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      type: ResourceType.fromJson(json['type'] as String),
      errorText: json['errorText'] as String,
      canceled: json.containsKey('canceled') ? json['canceled'] as bool : null,
      blockedReason: json.containsKey('blockedReason')
          ? BlockedReason.fromJson(json['blockedReason'] as String)
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
      requestId: RequestId.fromJson(json['requestId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      encodedDataLength: json['encodedDataLength'] as num,
      shouldReportCorbBlocking: json.containsKey('shouldReportCorbBlocking')
          ? json['shouldReportCorbBlocking'] as bool
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
      interceptionId: InterceptionId.fromJson(json['interceptionId'] as String),
      request: RequestData.fromJson(json['request'] as Map<String, dynamic>),
      frameId: page.FrameId.fromJson(json['frameId'] as String),
      resourceType: ResourceType.fromJson(json['resourceType'] as String),
      isNavigationRequest: json['isNavigationRequest'] as bool,
      isDownload:
          json.containsKey('isDownload') ? json['isDownload'] as bool : null,
      redirectUrl: json.containsKey('redirectUrl')
          ? json['redirectUrl'] as String
          : null,
      authChallenge: json.containsKey('authChallenge')
          ? AuthChallenge.fromJson(
              json['authChallenge'] as Map<String, dynamic>)
          : null,
      responseErrorReason: json.containsKey('responseErrorReason')
          ? ErrorReason.fromJson(json['responseErrorReason'] as String)
          : null,
      responseStatusCode: json.containsKey('responseStatusCode')
          ? json['responseStatusCode'] as int
          : null,
      responseHeaders: json.containsKey('responseHeaders')
          ? Headers.fromJson(json['responseHeaders'] as Map<String, dynamic>)
          : null,
      requestId: json.containsKey('requestId')
          ? RequestId.fromJson(json['requestId'] as String)
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
      requestId: RequestId.fromJson(json['requestId'] as String),
      loaderId: LoaderId.fromJson(json['loaderId'] as String),
      documentURL: json['documentURL'] as String,
      request: RequestData.fromJson(json['request'] as Map<String, dynamic>),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      wallTime: TimeSinceEpoch.fromJson(json['wallTime'] as num),
      initiator: Initiator.fromJson(json['initiator'] as Map<String, dynamic>),
      redirectResponse: json.containsKey('redirectResponse')
          ? ResponseData.fromJson(
              json['redirectResponse'] as Map<String, dynamic>)
          : null,
      type: json.containsKey('type')
          ? ResourceType.fromJson(json['type'] as String)
          : null,
      frameId: json.containsKey('frameId')
          ? page.FrameId.fromJson(json['frameId'] as String)
          : null,
      hasUserGesture: json.containsKey('hasUserGesture')
          ? json['hasUserGesture'] as bool
          : null,
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
      requestId: RequestId.fromJson(json['requestId'] as String),
      newPriority: ResourcePriority.fromJson(json['newPriority'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
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
      requestId: RequestId.fromJson(json['requestId'] as String),
      info: SignedExchangeInfo.fromJson(json['info'] as Map<String, dynamic>),
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
      requestId: RequestId.fromJson(json['requestId'] as String),
      loaderId: LoaderId.fromJson(json['loaderId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      type: ResourceType.fromJson(json['type'] as String),
      response: ResponseData.fromJson(json['response'] as Map<String, dynamic>),
      frameId: json.containsKey('frameId')
          ? page.FrameId.fromJson(json['frameId'] as String)
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
      requestId: RequestId.fromJson(json['requestId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
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
      requestId: RequestId.fromJson(json['requestId'] as String),
      url: json['url'] as String,
      initiator: json.containsKey('initiator')
          ? Initiator.fromJson(json['initiator'] as Map<String, dynamic>)
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
      requestId: RequestId.fromJson(json['requestId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      errorMessage: json['errorMessage'] as String,
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
      requestId: RequestId.fromJson(json['requestId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      response:
          WebSocketFrame.fromJson(json['response'] as Map<String, dynamic>),
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
      requestId: RequestId.fromJson(json['requestId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      response:
          WebSocketFrame.fromJson(json['response'] as Map<String, dynamic>),
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
      requestId: RequestId.fromJson(json['requestId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      response:
          WebSocketResponse.fromJson(json['response'] as Map<String, dynamic>),
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
      requestId: RequestId.fromJson(json['requestId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      wallTime: TimeSinceEpoch.fromJson(json['wallTime'] as num),
      request:
          WebSocketRequest.fromJson(json['request'] as Map<String, dynamic>),
    );
  }
}

class RequestWillBeSentExtraInfoEvent {
  /// Request identifier. Used to match this information to an existing requestWillBeSent event.
  final RequestId requestId;

  /// A list of cookies potentially associated to the requested URL. This includes both cookies sent with
  /// the request and the ones not sent; the latter are distinguished by having blockedReason field set.
  final List<BlockedCookieWithReason> associatedCookies;

  /// Raw request headers as they will be sent over the wire.
  final Headers headers;

  RequestWillBeSentExtraInfoEvent(
      {@required this.requestId,
      @required this.associatedCookies,
      @required this.headers});

  factory RequestWillBeSentExtraInfoEvent.fromJson(Map<String, dynamic> json) {
    return RequestWillBeSentExtraInfoEvent(
      requestId: RequestId.fromJson(json['requestId'] as String),
      associatedCookies: (json['associatedCookies'] as List)
          .map((e) =>
              BlockedCookieWithReason.fromJson(e as Map<String, dynamic>))
          .toList(),
      headers: Headers.fromJson(json['headers'] as Map<String, dynamic>),
    );
  }
}

class ResponseReceivedExtraInfoEvent {
  /// Request identifier. Used to match this information to another responseReceived event.
  final RequestId requestId;

  /// A list of cookies which were not stored from the response along with the corresponding
  /// reasons for blocking. The cookies here may not be valid due to syntax errors, which
  /// are represented by the invalid cookie line string instead of a proper cookie.
  final List<BlockedSetCookieWithReason> blockedCookies;

  /// Raw response headers as they were received over the wire.
  final Headers headers;

  /// Raw response header text as it was received over the wire. The raw text may not always be
  /// available, such as in the case of HTTP/2 or QUIC.
  final String headersText;

  ResponseReceivedExtraInfoEvent(
      {@required this.requestId,
      @required this.blockedCookies,
      @required this.headers,
      this.headersText});

  factory ResponseReceivedExtraInfoEvent.fromJson(Map<String, dynamic> json) {
    return ResponseReceivedExtraInfoEvent(
      requestId: RequestId.fromJson(json['requestId'] as String),
      blockedCookies: (json['blockedCookies'] as List)
          .map((e) =>
              BlockedSetCookieWithReason.fromJson(e as Map<String, dynamic>))
          .toList(),
      headers: Headers.fromJson(json['headers'] as Map<String, dynamic>),
      headersText: json.containsKey('headersText')
          ? json['headersText'] as String
          : null,
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
      body: json['body'] as String,
      base64Encoded: json['base64Encoded'] as bool,
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
      body: json['body'] as String,
      base64Encoded: json['base64Encoded'] as bool,
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
  final Map<String, dynamic> value;

  Headers(this.value);

  factory Headers.fromJson(Map<String, dynamic> value) => Headers(value);

  Map<String, dynamic> toJson() => value;

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
  static const none = CookieSameSite._('None');
  static const values = {
    'Strict': strict,
    'Lax': lax,
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

/// Represents the cookie's 'Priority' status:
/// https://tools.ietf.org/html/draft-west-cookie-priority-00
class CookiePriority {
  static const low = CookiePriority._('Low');
  static const medium = CookiePriority._('Medium');
  static const high = CookiePriority._('High');
  static const values = {
    'Low': low,
    'Medium': medium,
    'High': high,
  };

  final String value;

  const CookiePriority._(this.value);

  factory CookiePriority.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CookiePriority && other.value == value) || value == other;

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
      requestTime: json['requestTime'] as num,
      proxyStart: json['proxyStart'] as num,
      proxyEnd: json['proxyEnd'] as num,
      dnsStart: json['dnsStart'] as num,
      dnsEnd: json['dnsEnd'] as num,
      connectStart: json['connectStart'] as num,
      connectEnd: json['connectEnd'] as num,
      sslStart: json['sslStart'] as num,
      sslEnd: json['sslEnd'] as num,
      workerStart: json['workerStart'] as num,
      workerReady: json['workerReady'] as num,
      sendStart: json['sendStart'] as num,
      sendEnd: json['sendEnd'] as num,
      pushStart: json['pushStart'] as num,
      pushEnd: json['pushEnd'] as num,
      receiveHeadersEnd: json['receiveHeadersEnd'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      url: json['url'] as String,
      urlFragment: json.containsKey('urlFragment')
          ? json['urlFragment'] as String
          : null,
      method: json['method'] as String,
      headers: Headers.fromJson(json['headers'] as Map<String, dynamic>),
      postData:
          json.containsKey('postData') ? json['postData'] as String : null,
      hasPostData:
          json.containsKey('hasPostData') ? json['hasPostData'] as bool : null,
      mixedContentType: json.containsKey('mixedContentType')
          ? security.MixedContentType.fromJson(
              json['mixedContentType'] as String)
          : null,
      initialPriority:
          ResourcePriority.fromJson(json['initialPriority'] as String),
      referrerPolicy:
          RequestReferrerPolicy.fromJson(json['referrerPolicy'] as String),
      isLinkPreload: json.containsKey('isLinkPreload')
          ? json['isLinkPreload'] as bool
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'method': method,
      'headers': headers.toJson(),
      'initialPriority': initialPriority.toJson(),
      'referrerPolicy': referrerPolicy,
      if (urlFragment != null) 'urlFragment': urlFragment,
      if (postData != null) 'postData': postData,
      if (hasPostData != null) 'hasPostData': hasPostData,
      if (mixedContentType != null)
        'mixedContentType': mixedContentType.toJson(),
      if (isLinkPreload != null) 'isLinkPreload': isLinkPreload,
    };
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
      status: json['status'] as String,
      origin: json['origin'] as String,
      logDescription: json['logDescription'] as String,
      logId: json['logId'] as String,
      timestamp: TimeSinceEpoch.fromJson(json['timestamp'] as num),
      hashAlgorithm: json['hashAlgorithm'] as String,
      signatureAlgorithm: json['signatureAlgorithm'] as String,
      signatureData: json['signatureData'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'origin': origin,
      'logDescription': logDescription,
      'logId': logId,
      'timestamp': timestamp.toJson(),
      'hashAlgorithm': hashAlgorithm,
      'signatureAlgorithm': signatureAlgorithm,
      'signatureData': signatureData,
    };
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
      protocol: json['protocol'] as String,
      keyExchange: json['keyExchange'] as String,
      keyExchangeGroup: json.containsKey('keyExchangeGroup')
          ? json['keyExchangeGroup'] as String
          : null,
      cipher: json['cipher'] as String,
      mac: json.containsKey('mac') ? json['mac'] as String : null,
      certificateId:
          security.CertificateId.fromJson(json['certificateId'] as int),
      subjectName: json['subjectName'] as String,
      sanList: (json['sanList'] as List).map((e) => e as String).toList(),
      issuer: json['issuer'] as String,
      validFrom: TimeSinceEpoch.fromJson(json['validFrom'] as num),
      validTo: TimeSinceEpoch.fromJson(json['validTo'] as num),
      signedCertificateTimestampList: (json['signedCertificateTimestampList']
              as List)
          .map((e) =>
              SignedCertificateTimestamp.fromJson(e as Map<String, dynamic>))
          .toList(),
      certificateTransparencyCompliance:
          CertificateTransparencyCompliance.fromJson(
              json['certificateTransparencyCompliance'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protocol': protocol,
      'keyExchange': keyExchange,
      'cipher': cipher,
      'certificateId': certificateId.toJson(),
      'subjectName': subjectName,
      'sanList': [...sanList],
      'issuer': issuer,
      'validFrom': validFrom.toJson(),
      'validTo': validTo.toJson(),
      'signedCertificateTimestampList':
          signedCertificateTimestampList.map((e) => e.toJson()).toList(),
      'certificateTransparencyCompliance':
          certificateTransparencyCompliance.toJson(),
      if (keyExchangeGroup != null) 'keyExchangeGroup': keyExchangeGroup,
      if (mac != null) 'mac': mac,
    };
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
  static const coepFrameResourceNeedsCoepHeader =
      BlockedReason._('coep-frame-resource-needs-coep-header');
  static const coopSandboxedIframeCannotNavigateToCoopPage =
      BlockedReason._('coop-sandboxed-iframe-cannot-navigate-to-coop-page');
  static const corpNotSameOrigin = BlockedReason._('corp-not-same-origin');
  static const corpNotSameOriginAfterDefaultedToSameOriginByCoep =
      BlockedReason._(
          'corp-not-same-origin-after-defaulted-to-same-origin-by-coep');
  static const corpNotSameSite = BlockedReason._('corp-not-same-site');
  static const values = {
    'other': other,
    'csp': csp,
    'mixed-content': mixedContent,
    'origin': origin,
    'inspector': inspector,
    'subresource-filter': subresourceFilter,
    'content-type': contentType,
    'collapsed-by-client': collapsedByClient,
    'coep-frame-resource-needs-coep-header': coepFrameResourceNeedsCoepHeader,
    'coop-sandboxed-iframe-cannot-navigate-to-coop-page':
        coopSandboxedIframeCannotNavigateToCoopPage,
    'corp-not-same-origin': corpNotSameOrigin,
    'corp-not-same-origin-after-defaulted-to-same-origin-by-coep':
        corpNotSameOriginAfterDefaultedToSameOriginByCoep,
    'corp-not-same-site': corpNotSameSite,
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

  /// Specifies that the request was served from the prefetch cache.
  final bool fromPrefetchCache;

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
      this.fromPrefetchCache,
      @required this.encodedDataLength,
      this.timing,
      this.protocol,
      @required this.securityState,
      this.securityDetails});

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      url: json['url'] as String,
      status: json['status'] as int,
      statusText: json['statusText'] as String,
      headers: Headers.fromJson(json['headers'] as Map<String, dynamic>),
      headersText: json.containsKey('headersText')
          ? json['headersText'] as String
          : null,
      mimeType: json['mimeType'] as String,
      requestHeaders: json.containsKey('requestHeaders')
          ? Headers.fromJson(json['requestHeaders'] as Map<String, dynamic>)
          : null,
      requestHeadersText: json.containsKey('requestHeadersText')
          ? json['requestHeadersText'] as String
          : null,
      connectionReused: json['connectionReused'] as bool,
      connectionId: json['connectionId'] as num,
      remoteIPAddress: json.containsKey('remoteIPAddress')
          ? json['remoteIPAddress'] as String
          : null,
      remotePort:
          json.containsKey('remotePort') ? json['remotePort'] as int : null,
      fromDiskCache: json.containsKey('fromDiskCache')
          ? json['fromDiskCache'] as bool
          : null,
      fromServiceWorker: json.containsKey('fromServiceWorker')
          ? json['fromServiceWorker'] as bool
          : null,
      fromPrefetchCache: json.containsKey('fromPrefetchCache')
          ? json['fromPrefetchCache'] as bool
          : null,
      encodedDataLength: json['encodedDataLength'] as num,
      timing: json.containsKey('timing')
          ? ResourceTiming.fromJson(json['timing'] as Map<String, dynamic>)
          : null,
      protocol:
          json.containsKey('protocol') ? json['protocol'] as String : null,
      securityState:
          security.SecurityState.fromJson(json['securityState'] as String),
      securityDetails: json.containsKey('securityDetails')
          ? SecurityDetails.fromJson(
              json['securityDetails'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'status': status,
      'statusText': statusText,
      'headers': headers.toJson(),
      'mimeType': mimeType,
      'connectionReused': connectionReused,
      'connectionId': connectionId,
      'encodedDataLength': encodedDataLength,
      'securityState': securityState.toJson(),
      if (headersText != null) 'headersText': headersText,
      if (requestHeaders != null) 'requestHeaders': requestHeaders.toJson(),
      if (requestHeadersText != null) 'requestHeadersText': requestHeadersText,
      if (remoteIPAddress != null) 'remoteIPAddress': remoteIPAddress,
      if (remotePort != null) 'remotePort': remotePort,
      if (fromDiskCache != null) 'fromDiskCache': fromDiskCache,
      if (fromServiceWorker != null) 'fromServiceWorker': fromServiceWorker,
      if (fromPrefetchCache != null) 'fromPrefetchCache': fromPrefetchCache,
      if (timing != null) 'timing': timing.toJson(),
      if (protocol != null) 'protocol': protocol,
      if (securityDetails != null) 'securityDetails': securityDetails.toJson(),
    };
  }
}

/// WebSocket request data.
class WebSocketRequest {
  /// HTTP request headers.
  final Headers headers;

  WebSocketRequest({@required this.headers});

  factory WebSocketRequest.fromJson(Map<String, dynamic> json) {
    return WebSocketRequest(
      headers: Headers.fromJson(json['headers'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headers': headers.toJson(),
    };
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
      status: json['status'] as int,
      statusText: json['statusText'] as String,
      headers: Headers.fromJson(json['headers'] as Map<String, dynamic>),
      headersText: json.containsKey('headersText')
          ? json['headersText'] as String
          : null,
      requestHeaders: json.containsKey('requestHeaders')
          ? Headers.fromJson(json['requestHeaders'] as Map<String, dynamic>)
          : null,
      requestHeadersText: json.containsKey('requestHeadersText')
          ? json['requestHeadersText'] as String
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'statusText': statusText,
      'headers': headers.toJson(),
      if (headersText != null) 'headersText': headersText,
      if (requestHeaders != null) 'requestHeaders': requestHeaders.toJson(),
      if (requestHeadersText != null) 'requestHeadersText': requestHeadersText,
    };
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
      opcode: json['opcode'] as num,
      mask: json['mask'] as bool,
      payloadData: json['payloadData'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'opcode': opcode,
      'mask': mask,
      'payloadData': payloadData,
    };
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
      url: json['url'] as String,
      type: ResourceType.fromJson(json['type'] as String),
      response: json.containsKey('response')
          ? ResponseData.fromJson(json['response'] as Map<String, dynamic>)
          : null,
      bodySize: json['bodySize'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'type': type.toJson(),
      'bodySize': bodySize,
      if (response != null) 'response': response.toJson(),
    };
  }
}

/// Information about the request initiator.
class Initiator {
  /// Type of this initiator.
  final InitiatorType type;

  /// Initiator JavaScript stack trace, set for Script only.
  final runtime.StackTraceData stack;

  /// Initiator URL, set for Parser type or for Script type (when script is importing module) or for SignedExchange type.
  final String url;

  /// Initiator line number, set for Parser type or for Script type (when script is importing
  /// module) (0-based).
  final num lineNumber;

  Initiator({@required this.type, this.stack, this.url, this.lineNumber});

  factory Initiator.fromJson(Map<String, dynamic> json) {
    return Initiator(
      type: InitiatorType.fromJson(json['type'] as String),
      stack: json.containsKey('stack')
          ? runtime.StackTraceData.fromJson(
              json['stack'] as Map<String, dynamic>)
          : null,
      url: json.containsKey('url') ? json['url'] as String : null,
      lineNumber:
          json.containsKey('lineNumber') ? json['lineNumber'] as num : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (stack != null) 'stack': stack.toJson(),
      if (url != null) 'url': url,
      if (lineNumber != null) 'lineNumber': lineNumber,
    };
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

  /// Cookie Priority
  final CookiePriority priority;

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
      this.sameSite,
      @required this.priority});

  factory Cookie.fromJson(Map<String, dynamic> json) {
    return Cookie(
      name: json['name'] as String,
      value: json['value'] as String,
      domain: json['domain'] as String,
      path: json['path'] as String,
      expires: json['expires'] as num,
      size: json['size'] as int,
      httpOnly: json['httpOnly'] as bool,
      secure: json['secure'] as bool,
      session: json['session'] as bool,
      sameSite: json.containsKey('sameSite')
          ? CookieSameSite.fromJson(json['sameSite'] as String)
          : null,
      priority: CookiePriority.fromJson(json['priority'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'domain': domain,
      'path': path,
      'expires': expires,
      'size': size,
      'httpOnly': httpOnly,
      'secure': secure,
      'session': session,
      'priority': priority.toJson(),
      if (sameSite != null) 'sameSite': sameSite.toJson(),
    };
  }
}

/// Types of reasons why a cookie may not be stored from a response.
class SetCookieBlockedReason {
  static const secureOnly = SetCookieBlockedReason._('SecureOnly');
  static const sameSiteStrict = SetCookieBlockedReason._('SameSiteStrict');
  static const sameSiteLax = SetCookieBlockedReason._('SameSiteLax');
  static const sameSiteUnspecifiedTreatedAsLax =
      SetCookieBlockedReason._('SameSiteUnspecifiedTreatedAsLax');
  static const sameSiteNoneInsecure =
      SetCookieBlockedReason._('SameSiteNoneInsecure');
  static const userPreferences = SetCookieBlockedReason._('UserPreferences');
  static const syntaxError = SetCookieBlockedReason._('SyntaxError');
  static const schemeNotSupported =
      SetCookieBlockedReason._('SchemeNotSupported');
  static const overwriteSecure = SetCookieBlockedReason._('OverwriteSecure');
  static const invalidDomain = SetCookieBlockedReason._('InvalidDomain');
  static const invalidPrefix = SetCookieBlockedReason._('InvalidPrefix');
  static const unknownError = SetCookieBlockedReason._('UnknownError');
  static const values = {
    'SecureOnly': secureOnly,
    'SameSiteStrict': sameSiteStrict,
    'SameSiteLax': sameSiteLax,
    'SameSiteUnspecifiedTreatedAsLax': sameSiteUnspecifiedTreatedAsLax,
    'SameSiteNoneInsecure': sameSiteNoneInsecure,
    'UserPreferences': userPreferences,
    'SyntaxError': syntaxError,
    'SchemeNotSupported': schemeNotSupported,
    'OverwriteSecure': overwriteSecure,
    'InvalidDomain': invalidDomain,
    'InvalidPrefix': invalidPrefix,
    'UnknownError': unknownError,
  };

  final String value;

  const SetCookieBlockedReason._(this.value);

  factory SetCookieBlockedReason.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is SetCookieBlockedReason && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Types of reasons why a cookie may not be sent with a request.
class CookieBlockedReason {
  static const secureOnly = CookieBlockedReason._('SecureOnly');
  static const notOnPath = CookieBlockedReason._('NotOnPath');
  static const domainMismatch = CookieBlockedReason._('DomainMismatch');
  static const sameSiteStrict = CookieBlockedReason._('SameSiteStrict');
  static const sameSiteLax = CookieBlockedReason._('SameSiteLax');
  static const sameSiteUnspecifiedTreatedAsLax =
      CookieBlockedReason._('SameSiteUnspecifiedTreatedAsLax');
  static const sameSiteNoneInsecure =
      CookieBlockedReason._('SameSiteNoneInsecure');
  static const userPreferences = CookieBlockedReason._('UserPreferences');
  static const unknownError = CookieBlockedReason._('UnknownError');
  static const values = {
    'SecureOnly': secureOnly,
    'NotOnPath': notOnPath,
    'DomainMismatch': domainMismatch,
    'SameSiteStrict': sameSiteStrict,
    'SameSiteLax': sameSiteLax,
    'SameSiteUnspecifiedTreatedAsLax': sameSiteUnspecifiedTreatedAsLax,
    'SameSiteNoneInsecure': sameSiteNoneInsecure,
    'UserPreferences': userPreferences,
    'UnknownError': unknownError,
  };

  final String value;

  const CookieBlockedReason._(this.value);

  factory CookieBlockedReason.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CookieBlockedReason && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// A cookie which was not stored from a response with the corresponding reason.
class BlockedSetCookieWithReason {
  /// The reason(s) this cookie was blocked.
  final List<SetCookieBlockedReason> blockedReasons;

  /// The string representing this individual cookie as it would appear in the header.
  /// This is not the entire "cookie" or "set-cookie" header which could have multiple cookies.
  final String cookieLine;

  /// The cookie object which represents the cookie which was not stored. It is optional because
  /// sometimes complete cookie information is not available, such as in the case of parsing
  /// errors.
  final Cookie cookie;

  BlockedSetCookieWithReason(
      {@required this.blockedReasons, @required this.cookieLine, this.cookie});

  factory BlockedSetCookieWithReason.fromJson(Map<String, dynamic> json) {
    return BlockedSetCookieWithReason(
      blockedReasons: (json['blockedReasons'] as List)
          .map((e) => SetCookieBlockedReason.fromJson(e as String))
          .toList(),
      cookieLine: json['cookieLine'] as String,
      cookie: json.containsKey('cookie')
          ? Cookie.fromJson(json['cookie'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'blockedReasons': blockedReasons.map((e) => e.toJson()).toList(),
      'cookieLine': cookieLine,
      if (cookie != null) 'cookie': cookie.toJson(),
    };
  }
}

/// A cookie with was not sent with a request with the corresponding reason.
class BlockedCookieWithReason {
  /// The reason(s) the cookie was blocked.
  final List<CookieBlockedReason> blockedReasons;

  /// The cookie object representing the cookie which was not sent.
  final Cookie cookie;

  BlockedCookieWithReason(
      {@required this.blockedReasons, @required this.cookie});

  factory BlockedCookieWithReason.fromJson(Map<String, dynamic> json) {
    return BlockedCookieWithReason(
      blockedReasons: (json['blockedReasons'] as List)
          .map((e) => CookieBlockedReason.fromJson(e as String))
          .toList(),
      cookie: Cookie.fromJson(json['cookie'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'blockedReasons': blockedReasons.map((e) => e.toJson()).toList(),
      'cookie': cookie.toJson(),
    };
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

  /// Cookie Priority.
  final CookiePriority priority;

  CookieParam(
      {@required this.name,
      @required this.value,
      this.url,
      this.domain,
      this.path,
      this.secure,
      this.httpOnly,
      this.sameSite,
      this.expires,
      this.priority});

  factory CookieParam.fromJson(Map<String, dynamic> json) {
    return CookieParam(
      name: json['name'] as String,
      value: json['value'] as String,
      url: json.containsKey('url') ? json['url'] as String : null,
      domain: json.containsKey('domain') ? json['domain'] as String : null,
      path: json.containsKey('path') ? json['path'] as String : null,
      secure: json.containsKey('secure') ? json['secure'] as bool : null,
      httpOnly: json.containsKey('httpOnly') ? json['httpOnly'] as bool : null,
      sameSite: json.containsKey('sameSite')
          ? CookieSameSite.fromJson(json['sameSite'] as String)
          : null,
      expires: json.containsKey('expires')
          ? TimeSinceEpoch.fromJson(json['expires'] as num)
          : null,
      priority: json.containsKey('priority')
          ? CookiePriority.fromJson(json['priority'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      if (url != null) 'url': url,
      if (domain != null) 'domain': domain,
      if (path != null) 'path': path,
      if (secure != null) 'secure': secure,
      if (httpOnly != null) 'httpOnly': httpOnly,
      if (sameSite != null) 'sameSite': sameSite.toJson(),
      if (expires != null) 'expires': expires.toJson(),
      if (priority != null) 'priority': priority.toJson(),
    };
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
          ? AuthChallengeSource.fromJson(json['source'] as String)
          : null,
      origin: json['origin'] as String,
      scheme: json['scheme'] as String,
      realm: json['realm'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'origin': origin,
      'scheme': scheme,
      'realm': realm,
      if (source != null) 'source': source,
    };
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
      response:
          AuthChallengeResponseResponse.fromJson(json['response'] as String),
      username:
          json.containsKey('username') ? json['username'] as String : null,
      password:
          json.containsKey('password') ? json['password'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response': response,
      if (username != null) 'username': username,
      if (password != null) 'password': password,
    };
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
      urlPattern:
          json.containsKey('urlPattern') ? json['urlPattern'] as String : null,
      resourceType: json.containsKey('resourceType')
          ? ResourceType.fromJson(json['resourceType'] as String)
          : null,
      interceptionStage: json.containsKey('interceptionStage')
          ? InterceptionStage.fromJson(json['interceptionStage'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (urlPattern != null) 'urlPattern': urlPattern,
      if (resourceType != null) 'resourceType': resourceType.toJson(),
      if (interceptionStage != null)
        'interceptionStage': interceptionStage.toJson(),
    };
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
      label: json['label'] as String,
      signature: json['signature'] as String,
      integrity: json['integrity'] as String,
      certUrl: json.containsKey('certUrl') ? json['certUrl'] as String : null,
      certSha256:
          json.containsKey('certSha256') ? json['certSha256'] as String : null,
      validityUrl: json['validityUrl'] as String,
      date: json['date'] as int,
      expires: json['expires'] as int,
      certificates: json.containsKey('certificates')
          ? (json['certificates'] as List).map((e) => e as String).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'signature': signature,
      'integrity': integrity,
      'validityUrl': validityUrl,
      'date': date,
      'expires': expires,
      if (certUrl != null) 'certUrl': certUrl,
      if (certSha256 != null) 'certSha256': certSha256,
      if (certificates != null) 'certificates': [...certificates],
    };
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

  /// Signed exchange header integrity hash in the form of "sha256-<base64-hash-value>".
  final String headerIntegrity;

  SignedExchangeHeader(
      {@required this.requestUrl,
      @required this.responseCode,
      @required this.responseHeaders,
      @required this.signatures,
      @required this.headerIntegrity});

  factory SignedExchangeHeader.fromJson(Map<String, dynamic> json) {
    return SignedExchangeHeader(
      requestUrl: json['requestUrl'] as String,
      responseCode: json['responseCode'] as int,
      responseHeaders:
          Headers.fromJson(json['responseHeaders'] as Map<String, dynamic>),
      signatures: (json['signatures'] as List)
          .map((e) =>
              SignedExchangeSignature.fromJson(e as Map<String, dynamic>))
          .toList(),
      headerIntegrity: json['headerIntegrity'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestUrl': requestUrl,
      'responseCode': responseCode,
      'responseHeaders': responseHeaders.toJson(),
      'signatures': signatures.map((e) => e.toJson()).toList(),
      'headerIntegrity': headerIntegrity,
    };
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
      message: json['message'] as String,
      signatureIndex: json.containsKey('signatureIndex')
          ? json['signatureIndex'] as int
          : null,
      errorField: json.containsKey('errorField')
          ? SignedExchangeErrorField.fromJson(json['errorField'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (signatureIndex != null) 'signatureIndex': signatureIndex,
      if (errorField != null) 'errorField': errorField.toJson(),
    };
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
      outerResponse:
          ResponseData.fromJson(json['outerResponse'] as Map<String, dynamic>),
      header: json.containsKey('header')
          ? SignedExchangeHeader.fromJson(
              json['header'] as Map<String, dynamic>)
          : null,
      securityDetails: json.containsKey('securityDetails')
          ? SecurityDetails.fromJson(
              json['securityDetails'] as Map<String, dynamic>)
          : null,
      errors: json.containsKey('errors')
          ? (json['errors'] as List)
              .map((e) =>
                  SignedExchangeError.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'outerResponse': outerResponse.toJson(),
      if (header != null) 'header': header.toJson(),
      if (securityDetails != null) 'securityDetails': securityDetails.toJson(),
      if (errors != null) 'errors': errors.map((e) => e.toJson()).toList(),
    };
  }
}
