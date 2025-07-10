import 'dart:async';
import '../src/connection.dart';

/// Runtime domain exposes JavaScript runtime by means of remote evaluation and mirror objects.
/// Evaluation results are returned as mirror object that expose object type, string representation
/// and unique identifier that can be used for further object reference. Original objects are
/// maintained in memory unless they are either explicitly released or are released along with the
/// other objects in their object group.
class RuntimeApi {
  final Client _client;

  RuntimeApi(this._client);

  /// Notification is issued every time when binding is called.
  Stream<BindingCalledEvent> get onBindingCalled => _client.onEvent
      .where((event) => event.name == 'Runtime.bindingCalled')
      .map((event) => BindingCalledEvent.fromJson(event.parameters));

  /// Issued when console API was called.
  Stream<ConsoleAPICalledEvent> get onConsoleAPICalled => _client.onEvent
      .where((event) => event.name == 'Runtime.consoleAPICalled')
      .map((event) => ConsoleAPICalledEvent.fromJson(event.parameters));

  /// Issued when unhandled exception was revoked.
  Stream<ExceptionRevokedEvent> get onExceptionRevoked => _client.onEvent
      .where((event) => event.name == 'Runtime.exceptionRevoked')
      .map((event) => ExceptionRevokedEvent.fromJson(event.parameters));

  /// Issued when exception was thrown and unhandled.
  Stream<ExceptionThrownEvent> get onExceptionThrown => _client.onEvent
      .where((event) => event.name == 'Runtime.exceptionThrown')
      .map((event) => ExceptionThrownEvent.fromJson(event.parameters));

  /// Issued when new execution context is created.
  Stream<ExecutionContextDescription> get onExecutionContextCreated => _client
      .onEvent
      .where((event) => event.name == 'Runtime.executionContextCreated')
      .map(
        (event) => ExecutionContextDescription.fromJson(
          event.parameters['context'] as Map<String, dynamic>,
        ),
      );

  /// Issued when execution context is destroyed.
  Stream<ExecutionContextDestroyedEvent> get onExecutionContextDestroyed =>
      _client.onEvent
          .where((event) => event.name == 'Runtime.executionContextDestroyed')
          .map(
            (event) =>
                ExecutionContextDestroyedEvent.fromJson(event.parameters),
          );

  /// Issued when all executionContexts were cleared in browser
  Stream<void> get onExecutionContextsCleared => _client.onEvent.where(
    (event) => event.name == 'Runtime.executionContextsCleared',
  );

  /// Issued when object should be inspected (for example, as a result of inspect() command line API
  /// call).
  Stream<InspectRequestedEvent> get onInspectRequested => _client.onEvent
      .where((event) => event.name == 'Runtime.inspectRequested')
      .map((event) => InspectRequestedEvent.fromJson(event.parameters));

  /// Add handler to promise with given promise object id.
  /// [promiseObjectId] Identifier of the promise.
  /// [returnByValue] Whether the result is expected to be a JSON object that should be sent by value.
  /// [generatePreview] Whether preview should be generated for the result.
  Future<AwaitPromiseResult> awaitPromise(
    RemoteObjectId promiseObjectId, {
    bool? returnByValue,
    bool? generatePreview,
  }) async {
    var result = await _client.send('Runtime.awaitPromise', {
      'promiseObjectId': promiseObjectId,
      if (returnByValue != null) 'returnByValue': returnByValue,
      if (generatePreview != null) 'generatePreview': generatePreview,
    });
    return AwaitPromiseResult.fromJson(result);
  }

  /// Calls function with given declaration on the given object. Object group of the result is
  /// inherited from the target object.
  /// [functionDeclaration] Declaration of the function to call.
  /// [objectId] Identifier of the object to call function on. Either objectId or executionContextId should
  /// be specified.
  /// [arguments] Call arguments. All call arguments must belong to the same JavaScript world as the target
  /// object.
  /// [silent] In silent mode exceptions thrown during evaluation are not reported and do not pause
  /// execution. Overrides `setPauseOnException` state.
  /// [returnByValue] Whether the result is expected to be a JSON object which should be sent by value.
  /// Can be overriden by `serializationOptions`.
  /// [generatePreview] Whether preview should be generated for the result.
  /// [userGesture] Whether execution should be treated as initiated by user in the UI.
  /// [awaitPromise] Whether execution should `await` for resulting value and return once awaited promise is
  /// resolved.
  /// [executionContextId] Specifies execution context which global object will be used to call function on. Either
  /// executionContextId or objectId should be specified.
  /// [objectGroup] Symbolic group name that can be used to release multiple objects. If objectGroup is not
  /// specified and objectId is, objectGroup will be inherited from object.
  /// [throwOnSideEffect] Whether to throw an exception if side effect cannot be ruled out during evaluation.
  /// [uniqueContextId] An alternative way to specify the execution context to call function on.
  /// Compared to contextId that may be reused across processes, this is guaranteed to be
  /// system-unique, so it can be used to prevent accidental function call
  /// in context different than intended (e.g. as a result of navigation across process
  /// boundaries).
  /// This is mutually exclusive with `executionContextId`.
  /// [serializationOptions] Specifies the result serialization. If provided, overrides
  /// `generatePreview` and `returnByValue`.
  Future<CallFunctionOnResult> callFunctionOn(
    String functionDeclaration, {
    RemoteObjectId? objectId,
    List<CallArgument>? arguments,
    bool? silent,
    bool? returnByValue,
    bool? generatePreview,
    bool? userGesture,
    bool? awaitPromise,
    ExecutionContextId? executionContextId,
    String? objectGroup,
    bool? throwOnSideEffect,
    String? uniqueContextId,
    SerializationOptions? serializationOptions,
  }) async {
    var result = await _client.send('Runtime.callFunctionOn', {
      'functionDeclaration': functionDeclaration,
      if (objectId != null) 'objectId': objectId,
      if (arguments != null) 'arguments': [...arguments],
      if (silent != null) 'silent': silent,
      if (returnByValue != null) 'returnByValue': returnByValue,
      if (generatePreview != null) 'generatePreview': generatePreview,
      if (userGesture != null) 'userGesture': userGesture,
      if (awaitPromise != null) 'awaitPromise': awaitPromise,
      if (executionContextId != null) 'executionContextId': executionContextId,
      if (objectGroup != null) 'objectGroup': objectGroup,
      if (throwOnSideEffect != null) 'throwOnSideEffect': throwOnSideEffect,
      if (uniqueContextId != null) 'uniqueContextId': uniqueContextId,
      if (serializationOptions != null)
        'serializationOptions': serializationOptions,
    });
    return CallFunctionOnResult.fromJson(result);
  }

  /// Compiles expression.
  /// [expression] Expression to compile.
  /// [sourceURL] Source url to be set for the script.
  /// [persistScript] Specifies whether the compiled script should be persisted.
  /// [executionContextId] Specifies in which execution context to perform script run. If the parameter is omitted the
  /// evaluation will be performed in the context of the inspected page.
  Future<CompileScriptResult> compileScript(
    String expression,
    String sourceURL,
    bool persistScript, {
    ExecutionContextId? executionContextId,
  }) async {
    var result = await _client.send('Runtime.compileScript', {
      'expression': expression,
      'sourceURL': sourceURL,
      'persistScript': persistScript,
      if (executionContextId != null) 'executionContextId': executionContextId,
    });
    return CompileScriptResult.fromJson(result);
  }

