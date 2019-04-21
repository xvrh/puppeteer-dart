import 'dart:async';
import 'dart:io';

import 'package:puppeteer/protocol/network.dart';
import 'package:puppeteer/protocol/page.dart';
import 'package:puppeteer/protocol/runtime.dart';
import 'package:puppeteer/src/connection.dart';
import 'package:puppeteer/src/page/dom_world.dart';
import 'package:puppeteer/src/page/execution_context.dart';
import 'package:puppeteer/src/page/js_handle.dart';
import 'package:puppeteer/src/page/lifecycle_watcher.dart';
import 'package:puppeteer/src/page/mouse.dart';
import 'package:puppeteer/src/page/network_manager.dart';
import 'package:puppeteer/src/page/page.dart';

const _utilityWorldName = '__cdt_utility_world__';

class FrameManager {
  final Page page;
  NetworkManager _networkManager;
  final _frames = <FrameId, PageFrame>{};
  final _contextIdToContext = <ExecutionContextId, ExecutionContext>{};
  final _isolatedWorlds = <String>{};
  final _lifecycleEventController = StreamController<PageFrame>.broadcast(),
      _frameAttachedController = StreamController<PageFrame>.broadcast(),
      _frameNavigatedController = StreamController<PageFrame>.broadcast(),
      _frameNavigatedWithinDocumentController =
          StreamController<PageFrame>.broadcast(),
      _frameDetachedController = StreamController<PageFrame>.broadcast();
  PageFrame _mainFrame;

  FrameManager(this.page) {
    _networkManager = NetworkManager(page.session, this);

    _pageApi.onFrameAttached.listen(
        (event) => _onFrameAttached(event.frameId, event.parentFrameId));
    _pageApi.onFrameNavigated.listen(_onFrameNavigated);
    _pageApi.onNavigatedWithinDocument.listen(_onFrameNavigatedWithinDocument);
    _pageApi.onFrameDetached.listen(_onFrameDetached);
    _pageApi.onFrameStoppedLoading.listen(_onFrameStoppedLoading);
    _runtimeApi.onExecutionContextCreated.listen(_onExecutionContextCreated);
    _runtimeApi.onExecutionContextDestroyed
        .listen(_onExecutionContextDestroyed);
    _runtimeApi.onExecutionContextsCleared.listen(_onExecutionContextsCleared);
    _pageApi.onLifecycleEvent.listen(_onLifecycleEvent);
  }

  PageApi get _pageApi => page.devTools.page;

  RuntimeApi get _runtimeApi => page.devTools.runtime;

  NetworkManager get networkManager => _networkManager;

  Stream<PageFrame> get onLifecycleEvent => _lifecycleEventController.stream;

  Stream<PageFrame> get onFrameAttached => _frameAttachedController.stream;

  Stream<PageFrame> get onFrameNavigated => _frameNavigatedController.stream;

  Stream<PageFrame> get onFrameNavigatedWithinDocument =>
      _frameNavigatedWithinDocumentController.stream;

  Stream<PageFrame> get onFrameDetached => _frameDetachedController.stream;

  void dispose() {
    _networkManager.dispose();
    _lifecycleEventController.close();
    _frameAttachedController.close();
    _frameNavigatedController.close();
    _frameNavigatedWithinDocumentController.close();
    _frameDetachedController.close();
  }

  Future initialize() async {
    await _pageApi.enable();
    _handleFrameTree(await _pageApi.getFrameTree());
    await Future.wait([
      _pageApi.setLifecycleEventsEnabled(true),
      _runtimeApi.enable(),
      _networkManager.initialize()
    ]);

    _ensureIsolatedWorld(_utilityWorldName);
  }

  PageFrame frame(FrameId frameId) => _frames[frameId];

  Future<NetworkResponse> navigateFrame(PageFrame frame, String url,
      {String referrer, Duration timeout, Until wait}) async {
    var watcher = LifecycleWatcher(this, frame, wait: wait, timeout: timeout);

    Future navigate() async {
      var response =
          await _pageApi.navigate(url, referrer: referrer, frameId: frame.id);
      if (response.errorText != null) {
        throw Exception('${response.errorText} at $url');
      }
      await (response.loaderId != null
          ? watcher.newDocumentNavigation
          : watcher.sameDocumentNavigation);
    }

    try {
      await Future.any([
        navigate(),
        watcher.timeoutOrTermination,
      ]);
    } finally {
      watcher.dispose();
    }

    return watcher.navigationResponse;
  }

