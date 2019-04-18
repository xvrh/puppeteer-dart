import 'dart:async';
import 'package:chrome_dev_tools/domains/target.dart';
import 'package:chrome_dev_tools/src/chrome.dart';
import 'package:chrome_dev_tools/src/page/page.dart';
import 'package:meta/meta.dart';
import 'package:chrome_dev_tools/src/connection.dart';

class Target {
  final Browser browser;
  final BrowserContext browserContext;
  final TargetID targetID;
  final Future<Session> Function() _sessionFactory;
  TargetInfo _info;
  final _initializeCompleter = Completer<bool>();
  Future<Page> _pageFuture;
  Future<bool> _initialized;
  final _closedCompleter = Completer();
  bool _isInitialized = false;

  Target(this.browser, this._info, this._sessionFactory, {@required this.browserContext})
      : targetID = _info.targetId {
    _initialized = _initializeCompleter.future.then((success) async {
      if (!success)
        return false;
      var opener = this.opener;
      if (opener == null || opener._pageFuture == null || type != 'page')
        return true;

      var openerPage = await opener._pageFuture;

      if (openerPage.hasPopupListener) {
        openerPage.emitPopup(await page);
      }
      return true;
    });
  }

  Future<bool> get initialized => _initialized;

  bool get isInitialized => _isInitialized;

  Future get onClose => _closedCompleter.future;

  String get url => _info.url;

  String get type {
    var type = _info.type;
    if (type == 'page' || type == 'background_page' || type == 'service_worker' || type == 'browser')
      return type;
    return 'other';
  }

  Target get opener {
    return _info.openerId != null ? browser.targetById(_info.openerId) : null;
  }

  Future<Page> get page {
    if ((_info.type == 'page' || _info.type == 'background_page') && _pageFuture == null) {
      _pageFuture = this._sessionFactory()
          .then((session) => Page.create(this, session));
  }
    return _pageFuture;
  }

  void changeInfo(TargetInfo info) {
    assert(targetID == info.targetId);

    _info = info;

    if (!_initializeCompleter.isCompleted && (_info.type != 'page' || _info.url != '')) {
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