  /// Disables reporting of execution contexts creation.
  Future<void> disable() async {
    await _client.send('Runtime.disable');
  }

  /// Discards collected exceptions and console API calls.
  Future<void> discardConsoleEntries() async {
    await _client.send('Runtime.discardConsoleEntries');
  }

  /// Enables reporting of execution contexts creation by means of `executionContextCreated` event.
  /// When the reporting gets enabled the event will be sent immediately for each existing execution
  /// context.
  Future<void> enable() async {
    await _client.send('Runtime.enable');
  }

  /// Evaluates expression on global object.
  /// [expression] Expression to evaluate.
  /// [objectGroup] Symbolic group name that can be used to release multiple objects.
  /// [includeCommandLineAPI] Determines whether Command Line API should be available during the evaluation.
  /// [silent] In silent mode exceptions thrown during evaluation are not reported and do not pause
  /// execution. Overrides `setPauseOnException` state.
  /// [contextId] Specifies in which execution context to perform evaluation. If the parameter is omitted the
  /// evaluation will be performed in the context of the inspected page.
  /// This is mutually exclusive with `uniqueContextId`, which offers an
  /// alternative way to identify the execution context that is more reliable
  /// in a multi-process environment.
  /// [returnByValue] Whether the result is expected to be a JSON object that should be sent by value.
  /// [generatePreview] Whether preview should be generated for the result.
  /// [userGesture] Whether execution should be treated as initiated by user in the UI.
  /// [awaitPromise] Whether execution should `await` for resulting value and return once awaited promise is
  /// resolved.
  /// [throwOnSideEffect] Whether to throw an exception if side effect cannot be ruled out during evaluation.
  /// This implies `disableBreaks` below.
  /// [timeout] Terminate execution after timing out (number of milliseconds).
  /// [disableBreaks] Disable breakpoints during execution.
  /// [replMode] Setting this flag to true enables `let` re-declaration and top-level `await`.
  /// Note that `let` variables can only be re-declared if they originate from
  /// `replMode` themselves.
  /// [allowUnsafeEvalBlockedByCSP] The Content Security Policy (CSP) for the target might block 'unsafe-eval'
  /// which includes eval(), Function(), setTimeout() and setInterval()
  /// when called with non-callable arguments. This flag bypasses CSP for this
  /// evaluation and allows unsafe-eval. Defaults to true.
  /// [uniqueContextId] An alternative way to specify the execution context to evaluate in.
  /// Compared to contextId that may be reused across processes, this is guaranteed to be
  /// system-unique, so it can be used to prevent accidental evaluation of the expression
  /// in context different than intended (e.g. as a result of navigation across process
  /// boundaries).
  /// This is mutually exclusive with `contextId`.
  /// [serializationOptions] Specifies the result serialization. If provided, overrides
  /// `generatePreview` and `returnByValue`.
  Future<EvaluateResult> evaluate(
    String expression, {
    String? objectGroup,
    bool? includeCommandLineAPI,
    bool? silent,
    ExecutionContextId? contextId,
    bool? returnByValue,
    bool? generatePreview,
    bool? userGesture,
    bool? awaitPromise,
    bool? throwOnSideEffect,
    TimeDelta? timeout,
    bool? disableBreaks,
    bool? replMode,
    bool? allowUnsafeEvalBlockedByCSP,
    String? uniqueContextId,
    SerializationOptions? serializationOptions,
  }) async {
    var result = await _client.send('Runtime.evaluate', {
      'expression': expression,
      if (objectGroup != null) 'objectGroup': objectGroup,
      if (includeCommandLineAPI != null)
        'includeCommandLineAPI': includeCommandLineAPI,
      if (silent != null) 'silent': silent,
      if (contextId != null) 'contextId': contextId,
      if (returnByValue != null) 'returnByValue': returnByValue,
      if (generatePreview != null) 'generatePreview': generatePreview,
      if (userGesture != null) 'userGesture': userGesture,
      if (awaitPromise != null) 'awaitPromise': awaitPromise,
      if (throwOnSideEffect != null) 'throwOnSideEffect': throwOnSideEffect,
      if (timeout != null) 'timeout': timeout,
      if (disableBreaks != null) 'disableBreaks': disableBreaks,
      if (replMode != null) 'replMode': replMode,
      if (allowUnsafeEvalBlockedByCSP != null)
        'allowUnsafeEvalBlockedByCSP': allowUnsafeEvalBlockedByCSP,
      if (uniqueContextId != null) 'uniqueContextId': uniqueContextId,
      if (serializationOptions != null)
        'serializationOptions': serializationOptions,
    });
    return EvaluateResult.fromJson(result);
  }

  /// Returns the isolate id.
  /// Returns: The isolate id.
  Future<String> getIsolateId() async {
    var result = await _client.send('Runtime.getIsolateId');
    return result['id'] as String;
  }

  /// Returns the JavaScript heap usage.
  /// It is the total usage of the corresponding isolate not scoped to a particular Runtime.
  Future<GetHeapUsageResult> getHeapUsage() async {
    var result = await _client.send('Runtime.getHeapUsage');
    return GetHeapUsageResult.fromJson(result);
  }

  /// Returns properties of a given object. Object group of the result is inherited from the target
  /// object.
  /// [objectId] Identifier of the object to return properties for.
  /// [ownProperties] If true, returns properties belonging only to the element itself, not to its prototype
  /// chain.
  /// [accessorPropertiesOnly] If true, returns accessor properties (with getter/setter) only; internal properties are not
  /// returned either.
  /// [generatePreview] Whether preview should be generated for the results.
  /// [nonIndexedPropertiesOnly] If true, returns non-indexed properties only.
  Future<GetPropertiesResult> getProperties(
    RemoteObjectId objectId, {
    bool? ownProperties,
    bool? accessorPropertiesOnly,
    bool? generatePreview,
    bool? nonIndexedPropertiesOnly,
  }) async {
    var result = await _client.send('Runtime.getProperties', {
      'objectId': objectId,
      if (ownProperties != null) 'ownProperties': ownProperties,
      if (accessorPropertiesOnly != null)
        'accessorPropertiesOnly': accessorPropertiesOnly,
      if (generatePreview != null) 'generatePreview': generatePreview,
      if (nonIndexedPropertiesOnly != null)
        'nonIndexedPropertiesOnly': nonIndexedPropertiesOnly,
    });
    return GetPropertiesResult.fromJson(result);
  }

  /// Returns all let, const and class variables from global scope.
  /// [executionContextId] Specifies in which execution context to lookup global scope variables.
  Future<List<String>> globalLexicalScopeNames({
    ExecutionContextId? executionContextId,
  }) async {
    var result = await _client.send('Runtime.globalLexicalScopeNames', {
      if (executionContextId != null) 'executionContextId': executionContextId,
    });
    return (result['names'] as List).map((e) => e as String).toList();
  }

  /// [prototypeObjectId] Identifier of the prototype to return objects for.
  /// [objectGroup] Symbolic group name that can be used to release the results.
  /// Returns: Array with objects.
  Future<RemoteObject> queryObjects(
    RemoteObjectId prototypeObjectId, {
    String? objectGroup,
  }) async {
    var result = await _client.send('Runtime.queryObjects', {
      'prototypeObjectId': prototypeObjectId,
      if (objectGroup != null) 'objectGroup': objectGroup,
    });
    return RemoteObject.fromJson(result['objects'] as Map<String, dynamic>);
  }

