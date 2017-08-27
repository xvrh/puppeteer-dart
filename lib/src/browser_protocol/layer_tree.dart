import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';
import 'dom.dart' as dom;

class LayerTreeManager {
  final Session _client;

  LayerTreeManager(this._client);

  final StreamController<List<Layer>> _layerTreeDidChange =
      new StreamController<List<Layer>>.broadcast();

  Stream<List<Layer>> get onLayerTreeDidChange => _layerTreeDidChange.stream;

  final StreamController<LayerPaintedResult> _layerPainted =
      new StreamController<LayerPaintedResult>.broadcast();

  Stream<LayerPaintedResult> get onLayerPainted => _layerPainted.stream;

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
      parameters['minRepeatCount'] = minRepeatCount;
    }
    if (minDuration != null) {
      parameters['minDuration'] = minDuration;
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
      parameters['fromStep'] = fromStep;
    }
    if (toStep != null) {
      parameters['toStep'] = toStep;
    }
    if (scale != null) {
      parameters['scale'] = scale;
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

class LayerPaintedResult {
  /// The id of the painted layer.
  final LayerId layerId;

  /// Clip rectangle.
  final dom.Rect clip;

  LayerPaintedResult({
    @required this.layerId,
    @required this.clip,
  });

  factory LayerPaintedResult.fromJson(Map json) {
    return new LayerPaintedResult(
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

  /// Indicates whether this layer hosts any content, rather than being used for transform/scrolling purposes only.
  final bool drawsContent;

  /// Set if layer is not visible.
  final bool invisible;

  /// Rectangles scrolling on main thread only.
  final List<ScrollRect> scrollRects;

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
