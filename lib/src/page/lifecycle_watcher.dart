import 'dart:async';

import 'package:puppeteer/protocol/network.dart';
import 'package:puppeteer/src/page/frame_manager.dart';
import 'package:puppeteer/src/page/network_manager.dart';

class LifecycleWatcher {
  final FrameManager frameManager;
  final PageFrame frame;
  final WaitUntil waitUntil;
  final Duration timeout;
  List<StreamSubscription> _subscriptions;
  LoaderId _initialLoaderId;
  NetworkRequest _navigationRequest;
  final _sameDocumentNavigationCompleter = Completer<Exception>(),
      _lifecycleCompleter = Completer<Exception>(),
      _terminationCompleter = Completer<Exception>(),
      _newDocumentNavigationCompleter = Completer<Exception>();
  Future _timeoutFuture;
  bool _hasSameDocumentNavigation = false;
  Timer _timeoutTimer;

  LifecycleWatcher(this.frameManager, this.frame,
      {WaitUntil waitUntil, this.timeout})
      : waitUntil = waitUntil ?? WaitUntil.load {
    _initialLoaderId = frame.loaderId;

    _subscriptions = [
      frameManager.onLifecycleEvent.listen(_checkLifecycleComplete),
      frameManager.onFrameNavigatedWithinDocument
          .listen(_navigatedWithinDocument),
      frameManager.onFrameDetached.listen(_onFrameDetached),
      frameManager.networkManager.onRequest.listen(_onRequest),
    ];

    _timeoutFuture = _createTimeoutFuture();
    _checkLifecycleComplete();
  }

  Future<Exception> get timeoutOrTermination {
    return Future.any([
      _timeoutFuture,
      _terminationCompleter.future,
      frameManager.page.session.closed.then((_) =>
          Exception('Navigation failed because browser has disconnected!'))
    ]);
  }

  Future<Exception> get newDocumentNavigation =>
      _newDocumentNavigationCompleter.future;

  Future<Exception> get sameDocumentNavigation =>
      _sameDocumentNavigationCompleter.future;

  Future<Exception> get lifecycle => _lifecycleCompleter.future;

  NetworkResponse get navigationResponse {
    return _navigationRequest != null ? _navigationRequest.response : null;
  }

  void _onRequest(NetworkRequest request) {
    if (request.frame != frame || !request.isNavigationRequest) {
      return;
    }
    _navigationRequest = request;
  }

  void _onFrameDetached(PageFrame frame) {
    if (this.frame == frame) {
      _terminationCompleter
          .complete(new Exception('Navigating frame was detached'));
      return;
    }
    _checkLifecycleComplete();
  }

  Future<Exception> _createTimeoutFuture() {
    if (timeout == null || timeout == Duration.zero) {
      return Completer<Exception>().future;
    }
    var errorMessage =
        'Navigation Timeout Exceeded: ${timeout.inMilliseconds}ms exceeded';
    var completer = Completer<Exception>();
    _timeoutTimer =
        Timer(timeout, () => completer.complete(Exception(errorMessage)));
    return completer.future;
  }

  void _navigatedWithinDocument(PageFrame frame) {
    if (frame != this.frame) return;
    _hasSameDocumentNavigation = true;
    _checkLifecycleComplete();
  }

  void _checkLifecycleComplete([_]) {
    // We expect navigation to commit.
    if (!_checkLifecycle(frame)) return;

    if (!_lifecycleCompleter.isCompleted) {
      _lifecycleCompleter.complete();
    }
    if (frame.loaderId == _initialLoaderId && !_hasSameDocumentNavigation) {
      return;
    }
    if (_hasSameDocumentNavigation) {
      _sameDocumentNavigationCompleter.complete();
    }
    if (frame.loaderId != _initialLoaderId) {
      _newDocumentNavigationCompleter.complete();
    }
  }

  bool _checkLifecycle(PageFrame frame) {
    for (var event in waitUntil._events) {
      if (!frame.lifecycleEvents.contains(event)) return false;
    }
    for (var child in frame.children) {
      if (!_checkLifecycle(child)) return false;
    }
    return true;
  }

  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _timeoutTimer?.cancel();
  }
}

class WaitUntil {
  static final load = WaitUntil._('load');
  static final domContentLoaded = WaitUntil._('DOMContentLoaded');
  static final networkIdle = WaitUntil._('networkIdle');
  static final networkAlmostIdle = WaitUntil._('networkAlmostIdle');

  final List<String> _events = [];

  WaitUntil._(String event) {
    _events.add(event);
  }

  WaitUntil.multi(List<WaitUntil> waitUntils) {
    for (WaitUntil waitUntil in waitUntils) {
      _events.addAll(waitUntil._events);
    }
  }
}
