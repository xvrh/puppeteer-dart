import 'dart:async';
import '../protocol/target.dart';
import 'browser.dart';
import 'connection.dart';
import 'page/page.dart';
import 'page/worker.dart';

class Target {
  /// Get the browser the target belongs to.
  final Browser browser;

  /// The browser context the target belongs to.
  final BrowserContext browserContext;

  final TargetID targetID;
  final Future<Session> Function() _sessionFactory;
  TargetInfo? _info;
  final _initializeCompleter = Completer<bool>();
  Future<Page>? _pageFuture;
  Future<Worker>? _workerFuture;
  late final Future<bool> _initialized;
  final _closedCompleter = Completer();
  bool _isInitialized = false;

  Target(this.browser, TargetInfo info, this._sessionFactory,
      {required this.browserContext})
      : targetID = info.targetId {
    _initialized = _initializeCompleter.future.then((success) async {
      if (!success) return false;
      var opener = this.opener;
      if (opener == null || opener._pageFuture == null || type != 'page') {
        return true;
      }
      var openerPage = await opener._pageFuture!;

      if (openerPage.hasPopupListener) {
        openerPage.emitPopup(await page);
      }
      return true;
    });
    changeInfo(info);
  }

  Future<bool>? get initialized => _initialized;

  bool get isInitialized => _isInitialized;

  Future<void> get onClose => _closedCompleter.future;

  String get url => _info!.url;

  TargetInfo get targetInfo => _info!;

  /// Identifies what kind of target this is.
  /// Can be `"page"`, [`"background_page"`](https://developer.chrome.com/extensions/background_pages),
  /// `"service_worker"`, `"shared_worker"`, `"browser"` or `"other"`.
  String? get type {
    var type = _info!.type;
    if (const [
      'page',
      'background_page',
      'service_worker',
      'shared_worker',
      'browser'
    ].contains(type)) return type;
    return 'other';
  }

  /// Get the target that opened this target. Top-level targets return `null`.
  Target? get opener {
    return _info!.openerId != null ? browser.targetById(_info!.openerId) : null;
  }

  bool get isPage => _info!.type == 'page' || _info!.type == 'background_page';

  Future<Page> get page {
    if (!isPage) {
      throw Exception('The target is not page or background_page. '
          'Check `isPage` before accessing the `page` getter');
    }

    _pageFuture ??= _sessionFactory().then((session) =>
        Page.create(this, session, viewport: browser.defaultViewport));
    return _pageFuture!;
  }

  Future<Worker?> get worker async {
    if (_info!.type != 'service_worker' && _info!.type != 'shared_worker') {
      return null;
    }
    _workerFuture ??= _sessionFactory().then((client) async {
      return _sessionFactory().then((client) => Worker(client, _info!.url,
          onConsoleApiCalled: null, onExceptionThrown: null));
    });
    return _workerFuture;
  }

  void changeInfo(TargetInfo info) {
    _info = info;

    if (!_initializeCompleter.isCompleted &&
        (_info!.type != 'page' || _info!.url != '')) {
      _isInitialized = true;
      _initializeCompleter.complete(true);
    }
  }

  void onDestroyed() {
    if (!_initializeCompleter.isCompleted) {
      _initializeCompleter.complete(false);
    }
    _closedCompleter.complete();
  }
}
