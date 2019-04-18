import 'dart:async';
import 'dart:convert';

import 'package:chrome_dev_tools/domains/domains.dart';
import 'package:chrome_dev_tools/domains/fetch.dart';
import 'package:chrome_dev_tools/domains/fetch.dart' as fetch;
import 'package:chrome_dev_tools/domains/network.dart';
import 'package:chrome_dev_tools/domains/network.dart' as network;
import 'package:chrome_dev_tools/src/connection.dart';
import 'package:chrome_dev_tools/src/page/frame_manager.dart';

class NetworkManager {
  final Client client;
  final FrameManager frameManager;
  final _requestIdToRequest = <String, NetworkRequest>{};
  final _requestIdToRequestWillBeSentEvent = <String, RequestWillBeSentEvent>{};
  final _extraHTTPHeaders = <String, String>{};
  bool _offline = false;
  Credentials _credentials;
  final _attemptedAuthentications = <String>{};
  bool _userRequestInterceptionEnabled = false;
  bool _protocolRequestInterceptionEnabled = false;
  bool _userCacheDisabled = false;
  final _requestIdToInterceptionId = <String, String>{};
  final _onRequestController = StreamController<NetworkRequest>.broadcast(),
      _onRequestFinishedController =
          StreamController<NetworkRequest>.broadcast(),
      _onResponseController = StreamController<NetworkResponse>.broadcast(),
      _onRequestFailedController = StreamController<NetworkRequest>.broadcast();

  NetworkManager(this.client, this.frameManager) {
    _fetch.onRequestPaused.listen(_onRequestPaused);
    _fetch.onAuthRequired.listen(_onAuthRequired);
    _network.onRequestWillBeSent.listen(_onRequestWillBeSent);
    _network.onRequestServedFromCache.listen(_onRequestServedFromCache);
    _network.onResponseReceived.listen(_onResponseReceived);
    _network.onLoadingFinished.listen(_onLoadingFinished);
    _network.onLoadingFailed.listen(_onLoadingFailed);
  }

  Domains get _domains =>  frameManager.page.domains;

  FetchApi get _fetch => _domains.fetch;

  NetworkApi get _network => _domains.network;

  Stream<NetworkRequest> get onRequest => _onRequestController.stream;

  Stream<NetworkRequest> get onRequestFinished =>
      _onRequestFinishedController.stream;

  Stream<NetworkResponse> get onResponse => _onResponseController.stream;

  Stream<NetworkRequest> get onRequestFailed =>
      _onRequestFailedController.stream;

  void dispose() {
    _onRequestController.close();
    _onRequestFinishedController.close();
    _onResponseController.close();
    _onRequestFailedController.close();
  }

  Future<void> initialize() async {
    await _domains.network.enable();
    if (frameManager.page.browser.ignoreHttpsErrors) {
      await _domains.security.setIgnoreCertificateErrors(true);
    }
  }

  Future<void> authenticate(Credentials credentials) async {
    _credentials = credentials;
    await _updateProtocolRequestInterception();
  }

  Future<void> setExtraHTTPHeaders(Map<String, String> extraHttpHeaders) async {
    _extraHTTPHeaders.clear();
    _extraHTTPHeaders.addAll(new Map.fromIterable(extraHttpHeaders.entries,
        key: (e) => e.key.toLowercase(), value: (e) => e.value));
    await _network.setExtraHTTPHeaders(Headers(_extraHTTPHeaders));
  }

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

  Future<void> setRequestInterception(value) {
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

  Future <void>_updateProtocolCacheDisabled() {
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
        _requestIdToInterceptionId.remove(requestId);
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
      response =  fetch.AuthChallengeResponseResponse.cancelAuth;
    } else if (_credentials != null) {
      response = fetch.AuthChallengeResponseResponse.provideCredentials;
      _attemptedAuthentications.add(event.requestId.value);
    }

    _fetch.continueWithAuth(
        event.requestId,
        fetch.AuthChallengeResponse(
            response: response,
            username: _credentials?.userName,
            password: _credentials?.password));
  }

  void _onRequestPaused(RequestPausedEvent event) async {
    if (!_userRequestInterceptionEnabled &&
        _protocolRequestInterceptionEnabled) {
      await _fetch.continueRequest(event.requestId);
    }

    var requestId = event.networkId;
    var interceptionId = event.requestId;
    if (requestId != null &&
        _requestIdToRequestWillBeSentEvent.containsKey(requestId.value)) {
      var requestWillBeSentEvent =
          _requestIdToRequestWillBeSentEvent[requestId.value];
      _onRequest(requestWillBeSentEvent, interceptionId.value);
      _requestIdToRequestWillBeSentEvent.remove(requestId.value);
    } else {
      _requestIdToInterceptionId[requestId.value] = interceptionId.value;
    }
  }

  void _onRequest(RequestWillBeSentEvent event, String interceptionId) {
    var redirectChain = <NetworkRequest>[];
    if (event.redirectResponse != null) {
      var request = _requestIdToRequest[event.requestId.value];
      // If we connect late to the target, we could have missed the requestWillBeSent event.
      if (request != null) {
        _handleRequestRedirect(request, event.redirectResponse);
        redirectChain = request.redirectChain;
      }
    }
    var frame =
        event.frameId != null ? frameManager.frame(event.frameId) : null;
    var request = NetworkRequest(client, frame, interceptionId, event,
        allowInterception: _userRequestInterceptionEnabled,
        redirectChain: redirectChain);
    _requestIdToRequest[event.requestId.value] = request;
    _onRequestController.add(request);
  }

