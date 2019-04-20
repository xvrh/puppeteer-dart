import 'dart:async';

import 'package:meta/meta.dart' show required;

import '../src/connection.dart';
import 'runtime.dart' as runtime;

/// Debugger domain exposes JavaScript debugging capabilities. It allows setting and removing
/// breakpoints, stepping through execution, exploring stack traces, etc.
class DebuggerApi {
  final Client _client;

  DebuggerApi(this._client);

  /// Fired when breakpoint is resolved to an actual script and location.
  Stream<BreakpointResolvedEvent> get onBreakpointResolved => _client.onEvent
      .where((Event event) => event.name == 'Debugger.breakpointResolved')
      .map((Event event) => BreakpointResolvedEvent.fromJson(event.parameters));

  /// Fired when the virtual machine stopped on breakpoint or exception or any other stop criteria.
  Stream<PausedEvent> get onPaused => _client.onEvent
      .where((Event event) => event.name == 'Debugger.paused')
      .map((Event event) => PausedEvent.fromJson(event.parameters));

  /// Fired when the virtual machine resumed execution.
  Stream get onResumed =>
      _client.onEvent.where((Event event) => event.name == 'Debugger.resumed');

  /// Fired when virtual machine fails to parse the script.
  Stream<ScriptFailedToParseEvent> get onScriptFailedToParse => _client.onEvent
      .where((Event event) => event.name == 'Debugger.scriptFailedToParse')
      .map(
          (Event event) => ScriptFailedToParseEvent.fromJson(event.parameters));

  /// Fired when virtual machine parses script. This event is also fired for all known and uncollected
  /// scripts upon enabling debugger.
  Stream<ScriptParsedEvent> get onScriptParsed => _client.onEvent
      .where((Event event) => event.name == 'Debugger.scriptParsed')
      .map((Event event) => ScriptParsedEvent.fromJson(event.parameters));

  /// Continues execution until specific location is reached.
  /// [location] Location to continue to.
  Future<void> continueToLocation(Location location,
      {@Enum(['any', 'current']) String targetCallFrames}) async {
    assert(targetCallFrames == null ||
        const ['any', 'current'].contains(targetCallFrames));
    var parameters = <String, dynamic>{
      'location': location.toJson(),
    };
    if (targetCallFrames != null) {
      parameters['targetCallFrames'] = targetCallFrames;
    }
    await _client.send('Debugger.continueToLocation', parameters);
  }

  /// Disables debugger for given page.
  Future<void> disable() async {
    await _client.send('Debugger.disable');
  }

