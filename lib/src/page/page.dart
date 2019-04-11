import 'dart:async';

import 'package:chrome_dev_tools/domains/log.dart';
import 'package:chrome_dev_tools/domains/network.dart';
import 'package:chrome_dev_tools/domains/page.dart';
import 'package:chrome_dev_tools/domains/performance.dart';
import 'package:chrome_dev_tools/domains/runtime.dart';
import 'package:chrome_dev_tools/domains/target.dart';
import 'package:chrome_dev_tools/src/connection.dart';
import 'package:chrome_dev_tools/src/page/frame_manager.dart';
import 'package:chrome_dev_tools/src/page/worker.dart';
import 'package:chrome_dev_tools/src/tab.dart';
import 'package:meta/meta.dart';
import '../connection.dart' show Session;

class Page {
  static Future<Page> create(Tab tab) async {
    var page = Page._(tab);

    await Future.wait([
      page._frameManager.initialize(),
      tab.target.setAutoAttach(true, false, flatten: true),
      tab.performance.enable(),
      tab.log.enable(),
    ]);

    return page;
  }

  Page._(this.tab) {
    _frameManager = FrameManager(this);

    tab.target.onAttachedToTarget.listen((e) {
      if (e.targetInfo.type != 'worker') {
        // If we don't detach from service workers, they will never die.
        tab.target.detachFromTarget(sessionId: e.sessionId);
      } else {
        var session = Session(tab.target, e.sessionId);
        var worker = new Worker(session, e.targetInfo.url);
        _workers[e.sessionId] = worker;
        _workerCreated.add(worker);
      }
    });
    tab.target.onDetachedFromTarget.listen((e) {
      var worker = _workers[e.sessionId];
      if (worker != null) {
        _workerDestroyed.add(worker);
        _workers.remove(e.sessionId);
      }
    });

    // TODO(xha): onConsoleAPI: récupérer tous les arguments du console.xx et les convertir en string
    tab.runtime.onConsoleAPICalled.listen((e) {


      //If I recall correctly Log.entryAdded() shows errors and warning from Chrome (e.g., XSS violations and such), not necessarily coming from the console.* API.
    });

    tab.runtime.onBindingCalled.listen(_onBindingCalled);
    tab.page.onJavascriptDialogOpening.listen(_onDialog);
    tab.runtime.onExceptionThrown.listen(_onExceptionThrown);
    tab.inspector.onTargetCrashed.listen(_onTargetCrashed);
    tab.performance.onMetrics.listen(_onPerformanceMetric);
    tab.log.onEntryAdded.listen(_onLogEntryAdded);
  }

  final Tab tab;
  final _pageBindings = <String, Function>{};
  final _workers = <SessionID, Worker>{};
  FrameManager _frameManager;
  final StreamController _workerCreated = StreamController.broadcast();
  final StreamController _workerDestroyed = StreamController.broadcast();

  Stream<Worker> get onWorkerCreated => _workerCreated.stream;

  Stream<Worker> get onWorkerDestroyed => _workerDestroyed.stream;

  FrameManager get frames => _frameManager;

  Stream<MonotonicTime> get onDomContentLoaded =>
      tab.page.onDomContentEventFired;

  Stream<MonotonicTime> get onLoad => tab.page.onLoadEventFired;

  Future get onClose => tab.onClose;

  bool get isClosed => tab.session.isClosed;

  Future exposeFunction(String name, Function serverFunction) {}

  _onBindingCalled(BindingCalledEvent event) {}

  _onDialog(JavascriptDialogOpeningEvent event) {}

  _onExceptionThrown(ExceptionThrownEvent event) {}

  _onTargetCrashed(_) {}

  _onPerformanceMetric(MetricsEvent event) {}

  _onLogEntryAdded(LogEntry log) {

  }
}

class ConsoleMessage {
  final String type, text;
  final List args;
  final ConsoleMessageLocation location;

  ConsoleMessage(this.type, this.text, this.args, {@required this.location}) {
    assert(type != null);
    assert(text != null);
    assert(args != null);
    assert(location != null);
  }
}

class ConsoleMessageLocation {
  final String url;
  final int lineNumber, columnNumber;

  ConsoleMessageLocation(this.url, {@required this.lineNumber,@required  this.columnNumber});
}
