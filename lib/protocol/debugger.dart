import 'dart:async';
import '../src/connection.dart';
import 'debugger.dart' as debugger;
import 'runtime.dart' as runtime;

/// Debugger domain exposes JavaScript debugging capabilities. It allows setting and removing
/// breakpoints, stepping through execution, exploring stack traces, etc.
class DebuggerApi {
  final Client _client;

  DebuggerApi(this._client);

  /// Fired when breakpoint is resolved to an actual script and location.
  /// Deprecated in favor of `resolvedBreakpoints` in the `scriptParsed` event.
  Stream<BreakpointResolvedEvent> get onBreakpointResolved => _client.onEvent
      .where((event) => event.name == 'Debugger.breakpointResolved')
      .map((event) => BreakpointResolvedEvent.fromJson(event.parameters));

  /// Fired when the virtual machine stopped on breakpoint or exception or any other stop criteria.
  Stream<PausedEvent> get onPaused => _client.onEvent
      .where((event) => event.name == 'Debugger.paused')
      .map((event) => PausedEvent.fromJson(event.parameters));

  /// Fired when the virtual machine resumed execution.
  Stream<void> get onResumed =>
      _client.onEvent.where((event) => event.name == 'Debugger.resumed');

  /// Fired when virtual machine fails to parse the script.
  Stream<ScriptFailedToParseEvent> get onScriptFailedToParse => _client.onEvent
      .where((event) => event.name == 'Debugger.scriptFailedToParse')
      .map((event) => ScriptFailedToParseEvent.fromJson(event.parameters));

  /// Fired when virtual machine parses script. This event is also fired for all known and uncollected
  /// scripts upon enabling debugger.
  Stream<ScriptParsedEvent> get onScriptParsed => _client.onEvent
      .where((event) => event.name == 'Debugger.scriptParsed')
      .map((event) => ScriptParsedEvent.fromJson(event.parameters));

  /// Continues execution until specific location is reached.
  /// [location] Location to continue to.
  Future<void> continueToLocation(
    Location location, {
    @Enum(['any', 'current']) String? targetCallFrames,
  }) async {
    assert(
      targetCallFrames == null ||
          const ['any', 'current'].contains(targetCallFrames),
    );
    await _client.send('Debugger.continueToLocation', {
      'location': location,
      if (targetCallFrames != null) 'targetCallFrames': targetCallFrames,
    });
  }

  /// Disables debugger for given page.
  Future<void> disable() async {
    await _client.send('Debugger.disable');
  }

  /// Enables debugger for the given page. Clients should not assume that the debugging has been
  /// enabled until the result for this command is received.
  /// [maxScriptsCacheSize] The maximum size in bytes of collected scripts (not referenced by other heap objects)
  /// the debugger can hold. Puts no limit if parameter is omitted.
  /// Returns: Unique identifier of the debugger.
  Future<runtime.UniqueDebuggerId> enable({num? maxScriptsCacheSize}) async {
    var result = await _client.send('Debugger.enable', {
      if (maxScriptsCacheSize != null)
        'maxScriptsCacheSize': maxScriptsCacheSize,
    });
    return runtime.UniqueDebuggerId.fromJson(result['debuggerId'] as String);
  }

  /// Evaluates expression on a given call frame.
  /// [callFrameId] Call frame identifier to evaluate on.
  /// [expression] Expression to evaluate.
  /// [objectGroup] String object group name to put result into (allows rapid releasing resulting object handles
  /// using `releaseObjectGroup`).
  /// [includeCommandLineAPI] Specifies whether command line API should be available to the evaluated expression, defaults
  /// to false.
  /// [silent] In silent mode exceptions thrown during evaluation are not reported and do not pause
  /// execution. Overrides `setPauseOnException` state.
  /// [returnByValue] Whether the result is expected to be a JSON object that should be sent by value.
  /// [generatePreview] Whether preview should be generated for the result.
  /// [throwOnSideEffect] Whether to throw an exception if side effect cannot be ruled out during evaluation.
  /// [timeout] Terminate execution after timing out (number of milliseconds).
  Future<EvaluateOnCallFrameResult> evaluateOnCallFrame(
    CallFrameId callFrameId,
    String expression, {
    String? objectGroup,
    bool? includeCommandLineAPI,
    bool? silent,
    bool? returnByValue,
    bool? generatePreview,
    bool? throwOnSideEffect,
    runtime.TimeDelta? timeout,
  }) async {
    var result = await _client.send('Debugger.evaluateOnCallFrame', {
      'callFrameId': callFrameId,
      'expression': expression,
      if (objectGroup != null) 'objectGroup': objectGroup,
      if (includeCommandLineAPI != null)
        'includeCommandLineAPI': includeCommandLineAPI,
      if (silent != null) 'silent': silent,
      if (returnByValue != null) 'returnByValue': returnByValue,
      if (generatePreview != null) 'generatePreview': generatePreview,
      if (throwOnSideEffect != null) 'throwOnSideEffect': throwOnSideEffect,
      if (timeout != null) 'timeout': timeout,
    });
    return EvaluateOnCallFrameResult.fromJson(result);
  }

