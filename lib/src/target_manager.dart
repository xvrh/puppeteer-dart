import 'dart:async';
import 'package:logging/logging.dart';
import '../protocol/runtime.dart' show RuntimeApi;
import '../protocol/target.dart'
    show
        AttachedToTargetEvent,
        DetachedFromTargetEvent,
        FilterEntry,
        SessionID,
        TargetApi,
        TargetFilter,
        TargetID,
        TargetInfo;
import 'connection.dart';
import 'target.dart';

final _logger = Logger('target_manager');

typedef _TargetFactory = Target Function(TargetInfo, Session?);

typedef TargetPredicate = bool Function(TargetInfo);

typedef TargetInterceptor =
    Future<void> Function(Target created, Target? parent);

class TargetChangedEvent {
  final Target target;
  final TargetInfo targetInfo;

  TargetChangedEvent(this.target, this.targetInfo);
}

/// TargetManager encapsulates all interactions with CDP targets and is
/// responsible for coordinating the configuration of targets with the rest of
/// Puppeteer. Code outside of this class should not subscribe `Target.*` events
/// and only use the TargetManager events.
///
/// There are two implementations: one for Chrome that uses CDP's auto-attach
/// mechanism and one for Firefox because Firefox does not support auto-attach.
///
/// ChromeTargetManager uses the CDP's auto-attach mechanism to intercept
/// new targets and allow the rest of Puppeteer to configure listeners while
/// the target is paused.
class TargetManager {
  final Connection _connection;

  /// Keeps track of the following events: 'Target.targetCreated',
  /// 'Target.targetDestroyed', 'Target.targetInfoChanged'.
  ///
  /// A target becomes discovered when 'Target.targetCreated' is received.
  /// A target is removed from this map once 'Target.targetDestroyed' is
  /// received.
  ///
  /// `targetFilterCallback` has no effect on this map.
  final _discoveredTargetsByTargetId = <TargetID, TargetInfo>{};

  /// A target is added to this map once ChromeTargetManager has created
  /// a Target and attached at least once to it.
  final _attachedTargetsByTargetId = <TargetID, Target>{};

  ///
  /// Tracks which sessions attach to which target.
  final _attachedTargetsBySessionId = <SessionID, Target>{};

  /// If a target was filtered out by `targetFilterCallback`, we still receive
  /// events about it from CDP, but we don't forward them to the rest of Puppeteer.
  final _ignoredTargets = <TargetID>{};
  final TargetPredicate? _targetFilterCallback;
  final _TargetFactory _targetFactory;

  final _targetInterceptors = Expando<List<TargetInterceptor>>();
  final _attachedToTargetListenersBySession =
      Expando<StreamSubscription<dynamic>>();
  final _detachedFromTargetListenersBySession =
      Expando<StreamSubscription<dynamic>>();

  final _initializeCompleter = Completer<void>();
  final _targetsIdsForInit = <TargetID>{};

  final _targetDiscoveredController = StreamController<TargetInfo>.broadcast();
  final _targetAvailableController = StreamController<Target>.broadcast();
  final _targetGoneController = StreamController<Target>.broadcast();
  final _targetChangedController =
      StreamController<TargetChangedEvent>.broadcast();
  final _subscriptions = <StreamSubscription<dynamic>>[];

  TargetManager(
    this._connection,
    this._targetFactory, {
    TargetPredicate? targetFilterCallback,
  }) : _targetFilterCallback = targetFilterCallback {
    _subscriptions.add(
      _connection.targetApi.onTargetCreated.listen(_onTargetCreated),
    );
    _subscriptions.add(
      _connection.targetApi.onTargetDestroyed.listen(_onTargetDestroyed),
    );
    _subscriptions.add(
      _connection.targetApi.onTargetInfoChanged.listen(_onTargetInfoChanged),
    );
    _subscriptions.add(
      _connection.onSessionDetached.listen(_onSessionDetached),
    );
    _setupAttachmentListeners(_connection);
  }

  void _storeExistingTargetsForInit() {
    for (final e in _discoveredTargetsByTargetId.entries) {
      var targetId = e.key;
      var targetInfo = e.value;
      var targetFilterCallback = _targetFilterCallback;
      if ((targetFilterCallback == null || targetFilterCallback(targetInfo)) &&
          targetInfo.type != 'browser') {
        _targetsIdsForInit.add(targetId);
      }
    }
  }

