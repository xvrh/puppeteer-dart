import 'dart:async';
import '../src/connection.dart';
import 'debugger.dart' as debugger;
import 'emulation.dart' as emulation;
import 'io.dart' as io;
import 'network.dart' as network;
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

  /// Fired upon WebTransport creation.
  Stream<WebTransportCreatedEvent> get onWebTransportCreated => _client.onEvent
      .where((event) => event.name == 'Network.webTransportCreated')
      .map((event) => WebTransportCreatedEvent.fromJson(event.parameters));

  /// Fired when WebTransport handshake is finished.
  Stream<WebTransportConnectionEstablishedEvent>
      get onWebTransportConnectionEstablished => _client.onEvent
          .where((event) =>
              event.name == 'Network.webTransportConnectionEstablished')
          .map((event) => WebTransportConnectionEstablishedEvent.fromJson(
              event.parameters));

  /// Fired when WebTransport is disposed.
  Stream<WebTransportClosedEvent> get onWebTransportClosed => _client.onEvent
      .where((event) => event.name == 'Network.webTransportClosed')
      .map((event) => WebTransportClosedEvent.fromJson(event.parameters));

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

  /// Fired exactly once for each Trust Token operation. Depending on
  /// the type of the operation and whether the operation succeeded or
  /// failed, the event is fired before the corresponding request was sent
  /// or after the response was received.
  Stream<TrustTokenOperationDoneEvent> get onTrustTokenOperationDone => _client
      .onEvent
      .where((event) => event.name == 'Network.trustTokenOperationDone')
      .map((event) => TrustTokenOperationDoneEvent.fromJson(event.parameters));

  /// Fired once when parsing the .wbn file has succeeded.
  /// The event contains the information about the web bundle contents.
  Stream<SubresourceWebBundleMetadataReceivedEvent>
      get onSubresourceWebBundleMetadataReceived => _client.onEvent
          .where((event) =>
              event.name == 'Network.subresourceWebBundleMetadataReceived')
          .map((event) => SubresourceWebBundleMetadataReceivedEvent.fromJson(
              event.parameters));

  /// Fired once when parsing the .wbn file has failed.
  Stream<SubresourceWebBundleMetadataErrorEvent>
      get onSubresourceWebBundleMetadataError => _client.onEvent
          .where((event) =>
              event.name == 'Network.subresourceWebBundleMetadataError')
          .map((event) => SubresourceWebBundleMetadataErrorEvent.fromJson(
              event.parameters));

  /// Fired when handling requests for resources within a .wbn file.
  /// Note: this will only be fired for resources that are requested by the webpage.
  Stream<SubresourceWebBundleInnerResponseParsedEvent>
      get onSubresourceWebBundleInnerResponseParsed => _client.onEvent
          .where((event) =>
              event.name == 'Network.subresourceWebBundleInnerResponseParsed')
          .map((event) => SubresourceWebBundleInnerResponseParsedEvent.fromJson(
              event.parameters));

  /// Fired when request for resources within a .wbn file failed.
  Stream<SubresourceWebBundleInnerResponseErrorEvent>
      get onSubresourceWebBundleInnerResponseError => _client.onEvent
          .where((event) =>
              event.name == 'Network.subresourceWebBundleInnerResponseError')
          .map((event) => SubresourceWebBundleInnerResponseErrorEvent.fromJson(
              event.parameters));

  /// Is sent whenever a new report is added.
  /// And after 'enableReportingApi' for all existing reports.
  Stream<ReportingApiReport> get onReportingApiReportAdded => _client.onEvent
      .where((event) => event.name == 'Network.reportingApiReportAdded')
      .map((event) => ReportingApiReport.fromJson(
          event.parameters['report'] as Map<String, dynamic>));

  Stream<ReportingApiReport> get onReportingApiReportUpdated => _client.onEvent
      .where((event) => event.name == 'Network.reportingApiReportUpdated')
      .map((event) => ReportingApiReport.fromJson(
          event.parameters['report'] as Map<String, dynamic>));

  Stream<ReportingApiEndpointsChangedForOriginEvent>
      get onReportingApiEndpointsChangedForOrigin => _client.onEvent
          .where((event) =>
              event.name == 'Network.reportingApiEndpointsChangedForOrigin')
          .map((event) => ReportingApiEndpointsChangedForOriginEvent.fromJson(
              event.parameters));

  /// Sets a list of content encodings that will be accepted. Empty list means no encoding is accepted.
  /// [encodings] List of accepted content encodings.
  Future<void> setAcceptedEncodings(List<ContentEncoding> encodings) async {
    await _client.send('Network.setAcceptedEncodings', {
      'encodings': [...encodings],
    });
  }

  /// Clears accepted encodings set by setAcceptedEncodings
  Future<void> clearAcceptedEncodingsOverride() async {
    await _client.send('Network.clearAcceptedEncodingsOverride');
  }

  /// Tells whether clearing browser cache is supported.
  /// Returns: True if browser cache can be cleared.
  @Deprecated('This command is deprecated')
  Future<bool> canClearBrowserCache() async {
    var result = await _client.send('Network.canClearBrowserCache');
    return result['result'] as bool;
  }

  /// Tells whether clearing browser cookies is supported.
  /// Returns: True if browser cookies can be cleared.
  @Deprecated('This command is deprecated')
  Future<bool> canClearBrowserCookies() async {
    var result = await _client.send('Network.canClearBrowserCookies');
    return result['result'] as bool;
  }

  /// Tells whether emulation of network conditions is supported.
  /// Returns: True if emulation of network conditions is supported.
  @Deprecated('This command is deprecated')
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
  @Deprecated(
      'use Fetch.continueRequest, Fetch.fulfillRequest and Fetch.failRequest instead')
  Future<void> continueInterceptedRequest(InterceptionId interceptionId,
      {ErrorReason? errorReason,
      String? rawResponse,
      String? url,
      String? method,
      String? postData,
      Headers? headers,
      AuthChallengeResponse? authChallengeResponse}) async {
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
      {String? url, String? domain, String? path}) async {
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
      {ConnectionType? connectionType}) async {
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
      {int? maxTotalBufferSize,
      int? maxResourceBufferSize,
      int? maxPostDataSize}) async {
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
  /// [urls] The list of URLs for which applicable cookies will be fetched.
  /// If not specified, it's assumed to be set to the list containing
  /// the URLs of the page and all of its subframes.
  /// Returns: Array of cookie objects.
  Future<List<Cookie>> getCookies({List<String>? urls}) async {
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
      {bool? caseSensitive, bool? isRegex}) async {
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
  /// default domain, path, source port, and source scheme values of the created cookie.
  /// [domain] Cookie domain.
  /// [path] Cookie path.
  /// [secure] True if cookie is secure.
  /// [httpOnly] True if cookie is http-only.
  /// [sameSite] Cookie SameSite type.
  /// [expires] Cookie expiration date, session cookie if not set
  /// [priority] Cookie Priority type.
  /// [sameParty] True if cookie is SameParty.
  /// [sourceScheme] Cookie source scheme type.
  /// [sourcePort] Cookie source port. Valid values are {-1, [1, 65535]}, -1 indicates an unspecified port.
  /// An unspecified port value allows protocol clients to emulate legacy cookie scope for the port.
  /// This is a temporary ability and it will be removed in the future.
  /// [partitionKey] Cookie partition key. The site of the top-level URL the browser was visiting at the start
  /// of the request to the endpoint that set the cookie.
  /// If not set, the cookie will be set as not partitioned.
  /// Returns: Always set to true. If an error occurs, the response indicates protocol error.
  Future<bool> setCookie(String name, String value,
      {String? url,
      String? domain,
      String? path,
      bool? secure,
      bool? httpOnly,
      CookieSameSite? sameSite,
      TimeSinceEpoch? expires,
      CookiePriority? priority,
      bool? sameParty,
      CookieSourceScheme? sourceScheme,
      int? sourcePort,
      String? partitionKey}) async {
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
      if (sameParty != null) 'sameParty': sameParty,
      if (sourceScheme != null) 'sourceScheme': sourceScheme,
      if (sourcePort != null) 'sourcePort': sourcePort,
      if (partitionKey != null) 'partitionKey': partitionKey,
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

  /// Specifies whether to always send extra HTTP headers with the requests from this page.
  /// [headers] Map with extra HTTP headers.
  Future<void> setExtraHTTPHeaders(Headers headers) async {
    await _client.send('Network.setExtraHTTPHeaders', {
      'headers': headers,
    });
  }

  /// Specifies whether to attach a page script stack id in requests
  /// [enabled] Whether to attach a page script stack for debugging purpose.
  Future<void> setAttachDebugStack(bool enabled) async {
    await _client.send('Network.setAttachDebugStack', {
      'enabled': enabled,
    });
  }

  /// Sets the requests to intercept that match the provided patterns and optionally resource types.
  /// Deprecated, please use Fetch.enable instead.
  /// [patterns] Requests matching any of these patterns will be forwarded and wait for the corresponding
  /// continueInterceptedRequest call.
  @Deprecated('use Fetch.enable instead')
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
      {String? acceptLanguage,
      String? platform,
      emulation.UserAgentMetadata? userAgentMetadata}) async {
    await _client.send('Network.setUserAgentOverride', {
      'userAgent': userAgent,
      if (acceptLanguage != null) 'acceptLanguage': acceptLanguage,
      if (platform != null) 'platform': platform,
      if (userAgentMetadata != null) 'userAgentMetadata': userAgentMetadata,
    });
  }

  /// Returns information about the COEP/COOP isolation status.
  /// [frameId] If no frameId is provided, the status of the target is provided.
  Future<SecurityIsolationStatus> getSecurityIsolationStatus(
      {page.FrameId? frameId}) async {
    var result = await _client.send('Network.getSecurityIsolationStatus', {
      if (frameId != null) 'frameId': frameId,
    });
    return SecurityIsolationStatus.fromJson(
        result['status'] as Map<String, dynamic>);
  }

  /// Enables tracking for the Reporting API, events generated by the Reporting API will now be delivered to the client.
  /// Enabling triggers 'reportingApiReportAdded' for all existing reports.
  /// [enable] Whether to enable or disable events for the Reporting API
  Future<void> enableReportingApi(bool enable) async {
    await _client.send('Network.enableReportingApi', {
      'enable': enable,
    });
  }

  /// Fetches the resource and returns the content.
  /// [frameId] Frame id to get the resource for. Mandatory for frame targets, and
  /// should be omitted for worker targets.
  /// [url] URL of the resource to get content for.
  /// [options] Options for the request.
  Future<LoadNetworkResourcePageResult> loadNetworkResource(
      String url, LoadNetworkResourceOptions options,
      {page.FrameId? frameId}) async {
    var result = await _client.send('Network.loadNetworkResource', {
      'url': url,
      'options': options,
      if (frameId != null) 'frameId': frameId,
    });
    return LoadNetworkResourcePageResult.fromJson(
        result['resource'] as Map<String, dynamic>);
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
      {required this.requestId,
      required this.timestamp,
      required this.dataLength,
      required this.encodedDataLength});

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
      {required this.requestId,
      required this.timestamp,
      required this.eventName,
      required this.eventId,
      required this.data});

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
  final bool? canceled;

  /// The reason why loading was blocked, if any.
  final BlockedReason? blockedReason;

  /// The reason why loading was blocked by CORS, if any.
  final CorsErrorStatus? corsErrorStatus;

  LoadingFailedEvent(
      {required this.requestId,
      required this.timestamp,
      required this.type,
      required this.errorText,
      this.canceled,
      this.blockedReason,
      this.corsErrorStatus});

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
      corsErrorStatus: json.containsKey('corsErrorStatus')
          ? CorsErrorStatus.fromJson(
              json['corsErrorStatus'] as Map<String, dynamic>)
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
  final bool? shouldReportCorbBlocking;

  LoadingFinishedEvent(
      {required this.requestId,
      required this.timestamp,
      required this.encodedDataLength,
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
  final bool? isDownload;

  /// Redirect location, only sent if a redirect was intercepted.
  final String? redirectUrl;

  /// Details of the Authorization Challenge encountered. If this is set then
  /// continueInterceptedRequest must contain an authChallengeResponse.
  final AuthChallenge? authChallenge;

  /// Response error if intercepted at response stage or if redirect occurred while intercepting
  /// request.
  final ErrorReason? responseErrorReason;

  /// Response code if intercepted at response stage or if redirect occurred while intercepting
  /// request or auth retry occurred.
  final int? responseStatusCode;

  /// Response headers if intercepted at the response stage or if redirect occurred while
  /// intercepting request or auth retry occurred.
  final Headers? responseHeaders;

  /// If the intercepted request had a corresponding requestWillBeSent event fired for it, then
  /// this requestId will be the same as the requestId present in the requestWillBeSent event.
  final RequestId? requestId;

  RequestInterceptedEvent(
      {required this.interceptionId,
      required this.request,
      required this.frameId,
      required this.resourceType,
      required this.isNavigationRequest,
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
      isNavigationRequest: json['isNavigationRequest'] as bool? ?? false,
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

  /// In the case that redirectResponse is populated, this flag indicates whether
  /// requestWillBeSentExtraInfo and responseReceivedExtraInfo events will be or were emitted
  /// for the request which was just redirected.
  final bool redirectHasExtraInfo;

  /// Redirect response data.
  final ResponseData? redirectResponse;

  /// Type of this resource.
  final ResourceType? type;

  /// Frame identifier.
  final page.FrameId? frameId;

  /// Whether the request is initiated by a user gesture. Defaults to false.
  final bool? hasUserGesture;

  RequestWillBeSentEvent(
      {required this.requestId,
      required this.loaderId,
      required this.documentURL,
      required this.request,
      required this.timestamp,
      required this.wallTime,
      required this.initiator,
      required this.redirectHasExtraInfo,
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
      redirectHasExtraInfo: json['redirectHasExtraInfo'] as bool? ?? false,
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
      {required this.requestId,
      required this.newPriority,
      required this.timestamp});

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

  SignedExchangeReceivedEvent({required this.requestId, required this.info});

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

  /// Indicates whether requestWillBeSentExtraInfo and responseReceivedExtraInfo events will be
  /// or were emitted for this request.
  final bool hasExtraInfo;

  /// Frame identifier.
  final page.FrameId? frameId;

  ResponseReceivedEvent(
      {required this.requestId,
      required this.loaderId,
      required this.timestamp,
      required this.type,
      required this.response,
      required this.hasExtraInfo,
      this.frameId});

  factory ResponseReceivedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseReceivedEvent(
      requestId: RequestId.fromJson(json['requestId'] as String),
      loaderId: LoaderId.fromJson(json['loaderId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      type: ResourceType.fromJson(json['type'] as String),
      response: ResponseData.fromJson(json['response'] as Map<String, dynamic>),
      hasExtraInfo: json['hasExtraInfo'] as bool? ?? false,
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

  WebSocketClosedEvent({required this.requestId, required this.timestamp});

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
  final Initiator? initiator;

  WebSocketCreatedEvent(
      {required this.requestId, required this.url, this.initiator});

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
      {required this.requestId,
      required this.timestamp,
      required this.errorMessage});

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
      {required this.requestId,
      required this.timestamp,
      required this.response});

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
      {required this.requestId,
      required this.timestamp,
      required this.response});

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
      {required this.requestId,
      required this.timestamp,
      required this.response});

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
      {required this.requestId,
      required this.timestamp,
      required this.wallTime,
      required this.request});

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

class WebTransportCreatedEvent {
  /// WebTransport identifier.
  final RequestId transportId;

  /// WebTransport request URL.
  final String url;

  /// Timestamp.
  final MonotonicTime timestamp;

  /// Request initiator.
  final Initiator? initiator;

  WebTransportCreatedEvent(
      {required this.transportId,
      required this.url,
      required this.timestamp,
      this.initiator});

  factory WebTransportCreatedEvent.fromJson(Map<String, dynamic> json) {
    return WebTransportCreatedEvent(
      transportId: RequestId.fromJson(json['transportId'] as String),
      url: json['url'] as String,
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      initiator: json.containsKey('initiator')
          ? Initiator.fromJson(json['initiator'] as Map<String, dynamic>)
          : null,
    );
  }
}

class WebTransportConnectionEstablishedEvent {
  /// WebTransport identifier.
  final RequestId transportId;

  /// Timestamp.
  final MonotonicTime timestamp;

  WebTransportConnectionEstablishedEvent(
      {required this.transportId, required this.timestamp});

  factory WebTransportConnectionEstablishedEvent.fromJson(
      Map<String, dynamic> json) {
    return WebTransportConnectionEstablishedEvent(
      transportId: RequestId.fromJson(json['transportId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
    );
  }
}

class WebTransportClosedEvent {
  /// WebTransport identifier.
  final RequestId transportId;

  /// Timestamp.
  final MonotonicTime timestamp;

  WebTransportClosedEvent({required this.transportId, required this.timestamp});

  factory WebTransportClosedEvent.fromJson(Map<String, dynamic> json) {
    return WebTransportClosedEvent(
      transportId: RequestId.fromJson(json['transportId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
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

  /// Connection timing information for the request.
  final ConnectTiming connectTiming;

  /// The client security state set for the request.
  final ClientSecurityState? clientSecurityState;

  RequestWillBeSentExtraInfoEvent(
      {required this.requestId,
      required this.associatedCookies,
      required this.headers,
      required this.connectTiming,
      this.clientSecurityState});

  factory RequestWillBeSentExtraInfoEvent.fromJson(Map<String, dynamic> json) {
    return RequestWillBeSentExtraInfoEvent(
      requestId: RequestId.fromJson(json['requestId'] as String),
      associatedCookies: (json['associatedCookies'] as List)
          .map((e) =>
              BlockedCookieWithReason.fromJson(e as Map<String, dynamic>))
          .toList(),
      headers: Headers.fromJson(json['headers'] as Map<String, dynamic>),
      connectTiming:
          ConnectTiming.fromJson(json['connectTiming'] as Map<String, dynamic>),
      clientSecurityState: json.containsKey('clientSecurityState')
          ? ClientSecurityState.fromJson(
              json['clientSecurityState'] as Map<String, dynamic>)
          : null,
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

  /// The IP address space of the resource. The address space can only be determined once the transport
  /// established the connection, so we can't send it in `requestWillBeSentExtraInfo`.
  final IPAddressSpace resourceIPAddressSpace;

  /// The status code of the response. This is useful in cases the request failed and no responseReceived
  /// event is triggered, which is the case for, e.g., CORS errors. This is also the correct status code
  /// for cached requests, where the status in responseReceived is a 200 and this will be 304.
  final int statusCode;

  /// Raw response header text as it was received over the wire. The raw text may not always be
  /// available, such as in the case of HTTP/2 or QUIC.
  final String? headersText;

  ResponseReceivedExtraInfoEvent(
      {required this.requestId,
      required this.blockedCookies,
      required this.headers,
      required this.resourceIPAddressSpace,
      required this.statusCode,
      this.headersText});

  factory ResponseReceivedExtraInfoEvent.fromJson(Map<String, dynamic> json) {
    return ResponseReceivedExtraInfoEvent(
      requestId: RequestId.fromJson(json['requestId'] as String),
      blockedCookies: (json['blockedCookies'] as List)
          .map((e) =>
              BlockedSetCookieWithReason.fromJson(e as Map<String, dynamic>))
          .toList(),
      headers: Headers.fromJson(json['headers'] as Map<String, dynamic>),
      resourceIPAddressSpace:
          IPAddressSpace.fromJson(json['resourceIPAddressSpace'] as String),
      statusCode: json['statusCode'] as int,
      headersText: json.containsKey('headersText')
          ? json['headersText'] as String
          : null,
    );
  }
}

class TrustTokenOperationDoneEvent {
  /// Detailed success or error status of the operation.
  /// 'AlreadyExists' also signifies a successful operation, as the result
  /// of the operation already exists und thus, the operation was abort
  /// preemptively (e.g. a cache hit).
  final TrustTokenOperationDoneEventStatus status;

  final TrustTokenOperationType type;

  final RequestId requestId;

  /// Top level origin. The context in which the operation was attempted.
  final String? topLevelOrigin;

  /// Origin of the issuer in case of a "Issuance" or "Redemption" operation.
  final String? issuerOrigin;

  /// The number of obtained Trust Tokens on a successful "Issuance" operation.
  final int? issuedTokenCount;

  TrustTokenOperationDoneEvent(
      {required this.status,
      required this.type,
      required this.requestId,
      this.topLevelOrigin,
      this.issuerOrigin,
      this.issuedTokenCount});

  factory TrustTokenOperationDoneEvent.fromJson(Map<String, dynamic> json) {
    return TrustTokenOperationDoneEvent(
      status:
          TrustTokenOperationDoneEventStatus.fromJson(json['status'] as String),
      type: TrustTokenOperationType.fromJson(json['type'] as String),
      requestId: RequestId.fromJson(json['requestId'] as String),
      topLevelOrigin: json.containsKey('topLevelOrigin')
          ? json['topLevelOrigin'] as String
          : null,
      issuerOrigin: json.containsKey('issuerOrigin')
          ? json['issuerOrigin'] as String
          : null,
      issuedTokenCount: json.containsKey('issuedTokenCount')
          ? json['issuedTokenCount'] as int
          : null,
    );
  }
}

class SubresourceWebBundleMetadataReceivedEvent {
  /// Request identifier. Used to match this information to another event.
  final RequestId requestId;

  /// A list of URLs of resources in the subresource Web Bundle.
  final List<String> urls;

  SubresourceWebBundleMetadataReceivedEvent(
      {required this.requestId, required this.urls});

  factory SubresourceWebBundleMetadataReceivedEvent.fromJson(
      Map<String, dynamic> json) {
    return SubresourceWebBundleMetadataReceivedEvent(
      requestId: RequestId.fromJson(json['requestId'] as String),
      urls: (json['urls'] as List).map((e) => e as String).toList(),
    );
  }
}

class SubresourceWebBundleMetadataErrorEvent {
  /// Request identifier. Used to match this information to another event.
  final RequestId requestId;

  /// Error message
  final String errorMessage;

  SubresourceWebBundleMetadataErrorEvent(
      {required this.requestId, required this.errorMessage});

  factory SubresourceWebBundleMetadataErrorEvent.fromJson(
      Map<String, dynamic> json) {
    return SubresourceWebBundleMetadataErrorEvent(
      requestId: RequestId.fromJson(json['requestId'] as String),
      errorMessage: json['errorMessage'] as String,
    );
  }
}

class SubresourceWebBundleInnerResponseParsedEvent {
  /// Request identifier of the subresource request
  final RequestId innerRequestId;

  /// URL of the subresource resource.
  final String innerRequestURL;

  /// Bundle request identifier. Used to match this information to another event.
  /// This made be absent in case when the instrumentation was enabled only
  /// after webbundle was parsed.
  final RequestId? bundleRequestId;

  SubresourceWebBundleInnerResponseParsedEvent(
      {required this.innerRequestId,
      required this.innerRequestURL,
      this.bundleRequestId});

  factory SubresourceWebBundleInnerResponseParsedEvent.fromJson(
      Map<String, dynamic> json) {
    return SubresourceWebBundleInnerResponseParsedEvent(
      innerRequestId: RequestId.fromJson(json['innerRequestId'] as String),
      innerRequestURL: json['innerRequestURL'] as String,
      bundleRequestId: json.containsKey('bundleRequestId')
          ? RequestId.fromJson(json['bundleRequestId'] as String)
          : null,
    );
  }
}

class SubresourceWebBundleInnerResponseErrorEvent {
  /// Request identifier of the subresource request
  final RequestId innerRequestId;

  /// URL of the subresource resource.
  final String innerRequestURL;

  /// Error message
  final String errorMessage;

  /// Bundle request identifier. Used to match this information to another event.
  /// This made be absent in case when the instrumentation was enabled only
  /// after webbundle was parsed.
  final RequestId? bundleRequestId;

  SubresourceWebBundleInnerResponseErrorEvent(
      {required this.innerRequestId,
      required this.innerRequestURL,
      required this.errorMessage,
      this.bundleRequestId});

  factory SubresourceWebBundleInnerResponseErrorEvent.fromJson(
      Map<String, dynamic> json) {
    return SubresourceWebBundleInnerResponseErrorEvent(
      innerRequestId: RequestId.fromJson(json['innerRequestId'] as String),
      innerRequestURL: json['innerRequestURL'] as String,
      errorMessage: json['errorMessage'] as String,
      bundleRequestId: json.containsKey('bundleRequestId')
          ? RequestId.fromJson(json['bundleRequestId'] as String)
          : null,
    );
  }
}

class ReportingApiEndpointsChangedForOriginEvent {
  /// Origin of the document(s) which configured the endpoints.
  final String origin;

  final List<ReportingApiEndpoint> endpoints;

  ReportingApiEndpointsChangedForOriginEvent(
      {required this.origin, required this.endpoints});

  factory ReportingApiEndpointsChangedForOriginEvent.fromJson(
      Map<String, dynamic> json) {
    return ReportingApiEndpointsChangedForOriginEvent(
      origin: json['origin'] as String,
      endpoints: (json['endpoints'] as List)
          .map((e) => ReportingApiEndpoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GetResponseBodyResult {
  /// Response body.
  final String body;

  /// True, if content was sent as base64.
  final bool base64Encoded;

  GetResponseBodyResult({required this.body, required this.base64Encoded});

  factory GetResponseBodyResult.fromJson(Map<String, dynamic> json) {
    return GetResponseBodyResult(
      body: json['body'] as String,
      base64Encoded: json['base64Encoded'] as bool? ?? false,
    );
  }
}

class GetResponseBodyForInterceptionResult {
  /// Response body.
  final String body;

  /// True, if content was sent as base64.
  final bool base64Encoded;

  GetResponseBodyForInterceptionResult(
      {required this.body, required this.base64Encoded});

  factory GetResponseBodyForInterceptionResult.fromJson(
      Map<String, dynamic> json) {
    return GetResponseBodyForInterceptionResult(
      body: json['body'] as String,
      base64Encoded: json['base64Encoded'] as bool? ?? false,
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
  static const preflight = ResourceType._('Preflight');
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
    'Preflight': preflight,
    'Other': other,
  };

  final String value;

  const ResourceType._(this.value);

  factory ResourceType.fromJson(String value) => values[value]!;

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

  factory ErrorReason.fromJson(String value) => values[value]!;

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

  factory ConnectionType.fromJson(String value) => values[value]!;

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

  factory CookieSameSite.fromJson(String value) => values[value]!;

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

  factory CookiePriority.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CookiePriority && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Represents the source scheme of the origin that originally set the cookie.
/// A value of "Unset" allows protocol clients to emulate legacy cookie scope for the scheme.
/// This is a temporary ability and it will be removed in the future.
class CookieSourceScheme {
  static const unset = CookieSourceScheme._('Unset');
  static const nonSecure = CookieSourceScheme._('NonSecure');
  static const secure = CookieSourceScheme._('Secure');
  static const values = {
    'Unset': unset,
    'NonSecure': nonSecure,
    'Secure': secure,
  };

  final String value;

  const CookieSourceScheme._(this.value);

  factory CookieSourceScheme.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CookieSourceScheme && other.value == value) || value == other;

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

  /// Started fetch event.
  final num workerFetchStart;

  /// Settled fetch event respondWith promise.
  final num workerRespondWithSettled;

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
      {required this.requestTime,
      required this.proxyStart,
      required this.proxyEnd,
      required this.dnsStart,
      required this.dnsEnd,
      required this.connectStart,
      required this.connectEnd,
      required this.sslStart,
      required this.sslEnd,
      required this.workerStart,
      required this.workerReady,
      required this.workerFetchStart,
      required this.workerRespondWithSettled,
      required this.sendStart,
      required this.sendEnd,
      required this.pushStart,
      required this.pushEnd,
      required this.receiveHeadersEnd});

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
      workerFetchStart: json['workerFetchStart'] as num,
      workerRespondWithSettled: json['workerRespondWithSettled'] as num,
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
      'workerFetchStart': workerFetchStart,
      'workerRespondWithSettled': workerRespondWithSettled,
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

  factory ResourcePriority.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ResourcePriority && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Post data entry for HTTP request
class PostDataEntry {
  final String? bytes;

  PostDataEntry({this.bytes});

  factory PostDataEntry.fromJson(Map<String, dynamic> json) {
    return PostDataEntry(
      bytes: json.containsKey('bytes') ? json['bytes'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (bytes != null) 'bytes': bytes,
    };
  }
}

/// HTTP request data.
class RequestData {
  /// Request URL (without fragment).
  final String url;

  /// Fragment of the requested URL starting with hash, if present.
  final String? urlFragment;

  /// HTTP request method.
  final String method;

  /// HTTP request headers.
  final Headers headers;

  /// HTTP POST request data.
  final String? postData;

  /// True when the request has POST data. Note that postData might still be omitted when this flag is true when the data is too long.
  final bool? hasPostData;

  /// Request body elements. This will be converted from base64 to binary
  final List<PostDataEntry>? postDataEntries;

  /// The mixed content type of the request.
  final security.MixedContentType? mixedContentType;

  /// Priority of the resource request at the time request is sent.
  final ResourcePriority initialPriority;

  /// The referrer policy of the request, as defined in https://www.w3.org/TR/referrer-policy/
  final RequestReferrerPolicy referrerPolicy;

  /// Whether is loaded via link preload.
  final bool? isLinkPreload;

  /// Set for requests when the TrustToken API is used. Contains the parameters
  /// passed by the developer (e.g. via "fetch") as understood by the backend.
  final TrustTokenParams? trustTokenParams;

  /// True if this resource request is considered to be the 'same site' as the
  /// request correspondinfg to the main frame.
  final bool? isSameSite;

  RequestData(
      {required this.url,
      this.urlFragment,
      required this.method,
      required this.headers,
      this.postData,
      this.hasPostData,
      this.postDataEntries,
      this.mixedContentType,
      required this.initialPriority,
      required this.referrerPolicy,
      this.isLinkPreload,
      this.trustTokenParams,
      this.isSameSite});

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
      postDataEntries: json.containsKey('postDataEntries')
          ? (json['postDataEntries'] as List)
              .map((e) => PostDataEntry.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
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
      trustTokenParams: json.containsKey('trustTokenParams')
          ? TrustTokenParams.fromJson(
              json['trustTokenParams'] as Map<String, dynamic>)
          : null,
      isSameSite:
          json.containsKey('isSameSite') ? json['isSameSite'] as bool : null,
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
      if (postDataEntries != null)
        'postDataEntries': postDataEntries!.map((e) => e.toJson()).toList(),
      if (mixedContentType != null)
        'mixedContentType': mixedContentType!.toJson(),
      if (isLinkPreload != null) 'isLinkPreload': isLinkPreload,
      if (trustTokenParams != null)
        'trustTokenParams': trustTokenParams!.toJson(),
      if (isSameSite != null) 'isSameSite': isSameSite,
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

  factory RequestReferrerPolicy.fromJson(String value) => values[value]!;

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

  /// Issuance date. Unlike TimeSinceEpoch, this contains the number of
  /// milliseconds since January 1, 1970, UTC, not the number of seconds.
  final num timestamp;

  /// Hash algorithm.
  final String hashAlgorithm;

  /// Signature algorithm.
  final String signatureAlgorithm;

  /// Signature data.
  final String signatureData;

  SignedCertificateTimestamp(
      {required this.status,
      required this.origin,
      required this.logDescription,
      required this.logId,
      required this.timestamp,
      required this.hashAlgorithm,
      required this.signatureAlgorithm,
      required this.signatureData});

  factory SignedCertificateTimestamp.fromJson(Map<String, dynamic> json) {
    return SignedCertificateTimestamp(
      status: json['status'] as String,
      origin: json['origin'] as String,
      logDescription: json['logDescription'] as String,
      logId: json['logId'] as String,
      timestamp: json['timestamp'] as num,
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
      'timestamp': timestamp,
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
  final String? keyExchangeGroup;

  /// Cipher name.
  final String cipher;

  /// TLS MAC. Note that AEAD ciphers do not have separate MACs.
  final String? mac;

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
      {required this.protocol,
      required this.keyExchange,
      this.keyExchangeGroup,
      required this.cipher,
      this.mac,
      required this.certificateId,
      required this.subjectName,
      required this.sanList,
      required this.issuer,
      required this.validFrom,
      required this.validTo,
      required this.signedCertificateTimestampList,
      required this.certificateTransparencyCompliance});

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
      values[value]!;

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

  factory BlockedReason.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is BlockedReason && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// The reason why request was blocked.
class CorsError {
  static const disallowedByMode = CorsError._('DisallowedByMode');
  static const invalidResponse = CorsError._('InvalidResponse');
  static const wildcardOriginNotAllowed =
      CorsError._('WildcardOriginNotAllowed');
  static const missingAllowOriginHeader =
      CorsError._('MissingAllowOriginHeader');
  static const multipleAllowOriginValues =
      CorsError._('MultipleAllowOriginValues');
  static const invalidAllowOriginValue = CorsError._('InvalidAllowOriginValue');
  static const allowOriginMismatch = CorsError._('AllowOriginMismatch');
  static const invalidAllowCredentials = CorsError._('InvalidAllowCredentials');
  static const corsDisabledScheme = CorsError._('CorsDisabledScheme');
  static const preflightInvalidStatus = CorsError._('PreflightInvalidStatus');
  static const preflightDisallowedRedirect =
      CorsError._('PreflightDisallowedRedirect');
  static const preflightWildcardOriginNotAllowed =
      CorsError._('PreflightWildcardOriginNotAllowed');
  static const preflightMissingAllowOriginHeader =
      CorsError._('PreflightMissingAllowOriginHeader');
  static const preflightMultipleAllowOriginValues =
      CorsError._('PreflightMultipleAllowOriginValues');
  static const preflightInvalidAllowOriginValue =
      CorsError._('PreflightInvalidAllowOriginValue');
  static const preflightAllowOriginMismatch =
      CorsError._('PreflightAllowOriginMismatch');
  static const preflightInvalidAllowCredentials =
      CorsError._('PreflightInvalidAllowCredentials');
  static const preflightMissingAllowExternal =
      CorsError._('PreflightMissingAllowExternal');
  static const preflightInvalidAllowExternal =
      CorsError._('PreflightInvalidAllowExternal');
  static const preflightMissingAllowPrivateNetwork =
      CorsError._('PreflightMissingAllowPrivateNetwork');
  static const preflightInvalidAllowPrivateNetwork =
      CorsError._('PreflightInvalidAllowPrivateNetwork');
  static const invalidAllowMethodsPreflightResponse =
      CorsError._('InvalidAllowMethodsPreflightResponse');
  static const invalidAllowHeadersPreflightResponse =
      CorsError._('InvalidAllowHeadersPreflightResponse');
  static const methodDisallowedByPreflightResponse =
      CorsError._('MethodDisallowedByPreflightResponse');
  static const headerDisallowedByPreflightResponse =
      CorsError._('HeaderDisallowedByPreflightResponse');
  static const redirectContainsCredentials =
      CorsError._('RedirectContainsCredentials');
  static const insecurePrivateNetwork = CorsError._('InsecurePrivateNetwork');
  static const invalidPrivateNetworkAccess =
      CorsError._('InvalidPrivateNetworkAccess');
  static const unexpectedPrivateNetworkAccess =
      CorsError._('UnexpectedPrivateNetworkAccess');
  static const noCorsRedirectModeNotFollow =
      CorsError._('NoCorsRedirectModeNotFollow');
  static const values = {
    'DisallowedByMode': disallowedByMode,
    'InvalidResponse': invalidResponse,
    'WildcardOriginNotAllowed': wildcardOriginNotAllowed,
    'MissingAllowOriginHeader': missingAllowOriginHeader,
    'MultipleAllowOriginValues': multipleAllowOriginValues,
    'InvalidAllowOriginValue': invalidAllowOriginValue,
    'AllowOriginMismatch': allowOriginMismatch,
    'InvalidAllowCredentials': invalidAllowCredentials,
    'CorsDisabledScheme': corsDisabledScheme,
    'PreflightInvalidStatus': preflightInvalidStatus,
    'PreflightDisallowedRedirect': preflightDisallowedRedirect,
    'PreflightWildcardOriginNotAllowed': preflightWildcardOriginNotAllowed,
    'PreflightMissingAllowOriginHeader': preflightMissingAllowOriginHeader,
    'PreflightMultipleAllowOriginValues': preflightMultipleAllowOriginValues,
    'PreflightInvalidAllowOriginValue': preflightInvalidAllowOriginValue,
    'PreflightAllowOriginMismatch': preflightAllowOriginMismatch,
    'PreflightInvalidAllowCredentials': preflightInvalidAllowCredentials,
    'PreflightMissingAllowExternal': preflightMissingAllowExternal,
    'PreflightInvalidAllowExternal': preflightInvalidAllowExternal,
    'PreflightMissingAllowPrivateNetwork': preflightMissingAllowPrivateNetwork,
    'PreflightInvalidAllowPrivateNetwork': preflightInvalidAllowPrivateNetwork,
    'InvalidAllowMethodsPreflightResponse':
        invalidAllowMethodsPreflightResponse,
    'InvalidAllowHeadersPreflightResponse':
        invalidAllowHeadersPreflightResponse,
    'MethodDisallowedByPreflightResponse': methodDisallowedByPreflightResponse,
    'HeaderDisallowedByPreflightResponse': headerDisallowedByPreflightResponse,
    'RedirectContainsCredentials': redirectContainsCredentials,
    'InsecurePrivateNetwork': insecurePrivateNetwork,
    'InvalidPrivateNetworkAccess': invalidPrivateNetworkAccess,
    'UnexpectedPrivateNetworkAccess': unexpectedPrivateNetworkAccess,
    'NoCorsRedirectModeNotFollow': noCorsRedirectModeNotFollow,
  };

  final String value;

  const CorsError._(this.value);

  factory CorsError.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CorsError && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class CorsErrorStatus {
  final CorsError corsError;

  final String failedParameter;

  CorsErrorStatus({required this.corsError, required this.failedParameter});

  factory CorsErrorStatus.fromJson(Map<String, dynamic> json) {
    return CorsErrorStatus(
      corsError: CorsError.fromJson(json['corsError'] as String),
      failedParameter: json['failedParameter'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'corsError': corsError.toJson(),
      'failedParameter': failedParameter,
    };
  }
}

/// Source of serviceworker response.
class ServiceWorkerResponseSource {
  static const cacheStorage = ServiceWorkerResponseSource._('cache-storage');
  static const httpCache = ServiceWorkerResponseSource._('http-cache');
  static const fallbackCode = ServiceWorkerResponseSource._('fallback-code');
  static const network = ServiceWorkerResponseSource._('network');
  static const values = {
    'cache-storage': cacheStorage,
    'http-cache': httpCache,
    'fallback-code': fallbackCode,
    'network': network,
  };

  final String value;

  const ServiceWorkerResponseSource._(this.value);

  factory ServiceWorkerResponseSource.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ServiceWorkerResponseSource && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Determines what type of Trust Token operation is executed and
/// depending on the type, some additional parameters. The values
/// are specified in third_party/blink/renderer/core/fetch/trust_token.idl.
class TrustTokenParams {
  final TrustTokenOperationType type;

  /// Only set for "token-redemption" type and determine whether
  /// to request a fresh SRR or use a still valid cached SRR.
  final TrustTokenParamsRefreshPolicy refreshPolicy;

  /// Origins of issuers from whom to request tokens or redemption
  /// records.
  final List<String>? issuers;

  TrustTokenParams(
      {required this.type, required this.refreshPolicy, this.issuers});

  factory TrustTokenParams.fromJson(Map<String, dynamic> json) {
    return TrustTokenParams(
      type: TrustTokenOperationType.fromJson(json['type'] as String),
      refreshPolicy: TrustTokenParamsRefreshPolicy.fromJson(
          json['refreshPolicy'] as String),
      issuers: json.containsKey('issuers')
          ? (json['issuers'] as List).map((e) => e as String).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      'refreshPolicy': refreshPolicy,
      if (issuers != null) 'issuers': [...?issuers],
    };
  }
}

class TrustTokenParamsRefreshPolicy {
  static const useCached = TrustTokenParamsRefreshPolicy._('UseCached');
  static const refresh = TrustTokenParamsRefreshPolicy._('Refresh');
  static const values = {
    'UseCached': useCached,
    'Refresh': refresh,
  };

  final String value;

  const TrustTokenParamsRefreshPolicy._(this.value);

  factory TrustTokenParamsRefreshPolicy.fromJson(String value) =>
      values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is TrustTokenParamsRefreshPolicy && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class TrustTokenOperationType {
  static const issuance = TrustTokenOperationType._('Issuance');
  static const redemption = TrustTokenOperationType._('Redemption');
  static const signing = TrustTokenOperationType._('Signing');
  static const values = {
    'Issuance': issuance,
    'Redemption': redemption,
    'Signing': signing,
  };

  final String value;

  const TrustTokenOperationType._(this.value);

  factory TrustTokenOperationType.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is TrustTokenOperationType && other.value == value) ||
      value == other;

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

  /// Resource mimeType as determined by the browser.
  final String mimeType;

  /// Refined HTTP request headers that were actually transmitted over the network.
  final Headers? requestHeaders;

  /// Specifies whether physical connection was actually reused for this request.
  final bool connectionReused;

  /// Physical connection id that was actually used for this request.
  final num connectionId;

  /// Remote IP address.
  final String? remoteIPAddress;

  /// Remote port.
  final int? remotePort;

  /// Specifies that the request was served from the disk cache.
  final bool? fromDiskCache;

  /// Specifies that the request was served from the ServiceWorker.
  final bool? fromServiceWorker;

  /// Specifies that the request was served from the prefetch cache.
  final bool? fromPrefetchCache;

  /// Total number of bytes received for this request so far.
  final num encodedDataLength;

  /// Timing information for the given request.
  final ResourceTiming? timing;

  /// Response source of response from ServiceWorker.
  final ServiceWorkerResponseSource? serviceWorkerResponseSource;

  /// The time at which the returned response was generated.
  final TimeSinceEpoch? responseTime;

  /// Cache Storage Cache Name.
  final String? cacheStorageCacheName;

  /// Protocol used to fetch this request.
  final String? protocol;

  /// Security state of the request resource.
  final security.SecurityState securityState;

  /// Security details for the request.
  final SecurityDetails? securityDetails;

  ResponseData(
      {required this.url,
      required this.status,
      required this.statusText,
      required this.headers,
      required this.mimeType,
      this.requestHeaders,
      required this.connectionReused,
      required this.connectionId,
      this.remoteIPAddress,
      this.remotePort,
      this.fromDiskCache,
      this.fromServiceWorker,
      this.fromPrefetchCache,
      required this.encodedDataLength,
      this.timing,
      this.serviceWorkerResponseSource,
      this.responseTime,
      this.cacheStorageCacheName,
      this.protocol,
      required this.securityState,
      this.securityDetails});

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      url: json['url'] as String,
      status: json['status'] as int,
      statusText: json['statusText'] as String,
      headers: Headers.fromJson(json['headers'] as Map<String, dynamic>),
      mimeType: json['mimeType'] as String,
      requestHeaders: json.containsKey('requestHeaders')
          ? Headers.fromJson(json['requestHeaders'] as Map<String, dynamic>)
          : null,
      connectionReused: json['connectionReused'] as bool? ?? false,
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
      serviceWorkerResponseSource:
          json.containsKey('serviceWorkerResponseSource')
              ? ServiceWorkerResponseSource.fromJson(
                  json['serviceWorkerResponseSource'] as String)
              : null,
      responseTime: json.containsKey('responseTime')
          ? TimeSinceEpoch.fromJson(json['responseTime'] as num)
          : null,
      cacheStorageCacheName: json.containsKey('cacheStorageCacheName')
          ? json['cacheStorageCacheName'] as String
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
      if (requestHeaders != null) 'requestHeaders': requestHeaders!.toJson(),
      if (remoteIPAddress != null) 'remoteIPAddress': remoteIPAddress,
      if (remotePort != null) 'remotePort': remotePort,
      if (fromDiskCache != null) 'fromDiskCache': fromDiskCache,
      if (fromServiceWorker != null) 'fromServiceWorker': fromServiceWorker,
      if (fromPrefetchCache != null) 'fromPrefetchCache': fromPrefetchCache,
      if (timing != null) 'timing': timing!.toJson(),
      if (serviceWorkerResponseSource != null)
        'serviceWorkerResponseSource': serviceWorkerResponseSource!.toJson(),
      if (responseTime != null) 'responseTime': responseTime!.toJson(),
      if (cacheStorageCacheName != null)
        'cacheStorageCacheName': cacheStorageCacheName,
      if (protocol != null) 'protocol': protocol,
      if (securityDetails != null) 'securityDetails': securityDetails!.toJson(),
    };
  }
}

/// WebSocket request data.
class WebSocketRequest {
  /// HTTP request headers.
  final Headers headers;

  WebSocketRequest({required this.headers});

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
  final String? headersText;

  /// HTTP request headers.
  final Headers? requestHeaders;

  /// HTTP request headers text.
  final String? requestHeadersText;

  WebSocketResponse(
      {required this.status,
      required this.statusText,
      required this.headers,
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
      if (requestHeaders != null) 'requestHeaders': requestHeaders!.toJson(),
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
      {required this.opcode, required this.mask, required this.payloadData});

  factory WebSocketFrame.fromJson(Map<String, dynamic> json) {
    return WebSocketFrame(
      opcode: json['opcode'] as num,
      mask: json['mask'] as bool? ?? false,
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
  final ResponseData? response;

  /// Cached response body size.
  final num bodySize;

  CachedResource(
      {required this.url,
      required this.type,
      this.response,
      required this.bodySize});

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
      if (response != null) 'response': response!.toJson(),
    };
  }
}

/// Information about the request initiator.
class Initiator {
  /// Type of this initiator.
  final InitiatorType type;

  /// Initiator JavaScript stack trace, set for Script only.
  final runtime.StackTraceData? stack;

  /// Initiator URL, set for Parser type or for Script type (when script is importing module) or for SignedExchange type.
  final String? url;

  /// Initiator line number, set for Parser type or for Script type (when script is importing
  /// module) (0-based).
  final num? lineNumber;

  /// Initiator column number, set for Parser type or for Script type (when script is importing
  /// module) (0-based).
  final num? columnNumber;

  /// Set if another request triggered this request (e.g. preflight).
  final RequestId? requestId;

  Initiator(
      {required this.type,
      this.stack,
      this.url,
      this.lineNumber,
      this.columnNumber,
      this.requestId});

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
      columnNumber:
          json.containsKey('columnNumber') ? json['columnNumber'] as num : null,
      requestId: json.containsKey('requestId')
          ? RequestId.fromJson(json['requestId'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (stack != null) 'stack': stack!.toJson(),
      if (url != null) 'url': url,
      if (lineNumber != null) 'lineNumber': lineNumber,
      if (columnNumber != null) 'columnNumber': columnNumber,
      if (requestId != null) 'requestId': requestId!.toJson(),
    };
  }
}

class InitiatorType {
  static const parser = InitiatorType._('parser');
  static const script = InitiatorType._('script');
  static const preload = InitiatorType._('preload');
  static const signedExchange = InitiatorType._('SignedExchange');
  static const preflight = InitiatorType._('preflight');
  static const other = InitiatorType._('other');
  static const values = {
    'parser': parser,
    'script': script,
    'preload': preload,
    'SignedExchange': signedExchange,
    'preflight': preflight,
    'other': other,
  };

  final String value;

  const InitiatorType._(this.value);

  factory InitiatorType.fromJson(String value) => values[value]!;

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
  final CookieSameSite? sameSite;

  /// Cookie Priority
  final CookiePriority priority;

  /// True if cookie is SameParty.
  final bool sameParty;

  /// Cookie source scheme type.
  final CookieSourceScheme sourceScheme;

  /// Cookie source port. Valid values are {-1, [1, 65535]}, -1 indicates an unspecified port.
  /// An unspecified port value allows protocol clients to emulate legacy cookie scope for the port.
  /// This is a temporary ability and it will be removed in the future.
  final int sourcePort;

  /// Cookie partition key. The site of the top-level URL the browser was visiting at the start
  /// of the request to the endpoint that set the cookie.
  final String? partitionKey;

  /// True if cookie partition key is opaque.
  final bool? partitionKeyOpaque;

  Cookie(
      {required this.name,
      required this.value,
      required this.domain,
      required this.path,
      required this.expires,
      required this.size,
      required this.httpOnly,
      required this.secure,
      required this.session,
      this.sameSite,
      required this.priority,
      required this.sameParty,
      required this.sourceScheme,
      required this.sourcePort,
      this.partitionKey,
      this.partitionKeyOpaque});

  factory Cookie.fromJson(Map<String, dynamic> json) {
    return Cookie(
      name: json['name'] as String,
      value: json['value'] as String,
      domain: json['domain'] as String,
      path: json['path'] as String,
      expires: json['expires'] as num,
      size: json['size'] as int,
      httpOnly: json['httpOnly'] as bool? ?? false,
      secure: json['secure'] as bool? ?? false,
      session: json['session'] as bool? ?? false,
      sameSite: json.containsKey('sameSite')
          ? CookieSameSite.fromJson(json['sameSite'] as String)
          : null,
      priority: CookiePriority.fromJson(json['priority'] as String),
      sameParty: json['sameParty'] as bool? ?? false,
      sourceScheme: CookieSourceScheme.fromJson(json['sourceScheme'] as String),
      sourcePort: json['sourcePort'] as int,
      partitionKey: json.containsKey('partitionKey')
          ? json['partitionKey'] as String
          : null,
      partitionKeyOpaque: json.containsKey('partitionKeyOpaque')
          ? json['partitionKeyOpaque'] as bool
          : null,
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
      'sameParty': sameParty,
      'sourceScheme': sourceScheme.toJson(),
      'sourcePort': sourcePort,
      if (sameSite != null) 'sameSite': sameSite!.toJson(),
      if (partitionKey != null) 'partitionKey': partitionKey,
      if (partitionKeyOpaque != null) 'partitionKeyOpaque': partitionKeyOpaque,
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
  static const schemefulSameSiteStrict =
      SetCookieBlockedReason._('SchemefulSameSiteStrict');
  static const schemefulSameSiteLax =
      SetCookieBlockedReason._('SchemefulSameSiteLax');
  static const schemefulSameSiteUnspecifiedTreatedAsLax =
      SetCookieBlockedReason._('SchemefulSameSiteUnspecifiedTreatedAsLax');
  static const samePartyFromCrossPartyContext =
      SetCookieBlockedReason._('SamePartyFromCrossPartyContext');
  static const samePartyConflictsWithOtherAttributes =
      SetCookieBlockedReason._('SamePartyConflictsWithOtherAttributes');
  static const nameValuePairExceedsMaxSize =
      SetCookieBlockedReason._('NameValuePairExceedsMaxSize');
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
    'SchemefulSameSiteStrict': schemefulSameSiteStrict,
    'SchemefulSameSiteLax': schemefulSameSiteLax,
    'SchemefulSameSiteUnspecifiedTreatedAsLax':
        schemefulSameSiteUnspecifiedTreatedAsLax,
    'SamePartyFromCrossPartyContext': samePartyFromCrossPartyContext,
    'SamePartyConflictsWithOtherAttributes':
        samePartyConflictsWithOtherAttributes,
    'NameValuePairExceedsMaxSize': nameValuePairExceedsMaxSize,
  };

  final String value;

  const SetCookieBlockedReason._(this.value);

  factory SetCookieBlockedReason.fromJson(String value) => values[value]!;

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
  static const schemefulSameSiteStrict =
      CookieBlockedReason._('SchemefulSameSiteStrict');
  static const schemefulSameSiteLax =
      CookieBlockedReason._('SchemefulSameSiteLax');
  static const schemefulSameSiteUnspecifiedTreatedAsLax =
      CookieBlockedReason._('SchemefulSameSiteUnspecifiedTreatedAsLax');
  static const samePartyFromCrossPartyContext =
      CookieBlockedReason._('SamePartyFromCrossPartyContext');
  static const nameValuePairExceedsMaxSize =
      CookieBlockedReason._('NameValuePairExceedsMaxSize');
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
    'SchemefulSameSiteStrict': schemefulSameSiteStrict,
    'SchemefulSameSiteLax': schemefulSameSiteLax,
    'SchemefulSameSiteUnspecifiedTreatedAsLax':
        schemefulSameSiteUnspecifiedTreatedAsLax,
    'SamePartyFromCrossPartyContext': samePartyFromCrossPartyContext,
    'NameValuePairExceedsMaxSize': nameValuePairExceedsMaxSize,
  };

  final String value;

  const CookieBlockedReason._(this.value);

  factory CookieBlockedReason.fromJson(String value) => values[value]!;

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
  final Cookie? cookie;

  BlockedSetCookieWithReason(
      {required this.blockedReasons, required this.cookieLine, this.cookie});

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
      if (cookie != null) 'cookie': cookie!.toJson(),
    };
  }
}

/// A cookie with was not sent with a request with the corresponding reason.
class BlockedCookieWithReason {
  /// The reason(s) the cookie was blocked.
  final List<CookieBlockedReason> blockedReasons;

  /// The cookie object representing the cookie which was not sent.
  final Cookie cookie;

  BlockedCookieWithReason({required this.blockedReasons, required this.cookie});

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
  /// default domain, path, source port, and source scheme values of the created cookie.
  final String? url;

  /// Cookie domain.
  final String? domain;

  /// Cookie path.
  final String? path;

  /// True if cookie is secure.
  final bool? secure;

  /// True if cookie is http-only.
  final bool? httpOnly;

  /// Cookie SameSite type.
  final CookieSameSite? sameSite;

  /// Cookie expiration date, session cookie if not set
  final TimeSinceEpoch? expires;

  /// Cookie Priority.
  final CookiePriority? priority;

  /// True if cookie is SameParty.
  final bool? sameParty;

  /// Cookie source scheme type.
  final CookieSourceScheme? sourceScheme;

  /// Cookie source port. Valid values are {-1, [1, 65535]}, -1 indicates an unspecified port.
  /// An unspecified port value allows protocol clients to emulate legacy cookie scope for the port.
  /// This is a temporary ability and it will be removed in the future.
  final int? sourcePort;

  /// Cookie partition key. The site of the top-level URL the browser was visiting at the start
  /// of the request to the endpoint that set the cookie.
  /// If not set, the cookie will be set as not partitioned.
  final String? partitionKey;

  CookieParam(
      {required this.name,
      required this.value,
      this.url,
      this.domain,
      this.path,
      this.secure,
      this.httpOnly,
      this.sameSite,
      this.expires,
      this.priority,
      this.sameParty,
      this.sourceScheme,
      this.sourcePort,
      this.partitionKey});

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
      sameParty:
          json.containsKey('sameParty') ? json['sameParty'] as bool : null,
      sourceScheme: json.containsKey('sourceScheme')
          ? CookieSourceScheme.fromJson(json['sourceScheme'] as String)
          : null,
      sourcePort:
          json.containsKey('sourcePort') ? json['sourcePort'] as int : null,
      partitionKey: json.containsKey('partitionKey')
          ? json['partitionKey'] as String
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
      if (sameSite != null) 'sameSite': sameSite!.toJson(),
      if (expires != null) 'expires': expires!.toJson(),
      if (priority != null) 'priority': priority!.toJson(),
      if (sameParty != null) 'sameParty': sameParty,
      if (sourceScheme != null) 'sourceScheme': sourceScheme!.toJson(),
      if (sourcePort != null) 'sourcePort': sourcePort,
      if (partitionKey != null) 'partitionKey': partitionKey,
    };
  }
}

/// Authorization challenge for HTTP status code 401 or 407.
class AuthChallenge {
  /// Source of the authentication challenge.
  final AuthChallengeSource? source;

  /// Origin of the challenger.
  final String origin;

  /// The authentication scheme used, such as basic or digest
  final String scheme;

  /// The realm of the challenge. May be empty.
  final String realm;

  AuthChallenge(
      {this.source,
      required this.origin,
      required this.scheme,
      required this.realm});

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

  factory AuthChallengeSource.fromJson(String value) => values[value]!;

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
  final String? username;

  /// The password to provide, possibly empty. Should only be set if response is
  /// ProvideCredentials.
  final String? password;

  AuthChallengeResponse({required this.response, this.username, this.password});

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

  factory AuthChallengeResponseResponse.fromJson(String value) =>
      values[value]!;

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

  factory InterceptionStage.fromJson(String value) => values[value]!;

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
  /// Wildcards (`'*'` -> zero or more, `'?'` -> exactly one) are allowed. Escape character is
  /// backslash. Omitting is equivalent to `"*"`.
  final String? urlPattern;

  /// If set, only requests for matching resource types will be intercepted.
  final ResourceType? resourceType;

  /// Stage at which to begin intercepting requests. Default is Request.
  final InterceptionStage? interceptionStage;

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
      if (resourceType != null) 'resourceType': resourceType!.toJson(),
      if (interceptionStage != null)
        'interceptionStage': interceptionStage!.toJson(),
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
  final String? certUrl;

  /// The hex string of signed exchange signature cert sha256.
  final String? certSha256;

  /// Signed exchange signature validity Url.
  final String validityUrl;

  /// Signed exchange signature date.
  final int date;

  /// Signed exchange signature expires.
  final int expires;

  /// The encoded certificates.
  final List<String>? certificates;

  SignedExchangeSignature(
      {required this.label,
      required this.signature,
      required this.integrity,
      this.certUrl,
      this.certSha256,
      required this.validityUrl,
      required this.date,
      required this.expires,
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
      if (certificates != null) 'certificates': [...?certificates],
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
      {required this.requestUrl,
      required this.responseCode,
      required this.responseHeaders,
      required this.signatures,
      required this.headerIntegrity});

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

  factory SignedExchangeErrorField.fromJson(String value) => values[value]!;

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
  final int? signatureIndex;

  /// The field which caused the error.
  final SignedExchangeErrorField? errorField;

  SignedExchangeError(
      {required this.message, this.signatureIndex, this.errorField});

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
      if (errorField != null) 'errorField': errorField!.toJson(),
    };
  }
}

/// Information about a signed exchange response.
class SignedExchangeInfo {
  /// The outer response of signed HTTP exchange which was received from network.
  final ResponseData outerResponse;

  /// Information about the signed exchange header.
  final SignedExchangeHeader? header;

  /// Security details for the signed exchange header.
  final SecurityDetails? securityDetails;

  /// Errors occurred while handling the signed exchagne.
  final List<SignedExchangeError>? errors;

  SignedExchangeInfo(
      {required this.outerResponse,
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
      if (header != null) 'header': header!.toJson(),
      if (securityDetails != null) 'securityDetails': securityDetails!.toJson(),
      if (errors != null) 'errors': errors!.map((e) => e.toJson()).toList(),
    };
  }
}

/// List of content encodings supported by the backend.
class ContentEncoding {
  static const deflate = ContentEncoding._('deflate');
  static const gzip = ContentEncoding._('gzip');
  static const br = ContentEncoding._('br');
  static const values = {
    'deflate': deflate,
    'gzip': gzip,
    'br': br,
  };

  final String value;

  const ContentEncoding._(this.value);

  factory ContentEncoding.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ContentEncoding && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class PrivateNetworkRequestPolicy {
  static const allow = PrivateNetworkRequestPolicy._('Allow');
  static const blockFromInsecureToMorePrivate =
      PrivateNetworkRequestPolicy._('BlockFromInsecureToMorePrivate');
  static const warnFromInsecureToMorePrivate =
      PrivateNetworkRequestPolicy._('WarnFromInsecureToMorePrivate');
  static const preflightBlock = PrivateNetworkRequestPolicy._('PreflightBlock');
  static const preflightWarn = PrivateNetworkRequestPolicy._('PreflightWarn');
  static const values = {
    'Allow': allow,
    'BlockFromInsecureToMorePrivate': blockFromInsecureToMorePrivate,
    'WarnFromInsecureToMorePrivate': warnFromInsecureToMorePrivate,
    'PreflightBlock': preflightBlock,
    'PreflightWarn': preflightWarn,
  };

  final String value;

  const PrivateNetworkRequestPolicy._(this.value);

  factory PrivateNetworkRequestPolicy.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is PrivateNetworkRequestPolicy && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class IPAddressSpace {
  static const local = IPAddressSpace._('Local');
  static const private = IPAddressSpace._('Private');
  static const public = IPAddressSpace._('Public');
  static const unknown = IPAddressSpace._('Unknown');
  static const values = {
    'Local': local,
    'Private': private,
    'Public': public,
    'Unknown': unknown,
  };

  final String value;

  const IPAddressSpace._(this.value);

  factory IPAddressSpace.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is IPAddressSpace && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class ConnectTiming {
  /// Timing's requestTime is a baseline in seconds, while the other numbers are ticks in
  /// milliseconds relatively to this requestTime. Matches ResourceTiming's requestTime for
  /// the same request (but not for redirected requests).
  final num requestTime;

  ConnectTiming({required this.requestTime});

  factory ConnectTiming.fromJson(Map<String, dynamic> json) {
    return ConnectTiming(
      requestTime: json['requestTime'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestTime': requestTime,
    };
  }
}

class ClientSecurityState {
  final bool initiatorIsSecureContext;

  final IPAddressSpace initiatorIPAddressSpace;

  final PrivateNetworkRequestPolicy privateNetworkRequestPolicy;

  ClientSecurityState(
      {required this.initiatorIsSecureContext,
      required this.initiatorIPAddressSpace,
      required this.privateNetworkRequestPolicy});

  factory ClientSecurityState.fromJson(Map<String, dynamic> json) {
    return ClientSecurityState(
      initiatorIsSecureContext:
          json['initiatorIsSecureContext'] as bool? ?? false,
      initiatorIPAddressSpace:
          IPAddressSpace.fromJson(json['initiatorIPAddressSpace'] as String),
      privateNetworkRequestPolicy: PrivateNetworkRequestPolicy.fromJson(
          json['privateNetworkRequestPolicy'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'initiatorIsSecureContext': initiatorIsSecureContext,
      'initiatorIPAddressSpace': initiatorIPAddressSpace.toJson(),
      'privateNetworkRequestPolicy': privateNetworkRequestPolicy.toJson(),
    };
  }
}

class CrossOriginOpenerPolicyValue {
  static const sameOrigin = CrossOriginOpenerPolicyValue._('SameOrigin');
  static const sameOriginAllowPopups =
      CrossOriginOpenerPolicyValue._('SameOriginAllowPopups');
  static const unsafeNone = CrossOriginOpenerPolicyValue._('UnsafeNone');
  static const sameOriginPlusCoep =
      CrossOriginOpenerPolicyValue._('SameOriginPlusCoep');
  static const sameOriginAllowPopupsPlusCoep =
      CrossOriginOpenerPolicyValue._('SameOriginAllowPopupsPlusCoep');
  static const values = {
    'SameOrigin': sameOrigin,
    'SameOriginAllowPopups': sameOriginAllowPopups,
    'UnsafeNone': unsafeNone,
    'SameOriginPlusCoep': sameOriginPlusCoep,
    'SameOriginAllowPopupsPlusCoep': sameOriginAllowPopupsPlusCoep,
  };

  final String value;

  const CrossOriginOpenerPolicyValue._(this.value);

  factory CrossOriginOpenerPolicyValue.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CrossOriginOpenerPolicyValue && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class CrossOriginOpenerPolicyStatus {
  final CrossOriginOpenerPolicyValue value;

  final CrossOriginOpenerPolicyValue reportOnlyValue;

  final String? reportingEndpoint;

  final String? reportOnlyReportingEndpoint;

  CrossOriginOpenerPolicyStatus(
      {required this.value,
      required this.reportOnlyValue,
      this.reportingEndpoint,
      this.reportOnlyReportingEndpoint});

  factory CrossOriginOpenerPolicyStatus.fromJson(Map<String, dynamic> json) {
    return CrossOriginOpenerPolicyStatus(
      value: CrossOriginOpenerPolicyValue.fromJson(json['value'] as String),
      reportOnlyValue: CrossOriginOpenerPolicyValue.fromJson(
          json['reportOnlyValue'] as String),
      reportingEndpoint: json.containsKey('reportingEndpoint')
          ? json['reportingEndpoint'] as String
          : null,
      reportOnlyReportingEndpoint:
          json.containsKey('reportOnlyReportingEndpoint')
              ? json['reportOnlyReportingEndpoint'] as String
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value.toJson(),
      'reportOnlyValue': reportOnlyValue.toJson(),
      if (reportingEndpoint != null) 'reportingEndpoint': reportingEndpoint,
      if (reportOnlyReportingEndpoint != null)
        'reportOnlyReportingEndpoint': reportOnlyReportingEndpoint,
    };
  }
}

class CrossOriginEmbedderPolicyValue {
  static const none = CrossOriginEmbedderPolicyValue._('None');
  static const credentialless =
      CrossOriginEmbedderPolicyValue._('Credentialless');
  static const requireCorp = CrossOriginEmbedderPolicyValue._('RequireCorp');
  static const values = {
    'None': none,
    'Credentialless': credentialless,
    'RequireCorp': requireCorp,
  };

  final String value;

  const CrossOriginEmbedderPolicyValue._(this.value);

  factory CrossOriginEmbedderPolicyValue.fromJson(String value) =>
      values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CrossOriginEmbedderPolicyValue && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class CrossOriginEmbedderPolicyStatus {
  final CrossOriginEmbedderPolicyValue value;

  final CrossOriginEmbedderPolicyValue reportOnlyValue;

  final String? reportingEndpoint;

  final String? reportOnlyReportingEndpoint;

  CrossOriginEmbedderPolicyStatus(
      {required this.value,
      required this.reportOnlyValue,
      this.reportingEndpoint,
      this.reportOnlyReportingEndpoint});

  factory CrossOriginEmbedderPolicyStatus.fromJson(Map<String, dynamic> json) {
    return CrossOriginEmbedderPolicyStatus(
      value: CrossOriginEmbedderPolicyValue.fromJson(json['value'] as String),
      reportOnlyValue: CrossOriginEmbedderPolicyValue.fromJson(
          json['reportOnlyValue'] as String),
      reportingEndpoint: json.containsKey('reportingEndpoint')
          ? json['reportingEndpoint'] as String
          : null,
      reportOnlyReportingEndpoint:
          json.containsKey('reportOnlyReportingEndpoint')
              ? json['reportOnlyReportingEndpoint'] as String
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value.toJson(),
      'reportOnlyValue': reportOnlyValue.toJson(),
      if (reportingEndpoint != null) 'reportingEndpoint': reportingEndpoint,
      if (reportOnlyReportingEndpoint != null)
        'reportOnlyReportingEndpoint': reportOnlyReportingEndpoint,
    };
  }
}

class SecurityIsolationStatus {
  final CrossOriginOpenerPolicyStatus? coop;

  final CrossOriginEmbedderPolicyStatus? coep;

  SecurityIsolationStatus({this.coop, this.coep});

  factory SecurityIsolationStatus.fromJson(Map<String, dynamic> json) {
    return SecurityIsolationStatus(
      coop: json.containsKey('coop')
          ? CrossOriginOpenerPolicyStatus.fromJson(
              json['coop'] as Map<String, dynamic>)
          : null,
      coep: json.containsKey('coep')
          ? CrossOriginEmbedderPolicyStatus.fromJson(
              json['coep'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (coop != null) 'coop': coop!.toJson(),
      if (coep != null) 'coep': coep!.toJson(),
    };
  }
}

/// The status of a Reporting API report.
class ReportStatus {
  static const queued = ReportStatus._('Queued');
  static const pending = ReportStatus._('Pending');
  static const markedForRemoval = ReportStatus._('MarkedForRemoval');
  static const success = ReportStatus._('Success');
  static const values = {
    'Queued': queued,
    'Pending': pending,
    'MarkedForRemoval': markedForRemoval,
    'Success': success,
  };

  final String value;

  const ReportStatus._(this.value);

  factory ReportStatus.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ReportStatus && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class ReportId {
  final String value;

  ReportId(this.value);

  factory ReportId.fromJson(String value) => ReportId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ReportId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// An object representing a report generated by the Reporting API.
class ReportingApiReport {
  final ReportId id;

  /// The URL of the document that triggered the report.
  final String initiatorUrl;

  /// The name of the endpoint group that should be used to deliver the report.
  final String destination;

  /// The type of the report (specifies the set of data that is contained in the report body).
  final String type;

  /// When the report was generated.
  final network.TimeSinceEpoch timestamp;

  /// How many uploads deep the related request was.
  final int depth;

  /// The number of delivery attempts made so far, not including an active attempt.
  final int completedAttempts;

  final Map<String, dynamic> body;

  final ReportStatus status;

  ReportingApiReport(
      {required this.id,
      required this.initiatorUrl,
      required this.destination,
      required this.type,
      required this.timestamp,
      required this.depth,
      required this.completedAttempts,
      required this.body,
      required this.status});

  factory ReportingApiReport.fromJson(Map<String, dynamic> json) {
    return ReportingApiReport(
      id: ReportId.fromJson(json['id'] as String),
      initiatorUrl: json['initiatorUrl'] as String,
      destination: json['destination'] as String,
      type: json['type'] as String,
      timestamp: network.TimeSinceEpoch.fromJson(json['timestamp'] as num),
      depth: json['depth'] as int,
      completedAttempts: json['completedAttempts'] as int,
      body: json['body'] as Map<String, dynamic>,
      status: ReportStatus.fromJson(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toJson(),
      'initiatorUrl': initiatorUrl,
      'destination': destination,
      'type': type,
      'timestamp': timestamp.toJson(),
      'depth': depth,
      'completedAttempts': completedAttempts,
      'body': body,
      'status': status.toJson(),
    };
  }
}

class ReportingApiEndpoint {
  /// The URL of the endpoint to which reports may be delivered.
  final String url;

  /// Name of the endpoint group.
  final String groupName;

  ReportingApiEndpoint({required this.url, required this.groupName});

  factory ReportingApiEndpoint.fromJson(Map<String, dynamic> json) {
    return ReportingApiEndpoint(
      url: json['url'] as String,
      groupName: json['groupName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'groupName': groupName,
    };
  }
}

/// An object providing the result of a network resource load.
class LoadNetworkResourcePageResult {
  final bool success;

  /// Optional values used for error reporting.
  final num? netError;

  final String? netErrorName;

  final num? httpStatusCode;

  /// If successful, one of the following two fields holds the result.
  final io.StreamHandle? stream;

  /// Response headers.
  final network.Headers? headers;

  LoadNetworkResourcePageResult(
      {required this.success,
      this.netError,
      this.netErrorName,
      this.httpStatusCode,
      this.stream,
      this.headers});

  factory LoadNetworkResourcePageResult.fromJson(Map<String, dynamic> json) {
    return LoadNetworkResourcePageResult(
      success: json['success'] as bool? ?? false,
      netError: json.containsKey('netError') ? json['netError'] as num : null,
      netErrorName: json.containsKey('netErrorName')
          ? json['netErrorName'] as String
          : null,
      httpStatusCode: json.containsKey('httpStatusCode')
          ? json['httpStatusCode'] as num
          : null,
      stream: json.containsKey('stream')
          ? io.StreamHandle.fromJson(json['stream'] as String)
          : null,
      headers: json.containsKey('headers')
          ? network.Headers.fromJson(json['headers'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (netError != null) 'netError': netError,
      if (netErrorName != null) 'netErrorName': netErrorName,
      if (httpStatusCode != null) 'httpStatusCode': httpStatusCode,
      if (stream != null) 'stream': stream!.toJson(),
      if (headers != null) 'headers': headers!.toJson(),
    };
  }
}

/// An options object that may be extended later to better support CORS,
/// CORB and streaming.
class LoadNetworkResourceOptions {
  final bool disableCache;

  final bool includeCredentials;

  LoadNetworkResourceOptions(
      {required this.disableCache, required this.includeCredentials});

  factory LoadNetworkResourceOptions.fromJson(Map<String, dynamic> json) {
    return LoadNetworkResourceOptions(
      disableCache: json['disableCache'] as bool? ?? false,
      includeCredentials: json['includeCredentials'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disableCache': disableCache,
      'includeCredentials': includeCredentials,
    };
  }
}

class TrustTokenOperationDoneEventStatus {
  static const ok = TrustTokenOperationDoneEventStatus._('Ok');
  static const invalidArgument =
      TrustTokenOperationDoneEventStatus._('InvalidArgument');
  static const failedPrecondition =
      TrustTokenOperationDoneEventStatus._('FailedPrecondition');
  static const resourceExhausted =
      TrustTokenOperationDoneEventStatus._('ResourceExhausted');
  static const alreadyExists =
      TrustTokenOperationDoneEventStatus._('AlreadyExists');
  static const unavailable =
      TrustTokenOperationDoneEventStatus._('Unavailable');
  static const badResponse =
      TrustTokenOperationDoneEventStatus._('BadResponse');
  static const internalError =
      TrustTokenOperationDoneEventStatus._('InternalError');
  static const unknownError =
      TrustTokenOperationDoneEventStatus._('UnknownError');
  static const fulfilledLocally =
      TrustTokenOperationDoneEventStatus._('FulfilledLocally');
  static const values = {
    'Ok': ok,
    'InvalidArgument': invalidArgument,
    'FailedPrecondition': failedPrecondition,
    'ResourceExhausted': resourceExhausted,
    'AlreadyExists': alreadyExists,
    'Unavailable': unavailable,
    'BadResponse': badResponse,
    'InternalError': internalError,
    'UnknownError': unknownError,
    'FulfilledLocally': fulfilledLocally,
  };

  final String value;

  const TrustTokenOperationDoneEventStatus._(this.value);

  factory TrustTokenOperationDoneEventStatus.fromJson(String value) =>
      values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is TrustTokenOperationDoneEventStatus && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
