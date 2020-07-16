import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'dom.dart' as dom;
import 'page.dart' as page;
import 'runtime.dart' as runtime;

/// This domain provides various functionality related to drawing atop the inspected page.
class OverlayApi {
  final Client _client;

  OverlayApi(this._client);

  /// Fired when the node should be inspected. This happens after call to `setInspectMode` or when
  /// user manually inspects an element.
  Stream<dom.BackendNodeId> get onInspectNodeRequested => _client.onEvent
      .where((event) => event.name == 'Overlay.inspectNodeRequested')
      .map((event) =>
          dom.BackendNodeId.fromJson(event.parameters['backendNodeId'] as int));

  /// Fired when the node should be highlighted. This happens after call to `setInspectMode`.
  Stream<dom.NodeId> get onNodeHighlightRequested => _client.onEvent
      .where((event) => event.name == 'Overlay.nodeHighlightRequested')
      .map((event) => dom.NodeId.fromJson(event.parameters['nodeId'] as int));

  /// Fired when user asks to capture screenshot of some area on the page.
  Stream<page.Viewport> get onScreenshotRequested => _client.onEvent
      .where((event) => event.name == 'Overlay.screenshotRequested')
      .map((event) => page.Viewport.fromJson(
          event.parameters['viewport'] as Map<String, dynamic>));

  /// Fired when user cancels the inspect mode.
  Stream get onInspectModeCanceled => _client.onEvent
      .where((event) => event.name == 'Overlay.inspectModeCanceled');

  /// Disables domain notifications.
  Future<void> disable() async {
    await _client.send('Overlay.disable');
  }

  /// Enables domain notifications.
  Future<void> enable() async {
    await _client.send('Overlay.enable');
  }

  /// For testing.
  /// [nodeId] Id of the node to get highlight object for.
  /// [includeDistance] Whether to include distance info.
  /// [includeStyle] Whether to include style info.
  /// [colorFormat] The color format to get config with (default: hex)
  /// Returns: Highlight data for the node.
  Future<Map<String, dynamic>> getHighlightObjectForTest(dom.NodeId nodeId,
      {bool includeDistance,
      bool includeStyle,
      ColorFormat colorFormat}) async {
    var result = await _client.send('Overlay.getHighlightObjectForTest', {
      'nodeId': nodeId,
      if (includeDistance != null) 'includeDistance': includeDistance,
      if (includeStyle != null) 'includeStyle': includeStyle,
      if (colorFormat != null) 'colorFormat': colorFormat,
    });
    return result['highlight'] as Map<String, dynamic>;
  }

  /// Hides any highlight.
  Future<void> hideHighlight() async {
    await _client.send('Overlay.hideHighlight');
  }

  /// Highlights owner element of the frame with given id.
  /// [frameId] Identifier of the frame to highlight.
  /// [contentColor] The content box highlight fill color (default: transparent).
  /// [contentOutlineColor] The content box highlight outline color (default: transparent).
  Future<void> highlightFrame(page.FrameId frameId,
      {dom.RGBA contentColor, dom.RGBA contentOutlineColor}) async {
    await _client.send('Overlay.highlightFrame', {
      'frameId': frameId,
      if (contentColor != null) 'contentColor': contentColor,
      if (contentOutlineColor != null)
        'contentOutlineColor': contentOutlineColor,
    });
  }

  /// Highlights DOM node with given id or with the given JavaScript object wrapper. Either nodeId or
  /// objectId must be specified.
  /// [highlightConfig] A descriptor for the highlight appearance.
  /// [nodeId] Identifier of the node to highlight.
  /// [backendNodeId] Identifier of the backend node to highlight.
  /// [objectId] JavaScript object id of the node to be highlighted.
  /// [selector] Selectors to highlight relevant nodes.
  Future<void> highlightNode(HighlightConfig highlightConfig,
      {dom.NodeId nodeId,
      dom.BackendNodeId backendNodeId,
      runtime.RemoteObjectId objectId,
      String selector}) async {
    await _client.send('Overlay.highlightNode', {
      'highlightConfig': highlightConfig,
      if (nodeId != null) 'nodeId': nodeId,
      if (backendNodeId != null) 'backendNodeId': backendNodeId,
      if (objectId != null) 'objectId': objectId,
      if (selector != null) 'selector': selector,
    });
  }

  /// Highlights given quad. Coordinates are absolute with respect to the main frame viewport.
  /// [quad] Quad to highlight
  /// [color] The highlight fill color (default: transparent).
  /// [outlineColor] The highlight outline color (default: transparent).
  Future<void> highlightQuad(dom.Quad quad,
      {dom.RGBA color, dom.RGBA outlineColor}) async {
    await _client.send('Overlay.highlightQuad', {
      'quad': quad,
      if (color != null) 'color': color,
      if (outlineColor != null) 'outlineColor': outlineColor,
    });
  }

