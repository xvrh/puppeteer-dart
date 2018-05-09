import 'dart:async';
import '../domains/runtime.dart';
import 'connection.dart';
import 'tab_mixin.dart';
import 'wait_until.dart' as helper;
import 'remote_object.dart' as helper;

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

  Future<dynamic> evaluate(String javascript) {
    //TODO(xha): evaluer le javascript et essayer de retourner la valeur en Dart

    //TODO(xha): faire des tests pour tester le comportement avec des valeurs primitives,
    // des List, Map et des objets avec plusieurs niveaux.
  }

  Future close() => session.close();
}
