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

  Future waitUntilConsoleContains(String text) =>
      helper.waitUntilConsoleContains(log, text);

  Future<Map<String, dynamic>> remoteObjectProperties(
          RemoteObject remoteObject) =>
      helper.remoteObjectProperties(runtime, remoteObject);

  Future<dynamic> remoteObject(RemoteObject remoteObject) =>
      helper.remoteObject(runtime, remoteObject);

  Future close() => session.close();

  Future evaluate(String javascriptExpression) async {
    String javascriptFunction = '($javascriptExpression)';

    EvaluateResult result = await runtime.evaluate(javascriptFunction,
        returnByValue: true, userGesture: true, awaitPromise: true);
    RemoteObject object = result.result;

    var value = await remoteObject(object);
    return value;
  }
}

/*
async jsonValue() {
    if (this._remoteObject.objectId) {
      const response = await this._client.send('Runtime.callFunctionOn', {
        functionDeclaration: 'function() { return this; }',
        objectId: this._remoteObject.objectId,
        returnByValue: true,
        awaitPromise: true,
      });
      return helper.valueFromRemoteObject(response.result);
    }
    return helper.valueFromRemoteObject(this._remoteObject);
  }

  static valueFromRemoteObject(remoteObject) {
    console.assert(!remoteObject.objectId, 'Cannot extract value when objectId is given');
    if (remoteObject.unserializableValue) {
      switch (remoteObject.unserializableValue) {
        case '-0':
          return -0;
        case 'NaN':
          return NaN;
        case 'Infinity':
          return Infinity;
        case '-Infinity':
          return -Infinity;
        default:
          throw new Error('Unsupported unserializable value: ' + remoteObject.unserializableValue);
      }
    }
    return remoteObject.value;
  }
 */
