import 'dart:async';
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
  /// [colorFormat] The color format to get config with (default: hex).
  /// [showAccessibilityInfo] Whether to show accessibility info (default: true).
  /// Returns: Highlight data for the node.
  Future<Map<String, dynamic>> getHighlightObjectForTest(dom.NodeId nodeId,
      {bool? includeDistance,
      bool? includeStyle,
      ColorFormat? colorFormat,
      bool? showAccessibilityInfo}) async {
    var result = await _client.send('Overlay.getHighlightObjectForTest', {
      'nodeId': nodeId,
      if (includeDistance != null) 'includeDistance': includeDistance,
      if (includeStyle != null) 'includeStyle': includeStyle,
      if (colorFormat != null) 'colorFormat': colorFormat,
      if (showAccessibilityInfo != null)
        'showAccessibilityInfo': showAccessibilityInfo,
    });
    return result['highlight'] as Map<String, dynamic>;
  }

  /// For Persistent Grid testing.
  /// [nodeIds] Ids of the node to get highlight object for.
  /// Returns: Grid Highlight data for the node ids provided.
  Future<Map<String, dynamic>> getGridHighlightObjectsForTest(
      List<dom.NodeId> nodeIds) async {
    var result = await _client.send('Overlay.getGridHighlightObjectsForTest', {
      'nodeIds': [...nodeIds],
    });
    return result['highlights'] as Map<String, dynamic>;
  }

  /// For Source Order Viewer testing.
  /// [nodeId] Id of the node to highlight.
  /// Returns: Source order highlight data for the node id provided.
  Future<Map<String, dynamic>> getSourceOrderHighlightObjectForTest(
      dom.NodeId nodeId) async {
    var result =
        await _client.send('Overlay.getSourceOrderHighlightObjectForTest', {
      'nodeId': nodeId,
    });
    return result['highlight'] as Map<String, dynamic>;
  }

  /// Hides any highlight.
  Future<void> hideHighlight() async {
    await _client.send('Overlay.hideHighlight');
  }

  /// Highlights owner element of the frame with given id.
  /// Deprecated: Doesn't work reliablity and cannot be fixed due to process
  /// separatation (the owner node might be in a different process). Determine
  /// the owner node in the client and use highlightNode.
  /// [frameId] Identifier of the frame to highlight.
  /// [contentColor] The content box highlight fill color (default: transparent).
  /// [contentOutlineColor] The content box highlight outline color (default: transparent).
  @Deprecated('This command is deprecated')
  Future<void> highlightFrame(page.FrameId frameId,
      {dom.RGBA? contentColor, dom.RGBA? contentOutlineColor}) async {
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
      {dom.NodeId? nodeId,
      dom.BackendNodeId? backendNodeId,
      runtime.RemoteObjectId? objectId,
      String? selector}) async {
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
      {dom.RGBA? color, dom.RGBA? outlineColor}) async {
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
      {dom.RGBA? color, dom.RGBA? outlineColor}) async {
    await _client.send('Overlay.highlightRect', {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      if (color != null) 'color': color,
      if (outlineColor != null) 'outlineColor': outlineColor,
    });
  }

  /// Highlights the source order of the children of the DOM node with given id or with the given
  /// JavaScript object wrapper. Either nodeId or objectId must be specified.
  /// [sourceOrderConfig] A descriptor for the appearance of the overlay drawing.
  /// [nodeId] Identifier of the node to highlight.
  /// [backendNodeId] Identifier of the backend node to highlight.
  /// [objectId] JavaScript object id of the node to be highlighted.
  Future<void> highlightSourceOrder(SourceOrderConfig sourceOrderConfig,
      {dom.NodeId? nodeId,
      dom.BackendNodeId? backendNodeId,
      runtime.RemoteObjectId? objectId}) async {
    await _client.send('Overlay.highlightSourceOrder', {
      'sourceOrderConfig': sourceOrderConfig,
      if (nodeId != null) 'nodeId': nodeId,
      if (backendNodeId != null) 'backendNodeId': backendNodeId,
      if (objectId != null) 'objectId': objectId,
    });
  }

  /// Enters the 'inspect' mode. In this mode, elements that user is hovering over are highlighted.
  /// Backend then generates 'inspectNodeRequested' event upon element selection.
  /// [mode] Set an inspection mode.
  /// [highlightConfig] A descriptor for the highlight appearance of hovered-over nodes. May be omitted if `enabled
  /// == false`.
  Future<void> setInspectMode(InspectMode mode,
      {HighlightConfig? highlightConfig}) async {
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
  Future<void> setPausedInDebuggerMessage({String? message}) async {
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

  /// Highlight multiple elements with the CSS Grid overlay.
  /// [gridNodeHighlightConfigs] An array of node identifiers and descriptors for the highlight appearance.
  Future<void> setShowGridOverlays(
      List<GridNodeHighlightConfig> gridNodeHighlightConfigs) async {
    await _client.send('Overlay.setShowGridOverlays', {
      'gridNodeHighlightConfigs': [...gridNodeHighlightConfigs],
    });
  }

  /// [flexNodeHighlightConfigs] An array of node identifiers and descriptors for the highlight appearance.
  Future<void> setShowFlexOverlays(
      List<FlexNodeHighlightConfig> flexNodeHighlightConfigs) async {
    await _client.send('Overlay.setShowFlexOverlays', {
      'flexNodeHighlightConfigs': [...flexNodeHighlightConfigs],
    });
  }

  /// [scrollSnapHighlightConfigs] An array of node identifiers and descriptors for the highlight appearance.
  Future<void> setShowScrollSnapOverlays(
      List<ScrollSnapHighlightConfig> scrollSnapHighlightConfigs) async {
    await _client.send('Overlay.setShowScrollSnapOverlays', {
      'scrollSnapHighlightConfigs': [...scrollSnapHighlightConfigs],
    });
  }

  /// [containerQueryHighlightConfigs] An array of node identifiers and descriptors for the highlight appearance.
  Future<void> setShowContainerQueryOverlays(
      List<ContainerQueryHighlightConfig>
          containerQueryHighlightConfigs) async {
    await _client.send('Overlay.setShowContainerQueryOverlays', {
      'containerQueryHighlightConfigs': [...containerQueryHighlightConfigs],
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

  /// Deprecated, no longer has any effect.
  /// [show] True for showing hit-test borders
  @Deprecated('no longer has any effect.')
  Future<void> setShowHitTestBorders(bool show) async {
    await _client.send('Overlay.setShowHitTestBorders', {
      'show': show,
    });
  }

  /// Request that backend shows an overlay with web vital metrics.
  Future<void> setShowWebVitals(bool show) async {
    await _client.send('Overlay.setShowWebVitals', {
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
  Future<void> setShowHinge({HingeConfig? hingeConfig}) async {
    await _client.send('Overlay.setShowHinge', {
      if (hingeConfig != null) 'hingeConfig': hingeConfig,
    });
  }

  /// Show elements in isolation mode with overlays.
  /// [isolatedElementHighlightConfigs] An array of node identifiers and descriptors for the highlight appearance.
  Future<void> setShowIsolatedElements(
      List<IsolatedElementHighlightConfig>
          isolatedElementHighlightConfigs) async {
    await _client.send('Overlay.setShowIsolatedElements', {
      'isolatedElementHighlightConfigs': [...isolatedElementHighlightConfigs],
    });
  }
}

/// Configuration data for drawing the source order of an elements children.
class SourceOrderConfig {
  /// the color to outline the givent element in.
  final dom.RGBA parentOutlineColor;

  /// the color to outline the child elements in.
  final dom.RGBA childOutlineColor;

  SourceOrderConfig(
      {required this.parentOutlineColor, required this.childOutlineColor});

  factory SourceOrderConfig.fromJson(Map<String, dynamic> json) {
    return SourceOrderConfig(
      parentOutlineColor:
          dom.RGBA.fromJson(json['parentOutlineColor'] as Map<String, dynamic>),
      childOutlineColor:
          dom.RGBA.fromJson(json['childOutlineColor'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parentOutlineColor': parentOutlineColor.toJson(),
      'childOutlineColor': childOutlineColor.toJson(),
    };
  }
}

/// Configuration data for the highlighting of Grid elements.
class GridHighlightConfig {
  /// Whether the extension lines from grid cells to the rulers should be shown (default: false).
  final bool? showGridExtensionLines;

  /// Show Positive line number labels (default: false).
  final bool? showPositiveLineNumbers;

  /// Show Negative line number labels (default: false).
  final bool? showNegativeLineNumbers;

  /// Show area name labels (default: false).
  final bool? showAreaNames;

  /// Show line name labels (default: false).
  final bool? showLineNames;

  /// Show track size labels (default: false).
  final bool? showTrackSizes;

  /// The grid container border highlight color (default: transparent).
  final dom.RGBA? gridBorderColor;

  /// The row line color (default: transparent).
  final dom.RGBA? rowLineColor;

  /// The column line color (default: transparent).
  final dom.RGBA? columnLineColor;

  /// Whether the grid border is dashed (default: false).
  final bool? gridBorderDash;

  /// Whether row lines are dashed (default: false).
  final bool? rowLineDash;

  /// Whether column lines are dashed (default: false).
  final bool? columnLineDash;

  /// The row gap highlight fill color (default: transparent).
  final dom.RGBA? rowGapColor;

  /// The row gap hatching fill color (default: transparent).
  final dom.RGBA? rowHatchColor;

  /// The column gap highlight fill color (default: transparent).
  final dom.RGBA? columnGapColor;

  /// The column gap hatching fill color (default: transparent).
  final dom.RGBA? columnHatchColor;

  /// The named grid areas border color (Default: transparent).
  final dom.RGBA? areaBorderColor;

  /// The grid container background color (Default: transparent).
  final dom.RGBA? gridBackgroundColor;

  GridHighlightConfig(
      {this.showGridExtensionLines,
      this.showPositiveLineNumbers,
      this.showNegativeLineNumbers,
      this.showAreaNames,
      this.showLineNames,
      this.showTrackSizes,
      this.gridBorderColor,
      this.rowLineColor,
      this.columnLineColor,
      this.gridBorderDash,
      this.rowLineDash,
      this.columnLineDash,
      this.rowGapColor,
      this.rowHatchColor,
      this.columnGapColor,
      this.columnHatchColor,
      this.areaBorderColor,
      this.gridBackgroundColor});

  factory GridHighlightConfig.fromJson(Map<String, dynamic> json) {
    return GridHighlightConfig(
      showGridExtensionLines: json.containsKey('showGridExtensionLines')
          ? json['showGridExtensionLines'] as bool
          : null,
      showPositiveLineNumbers: json.containsKey('showPositiveLineNumbers')
          ? json['showPositiveLineNumbers'] as bool
          : null,
      showNegativeLineNumbers: json.containsKey('showNegativeLineNumbers')
          ? json['showNegativeLineNumbers'] as bool
          : null,
      showAreaNames: json.containsKey('showAreaNames')
          ? json['showAreaNames'] as bool
          : null,
      showLineNames: json.containsKey('showLineNames')
          ? json['showLineNames'] as bool
          : null,
      showTrackSizes: json.containsKey('showTrackSizes')
          ? json['showTrackSizes'] as bool
          : null,
      gridBorderColor: json.containsKey('gridBorderColor')
          ? dom.RGBA.fromJson(json['gridBorderColor'] as Map<String, dynamic>)
          : null,
      rowLineColor: json.containsKey('rowLineColor')
          ? dom.RGBA.fromJson(json['rowLineColor'] as Map<String, dynamic>)
          : null,
      columnLineColor: json.containsKey('columnLineColor')
          ? dom.RGBA.fromJson(json['columnLineColor'] as Map<String, dynamic>)
          : null,
      gridBorderDash: json.containsKey('gridBorderDash')
          ? json['gridBorderDash'] as bool
          : null,
      rowLineDash:
          json.containsKey('rowLineDash') ? json['rowLineDash'] as bool : null,
      columnLineDash: json.containsKey('columnLineDash')
          ? json['columnLineDash'] as bool
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
      areaBorderColor: json.containsKey('areaBorderColor')
          ? dom.RGBA.fromJson(json['areaBorderColor'] as Map<String, dynamic>)
          : null,
      gridBackgroundColor: json.containsKey('gridBackgroundColor')
          ? dom.RGBA
              .fromJson(json['gridBackgroundColor'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (showGridExtensionLines != null)
        'showGridExtensionLines': showGridExtensionLines,
      if (showPositiveLineNumbers != null)
        'showPositiveLineNumbers': showPositiveLineNumbers,
      if (showNegativeLineNumbers != null)
        'showNegativeLineNumbers': showNegativeLineNumbers,
      if (showAreaNames != null) 'showAreaNames': showAreaNames,
      if (showLineNames != null) 'showLineNames': showLineNames,
      if (showTrackSizes != null) 'showTrackSizes': showTrackSizes,
      if (gridBorderColor != null) 'gridBorderColor': gridBorderColor!.toJson(),
      if (rowLineColor != null) 'rowLineColor': rowLineColor!.toJson(),
      if (columnLineColor != null) 'columnLineColor': columnLineColor!.toJson(),
      if (gridBorderDash != null) 'gridBorderDash': gridBorderDash,
      if (rowLineDash != null) 'rowLineDash': rowLineDash,
      if (columnLineDash != null) 'columnLineDash': columnLineDash,
      if (rowGapColor != null) 'rowGapColor': rowGapColor!.toJson(),
      if (rowHatchColor != null) 'rowHatchColor': rowHatchColor!.toJson(),
      if (columnGapColor != null) 'columnGapColor': columnGapColor!.toJson(),
      if (columnHatchColor != null)
        'columnHatchColor': columnHatchColor!.toJson(),
      if (areaBorderColor != null) 'areaBorderColor': areaBorderColor!.toJson(),
      if (gridBackgroundColor != null)
        'gridBackgroundColor': gridBackgroundColor!.toJson(),
    };
  }
}

/// Configuration data for the highlighting of Flex container elements.
class FlexContainerHighlightConfig {
  /// The style of the container border
  final LineStyle? containerBorder;

  /// The style of the separator between lines
  final LineStyle? lineSeparator;

  /// The style of the separator between items
  final LineStyle? itemSeparator;

  /// Style of content-distribution space on the main axis (justify-content).
  final BoxStyle? mainDistributedSpace;

  /// Style of content-distribution space on the cross axis (align-content).
  final BoxStyle? crossDistributedSpace;

  /// Style of empty space caused by row gaps (gap/row-gap).
  final BoxStyle? rowGapSpace;

  /// Style of empty space caused by columns gaps (gap/column-gap).
  final BoxStyle? columnGapSpace;

  /// Style of the self-alignment line (align-items).
  final LineStyle? crossAlignment;

  FlexContainerHighlightConfig(
      {this.containerBorder,
      this.lineSeparator,
      this.itemSeparator,
      this.mainDistributedSpace,
      this.crossDistributedSpace,
      this.rowGapSpace,
      this.columnGapSpace,
      this.crossAlignment});

  factory FlexContainerHighlightConfig.fromJson(Map<String, dynamic> json) {
    return FlexContainerHighlightConfig(
      containerBorder: json.containsKey('containerBorder')
          ? LineStyle.fromJson(json['containerBorder'] as Map<String, dynamic>)
          : null,
      lineSeparator: json.containsKey('lineSeparator')
          ? LineStyle.fromJson(json['lineSeparator'] as Map<String, dynamic>)
          : null,
      itemSeparator: json.containsKey('itemSeparator')
          ? LineStyle.fromJson(json['itemSeparator'] as Map<String, dynamic>)
          : null,
      mainDistributedSpace: json.containsKey('mainDistributedSpace')
          ? BoxStyle.fromJson(
              json['mainDistributedSpace'] as Map<String, dynamic>)
          : null,
      crossDistributedSpace: json.containsKey('crossDistributedSpace')
          ? BoxStyle.fromJson(
              json['crossDistributedSpace'] as Map<String, dynamic>)
          : null,
      rowGapSpace: json.containsKey('rowGapSpace')
          ? BoxStyle.fromJson(json['rowGapSpace'] as Map<String, dynamic>)
          : null,
      columnGapSpace: json.containsKey('columnGapSpace')
          ? BoxStyle.fromJson(json['columnGapSpace'] as Map<String, dynamic>)
          : null,
      crossAlignment: json.containsKey('crossAlignment')
          ? LineStyle.fromJson(json['crossAlignment'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (containerBorder != null) 'containerBorder': containerBorder!.toJson(),
      if (lineSeparator != null) 'lineSeparator': lineSeparator!.toJson(),
      if (itemSeparator != null) 'itemSeparator': itemSeparator!.toJson(),
      if (mainDistributedSpace != null)
        'mainDistributedSpace': mainDistributedSpace!.toJson(),
      if (crossDistributedSpace != null)
        'crossDistributedSpace': crossDistributedSpace!.toJson(),
      if (rowGapSpace != null) 'rowGapSpace': rowGapSpace!.toJson(),
      if (columnGapSpace != null) 'columnGapSpace': columnGapSpace!.toJson(),
      if (crossAlignment != null) 'crossAlignment': crossAlignment!.toJson(),
    };
  }
}

/// Configuration data for the highlighting of Flex item elements.
class FlexItemHighlightConfig {
  /// Style of the box representing the item's base size
  final BoxStyle? baseSizeBox;

  /// Style of the border around the box representing the item's base size
  final LineStyle? baseSizeBorder;

  /// Style of the arrow representing if the item grew or shrank
  final LineStyle? flexibilityArrow;

  FlexItemHighlightConfig(
      {this.baseSizeBox, this.baseSizeBorder, this.flexibilityArrow});

  factory FlexItemHighlightConfig.fromJson(Map<String, dynamic> json) {
    return FlexItemHighlightConfig(
      baseSizeBox: json.containsKey('baseSizeBox')
          ? BoxStyle.fromJson(json['baseSizeBox'] as Map<String, dynamic>)
          : null,
      baseSizeBorder: json.containsKey('baseSizeBorder')
          ? LineStyle.fromJson(json['baseSizeBorder'] as Map<String, dynamic>)
          : null,
      flexibilityArrow: json.containsKey('flexibilityArrow')
          ? LineStyle.fromJson(json['flexibilityArrow'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (baseSizeBox != null) 'baseSizeBox': baseSizeBox!.toJson(),
      if (baseSizeBorder != null) 'baseSizeBorder': baseSizeBorder!.toJson(),
      if (flexibilityArrow != null)
        'flexibilityArrow': flexibilityArrow!.toJson(),
    };
  }
}

/// Style information for drawing a line.
class LineStyle {
  /// The color of the line (default: transparent)
  final dom.RGBA? color;

  /// The line pattern (default: solid)
  final LineStylePattern? pattern;

  LineStyle({this.color, this.pattern});

  factory LineStyle.fromJson(Map<String, dynamic> json) {
    return LineStyle(
      color: json.containsKey('color')
          ? dom.RGBA.fromJson(json['color'] as Map<String, dynamic>)
          : null,
      pattern: json.containsKey('pattern')
          ? LineStylePattern.fromJson(json['pattern'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (color != null) 'color': color!.toJson(),
      if (pattern != null) 'pattern': pattern,
    };
  }
}

class LineStylePattern {
  static const dashed = LineStylePattern._('dashed');
  static const dotted = LineStylePattern._('dotted');
  static const values = {
    'dashed': dashed,
    'dotted': dotted,
  };

  final String value;

  const LineStylePattern._(this.value);

  factory LineStylePattern.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is LineStylePattern && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Style information for drawing a box.
class BoxStyle {
  /// The background color for the box (default: transparent)
  final dom.RGBA? fillColor;

  /// The hatching color for the box (default: transparent)
  final dom.RGBA? hatchColor;

  BoxStyle({this.fillColor, this.hatchColor});

  factory BoxStyle.fromJson(Map<String, dynamic> json) {
    return BoxStyle(
      fillColor: json.containsKey('fillColor')
          ? dom.RGBA.fromJson(json['fillColor'] as Map<String, dynamic>)
          : null,
      hatchColor: json.containsKey('hatchColor')
          ? dom.RGBA.fromJson(json['hatchColor'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (fillColor != null) 'fillColor': fillColor!.toJson(),
      if (hatchColor != null) 'hatchColor': hatchColor!.toJson(),
    };
  }
}

class ContrastAlgorithm {
  static const aa = ContrastAlgorithm._('aa');
  static const aaa = ContrastAlgorithm._('aaa');
  static const apca = ContrastAlgorithm._('apca');
  static const values = {
    'aa': aa,
    'aaa': aaa,
    'apca': apca,
  };

  final String value;

  const ContrastAlgorithm._(this.value);

  factory ContrastAlgorithm.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ContrastAlgorithm && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Configuration data for the highlighting of page elements.
class HighlightConfig {
  /// Whether the node info tooltip should be shown (default: false).
  final bool? showInfo;

  /// Whether the node styles in the tooltip (default: false).
  final bool? showStyles;

  /// Whether the rulers should be shown (default: false).
  final bool? showRulers;

  /// Whether the a11y info should be shown (default: true).
  final bool? showAccessibilityInfo;

  /// Whether the extension lines from node to the rulers should be shown (default: false).
  final bool? showExtensionLines;

  /// The content box highlight fill color (default: transparent).
  final dom.RGBA? contentColor;

  /// The padding highlight fill color (default: transparent).
  final dom.RGBA? paddingColor;

  /// The border highlight fill color (default: transparent).
  final dom.RGBA? borderColor;

  /// The margin highlight fill color (default: transparent).
  final dom.RGBA? marginColor;

  /// The event target element highlight fill color (default: transparent).
  final dom.RGBA? eventTargetColor;

  /// The shape outside fill color (default: transparent).
  final dom.RGBA? shapeColor;

  /// The shape margin fill color (default: transparent).
  final dom.RGBA? shapeMarginColor;

  /// The grid layout color (default: transparent).
  final dom.RGBA? cssGridColor;

  /// The color format used to format color styles (default: hex).
  final ColorFormat? colorFormat;

  /// The grid layout highlight configuration (default: all transparent).
  final GridHighlightConfig? gridHighlightConfig;

  /// The flex container highlight configuration (default: all transparent).
  final FlexContainerHighlightConfig? flexContainerHighlightConfig;

  /// The flex item highlight configuration (default: all transparent).
  final FlexItemHighlightConfig? flexItemHighlightConfig;

  /// The contrast algorithm to use for the contrast ratio (default: aa).
  final ContrastAlgorithm? contrastAlgorithm;

  /// The container query container highlight configuration (default: all transparent).
  final ContainerQueryContainerHighlightConfig?
      containerQueryContainerHighlightConfig;

  HighlightConfig(
      {this.showInfo,
      this.showStyles,
      this.showRulers,
      this.showAccessibilityInfo,
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
      this.gridHighlightConfig,
      this.flexContainerHighlightConfig,
      this.flexItemHighlightConfig,
      this.contrastAlgorithm,
      this.containerQueryContainerHighlightConfig});

  factory HighlightConfig.fromJson(Map<String, dynamic> json) {
    return HighlightConfig(
      showInfo: json.containsKey('showInfo') ? json['showInfo'] as bool : null,
      showStyles:
          json.containsKey('showStyles') ? json['showStyles'] as bool : null,
      showRulers:
          json.containsKey('showRulers') ? json['showRulers'] as bool : null,
      showAccessibilityInfo: json.containsKey('showAccessibilityInfo')
          ? json['showAccessibilityInfo'] as bool
          : null,
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
      flexContainerHighlightConfig:
          json.containsKey('flexContainerHighlightConfig')
              ? FlexContainerHighlightConfig.fromJson(
                  json['flexContainerHighlightConfig'] as Map<String, dynamic>)
              : null,
      flexItemHighlightConfig: json.containsKey('flexItemHighlightConfig')
          ? FlexItemHighlightConfig.fromJson(
              json['flexItemHighlightConfig'] as Map<String, dynamic>)
          : null,
      contrastAlgorithm: json.containsKey('contrastAlgorithm')
          ? ContrastAlgorithm.fromJson(json['contrastAlgorithm'] as String)
          : null,
      containerQueryContainerHighlightConfig:
          json.containsKey('containerQueryContainerHighlightConfig')
              ? ContainerQueryContainerHighlightConfig.fromJson(
                  json['containerQueryContainerHighlightConfig']
                      as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (showInfo != null) 'showInfo': showInfo,
      if (showStyles != null) 'showStyles': showStyles,
      if (showRulers != null) 'showRulers': showRulers,
      if (showAccessibilityInfo != null)
        'showAccessibilityInfo': showAccessibilityInfo,
      if (showExtensionLines != null) 'showExtensionLines': showExtensionLines,
      if (contentColor != null) 'contentColor': contentColor!.toJson(),
      if (paddingColor != null) 'paddingColor': paddingColor!.toJson(),
      if (borderColor != null) 'borderColor': borderColor!.toJson(),
      if (marginColor != null) 'marginColor': marginColor!.toJson(),
      if (eventTargetColor != null)
        'eventTargetColor': eventTargetColor!.toJson(),
      if (shapeColor != null) 'shapeColor': shapeColor!.toJson(),
      if (shapeMarginColor != null)
        'shapeMarginColor': shapeMarginColor!.toJson(),
      if (cssGridColor != null) 'cssGridColor': cssGridColor!.toJson(),
      if (colorFormat != null) 'colorFormat': colorFormat!.toJson(),
      if (gridHighlightConfig != null)
        'gridHighlightConfig': gridHighlightConfig!.toJson(),
      if (flexContainerHighlightConfig != null)
        'flexContainerHighlightConfig': flexContainerHighlightConfig!.toJson(),
      if (flexItemHighlightConfig != null)
        'flexItemHighlightConfig': flexItemHighlightConfig!.toJson(),
      if (contrastAlgorithm != null)
        'contrastAlgorithm': contrastAlgorithm!.toJson(),
      if (containerQueryContainerHighlightConfig != null)
        'containerQueryContainerHighlightConfig':
            containerQueryContainerHighlightConfig!.toJson(),
    };
  }
}

class ColorFormat {
  static const rgb = ColorFormat._('rgb');
  static const hsl = ColorFormat._('hsl');
  static const hwb = ColorFormat._('hwb');
  static const hex = ColorFormat._('hex');
  static const values = {
    'rgb': rgb,
    'hsl': hsl,
    'hwb': hwb,
    'hex': hex,
  };

  final String value;

  const ColorFormat._(this.value);

  factory ColorFormat.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ColorFormat && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Configurations for Persistent Grid Highlight
class GridNodeHighlightConfig {
  /// A descriptor for the highlight appearance.
  final GridHighlightConfig gridHighlightConfig;

  /// Identifier of the node to highlight.
  final dom.NodeId nodeId;

  GridNodeHighlightConfig(
      {required this.gridHighlightConfig, required this.nodeId});

  factory GridNodeHighlightConfig.fromJson(Map<String, dynamic> json) {
    return GridNodeHighlightConfig(
      gridHighlightConfig: GridHighlightConfig.fromJson(
          json['gridHighlightConfig'] as Map<String, dynamic>),
      nodeId: dom.NodeId.fromJson(json['nodeId'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gridHighlightConfig': gridHighlightConfig.toJson(),
      'nodeId': nodeId.toJson(),
    };
  }
}

class FlexNodeHighlightConfig {
  /// A descriptor for the highlight appearance of flex containers.
  final FlexContainerHighlightConfig flexContainerHighlightConfig;

  /// Identifier of the node to highlight.
  final dom.NodeId nodeId;

  FlexNodeHighlightConfig(
      {required this.flexContainerHighlightConfig, required this.nodeId});

  factory FlexNodeHighlightConfig.fromJson(Map<String, dynamic> json) {
    return FlexNodeHighlightConfig(
      flexContainerHighlightConfig: FlexContainerHighlightConfig.fromJson(
          json['flexContainerHighlightConfig'] as Map<String, dynamic>),
      nodeId: dom.NodeId.fromJson(json['nodeId'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flexContainerHighlightConfig': flexContainerHighlightConfig.toJson(),
      'nodeId': nodeId.toJson(),
    };
  }
}

class ScrollSnapContainerHighlightConfig {
  /// The style of the snapport border (default: transparent)
  final LineStyle? snapportBorder;

  /// The style of the snap area border (default: transparent)
  final LineStyle? snapAreaBorder;

  /// The margin highlight fill color (default: transparent).
  final dom.RGBA? scrollMarginColor;

  /// The padding highlight fill color (default: transparent).
  final dom.RGBA? scrollPaddingColor;

  ScrollSnapContainerHighlightConfig(
      {this.snapportBorder,
      this.snapAreaBorder,
      this.scrollMarginColor,
      this.scrollPaddingColor});

  factory ScrollSnapContainerHighlightConfig.fromJson(
      Map<String, dynamic> json) {
    return ScrollSnapContainerHighlightConfig(
      snapportBorder: json.containsKey('snapportBorder')
          ? LineStyle.fromJson(json['snapportBorder'] as Map<String, dynamic>)
          : null,
      snapAreaBorder: json.containsKey('snapAreaBorder')
          ? LineStyle.fromJson(json['snapAreaBorder'] as Map<String, dynamic>)
          : null,
      scrollMarginColor: json.containsKey('scrollMarginColor')
          ? dom.RGBA.fromJson(json['scrollMarginColor'] as Map<String, dynamic>)
          : null,
      scrollPaddingColor: json.containsKey('scrollPaddingColor')
          ? dom.RGBA
              .fromJson(json['scrollPaddingColor'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (snapportBorder != null) 'snapportBorder': snapportBorder!.toJson(),
      if (snapAreaBorder != null) 'snapAreaBorder': snapAreaBorder!.toJson(),
      if (scrollMarginColor != null)
        'scrollMarginColor': scrollMarginColor!.toJson(),
      if (scrollPaddingColor != null)
        'scrollPaddingColor': scrollPaddingColor!.toJson(),
    };
  }
}

class ScrollSnapHighlightConfig {
  /// A descriptor for the highlight appearance of scroll snap containers.
  final ScrollSnapContainerHighlightConfig scrollSnapContainerHighlightConfig;

  /// Identifier of the node to highlight.
  final dom.NodeId nodeId;

  ScrollSnapHighlightConfig(
      {required this.scrollSnapContainerHighlightConfig, required this.nodeId});

  factory ScrollSnapHighlightConfig.fromJson(Map<String, dynamic> json) {
    return ScrollSnapHighlightConfig(
      scrollSnapContainerHighlightConfig:
          ScrollSnapContainerHighlightConfig.fromJson(
              json['scrollSnapContainerHighlightConfig']
                  as Map<String, dynamic>),
      nodeId: dom.NodeId.fromJson(json['nodeId'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scrollSnapContainerHighlightConfig':
          scrollSnapContainerHighlightConfig.toJson(),
      'nodeId': nodeId.toJson(),
    };
  }
}

/// Configuration for dual screen hinge
class HingeConfig {
  /// A rectangle represent hinge
  final dom.Rect rect;

  /// The content box highlight fill color (default: a dark color).
  final dom.RGBA? contentColor;

  /// The content box highlight outline color (default: transparent).
  final dom.RGBA? outlineColor;

  HingeConfig({required this.rect, this.contentColor, this.outlineColor});

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
      if (contentColor != null) 'contentColor': contentColor!.toJson(),
      if (outlineColor != null) 'outlineColor': outlineColor!.toJson(),
    };
  }
}

class ContainerQueryHighlightConfig {
  /// A descriptor for the highlight appearance of container query containers.
  final ContainerQueryContainerHighlightConfig
      containerQueryContainerHighlightConfig;

  /// Identifier of the container node to highlight.
  final dom.NodeId nodeId;

  ContainerQueryHighlightConfig(
      {required this.containerQueryContainerHighlightConfig,
      required this.nodeId});

  factory ContainerQueryHighlightConfig.fromJson(Map<String, dynamic> json) {
    return ContainerQueryHighlightConfig(
      containerQueryContainerHighlightConfig:
          ContainerQueryContainerHighlightConfig.fromJson(
              json['containerQueryContainerHighlightConfig']
                  as Map<String, dynamic>),
      nodeId: dom.NodeId.fromJson(json['nodeId'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'containerQueryContainerHighlightConfig':
          containerQueryContainerHighlightConfig.toJson(),
      'nodeId': nodeId.toJson(),
    };
  }
}

class ContainerQueryContainerHighlightConfig {
  /// The style of the container border.
  final LineStyle? containerBorder;

  /// The style of the descendants' borders.
  final LineStyle? descendantBorder;

  ContainerQueryContainerHighlightConfig(
      {this.containerBorder, this.descendantBorder});

  factory ContainerQueryContainerHighlightConfig.fromJson(
      Map<String, dynamic> json) {
    return ContainerQueryContainerHighlightConfig(
      containerBorder: json.containsKey('containerBorder')
          ? LineStyle.fromJson(json['containerBorder'] as Map<String, dynamic>)
          : null,
      descendantBorder: json.containsKey('descendantBorder')
          ? LineStyle.fromJson(json['descendantBorder'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (containerBorder != null) 'containerBorder': containerBorder!.toJson(),
      if (descendantBorder != null)
        'descendantBorder': descendantBorder!.toJson(),
    };
  }
}

class IsolatedElementHighlightConfig {
  /// A descriptor for the highlight appearance of an element in isolation mode.
  final IsolationModeHighlightConfig isolationModeHighlightConfig;

  /// Identifier of the isolated element to highlight.
  final dom.NodeId nodeId;

  IsolatedElementHighlightConfig(
      {required this.isolationModeHighlightConfig, required this.nodeId});

  factory IsolatedElementHighlightConfig.fromJson(Map<String, dynamic> json) {
    return IsolatedElementHighlightConfig(
      isolationModeHighlightConfig: IsolationModeHighlightConfig.fromJson(
          json['isolationModeHighlightConfig'] as Map<String, dynamic>),
      nodeId: dom.NodeId.fromJson(json['nodeId'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isolationModeHighlightConfig': isolationModeHighlightConfig.toJson(),
      'nodeId': nodeId.toJson(),
    };
  }
}

class IsolationModeHighlightConfig {
  /// The fill color of the resizers (default: transparent).
  final dom.RGBA? resizerColor;

  /// The fill color for resizer handles (default: transparent).
  final dom.RGBA? resizerHandleColor;

  /// The fill color for the mask covering non-isolated elements (default: transparent).
  final dom.RGBA? maskColor;

  IsolationModeHighlightConfig(
      {this.resizerColor, this.resizerHandleColor, this.maskColor});

  factory IsolationModeHighlightConfig.fromJson(Map<String, dynamic> json) {
    return IsolationModeHighlightConfig(
      resizerColor: json.containsKey('resizerColor')
          ? dom.RGBA.fromJson(json['resizerColor'] as Map<String, dynamic>)
          : null,
      resizerHandleColor: json.containsKey('resizerHandleColor')
          ? dom.RGBA
              .fromJson(json['resizerHandleColor'] as Map<String, dynamic>)
          : null,
      maskColor: json.containsKey('maskColor')
          ? dom.RGBA.fromJson(json['maskColor'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (resizerColor != null) 'resizerColor': resizerColor!.toJson(),
      if (resizerHandleColor != null)
        'resizerHandleColor': resizerHandleColor!.toJson(),
      if (maskColor != null) 'maskColor': maskColor!.toJson(),
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

  factory InspectMode.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is InspectMode && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