  Future<NetworkResponse> waitForFrameNavigation(PageFrame frame,
      {Until wait, Duration timeout}) async {
    var watcher = LifecycleWatcher(this, frame, wait: wait, timeout: timeout);
    try {
      await Future.any([
        watcher.timeoutOrTermination,
        watcher.sameDocumentNavigation,
        watcher.newDocumentNavigation,
      ]);
    } finally {
      watcher.dispose();
    }

    return watcher.navigationResponse;
  }

  void _onLifecycleEvent(LifecycleEventEvent event) {
    var frame = _frames[event.frameId];
    if (frame == null) {
      return;
    }
    frame._onLifecycleEvent(event.loaderId, event.name);
    _lifecycleEventController.add(frame);
  }

  void _onFrameStoppedLoading(FrameId frameId) {
    var frame = _frames[frameId];
    if (frame == null) {
      return;
    }
    frame._onLoadingStopped();
    _lifecycleEventController.add(frame);
  }

  void _handleFrameTree(FrameTree frameTree) {
    if (frameTree.frame.parentId != null) {
      _onFrameAttached(
          FrameId(frameTree.frame.id), FrameId(frameTree.frame.parentId));
    }
    _onFrameNavigated(frameTree.frame);
    if (frameTree.childFrames == null) {
      return;
    }

    frameTree.childFrames.forEach(_handleFrameTree);
  }

  PageFrame get mainFrame => _mainFrame;

  List<PageFrame> get frames => List.unmodifiable(_frames.values);

  PageFrame frameById(FrameId frameId) => _frames[frameId];

  void _onFrameAttached(FrameId frameId, FrameId parentFrameId) {
    if (_frames.containsKey(frameId)) return;
    assert(parentFrameId != null);
    var parentFrame = _frames[parentFrameId];
    var frame = PageFrame(this, page.session, parentFrame, frameId);
    _frames[frameId] = frame;
    _frameAttachedController.add(frame);
  }

  void _onFrameNavigated(Frame framePayload) {
    var isMainFrame = framePayload.parentId == null;
    var frame = isMainFrame ? _mainFrame : _frames[FrameId(framePayload.id)];
    assert(isMainFrame || frame != null,
        'We either navigate top level or have old version of the navigated frame');

    // Detach all child frames first.
    if (frame != null) {
      frame.children.forEach(_removeFramesRecursively);
    }

    // Update or create main frame.
    if (isMainFrame) {
      if (frame != null) {
        // Update frame id to retain frame identity on cross-process navigation.
        _frames.remove(frame.id);
        frame._id = FrameId(framePayload.id);
      } else {
        // Initial main frame navigation.
        frame = PageFrame(this, page.session, null, FrameId(framePayload.id));
      }
      _frames[FrameId(framePayload.id)] = frame;
      _mainFrame = frame;
    }

    // Update frame payload.
    frame._navigated(framePayload);

    _frameNavigatedController.add(frame);
  }

  void _ensureIsolatedWorld(String name) async {
    if (_isolatedWorlds.contains(name)) {
      return;
    }
    _isolatedWorlds.add(name);
    await _pageApi.addScriptToEvaluateOnNewDocument(
        '//# sourceURL=$evaluationScriptUrl',
        worldName: name);

    await Future.wait(frames.map((frame) => _pageApi.createIsolatedWorld(
        frame.id,
        grantUniveralAccess: true,
        worldName: name)));
  }

  void _onFrameNavigatedWithinDocument(NavigatedWithinDocumentEvent event) {
    var frame = _frames[event.frameId];
    if (frame == null) {
      return;
    }
    frame._navigatedWithinDocument(event.url);

    _frameNavigatedWithinDocumentController.add(frame);
    _frameNavigatedController.add(frame);
  }

  void _onFrameDetached(FrameId frameId) {
    var frame = _frames[frameId];
    if (frame != null) {
      _removeFramesRecursively(frame);
    }
  }

