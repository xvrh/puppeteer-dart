import 'dart:async';
import '../src/connection.dart';
import 'io.dart' as io;
import 'network.dart' as network;
import 'page.dart' as page;

/// A domain for letting clients substitute browser's network layer with client code.
class FetchApi {
  final Client _client;

  FetchApi(this._client);

  /// Issued when the domain is enabled and the request URL matches the
  /// specified filter. The request is paused until the client responds
  /// with one of continueRequest, failRequest or fulfillRequest.
  /// The stage of the request can be determined by presence of responseErrorReason
  /// and responseStatusCode -- the request is at the response stage if either
  /// of these fields is present and in the request stage otherwise.
  Stream<RequestPausedEvent> get onRequestPaused => _client.onEvent
      .where((event) => event.name == 'Fetch.requestPaused')
      .map((event) => RequestPausedEvent.fromJson(event.parameters));

  /// Issued when the domain is enabled with handleAuthRequests set to true.
  /// The request is paused until client responds with continueWithAuth.
  Stream<AuthRequiredEvent> get onAuthRequired => _client.onEvent
      .where((event) => event.name == 'Fetch.authRequired')
      .map((event) => AuthRequiredEvent.fromJson(event.parameters));

  /// Disables the fetch domain.
  Future<void> disable() async {
    await _client.send('Fetch.disable');
  }

  /// Enables issuing of requestPaused events. A request will be paused until client
  /// calls one of failRequest, fulfillRequest or continueRequest/continueWithAuth.
  /// [patterns] If specified, only requests matching any of these patterns will produce
  /// fetchRequested event and will be paused until clients response. If not set,
  /// all requests will be affected.
  /// [handleAuthRequests] If true, authRequired events will be issued and requests will be paused
  /// expecting a call to continueWithAuth.
  Future<void> enable(
      {List<RequestPattern>? patterns, bool? handleAuthRequests}) async {
    await _client.send('Fetch.enable', {
      if (patterns != null) 'patterns': [...patterns],
      if (handleAuthRequests != null) 'handleAuthRequests': handleAuthRequests,
    });
  }

  /// Causes the request to fail with specified reason.
  /// [requestId] An id the client received in requestPaused event.
  /// [errorReason] Causes the request to fail with the given reason.
  Future<void> failRequest(
      RequestId requestId, network.ErrorReason errorReason) async {
    await _client.send('Fetch.failRequest', {
      'requestId': requestId,
      'errorReason': errorReason,
    });
  }

  /// Provides response to the request.
  /// [requestId] An id the client received in requestPaused event.
  /// [responseCode] An HTTP response code.
  /// [responseHeaders] Response headers.
  /// [binaryResponseHeaders] Alternative way of specifying response headers as a \0-separated
  /// series of name: value pairs. Prefer the above method unless you
  /// need to represent some non-UTF8 values that can't be transmitted
  /// over the protocol as text.
  /// [body] A response body. If absent, original response body will be used if
  /// the request is intercepted at the response stage and empty body
  /// will be used if the request is intercepted at the request stage.
  /// [responsePhrase] A textual representation of responseCode.
  /// If absent, a standard phrase matching responseCode is used.
  Future<void> fulfillRequest(RequestId requestId, int responseCode,
      {List<HeaderEntry>? responseHeaders,
      String? binaryResponseHeaders,
      String? body,
      String? responsePhrase}) async {
    await _client.send('Fetch.fulfillRequest', {
      'requestId': requestId,
      'responseCode': responseCode,
      if (responseHeaders != null) 'responseHeaders': [...responseHeaders],
      if (binaryResponseHeaders != null)
        'binaryResponseHeaders': binaryResponseHeaders,
      if (body != null) 'body': body,
      if (responsePhrase != null) 'responsePhrase': responsePhrase,
    });
  }

  /// Continues the request, optionally modifying some of its parameters.
  /// [requestId] An id the client received in requestPaused event.
  /// [url] If set, the request url will be modified in a way that's not observable by page.
  /// [method] If set, the request method is overridden.
  /// [postData] If set, overrides the post data in the request.
  /// [headers] If set, overrides the request headers.
  /// [interceptResponse] If set, overrides response interception behavior for this request.
  Future<void> continueRequest(RequestId requestId,
      {String? url,
      String? method,
      String? postData,
      List<HeaderEntry>? headers,
      bool? interceptResponse}) async {
    await _client.send('Fetch.continueRequest', {
      'requestId': requestId,
      if (url != null) 'url': url,
      if (method != null) 'method': method,
      if (postData != null) 'postData': postData,
      if (headers != null) 'headers': [...headers],
      if (interceptResponse != null) 'interceptResponse': interceptResponse,
    });
  }

