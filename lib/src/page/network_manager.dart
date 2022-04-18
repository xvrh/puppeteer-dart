import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import '../../protocol/dev_tools.dart';
import '../../protocol/fetch.dart';
import '../../protocol/fetch.dart' as fetch;
import '../../protocol/network.dart';
import '../../protocol/network.dart' as network;
import '../../protocol/security.dart';
import '../connection.dart';
import 'frame_manager.dart';

final _logger = Logger('puppeteer.network_manager');

class NetworkManager {
  final Client client;
  final FrameManager frameManager;
  final _requestIdToRequest = <String, Request>{};
  final _requestIdToRequestWillBeSentEvent = <String, RequestWillBeSentEvent>{};
  final _extraHTTPHeaders =
      CanonicalizedMap<String, String, String?>((key) => key.toLowerCase());
  bool _offline = false;
  Credentials? _credentials;
  final _attemptedAuthentications = <String?>{};
  bool _userRequestInterceptionEnabled = false;
  bool _protocolRequestInterceptionEnabled = false;
  bool _userCacheDisabled = false;
  final _requestIdToInterceptionId = <String?, String?>{};
  final _onRequestController = StreamController<Request>.broadcast(),
      _onRequestFinishedController = StreamController<Request>.broadcast(),
      _onResponseController = StreamController<Response>.broadcast(),
      _onRequestFailedController = StreamController<Request>.broadcast();

  NetworkManager(this.client, this.frameManager) {
    _fetch.onRequestPaused.listen(_onRequestPaused);
    _fetch.onAuthRequired.listen(_onAuthRequired);
    _network.onRequestWillBeSent.listen(_onRequestWillBeSent);
    _network.onRequestServedFromCache.listen(_onRequestServedFromCache);
    _network.onResponseReceived.listen(_onResponseReceived);
    _network.onLoadingFinished.listen(_onLoadingFinished);
    _network.onLoadingFailed.listen(_onLoadingFailed);
  }

  DevTools get _devTools => frameManager.page.devTools;

  FetchApi get _fetch => _devTools.fetch;

  NetworkApi get _network => _devTools.network;

  Stream<Request> get onRequest => _onRequestController.stream;

  Stream<Request> get onRequestFinished => _onRequestFinishedController.stream;

  Stream<Response> get onResponse => _onResponseController.stream;

  Stream<Request> get onRequestFailed => _onRequestFailedController.stream;

  void dispose() {
    _onRequestController.close();
    _onRequestFinishedController.close();
    _onResponseController.close();
    _onRequestFailedController.close();
  }

  Future<void> initialize() async {
    await _devTools.network.enable();
    if (frameManager.page.browser.ignoreHttpsErrors) {
      await _devTools.security.setIgnoreCertificateErrors(true);
    }
  }

  Future<void> authenticate(Credentials? credentials) async {
    _credentials = credentials;
    await _updateProtocolRequestInterception();
  }

  Future<void> setExtraHTTPHeaders(Map<String, String> extraHttpHeaders) async {
    for (var key in extraHttpHeaders.keys) {
      _extraHTTPHeaders[key.toLowerCase()] = extraHttpHeaders[key];
    }
    await _network.setExtraHTTPHeaders(Headers(_extraHTTPHeaders));
  }

  Map<String, String> get extraHTTPHeaders =>
      Map.unmodifiable(_extraHTTPHeaders);

  Future<void> setOfflineMode(bool value) async {
    if (_offline == value) return;
    _offline = value;
    await _network.emulateNetworkConditions(_offline, 0, -1, -1);
  }

  Future<void> setUserAgent(String userAgent) {
    return _network.setUserAgentOverride(userAgent);
  }

  Future<void> setCacheEnabled(bool enabled) {
    _userCacheDisabled = !enabled;
    return _updateProtocolCacheDisabled();
  }

  Future<void> setRequestInterception(bool value) {
    _userRequestInterceptionEnabled = value;
    return _updateProtocolRequestInterception();
  }