  /// Enables debugger for the given page. Clients should not assume that the debugging has been
  /// enabled until the result for this command is received.
  /// [maxScriptsCacheSize] The maximum size in bytes of collected scripts (not referenced by other heap objects)
  /// the debugger can hold. Puts no limit if paramter is omitted.
  /// Returns: Unique identifier of the debugger.
  Future<runtime.UniqueDebuggerId> enable({num maxScriptsCacheSize}) async {
    var parameters = <String, dynamic>{};
    if (maxScriptsCacheSize != null) {
      parameters['maxScriptsCacheSize'] = maxScriptsCacheSize;
    }
    var result = await _client.send('Debugger.enable', parameters);
    return runtime.UniqueDebuggerId.fromJson(result['debuggerId']);
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
      {String objectGroup,
      bool includeCommandLineAPI,
      bool silent,
      bool returnByValue,
      bool generatePreview,
      bool throwOnSideEffect,
      runtime.TimeDelta timeout}) async {
    var parameters = <String, dynamic>{
      'callFrameId': callFrameId.toJson(),
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
    if (returnByValue != null) {
      parameters['returnByValue'] = returnByValue;
    }
    if (generatePreview != null) {
      parameters['generatePreview'] = generatePreview;
    }
    if (throwOnSideEffect != null) {
      parameters['throwOnSideEffect'] = throwOnSideEffect;
    }
    if (timeout != null) {
      parameters['timeout'] = timeout.toJson();
    }
    var result = await _client.send('Debugger.evaluateOnCallFrame', parameters);
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
      {Location end, bool restrictToFunction}) async {
    var parameters = <String, dynamic>{
      'start': start.toJson(),
    };
    if (end != null) {
      parameters['end'] = end.toJson();
    }
    if (restrictToFunction != null) {
      parameters['restrictToFunction'] = restrictToFunction;
    }
    var result =
        await _client.send('Debugger.getPossibleBreakpoints', parameters);
    return (result['locations'] as List)
        .map((e) => BreakLocation.fromJson(e))
        .toList();
  }

  /// Returns source for the script with given id.
  /// [scriptId] Id of the script to get source for.
  /// Returns: Script source.
  Future<String> getScriptSource(runtime.ScriptId scriptId) async {
    var parameters = <String, dynamic>{
      'scriptId': scriptId.toJson(),
    };
    var result = await _client.send('Debugger.getScriptSource', parameters);
    return result['scriptSource'];
  }

  /// Returns stack trace with given `stackTraceId`.
  Future<runtime.StackTrace> getStackTrace(
      runtime.StackTraceId stackTraceId) async {
    var parameters = <String, dynamic>{
      'stackTraceId': stackTraceId.toJson(),
    };
    var result = await _client.send('Debugger.getStackTrace', parameters);
    return runtime.StackTrace.fromJson(result['stackTrace']);
  }

  /// Stops on the next JavaScript statement.
  Future<void> pause() async {
    await _client.send('Debugger.pause');
  }

  /// [parentStackTraceId] Debugger will pause when async call with given stack trace is started.
  Future<void> pauseOnAsyncCall(runtime.StackTraceId parentStackTraceId) async {
    var parameters = <String, dynamic>{
      'parentStackTraceId': parentStackTraceId.toJson(),
    };
    await _client.send('Debugger.pauseOnAsyncCall', parameters);
  }

  /// Removes JavaScript breakpoint.
  Future<void> removeBreakpoint(BreakpointId breakpointId) async {
    var parameters = <String, dynamic>{
      'breakpointId': breakpointId.toJson(),
    };
    await _client.send('Debugger.removeBreakpoint', parameters);
  }

  /// Restarts particular call frame from the beginning.
  /// [callFrameId] Call frame identifier to evaluate on.
  Future<RestartFrameResult> restartFrame(CallFrameId callFrameId) async {
    var parameters = <String, dynamic>{
      'callFrameId': callFrameId.toJson(),
    };
    var result = await _client.send('Debugger.restartFrame', parameters);
    return RestartFrameResult.fromJson(result);
  }

  /// Resumes JavaScript execution.
  Future<void> resume() async {
    await _client.send('Debugger.resume');
  }

  /// Searches for given string in script content.
  /// [scriptId] Id of the script to search in.
  /// [query] String to search for.
  /// [caseSensitive] If true, search is case sensitive.
  /// [isRegex] If true, treats string parameter as regex.
  /// Returns: List of search matches.
  Future<List<SearchMatch>> searchInContent(
      runtime.ScriptId scriptId, String query,
      {bool caseSensitive, bool isRegex}) async {
    var parameters = <String, dynamic>{
      'scriptId': scriptId.toJson(),
      'query': query,
    };
    if (caseSensitive != null) {
      parameters['caseSensitive'] = caseSensitive;
    }
    if (isRegex != null) {
      parameters['isRegex'] = isRegex;
    }
    var result = await _client.send('Debugger.searchInContent', parameters);
    return (result['result'] as List)
        .map((e) => SearchMatch.fromJson(e))
        .toList();
  }

  /// Enables or disables async call stacks tracking.
  /// [maxDepth] Maximum depth of async call stacks. Setting to `0` will effectively disable collecting async
  /// call stacks (default).
  Future<void> setAsyncCallStackDepth(int maxDepth) async {
    var parameters = <String, dynamic>{
      'maxDepth': maxDepth,
    };
    await _client.send('Debugger.setAsyncCallStackDepth', parameters);
  }

  /// Replace previous blackbox patterns with passed ones. Forces backend to skip stepping/pausing in
  /// scripts with url matching one of the patterns. VM will try to leave blackboxed script by
  /// performing 'step in' several times, finally resorting to 'step out' if unsuccessful.
  /// [patterns] Array of regexps that will be used to check script url for blackbox state.
  Future<void> setBlackboxPatterns(List<String> patterns) async {
    var parameters = <String, dynamic>{
      'patterns': patterns.map((e) => e).toList(),
    };
    await _client.send('Debugger.setBlackboxPatterns', parameters);
  }

  /// Makes backend skip steps in the script in blackboxed ranges. VM will try leave blacklisted
  /// scripts by performing 'step in' several times, finally resorting to 'step out' if unsuccessful.
  /// Positions array contains positions where blackbox state is changed. First interval isn't
  /// blackboxed. Array should be sorted.
  /// [scriptId] Id of the script.
  Future<void> setBlackboxedRanges(
      runtime.ScriptId scriptId, List<ScriptPosition> positions) async {
    var parameters = <String, dynamic>{
      'scriptId': scriptId.toJson(),
      'positions': positions.map((e) => e.toJson()).toList(),
    };
    await _client.send('Debugger.setBlackboxedRanges', parameters);
  }

  /// Sets JavaScript breakpoint at a given location.
  /// [location] Location to set breakpoint in.
  /// [condition] Expression to use as a breakpoint condition. When specified, debugger will only stop on the
  /// breakpoint if this expression evaluates to true.
  Future<SetBreakpointResult> setBreakpoint(Location location,
      {String condition}) async {
    var parameters = <String, dynamic>{
      'location': location.toJson(),
    };
    if (condition != null) {
      parameters['condition'] = condition;
    }
    var result = await _client.send('Debugger.setBreakpoint', parameters);
    return SetBreakpointResult.fromJson(result);
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
      {String url,
      String urlRegex,
      String scriptHash,
      int columnNumber,
      String condition}) async {
    var parameters = <String, dynamic>{
      'lineNumber': lineNumber,
    };
    if (url != null) {
      parameters['url'] = url;
    }
    if (urlRegex != null) {
      parameters['urlRegex'] = urlRegex;
    }
    if (scriptHash != null) {
      parameters['scriptHash'] = scriptHash;
    }
    if (columnNumber != null) {
      parameters['columnNumber'] = columnNumber;
    }
    if (condition != null) {
      parameters['condition'] = condition;
    }
    var result = await _client.send('Debugger.setBreakpointByUrl', parameters);
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
      {String condition}) async {
    var parameters = <String, dynamic>{
      'objectId': objectId.toJson(),
    };
    if (condition != null) {
      parameters['condition'] = condition;
    }
    var result =
        await _client.send('Debugger.setBreakpointOnFunctionCall', parameters);
    return BreakpointId.fromJson(result['breakpointId']);
  }

  /// Activates / deactivates all breakpoints on the page.
  /// [active] New value for breakpoints active state.
  Future<void> setBreakpointsActive(bool active) async {
    var parameters = <String, dynamic>{
      'active': active,
    };
    await _client.send('Debugger.setBreakpointsActive', parameters);
  }

  /// Defines pause on exceptions state. Can be set to stop on all exceptions, uncaught exceptions or
  /// no exceptions. Initial pause on exceptions state is `none`.
  /// [state] Pause on exceptions mode.
  Future<void> setPauseOnExceptions(
      @Enum(['none', 'uncaught', 'all']) String state) async {
    assert(const ['none', 'uncaught', 'all'].contains(state));
    var parameters = <String, dynamic>{
      'state': state,
    };
    await _client.send('Debugger.setPauseOnExceptions', parameters);
  }

  /// Changes return value in top frame. Available only at return break position.
  /// [newValue] New return value.
  Future<void> setReturnValue(runtime.CallArgument newValue) async {
    var parameters = <String, dynamic>{
      'newValue': newValue.toJson(),
    };
    await _client.send('Debugger.setReturnValue', parameters);
  }

  /// Edits JavaScript source live.
  /// [scriptId] Id of the script to edit.
  /// [scriptSource] New content of the script.
  /// [dryRun] If true the change will not actually be applied. Dry run may be used to get result
  /// description without actually modifying the code.
  Future<SetScriptSourceResult> setScriptSource(
      runtime.ScriptId scriptId, String scriptSource,
      {bool dryRun}) async {
    var parameters = <String, dynamic>{
      'scriptId': scriptId.toJson(),
      'scriptSource': scriptSource,
    };
    if (dryRun != null) {
      parameters['dryRun'] = dryRun;
    }
    var result = await _client.send('Debugger.setScriptSource', parameters);
    return SetScriptSourceResult.fromJson(result);
  }

  /// Makes page not interrupt on any pauses (breakpoint, exception, dom exception etc).
  /// [skip] New value for skip pauses state.
  Future<void> setSkipAllPauses(bool skip) async {
    var parameters = <String, dynamic>{
      'skip': skip,
    };
    await _client.send('Debugger.setSkipAllPauses', parameters);
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
    var parameters = <String, dynamic>{
      'scopeNumber': scopeNumber,
      'variableName': variableName,
      'newValue': newValue.toJson(),
      'callFrameId': callFrameId.toJson(),
    };
    await _client.send('Debugger.setVariableValue', parameters);
  }

  /// Steps into the function call.
  /// [breakOnAsyncCall] Debugger will issue additional Debugger.paused notification if any async task is scheduled
  /// before next pause.
  Future<void> stepInto({bool breakOnAsyncCall}) async {
    var parameters = <String, dynamic>{};
    if (breakOnAsyncCall != null) {
      parameters['breakOnAsyncCall'] = breakOnAsyncCall;
    }
    await _client.send('Debugger.stepInto', parameters);
  }

  /// Steps out of the function call.
  Future<void> stepOut() async {
    await _client.send('Debugger.stepOut');
  }

  /// Steps over the statement.
  Future<void> stepOver() async {
    await _client.send('Debugger.stepOver');
  }
}

class BreakpointResolvedEvent {
  /// Breakpoint unique identifier.
  final BreakpointId breakpointId;

