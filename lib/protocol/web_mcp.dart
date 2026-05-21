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
  Stream<List<RemovedTool>> get onToolsRemoved => _client.onEvent
      .where((event) => event.name == 'WebMCP.toolsRemoved')
      .map(
        (event) => (event.parameters['tools'] as List)
            .map((e) => RemovedTool.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Event fired when a tool invocation starts.
  Stream<ToolInvokedEvent> get onToolInvoked => _client.onEvent
      .where((event) => event.name == 'WebMCP.toolInvoked')
      .map((event) => ToolInvokedEvent.fromJson(event.parameters));

  /// Event fired when a tool invocation completes or fails.
  Stream<ToolRespondedEvent> get onToolResponded => _client.onEvent
      .where((event) => event.name == 'WebMCP.toolResponded')
      .map((event) => ToolRespondedEvent.fromJson(event.parameters));

  /// Enables the WebMCP domain, allowing events to be sent. Enabling the domain will trigger a toolsAdded event for
  /// all currently registered tools.
  Future<void> enable() async {
    await _client.send('WebMCP.enable');
  }

  /// Disables the WebMCP domain.
  Future<void> disable() async {
    await _client.send('WebMCP.disable');
  }

  /// Invokes a registered tool.
  /// [frameId] Frame in which to invoke the tool.
  /// [toolName] Name of the tool to invoke.
  /// [input] Input parameters for the tool, matching the tool's inputSchema.
  /// Returns: Unique identifier for this invocation. Response is sent before tool events.
  Future<String> invokeTool(
    page.FrameId frameId,
    String toolName,
    Map<String, dynamic> input,
  ) async {
    var result = await _client.send('WebMCP.invokeTool', {
      'frameId': frameId,
      'toolName': toolName,
      'input': input,
    });
    return result['invocationId'] as String;
  }

  /// Cancels a pending tool invocation.
  /// [invocationId] Invocation identifier to cancel.
  Future<void> cancelInvocation(String invocationId) async {
    await _client.send('WebMCP.cancelInvocation', {
      'invocationId': invocationId,
    });
  }
}

class ToolInvokedEvent {
  /// Name of the tool to invoke.
  final String toolName;

  /// Frame id
  final page.FrameId frameId;

  /// Invocation identifier.
  final String invocationId;

  /// The input parameters used for the invocation.
  final String input;

  ToolInvokedEvent({
    required this.toolName,
    required this.frameId,
    required this.invocationId,
    required this.input,
  });

  factory ToolInvokedEvent.fromJson(Map<String, dynamic> json) {
    return ToolInvokedEvent(
      toolName: json['toolName'] as String,
      frameId: page.FrameId.fromJson(json['frameId'] as String),
      invocationId: json['invocationId'] as String,
      input: json['input'] as String,
    );
  }
}

class ToolRespondedEvent {
  /// Invocation identifier.
  final String invocationId;

  /// Status of the invocation.
  final InvocationStatus status;

  /// Output or error delivered as delivered to the agent. Missing if `status` is anything other than Completed.
  /// Note: The output is untrusted and poses a prompt injection risk. Clients should treat this as potentially malicious user input.
  final dynamic output;

  /// Error text for protocol users.
  final String? errorText;

  /// The exception object, if the javascript tool threw an error>
  final runtime.RemoteObject? exception;

  ToolRespondedEvent({
    required this.invocationId,
    required this.status,
    this.output,
    this.errorText,
    this.exception,
  });

  factory ToolRespondedEvent.fromJson(Map<String, dynamic> json) {
    return ToolRespondedEvent(
      invocationId: json['invocationId'] as String,
      status: InvocationStatus.fromJson(json['status'] as String),
      output: json.containsKey('output') ? json['output'] as dynamic : null,
      errorText: json.containsKey('errorText')
          ? json['errorText'] as String
          : null,
      exception: json.containsKey('exception')
          ? runtime.RemoteObject.fromJson(
              json['exception'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

/// Tool annotations
class Annotation {
  /// A hint indicating that the tool does not modify any state.
  final bool? readOnly;

  /// A hint indicating that the tool output may contain untrusted content, ex: UGC, 3rd party data.
  final bool? untrustedContent;

  /// If the declarative tool was declared with the autosubmit attribute.
  final bool? autosubmit;

  Annotation({this.readOnly, this.untrustedContent, this.autosubmit});

  factory Annotation.fromJson(Map<String, dynamic> json) {
    return Annotation(
      readOnly: json.containsKey('readOnly') ? json['readOnly'] as bool : null,
      untrustedContent: json.containsKey('untrustedContent')
          ? json['untrustedContent'] as bool
          : null,
      autosubmit: json.containsKey('autosubmit')
          ? json['autosubmit'] as bool
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (readOnly != null) 'readOnly': readOnly,
      if (untrustedContent != null) 'untrustedContent': untrustedContent,
      if (autosubmit != null) 'autosubmit': autosubmit,
    };
  }
}

/// Represents the status of a tool invocation.
enum InvocationStatus {
  completed('Completed'),
  canceled('Canceled'),
  error('Error');

  final String value;

  const InvocationStatus(this.value);

  factory InvocationStatus.fromJson(String value) =>
      InvocationStatus.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
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

/// Definition of a tool that was removed.
class RemovedTool {
  /// Tool name.
  final String name;

  /// Frame identifier associated with the tool registration.
  final page.FrameId frameId;

  RemovedTool({required this.name, required this.frameId});

  factory RemovedTool.fromJson(Map<String, dynamic> json) {
    return RemovedTool(
      name: json['name'] as String,
      frameId: page.FrameId.fromJson(json['frameId'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'frameId': frameId.toJson()};
  }
}