  Future<void> _updateProtocolRequestInterception() async {
    var enabled = _userRequestInterceptionEnabled || _credentials != null;
    if (enabled == _protocolRequestInterceptionEnabled) return;
    _protocolRequestInterceptionEnabled = enabled;
    if (enabled) {
      await Future.wait([
        _updateProtocolCacheDisabled(),
        _fetch.enable(
            handleAuthRequests: true,
            patterns: [fetch.RequestPattern(urlPattern: '*')]),
      ]);
    } else {
      await Future.wait([
        _updateProtocolCacheDisabled(),
        _fetch.disable(),
      ]);
    }
  }

  Future<void> _updateProtocolCacheDisabled() {
    return _network.setCacheDisabled(
        _userCacheDisabled || _protocolRequestInterceptionEnabled);
  }

  void _onRequestWillBeSent(RequestWillBeSentEvent event) {
    // Request interception doesn't happen for data URLs with Network Service.
    if (_protocolRequestInterceptionEnabled &&
        !event.request.url.startsWith('data:')) {
      var requestId = event.requestId;
      var interceptionId = _requestIdToInterceptionId[requestId.value];
      if (interceptionId != null) {
        _onRequest(event, interceptionId);
        _requestIdToInterceptionId.remove(requestId.value);
      } else {
        _requestIdToRequestWillBeSentEvent[event.requestId.value] = event;
      }
      return;
    }
    _onRequest(event, null);
  }

  void _onAuthRequired(AuthRequiredEvent event) {
    var response = fetch.AuthChallengeResponseResponse.default$;
    if (_attemptedAuthentications.contains(event.requestId.value)) {
      response = fetch.AuthChallengeResponseResponse.cancelAuth;
    } else if (_credentials != null) {
      response = fetch.AuthChallengeResponseResponse.provideCredentials;
      _attemptedAuthentications.add(event.requestId.value);
    }

    _fetch.continueWithAuth(
        event.requestId,
        fetch.AuthChallengeResponse(
            response: response,
            username: _credentials?.username,
            password: _credentials?.password));
  }

  Future<void> _onRequestPaused(RequestPausedEvent event) async {
    if (!_userRequestInterceptionEnabled &&
        _protocolRequestInterceptionEnabled) {
      await _fetch.continueRequest(event.requestId);
    }

    var requestId = event.networkId;
    var interceptionId = event.requestId;
    if (requestId != null) {
      if (_requestIdToRequestWillBeSentEvent.containsKey(requestId.value)) {
        var requestWillBeSentEvent =
            _requestIdToRequestWillBeSentEvent[requestId.value]!;
        _onRequest(requestWillBeSentEvent, interceptionId.value);
        _requestIdToRequestWillBeSentEvent.remove(requestId.value);
      } else {
        _requestIdToInterceptionId[requestId.value] = interceptionId.value;
      }
    }
  }

  void _onRequest(RequestWillBeSentEvent event, String? interceptionId) {
    List<Request>? redirectChain = <Request>[];
    var redirectResponse = event.redirectResponse;
    if (redirectResponse != null) {
      var request = _requestIdToRequest[event.requestId.value];
      // If we connect late to the target, we could have missed the requestWillBeSent event.
      if (request != null) {
        _handleRequestRedirect(request, redirectResponse);
        redirectChain = request.redirectChain;
      }
    }
    var frame =
        event.frameId != null ? frameManager.frame(event.frameId) : null;
    var request = Request(FetchApi(client), frame, interceptionId, event,
        allowInterception: _userRequestInterceptionEnabled,
        redirectChain: redirectChain);
    _requestIdToRequest[event.requestId.value] = request;
    _onRequestController.add(request);
  }

  void _onRequestServedFromCache(network.RequestId requestId) {
    var request = _requestIdToRequest[requestId.value];
    if (request != null) request._fromMemoryCache = true;
  }

  void _handleRequestRedirect(Request request, ResponseData responsePayload) {
    var response = Response(_network, request, responsePayload);
    request._response = response;
    request.redirectChain.add(request);
    response._bodyLoadedCompleter.complete(
        Exception('Response body is unavailable for redirect responses'));
    _requestIdToRequest.remove(request.requestId);
    _attemptedAuthentications.remove(request.interceptionId);
    _onResponseController.add(response);
    _onRequestFinishedController.add(request);
  }