  /// Releases remote object with given id.
  /// [objectId] Identifier of the object to release.
  Future<void> releaseObject(RemoteObjectId objectId) async {
    await _client.send('Runtime.releaseObject', {'objectId': objectId});
  }

  /// Releases all remote objects that belong to a given group.
  /// [objectGroup] Symbolic object group name.
  Future<void> releaseObjectGroup(String objectGroup) async {
    await _client.send('Runtime.releaseObjectGroup', {
      'objectGroup': objectGroup,
    });
  }

  /// Tells inspected instance to run if it was waiting for debugger to attach.
  Future<void> runIfWaitingForDebugger() async {
    await _client.send('Runtime.runIfWaitingForDebugger');
  }

  /// Runs script with given id in a given context.
  /// [scriptId] Id of the script to run.
  /// [executionContextId] Specifies in which execution context to perform script run. If the parameter is omitted the
  /// evaluation will be performed in the context of the inspected page.
  /// [objectGroup] Symbolic group name that can be used to release multiple objects.
  /// [silent] In silent mode exceptions thrown during evaluation are not reported and do not pause
  /// execution. Overrides `setPauseOnException` state.
  /// [includeCommandLineAPI] Determines whether Command Line API should be available during the evaluation.
  /// [returnByValue] Whether the result is expected to be a JSON object which should be sent by value.
  /// [generatePreview] Whether preview should be generated for the result.
  /// [awaitPromise] Whether execution should `await` for resulting value and return once awaited promise is
  /// resolved.
  Future<RunScriptResult> runScript(
    ScriptId scriptId, {
    ExecutionContextId? executionContextId,
    String? objectGroup,
    bool? silent,
    bool? includeCommandLineAPI,
    bool? returnByValue,
    bool? generatePreview,
    bool? awaitPromise,
  }) async {
    var result = await _client.send('Runtime.runScript', {
      'scriptId': scriptId,
      if (executionContextId != null) 'executionContextId': executionContextId,
      if (objectGroup != null) 'objectGroup': objectGroup,
      if (silent != null) 'silent': silent,
      if (includeCommandLineAPI != null)
        'includeCommandLineAPI': includeCommandLineAPI,
      if (returnByValue != null) 'returnByValue': returnByValue,
      if (generatePreview != null) 'generatePreview': generatePreview,
      if (awaitPromise != null) 'awaitPromise': awaitPromise,
    });
    return RunScriptResult.fromJson(result);
  }

  /// Enables or disables async call stacks tracking.
  /// [maxDepth] Maximum depth of async call stacks. Setting to `0` will effectively disable collecting async
  /// call stacks (default).
  Future<void> setAsyncCallStackDepth(int maxDepth) async {
    await _client.send('Runtime.setAsyncCallStackDepth', {
      'maxDepth': maxDepth,
    });
  }

  Future<void> setCustomObjectFormatterEnabled(bool enabled) async {
    await _client.send('Runtime.setCustomObjectFormatterEnabled', {
      'enabled': enabled,
    });
  }

  Future<void> setMaxCallStackSizeToCapture(int size) async {
    await _client.send('Runtime.setMaxCallStackSizeToCapture', {'size': size});
  }

  /// Terminate current or next JavaScript execution.
  /// Will cancel the termination when the outer-most script execution ends.
  Future<void> terminateExecution() async {
    await _client.send('Runtime.terminateExecution');
  }

  /// If executionContextId is empty, adds binding with the given name on the
  /// global objects of all inspected contexts, including those created later,
  /// bindings survive reloads.
  /// Binding function takes exactly one argument, this argument should be string,
  /// in case of any other input, function throws an exception.
  /// Each binding function call produces Runtime.bindingCalled notification.
  /// [executionContextName] If specified, the binding is exposed to the executionContext with
  /// matching name, even for contexts created after the binding is added.
  /// See also `ExecutionContext.name` and `worldName` parameter to
  /// `Page.addScriptToEvaluateOnNewDocument`.
  /// This parameter is mutually exclusive with `executionContextId`.
  Future<void> addBinding(
    String name, {
    @Deprecated('This parameter is deprecated')
    ExecutionContextId? executionContextId,
    String? executionContextName,
  }) async {
    await _client.send('Runtime.addBinding', {
      'name': name,
      if (executionContextId != null) 'executionContextId': executionContextId,
      if (executionContextName != null)
        'executionContextName': executionContextName,
    });
  }

  /// This method does not remove binding function from global object but
  /// unsubscribes current runtime agent from Runtime.bindingCalled notifications.
  Future<void> removeBinding(String name) async {
    await _client.send('Runtime.removeBinding', {'name': name});
  }

  /// This method tries to lookup and populate exception details for a
  /// JavaScript Error object.
  /// Note that the stackTrace portion of the resulting exceptionDetails will
  /// only be populated if the Runtime domain was enabled at the time when the
  /// Error was thrown.
  /// [errorObjectId] The error object for which to resolve the exception details.
  Future<ExceptionDetails> getExceptionDetails(
    RemoteObjectId errorObjectId,
  ) async {
    var result = await _client.send('Runtime.getExceptionDetails', {
      'errorObjectId': errorObjectId,
    });
    return ExceptionDetails.fromJson(
      result['exceptionDetails'] as Map<String, dynamic>,
    );
  }
}

class BindingCalledEvent {
  final String name;

  final String payload;

  /// Identifier of the context where the call was made.
  final ExecutionContextId executionContextId;

  BindingCalledEvent({
    required this.name,
    required this.payload,
    required this.executionContextId,
  });

  factory BindingCalledEvent.fromJson(Map<String, dynamic> json) {
    return BindingCalledEvent(
      name: json['name'] as String,
      payload: json['payload'] as String,
      executionContextId: ExecutionContextId.fromJson(
        json['executionContextId'] as int,
      ),
    );
  }
}

class ConsoleAPICalledEvent {
  /// Type of the call.
  final ConsoleAPICalledEventType type;

  /// Call arguments.
  final List<RemoteObject> args;

  /// Identifier of the context where the call was made.
  final ExecutionContextId executionContextId;

  /// Call timestamp.
  final Timestamp timestamp;

  /// Stack trace captured when the call was made. The async stack chain is automatically reported for
  /// the following call types: `assert`, `error`, `trace`, `warning`. For other types the async call
  /// chain can be retrieved using `Debugger.getStackTrace` and `stackTrace.parentId` field.
  final StackTraceData? stackTrace;

  /// Console context descriptor for calls on non-default console context (not console.*):
  /// 'anonymous#unique-logger-id' for call on unnamed context, 'name#unique-logger-id' for call
  /// on named context.
  final String? context;

  ConsoleAPICalledEvent({
    required this.type,
    required this.args,
    required this.executionContextId,
    required this.timestamp,
    this.stackTrace,
    this.context,
  });

