import 'dart:convert';
import '../../protocol/runtime.dart';
import '../javascript_function_parser.dart';

String evaluationString(String function, List args) {
  String functionDeclaration = convertToFunctionDeclaration(function);

  if (functionDeclaration == null) {
    return function;
  } else {
    args ??= [];
    return '($functionDeclaration)(${args.map(jsonEncode).join(', ')})';
  }
}

dynamic valueFromRemoteObject(RemoteObject remoteObject) {
  assert(remoteObject.objectId == null,
      'Cannot extract value when objectId is given');
  if (remoteObject.unserializableValue != null) {
    if (remoteObject.type == RemoteObjectType.bigint)
      return BigInt.tryParse(
          remoteObject.unserializableValue.value.replaceAll('n', ''));
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

Future<void> releaseObject(
    RuntimeApi runtimeApi, RemoteObject remoteObject) async {
  if (remoteObject.objectId == null) return;
  await runtimeApi.releaseObject(remoteObject.objectId);
}
