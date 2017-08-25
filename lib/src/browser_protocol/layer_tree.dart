import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';
import 'dom.dart' as dom;

class LayerTreeManager {
  final Session _client;

  LayerTreeManager(this._client);

  /// Enables compositing tree inspection.
  Future enable() async {
    await _client.send('LayerTree.enable');
  }

  /// Disables compositing tree inspection.
  Future disable() async {
    await _client.send('LayerTree.disable');
  }

  /// Provides the reasons why the given layer was composited.
  /// [layerId] The id of the layer for which we want to get the reasons it was composited.
  /// Return: A list of strings specifying reasons for the given layer to become composited.
  Future<List<String>> compositingReasons(
    LayerId layerId,
  ) async {
    Map parameters = {
      'layerId': layerId.toJson(),
    };
    await _client.send('LayerTree.compositingReasons', parameters);
  }

  /// Returns the layer snapshot identifier.
  /// [layerId] The id of the layer.
  /// Return: The id of the layer snapshot.
  Future<SnapshotId> makeSnapshot(
    LayerId layerId,
  ) async {
    Map parameters = {
      'layerId': layerId.toJson(),
    };
    await _client.send('LayerTree.makeSnapshot', parameters);
  }

  /// Returns the snapshot identifier.
  /// [tiles] An array of tiles composing the snapshot.
  /// Return: The id of the snapshot.
  Future<SnapshotId> loadSnapshot(
    List<PictureTile> tiles,
  ) async {
    Map parameters = {
      'tiles': tiles.map((e) => e.toJson()).toList(),
    };
    await _client.send('LayerTree.loadSnapshot', parameters);
  }

  /// Releases layer snapshot captured by the back-end.
  /// [snapshotId] The id of the layer snapshot.
  Future releaseSnapshot(
    SnapshotId snapshotId,
  ) async {
    Map parameters = {
      'snapshotId': snapshotId.toJson(),
    };
    await _client.send('LayerTree.releaseSnapshot', parameters);
  }

  /// [snapshotId] The id of the layer snapshot.
  /// [minRepeatCount] The maximum number of times to replay the snapshot (1, if not specified).
  /// [minDuration] The minimum duration (in seconds) to replay the snapshot.
  /// [clipRect] The clip rectangle to apply when replaying the snapshot.
  /// Return: The array of paint profiles, one per run.
  Future<List<PaintProfile>> profileSnapshot(
    SnapshotId snapshotId, {
    int minRepeatCount,
    num minDuration,
    dom.Rect clipRect,
  }) async {
    Map parameters = {
      'snapshotId': snapshotId.toJson(),
    };
    if (minRepeatCount != null) {
      parameters['minRepeatCount'] = minRepeatCount.toString();
    }
    if (minDuration != null) {
      parameters['minDuration'] = minDuration.toString();
    }
    if (clipRect != null) {
      parameters['clipRect'] = clipRect.toJson();
    }
    await _client.send('LayerTree.profileSnapshot', parameters);
  }

  /// Replays the layer snapshot and returns the resulting bitmap.
  /// [snapshotId] The id of the layer snapshot.
  /// [fromStep] The first step to replay from (replay from the very start if not specified).
  /// [toStep] The last step to replay to (replay till the end if not specified).
  /// [scale] The scale to apply while replaying (defaults to 1).
  /// Return: A data: URL for resulting image.
  Future<String> replaySnapshot(
    SnapshotId snapshotId, {
    int fromStep,
    int toStep,
    num scale,
  }) async {
    Map parameters = {
      'snapshotId': snapshotId.toJson(),
    };
    if (fromStep != null) {
      parameters['fromStep'] = fromStep.toString();
    }
    if (toStep != null) {
      parameters['toStep'] = toStep.toString();
    }
    if (scale != null) {
      parameters['scale'] = scale.toString();
    }
    await _client.send('LayerTree.replaySnapshot', parameters);
  }

  /// Replays the layer snapshot and returns canvas log.
  /// [snapshotId] The id of the layer snapshot.
  /// Return: The array of canvas function calls.
  Future<List<Map>> snapshotCommandLog(
    SnapshotId snapshotId,
  ) async {
    Map parameters = {
      'snapshotId': snapshotId.toJson(),
    };
    await _client.send('LayerTree.snapshotCommandLog', parameters);
  }
}

/// Unique Layer identifier.
class LayerId {
  final String value;

  LayerId(this.value);
  factory LayerId.fromJson(String value) => new LayerId(value);

  String toJson() => value;
}

/// Unique snapshot identifier.
class SnapshotId {
  final String value;

  SnapshotId(this.value);
  factory SnapshotId.fromJson(String value) => new SnapshotId(value);

  String toJson() => value;
}

/// Rectangle where scrolling happens on the main thread.
class ScrollRect {
  /// Rectangle itself.
  final dom.Rect rect;

