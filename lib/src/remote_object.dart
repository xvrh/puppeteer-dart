import 'dart:async';
import '../domains/runtime.dart';

Future<dynamic> remoteObject(
    RuntimeApi runtime, RemoteObject remoteObject) async {
  if (remoteObject.subtype == RemoteObjectSubtype.error) {
    throw 'RemoteObject has error: ${remoteObject.description}';
  }

  if (remoteObject.type == RemoteObjectType.undefined) {
    return null;
  }

  if (remoteObject.value != null) {
    return remoteObject.value;
  }

  if (remoteObject.unserializableValue != null) {
    switch (remoteObject.unserializableValue.value) {
      case '-0':
        return -0;
      case 'NaN':
        return double.nan;
      case 'Infinity':
        return double.infinity;
      case '-Infinity':
        return double.negativeInfinity;
      default:
        throw Exception(
            'Unsupported unserializable value: ${remoteObject.unserializableValue}');
    }
  }
  if (remoteObject.objectId == null) {
    return remoteObject.value;
  }
  if (remoteObject.subtype == RemoteObjectSubtype.promise) {
    return remoteObject.description;
  }
  try {
    final response = await runtime.callFunctionOn('function() { return this; }',
        objectId: remoteObject.objectId, returnByValue: true);
    return response.result.value;
  } catch (_) {
    // Return description for unserializable object, e.g. 'window'.
    return remoteObject.description;
  } finally {
    await releaseObject(runtime, remoteObject);
  }
}

Future<Map<String, dynamic>> remoteObjectProperties(
    RuntimeApi runtime, RemoteObject remoteObject) async {
  var properties = await runtime.getProperties(remoteObject.objectId);

  Map<String, dynamic> result = {};

  for (PropertyDescriptor property in properties.result) {
    if (property.value != null &&
        property.enumerable &&
        property.value.type != RemoteObjectType.function) {
      result[property.name] = property.value.value;
    }
  }
  return result;
}

Future releaseObject(RuntimeApi runtime, RemoteObject remoteObject) async {
  if (remoteObject.objectId == null) return;
  try {
    await runtime.releaseObject(remoteObject.objectId);
  } catch (_) {
    // Exceptions might happen in case of a page been navigated or closed.
    // Swallow these since they are harmless and we don't leak anything in this case.
  }
}
