/// DOM debugging allows setting breakpoints on particular DOM operations and events. JavaScript execution will stop on these operations as if there was a regular breakpoint set.

import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';
import '../runtime.dart' as runtime;
import 'dom.dart' as dom;

class DOMDebuggerManager {
  final Session _client;

  DOMDebuggerManager(this._client);

  /// Sets breakpoint on particular operation with DOM.
  /// [nodeId] Identifier of the node to set breakpoint on.
  /// [type] Type of the operation to stop upon.
  Future setDOMBreakpoint(
    dom.NodeId nodeId,
    DOMBreakpointType type,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
      'type': type.toJson(),
    };
    await _client.send('DOMDebugger.setDOMBreakpoint', parameters);
  }

  /// Removes DOM breakpoint that was set using <code>setDOMBreakpoint</code>.
  /// [nodeId] Identifier of the node to remove breakpoint from.
  /// [type] Type of the breakpoint to remove.
  Future removeDOMBreakpoint(
    dom.NodeId nodeId,
    DOMBreakpointType type,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
      'type': type.toJson(),
    };
    await _client.send('DOMDebugger.removeDOMBreakpoint', parameters);
  }

  /// Sets breakpoint on particular DOM event.
  /// [eventName] DOM Event name to stop on (any DOM event will do).
  /// [targetName] EventTarget interface name to stop on. If equal to <code>"*"</code> or not provided, will stop on any EventTarget.
  Future setEventListenerBreakpoint(
    String eventName, {
    String targetName,
  }) async {
    Map parameters = {
      'eventName': eventName.toString(),
    };
    if (targetName != null) {
      parameters['targetName'] = targetName.toString();
    }
    await _client.send('DOMDebugger.setEventListenerBreakpoint', parameters);
  }

  /// Removes breakpoint on particular DOM event.
  /// [eventName] Event name.
  /// [targetName] EventTarget interface name.
  Future removeEventListenerBreakpoint(
    String eventName, {
    String targetName,
  }) async {
    Map parameters = {
      'eventName': eventName.toString(),
    };
    if (targetName != null) {
      parameters['targetName'] = targetName.toString();
    }
    await _client.send('DOMDebugger.removeEventListenerBreakpoint', parameters);
  }

  /// Sets breakpoint on particular native event.
  /// [eventName] Instrumentation name to stop on.
  Future setInstrumentationBreakpoint(
    String eventName,
  ) async {
    Map parameters = {
      'eventName': eventName.toString(),
    };
    await _client.send('DOMDebugger.setInstrumentationBreakpoint', parameters);
  }

  /// Removes breakpoint on particular native event.
  /// [eventName] Instrumentation name to stop on.
  Future removeInstrumentationBreakpoint(
    String eventName,
  ) async {
    Map parameters = {
      'eventName': eventName.toString(),
    };
    await _client.send(
        'DOMDebugger.removeInstrumentationBreakpoint', parameters);
  }

  /// Sets breakpoint on XMLHttpRequest.
  /// [url] Resource URL substring. All XHRs having this substring in the URL will get stopped upon.
  Future setXHRBreakpoint(
    String url,
  ) async {
    Map parameters = {
      'url': url.toString(),
    };
    await _client.send('DOMDebugger.setXHRBreakpoint', parameters);
  }

  /// Removes breakpoint from XMLHttpRequest.
  /// [url] Resource URL substring.
  Future removeXHRBreakpoint(
    String url,
  ) async {
    Map parameters = {
      'url': url.toString(),
    };
    await _client.send('DOMDebugger.removeXHRBreakpoint', parameters);
  }

  /// Returns event listeners of the given object.
  /// [objectId] Identifier of the object to return listeners for.
  /// [depth] The maximum depth at which Node children should be retrieved, defaults to 1. Use -1 for the entire subtree or provide an integer larger than 0.
  /// [pierce] Whether or not iframes and shadow roots should be traversed when returning the subtree (default is false). Reports listeners for all contexts if pierce is enabled.
  /// Return: Array of relevant listeners.
  Future<List<EventListener>> getEventListeners(
    runtime.RemoteObjectId objectId, {
    int depth,
    bool pierce,
  }) async {
    Map parameters = {
      'objectId': objectId.toJson(),
    };
    if (depth != null) {
      parameters['depth'] = depth.toString();
    }
    if (pierce != null) {
      parameters['pierce'] = pierce.toString();
    }
    await _client.send('DOMDebugger.getEventListeners', parameters);
  }
}

/// DOM breakpoint type.
class DOMBreakpointType {
  static const DOMBreakpointType subtreeModified =
      const DOMBreakpointType._('subtree-modified');
  static const DOMBreakpointType attributeModified =
      const DOMBreakpointType._('attribute-modified');
  static const DOMBreakpointType nodeRemoved =
      const DOMBreakpointType._('node-removed');

  final String value;

  const DOMBreakpointType._(this.value);

  String toJson() => value;
}

/// Object event listener.
class EventListener {
  /// <code>EventListener</code>'s type.
  final String type;

  /// <code>EventListener</code>'s useCapture.
  final bool useCapture;

  /// <code>EventListener</code>'s passive flag.
  final bool passive;

  /// <code>EventListener</code>'s once flag.
  final bool once;

  /// Script id of the handler code.
  final runtime.ScriptId scriptId;

  /// Line number in the script (0-based).
  final int lineNumber;

  /// Column number in the script (0-based).
  final int columnNumber;

  /// Event handler function value.
  final runtime.RemoteObject handler;

  /// Event original handler function value.
  final runtime.RemoteObject originalHandler;

  /// Node the listener is added to (if any).
  final dom.BackendNodeId backendNodeId;

  EventListener({
    @required this.type,
    @required this.useCapture,
    @required this.passive,
    @required this.once,
    @required this.scriptId,
    @required this.lineNumber,
    @required this.columnNumber,
    this.handler,
    this.originalHandler,
    this.backendNodeId,
  });

  Map toJson() {
    Map json = {
      'type': type.toString(),
      'useCapture': useCapture.toString(),
      'passive': passive.toString(),
      'once': once.toString(),
      'scriptId': scriptId.toJson(),
      'lineNumber': lineNumber.toString(),
      'columnNumber': columnNumber.toString(),
    };
    if (handler != null) {
      json['handler'] = handler.toJson();
    }
    if (originalHandler != null) {
      json['originalHandler'] = originalHandler.toJson();
    }
    if (backendNodeId != null) {
      json['backendNodeId'] = backendNodeId.toJson();
    }
    return json;
  }
}