  /// Highlights given rectangle. Coordinates are absolute with respect to the main frame viewport.
  /// [x] X coordinate
  /// [y] Y coordinate
  /// [width] Rectangle width
  /// [height] Rectangle height
  /// [color] The highlight fill color (default: transparent).
  /// [outlineColor] The highlight outline color (default: transparent).
  Future<void> highlightRect(int x, int y, int width, int height,
      {dom.RGBA color, dom.RGBA outlineColor}) async {
    await _client.send('Overlay.highlightRect', {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      if (color != null) 'color': color,
      if (outlineColor != null) 'outlineColor': outlineColor,
    });
  }

  /// Enters the 'inspect' mode. In this mode, elements that user is hovering over are highlighted.
  /// Backend then generates 'inspectNodeRequested' event upon element selection.
  /// [mode] Set an inspection mode.
  /// [highlightConfig] A descriptor for the highlight appearance of hovered-over nodes. May be omitted if `enabled
  /// == false`.
  Future<void> setInspectMode(InspectMode mode,
      {HighlightConfig highlightConfig}) async {
    await _client.send('Overlay.setInspectMode', {
      'mode': mode,
      if (highlightConfig != null) 'highlightConfig': highlightConfig,
    });
  }

  /// Highlights owner element of all frames detected to be ads.
  /// [show] True for showing ad highlights
  Future<void> setShowAdHighlights(bool show) async {
    await _client.send('Overlay.setShowAdHighlights', {
      'show': show,
    });
  }

  /// [message] The message to display, also triggers resume and step over controls.
  Future<void> setPausedInDebuggerMessage({String message}) async {
    await _client.send('Overlay.setPausedInDebuggerMessage', {
      if (message != null) 'message': message,
    });
  }

  /// Requests that backend shows debug borders on layers
  /// [show] True for showing debug borders
  Future<void> setShowDebugBorders(bool show) async {
    await _client.send('Overlay.setShowDebugBorders', {
      'show': show,
    });
  }

  /// Requests that backend shows the FPS counter
  /// [show] True for showing the FPS counter
  Future<void> setShowFPSCounter(bool show) async {
    await _client.send('Overlay.setShowFPSCounter', {
      'show': show,
    });
  }

  /// Requests that backend shows paint rectangles
  /// [result] True for showing paint rectangles
  Future<void> setShowPaintRects(bool result) async {
    await _client.send('Overlay.setShowPaintRects', {
      'result': result,
    });
  }

  /// Requests that backend shows layout shift regions
  /// [result] True for showing layout shift regions
  Future<void> setShowLayoutShiftRegions(bool result) async {
    await _client.send('Overlay.setShowLayoutShiftRegions', {
      'result': result,
    });
  }

  /// Requests that backend shows scroll bottleneck rects
  /// [show] True for showing scroll bottleneck rects
  Future<void> setShowScrollBottleneckRects(bool show) async {
    await _client.send('Overlay.setShowScrollBottleneckRects', {
      'show': show,
    });
  }

  /// Requests that backend shows hit-test borders on layers
  /// [show] True for showing hit-test borders
  Future<void> setShowHitTestBorders(bool show) async {
    await _client.send('Overlay.setShowHitTestBorders', {
      'show': show,
    });
  }

  /// Paints viewport size upon main frame resize.
  /// [show] Whether to paint size or not.
  Future<void> setShowViewportSizeOnResize(bool show) async {
    await _client.send('Overlay.setShowViewportSizeOnResize', {
      'show': show,
    });
  }

  /// Add a dual screen device hinge
  /// [hingeConfig] hinge data, null means hideHinge
  Future<void> setShowHinge({HingeConfig hingeConfig}) async {
    await _client.send('Overlay.setShowHinge', {
      if (hingeConfig != null) 'hingeConfig': hingeConfig,
    });
  }
}

/// Configuration data for the highlighting of Grid elements.
class GridHighlightConfig {
  /// Whether the extension lines from grid cells to the rulers should be shown (default: false).
  final bool showGridExtensionLines;

  /// The grid container border highlight color (default: transparent).
  final dom.RGBA gridBorderColor;

  /// The cell border color (default: transparent).
  final dom.RGBA cellBorderColor;

  /// Whether the grid border is dashed (default: false).
  final bool gridBorderDash;

  /// Whether the cell border is dashed (default: false).
  final bool cellBorderDash;

  /// The row gap highlight fill color (default: transparent).
  final dom.RGBA rowGapColor;

  /// The row gap hatching fill color (default: transparent).
  final dom.RGBA rowHatchColor;

  /// The column gap highlight fill color (default: transparent).
  final dom.RGBA columnGapColor;

  /// The column gap hatching fill color (default: transparent).
  final dom.RGBA columnHatchColor;

