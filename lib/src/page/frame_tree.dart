import 'dart:async';

import 'package:collection/collection.dart';

import '../../protocol/page.dart' show FrameId;
import 'frame_manager.dart';

/// Keeps track of the page frame tree and it's is managed by
/// {@link FrameManager}. FrameTree uses frame IDs to reference frame and it
/// means that referenced frames might not be in the tree anymore. Thus, the tree
/// structure is eventually consistent.
/// @internal
class FrameTree {
  final _frames = <FrameId, Frame>{};
  // frameID -> parentFrameID
  final _parentIds = <FrameId, FrameId>{};
  // frameID -> childFrameIDs
  final _childIds = <FrameId, Set<FrameId>>{};
  Frame? _mainFrame;
  final _waitRequests = <FrameId, Set<Completer<Frame>>>{};

  Frame? get mainFrame => _mainFrame;

  Frame? getById(FrameId frameId) {
    return _frames[frameId];
  }

  /// Returns a promise that is resolved once the frame with
  /// the given ID is added to the tree.
  Future<Frame> waitForFrame(FrameId frameId) {
    var frame = getById(frameId);
    if (frame != null) {
      return Future.value(frame);
    }
    var deferred = Completer<Frame>();
    var callbacks = _waitRequests[frameId] ?? <Completer<Frame>>{};
    callbacks.add(deferred);
    return deferred.future;
  }

  List<Frame> get frames {
    return _frames.values.toList();
  }

  void addFrame(Frame frame) {
    _frames[frame.id] = frame;
    var parentId = frame.parentId;
    if (parentId != null) {
      _parentIds[frame.id] = parentId;
      if (!_childIds.containsKey(frame.parentId)) {
        _childIds[parentId] = {};
      }
      _childIds[parentId]!.add(frame.id);
    } else {
      _mainFrame = frame;
    }
    _waitRequests[frame.id]?.forEach((request) {
      return request.complete(frame);
    });
  }

  void removeFrame(Frame frame) {
    _frames.remove(frame.id);
    _parentIds.remove(frame.id);
    if (frame.parentId != null) {
      _childIds[frame.parentId]?.remove(frame.id);
    } else {
      _mainFrame = null;
    }
  }

  List<Frame> childFrames(FrameId frameId) {
    var childIds = _childIds[frameId];
    if (childIds == null) {
      return [];
    }
    return childIds
        .map((id) {
          return getById(id);
        })
        .whereNotNull()
        .toList();
  }

  Frame? parentFrame(FrameId frameId) {
    var parentId = _parentIds[frameId];
    return parentId != null ? getById(parentId) : null;
  }
}