  factory ConsoleAPICalledEvent.fromJson(Map<String, dynamic> json) {
    return ConsoleAPICalledEvent(
      type: ConsoleAPICalledEventType.fromJson(json['type'] as String),
      args: (json['args'] as List)
          .map((e) => RemoteObject.fromJson(e as Map<String, dynamic>))
          .toList(),
      executionContextId: ExecutionContextId.fromJson(
        json['executionContextId'] as int,
      ),
      timestamp: Timestamp.fromJson(json['timestamp'] as num),
      stackTrace: json.containsKey('stackTrace')
          ? StackTraceData.fromJson(json['stackTrace'] as Map<String, dynamic>)
          : null,
      context: json.containsKey('context') ? json['context'] as String : null,
    );
  }
}

class ExceptionRevokedEvent {
  /// Reason describing why exception was revoked.
  final String reason;

  /// The id of revoked exception, as reported in `exceptionThrown`.
  final int exceptionId;

  ExceptionRevokedEvent({required this.reason, required this.exceptionId});

  factory ExceptionRevokedEvent.fromJson(Map<String, dynamic> json) {
    return ExceptionRevokedEvent(
      reason: json['reason'] as String,
      exceptionId: json['exceptionId'] as int,
    );
  }
}

class ExceptionThrownEvent {
  /// Timestamp of the exception.
  final Timestamp timestamp;

  final ExceptionDetails exceptionDetails;

  ExceptionThrownEvent({
    required this.timestamp,
    required this.exceptionDetails,
  });

  factory ExceptionThrownEvent.fromJson(Map<String, dynamic> json) {
    return ExceptionThrownEvent(
      timestamp: Timestamp.fromJson(json['timestamp'] as num),
      exceptionDetails: ExceptionDetails.fromJson(
        json['exceptionDetails'] as Map<String, dynamic>,
      ),
    );
  }
}

class ExecutionContextDestroyedEvent {
  /// Unique Id of the destroyed context
  final String executionContextUniqueId;

  ExecutionContextDestroyedEvent({required this.executionContextUniqueId});

  factory ExecutionContextDestroyedEvent.fromJson(Map<String, dynamic> json) {
    return ExecutionContextDestroyedEvent(
      executionContextUniqueId: json['executionContextUniqueId'] as String,
    );
  }
}

class InspectRequestedEvent {
  final RemoteObject object;

  final Map<String, dynamic> hints;

  /// Identifier of the context where the call was made.
  final ExecutionContextId? executionContextId;

  InspectRequestedEvent({
    required this.object,
    required this.hints,
    this.executionContextId,
  });

  factory InspectRequestedEvent.fromJson(Map<String, dynamic> json) {
    return InspectRequestedEvent(
      object: RemoteObject.fromJson(json['object'] as Map<String, dynamic>),
      hints: json['hints'] as Map<String, dynamic>,
      executionContextId: json.containsKey('executionContextId')
          ? ExecutionContextId.fromJson(json['executionContextId'] as int)
          : null,
    );
  }
}

class AwaitPromiseResult {
  /// Promise result. Will contain rejected value if promise was rejected.
  final RemoteObject result;

  /// Exception details if stack strace is available.
  final ExceptionDetails? exceptionDetails;

  AwaitPromiseResult({required this.result, this.exceptionDetails});

