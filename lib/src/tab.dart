import 'dart:async';
import 'package:chrome_dev_tools/domains/runtime.dart';
import 'package:chrome_dev_tools/src/connection.dart';
import 'package:chrome_dev_tools/src/tab_mixin.dart';
import 'package:chrome_dev_tools/src/wait_until.dart' as helper;
import 'package:chrome_dev_tools/src/remote_object.dart' as helper;

class Tab extends Object with TabMixin {
  @override
  final Session session;

  Tab(this.session);

  Future waitUntilNetworkIdle(
          {Duration idleDuration: const Duration(milliseconds: 1000),
          int idleInFlight: 0}) =>
      helper.waitUntilNetworkIdle(network,
          idleDuration: idleDuration, idleInFlight: idleInFlight);

  Future<Map<String, dynamic>> remoteObjectProperties(
          RemoteObject remoteObject) =>
      helper.remoteObjectProperties(runtime, remoteObject);

  Future<dynamic> remoteObject(RemoteObject remoteObject) =>
      helper.remoteObject(runtime, remoteObject);
}
