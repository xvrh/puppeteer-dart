import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'security.dart' as security;
import 'page.dart' as page;
import 'runtime.dart' as runtime;
import 'io.dart' as io;
import 'debugger.dart' as debugger;

/// Network domain allows tracking network activities of the page. It exposes information about http,
/// file, data and other requests and responses, their headers, bodies, timing, etc.
class NetworkApi {
  final Client _client;

  NetworkApi(this._client);

  /// Fired when data chunk was received over the network.
  Stream<DataReceivedEvent> get onDataReceived => _client.onEvent
      .where((Event event) => event.name == 'Network.dataReceived')
      .map((Event event) => new DataReceivedEvent.fromJson(event.parameters));

  /// Fired when EventSource message is received.
  Stream<EventSourceMessageReceivedEvent> get onEventSourceMessageReceived =>
      _client.onEvent
          .where((Event event) =>
              event.name == 'Network.eventSourceMessageReceived')
          .map((Event event) =>
              new EventSourceMessageReceivedEvent.fromJson(event.parameters));

  /// Fired when HTTP request has failed to load.
  Stream<LoadingFailedEvent> get onLoadingFailed => _client.onEvent
      .where((Event event) => event.name == 'Network.loadingFailed')
      .map((Event event) => new LoadingFailedEvent.fromJson(event.parameters));

  /// Fired when HTTP request has finished loading.
  Stream<LoadingFinishedEvent> get onLoadingFinished => _client.onEvent
      .where((Event event) => event.name == 'Network.loadingFinished')
      .map(
          (Event event) => new LoadingFinishedEvent.fromJson(event.parameters));

  /// Details of an intercepted HTTP request, which must be either allowed, blocked, modified or
  /// mocked.
  Stream<RequestInterceptedEvent> get onRequestIntercepted => _client.onEvent
      .where((Event event) => event.name == 'Network.requestIntercepted')
      .map((Event event) =>
          new RequestInterceptedEvent.fromJson(event.parameters));

  /// Fired if request ended up loading from cache.
  Stream<RequestId> get onRequestServedFromCache => _client.onEvent
      .where((Event event) => event.name == 'Network.requestServedFromCache')
      .map((Event event) =>
          new RequestId.fromJson(event.parameters['requestId']));

  /// Fired when page is about to send HTTP request.
  Stream<RequestWillBeSentEvent> get onRequestWillBeSent => _client.onEvent
      .where((Event event) => event.name == 'Network.requestWillBeSent')
      .map((Event event) =>
          new RequestWillBeSentEvent.fromJson(event.parameters));

  /// Fired when resource loading priority is changed
  Stream<ResourceChangedPriorityEvent> get onResourceChangedPriority => _client
      .onEvent
      .where((Event event) => event.name == 'Network.resourceChangedPriority')
      .map((Event event) =>
          new ResourceChangedPriorityEvent.fromJson(event.parameters));

  /// Fired when HTTP response is available.
  Stream<ResponseReceivedEvent> get onResponseReceived => _client.onEvent
      .where((Event event) => event.name == 'Network.responseReceived')
      .map((Event event) =>
          new ResponseReceivedEvent.fromJson(event.parameters));

  /// Fired when WebSocket is closed.
  Stream<WebSocketClosedEvent> get onWebSocketClosed => _client.onEvent
      .where((Event event) => event.name == 'Network.webSocketClosed')
      .map(
          (Event event) => new WebSocketClosedEvent.fromJson(event.parameters));

  /// Fired upon WebSocket creation.
  Stream<WebSocketCreatedEvent> get onWebSocketCreated => _client.onEvent
      .where((Event event) => event.name == 'Network.webSocketCreated')
      .map((Event event) =>
          new WebSocketCreatedEvent.fromJson(event.parameters));

  /// Fired when WebSocket frame error occurs.
  Stream<WebSocketFrameErrorEvent> get onWebSocketFrameError => _client.onEvent
      .where((Event event) => event.name == 'Network.webSocketFrameError')
      .map((Event event) =>
          new WebSocketFrameErrorEvent.fromJson(event.parameters));

  /// Fired when WebSocket frame is received.
  Stream<WebSocketFrameReceivedEvent> get onWebSocketFrameReceived => _client
      .onEvent
      .where((Event event) => event.name == 'Network.webSocketFrameReceived')
      .map((Event event) =>
          new WebSocketFrameReceivedEvent.fromJson(event.parameters));

  /// Fired when WebSocket frame is sent.
  Stream<WebSocketFrameSentEvent> get onWebSocketFrameSent => _client.onEvent
      .where((Event event) => event.name == 'Network.webSocketFrameSent')
      .map((Event event) =>
          new WebSocketFrameSentEvent.fromJson(event.parameters));