  /// Reason for rectangle to force scrolling on the main thread
  final String type;

  ScrollRect({
    @required this.rect,
    @required this.type,
  });
  factory ScrollRect.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'rect': rect.toJson(),
      'type': type.toString(),
    };
    return json;
  }
}

/// Sticky position constraints.
class StickyPositionConstraint {
  /// Layout rectangle of the sticky element before being shifted
  final dom.Rect stickyBoxRect;

  /// Layout rectangle of the containing block of the sticky element
  final dom.Rect containingBlockRect;

  /// The nearest sticky layer that shifts the sticky box
  final LayerId nearestLayerShiftingStickyBox;

  /// The nearest sticky layer that shifts the containing block
  final LayerId nearestLayerShiftingContainingBlock;

  StickyPositionConstraint({
    @required this.stickyBoxRect,
    @required this.containingBlockRect,
    this.nearestLayerShiftingStickyBox,
    this.nearestLayerShiftingContainingBlock,
  });
  factory StickyPositionConstraint.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'stickyBoxRect': stickyBoxRect.toJson(),
      'containingBlockRect': containingBlockRect.toJson(),
    };
    if (nearestLayerShiftingStickyBox != null) {
      json['nearestLayerShiftingStickyBox'] =
          nearestLayerShiftingStickyBox.toJson();
    }
    if (nearestLayerShiftingContainingBlock != null) {
      json['nearestLayerShiftingContainingBlock'] =
          nearestLayerShiftingContainingBlock.toJson();
    }
    return json;
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

  PictureTile({
    @required this.x,
    @required this.y,
    @required this.picture,
  });
  factory PictureTile.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'x': x.toString(),
      'y': y.toString(),
      'picture': picture.toString(),
    };
    return json;
  }
}

/// Information about a compositing layer.
class Layer {
  /// The unique id for this layer.
  final LayerId layerId;

  /// The id of parent (not present for root).
  final LayerId parentLayerId;

  /// The backend id for the node associated with this layer.
  final dom.BackendNodeId backendNodeId;

  /// Offset from parent layer, X coordinate.
  final num offsetX;

  /// Offset from parent layer, Y coordinate.
  final num offsetY;

  /// Layer width.
  final num width;

  /// Layer height.
  final num height;

  /// Transformation matrix for layer, default is identity matrix
  final List<num> transform;

  /// Transform anchor point X, absent if no transform specified
  final num anchorX;

  /// Transform anchor point Y, absent if no transform specified
  final num anchorY;

  /// Transform anchor point Z, absent if no transform specified
  final num anchorZ;

  /// Indicates how many time this layer has painted.
  final int paintCount;

  /// Indicates whether this layer hosts any content, rather than being used for transform/scrolling purposes only.
  final bool drawsContent;

  /// Set if layer is not visible.
  final bool invisible;

  /// Rectangles scrolling on main thread only.
  final List<ScrollRect> scrollRects;

  /// Sticky position constraint information
  final StickyPositionConstraint stickyPositionConstraint;

  Layer({
    @required this.layerId,
    this.parentLayerId,
    this.backendNodeId,
    @required this.offsetX,
    @required this.offsetY,
    @required this.width,
    @required this.height,
    this.transform,
    this.anchorX,
    this.anchorY,
    this.anchorZ,
    @required this.paintCount,
    @required this.drawsContent,
    this.invisible,
    this.scrollRects,
    this.stickyPositionConstraint,
  });
  factory Layer.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'layerId': layerId.toJson(),
      'offsetX': offsetX.toString(),
      'offsetY': offsetY.toString(),
      'width': width.toString(),
      'height': height.toString(),
      'paintCount': paintCount.toString(),
      'drawsContent': drawsContent.toString(),
    };
    if (parentLayerId != null) {
      json['parentLayerId'] = parentLayerId.toJson();
    }
    if (backendNodeId != null) {
      json['backendNodeId'] = backendNodeId.toJson();
    }
    if (transform != null) {
      json['transform'] = transform.map((e) => e.toString()).toList();
    }
    if (anchorX != null) {
      json['anchorX'] = anchorX.toString();
    }
    if (anchorY != null) {
      json['anchorY'] = anchorY.toString();
    }
    if (anchorZ != null) {
      json['anchorZ'] = anchorZ.toString();
    }
    if (invisible != null) {
      json['invisible'] = invisible.toString();
    }
    if (scrollRects != null) {
      json['scrollRects'] = scrollRects.map((e) => e.toJson()).toList();
    }
    if (stickyPositionConstraint != null) {
      json['stickyPositionConstraint'] = stickyPositionConstraint.toJson();
    }
    return json;
  }
}

/// Array of timings, one per paint step.
class PaintProfile {
  final List<num> value;

  PaintProfile(this.value);
  factory PaintProfile.fromJson(List<num> value) => new PaintProfile(value);

  List<num> toJson() => value;
}
