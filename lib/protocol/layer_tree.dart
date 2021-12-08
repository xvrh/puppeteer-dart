import 'dart:async';
import '../src/connection.dart';
import 'dom.dart' as dom;

class LayerTreeApi {
  final Client _client;

  LayerTreeApi(this._client);

  Stream<LayerPaintedEvent> get onLayerPainted => _client.onEvent
      .where((event) => event.name == 'LayerTree.layerPainted')
      .map((event) => LayerPaintedEvent.fromJson(event.parameters));

  Stream<List<Layer>> get onLayerTreeDidChange => _client.onEvent
      .where((event) => event.name == 'LayerTree.layerTreeDidChange')
      .map((event) => (event.parameters['layers'] as List)
          .map((e) => Layer.fromJson(e as Map<String, dynamic>))
          .toList());

  /// Provides the reasons why the given layer was composited.
  /// [layerId] The id of the layer for which we want to get the reasons it was composited.
  Future<CompositingReasonsResult> compositingReasons(LayerId layerId) async {
    var result = await _client.send('LayerTree.compositingReasons', {
      'layerId': layerId,
    });
    return CompositingReasonsResult.fromJson(result);
  }

  /// Disables compositing tree inspection.
  Future<void> disable() async {
    await _client.send('LayerTree.disable');
  }

  /// Enables compositing tree inspection.
  Future<void> enable() async {
    await _client.send('LayerTree.enable');
  }

  /// Returns the snapshot identifier.
  /// [tiles] An array of tiles composing the snapshot.
  /// Returns: The id of the snapshot.
  Future<SnapshotId> loadSnapshot(List<PictureTile> tiles) async {
    var result = await _client.send('LayerTree.loadSnapshot', {
      'tiles': [...tiles],
    });
    return SnapshotId.fromJson(result['snapshotId'] as String);
  }

  /// Returns the layer snapshot identifier.
  /// [layerId] The id of the layer.
  /// Returns: The id of the layer snapshot.
  Future<SnapshotId> makeSnapshot(LayerId layerId) async {
    var result = await _client.send('LayerTree.makeSnapshot', {
      'layerId': layerId,
    });
    return SnapshotId.fromJson(result['snapshotId'] as String);
  }

  /// [snapshotId] The id of the layer snapshot.
  /// [minRepeatCount] The maximum number of times to replay the snapshot (1, if not specified).
  /// [minDuration] The minimum duration (in seconds) to replay the snapshot.
  /// [clipRect] The clip rectangle to apply when replaying the snapshot.
  /// Returns: The array of paint profiles, one per run.
  Future<List<PaintProfile>> profileSnapshot(SnapshotId snapshotId,
      {int? minRepeatCount, num? minDuration, dom.Rect? clipRect}) async {
    var result = await _client.send('LayerTree.profileSnapshot', {
      'snapshotId': snapshotId,
      if (minRepeatCount != null) 'minRepeatCount': minRepeatCount,
      if (minDuration != null) 'minDuration': minDuration,
      if (clipRect != null) 'clipRect': clipRect,
    });
    return (result['timings'] as List)
        .map((e) => PaintProfile.fromJson(e as List))
        .toList();
  }

  /// Releases layer snapshot captured by the back-end.
  /// [snapshotId] The id of the layer snapshot.
  Future<void> releaseSnapshot(SnapshotId snapshotId) async {
    await _client.send('LayerTree.releaseSnapshot', {
      'snapshotId': snapshotId,
    });
  }

  /// Replays the layer snapshot and returns the resulting bitmap.
  /// [snapshotId] The id of the layer snapshot.
  /// [fromStep] The first step to replay from (replay from the very start if not specified).
  /// [toStep] The last step to replay to (replay till the end if not specified).
  /// [scale] The scale to apply while replaying (defaults to 1).
  /// Returns: A data: URL for resulting image.
  Future<String> replaySnapshot(SnapshotId snapshotId,
      {int? fromStep, int? toStep, num? scale}) async {
    var result = await _client.send('LayerTree.replaySnapshot', {
      'snapshotId': snapshotId,
      if (fromStep != null) 'fromStep': fromStep,
      if (toStep != null) 'toStep': toStep,
      if (scale != null) 'scale': scale,
    });
    return result['dataURL'] as String;
  }

  /// Replays the layer snapshot and returns canvas log.
  /// [snapshotId] The id of the layer snapshot.
  /// Returns: The array of canvas function calls.
  Future<List<Map<String, dynamic>>> snapshotCommandLog(
      SnapshotId snapshotId) async {
    var result = await _client.send('LayerTree.snapshotCommandLog', {
      'snapshotId': snapshotId,
    });
    return (result['commandLog'] as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }
}

class LayerPaintedEvent {
  /// The id of the painted layer.
  final LayerId layerId;