  Future<void> initialize() async {
    await _connection.targetApi.setDiscoverTargets(
      true,
      filter: TargetFilter([
        FilterEntry(type: 'tab', exclude: true),
        FilterEntry(),
      ]),
    );
    _storeExistingTargetsForInit();
    await _connection.targetApi.setAutoAttach(true, true, flatten: true);
    _finishInitializationIfReady(null);
    await _initializeCompleter.future;
  }

  Stream<TargetInfo> get onTargetDiscovered =>
      _targetDiscoveredController.stream;
  Stream<Target> get onTargetAvailable => _targetAvailableController.stream;
  Stream<Target> get onTargetGone => _targetGoneController.stream;
  Stream<TargetChangedEvent> get onTargetChanged =>
      _targetChangedController.stream;

  void dispose() {
    _targetDiscoveredController.close();
    _targetAvailableController.close();
    _targetGoneController.close();
    _targetChangedController.close();

    for (var subscription in _subscriptions) {
      subscription.cancel();
    }

    _removeAttachmentListeners(_connection);
  }

  Map<TargetID, Target> availableTargets() {
    return _attachedTargetsByTargetId;
  }

  void addTargetInterceptor(Client client, TargetInterceptor interceptor) {
    final interceptors = _targetInterceptors[client] ?? [];
    interceptors.add(interceptor);
    _targetInterceptors[client] = interceptors;
  }

  void removeTargetInterceptor(Client client, TargetInterceptor interceptor) {
    final interceptors = _targetInterceptors[client] ?? [];
    _targetInterceptors[client] = interceptors.where((currentInterceptor) {
      return currentInterceptor != interceptor;
    }).toList();
  }

  void _setupAttachmentListeners(Client session) {
    assert(_attachedToTargetListenersBySession[session] == null);
    var targetApi = TargetApi(session);
    _attachedToTargetListenersBySession[session] = targetApi.onAttachedToTarget
        .listen((AttachedToTargetEvent event) {
          _onAttachedToTarget(session, event);
        });

    assert(_detachedFromTargetListenersBySession[session] == null);
    _detachedFromTargetListenersBySession[session] = targetApi
        .onDetachedFromTarget
        .listen((DetachedFromTargetEvent event) {
          _onDetachedFromTarget(session, event);
        });
  }

  void _removeAttachmentListeners(Client session) {
    var attachedListener = _attachedToTargetListenersBySession[session];
    if (attachedListener != null) {
      attachedListener.cancel();
      _attachedToTargetListenersBySession[session] = null;
    }

    var detachedListener = _detachedFromTargetListenersBySession[session];
    if (detachedListener != null) {
      detachedListener.cancel();
      _detachedFromTargetListenersBySession[session] = null;
    }
  }

  void _onSessionDetached(Session session) {
    _removeAttachmentListeners(session);
    _targetInterceptors[session] = null;
  }

  void _onTargetCreated(TargetInfo targetInfo) async {
    _discoveredTargetsByTargetId[targetInfo.targetId] = targetInfo;

    _targetDiscoveredController.add(targetInfo);

    // The connection is already attached to the browser target implicitly,
    // therefore, no new CDPSession is created and we have special handling
    // here.
    if (targetInfo.type == 'browser' && targetInfo.attached) {
      if (_attachedTargetsByTargetId.containsKey(targetInfo.targetId)) {
        return;
      }
      var target = _targetFactory(targetInfo, null);
      _attachedTargetsByTargetId[targetInfo.targetId] = target;
    }
  }

  void _onTargetDestroyed(TargetID targetId) {
    final targetInfo = _discoveredTargetsByTargetId[targetId];
    _discoveredTargetsByTargetId.remove(targetId);
    _finishInitializationIfReady(targetId);
    if (targetInfo?.type == 'service_worker' &&
        _attachedTargetsByTargetId.containsKey(targetId)) {
      // Special case for service workers: report TargetGone event when
      // the worker is destroyed.
      final target = _attachedTargetsByTargetId[targetId]!;
      _targetGoneController.add(target);
      _attachedTargetsByTargetId.remove(targetId);
    }
  }

  void _onTargetInfoChanged(TargetInfo targetInfo) {
    _discoveredTargetsByTargetId[targetInfo.targetId] = targetInfo;

    if (_ignoredTargets.contains(targetInfo.targetId) ||
        !_attachedTargetsByTargetId.containsKey(targetInfo.targetId) ||
        !targetInfo.attached) {
      return;
    }

    final target = _attachedTargetsByTargetId[targetInfo.targetId];
    _targetChangedController.add(TargetChangedEvent(target!, targetInfo));
  }