  /// Actual breakpoint location.
  final Location location;

  BreakpointResolvedEvent(
      {@required this.breakpointId, @required this.location});

  factory BreakpointResolvedEvent.fromJson(Map<String, dynamic> json) {
    return BreakpointResolvedEvent(
      breakpointId: BreakpointId.fromJson(json['breakpointId']),
      location: Location.fromJson(json['location']),
    );
  }
}

class PausedEvent {
  /// Call stack the virtual machine stopped on.
  final List<CallFrame> callFrames;

  /// Pause reason.
  final PausedEventReason reason;

  /// Object containing break-specific auxiliary properties.
  final Map data;

  /// Hit breakpoints IDs
  final List<String> hitBreakpoints;

  /// Async stack trace, if any.
  final runtime.StackTrace asyncStackTrace;

  /// Async stack trace, if any.
  final runtime.StackTraceId asyncStackTraceId;

  /// Just scheduled async call will have this stack trace as parent stack during async execution.
  /// This field is available only after `Debugger.stepInto` call with `breakOnAsynCall` flag.
  final runtime.StackTraceId asyncCallStackTraceId;

  PausedEvent(
      {@required this.callFrames,
      @required this.reason,
      this.data,
      this.hitBreakpoints,
      this.asyncStackTrace,
      this.asyncStackTraceId,
      this.asyncCallStackTraceId});

