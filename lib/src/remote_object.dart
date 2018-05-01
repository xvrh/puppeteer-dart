import 'dart:async';

import 'package:chrome_dev_tools/domains/runtime.dart';

Future remoteObject(RuntimeManager runtime, RemoteObject remoteObject) async {
  if (remoteObject.subtype == 'error')
    throw 'RemoteObject has error: ${remoteObject.description}';

  if (remoteObject.unserializableValue != null) {
    switch (remoteObject.unserializableValue.value) {
      case '-0':
        return -0;
      case 'NaN':
        return double.NAN;
      case 'Infinity':
        return double.INFINITY;
      case '-Infinity':
        return double.NEGATIVE_INFINITY;
      default:
        throw new Exception(
            'Unsupported unserializable value: ${remoteObject.unserializableValue}');
    }
  }
  if (remoteObject.objectId == null) {
    return remoteObject.value;
  }
  if (remoteObject.subtype == 'promise') {
    return remoteObject.description;
  }
  try {
    final response = await runtime.callFunctionOn('function() { return this; }',
        objectId: remoteObject.objectId, returnByValue: true);
    return response.result.value;
  } catch (e) {
    // Return description for unserializable object, e.g. 'window'.
    return remoteObject.description;
  } finally {
    await releaseObject(runtime, remoteObject);
  }
}

Future<Map<String, dynamic>> remoteObjectProperties(
    RuntimeManager runtime, RemoteObject remoteObject) async {
  var properties = await runtime.getProperties(remoteObject.objectId);

  Map<String, dynamic> result = {};

  for (PropertyDescriptor property in properties.result) {
    if (property.value != null &&
        property.enumerable &&
        property.value.type != 'function') {
      result[property.name] = property.value.value;
    }
  }
  return result;
}

Future releaseObject(RuntimeManager runtime, RemoteObject remoteObject) async {
  if (remoteObject.objectId == null) return;
  try {
    await runtime.releaseObject(remoteObject.objectId);
  } catch (e) {
    // Exceptions might happen in case of a page been navigated or closed.
    // Swallow these since they are harmless and we don't leak anything in this case.
  }
}
