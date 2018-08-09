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

  /// Issued when console API was called.
  Stream<ConsoleAPICalledEvent> get onConsoleAPICalled => _client.onEvent
      .where((Event event) => event.name == 'Runtime.consoleAPICalled')
      .map((Event event) =>
          new ConsoleAPICalledEvent.fromJson(event.parameters));

  /// Issued when unhandled exception was revoked.
  Stream<ExceptionRevokedEvent> get onExceptionRevoked => _client.onEvent
      .where((Event event) => event.name == 'Runtime.exceptionRevoked')
      .map((Event event) =>
          new ExceptionRevokedEvent.fromJson(event.parameters));

  /// Issued when exception was thrown and unhandled.
  Stream<ExceptionThrownEvent> get onExceptionThrown => _client.onEvent
      .where((Event event) => event.name == 'Runtime.exceptionThrown')
      .map(
          (Event event) => new ExceptionThrownEvent.fromJson(event.parameters));

  /// Issued when new execution context is created.
  Stream<ExecutionContextDescription> get onExecutionContextCreated => _client
      .onEvent
      .where((Event event) => event.name == 'Runtime.executionContextCreated')
      .map((Event event) => new ExecutionContextDescription.fromJson(
          event.parameters['context']));

  /// Issued when execution context is destroyed.
  Stream<ExecutionContextId> get onExecutionContextDestroyed => _client.onEvent
      .where((Event event) => event.name == 'Runtime.executionContextDestroyed')
      .map((Event event) => new ExecutionContextId.fromJson(
          event.parameters['executionContextId']));

  /// Issued when all executionContexts were cleared in browser
  Stream get onExecutionContextsCleared => _client.onEvent
      .where((Event event) => event.name == 'Runtime.executionContextsCleared');

  /// Issued when object should be inspected (for example, as a result of inspect() command line API
  /// call).
  Stream<InspectRequestedEvent> get onInspectRequested => _client.onEvent
      .where((Event event) => event.name == 'Runtime.inspectRequested')
      .map((Event event) =>
          new InspectRequestedEvent.fromJson(event.parameters));

  /// Add handler to promise with given promise object id.
  /// [promiseObjectId] Identifier of the promise.
  /// [returnByValue] Whether the result is expected to be a JSON object that should be sent by value.
  /// [generatePreview] Whether preview should be generated for the result.
  Future<AwaitPromiseResult> awaitPromise(
    RemoteObjectId promiseObjectId, {
    bool returnByValue,
    bool generatePreview,
  }) async {
    Map parameters = {
      'promiseObjectId': promiseObjectId.toJson(),
    };
    if (returnByValue != null) {
      parameters['returnByValue'] = returnByValue;
    }
    if (generatePreview != null) {
      parameters['generatePreview'] = generatePreview;
    }
    Map result = await _client.send('Runtime.awaitPromise', parameters);
    return new AwaitPromiseResult.fromJson(result);
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
  Future<CallFunctionOnResult> callFunctionOn(
    String functionDeclaration, {
    RemoteObjectId objectId,
    List<CallArgument> arguments,
    bool silent,
    bool returnByValue,
    bool generatePreview,
    bool userGesture,
    bool awaitPromise,
    ExecutionContextId executionContextId,
    String objectGroup,
  }) async {
    Map parameters = {
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
    Map result = await _client.send('Runtime.callFunctionOn', parameters);
    return new CallFunctionOnResult.fromJson(result);
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
    ExecutionContextId executionContextId,
  }) async {
    Map parameters = {
      'expression': expression,
      'sourceURL': sourceURL,
      'persistScript': persistScript,
    };
    if (executionContextId != null) {
      parameters['executionContextId'] = executionContextId.toJson();
    }
    Map result = await _client.send('Runtime.compileScript', parameters);
    return new CompileScriptResult.fromJson(result);
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
  Future<EvaluateResult> evaluate(
    String expression, {
    String objectGroup,
    bool includeCommandLineAPI,
    bool silent,
    ExecutionContextId contextId,
    bool returnByValue,
    bool generatePreview,
    bool userGesture,
    bool awaitPromise,
    bool throwOnSideEffect,
    TimeDelta timeout,
  }) async {
    Map parameters = {
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
    Map result = await _client.send('Runtime.evaluate', parameters);
    return new EvaluateResult.fromJson(result);
  }

  /// Returns the isolate id.
  /// Returns: The isolate id.
  Future<String> getIsolateId() async {
    Map result = await _client.send('Runtime.getIsolateId');
    return result['id'];
  }

  /// Returns the JavaScript heap usage.
  /// It is the total usage of the corresponding isolate not scoped to a particular Runtime.
  Future<GetHeapUsageResult> getHeapUsage() async {
    Map result = await _client.send('Runtime.getHeapUsage');
    return new GetHeapUsageResult.fromJson(result);
  }

  /// Returns properties of a given object. Object group of the result is inherited from the target
  /// object.
  /// [objectId] Identifier of the object to return properties for.
  /// [ownProperties] If true, returns properties belonging only to the element itself, not to its prototype
  /// chain.
  /// [accessorPropertiesOnly] If true, returns accessor properties (with getter/setter) only; internal properties are not
  /// returned either.
  /// [generatePreview] Whether preview should be generated for the results.
  Future<GetPropertiesResult> getProperties(
    RemoteObjectId objectId, {
    bool ownProperties,
    bool accessorPropertiesOnly,
    bool generatePreview,
  }) async {
    Map parameters = {
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
    Map result = await _client.send('Runtime.getProperties', parameters);
    return new GetPropertiesResult.fromJson(result);
  }

  /// Returns all let, const and class variables from global scope.
  /// [executionContextId] Specifies in which execution context to lookup global scope variables.
  Future<List<String>> globalLexicalScopeNames({
    ExecutionContextId executionContextId,
  }) async {
    Map parameters = {};
    if (executionContextId != null) {
      parameters['executionContextId'] = executionContextId.toJson();
    }
    Map result =
        await _client.send('Runtime.globalLexicalScopeNames', parameters);
    return (result['names'] as List).map((e) => e as String).toList();
  }

  /// [prototypeObjectId] Identifier of the prototype to return objects for.
  /// [objectGroup] Symbolic group name that can be used to release the results.
  /// Returns: Array with objects.
  Future<RemoteObject> queryObjects(
    RemoteObjectId prototypeObjectId, {
    String objectGroup,
  }) async {
    Map parameters = {
      'prototypeObjectId': prototypeObjectId.toJson(),
    };
    if (objectGroup != null) {
      parameters['objectGroup'] = objectGroup;
    }
    Map result = await _client.send('Runtime.queryObjects', parameters);
    return new RemoteObject.fromJson(result['objects']);
  }

  /// Releases remote object with given id.
  /// [objectId] Identifier of the object to release.
  Future releaseObject(
    RemoteObjectId objectId,
  ) async {
    Map parameters = {
      'objectId': objectId.toJson(),
    };
    await _client.send('Runtime.releaseObject', parameters);
  }

  /// Releases all remote objects that belong to a given group.
  /// [objectGroup] Symbolic object group name.
  Future releaseObjectGroup(
    String objectGroup,
  ) async {
    Map parameters = {
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
  Future<RunScriptResult> runScript(
    ScriptId scriptId, {
    ExecutionContextId executionContextId,
    String objectGroup,
    bool silent,
    bool includeCommandLineAPI,
    bool returnByValue,
    bool generatePreview,
    bool awaitPromise,
  }) async {
    Map parameters = {
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
    Map result = await _client.send('Runtime.runScript', parameters);
    return new RunScriptResult.fromJson(result);
  }

  Future setCustomObjectFormatterEnabled(
    bool enabled,
  ) async {
    Map parameters = {
      'enabled': enabled,
    };
    await _client.send('Runtime.setCustomObjectFormatterEnabled', parameters);
  }

  /// Terminate current or next JavaScript execution.
  /// Will cancel the termination when the outer-most script execution ends.
  Future terminateExecution() async {
    await _client.send('Runtime.terminateExecution');
  }
}

class ConsoleAPICalledEvent {
  /// Type of the call.
  final String type;

  /// Call arguments.
  final List<RemoteObject> args;

  /// Identifier of the context where the call was made.
  final ExecutionContextId executionContextId;

  /// Call timestamp.
  final Timestamp timestamp;

  /// Stack trace captured when the call was made.
  final StackTrace stackTrace;

  /// Console context descriptor for calls on non-default console context (not console.*):
  /// 'anonymous#unique-logger-id' for call on unnamed context, 'name#unique-logger-id' for call
  /// on named context.
  final String context;

  ConsoleAPICalledEvent({
    @required this.type,
    @required this.args,
    @required this.executionContextId,
    @required this.timestamp,
    this.stackTrace,
    this.context,
  });

  factory ConsoleAPICalledEvent.fromJson(Map json) {
    return new ConsoleAPICalledEvent(
      type: json['type'],
      args: (json['args'] as List)
          .map((e) => new RemoteObject.fromJson(e))
          .toList(),
      executionContextId:
          new ExecutionContextId.fromJson(json['executionContextId']),
      timestamp: new Timestamp.fromJson(json['timestamp']),
      stackTrace: json.containsKey('stackTrace')
          ? new StackTrace.fromJson(json['stackTrace'])
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

  ExceptionRevokedEvent({
    @required this.reason,
    @required this.exceptionId,
  });

  factory ExceptionRevokedEvent.fromJson(Map json) {
    return new ExceptionRevokedEvent(
      reason: json['reason'],
      exceptionId: json['exceptionId'],
    );
  }
}

class ExceptionThrownEvent {
  /// Timestamp of the exception.
  final Timestamp timestamp;

  final ExceptionDetails exceptionDetails;

  ExceptionThrownEvent({
    @required this.timestamp,
    @required this.exceptionDetails,
  });

  factory ExceptionThrownEvent.fromJson(Map json) {
    return new ExceptionThrownEvent(
      timestamp: new Timestamp.fromJson(json['timestamp']),
      exceptionDetails: new ExceptionDetails.fromJson(json['exceptionDetails']),
    );
  }
}

class InspectRequestedEvent {
  final RemoteObject object;

  final Map hints;

  InspectRequestedEvent({
    @required this.object,
    @required this.hints,
  });

  factory InspectRequestedEvent.fromJson(Map json) {
    return new InspectRequestedEvent(
      object: new RemoteObject.fromJson(json['object']),
      hints: json['hints'],
    );
  }
}

class AwaitPromiseResult {
  /// Promise result. Will contain rejected value if promise was rejected.
  final RemoteObject result;

  /// Exception details if stack strace is available.
  final ExceptionDetails exceptionDetails;

  AwaitPromiseResult({
    @required this.result,
    this.exceptionDetails,
  });

  factory AwaitPromiseResult.fromJson(Map json) {
    return new AwaitPromiseResult(
      result: new RemoteObject.fromJson(json['result']),
      exceptionDetails: json.containsKey('exceptionDetails')
          ? new ExceptionDetails.fromJson(json['exceptionDetails'])
          : null,
    );
  }
}

class CallFunctionOnResult {
  /// Call result.
  final RemoteObject result;

  /// Exception details.
  final ExceptionDetails exceptionDetails;

  CallFunctionOnResult({
    @required this.result,
    this.exceptionDetails,
  });

  factory CallFunctionOnResult.fromJson(Map json) {
    return new CallFunctionOnResult(
      result: new RemoteObject.fromJson(json['result']),
      exceptionDetails: json.containsKey('exceptionDetails')
          ? new ExceptionDetails.fromJson(json['exceptionDetails'])
          : null,
    );
  }
}

class CompileScriptResult {
  /// Id of the script.
  final ScriptId scriptId;

  /// Exception details.
  final ExceptionDetails exceptionDetails;

  CompileScriptResult({
    this.scriptId,
    this.exceptionDetails,
  });

  factory CompileScriptResult.fromJson(Map json) {
    return new CompileScriptResult(
      scriptId: json.containsKey('scriptId')
          ? new ScriptId.fromJson(json['scriptId'])
          : null,
      exceptionDetails: json.containsKey('exceptionDetails')
          ? new ExceptionDetails.fromJson(json['exceptionDetails'])
          : null,
    );
  }
}

class EvaluateResult {
  /// Evaluation result.
  final RemoteObject result;

  /// Exception details.
  final ExceptionDetails exceptionDetails;

  EvaluateResult({
    @required this.result,
    this.exceptionDetails,
  });

  factory EvaluateResult.fromJson(Map json) {
    return new EvaluateResult(
      result: new RemoteObject.fromJson(json['result']),
      exceptionDetails: json.containsKey('exceptionDetails')
          ? new ExceptionDetails.fromJson(json['exceptionDetails'])
          : null,
    );
  }
}

class GetHeapUsageResult {
  /// Used heap size in bytes.
  final num usedSize;

  /// Allocated heap size in bytes.
  final num totalSize;

  GetHeapUsageResult({
    @required this.usedSize,
    @required this.totalSize,
  });

  factory GetHeapUsageResult.fromJson(Map json) {
    return new GetHeapUsageResult(
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

  /// Exception details.
  final ExceptionDetails exceptionDetails;

  GetPropertiesResult({
    @required this.result,
    this.internalProperties,
    this.exceptionDetails,
  });

  factory GetPropertiesResult.fromJson(Map json) {
    return new GetPropertiesResult(
      result: (json['result'] as List)
          .map((e) => new PropertyDescriptor.fromJson(e))
          .toList(),
      internalProperties: json.containsKey('internalProperties')
          ? (json['internalProperties'] as List)
              .map((e) => new InternalPropertyDescriptor.fromJson(e))
              .toList()
          : null,
      exceptionDetails: json.containsKey('exceptionDetails')
          ? new ExceptionDetails.fromJson(json['exceptionDetails'])
          : null,
    );
  }
}

class RunScriptResult {
  /// Run result.
  final RemoteObject result;

  /// Exception details.
  final ExceptionDetails exceptionDetails;

  RunScriptResult({
    @required this.result,
    this.exceptionDetails,
  });

  factory RunScriptResult.fromJson(Map json) {
    return new RunScriptResult(
      result: new RemoteObject.fromJson(json['result']),
      exceptionDetails: json.containsKey('exceptionDetails')
          ? new ExceptionDetails.fromJson(json['exceptionDetails'])
          : null,
    );
  }
}

/// Unique script identifier.
class ScriptId {
  final String value;

  ScriptId(this.value);

  factory ScriptId.fromJson(String value) => new ScriptId(value);

  String toJson() => value;

  @override
  bool operator ==(other) => other is ScriptId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Unique object identifier.
class RemoteObjectId {
  final String value;

  RemoteObjectId(this.value);

  factory RemoteObjectId.fromJson(String value) => new RemoteObjectId(value);

  String toJson() => value;

  @override
  bool operator ==(other) => other is RemoteObjectId && other.value == value;

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
      new UnserializableValue(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      other is UnserializableValue && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Mirror object referencing original JavaScript object.
class RemoteObject {
  /// Object type.
  final String type;

  /// Object subtype hint. Specified for `object` type values only.
  final String subtype;

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

  RemoteObject({
    @required this.type,
    this.subtype,
    this.className,
    this.value,
    this.unserializableValue,
    this.description,
    this.objectId,
    this.preview,
    this.customPreview,
  });

  factory RemoteObject.fromJson(Map json) {
    return new RemoteObject(
      type: json['type'],
      subtype: json.containsKey('subtype') ? json['subtype'] : null,
      className: json.containsKey('className') ? json['className'] : null,
      value: json.containsKey('value') ? json['value'] : null,
      unserializableValue: json.containsKey('unserializableValue')
          ? new UnserializableValue.fromJson(json['unserializableValue'])
          : null,
      description: json.containsKey('description') ? json['description'] : null,
      objectId: json.containsKey('objectId')
          ? new RemoteObjectId.fromJson(json['objectId'])
          : null,
      preview: json.containsKey('preview')
          ? new ObjectPreview.fromJson(json['preview'])
          : null,
      customPreview: json.containsKey('customPreview')
          ? new CustomPreview.fromJson(json['customPreview'])
          : null,
    );
  }

  Map toJson() {
    Map json = {
      'type': type,
    };
    if (subtype != null) {
      json['subtype'] = subtype;
    }
    if (className != null) {
      json['className'] = className;
    }
    if (value != null) {
      json['value'] = value.toJson();
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

class CustomPreview {
  final String header;

  final bool hasBody;

  final RemoteObjectId formatterObjectId;

  final RemoteObjectId bindRemoteObjectFunctionId;

  final RemoteObjectId configObjectId;

  CustomPreview({
    @required this.header,
    @required this.hasBody,
    @required this.formatterObjectId,
    @required this.bindRemoteObjectFunctionId,
    this.configObjectId,
  });

  factory CustomPreview.fromJson(Map json) {
    return new CustomPreview(
      header: json['header'],
      hasBody: json['hasBody'],
      formatterObjectId: new RemoteObjectId.fromJson(json['formatterObjectId']),
      bindRemoteObjectFunctionId:
          new RemoteObjectId.fromJson(json['bindRemoteObjectFunctionId']),
      configObjectId: json.containsKey('configObjectId')
          ? new RemoteObjectId.fromJson(json['configObjectId'])
          : null,
    );
  }

  Map toJson() {
    Map json = {
      'header': header,
      'hasBody': hasBody,
      'formatterObjectId': formatterObjectId.toJson(),
      'bindRemoteObjectFunctionId': bindRemoteObjectFunctionId.toJson(),
    };
    if (configObjectId != null) {
      json['configObjectId'] = configObjectId.toJson();
    }
    return json;
  }
}

/// Object containing abbreviated remote object value.
class ObjectPreview {
  /// Object type.
  final String type;

  /// Object subtype hint. Specified for `object` type values only.
  final String subtype;

  /// String representation of the object.
  final String description;

  /// True iff some of the properties or entries of the original object did not fit.
  final bool overflow;

  /// List of the properties.
  final List<PropertyPreview> properties;

  /// List of the entries. Specified for `map` and `set` subtype values only.
  final List<EntryPreview> entries;

  ObjectPreview({
    @required this.type,
    this.subtype,
    this.description,
    @required this.overflow,
    @required this.properties,
    this.entries,
  });

  factory ObjectPreview.fromJson(Map json) {
    return new ObjectPreview(
      type: json['type'],
      subtype: json.containsKey('subtype') ? json['subtype'] : null,
      description: json.containsKey('description') ? json['description'] : null,
      overflow: json['overflow'],
      properties: (json['properties'] as List)
          .map((e) => new PropertyPreview.fromJson(e))
          .toList(),
      entries: json.containsKey('entries')
          ? (json['entries'] as List)
              .map((e) => new EntryPreview.fromJson(e))
              .toList()
          : null,
    );
  }

  Map toJson() {
    Map json = {
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

class PropertyPreview {
  /// Property name.
  final String name;

  /// Object type. Accessor means that the property itself is an accessor property.
  final String type;

  /// User-friendly property value string.
  final String value;

  /// Nested value preview.
  final ObjectPreview valuePreview;

  /// Object subtype hint. Specified for `object` type values only.
  final String subtype;

  PropertyPreview({
    @required this.name,
    @required this.type,
    this.value,
    this.valuePreview,
    this.subtype,
  });

  factory PropertyPreview.fromJson(Map json) {
    return new PropertyPreview(
      name: json['name'],
      type: json['type'],
      value: json.containsKey('value') ? json['value'] : null,
      valuePreview: json.containsKey('valuePreview')
          ? new ObjectPreview.fromJson(json['valuePreview'])
          : null,
      subtype: json.containsKey('subtype') ? json['subtype'] : null,
    );
  }

  Map toJson() {
    Map json = {
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

class EntryPreview {
  /// Preview of the key. Specified for map-like collection entries.
  final ObjectPreview key;

  /// Preview of the value.
  final ObjectPreview value;

  EntryPreview({
    this.key,
    @required this.value,
  });

  factory EntryPreview.fromJson(Map json) {
    return new EntryPreview(
      key: json.containsKey('key')
          ? new ObjectPreview.fromJson(json['key'])
          : null,
      value: new ObjectPreview.fromJson(json['value']),
    );
  }

  Map toJson() {
    Map json = {
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

  PropertyDescriptor({
    @required this.name,
    this.value,
    this.writable,
    this.get,
    this.set,
    @required this.configurable,
    @required this.enumerable,
    this.wasThrown,
    this.isOwn,
    this.symbol,
  });

  factory PropertyDescriptor.fromJson(Map json) {
    return new PropertyDescriptor(
      name: json['name'],
      value: json.containsKey('value')
          ? new RemoteObject.fromJson(json['value'])
          : null,
      writable: json.containsKey('writable') ? json['writable'] : null,
      get: json.containsKey('get')
          ? new RemoteObject.fromJson(json['get'])
          : null,
      set: json.containsKey('set')
          ? new RemoteObject.fromJson(json['set'])
          : null,
      configurable: json['configurable'],
      enumerable: json['enumerable'],
      wasThrown: json.containsKey('wasThrown') ? json['wasThrown'] : null,
      isOwn: json.containsKey('isOwn') ? json['isOwn'] : null,
      symbol: json.containsKey('symbol')
          ? new RemoteObject.fromJson(json['symbol'])
          : null,
    );
  }

  Map toJson() {
    Map json = {
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

  InternalPropertyDescriptor({
    @required this.name,
    this.value,
  });

  factory InternalPropertyDescriptor.fromJson(Map json) {
    return new InternalPropertyDescriptor(
      name: json['name'],
      value: json.containsKey('value')
          ? new RemoteObject.fromJson(json['value'])
          : null,
    );
  }

  Map toJson() {
    Map json = {
      'name': name,
    };
    if (value != null) {
      json['value'] = value.toJson();
    }
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

  CallArgument({
    this.value,
    this.unserializableValue,
    this.objectId,
  });

  factory CallArgument.fromJson(Map json) {
    return new CallArgument(
      value: json.containsKey('value') ? json['value'] : null,
      unserializableValue: json.containsKey('unserializableValue')
          ? new UnserializableValue.fromJson(json['unserializableValue'])
          : null,
      objectId: json.containsKey('objectId')
          ? new RemoteObjectId.fromJson(json['objectId'])
          : null,
    );
  }

  Map toJson() {
    Map json = {};
    if (value != null) {
      json['value'] = value.toJson();
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

  factory ExecutionContextId.fromJson(int value) =>
      new ExecutionContextId(value);

  int toJson() => value;

  @override
  bool operator ==(other) =>
      other is ExecutionContextId && other.value == value;

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

  ExecutionContextDescription({
    @required this.id,
    @required this.origin,
    @required this.name,
    this.auxData,
  });

  factory ExecutionContextDescription.fromJson(Map json) {
    return new ExecutionContextDescription(
      id: new ExecutionContextId.fromJson(json['id']),
      origin: json['origin'],
      name: json['name'],
      auxData: json.containsKey('auxData') ? json['auxData'] : null,
    );
  }

  Map toJson() {
    Map json = {
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

  ExceptionDetails({
    @required this.exceptionId,
    @required this.text,
    @required this.lineNumber,
    @required this.columnNumber,
    this.scriptId,
    this.url,
    this.stackTrace,
    this.exception,
    this.executionContextId,
  });

  factory ExceptionDetails.fromJson(Map json) {
    return new ExceptionDetails(
      exceptionId: json['exceptionId'],
      text: json['text'],
      lineNumber: json['lineNumber'],
      columnNumber: json['columnNumber'],
      scriptId: json.containsKey('scriptId')
          ? new ScriptId.fromJson(json['scriptId'])
          : null,
      url: json.containsKey('url') ? json['url'] : null,
      stackTrace: json.containsKey('stackTrace')
          ? new StackTrace.fromJson(json['stackTrace'])
          : null,
      exception: json.containsKey('exception')
          ? new RemoteObject.fromJson(json['exception'])
          : null,
      executionContextId: json.containsKey('executionContextId')
          ? new ExecutionContextId.fromJson(json['executionContextId'])
          : null,
    );
  }

  Map toJson() {
    Map json = {
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

  factory Timestamp.fromJson(num value) => new Timestamp(value);

  num toJson() => value;

  @override
  bool operator ==(other) => other is Timestamp && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Number of milliseconds.
class TimeDelta {
  final num value;

  TimeDelta(this.value);

  factory TimeDelta.fromJson(num value) => new TimeDelta(value);

  num toJson() => value;

  @override
  bool operator ==(other) => other is TimeDelta && other.value == value;

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

  CallFrame({
    @required this.functionName,
    @required this.scriptId,
    @required this.url,
    @required this.lineNumber,
    @required this.columnNumber,
  });

  factory CallFrame.fromJson(Map json) {
    return new CallFrame(
      functionName: json['functionName'],
      scriptId: new ScriptId.fromJson(json['scriptId']),
      url: json['url'],
      lineNumber: json['lineNumber'],
      columnNumber: json['columnNumber'],
    );
  }

  Map toJson() {
    Map json = {
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

  StackTrace({
    this.description,
    @required this.callFrames,
    this.parent,
    this.parentId,
  });

  factory StackTrace.fromJson(Map json) {
    return new StackTrace(
      description: json.containsKey('description') ? json['description'] : null,
      callFrames: (json['callFrames'] as List)
          .map((e) => new CallFrame.fromJson(e))
          .toList(),
      parent: json.containsKey('parent')
          ? new StackTrace.fromJson(json['parent'])
          : null,
      parentId: json.containsKey('parentId')
          ? new StackTraceId.fromJson(json['parentId'])
          : null,
    );
  }

  Map toJson() {
    Map json = {
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

  factory UniqueDebuggerId.fromJson(String value) =>
      new UniqueDebuggerId(value);

  String toJson() => value;

  @override
  bool operator ==(other) => other is UniqueDebuggerId && other.value == value;

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

  StackTraceId({
    @required this.id,
    this.debuggerId,
  });

  factory StackTraceId.fromJson(Map json) {
    return new StackTraceId(
      id: json['id'],
      debuggerId: json.containsKey('debuggerId')
          ? new UniqueDebuggerId.fromJson(json['debuggerId'])
          : null,
    );
  }

  Map toJson() {
    Map json = {
      'id': id,
    };
    if (debuggerId != null) {
      json['debuggerId'] = debuggerId.toJson();
    }
    return json;
  }
}
