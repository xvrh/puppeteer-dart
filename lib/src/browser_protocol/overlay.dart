/// This domain provides various functionality related to drawing atop the inspected page.

import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';
import 'dom.dart' as dom;
import '../runtime.dart' as runtime;
import 'page.dart' as page;

class OverlayManager {
  final Session _client;

  OverlayManager(this._client);

  /// Enables domain notifications.
  Future enable() async {
    await _client.send('Overlay.enable');
  }

  /// Disables domain notifications.
  Future disable() async {
    await _client.send('Overlay.disable');
  }

  /// Requests that backend shows paint rectangles
  /// [result] True for showing paint rectangles
  Future setShowPaintRects(
    bool result,
  ) async {
    Map parameters = {
      'result': result.toString(),
    };
    await _client.send('Overlay.setShowPaintRects', parameters);
  }

  /// Requests that backend shows debug borders on layers
  /// [show] True for showing debug borders
  Future setShowDebugBorders(
    bool show,
  ) async {
    Map parameters = {
      'show': show.toString(),
    };
    await _client.send('Overlay.setShowDebugBorders', parameters);
  }

  /// Requests that backend shows the FPS counter
  /// [show] True for showing the FPS counter
  Future setShowFPSCounter(
    bool show,
  ) async {
    Map parameters = {
      'show': show.toString(),
    };
    await _client.send('Overlay.setShowFPSCounter', parameters);
  }

  /// Requests that backend shows scroll bottleneck rects
  /// [show] True for showing scroll bottleneck rects
  Future setShowScrollBottleneckRects(
    bool show,
  ) async {
    Map parameters = {
      'show': show.toString(),
    };
    await _client.send('Overlay.setShowScrollBottleneckRects', parameters);
  }

  /// Paints viewport size upon main frame resize.
  /// [show] Whether to paint size or not.
  Future setShowViewportSizeOnResize(
    bool show,
  ) async {
    Map parameters = {
      'show': show.toString(),
    };
    await _client.send('Overlay.setShowViewportSizeOnResize', parameters);
  }

  /// [message] The message to display, also triggers resume and step over controls.
  Future setPausedInDebuggerMessage({
    String message,
  }) async {
    Map parameters = {};
    if (message != null) {
      parameters['message'] = message.toString();
    }
    await _client.send('Overlay.setPausedInDebuggerMessage', parameters);
  }

  /// [suspended] Whether overlay should be suspended and not consume any resources until resumed.
  Future setSuspended(
    bool suspended,
  ) async {
    Map parameters = {
      'suspended': suspended.toString(),
    };
    await _client.send('Overlay.setSuspended', parameters);
  }

  /// Enters the 'inspect' mode. In this mode, elements that user is hovering over are highlighted. Backend then generates 'inspectNodeRequested' event upon element selection.
  /// [mode] Set an inspection mode.
  /// [highlightConfig] A descriptor for the highlight appearance of hovered-over nodes. May be omitted if <code>enabled == false</code>.
  Future setInspectMode(
    InspectMode mode, {
    HighlightConfig highlightConfig,
  }) async {
    Map parameters = {
      'mode': mode.toJson(),
    };
    if (highlightConfig != null) {
      parameters['highlightConfig'] = highlightConfig.toJson();
    }
    await _client.send('Overlay.setInspectMode', parameters);
  }

  /// Highlights given rectangle. Coordinates are absolute with respect to the main frame viewport.
  /// [x] X coordinate
  /// [y] Y coordinate
  /// [width] Rectangle width
  /// [height] Rectangle height
  /// [color] The highlight fill color (default: transparent).
  /// [outlineColor] The highlight outline color (default: transparent).
  Future highlightRect(
    int x,
    int y,
    int width,
    int height, {
    dom.RGBA color,
    dom.RGBA outlineColor,
  }) async {
    Map parameters = {
      'x': x.toString(),
      'y': y.toString(),
      'width': width.toString(),
      'height': height.toString(),
    };
    if (color != null) {
      parameters['color'] = color.toJson();
    }
    if (outlineColor != null) {
      parameters['outlineColor'] = outlineColor.toJson();
    }
    await _client.send('Overlay.highlightRect', parameters);
  }

  /// Highlights given quad. Coordinates are absolute with respect to the main frame viewport.
  /// [quad] Quad to highlight
  /// [color] The highlight fill color (default: transparent).
  /// [outlineColor] The highlight outline color (default: transparent).
  Future highlightQuad(
    dom.Quad quad, {
    dom.RGBA color,
    dom.RGBA outlineColor,
  }) async {
    Map parameters = {
      'quad': quad.toJson(),
    };
    if (color != null) {
      parameters['color'] = color.toJson();
    }
    if (outlineColor != null) {
      parameters['outlineColor'] = outlineColor.toJson();
    }
    await _client.send('Overlay.highlightQuad', parameters);
  }