  void _onRequestServedFromCache(network.RequestId requestId) {
    var request = _requestIdToRequest[requestId.value];
    if (request != null) request._fromMemoryCache = true;
  }

  void _handleRequestRedirect(
      NetworkRequest request, Response responsePayload) {
    var response = new NetworkResponse(client, request, responsePayload);
    request._response = response;
    request.redirectChain.add(request);
    response._bodyLoadedCompleter.complete(
        new Exception('Response body is unavailable for redirect responses'));
    _requestIdToRequest.remove(request.requestId);
    _attemptedAuthentications.remove(request.interceptionId);
    _onResponseController.add(response);
    _onRequestFinishedController.add(request);
  }

  void _onResponseReceived(network.ResponseReceivedEvent event) {
    var request = _requestIdToRequest[event.requestId.value];
    // FileUpload sends a response without a matching request.
    if (request == null) return;
    var response = new NetworkResponse(client, request, event.response);
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
      request.response._bodyLoadedCompleter.complete(null);
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

class NetworkRequest {
  final Client client;
  final PageFrame frame;
  final String interceptionId;
  final RequestWillBeSentEvent event;
  final List<NetworkRequest> redirectChain;
  final bool allowInterception;
  NetworkResponse _response;
  String _failureText;
  bool _fromMemoryCache = false;
  bool _interceptionHandled = false;
  final FetchApi _fetchApi;

  NetworkRequest(this.client, this.frame, this.interceptionId, this.event,
      {this.redirectChain, bool allowInterception})
      : allowInterception = allowInterception ?? false,
        _fetchApi = FetchApi(client);

  String get requestId => event.requestId.value;

  bool get isNavigationRequest =>
      event.requestId.value == event.loaderId.value &&
      event.type == ResourceType.document;

  String get url => event.request.url;

  ResourceType get resourceType => event.type;

  String get method => event.request.method;

  String get postData => event.request.postData;

  Map get headers => event.request.headers.value;

  NetworkResponse get response => _response;

  String get failure => _failureText;

  Future<void> continueRequest(
      {String url, String method, String postData, Map headers}) async {
    // Request interception is not supported for data: urls.
    if (this.url.startsWith('data:')) return;
    assert(allowInterception, 'Request Interception is not enabled!');
    assert(!_interceptionHandled, 'Request is already handled!');
    _interceptionHandled = true;

    headers ??= {};
    await _fetchApi.continueRequest(fetch.RequestId(interceptionId),
        url: url,
        method: method,
        postData: postData,
        headers: headers.entries
            .map((e) => fetch.HeaderEntry(name: e.key, value: e.value))
            .toList());
  }

  Future<void> respond(
      {int status,
      Map<String, String> headers,
      String contentType,
      String body}) async {
    // Mocking responses for dataURL requests is not currently supported.
    if (url.startsWith('data:')) return;
    assert(allowInterception, 'Request Interception is not enabled!');
    assert(!_interceptionHandled, 'Request is already handled!');
    _interceptionHandled = true;

    headers ??= {};

    if (contentType != null) {
      headers['content-type'] = contentType;
    }
    if (body != null && !headers.containsKey('content-length')) {
      headers['content-length'] = utf8.encode(body).length.toString();
    }

    await _fetchApi.fulfillRequest(
        fetch.RequestId(requestId),
        response.status ?? 200,
        headers.entries
            .map((e) => fetch.HeaderEntry(name: e.key, value: e.value))
            .toList());
  }

  Future<void> abort({ErrorReason error}) async {
    error ??= ErrorReason.failed;
    // Request interception is not supported for data: urls.
    if (url.startsWith('data:')) return;

    assert(allowInterception, 'Request Interception is not enabled!');
    assert(!_interceptionHandled, 'Request is already handled!');
    _interceptionHandled = true;
    await _fetchApi.failRequest(fetch.RequestId(requestId), error);
  }
}

class NetworkResponse {
  final Client client;
  final NetworkRequest request;
  final Response response;
  final _bodyLoadedCompleter = Completer();
  Future _contentFuture;
  final NetworkApi _networkApi;

  NetworkResponse(this.client, this.request, this.response)
      : _networkApi = NetworkApi(client);

  String get ip => response.remoteIPAddress;

  int get port => response.remotePort;

  int get status => response.status;

  String get statusText => response.statusText;

  String get url => request.url;

  bool get fromDiskCache => response.fromDiskCache;

  bool get fromServiceWorker => response.fromServiceWorker;

  bool get fromCache => fromDiskCache || request._fromMemoryCache;

  Map get headers => response.headers.value;

  SecurityDetails get securityDetails => response.securityDetails;

  PageFrame get frame => request.frame;

  bool get ok => status == 0 || (status >= 200 && status <= 299);

  Future get content {
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

  Future<List<int>> get bytes => content.then((content) =>
      content is List<int> ? content : utf8.encode((content as String)));

  Future<String> get text => content.then((content) =>
      content is String ? content : utf8.decode((content as List<int>)));

  Future get json => text.then(jsonDecode);
}

class Credentials {
  final String userName, password;

  Credentials(this.userName, this.password);
}