  /// Fired when WebSocket handshake response becomes available.
  Stream<WebSocketHandshakeResponseReceivedEvent>
      get onWebSocketHandshakeResponseReceived => _client.onEvent
          .where((Event event) =>
              event.name == 'Network.webSocketHandshakeResponseReceived')
          .map((Event event) =>
              new WebSocketHandshakeResponseReceivedEvent.fromJson(
                  event.parameters));

  /// Fired when WebSocket is about to initiate handshake.
  Stream<WebSocketWillSendHandshakeRequestEvent>
      get onWebSocketWillSendHandshakeRequest => _client.onEvent
          .where((Event event) =>
              event.name == 'Network.webSocketWillSendHandshakeRequest')
          .map((Event event) =>
              new WebSocketWillSendHandshakeRequestEvent.fromJson(
                  event.parameters));

  /// Tells whether clearing browser cache is supported.
  /// Returns: True if browser cache can be cleared.
  @deprecated
  Future<bool> canClearBrowserCache() async {
    Map result = await _client.send('Network.canClearBrowserCache');
    return result['result'];
  }

  /// Tells whether clearing browser cookies is supported.
  /// Returns: True if browser cookies can be cleared.
  @deprecated
  Future<bool> canClearBrowserCookies() async {
    Map result = await _client.send('Network.canClearBrowserCookies');
    return result['result'];
  }

  /// Tells whether emulation of network conditions is supported.
  /// Returns: True if emulation of network conditions is supported.
  @deprecated
  Future<bool> canEmulateNetworkConditions() async {
    Map result = await _client.send('Network.canEmulateNetworkConditions');
    return result['result'];
  }

  /// Clears browser cache.
  Future clearBrowserCache() async {
    await _client.send('Network.clearBrowserCache');
  }

