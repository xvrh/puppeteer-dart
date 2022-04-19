import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import '../../protocol/io.dart';
import '../../protocol/runtime.dart';
import '../javascript_function_parser.dart';

final _logger = Logger('puppeteer.helper');

String evaluationString(String function, List? args) {
  var functionDeclaration = convertToFunctionDeclaration(function);

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
    if (remoteObject.type == RemoteObjectType.bigint) {
      return BigInt.tryParse(
          remoteObject.unserializableValue!.value.replaceAll('n', ''));
    }
    switch (remoteObject.unserializableValue!.value) {
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
            'Unsupported unserializable value: ${remoteObject.unserializableValue!.value}');
    }
  }
  return remoteObject.value;
}

Future<void> releaseObject(
    RuntimeApi runtimeApi, RemoteObject remoteObject) async {
  if (remoteObject.objectId == null) return;

  await runtimeApi
      .releaseObject(remoteObject.objectId!)
      .catchError((e, StackTrace stackTrace) {
    // Exceptions might happen in case of a page been navigated or closed.
    // Swallow these since they are harmless and we don't leak anything in this case.
    _logger.finer(e, e, stackTrace);
  });
}

Future<void> readStream(IOApi io, StreamHandle stream, IOSink output) async {
  ReadResult response;
  var base64Sink = Base64Decoder().startChunkedConversion(output);
  do {
    response = await io.read(stream);
    if (response.base64Encoded!) {
      base64Sink.add(response.data);
    } else {
      output.write(response.data);
    }
  } while (!response.eof);
  base64Sink.close();
  await io.close(stream);
}
