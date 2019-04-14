

import 'dart:async';

import 'package:chrome_dev_tools/domains/fetch.dart';
import 'package:chrome_dev_tools/domains/fetch.dart' as fetch;
import 'package:chrome_dev_tools/domains/network.dart';
import 'package:chrome_dev_tools/domains/network.dart' as network;
import 'package:chrome_dev_tools/src/connection.dart';
import 'package:chrome_dev_tools/src/page/frame_manager.dart';

class NetworkManager {
  final Client client;
  final FrameManager frameManager;
  final bool ignoreHttpsErrors;
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
      _onRequestFinishedController = StreamController<NetworkRequest>.broadcast(),
      _onResponseController = StreamController<NetworkResponse>.broadcast();

  NetworkManager(this.client, this.frameManager, {this.ignoreHttpsErrors = false}) {
    _fetch.onRequestPaused.listen(_onRequestPaused);
    _fetch.onAuthRequired.listen(_onAuthRequired);
    _network.onRequestWillBeSent.listen(_onRequestWillBeSent);
    _network.onRequestServedFromCache.listen(_onRequestServedFromCache);
    _network.onResponseReceived.listen(_onResponseReceived);
    _network.onLoadingFinished.listen(_onLoadingFinished);
    _network.onLoadingFailed.listen(_onLoadingFailed);
  }

  FetchApi get _fetch => frameManager.page.tab.fetch;
  NetworkApi get _network => frameManager.page.tab.network;

  Stream<NetworkRequest> get onRequest => _onRequestController.stream;
  Stream<NetworkRequest> get onRequestFinished => _onRequestFinishedController.stream;
  Stream<NetworkResponse> get onResponse => _onResponseController.stream;

  void dispose() {
    _onRequestController.close();
    _onRequestFinishedController.close();
    _onResponseController.close();
  }

  Future initialize() async {
    if (ignoreHttpsErrors) {
      await frameManager.page.tab.security.setIgnoreCertificateErrors(true);
    }
  }

  Future authenticate(Credentials credentials) async {
    _credentials = credentials;
    await _updateProtocolRequestInterception();
  }

  Future setExtraHTTPHeaders(Map<String, String> extraHttpHeaders) async {
    _extraHTTPHeaders.clear();
    _extraHTTPHeaders.addAll(new Map.fromIterable(extraHttpHeaders.entries, key: (e) => e.key.toLowercase(), value: (e) => e.value));
    await _network.setExtraHTTPHeaders(Headers(_extraHTTPHeaders));
  }

  Future setOfflineMode(bool value) async {
    if (_offline == value)
      return;
    _offline = value;
    await _network.emulateNetworkConditions(_offline, 0, -1, -1);
  }

  Future setUserAgent(String userAgent) {
    return _network.setUserAgentOverride(userAgent);
  }

  Future setCacheEnabled(bool enabled) {
    _userCacheDisabled = !enabled;
    return _updateProtocolCacheDisabled();
  }

  Future setRequestInterception(value) {
    _userRequestInterceptionEnabled = value;
    return _updateProtocolRequestInterception();
  }

  Future _updateProtocolRequestInterception() async {
    var enabled = _userRequestInterceptionEnabled || _credentials != null;
    if (enabled == _protocolRequestInterceptionEnabled)
      return;
    _protocolRequestInterceptionEnabled = enabled;
    if (enabled) {
      await Future.wait([
        _updateProtocolCacheDisabled(),
        _fetch.enable(handleAuthRequests: true, patterns: [fetch.RequestPattern(urlPattern: '*')]),
      ]);
    } else {
      await Future.wait([
        _updateProtocolCacheDisabled(),
        _fetch.disable(),
      ]);
    }
  }

  Future _updateProtocolCacheDisabled() {
    return _network.setCacheDisabled(_userCacheDisabled || _protocolRequestInterceptionEnabled);
  }