  GridHighlightConfig(
      {this.showGridExtensionLines,
      this.gridBorderColor,
      this.cellBorderColor,
      this.gridBorderDash,
      this.cellBorderDash,
      this.rowGapColor,
      this.rowHatchColor,
      this.columnGapColor,
      this.columnHatchColor});

  factory GridHighlightConfig.fromJson(Map<String, dynamic> json) {
    return GridHighlightConfig(
      showGridExtensionLines: json.containsKey('showGridExtensionLines')
          ? json['showGridExtensionLines'] as bool
          : null,
      gridBorderColor: json.containsKey('gridBorderColor')
          ? dom.RGBA.fromJson(json['gridBorderColor'] as Map<String, dynamic>)
          : null,
      cellBorderColor: json.containsKey('cellBorderColor')
          ? dom.RGBA.fromJson(json['cellBorderColor'] as Map<String, dynamic>)
          : null,
      gridBorderDash: json.containsKey('gridBorderDash')
          ? json['gridBorderDash'] as bool
          : null,
      cellBorderDash: json.containsKey('cellBorderDash')
          ? json['cellBorderDash'] as bool
          : null,
      rowGapColor: json.containsKey('rowGapColor')
          ? dom.RGBA.fromJson(json['rowGapColor'] as Map<String, dynamic>)
          : null,
      rowHatchColor: json.containsKey('rowHatchColor')
          ? dom.RGBA.fromJson(json['rowHatchColor'] as Map<String, dynamic>)
          : null,
      columnGapColor: json.containsKey('columnGapColor')
          ? dom.RGBA.fromJson(json['columnGapColor'] as Map<String, dynamic>)
          : null,
      columnHatchColor: json.containsKey('columnHatchColor')
          ? dom.RGBA.fromJson(json['columnHatchColor'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (showGridExtensionLines != null)
        'showGridExtensionLines': showGridExtensionLines,
      if (gridBorderColor != null) 'gridBorderColor': gridBorderColor.toJson(),
      if (cellBorderColor != null) 'cellBorderColor': cellBorderColor.toJson(),
      if (gridBorderDash != null) 'gridBorderDash': gridBorderDash,
      if (cellBorderDash != null) 'cellBorderDash': cellBorderDash,
      if (rowGapColor != null) 'rowGapColor': rowGapColor.toJson(),
      if (rowHatchColor != null) 'rowHatchColor': rowHatchColor.toJson(),
      if (columnGapColor != null) 'columnGapColor': columnGapColor.toJson(),
      if (columnHatchColor != null)
        'columnHatchColor': columnHatchColor.toJson(),
    };
  }
}

/// Configuration data for the highlighting of page elements.
class HighlightConfig {
  /// Whether the node info tooltip should be shown (default: false).
  final bool showInfo;

  /// Whether the node styles in the tooltip (default: false).
  final bool showStyles;

  /// Whether the rulers should be shown (default: false).
  final bool showRulers;

  /// Whether the extension lines from node to the rulers should be shown (default: false).
  final bool showExtensionLines;

  /// The content box highlight fill color (default: transparent).
  final dom.RGBA contentColor;

  /// The padding highlight fill color (default: transparent).
  final dom.RGBA paddingColor;

  /// The border highlight fill color (default: transparent).
  final dom.RGBA borderColor;

  /// The margin highlight fill color (default: transparent).
  final dom.RGBA marginColor;

  /// The event target element highlight fill color (default: transparent).
  final dom.RGBA eventTargetColor;

  /// The shape outside fill color (default: transparent).
  final dom.RGBA shapeColor;

  /// The shape margin fill color (default: transparent).
  final dom.RGBA shapeMarginColor;

  /// The grid layout color (default: transparent).
  final dom.RGBA cssGridColor;

  /// The color format used to format color styles (default: hex).
  final ColorFormat colorFormat;

  /// The grid layout highlight configuration (default: all transparent).
  final GridHighlightConfig gridHighlightConfig;

  HighlightConfig(
      {this.showInfo,
      this.showStyles,
      this.showRulers,
      this.showExtensionLines,
      this.contentColor,
      this.paddingColor,
      this.borderColor,
      this.marginColor,
      this.eventTargetColor,
      this.shapeColor,
      this.shapeMarginColor,
      this.cssGridColor,
      this.colorFormat,
      this.gridHighlightConfig});

  factory HighlightConfig.fromJson(Map<String, dynamic> json) {
    return HighlightConfig(
      showInfo: json.containsKey('showInfo') ? json['showInfo'] as bool : null,
      showStyles:
          json.containsKey('showStyles') ? json['showStyles'] as bool : null,
      showRulers:
          json.containsKey('showRulers') ? json['showRulers'] as bool : null,
      showExtensionLines: json.containsKey('showExtensionLines')
          ? json['showExtensionLines'] as bool
          : null,
      contentColor: json.containsKey('contentColor')
          ? dom.RGBA.fromJson(json['contentColor'] as Map<String, dynamic>)
          : null,
      paddingColor: json.containsKey('paddingColor')
          ? dom.RGBA.fromJson(json['paddingColor'] as Map<String, dynamic>)
          : null,
      borderColor: json.containsKey('borderColor')
          ? dom.RGBA.fromJson(json['borderColor'] as Map<String, dynamic>)
          : null,
      marginColor: json.containsKey('marginColor')
          ? dom.RGBA.fromJson(json['marginColor'] as Map<String, dynamic>)
          : null,
      eventTargetColor: json.containsKey('eventTargetColor')
          ? dom.RGBA.fromJson(json['eventTargetColor'] as Map<String, dynamic>)
          : null,
      shapeColor: json.containsKey('shapeColor')
          ? dom.RGBA.fromJson(json['shapeColor'] as Map<String, dynamic>)
          : null,
      shapeMarginColor: json.containsKey('shapeMarginColor')
          ? dom.RGBA.fromJson(json['shapeMarginColor'] as Map<String, dynamic>)
          : null,
      cssGridColor: json.containsKey('cssGridColor')
          ? dom.RGBA.fromJson(json['cssGridColor'] as Map<String, dynamic>)
          : null,
      colorFormat: json.containsKey('colorFormat')
          ? ColorFormat.fromJson(json['colorFormat'] as String)
          : null,
      gridHighlightConfig: json.containsKey('gridHighlightConfig')
          ? GridHighlightConfig.fromJson(
              json['gridHighlightConfig'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (showInfo != null) 'showInfo': showInfo,
      if (showStyles != null) 'showStyles': showStyles,
      if (showRulers != null) 'showRulers': showRulers,
      if (showExtensionLines != null) 'showExtensionLines': showExtensionLines,
      if (contentColor != null) 'contentColor': contentColor.toJson(),
      if (paddingColor != null) 'paddingColor': paddingColor.toJson(),
      if (borderColor != null) 'borderColor': borderColor.toJson(),
      if (marginColor != null) 'marginColor': marginColor.toJson(),
      if (eventTargetColor != null)
        'eventTargetColor': eventTargetColor.toJson(),
      if (shapeColor != null) 'shapeColor': shapeColor.toJson(),
      if (shapeMarginColor != null)
        'shapeMarginColor': shapeMarginColor.toJson(),
      if (cssGridColor != null) 'cssGridColor': cssGridColor.toJson(),
      if (colorFormat != null) 'colorFormat': colorFormat.toJson(),
      if (gridHighlightConfig != null)
        'gridHighlightConfig': gridHighlightConfig.toJson(),
    };
  }
}

class ColorFormat {
  static const rgb = ColorFormat._('rgb');
  static const hsl = ColorFormat._('hsl');
  static const hex = ColorFormat._('hex');
  static const values = {
    'rgb': rgb,
    'hsl': hsl,
    'hex': hex,
  };

  final String value;

  const ColorFormat._(this.value);

  factory ColorFormat.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ColorFormat && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Configuration for dual screen hinge
class HingeConfig {
  /// A rectangle represent hinge
  final dom.Rect rect;

  /// The content box highlight fill color (default: a dark color).
  final dom.RGBA contentColor;

  /// The content box highlight outline color (default: transparent).
  final dom.RGBA outlineColor;

  HingeConfig({@required this.rect, this.contentColor, this.outlineColor});

  factory HingeConfig.fromJson(Map<String, dynamic> json) {
    return HingeConfig(
      rect: dom.Rect.fromJson(json['rect'] as Map<String, dynamic>),
      contentColor: json.containsKey('contentColor')
          ? dom.RGBA.fromJson(json['contentColor'] as Map<String, dynamic>)
          : null,
      outlineColor: json.containsKey('outlineColor')
          ? dom.RGBA.fromJson(json['outlineColor'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rect': rect.toJson(),
      if (contentColor != null) 'contentColor': contentColor.toJson(),
      if (outlineColor != null) 'outlineColor': outlineColor.toJson(),
    };
  }
}

class InspectMode {
  static const searchForNode = InspectMode._('searchForNode');
  static const searchForUaShadowDom = InspectMode._('searchForUAShadowDOM');
  static const captureAreaScreenshot = InspectMode._('captureAreaScreenshot');
  static const showDistances = InspectMode._('showDistances');
  static const none = InspectMode._('none');
  static const values = {
    'searchForNode': searchForNode,
    'searchForUAShadowDOM': searchForUaShadowDom,
    'captureAreaScreenshot': captureAreaScreenshot,
    'showDistances': showDistances,
    'none': none,
  };

  final String value;

  const InspectMode._(this.value);

  factory InspectMode.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is InspectMode && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
