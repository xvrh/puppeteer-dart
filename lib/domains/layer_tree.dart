import 'dart:async';
// ignore: unused_import
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'dom.dart' as dom;

class LayerTreeDomain {
  final Client _client;

  LayerTreeDomain(this._client);

  Stream<List<Layer>> get onLayerTreeDidChange => _client.onEvent
      .where((Event event) => event.name == 'LayerTree.layerTreeDidChange')
      .map((Event event) => (event.parameters['layers'] as List)
          .map((e) => new Layer.fromJson(e))
          .toList());

  Stream<LayerPaintedEvent> get onLayerPainted => _client.onEvent
      .where((Event event) => event.name == 'LayerTree.layerPainted')
      .map((Event event) => new LayerPaintedEvent.fromJson(event.parameters));

  /// Enables compositing tree inspection.
  Future enable() async {
    await _client.send('LayerTree.enable');
  }

  /// Disables compositing tree inspection.
  Future disable() async {
    await _client.send('LayerTree.disable');
  }

  /// Provides the reasons why the given layer was composited.
  /// [layerId] The id of the layer for which we want to get the reasons it was
  /// composited.
  /// Return: A list of strings specifying reasons for the given layer to become
  /// composited.
  Future<List<String>> compositingReasons(
    LayerId layerId,
  ) async {
    Map parameters = {
      'layerId': layerId.toJson(),
    };
    Map result = await _client.send('LayerTree.compositingReasons', parameters);
    return (result['compositingReasons'] as List)
        .map((e) => e as String)
        .toList();
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
    Map result = await _client.send('LayerTree.makeSnapshot', parameters);
    return new SnapshotId.fromJson(result['snapshotId']);
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
    Map result = await _client.send('LayerTree.loadSnapshot', parameters);
    return new SnapshotId.fromJson(result['snapshotId']);
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
  /// [minRepeatCount] The maximum number of times to replay the snapshot (1, if
  /// not specified).
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
      parameters['minRepeatCount'] = minRepeatCount;
    }
    if (minDuration != null) {
      parameters['minDuration'] = minDuration;
    }
    if (clipRect != null) {
      parameters['clipRect'] = clipRect.toJson();
    }
    Map result = await _client.send('LayerTree.profileSnapshot', parameters);
    return (result['timings'] as List)
        .map((e) => new PaintProfile.fromJson(e))
        .toList();
  }

  /// Replays the layer snapshot and returns the resulting bitmap.
  /// [snapshotId] The id of the layer snapshot.
  /// [fromStep] The first step to replay from (replay from the very start if not
  /// specified).
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
      parameters['fromStep'] = fromStep;
    }
    if (toStep != null) {
      parameters['toStep'] = toStep;
    }
    if (scale != null) {
      parameters['scale'] = scale;
    }
    Map result = await _client.send('LayerTree.replaySnapshot', parameters);
    return result['dataURL'];
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
    Map result = await _client.send('LayerTree.snapshotCommandLog', parameters);
    return (result['commandLog'] as List).map((e) => e as Map).toList();
  }
}

class LayerPaintedEvent {
  /// The id of the painted layer.
  final LayerId layerId;

  /// Clip rectangle.
  final dom.Rect clip;

  LayerPaintedEvent({
    @required this.layerId,
    @required this.clip,
  });

  factory LayerPaintedEvent.fromJson(Map json) {
    return new LayerPaintedEvent(
      layerId: new LayerId.fromJson(json['layerId']),
      clip: new dom.Rect.fromJson(json['clip']),
    );
  }
}

/// Unique Layer identifier.
class LayerId {
  final String value;

  LayerId(this.value);

  factory LayerId.fromJson(String value) => new LayerId(value);

  String toJson() => value;

  bool operator ==(other) => other is LayerId && other.value == value;

  int get hashCode => value.hashCode;

  String toString() => value.toString();
}

/// Unique snapshot identifier.
class SnapshotId {
  final String value;

  SnapshotId(this.value);

  factory SnapshotId.fromJson(String value) => new SnapshotId(value);