  void _onExecutionContextCreated(ExecutionContextDescription contextPayload) {
    String frameId = contextPayload.auxData != null
        ? contextPayload.auxData['frameId']
        : null;
    var frame = _frames[FrameId(frameId)];
    DomWorld world;
    if (frame != null) {
      if (contextPayload.auxData != null &&
          contextPayload.auxData['isDefault'] == true) {
        world = frame._mainWorld;
      } else if (contextPayload.name == _utilityWorldName &&
          !frame._secondaryWorld.hasContext) {
        // In case of multiple sessions to the same target, there's a race between
        // connections so we might end up creating multiple isolated worlds.
        // We can use either.
        world = frame._secondaryWorld;
      }
    }
    if (contextPayload.auxData != null &&
        contextPayload.auxData['type'] == 'isolated') {
      _isolatedWorlds.add(contextPayload.name);
    }
    var context = ExecutionContext(page.session, contextPayload, world);
    if (world != null) {
      world.setContext(context);
    }
    _contextIdToContext[contextPayload.id] = context;
  }

  void _onExecutionContextDestroyed(ExecutionContextId executionContextId) {
    var context = _contextIdToContext[executionContextId];
    if (context == null) {
      return;
    }
    _contextIdToContext.remove(executionContextId);
    if (context.world != null) {
      context.world.setContext(null);
    }
  }

  void _onExecutionContextsCleared(_) {
    for (var context in _contextIdToContext.values) {
      if (context.world != null) context.world.setContext(null);
    }
    _contextIdToContext.clear();
  }

  ExecutionContext executionContextById(ExecutionContextId contextId) {
    var context = _contextIdToContext[contextId];
    assert(context != null,
        'INTERNAL ERROR: missing context with id = ${contextId.value}');
    return context;
  }

  void _removeFramesRecursively(PageFrame frame) {
    frame.children.forEach(_removeFramesRecursively);

    frame._detach();
    _frames.remove(frame.id);
    _frameDetachedController.add(frame);
  }
}

class PageFrame {
  final FrameManager frameManager;
  final Client client;
  PageFrame _parent;
  FrameId _id;
  final lifecycleEvents = <String>{};
  final children = <PageFrame>[];
  String _url, _name;
  bool _detached = false;
  LoaderId _loaderId;
  DomWorld _mainWorld, _secondaryWorld;

  PageFrame(this.frameManager, this.client, this._parent, this._id) {
    _mainWorld = DomWorld(frameManager, this);
    _secondaryWorld = DomWorld(frameManager, this);

    if (_parent != null) {
      _parent.children.add(this);
    }
  }

  FrameId get id => _id;

  String get url => _url;

  String get name => _name;

  bool get isDetached => _detached;

  LoaderId get loaderId => _loaderId;

  Future<NetworkResponse> goto(String url,
      {String referrer, Duration timeout, Until wait}) {
    return frameManager.navigateFrame(this, url,
        referrer: referrer, timeout: timeout, wait: wait);
  }

  Future<NetworkResponse> waitForNavigation({Duration timeout, Until wait}) {
    return frameManager.waitForFrameNavigation(this,
        timeout: timeout, wait: wait);
  }

  Future<ExecutionContext> get executionContext {
    return _mainWorld.executionContext;
  }

  Future<JsHandle> evaluateHandle(@javascript String pageFunction,
      {List args}) {
    return _mainWorld.evaluateHandle(pageFunction, args: args);
  }

  Future<T> evaluate<T>(@javascript String pageFunction, {List args}) {
    return _mainWorld.evaluate<T>(pageFunction, args: args);
  }

  /// The method queries frame for the selector. If there's no such element
  /// within the frame, the method will resolve to null.
  ///
  /// [selector]: A selector to query frame for
  /// Returns a Future which resolves to ElementHandle pointing to the frame
  /// element.
  Future<ElementHandle> $(String selector) {
    return _mainWorld.$(selector);
  }

  /// Evaluates the XPath expression.
  Future<List<ElementHandle>> $x(String expression) {
    return _mainWorld.$x(expression);
  }