  /// Clip rectangle.
  final dom.Rect clip;

  LayerPaintedEvent({required this.layerId, required this.clip});

  factory LayerPaintedEvent.fromJson(Map<String, dynamic> json) {
    return LayerPaintedEvent(
      layerId: LayerId.fromJson(json['layerId'] as String),
      clip: dom.Rect.fromJson(json['clip'] as Map<String, dynamic>),
    );
  }
}

class CompositingReasonsResult {
  /// A list of strings specifying reason IDs for the given layer to become composited.
  final List<String> compositingReasonIds;

  CompositingReasonsResult({required this.compositingReasonIds});

  factory CompositingReasonsResult.fromJson(Map<String, dynamic> json) {
    return CompositingReasonsResult(
      compositingReasonIds: (json['compositingReasonIds'] as List)
          .map((e) => e as String)
          .toList(),
    );
  }
}

/// Unique Layer identifier.
class LayerId {
  final String value;

  LayerId(this.value);

  factory LayerId.fromJson(String value) => LayerId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is LayerId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Unique snapshot identifier.
class SnapshotId {
  final String value;

  SnapshotId(this.value);

  factory SnapshotId.fromJson(String value) => SnapshotId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is SnapshotId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Rectangle where scrolling happens on the main thread.
class ScrollRect {
  /// Rectangle itself.
  final dom.Rect rect;

  /// Reason for rectangle to force scrolling on the main thread
  final ScrollRectType type;

  ScrollRect({required this.rect, required this.type});