  Future<void> _onAttachedToTarget(
    Client parentSession,
    AttachedToTargetEvent event,
  ) async {
    final targetInfo = event.targetInfo;
    final session = _connection.sessions[event.sessionId];
    if (session == null) {
      throw Exception('Session ${event.sessionId} was not created.');
    }

    var targetApi = TargetApi(session);
    var runtimeApi = RuntimeApi(session);
    Future<void> silentDetach() async {
      try {
        await runtimeApi.runIfWaitingForDebugger();
      } catch (e, s) {
        _logger.warning('Error on silent detach', e, s);
      }
      // We don't use `session.detach()` because that dispatches all commands on
      // the connection instead of the parent session.
      try {
        await parentSession.send('Target.detachFromTarget', {
          'sessionId': session.sessionId.value,
        });
      } catch (e, s) {
        _logger.warning('Error on silent detach detachFromTarget', e, s);
      }
    }

    if (!_connection.isAutoAttached(targetInfo.targetId)) {
      return;
    }

    // Special case for service workers: being attached to service workers will
    // prevent them from ever being destroyed. Therefore, we silently detach
    // from service workers unless the connection was manually created via
    // `page.worker()`. To determine this, we use
    // `this.#connection.isAutoAttached(targetInfo.targetId)`. In the future, we
    // should determine if a target is auto-attached or not with the help of
    // CDP.
    if (targetInfo.type == 'service_worker' &&
        _connection.isAutoAttached(targetInfo.targetId)) {
      _finishInitializationIfReady(targetInfo.targetId);
      await silentDetach();
      if (_attachedTargetsByTargetId.containsKey(targetInfo.targetId)) {
        return;
      }
      final target = _targetFactory(targetInfo, null);
      _attachedTargetsByTargetId[targetInfo.targetId] = target;
      _targetAvailableController.add(target);
      return;
    }

    if (_targetFilterCallback != null && !_targetFilterCallback(targetInfo)) {
      _ignoredTargets.add(targetInfo.targetId);
      _finishInitializationIfReady(targetInfo.targetId);
      await silentDetach();
      return;
    }

    final existingTarget = _attachedTargetsByTargetId[targetInfo.targetId];

    final target = existingTarget ?? _targetFactory(targetInfo, session);

    _setupAttachmentListeners(session);

    if (existingTarget != null) {
      _attachedTargetsBySessionId[session.sessionId] = existingTarget;
    } else {
      _attachedTargetsByTargetId[targetInfo.targetId] = target;
      _attachedTargetsBySessionId[session.sessionId] = target;
    }

    for (final interceptor
        in _targetInterceptors[parentSession] ?? <TargetInterceptor>[]) {
      if (parentSession is Session) {
        // Sanity check: if parent session is not a connection, it should be
        // present in #attachedTargetsBySessionId.
        assert(
          _attachedTargetsBySessionId.containsKey(parentSession.sessionId),
        );
      }
      await interceptor(
        target,
        parentSession is Session
            ? _attachedTargetsBySessionId[parentSession.sessionId]!
            : null,
      );
    }

    _targetsIdsForInit.remove(target.targetID);
    if (existingTarget == null) {
      _targetAvailableController.add(target);
    }
    _finishInitializationIfReady(null);

    // TODO: the browser might be shutting down here. What do we do with the
    // error?
    try {
      await Future.wait([
        targetApi.setAutoAttach(true, true, flatten: true),
        runtimeApi.runIfWaitingForDebugger(),
      ]);
    } catch (e, s) {
      _logger.warning('Error on attached target', e, s);
    }
  }

  void _finishInitializationIfReady(TargetID? targetId) {
    if (targetId != null) {
      _targetsIdsForInit.remove(targetId);
    }
    if (_targetsIdsForInit.isEmpty && !_initializeCompleter.isCompleted) {
      _initializeCompleter.complete();
    }
  }

  void _onDetachedFromTarget(
    Client parentSession,
    DetachedFromTargetEvent event,
  ) {
    final target = _attachedTargetsBySessionId[event.sessionId];

    _attachedTargetsBySessionId.remove(event.sessionId);

    if (target == null) {
      return;
    }

    _attachedTargetsByTargetId.remove(target.targetID);
    _targetGoneController.add(target);
  }
}
