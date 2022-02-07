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
  Stream<BreakpointResolvedEvent> get onBreakpointResolved => _client.onEvent
      .where((event) => event.name == 'Debugger.breakpointResolved')
      .map((event) => BreakpointResolvedEvent.fromJson(event.parameters));

  /// Fired when the virtual machine stopped on breakpoint or exception or any other stop criteria.
  Stream<PausedEvent> get onPaused => _client.onEvent
      .where((event) => event.name == 'Debugger.paused')
      .map((event) => PausedEvent.fromJson(event.parameters));

  /// Fired when the virtual machine resumed execution.
  Stream get onResumed =>
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
  Future<void> continueToLocation(Location location,
      {@Enum(['any', 'current']) String? targetCallFrames}) async {
    assert(targetCallFrames == null ||
        const ['any', 'current'].contains(targetCallFrames));
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
      CallFrameId callFrameId, String expression,
      {String? objectGroup,
      bool? includeCommandLineAPI,
      bool? silent,
      bool? returnByValue,
      bool? generatePreview,
      bool? throwOnSideEffect,
      runtime.TimeDelta? timeout}) async {
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
  Future<List<BreakLocation>> getPossibleBreakpoints(Location start,
      {Location? end, bool? restrictToFunction}) async {
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
      runtime.ScriptId scriptId) async {
    var result = await _client.send('Debugger.getScriptSource', {
      'scriptId': scriptId,
    });
    return GetScriptSourceResult.fromJson(result);
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
      runtime.StackTraceId stackTraceId) async {
    var result = await _client.send('Debugger.getStackTrace', {
      'stackTraceId': stackTraceId,
    });
    return runtime.StackTraceData.fromJson(
        result['stackTrace'] as Map<String, dynamic>);
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

  /// Restarts particular call frame from the beginning.
  /// [callFrameId] Call frame identifier to evaluate on.
  @Deprecated('This command is deprecated')
  Future<RestartFrameResult> restartFrame(CallFrameId callFrameId) async {
    var result = await _client.send('Debugger.restartFrame', {
      'callFrameId': callFrameId,
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
      runtime.ScriptId scriptId, String query,
      {bool? caseSensitive, bool? isRegex}) async {
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

  /// Replace previous blackbox patterns with passed ones. Forces backend to skip stepping/pausing in
  /// scripts with url matching one of the patterns. VM will try to leave blackboxed script by
  /// performing 'step in' several times, finally resorting to 'step out' if unsuccessful.
  /// [patterns] Array of regexps that will be used to check script url for blackbox state.
  Future<void> setBlackboxPatterns(List<String> patterns) async {
    await _client.send('Debugger.setBlackboxPatterns', {
      'patterns': [...patterns],
    });
  }

  /// Makes backend skip steps in the script in blackboxed ranges. VM will try leave blacklisted
  /// scripts by performing 'step in' several times, finally resorting to 'step out' if unsuccessful.
  /// Positions array contains positions where blackbox state is changed. First interval isn't
  /// blackboxed. Array should be sorted.
  /// [scriptId] Id of the script.
  Future<void> setBlackboxedRanges(
      runtime.ScriptId scriptId, List<ScriptPosition> positions) async {
    await _client.send('Debugger.setBlackboxedRanges', {
      'scriptId': scriptId,
      'positions': [...positions],
    });
  }

  /// Sets JavaScript breakpoint at a given location.
  /// [location] Location to set breakpoint in.
  /// [condition] Expression to use as a breakpoint condition. When specified, debugger will only stop on the
  /// breakpoint if this expression evaluates to true.
  Future<SetBreakpointResult> setBreakpoint(Location location,
      {String? condition}) async {
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
          String instrumentation) async {
    assert(const ['beforeScriptExecution', 'beforeScriptWithSourceMapExecution']
        .contains(instrumentation));
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
  Future<SetBreakpointByUrlResult> setBreakpointByUrl(int lineNumber,
      {String? url,
      String? urlRegex,
      String? scriptHash,
      int? columnNumber,
      String? condition}) async {
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
      runtime.RemoteObjectId objectId,
      {String? condition}) async {
    var result = await _client.send('Debugger.setBreakpointOnFunctionCall', {
      'objectId': objectId,
      if (condition != null) 'condition': condition,
    });
    return BreakpointId.fromJson(result['breakpointId'] as String);
  }

  /// Activates / deactivates all breakpoints on the page.
  /// [active] New value for breakpoints active state.
  Future<void> setBreakpointsActive(bool active) async {
    await _client.send('Debugger.setBreakpointsActive', {
      'active': active,
    });
  }

  /// Defines pause on exceptions state. Can be set to stop on all exceptions, uncaught exceptions or
  /// no exceptions. Initial pause on exceptions state is `none`.
  /// [state] Pause on exceptions mode.
  Future<void> setPauseOnExceptions(
      @Enum(['none', 'uncaught', 'all']) String state) async {
    assert(const ['none', 'uncaught', 'all'].contains(state));
    await _client.send('Debugger.setPauseOnExceptions', {
      'state': state,
    });
  }

  /// Changes return value in top frame. Available only at return break position.
  /// [newValue] New return value.
  Future<void> setReturnValue(runtime.CallArgument newValue) async {
    await _client.send('Debugger.setReturnValue', {
      'newValue': newValue,
    });
  }

  /// Edits JavaScript source live.
  /// [scriptId] Id of the script to edit.
  /// [scriptSource] New content of the script.
  /// [dryRun] If true the change will not actually be applied. Dry run may be used to get result
  /// description without actually modifying the code.
  Future<SetScriptSourceResult> setScriptSource(
      runtime.ScriptId scriptId, String scriptSource,
      {bool? dryRun}) async {
    var result = await _client.send('Debugger.setScriptSource', {
      'scriptId': scriptId,
      'scriptSource': scriptSource,
      if (dryRun != null) 'dryRun': dryRun,
    });
    return SetScriptSourceResult.fromJson(result);
  }

  /// Makes page not interrupt on any pauses (breakpoint, exception, dom exception etc).
  /// [skip] New value for skip pauses state.
  Future<void> setSkipAllPauses(bool skip) async {
    await _client.send('Debugger.setSkipAllPauses', {
      'skip': skip,
    });
  }

  /// Changes value of variable in a callframe. Object-based scopes are not supported and must be
  /// mutated manually.
  /// [scopeNumber] 0-based number of scope as was listed in scope chain. Only 'local', 'closure' and 'catch'
  /// scope types are allowed. Other scopes could be manipulated manually.
  /// [variableName] Variable name.
  /// [newValue] New variable value.
  /// [callFrameId] Id of callframe that holds variable.
  Future<void> setVariableValue(int scopeNumber, String variableName,
      runtime.CallArgument newValue, CallFrameId callFrameId) async {
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
  Future<void> stepInto(
      {bool? breakOnAsyncCall, List<LocationRange>? skipList}) async {
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

  PausedEvent(
      {required this.callFrames,
      required this.reason,
      this.data,
      this.hitBreakpoints,
      this.asyncStackTrace,
      this.asyncStackTraceId});

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
              json['asyncStackTrace'] as Map<String, dynamic>)
          : null,
      asyncStackTraceId: json.containsKey('asyncStackTraceId')
          ? runtime.StackTraceId.fromJson(
              json['asyncStackTraceId'] as Map<String, dynamic>)
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

  /// Content hash of the script.
  final String hash;

  /// Embedder-specific auxiliary data.
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

  ScriptFailedToParseEvent(
      {required this.scriptId,
      required this.url,
      required this.startLine,
      required this.startColumn,
      required this.endLine,
      required this.endColumn,
      required this.executionContextId,
      required this.hash,
      this.executionContextAuxData,
      this.sourceMapURL,
      this.hasSourceURL,
      this.isModule,
      this.length,
      this.stackTrace,
      this.codeOffset,
      this.scriptLanguage,
      this.embedderName});

  factory ScriptFailedToParseEvent.fromJson(Map<String, dynamic> json) {
    return ScriptFailedToParseEvent(
      scriptId: runtime.ScriptId.fromJson(json['scriptId'] as String),
      url: json['url'] as String,
      startLine: json['startLine'] as int,
      startColumn: json['startColumn'] as int,
      endLine: json['endLine'] as int,
      endColumn: json['endColumn'] as int,
      executionContextId: runtime.ExecutionContextId.fromJson(
          json['executionContextId'] as int),
      hash: json['hash'] as String,
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
              json['stackTrace'] as Map<String, dynamic>)
          : null,
      codeOffset:
          json.containsKey('codeOffset') ? json['codeOffset'] as int : null,
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

  /// Content hash of the script.
  final String hash;

  /// Embedder-specific auxiliary data.
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

  /// If the scriptLanguage is WebASsembly, the source of debug symbols for the module.
  final debugger.DebugSymbols? debugSymbols;

  /// The name the embedder supplied for this script.
  final String? embedderName;

  ScriptParsedEvent(
      {required this.scriptId,
      required this.url,
      required this.startLine,
      required this.startColumn,
      required this.endLine,
      required this.endColumn,
      required this.executionContextId,
      required this.hash,
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
      this.embedderName});

  factory ScriptParsedEvent.fromJson(Map<String, dynamic> json) {
    return ScriptParsedEvent(
      scriptId: runtime.ScriptId.fromJson(json['scriptId'] as String),
      url: json['url'] as String,
      startLine: json['startLine'] as int,
      startColumn: json['startColumn'] as int,
      endLine: json['endLine'] as int,
      endColumn: json['endColumn'] as int,
      executionContextId: runtime.ExecutionContextId.fromJson(
          json['executionContextId'] as int),
      hash: json['hash'] as String,
      executionContextAuxData: json.containsKey('executionContextAuxData')
          ? json['executionContextAuxData'] as Map<String, dynamic>
          : null,
      isLiveEdit:
          json.containsKey('isLiveEdit') ? json['isLiveEdit'] as bool : null,
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
              json['stackTrace'] as Map<String, dynamic>)
          : null,
      codeOffset:
          json.containsKey('codeOffset') ? json['codeOffset'] as int : null,
      scriptLanguage: json.containsKey('scriptLanguage')
          ? debugger.ScriptLanguage.fromJson(json['scriptLanguage'] as String)
          : null,
      debugSymbols: json.containsKey('debugSymbols')
          ? debugger.DebugSymbols.fromJson(
              json['debugSymbols'] as Map<String, dynamic>)
          : null,
      embedderName: json.containsKey('embedderName')
          ? json['embedderName'] as String
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
      result:
          runtime.RemoteObject.fromJson(json['result'] as Map<String, dynamic>),
      exceptionDetails: json.containsKey('exceptionDetails')
          ? runtime.ExceptionDetails.fromJson(
              json['exceptionDetails'] as Map<String, dynamic>)
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
      bytecode:
          json.containsKey('bytecode') ? json['bytecode'] as String : null,
    );
  }
}

class RestartFrameResult {
  /// New stack trace.
  final List<CallFrame> callFrames;

  /// Async stack trace, if any.
  final runtime.StackTraceData? asyncStackTrace;

  /// Async stack trace, if any.
  final runtime.StackTraceId? asyncStackTraceId;

  RestartFrameResult(
      {required this.callFrames, this.asyncStackTrace, this.asyncStackTraceId});

  factory RestartFrameResult.fromJson(Map<String, dynamic> json) {
    return RestartFrameResult(
      callFrames: (json['callFrames'] as List)
          .map((e) => CallFrame.fromJson(e as Map<String, dynamic>))
          .toList(),
      asyncStackTrace: json.containsKey('asyncStackTrace')
          ? runtime.StackTraceData.fromJson(
              json['asyncStackTrace'] as Map<String, dynamic>)
          : null,
      asyncStackTraceId: json.containsKey('asyncStackTraceId')
          ? runtime.StackTraceId.fromJson(
              json['asyncStackTraceId'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SetBreakpointResult {
  /// Id of the created breakpoint for further reference.
  final BreakpointId breakpointId;

  /// Location this breakpoint resolved into.
  final Location actualLocation;

  SetBreakpointResult(
      {required this.breakpointId, required this.actualLocation});

  factory SetBreakpointResult.fromJson(Map<String, dynamic> json) {
    return SetBreakpointResult(
      breakpointId: BreakpointId.fromJson(json['breakpointId'] as String),
      actualLocation:
          Location.fromJson(json['actualLocation'] as Map<String, dynamic>),
    );
  }
}

class SetBreakpointByUrlResult {
  /// Id of the created breakpoint for further reference.
  final BreakpointId breakpointId;

  /// List of the locations this breakpoint resolved into upon addition.
  final List<Location> locations;

  SetBreakpointByUrlResult(
      {required this.breakpointId, required this.locations});

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
  /// New stack trace in case editing has happened while VM was stopped.
  final List<CallFrame>? callFrames;

  /// Whether current call stack  was modified after applying the changes.
  final bool? stackChanged;

  /// Async stack trace, if any.
  final runtime.StackTraceData? asyncStackTrace;

  /// Async stack trace, if any.
  final runtime.StackTraceId? asyncStackTraceId;

  /// Exception details if any.
  final runtime.ExceptionDetails? exceptionDetails;

  SetScriptSourceResult(
      {this.callFrames,
      this.stackChanged,
      this.asyncStackTrace,
      this.asyncStackTraceId,
      this.exceptionDetails});

  factory SetScriptSourceResult.fromJson(Map<String, dynamic> json) {
    return SetScriptSourceResult(
      callFrames: json.containsKey('callFrames')
          ? (json['callFrames'] as List)
              .map((e) => CallFrame.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      stackChanged: json.containsKey('stackChanged')
          ? json['stackChanged'] as bool
          : null,
      asyncStackTrace: json.containsKey('asyncStackTrace')
          ? runtime.StackTraceData.fromJson(
              json['asyncStackTrace'] as Map<String, dynamic>)
          : null,
      asyncStackTraceId: json.containsKey('asyncStackTraceId')
          ? runtime.StackTraceId.fromJson(
              json['asyncStackTraceId'] as Map<String, dynamic>)
          : null,
      exceptionDetails: json.containsKey('exceptionDetails')
          ? runtime.ExceptionDetails.fromJson(
              json['exceptionDetails'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Breakpoint identifier.
class BreakpointId {
  final String value;

  BreakpointId(this.value);

  factory BreakpointId.fromJson(String value) => BreakpointId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is BreakpointId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Call frame identifier.
class CallFrameId {
  final String value;

  CallFrameId(this.value);

  factory CallFrameId.fromJson(String value) => CallFrameId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CallFrameId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Location in the source code.
class Location {
  /// Script identifier as reported in the `Debugger.scriptParsed`.
  final runtime.ScriptId scriptId;

  /// Line number in the script (0-based).
  final int lineNumber;

  /// Column number in the script (0-based).
  final int? columnNumber;

  Location(
      {required this.scriptId, required this.lineNumber, this.columnNumber});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      scriptId: runtime.ScriptId.fromJson(json['scriptId'] as String),
      lineNumber: json['lineNumber'] as int,
      columnNumber:
          json.containsKey('columnNumber') ? json['columnNumber'] as int : null,
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
    return {
      'lineNumber': lineNumber,
      'columnNumber': columnNumber,
    };
  }
}

/// Location range within one script.
class LocationRange {
  final runtime.ScriptId scriptId;

  final ScriptPosition start;

  final ScriptPosition end;

  LocationRange(
      {required this.scriptId, required this.start, required this.end});

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

  CallFrame(
      {required this.callFrameId,
      required this.functionName,
      this.functionLocation,
      required this.location,
      required this.scopeChain,
      required this.this$,
      this.returnValue});

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
      this$:
          runtime.RemoteObject.fromJson(json['this'] as Map<String, dynamic>),
      returnValue: json.containsKey('returnValue')
          ? runtime.RemoteObject.fromJson(
              json['returnValue'] as Map<String, dynamic>)
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

  Scope(
      {required this.type,
      required this.object,
      this.name,
      this.startLocation,
      this.endLocation});

  factory Scope.fromJson(Map<String, dynamic> json) {
    return Scope(
      type: ScopeType.fromJson(json['type'] as String),
      object:
          runtime.RemoteObject.fromJson(json['object'] as Map<String, dynamic>),
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

class ScopeType {
  static const global = ScopeType._('global');
  static const local = ScopeType._('local');
  static const with$ = ScopeType._('with');
  static const closure = ScopeType._('closure');
  static const catch$ = ScopeType._('catch');
  static const block = ScopeType._('block');
  static const script = ScopeType._('script');
  static const eval = ScopeType._('eval');
  static const module = ScopeType._('module');
  static const wasmExpressionStack = ScopeType._('wasm-expression-stack');
  static const values = {
    'global': global,
    'local': local,
    'with': with$,
    'closure': closure,
    'catch': catch$,
    'block': block,
    'script': script,
    'eval': eval,
    'module': module,
    'wasm-expression-stack': wasmExpressionStack,
  };

  final String value;

  const ScopeType._(this.value);

  factory ScopeType.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ScopeType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

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
    return {
      'lineNumber': lineNumber,
      'lineContent': lineContent,
    };
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

  BreakLocation(
      {required this.scriptId,
      required this.lineNumber,
      this.columnNumber,
      this.type});

  factory BreakLocation.fromJson(Map<String, dynamic> json) {
    return BreakLocation(
      scriptId: runtime.ScriptId.fromJson(json['scriptId'] as String),
      lineNumber: json['lineNumber'] as int,
      columnNumber:
          json.containsKey('columnNumber') ? json['columnNumber'] as int : null,
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

class BreakLocationType {
  static const debuggerStatement = BreakLocationType._('debuggerStatement');
  static const call = BreakLocationType._('call');
  static const return$ = BreakLocationType._('return');
  static const values = {
    'debuggerStatement': debuggerStatement,
    'call': call,
    'return': return$,
  };

  final String value;

  const BreakLocationType._(this.value);

  factory BreakLocationType.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is BreakLocationType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Enum of possible script languages.
class ScriptLanguage {
  static const javaScript = ScriptLanguage._('JavaScript');
  static const webAssembly = ScriptLanguage._('WebAssembly');
  static const values = {
    'JavaScript': javaScript,
    'WebAssembly': webAssembly,
  };

  final String value;

  const ScriptLanguage._(this.value);

  factory ScriptLanguage.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ScriptLanguage && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

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
    return {
      'type': type,
      if (externalURL != null) 'externalURL': externalURL,
    };
  }
}

class DebugSymbolsType {
  static const none = DebugSymbolsType._('None');
  static const sourceMap = DebugSymbolsType._('SourceMap');
  static const embeddedDwarf = DebugSymbolsType._('EmbeddedDWARF');
  static const externalDwarf = DebugSymbolsType._('ExternalDWARF');
  static const values = {
    'None': none,
    'SourceMap': sourceMap,
    'EmbeddedDWARF': embeddedDwarf,
    'ExternalDWARF': externalDwarf,
  };

  final String value;

  const DebugSymbolsType._(this.value);

  factory DebugSymbolsType.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is DebugSymbolsType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class PausedEventReason {
  static const ambiguous = PausedEventReason._('ambiguous');
  static const assert$ = PausedEventReason._('assert');
  static const cspViolation = PausedEventReason._('CSPViolation');
  static const debugCommand = PausedEventReason._('debugCommand');
  static const dom = PausedEventReason._('DOM');
  static const eventListener = PausedEventReason._('EventListener');
  static const exception = PausedEventReason._('exception');
  static const instrumentation = PausedEventReason._('instrumentation');
  static const oom = PausedEventReason._('OOM');
  static const other = PausedEventReason._('other');
  static const promiseRejection = PausedEventReason._('promiseRejection');
  static const xhr = PausedEventReason._('XHR');
  static const values = {
    'ambiguous': ambiguous,
    'assert': assert$,
    'CSPViolation': cspViolation,
    'debugCommand': debugCommand,
    'DOM': dom,
    'EventListener': eventListener,
    'exception': exception,
    'instrumentation': instrumentation,
    'OOM': oom,
    'other': other,
    'promiseRejection': promiseRejection,
    'XHR': xhr,
  };

  final String value;

  const PausedEventReason._(this.value);

  factory PausedEventReason.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is PausedEventReason && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
