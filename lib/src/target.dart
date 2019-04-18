import 'dart:async';
import 'package:chrome_dev_tools/domains/target.dart';
import 'package:chrome_dev_tools/src/chrome.dart';

import '../domains/runtime.dart';
import 'package:chrome_dev_tools/src/connection.dart';
import 'tab_mixin.dart';
import 'wait_until.dart' as helper;
import 'remote_object.dart' as helper;

class Target {
  final Browser browser;
  final TargetID targetID;
  final BrowserContextID _browserContextID;
  final Future<Session> Function() _sessionFactory;
  TargetInfo _info;

  Target(this.browser, this._info, this._sessionFactory, {BrowserContextID browserContextID})
      : _browserContextID = browserContextID, targetID = _info.targetId;


}