  void _onRequestWillBeSent(RequestWillBeSentEvent event) {
    // Request interception doesn't happen for data URLs with Network Service.
    if (_protocolRequestInterceptionEnabled && !event.request.url.startsWith('data:')) {
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
    var response = 'Default';
    if (_attemptedAuthentications.contains(event.requestId.value)) {
      response = 'CancelAuth';
    } else if (_credentials != null) {
      response = 'ProvideCredentials';
      _attemptedAuthentications.add(event.requestId.value);
    }

    _fetch.continueWithAuth(event.requestId, fetch.AuthChallengeResponse(response: response, username: _credentials?.userName, password: _credentials?.password));
  }

  void _onRequestPaused(RequestPausedEvent event) async {
    if (!_userRequestInterceptionEnabled && _protocolRequestInterceptionEnabled) {
      await _fetch.continueRequest(event.requestId);
    }

    var requestId = event.networkId;
    var interceptionId = event.requestId;
    if (requestId != null && _requestIdToRequestWillBeSentEvent.containsKey(requestId.value)) {
    var requestWillBeSentEvent = _requestIdToRequestWillBeSentEvent[requestId.value];
    _onRequest(requestWillBeSentEvent, interceptionId.value);
    _requestIdToRequestWillBeSentEvent.remove(requestId.value);
    } else {
    _requestIdToInterceptionId[requestId.value] = interceptionId.value;
    }
  }

  void _onRequest(RequestWillBeSentEvent event, String interceptionId) {
    var redirectChain = [];
    if (event.redirectResponse != null) {
      var request = _requestIdToRequest[event.requestId.value];
      // If we connect late to the target, we could have missed the requestWillBeSent event.
      if (request != null) {
        _handleRequestRedirect(request, event.redirectResponse);
        redirectChain = request._redirectChain;
      }
    }
    var frame = event.frameId != null ? frameManager.frame(event.frameId) : null;
    var request = NetworkRequest(_client, frame, interceptionId, this._userRequestInterceptionEnabled, event, redirectChain);
    _requestIdToRequest[event.requestId.value] = request;
    _onRequestController.add(request);
  }

  void _onRequestServedFromCache(network.RequestId requestId) {
    var request = _requestIdToRequest[requestId.value];
    if (request != null)
      request._fromMemoryCache = true;
  }

  void _handleRequestRedirect(NetworkRequest request, Response responsePayload) {
    var response = new NetworkResponse(client, request, responsePayload);
    request._response = response;
    request._redirectChain.add(request);
    response._bodyLoadedCompleter.complete(new Exception('Response body is unavailable for redirect responses'));
    _requestIdToRequest.remove(request._requestId);
    _attemptedAuthentications.remove(request._interceptionId);
    _onResponseController.add(response);
    _onRequestFinishedController.add(request);
  }

  void _onResponseReceived(network.ResponseReceivedEvent event) {
    var request = _requestIdToRequest[event.requestId.value];
    // FileUpload sends a response without a matching request.
    if (request == null)
      return;
    var response = new NetworkResponse(client, request, event.response);
    request._response = response;
    _onResponseController.add(response);
  }

  /**
   * @param {!Protocol.Network.loadingFinishedPayload} event
   */
  void _onLoadingFinished(LoadingFinishedEvent event) {
    var request = _requestIdToRequest[event.requestId.value];
    // For certain requestIds we never receive requestWillBeSent event.
    // @see https://crbug.com/750469
    if (request == null)
      return;

    // Under certain conditions we never get the Network.responseReceived
    // event from protocol. @see https://crbug.com/883475
    if (request.response())
      request.response()._bodyLoadedPromiseFulfill.call(null);
    this._requestIdToRequest.delete(request._requestId);
    this._attemptedAuthentications.delete(request._interceptionId);
    this.emit(Events.NetworkManager.RequestFinished, request);
  }

  /**
   * @param {!Protocol.Network.loadingFailedPayload} event
   */
  _onLoadingFailed(event) {
    const request = this._requestIdToRequest.get(event.requestId);
    // For certain requestIds we never receive requestWillBeSent event.
    // @see https://crbug.com/750469
    if (!request)
      return;
    request._failureText = event.errorText;
    const response = request.response();
    if (response)
      response._bodyLoadedPromiseFulfill.call(null);
    this._requestIdToRequest.delete(request._requestId);
    this._attemptedAuthentications.delete(request._interceptionId);
    this.emit(Events.NetworkManager.RequestFailed, request);
  }
}

class NetworkRequest {

}

class NetworkResponse {

}

class Credentials {
  final String userName, password;

  Credentials(this.userName, this.password);
}