  factory PausedEvent.fromJson(Map<String, dynamic> json) {
    return PausedEvent(
      callFrames: (json['callFrames'] as List)
          .map((e) => CallFrame.fromJson(e))
          .toList(),
      reason: PausedEventReason.fromJson(json['reason']),
      data: json.containsKey('data') ? json['data'] : null,
      hitBreakpoints: json.containsKey('hitBreakpoints')
          ? (json['hitBreakpoints'] as List).map((e) => e as String).toList()
          : null,
      asyncStackTrace: json.containsKey('asyncStackTrace')
          ? runtime.StackTrace.fromJson(json['asyncStackTrace'])
          : null,
      asyncStackTraceId: json.containsKey('asyncStackTraceId')
          ? runtime.StackTraceId.fromJson(json['asyncStackTraceId'])
          : null,
      asyncCallStackTraceId: json.containsKey('asyncCallStackTraceId')
          ? runtime.StackTraceId.fromJson(json['asyncCallStackTraceId'])
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
  final Map executionContextAuxData;

  /// URL of source map associated with script (if any).
  final String sourceMapURL;

  /// True, if this script has sourceURL.
  final bool hasSourceURL;

  /// True, if this script is ES6 module.
  final bool isModule;

  /// This script length.
  final int length;

  /// JavaScript top stack frame of where the script parsed event was triggered if available.
  final runtime.StackTrace stackTrace;

  ScriptFailedToParseEvent(
      {@required this.scriptId,
      @required this.url,
      @required this.startLine,
      @required this.startColumn,
      @required this.endLine,
      @required this.endColumn,
      @required this.executionContextId,
      @required this.hash,
      this.executionContextAuxData,
      this.sourceMapURL,
      this.hasSourceURL,
      this.isModule,
      this.length,
      this.stackTrace});

  factory ScriptFailedToParseEvent.fromJson(Map<String, dynamic> json) {
    return ScriptFailedToParseEvent(
      scriptId: runtime.ScriptId.fromJson(json['scriptId']),
      url: json['url'],
      startLine: json['startLine'],
      startColumn: json['startColumn'],
      endLine: json['endLine'],
      endColumn: json['endColumn'],
      executionContextId:
          runtime.ExecutionContextId.fromJson(json['executionContextId']),
      hash: json['hash'],
      executionContextAuxData: json.containsKey('executionContextAuxData')
          ? json['executionContextAuxData']
          : null,
      sourceMapURL:
          json.containsKey('sourceMapURL') ? json['sourceMapURL'] : null,
      hasSourceURL:
          json.containsKey('hasSourceURL') ? json['hasSourceURL'] : null,
      isModule: json.containsKey('isModule') ? json['isModule'] : null,
      length: json.containsKey('length') ? json['length'] : null,
      stackTrace: json.containsKey('stackTrace')
          ? runtime.StackTrace.fromJson(json['stackTrace'])
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
  final Map executionContextAuxData;

  /// True, if this script is generated as a result of the live edit operation.
  final bool isLiveEdit;

  /// URL of source map associated with script (if any).
  final String sourceMapURL;

  /// True, if this script has sourceURL.
  final bool hasSourceURL;

  /// True, if this script is ES6 module.
  final bool isModule;

  /// This script length.
  final int length;

  /// JavaScript top stack frame of where the script parsed event was triggered if available.
  final runtime.StackTrace stackTrace;

  ScriptParsedEvent(
      {@required this.scriptId,
      @required this.url,
      @required this.startLine,
      @required this.startColumn,
      @required this.endLine,
      @required this.endColumn,
      @required this.executionContextId,
      @required this.hash,
      this.executionContextAuxData,
      this.isLiveEdit,
      this.sourceMapURL,
      this.hasSourceURL,
      this.isModule,
      this.length,
      this.stackTrace});

  factory ScriptParsedEvent.fromJson(Map<String, dynamic> json) {
    return ScriptParsedEvent(
      scriptId: runtime.ScriptId.fromJson(json['scriptId']),
      url: json['url'],
      startLine: json['startLine'],
      startColumn: json['startColumn'],
      endLine: json['endLine'],
      endColumn: json['endColumn'],
      executionContextId:
          runtime.ExecutionContextId.fromJson(json['executionContextId']),
      hash: json['hash'],
      executionContextAuxData: json.containsKey('executionContextAuxData')
          ? json['executionContextAuxData']
          : null,
      isLiveEdit: json.containsKey('isLiveEdit') ? json['isLiveEdit'] : null,
      sourceMapURL:
          json.containsKey('sourceMapURL') ? json['sourceMapURL'] : null,
      hasSourceURL:
          json.containsKey('hasSourceURL') ? json['hasSourceURL'] : null,
      isModule: json.containsKey('isModule') ? json['isModule'] : null,
      length: json.containsKey('length') ? json['length'] : null,
      stackTrace: json.containsKey('stackTrace')
          ? runtime.StackTrace.fromJson(json['stackTrace'])
          : null,
    );
  }
}

class EvaluateOnCallFrameResult {
  /// Object wrapper for the evaluation result.
  final runtime.RemoteObject result;

  /// Exception details.
  final runtime.ExceptionDetails exceptionDetails;

  EvaluateOnCallFrameResult({@required this.result, this.exceptionDetails});

  factory EvaluateOnCallFrameResult.fromJson(Map<String, dynamic> json) {
    return EvaluateOnCallFrameResult(
      result: runtime.RemoteObject.fromJson(json['result']),
      exceptionDetails: json.containsKey('exceptionDetails')
          ? runtime.ExceptionDetails.fromJson(json['exceptionDetails'])
          : null,
    );
  }
}

class RestartFrameResult {
  /// New stack trace.
  final List<CallFrame> callFrames;

  /// Async stack trace, if any.
  final runtime.StackTrace asyncStackTrace;

  /// Async stack trace, if any.
  final runtime.StackTraceId asyncStackTraceId;

  RestartFrameResult(
      {@required this.callFrames,
      this.asyncStackTrace,
      this.asyncStackTraceId});

  factory RestartFrameResult.fromJson(Map<String, dynamic> json) {
    return RestartFrameResult(
      callFrames: (json['callFrames'] as List)
          .map((e) => CallFrame.fromJson(e))
          .toList(),
      asyncStackTrace: json.containsKey('asyncStackTrace')
          ? runtime.StackTrace.fromJson(json['asyncStackTrace'])
          : null,
      asyncStackTraceId: json.containsKey('asyncStackTraceId')
          ? runtime.StackTraceId.fromJson(json['asyncStackTraceId'])
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
      {@required this.breakpointId, @required this.actualLocation});

  factory SetBreakpointResult.fromJson(Map<String, dynamic> json) {
    return SetBreakpointResult(
      breakpointId: BreakpointId.fromJson(json['breakpointId']),
      actualLocation: Location.fromJson(json['actualLocation']),
    );
  }
}

class SetBreakpointByUrlResult {
  /// Id of the created breakpoint for further reference.
  final BreakpointId breakpointId;

  /// List of the locations this breakpoint resolved into upon addition.
  final List<Location> locations;

  SetBreakpointByUrlResult(
      {@required this.breakpointId, @required this.locations});

  factory SetBreakpointByUrlResult.fromJson(Map<String, dynamic> json) {
    return SetBreakpointByUrlResult(
      breakpointId: BreakpointId.fromJson(json['breakpointId']),
      locations:
          (json['locations'] as List).map((e) => Location.fromJson(e)).toList(),
    );
  }
}

class SetScriptSourceResult {
  /// New stack trace in case editing has happened while VM was stopped.
  final List<CallFrame> callFrames;

  /// Whether current call stack  was modified after applying the changes.
  final bool stackChanged;

  /// Async stack trace, if any.
  final runtime.StackTrace asyncStackTrace;

  /// Async stack trace, if any.
  final runtime.StackTraceId asyncStackTraceId;

  /// Exception details if any.
  final runtime.ExceptionDetails exceptionDetails;

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
              .map((e) => CallFrame.fromJson(e))
              .toList()
          : null,
      stackChanged:
          json.containsKey('stackChanged') ? json['stackChanged'] : null,
      asyncStackTrace: json.containsKey('asyncStackTrace')
          ? runtime.StackTrace.fromJson(json['asyncStackTrace'])
          : null,
      asyncStackTraceId: json.containsKey('asyncStackTraceId')
          ? runtime.StackTraceId.fromJson(json['asyncStackTraceId'])
          : null,
      exceptionDetails: json.containsKey('exceptionDetails')
          ? runtime.ExceptionDetails.fromJson(json['exceptionDetails'])
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
  final int columnNumber;

  Location(
      {@required this.scriptId, @required this.lineNumber, this.columnNumber});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      scriptId: runtime.ScriptId.fromJson(json['scriptId']),
      lineNumber: json['lineNumber'],
      columnNumber:
          json.containsKey('columnNumber') ? json['columnNumber'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'scriptId': scriptId.toJson(),
      'lineNumber': lineNumber,
    };
    if (columnNumber != null) {
      json['columnNumber'] = columnNumber;
    }
    return json;
  }
}

/// Location in the source code.
class ScriptPosition {
  final int lineNumber;

  final int columnNumber;

  ScriptPosition({@required this.lineNumber, @required this.columnNumber});

  factory ScriptPosition.fromJson(Map<String, dynamic> json) {
    return ScriptPosition(
      lineNumber: json['lineNumber'],
      columnNumber: json['columnNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'lineNumber': lineNumber,
      'columnNumber': columnNumber,
    };
    return json;
  }
}

/// JavaScript call frame. Array of call frames form the call stack.
class CallFrame {
  /// Call frame identifier. This identifier is only valid while the virtual machine is paused.
  final CallFrameId callFrameId;

  /// Name of the JavaScript function called on this call frame.
  final String functionName;

  /// Location in the source code.
  final Location functionLocation;

  /// Location in the source code.
  final Location location;

  /// JavaScript script name or url.
  final String url;

  /// Scope chain for this call frame.
  final List<Scope> scopeChain;

  /// `this` object for this call frame.
  final runtime.RemoteObject this$;

  /// The value being returned, if the function is at return point.
  final runtime.RemoteObject returnValue;

  CallFrame(
      {@required this.callFrameId,
      @required this.functionName,
      this.functionLocation,
      @required this.location,
      @required this.url,
      @required this.scopeChain,
      @required this.this$,
      this.returnValue});

  factory CallFrame.fromJson(Map<String, dynamic> json) {
    return CallFrame(
      callFrameId: CallFrameId.fromJson(json['callFrameId']),
      functionName: json['functionName'],
      functionLocation: json.containsKey('functionLocation')
          ? Location.fromJson(json['functionLocation'])
          : null,
      location: Location.fromJson(json['location']),
      url: json['url'],
      scopeChain:
          (json['scopeChain'] as List).map((e) => Scope.fromJson(e)).toList(),
      this$: runtime.RemoteObject.fromJson(json['this']),
      returnValue: json.containsKey('returnValue')
          ? runtime.RemoteObject.fromJson(json['returnValue'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'callFrameId': callFrameId.toJson(),
      'functionName': functionName,
      'location': location.toJson(),
      'url': url,
      'scopeChain': scopeChain.map((e) => e.toJson()).toList(),
      'this': this$.toJson(),
    };
    if (functionLocation != null) {
      json['functionLocation'] = functionLocation.toJson();
    }
    if (returnValue != null) {
      json['returnValue'] = returnValue.toJson();
    }
    return json;
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

  final String name;

  /// Location in the source code where scope starts
  final Location startLocation;

  /// Location in the source code where scope ends
  final Location endLocation;

  Scope(
      {@required this.type,
      @required this.object,
      this.name,
      this.startLocation,
      this.endLocation});

  factory Scope.fromJson(Map<String, dynamic> json) {
    return Scope(
      type: ScopeType.fromJson(json['type']),
      object: runtime.RemoteObject.fromJson(json['object']),
      name: json.containsKey('name') ? json['name'] : null,
      startLocation: json.containsKey('startLocation')
          ? Location.fromJson(json['startLocation'])
          : null,
      endLocation: json.containsKey('endLocation')
          ? Location.fromJson(json['endLocation'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'type': type,
      'object': object.toJson(),
    };
    if (name != null) {
      json['name'] = name;
    }
    if (startLocation != null) {
      json['startLocation'] = startLocation.toJson();
    }
    if (endLocation != null) {
      json['endLocation'] = endLocation.toJson();
    }
    return json;
  }
}

class ScopeType {
  static const ScopeType global = ScopeType._('global');
  static const ScopeType local = ScopeType._('local');
  static const ScopeType with$ = ScopeType._('with');
  static const ScopeType closure = ScopeType._('closure');
  static const ScopeType catch$ = ScopeType._('catch');
  static const ScopeType block = ScopeType._('block');
  static const ScopeType script = ScopeType._('script');
  static const ScopeType eval = ScopeType._('eval');
  static const ScopeType module = ScopeType._('module');
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
  };

  final String value;

  const ScopeType._(this.value);

  factory ScopeType.fromJson(String value) => values[value];

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

  SearchMatch({@required this.lineNumber, @required this.lineContent});

  factory SearchMatch.fromJson(Map<String, dynamic> json) {
    return SearchMatch(
      lineNumber: json['lineNumber'],
      lineContent: json['lineContent'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'lineNumber': lineNumber,
      'lineContent': lineContent,
    };
    return json;
  }
}

class BreakLocation {
  /// Script identifier as reported in the `Debugger.scriptParsed`.
  final runtime.ScriptId scriptId;

  /// Line number in the script (0-based).
  final int lineNumber;

  /// Column number in the script (0-based).
  final int columnNumber;

  final BreakLocationType type;

  BreakLocation(
      {@required this.scriptId,
      @required this.lineNumber,
      this.columnNumber,
      this.type});

  factory BreakLocation.fromJson(Map<String, dynamic> json) {
    return BreakLocation(
      scriptId: runtime.ScriptId.fromJson(json['scriptId']),
      lineNumber: json['lineNumber'],
      columnNumber:
          json.containsKey('columnNumber') ? json['columnNumber'] : null,
      type: json.containsKey('type')
          ? BreakLocationType.fromJson(json['type'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'scriptId': scriptId.toJson(),
      'lineNumber': lineNumber,
    };
    if (columnNumber != null) {
      json['columnNumber'] = columnNumber;
    }
    if (type != null) {
      json['type'] = type;
    }
    return json;
  }
}

class BreakLocationType {
  static const BreakLocationType debuggerStatement =
      BreakLocationType._('debuggerStatement');
  static const BreakLocationType call = BreakLocationType._('call');
  static const BreakLocationType return$ = BreakLocationType._('return');
  static const values = {
    'debuggerStatement': debuggerStatement,
    'call': call,
    'return': return$,
  };

  final String value;

  const BreakLocationType._(this.value);

  factory BreakLocationType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is BreakLocationType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class PausedEventReason {
  static const PausedEventReason xhr = PausedEventReason._('XHR');
  static const PausedEventReason dom = PausedEventReason._('DOM');
  static const PausedEventReason eventListener =
      PausedEventReason._('EventListener');
  static const PausedEventReason exception = PausedEventReason._('exception');
  static const PausedEventReason assert$ = PausedEventReason._('assert');
  static const PausedEventReason debugCommand =
      PausedEventReason._('debugCommand');
  static const PausedEventReason promiseRejection =
      PausedEventReason._('promiseRejection');
  static const PausedEventReason oom = PausedEventReason._('OOM');
  static const PausedEventReason other = PausedEventReason._('other');
  static const PausedEventReason ambiguous = PausedEventReason._('ambiguous');
  static const values = {
    'XHR': xhr,
    'DOM': dom,
    'EventListener': eventListener,
    'exception': exception,
    'assert': assert$,
    'debugCommand': debugCommand,
    'promiseRejection': promiseRejection,
    'OOM': oom,
    'other': other,
    'ambiguous': ambiguous,
  };

  final String value;

  const PausedEventReason._(this.value);

  factory PausedEventReason.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is PausedEventReason && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