  String toJson() => value;

  bool operator ==(other) => other is SnapshotId && other.value == value;

  int get hashCode => value.hashCode;

  String toString() => value.toString();
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

  factory ScrollRect.fromJson(Map json) {
    return new ScrollRect(
      rect: new dom.Rect.fromJson(json['rect']),
      type: json['type'],
    );
  }

  Map toJson() {
    Map json = {
      'rect': rect.toJson(),
      'type': type,
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

  factory StickyPositionConstraint.fromJson(Map json) {
    return new StickyPositionConstraint(
      stickyBoxRect: new dom.Rect.fromJson(json['stickyBoxRect']),
      containingBlockRect: new dom.Rect.fromJson(json['containingBlockRect']),
      nearestLayerShiftingStickyBox:
          json.containsKey('nearestLayerShiftingStickyBox')
              ? new LayerId.fromJson(json['nearestLayerShiftingStickyBox'])
              : null,
      nearestLayerShiftingContainingBlock: json
              .containsKey('nearestLayerShiftingContainingBlock')
          ? new LayerId.fromJson(json['nearestLayerShiftingContainingBlock'])
          : null,
    );
  }

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

  factory PictureTile.fromJson(Map json) {
    return new PictureTile(
      x: json['x'],
      y: json['y'],
      picture: json['picture'],
    );
  }

  Map toJson() {
    Map json = {
      'x': x,
      'y': y,
      'picture': picture,
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

  /// Indicates whether this layer hosts any content, rather than being used for
  /// transform/scrolling purposes only.
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

  factory Layer.fromJson(Map json) {
    return new Layer(
      layerId: new LayerId.fromJson(json['layerId']),
      parentLayerId: json.containsKey('parentLayerId')
          ? new LayerId.fromJson(json['parentLayerId'])
          : null,
      backendNodeId: json.containsKey('backendNodeId')
          ? new dom.BackendNodeId.fromJson(json['backendNodeId'])
          : null,
      offsetX: json['offsetX'],
      offsetY: json['offsetY'],
      width: json['width'],
      height: json['height'],
      transform: json.containsKey('transform')
          ? (json['transform'] as List).map((e) => e as num).toList()
          : null,
      anchorX: json.containsKey('anchorX') ? json['anchorX'] : null,
      anchorY: json.containsKey('anchorY') ? json['anchorY'] : null,
      anchorZ: json.containsKey('anchorZ') ? json['anchorZ'] : null,
      paintCount: json['paintCount'],
      drawsContent: json['drawsContent'],
      invisible: json.containsKey('invisible') ? json['invisible'] : null,
      scrollRects: json.containsKey('scrollRects')
          ? (json['scrollRects'] as List)
              .map((e) => new ScrollRect.fromJson(e))
              .toList()
          : null,
      stickyPositionConstraint: json.containsKey('stickyPositionConstraint')
          ? new StickyPositionConstraint.fromJson(
              json['stickyPositionConstraint'])
          : null,
    );
  }

  Map toJson() {
    Map json = {
      'layerId': layerId.toJson(),
      'offsetX': offsetX,
      'offsetY': offsetY,
      'width': width,
      'height': height,
      'paintCount': paintCount,
      'drawsContent': drawsContent,
    };
    if (parentLayerId != null) {
      json['parentLayerId'] = parentLayerId.toJson();
    }
    if (backendNodeId != null) {
      json['backendNodeId'] = backendNodeId.toJson();
    }
    if (transform != null) {
      json['transform'] = transform.map((e) => e).toList();
    }
    if (anchorX != null) {
      json['anchorX'] = anchorX;
    }
    if (anchorY != null) {
      json['anchorY'] = anchorY;
    }
    if (anchorZ != null) {
      json['anchorZ'] = anchorZ;
    }
    if (invisible != null) {
      json['invisible'] = invisible;
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

  bool operator ==(other) => other is PaintProfile && other.value == value;

  int get hashCode => value.hashCode;

  String toString() => value.toString();
}