  void _onResponseReceived(network.ResponseReceivedEvent event) {
    var request = _requestIdToRequest[event.requestId.value];
    // FileUpload sends a response without a matching request.
    if (request == null) return;
    var response = Response(_network, request, event.response);
    request._response = response;
    _onResponseController.add(response);
  }

  void _onLoadingFinished(LoadingFinishedEvent event) {
    var request = _requestIdToRequest[event.requestId.value];
    // For certain requestIds we never receive requestWillBeSent event.
    // @see https://crbug.com/750469
    if (request == null) return;

    // Under certain conditions we never get the Network.responseReceived
    // event from protocol. @see https://crbug.com/883475
    if (request.response != null) {
      request.response!._bodyLoadedCompleter.complete(null);
    }
    _requestIdToRequest.remove(request.requestId);
    _attemptedAuthentications.remove(request.interceptionId);
    _onRequestFinishedController.add(request);
  }

  void _onLoadingFailed(LoadingFailedEvent event) {
    var request = _requestIdToRequest[event.requestId.value];
    // For certain requestIds we never receive requestWillBeSent event.
    // @see https://crbug.com/750469
    if (request == null) return;
    request._failureText = event.errorText;
    var response = request.response;
    if (response != null) response._bodyLoadedCompleter.complete(null);
    _requestIdToRequest.remove(request.requestId);
    _attemptedAuthentications.remove(request.interceptionId);
    _onRequestFailedController.add(request);
  }
}

/// Whenever the page sends a request, such as for a network resource, the
/// following events are emitted by puppeteer's page:
/// - [onRequest] emitted when the request is issued by the page.
/// - [onResponse] emitted when/if the response is received for the request.
/// - [onRequestFinished] emitted when the response body is downloaded and the
///    request is complete.
///
/// If request fails at some point, then instead of 'onRequestFinished' event
/// (and possibly instead of 'response' event), the  [onRequestFailed] event is
/// emitted.
///
/// If request gets a 'redirect' response, the request is successfully finished
/// with the 'onRequestFinished' event, and a new request is  issued to a
/// redirected url.
class Request {
  /// A [Frame] that initiated this request, or `null` if navigating to
  /// error pages.
  final Frame? frame;
  final String? interceptionId;
  final RequestWillBeSentEvent event;

  /// A `redirectChain` is a chain of requests initiated to fetch a resource.
  /// - If there are no redirects and the request was successful, the chain will
  ///   be empty.
  /// - If a server responds with at least a single redirect, then the chain will
  ///   contain all the requests that were redirected.
  ///
  /// `redirectChain` is shared between all the requests of the same chain.
  ///
  /// For example, if the website `http://example.com` has a single redirect to
  /// `https://example.com`, then the chain will contain one request:
  ///
  /// ```dart
  /// var response = await page.goto('http://example.com');
  /// var chain = response.request.redirectChain;
  /// expect(chain, hasLength(1));
  /// expect(chain[0].url, equals('http://example.com'));
  /// ```
  ///
  /// If the website `https://example.com` has no redirects, then the chain will
  /// be empty:
  /// ```dart
  /// var response = await page.goto('https://example.com');
  /// var chain = response.request.redirectChain;
  /// expect(chain, isEmpty);
  /// ```
  final List<Request> redirectChain;

  final bool allowInterception;
  final _headers =
      CanonicalizedMap<String, String, String>((key) => key.toLowerCase());
  Response? _response;
  String? _failureText;
  bool _fromMemoryCache = false;
  bool _interceptionHandled = false;
  final FetchApi _fetchApi;

  Request(this._fetchApi, this.frame, this.interceptionId, this.event,
      {required this.redirectChain, required bool? allowInterception})
      : allowInterception = allowInterception ?? false {
    for (var header in event.request.headers.value.keys) {
      _headers[header] = event.request.headers.value[header] as String;
    }
  }