  /// Clears browser cookies.
  Future clearBrowserCookies() async {
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
  Future deleteCookies(
    String name, {
    String url,
    String domain,
    String path,
  }) async {
    Map parameters = {
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
  Future disable() async {
    await _client.send('Network.disable');
  }

  /// Activates emulation of network conditions.
  /// [offline] True to emulate internet disconnection.
  /// [latency] Minimum latency from request sent to response headers received (ms).
  /// [downloadThroughput] Maximal aggregated download throughput (bytes/sec). -1 disables download throttling.
  /// [uploadThroughput] Maximal aggregated upload throughput (bytes/sec).  -1 disables upload throttling.
  /// [connectionType] Connection type if known.
  Future emulateNetworkConditions(
    bool offline,
    num latency,
    num downloadThroughput,
    num uploadThroughput, {
    ConnectionType connectionType,
  }) async {
    Map parameters = {
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
  Future enable({
    int maxTotalBufferSize,
    int maxResourceBufferSize,
    int maxPostDataSize,
  }) async {
    Map parameters = {};
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
    Map result = await _client.send('Network.getAllCookies');
    return (result['cookies'] as List)
        .map((e) => new Cookie.fromJson(e))
        .toList();
  }

  /// Returns the DER-encoded certificate.
  /// [origin] Origin to get certificate for.
  Future<List<String>> getCertificate(
    String origin,
  ) async {
    Map parameters = {
      'origin': origin,
    };
    Map result = await _client.send('Network.getCertificate', parameters);
    return (result['tableNames'] as List).map((e) => e as String).toList();
  }

  /// Returns all browser cookies for the current URL. Depending on the backend support, will return
  /// detailed cookie information in the `cookies` field.
  /// [urls] The list of URLs for which applicable cookies will be fetched
  /// Returns: Array of cookie objects.
  Future<List<Cookie>> getCookies({
    List<String> urls,
  }) async {
    Map parameters = {};
    if (urls != null) {
      parameters['urls'] = urls.map((e) => e).toList();
    }
    Map result = await _client.send('Network.getCookies', parameters);
    return (result['cookies'] as List)
        .map((e) => new Cookie.fromJson(e))
        .toList();
  }

  /// Returns content served for the given request.
  /// [requestId] Identifier of the network request to get content for.
  Future<GetResponseBodyResult> getResponseBody(
    RequestId requestId,
  ) async {
    Map parameters = {
      'requestId': requestId.toJson(),
    };
    Map result = await _client.send('Network.getResponseBody', parameters);
    return new GetResponseBodyResult.fromJson(result);
  }

  /// Returns post data sent with the request. Returns an error when no data was sent with the request.
  /// [requestId] Identifier of the network request to get content for.
  /// Returns: Base64-encoded request body.
  Future<String> getRequestPostData(
    RequestId requestId,
  ) async {
    Map parameters = {
      'requestId': requestId.toJson(),
    };
    Map result = await _client.send('Network.getRequestPostData', parameters);
    return result['postData'];
  }

  /// Returns content served for the given currently intercepted request.
  /// [interceptionId] Identifier for the intercepted request to get body for.
  Future<GetResponseBodyForInterceptionResult> getResponseBodyForInterception(
    InterceptionId interceptionId,
  ) async {
    Map parameters = {
      'interceptionId': interceptionId.toJson(),
    };
    Map result = await _client.send(
        'Network.getResponseBodyForInterception', parameters);
    return new GetResponseBodyForInterceptionResult.fromJson(result);
  }

  /// Returns a handle to the stream representing the response body. Note that after this command,
  /// the intercepted request can't be continued as is -- you either need to cancel it or to provide
  /// the response body. The stream only supports sequential read, IO.read will fail if the position
  /// is specified.
  Future<io.StreamHandle> takeResponseBodyForInterceptionAsStream(
    InterceptionId interceptionId,
  ) async {
    Map parameters = {
      'interceptionId': interceptionId.toJson(),
    };
    Map result = await _client.send(
        'Network.takeResponseBodyForInterceptionAsStream', parameters);
    return new io.StreamHandle.fromJson(result['stream']);
  }

  /// This method sends a new XMLHttpRequest which is identical to the original one. The following
  /// parameters should be identical: method, url, async, request body, extra headers, withCredentials
  /// attribute, user, password.
  /// [requestId] Identifier of XHR to replay.
  Future replayXHR(
    RequestId requestId,
  ) async {
    Map parameters = {
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
    RequestId requestId,
    String query, {
    bool caseSensitive,
    bool isRegex,
  }) async {
    Map parameters = {
      'requestId': requestId.toJson(),
      'query': query,
    };
    if (caseSensitive != null) {
      parameters['caseSensitive'] = caseSensitive;
    }
    if (isRegex != null) {
      parameters['isRegex'] = isRegex;
    }
    Map result = await _client.send('Network.searchInResponseBody', parameters);
    return (result['result'] as List)
        .map((e) => new debugger.SearchMatch.fromJson(e))
        .toList();
  }

  /// Blocks URLs from loading.
  /// [urls] URL patterns to block. Wildcards ('*') are allowed.
  Future setBlockedURLs(
    List<String> urls,
  ) async {
    Map parameters = {
      'urls': urls.map((e) => e).toList(),
    };
    await _client.send('Network.setBlockedURLs', parameters);
  }

  /// Toggles ignoring of service worker for each request.
  /// [bypass] Bypass service worker and load from network.
  Future setBypassServiceWorker(
    bool bypass,
  ) async {
    Map parameters = {
      'bypass': bypass,
    };
    await _client.send('Network.setBypassServiceWorker', parameters);
  }

  /// Toggles ignoring cache for each request. If `true`, cache will not be used.
  /// [cacheDisabled] Cache disabled state.
  Future setCacheDisabled(
    bool cacheDisabled,
  ) async {
    Map parameters = {
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
    Map result = await _client.send('Network.setCookie', parameters);
    return result['success'];
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

  /// For testing.
  /// [maxTotalSize] Maximum total buffer size.
  /// [maxResourceSize] Maximum per-resource size.
  Future setDataSizeLimitsForTest(
    int maxTotalSize,
    int maxResourceSize,
  ) async {
    Map parameters = {
      'maxTotalSize': maxTotalSize,
      'maxResourceSize': maxResourceSize,
    };
    await _client.send('Network.setDataSizeLimitsForTest', parameters);
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

  /// Sets the requests to intercept that match a the provided patterns and optionally resource types.
  /// [patterns] Requests matching any of these patterns will be forwarded and wait for the corresponding
  /// continueInterceptedRequest call.
  Future setRequestInterception(
    List<RequestPattern> patterns,
  ) async {
    Map parameters = {
      'patterns': patterns.map((e) => e.toJson()).toList(),
    };
    await _client.send('Network.setRequestInterception', parameters);
  }

  /// Allows overriding user agent with the given string.
  /// [userAgent] User agent to use.
  Future setUserAgentOverride(
    String userAgent,
  ) async {
    Map parameters = {
      'userAgent': userAgent,
    };
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

  DataReceivedEvent({
    @required this.requestId,
    @required this.timestamp,
    @required this.dataLength,
    @required this.encodedDataLength,
  });

  factory DataReceivedEvent.fromJson(Map json) {
    return new DataReceivedEvent(
      requestId: new RequestId.fromJson(json['requestId']),
      timestamp: new MonotonicTime.fromJson(json['timestamp']),
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

  EventSourceMessageReceivedEvent({
    @required this.requestId,
    @required this.timestamp,
    @required this.eventName,
    @required this.eventId,
    @required this.data,
  });

  factory EventSourceMessageReceivedEvent.fromJson(Map json) {
    return new EventSourceMessageReceivedEvent(
      requestId: new RequestId.fromJson(json['requestId']),
      timestamp: new MonotonicTime.fromJson(json['timestamp']),
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
  final page.ResourceType type;

  /// User friendly error message.
  final String errorText;

  /// True if loading was canceled.
  final bool canceled;

  /// The reason why loading was blocked, if any.
  final BlockedReason blockedReason;

  LoadingFailedEvent({
    @required this.requestId,
    @required this.timestamp,
    @required this.type,
    @required this.errorText,
    this.canceled,
    this.blockedReason,
  });

  factory LoadingFailedEvent.fromJson(Map json) {
    return new LoadingFailedEvent(
      requestId: new RequestId.fromJson(json['requestId']),
      timestamp: new MonotonicTime.fromJson(json['timestamp']),
      type: new page.ResourceType.fromJson(json['type']),
      errorText: json['errorText'],
      canceled: json.containsKey('canceled') ? json['canceled'] : null,
      blockedReason: json.containsKey('blockedReason')
          ? new BlockedReason.fromJson(json['blockedReason'])
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

  /// Set when response was blocked due to being cross-site document response.
  final bool blockedCrossSiteDocument;

  LoadingFinishedEvent({
    @required this.requestId,
    @required this.timestamp,
    @required this.encodedDataLength,
    this.blockedCrossSiteDocument,
  });

  factory LoadingFinishedEvent.fromJson(Map json) {
    return new LoadingFinishedEvent(
      requestId: new RequestId.fromJson(json['requestId']),
      timestamp: new MonotonicTime.fromJson(json['timestamp']),
      encodedDataLength: json['encodedDataLength'],
      blockedCrossSiteDocument: json.containsKey('blockedCrossSiteDocument')
          ? json['blockedCrossSiteDocument']
          : null,
    );
  }
}

class RequestInterceptedEvent {
  /// Each request the page makes will have a unique id, however if any redirects are encountered
  /// while processing that fetch, they will be reported with the same id as the original fetch.
  /// Likewise if HTTP authentication is needed then the same fetch id will be used.
  final InterceptionId interceptionId;

  final Request request;

  /// The id of the frame that initiated the request.
  final page.FrameId frameId;

  /// How the requested resource will be used.
  final page.ResourceType resourceType;

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

  RequestInterceptedEvent({
    @required this.interceptionId,
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
  });

  factory RequestInterceptedEvent.fromJson(Map json) {
    return new RequestInterceptedEvent(
      interceptionId: new InterceptionId.fromJson(json['interceptionId']),
      request: new Request.fromJson(json['request']),
      frameId: new page.FrameId.fromJson(json['frameId']),
      resourceType: new page.ResourceType.fromJson(json['resourceType']),
      isNavigationRequest: json['isNavigationRequest'],
      isDownload: json.containsKey('isDownload') ? json['isDownload'] : null,
      redirectUrl: json.containsKey('redirectUrl') ? json['redirectUrl'] : null,
      authChallenge: json.containsKey('authChallenge')
          ? new AuthChallenge.fromJson(json['authChallenge'])
          : null,
      responseErrorReason: json.containsKey('responseErrorReason')
          ? new ErrorReason.fromJson(json['responseErrorReason'])
          : null,
      responseStatusCode: json.containsKey('responseStatusCode')
          ? json['responseStatusCode']
          : null,
      responseHeaders: json.containsKey('responseHeaders')
          ? new Headers.fromJson(json['responseHeaders'])
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
  final Request request;

  /// Timestamp.
  final MonotonicTime timestamp;

  /// Timestamp.
  final TimeSinceEpoch wallTime;

  /// Request initiator.
  final Initiator initiator;

  /// Redirect response data.
  final Response redirectResponse;

  /// Type of this resource.
  final page.ResourceType type;

  /// Frame identifier.
  final page.FrameId frameId;

  /// Whether the request is initiated by a user gesture. Defaults to false.
  final bool hasUserGesture;

  RequestWillBeSentEvent({
    @required this.requestId,
    @required this.loaderId,
    @required this.documentURL,
    @required this.request,
    @required this.timestamp,
    @required this.wallTime,
    @required this.initiator,
    this.redirectResponse,
    this.type,
    this.frameId,
    this.hasUserGesture,
  });

  factory RequestWillBeSentEvent.fromJson(Map json) {
    return new RequestWillBeSentEvent(
      requestId: new RequestId.fromJson(json['requestId']),
      loaderId: new LoaderId.fromJson(json['loaderId']),
      documentURL: json['documentURL'],
      request: new Request.fromJson(json['request']),
      timestamp: new MonotonicTime.fromJson(json['timestamp']),
      wallTime: new TimeSinceEpoch.fromJson(json['wallTime']),
      initiator: new Initiator.fromJson(json['initiator']),
      redirectResponse: json.containsKey('redirectResponse')
          ? new Response.fromJson(json['redirectResponse'])
          : null,
      type: json.containsKey('type')
          ? new page.ResourceType.fromJson(json['type'])
          : null,
      frameId: json.containsKey('frameId')
          ? new page.FrameId.fromJson(json['frameId'])
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

  ResourceChangedPriorityEvent({
    @required this.requestId,
    @required this.newPriority,
    @required this.timestamp,
  });

  factory ResourceChangedPriorityEvent.fromJson(Map json) {
    return new ResourceChangedPriorityEvent(
      requestId: new RequestId.fromJson(json['requestId']),
      newPriority: new ResourcePriority.fromJson(json['newPriority']),
      timestamp: new MonotonicTime.fromJson(json['timestamp']),
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
  final page.ResourceType type;

  /// Response data.
  final Response response;

  /// Frame identifier.
  final page.FrameId frameId;

  ResponseReceivedEvent({
    @required this.requestId,
    @required this.loaderId,
    @required this.timestamp,
    @required this.type,
    @required this.response,
    this.frameId,
  });

  factory ResponseReceivedEvent.fromJson(Map json) {
    return new ResponseReceivedEvent(
      requestId: new RequestId.fromJson(json['requestId']),
      loaderId: new LoaderId.fromJson(json['loaderId']),
      timestamp: new MonotonicTime.fromJson(json['timestamp']),
      type: new page.ResourceType.fromJson(json['type']),
      response: new Response.fromJson(json['response']),
      frameId: json.containsKey('frameId')
          ? new page.FrameId.fromJson(json['frameId'])
          : null,
    );
  }
}

class WebSocketClosedEvent {
  /// Request identifier.
  final RequestId requestId;

  /// Timestamp.
  final MonotonicTime timestamp;

  WebSocketClosedEvent({
    @required this.requestId,
    @required this.timestamp,
  });

  factory WebSocketClosedEvent.fromJson(Map json) {
    return new WebSocketClosedEvent(
      requestId: new RequestId.fromJson(json['requestId']),
      timestamp: new MonotonicTime.fromJson(json['timestamp']),
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

  WebSocketCreatedEvent({
    @required this.requestId,
    @required this.url,
    this.initiator,
  });

  factory WebSocketCreatedEvent.fromJson(Map json) {
    return new WebSocketCreatedEvent(
      requestId: new RequestId.fromJson(json['requestId']),
      url: json['url'],
      initiator: json.containsKey('initiator')
          ? new Initiator.fromJson(json['initiator'])
          : null,
    );
  }
}

class WebSocketFrameErrorEvent {
  /// Request identifier.
  final RequestId requestId;

  /// Timestamp.
  final MonotonicTime timestamp;

  /// WebSocket frame error message.
  final String errorMessage;

  WebSocketFrameErrorEvent({
    @required this.requestId,
    @required this.timestamp,
    @required this.errorMessage,
  });

  factory WebSocketFrameErrorEvent.fromJson(Map json) {
    return new WebSocketFrameErrorEvent(
      requestId: new RequestId.fromJson(json['requestId']),
      timestamp: new MonotonicTime.fromJson(json['timestamp']),
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

  WebSocketFrameReceivedEvent({
    @required this.requestId,
    @required this.timestamp,
    @required this.response,
  });

  factory WebSocketFrameReceivedEvent.fromJson(Map json) {
    return new WebSocketFrameReceivedEvent(
      requestId: new RequestId.fromJson(json['requestId']),
      timestamp: new MonotonicTime.fromJson(json['timestamp']),
      response: new WebSocketFrame.fromJson(json['response']),
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

  WebSocketFrameSentEvent({
    @required this.requestId,
    @required this.timestamp,
    @required this.response,
  });

  factory WebSocketFrameSentEvent.fromJson(Map json) {
    return new WebSocketFrameSentEvent(
      requestId: new RequestId.fromJson(json['requestId']),
      timestamp: new MonotonicTime.fromJson(json['timestamp']),
      response: new WebSocketFrame.fromJson(json['response']),
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

  WebSocketHandshakeResponseReceivedEvent({
    @required this.requestId,
    @required this.timestamp,
    @required this.response,
  });

  factory WebSocketHandshakeResponseReceivedEvent.fromJson(Map json) {
    return new WebSocketHandshakeResponseReceivedEvent(
      requestId: new RequestId.fromJson(json['requestId']),
      timestamp: new MonotonicTime.fromJson(json['timestamp']),
      response: new WebSocketResponse.fromJson(json['response']),
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

  WebSocketWillSendHandshakeRequestEvent({
    @required this.requestId,
    @required this.timestamp,
    @required this.wallTime,
    @required this.request,
  });

  factory WebSocketWillSendHandshakeRequestEvent.fromJson(Map json) {
    return new WebSocketWillSendHandshakeRequestEvent(
      requestId: new RequestId.fromJson(json['requestId']),
      timestamp: new MonotonicTime.fromJson(json['timestamp']),
      wallTime: new TimeSinceEpoch.fromJson(json['wallTime']),
      request: new WebSocketRequest.fromJson(json['request']),
    );
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

  factory GetResponseBodyResult.fromJson(Map json) {
    return new GetResponseBodyResult(
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

  GetResponseBodyForInterceptionResult({
    @required this.body,
    @required this.base64Encoded,
  });

  factory GetResponseBodyForInterceptionResult.fromJson(Map json) {
    return new GetResponseBodyForInterceptionResult(
      body: json['body'],
      base64Encoded: json['base64Encoded'],
    );
  }
}

/// Unique loader identifier.
class LoaderId {
  final String value;

  LoaderId(this.value);

  factory LoaderId.fromJson(String value) => new LoaderId(value);

  String toJson() => value;

  @override
  bool operator ==(other) => other is LoaderId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Unique request identifier.
class RequestId {
  final String value;

  RequestId(this.value);

  factory RequestId.fromJson(String value) => new RequestId(value);

  String toJson() => value;

  @override
  bool operator ==(other) => other is RequestId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Unique intercepted request identifier.
class InterceptionId {
  final String value;

  InterceptionId(this.value);

  factory InterceptionId.fromJson(String value) => new InterceptionId(value);

  String toJson() => value;

  @override
  bool operator ==(other) => other is InterceptionId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
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
  static const values = const {
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
  };

  final String value;

  const ErrorReason._(this.value);

  factory ErrorReason.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// UTC time in seconds, counted from January 1, 1970.
class TimeSinceEpoch {
  final num value;

  TimeSinceEpoch(this.value);

  factory TimeSinceEpoch.fromJson(num value) => new TimeSinceEpoch(value);

  num toJson() => value;

  @override
  bool operator ==(other) => other is TimeSinceEpoch && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Monotonically increasing time in seconds since an arbitrary point in the past.
class MonotonicTime {
  final num value;

  MonotonicTime(this.value);

  factory MonotonicTime.fromJson(num value) => new MonotonicTime(value);

  num toJson() => value;

  @override
  bool operator ==(other) => other is MonotonicTime && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Request / response headers as keys / values of JSON object.
class Headers {
  final Map value;

  Headers(this.value);

  factory Headers.fromJson(Map value) => new Headers(value);

  Map toJson() => value;

  @override
  bool operator ==(other) => other is Headers && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// The underlying connection technology that the browser is supposedly using.
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
  static const values = const {
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
  String toString() => value.toString();
}

/// Represents the cookie's 'SameSite' status:
/// https://tools.ietf.org/html/draft-west-first-party-cookies
class CookieSameSite {
  static const CookieSameSite strict = const CookieSameSite._('Strict');
  static const CookieSameSite lax = const CookieSameSite._('Lax');
  static const values = const {
    'Strict': strict,
    'Lax': lax,
  };

  final String value;

  const CookieSameSite._(this.value);

  factory CookieSameSite.fromJson(String value) => values[value];

  String toJson() => value;

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

  factory ResourceTiming.fromJson(Map json) {
    return new ResourceTiming(
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

  Map toJson() {
    Map json = {
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
  static const ResourcePriority veryLow = const ResourcePriority._('VeryLow');
  static const ResourcePriority low = const ResourcePriority._('Low');
  static const ResourcePriority medium = const ResourcePriority._('Medium');
  static const ResourcePriority high = const ResourcePriority._('High');
  static const ResourcePriority veryHigh = const ResourcePriority._('VeryHigh');
  static const values = const {
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
  String toString() => value.toString();
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

  /// True when the request has POST data. Note that postData might still be omitted when this flag is true when the data is too long.
  final bool hasPostData;

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
    this.hasPostData,
    this.mixedContentType,
    @required this.initialPriority,
    @required this.referrerPolicy,
    this.isLinkPreload,
  });

  factory Request.fromJson(Map json) {
    return new Request(
      url: json['url'],
      method: json['method'],
      headers: new Headers.fromJson(json['headers']),
      postData: json.containsKey('postData') ? json['postData'] : null,
      hasPostData: json.containsKey('hasPostData') ? json['hasPostData'] : null,
      mixedContentType: json.containsKey('mixedContentType')
          ? new security.MixedContentType.fromJson(json['mixedContentType'])
          : null,
      initialPriority: new ResourcePriority.fromJson(json['initialPriority']),
      referrerPolicy: json['referrerPolicy'],
      isLinkPreload:
          json.containsKey('isLinkPreload') ? json['isLinkPreload'] : null,
    );
  }

  Map toJson() {
    Map json = {
      'url': url,
      'method': method,
      'headers': headers.toJson(),
      'initialPriority': initialPriority.toJson(),
      'referrerPolicy': referrerPolicy,
    };
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

  factory SignedCertificateTimestamp.fromJson(Map json) {
    return new SignedCertificateTimestamp(
      status: json['status'],
      origin: json['origin'],
      logDescription: json['logDescription'],
      logId: json['logId'],
      timestamp: new TimeSinceEpoch.fromJson(json['timestamp']),
      hashAlgorithm: json['hashAlgorithm'],
      signatureAlgorithm: json['signatureAlgorithm'],
      signatureData: json['signatureData'],
    );
  }

  Map toJson() {
    Map json = {
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
    @required this.certificateTransparencyCompliance,
  });

  factory SecurityDetails.fromJson(Map json) {
    return new SecurityDetails(
      protocol: json['protocol'],
      keyExchange: json['keyExchange'],
      keyExchangeGroup: json.containsKey('keyExchangeGroup')
          ? json['keyExchangeGroup']
          : null,
      cipher: json['cipher'],
      mac: json.containsKey('mac') ? json['mac'] : null,
      certificateId: new security.CertificateId.fromJson(json['certificateId']),
      subjectName: json['subjectName'],
      sanList: (json['sanList'] as List).map((e) => e as String).toList(),
      issuer: json['issuer'],
      validFrom: new TimeSinceEpoch.fromJson(json['validFrom']),
      validTo: new TimeSinceEpoch.fromJson(json['validTo']),
      signedCertificateTimestampList:
          (json['signedCertificateTimestampList'] as List)
              .map((e) => new SignedCertificateTimestamp.fromJson(e))
              .toList(),
      certificateTransparencyCompliance:
          new CertificateTransparencyCompliance.fromJson(
              json['certificateTransparencyCompliance']),
    );
  }

  Map toJson() {
    Map json = {
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
  static const CertificateTransparencyCompliance unknown =
      const CertificateTransparencyCompliance._('unknown');
  static const CertificateTransparencyCompliance notCompliant =
      const CertificateTransparencyCompliance._('not-compliant');
  static const CertificateTransparencyCompliance compliant =
      const CertificateTransparencyCompliance._('compliant');
  static const values = const {
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
  String toString() => value.toString();
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
  static const BlockedReason contentType =
      const BlockedReason._('content-type');
  static const BlockedReason other = const BlockedReason._('other');
  static const values = const {
    'csp': csp,
    'mixed-content': mixedContent,
    'origin': origin,
    'inspector': inspector,
    'subresource-filter': subresourceFilter,
    'content-type': contentType,
    'other': other,
  };

  final String value;

  const BlockedReason._(this.value);

  factory BlockedReason.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// HTTP response data.
class Response {
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

  factory Response.fromJson(Map json) {
    return new Response(
      url: json['url'],
      status: json['status'],
      statusText: json['statusText'],
      headers: new Headers.fromJson(json['headers']),
      headersText: json.containsKey('headersText') ? json['headersText'] : null,
      mimeType: json['mimeType'],
      requestHeaders: json.containsKey('requestHeaders')
          ? new Headers.fromJson(json['requestHeaders'])
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
          ? new ResourceTiming.fromJson(json['timing'])
          : null,
      protocol: json.containsKey('protocol') ? json['protocol'] : null,
      securityState: new security.SecurityState.fromJson(json['securityState']),
      securityDetails: json.containsKey('securityDetails')
          ? new SecurityDetails.fromJson(json['securityDetails'])
          : null,
    );
  }

  Map toJson() {
    Map json = {
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

  WebSocketRequest({
    @required this.headers,
  });

  factory WebSocketRequest.fromJson(Map json) {
    return new WebSocketRequest(
      headers: new Headers.fromJson(json['headers']),
    );
  }

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

  WebSocketResponse({
    @required this.status,
    @required this.statusText,
    @required this.headers,
    this.headersText,
    this.requestHeaders,
    this.requestHeadersText,
  });

  factory WebSocketResponse.fromJson(Map json) {
    return new WebSocketResponse(
      status: json['status'],
      statusText: json['statusText'],
      headers: new Headers.fromJson(json['headers']),
      headersText: json.containsKey('headersText') ? json['headersText'] : null,
      requestHeaders: json.containsKey('requestHeaders')
          ? new Headers.fromJson(json['requestHeaders'])
          : null,
      requestHeadersText: json.containsKey('requestHeadersText')
          ? json['requestHeadersText']
          : null,
    );
  }

  Map toJson() {
    Map json = {
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

  factory WebSocketFrame.fromJson(Map json) {
    return new WebSocketFrame(
      opcode: json['opcode'],
      mask: json['mask'],
      payloadData: json['payloadData'],
    );
  }

  Map toJson() {
    Map json = {
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

  factory CachedResource.fromJson(Map json) {
    return new CachedResource(
      url: json['url'],
      type: new page.ResourceType.fromJson(json['type']),
      response: json.containsKey('response')
          ? new Response.fromJson(json['response'])
          : null,
      bodySize: json['bodySize'],
    );
  }

  Map toJson() {
    Map json = {
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
  final String type;

  /// Initiator JavaScript stack trace, set for Script only.
  final runtime.StackTrace stack;

  /// Initiator URL, set for Parser type or for Script type (when script is importing module).
  final String url;

  /// Initiator line number, set for Parser type or for Script type (when script is importing
  /// module) (0-based).
  final num lineNumber;

  Initiator({
    @required this.type,
    this.stack,
    this.url,
    this.lineNumber,
  });

  factory Initiator.fromJson(Map json) {
    return new Initiator(
      type: json['type'],
      stack: json.containsKey('stack')
          ? new runtime.StackTrace.fromJson(json['stack'])
          : null,
      url: json.containsKey('url') ? json['url'] : null,
      lineNumber: json.containsKey('lineNumber') ? json['lineNumber'] : null,
    );
  }

  Map toJson() {
    Map json = {
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

  factory Cookie.fromJson(Map json) {
    return new Cookie(
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
          ? new CookieSameSite.fromJson(json['sameSite'])
          : null,
    );
  }

  Map toJson() {
    Map json = {
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

  factory CookieParam.fromJson(Map json) {
    return new CookieParam(
      name: json['name'],
      value: json['value'],
      url: json.containsKey('url') ? json['url'] : null,
      domain: json.containsKey('domain') ? json['domain'] : null,
      path: json.containsKey('path') ? json['path'] : null,
      secure: json.containsKey('secure') ? json['secure'] : null,
      httpOnly: json.containsKey('httpOnly') ? json['httpOnly'] : null,
      sameSite: json.containsKey('sameSite')
          ? new CookieSameSite.fromJson(json['sameSite'])
          : null,
      expires: json.containsKey('expires')
          ? new TimeSinceEpoch.fromJson(json['expires'])
          : null,
    );
  }

  Map toJson() {
    Map json = {
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

  factory AuthChallenge.fromJson(Map json) {
    return new AuthChallenge(
      source: json.containsKey('source') ? json['source'] : null,
      origin: json['origin'],
      scheme: json['scheme'],
      realm: json['realm'],
    );
  }

  Map toJson() {
    Map json = {
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

/// Response to an AuthChallenge.
class AuthChallengeResponse {
  /// The decision on what to do in response to the authorization challenge.  Default means
  /// deferring to the default behavior of the net stack, which will likely either the Cancel
  /// authentication or display a popup dialog box.
  final String response;

  /// The username to provide, possibly empty. Should only be set if response is
  /// ProvideCredentials.
  final String username;

  /// The password to provide, possibly empty. Should only be set if response is
  /// ProvideCredentials.
  final String password;

  AuthChallengeResponse({
    @required this.response,
    this.username,
    this.password,
  });

  factory AuthChallengeResponse.fromJson(Map json) {
    return new AuthChallengeResponse(
      response: json['response'],
      username: json.containsKey('username') ? json['username'] : null,
      password: json.containsKey('password') ? json['password'] : null,
    );
  }

  Map toJson() {
    Map json = {
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

/// Stages of the interception to begin intercepting. Request will intercept before the request is
/// sent. Response will intercept after the response is received.
class InterceptionStage {
  static const InterceptionStage request = const InterceptionStage._('Request');
  static const InterceptionStage headersReceived =
      const InterceptionStage._('HeadersReceived');
  static const values = const {
    'Request': request,
    'HeadersReceived': headersReceived,
  };

  final String value;

  const InterceptionStage._(this.value);

  factory InterceptionStage.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Request pattern for interception.
class RequestPattern {
  /// Wildcards ('*' -> zero or more, '?' -> exactly one) are allowed. Escape character is
  /// backslash. Omitting is equivalent to "*".
  final String urlPattern;

  /// If set, only requests for matching resource types will be intercepted.
  final page.ResourceType resourceType;

  /// Stage at wich to begin intercepting requests. Default is Request.
  final InterceptionStage interceptionStage;

  RequestPattern({
    this.urlPattern,
    this.resourceType,
    this.interceptionStage,
  });

  factory RequestPattern.fromJson(Map json) {
    return new RequestPattern(
      urlPattern: json.containsKey('urlPattern') ? json['urlPattern'] : null,
      resourceType: json.containsKey('resourceType')
          ? new page.ResourceType.fromJson(json['resourceType'])
          : null,
      interceptionStage: json.containsKey('interceptionStage')
          ? new InterceptionStage.fromJson(json['interceptionStage'])
          : null,
    );
  }

  Map toJson() {
    Map json = {};
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
