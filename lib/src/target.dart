import 'dart:async';
import 'package:collection/collection.dart';
import '../protocol/target.dart';
import 'browser.dart';
import 'connection.dart';
import 'page/page.dart';
import 'page/worker.dart';
import 'target_manager.dart';

bool _isPageTarget(TargetInfo target) =>
    const ['page', 'background_page', 'webview'].contains(target.type);

class Target {
  final Session? session;

  /// The browser context the target belongs to.
  final BrowserContext browserContext;

  final TargetManager targetManager;

  final TargetID targetID;
  final Future<Session> Function({required bool isAutoAttachEmulated})
  _sessionFactory;
  TargetInfo _info;
  final _initializeCompleter = Completer<bool>();
  Future<Page>? _pageFuture;
  Future<Worker>? _workerFuture;
  late final Future<bool> _initialized;
  final _closedCompleter = Completer();
  bool _isInitialized = false;

  Target(
    this.session,
    this.targetManager,
    TargetInfo info,
    this._sessionFactory, {
    required this.browserContext,
  }) : _info = info,
       targetID = info.targetId {
    _initialized = _initializeCompleter.future.then((success) async {
      if (!success) return false;
      var opener = this.opener;
      if (opener == null || opener._pageFuture == null || type != 'page') {
        return true;
      }
      var openerPage = await opener._pageFuture!;
      if (!openerPage.hasPopupListener) {
        return true;
      }
      var popupPage = await pageOrNull;
      if (popupPage != null) {
        openerPage.emitPopup(popupPage);
      }
      return true;
    });
    _isInitialized = !_isPageTarget(info) || info.url != '';
    if (_isInitialized) {
      _initializeCompleter.complete(true);
    }
  }

  Browser get browser => browserContext.browser;

  Future<bool> get initialized => _initialized;

  bool get isInitialized => _isInitialized;

  Future<void> get onClose => _closedCompleter.future;

  String get url => _info.url;

  TargetInfo get targetInfo => _info;

  /// Identifies what kind of target this is.
  /// Can be `"page"`, [`"background_page"`](https://developer.chrome.com/extensions/background_pages),
  /// `"service_worker"`, `"shared_worker"`, `"browser"`, `"webview"` or `"other"`.
  String get type {
    var type = _info.type;
    if (_possibleTargetTypes.contains(type)) return type;
    return 'other';
  }

  /// Sets the kind of target this is.
  /// Must be `"page"`, [`"background_page"`](https://developer.chrome.com/extensions/background_pages),
  /// `"service_worker"`, `"shared_worker"`, `"browser"` or `"webview"`.
  set type(String targetType) {
    if (_possibleTargetTypes.contains(targetType)) {
      final json = _info.toJson();
      json['type'] = targetType;
      _info = TargetInfo.fromJson(json);
    }
  }

  /// Get the target that opened this target. Top-level targets return `null`.
  Target? get opener {
    return _info.openerId != null
        ? browser.targets.firstWhereOrNull((e) => e.targetID == _info.openerId)
        : null;
  }

  Future<Page> get page async => (await pageOrNull)!;

  bool get isPage => _isPageTarget(_info);

  /// If the target is not of type `"page"` or `"background_page"`, returns `null`.
  Future<Page?> get pageOrNull async {
    if (_isPageTarget(_info) && _pageFuture == null) {
      var session = this.session;
      _pageFuture =
          (session != null
                  ? Future.value(session)
                  : _sessionFactory(isAutoAttachEmulated: true))
              .then(
                (session) => Page.create(
                  this,
                  session,
                  viewport: browser.defaultViewport,
                ),
              );
    }
    return await _pageFuture;
  }

  /// If the target is not of type `"service_worker"` or `"shared_worker"`, returns `null`.
  Future<Worker?> get worker async {
    if (!const ['service_worker', 'shared_worker'].contains(_info.type)) {
      return null;
    }
    _workerFuture ??= _sessionFactory(isAutoAttachEmulated: false).then((
      client,
    ) async {
      return Worker(
        client,
        _info.url,
        onConsoleApiCalled: null,
        onExceptionThrown: null,
      );
    });
    return _workerFuture;
  }

  void changeInfo(TargetInfo info) {
    _info = info;

    if (!_initializeCompleter.isCompleted &&
        (!_isPageTarget(info) || _info.url != '')) {
      _isInitialized = true;
      _initializeCompleter.complete(true);
    }
  }

  void onDestroyed() {
    if (!_initializeCompleter.isCompleted) {
      _initializeCompleter.complete(false);
    }
    if (!_closedCompleter.isCompleted) {
      _closedCompleter.complete();
    }
  }

  bool get isDestroyed => _closedCompleter.isCompleted;
}

const _possibleTargetTypes = [
  'page',
  'background_page',
  'service_worker',
  'shared_worker',
  'browser',
  'webview',
];
