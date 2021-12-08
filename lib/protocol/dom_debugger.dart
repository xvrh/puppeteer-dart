import 'dart:async';
import '../src/connection.dart';
import 'dom.dart' as dom;
import 'runtime.dart' as runtime;

/// DOM debugging allows setting breakpoints on particular DOM operations and events. JavaScript
/// execution will stop on these operations as if there was a regular breakpoint set.
class DOMDebuggerApi {
  final Client _client;

  DOMDebuggerApi(this._client);

  /// Returns event listeners of the given object.
  /// [objectId] Identifier of the object to return listeners for.
  /// [depth] The maximum depth at which Node children should be retrieved, defaults to 1. Use -1 for the
  /// entire subtree or provide an integer larger than 0.
  /// [pierce] Whether or not iframes and shadow roots should be traversed when returning the subtree
  /// (default is false). Reports listeners for all contexts if pierce is enabled.
  /// Returns: Array of relevant listeners.
  Future<List<EventListener>> getEventListeners(runtime.RemoteObjectId objectId,
      {int? depth, bool? pierce}) async {
    var result = await _client.send('DOMDebugger.getEventListeners', {
      'objectId': objectId,
      if (depth != null) 'depth': depth,
      if (pierce != null) 'pierce': pierce,
    });
    return (result['listeners'] as List)
        .map((e) => EventListener.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Removes DOM breakpoint that was set using `setDOMBreakpoint`.
  /// [nodeId] Identifier of the node to remove breakpoint from.
  /// [type] Type of the breakpoint to remove.
  Future<void> removeDOMBreakpoint(
      dom.NodeId nodeId, DOMBreakpointType type) async {
    await _client.send('DOMDebugger.removeDOMBreakpoint', {
      'nodeId': nodeId,
      'type': type,
    });
  }

  /// Removes breakpoint on particular DOM event.
  /// [eventName] Event name.
  /// [targetName] EventTarget interface name.
  Future<void> removeEventListenerBreakpoint(String eventName,
      {String? targetName}) async {
    await _client.send('DOMDebugger.removeEventListenerBreakpoint', {
      'eventName': eventName,
      if (targetName != null) 'targetName': targetName,
    });
  }

  /// Removes breakpoint on particular native event.
  /// [eventName] Instrumentation name to stop on.
  Future<void> removeInstrumentationBreakpoint(String eventName) async {
    await _client.send('DOMDebugger.removeInstrumentationBreakpoint', {
      'eventName': eventName,
    });
  }

  /// Removes breakpoint from XMLHttpRequest.
  /// [url] Resource URL substring.
  Future<void> removeXHRBreakpoint(String url) async {
    await _client.send('DOMDebugger.removeXHRBreakpoint', {
      'url': url,
    });
  }

  /// Sets breakpoint on particular CSP violations.
  /// [violationTypes] CSP Violations to stop upon.
  Future<void> setBreakOnCSPViolation(
      List<CSPViolationType> violationTypes) async {
    await _client.send('DOMDebugger.setBreakOnCSPViolation', {
      'violationTypes': [...violationTypes],
    });
  }

  /// Sets breakpoint on particular operation with DOM.
  /// [nodeId] Identifier of the node to set breakpoint on.
  /// [type] Type of the operation to stop upon.
  Future<void> setDOMBreakpoint(
      dom.NodeId nodeId, DOMBreakpointType type) async {
    await _client.send('DOMDebugger.setDOMBreakpoint', {
      'nodeId': nodeId,
      'type': type,
    });
  }

  /// Sets breakpoint on particular DOM event.
  /// [eventName] DOM Event name to stop on (any DOM event will do).
  /// [targetName] EventTarget interface name to stop on. If equal to `"*"` or not provided, will stop on any
  /// EventTarget.
  Future<void> setEventListenerBreakpoint(String eventName,
      {String? targetName}) async {
    await _client.send('DOMDebugger.setEventListenerBreakpoint', {
      'eventName': eventName,
      if (targetName != null) 'targetName': targetName,
    });
  }

  /// Sets breakpoint on particular native event.
  /// [eventName] Instrumentation name to stop on.
  Future<void> setInstrumentationBreakpoint(String eventName) async {
    await _client.send('DOMDebugger.setInstrumentationBreakpoint', {
      'eventName': eventName,
    });
  }

  /// Sets breakpoint on XMLHttpRequest.
  /// [url] Resource URL substring. All XHRs having this substring in the URL will get stopped upon.
  Future<void> setXHRBreakpoint(String url) async {
    await _client.send('DOMDebugger.setXHRBreakpoint', {
      'url': url,
    });
  }
}

/// DOM breakpoint type.
class DOMBreakpointType {
  static const subtreeModified = DOMBreakpointType._('subtree-modified');
  static const attributeModified = DOMBreakpointType._('attribute-modified');
  static const nodeRemoved = DOMBreakpointType._('node-removed');
  static const values = {
    'subtree-modified': subtreeModified,
    'attribute-modified': attributeModified,
    'node-removed': nodeRemoved,
  };

  final String value;

  const DOMBreakpointType._(this.value);

  factory DOMBreakpointType.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is DOMBreakpointType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// CSP Violation type.
class CSPViolationType {
  static const trustedtypeSinkViolation =
      CSPViolationType._('trustedtype-sink-violation');
  static const trustedtypePolicyViolation =
      CSPViolationType._('trustedtype-policy-violation');
  static const values = {
    'trustedtype-sink-violation': trustedtypeSinkViolation,
    'trustedtype-policy-violation': trustedtypePolicyViolation,
  };

  final String value;

  const CSPViolationType._(this.value);

  factory CSPViolationType.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CSPViolationType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Object event listener.
class EventListener {
  /// `EventListener`'s type.
  final String type;

  /// `EventListener`'s useCapture.
  final bool useCapture;

  /// `EventListener`'s passive flag.
  final bool passive;

  /// `EventListener`'s once flag.
  final bool once;

  /// Script id of the handler code.
  final runtime.ScriptId scriptId;

  /// Line number in the script (0-based).
  final int lineNumber;

  /// Column number in the script (0-based).
  final int columnNumber;

  /// Event handler function value.
  final runtime.RemoteObject? handler;

  /// Event original handler function value.
  final runtime.RemoteObject? originalHandler;

  /// Node the listener is added to (if any).
  final dom.BackendNodeId? backendNodeId;

  EventListener(
      {required this.type,
      required this.useCapture,
      required this.passive,
      required this.once,
      required this.scriptId,
      required this.lineNumber,
      required this.columnNumber,
      this.handler,
      this.originalHandler,
      this.backendNodeId});

  factory EventListener.fromJson(Map<String, dynamic> json) {
    return EventListener(
      type: json['type'] as String,
      useCapture: json['useCapture'] as bool? ?? false,
      passive: json['passive'] as bool? ?? false,
      once: json['once'] as bool? ?? false,
      scriptId: runtime.ScriptId.fromJson(json['scriptId'] as String),
      lineNumber: json['lineNumber'] as int,
      columnNumber: json['columnNumber'] as int,
      handler: json.containsKey('handler')
          ? runtime.RemoteObject.fromJson(
              json['handler'] as Map<String, dynamic>)
          : null,
      originalHandler: json.containsKey('originalHandler')
          ? runtime.RemoteObject.fromJson(
              json['originalHandler'] as Map<String, dynamic>)
          : null,
      backendNodeId: json.containsKey('backendNodeId')
          ? dom.BackendNodeId.fromJson(json['backendNodeId'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'useCapture': useCapture,
      'passive': passive,
      'once': once,
      'scriptId': scriptId.toJson(),
      'lineNumber': lineNumber,
      'columnNumber': columnNumber,
      if (handler != null) 'handler': handler!.toJson(),
      if (originalHandler != null) 'originalHandler': originalHandler!.toJson(),
      if (backendNodeId != null) 'backendNodeId': backendNodeId!.toJson(),
    };
  }
}