  /// This method runs document.querySelector within the frame and passes it as
  /// the first argument to pageFunction. If there's no element matching
  /// selector, the method throws an error.
  ///
  ///  If pageFunction returns a Promise, then frame.$eval would wait for the
  ///  promise to resolve and return its value.
  ///
  /// Examples:
  ///
  /// ```dart
  /// var searchValue = await frame.$eval('#search', Js.function('function (el) { return el.value; }'));
  /// var preloadHref = await frame.$eval('link[rel=preload]', Js.function('function (el) { return el.href; }'));
  /// var html = await frame.$eval('.main-container', , Js.function('function (e) { return e.outerHTML; }'));
  /// ```
  ///
  /// [selector]: A selector to query frame for
  /// [pageFunction]: Function to be evaluated in browser context
  /// [args]: Arguments to pass to pageFunction
  /// Returns a Future which resolves to the return value of pageFunction
  Future<T> $eval<T>(String selector, @javascript String pageFunction,
      {List args}) {
    return _mainWorld.$eval<T>(selector, pageFunction, args: args);
  }

  Future<T> $$eval<T>(String selector, @javascript String pageFunction,
      {List args}) {
    return _mainWorld.$$eval<T>(selector, pageFunction, args: args);
  }

  Future<List<ElementHandle>> $$(String selector) {
    return _mainWorld.$$(selector);
  }

  Future<String> get content {
    return _secondaryWorld.content;
  }

  Future<void> setContent(String html, {Duration timeout, Until wait}) {
    return _secondaryWorld.setContent(html, timeout: timeout, wait: wait);
  }

  Future<ElementHandle> addScriptTag(
      {String url, File file, String content, String type}) {
    return _mainWorld.addScriptTag(
        url: url, file: file, content: content, type: type);
  }

  Future<ElementHandle> addStyleTag({String url, File file, String content}) {
    return _mainWorld.addStyleTag(url: url, file: file, content: content);
  }

  Future<void> click(String selector,
      {Duration delay, MouseButton button, int clickCount}) {
    return _secondaryWorld.click(selector,
        delay: delay, button: button, clickCount: clickCount);
  }

  Future<void> focus(String selector) {
    return _secondaryWorld.focus(selector);
  }

  Future<void> hover(String selector) {
    return _secondaryWorld.hover(selector);
  }

  Future<List<String>> select(selector, List<String> values) {
    return _secondaryWorld.select(selector, values);
  }

  Future<void> tap(String selector) {
    return _secondaryWorld.tap(selector);
  }

  Future<void> type(String selector, String text, {Duration delay}) {
    return _mainWorld.type(selector, text, delay: delay);
  }

  Future<ElementHandle> waitForSelector(String selector,
      {bool visible, bool hidden, Duration timeout}) async {
    var handle = await _secondaryWorld.waitForSelector(selector,
        visible: visible, hidden: hidden, timeout: timeout);
    if (handle == null) {
      return null;
    }
    var mainExecutionContext = await _mainWorld.executionContext;
    var result = await mainExecutionContext.adoptElementHandle(handle);
    await handle.dispose();
    return result;
  }

  Future<ElementHandle> waitForXPath(String xpath,
      {bool visible, bool hidden, Duration timeout}) async {
    var handle = await _secondaryWorld.waitForXPath(xpath,
        visible: visible, hidden: hidden, timeout: timeout);
    if (handle == null) {
      return null;
    }
    var mainExecutionContext = await _mainWorld.executionContext;
    var result = await mainExecutionContext.adoptElementHandle(handle);
    await handle.dispose();
    return result;
  }

  Future<JsHandle> waitForFunction(@javascript String pageFunction, List args,
      {Duration timeout, Polling polling}) {
    return _mainWorld.waitForFunction(pageFunction, args,
        timeout: timeout, polling: polling);
  }

  Future<String> get title {
    return _secondaryWorld.title;
  }

  void _onLifecycleEvent(LoaderId loaderId, String name) {
    if (name == 'init') {
      _loaderId = loaderId;
      lifecycleEvents.clear();
    }
    lifecycleEvents.add(name);
  }

  void _navigated(Frame framePayload) {
    _name = framePayload.name;
    _url = framePayload.url;
  }

  void _navigatedWithinDocument(String url) {
    _url = url;
  }

  void _onLoadingStopped() {
    lifecycleEvents.add('DOMContentLoaded');
    lifecycleEvents.add('load');
  }

  void _detach() {
    _detached = true;
    _mainWorld.detach();
    _secondaryWorld.detach();
    if (_parent != null) {
      _parent.children.remove(this);
    }
    _parent = null;
  }
}
