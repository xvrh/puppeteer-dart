import 'dart:async';
import 'package:meta/meta.dart' show required;
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
      .where((Event event) => event.name == 'Runtime.bindingCalled')
      .map((Event event) => BindingCalledEvent.fromJson(event.parameters));

  /// Issued when console API was called.
  Stream<ConsoleAPICalledEvent> get onConsoleAPICalled => _client.onEvent
      .where((Event event) => event.name == 'Runtime.consoleAPICalled')
      .map((Event event) => ConsoleAPICalledEvent.fromJson(event.parameters));

  /// Issued when unhandled exception was revoked.
  Stream<ExceptionRevokedEvent> get onExceptionRevoked => _client.onEvent
      .where((Event event) => event.name == 'Runtime.exceptionRevoked')
      .map((Event event) => ExceptionRevokedEvent.fromJson(event.parameters));

  /// Issued when exception was thrown and unhandled.
  Stream<ExceptionThrownEvent> get onExceptionThrown => _client.onEvent
      .where((Event event) => event.name == 'Runtime.exceptionThrown')
      .map((Event event) => ExceptionThrownEvent.fromJson(event.parameters));

  /// Issued when new execution context is created.
  Stream<ExecutionContextDescription> get onExecutionContextCreated => _client
      .onEvent
      .where((Event event) => event.name == 'Runtime.executionContextCreated')
      .map((Event event) =>
          ExecutionContextDescription.fromJson(event.parameters['context']));

  /// Issued when execution context is destroyed.
  Stream<ExecutionContextId> get onExecutionContextDestroyed => _client.onEvent
      .where((Event event) => event.name == 'Runtime.executionContextDestroyed')
      .map((Event event) =>
          ExecutionContextId.fromJson(event.parameters['executionContextId']));

  /// Issued when all executionContexts were cleared in browser
  Stream get onExecutionContextsCleared => _client.onEvent
      .where((Event event) => event.name == 'Runtime.executionContextsCleared');

  /// Issued when object should be inspected (for example, as a result of inspect() command line API
  /// call).
  Stream<InspectRequestedEvent> get onInspectRequested => _client.onEvent
      .where((Event event) => event.name == 'Runtime.inspectRequested')
      .map((Event event) => InspectRequestedEvent.fromJson(event.parameters));

  /// Add handler to promise with given promise object id.
  /// [promiseObjectId] Identifier of the promise.
  /// [returnByValue] Whether the result is expected to be a JSON object that should be sent by value.
  /// [generatePreview] Whether preview should be generated for the result.
  Future<AwaitPromiseResult> awaitPromise(RemoteObjectId promiseObjectId,
      {bool returnByValue, bool generatePreview}) async {
    var parameters = <String, dynamic>{
      'promiseObjectId': promiseObjectId.toJson(),
    };
    if (returnByValue != null) {
      parameters['returnByValue'] = returnByValue;
    }
    if (generatePreview != null) {
      parameters['generatePreview'] = generatePreview;
    }
    var result = await _client.send('Runtime.awaitPromise', parameters);
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
  /// [generatePreview] Whether preview should be generated for the result.
  /// [userGesture] Whether execution should be treated as initiated by user in the UI.
  /// [awaitPromise] Whether execution should `await` for resulting value and return once awaited promise is
  /// resolved.
  /// [executionContextId] Specifies execution context which global object will be used to call function on. Either
  /// executionContextId or objectId should be specified.
  /// [objectGroup] Symbolic group name that can be used to release multiple objects. If objectGroup is not
  /// specified and objectId is, objectGroup will be inherited from object.
  Future<CallFunctionOnResult> callFunctionOn(String functionDeclaration,
      {RemoteObjectId objectId,
      List<CallArgument> arguments,
      bool silent,
      bool returnByValue,
      bool generatePreview,
      bool userGesture,
      bool awaitPromise,
      ExecutionContextId executionContextId,
      String objectGroup}) async {
    var parameters = <String, dynamic>{
      'functionDeclaration': functionDeclaration,
    };
    if (objectId != null) {
      parameters['objectId'] = objectId.toJson();
    }
    if (arguments != null) {
      parameters['arguments'] = arguments.map((e) => e.toJson()).toList();
    }
    if (silent != null) {
      parameters['silent'] = silent;
    }
    if (returnByValue != null) {
      parameters['returnByValue'] = returnByValue;
    }
    if (generatePreview != null) {
      parameters['generatePreview'] = generatePreview;
    }
    if (userGesture != null) {
      parameters['userGesture'] = userGesture;
    }
    if (awaitPromise != null) {
      parameters['awaitPromise'] = awaitPromise;
    }
    if (executionContextId != null) {
      parameters['executionContextId'] = executionContextId.toJson();
    }
    if (objectGroup != null) {
      parameters['objectGroup'] = objectGroup;
    }
    var result = await _client.send('Runtime.callFunctionOn', parameters);
    return CallFunctionOnResult.fromJson(result);
  }

  /// Compiles expression.
  /// [expression] Expression to compile.
  /// [sourceURL] Source url to be set for the script.
  /// [persistScript] Specifies whether the compiled script should be persisted.
  /// [executionContextId] Specifies in which execution context to perform script run. If the parameter is omitted the
  /// evaluation will be performed in the context of the inspected page.
  Future<CompileScriptResult> compileScript(
      String expression, String sourceURL, bool persistScript,
      {ExecutionContextId executionContextId}) async {
    var parameters = <String, dynamic>{
      'expression': expression,
      'sourceURL': sourceURL,
      'persistScript': persistScript,
    };
    if (executionContextId != null) {
      parameters['executionContextId'] = executionContextId.toJson();
    }
    var result = await _client.send('Runtime.compileScript', parameters);
    return CompileScriptResult.fromJson(result);
  }

  /// Disables reporting of execution contexts creation.
  Future disable() async {
    await _client.send('Runtime.disable');
  }

  /// Discards collected exceptions and console API calls.
  Future discardConsoleEntries() async {
    await _client.send('Runtime.discardConsoleEntries');
  }

  /// Enables reporting of execution contexts creation by means of `executionContextCreated` event.
  /// When the reporting gets enabled the event will be sent immediately for each existing execution
  /// context.
  Future enable() async {
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
  /// [returnByValue] Whether the result is expected to be a JSON object that should be sent by value.
  /// [generatePreview] Whether preview should be generated for the result.
  /// [userGesture] Whether execution should be treated as initiated by user in the UI.
  /// [awaitPromise] Whether execution should `await` for resulting value and return once awaited promise is
  /// resolved.
  /// [throwOnSideEffect] Whether to throw an exception if side effect cannot be ruled out during evaluation.
  /// [timeout] Terminate execution after timing out (number of milliseconds).
  Future<EvaluateResult> evaluate(String expression,
      {String objectGroup,
      bool includeCommandLineAPI,
      bool silent,
      ExecutionContextId contextId,
      bool returnByValue,
      bool generatePreview,
      bool userGesture,
      bool awaitPromise,
      bool throwOnSideEffect,
      TimeDelta timeout}) async {
    var parameters = <String, dynamic>{
      'expression': expression,
    };
    if (objectGroup != null) {
      parameters['objectGroup'] = objectGroup;
    }
    if (includeCommandLineAPI != null) {
      parameters['includeCommandLineAPI'] = includeCommandLineAPI;
    }
    if (silent != null) {
      parameters['silent'] = silent;
    }
    if (contextId != null) {
      parameters['contextId'] = contextId.toJson();
    }
    if (returnByValue != null) {
      parameters['returnByValue'] = returnByValue;
    }
    if (generatePreview != null) {
      parameters['generatePreview'] = generatePreview;
    }
    if (userGesture != null) {
      parameters['userGesture'] = userGesture;
    }
    if (awaitPromise != null) {
      parameters['awaitPromise'] = awaitPromise;
    }
    if (throwOnSideEffect != null) {
      parameters['throwOnSideEffect'] = throwOnSideEffect;
    }
    if (timeout != null) {
      parameters['timeout'] = timeout.toJson();
    }
    var result = await _client.send('Runtime.evaluate', parameters);
    return EvaluateResult.fromJson(result);
  }

  /// Returns the isolate id.
  /// Returns: The isolate id.
  Future<String> getIsolateId() async {
    var result = await _client.send('Runtime.getIsolateId');
    return result['id'];
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
  Future<GetPropertiesResult> getProperties(RemoteObjectId objectId,
      {bool ownProperties,
      bool accessorPropertiesOnly,
      bool generatePreview}) async {
    var parameters = <String, dynamic>{
      'objectId': objectId.toJson(),
    };
    if (ownProperties != null) {
      parameters['ownProperties'] = ownProperties;
    }
    if (accessorPropertiesOnly != null) {
      parameters['accessorPropertiesOnly'] = accessorPropertiesOnly;
    }
    if (generatePreview != null) {
      parameters['generatePreview'] = generatePreview;
    }
    var result = await _client.send('Runtime.getProperties', parameters);
    return GetPropertiesResult.fromJson(result);
  }

  /// Returns all let, const and class variables from global scope.
  /// [executionContextId] Specifies in which execution context to lookup global scope variables.
  Future<List<String>> globalLexicalScopeNames(
      {ExecutionContextId executionContextId}) async {
    var parameters = <String, dynamic>{};
    if (executionContextId != null) {
      parameters['executionContextId'] = executionContextId.toJson();
    }
    var result =
        await _client.send('Runtime.globalLexicalScopeNames', parameters);
    return (result['names'] as List).map((e) => e as String).toList();
  }

  /// [prototypeObjectId] Identifier of the prototype to return objects for.
  /// [objectGroup] Symbolic group name that can be used to release the results.
  /// Returns: Array with objects.
  Future<RemoteObject> queryObjects(RemoteObjectId prototypeObjectId,
      {String objectGroup}) async {
    var parameters = <String, dynamic>{
      'prototypeObjectId': prototypeObjectId.toJson(),
    };
    if (objectGroup != null) {
      parameters['objectGroup'] = objectGroup;
    }
    var result = await _client.send('Runtime.queryObjects', parameters);
    return RemoteObject.fromJson(result['objects']);
  }

  /// Releases remote object with given id.
  /// [objectId] Identifier of the object to release.
  Future releaseObject(RemoteObjectId objectId) async {
    var parameters = <String, dynamic>{
      'objectId': objectId.toJson(),
    };
    await _client.send('Runtime.releaseObject', parameters);
  }

  /// Releases all remote objects that belong to a given group.
  /// [objectGroup] Symbolic object group name.
  Future releaseObjectGroup(String objectGroup) async {
    var parameters = <String, dynamic>{
      'objectGroup': objectGroup,
    };
    await _client.send('Runtime.releaseObjectGroup', parameters);
  }

  /// Tells inspected instance to run if it was waiting for debugger to attach.
  Future runIfWaitingForDebugger() async {
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
  Future<RunScriptResult> runScript(ScriptId scriptId,
      {ExecutionContextId executionContextId,
      String objectGroup,
      bool silent,
      bool includeCommandLineAPI,
      bool returnByValue,
      bool generatePreview,
      bool awaitPromise}) async {
    var parameters = <String, dynamic>{
      'scriptId': scriptId.toJson(),
    };
    if (executionContextId != null) {
      parameters['executionContextId'] = executionContextId.toJson();
    }
    if (objectGroup != null) {
      parameters['objectGroup'] = objectGroup;
    }
    if (silent != null) {
      parameters['silent'] = silent;
    }
    if (includeCommandLineAPI != null) {
      parameters['includeCommandLineAPI'] = includeCommandLineAPI;
    }
    if (returnByValue != null) {
      parameters['returnByValue'] = returnByValue;
    }
    if (generatePreview != null) {
      parameters['generatePreview'] = generatePreview;
    }
    if (awaitPromise != null) {
      parameters['awaitPromise'] = awaitPromise;
    }
    var result = await _client.send('Runtime.runScript', parameters);
    return RunScriptResult.fromJson(result);
  }

  /// Enables or disables async call stacks tracking.
  /// [maxDepth] Maximum depth of async call stacks. Setting to `0` will effectively disable collecting async
  /// call stacks (default).
  Future setAsyncCallStackDepth(int maxDepth) async {
    var parameters = <String, dynamic>{
      'maxDepth': maxDepth,
    };
    await _client.send('Runtime.setAsyncCallStackDepth', parameters);
  }

  Future setCustomObjectFormatterEnabled(bool enabled) async {
    var parameters = <String, dynamic>{
      'enabled': enabled,
    };
    await _client.send('Runtime.setCustomObjectFormatterEnabled', parameters);
  }

  Future setMaxCallStackSizeToCapture(int size) async {
    var parameters = <String, dynamic>{
      'size': size,
    };
    await _client.send('Runtime.setMaxCallStackSizeToCapture', parameters);
  }

  /// Terminate current or next JavaScript execution.
  /// Will cancel the termination when the outer-most script execution ends.
  Future terminateExecution() async {
    await _client.send('Runtime.terminateExecution');
  }

  /// If executionContextId is empty, adds binding with the given name on the
  /// global objects of all inspected contexts, including those created later,
  /// bindings survive reloads.
  /// If executionContextId is specified, adds binding only on global object of
  /// given execution context.
  /// Binding function takes exactly one argument, this argument should be string,
  /// in case of any other input, function throws an exception.
  /// Each binding function call produces Runtime.bindingCalled notification.
  Future addBinding(String name,
      {ExecutionContextId executionContextId}) async {
    var parameters = <String, dynamic>{
      'name': name,
    };
    if (executionContextId != null) {
      parameters['executionContextId'] = executionContextId.toJson();
    }
    await _client.send('Runtime.addBinding', parameters);
  }

  /// This method does not remove binding function from global object but
  /// unsubscribes current runtime agent from Runtime.bindingCalled notifications.
  Future removeBinding(String name) async {
    var parameters = <String, dynamic>{
      'name': name,
    };
    await _client.send('Runtime.removeBinding', parameters);
  }
}

class BindingCalledEvent {
  final String name;

  final String payload;

  /// Identifier of the context where the call was made.
  final ExecutionContextId executionContextId;

  BindingCalledEvent(
      {@required this.name,
      @required this.payload,
      @required this.executionContextId});

  factory BindingCalledEvent.fromJson(Map<String, dynamic> json) {
    return BindingCalledEvent(
      name: json['name'],
      payload: json['payload'],
      executionContextId:
          ExecutionContextId.fromJson(json['executionContextId']),
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
  final StackTrace stackTrace;

  /// Console context descriptor for calls on non-default console context (not console.*):
  /// 'anonymous#unique-logger-id' for call on unnamed context, 'name#unique-logger-id' for call
  /// on named context.
  final String context;

  ConsoleAPICalledEvent(
      {@required this.type,
      @required this.args,
      @required this.executionContextId,
      @required this.timestamp,
      this.stackTrace,
      this.context});

  factory ConsoleAPICalledEvent.fromJson(Map<String, dynamic> json) {
    return ConsoleAPICalledEvent(
      type: ConsoleAPICalledEventType.fromJson(json['type']),
      args:
          (json['args'] as List).map((e) => RemoteObject.fromJson(e)).toList(),
      executionContextId:
          ExecutionContextId.fromJson(json['executionContextId']),
      timestamp: Timestamp.fromJson(json['timestamp']),
      stackTrace: json.containsKey('stackTrace')
          ? StackTrace.fromJson(json['stackTrace'])
          : null,
      context: json.containsKey('context') ? json['context'] : null,
    );
  }
}

class ExceptionRevokedEvent {
  /// Reason describing why exception was revoked.
  final String reason;

  /// The id of revoked exception, as reported in `exceptionThrown`.
  final int exceptionId;

  ExceptionRevokedEvent({@required this.reason, @required this.exceptionId});

  factory ExceptionRevokedEvent.fromJson(Map<String, dynamic> json) {
    return ExceptionRevokedEvent(
      reason: json['reason'],
      exceptionId: json['exceptionId'],
    );
  }
}

class ExceptionThrownEvent {
  /// Timestamp of the exception.
  final Timestamp timestamp;

  final ExceptionDetails exceptionDetails;

  ExceptionThrownEvent(
      {@required this.timestamp, @required this.exceptionDetails});

  factory ExceptionThrownEvent.fromJson(Map<String, dynamic> json) {
    return ExceptionThrownEvent(
      timestamp: Timestamp.fromJson(json['timestamp']),
      exceptionDetails: ExceptionDetails.fromJson(json['exceptionDetails']),
    );
  }
}

class InspectRequestedEvent {
  final RemoteObject object;

  final Map hints;

  InspectRequestedEvent({@required this.object, @required this.hints});

  factory InspectRequestedEvent.fromJson(Map<String, dynamic> json) {
    return InspectRequestedEvent(
      object: RemoteObject.fromJson(json['object']),
      hints: json['hints'],
    );
  }
}

class AwaitPromiseResult {
  /// Promise result. Will contain rejected value if promise was rejected.
  final RemoteObject result;

  /// Exception details if stack strace is available.
  final ExceptionDetails exceptionDetails;

  AwaitPromiseResult({@required this.result, this.exceptionDetails});

  factory AwaitPromiseResult.fromJson(Map<String, dynamic> json) {
    return AwaitPromiseResult(
      result: RemoteObject.fromJson(json['result']),
      exceptionDetails: json.containsKey('exceptionDetails')
          ? ExceptionDetails.fromJson(json['exceptionDetails'])
          : null,
    );
  }
}

class CallFunctionOnResult {
  /// Call result.
  final RemoteObject result;

  /// Exception details.
  final ExceptionDetails exceptionDetails;

  CallFunctionOnResult({@required this.result, this.exceptionDetails});

  factory CallFunctionOnResult.fromJson(Map<String, dynamic> json) {
    return CallFunctionOnResult(
      result: RemoteObject.fromJson(json['result']),
      exceptionDetails: json.containsKey('exceptionDetails')
          ? ExceptionDetails.fromJson(json['exceptionDetails'])
          : null,
    );
  }
}

class CompileScriptResult {
  /// Id of the script.
  final ScriptId scriptId;

  /// Exception details.
  final ExceptionDetails exceptionDetails;

  CompileScriptResult({this.scriptId, this.exceptionDetails});

  factory CompileScriptResult.fromJson(Map<String, dynamic> json) {
    return CompileScriptResult(
      scriptId: json.containsKey('scriptId')
          ? ScriptId.fromJson(json['scriptId'])
          : null,
      exceptionDetails: json.containsKey('exceptionDetails')
          ? ExceptionDetails.fromJson(json['exceptionDetails'])
          : null,
    );
  }
}

class EvaluateResult {
  /// Evaluation result.
  final RemoteObject result;

  /// Exception details.
  final ExceptionDetails exceptionDetails;

  EvaluateResult({@required this.result, this.exceptionDetails});

  factory EvaluateResult.fromJson(Map<String, dynamic> json) {
    return EvaluateResult(
      result: RemoteObject.fromJson(json['result']),
      exceptionDetails: json.containsKey('exceptionDetails')
          ? ExceptionDetails.fromJson(json['exceptionDetails'])
          : null,
    );
  }
}

class GetHeapUsageResult {
  /// Used heap size in bytes.
  final num usedSize;

  /// Allocated heap size in bytes.
  final num totalSize;

  GetHeapUsageResult({@required this.usedSize, @required this.totalSize});

  factory GetHeapUsageResult.fromJson(Map<String, dynamic> json) {
    return GetHeapUsageResult(
      usedSize: json['usedSize'],
      totalSize: json['totalSize'],
    );
  }
}

class GetPropertiesResult {
  /// Object properties.
  final List<PropertyDescriptor> result;

  /// Internal object properties (only of the element itself).
  final List<InternalPropertyDescriptor> internalProperties;

  /// Object private properties.
  final List<PrivatePropertyDescriptor> privateProperties;

  /// Exception details.
  final ExceptionDetails exceptionDetails;

  GetPropertiesResult(
      {@required this.result,
      this.internalProperties,
      this.privateProperties,
      this.exceptionDetails});

  factory GetPropertiesResult.fromJson(Map<String, dynamic> json) {
    return GetPropertiesResult(
      result: (json['result'] as List)
          .map((e) => PropertyDescriptor.fromJson(e))
          .toList(),
      internalProperties: json.containsKey('internalProperties')
          ? (json['internalProperties'] as List)
              .map((e) => InternalPropertyDescriptor.fromJson(e))
              .toList()
          : null,
      privateProperties: json.containsKey('privateProperties')
          ? (json['privateProperties'] as List)
              .map((e) => PrivatePropertyDescriptor.fromJson(e))
              .toList()
          : null,
      exceptionDetails: json.containsKey('exceptionDetails')
          ? ExceptionDetails.fromJson(json['exceptionDetails'])
          : null,
    );
  }
}

class RunScriptResult {
  /// Run result.
  final RemoteObject result;

  /// Exception details.
  final ExceptionDetails exceptionDetails;

  RunScriptResult({@required this.result, this.exceptionDetails});

  factory RunScriptResult.fromJson(Map<String, dynamic> json) {
    return RunScriptResult(
      result: RemoteObject.fromJson(json['result']),
      exceptionDetails: json.containsKey('exceptionDetails')
          ? ExceptionDetails.fromJson(json['exceptionDetails'])
          : null,
    );
  }
}

/// Unique script identifier.
class ScriptId {
  final String value;

  ScriptId(this.value);

  factory ScriptId.fromJson(String value) => ScriptId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ScriptId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Unique object identifier.
class RemoteObjectId {
  final String value;

  RemoteObjectId(this.value);

  factory RemoteObjectId.fromJson(String value) => RemoteObjectId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is RemoteObjectId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Primitive value which cannot be JSON-stringified. Includes values `-0`, `NaN`, `Infinity`,
/// `-Infinity`, and bigint literals.
class UnserializableValue {
  final String value;

  UnserializableValue(this.value);

  factory UnserializableValue.fromJson(String value) =>
      UnserializableValue(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is UnserializableValue && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Mirror object referencing original JavaScript object.
class RemoteObject {
  /// Object type.
  final RemoteObjectType type;

  /// Object subtype hint. Specified for `object` type values only.
  final RemoteObjectSubtype subtype;

  /// Object class (constructor) name. Specified for `object` type values only.
  final String className;

  /// Remote object value in case of primitive values or JSON values (if it was requested).
  final dynamic value;

  /// Primitive value which can not be JSON-stringified does not have `value`, but gets this
  /// property.
  final UnserializableValue unserializableValue;

  /// String representation of the object.
  final String description;

  /// Unique object identifier (for non-primitive values).
  final RemoteObjectId objectId;

  /// Preview containing abbreviated property values. Specified for `object` type values only.
  final ObjectPreview preview;

  final CustomPreview customPreview;

  RemoteObject(
      {@required this.type,
      this.subtype,
      this.className,
      this.value,
      this.unserializableValue,
      this.description,
      this.objectId,
      this.preview,
      this.customPreview});

  factory RemoteObject.fromJson(Map<String, dynamic> json) {
    return RemoteObject(
      type: RemoteObjectType.fromJson(json['type']),
      subtype: json.containsKey('subtype')
          ? RemoteObjectSubtype.fromJson(json['subtype'])
          : null,
      className: json.containsKey('className') ? json['className'] : null,
      value: json.containsKey('value') ? json['value'] : null,
      unserializableValue: json.containsKey('unserializableValue')
          ? UnserializableValue.fromJson(json['unserializableValue'])
          : null,
      description: json.containsKey('description') ? json['description'] : null,
      objectId: json.containsKey('objectId')
          ? RemoteObjectId.fromJson(json['objectId'])
          : null,
      preview: json.containsKey('preview')
          ? ObjectPreview.fromJson(json['preview'])
          : null,
      customPreview: json.containsKey('customPreview')
          ? CustomPreview.fromJson(json['customPreview'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'type': type,
    };
    if (subtype != null) {
      json['subtype'] = subtype;
    }
    if (className != null) {
      json['className'] = className;
    }
    if (value != null) {
      json['value'] = value;
    }
    if (unserializableValue != null) {
      json['unserializableValue'] = unserializableValue.toJson();
    }
    if (description != null) {
      json['description'] = description;
    }
    if (objectId != null) {
      json['objectId'] = objectId.toJson();
    }
    if (preview != null) {
      json['preview'] = preview.toJson();
    }
    if (customPreview != null) {
      json['customPreview'] = customPreview.toJson();
    }
    return json;
  }
}

class RemoteObjectType {
  static const RemoteObjectType object = const RemoteObjectType._('object');
  static const RemoteObjectType function = const RemoteObjectType._('function');
  static const RemoteObjectType undefined =
      const RemoteObjectType._('undefined');
  static const RemoteObjectType string = const RemoteObjectType._('string');
  static const RemoteObjectType number = const RemoteObjectType._('number');
  static const RemoteObjectType boolean = const RemoteObjectType._('boolean');
  static const RemoteObjectType symbol = const RemoteObjectType._('symbol');
  static const RemoteObjectType bigint = const RemoteObjectType._('bigint');
  static const values = const {
    'object': object,
    'function': function,
    'undefined': undefined,
    'string': string,
    'number': number,
    'boolean': boolean,
    'symbol': symbol,
    'bigint': bigint,
  };

  final String value;

  const RemoteObjectType._(this.value);

  factory RemoteObjectType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class RemoteObjectSubtype {
  static const RemoteObjectSubtype array = const RemoteObjectSubtype._('array');
  static const RemoteObjectSubtype null$ = const RemoteObjectSubtype._('null');
  static const RemoteObjectSubtype node = const RemoteObjectSubtype._('node');
  static const RemoteObjectSubtype regexp =
      const RemoteObjectSubtype._('regexp');
  static const RemoteObjectSubtype date = const RemoteObjectSubtype._('date');
  static const RemoteObjectSubtype map = const RemoteObjectSubtype._('map');
  static const RemoteObjectSubtype set$ = const RemoteObjectSubtype._('set');
  static const RemoteObjectSubtype weakmap =
      const RemoteObjectSubtype._('weakmap');
  static const RemoteObjectSubtype weakset =
      const RemoteObjectSubtype._('weakset');
  static const RemoteObjectSubtype iterator =
      const RemoteObjectSubtype._('iterator');
  static const RemoteObjectSubtype generator =
      const RemoteObjectSubtype._('generator');
  static const RemoteObjectSubtype error = const RemoteObjectSubtype._('error');
  static const RemoteObjectSubtype proxy = const RemoteObjectSubtype._('proxy');
  static const RemoteObjectSubtype promise =
      const RemoteObjectSubtype._('promise');
  static const RemoteObjectSubtype typedarray =
      const RemoteObjectSubtype._('typedarray');
  static const RemoteObjectSubtype arraybuffer =
      const RemoteObjectSubtype._('arraybuffer');
  static const RemoteObjectSubtype dataview =
      const RemoteObjectSubtype._('dataview');
  static const values = const {
    'array': array,
    'null': null$,
    'node': node,
    'regexp': regexp,
    'date': date,
    'map': map,
    'set': set$,
    'weakmap': weakmap,
    'weakset': weakset,
    'iterator': iterator,
    'generator': generator,
    'error': error,
    'proxy': proxy,
    'promise': promise,
    'typedarray': typedarray,
    'arraybuffer': arraybuffer,
    'dataview': dataview,
  };

  final String value;

  const RemoteObjectSubtype._(this.value);

  factory RemoteObjectSubtype.fromJson(String value) => values[value];

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
  final RemoteObjectId bodyGetterId;

  CustomPreview({@required this.header, this.bodyGetterId});

  factory CustomPreview.fromJson(Map<String, dynamic> json) {
    return CustomPreview(
      header: json['header'],
      bodyGetterId: json.containsKey('bodyGetterId')
          ? RemoteObjectId.fromJson(json['bodyGetterId'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'header': header,
    };
    if (bodyGetterId != null) {
      json['bodyGetterId'] = bodyGetterId.toJson();
    }
    return json;
  }
}

/// Object containing abbreviated remote object value.
class ObjectPreview {
  /// Object type.
  final ObjectPreviewType type;

  /// Object subtype hint. Specified for `object` type values only.
  final ObjectPreviewSubtype subtype;

  /// String representation of the object.
  final String description;

  /// True iff some of the properties or entries of the original object did not fit.
  final bool overflow;

  /// List of the properties.
  final List<PropertyPreview> properties;

  /// List of the entries. Specified for `map` and `set` subtype values only.
  final List<EntryPreview> entries;

  ObjectPreview(
      {@required this.type,
      this.subtype,
      this.description,
      @required this.overflow,
      @required this.properties,
      this.entries});

  factory ObjectPreview.fromJson(Map<String, dynamic> json) {
    return ObjectPreview(
      type: ObjectPreviewType.fromJson(json['type']),
      subtype: json.containsKey('subtype')
          ? ObjectPreviewSubtype.fromJson(json['subtype'])
          : null,
      description: json.containsKey('description') ? json['description'] : null,
      overflow: json['overflow'],
      properties: (json['properties'] as List)
          .map((e) => PropertyPreview.fromJson(e))
          .toList(),
      entries: json.containsKey('entries')
          ? (json['entries'] as List)
              .map((e) => EntryPreview.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'type': type,
      'overflow': overflow,
      'properties': properties.map((e) => e.toJson()).toList(),
    };
    if (subtype != null) {
      json['subtype'] = subtype;
    }
    if (description != null) {
      json['description'] = description;
    }
    if (entries != null) {
      json['entries'] = entries.map((e) => e.toJson()).toList();
    }
    return json;
  }
}

class ObjectPreviewType {
  static const ObjectPreviewType object = const ObjectPreviewType._('object');
  static const ObjectPreviewType function =
      const ObjectPreviewType._('function');
  static const ObjectPreviewType undefined =
      const ObjectPreviewType._('undefined');
  static const ObjectPreviewType string = const ObjectPreviewType._('string');
  static const ObjectPreviewType number = const ObjectPreviewType._('number');
  static const ObjectPreviewType boolean = const ObjectPreviewType._('boolean');
  static const ObjectPreviewType symbol = const ObjectPreviewType._('symbol');
  static const ObjectPreviewType bigint = const ObjectPreviewType._('bigint');
  static const values = const {
    'object': object,
    'function': function,
    'undefined': undefined,
    'string': string,
    'number': number,
    'boolean': boolean,
    'symbol': symbol,
    'bigint': bigint,
  };

  final String value;

  const ObjectPreviewType._(this.value);

  factory ObjectPreviewType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class ObjectPreviewSubtype {
  static const ObjectPreviewSubtype array =
      const ObjectPreviewSubtype._('array');
  static const ObjectPreviewSubtype null$ =
      const ObjectPreviewSubtype._('null');
  static const ObjectPreviewSubtype node = const ObjectPreviewSubtype._('node');
  static const ObjectPreviewSubtype regexp =
      const ObjectPreviewSubtype._('regexp');
  static const ObjectPreviewSubtype date = const ObjectPreviewSubtype._('date');
  static const ObjectPreviewSubtype map = const ObjectPreviewSubtype._('map');
  static const ObjectPreviewSubtype set$ = const ObjectPreviewSubtype._('set');
  static const ObjectPreviewSubtype weakmap =
      const ObjectPreviewSubtype._('weakmap');
  static const ObjectPreviewSubtype weakset =
      const ObjectPreviewSubtype._('weakset');
  static const ObjectPreviewSubtype iterator =
      const ObjectPreviewSubtype._('iterator');
  static const ObjectPreviewSubtype generator =
      const ObjectPreviewSubtype._('generator');
  static const ObjectPreviewSubtype error =
      const ObjectPreviewSubtype._('error');
  static const values = const {
    'array': array,
    'null': null$,
    'node': node,
    'regexp': regexp,
    'date': date,
    'map': map,
    'set': set$,
    'weakmap': weakmap,
    'weakset': weakset,
    'iterator': iterator,
    'generator': generator,
    'error': error,
  };

  final String value;

  const ObjectPreviewSubtype._(this.value);

  factory ObjectPreviewSubtype.fromJson(String value) => values[value];

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
  final String value;

  /// Nested value preview.
  final ObjectPreview valuePreview;

  /// Object subtype hint. Specified for `object` type values only.
  final PropertyPreviewSubtype subtype;

  PropertyPreview(
      {@required this.name,
      @required this.type,
      this.value,
      this.valuePreview,
      this.subtype});

  factory PropertyPreview.fromJson(Map<String, dynamic> json) {
    return PropertyPreview(
      name: json['name'],
      type: PropertyPreviewType.fromJson(json['type']),
      value: json.containsKey('value') ? json['value'] : null,
      valuePreview: json.containsKey('valuePreview')
          ? ObjectPreview.fromJson(json['valuePreview'])
          : null,
      subtype: json.containsKey('subtype')
          ? PropertyPreviewSubtype.fromJson(json['subtype'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'name': name,
      'type': type,
    };
    if (value != null) {
      json['value'] = value;
    }
    if (valuePreview != null) {
      json['valuePreview'] = valuePreview.toJson();
    }
    if (subtype != null) {
      json['subtype'] = subtype;
    }
    return json;
  }
}

class PropertyPreviewType {
  static const PropertyPreviewType object =
      const PropertyPreviewType._('object');
  static const PropertyPreviewType function =
      const PropertyPreviewType._('function');
  static const PropertyPreviewType undefined =
      const PropertyPreviewType._('undefined');
  static const PropertyPreviewType string =
      const PropertyPreviewType._('string');
  static const PropertyPreviewType number =
      const PropertyPreviewType._('number');
  static const PropertyPreviewType boolean =
      const PropertyPreviewType._('boolean');
  static const PropertyPreviewType symbol =
      const PropertyPreviewType._('symbol');
  static const PropertyPreviewType accessor =
      const PropertyPreviewType._('accessor');
  static const PropertyPreviewType bigint =
      const PropertyPreviewType._('bigint');
  static const values = const {
    'object': object,
    'function': function,
    'undefined': undefined,
    'string': string,
    'number': number,
    'boolean': boolean,
    'symbol': symbol,
    'accessor': accessor,
    'bigint': bigint,
  };

  final String value;

  const PropertyPreviewType._(this.value);

  factory PropertyPreviewType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class PropertyPreviewSubtype {
  static const PropertyPreviewSubtype array =
      const PropertyPreviewSubtype._('array');
  static const PropertyPreviewSubtype null$ =
      const PropertyPreviewSubtype._('null');
  static const PropertyPreviewSubtype node =
      const PropertyPreviewSubtype._('node');
  static const PropertyPreviewSubtype regexp =
      const PropertyPreviewSubtype._('regexp');
  static const PropertyPreviewSubtype date =
      const PropertyPreviewSubtype._('date');
  static const PropertyPreviewSubtype map =
      const PropertyPreviewSubtype._('map');
  static const PropertyPreviewSubtype set$ =
      const PropertyPreviewSubtype._('set');
  static const PropertyPreviewSubtype weakmap =
      const PropertyPreviewSubtype._('weakmap');
  static const PropertyPreviewSubtype weakset =
      const PropertyPreviewSubtype._('weakset');
  static const PropertyPreviewSubtype iterator =
      const PropertyPreviewSubtype._('iterator');
  static const PropertyPreviewSubtype generator =
      const PropertyPreviewSubtype._('generator');
  static const PropertyPreviewSubtype error =
      const PropertyPreviewSubtype._('error');
  static const values = const {
    'array': array,
    'null': null$,
    'node': node,
    'regexp': regexp,
    'date': date,
    'map': map,
    'set': set$,
    'weakmap': weakmap,
    'weakset': weakset,
    'iterator': iterator,
    'generator': generator,
    'error': error,
  };

  final String value;

  const PropertyPreviewSubtype._(this.value);

  factory PropertyPreviewSubtype.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class EntryPreview {
  /// Preview of the key. Specified for map-like collection entries.
  final ObjectPreview key;

  /// Preview of the value.
  final ObjectPreview value;

  EntryPreview({this.key, @required this.value});

  factory EntryPreview.fromJson(Map<String, dynamic> json) {
    return EntryPreview(
      key: json.containsKey('key') ? ObjectPreview.fromJson(json['key']) : null,
      value: ObjectPreview.fromJson(json['value']),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'value': value.toJson(),
    };
    if (key != null) {
      json['key'] = key.toJson();
    }
    return json;
  }
}

/// Object property descriptor.
class PropertyDescriptor {
  /// Property name or symbol description.
  final String name;

  /// The value associated with the property.
  final RemoteObject value;

  /// True if the value associated with the property may be changed (data descriptors only).
  final bool writable;

  /// A function which serves as a getter for the property, or `undefined` if there is no getter
  /// (accessor descriptors only).
  final RemoteObject get;

  /// A function which serves as a setter for the property, or `undefined` if there is no setter
  /// (accessor descriptors only).
  final RemoteObject set;

  /// True if the type of this property descriptor may be changed and if the property may be
  /// deleted from the corresponding object.
  final bool configurable;

  /// True if this property shows up during enumeration of the properties on the corresponding
  /// object.
  final bool enumerable;

  /// True if the result was thrown during the evaluation.
  final bool wasThrown;

  /// True if the property is owned for the object.
  final bool isOwn;

  /// Property symbol object, if the property is of the `symbol` type.
  final RemoteObject symbol;

  PropertyDescriptor(
      {@required this.name,
      this.value,
      this.writable,
      this.get,
      this.set,
      @required this.configurable,
      @required this.enumerable,
      this.wasThrown,
      this.isOwn,
      this.symbol});

  factory PropertyDescriptor.fromJson(Map<String, dynamic> json) {
    return PropertyDescriptor(
      name: json['name'],
      value: json.containsKey('value')
          ? RemoteObject.fromJson(json['value'])
          : null,
      writable: json.containsKey('writable') ? json['writable'] : null,
      get: json.containsKey('get') ? RemoteObject.fromJson(json['get']) : null,
      set: json.containsKey('set') ? RemoteObject.fromJson(json['set']) : null,
      configurable: json['configurable'],
      enumerable: json['enumerable'],
      wasThrown: json.containsKey('wasThrown') ? json['wasThrown'] : null,
      isOwn: json.containsKey('isOwn') ? json['isOwn'] : null,
      symbol: json.containsKey('symbol')
          ? RemoteObject.fromJson(json['symbol'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'name': name,
      'configurable': configurable,
      'enumerable': enumerable,
    };
    if (value != null) {
      json['value'] = value.toJson();
    }
    if (writable != null) {
      json['writable'] = writable;
    }
    if (get != null) {
      json['get'] = get.toJson();
    }
    if (set != null) {
      json['set'] = set.toJson();
    }
    if (wasThrown != null) {
      json['wasThrown'] = wasThrown;
    }
    if (isOwn != null) {
      json['isOwn'] = isOwn;
    }
    if (symbol != null) {
      json['symbol'] = symbol.toJson();
    }
    return json;
  }
}

/// Object internal property descriptor. This property isn't normally visible in JavaScript code.
class InternalPropertyDescriptor {
  /// Conventional property name.
  final String name;

  /// The value associated with the property.
  final RemoteObject value;

  InternalPropertyDescriptor({@required this.name, this.value});

  factory InternalPropertyDescriptor.fromJson(Map<String, dynamic> json) {
    return InternalPropertyDescriptor(
      name: json['name'],
      value: json.containsKey('value')
          ? RemoteObject.fromJson(json['value'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'name': name,
    };
    if (value != null) {
      json['value'] = value.toJson();
    }
    return json;
  }
}

/// Object private field descriptor.
class PrivatePropertyDescriptor {
  /// Private property name.
  final String name;

  /// The value associated with the private property.
  final RemoteObject value;

  PrivatePropertyDescriptor({@required this.name, @required this.value});

  factory PrivatePropertyDescriptor.fromJson(Map<String, dynamic> json) {
    return PrivatePropertyDescriptor(
      name: json['name'],
      value: RemoteObject.fromJson(json['value']),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'name': name,
      'value': value.toJson(),
    };
    return json;
  }
}

/// Represents function call argument. Either remote object id `objectId`, primitive `value`,
/// unserializable primitive value or neither of (for undefined) them should be specified.
class CallArgument {
  /// Primitive value or serializable javascript object.
  final dynamic value;

  /// Primitive value which can not be JSON-stringified.
  final UnserializableValue unserializableValue;

  /// Remote object handle.
  final RemoteObjectId objectId;

  CallArgument({this.value, this.unserializableValue, this.objectId});

  factory CallArgument.fromJson(Map<String, dynamic> json) {
    return CallArgument(
      value: json.containsKey('value') ? json['value'] : null,
      unserializableValue: json.containsKey('unserializableValue')
          ? UnserializableValue.fromJson(json['unserializableValue'])
          : null,
      objectId: json.containsKey('objectId')
          ? RemoteObjectId.fromJson(json['objectId'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};
    if (value != null) {
      json['value'] = value;
    }
    if (unserializableValue != null) {
      json['unserializableValue'] = unserializableValue.toJson();
    }
    if (objectId != null) {
      json['objectId'] = objectId.toJson();
    }
    return json;
  }
}

/// Id of an execution context.
class ExecutionContextId {
  final int value;

  ExecutionContextId(this.value);

  factory ExecutionContextId.fromJson(int value) => ExecutionContextId(value);

  int toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ExecutionContextId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
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

  /// Embedder-specific auxiliary data.
  final Map auxData;

  ExecutionContextDescription(
      {@required this.id,
      @required this.origin,
      @required this.name,
      this.auxData});

  factory ExecutionContextDescription.fromJson(Map<String, dynamic> json) {
    return ExecutionContextDescription(
      id: ExecutionContextId.fromJson(json['id']),
      origin: json['origin'],
      name: json['name'],
      auxData: json.containsKey('auxData') ? json['auxData'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'id': id.toJson(),
      'origin': origin,
      'name': name,
    };
    if (auxData != null) {
      json['auxData'] = auxData;
    }
    return json;
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
  final ScriptId scriptId;

  /// URL of the exception location, to be used when the script was not reported.
  final String url;

  /// JavaScript stack trace if available.
  final StackTrace stackTrace;

  /// Exception object if available.
  final RemoteObject exception;

  /// Identifier of the context where exception happened.
  final ExecutionContextId executionContextId;

  ExceptionDetails(
      {@required this.exceptionId,
      @required this.text,
      @required this.lineNumber,
      @required this.columnNumber,
      this.scriptId,
      this.url,
      this.stackTrace,
      this.exception,
      this.executionContextId});

  factory ExceptionDetails.fromJson(Map<String, dynamic> json) {
    return ExceptionDetails(
      exceptionId: json['exceptionId'],
      text: json['text'],
      lineNumber: json['lineNumber'],
      columnNumber: json['columnNumber'],
      scriptId: json.containsKey('scriptId')
          ? ScriptId.fromJson(json['scriptId'])
          : null,
      url: json.containsKey('url') ? json['url'] : null,
      stackTrace: json.containsKey('stackTrace')
          ? StackTrace.fromJson(json['stackTrace'])
          : null,
      exception: json.containsKey('exception')
          ? RemoteObject.fromJson(json['exception'])
          : null,
      executionContextId: json.containsKey('executionContextId')
          ? ExecutionContextId.fromJson(json['executionContextId'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'exceptionId': exceptionId,
      'text': text,
      'lineNumber': lineNumber,
      'columnNumber': columnNumber,
    };
    if (scriptId != null) {
      json['scriptId'] = scriptId.toJson();
    }
    if (url != null) {
      json['url'] = url;
    }
    if (stackTrace != null) {
      json['stackTrace'] = stackTrace.toJson();
    }
    if (exception != null) {
      json['exception'] = exception.toJson();
    }
    if (executionContextId != null) {
      json['executionContextId'] = executionContextId.toJson();
    }
    return json;
  }
}

/// Number of milliseconds since epoch.
class Timestamp {
  final num value;

  Timestamp(this.value);

  factory Timestamp.fromJson(num value) => Timestamp(value);

  num toJson() => value;

  @override
  bool operator ==(other) =>
      (other is Timestamp && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Number of milliseconds.
class TimeDelta {
  final num value;

  TimeDelta(this.value);

  factory TimeDelta.fromJson(num value) => TimeDelta(value);

  num toJson() => value;

  @override
  bool operator ==(other) =>
      (other is TimeDelta && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
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

  CallFrame(
      {@required this.functionName,
      @required this.scriptId,
      @required this.url,
      @required this.lineNumber,
      @required this.columnNumber});

  factory CallFrame.fromJson(Map<String, dynamic> json) {
    return CallFrame(
      functionName: json['functionName'],
      scriptId: ScriptId.fromJson(json['scriptId']),
      url: json['url'],
      lineNumber: json['lineNumber'],
      columnNumber: json['columnNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'functionName': functionName,
      'scriptId': scriptId.toJson(),
      'url': url,
      'lineNumber': lineNumber,
      'columnNumber': columnNumber,
    };
    return json;
  }
}

/// Call frames for assertions or error messages.
class StackTrace {
  /// String label of this stack trace. For async traces this may be a name of the function that
  /// initiated the async call.
  final String description;

  /// JavaScript function name.
  final List<CallFrame> callFrames;

  /// Asynchronous JavaScript stack trace that preceded this stack, if available.
  final StackTrace parent;

  /// Asynchronous JavaScript stack trace that preceded this stack, if available.
  final StackTraceId parentId;

  StackTrace(
      {this.description,
      @required this.callFrames,
      this.parent,
      this.parentId});

  factory StackTrace.fromJson(Map<String, dynamic> json) {
    return StackTrace(
      description: json.containsKey('description') ? json['description'] : null,
      callFrames: (json['callFrames'] as List)
          .map((e) => CallFrame.fromJson(e))
          .toList(),
      parent: json.containsKey('parent')
          ? StackTrace.fromJson(json['parent'])
          : null,
      parentId: json.containsKey('parentId')
          ? StackTraceId.fromJson(json['parentId'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'callFrames': callFrames.map((e) => e.toJson()).toList(),
    };
    if (description != null) {
      json['description'] = description;
    }
    if (parent != null) {
      json['parent'] = parent.toJson();
    }
    if (parentId != null) {
      json['parentId'] = parentId.toJson();
    }
    return json;
  }
}

/// Unique identifier of current debugger.
class UniqueDebuggerId {
  final String value;

  UniqueDebuggerId(this.value);

  factory UniqueDebuggerId.fromJson(String value) => UniqueDebuggerId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is UniqueDebuggerId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// If `debuggerId` is set stack trace comes from another debugger and can be resolved there. This
/// allows to track cross-debugger calls. See `Runtime.StackTrace` and `Debugger.paused` for usages.
class StackTraceId {
  final String id;

  final UniqueDebuggerId debuggerId;

  StackTraceId({@required this.id, this.debuggerId});

  factory StackTraceId.fromJson(Map<String, dynamic> json) {
    return StackTraceId(
      id: json['id'],
      debuggerId: json.containsKey('debuggerId')
          ? UniqueDebuggerId.fromJson(json['debuggerId'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'id': id,
    };
    if (debuggerId != null) {
      json['debuggerId'] = debuggerId.toJson();
    }
    return json;
  }
}

class ConsoleAPICalledEventType {
  static const ConsoleAPICalledEventType log =
      const ConsoleAPICalledEventType._('log');
  static const ConsoleAPICalledEventType debug =
      const ConsoleAPICalledEventType._('debug');
  static const ConsoleAPICalledEventType info =
      const ConsoleAPICalledEventType._('info');
  static const ConsoleAPICalledEventType error =
      const ConsoleAPICalledEventType._('error');
  static const ConsoleAPICalledEventType warning =
      const ConsoleAPICalledEventType._('warning');
  static const ConsoleAPICalledEventType dir =
      const ConsoleAPICalledEventType._('dir');
  static const ConsoleAPICalledEventType dirxml =
      const ConsoleAPICalledEventType._('dirxml');
  static const ConsoleAPICalledEventType table =
      const ConsoleAPICalledEventType._('table');
  static const ConsoleAPICalledEventType trace =
      const ConsoleAPICalledEventType._('trace');
  static const ConsoleAPICalledEventType clear =
      const ConsoleAPICalledEventType._('clear');
  static const ConsoleAPICalledEventType startGroup =
      const ConsoleAPICalledEventType._('startGroup');
  static const ConsoleAPICalledEventType startGroupCollapsed =
      const ConsoleAPICalledEventType._('startGroupCollapsed');
  static const ConsoleAPICalledEventType endGroup =
      const ConsoleAPICalledEventType._('endGroup');
  static const ConsoleAPICalledEventType assert$ =
      const ConsoleAPICalledEventType._('assert');
  static const ConsoleAPICalledEventType profile =
      const ConsoleAPICalledEventType._('profile');
  static const ConsoleAPICalledEventType profileEnd =
      const ConsoleAPICalledEventType._('profileEnd');
  static const ConsoleAPICalledEventType count =
      const ConsoleAPICalledEventType._('count');
  static const ConsoleAPICalledEventType timeEnd =
      const ConsoleAPICalledEventType._('timeEnd');
  static const values = const {
    'log': log,
    'debug': debug,
    'info': info,
    'error': error,
    'warning': warning,
    'dir': dir,
    'dirxml': dirxml,
    'table': table,
    'trace': trace,
    'clear': clear,
    'startGroup': startGroup,
    'startGroupCollapsed': startGroupCollapsed,
    'endGroup': endGroup,
    'assert': assert$,
    'profile': profile,
    'profileEnd': profileEnd,
    'count': count,
    'timeEnd': timeEnd,
  };

  final String value;

  const ConsoleAPICalledEventType._(this.value);

  factory ConsoleAPICalledEventType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  String toString() => value.toString();
}