  /// Highlights DOM node with given id or with the given JavaScript object wrapper. Either nodeId or objectId must be specified.
  /// [highlightConfig] A descriptor for the highlight appearance.
  /// [nodeId] Identifier of the node to highlight.
  /// [backendNodeId] Identifier of the backend node to highlight.
  /// [objectId] JavaScript object id of the node to be highlighted.
  Future highlightNode(
    HighlightConfig highlightConfig, {
    dom.NodeId nodeId,
    dom.BackendNodeId backendNodeId,
    runtime.RemoteObjectId objectId,
  }) async {
    Map parameters = {
      'highlightConfig': highlightConfig.toJson(),
    };
    if (nodeId != null) {
      parameters['nodeId'] = nodeId.toJson();
    }
    if (backendNodeId != null) {
      parameters['backendNodeId'] = backendNodeId.toJson();
    }
    if (objectId != null) {
      parameters['objectId'] = objectId.toJson();
    }
    await _client.send('Overlay.highlightNode', parameters);
  }

  /// Highlights owner element of the frame with given id.
  /// [frameId] Identifier of the frame to highlight.
  /// [contentColor] The content box highlight fill color (default: transparent).
  /// [contentOutlineColor] The content box highlight outline color (default: transparent).
  Future highlightFrame(
    page.FrameId frameId, {
    dom.RGBA contentColor,
    dom.RGBA contentOutlineColor,
  }) async {
    Map parameters = {
      'frameId': frameId.toJson(),
    };
    if (contentColor != null) {
      parameters['contentColor'] = contentColor.toJson();
    }
    if (contentOutlineColor != null) {
      parameters['contentOutlineColor'] = contentOutlineColor.toJson();
    }
    await _client.send('Overlay.highlightFrame', parameters);
  }

  /// Hides any highlight.
  Future hideHighlight() async {
    await _client.send('Overlay.hideHighlight');
  }

  /// For testing.
  /// [nodeId] Id of the node to get highlight object for.
  /// Return: Highlight data for the node.
  Future<Object> getHighlightObjectForTest(
    dom.NodeId nodeId,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
    };
    await _client.send('Overlay.getHighlightObjectForTest', parameters);
  }
}

/// Configuration data for the highlighting of page elements.
class HighlightConfig {
  /// Whether the node info tooltip should be shown (default: false).
  final bool showInfo;

  /// Whether the rulers should be shown (default: false).
  final bool showRulers;

  /// Whether the extension lines from node to the rulers should be shown (default: false).
  final bool showExtensionLines;

  final bool displayAsMaterial;

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

  /// Selectors to highlight relevant nodes.
  final String selectorList;

  /// The grid layout color (default: transparent).
  final dom.RGBA cssGridColor;

  HighlightConfig({
    this.showInfo,
    this.showRulers,
    this.showExtensionLines,
    this.displayAsMaterial,
    this.contentColor,
    this.paddingColor,
    this.borderColor,
    this.marginColor,
    this.eventTargetColor,
    this.shapeColor,
    this.shapeMarginColor,
    this.selectorList,
    this.cssGridColor,
  });

  Map toJson() {
    Map json = {};
    if (showInfo != null) {
      json['showInfo'] = showInfo.toString();
    }
    if (showRulers != null) {
      json['showRulers'] = showRulers.toString();
    }
    if (showExtensionLines != null) {
      json['showExtensionLines'] = showExtensionLines.toString();
    }
    if (displayAsMaterial != null) {
      json['displayAsMaterial'] = displayAsMaterial.toString();
    }
    if (contentColor != null) {
      json['contentColor'] = contentColor.toJson();
    }
    if (paddingColor != null) {
      json['paddingColor'] = paddingColor.toJson();
    }
    if (borderColor != null) {
      json['borderColor'] = borderColor.toJson();
    }
    if (marginColor != null) {
      json['marginColor'] = marginColor.toJson();
    }
    if (eventTargetColor != null) {
      json['eventTargetColor'] = eventTargetColor.toJson();
    }
    if (shapeColor != null) {
      json['shapeColor'] = shapeColor.toJson();
    }
    if (shapeMarginColor != null) {
      json['shapeMarginColor'] = shapeMarginColor.toJson();
    }
    if (selectorList != null) {
      json['selectorList'] = selectorList.toString();
    }
    if (cssGridColor != null) {
      json['cssGridColor'] = cssGridColor.toJson();
    }
    return json;
  }
}

class InspectMode {
  static const InspectMode searchForNode = const InspectMode._('searchForNode');
  static const InspectMode searchForUAShadowDOM =
      const InspectMode._('searchForUAShadowDOM');
  static const InspectMode none = const InspectMode._('none');

  final String value;

  const InspectMode._(this.value);

  String toJson() => value;
}
