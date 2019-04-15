import 'dart:convert';

import 'package:chrome_dev_tools/domains/runtime.dart';

String evaluationString(String function, Map<String, dynamic> args) {
  if (args == null || args.isEmpty) {
    return function;
  } else {
    return '''
(function(${args.keys.join(', ')}) {
  $function
})(${args.values.map(jsonEncode).join(', ')})''';
  }
}

dynamic valueFromRemoteObject(RemoteObject remoteObject) {
  assert(remoteObject.objectId == null,
      'Cannot extract value when objectId is given');
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
        throw Exception('Unsupported unserializable value: ' +
            remoteObject.unserializableValue.value);
    }
  }
  return remoteObject.value;
}
