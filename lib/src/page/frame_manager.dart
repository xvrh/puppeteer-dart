import 'dart:async';
import 'dart:io';
import '../../protocol/network.dart';
import '../../protocol/page.dart';
import '../../protocol/runtime.dart';
import '../connection.dart';
import 'dom_world.dart';
import 'execution_context.dart';
import 'js_handle.dart';
import 'lifecycle_watcher.dart';
import 'mouse.dart';
import 'network_manager.dart';
import 'page.dart';

const _utilityWorldName = '__cdt_utility_world__';

class FrameManager {
  final Page page;
  late final NetworkManager _networkManager;
  final _frames = <FrameId, Frame>{};
  final _contextIdToContext = <ExecutionContextId, ExecutionContext>{};
  final _isolatedWorlds = <String?>{};
  final _lifecycleEventController = StreamController<Frame>.broadcast(),
      _frameAttachedController = StreamController<Frame>.broadcast(),
      _frameNavigatedController = StreamController<Frame>.broadcast(),
      _frameNavigatedWithinDocumentController =
          StreamController<Frame>.broadcast(),
      _frameDetachedController = StreamController<Frame>.broadcast();
  Frame? _mainFrame;

  FrameManager(this.page) {
    _networkManager = NetworkManager(page.session, this);

    _pageApi.onFrameAttached.listen(
        (event) => _onFrameAttached(event.frameId, event.parentFrameId));
    _pageApi.onFrameNavigated.listen((e) => _onFrameNavigated(e.frame));
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

  Stream<Frame> get onLifecycleEvent => _lifecycleEventController.stream;

  Stream<Frame> get onFrameAttached => _frameAttachedController.stream;

  Stream<Frame> get onFrameNavigated => _frameNavigatedController.stream;

  Stream<Frame> get onFrameNavigatedWithinDocument =>
      _frameNavigatedWithinDocumentController.stream;

  Stream<Frame> get onFrameDetached => _frameDetachedController.stream;

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

    await _ensureIsolatedWorld(_utilityWorldName);
  }

  Frame? frame(FrameId? frameId) => _frames[frameId];

  Future<Response> navigateFrame(Frame frame, String url,
      {String? referrer, Duration? timeout, Until? wait}) async {
    referrer ??= _networkManager.extraHTTPHeaders['referer'];
    var watcher = LifecycleWatcher(this, frame,
        wait: wait, timeout: timeout ?? page.navigationTimeoutOrDefault);

    Future<Null> navigate() async {
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
      var error = await Future.any([
        navigate(),
        watcher.timeoutOrTermination,
      ]);

      if (error != null) {
        return Future.error(error);
      }
    } finally {
      watcher.dispose();
    }

    return watcher.navigationResponse ??
        Response.aborted(page.devTools, watcher.navigationRequest);
  }

  Future<Response> waitForFrameNavigation(Frame frame,
      {Until? wait, Duration? timeout}) async {
    var watcher = LifecycleWatcher(this, frame,
        wait: wait, timeout: timeout ?? page.navigationTimeoutOrDefault);
    try {
      var error = await Future.any([
        watcher.timeoutOrTermination,
        watcher.sameDocumentNavigation,
        watcher.newDocumentNavigation,
      ]);

      if (error != null) {
        return Future.error(error);
      }
    } finally {
      watcher.dispose();
    }

    return watcher.navigationResponse ??
        Response.aborted(page.devTools, watcher.navigationRequest);
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
    var parentId = frameTree.frame.parentId;
    if (parentId != null) {
      _onFrameAttached(frameTree.frame.id, parentId);
    }
    _onFrameNavigated(frameTree.frame);
    if (frameTree.childFrames == null) {
      return;
    }

    frameTree.childFrames!.forEach(_handleFrameTree);
  }

  Frame? get mainFrame => _mainFrame;

  List<Frame> get frames => List.unmodifiable(_frames.values);

  Frame? frameById(FrameId frameId) => _frames[frameId];

  void _onFrameAttached(FrameId frameId, FrameId parentFrameId) {
    if (_frames.containsKey(frameId)) return;
    var parentFrame = _frames[parentFrameId];
    var frame = Frame(this, page.session, parentFrame, frameId);
    _frames[frameId] = frame;
    _frameAttachedController.add(frame);
  }

