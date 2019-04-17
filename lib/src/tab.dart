import 'dart:async';
import 'package:chrome_dev_tools/domains/target.dart';
import 'package:chrome_dev_tools/src/chrome.dart';
import 'package:chrome_dev_tools/src/page/emulation_manager.dart';

import '../domains/runtime.dart';
import 'package:chrome_dev_tools/src/connection.dart';
import 'tab_mixin.dart';
import 'wait_until.dart' as helper;
import 'remote_object.dart' as helper;

class Tab extends Object with TabMixin {
  final Chrome browser;
  final TargetID targetID;
  final BrowserContextID _browserContextID;

  @override
  final Session session;

  Tab(this.browser, this.targetID, this.session, {BrowserContextID browserContextID})
      : _browserContextID = browserContextID;

  Future get onClose => session.onClose;

  Future waitUntilNetworkIdle(
          {Duration idleDuration = const Duration(milliseconds: 1000),
          int idleInFlight = 0}) =>
      helper.waitUntilNetworkIdle(network,
          idleDuration: idleDuration, idleInFlight: idleInFlight);

  Future waitUntilConsoleContains(String text) =>
      helper.waitUntilConsoleContains(log, text);

  Future<Map<String, dynamic>> remoteObjectProperties(
          RemoteObject remoteObject) =>
      helper.remoteObjectProperties(runtime, remoteObject);

  Future<dynamic> remoteObject(RemoteObject remoteObject) =>
      helper.remoteObject(runtime, remoteObject);

  Future close() async {
    await session.targetApi.closeTarget(targetID);
    if (_browserContextID != null) {
      await session.targetApi.disposeBrowserContext(_browserContextID);
    }
    await onClose;
  }

  Future<dynamic> evaluate(String javascriptExpression) async {
    String javascriptFunction = '($javascriptExpression)';

    EvaluateResult result = await runtime.evaluate(javascriptFunction,
        returnByValue: true, userGesture: true, awaitPromise: true);
    RemoteObject object = result.result;

    dynamic value = await remoteObject(object);
    return value;
  }
}
