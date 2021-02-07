import 'dart:async';
import '../../protocol/dom.dart';
import '../../protocol/page.dart';
import '../../protocol/runtime.dart';
import '../connection.dart';
import '../javascript_function_parser.dart';
import 'dom_world.dart';
import 'frame_manager.dart';
import 'helper.dart';
import 'js_handle.dart';
import 'page.dart';

const evaluationScriptUrl = '__puppeteer_evaluation_script__';
final RegExp sourceUrlRegExp =
    RegExp(r'^[\040\t]*\/\/[@#] sourceURL=\s*(\S*?)\s*$', multiLine: true);

/// The class represents a context for JavaScript execution. A [Page] might have
/// many execution contexts:
/// - each [frame](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe)
///   has "default" execution context that is always created after frame is attached
///   to DOM. This context is returned by the [frame.executionContext] method.
/// - [Extensions](https://developer.chrome.com/extensions)'s content scripts
///   create additional execution contexts.
///
/// Besides pages, execution contexts can be found in [workers](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API).
class ExecutionContext {
  final Client client;
  final RuntimeApi runtimeApi;
  final DOMApi domApi;
  final PageApi pageApi;
  final ExecutionContextDescription context;
  final DomWorld? world;

  ExecutionContext(this.client, this.context, this.world)
      : runtimeApi = RuntimeApi(client),
        domApi = DOMApi(client),
        pageApi = PageApi(client);

  /// Frame associated with this execution context.
  ///
  /// > **NOTE** Not every execution context is associated with a frame. For
  /// example, workers and extensions have execution contexts that are not
  /// associated with frames.
  Frame? get frame => world?.frame;

  /// If the function passed to the `executionContext.evaluate` returns a [Promise],
  /// then `executionContext.evaluate` would wait for the promise to resolve and
  /// return its value.
  ///
  /// If the function passed to the `executionContext.evaluate` returns a
  /// non-[Serializable] value, then `executionContext.evaluate` resolves to `null`.
  /// DevTools Protocol also supports transferring some additional values that
  /// are not serializable by `JSON`: `-0`, `NaN`, `Infinity`, `-Infinity`, and
  /// bigint literals.
  ///
  /// ```dart
  /// var executionContext = await page.mainFrame.executionContext;
  /// var result = await executionContext.evaluate('() => Promise.resolve(8 * 7)');
  /// print(result); // prints "56"
  /// ```
  ///
  /// An expression can also be passed in instead of a function.
  ///
  /// ```dart
  /// print(await executionContext.evaluate('1 + 2')); // prints "3"
  /// ```
  ///
  /// Parameters:
  /// - `pageFunction`:  Function to be evaluated in `executionContext`
  /// - [args]:  Arguments to pass to `pageFunction`
  ///
  /// Returns [Future] which resolves to the return value of `pageFunction`
  Future<T> evaluate<T>(@Language('js') String pageFunction,
      {List? args}) async {
    try {
      var result = await _evaluateInternal<T>(pageFunction,
          args: args, returnByValue: true);
      return result;
    } catch (error) {
      if (error is ServerException &&
          (error.message.contains('Object reference chain is too long') ||
              error.message
                  .contains('Object couldn\'t be returned by value'))) {
        return null as T;
      } else {
        rethrow;
      }
    }
  }

  /// The only difference between `executionContext.evaluate` and
  /// `executionContext.evaluateHandle` is that `executionContext.evaluateHandle`
  /// returns in-page object (JSHandle).
  ///
  /// If the function passed to the `executionContext.evaluateHandle` returns a
  /// [Promise], then `executionContext.evaluateHandle` would wait for the promise
  /// to resolve and return its value.
  ///
  /// ```dart
  /// var context = await page.mainFrame.executionContext;
  /// var aHandle = await context.evaluateHandle('() => Promise.resolve(self)');
  /// print(aHandle); // Handle for the global object.
  /// ```
  ///
  /// A string can also be passed in instead of a function.
  ///
  /// ```dart
  /// var aHandle =
  ///     await context.evaluateHandle('1 + 2'); // Handle for the '3' object.
  /// ```
  ///
  /// [JSHandle] instances can be passed as arguments to the `executionContext.evaluateHandle`:
  /// ```dart
  /// var aHandle = await context.evaluateHandle('() => document.body');
  /// var resultHandle =
  ///     await context.evaluateHandle('body => body.innerHTML', args: [aHandle]);
  /// print(await resultHandle.jsonValue); // prints body's innerHTML
  /// await aHandle.dispose();
  /// await resultHandle.dispose();
  /// ```
  Future<T> evaluateHandle<T extends JsHandle>(
          @Language('js') String pageFunction,
          {List? args}) async =>
      await _evaluateInternal(pageFunction, args: args, returnByValue: false);

