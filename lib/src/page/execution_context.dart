import 'dart:async';

import 'package:puppeteer/protocol/dom.dart';
import 'package:puppeteer/protocol/page.dart';
import 'package:puppeteer/protocol/runtime.dart';
import 'package:puppeteer/src/connection.dart';
import 'package:puppeteer/src/javascript_function_parser.dart';
import 'package:puppeteer/src/page/dom_world.dart';
import 'package:puppeteer/src/page/frame_manager.dart';
import 'package:puppeteer/src/page/js_handle.dart';

const evaluationScriptUrl = '__puppeteer_evaluation_script__';
final RegExp sourceUrlRegExp =
    RegExp(r'^[\040\t]*\/\/[@#] sourceURL=\s*(\S*?)\s*$', multiLine: true);

class ExecutionContext {
  final Client client;
  final RuntimeApi runtimeApi;
  final DOMApi domApi;
  final PageApi pageApi;
  final ExecutionContextDescription context;
  final DomWorld world;

  ExecutionContext(this.client, this.context, this.world)
      : runtimeApi = RuntimeApi(client),
        domApi = DOMApi(client),
        pageApi = PageApi(client);

  PageFrame get frame => world?.frame;

  Future<T> evaluate<T>(@javascript String pageFunction, {List args}) async {
    var handle = await evaluateHandle(pageFunction, args: args);
    T result = await handle.jsonValue;
    await handle.dispose();
    return result;
  }

  Future<JsHandle> evaluateHandle(@javascript String pageFunction,
      {List args}) async {
    // Try to convert a function shorthand (ie: '(el) => el.value;' to a full
    // function declaration (function(el) { return el.value; })
    // If it can't parse the shorthand function, it considers it as a
    // JavaScript expression.
    String functionDeclaration = convertToFunctionDeclaration(pageFunction);

    try {
      if (functionDeclaration == null) {
        assert(args == null || args.isEmpty,
            "Javascript expression can't have arguments ($pageFunction)");
        var response = await runtimeApi.evaluate(pageFunction,
            contextId: context.id,
            returnByValue: false,
            awaitPromise: true,
            userGesture: true);

        return _createJsHandle(response.result);
      } else {
        args ??= [];

        var result = await runtimeApi.callFunctionOn(functionDeclaration,
            executionContextId: context.id,
            arguments: args.map(_convertArgument).toList(),
            returnByValue: false,
            awaitPromise: true,
            userGesture: true);

        return _createJsHandle(result.result);
      }
    } on ServerException catch (e) {
      if (e.message.contains('Cannot find context with specified id') ||
          e.message.contains('Execution context was destroyed')) {
        throw ExecutionContextDestroyedException();
      }
      rethrow;
    }
  }

  CallArgument _convertArgument(arg) {
    if (arg is BigInt) {
      return CallArgument(unserializableValue: UnserializableValue('$arg'));
    }
    if (arg is double) {
      if (arg == 0 && arg.isNegative) {
        return CallArgument(unserializableValue: UnserializableValue('-0'));
      }
      if (arg.isInfinite) {
        return CallArgument(
            unserializableValue:
                UnserializableValue((arg.isNegative ? '-' : '') + 'Infinity'));
      }
      if (arg.isNaN) {
        return CallArgument(unserializableValue: UnserializableValue('NaN'));
      }
    }
    if (arg is JsHandle) {
      if (arg.context != this) {
        throw Exception(
            'JSHandles can be evaluated only in the context they were created!');
      }
      if (arg.isDisposed) {
        throw Exception('JSHandle is disposed!');
      }
      if (arg.remoteObject.unserializableValue != null) {
        return CallArgument(
            unserializableValue: arg.remoteObject.unserializableValue);
      }
      if (arg.remoteObject.objectId != null) {
        return CallArgument(objectId: arg.remoteObject.objectId);
      } else {
        return CallArgument(value: arg.remoteObject.value);
      }
    }
    return CallArgument(value: arg);
  }

  Future<JsHandle> queryObjects(JsHandle prototypeHandle) async {
    assert(!prototypeHandle.isDisposed, 'Prototype JSHandle is disposed!');
    assert(prototypeHandle.remoteObject.objectId != null,
        'Prototype JSHandle must not be referencing primitive value');
    var response =
        await runtimeApi.queryObjects(prototypeHandle.remoteObject.objectId);

    return _createJsHandle(response);
  }

  Future<ElementHandle> adoptElementHandle(ElementHandle elementHandle) async {
    assert(elementHandle.context != this,
        'Cannot adopt handle that already belongs to this execution context');
    assert(world != null, 'Cannot adopt handle without DOMWorld');

    var nodeInfo = await domApi.describeNode(
        objectId: elementHandle.remoteObject.objectId);
    var object = await domApi.resolveNode(
        backendNodeId: nodeInfo.backendNodeId, executionContextId: context.id);

    return _createJsHandle(object);
  }

  JsHandle _createJsHandle(RemoteObject remoteObject) =>
      JsHandle.fromRemoteObject(this, remoteObject);
}

class ExecutionContextDestroyedException implements Exception {
  @override
  toString() =>
      'Execution context was destroyed, most likely because of a navigation.';
}

const _Language javascript = _Language('js');

class _Language {
  const _Language(String language);
}