  factory ScrollRect.fromJson(Map<String, dynamic> json) {
    return ScrollRect(
      rect: dom.Rect.fromJson(json['rect'] as Map<String, dynamic>),
      type: ScrollRectType.fromJson(json['type'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rect': rect.toJson(),
      'type': type,
    };
  }
}

class ScrollRectType {
  static const repaintsOnScroll = ScrollRectType._('RepaintsOnScroll');
  static const touchEventHandler = ScrollRectType._('TouchEventHandler');
  static const wheelEventHandler = ScrollRectType._('WheelEventHandler');
  static const values = {
    'RepaintsOnScroll': repaintsOnScroll,
    'TouchEventHandler': touchEventHandler,
    'WheelEventHandler': wheelEventHandler,
  };

  final String value;

  const ScrollRectType._(this.value);

  factory ScrollRectType.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ScrollRectType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Sticky position constraints.
class StickyPositionConstraint {
  /// Layout rectangle of the sticky element before being shifted
  final dom.Rect stickyBoxRect;

  /// Layout rectangle of the containing block of the sticky element
  final dom.Rect containingBlockRect;

  /// The nearest sticky layer that shifts the sticky box
  final LayerId? nearestLayerShiftingStickyBox;

  /// The nearest sticky layer that shifts the containing block
  final LayerId? nearestLayerShiftingContainingBlock;

  StickyPositionConstraint(
      {required this.stickyBoxRect,
      required this.containingBlockRect,
      this.nearestLayerShiftingStickyBox,
      this.nearestLayerShiftingContainingBlock});

  factory StickyPositionConstraint.fromJson(Map<String, dynamic> json) {
    return StickyPositionConstraint(
      stickyBoxRect:
          dom.Rect.fromJson(json['stickyBoxRect'] as Map<String, dynamic>),
      containingBlockRect: dom.Rect.fromJson(
          json['containingBlockRect'] as Map<String, dynamic>),
      nearestLayerShiftingStickyBox: json
              .containsKey('nearestLayerShiftingStickyBox')
          ? LayerId.fromJson(json['nearestLayerShiftingStickyBox'] as String)
          : null,
      nearestLayerShiftingContainingBlock:
          json.containsKey('nearestLayerShiftingContainingBlock')
              ? LayerId.fromJson(
                  json['nearestLayerShiftingContainingBlock'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stickyBoxRect': stickyBoxRect.toJson(),
      'containingBlockRect': containingBlockRect.toJson(),
      if (nearestLayerShiftingStickyBox != null)
        'nearestLayerShiftingStickyBox':
            nearestLayerShiftingStickyBox!.toJson(),
      if (nearestLayerShiftingContainingBlock != null)
        'nearestLayerShiftingContainingBlock':
            nearestLayerShiftingContainingBlock!.toJson(),
    };
  }
}

/// Serialized fragment of layer picture along with its offset within the layer.
class PictureTile {
  /// Offset from owning layer left boundary
  final num x;

  /// Offset from owning layer top boundary
  final num y;

  /// Base64-encoded snapshot data.
  final String picture;

  PictureTile({required this.x, required this.y, required this.picture});

  factory PictureTile.fromJson(Map<String, dynamic> json) {
    return PictureTile(
      x: json['x'] as num,
      y: json['y'] as num,
      picture: json['picture'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'picture': picture,
    };
  }
}

/// Information about a compositing layer.
class Layer {
  /// The unique id for this layer.
  final LayerId layerId;

  /// The id of parent (not present for root).
  final LayerId? parentLayerId;

  /// The backend id for the node associated with this layer.
  final dom.BackendNodeId? backendNodeId;

  /// Offset from parent layer, X coordinate.
  final num offsetX;

  /// Offset from parent layer, Y coordinate.
  final num offsetY;

  /// Layer width.
  final num width;

  /// Layer height.
  final num height;

  /// Transformation matrix for layer, default is identity matrix
  final List<num>? transform;

  /// Transform anchor point X, absent if no transform specified
  final num? anchorX;

  /// Transform anchor point Y, absent if no transform specified
  final num? anchorY;

  /// Transform anchor point Z, absent if no transform specified
  final num? anchorZ;

  /// Indicates how many time this layer has painted.
  final int paintCount;

  /// Indicates whether this layer hosts any content, rather than being used for
  /// transform/scrolling purposes only.
  final bool drawsContent;

  /// Set if layer is not visible.
  final bool? invisible;

  /// Rectangles scrolling on main thread only.
  final List<ScrollRect>? scrollRects;

  /// Sticky position constraint information
  final StickyPositionConstraint? stickyPositionConstraint;

  Layer(
      {required this.layerId,
      this.parentLayerId,
      this.backendNodeId,
      required this.offsetX,
      required this.offsetY,
      required this.width,
      required this.height,
      this.transform,
      this.anchorX,
      this.anchorY,
      this.anchorZ,
      required this.paintCount,
      required this.drawsContent,
      this.invisible,
      this.scrollRects,
      this.stickyPositionConstraint});

  factory Layer.fromJson(Map<String, dynamic> json) {
    return Layer(
      layerId: LayerId.fromJson(json['layerId'] as String),
      parentLayerId: json.containsKey('parentLayerId')
          ? LayerId.fromJson(json['parentLayerId'] as String)
          : null,
      backendNodeId: json.containsKey('backendNodeId')
          ? dom.BackendNodeId.fromJson(json['backendNodeId'] as int)
          : null,
      offsetX: json['offsetX'] as num,
      offsetY: json['offsetY'] as num,
      width: json['width'] as num,
      height: json['height'] as num,
      transform: json.containsKey('transform')
          ? (json['transform'] as List).map((e) => e as num).toList()
          : null,
      anchorX: json.containsKey('anchorX') ? json['anchorX'] as num : null,
      anchorY: json.containsKey('anchorY') ? json['anchorY'] as num : null,
      anchorZ: json.containsKey('anchorZ') ? json['anchorZ'] as num : null,
      paintCount: json['paintCount'] as int,
      drawsContent: json['drawsContent'] as bool? ?? false,
      invisible:
          json.containsKey('invisible') ? json['invisible'] as bool : null,
      scrollRects: json.containsKey('scrollRects')
          ? (json['scrollRects'] as List)
              .map((e) => ScrollRect.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      stickyPositionConstraint: json.containsKey('stickyPositionConstraint')
          ? StickyPositionConstraint.fromJson(
              json['stickyPositionConstraint'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'layerId': layerId.toJson(),
      'offsetX': offsetX,
      'offsetY': offsetY,
      'width': width,
      'height': height,
      'paintCount': paintCount,
      'drawsContent': drawsContent,
      if (parentLayerId != null) 'parentLayerId': parentLayerId!.toJson(),
      if (backendNodeId != null) 'backendNodeId': backendNodeId!.toJson(),
      if (transform != null) 'transform': [...?transform],
      if (anchorX != null) 'anchorX': anchorX,
      if (anchorY != null) 'anchorY': anchorY,
      if (anchorZ != null) 'anchorZ': anchorZ,
      if (invisible != null) 'invisible': invisible,
      if (scrollRects != null)
        'scrollRects': scrollRects!.map((e) => e.toJson()).toList(),
      if (stickyPositionConstraint != null)
        'stickyPositionConstraint': stickyPositionConstraint!.toJson(),
    };
  }
}

/// Array of timings, one per paint step.
class PaintProfile {
  final List<num> value;

  PaintProfile(this.value);

  factory PaintProfile.fromJson(List<dynamic> value) =>
      PaintProfile(value.map((e) => e as num).toList());

  List<num> toJson() => value;

  @override
  bool operator ==(other) =>
      (other is PaintProfile && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
