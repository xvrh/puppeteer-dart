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
          .map(
            (event) =>
                EventSourceMessageReceivedEvent.fromJson(event.parameters),
          );

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
      .map(
        (event) => RequestId.fromJson(event.parameters['requestId'] as String),
      );

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
      .where(
        (event) => event.name == 'Network.webSocketHandshakeResponseReceived',
      )
      .map(
        (event) =>
            WebSocketHandshakeResponseReceivedEvent.fromJson(event.parameters),
      );

  /// Fired when WebSocket is about to initiate handshake.
  Stream<WebSocketWillSendHandshakeRequestEvent>
  get onWebSocketWillSendHandshakeRequest => _client.onEvent
      .where(
        (event) => event.name == 'Network.webSocketWillSendHandshakeRequest',
      )
      .map(
        (event) =>
            WebSocketWillSendHandshakeRequestEvent.fromJson(event.parameters),
      );

  /// Fired upon WebTransport creation.
  Stream<WebTransportCreatedEvent> get onWebTransportCreated => _client.onEvent
      .where((event) => event.name == 'Network.webTransportCreated')
      .map((event) => WebTransportCreatedEvent.fromJson(event.parameters));

  /// Fired when WebTransport handshake is finished.
  Stream<WebTransportConnectionEstablishedEvent>
  get onWebTransportConnectionEstablished => _client.onEvent
      .where(
        (event) => event.name == 'Network.webTransportConnectionEstablished',
      )
      .map(
        (event) =>
            WebTransportConnectionEstablishedEvent.fromJson(event.parameters),
      );

  /// Fired when WebTransport is disposed.
  Stream<WebTransportClosedEvent> get onWebTransportClosed => _client.onEvent
      .where((event) => event.name == 'Network.webTransportClosed')
      .map((event) => WebTransportClosedEvent.fromJson(event.parameters));

  /// Fired upon direct_socket.TCPSocket creation.
  Stream<DirectTCPSocketCreatedEvent> get onDirectTCPSocketCreated => _client
      .onEvent
      .where((event) => event.name == 'Network.directTCPSocketCreated')
      .map((event) => DirectTCPSocketCreatedEvent.fromJson(event.parameters));

  /// Fired when direct_socket.TCPSocket connection is opened.
  Stream<DirectTCPSocketOpenedEvent> get onDirectTCPSocketOpened => _client
      .onEvent
      .where((event) => event.name == 'Network.directTCPSocketOpened')
      .map((event) => DirectTCPSocketOpenedEvent.fromJson(event.parameters));

  /// Fired when direct_socket.TCPSocket is aborted.
  Stream<DirectTCPSocketAbortedEvent> get onDirectTCPSocketAborted => _client
      .onEvent
      .where((event) => event.name == 'Network.directTCPSocketAborted')
      .map((event) => DirectTCPSocketAbortedEvent.fromJson(event.parameters));

  /// Fired when direct_socket.TCPSocket is closed.
  Stream<DirectTCPSocketClosedEvent> get onDirectTCPSocketClosed => _client
      .onEvent
      .where((event) => event.name == 'Network.directTCPSocketClosed')
      .map((event) => DirectTCPSocketClosedEvent.fromJson(event.parameters));

  /// Fired when data is sent to tcp direct socket stream.
  Stream<DirectTCPSocketChunkSentEvent> get onDirectTCPSocketChunkSent =>
      _client.onEvent
          .where((event) => event.name == 'Network.directTCPSocketChunkSent')
          .map(
            (event) => DirectTCPSocketChunkSentEvent.fromJson(event.parameters),
          );

  /// Fired when data is received from tcp direct socket stream.
  Stream<DirectTCPSocketChunkReceivedEvent>
  get onDirectTCPSocketChunkReceived => _client.onEvent
      .where((event) => event.name == 'Network.directTCPSocketChunkReceived')
      .map(
        (event) => DirectTCPSocketChunkReceivedEvent.fromJson(event.parameters),
      );

  /// Fired upon direct_socket.UDPSocket creation.
  Stream<DirectUDPSocketCreatedEvent> get onDirectUDPSocketCreated => _client
      .onEvent
      .where((event) => event.name == 'Network.directUDPSocketCreated')
      .map((event) => DirectUDPSocketCreatedEvent.fromJson(event.parameters));

  /// Fired when direct_socket.UDPSocket connection is opened.
  Stream<DirectUDPSocketOpenedEvent> get onDirectUDPSocketOpened => _client
      .onEvent
      .where((event) => event.name == 'Network.directUDPSocketOpened')
      .map((event) => DirectUDPSocketOpenedEvent.fromJson(event.parameters));

  /// Fired when direct_socket.UDPSocket is aborted.
  Stream<DirectUDPSocketAbortedEvent> get onDirectUDPSocketAborted => _client
      .onEvent
      .where((event) => event.name == 'Network.directUDPSocketAborted')
      .map((event) => DirectUDPSocketAbortedEvent.fromJson(event.parameters));

  /// Fired when direct_socket.UDPSocket is closed.
  Stream<DirectUDPSocketClosedEvent> get onDirectUDPSocketClosed => _client
      .onEvent
      .where((event) => event.name == 'Network.directUDPSocketClosed')
      .map((event) => DirectUDPSocketClosedEvent.fromJson(event.parameters));

  /// Fired when message is sent to udp direct socket stream.
  Stream<DirectUDPSocketChunkSentEvent> get onDirectUDPSocketChunkSent =>
      _client.onEvent
          .where((event) => event.name == 'Network.directUDPSocketChunkSent')
          .map(
            (event) => DirectUDPSocketChunkSentEvent.fromJson(event.parameters),
          );

  /// Fired when message is received from udp direct socket stream.
  Stream<DirectUDPSocketChunkReceivedEvent>
  get onDirectUDPSocketChunkReceived => _client.onEvent
      .where((event) => event.name == 'Network.directUDPSocketChunkReceived')
      .map(
        (event) => DirectUDPSocketChunkReceivedEvent.fromJson(event.parameters),
      );

  /// Fired when additional information about a requestWillBeSent event is available from the
  /// network stack. Not every requestWillBeSent event will have an additional
  /// requestWillBeSentExtraInfo fired for it, and there is no guarantee whether requestWillBeSent
  /// or requestWillBeSentExtraInfo will be fired first for the same request.
  Stream<RequestWillBeSentExtraInfoEvent> get onRequestWillBeSentExtraInfo =>
      _client.onEvent
          .where((event) => event.name == 'Network.requestWillBeSentExtraInfo')
          .map(
            (event) =>
                RequestWillBeSentExtraInfoEvent.fromJson(event.parameters),
          );

  /// Fired when additional information about a responseReceived event is available from the network
  /// stack. Not every responseReceived event will have an additional responseReceivedExtraInfo for
  /// it, and responseReceivedExtraInfo may be fired before or after responseReceived.
  Stream<ResponseReceivedExtraInfoEvent> get onResponseReceivedExtraInfo =>
      _client.onEvent
          .where((event) => event.name == 'Network.responseReceivedExtraInfo')
          .map(
            (event) =>
                ResponseReceivedExtraInfoEvent.fromJson(event.parameters),
          );

  /// Fired when 103 Early Hints headers is received in addition to the common response.
  /// Not every responseReceived event will have an responseReceivedEarlyHints fired.
  /// Only one responseReceivedEarlyHints may be fired for eached responseReceived event.
  Stream<ResponseReceivedEarlyHintsEvent> get onResponseReceivedEarlyHints =>
      _client.onEvent
          .where((event) => event.name == 'Network.responseReceivedEarlyHints')
          .map(
            (event) =>
                ResponseReceivedEarlyHintsEvent.fromJson(event.parameters),
          );

  /// Fired exactly once for each Trust Token operation. Depending on
  /// the type of the operation and whether the operation succeeded or
  /// failed, the event is fired before the corresponding request was sent
  /// or after the response was received.
  Stream<TrustTokenOperationDoneEvent> get onTrustTokenOperationDone => _client
      .onEvent
      .where((event) => event.name == 'Network.trustTokenOperationDone')
      .map((event) => TrustTokenOperationDoneEvent.fromJson(event.parameters));

  /// Fired once security policy has been updated.
  Stream<void> get onPolicyUpdated =>
      _client.onEvent.where((event) => event.name == 'Network.policyUpdated');

  /// Fired once when parsing the .wbn file has succeeded.
  /// The event contains the information about the web bundle contents.
  Stream<SubresourceWebBundleMetadataReceivedEvent>
  get onSubresourceWebBundleMetadataReceived => _client.onEvent
      .where(
        (event) => event.name == 'Network.subresourceWebBundleMetadataReceived',
      )
      .map(
        (event) => SubresourceWebBundleMetadataReceivedEvent.fromJson(
          event.parameters,
        ),
      );

  /// Fired once when parsing the .wbn file has failed.
  Stream<SubresourceWebBundleMetadataErrorEvent>
  get onSubresourceWebBundleMetadataError => _client.onEvent
      .where(
        (event) => event.name == 'Network.subresourceWebBundleMetadataError',
      )
      .map(
        (event) =>
            SubresourceWebBundleMetadataErrorEvent.fromJson(event.parameters),
      );

  /// Fired when handling requests for resources within a .wbn file.
  /// Note: this will only be fired for resources that are requested by the webpage.
  Stream<SubresourceWebBundleInnerResponseParsedEvent>
  get onSubresourceWebBundleInnerResponseParsed => _client.onEvent
      .where(
        (event) =>
            event.name == 'Network.subresourceWebBundleInnerResponseParsed',
      )
      .map(
        (event) => SubresourceWebBundleInnerResponseParsedEvent.fromJson(
          event.parameters,
        ),
      );

  /// Fired when request for resources within a .wbn file failed.
  Stream<SubresourceWebBundleInnerResponseErrorEvent>
  get onSubresourceWebBundleInnerResponseError => _client.onEvent
      .where(
        (event) =>
            event.name == 'Network.subresourceWebBundleInnerResponseError',
      )
      .map(
        (event) => SubresourceWebBundleInnerResponseErrorEvent.fromJson(
          event.parameters,
        ),
      );

  /// Is sent whenever a new report is added.
  /// And after 'enableReportingApi' for all existing reports.
  Stream<ReportingApiReport> get onReportingApiReportAdded => _client.onEvent
      .where((event) => event.name == 'Network.reportingApiReportAdded')
      .map(
        (event) => ReportingApiReport.fromJson(
          event.parameters['report'] as Map<String, dynamic>,
        ),
      );

  Stream<ReportingApiReport> get onReportingApiReportUpdated => _client.onEvent
      .where((event) => event.name == 'Network.reportingApiReportUpdated')
      .map(
        (event) => ReportingApiReport.fromJson(
          event.parameters['report'] as Map<String, dynamic>,
        ),
      );

  Stream<ReportingApiEndpointsChangedForOriginEvent>
  get onReportingApiEndpointsChangedForOrigin => _client.onEvent
      .where(
        (event) =>
            event.name == 'Network.reportingApiEndpointsChangedForOrigin',
      )
      .map(
        (event) => ReportingApiEndpointsChangedForOriginEvent.fromJson(
          event.parameters,
        ),
      );

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
    'use Fetch.continueRequest, Fetch.fulfillRequest and Fetch.failRequest instead',
  )
  Future<void> continueInterceptedRequest(
    InterceptionId interceptionId, {
    ErrorReason? errorReason,
    String? rawResponse,
    String? url,
    String? method,
    String? postData,
    Headers? headers,
    AuthChallengeResponse? authChallengeResponse,
  }) async {
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

  /// Deletes browser cookies with matching name and url or domain/path/partitionKey pair.
  /// [name] Name of the cookies to remove.
  /// [url] If specified, deletes all the cookies with the given name where domain and path match
  /// provided URL.
  /// [domain] If specified, deletes only cookies with the exact domain.
  /// [path] If specified, deletes only cookies with the exact path.
  /// [partitionKey] If specified, deletes only cookies with the the given name and partitionKey where
  /// all partition key attributes match the cookie partition key attribute.
  Future<void> deleteCookies(
    String name, {
    String? url,
    String? domain,
    String? path,
    CookiePartitionKey? partitionKey,
  }) async {
    await _client.send('Network.deleteCookies', {
      'name': name,
      if (url != null) 'url': url,
      if (domain != null) 'domain': domain,
      if (path != null) 'path': path,
      if (partitionKey != null) 'partitionKey': partitionKey,
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
  /// [packetLoss] WebRTC packet loss (percent, 0-100). 0 disables packet loss emulation, 100 drops all the packets.
  /// [packetQueueLength] WebRTC packet queue length (packet). 0 removes any queue length limitations.
  /// [packetReordering] WebRTC packetReordering feature.
  Future<void> emulateNetworkConditions(
    bool offline,
    num latency,
    num downloadThroughput,
    num uploadThroughput, {
    ConnectionType? connectionType,
    num? packetLoss,
    int? packetQueueLength,
    bool? packetReordering,
  }) async {
    await _client.send('Network.emulateNetworkConditions', {
      'offline': offline,
      'latency': latency,
      'downloadThroughput': downloadThroughput,
      'uploadThroughput': uploadThroughput,
      if (connectionType != null) 'connectionType': connectionType,
      if (packetLoss != null) 'packetLoss': packetLoss,
      if (packetQueueLength != null) 'packetQueueLength': packetQueueLength,
      if (packetReordering != null) 'packetReordering': packetReordering,
    });
  }

  /// Enables network tracking, network events will now be delivered to the client.
  /// [maxTotalBufferSize] Buffer size in bytes to use when preserving network payloads (XHRs, etc).
  /// [maxResourceBufferSize] Per-resource buffer size in bytes to use when preserving network payloads (XHRs, etc).
  /// [maxPostDataSize] Longest post body size (in bytes) that would be included in requestWillBeSent notification
  /// [reportDirectSocketTraffic] Whether DirectSocket chunk send/receive events should be reported.
  Future<void> enable({
    int? maxTotalBufferSize,
    int? maxResourceBufferSize,
    int? maxPostDataSize,
    bool? reportDirectSocketTraffic,
  }) async {
    await _client.send('Network.enable', {
      if (maxTotalBufferSize != null) 'maxTotalBufferSize': maxTotalBufferSize,
      if (maxResourceBufferSize != null)
        'maxResourceBufferSize': maxResourceBufferSize,
      if (maxPostDataSize != null) 'maxPostDataSize': maxPostDataSize,
      if (reportDirectSocketTraffic != null)
        'reportDirectSocketTraffic': reportDirectSocketTraffic,
    });
  }

  /// Returns all browser cookies. Depending on the backend support, will return detailed cookie
  /// information in the `cookies` field.
  /// Deprecated. Use Storage.getCookies instead.
  /// Returns: Array of cookie objects.
  @Deprecated('Use Storage.getCookies instead')
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
    InterceptionId interceptionId,
  ) async {
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
    InterceptionId interceptionId,
  ) async {
    var result = await _client.send(
      'Network.takeResponseBodyForInterceptionAsStream',
      {'interceptionId': interceptionId},
    );
    return io.StreamHandle.fromJson(result['stream'] as String);
  }

  /// This method sends a new XMLHttpRequest which is identical to the original one. The following
  /// parameters should be identical: method, url, async, request body, extra headers, withCredentials
  /// attribute, user, password.
  /// [requestId] Identifier of XHR to replay.
  Future<void> replayXHR(RequestId requestId) async {
    await _client.send('Network.replayXHR', {'requestId': requestId});
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
    bool? caseSensitive,
    bool? isRegex,
  }) async {
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
    await _client.send('Network.setBypassServiceWorker', {'bypass': bypass});
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
  /// [partitionKey] Cookie partition key. If not set, the cookie will be set as not partitioned.
  /// Returns: Always set to true. If an error occurs, the response indicates protocol error.
  Future<bool> setCookie(
    String name,
    String value, {
    String? url,
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
    CookiePartitionKey? partitionKey,
  }) async {
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
    await _client.send('Network.setExtraHTTPHeaders', {'headers': headers});
  }

  /// Specifies whether to attach a page script stack id in requests
  /// [enabled] Whether to attach a page script stack for debugging purpose.
  Future<void> setAttachDebugStack(bool enabled) async {
    await _client.send('Network.setAttachDebugStack', {'enabled': enabled});
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
  /// [acceptLanguage] Browser language to emulate.
  /// [platform] The platform navigator.platform should return.
  /// [userAgentMetadata] To be sent in Sec-CH-UA-* headers and returned in navigator.userAgentData
  Future<void> setUserAgentOverride(
    String userAgent, {
    String? acceptLanguage,
    String? platform,
    emulation.UserAgentMetadata? userAgentMetadata,
  }) async {
    await _client.send('Network.setUserAgentOverride', {
      'userAgent': userAgent,
      if (acceptLanguage != null) 'acceptLanguage': acceptLanguage,
      if (platform != null) 'platform': platform,
      if (userAgentMetadata != null) 'userAgentMetadata': userAgentMetadata,
    });
  }

  /// Enables streaming of the response for the given requestId.
  /// If enabled, the dataReceived event contains the data that was received during streaming.
  /// [requestId] Identifier of the request to stream.
  /// Returns: Data that has been buffered until streaming is enabled.
  Future<String> streamResourceContent(RequestId requestId) async {
    var result = await _client.send('Network.streamResourceContent', {
      'requestId': requestId,
    });
    return result['bufferedData'] as String;
  }

  /// Returns information about the COEP/COOP isolation status.
  /// [frameId] If no frameId is provided, the status of the target is provided.
  Future<SecurityIsolationStatus> getSecurityIsolationStatus({
    page.FrameId? frameId,
  }) async {
    var result = await _client.send('Network.getSecurityIsolationStatus', {
      if (frameId != null) 'frameId': frameId,
    });
    return SecurityIsolationStatus.fromJson(
      result['status'] as Map<String, dynamic>,
    );
  }

  /// Enables tracking for the Reporting API, events generated by the Reporting API will now be delivered to the client.
  /// Enabling triggers 'reportingApiReportAdded' for all existing reports.
  /// [enable] Whether to enable or disable events for the Reporting API
  Future<void> enableReportingApi(bool enable) async {
    await _client.send('Network.enableReportingApi', {'enable': enable});
  }

  /// Fetches the resource and returns the content.
  /// [frameId] Frame id to get the resource for. Mandatory for frame targets, and
  /// should be omitted for worker targets.
  /// [url] URL of the resource to get content for.
  /// [options] Options for the request.
  Future<LoadNetworkResourcePageResult> loadNetworkResource(
    String url,
    LoadNetworkResourceOptions options, {
    page.FrameId? frameId,
  }) async {
    var result = await _client.send('Network.loadNetworkResource', {
      'url': url,
      'options': options,
      if (frameId != null) 'frameId': frameId,
    });
    return LoadNetworkResourcePageResult.fromJson(
      result['resource'] as Map<String, dynamic>,
    );
  }

  /// Sets Controls for third-party cookie access
  /// Page reload is required before the new cookie behavior will be observed
  /// [enableThirdPartyCookieRestriction] Whether 3pc restriction is enabled.
  /// [disableThirdPartyCookieMetadata] Whether 3pc grace period exception should be enabled; false by default.
  /// [disableThirdPartyCookieHeuristics] Whether 3pc heuristics exceptions should be enabled; false by default.
  Future<void> setCookieControls(
    bool enableThirdPartyCookieRestriction,
    bool disableThirdPartyCookieMetadata,
    bool disableThirdPartyCookieHeuristics,
  ) async {
    await _client.send('Network.setCookieControls', {
      'enableThirdPartyCookieRestriction': enableThirdPartyCookieRestriction,
      'disableThirdPartyCookieMetadata': disableThirdPartyCookieMetadata,
      'disableThirdPartyCookieHeuristics': disableThirdPartyCookieHeuristics,
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

  /// Data that was received.
  final String? data;

  DataReceivedEvent({
    required this.requestId,
    required this.timestamp,
    required this.dataLength,
    required this.encodedDataLength,
    this.data,
  });

  factory DataReceivedEvent.fromJson(Map<String, dynamic> json) {
    return DataReceivedEvent(
      requestId: RequestId.fromJson(json['requestId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      dataLength: json['dataLength'] as int,
      encodedDataLength: json['encodedDataLength'] as int,
      data: json.containsKey('data') ? json['data'] as String : null,
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
    required this.requestId,
    required this.timestamp,
    required this.eventName,
    required this.eventId,
    required this.data,
  });

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

  /// Error message. List of network errors: https://cs.chromium.org/chromium/src/net/base/net_error_list.h
  final String errorText;

  /// True if loading was canceled.
  final bool? canceled;

  /// The reason why loading was blocked, if any.
  final BlockedReason? blockedReason;

  /// The reason why loading was blocked by CORS, if any.
  final CorsErrorStatus? corsErrorStatus;

  LoadingFailedEvent({
    required this.requestId,
    required this.timestamp,
    required this.type,
    required this.errorText,
    this.canceled,
    this.blockedReason,
    this.corsErrorStatus,
  });

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
              json['corsErrorStatus'] as Map<String, dynamic>,
            )
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

  LoadingFinishedEvent({
    required this.requestId,
    required this.timestamp,
    required this.encodedDataLength,
  });

  factory LoadingFinishedEvent.fromJson(Map<String, dynamic> json) {
    return LoadingFinishedEvent(
      requestId: RequestId.fromJson(json['requestId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      encodedDataLength: json['encodedDataLength'] as num,
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

  RequestInterceptedEvent({
    required this.interceptionId,
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
    this.requestId,
  });

  factory RequestInterceptedEvent.fromJson(Map<String, dynamic> json) {
    return RequestInterceptedEvent(
      interceptionId: InterceptionId.fromJson(json['interceptionId'] as String),
      request: RequestData.fromJson(json['request'] as Map<String, dynamic>),
      frameId: page.FrameId.fromJson(json['frameId'] as String),
      resourceType: ResourceType.fromJson(json['resourceType'] as String),
      isNavigationRequest: json['isNavigationRequest'] as bool? ?? false,
      isDownload: json.containsKey('isDownload')
          ? json['isDownload'] as bool
          : null,
      redirectUrl: json.containsKey('redirectUrl')
          ? json['redirectUrl'] as String
          : null,
      authChallenge: json.containsKey('authChallenge')
          ? AuthChallenge.fromJson(
              json['authChallenge'] as Map<String, dynamic>,
            )
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

  RequestWillBeSentEvent({
    required this.requestId,
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
    this.hasUserGesture,
  });

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
              json['redirectResponse'] as Map<String, dynamic>,
            )
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

  ResourceChangedPriorityEvent({
    required this.requestId,
    required this.newPriority,
    required this.timestamp,
  });

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

  ResponseReceivedEvent({
    required this.requestId,
    required this.loaderId,
    required this.timestamp,
    required this.type,
    required this.response,
    required this.hasExtraInfo,
    this.frameId,
  });

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

  WebSocketCreatedEvent({
    required this.requestId,
    required this.url,
    this.initiator,
  });

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

  WebSocketFrameErrorEvent({
    required this.requestId,
    required this.timestamp,
    required this.errorMessage,
  });

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

  WebSocketFrameReceivedEvent({
    required this.requestId,
    required this.timestamp,
    required this.response,
  });

  factory WebSocketFrameReceivedEvent.fromJson(Map<String, dynamic> json) {
    return WebSocketFrameReceivedEvent(
      requestId: RequestId.fromJson(json['requestId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      response: WebSocketFrame.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
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
    required this.requestId,
    required this.timestamp,
    required this.response,
  });

  factory WebSocketFrameSentEvent.fromJson(Map<String, dynamic> json) {
    return WebSocketFrameSentEvent(
      requestId: RequestId.fromJson(json['requestId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      response: WebSocketFrame.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
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
    required this.requestId,
    required this.timestamp,
    required this.response,
  });

  factory WebSocketHandshakeResponseReceivedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return WebSocketHandshakeResponseReceivedEvent(
      requestId: RequestId.fromJson(json['requestId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      response: WebSocketResponse.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
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
    required this.requestId,
    required this.timestamp,
    required this.wallTime,
    required this.request,
  });

  factory WebSocketWillSendHandshakeRequestEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return WebSocketWillSendHandshakeRequestEvent(
      requestId: RequestId.fromJson(json['requestId'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      wallTime: TimeSinceEpoch.fromJson(json['wallTime'] as num),
      request: WebSocketRequest.fromJson(
        json['request'] as Map<String, dynamic>,
      ),
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

  WebTransportCreatedEvent({
    required this.transportId,
    required this.url,
    required this.timestamp,
    this.initiator,
  });

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

  WebTransportConnectionEstablishedEvent({
    required this.transportId,
    required this.timestamp,
  });

  factory WebTransportConnectionEstablishedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
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

class DirectTCPSocketCreatedEvent {
  final RequestId identifier;

  final String remoteAddr;

  /// Unsigned int 16.
  final int remotePort;

  final DirectTCPSocketOptions options;

  final MonotonicTime timestamp;

  final Initiator? initiator;

  DirectTCPSocketCreatedEvent({
    required this.identifier,
    required this.remoteAddr,
    required this.remotePort,
    required this.options,
    required this.timestamp,
    this.initiator,
  });

  factory DirectTCPSocketCreatedEvent.fromJson(Map<String, dynamic> json) {
    return DirectTCPSocketCreatedEvent(
      identifier: RequestId.fromJson(json['identifier'] as String),
      remoteAddr: json['remoteAddr'] as String,
      remotePort: json['remotePort'] as int,
      options: DirectTCPSocketOptions.fromJson(
        json['options'] as Map<String, dynamic>,
      ),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      initiator: json.containsKey('initiator')
          ? Initiator.fromJson(json['initiator'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DirectTCPSocketOpenedEvent {
  final RequestId identifier;

  final String remoteAddr;

  /// Expected to be unsigned integer.
  final int remotePort;

  final MonotonicTime timestamp;

  final String? localAddr;

  /// Expected to be unsigned integer.
  final int? localPort;

  DirectTCPSocketOpenedEvent({
    required this.identifier,
    required this.remoteAddr,
    required this.remotePort,
    required this.timestamp,
    this.localAddr,
    this.localPort,
  });

  factory DirectTCPSocketOpenedEvent.fromJson(Map<String, dynamic> json) {
    return DirectTCPSocketOpenedEvent(
      identifier: RequestId.fromJson(json['identifier'] as String),
      remoteAddr: json['remoteAddr'] as String,
      remotePort: json['remotePort'] as int,
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      localAddr: json.containsKey('localAddr')
          ? json['localAddr'] as String
          : null,
      localPort: json.containsKey('localPort')
          ? json['localPort'] as int
          : null,
    );
  }
}

class DirectTCPSocketAbortedEvent {
  final RequestId identifier;

  final String errorMessage;

  final MonotonicTime timestamp;

  DirectTCPSocketAbortedEvent({
    required this.identifier,
    required this.errorMessage,
    required this.timestamp,
  });

  factory DirectTCPSocketAbortedEvent.fromJson(Map<String, dynamic> json) {
    return DirectTCPSocketAbortedEvent(
      identifier: RequestId.fromJson(json['identifier'] as String),
      errorMessage: json['errorMessage'] as String,
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
    );
  }
}

class DirectTCPSocketClosedEvent {
  final RequestId identifier;

  final MonotonicTime timestamp;

  DirectTCPSocketClosedEvent({
    required this.identifier,
    required this.timestamp,
  });

  factory DirectTCPSocketClosedEvent.fromJson(Map<String, dynamic> json) {
    return DirectTCPSocketClosedEvent(
      identifier: RequestId.fromJson(json['identifier'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
    );
  }
}

class DirectTCPSocketChunkSentEvent {
  final RequestId identifier;

  final String data;

  final MonotonicTime timestamp;

  DirectTCPSocketChunkSentEvent({
    required this.identifier,
    required this.data,
    required this.timestamp,
  });

  factory DirectTCPSocketChunkSentEvent.fromJson(Map<String, dynamic> json) {
    return DirectTCPSocketChunkSentEvent(
      identifier: RequestId.fromJson(json['identifier'] as String),
      data: json['data'] as String,
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
    );
  }
}

class DirectTCPSocketChunkReceivedEvent {
  final RequestId identifier;

  final String data;

  final MonotonicTime timestamp;

  DirectTCPSocketChunkReceivedEvent({
    required this.identifier,
    required this.data,
    required this.timestamp,
  });

  factory DirectTCPSocketChunkReceivedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return DirectTCPSocketChunkReceivedEvent(
      identifier: RequestId.fromJson(json['identifier'] as String),
      data: json['data'] as String,
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
    );
  }
}

class DirectUDPSocketCreatedEvent {
  final RequestId identifier;

  final DirectUDPSocketOptions options;

  final MonotonicTime timestamp;

  final Initiator? initiator;

  DirectUDPSocketCreatedEvent({
    required this.identifier,
    required this.options,
    required this.timestamp,
    this.initiator,
  });

  factory DirectUDPSocketCreatedEvent.fromJson(Map<String, dynamic> json) {
    return DirectUDPSocketCreatedEvent(
      identifier: RequestId.fromJson(json['identifier'] as String),
      options: DirectUDPSocketOptions.fromJson(
        json['options'] as Map<String, dynamic>,
      ),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      initiator: json.containsKey('initiator')
          ? Initiator.fromJson(json['initiator'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DirectUDPSocketOpenedEvent {
  final RequestId identifier;

  final String localAddr;

  /// Expected to be unsigned integer.
  final int localPort;

  final MonotonicTime timestamp;

  final String? remoteAddr;

  /// Expected to be unsigned integer.
  final int? remotePort;

  DirectUDPSocketOpenedEvent({
    required this.identifier,
    required this.localAddr,
    required this.localPort,
    required this.timestamp,
    this.remoteAddr,
    this.remotePort,
  });

  factory DirectUDPSocketOpenedEvent.fromJson(Map<String, dynamic> json) {
    return DirectUDPSocketOpenedEvent(
      identifier: RequestId.fromJson(json['identifier'] as String),
      localAddr: json['localAddr'] as String,
      localPort: json['localPort'] as int,
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
      remoteAddr: json.containsKey('remoteAddr')
          ? json['remoteAddr'] as String
          : null,
      remotePort: json.containsKey('remotePort')
          ? json['remotePort'] as int
          : null,
    );
  }
}

class DirectUDPSocketAbortedEvent {
  final RequestId identifier;

  final String errorMessage;

  final MonotonicTime timestamp;

  DirectUDPSocketAbortedEvent({
    required this.identifier,
    required this.errorMessage,
    required this.timestamp,
  });

  factory DirectUDPSocketAbortedEvent.fromJson(Map<String, dynamic> json) {
    return DirectUDPSocketAbortedEvent(
      identifier: RequestId.fromJson(json['identifier'] as String),
      errorMessage: json['errorMessage'] as String,
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
    );
  }
}

class DirectUDPSocketClosedEvent {
  final RequestId identifier;

  final MonotonicTime timestamp;

  DirectUDPSocketClosedEvent({
    required this.identifier,
    required this.timestamp,
  });

  factory DirectUDPSocketClosedEvent.fromJson(Map<String, dynamic> json) {
    return DirectUDPSocketClosedEvent(
      identifier: RequestId.fromJson(json['identifier'] as String),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
    );
  }
}

class DirectUDPSocketChunkSentEvent {
  final RequestId identifier;

  final DirectUDPMessage message;

  final MonotonicTime timestamp;

  DirectUDPSocketChunkSentEvent({
    required this.identifier,
    required this.message,
    required this.timestamp,
  });

  factory DirectUDPSocketChunkSentEvent.fromJson(Map<String, dynamic> json) {
    return DirectUDPSocketChunkSentEvent(
      identifier: RequestId.fromJson(json['identifier'] as String),
      message: DirectUDPMessage.fromJson(
        json['message'] as Map<String, dynamic>,
      ),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
    );
  }
}

class DirectUDPSocketChunkReceivedEvent {
  final RequestId identifier;

  final DirectUDPMessage message;

  final MonotonicTime timestamp;

  DirectUDPSocketChunkReceivedEvent({
    required this.identifier,
    required this.message,
    required this.timestamp,
  });

  factory DirectUDPSocketChunkReceivedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return DirectUDPSocketChunkReceivedEvent(
      identifier: RequestId.fromJson(json['identifier'] as String),
      message: DirectUDPMessage.fromJson(
        json['message'] as Map<String, dynamic>,
      ),
      timestamp: MonotonicTime.fromJson(json['timestamp'] as num),
    );
  }
}

class RequestWillBeSentExtraInfoEvent {
  /// Request identifier. Used to match this information to an existing requestWillBeSent event.
  final RequestId requestId;

  /// A list of cookies potentially associated to the requested URL. This includes both cookies sent with
  /// the request and the ones not sent; the latter are distinguished by having blockedReasons field set.
  final List<AssociatedCookie> associatedCookies;

  /// Raw request headers as they will be sent over the wire.
  final Headers headers;

  /// Connection timing information for the request.
  final ConnectTiming connectTiming;

  /// The client security state set for the request.
  final ClientSecurityState? clientSecurityState;

  /// Whether the site has partitioned cookies stored in a partition different than the current one.
  final bool? siteHasCookieInOtherPartition;

  RequestWillBeSentExtraInfoEvent({
    required this.requestId,
    required this.associatedCookies,
    required this.headers,
    required this.connectTiming,
    this.clientSecurityState,
    this.siteHasCookieInOtherPartition,
  });

  factory RequestWillBeSentExtraInfoEvent.fromJson(Map<String, dynamic> json) {
    return RequestWillBeSentExtraInfoEvent(
      requestId: RequestId.fromJson(json['requestId'] as String),
      associatedCookies: (json['associatedCookies'] as List)
          .map((e) => AssociatedCookie.fromJson(e as Map<String, dynamic>))
          .toList(),
      headers: Headers.fromJson(json['headers'] as Map<String, dynamic>),
      connectTiming: ConnectTiming.fromJson(
        json['connectTiming'] as Map<String, dynamic>,
      ),
      clientSecurityState: json.containsKey('clientSecurityState')
          ? ClientSecurityState.fromJson(
              json['clientSecurityState'] as Map<String, dynamic>,
            )
          : null,
      siteHasCookieInOtherPartition:
          json.containsKey('siteHasCookieInOtherPartition')
          ? json['siteHasCookieInOtherPartition'] as bool
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
  /// Duplicate headers in the response are represented as a single key with their values
  /// concatentated using `\n` as the separator.
  /// See also `headersText` that contains verbatim text for HTTP/1.*.
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

  /// The cookie partition key that will be used to store partitioned cookies set in this response.
  /// Only sent when partitioned cookies are enabled.
  final CookiePartitionKey? cookiePartitionKey;

  /// True if partitioned cookies are enabled, but the partition key is not serializable to string.
  final bool? cookiePartitionKeyOpaque;

  /// A list of cookies which should have been blocked by 3PCD but are exempted and stored from
  /// the response with the corresponding reason.
  final List<ExemptedSetCookieWithReason>? exemptedCookies;

  ResponseReceivedExtraInfoEvent({
    required this.requestId,
    required this.blockedCookies,
    required this.headers,
    required this.resourceIPAddressSpace,
    required this.statusCode,
    this.headersText,
    this.cookiePartitionKey,
    this.cookiePartitionKeyOpaque,
    this.exemptedCookies,
  });

  factory ResponseReceivedExtraInfoEvent.fromJson(Map<String, dynamic> json) {
    return ResponseReceivedExtraInfoEvent(
      requestId: RequestId.fromJson(json['requestId'] as String),
      blockedCookies: (json['blockedCookies'] as List)
          .map(
            (e) =>
                BlockedSetCookieWithReason.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      headers: Headers.fromJson(json['headers'] as Map<String, dynamic>),
      resourceIPAddressSpace: IPAddressSpace.fromJson(
        json['resourceIPAddressSpace'] as String,
      ),
      statusCode: json['statusCode'] as int,
      headersText: json.containsKey('headersText')
          ? json['headersText'] as String
          : null,
      cookiePartitionKey: json.containsKey('cookiePartitionKey')
          ? CookiePartitionKey.fromJson(
              json['cookiePartitionKey'] as Map<String, dynamic>,
            )
          : null,
      cookiePartitionKeyOpaque: json.containsKey('cookiePartitionKeyOpaque')
          ? json['cookiePartitionKeyOpaque'] as bool
          : null,
      exemptedCookies: json.containsKey('exemptedCookies')
          ? (json['exemptedCookies'] as List)
                .map(
                  (e) => ExemptedSetCookieWithReason.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : null,
    );
  }
}

class ResponseReceivedEarlyHintsEvent {
  /// Request identifier. Used to match this information to another responseReceived event.
  final RequestId requestId;

  /// Raw response headers as they were received over the wire.
  /// Duplicate headers in the response are represented as a single key with their values
  /// concatentated using `\n` as the separator.
  /// See also `headersText` that contains verbatim text for HTTP/1.*.
  final Headers headers;

  ResponseReceivedEarlyHintsEvent({
    required this.requestId,
    required this.headers,
  });

  factory ResponseReceivedEarlyHintsEvent.fromJson(Map<String, dynamic> json) {
    return ResponseReceivedEarlyHintsEvent(
      requestId: RequestId.fromJson(json['requestId'] as String),
      headers: Headers.fromJson(json['headers'] as Map<String, dynamic>),
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

  TrustTokenOperationDoneEvent({
    required this.status,
    required this.type,
    required this.requestId,
    this.topLevelOrigin,
    this.issuerOrigin,
    this.issuedTokenCount,
  });

  factory TrustTokenOperationDoneEvent.fromJson(Map<String, dynamic> json) {
    return TrustTokenOperationDoneEvent(
      status: TrustTokenOperationDoneEventStatus.fromJson(
        json['status'] as String,
      ),
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

  SubresourceWebBundleMetadataReceivedEvent({
    required this.requestId,
    required this.urls,
  });

  factory SubresourceWebBundleMetadataReceivedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
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

  SubresourceWebBundleMetadataErrorEvent({
    required this.requestId,
    required this.errorMessage,
  });

  factory SubresourceWebBundleMetadataErrorEvent.fromJson(
    Map<String, dynamic> json,
  ) {
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

  SubresourceWebBundleInnerResponseParsedEvent({
    required this.innerRequestId,
    required this.innerRequestURL,
    this.bundleRequestId,
  });

  factory SubresourceWebBundleInnerResponseParsedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
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

  SubresourceWebBundleInnerResponseErrorEvent({
    required this.innerRequestId,
    required this.innerRequestURL,
    required this.errorMessage,
    this.bundleRequestId,
  });

  factory SubresourceWebBundleInnerResponseErrorEvent.fromJson(
    Map<String, dynamic> json,
  ) {
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

  ReportingApiEndpointsChangedForOriginEvent({
    required this.origin,
    required this.endpoints,
  });

  factory ReportingApiEndpointsChangedForOriginEvent.fromJson(
    Map<String, dynamic> json,
  ) {
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

  GetResponseBodyForInterceptionResult({
    required this.body,
    required this.base64Encoded,
  });

  factory GetResponseBodyForInterceptionResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return GetResponseBodyForInterceptionResult(
      body: json['body'] as String,
      base64Encoded: json['base64Encoded'] as bool? ?? false,
    );
  }
}

/// Resource type as it was perceived by the rendering engine.
enum ResourceType {
  document('Document'),
  stylesheet('Stylesheet'),
  image('Image'),
  media('Media'),
  font('Font'),
  script('Script'),
  textTrack('TextTrack'),
  xhr('XHR'),
  fetch('Fetch'),
  prefetch('Prefetch'),
  eventSource('EventSource'),
  webSocket('WebSocket'),
  manifest('Manifest'),
  signedExchange('SignedExchange'),
  ping('Ping'),
  cspViolationReport('CSPViolationReport'),
  preflight('Preflight'),
  fedCm('FedCM'),
  other('Other');

  final String value;

  const ResourceType(this.value);

  factory ResourceType.fromJson(String value) =>
      ResourceType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Unique loader identifier.
extension type LoaderId(String value) {
  factory LoaderId.fromJson(String value) => LoaderId(value);

  String toJson() => value;
}

/// Unique network request identifier.
/// Note that this does not identify individual HTTP requests that are part of
/// a network request.
extension type RequestId(String value) {
  factory RequestId.fromJson(String value) => RequestId(value);

  String toJson() => value;
}

/// Unique intercepted request identifier.
extension type InterceptionId(String value) {
  factory InterceptionId.fromJson(String value) => InterceptionId(value);

  String toJson() => value;
}

/// Network level fetch failure reason.
enum ErrorReason {
  failed('Failed'),
  aborted('Aborted'),
  timedOut('TimedOut'),
  accessDenied('AccessDenied'),
  connectionClosed('ConnectionClosed'),
  connectionReset('ConnectionReset'),
  connectionRefused('ConnectionRefused'),
  connectionAborted('ConnectionAborted'),
  connectionFailed('ConnectionFailed'),
  nameNotResolved('NameNotResolved'),
  internetDisconnected('InternetDisconnected'),
  addressUnreachable('AddressUnreachable'),
  blockedByClient('BlockedByClient'),
  blockedByResponse('BlockedByResponse');

  final String value;

  const ErrorReason(this.value);

  factory ErrorReason.fromJson(String value) =>
      ErrorReason.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// UTC time in seconds, counted from January 1, 1970.
extension type TimeSinceEpoch(num value) {
  factory TimeSinceEpoch.fromJson(num value) => TimeSinceEpoch(value);

  num toJson() => value;
}

/// Monotonically increasing time in seconds since an arbitrary point in the past.
extension type MonotonicTime(num value) {
  factory MonotonicTime.fromJson(num value) => MonotonicTime(value);

  num toJson() => value;
}

/// Request / response headers as keys / values of JSON object.
extension type Headers(Map<String, dynamic> value) {
  factory Headers.fromJson(Map<String, dynamic> value) => Headers(value);

  Map<String, dynamic> toJson() => value;
}

/// The underlying connection technology that the browser is supposedly using.
enum ConnectionType {
  none('none'),
  cellular2g('cellular2g'),
  cellular3g('cellular3g'),
  cellular4g('cellular4g'),
  bluetooth('bluetooth'),
  ethernet('ethernet'),
  wifi('wifi'),
  wimax('wimax'),
  other('other');

  final String value;

  const ConnectionType(this.value);

  factory ConnectionType.fromJson(String value) =>
      ConnectionType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Represents the cookie's 'SameSite' status:
/// https://tools.ietf.org/html/draft-west-first-party-cookies
enum CookieSameSite {
  strict('Strict'),
  lax('Lax'),
  none('None');

  final String value;

  const CookieSameSite(this.value);

  factory CookieSameSite.fromJson(String value) =>
      CookieSameSite.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Represents the cookie's 'Priority' status:
/// https://tools.ietf.org/html/draft-west-cookie-priority-00
enum CookiePriority {
  low('Low'),
  medium('Medium'),
  high('High');

  final String value;

  const CookiePriority(this.value);

  factory CookiePriority.fromJson(String value) =>
      CookiePriority.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Represents the source scheme of the origin that originally set the cookie.
/// A value of "Unset" allows protocol clients to emulate legacy cookie scope for the scheme.
/// This is a temporary ability and it will be removed in the future.
enum CookieSourceScheme {
  unset('Unset'),
  nonSecure('NonSecure'),
  secure('Secure');

  final String value;

  const CookieSourceScheme(this.value);

  factory CookieSourceScheme.fromJson(String value) =>
      CookieSourceScheme.values.firstWhere((e) => e.value == value);

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

  /// Started fetch event.
  final num workerFetchStart;

  /// Settled fetch event respondWith promise.
  final num workerRespondWithSettled;

  /// Started ServiceWorker static routing source evaluation.
  final num? workerRouterEvaluationStart;

  /// Started cache lookup when the source was evaluated to `cache`.
  final num? workerCacheLookupStart;

  /// Started sending request.
  final num sendStart;

  /// Finished sending request.
  final num sendEnd;

  /// Time the server started pushing request.
  final num pushStart;

  /// Time the server finished pushing request.
  final num pushEnd;

  /// Started receiving response headers.
  final num receiveHeadersStart;

  /// Finished receiving response headers.
  final num receiveHeadersEnd;

  ResourceTiming({
    required this.requestTime,
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
    this.workerRouterEvaluationStart,
    this.workerCacheLookupStart,
    required this.sendStart,
    required this.sendEnd,
    required this.pushStart,
    required this.pushEnd,
    required this.receiveHeadersStart,
    required this.receiveHeadersEnd,
  });

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
      workerRouterEvaluationStart:
          json.containsKey('workerRouterEvaluationStart')
          ? json['workerRouterEvaluationStart'] as num
          : null,
      workerCacheLookupStart: json.containsKey('workerCacheLookupStart')
          ? json['workerCacheLookupStart'] as num
          : null,
      sendStart: json['sendStart'] as num,
      sendEnd: json['sendEnd'] as num,
      pushStart: json['pushStart'] as num,
      pushEnd: json['pushEnd'] as num,
      receiveHeadersStart: json['receiveHeadersStart'] as num,
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
      'receiveHeadersStart': receiveHeadersStart,
      'receiveHeadersEnd': receiveHeadersEnd,
      if (workerRouterEvaluationStart != null)
        'workerRouterEvaluationStart': workerRouterEvaluationStart,
      if (workerCacheLookupStart != null)
        'workerCacheLookupStart': workerCacheLookupStart,
    };
  }
}

/// Loading priority of a resource request.
enum ResourcePriority {
  veryLow('VeryLow'),
  low('Low'),
  medium('Medium'),
  high('High'),
  veryHigh('VeryHigh');

  final String value;

  const ResourcePriority(this.value);

  factory ResourcePriority.fromJson(String value) =>
      ResourcePriority.values.firstWhere((e) => e.value == value);

  String toJson() => value;

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
    return {if (bytes != null) 'bytes': bytes};
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

  /// True when the request has POST data. Note that postData might still be omitted when this flag is true when the data is too long.
  final bool? hasPostData;

  /// Request body elements (post data broken into individual entries).
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
  /// request corresponding to the main frame.
  final bool? isSameSite;

  RequestData({
    required this.url,
    this.urlFragment,
    required this.method,
    required this.headers,
    this.hasPostData,
    this.postDataEntries,
    this.mixedContentType,
    required this.initialPriority,
    required this.referrerPolicy,
    this.isLinkPreload,
    this.trustTokenParams,
    this.isSameSite,
  });

  factory RequestData.fromJson(Map<String, dynamic> json) {
    return RequestData(
      url: json['url'] as String,
      urlFragment: json.containsKey('urlFragment')
          ? json['urlFragment'] as String
          : null,
      method: json['method'] as String,
      headers: Headers.fromJson(json['headers'] as Map<String, dynamic>),
      hasPostData: json.containsKey('hasPostData')
          ? json['hasPostData'] as bool
          : null,
      postDataEntries: json.containsKey('postDataEntries')
          ? (json['postDataEntries'] as List)
                .map((e) => PostDataEntry.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      mixedContentType: json.containsKey('mixedContentType')
          ? security.MixedContentType.fromJson(
              json['mixedContentType'] as String,
            )
          : null,
      initialPriority: ResourcePriority.fromJson(
        json['initialPriority'] as String,
      ),
      referrerPolicy: RequestReferrerPolicy.fromJson(
        json['referrerPolicy'] as String,
      ),
      isLinkPreload: json.containsKey('isLinkPreload')
          ? json['isLinkPreload'] as bool
          : null,
      trustTokenParams: json.containsKey('trustTokenParams')
          ? TrustTokenParams.fromJson(
              json['trustTokenParams'] as Map<String, dynamic>,
            )
          : null,
      isSameSite: json.containsKey('isSameSite')
          ? json['isSameSite'] as bool
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

enum RequestReferrerPolicy {
  unsafeUrl('unsafe-url'),
  noReferrerWhenDowngrade('no-referrer-when-downgrade'),
  noReferrer('no-referrer'),
  origin('origin'),
  originWhenCrossOrigin('origin-when-cross-origin'),
  sameOrigin('same-origin'),
  strictOrigin('strict-origin'),
  strictOriginWhenCrossOrigin('strict-origin-when-cross-origin');

  final String value;

  const RequestReferrerPolicy(this.value);

  factory RequestReferrerPolicy.fromJson(String value) =>
      RequestReferrerPolicy.values.firstWhere((e) => e.value == value);

  String toJson() => value;

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

  SignedCertificateTimestamp({
    required this.status,
    required this.origin,
    required this.logDescription,
    required this.logId,
    required this.timestamp,
    required this.hashAlgorithm,
    required this.signatureAlgorithm,
    required this.signatureData,
  });

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

  /// The signature algorithm used by the server in the TLS server signature,
  /// represented as a TLS SignatureScheme code point. Omitted if not
  /// applicable or not known.
  final int? serverSignatureAlgorithm;

  /// Whether the connection used Encrypted ClientHello
  final bool encryptedClientHello;

  SecurityDetails({
    required this.protocol,
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
    required this.certificateTransparencyCompliance,
    this.serverSignatureAlgorithm,
    required this.encryptedClientHello,
  });

  factory SecurityDetails.fromJson(Map<String, dynamic> json) {
    return SecurityDetails(
      protocol: json['protocol'] as String,
      keyExchange: json['keyExchange'] as String,
      keyExchangeGroup: json.containsKey('keyExchangeGroup')
          ? json['keyExchangeGroup'] as String
          : null,
      cipher: json['cipher'] as String,
      mac: json.containsKey('mac') ? json['mac'] as String : null,
      certificateId: security.CertificateId.fromJson(
        json['certificateId'] as int,
      ),
      subjectName: json['subjectName'] as String,
      sanList: (json['sanList'] as List).map((e) => e as String).toList(),
      issuer: json['issuer'] as String,
      validFrom: TimeSinceEpoch.fromJson(json['validFrom'] as num),
      validTo: TimeSinceEpoch.fromJson(json['validTo'] as num),
      signedCertificateTimestampList:
          (json['signedCertificateTimestampList'] as List)
              .map(
                (e) => SignedCertificateTimestamp.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
      certificateTransparencyCompliance:
          CertificateTransparencyCompliance.fromJson(
            json['certificateTransparencyCompliance'] as String,
          ),
      serverSignatureAlgorithm: json.containsKey('serverSignatureAlgorithm')
          ? json['serverSignatureAlgorithm'] as int
          : null,
      encryptedClientHello: json['encryptedClientHello'] as bool? ?? false,
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
      'signedCertificateTimestampList': signedCertificateTimestampList
          .map((e) => e.toJson())
          .toList(),
      'certificateTransparencyCompliance': certificateTransparencyCompliance
          .toJson(),
      'encryptedClientHello': encryptedClientHello,
      if (keyExchangeGroup != null) 'keyExchangeGroup': keyExchangeGroup,
      if (mac != null) 'mac': mac,
      if (serverSignatureAlgorithm != null)
        'serverSignatureAlgorithm': serverSignatureAlgorithm,
    };
  }
}

/// Whether the request complied with Certificate Transparency policy.
enum CertificateTransparencyCompliance {
  unknown('unknown'),
  notCompliant('not-compliant'),
  compliant('compliant');

  final String value;

  const CertificateTransparencyCompliance(this.value);

  factory CertificateTransparencyCompliance.fromJson(String value) =>
      CertificateTransparencyCompliance.values.firstWhere(
        (e) => e.value == value,
      );

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// The reason why request was blocked.
enum BlockedReason {
  other('other'),
  csp('csp'),
  mixedContent('mixed-content'),
  origin('origin'),
  inspector('inspector'),
  integrity('integrity'),
  subresourceFilter('subresource-filter'),
  contentType('content-type'),
  coepFrameResourceNeedsCoepHeader('coep-frame-resource-needs-coep-header'),
  coopSandboxedIframeCannotNavigateToCoopPage(
    'coop-sandboxed-iframe-cannot-navigate-to-coop-page',
  ),
  corpNotSameOrigin('corp-not-same-origin'),
  corpNotSameOriginAfterDefaultedToSameOriginByCoep(
    'corp-not-same-origin-after-defaulted-to-same-origin-by-coep',
  ),
  corpNotSameOriginAfterDefaultedToSameOriginByDip(
    'corp-not-same-origin-after-defaulted-to-same-origin-by-dip',
  ),
  corpNotSameOriginAfterDefaultedToSameOriginByCoepAndDip(
    'corp-not-same-origin-after-defaulted-to-same-origin-by-coep-and-dip',
  ),
  corpNotSameSite('corp-not-same-site'),
  sriMessageSignatureMismatch('sri-message-signature-mismatch');

  final String value;

  const BlockedReason(this.value);

  factory BlockedReason.fromJson(String value) =>
      BlockedReason.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// The reason why request was blocked.
enum CorsError {
  disallowedByMode('DisallowedByMode'),
  invalidResponse('InvalidResponse'),
  wildcardOriginNotAllowed('WildcardOriginNotAllowed'),
  missingAllowOriginHeader('MissingAllowOriginHeader'),
  multipleAllowOriginValues('MultipleAllowOriginValues'),
  invalidAllowOriginValue('InvalidAllowOriginValue'),
  allowOriginMismatch('AllowOriginMismatch'),
  invalidAllowCredentials('InvalidAllowCredentials'),
  corsDisabledScheme('CorsDisabledScheme'),
  preflightInvalidStatus('PreflightInvalidStatus'),
  preflightDisallowedRedirect('PreflightDisallowedRedirect'),
  preflightWildcardOriginNotAllowed('PreflightWildcardOriginNotAllowed'),
  preflightMissingAllowOriginHeader('PreflightMissingAllowOriginHeader'),
  preflightMultipleAllowOriginValues('PreflightMultipleAllowOriginValues'),
  preflightInvalidAllowOriginValue('PreflightInvalidAllowOriginValue'),
  preflightAllowOriginMismatch('PreflightAllowOriginMismatch'),
  preflightInvalidAllowCredentials('PreflightInvalidAllowCredentials'),
  preflightMissingAllowExternal('PreflightMissingAllowExternal'),
  preflightInvalidAllowExternal('PreflightInvalidAllowExternal'),
  preflightMissingAllowPrivateNetwork('PreflightMissingAllowPrivateNetwork'),
  preflightInvalidAllowPrivateNetwork('PreflightInvalidAllowPrivateNetwork'),
  invalidAllowMethodsPreflightResponse('InvalidAllowMethodsPreflightResponse'),
  invalidAllowHeadersPreflightResponse('InvalidAllowHeadersPreflightResponse'),
  methodDisallowedByPreflightResponse('MethodDisallowedByPreflightResponse'),
  headerDisallowedByPreflightResponse('HeaderDisallowedByPreflightResponse'),
  redirectContainsCredentials('RedirectContainsCredentials'),
  insecurePrivateNetwork('InsecurePrivateNetwork'),
  invalidPrivateNetworkAccess('InvalidPrivateNetworkAccess'),
  unexpectedPrivateNetworkAccess('UnexpectedPrivateNetworkAccess'),
  noCorsRedirectModeNotFollow('NoCorsRedirectModeNotFollow'),
  preflightMissingPrivateNetworkAccessId(
    'PreflightMissingPrivateNetworkAccessId',
  ),
  preflightMissingPrivateNetworkAccessName(
    'PreflightMissingPrivateNetworkAccessName',
  ),
  privateNetworkAccessPermissionUnavailable(
    'PrivateNetworkAccessPermissionUnavailable',
  ),
  privateNetworkAccessPermissionDenied('PrivateNetworkAccessPermissionDenied'),
  localNetworkAccessPermissionDenied('LocalNetworkAccessPermissionDenied');

  final String value;

  const CorsError(this.value);

  factory CorsError.fromJson(String value) =>
      CorsError.values.firstWhere((e) => e.value == value);

  String toJson() => value;

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
enum ServiceWorkerResponseSource {
  cacheStorage('cache-storage'),
  httpCache('http-cache'),
  fallbackCode('fallback-code'),
  network('network');

  final String value;

  const ServiceWorkerResponseSource(this.value);

  factory ServiceWorkerResponseSource.fromJson(String value) =>
      ServiceWorkerResponseSource.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Determines what type of Trust Token operation is executed and
/// depending on the type, some additional parameters. The values
/// are specified in third_party/blink/renderer/core/fetch/trust_token.idl.
class TrustTokenParams {
  final TrustTokenOperationType operation;

  /// Only set for "token-redemption" operation and determine whether
  /// to request a fresh SRR or use a still valid cached SRR.
  final TrustTokenParamsRefreshPolicy refreshPolicy;

  /// Origins of issuers from whom to request tokens or redemption
  /// records.
  final List<String>? issuers;

  TrustTokenParams({
    required this.operation,
    required this.refreshPolicy,
    this.issuers,
  });

  factory TrustTokenParams.fromJson(Map<String, dynamic> json) {
    return TrustTokenParams(
      operation: TrustTokenOperationType.fromJson(json['operation'] as String),
      refreshPolicy: TrustTokenParamsRefreshPolicy.fromJson(
        json['refreshPolicy'] as String,
      ),
      issuers: json.containsKey('issuers')
          ? (json['issuers'] as List).map((e) => e as String).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operation': operation.toJson(),
      'refreshPolicy': refreshPolicy,
      if (issuers != null) 'issuers': [...?issuers],
    };
  }
}

enum TrustTokenParamsRefreshPolicy {
  useCached('UseCached'),
  refresh('Refresh');

  final String value;

  const TrustTokenParamsRefreshPolicy(this.value);

  factory TrustTokenParamsRefreshPolicy.fromJson(String value) =>
      TrustTokenParamsRefreshPolicy.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum TrustTokenOperationType {
  issuance('Issuance'),
  redemption('Redemption'),
  signing('Signing');

  final String value;

  const TrustTokenOperationType(this.value);

  factory TrustTokenOperationType.fromJson(String value) =>
      TrustTokenOperationType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// The reason why Chrome uses a specific transport protocol for HTTP semantics.
enum AlternateProtocolUsage {
  alternativeJobWonWithoutRace('alternativeJobWonWithoutRace'),
  alternativeJobWonRace('alternativeJobWonRace'),
  mainJobWonRace('mainJobWonRace'),
  mappingMissing('mappingMissing'),
  broken('broken'),
  dnsAlpnH3JobWonWithoutRace('dnsAlpnH3JobWonWithoutRace'),
  dnsAlpnH3JobWonRace('dnsAlpnH3JobWonRace'),
  unspecifiedReason('unspecifiedReason');

  final String value;

  const AlternateProtocolUsage(this.value);

  factory AlternateProtocolUsage.fromJson(String value) =>
      AlternateProtocolUsage.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Source of service worker router.
enum ServiceWorkerRouterSource {
  network('network'),
  cache('cache'),
  fetchEvent('fetch-event'),
  raceNetworkAndFetchHandler('race-network-and-fetch-handler'),
  raceNetworkAndCache('race-network-and-cache');

  final String value;

  const ServiceWorkerRouterSource(this.value);

  factory ServiceWorkerRouterSource.fromJson(String value) =>
      ServiceWorkerRouterSource.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class ServiceWorkerRouterInfo {
  /// ID of the rule matched. If there is a matched rule, this field will
  /// be set, otherwiser no value will be set.
  final int? ruleIdMatched;

  /// The router source of the matched rule. If there is a matched rule, this
  /// field will be set, otherwise no value will be set.
  final ServiceWorkerRouterSource? matchedSourceType;

  /// The actual router source used.
  final ServiceWorkerRouterSource? actualSourceType;

  ServiceWorkerRouterInfo({
    this.ruleIdMatched,
    this.matchedSourceType,
    this.actualSourceType,
  });

  factory ServiceWorkerRouterInfo.fromJson(Map<String, dynamic> json) {
    return ServiceWorkerRouterInfo(
      ruleIdMatched: json.containsKey('ruleIdMatched')
          ? json['ruleIdMatched'] as int
          : null,
      matchedSourceType: json.containsKey('matchedSourceType')
          ? ServiceWorkerRouterSource.fromJson(
              json['matchedSourceType'] as String,
            )
          : null,
      actualSourceType: json.containsKey('actualSourceType')
          ? ServiceWorkerRouterSource.fromJson(
              json['actualSourceType'] as String,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (ruleIdMatched != null) 'ruleIdMatched': ruleIdMatched,
      if (matchedSourceType != null)
        'matchedSourceType': matchedSourceType!.toJson(),
      if (actualSourceType != null)
        'actualSourceType': actualSourceType!.toJson(),
    };
  }
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

  /// Resource charset as determined by the browser (if applicable).
  final String charset;

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

  /// Specifies that the request was served from the prefetch cache.
  final bool? fromEarlyHints;

  /// Information about how ServiceWorker Static Router API was used. If this
  /// field is set with `matchedSourceType` field, a matching rule is found.
  /// If this field is set without `matchedSource`, no matching rule is found.
  /// Otherwise, the API is not used.
  final ServiceWorkerRouterInfo? serviceWorkerRouterInfo;

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

  /// The reason why Chrome uses a specific transport protocol for HTTP semantics.
  final AlternateProtocolUsage? alternateProtocolUsage;

  /// Security state of the request resource.
  final security.SecurityState securityState;

  /// Security details for the request.
  final SecurityDetails? securityDetails;

  /// Indicates whether the request was sent through IP Protection proxies. If
  /// set to true, the request used the IP Protection privacy feature.
  final bool? isIpProtectionUsed;

  ResponseData({
    required this.url,
    required this.status,
    required this.statusText,
    required this.headers,
    required this.mimeType,
    required this.charset,
    this.requestHeaders,
    required this.connectionReused,
    required this.connectionId,
    this.remoteIPAddress,
    this.remotePort,
    this.fromDiskCache,
    this.fromServiceWorker,
    this.fromPrefetchCache,
    this.fromEarlyHints,
    this.serviceWorkerRouterInfo,
    required this.encodedDataLength,
    this.timing,
    this.serviceWorkerResponseSource,
    this.responseTime,
    this.cacheStorageCacheName,
    this.protocol,
    this.alternateProtocolUsage,
    required this.securityState,
    this.securityDetails,
    this.isIpProtectionUsed,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      url: json['url'] as String,
      status: json['status'] as int,
      statusText: json['statusText'] as String,
      headers: Headers.fromJson(json['headers'] as Map<String, dynamic>),
      mimeType: json['mimeType'] as String,
      charset: json['charset'] as String,
      requestHeaders: json.containsKey('requestHeaders')
          ? Headers.fromJson(json['requestHeaders'] as Map<String, dynamic>)
          : null,
      connectionReused: json['connectionReused'] as bool? ?? false,
      connectionId: json['connectionId'] as num,
      remoteIPAddress: json.containsKey('remoteIPAddress')
          ? json['remoteIPAddress'] as String
          : null,
      remotePort: json.containsKey('remotePort')
          ? json['remotePort'] as int
          : null,
      fromDiskCache: json.containsKey('fromDiskCache')
          ? json['fromDiskCache'] as bool
          : null,
      fromServiceWorker: json.containsKey('fromServiceWorker')
          ? json['fromServiceWorker'] as bool
          : null,
      fromPrefetchCache: json.containsKey('fromPrefetchCache')
          ? json['fromPrefetchCache'] as bool
          : null,
      fromEarlyHints: json.containsKey('fromEarlyHints')
          ? json['fromEarlyHints'] as bool
          : null,
      serviceWorkerRouterInfo: json.containsKey('serviceWorkerRouterInfo')
          ? ServiceWorkerRouterInfo.fromJson(
              json['serviceWorkerRouterInfo'] as Map<String, dynamic>,
            )
          : null,
      encodedDataLength: json['encodedDataLength'] as num,
      timing: json.containsKey('timing')
          ? ResourceTiming.fromJson(json['timing'] as Map<String, dynamic>)
          : null,
      serviceWorkerResponseSource:
          json.containsKey('serviceWorkerResponseSource')
          ? ServiceWorkerResponseSource.fromJson(
              json['serviceWorkerResponseSource'] as String,
            )
          : null,
      responseTime: json.containsKey('responseTime')
          ? TimeSinceEpoch.fromJson(json['responseTime'] as num)
          : null,
      cacheStorageCacheName: json.containsKey('cacheStorageCacheName')
          ? json['cacheStorageCacheName'] as String
          : null,
      protocol: json.containsKey('protocol')
          ? json['protocol'] as String
          : null,
      alternateProtocolUsage: json.containsKey('alternateProtocolUsage')
          ? AlternateProtocolUsage.fromJson(
              json['alternateProtocolUsage'] as String,
            )
          : null,
      securityState: security.SecurityState.fromJson(
        json['securityState'] as String,
      ),
      securityDetails: json.containsKey('securityDetails')
          ? SecurityDetails.fromJson(
              json['securityDetails'] as Map<String, dynamic>,
            )
          : null,
      isIpProtectionUsed: json.containsKey('isIpProtectionUsed')
          ? json['isIpProtectionUsed'] as bool
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
      'charset': charset,
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
      if (fromEarlyHints != null) 'fromEarlyHints': fromEarlyHints,
      if (serviceWorkerRouterInfo != null)
        'serviceWorkerRouterInfo': serviceWorkerRouterInfo!.toJson(),
      if (timing != null) 'timing': timing!.toJson(),
      if (serviceWorkerResponseSource != null)
        'serviceWorkerResponseSource': serviceWorkerResponseSource!.toJson(),
      if (responseTime != null) 'responseTime': responseTime!.toJson(),
      if (cacheStorageCacheName != null)
        'cacheStorageCacheName': cacheStorageCacheName,
      if (protocol != null) 'protocol': protocol,
      if (alternateProtocolUsage != null)
        'alternateProtocolUsage': alternateProtocolUsage!.toJson(),
      if (securityDetails != null) 'securityDetails': securityDetails!.toJson(),
      if (isIpProtectionUsed != null) 'isIpProtectionUsed': isIpProtectionUsed,
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
    return {'headers': headers.toJson()};
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

  WebSocketResponse({
    required this.status,
    required this.statusText,
    required this.headers,
    this.headersText,
    this.requestHeaders,
    this.requestHeadersText,
  });

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

  WebSocketFrame({
    required this.opcode,
    required this.mask,
    required this.payloadData,
  });

  factory WebSocketFrame.fromJson(Map<String, dynamic> json) {
    return WebSocketFrame(
      opcode: json['opcode'] as num,
      mask: json['mask'] as bool? ?? false,
      payloadData: json['payloadData'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'opcode': opcode, 'mask': mask, 'payloadData': payloadData};
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

  CachedResource({
    required this.url,
    required this.type,
    this.response,
    required this.bodySize,
  });

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
  /// Requires the Debugger domain to be enabled.
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

  Initiator({
    required this.type,
    this.stack,
    this.url,
    this.lineNumber,
    this.columnNumber,
    this.requestId,
  });

  factory Initiator.fromJson(Map<String, dynamic> json) {
    return Initiator(
      type: InitiatorType.fromJson(json['type'] as String),
      stack: json.containsKey('stack')
          ? runtime.StackTraceData.fromJson(
              json['stack'] as Map<String, dynamic>,
            )
          : null,
      url: json.containsKey('url') ? json['url'] as String : null,
      lineNumber: json.containsKey('lineNumber')
          ? json['lineNumber'] as num
          : null,
      columnNumber: json.containsKey('columnNumber')
          ? json['columnNumber'] as num
          : null,
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

enum InitiatorType {
  parser('parser'),
  script('script'),
  preload('preload'),
  signedExchange('SignedExchange'),
  preflight('preflight'),
  other('other');

  final String value;

  const InitiatorType(this.value);

  factory InitiatorType.fromJson(String value) =>
      InitiatorType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// cookiePartitionKey object
/// The representation of the components of the key that are created by the cookiePartitionKey class contained in net/cookies/cookie_partition_key.h.
class CookiePartitionKey {
  /// The site of the top-level URL the browser was visiting at the start
  /// of the request to the endpoint that set the cookie.
  final String topLevelSite;

  /// Indicates if the cookie has any ancestors that are cross-site to the topLevelSite.
  final bool hasCrossSiteAncestor;

  CookiePartitionKey({
    required this.topLevelSite,
    required this.hasCrossSiteAncestor,
  });

  factory CookiePartitionKey.fromJson(Map<String, dynamic> json) {
    return CookiePartitionKey(
      topLevelSite: json['topLevelSite'] as String,
      hasCrossSiteAncestor: json['hasCrossSiteAncestor'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topLevelSite': topLevelSite,
      'hasCrossSiteAncestor': hasCrossSiteAncestor,
    };
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
  final CookieSameSite? sameSite;

  /// Cookie Priority
  final CookiePriority priority;

  /// Cookie source scheme type.
  final CookieSourceScheme sourceScheme;

  /// Cookie source port. Valid values are {-1, [1, 65535]}, -1 indicates an unspecified port.
  /// An unspecified port value allows protocol clients to emulate legacy cookie scope for the port.
  /// This is a temporary ability and it will be removed in the future.
  final int sourcePort;

  /// Cookie partition key.
  final CookiePartitionKey? partitionKey;

  /// True if cookie partition key is opaque.
  final bool? partitionKeyOpaque;

  Cookie({
    required this.name,
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
    required this.sourceScheme,
    required this.sourcePort,
    this.partitionKey,
    this.partitionKeyOpaque,
  });

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
      sourceScheme: CookieSourceScheme.fromJson(json['sourceScheme'] as String),
      sourcePort: json['sourcePort'] as int,
      partitionKey: json.containsKey('partitionKey')
          ? CookiePartitionKey.fromJson(
              json['partitionKey'] as Map<String, dynamic>,
            )
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
      'sourceScheme': sourceScheme.toJson(),
      'sourcePort': sourcePort,
      if (sameSite != null) 'sameSite': sameSite!.toJson(),
      if (partitionKey != null) 'partitionKey': partitionKey!.toJson(),
      if (partitionKeyOpaque != null) 'partitionKeyOpaque': partitionKeyOpaque,
    };
  }
}

/// Types of reasons why a cookie may not be stored from a response.
enum SetCookieBlockedReason {
  secureOnly('SecureOnly'),
  sameSiteStrict('SameSiteStrict'),
  sameSiteLax('SameSiteLax'),
  sameSiteUnspecifiedTreatedAsLax('SameSiteUnspecifiedTreatedAsLax'),
  sameSiteNoneInsecure('SameSiteNoneInsecure'),
  userPreferences('UserPreferences'),
  thirdPartyPhaseout('ThirdPartyPhaseout'),
  thirdPartyBlockedInFirstPartySet('ThirdPartyBlockedInFirstPartySet'),
  syntaxError('SyntaxError'),
  schemeNotSupported('SchemeNotSupported'),
  overwriteSecure('OverwriteSecure'),
  invalidDomain('InvalidDomain'),
  invalidPrefix('InvalidPrefix'),
  unknownError('UnknownError'),
  schemefulSameSiteStrict('SchemefulSameSiteStrict'),
  schemefulSameSiteLax('SchemefulSameSiteLax'),
  schemefulSameSiteUnspecifiedTreatedAsLax(
    'SchemefulSameSiteUnspecifiedTreatedAsLax',
  ),
  samePartyFromCrossPartyContext('SamePartyFromCrossPartyContext'),
  samePartyConflictsWithOtherAttributes(
    'SamePartyConflictsWithOtherAttributes',
  ),
  nameValuePairExceedsMaxSize('NameValuePairExceedsMaxSize'),
  disallowedCharacter('DisallowedCharacter'),
  noCookieContent('NoCookieContent');

  final String value;

  const SetCookieBlockedReason(this.value);

  factory SetCookieBlockedReason.fromJson(String value) =>
      SetCookieBlockedReason.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Types of reasons why a cookie may not be sent with a request.
enum CookieBlockedReason {
  secureOnly('SecureOnly'),
  notOnPath('NotOnPath'),
  domainMismatch('DomainMismatch'),
  sameSiteStrict('SameSiteStrict'),
  sameSiteLax('SameSiteLax'),
  sameSiteUnspecifiedTreatedAsLax('SameSiteUnspecifiedTreatedAsLax'),
  sameSiteNoneInsecure('SameSiteNoneInsecure'),
  userPreferences('UserPreferences'),
  thirdPartyPhaseout('ThirdPartyPhaseout'),
  thirdPartyBlockedInFirstPartySet('ThirdPartyBlockedInFirstPartySet'),
  unknownError('UnknownError'),
  schemefulSameSiteStrict('SchemefulSameSiteStrict'),
  schemefulSameSiteLax('SchemefulSameSiteLax'),
  schemefulSameSiteUnspecifiedTreatedAsLax(
    'SchemefulSameSiteUnspecifiedTreatedAsLax',
  ),
  samePartyFromCrossPartyContext('SamePartyFromCrossPartyContext'),
  nameValuePairExceedsMaxSize('NameValuePairExceedsMaxSize'),
  portMismatch('PortMismatch'),
  schemeMismatch('SchemeMismatch'),
  anonymousContext('AnonymousContext');

  final String value;

  const CookieBlockedReason(this.value);

  factory CookieBlockedReason.fromJson(String value) =>
      CookieBlockedReason.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Types of reasons why a cookie should have been blocked by 3PCD but is exempted for the request.
enum CookieExemptionReason {
  none('None'),
  userSetting('UserSetting'),
  tpcdMetadata('TPCDMetadata'),
  tpcdDeprecationTrial('TPCDDeprecationTrial'),
  topLevelTpcdDeprecationTrial('TopLevelTPCDDeprecationTrial'),
  tpcdHeuristics('TPCDHeuristics'),
  enterprisePolicy('EnterprisePolicy'),
  storageAccess('StorageAccess'),
  topLevelStorageAccess('TopLevelStorageAccess'),
  scheme('Scheme'),
  sameSiteNoneCookiesInSandbox('SameSiteNoneCookiesInSandbox');

  final String value;

  const CookieExemptionReason(this.value);

  factory CookieExemptionReason.fromJson(String value) =>
      CookieExemptionReason.values.firstWhere((e) => e.value == value);

  String toJson() => value;

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

  BlockedSetCookieWithReason({
    required this.blockedReasons,
    required this.cookieLine,
    this.cookie,
  });

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

/// A cookie should have been blocked by 3PCD but is exempted and stored from a response with the
/// corresponding reason. A cookie could only have at most one exemption reason.
class ExemptedSetCookieWithReason {
  /// The reason the cookie was exempted.
  final CookieExemptionReason exemptionReason;

  /// The string representing this individual cookie as it would appear in the header.
  final String cookieLine;

  /// The cookie object representing the cookie.
  final Cookie cookie;

  ExemptedSetCookieWithReason({
    required this.exemptionReason,
    required this.cookieLine,
    required this.cookie,
  });

  factory ExemptedSetCookieWithReason.fromJson(Map<String, dynamic> json) {
    return ExemptedSetCookieWithReason(
      exemptionReason: CookieExemptionReason.fromJson(
        json['exemptionReason'] as String,
      ),
      cookieLine: json['cookieLine'] as String,
      cookie: Cookie.fromJson(json['cookie'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exemptionReason': exemptionReason.toJson(),
      'cookieLine': cookieLine,
      'cookie': cookie.toJson(),
    };
  }
}

/// A cookie associated with the request which may or may not be sent with it.
/// Includes the cookies itself and reasons for blocking or exemption.
class AssociatedCookie {
  /// The cookie object representing the cookie which was not sent.
  final Cookie cookie;

  /// The reason(s) the cookie was blocked. If empty means the cookie is included.
  final List<CookieBlockedReason> blockedReasons;

  /// The reason the cookie should have been blocked by 3PCD but is exempted. A cookie could
  /// only have at most one exemption reason.
  final CookieExemptionReason? exemptionReason;

  AssociatedCookie({
    required this.cookie,
    required this.blockedReasons,
    this.exemptionReason,
  });

  factory AssociatedCookie.fromJson(Map<String, dynamic> json) {
    return AssociatedCookie(
      cookie: Cookie.fromJson(json['cookie'] as Map<String, dynamic>),
      blockedReasons: (json['blockedReasons'] as List)
          .map((e) => CookieBlockedReason.fromJson(e as String))
          .toList(),
      exemptionReason: json.containsKey('exemptionReason')
          ? CookieExemptionReason.fromJson(json['exemptionReason'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cookie': cookie.toJson(),
      'blockedReasons': blockedReasons.map((e) => e.toJson()).toList(),
      if (exemptionReason != null) 'exemptionReason': exemptionReason!.toJson(),
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

  /// Cookie partition key. If not set, the cookie will be set as not partitioned.
  final CookiePartitionKey? partitionKey;

  CookieParam({
    required this.name,
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
    this.partitionKey,
  });

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
      sameParty: json.containsKey('sameParty')
          ? json['sameParty'] as bool
          : null,
      sourceScheme: json.containsKey('sourceScheme')
          ? CookieSourceScheme.fromJson(json['sourceScheme'] as String)
          : null,
      sourcePort: json.containsKey('sourcePort')
          ? json['sourcePort'] as int
          : null,
      partitionKey: json.containsKey('partitionKey')
          ? CookiePartitionKey.fromJson(
              json['partitionKey'] as Map<String, dynamic>,
            )
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
      if (partitionKey != null) 'partitionKey': partitionKey!.toJson(),
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

  AuthChallenge({
    this.source,
    required this.origin,
    required this.scheme,
    required this.realm,
  });

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

enum AuthChallengeSource {
  server('Server'),
  proxy('Proxy');

  final String value;

  const AuthChallengeSource(this.value);

  factory AuthChallengeSource.fromJson(String value) =>
      AuthChallengeSource.values.firstWhere((e) => e.value == value);

  String toJson() => value;

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
      response: AuthChallengeResponseResponse.fromJson(
        json['response'] as String,
      ),
      username: json.containsKey('username')
          ? json['username'] as String
          : null,
      password: json.containsKey('password')
          ? json['password'] as String
          : null,
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

enum AuthChallengeResponseResponse {
  default$('Default'),
  cancelAuth('CancelAuth'),
  provideCredentials('ProvideCredentials');

  final String value;

  const AuthChallengeResponseResponse(this.value);

  factory AuthChallengeResponseResponse.fromJson(String value) =>
      AuthChallengeResponseResponse.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Stages of the interception to begin intercepting. Request will intercept before the request is
/// sent. Response will intercept after the response is received.
enum InterceptionStage {
  request('Request'),
  headersReceived('HeadersReceived');

  final String value;

  const InterceptionStage(this.value);

  factory InterceptionStage.fromJson(String value) =>
      InterceptionStage.values.firstWhere((e) => e.value == value);

  String toJson() => value;

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
      urlPattern: json.containsKey('urlPattern')
          ? json['urlPattern'] as String
          : null,
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

  SignedExchangeSignature({
    required this.label,
    required this.signature,
    required this.integrity,
    this.certUrl,
    this.certSha256,
    required this.validityUrl,
    required this.date,
    required this.expires,
    this.certificates,
  });

  factory SignedExchangeSignature.fromJson(Map<String, dynamic> json) {
    return SignedExchangeSignature(
      label: json['label'] as String,
      signature: json['signature'] as String,
      integrity: json['integrity'] as String,
      certUrl: json.containsKey('certUrl') ? json['certUrl'] as String : null,
      certSha256: json.containsKey('certSha256')
          ? json['certSha256'] as String
          : null,
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

  /// Signed exchange header integrity hash in the form of `sha256-<base64-hash-value>`.
  final String headerIntegrity;

  SignedExchangeHeader({
    required this.requestUrl,
    required this.responseCode,
    required this.responseHeaders,
    required this.signatures,
    required this.headerIntegrity,
  });

  factory SignedExchangeHeader.fromJson(Map<String, dynamic> json) {
    return SignedExchangeHeader(
      requestUrl: json['requestUrl'] as String,
      responseCode: json['responseCode'] as int,
      responseHeaders: Headers.fromJson(
        json['responseHeaders'] as Map<String, dynamic>,
      ),
      signatures: (json['signatures'] as List)
          .map(
            (e) => SignedExchangeSignature.fromJson(e as Map<String, dynamic>),
          )
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
enum SignedExchangeErrorField {
  signatureSig('signatureSig'),
  signatureIntegrity('signatureIntegrity'),
  signatureCertUrl('signatureCertUrl'),
  signatureCertSha256('signatureCertSha256'),
  signatureValidityUrl('signatureValidityUrl'),
  signatureTimestamps('signatureTimestamps');

  final String value;

  const SignedExchangeErrorField(this.value);

  factory SignedExchangeErrorField.fromJson(String value) =>
      SignedExchangeErrorField.values.firstWhere((e) => e.value == value);

  String toJson() => value;

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

  SignedExchangeError({
    required this.message,
    this.signatureIndex,
    this.errorField,
  });

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

  /// Whether network response for the signed exchange was accompanied by
  /// extra headers.
  final bool hasExtraInfo;

  /// Information about the signed exchange header.
  final SignedExchangeHeader? header;

  /// Security details for the signed exchange header.
  final SecurityDetails? securityDetails;

  /// Errors occurred while handling the signed exchange.
  final List<SignedExchangeError>? errors;

  SignedExchangeInfo({
    required this.outerResponse,
    required this.hasExtraInfo,
    this.header,
    this.securityDetails,
    this.errors,
  });

  factory SignedExchangeInfo.fromJson(Map<String, dynamic> json) {
    return SignedExchangeInfo(
      outerResponse: ResponseData.fromJson(
        json['outerResponse'] as Map<String, dynamic>,
      ),
      hasExtraInfo: json['hasExtraInfo'] as bool? ?? false,
      header: json.containsKey('header')
          ? SignedExchangeHeader.fromJson(
              json['header'] as Map<String, dynamic>,
            )
          : null,
      securityDetails: json.containsKey('securityDetails')
          ? SecurityDetails.fromJson(
              json['securityDetails'] as Map<String, dynamic>,
            )
          : null,
      errors: json.containsKey('errors')
          ? (json['errors'] as List)
                .map(
                  (e) =>
                      SignedExchangeError.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'outerResponse': outerResponse.toJson(),
      'hasExtraInfo': hasExtraInfo,
      if (header != null) 'header': header!.toJson(),
      if (securityDetails != null) 'securityDetails': securityDetails!.toJson(),
      if (errors != null) 'errors': errors!.map((e) => e.toJson()).toList(),
    };
  }
}

/// List of content encodings supported by the backend.
enum ContentEncoding {
  deflate('deflate'),
  gzip('gzip'),
  br('br'),
  zstd('zstd');

  final String value;

  const ContentEncoding(this.value);

  factory ContentEncoding.fromJson(String value) =>
      ContentEncoding.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum DirectSocketDnsQueryType {
  ipv4('ipv4'),
  ipv6('ipv6');

  final String value;

  const DirectSocketDnsQueryType(this.value);

  factory DirectSocketDnsQueryType.fromJson(String value) =>
      DirectSocketDnsQueryType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class DirectTCPSocketOptions {
  /// TCP_NODELAY option
  final bool noDelay;

  /// Expected to be unsigned integer.
  final num? keepAliveDelay;

  /// Expected to be unsigned integer.
  final num? sendBufferSize;

  /// Expected to be unsigned integer.
  final num? receiveBufferSize;

  final DirectSocketDnsQueryType? dnsQueryType;

  DirectTCPSocketOptions({
    required this.noDelay,
    this.keepAliveDelay,
    this.sendBufferSize,
    this.receiveBufferSize,
    this.dnsQueryType,
  });

  factory DirectTCPSocketOptions.fromJson(Map<String, dynamic> json) {
    return DirectTCPSocketOptions(
      noDelay: json['noDelay'] as bool? ?? false,
      keepAliveDelay: json.containsKey('keepAliveDelay')
          ? json['keepAliveDelay'] as num
          : null,
      sendBufferSize: json.containsKey('sendBufferSize')
          ? json['sendBufferSize'] as num
          : null,
      receiveBufferSize: json.containsKey('receiveBufferSize')
          ? json['receiveBufferSize'] as num
          : null,
      dnsQueryType: json.containsKey('dnsQueryType')
          ? DirectSocketDnsQueryType.fromJson(json['dnsQueryType'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noDelay': noDelay,
      if (keepAliveDelay != null) 'keepAliveDelay': keepAliveDelay,
      if (sendBufferSize != null) 'sendBufferSize': sendBufferSize,
      if (receiveBufferSize != null) 'receiveBufferSize': receiveBufferSize,
      if (dnsQueryType != null) 'dnsQueryType': dnsQueryType!.toJson(),
    };
  }
}

class DirectUDPSocketOptions {
  final String? remoteAddr;

  /// Unsigned int 16.
  final int? remotePort;

  final String? localAddr;

  /// Unsigned int 16.
  final int? localPort;

  final DirectSocketDnsQueryType? dnsQueryType;

  /// Expected to be unsigned integer.
  final num? sendBufferSize;

  /// Expected to be unsigned integer.
  final num? receiveBufferSize;

  DirectUDPSocketOptions({
    this.remoteAddr,
    this.remotePort,
    this.localAddr,
    this.localPort,
    this.dnsQueryType,
    this.sendBufferSize,
    this.receiveBufferSize,
  });

  factory DirectUDPSocketOptions.fromJson(Map<String, dynamic> json) {
    return DirectUDPSocketOptions(
      remoteAddr: json.containsKey('remoteAddr')
          ? json['remoteAddr'] as String
          : null,
      remotePort: json.containsKey('remotePort')
          ? json['remotePort'] as int
          : null,
      localAddr: json.containsKey('localAddr')
          ? json['localAddr'] as String
          : null,
      localPort: json.containsKey('localPort')
          ? json['localPort'] as int
          : null,
      dnsQueryType: json.containsKey('dnsQueryType')
          ? DirectSocketDnsQueryType.fromJson(json['dnsQueryType'] as String)
          : null,
      sendBufferSize: json.containsKey('sendBufferSize')
          ? json['sendBufferSize'] as num
          : null,
      receiveBufferSize: json.containsKey('receiveBufferSize')
          ? json['receiveBufferSize'] as num
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (remoteAddr != null) 'remoteAddr': remoteAddr,
      if (remotePort != null) 'remotePort': remotePort,
      if (localAddr != null) 'localAddr': localAddr,
      if (localPort != null) 'localPort': localPort,
      if (dnsQueryType != null) 'dnsQueryType': dnsQueryType!.toJson(),
      if (sendBufferSize != null) 'sendBufferSize': sendBufferSize,
      if (receiveBufferSize != null) 'receiveBufferSize': receiveBufferSize,
    };
  }
}

class DirectUDPMessage {
  final String data;

  /// Null for connected mode.
  final String? remoteAddr;

  /// Null for connected mode.
  /// Expected to be unsigned integer.
  final int? remotePort;

  DirectUDPMessage({required this.data, this.remoteAddr, this.remotePort});

  factory DirectUDPMessage.fromJson(Map<String, dynamic> json) {
    return DirectUDPMessage(
      data: json['data'] as String,
      remoteAddr: json.containsKey('remoteAddr')
          ? json['remoteAddr'] as String
          : null,
      remotePort: json.containsKey('remotePort')
          ? json['remotePort'] as int
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      if (remoteAddr != null) 'remoteAddr': remoteAddr,
      if (remotePort != null) 'remotePort': remotePort,
    };
  }
}

enum PrivateNetworkRequestPolicy {
  allow('Allow'),
  blockFromInsecureToMorePrivate('BlockFromInsecureToMorePrivate'),
  warnFromInsecureToMorePrivate('WarnFromInsecureToMorePrivate'),
  preflightBlock('PreflightBlock'),
  preflightWarn('PreflightWarn'),
  permissionBlock('PermissionBlock'),
  permissionWarn('PermissionWarn');

  final String value;

  const PrivateNetworkRequestPolicy(this.value);

  factory PrivateNetworkRequestPolicy.fromJson(String value) =>
      PrivateNetworkRequestPolicy.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum IPAddressSpace {
  loopback('Loopback'),
  local('Local'),
  public('Public'),
  unknown('Unknown');

  final String value;

  const IPAddressSpace(this.value);

  factory IPAddressSpace.fromJson(String value) =>
      IPAddressSpace.values.firstWhere((e) => e.value == value);

  String toJson() => value;

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
    return ConnectTiming(requestTime: json['requestTime'] as num);
  }

  Map<String, dynamic> toJson() {
    return {'requestTime': requestTime};
  }
}

class ClientSecurityState {
  final bool initiatorIsSecureContext;

  final IPAddressSpace initiatorIPAddressSpace;

  final PrivateNetworkRequestPolicy privateNetworkRequestPolicy;

  ClientSecurityState({
    required this.initiatorIsSecureContext,
    required this.initiatorIPAddressSpace,
    required this.privateNetworkRequestPolicy,
  });

  factory ClientSecurityState.fromJson(Map<String, dynamic> json) {
    return ClientSecurityState(
      initiatorIsSecureContext:
          json['initiatorIsSecureContext'] as bool? ?? false,
      initiatorIPAddressSpace: IPAddressSpace.fromJson(
        json['initiatorIPAddressSpace'] as String,
      ),
      privateNetworkRequestPolicy: PrivateNetworkRequestPolicy.fromJson(
        json['privateNetworkRequestPolicy'] as String,
      ),
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

enum CrossOriginOpenerPolicyValue {
  sameOrigin('SameOrigin'),
  sameOriginAllowPopups('SameOriginAllowPopups'),
  restrictProperties('RestrictProperties'),
  unsafeNone('UnsafeNone'),
  sameOriginPlusCoep('SameOriginPlusCoep'),
  restrictPropertiesPlusCoep('RestrictPropertiesPlusCoep'),
  noopenerAllowPopups('NoopenerAllowPopups');

  final String value;

  const CrossOriginOpenerPolicyValue(this.value);

  factory CrossOriginOpenerPolicyValue.fromJson(String value) =>
      CrossOriginOpenerPolicyValue.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class CrossOriginOpenerPolicyStatus {
  final CrossOriginOpenerPolicyValue value;

  final CrossOriginOpenerPolicyValue reportOnlyValue;

  final String? reportingEndpoint;

  final String? reportOnlyReportingEndpoint;

  CrossOriginOpenerPolicyStatus({
    required this.value,
    required this.reportOnlyValue,
    this.reportingEndpoint,
    this.reportOnlyReportingEndpoint,
  });

  factory CrossOriginOpenerPolicyStatus.fromJson(Map<String, dynamic> json) {
    return CrossOriginOpenerPolicyStatus(
      value: CrossOriginOpenerPolicyValue.fromJson(json['value'] as String),
      reportOnlyValue: CrossOriginOpenerPolicyValue.fromJson(
        json['reportOnlyValue'] as String,
      ),
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

enum CrossOriginEmbedderPolicyValue {
  none('None'),
  credentialless('Credentialless'),
  requireCorp('RequireCorp');

  final String value;

  const CrossOriginEmbedderPolicyValue(this.value);

  factory CrossOriginEmbedderPolicyValue.fromJson(String value) =>
      CrossOriginEmbedderPolicyValue.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class CrossOriginEmbedderPolicyStatus {
  final CrossOriginEmbedderPolicyValue value;

  final CrossOriginEmbedderPolicyValue reportOnlyValue;

  final String? reportingEndpoint;

  final String? reportOnlyReportingEndpoint;

  CrossOriginEmbedderPolicyStatus({
    required this.value,
    required this.reportOnlyValue,
    this.reportingEndpoint,
    this.reportOnlyReportingEndpoint,
  });

  factory CrossOriginEmbedderPolicyStatus.fromJson(Map<String, dynamic> json) {
    return CrossOriginEmbedderPolicyStatus(
      value: CrossOriginEmbedderPolicyValue.fromJson(json['value'] as String),
      reportOnlyValue: CrossOriginEmbedderPolicyValue.fromJson(
        json['reportOnlyValue'] as String,
      ),
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

enum ContentSecurityPolicySource {
  http('HTTP'),
  meta('Meta');

  final String value;

  const ContentSecurityPolicySource(this.value);

  factory ContentSecurityPolicySource.fromJson(String value) =>
      ContentSecurityPolicySource.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class ContentSecurityPolicyStatus {
  final String effectiveDirectives;

  final bool isEnforced;

  final ContentSecurityPolicySource source;

  ContentSecurityPolicyStatus({
    required this.effectiveDirectives,
    required this.isEnforced,
    required this.source,
  });

  factory ContentSecurityPolicyStatus.fromJson(Map<String, dynamic> json) {
    return ContentSecurityPolicyStatus(
      effectiveDirectives: json['effectiveDirectives'] as String,
      isEnforced: json['isEnforced'] as bool? ?? false,
      source: ContentSecurityPolicySource.fromJson(json['source'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'effectiveDirectives': effectiveDirectives,
      'isEnforced': isEnforced,
      'source': source.toJson(),
    };
  }
}

class SecurityIsolationStatus {
  final CrossOriginOpenerPolicyStatus? coop;

  final CrossOriginEmbedderPolicyStatus? coep;

  final List<ContentSecurityPolicyStatus>? csp;

  SecurityIsolationStatus({this.coop, this.coep, this.csp});

  factory SecurityIsolationStatus.fromJson(Map<String, dynamic> json) {
    return SecurityIsolationStatus(
      coop: json.containsKey('coop')
          ? CrossOriginOpenerPolicyStatus.fromJson(
              json['coop'] as Map<String, dynamic>,
            )
          : null,
      coep: json.containsKey('coep')
          ? CrossOriginEmbedderPolicyStatus.fromJson(
              json['coep'] as Map<String, dynamic>,
            )
          : null,
      csp: json.containsKey('csp')
          ? (json['csp'] as List)
                .map(
                  (e) => ContentSecurityPolicyStatus.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (coop != null) 'coop': coop!.toJson(),
      if (coep != null) 'coep': coep!.toJson(),
      if (csp != null) 'csp': csp!.map((e) => e.toJson()).toList(),
    };
  }
}

/// The status of a Reporting API report.
enum ReportStatus {
  queued('Queued'),
  pending('Pending'),
  markedForRemoval('MarkedForRemoval'),
  success('Success');

  final String value;

  const ReportStatus(this.value);

  factory ReportStatus.fromJson(String value) =>
      ReportStatus.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

extension type ReportId(String value) {
  factory ReportId.fromJson(String value) => ReportId(value);

  String toJson() => value;
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

  ReportingApiReport({
    required this.id,
    required this.initiatorUrl,
    required this.destination,
    required this.type,
    required this.timestamp,
    required this.depth,
    required this.completedAttempts,
    required this.body,
    required this.status,
  });

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
    return {'url': url, 'groupName': groupName};
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

  LoadNetworkResourcePageResult({
    required this.success,
    this.netError,
    this.netErrorName,
    this.httpStatusCode,
    this.stream,
    this.headers,
  });

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

  LoadNetworkResourceOptions({
    required this.disableCache,
    required this.includeCredentials,
  });

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

enum TrustTokenOperationDoneEventStatus {
  ok('Ok'),
  invalidArgument('InvalidArgument'),
  missingIssuerKeys('MissingIssuerKeys'),
  failedPrecondition('FailedPrecondition'),
  resourceExhausted('ResourceExhausted'),
  alreadyExists('AlreadyExists'),
  resourceLimited('ResourceLimited'),
  unauthorized('Unauthorized'),
  badResponse('BadResponse'),
  internalError('InternalError'),
  unknownError('UnknownError'),
  fulfilledLocally('FulfilledLocally'),
  siteIssuerLimit('SiteIssuerLimit');

  final String value;

  const TrustTokenOperationDoneEventStatus(this.value);

  factory TrustTokenOperationDoneEventStatus.fromJson(String value) =>
      TrustTokenOperationDoneEventStatus.values.firstWhere(
        (e) => e.value == value,
      );

  String toJson() => value;

  @override
  String toString() => value.toString();
}