  String get requestId => event.requestId.value;

  /// Whether this request is driving frame's navigation.
  bool get isNavigationRequest =>
      event.requestId.value == event.loaderId.value &&
      event.type == ResourceType.document;

  /// URL of the request.
  String get url => event.request.url;

  /// Contains the request's resource type as it was perceived by the rendering
  /// engine.
  ResourceType? get resourceType => event.type;

  /// Request's method (GET, POST, etc.)
  String get method => event.request.method;

  /// Request's post body, if any.
  String? get postData => event.request.postData;

  /// An object with HTTP headers associated with the request. All header names
  /// are lower-case.
  Map<String, String> get headers => _headers;

  /// A matching [Response] object, or `null` if the response has not been
  /// received yet.
  Response? get response => _response;

  /// The method returns `null` unless this request was failed, as reported by
  /// `onRequestFailed` event.
  ///
  /// Example of logging all failed requests:
  ///
  /// ```dart
  /// page.onRequestFailed.listen((request) {
  ///   print(request.url + ' ' + request.failure!);
  /// });
  /// ```
  String? get failure => _failureText;

  /// Continues request with optional request overrides. To use this, request
  /// interception should be enabled with `page.setRequestInterception`.
  /// Exception is immediately thrown if the request interception is not enabled.
  ///
  /// ```dart
  /// await page.setRequestInterception(true);
  /// page.onRequest.listen((request) {
  ///   // Override headers
  ///   var headers = Map<String, String>.from(request.headers)
  ///     ..['foo'] = 'bar'
  ///     ..remove('origin');
  ///   request.continueRequest(headers: headers);
  /// });
  /// ```
  ///
  /// Parameters:
  /// - [url]: If set, the request url will be changed. This is not a redirect.
  ///   The request will be silently forwarded to the new url. For example, the
  ///   address bar will show the original url.
  /// - [method]: If set changes the request method (e.g. `GET` or `POST`)
  /// - [postData]: If set changes the post data of request
  /// - [headers]: If set changes the request HTTP headers
  Future<void> continueRequest(
      {String? url,
      String? method,
      String? postData,
      Map<String, String>? headers}) async {
    // Request interception is not supported for data: urls.
    if (this.url.startsWith('data:')) return;
    assert(allowInterception, 'Request Interception is not enabled!');
    assert(!_interceptionHandled, 'Request is already handled!');
    _interceptionHandled = true;

    var postDataBinaryBase64 =
        postData != null ? base64Encode(utf8.encode(postData)) : null;

    headers ??= {};
    await _fetchApi
        .continueRequest(fetch.RequestId(interceptionId!),
            url: url,
            method: method,
            postData: postDataBinaryBase64,
            headers: headers.entries
                .map((e) => fetch.HeaderEntry(name: e.key, value: e.value))
                .toList())
        .catchError((error) {
      // In certain cases, protocol will return error if the request was already canceled
      // or the page was closed. We should tolerate these errors.
      _logger.finer('[Request.continueRequest] swallow error: $error');
    });
  }

