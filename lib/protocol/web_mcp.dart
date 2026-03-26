import 'dart:async';
import '../src/connection.dart';
import 'dom.dart' as dom;
import 'page.dart' as page;
import 'runtime.dart' as runtime;

class WebMCPApi {
  final Client _client;

  WebMCPApi(this._client);

  /// Event fired when new tools are added.
  Stream<List<Tool>> get onToolsAdded => _client.onEvent
      .where((event) => event.name == 'WebMCP.toolsAdded')
      .map(
        (event) => (event.parameters['tools'] as List)
            .map((e) => Tool.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Event fired when tools are removed.
  Stream<List<Tool>> get onToolsRemoved => _client.onEvent
      .where((event) => event.name == 'WebMCP.toolsRemoved')
      .map(
        (event) => (event.parameters['tools'] as List)
            .map((e) => Tool.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Enables the WebMCP domain, allowing events to be sent. Enabling the domain will trigger a toolsAdded event for
  /// all currently registered tools.
  Future<void> enable() async {
    await _client.send('WebMCP.enable');
  }
}

/// Tool annotations
class Annotation {
  /// A hint indicating that the tool does not modify any state.
  final bool? readOnly;

  /// If the declarative tool was declared with the autosubmit attribute.
  final bool? autosubmit;

  Annotation({this.readOnly, this.autosubmit});

  factory Annotation.fromJson(Map<String, dynamic> json) {
    return Annotation(
      readOnly: json.containsKey('readOnly') ? json['readOnly'] as bool : null,
      autosubmit: json.containsKey('autosubmit')
          ? json['autosubmit'] as bool
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (readOnly != null) 'readOnly': readOnly,
      if (autosubmit != null) 'autosubmit': autosubmit,
    };
  }
}

/// Definition of a tool that can be invoked.
class Tool {
  /// Tool name.
  final String name;

  /// Tool description.
  final String description;

  /// Schema for the tool's input parameters.
  final Map<String, dynamic>? inputSchema;

  /// Optional annotations for the tool.
  final Annotation? annotations;

  /// Frame identifier associated with the tool registration.
  final page.FrameId frameId;

  /// Optional node ID for declarative tools.
  final dom.BackendNodeId? backendNodeId;

  /// The stack trace at the time of the registration.
  final runtime.StackTraceData? stackTrace;

  Tool({
    required this.name,
    required this.description,
    this.inputSchema,
    this.annotations,
    required this.frameId,
    this.backendNodeId,
    this.stackTrace,
  });

  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      name: json['name'] as String,
      description: json['description'] as String,
      inputSchema: json.containsKey('inputSchema')
          ? json['inputSchema'] as Map<String, dynamic>
          : null,
      annotations: json.containsKey('annotations')
          ? Annotation.fromJson(json['annotations'] as Map<String, dynamic>)
          : null,
      frameId: page.FrameId.fromJson(json['frameId'] as String),
      backendNodeId: json.containsKey('backendNodeId')
          ? dom.BackendNodeId.fromJson(json['backendNodeId'] as int)
          : null,
      stackTrace: json.containsKey('stackTrace')
          ? runtime.StackTraceData.fromJson(
              json['stackTrace'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'frameId': frameId.toJson(),
      if (inputSchema != null) 'inputSchema': inputSchema,
      if (annotations != null) 'annotations': annotations!.toJson(),
      if (backendNodeId != null) 'backendNodeId': backendNodeId!.toJson(),
      if (stackTrace != null) 'stackTrace': stackTrace!.toJson(),
    };
  }
}
