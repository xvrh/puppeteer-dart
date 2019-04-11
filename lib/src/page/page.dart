import 'dart:async';

import 'package:chrome_dev_tools/domains/network.dart';
import 'package:chrome_dev_tools/domains/target.dart';
import 'package:chrome_dev_tools/src/connection.dart';
import 'package:chrome_dev_tools/src/page/frame_manager.dart';
import 'package:chrome_dev_tools/src/page/worker.dart';
import 'package:chrome_dev_tools/src/tab.dart';
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
  }

  final Tab tab;
  final _pageBindings = <String, Function>{};
  final _workers = <SessionID, Worker>{};
  FrameManager _frameManager;
  bool _closed = false;
  final StreamController _workerCreated = StreamController.broadcast();
  final StreamController _workerDestroyed = StreamController.broadcast();

  Stream<Worker> get onWorkerCreated => _workerCreated.stream;
  Stream<Worker> get onWorkerDestroyed => _workerDestroyed.stream;

  FrameManager get frames => _frameManager;

  Stream<MonotonicTime> get onDomContentLoaded => tab.page.onDomContentEventFired;
  Stream<MonotonicTime> get onLoad => tab.page.onLoadEventFired;

  Future exposeFunction(String name, Function serverFunction) {
    tab.runtime.onConsoleAPICalled.
  }
}