  Future<T> _evaluateInternal<T>(@Language('js') String pageFunction,
      {List? args, required bool returnByValue}) async {
    // Try to convert a function shorthand (ie: '(el) => el.value;' to a full
    // function declaration (function(el) { return el.value; })
    // If it can't parse the shorthand function, it considers it as a
    // JavaScript expression.
    var functionDeclaration = convertToFunctionDeclaration(pageFunction);

    const suffix = '//# sourceURL=$evaluationScriptUrl';

    try {
      if (functionDeclaration == null) {
        assert(args == null || args.isEmpty,
            "Javascript expression can't have arguments ($pageFunction)");

        var pageFunctionWithSourceUrl = sourceUrlRegExp.hasMatch(pageFunction)
            ? pageFunction
            : '$pageFunction\n$suffix';

        var response = await runtimeApi.evaluate(pageFunctionWithSourceUrl,
            contextId: context.id,
            returnByValue: returnByValue,
            awaitPromise: true,
            userGesture: true);

        if (response.exceptionDetails != null) {
          throw ClientError(response.exceptionDetails!);
        }

        return (returnByValue
            ? valueFromRemoteObject(response.result)
            : _createHandle(response.result)) as T;
      } else {
        args ??= [];

        var result = await runtimeApi.callFunctionOn(
            '$functionDeclaration\n$suffix\n',
            executionContextId: context.id,
            arguments: args.map(_convertArgument).toList(),
            returnByValue: returnByValue,
            awaitPromise: true,
            userGesture: true);

        if (result.exceptionDetails != null) {
          throw ClientError(result.exceptionDetails!);
        }

        return (returnByValue
            ? valueFromRemoteObject(result.result)
            : _createHandle(result.result)) as T;
      }
    } on ServerException catch (e) {
      if (e.message.contains('Cannot find context with specified id') ||
          e.message.contains('Execution context was destroyed') ||
          e.message.contains('Inspected target navigated or closed')) {
        throw ExecutionContextDestroyedException();
      }
      rethrow;
    }
  }

  CallArgument _convertArgument(arg) {
    if (arg is BigInt) {
      return CallArgument(unserializableValue: UnserializableValue('${arg}n'));
    }
    if (arg is double) {
      if (arg == 0 && arg.isNegative) {
        return CallArgument(unserializableValue: UnserializableValue('-0'));
      }
      if (arg.isInfinite) {
        return CallArgument(
            unserializableValue:
                UnserializableValue("${arg.isNegative ? '-' : ''}Infinity"));
      }
      if (arg.isNaN) {
        return CallArgument(unserializableValue: UnserializableValue('NaN'));
      }
    }
    if (arg is JsHandle) {
      if (arg.executionContext != this) {
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

  /// The method iterates the JavaScript heap and finds all the objects with the
  /// given prototype.
  Future<JsHandle> queryObjects(JsHandle prototypeHandle) async {
    if (prototypeHandle.isDisposed) {
      throw Exception('Prototype JSHandle is disposed!');
    }
    if (prototypeHandle.remoteObject.objectId == null) {
      throw Exception(
          'Prototype JSHandle must not be referencing primitive value');
    }
    var response =
        await runtimeApi.queryObjects(prototypeHandle.remoteObject.objectId!);

    return _createHandle(response);
  }

  Future<ElementHandle> adoptBackendNodeId(BackendNodeId backendNodeId) async {
    var object = await domApi.resolveNode(
        backendNodeId: backendNodeId, executionContextId: context.id);
    return _createHandle(object) as ElementHandle;
  }

  Future<ElementHandle> adoptElementHandle(ElementHandle elementHandle) async {
    assert(elementHandle.executionContext != this,
        'Cannot adopt handle that already belongs to this execution context');
    assert(world != null, 'Cannot adopt handle without DOMWorld');

    var nodeInfo = await domApi.describeNode(
        objectId: elementHandle.remoteObject.objectId);
    return adoptBackendNodeId(nodeInfo.backendNodeId);
  }

  JsHandle _createHandle(RemoteObject remoteObject) =>
      JsHandle.fromRemoteObject(this, remoteObject);
}

class ExecutionContextDestroyedException implements Exception {
  @override
  String toString() =>
      'Execution context was destroyed, most likely because of a navigation.';
}

class Language {
  const Language(String language);
}