  void _onFrameNavigated(FrameInfo framePayload) {
    var isMainFrame = framePayload.parentId == null;
    var frame = isMainFrame ? _mainFrame : _frames[framePayload.id];
    assert(isMainFrame || frame != null,
        'We either navigate top level or have old version of the navigated frame');

    // Detach all child frames first.
    if (frame != null) {
      // avoid 'Concurrent modification during iteration' Error,
      // by iterating with another iterable object.
      final childFramesForIterate = frame.childFrames.toList(growable: false);
      childFramesForIterate.forEach(_removeFramesRecursively);
    }

    // Update or create main frame.
    if (isMainFrame) {
      if (frame != null) {
        // Update frame id to retain frame identity on cross-process navigation.
        _frames.remove(frame.id);
        frame._id = framePayload.id;
      } else {
        // Initial main frame navigation.
        frame = Frame(this, page.session, null, framePayload.id);
      }
      _frames[framePayload.id] = frame;
      _mainFrame = frame;
    }

    // Update frame payload.
    frame!._navigated(framePayload);

    _frameNavigatedController.add(frame);
  }

  Future<void> _ensureIsolatedWorld(String name) async {
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

  void _onFrameDetached(FrameDetachedEvent event) {
    var frame = _frames[event.frameId];
    if (frame != null) {
      _removeFramesRecursively(frame);
    }
  }

  void _onExecutionContextCreated(ExecutionContextDescription contextPayload) {
    var frameId = contextPayload.auxData != null
        ? contextPayload.auxData!['frameId'] as String?
        : null;
    var frame = frameId != null ? _frames[FrameId(frameId)] : null;
    DomWorld? world;
    if (frame != null) {
      if (contextPayload.auxData != null &&
          contextPayload.auxData!['isDefault'] == true) {
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
        contextPayload.auxData!['type'] == 'isolated') {
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
      context.world!.setContext(null);
    }
  }

  void _onExecutionContextsCleared(_) {
    for (var context in _contextIdToContext.values) {
      if (context.world != null) context.world!.setContext(null);
    }
    _contextIdToContext.clear();
  }

  ExecutionContext executionContextById(ExecutionContextId contextId) {
    var context = _contextIdToContext[contextId];
    assert(context != null,
        'INTERNAL ERROR: missing context with id = ${contextId.value}');
    return context!;
  }

  void _removeFramesRecursively(Frame frame) {
    // avoid 'Concurrent modification during iteration' Error,
    // by iterating with another iterable object.
    final childFramesForIterate = frame.childFrames.toList(growable: false);
    childFramesForIterate.forEach(_removeFramesRecursively);

    frame._detach();
    _frames.remove(frame.id);
    _frameDetachedController.add(frame);
  }
}

/// At every point of time, page exposes its current frame tree via the
/// [page.mainFrame] and [frame.childFrames] methods.
///
/// [Frame] object's lifecycle is controlled by three events, dispatched on the
/// page object:
/// - [Page.onFrameAttached] - fired when the frame gets attached to the page.
///   A Frame can be attached to the page only once.
/// - [Page.onFrameNavigated] - fired when the frame commits navigation to a
///   different URL.
/// - [Page.onFrameDetached] - fired when the frame gets detached from the page.
///   A Frame can be detached from the page only once.
///
/// An example of dumping frame tree:
///
/// ```dart
/// void dumpFrameTree(Frame frame, String indent) {
///   print(indent + frame.url);
///   for (var child in frame.childFrames) {
///     dumpFrameTree(child, indent + '  ');
///   }
/// }
///
/// var browser = await puppeteer.launch();
/// var page = await browser.newPage();
/// await page.goto('https://example.com');
/// dumpFrameTree(page.mainFrame, '');
/// await browser.close();
/// ```
///
/// An example of getting text from an iframe element:
///
/// ```dart
/// var frame = page.frames.firstWhere((frame) => frame.name == 'myframe');
/// var text = await frame.$eval('.selector', 'el => el.textContent');
/// print(text);
/// ```
class Frame {
  final FrameManager frameManager;
  final Client client;
  Frame? _parent;
  FrameId _id;
  final lifecycleEvents = <String?>{};
  final childFrames = <Frame>[];
  late String _url;
  String? _name;
  bool _detached = false;
  LoaderId? _loaderId;
  late final DomWorld _mainWorld, _secondaryWorld;

  Frame(this.frameManager, this.client, this._parent, this._id) {
    _mainWorld = DomWorld(frameManager, this);
    _secondaryWorld = DomWorld(frameManager, this);

    if (_parent != null) {
      _parent!.childFrames.add(this);
    }
  }

  FrameId get id => _id;

  /// Returns frame's url.
  String get url => _url;

  /// Returns frame's name attribute as specified in the tag.
  ///
  /// If the name is empty, returns the id attribute instead.
  ///
  /// > **NOTE** This value is calculated once when the frame is created, and
  /// will not update if the attribute is changed later.
  String? get name => _name;

  /// Returns `true` if the frame has been detached, or `false` otherwise.
  bool get isDetached => _detached;

  LoaderId? get loaderId => _loaderId;

  /// Parent frame, if any. Detached frames and main frames return `null`.
  Frame? get parentFrame => _parent;

  /// The [Frame.goto] will throw an error if:
  /// - there's an SSL error (e.g. in case of self-signed certificates).
  /// - target URL is invalid.
  /// - the `timeout` is exceeded during navigation.
  /// - the main resource failed to load.
  ///
  /// `page.goto` will not throw an error when any valid HTTP status code is
  ///  returned by the remote server, including 404 "Not Found" and 500 "Internal Server Error".
  ///  The status code for such responses can be retrieved by calling [response.status].
  ///
  /// > **NOTE** `page.goto` either throws an error or returns a main resource response.
  ///  The only exceptions are navigation to `about:blank` or navigation to the
  ///  same URL with a different hash, which would succeed and return `null`.
  ///
  /// > **NOTE** Headless mode doesn't support navigation to a PDF document. See
  /// the [upstream issue](https://bugs.chromium.org/p/chromium/issues/detail?id=761295).
  ///
  /// Parameters:
  /// - [url]: URL to navigate page to. The url should include scheme, e.g. `https://`.
  /// - [timeout] Maximum navigation time in milliseconds, defaults
  ///     to 30 seconds, pass [Duration.zero] to disable timeout. The default value
  ///     can be changed by using the [Page.defaultNavigationTimeout] or
  ///     [Page.defaultTimeout] properties.
  /// - [wait] When to consider navigation succeeded, defaults to [Until.load].
  ///     Given an array of event strings, navigation is considered to be
  ///     successful after all events have been fired. Events can be either:
  ///   - [Until.load] - consider navigation to be finished when the `load`
  ///     event is fired.
  ///   - [Until.domContentLoaded] - consider navigation to be finished when the
  ///     `DOMContentLoaded` event is fired.
  ///   - [Until.networkIdle] - consider navigation to be finished when there
  ///     are no more than 0 network connections for at least `500` ms.
  ///   - [Until.networkAlmostIdle] - consider navigation to be finished when
  ///     there are no more than 2 network connections for at least `500` ms.
  /// - [referrer] Referer header value. If provided it will take preference
  ///   over the referer header value set by [Page.setExtraHTTPHeaders].
  ///
  /// Returns: [Future] which resolves to the main resource response. In case
  /// of multiple redirects, the navigation will resolve with the response of
  /// the last redirect.
  Future<Response> goto(String url,
      {String? referrer, Duration? timeout, Until? wait}) {
    return frameManager.navigateFrame(this, url,
        referrer: referrer, timeout: timeout, wait: wait);
  }

  Future<Response> waitForNavigation({Duration? timeout, Until? wait}) {
    return frameManager.waitForFrameNavigation(this,
        timeout: timeout, wait: wait);
  }

  /// Returns promise that resolves to the frame's default execution context.
  Future<ExecutionContext> get executionContext {
    return _mainWorld.executionContext;
  }

  /// The only difference between [Frame.evaluate] and [Frame.evaluateHandle] is
  /// that [Frame.evaluateHandle] returns in-page object (JSHandle).
  ///
  /// If the function passed to the [Frame.evaluateHandle] returns a [Promise],
  /// then [Frame.evaluateHandle] would wait for the promise to resolve and
  /// return its value.
  ///
  /// A JavaScript expression can also be passed in instead of a function:
  /// ```dart
  /// // Get an handle for the 'document'
  /// var aHandle = await frame.evaluateHandle('document');
  /// ```
  ///
  /// [JSHandle] instances can be passed as arguments to the [Frame.evaluateHandle]:
  /// ```dart
  /// var aHandle = await frame.evaluateHandle('() => document.body');
  /// var resultHandle =
  ///     await frame.evaluateHandle('body => body.innerHTML', args: [aHandle]);
  /// print(await resultHandle.jsonValue);
  /// await resultHandle.dispose();
  /// ```
  ///
  /// Parameters:
  /// - [pageFunction] Function to be evaluated in the page context
  /// - [args] Arguments to pass to [pageFunction]
  ///
  /// returns: Future which resolves to the return value of `pageFunction` as
  /// in-page object (JSHandle)
  Future<T> evaluateHandle<T extends JsHandle>(
      @Language('js') String pageFunction,
      {List? args}) {
    return _mainWorld.evaluateHandle(pageFunction, args: args);
  }

  /// If the function passed to the [Frame.evaluate] returns a [Promise], then
  /// [Frame.evaluate] would wait for the promise to resolve and return its value.
  ///
  /// If the function passed to the [Frame.evaluate] returns a non-[Serializable]
  /// value, then `Frame.evaluate` resolves to null.
  /// DevTools Protocol also supports transferring some additional values that
  /// are not serializable by `JSON`: `-0`, `NaN`, `Infinity`, `-Infinity`, and
  /// bigint literals.
  ///
  /// Passing arguments to `pageFunction`:
  /// ```dart
  /// var result = await frame.evaluate<int>('''x => {
  ///           return Promise.resolve(8 * x);
  ///         }''', args: [7]);
  /// print(result); // prints "56"
  /// ```
  ///
  /// An expression can also be passed in instead of a function:
  /// ```dart
  /// print(await frame.evaluate('1 + 2')); // prints "3"
  /// var x = 10;
  /// print(await frame.evaluate('1 + $x')); // prints "11"
  /// ```
  ///
  /// [ElementHandle] instances can be passed as arguments to the [Frame.evaluate]:
  /// ```dart
  /// var bodyHandle = await frame.$('body');
  /// var html = await frame.evaluate('body => body.innerHTML', args: [bodyHandle]);
  /// await bodyHandle.dispose();
  /// print(html);
  /// ```
  ///
  /// Parameters:
  /// - [pageFunction] Function to be evaluated in the page context
  /// - [args] Arguments to pass to `pageFunction`
  /// - Returns: Future which resolves to the return value of `pageFunction`
  Future<T> evaluate<T>(@Language('js') String pageFunction, {List? args}) {
    return _mainWorld.evaluate<T>(pageFunction, args: args);
  }

  /// The method queries frame for the selector. If there's no such element
  /// within the frame, the method will throw an Exception.
  ///
  /// [selector]: A selector to query frame for
  /// Returns a Future which resolves to ElementHandle pointing to the frame
  /// element.
  Future<ElementHandle> $(String selector) {
    return _mainWorld.$(selector);
  }

  /// The method queries frame for the selector. If there's no such element
  /// within the frame, the method will resolve to null.
  ///
  /// [selector]: A selector to query frame for
  /// Returns a Future which resolves to ElementHandle pointing to the frame
  /// element.
  Future<ElementHandle?> $OrNull(String selector) {
    return _mainWorld.$OrNull(selector);
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
  /// var searchValue =
  ///     await frame.$eval('#search', 'function (el) { return el.value; }');
  /// var preloadHref = await frame.$eval(
  ///     'link[rel=preload]', 'function (el) { return el.href; }');
  /// var html = await frame.$eval(
  ///     '.main-container', 'function (e) { return e.outerHTML; }');
  /// ```
  ///
  /// [selector]: A selector to query frame for
  /// [pageFunction]: Function to be evaluated in browser context
  /// [args]: Arguments to pass to pageFunction
  /// Returns a Future which resolves to the return value of pageFunction
  Future<T?> $eval<T>(String selector, @Language('js') String pageFunction,
      {List? args}) {
    return _mainWorld.$eval<T>(selector, pageFunction, args: args);
  }

  /// This method runs `Array.from(document.querySelectorAll(selector))` within
  /// the frame and passes it as the first argument to `pageFunction`.
  ///
  /// If `pageFunction` returns a [Promise], then `frame.$$eval` would wait for
  /// the promise to resolve and return its value.
  ///
  /// Examples:
  /// ```dart
  /// var divsCounts = await frame.$$eval('div', 'divs => divs.length');
  /// ```
  Future<T?> $$eval<T>(String selector, @Language('js') String pageFunction,
      {List? args}) {
    return _mainWorld.$$eval<T>(selector, pageFunction, args: args);
  }

  /// The method runs `document.querySelectorAll` within the frame. If no
  /// elements match the selector, the return value resolves to `[]`.
  ///
  /// Parameters:
  /// A [selector] to query frame for
  ///
  /// Returns a [Future] which resolves to ElementHandles pointing to the frame
  /// elements.
  Future<List<ElementHandle>> $$(String selector) {
    return _mainWorld.$$(selector);
  }

  /// Gets the full HTML contents of the frame, including the doctype.
  Future<String?> get content {
    return _secondaryWorld.content;
  }

  /// Parameters:
  /// - [html]: HTML markup to assign to the page.
  /// - [timeout]: Maximum time in milliseconds for resources to load, defaults
  ///   to 30 seconds, pass `0` to disable timeout. The default value can be
  ///   changed by using the [page.defaultNavigationTimeout] or [page.defaultTimeout].
  /// - [wait] When to consider navigation succeeded, defaults to [Until.load].
  ///     Given an array of event strings, navigation is considered to be
  ///     successful after all events have been fired. Events can be either:
  ///   - [Until.load] - consider navigation to be finished when the `load`
  ///     event is fired.
  ///   - [Until.domContentLoaded] - consider navigation to be finished when the
  ///     `DOMContentLoaded` event is fired.
  ///   - [Until.networkIdle] - consider navigation to be finished when there
  ///     are no more than 0 network connections for at least `500` ms.
  ///   - [Until.networkAlmostIdle] - consider navigation to be finished when
  ///     there are no more than 2 network connections for at least `500` ms.
  Future<void> setContent(String html, {Duration? timeout, Until? wait}) {
    return _secondaryWorld.setContent(html, timeout: timeout, wait: wait);
  }

  /// Adds a `<script>` tag into the page with the desired url or content.
  ///
  /// Parameters:
  /// - [url]: URL of a script to be added.
  /// - [file]: JavaScript file to be injected into frame
  /// - [content]: Raw JavaScript content to be injected into frame.
  /// - [type]: Script type. Use 'module' in order to load a Javascript ES6 module.
  ///   See [script](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script)
  ///   for more details.
  ///
  /// Returns a [Future<ElementHandle>] which resolves to the added tag when the
  /// script's onload fires or when the script content was injected into frame.
  Future<ElementHandle> addScriptTag(
      {String? url, File? file, String? content, String? type}) {
    return _mainWorld.addScriptTag(
        url: url, file: file, content: content, type: type);
  }

  /// Adds a `<link rel="stylesheet">` tag into the page with the desired url or
  /// a `<style type="text/css">` tag with the content.
  ///
  /// Parameters:
  /// [url]: URL of the `<link>` tag.
  /// [file]: CSS file to be injected into frame.
  /// [content]: Raw CSS content to be injected into frame.
  ///
  /// Returns a [Future<ElementHandle>] which resolves to the added tag when the
  /// stylesheet's onload fires or when the CSS content was injected into frame.
  Future<ElementHandle> addStyleTag(
      {String? url, File? file, String? content}) {
    return _mainWorld.addStyleTag(url: url, file: file, content: content);
  }

  /// This method fetches an element with `selector`, scrolls it into view if
  /// needed, and then uses [Page.mouse] to click in the center of the element.
  /// If there's no element matching `selector`, the method throws an error.
  ///
  /// Bear in mind that if `click()` triggers a navigation event and there's a
  /// separate `page.waitForNavigation()` promise to be resolved, you may end
  /// up with a race condition that yields unexpected results. The correct
  /// pattern for click and wait for navigation is the following:
  ///
  /// ```dart
  /// var responseFuture = page.waitForNavigation();
  /// await frame.click('a');
  /// var response = await responseFuture;
  /// ```
  ///
  /// Parameters:
  /// - [selector]: A [selector] to search for element to click. If there are
  ///   multiple elements satisfying the selector, the first will be clicked.
  /// - [button]: <"left"|"right"|"middle"> Defaults to `left`
  /// - [clickCount]: defaults to 1
  /// - [delay]: Time to wait between `mousedown` and `mouseup`. Default to zero.
  Future<void> click(String selector,
      {Duration? delay, MouseButton? button, int? clickCount}) {
    return _secondaryWorld.click(selector,
        delay: delay, button: button, clickCount: clickCount);
  }

  /// This method fetches an element with `selector` and focuses it.
  /// If there's no element matching `selector`, the method throws an error.
  ///
  /// Parameters:
  /// - A [selector] of an element to focus. If there are multiple elements
  ///   satisfying the selector, the first will be focused.
  /// - Promise which resolves when the element matching `selector` is successfully
  ///   focused. The promise will be rejected if there is no element matching `selector`.
  Future<void> focus(String selector) {
    return _secondaryWorld.focus(selector);
  }

  /// This method fetches an element with [selector], scrolls it into view if
  /// needed, and then uses [Page.mouse] to hover over the center of
  /// the element.
  /// If there's no element matching [selector], the method throws an error.
  ///
  /// Parameters:
  /// A [selector] to search for element to hover. If there are multiple elements
  /// satisfying the selector, the first will be hovered.
  ///
  /// Returns: [Future] which resolves when the element matching [selector] is
  /// successfully hovered. Future gets rejected if there's no element matching
  /// [selector].
  Future<void> hover(String selector) {
    return _secondaryWorld.hover(selector);
  }

  /// Triggers a `change` and `input` event once all the provided options have
  /// been selected.
  /// If there's no `<select>` element matching `selector`, the method throws an
  /// error.
  ///
  /// ```dart
  /// await frame.select('select#colors', ['blue']); // single selection
  /// await frame
  ///     .select('select#colors', ['red', 'green', 'blue']); // multiple selections
  /// ```
  ///
  /// Shortcut for [Page.mainFrame.select]
  ///
  /// Parameters:
  /// - [selector]: A [selector] to query page for
  /// - [values]: Values of options to select. If the `<select>` has the
  ///   `multiple` attribute, all values are considered, otherwise only the
  ///   first one is taken into account.
  ///
  /// Returns an array of option values that have been successfully selected.
  Future<List<String>> select(String selector, List<String> values) {
    return _secondaryWorld.select(selector, values);
  }

  /// This method fetches an element with `selector`, scrolls it into view if
  /// needed, and then uses [page.touchscreen] to tap in the center of the element.
  /// If there's no element matching `selector`, the method throws an error.
  ///
  /// Parameters:
  /// A [selector] to search for element to tap. If there are multiple
  /// elements satisfying the selector, the first will be tapped.
  Future<void> tap(String selector) {
    return _secondaryWorld.tap(selector);
  }

  /// Sends a `keydown`, `keypress`/`input`, and `keyup` event for each character
  /// in the text.
  ///
  /// To press a special key, like `Control` or `ArrowDown`, use [`keyboard.press`].
  ///
  /// ```dart
  /// // Types instantly
  /// await frame.type('#mytextarea', 'Hello');
  ///
  /// // Types slower, like a user
  /// await frame.type('#mytextarea', 'World', delay: Duration(milliseconds: 100));
  /// ```
  Future<void> type(String selector, String text, {Duration? delay}) {
    return _mainWorld.type(selector, text, delay: delay);
  }

  /// Wait for the `selector` to appear in page. If at the moment of calling
  /// the method the `selector` already exists, the method will return
  /// immediately. If the selector doesn't appear after the `timeout` of waiting,
  /// the function will throw.
  ///
  /// This method works across navigations:
  /// ```dart
  /// import 'package:puppeteer/puppeteer.dart';
  ///
  /// void main() async {
  ///   var browser = await puppeteer.launch();
  ///   var page = await browser.newPage();
  ///   var watchImg = page.mainFrame.waitForSelector('img');
  ///   await page.goto('https://example.com');
  ///   var image = await watchImg;
  ///   print(await image!.propertyValue('src'));
  ///   await browser.close();
  /// }
  /// ```
  ///
  /// Parameters:
  /// - A [selector] of an element to wait for
  /// - [visible]: wait for element to be present in DOM and to be visible,
  ///   i.e. to not have `display: none` or `visibility: hidden` CSS properties.
  ///   Defaults to `false`.
  /// - [hidden]: wait for element to not be found in the DOM or to be hidden,
  ///   i.e. have `display: none` or `visibility: hidden` CSS properties.
  ///   Defaults to `false`.
  /// - [timeout]:  maximum time to wait for. Pass [Duration.zero]
  ///   to disable timeout. The default value can be changed by using the
  ///   [page.defaultTimeout] property.
  ///
  /// Returns a [Future] which resolves when element specified by selector string
  /// is added to DOM. Resolves to `null` if waiting for `hidden: true` and selector
  /// is not found in DOM.
  Future<ElementHandle?> waitForSelector(String selector,
      {bool? visible, bool? hidden, Duration? timeout}) async {
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

  /// Wait for the `xpath` to appear in page. If at the moment of calling
  /// the method the `xpath` already exists, the method will return
  /// immediately. If the xpath doesn't appear after the `timeout` of waiting,
  /// the function will throw.
  ///
  /// This method works across navigations:
  /// ```dart
  /// import 'package:puppeteer/puppeteer.dart';
  ///
  /// void main() async {
  ///   var browser = await puppeteer.launch();
  ///   var page = await browser.newPage();
  ///   var watchImg = page.mainFrame.waitForXPath('//img');
  ///   await page.goto('https://example.com');
  ///   var image = await watchImg;
  ///   print(await image!.propertyValue('src'));
  ///   await browser.close();
  /// }
  /// ```
  ///
  /// Parameters:
  /// - A [xpath] of an element to wait for
  /// - [visible]: wait for element to be present in DOM and to be visible,
  ///   i.e. to not have `display: none` or `visibility: hidden` CSS properties.
  ///   Defaults to `false`.
  /// - [hidden]: wait for element to not be found in the DOM or to be hidden,
  ///   i.e. have `display: none` or `visibility: hidden` CSS properties.
  ///   Defaults to `false`.
  /// - [timeout]:  maximum time to wait for. Pass [Duration.zero]
  ///   to disable timeout. The default value can be changed by using the
  ///   [page.defaultTimeout] property.
  ///
  /// Returns a [Future] which resolves when element specified by xpath string
  /// is added to DOM. Resolves to `null` if waiting for `hidden: true` and selector
  /// is not found in DOM.
  Future<ElementHandle?> waitForXPath(String xpath,
      {bool? visible, bool? hidden, Duration? timeout}) async {
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

  /// Parameters:
  /// - [pageFunction]: Function to be evaluated in browser context
  /// - [polling]: An interval at which the `pageFunction` is executed, defaults
  ///   to `everyFrame`.
  ///   - [Polling.everyFrame]: to constantly execute `pageFunction` in
  ///     `requestAnimationFrame` callback. This is the tightest polling mode
  ///     which is suitable to observe styling changes.
  ///   - [Polling.mutation]: to execute `pageFunction` on every DOM mutation.
  ///   - [Polling.interval]: An interval at which the function would be executed
  /// - [args]: Arguments to pass to  `pageFunction`
  ///
  /// Returns a [Future] which resolves when the `pageFunction` returns a truthy
  /// value. It resolves to a JSHandle of the truthy value.
  ///
  /// The `waitForFunction` can be used to observe viewport size change:
  /// ```dart
  /// import 'package:puppeteer/puppeteer.dart';
  ///
  /// void main() async {
  ///   var browser = await puppeteer.launch();
  ///   var page = await browser.newPage();
  ///   var watchDog = page.mainFrame.waitForFunction('window.innerWidth < 100');
  ///   await page.setViewport(DeviceViewport(width: 50, height: 50));
  ///   await watchDog;
  ///   await browser.close();
  /// }
  /// ```
  ///
  /// To pass arguments from node.js to the predicate of `page.waitForFunction` function:
  ///
  /// ```dart
  /// var selector = '.foo';
  /// await page.mainFrame.waitForFunction(
  ///     'selector => !!document.querySelector(selector)',
  ///     args: [selector]);
  /// ```
  Future<JsHandle> waitForFunction(@Language('js') String pageFunction,
      {List? args, Duration? timeout, Polling? polling}) {
    return _mainWorld.waitForFunction(pageFunction, args,
        timeout: timeout, polling: polling);
  }

  /// The page's title.
  Future<String?> get title {
    return _secondaryWorld.title;
  }

  void _onLifecycleEvent(LoaderId loaderId, String? name) {
    if (name == 'init') {
      _loaderId = loaderId;
      lifecycleEvents.clear();
    }
    lifecycleEvents.add(name);
  }

  void _navigated(FrameInfo framePayload) {
    _name = framePayload.name;
    _url = '${framePayload.url}${framePayload.urlFragment ?? ''}';
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
      _parent!.childFrames.remove(this);
    }
    _parent = null;
  }
}