  factory AwaitPromiseResult.fromJson(Map<String, dynamic> json) {
    return AwaitPromiseResult(
      result: RemoteObject.fromJson(json['result'] as Map<String, dynamic>),
      exceptionDetails: json.containsKey('exceptionDetails')
          ? ExceptionDetails.fromJson(
              json['exceptionDetails'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class CallFunctionOnResult {
  /// Call result.
  final RemoteObject result;

  /// Exception details.
  final ExceptionDetails? exceptionDetails;

  CallFunctionOnResult({required this.result, this.exceptionDetails});

  factory CallFunctionOnResult.fromJson(Map<String, dynamic> json) {
    return CallFunctionOnResult(
      result: RemoteObject.fromJson(json['result'] as Map<String, dynamic>),
      exceptionDetails: json.containsKey('exceptionDetails')
          ? ExceptionDetails.fromJson(
              json['exceptionDetails'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class CompileScriptResult {
  /// Id of the script.
  final ScriptId? scriptId;

  /// Exception details.
  final ExceptionDetails? exceptionDetails;

  CompileScriptResult({this.scriptId, this.exceptionDetails});

  factory CompileScriptResult.fromJson(Map<String, dynamic> json) {
    return CompileScriptResult(
      scriptId: json.containsKey('scriptId')
          ? ScriptId.fromJson(json['scriptId'] as String)
          : null,
      exceptionDetails: json.containsKey('exceptionDetails')
          ? ExceptionDetails.fromJson(
              json['exceptionDetails'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class EvaluateResult {
  /// Evaluation result.
  final RemoteObject result;

  /// Exception details.
  final ExceptionDetails? exceptionDetails;

  EvaluateResult({required this.result, this.exceptionDetails});

  factory EvaluateResult.fromJson(Map<String, dynamic> json) {
    return EvaluateResult(
      result: RemoteObject.fromJson(json['result'] as Map<String, dynamic>),
      exceptionDetails: json.containsKey('exceptionDetails')
          ? ExceptionDetails.fromJson(
              json['exceptionDetails'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class GetHeapUsageResult {
  /// Used JavaScript heap size in bytes.
  final num usedSize;

  /// Allocated JavaScript heap size in bytes.
  final num totalSize;

  /// Used size in bytes in the embedder's garbage-collected heap.
  final num embedderHeapUsedSize;

  /// Size in bytes of backing storage for array buffers and external strings.
  final num backingStorageSize;

  GetHeapUsageResult({
    required this.usedSize,
    required this.totalSize,
    required this.embedderHeapUsedSize,
    required this.backingStorageSize,
  });

  factory GetHeapUsageResult.fromJson(Map<String, dynamic> json) {
    return GetHeapUsageResult(
      usedSize: json['usedSize'] as num,
      totalSize: json['totalSize'] as num,
      embedderHeapUsedSize: json['embedderHeapUsedSize'] as num,
      backingStorageSize: json['backingStorageSize'] as num,
    );
  }
}

class GetPropertiesResult {
  /// Object properties.
  final List<PropertyDescriptor> result;

  /// Internal object properties (only of the element itself).
  final List<InternalPropertyDescriptor>? internalProperties;

  /// Object private properties.
  final List<PrivatePropertyDescriptor>? privateProperties;

  /// Exception details.
  final ExceptionDetails? exceptionDetails;

  GetPropertiesResult({
    required this.result,
    this.internalProperties,
    this.privateProperties,
    this.exceptionDetails,
  });

  factory GetPropertiesResult.fromJson(Map<String, dynamic> json) {
    return GetPropertiesResult(
      result: (json['result'] as List)
          .map((e) => PropertyDescriptor.fromJson(e as Map<String, dynamic>))
          .toList(),
      internalProperties: json.containsKey('internalProperties')
          ? (json['internalProperties'] as List)
                .map(
                  (e) => InternalPropertyDescriptor.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : null,
      privateProperties: json.containsKey('privateProperties')
          ? (json['privateProperties'] as List)
                .map(
                  (e) => PrivatePropertyDescriptor.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : null,
      exceptionDetails: json.containsKey('exceptionDetails')
          ? ExceptionDetails.fromJson(
              json['exceptionDetails'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class RunScriptResult {
  /// Run result.
  final RemoteObject result;

  /// Exception details.
  final ExceptionDetails? exceptionDetails;

  RunScriptResult({required this.result, this.exceptionDetails});

  factory RunScriptResult.fromJson(Map<String, dynamic> json) {
    return RunScriptResult(
      result: RemoteObject.fromJson(json['result'] as Map<String, dynamic>),
      exceptionDetails: json.containsKey('exceptionDetails')
          ? ExceptionDetails.fromJson(
              json['exceptionDetails'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

/// Unique script identifier.
extension type ScriptId(String value) {
  factory ScriptId.fromJson(String value) => ScriptId(value);

  String toJson() => value;
}

/// Represents options for serialization. Overrides `generatePreview` and `returnByValue`.
class SerializationOptions {
  final SerializationOptionsSerialization serialization;

  /// Deep serialization depth. Default is full depth. Respected only in `deep` serialization mode.
  final int? maxDepth;

  /// Embedder-specific parameters. For example if connected to V8 in Chrome these control DOM
  /// serialization via `maxNodeDepth: integer` and `includeShadowTree: "none" | "open" | "all"`.
  /// Values can be only of type string or integer.
  final Map<String, dynamic>? additionalParameters;

  SerializationOptions({
    required this.serialization,
    this.maxDepth,
    this.additionalParameters,
  });

  factory SerializationOptions.fromJson(Map<String, dynamic> json) {
    return SerializationOptions(
      serialization: SerializationOptionsSerialization.fromJson(
        json['serialization'] as String,
      ),
      maxDepth: json.containsKey('maxDepth') ? json['maxDepth'] as int : null,
      additionalParameters: json.containsKey('additionalParameters')
          ? json['additionalParameters'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serialization': serialization,
      if (maxDepth != null) 'maxDepth': maxDepth,
      if (additionalParameters != null)
        'additionalParameters': additionalParameters,
    };
  }
}

enum SerializationOptionsSerialization {
  deep('deep'),
  json('json'),
  idOnly('idOnly');

  final String value;

  const SerializationOptionsSerialization(this.value);

  factory SerializationOptionsSerialization.fromJson(String value) =>
      SerializationOptionsSerialization.values.firstWhere(
        (e) => e.value == value,
      );

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Represents deep serialized value.
class DeepSerializedValue {
  final DeepSerializedValueType type;

  final dynamic value;

  final String? objectId;

  /// Set if value reference met more then once during serialization. In such
  /// case, value is provided only to one of the serialized values. Unique
  /// per value in the scope of one CDP call.
  final int? weakLocalObjectReference;

  DeepSerializedValue({
    required this.type,
    this.value,
    this.objectId,
    this.weakLocalObjectReference,
  });

  factory DeepSerializedValue.fromJson(Map<String, dynamic> json) {
    return DeepSerializedValue(
      type: DeepSerializedValueType.fromJson(json['type'] as String),
      value: json.containsKey('value') ? json['value'] as dynamic : null,
      objectId: json.containsKey('objectId')
          ? json['objectId'] as String
          : null,
      weakLocalObjectReference: json.containsKey('weakLocalObjectReference')
          ? json['weakLocalObjectReference'] as int
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (value != null) 'value': value,
      if (objectId != null) 'objectId': objectId,
      if (weakLocalObjectReference != null)
        'weakLocalObjectReference': weakLocalObjectReference,
    };
  }
}

enum DeepSerializedValueType {
  undefined('undefined'),
  null$('null'),
  string('string'),
  number('number'),
  boolean('boolean'),
  bigint('bigint'),
  regexp('regexp'),
  date('date'),
  symbol('symbol'),
  array('array'),
  object('object'),
  function('function'),
  map('map'),
  set('set'),
  weakmap('weakmap'),
  weakset('weakset'),
  error('error'),
  proxy('proxy'),
  promise('promise'),
  typedarray('typedarray'),
  arraybuffer('arraybuffer'),
  node('node'),
  window('window'),
  generator('generator');

  final String value;

  const DeepSerializedValueType(this.value);

  factory DeepSerializedValueType.fromJson(String value) =>
      DeepSerializedValueType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Unique object identifier.
extension type RemoteObjectId(String value) {
  factory RemoteObjectId.fromJson(String value) => RemoteObjectId(value);

  String toJson() => value;
}

/// Primitive value which cannot be JSON-stringified. Includes values `-0`, `NaN`, `Infinity`,
/// `-Infinity`, and bigint literals.
extension type UnserializableValue(String value) {
  factory UnserializableValue.fromJson(String value) =>
      UnserializableValue(value);

  String toJson() => value;
}

/// Mirror object referencing original JavaScript object.
class RemoteObject {
  /// Object type.
  final RemoteObjectType type;

  /// Object subtype hint. Specified for `object` type values only.
  /// NOTE: If you change anything here, make sure to also update
  /// `subtype` in `ObjectPreview` and `PropertyPreview` below.
  final RemoteObjectSubtype? subtype;

  /// Object class (constructor) name. Specified for `object` type values only.
  final String? className;

  /// Remote object value in case of primitive values or JSON values (if it was requested).
  final dynamic value;

  /// Primitive value which can not be JSON-stringified does not have `value`, but gets this
  /// property.
  final UnserializableValue? unserializableValue;

  /// String representation of the object.
  final String? description;

  /// Deep serialized value.
  final DeepSerializedValue? deepSerializedValue;

  /// Unique object identifier (for non-primitive values).
  final RemoteObjectId? objectId;

  /// Preview containing abbreviated property values. Specified for `object` type values only.
  final ObjectPreview? preview;

  final CustomPreview? customPreview;

  RemoteObject({
    required this.type,
    this.subtype,
    this.className,
    this.value,
    this.unserializableValue,
    this.description,
    this.deepSerializedValue,
    this.objectId,
    this.preview,
    this.customPreview,
  });

  factory RemoteObject.fromJson(Map<String, dynamic> json) {
    return RemoteObject(
      type: RemoteObjectType.fromJson(json['type'] as String),
      subtype: json.containsKey('subtype')
          ? RemoteObjectSubtype.fromJson(json['subtype'] as String)
          : null,
      className: json.containsKey('className')
          ? json['className'] as String
          : null,
      value: json.containsKey('value') ? json['value'] as dynamic : null,
      unserializableValue: json.containsKey('unserializableValue')
          ? UnserializableValue.fromJson(json['unserializableValue'] as String)
          : null,
      description: json.containsKey('description')
          ? json['description'] as String
          : null,
      deepSerializedValue: json.containsKey('deepSerializedValue')
          ? DeepSerializedValue.fromJson(
              json['deepSerializedValue'] as Map<String, dynamic>,
            )
          : null,
      objectId: json.containsKey('objectId')
          ? RemoteObjectId.fromJson(json['objectId'] as String)
          : null,
      preview: json.containsKey('preview')
          ? ObjectPreview.fromJson(json['preview'] as Map<String, dynamic>)
          : null,
      customPreview: json.containsKey('customPreview')
          ? CustomPreview.fromJson(
              json['customPreview'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (subtype != null) 'subtype': subtype,
      if (className != null) 'className': className,
      if (value != null) 'value': value,
      if (unserializableValue != null)
        'unserializableValue': unserializableValue!.toJson(),
      if (description != null) 'description': description,
      if (deepSerializedValue != null)
        'deepSerializedValue': deepSerializedValue!.toJson(),
      if (objectId != null) 'objectId': objectId!.toJson(),
      if (preview != null) 'preview': preview!.toJson(),
      if (customPreview != null) 'customPreview': customPreview!.toJson(),
    };
  }
}

enum RemoteObjectType {
  object('object'),
  function('function'),
  undefined('undefined'),
  string('string'),
  number('number'),
  boolean('boolean'),
  symbol('symbol'),
  bigint('bigint');

  final String value;

  const RemoteObjectType(this.value);

  factory RemoteObjectType.fromJson(String value) =>
      RemoteObjectType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum RemoteObjectSubtype {
  array('array'),
  null$('null'),
  node('node'),
  regexp('regexp'),
  date('date'),
  map('map'),
  set('set'),
  weakmap('weakmap'),
  weakset('weakset'),
  iterator('iterator'),
  generator('generator'),
  error('error'),
  proxy('proxy'),
  promise('promise'),
  typedarray('typedarray'),
  arraybuffer('arraybuffer'),
  dataview('dataview'),
  webassemblymemory('webassemblymemory'),
  wasmvalue('wasmvalue');

  final String value;

  const RemoteObjectSubtype(this.value);

  factory RemoteObjectSubtype.fromJson(String value) =>
      RemoteObjectSubtype.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class CustomPreview {
  /// The JSON-stringified result of formatter.header(object, config) call.
  /// It contains json ML array that represents RemoteObject.
  final String header;

  /// If formatter returns true as a result of formatter.hasBody call then bodyGetterId will
  /// contain RemoteObjectId for the function that returns result of formatter.body(object, config) call.
  /// The result value is json ML array.
  final RemoteObjectId? bodyGetterId;

  CustomPreview({required this.header, this.bodyGetterId});

  factory CustomPreview.fromJson(Map<String, dynamic> json) {
    return CustomPreview(
      header: json['header'] as String,
      bodyGetterId: json.containsKey('bodyGetterId')
          ? RemoteObjectId.fromJson(json['bodyGetterId'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'header': header,
      if (bodyGetterId != null) 'bodyGetterId': bodyGetterId!.toJson(),
    };
  }
}

/// Object containing abbreviated remote object value.
class ObjectPreview {
  /// Object type.
  final ObjectPreviewType type;

  /// Object subtype hint. Specified for `object` type values only.
  final ObjectPreviewSubtype? subtype;

  /// String representation of the object.
  final String? description;

  /// True iff some of the properties or entries of the original object did not fit.
  final bool overflow;

  /// List of the properties.
  final List<PropertyPreview> properties;

  /// List of the entries. Specified for `map` and `set` subtype values only.
  final List<EntryPreview>? entries;

  ObjectPreview({
    required this.type,
    this.subtype,
    this.description,
    required this.overflow,
    required this.properties,
    this.entries,
  });

  factory ObjectPreview.fromJson(Map<String, dynamic> json) {
    return ObjectPreview(
      type: ObjectPreviewType.fromJson(json['type'] as String),
      subtype: json.containsKey('subtype')
          ? ObjectPreviewSubtype.fromJson(json['subtype'] as String)
          : null,
      description: json.containsKey('description')
          ? json['description'] as String
          : null,
      overflow: json['overflow'] as bool? ?? false,
      properties: (json['properties'] as List)
          .map((e) => PropertyPreview.fromJson(e as Map<String, dynamic>))
          .toList(),
      entries: json.containsKey('entries')
          ? (json['entries'] as List)
                .map((e) => EntryPreview.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'overflow': overflow,
      'properties': properties.map((e) => e.toJson()).toList(),
      if (subtype != null) 'subtype': subtype,
      if (description != null) 'description': description,
      if (entries != null) 'entries': entries!.map((e) => e.toJson()).toList(),
    };
  }
}

enum ObjectPreviewType {
  object('object'),
  function('function'),
  undefined('undefined'),
  string('string'),
  number('number'),
  boolean('boolean'),
  symbol('symbol'),
  bigint('bigint');

  final String value;

  const ObjectPreviewType(this.value);

  factory ObjectPreviewType.fromJson(String value) =>
      ObjectPreviewType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum ObjectPreviewSubtype {
  array('array'),
  null$('null'),
  node('node'),
  regexp('regexp'),
  date('date'),
  map('map'),
  set('set'),
  weakmap('weakmap'),
  weakset('weakset'),
  iterator('iterator'),
  generator('generator'),
  error('error'),
  proxy('proxy'),
  promise('promise'),
  typedarray('typedarray'),
  arraybuffer('arraybuffer'),
  dataview('dataview'),
  webassemblymemory('webassemblymemory'),
  wasmvalue('wasmvalue');

  final String value;

  const ObjectPreviewSubtype(this.value);

  factory ObjectPreviewSubtype.fromJson(String value) =>
      ObjectPreviewSubtype.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class PropertyPreview {
  /// Property name.
  final String name;

  /// Object type. Accessor means that the property itself is an accessor property.
  final PropertyPreviewType type;

  /// User-friendly property value string.
  final String? value;

  /// Nested value preview.
  final ObjectPreview? valuePreview;

  /// Object subtype hint. Specified for `object` type values only.
  final PropertyPreviewSubtype? subtype;

  PropertyPreview({
    required this.name,
    required this.type,
    this.value,
    this.valuePreview,
    this.subtype,
  });

  factory PropertyPreview.fromJson(Map<String, dynamic> json) {
    return PropertyPreview(
      name: json['name'] as String,
      type: PropertyPreviewType.fromJson(json['type'] as String),
      value: json.containsKey('value') ? json['value'] as String : null,
      valuePreview: json.containsKey('valuePreview')
          ? ObjectPreview.fromJson(json['valuePreview'] as Map<String, dynamic>)
          : null,
      subtype: json.containsKey('subtype')
          ? PropertyPreviewSubtype.fromJson(json['subtype'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      if (value != null) 'value': value,
      if (valuePreview != null) 'valuePreview': valuePreview!.toJson(),
      if (subtype != null) 'subtype': subtype,
    };
  }
}

enum PropertyPreviewType {
  object('object'),
  function('function'),
  undefined('undefined'),
  string('string'),
  number('number'),
  boolean('boolean'),
  symbol('symbol'),
  accessor('accessor'),
  bigint('bigint');

  final String value;

  const PropertyPreviewType(this.value);

  factory PropertyPreviewType.fromJson(String value) =>
      PropertyPreviewType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum PropertyPreviewSubtype {
  array('array'),
  null$('null'),
  node('node'),
  regexp('regexp'),
  date('date'),
  map('map'),
  set('set'),
  weakmap('weakmap'),
  weakset('weakset'),
  iterator('iterator'),
  generator('generator'),
  error('error'),
  proxy('proxy'),
  promise('promise'),
  typedarray('typedarray'),
  arraybuffer('arraybuffer'),
  dataview('dataview'),
  webassemblymemory('webassemblymemory'),
  wasmvalue('wasmvalue');

  final String value;

  const PropertyPreviewSubtype(this.value);

  factory PropertyPreviewSubtype.fromJson(String value) =>
      PropertyPreviewSubtype.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class EntryPreview {
  /// Preview of the key. Specified for map-like collection entries.
  final ObjectPreview? key;

  /// Preview of the value.
  final ObjectPreview value;

  EntryPreview({this.key, required this.value});

  factory EntryPreview.fromJson(Map<String, dynamic> json) {
    return EntryPreview(
      key: json.containsKey('key')
          ? ObjectPreview.fromJson(json['key'] as Map<String, dynamic>)
          : null,
      value: ObjectPreview.fromJson(json['value'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'value': value.toJson(), if (key != null) 'key': key!.toJson()};
  }
}

/// Object property descriptor.
class PropertyDescriptor {
  /// Property name or symbol description.
  final String name;

  /// The value associated with the property.
  final RemoteObject? value;

  /// True if the value associated with the property may be changed (data descriptors only).
  final bool? writable;

  /// A function which serves as a getter for the property, or `undefined` if there is no getter
  /// (accessor descriptors only).
  final RemoteObject? get;

  /// A function which serves as a setter for the property, or `undefined` if there is no setter
  /// (accessor descriptors only).
  final RemoteObject? set;

  /// True if the type of this property descriptor may be changed and if the property may be
  /// deleted from the corresponding object.
  final bool configurable;

  /// True if this property shows up during enumeration of the properties on the corresponding
  /// object.
  final bool enumerable;

  /// True if the result was thrown during the evaluation.
  final bool? wasThrown;

  /// True if the property is owned for the object.
  final bool? isOwn;

  /// Property symbol object, if the property is of the `symbol` type.
  final RemoteObject? symbol;

  PropertyDescriptor({
    required this.name,
    this.value,
    this.writable,
    this.get,
    this.set,
    required this.configurable,
    required this.enumerable,
    this.wasThrown,
    this.isOwn,
    this.symbol,
  });

  factory PropertyDescriptor.fromJson(Map<String, dynamic> json) {
    return PropertyDescriptor(
      name: json['name'] as String,
      value: json.containsKey('value')
          ? RemoteObject.fromJson(json['value'] as Map<String, dynamic>)
          : null,
      writable: json.containsKey('writable') ? json['writable'] as bool : null,
      get: json.containsKey('get')
          ? RemoteObject.fromJson(json['get'] as Map<String, dynamic>)
          : null,
      set: json.containsKey('set')
          ? RemoteObject.fromJson(json['set'] as Map<String, dynamic>)
          : null,
      configurable: json['configurable'] as bool? ?? false,
      enumerable: json['enumerable'] as bool? ?? false,
      wasThrown: json.containsKey('wasThrown')
          ? json['wasThrown'] as bool
          : null,
      isOwn: json.containsKey('isOwn') ? json['isOwn'] as bool : null,
      symbol: json.containsKey('symbol')
          ? RemoteObject.fromJson(json['symbol'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'configurable': configurable,
      'enumerable': enumerable,
      if (value != null) 'value': value!.toJson(),
      if (writable != null) 'writable': writable,
      if (get != null) 'get': get!.toJson(),
      if (set != null) 'set': set!.toJson(),
      if (wasThrown != null) 'wasThrown': wasThrown,
      if (isOwn != null) 'isOwn': isOwn,
      if (symbol != null) 'symbol': symbol!.toJson(),
    };
  }
}

/// Object internal property descriptor. This property isn't normally visible in JavaScript code.
class InternalPropertyDescriptor {
  /// Conventional property name.
  final String name;

  /// The value associated with the property.
  final RemoteObject? value;

  InternalPropertyDescriptor({required this.name, this.value});

  factory InternalPropertyDescriptor.fromJson(Map<String, dynamic> json) {
    return InternalPropertyDescriptor(
      name: json['name'] as String,
      value: json.containsKey('value')
          ? RemoteObject.fromJson(json['value'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, if (value != null) 'value': value!.toJson()};
  }
}

/// Object private field descriptor.
class PrivatePropertyDescriptor {
  /// Private property name.
  final String name;

  /// The value associated with the private property.
  final RemoteObject? value;

  /// A function which serves as a getter for the private property,
  /// or `undefined` if there is no getter (accessor descriptors only).
  final RemoteObject? get;

  /// A function which serves as a setter for the private property,
  /// or `undefined` if there is no setter (accessor descriptors only).
  final RemoteObject? set;

  PrivatePropertyDescriptor({
    required this.name,
    this.value,
    this.get,
    this.set,
  });

  factory PrivatePropertyDescriptor.fromJson(Map<String, dynamic> json) {
    return PrivatePropertyDescriptor(
      name: json['name'] as String,
      value: json.containsKey('value')
          ? RemoteObject.fromJson(json['value'] as Map<String, dynamic>)
          : null,
      get: json.containsKey('get')
          ? RemoteObject.fromJson(json['get'] as Map<String, dynamic>)
          : null,
      set: json.containsKey('set')
          ? RemoteObject.fromJson(json['set'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (value != null) 'value': value!.toJson(),
      if (get != null) 'get': get!.toJson(),
      if (set != null) 'set': set!.toJson(),
    };
  }
}

/// Represents function call argument. Either remote object id `objectId`, primitive `value`,
/// unserializable primitive value or neither of (for undefined) them should be specified.
class CallArgument {
  /// Primitive value or serializable javascript object.
  final dynamic value;

  /// Primitive value which can not be JSON-stringified.
  final UnserializableValue? unserializableValue;

  /// Remote object handle.
  final RemoteObjectId? objectId;

  CallArgument({this.value, this.unserializableValue, this.objectId});

  factory CallArgument.fromJson(Map<String, dynamic> json) {
    return CallArgument(
      value: json.containsKey('value') ? json['value'] as dynamic : null,
      unserializableValue: json.containsKey('unserializableValue')
          ? UnserializableValue.fromJson(json['unserializableValue'] as String)
          : null,
      objectId: json.containsKey('objectId')
          ? RemoteObjectId.fromJson(json['objectId'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (value != null) 'value': value,
      if (unserializableValue != null)
        'unserializableValue': unserializableValue!.toJson(),
      if (objectId != null) 'objectId': objectId!.toJson(),
    };
  }
}

/// Id of an execution context.
extension type ExecutionContextId(int value) {
  factory ExecutionContextId.fromJson(int value) => ExecutionContextId(value);

  int toJson() => value;
}

/// Description of an isolated world.
class ExecutionContextDescription {
  /// Unique id of the execution context. It can be used to specify in which execution context
  /// script evaluation should be performed.
  final ExecutionContextId id;

  /// Execution context origin.
  final String origin;

  /// Human readable name describing given context.
  final String name;

  /// A system-unique execution context identifier. Unlike the id, this is unique across
  /// multiple processes, so can be reliably used to identify specific context while backend
  /// performs a cross-process navigation.
  final String uniqueId;

  /// Embedder-specific auxiliary data likely matching {isDefault: boolean, type: 'default'|'isolated'|'worker', frameId: string}
  final Map<String, dynamic>? auxData;

  ExecutionContextDescription({
    required this.id,
    required this.origin,
    required this.name,
    required this.uniqueId,
    this.auxData,
  });

  factory ExecutionContextDescription.fromJson(Map<String, dynamic> json) {
    return ExecutionContextDescription(
      id: ExecutionContextId.fromJson(json['id'] as int),
      origin: json['origin'] as String,
      name: json['name'] as String,
      uniqueId: json['uniqueId'] as String,
      auxData: json.containsKey('auxData')
          ? json['auxData'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toJson(),
      'origin': origin,
      'name': name,
      'uniqueId': uniqueId,
      if (auxData != null) 'auxData': auxData,
    };
  }
}

/// Detailed information about exception (or error) that was thrown during script compilation or
/// execution.
class ExceptionDetails {
  /// Exception id.
  final int exceptionId;

  /// Exception text, which should be used together with exception object when available.
  final String text;

  /// Line number of the exception location (0-based).
  final int lineNumber;

  /// Column number of the exception location (0-based).
  final int columnNumber;

  /// Script ID of the exception location.
  final ScriptId? scriptId;

  /// URL of the exception location, to be used when the script was not reported.
  final String? url;

  /// JavaScript stack trace if available.
  final StackTraceData? stackTrace;

  /// Exception object if available.
  final RemoteObject? exception;

  /// Identifier of the context where exception happened.
  final ExecutionContextId? executionContextId;

  /// Dictionary with entries of meta data that the client associated
  /// with this exception, such as information about associated network
  /// requests, etc.
  final Map<String, dynamic>? exceptionMetaData;

  ExceptionDetails({
    required this.exceptionId,
    required this.text,
    required this.lineNumber,
    required this.columnNumber,
    this.scriptId,
    this.url,
    this.stackTrace,
    this.exception,
    this.executionContextId,
    this.exceptionMetaData,
  });

  factory ExceptionDetails.fromJson(Map<String, dynamic> json) {
    return ExceptionDetails(
      exceptionId: json['exceptionId'] as int,
      text: json['text'] as String,
      lineNumber: json['lineNumber'] as int,
      columnNumber: json['columnNumber'] as int,
      scriptId: json.containsKey('scriptId')
          ? ScriptId.fromJson(json['scriptId'] as String)
          : null,
      url: json.containsKey('url') ? json['url'] as String : null,
      stackTrace: json.containsKey('stackTrace')
          ? StackTraceData.fromJson(json['stackTrace'] as Map<String, dynamic>)
          : null,
      exception: json.containsKey('exception')
          ? RemoteObject.fromJson(json['exception'] as Map<String, dynamic>)
          : null,
      executionContextId: json.containsKey('executionContextId')
          ? ExecutionContextId.fromJson(json['executionContextId'] as int)
          : null,
      exceptionMetaData: json.containsKey('exceptionMetaData')
          ? json['exceptionMetaData'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exceptionId': exceptionId,
      'text': text,
      'lineNumber': lineNumber,
      'columnNumber': columnNumber,
      if (scriptId != null) 'scriptId': scriptId!.toJson(),
      if (url != null) 'url': url,
      if (stackTrace != null) 'stackTrace': stackTrace!.toJson(),
      if (exception != null) 'exception': exception!.toJson(),
      if (executionContextId != null)
        'executionContextId': executionContextId!.toJson(),
      if (exceptionMetaData != null) 'exceptionMetaData': exceptionMetaData,
    };
  }
}

/// Number of milliseconds since epoch.
extension type Timestamp(num value) {
  factory Timestamp.fromJson(num value) => Timestamp(value);

  num toJson() => value;
}

/// Number of milliseconds.
extension type TimeDelta(num value) {
  factory TimeDelta.fromJson(num value) => TimeDelta(value);

  num toJson() => value;
}

/// Stack entry for runtime errors and assertions.
class CallFrame {
  /// JavaScript function name.
  final String functionName;

  /// JavaScript script id.
  final ScriptId scriptId;

  /// JavaScript script name or url.
  final String url;

  /// JavaScript script line number (0-based).
  final int lineNumber;

  /// JavaScript script column number (0-based).
  final int columnNumber;

  CallFrame({
    required this.functionName,
    required this.scriptId,
    required this.url,
    required this.lineNumber,
    required this.columnNumber,
  });

  factory CallFrame.fromJson(Map<String, dynamic> json) {
    return CallFrame(
      functionName: json['functionName'] as String,
      scriptId: ScriptId.fromJson(json['scriptId'] as String),
      url: json['url'] as String,
      lineNumber: json['lineNumber'] as int,
      columnNumber: json['columnNumber'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'functionName': functionName,
      'scriptId': scriptId.toJson(),
      'url': url,
      'lineNumber': lineNumber,
      'columnNumber': columnNumber,
    };
  }
}

/// Call frames for assertions or error messages.
class StackTraceData {
  /// String label of this stack trace. For async traces this may be a name of the function that
  /// initiated the async call.
  final String? description;

  /// JavaScript function name.
  final List<CallFrame> callFrames;

  /// Asynchronous JavaScript stack trace that preceded this stack, if available.
  final StackTraceData? parent;

  /// Asynchronous JavaScript stack trace that preceded this stack, if available.
  final StackTraceId? parentId;

  StackTraceData({
    this.description,
    required this.callFrames,
    this.parent,
    this.parentId,
  });

  factory StackTraceData.fromJson(Map<String, dynamic> json) {
    return StackTraceData(
      description: json.containsKey('description')
          ? json['description'] as String
          : null,
      callFrames: (json['callFrames'] as List)
          .map((e) => CallFrame.fromJson(e as Map<String, dynamic>))
          .toList(),
      parent: json.containsKey('parent')
          ? StackTraceData.fromJson(json['parent'] as Map<String, dynamic>)
          : null,
      parentId: json.containsKey('parentId')
          ? StackTraceId.fromJson(json['parentId'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'callFrames': callFrames.map((e) => e.toJson()).toList(),
      if (description != null) 'description': description,
      if (parent != null) 'parent': parent!.toJson(),
      if (parentId != null) 'parentId': parentId!.toJson(),
    };
  }
}

/// Unique identifier of current debugger.
extension type UniqueDebuggerId(String value) {
  factory UniqueDebuggerId.fromJson(String value) => UniqueDebuggerId(value);

  String toJson() => value;
}

/// If `debuggerId` is set stack trace comes from another debugger and can be resolved there. This
/// allows to track cross-debugger calls. See `Runtime.StackTrace` and `Debugger.paused` for usages.
class StackTraceId {
  final String id;

  final UniqueDebuggerId? debuggerId;

  StackTraceId({required this.id, this.debuggerId});

  factory StackTraceId.fromJson(Map<String, dynamic> json) {
    return StackTraceId(
      id: json['id'] as String,
      debuggerId: json.containsKey('debuggerId')
          ? UniqueDebuggerId.fromJson(json['debuggerId'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (debuggerId != null) 'debuggerId': debuggerId!.toJson(),
    };
  }
}

enum ConsoleAPICalledEventType {
  log('log'),
  debug('debug'),
  info('info'),
  error('error'),
  warning('warning'),
  dir('dir'),
  dirxml('dirxml'),
  table('table'),
  trace('trace'),
  clear('clear'),
  startGroup('startGroup'),
  startGroupCollapsed('startGroupCollapsed'),
  endGroup('endGroup'),
  assert$('assert'),
  profile('profile'),
  profileEnd('profileEnd'),
  count('count'),
  timeEnd('timeEnd');

  final String value;

  const ConsoleAPICalledEventType(this.value);

  factory ConsoleAPICalledEventType.fromJson(String value) =>
      ConsoleAPICalledEventType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}