  /// Continues a request supplying authChallengeResponse following authRequired event.
  /// [requestId] An id the client received in authRequired event.
  /// [authChallengeResponse] Response to  with an authChallenge.
  Future<void> continueWithAuth(
      RequestId requestId, AuthChallengeResponse authChallengeResponse) async {
    await _client.send('Fetch.continueWithAuth', {
      'requestId': requestId,
      'authChallengeResponse': authChallengeResponse,
    });
  }

  /// Continues loading of the paused response, optionally modifying the
  /// response headers. If either responseCode or headers are modified, all of them
  /// must be present.
  /// [requestId] An id the client received in requestPaused event.
  /// [responseCode] An HTTP response code. If absent, original response code will be used.
  /// [responsePhrase] A textual representation of responseCode.
  /// If absent, a standard phrase matching responseCode is used.
  /// [responseHeaders] Response headers. If absent, original response headers will be used.
  /// [binaryResponseHeaders] Alternative way of specifying response headers as a \0-separated
  /// series of name: value pairs. Prefer the above method unless you
  /// need to represent some non-UTF8 values that can't be transmitted
  /// over the protocol as text.
  Future<void> continueResponse(RequestId requestId,
      {int? responseCode,
      String? responsePhrase,
      List<HeaderEntry>? responseHeaders,
      String? binaryResponseHeaders}) async {
    await _client.send('Fetch.continueResponse', {
      'requestId': requestId,
      if (responseCode != null) 'responseCode': responseCode,
      if (responsePhrase != null) 'responsePhrase': responsePhrase,
      if (responseHeaders != null) 'responseHeaders': [...responseHeaders],
      if (binaryResponseHeaders != null)
        'binaryResponseHeaders': binaryResponseHeaders,
    });
  }

  /// Causes the body of the response to be received from the server and
  /// returned as a single string. May only be issued for a request that
  /// is paused in the Response stage and is mutually exclusive with
  /// takeResponseBodyForInterceptionAsStream. Calling other methods that
  /// affect the request or disabling fetch domain before body is received
  /// results in an undefined behavior.
  /// [requestId] Identifier for the intercepted request to get body for.
  Future<GetResponseBodyResult> getResponseBody(RequestId requestId) async {
    var result = await _client.send('Fetch.getResponseBody', {
      'requestId': requestId,
    });
    return GetResponseBodyResult.fromJson(result);
  }

  /// Returns a handle to the stream representing the response body.
  /// The request must be paused in the HeadersReceived stage.
  /// Note that after this command the request can't be continued
  /// as is -- client either needs to cancel it or to provide the
  /// response body.
  /// The stream only supports sequential read, IO.read will fail if the position
  /// is specified.
  /// This method is mutually exclusive with getResponseBody.
  /// Calling other methods that affect the request or disabling fetch
  /// domain before body is received results in an undefined behavior.
  Future<io.StreamHandle> takeResponseBodyAsStream(RequestId requestId) async {
    var result = await _client.send('Fetch.takeResponseBodyAsStream', {
      'requestId': requestId,
    });
    return io.StreamHandle.fromJson(result['stream'] as String);
  }
}

class RequestPausedEvent {
  /// Each request the page makes will have a unique id.
  final RequestId requestId;

  /// The details of the request.
  final network.RequestData request;

  /// The id of the frame that initiated the request.
  final page.FrameId frameId;

  /// How the requested resource will be used.
  final network.ResourceType resourceType;

  /// Response error if intercepted at response stage.
  final network.ErrorReason? responseErrorReason;

  /// Response code if intercepted at response stage.
  final int? responseStatusCode;

  /// Response status text if intercepted at response stage.
  final String? responseStatusText;

  /// Response headers if intercepted at the response stage.
  final List<HeaderEntry>? responseHeaders;

  /// If the intercepted request had a corresponding Network.requestWillBeSent event fired for it,
  /// then this networkId will be the same as the requestId present in the requestWillBeSent event.
  final RequestId? networkId;

