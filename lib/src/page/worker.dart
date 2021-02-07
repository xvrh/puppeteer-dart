import 'dart:async';
import '../../protocol/runtime.dart';
import '../../puppeteer.dart';
import '../connection.dart';
import 'execution_context.dart';

/// The Worker class represents a [WebWorker](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API).
/// The events `workercreated` and `workerdestroyed` are emitted on the page
/// object to signal the worker lifecycle.
///
/// ```dart
/// page.onWorkerCreated
///     .listen((worker) => print('Worker created: ${worker.url}'));
/// page.onWorkerDestroyed
///     .listen((worker) => print('Worker destroyed: ${worker.url}'));
/// print('Current workers:');
/// for (var worker in page.workers) {
///   print('  ${worker.url}');
/// }
/// ```
class Worker {
  final Client client;
  final String? url;
  final _executionContextCompleter = Completer<ExecutionContext>();

  Worker(this.client, this.url,
      {required void Function(
              ConsoleAPICalledEventType, List<JsHandle>, StackTraceData?)?
          onConsoleApiCalled,
      required void Function(ExceptionThrownEvent)? onExceptionThrown}) {
    var runtimeApi = RuntimeApi(client);

    late JsHandle Function(RemoteObject) jsHandleFactory;
    runtimeApi.onExecutionContextCreated.listen((event) {
      var executionContext = ExecutionContext(client, event, null);
      jsHandleFactory =
          (remoteObject) => JsHandle(executionContext, remoteObject);
      _executionContextCompleter.complete(executionContext);
    });

    runtimeApi.onConsoleAPICalled.listen((event) {
      if (onConsoleApiCalled != null) {
        onConsoleApiCalled(event.type, event.args.map(jsHandleFactory).toList(),
            event.stackTrace);
      }
    });
    runtimeApi.onExceptionThrown.listen((event) {
      if (onExceptionThrown != null) {
        onExceptionThrown(event);
      }
    });

    runtimeApi.enable().catchError((e) {
      // This might fail if the target is closed before we recieve all execution contexts.
    });
  }

  Future<ExecutionContext> get executionContext =>
      _executionContextCompleter.future;

  /// If the function passed to the [Frame.evaluate] returns a [Promise], then
  /// [Frame.evaluate] would wait for the promise to resolve and return its value.
  ///
  /// If the function passed to the [Frame.evaluate] returns a non-[Serializable]
  /// value, then `Frame.evaluate` resolves to null.
  /// DevTools Protocol also supports transferring some additional values that
  /// are not serializable by `JSON`: `-0`, `NaN`, `Infinity`, `-Infinity`, and
  /// bigint literals.
  ///
  /// Shortcut for [(await worker.executionContext).evaluate].
  ///
  /// Parameters:
  /// - [pageFunction] Function to be evaluated in the page context
  /// - [args] Arguments to pass to `pageFunction`
  /// - Returns: Future which resolves to the return value of `pageFunction`
  Future<T?> evaluate<T>(@Language('js') String pageFunction,
      {List? args}) async {
    return (await executionContext).evaluate<T>(pageFunction, args: args);
  }

  /// The only difference between [Worker.evaluate] and [Worker.evaluateHandle] is
  /// that [Worker.evaluateHandle] returns in-page object (JSHandle).
  ///
  /// If the function passed to the [Worker.evaluateHandle] returns a [Promise],
  /// then [Worker.evaluateHandle] would wait for the promise to resolve and
  /// return its value.
  ///
  /// Shortcut for [(await worker.executionContext).evaluateHandle].
  ///
  /// Parameters:
  /// - [pageFunction] Function to be evaluated in the page context
  /// - [args] Arguments to pass to [pageFunction]
  ///
  /// returns: Future which resolves to the return value of `pageFunction` as
  /// in-page object (JSHandle)
  Future<T> evaluateHandle<T extends JsHandle>(
      @Language('js') String pageFunction,
      {List? args}) async {
    return (await executionContext).evaluateHandle(pageFunction, args: args);
  }
}