  /// Fulfills request with given response. To use this, request interception should
  /// be enabled with `page.setRequestInterception`. Exception is thrown if
  /// request interception is not enabled.
  ///
  /// An example of fulfilling all requests with 404 responses:
  ///
  /// ```dart
  /// await page.setRequestInterception(true);
  /// page.onRequest.listen((request) {
  ///   request.respond(status: 404, contentType: 'text/plain', body: 'Not Found!');
  /// });
  /// ```
  ///
  /// > **NOTE** Mocking responses for dataURL requests is not supported.
  /// > Calling `request.respond` for a dataURL request is a noop.
  ///
  /// Parameters:
  /// - [status]: Response status code, defaults to `200`.
  /// - [headers]: Optional response headers
  /// - [contentType]: If set, equals to setting `Content-Type` response header
  /// - [body]: Optional response body
  Future<void> respond(
      {int? status,
      Map<String, String>? headers,
      String? contentType,
      body}) async {
    // Mocking responses for dataURL requests is not currently supported.
    if (url.startsWith('data:')) return;
    assert(allowInterception, 'Request Interception is not enabled!');
    assert(!_interceptionHandled, 'Request is already handled!');
    _interceptionHandled = true;

    headers ??= {};

    if (contentType != null) {
      headers['content-type'] = contentType;
    }

    List<int>? bodyBytes;
    if (body is String) {
      bodyBytes = utf8.encode(body);
    }
    if (body is List<int>) {
      bodyBytes = body;
    }

    if (bodyBytes != null && !headers.containsKey('content-length')) {
      headers['content-length'] = bodyBytes.length.toString();
    }

    await _fetchApi
        .fulfillRequest(fetch.RequestId(interceptionId!), status ?? 200,
            responseHeaders: headers.entries
                .map((e) => fetch.HeaderEntry(
                    name: e.key.toLowerCase(), value: e.value))
                .toList(),
            responsePhrase: _statusTexts[status ?? 200],
            body: body != null ? base64.encode(bodyBytes!) : null)
        .catchError((error) {
      // In certain cases, protocol will return error if the request was already canceled
      // or the page was closed. We should tolerate these errors.
      _logger.finer('[Request.respond] swallow error: $error');
    });
  }

  /// Aborts request. To use this, request interception should be enabled with
  /// `page.setRequestInterception`.
  /// Exception is immediately thrown if the request interception is not enabled.
  ///
  /// Parameters:
  /// [error]: Optional error code. Defaults to `failed`
  Future<void> abort({ErrorReason? error}) async {
    error ??= ErrorReason.failed;
    // Request interception is not supported for data: urls.
    if (url.startsWith('data:')) return;

    assert(allowInterception, 'Request Interception is not enabled!');
    assert(!_interceptionHandled, 'Request is already handled!');
    _interceptionHandled = true;
    await _fetchApi
        .failRequest(fetch.RequestId(interceptionId!), error)
        .catchError((error) {
      // In certain cases, protocol will return error if the request was already canceled
      // or the page was closed. We should tolerate these errors.
      _logger.finer('[Request.abort] swallow error: $error');
    });
  }
}

/// [Response] class represents responses which are received by page.
class Response {
  /// A matching [Request] object.
  final Request request;
  final ResponseData data;
  final _bodyLoadedCompleter = Completer();
  Future? _contentFuture;
  final NetworkApi _networkApi;
  final _headers =
      CanonicalizedMap<String, String, String>((key) => key.toLowerCase());

  Response(this._networkApi, this.request, this.data) {
    for (var header in data.headers.value.keys) {
      _headers[header] = data.headers.value[header] as String;
    }
  }

  factory Response.aborted(DevTools apis, Request? request) {
    return Response(
      apis.network,
      request ??
          Request(
              apis.fetch,
              null,
              null,
              RequestWillBeSentEvent(
                requestId: network.RequestId(''),
                loaderId: network.LoaderId(''),
                documentURL: '',
                request: RequestData(
                    url: '',
                    method: '',
                    headers: Headers({}),
                    initialPriority: network.ResourcePriority.medium,
                    referrerPolicy: network.RequestReferrerPolicy.noReferrer),
                timestamp: network.MonotonicTime(0),
                wallTime: network.TimeSinceEpoch(0),
                initiator: network.Initiator(type: InitiatorType.other),
                redirectHasExtraInfo: false,
              ),
              redirectChain: [],
              allowInterception: false),
      ResponseData(
          url: '',
          status: 0,
          statusText: '',
          headers: Headers({}),
          mimeType: '',
          connectionReused: false,
          connectionId: 0,
          encodedDataLength: 0,
          securityState: SecurityState.unknown),
    );
  }

  /// The IP address of the remote server
  String? get remoteIPAddress => data.remoteIPAddress;

  /// The port used to connect to the remote server
  int? get remotePort => data.remotePort;

  /// Contains the status code of the response (e.g., 200 for a success).
  int get status => data.status;

  /// Contains the status text of the response (e.g. usually an "OK" for a success).
  String get statusText => data.statusText;