  /// Returns possible locations for breakpoint. scriptId in start and end range locations should be
  /// the same.
  /// [start] Start of range to search possible breakpoint locations in.
  /// [end] End of range to search possible breakpoint locations in (excluding). When not specified, end
  /// of scripts is used as end of range.
  /// [restrictToFunction] Only consider locations which are in the same (non-nested) function as start.
  /// Returns: List of the possible breakpoint locations.
  Future<List<BreakLocation>> getPossibleBreakpoints(
    Location start, {
    Location? end,
    bool? restrictToFunction,
  }) async {
    var result = await _client.send('Debugger.getPossibleBreakpoints', {
      'start': start,
      if (end != null) 'end': end,
      if (restrictToFunction != null) 'restrictToFunction': restrictToFunction,
    });
    return (result['locations'] as List)
        .map((e) => BreakLocation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns source for the script with given id.
  /// [scriptId] Id of the script to get source for.
  Future<GetScriptSourceResult> getScriptSource(
    runtime.ScriptId scriptId,
  ) async {
    var result = await _client.send('Debugger.getScriptSource', {
      'scriptId': scriptId,
    });
    return GetScriptSourceResult.fromJson(result);
  }

  /// [scriptId] Id of the script to disassemble
  Future<DisassembleWasmModuleResult> disassembleWasmModule(
    runtime.ScriptId scriptId,
  ) async {
    var result = await _client.send('Debugger.disassembleWasmModule', {
      'scriptId': scriptId,
    });
    return DisassembleWasmModuleResult.fromJson(result);
  }

  /// Disassemble the next chunk of lines for the module corresponding to the
  /// stream. If disassembly is complete, this API will invalidate the streamId
  /// and return an empty chunk. Any subsequent calls for the now invalid stream
  /// will return errors.
  /// Returns: The next chunk of disassembly.
  Future<WasmDisassemblyChunk> nextWasmDisassemblyChunk(String streamId) async {
    var result = await _client.send('Debugger.nextWasmDisassemblyChunk', {
      'streamId': streamId,
    });
    return WasmDisassemblyChunk.fromJson(
      result['chunk'] as Map<String, dynamic>,
    );
  }

  /// This command is deprecated. Use getScriptSource instead.
  /// [scriptId] Id of the Wasm script to get source for.
  /// Returns: Script source.
  @Deprecated('Use getScriptSource instead')
  Future<String> getWasmBytecode(runtime.ScriptId scriptId) async {
    var result = await _client.send('Debugger.getWasmBytecode', {
      'scriptId': scriptId,
    });
    return result['bytecode'] as String;
  }

  /// Returns stack trace with given `stackTraceId`.
  Future<runtime.StackTraceData> getStackTrace(
    runtime.StackTraceId stackTraceId,
  ) async {
    var result = await _client.send('Debugger.getStackTrace', {
      'stackTraceId': stackTraceId,
    });
    return runtime.StackTraceData.fromJson(
      result['stackTrace'] as Map<String, dynamic>,
    );
  }

  /// Stops on the next JavaScript statement.
  Future<void> pause() async {
    await _client.send('Debugger.pause');
  }

  /// [parentStackTraceId] Debugger will pause when async call with given stack trace is started.
  @Deprecated('This command is deprecated')
  Future<void> pauseOnAsyncCall(runtime.StackTraceId parentStackTraceId) async {
    await _client.send('Debugger.pauseOnAsyncCall', {
      'parentStackTraceId': parentStackTraceId,
    });
  }

  /// Removes JavaScript breakpoint.
  Future<void> removeBreakpoint(BreakpointId breakpointId) async {
    await _client.send('Debugger.removeBreakpoint', {
      'breakpointId': breakpointId,
    });
  }

  /// Restarts particular call frame from the beginning. The old, deprecated
  /// behavior of `restartFrame` is to stay paused and allow further CDP commands
  /// after a restart was scheduled. This can cause problems with restarting, so
  /// we now continue execution immediatly after it has been scheduled until we
  /// reach the beginning of the restarted frame.
  ///
  /// To stay back-wards compatible, `restartFrame` now expects a `mode`
  /// parameter to be present. If the `mode` parameter is missing, `restartFrame`
  /// errors out.
  ///
  /// The various return values are deprecated and `callFrames` is always empty.
  /// Use the call frames from the `Debugger#paused` events instead, that fires
  /// once V8 pauses at the beginning of the restarted function.
  /// [callFrameId] Call frame identifier to evaluate on.
  /// [mode] The `mode` parameter must be present and set to 'StepInto', otherwise
  /// `restartFrame` will error out.
  Future<RestartFrameResult> restartFrame(
    CallFrameId callFrameId, {
    @Enum(['StepInto']) String? mode,
  }) async {
    assert(mode == null || const ['StepInto'].contains(mode));
    var result = await _client.send('Debugger.restartFrame', {
      'callFrameId': callFrameId,
      if (mode != null) 'mode': mode,
    });
    return RestartFrameResult.fromJson(result);
  }

  /// Resumes JavaScript execution.
  /// [terminateOnResume] Set to true to terminate execution upon resuming execution. In contrast
  /// to Runtime.terminateExecution, this will allows to execute further
  /// JavaScript (i.e. via evaluation) until execution of the paused code
  /// is actually resumed, at which point termination is triggered.
  /// If execution is currently not paused, this parameter has no effect.
  Future<void> resume({bool? terminateOnResume}) async {
    await _client.send('Debugger.resume', {
      if (terminateOnResume != null) 'terminateOnResume': terminateOnResume,
    });
  }

  /// Searches for given string in script content.
  /// [scriptId] Id of the script to search in.
  /// [query] String to search for.
  /// [caseSensitive] If true, search is case sensitive.
  /// [isRegex] If true, treats string parameter as regex.
  /// Returns: List of search matches.
  Future<List<SearchMatch>> searchInContent(
    runtime.ScriptId scriptId,
    String query, {
    bool? caseSensitive,
    bool? isRegex,
  }) async {
    var result = await _client.send('Debugger.searchInContent', {
      'scriptId': scriptId,
      'query': query,
      if (caseSensitive != null) 'caseSensitive': caseSensitive,
      if (isRegex != null) 'isRegex': isRegex,
    });
    return (result['result'] as List)
        .map((e) => SearchMatch.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Enables or disables async call stacks tracking.
  /// [maxDepth] Maximum depth of async call stacks. Setting to `0` will effectively disable collecting async
  /// call stacks (default).
  Future<void> setAsyncCallStackDepth(int maxDepth) async {
    await _client.send('Debugger.setAsyncCallStackDepth', {
      'maxDepth': maxDepth,
    });
  }

  /// Replace previous blackbox execution contexts with passed ones. Forces backend to skip
  /// stepping/pausing in scripts in these execution contexts. VM will try to leave blackboxed script by
  /// performing 'step in' several times, finally resorting to 'step out' if unsuccessful.
  /// [uniqueIds] Array of execution context unique ids for the debugger to ignore.
  Future<void> setBlackboxExecutionContexts(List<String> uniqueIds) async {
    await _client.send('Debugger.setBlackboxExecutionContexts', {
      'uniqueIds': [...uniqueIds],
    });
  }

  /// Replace previous blackbox patterns with passed ones. Forces backend to skip stepping/pausing in
  /// scripts with url matching one of the patterns. VM will try to leave blackboxed script by
  /// performing 'step in' several times, finally resorting to 'step out' if unsuccessful.
  /// [patterns] Array of regexps that will be used to check script url for blackbox state.
  /// [skipAnonymous] If true, also ignore scripts with no source url.
  Future<void> setBlackboxPatterns(
    List<String> patterns, {
    bool? skipAnonymous,
  }) async {
    await _client.send('Debugger.setBlackboxPatterns', {
      'patterns': [...patterns],
      if (skipAnonymous != null) 'skipAnonymous': skipAnonymous,
    });
  }

  /// Makes backend skip steps in the script in blackboxed ranges. VM will try leave blacklisted
  /// scripts by performing 'step in' several times, finally resorting to 'step out' if unsuccessful.
  /// Positions array contains positions where blackbox state is changed. First interval isn't
  /// blackboxed. Array should be sorted.
  /// [scriptId] Id of the script.
  Future<void> setBlackboxedRanges(
    runtime.ScriptId scriptId,
    List<ScriptPosition> positions,
  ) async {
    await _client.send('Debugger.setBlackboxedRanges', {
      'scriptId': scriptId,
      'positions': [...positions],
    });
  }

  /// Sets JavaScript breakpoint at a given location.
  /// [location] Location to set breakpoint in.
  /// [condition] Expression to use as a breakpoint condition. When specified, debugger will only stop on the
  /// breakpoint if this expression evaluates to true.
  Future<SetBreakpointResult> setBreakpoint(
    Location location, {
    String? condition,
  }) async {
    var result = await _client.send('Debugger.setBreakpoint', {
      'location': location,
      if (condition != null) 'condition': condition,
    });
    return SetBreakpointResult.fromJson(result);
  }

  /// Sets instrumentation breakpoint.
  /// [instrumentation] Instrumentation name.
  /// Returns: Id of the created breakpoint for further reference.
  Future<BreakpointId> setInstrumentationBreakpoint(
    @Enum(['beforeScriptExecution', 'beforeScriptWithSourceMapExecution'])
    String instrumentation,
  ) async {
    assert(
      const [
        'beforeScriptExecution',
        'beforeScriptWithSourceMapExecution',
      ].contains(instrumentation),
    );
    var result = await _client.send('Debugger.setInstrumentationBreakpoint', {
      'instrumentation': instrumentation,
    });
    return BreakpointId.fromJson(result['breakpointId'] as String);
  }

  /// Sets JavaScript breakpoint at given location specified either by URL or URL regex. Once this
  /// command is issued, all existing parsed scripts will have breakpoints resolved and returned in
  /// `locations` property. Further matching script parsing will result in subsequent
  /// `breakpointResolved` events issued. This logical breakpoint will survive page reloads.
  /// [lineNumber] Line number to set breakpoint at.
  /// [url] URL of the resources to set breakpoint on.
  /// [urlRegex] Regex pattern for the URLs of the resources to set breakpoints on. Either `url` or
  /// `urlRegex` must be specified.
  /// [scriptHash] Script hash of the resources to set breakpoint on.
  /// [columnNumber] Offset in the line to set breakpoint at.
  /// [condition] Expression to use as a breakpoint condition. When specified, debugger will only stop on the
  /// breakpoint if this expression evaluates to true.
  Future<SetBreakpointByUrlResult> setBreakpointByUrl(
    int lineNumber, {
    String? url,
    String? urlRegex,
    String? scriptHash,
    int? columnNumber,
    String? condition,
  }) async {
    var result = await _client.send('Debugger.setBreakpointByUrl', {
      'lineNumber': lineNumber,
      if (url != null) 'url': url,
      if (urlRegex != null) 'urlRegex': urlRegex,
      if (scriptHash != null) 'scriptHash': scriptHash,
      if (columnNumber != null) 'columnNumber': columnNumber,
      if (condition != null) 'condition': condition,
    });
    return SetBreakpointByUrlResult.fromJson(result);
  }

  /// Sets JavaScript breakpoint before each call to the given function.
  /// If another function was created from the same source as a given one,
  /// calling it will also trigger the breakpoint.
  /// [objectId] Function object id.
  /// [condition] Expression to use as a breakpoint condition. When specified, debugger will
  /// stop on the breakpoint if this expression evaluates to true.
  /// Returns: Id of the created breakpoint for further reference.
  Future<BreakpointId> setBreakpointOnFunctionCall(
    runtime.RemoteObjectId objectId, {
    String? condition,
  }) async {
    var result = await _client.send('Debugger.setBreakpointOnFunctionCall', {
      'objectId': objectId,
      if (condition != null) 'condition': condition,
    });
    return BreakpointId.fromJson(result['breakpointId'] as String);
  }

  /// Activates / deactivates all breakpoints on the page.
  /// [active] New value for breakpoints active state.
  Future<void> setBreakpointsActive(bool active) async {
    await _client.send('Debugger.setBreakpointsActive', {'active': active});
  }

  /// Defines pause on exceptions state. Can be set to stop on all exceptions, uncaught exceptions,
  /// or caught exceptions, no exceptions. Initial pause on exceptions state is `none`.
  /// [state] Pause on exceptions mode.
  Future<void> setPauseOnExceptions(
    @Enum(['none', 'caught', 'uncaught', 'all']) String state,
  ) async {
    assert(const ['none', 'caught', 'uncaught', 'all'].contains(state));
    await _client.send('Debugger.setPauseOnExceptions', {'state': state});
  }

  /// Changes return value in top frame. Available only at return break position.
  /// [newValue] New return value.
  Future<void> setReturnValue(runtime.CallArgument newValue) async {
    await _client.send('Debugger.setReturnValue', {'newValue': newValue});
  }

  /// Edits JavaScript source live.
  ///
  /// In general, functions that are currently on the stack can not be edited with
  /// a single exception: If the edited function is the top-most stack frame and
  /// that is the only activation of that function on the stack. In this case
  /// the live edit will be successful and a `Debugger.restartFrame` for the
  /// top-most function is automatically triggered.
  /// [scriptId] Id of the script to edit.
  /// [scriptSource] New content of the script.
  /// [dryRun] If true the change will not actually be applied. Dry run may be used to get result
  /// description without actually modifying the code.
  /// [allowTopFrameEditing] If true, then `scriptSource` is allowed to change the function on top of the stack
  /// as long as the top-most stack frame is the only activation of that function.
  Future<SetScriptSourceResult> setScriptSource(
    runtime.ScriptId scriptId,
    String scriptSource, {
    bool? dryRun,
    bool? allowTopFrameEditing,
  }) async {
    var result = await _client.send('Debugger.setScriptSource', {
      'scriptId': scriptId,
      'scriptSource': scriptSource,
      if (dryRun != null) 'dryRun': dryRun,
      if (allowTopFrameEditing != null)
        'allowTopFrameEditing': allowTopFrameEditing,
    });
    return SetScriptSourceResult.fromJson(result);
  }

  /// Makes page not interrupt on any pauses (breakpoint, exception, dom exception etc).
  /// [skip] New value for skip pauses state.
  Future<void> setSkipAllPauses(bool skip) async {
    await _client.send('Debugger.setSkipAllPauses', {'skip': skip});
  }

  /// Changes value of variable in a callframe. Object-based scopes are not supported and must be
  /// mutated manually.
  /// [scopeNumber] 0-based number of scope as was listed in scope chain. Only 'local', 'closure' and 'catch'
  /// scope types are allowed. Other scopes could be manipulated manually.
  /// [variableName] Variable name.
  /// [newValue] New variable value.
  /// [callFrameId] Id of callframe that holds variable.
  Future<void> setVariableValue(
    int scopeNumber,
    String variableName,
    runtime.CallArgument newValue,
    CallFrameId callFrameId,
  ) async {
    await _client.send('Debugger.setVariableValue', {
      'scopeNumber': scopeNumber,
      'variableName': variableName,
      'newValue': newValue,
      'callFrameId': callFrameId,
    });
  }

  /// Steps into the function call.
  /// [breakOnAsyncCall] Debugger will pause on the execution of the first async task which was scheduled
  /// before next pause.
  /// [skipList] The skipList specifies location ranges that should be skipped on step into.
  Future<void> stepInto({
    bool? breakOnAsyncCall,
    List<LocationRange>? skipList,
  }) async {
    await _client.send('Debugger.stepInto', {
      if (breakOnAsyncCall != null) 'breakOnAsyncCall': breakOnAsyncCall,
      if (skipList != null) 'skipList': [...skipList],
    });
  }

  /// Steps out of the function call.
  Future<void> stepOut() async {
    await _client.send('Debugger.stepOut');
  }

  /// Steps over the statement.
  /// [skipList] The skipList specifies location ranges that should be skipped on step over.
  Future<void> stepOver({List<LocationRange>? skipList}) async {
    await _client.send('Debugger.stepOver', {
      if (skipList != null) 'skipList': [...skipList],
    });
  }
}

class BreakpointResolvedEvent {
  /// Breakpoint unique identifier.
  final BreakpointId breakpointId;

  /// Actual breakpoint location.
  final Location location;

  BreakpointResolvedEvent({required this.breakpointId, required this.location});

  factory BreakpointResolvedEvent.fromJson(Map<String, dynamic> json) {
    return BreakpointResolvedEvent(
      breakpointId: BreakpointId.fromJson(json['breakpointId'] as String),
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
    );
  }
}

class PausedEvent {
  /// Call stack the virtual machine stopped on.
  final List<CallFrame> callFrames;

  /// Pause reason.
  final PausedEventReason reason;

  /// Object containing break-specific auxiliary properties.
  final Map<String, dynamic>? data;

  /// Hit breakpoints IDs
  final List<String>? hitBreakpoints;

  /// Async stack trace, if any.
  final runtime.StackTraceData? asyncStackTrace;

  /// Async stack trace, if any.
  final runtime.StackTraceId? asyncStackTraceId;

  PausedEvent({
    required this.callFrames,
    required this.reason,
    this.data,
    this.hitBreakpoints,
    this.asyncStackTrace,
    this.asyncStackTraceId,
  });

  factory PausedEvent.fromJson(Map<String, dynamic> json) {
    return PausedEvent(
      callFrames: (json['callFrames'] as List)
          .map((e) => CallFrame.fromJson(e as Map<String, dynamic>))
          .toList(),
      reason: PausedEventReason.fromJson(json['reason'] as String),
      data: json.containsKey('data')
          ? json['data'] as Map<String, dynamic>
          : null,
      hitBreakpoints: json.containsKey('hitBreakpoints')
          ? (json['hitBreakpoints'] as List).map((e) => e as String).toList()
          : null,
      asyncStackTrace: json.containsKey('asyncStackTrace')
          ? runtime.StackTraceData.fromJson(
              json['asyncStackTrace'] as Map<String, dynamic>,
            )
          : null,
      asyncStackTraceId: json.containsKey('asyncStackTraceId')
          ? runtime.StackTraceId.fromJson(
              json['asyncStackTraceId'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class ScriptFailedToParseEvent {
  /// Identifier of the script parsed.
  final runtime.ScriptId scriptId;

  /// URL or name of the script parsed (if any).
  final String url;

  /// Line offset of the script within the resource with given URL (for script tags).
  final int startLine;

  /// Column offset of the script within the resource with given URL.
  final int startColumn;

  /// Last line of the script.
  final int endLine;

  /// Length of the last line of the script.
  final int endColumn;

  /// Specifies script creation context.
  final runtime.ExecutionContextId executionContextId;

  /// Content hash of the script, SHA-256.
  final String hash;

  /// For Wasm modules, the content of the `build_id` custom section. For JavaScript the `debugId` magic comment.
  final String buildId;

  /// Embedder-specific auxiliary data likely matching {isDefault: boolean, type: 'default'|'isolated'|'worker', frameId: string}
  final Map<String, dynamic>? executionContextAuxData;

  /// URL of source map associated with script (if any).
  final String? sourceMapURL;

  /// True, if this script has sourceURL.
  final bool? hasSourceURL;

  /// True, if this script is ES6 module.
  final bool? isModule;

  /// This script length.
  final int? length;

  /// JavaScript top stack frame of where the script parsed event was triggered if available.
  final runtime.StackTraceData? stackTrace;

  /// If the scriptLanguage is WebAssembly, the code section offset in the module.
  final int? codeOffset;

  /// The language of the script.
  final debugger.ScriptLanguage? scriptLanguage;

  /// The name the embedder supplied for this script.
  final String? embedderName;

  ScriptFailedToParseEvent({
    required this.scriptId,
    required this.url,
    required this.startLine,
    required this.startColumn,
    required this.endLine,
    required this.endColumn,
    required this.executionContextId,
    required this.hash,
    required this.buildId,
    this.executionContextAuxData,
    this.sourceMapURL,
    this.hasSourceURL,
    this.isModule,
    this.length,
    this.stackTrace,
    this.codeOffset,
    this.scriptLanguage,
    this.embedderName,
  });

  factory ScriptFailedToParseEvent.fromJson(Map<String, dynamic> json) {
    return ScriptFailedToParseEvent(
      scriptId: runtime.ScriptId.fromJson(json['scriptId'] as String),
      url: json['url'] as String,
      startLine: json['startLine'] as int,
      startColumn: json['startColumn'] as int,
      endLine: json['endLine'] as int,
      endColumn: json['endColumn'] as int,
      executionContextId: runtime.ExecutionContextId.fromJson(
        json['executionContextId'] as int,
      ),
      hash: json['hash'] as String,
      buildId: json['buildId'] as String,
      executionContextAuxData: json.containsKey('executionContextAuxData')
          ? json['executionContextAuxData'] as Map<String, dynamic>
          : null,
      sourceMapURL: json.containsKey('sourceMapURL')
          ? json['sourceMapURL'] as String
          : null,
      hasSourceURL: json.containsKey('hasSourceURL')
          ? json['hasSourceURL'] as bool
          : null,
      isModule: json.containsKey('isModule') ? json['isModule'] as bool : null,
      length: json.containsKey('length') ? json['length'] as int : null,
      stackTrace: json.containsKey('stackTrace')
          ? runtime.StackTraceData.fromJson(
              json['stackTrace'] as Map<String, dynamic>,
            )
          : null,
      codeOffset: json.containsKey('codeOffset')
          ? json['codeOffset'] as int
          : null,
      scriptLanguage: json.containsKey('scriptLanguage')
          ? debugger.ScriptLanguage.fromJson(json['scriptLanguage'] as String)
          : null,
      embedderName: json.containsKey('embedderName')
          ? json['embedderName'] as String
          : null,
    );
  }
}

class ScriptParsedEvent {
  /// Identifier of the script parsed.
  final runtime.ScriptId scriptId;

  /// URL or name of the script parsed (if any).
  final String url;

  /// Line offset of the script within the resource with given URL (for script tags).
  final int startLine;

  /// Column offset of the script within the resource with given URL.
  final int startColumn;

  /// Last line of the script.
  final int endLine;

  /// Length of the last line of the script.
  final int endColumn;

  /// Specifies script creation context.
  final runtime.ExecutionContextId executionContextId;

  /// Content hash of the script, SHA-256.
  final String hash;

  /// For Wasm modules, the content of the `build_id` custom section. For JavaScript the `debugId` magic comment.
  final String buildId;

  /// Embedder-specific auxiliary data likely matching {isDefault: boolean, type: 'default'|'isolated'|'worker', frameId: string}
  final Map<String, dynamic>? executionContextAuxData;

  /// True, if this script is generated as a result of the live edit operation.
  final bool? isLiveEdit;

  /// URL of source map associated with script (if any).
  final String? sourceMapURL;

  /// True, if this script has sourceURL.
  final bool? hasSourceURL;

  /// True, if this script is ES6 module.
  final bool? isModule;

  /// This script length.
  final int? length;

  /// JavaScript top stack frame of where the script parsed event was triggered if available.
  final runtime.StackTraceData? stackTrace;

  /// If the scriptLanguage is WebAssembly, the code section offset in the module.
  final int? codeOffset;

  /// The language of the script.
  final debugger.ScriptLanguage? scriptLanguage;

  /// If the scriptLanguage is WebAssembly, the source of debug symbols for the module.
  final List<debugger.DebugSymbols>? debugSymbols;

  /// The name the embedder supplied for this script.
  final String? embedderName;

  /// The list of set breakpoints in this script if calls to `setBreakpointByUrl`
  /// matches this script's URL or hash. Clients that use this list can ignore the
  /// `breakpointResolved` event. They are equivalent.
  final List<ResolvedBreakpoint>? resolvedBreakpoints;

  ScriptParsedEvent({
    required this.scriptId,
    required this.url,
    required this.startLine,
    required this.startColumn,
    required this.endLine,
    required this.endColumn,
    required this.executionContextId,
    required this.hash,
    required this.buildId,
    this.executionContextAuxData,
    this.isLiveEdit,
    this.sourceMapURL,
    this.hasSourceURL,
    this.isModule,
    this.length,
    this.stackTrace,
    this.codeOffset,
    this.scriptLanguage,
    this.debugSymbols,
    this.embedderName,
    this.resolvedBreakpoints,
  });

  factory ScriptParsedEvent.fromJson(Map<String, dynamic> json) {
    return ScriptParsedEvent(
      scriptId: runtime.ScriptId.fromJson(json['scriptId'] as String),
      url: json['url'] as String,
      startLine: json['startLine'] as int,
      startColumn: json['startColumn'] as int,
      endLine: json['endLine'] as int,
      endColumn: json['endColumn'] as int,
      executionContextId: runtime.ExecutionContextId.fromJson(
        json['executionContextId'] as int,
      ),
      hash: json['hash'] as String,
      buildId: json['buildId'] as String,
      executionContextAuxData: json.containsKey('executionContextAuxData')
          ? json['executionContextAuxData'] as Map<String, dynamic>
          : null,
      isLiveEdit: json.containsKey('isLiveEdit')
          ? json['isLiveEdit'] as bool
          : null,
      sourceMapURL: json.containsKey('sourceMapURL')
          ? json['sourceMapURL'] as String
          : null,
      hasSourceURL: json.containsKey('hasSourceURL')
          ? json['hasSourceURL'] as bool
          : null,
      isModule: json.containsKey('isModule') ? json['isModule'] as bool : null,
      length: json.containsKey('length') ? json['length'] as int : null,
      stackTrace: json.containsKey('stackTrace')
          ? runtime.StackTraceData.fromJson(
              json['stackTrace'] as Map<String, dynamic>,
            )
          : null,
      codeOffset: json.containsKey('codeOffset')
          ? json['codeOffset'] as int
          : null,
      scriptLanguage: json.containsKey('scriptLanguage')
          ? debugger.ScriptLanguage.fromJson(json['scriptLanguage'] as String)
          : null,
      debugSymbols: json.containsKey('debugSymbols')
          ? (json['debugSymbols'] as List)
                .map(
                  (e) =>
                      debugger.DebugSymbols.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      embedderName: json.containsKey('embedderName')
          ? json['embedderName'] as String
          : null,
      resolvedBreakpoints: json.containsKey('resolvedBreakpoints')
          ? (json['resolvedBreakpoints'] as List)
                .map(
                  (e) => ResolvedBreakpoint.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }
}

class EvaluateOnCallFrameResult {
  /// Object wrapper for the evaluation result.
  final runtime.RemoteObject result;

  /// Exception details.
  final runtime.ExceptionDetails? exceptionDetails;

  EvaluateOnCallFrameResult({required this.result, this.exceptionDetails});

  factory EvaluateOnCallFrameResult.fromJson(Map<String, dynamic> json) {
    return EvaluateOnCallFrameResult(
      result: runtime.RemoteObject.fromJson(
        json['result'] as Map<String, dynamic>,
      ),
      exceptionDetails: json.containsKey('exceptionDetails')
          ? runtime.ExceptionDetails.fromJson(
              json['exceptionDetails'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class GetScriptSourceResult {
  /// Script source (empty in case of Wasm bytecode).
  final String scriptSource;

  /// Wasm bytecode.
  final String? bytecode;

  GetScriptSourceResult({required this.scriptSource, this.bytecode});

  factory GetScriptSourceResult.fromJson(Map<String, dynamic> json) {
    return GetScriptSourceResult(
      scriptSource: json['scriptSource'] as String,
      bytecode: json.containsKey('bytecode')
          ? json['bytecode'] as String
          : null,
    );
  }
}

class DisassembleWasmModuleResult {
  /// For large modules, return a stream from which additional chunks of
  /// disassembly can be read successively.
  final String? streamId;

  /// The total number of lines in the disassembly text.
  final int totalNumberOfLines;

  /// The offsets of all function bodies, in the format [start1, end1,
  /// start2, end2, ...] where all ends are exclusive.
  final List<int> functionBodyOffsets;

  /// The first chunk of disassembly.
  final WasmDisassemblyChunk chunk;

  DisassembleWasmModuleResult({
    this.streamId,
    required this.totalNumberOfLines,
    required this.functionBodyOffsets,
    required this.chunk,
  });

  factory DisassembleWasmModuleResult.fromJson(Map<String, dynamic> json) {
    return DisassembleWasmModuleResult(
      streamId: json.containsKey('streamId')
          ? json['streamId'] as String
          : null,
      totalNumberOfLines: json['totalNumberOfLines'] as int,
      functionBodyOffsets: (json['functionBodyOffsets'] as List)
          .map((e) => e as int)
          .toList(),
      chunk: WasmDisassemblyChunk.fromJson(
        json['chunk'] as Map<String, dynamic>,
      ),
    );
  }
}

class RestartFrameResult {
  RestartFrameResult();

  factory RestartFrameResult.fromJson(Map<String, dynamic> json) {
    return RestartFrameResult();
  }
}

class SetBreakpointResult {
  /// Id of the created breakpoint for further reference.
  final BreakpointId breakpointId;

  /// Location this breakpoint resolved into.
  final Location actualLocation;

  SetBreakpointResult({
    required this.breakpointId,
    required this.actualLocation,
  });

  factory SetBreakpointResult.fromJson(Map<String, dynamic> json) {
    return SetBreakpointResult(
      breakpointId: BreakpointId.fromJson(json['breakpointId'] as String),
      actualLocation: Location.fromJson(
        json['actualLocation'] as Map<String, dynamic>,
      ),
    );
  }
}

class SetBreakpointByUrlResult {
  /// Id of the created breakpoint for further reference.
  final BreakpointId breakpointId;

  /// List of the locations this breakpoint resolved into upon addition.
  final List<Location> locations;

  SetBreakpointByUrlResult({
    required this.breakpointId,
    required this.locations,
  });

  factory SetBreakpointByUrlResult.fromJson(Map<String, dynamic> json) {
    return SetBreakpointByUrlResult(
      breakpointId: BreakpointId.fromJson(json['breakpointId'] as String),
      locations: (json['locations'] as List)
          .map((e) => Location.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SetScriptSourceResult {
  /// Whether the operation was successful or not. Only `Ok` denotes a
  /// successful live edit while the other enum variants denote why
  /// the live edit failed.
  final SetScriptSourceResultStatus status;

  /// Exception details if any. Only present when `status` is `CompileError`.
  final runtime.ExceptionDetails? exceptionDetails;

  SetScriptSourceResult({required this.status, this.exceptionDetails});

  factory SetScriptSourceResult.fromJson(Map<String, dynamic> json) {
    return SetScriptSourceResult(
      status: SetScriptSourceResultStatus.fromJson(json['status'] as String),
      exceptionDetails: json.containsKey('exceptionDetails')
          ? runtime.ExceptionDetails.fromJson(
              json['exceptionDetails'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

/// Breakpoint identifier.
extension type BreakpointId(String value) {
  factory BreakpointId.fromJson(String value) => BreakpointId(value);

  String toJson() => value;
}

/// Call frame identifier.
extension type CallFrameId(String value) {
  factory CallFrameId.fromJson(String value) => CallFrameId(value);

  String toJson() => value;
}

/// Location in the source code.
class Location {
  /// Script identifier as reported in the `Debugger.scriptParsed`.
  final runtime.ScriptId scriptId;

  /// Line number in the script (0-based).
  final int lineNumber;

  /// Column number in the script (0-based).
  final int? columnNumber;

  Location({
    required this.scriptId,
    required this.lineNumber,
    this.columnNumber,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      scriptId: runtime.ScriptId.fromJson(json['scriptId'] as String),
      lineNumber: json['lineNumber'] as int,
      columnNumber: json.containsKey('columnNumber')
          ? json['columnNumber'] as int
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scriptId': scriptId.toJson(),
      'lineNumber': lineNumber,
      if (columnNumber != null) 'columnNumber': columnNumber,
    };
  }
}

/// Location in the source code.
class ScriptPosition {
  final int lineNumber;

  final int columnNumber;

  ScriptPosition({required this.lineNumber, required this.columnNumber});

  factory ScriptPosition.fromJson(Map<String, dynamic> json) {
    return ScriptPosition(
      lineNumber: json['lineNumber'] as int,
      columnNumber: json['columnNumber'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'lineNumber': lineNumber, 'columnNumber': columnNumber};
  }
}

/// Location range within one script.
class LocationRange {
  final runtime.ScriptId scriptId;

  final ScriptPosition start;

  final ScriptPosition end;

  LocationRange({
    required this.scriptId,
    required this.start,
    required this.end,
  });

  factory LocationRange.fromJson(Map<String, dynamic> json) {
    return LocationRange(
      scriptId: runtime.ScriptId.fromJson(json['scriptId'] as String),
      start: ScriptPosition.fromJson(json['start'] as Map<String, dynamic>),
      end: ScriptPosition.fromJson(json['end'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scriptId': scriptId.toJson(),
      'start': start.toJson(),
      'end': end.toJson(),
    };
  }
}

/// JavaScript call frame. Array of call frames form the call stack.
class CallFrame {
  /// Call frame identifier. This identifier is only valid while the virtual machine is paused.
  final CallFrameId callFrameId;

  /// Name of the JavaScript function called on this call frame.
  final String functionName;

  /// Location in the source code.
  final Location? functionLocation;

  /// Location in the source code.
  final Location location;

  /// Scope chain for this call frame.
  final List<Scope> scopeChain;

  /// `this` object for this call frame.
  final runtime.RemoteObject this$;

  /// The value being returned, if the function is at return point.
  final runtime.RemoteObject? returnValue;

  /// Valid only while the VM is paused and indicates whether this frame
  /// can be restarted or not. Note that a `true` value here does not
  /// guarantee that Debugger#restartFrame with this CallFrameId will be
  /// successful, but it is very likely.
  final bool? canBeRestarted;

  CallFrame({
    required this.callFrameId,
    required this.functionName,
    this.functionLocation,
    required this.location,
    required this.scopeChain,
    required this.this$,
    this.returnValue,
    this.canBeRestarted,
  });

  factory CallFrame.fromJson(Map<String, dynamic> json) {
    return CallFrame(
      callFrameId: CallFrameId.fromJson(json['callFrameId'] as String),
      functionName: json['functionName'] as String,
      functionLocation: json.containsKey('functionLocation')
          ? Location.fromJson(json['functionLocation'] as Map<String, dynamic>)
          : null,
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      scopeChain: (json['scopeChain'] as List)
          .map((e) => Scope.fromJson(e as Map<String, dynamic>))
          .toList(),
      this$: runtime.RemoteObject.fromJson(
        json['this'] as Map<String, dynamic>,
      ),
      returnValue: json.containsKey('returnValue')
          ? runtime.RemoteObject.fromJson(
              json['returnValue'] as Map<String, dynamic>,
            )
          : null,
      canBeRestarted: json.containsKey('canBeRestarted')
          ? json['canBeRestarted'] as bool
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'callFrameId': callFrameId.toJson(),
      'functionName': functionName,
      'location': location.toJson(),
      'scopeChain': scopeChain.map((e) => e.toJson()).toList(),
      'this': this$.toJson(),
      if (functionLocation != null)
        'functionLocation': functionLocation!.toJson(),
      if (returnValue != null) 'returnValue': returnValue!.toJson(),
      if (canBeRestarted != null) 'canBeRestarted': canBeRestarted,
    };
  }
}

/// Scope description.
class Scope {
  /// Scope type.
  final ScopeType type;

  /// Object representing the scope. For `global` and `with` scopes it represents the actual
  /// object; for the rest of the scopes, it is artificial transient object enumerating scope
  /// variables as its properties.
  final runtime.RemoteObject object;

  final String? name;

  /// Location in the source code where scope starts
  final Location? startLocation;

  /// Location in the source code where scope ends
  final Location? endLocation;

  Scope({
    required this.type,
    required this.object,
    this.name,
    this.startLocation,
    this.endLocation,
  });

  factory Scope.fromJson(Map<String, dynamic> json) {
    return Scope(
      type: ScopeType.fromJson(json['type'] as String),
      object: runtime.RemoteObject.fromJson(
        json['object'] as Map<String, dynamic>,
      ),
      name: json.containsKey('name') ? json['name'] as String : null,
      startLocation: json.containsKey('startLocation')
          ? Location.fromJson(json['startLocation'] as Map<String, dynamic>)
          : null,
      endLocation: json.containsKey('endLocation')
          ? Location.fromJson(json['endLocation'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'object': object.toJson(),
      if (name != null) 'name': name,
      if (startLocation != null) 'startLocation': startLocation!.toJson(),
      if (endLocation != null) 'endLocation': endLocation!.toJson(),
    };
  }
}

enum ScopeType {
  global('global'),
  local('local'),
  with$('with'),
  closure('closure'),
  catch$('catch'),
  block('block'),
  script('script'),
  eval('eval'),
  module('module'),
  wasmExpressionStack('wasm-expression-stack');

  final String value;

  const ScopeType(this.value);

  factory ScopeType.fromJson(String value) =>
      ScopeType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Search match for resource.
class SearchMatch {
  /// Line number in resource content.
  final num lineNumber;

  /// Line with match content.
  final String lineContent;

  SearchMatch({required this.lineNumber, required this.lineContent});

  factory SearchMatch.fromJson(Map<String, dynamic> json) {
    return SearchMatch(
      lineNumber: json['lineNumber'] as num,
      lineContent: json['lineContent'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'lineNumber': lineNumber, 'lineContent': lineContent};
  }
}

class BreakLocation {
  /// Script identifier as reported in the `Debugger.scriptParsed`.
  final runtime.ScriptId scriptId;

  /// Line number in the script (0-based).
  final int lineNumber;

  /// Column number in the script (0-based).
  final int? columnNumber;

  final BreakLocationType? type;

  BreakLocation({
    required this.scriptId,
    required this.lineNumber,
    this.columnNumber,
    this.type,
  });

  factory BreakLocation.fromJson(Map<String, dynamic> json) {
    return BreakLocation(
      scriptId: runtime.ScriptId.fromJson(json['scriptId'] as String),
      lineNumber: json['lineNumber'] as int,
      columnNumber: json.containsKey('columnNumber')
          ? json['columnNumber'] as int
          : null,
      type: json.containsKey('type')
          ? BreakLocationType.fromJson(json['type'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scriptId': scriptId.toJson(),
      'lineNumber': lineNumber,
      if (columnNumber != null) 'columnNumber': columnNumber,
      if (type != null) 'type': type,
    };
  }
}

enum BreakLocationType {
  debuggerStatement('debuggerStatement'),
  call('call'),
  return$('return');

  final String value;

  const BreakLocationType(this.value);

  factory BreakLocationType.fromJson(String value) =>
      BreakLocationType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class WasmDisassemblyChunk {
  /// The next chunk of disassembled lines.
  final List<String> lines;

  /// The bytecode offsets describing the start of each line.
  final List<int> bytecodeOffsets;

  WasmDisassemblyChunk({required this.lines, required this.bytecodeOffsets});

  factory WasmDisassemblyChunk.fromJson(Map<String, dynamic> json) {
    return WasmDisassemblyChunk(
      lines: (json['lines'] as List).map((e) => e as String).toList(),
      bytecodeOffsets: (json['bytecodeOffsets'] as List)
          .map((e) => e as int)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lines': [...lines],
      'bytecodeOffsets': [...bytecodeOffsets],
    };
  }
}

/// Enum of possible script languages.
enum ScriptLanguage {
  javaScript('JavaScript'),
  webAssembly('WebAssembly');

  final String value;

  const ScriptLanguage(this.value);

  factory ScriptLanguage.fromJson(String value) =>
      ScriptLanguage.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Debug symbols available for a wasm script.
class DebugSymbols {
  /// Type of the debug symbols.
  final DebugSymbolsType type;

  /// URL of the external symbol source.
  final String? externalURL;

  DebugSymbols({required this.type, this.externalURL});

  factory DebugSymbols.fromJson(Map<String, dynamic> json) {
    return DebugSymbols(
      type: DebugSymbolsType.fromJson(json['type'] as String),
      externalURL: json.containsKey('externalURL')
          ? json['externalURL'] as String
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, if (externalURL != null) 'externalURL': externalURL};
  }
}

enum DebugSymbolsType {
  sourceMap('SourceMap'),
  embeddedDwarf('EmbeddedDWARF'),
  externalDwarf('ExternalDWARF');

  final String value;

  const DebugSymbolsType(this.value);

  factory DebugSymbolsType.fromJson(String value) =>
      DebugSymbolsType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class ResolvedBreakpoint {
  /// Breakpoint unique identifier.
  final BreakpointId breakpointId;

  /// Actual breakpoint location.
  final Location location;

  ResolvedBreakpoint({required this.breakpointId, required this.location});

  factory ResolvedBreakpoint.fromJson(Map<String, dynamic> json) {
    return ResolvedBreakpoint(
      breakpointId: BreakpointId.fromJson(json['breakpointId'] as String),
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breakpointId': breakpointId.toJson(),
      'location': location.toJson(),
    };
  }
}

enum SetScriptSourceResultStatus {
  ok('Ok'),
  compileError('CompileError'),
  blockedByActiveGenerator('BlockedByActiveGenerator'),
  blockedByActiveFunction('BlockedByActiveFunction'),
  blockedByTopLevelEsModuleChange('BlockedByTopLevelEsModuleChange');

  final String value;

  const SetScriptSourceResultStatus(this.value);

  factory SetScriptSourceResultStatus.fromJson(String value) =>
      SetScriptSourceResultStatus.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum PausedEventReason {
  ambiguous('ambiguous'),
  assert$('assert'),
  cspViolation('CSPViolation'),
  debugCommand('debugCommand'),
  dom('DOM'),
  eventListener('EventListener'),
  exception('exception'),
  instrumentation('instrumentation'),
  oom('OOM'),
  other('other'),
  promiseRejection('promiseRejection'),
  xhr('XHR'),
  step('step');

  final String value;

  const PausedEventReason(this.value);

  factory PausedEventReason.fromJson(String value) =>
      PausedEventReason.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}