  RequestPausedEvent(
      {required this.requestId,
      required this.request,
      required this.frameId,
      required this.resourceType,
      this.responseErrorReason,
      this.responseStatusCode,
      this.responseStatusText,
      this.responseHeaders,
      this.networkId});

  factory RequestPausedEvent.fromJson(Map<String, dynamic> json) {
    return RequestPausedEvent(
      requestId: RequestId.fromJson(json['requestId'] as String),
      request:
          network.RequestData.fromJson(json['request'] as Map<String, dynamic>),
      frameId: page.FrameId.fromJson(json['frameId'] as String),
      resourceType:
          network.ResourceType.fromJson(json['resourceType'] as String),
      responseErrorReason: json.containsKey('responseErrorReason')
          ? network.ErrorReason.fromJson(json['responseErrorReason'] as String)
          : null,
      responseStatusCode: json.containsKey('responseStatusCode')
          ? json['responseStatusCode'] as int
          : null,
      responseStatusText: json.containsKey('responseStatusText')
          ? json['responseStatusText'] as String
          : null,
      responseHeaders: json.containsKey('responseHeaders')
          ? (json['responseHeaders'] as List)
              .map((e) => HeaderEntry.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      networkId: json.containsKey('networkId')
          ? RequestId.fromJson(json['networkId'] as String)
          : null,
    );
  }
}

class AuthRequiredEvent {
  /// Each request the page makes will have a unique id.
  final RequestId requestId;

  /// The details of the request.
  final network.RequestData request;

  /// The id of the frame that initiated the request.
  final page.FrameId frameId;

  /// How the requested resource will be used.
  final network.ResourceType resourceType;

  /// Details of the Authorization Challenge encountered.
  /// If this is set, client should respond with continueRequest that
  /// contains AuthChallengeResponse.
  final AuthChallenge authChallenge;

  AuthRequiredEvent(
      {required this.requestId,
      required this.request,
      required this.frameId,
      required this.resourceType,
      required this.authChallenge});

  factory AuthRequiredEvent.fromJson(Map<String, dynamic> json) {
    return AuthRequiredEvent(
      requestId: RequestId.fromJson(json['requestId'] as String),
      request:
          network.RequestData.fromJson(json['request'] as Map<String, dynamic>),
      frameId: page.FrameId.fromJson(json['frameId'] as String),
      resourceType:
          network.ResourceType.fromJson(json['resourceType'] as String),
      authChallenge:
          AuthChallenge.fromJson(json['authChallenge'] as Map<String, dynamic>),
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

/// Stages of the request to handle. Request will intercept before the request is
/// sent. Response will intercept after the response is received (but before response
/// body is received).
class RequestStage {
  static const request = RequestStage._('Request');
  static const response = RequestStage._('Response');
  static const values = {
    'Request': request,
    'Response': response,
  };

  final String value;

  const RequestStage._(this.value);

  factory RequestStage.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is RequestStage && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class RequestPattern {
  /// Wildcards (`'*'` -> zero or more, `'?'` -> exactly one) are allowed. Escape character is
  /// backslash. Omitting is equivalent to `"*"`.
  final String? urlPattern;

  /// If set, only requests for matching resource types will be intercepted.
  final network.ResourceType? resourceType;

  /// Stage at which to begin intercepting requests. Default is Request.
  final RequestStage? requestStage;

  RequestPattern({this.urlPattern, this.resourceType, this.requestStage});

  factory RequestPattern.fromJson(Map<String, dynamic> json) {
    return RequestPattern(
      urlPattern:
          json.containsKey('urlPattern') ? json['urlPattern'] as String : null,
      resourceType: json.containsKey('resourceType')
          ? network.ResourceType.fromJson(json['resourceType'] as String)
          : null,
      requestStage: json.containsKey('requestStage')
          ? RequestStage.fromJson(json['requestStage'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (urlPattern != null) 'urlPattern': urlPattern,
      if (resourceType != null) 'resourceType': resourceType!.toJson(),
      if (requestStage != null) 'requestStage': requestStage!.toJson(),
    };
  }
}

/// Response HTTP header entry
class HeaderEntry {
  final String name;

  final String value;

  HeaderEntry({required this.name, required this.value});

  factory HeaderEntry.fromJson(Map<String, dynamic> json) {
    return HeaderEntry(
      name: json['name'] as String,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
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