  /// Contains the URL of the response.
  String get url => request.url;

  bool get fromDiskCache => data.fromDiskCache ?? false;

  /// True if the response was served by a service worker.
  bool get fromServiceWorker => data.fromServiceWorker ?? false;

  /// True if the response was served from either the browser's disk cache or
  /// memory cache.
  bool get fromCache => fromDiskCache || request._fromMemoryCache;

  /// An object with HTTP headers associated with the response.
  Map<String, String> get headers => _headers;

  /// Security details if the response was received over the secure connection,
  /// or `null` otherwise.
  SecurityDetails? get securityDetails => data.securityDetails;

  /// A [Frame] that initiated this response, or `null` if navigating to error
  /// pages.
  Frame? get frame => request.frame;

  /// Contains a boolean stating whether the response was successful (status in
  /// the range 200-299) or not.
  bool get ok => status == 0 || (status >= 200 && status <= 299);

  Future? get content {
    _contentFuture ??= _bodyLoadedCompleter.future.then((error) async {
      if (error is Exception) throw error;
      var response = await _networkApi
          .getResponseBody(network.RequestId(request.requestId));
      if (response.base64Encoded) {
        return base64.decode(response.body);
      } else {
        return response.body;
      }
    });
    return _contentFuture;
  }

  /// Promise which resolves to the bytes with response body.
  Future<List<int>> get bytes => content!.then((content) =>
      content is List<int> ? content : utf8.encode(content as String));

  /// Promise which resolves to a text representation of response body.
  Future<String> get text => content!.then((content) =>
      content is String ? content : utf8.decode(content as List<int>));

  /// This method will throw if the response body is not parsable via `jsonDecode`.
  Future<dynamic> get json => text.then(jsonDecode);
}

class Credentials {
  final String? username, password;

  Credentials(this.username, this.password);
}

// List taken from https://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml with extra 306 and 418 codes.
const _statusTexts = <int, String>{
  100: 'Continue',
  101: 'Switching Protocols',
  102: 'Processing',
  103: 'Early Hints',
  200: 'OK',
  201: 'Created',
  202: 'Accepted',
  203: 'Non-Authoritative Information',
  204: 'No Content',
  205: 'Reset Content',
  206: 'Partial Content',
  207: 'Multi-Status',
  208: 'Already Reported',
  226: 'IM Used',
  300: 'Multiple Choices',
  301: 'Moved Permanently',
  302: 'Found',
  303: 'See Other',
  304: 'Not Modified',
  305: 'Use Proxy',
  306: 'Switch Proxy',
  307: 'Temporary Redirect',
  308: 'Permanent Redirect',
  400: 'Bad Request',
  401: 'Unauthorized',
  402: 'Payment Required',
  403: 'Forbidden',
  404: 'Not Found',
  405: 'Method Not Allowed',
  406: 'Not Acceptable',
  407: 'Proxy Authentication Required',
  408: 'Request Timeout',
  409: 'Conflict',
  410: 'Gone',
  411: 'Length Required',
  412: 'Precondition Failed',
  413: 'Payload Too Large',
  414: 'URI Too Long',
  415: 'Unsupported Media Type',
  416: 'Range Not Satisfiable',
  417: 'Expectation Failed',
  418: 'I\'m a teapot',
  421: 'Misdirected Request',
  422: 'Unprocessable Entity',
  423: 'Locked',
  424: 'Failed Dependency',
  425: 'Too Early',
  426: 'Upgrade Required',
  428: 'Precondition Required',
  429: 'Too Many Requests',
  431: 'Request Header Fields Too Large',
  451: 'Unavailable For Legal Reasons',
  500: 'Internal Server Error',
  501: 'Not Implemented',
  502: 'Bad Gateway',
  503: 'Service Unavailable',
  504: 'Gateway Timeout',
  505: 'HTTP Version Not Supported',
  506: 'Variant Also Negotiates',
  507: 'Insufficient Storage',
  508: 'Loop Detected',
  510: 'Not Extended',
  511: 'Network Authentication Required',
};
