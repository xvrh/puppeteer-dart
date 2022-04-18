import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import '../../protocol/dev_tools.dart';
import '../../protocol/dom.dart';
import '../../protocol/emulation.dart' as protocol;
import '../../protocol/log.dart';
import '../../protocol/network.dart';
import '../../protocol/page.dart';
import '../../protocol/runtime.dart';
import '../../protocol/target.dart';
import '../browser.dart';
import '../connection.dart';
import '../target.dart';
import 'accessibility.dart';
import 'coverage.dart';
import 'dialog.dart';
import 'dom_world.dart';
import 'emulation_manager.dart';
import 'execution_context.dart';
import 'frame_manager.dart';
import 'helper.dart';
import 'js_handle.dart';
import 'keyboard.dart';
import 'lifecycle_watcher.dart';
import 'metrics.dart';
import 'mouse.dart';
import 'network_manager.dart';
import 'touchscreen.dart';
import 'tracing.dart';
import 'worker.dart';

final _logger = Logger('puppeteer.page');

const globalDefaultTimeout = Duration(seconds: 30);

/// Page provides methods to interact with a single tab or extension background
/// page in Chromium. One Browser instance might have multiple Page instances.
///
/// This example creates a page, navigates it to a URL, and then saves a
/// screenshot:
///
/// ```dart
///  import 'dart:io';
///  import 'package:puppeteer/puppeteer.dart';
///
/// void main() async {
///   var browser = await puppeteer.launch();
///   var page = await browser.newPage();
///   await page.goto('https://example.com');
///   await File('screenshot.png').writeAsBytes(await page.screenshot());
///   await browser.close();
/// }
/// ```
///
/// The Page class emits various events which can be handled using any of Dart'
/// native Stream methods, such as listen, first, map, where...
///
/// ```dart
/// page.onLoad.listen((_) => print('Page loaded!'));
/// ```
///
/// To unsubscribe from events use the [StreamSubscription.cancel] method:
/// ```dart
/// void logRequest(Request interceptedRequest) {
///   print('A request was made: ${interceptedRequest.url}');
/// }
///
/// var subscription = page.onRequest.listen(logRequest);
/// await subscription.cancel();
/// ```
class Page {
  /// A target this page was created from.
  final Target target;

  final DevTools devTools;
  final _pageBindings = <String, Function>{};
  final _workers = <SessionID, Worker>{};
  final Coverage coverage;
  final Tracing tracing;
  final Accessibility accessibility;
  late final FrameManager _frameManager = FrameManager(this);
  final _workerCreated = StreamController<Worker>.broadcast(),
      _workerDestroyed = StreamController<Worker>.broadcast(),
      _onErrorController = StreamController<ClientError>.broadcast(),
      _onPopupController = StreamController<Page>.broadcast(),
      _onConsoleController = StreamController<ConsoleMessage>.broadcast(),
      _onDialogController = StreamController<Dialog>.broadcast();
  bool _javascriptEnabled = true;

  /// Maximum navigation time in milliseconds
  /// This setting will change the default maximum navigation time for the
  /// following methods and related shortcuts:
  /// - [Page.goBack]
  /// - [Page.goForward]
  /// - [Page.goto]
  /// - [Page.reload]
  /// - [Page.setContent]
  /// - [Page.waitForNavigation]
  ///
  /// > **NOTE** [page.defaultNavigationTimeout] takes priority over [page.defaultTimeout]
  Duration? defaultNavigationTimeout;

  /// Maximum time in milliseconds
  ///
  /// This setting will change the default maximum time for the following methods
  /// and related shortcuts:
  /// - [Page.goBack]
  /// - [Page.goForward]
  /// - [Page.goto]
  /// - [Page.reload]
  /// - [Page.setContent]
  /// - [Page.waitForFunction]
  /// - [Page.waitForNavigation]
  /// - [Page.waitForRequest]
  /// - [Page.waitForResponse]
  /// - [Page.waitForSelector]
  /// - [Page.waitForXPath]
  ///
  /// > **NOTE** [`page.defaultNavigationTimeout`] takes priority over [`page.defaultTimeout`]
  Duration? defaultTimeout = globalDefaultTimeout;
  DeviceViewport? _viewport;
  final EmulationManager _emulationManager;
  late final Mouse _mouse = Mouse(devTools.input, _keyboard);
  late final Touchscreen _touchscreen =
      Touchscreen(devTools.runtime, devTools.input, _keyboard);
  late final Keyboard _keyboard = Keyboard(devTools.input);
  final _fileChooserInterceptors = <Completer<FileChooser>>{};
  bool _userDragInterceptionEnabled = false;

  Page._(this.target, this.devTools)
      : _emulationManager = EmulationManager(devTools),
        accessibility = Accessibility(devTools),
        coverage = Coverage(devTools),
        tracing = Tracing(devTools) {
    devTools.target.onAttachedToTarget.listen((e) {
      if (e.targetInfo.type != 'worker') {
        // If we don't detach from service workers, they will never die.
        devTools.target
            .detachFromTarget(sessionId: e.sessionId)
            .catchError((e) {
          _logger.finer('[devTools.target.detachFromTarget] swallow error', e);
        });
      } else {
        var session = target.browser.connection.sessions[e.sessionId.value]!;
        var worker = Worker(session, e.targetInfo.url,
            onConsoleApiCalled: _addConsoleMessage,
            onExceptionThrown: _handleException);
        _workers[e.sessionId] = worker;
        _workerCreated.add(worker);
      }
    });
    devTools.target.onDetachedFromTarget.listen((e) {
      var worker = _workers[e.sessionId];
      if (worker != null) {
        _workers.remove(e.sessionId);
        _workerDestroyed.add(worker);
      }
    });

    devTools.runtime.onBindingCalled.listen(_onBindingCalled);
    devTools.page.onJavascriptDialogOpening.listen(_onDialog);
    devTools.runtime.onExceptionThrown.listen(_handleException);
    devTools.inspector.onTargetCrashed.listen(_handleTargetCrashed);
    devTools.runtime.onConsoleAPICalled.listen(_onConsoleApi);
    devTools.log.onEntryAdded.listen(_onLogEntryAdded);
    devTools.page.onFileChooserOpened.listen(_onFileChooser);
    onClose.then((_) {
      _dispose('Page.onClose completed');
    });
    browser.disconnected.then((_) {
      _dispose('Browser.disconnected completed');
    });
  }

  static Future<Page> create(Target target, Session session,
      {DeviceViewport? viewport}) async {
    var devTools = DevTools(session);
    var page = Page._(target, devTools);

    await page._initialize();

    if (viewport != null) {
      await page.setViewport(viewport);
    }

    for (var plugin in page.browser.plugins) {
      await plugin.pageCreated(page);
    }

    return page;
  }

  Future _initialize() async {
    await Future.wait([
      _frameManager.initialize(),
      devTools.target.setAutoAttach(true, false, flatten: true),
      devTools.performance.enable(),
      devTools.log.enable(),
    ]);
  }

  void _onFileChooser(FileChooserOpenedEvent event) async {
    if (_fileChooserInterceptors.isEmpty) {
      return;
    }
    var frame = _frameManager.frame(event.frameId)!;
    var context = await frame.executionContext;
    var element = await context.adoptBackendNodeId(event.backendNodeId);

    var interceptors = _fileChooserInterceptors.toList();
    _fileChooserInterceptors.clear();
    var fileChooser = FileChooser(devTools, element, event);
    for (var interceptor in interceptors) {
      interceptor.complete(fileChooser);
    }
  }

  /// > **NOTE** In non-headless Chromium, this method results in the native file picker dialog **not showing up** for the user.
  ///
  /// This method is typically coupled with an action that triggers file choosing.
  /// The following example clicks a button that issues a file chooser, and then
  /// responds with `/tmp/myfile.pdf` as if a user has selected this file.
  ///
  /// ```dart
  /// var futureFileChooser = page.waitForFileChooser();
  /// // some button that triggers file selection
  /// await page.click('#upload-file-button');
  /// var fileChooser = await futureFileChooser;
  ///
  /// await fileChooser.accept([File('myfile.pdf')]);
  /// ```
  ///
  /// > **NOTE** This must be called *before* the file chooser is launched. It will not return a currently active file chooser.
  ///
  /// Parameters:
  ///  - `timeout` Maximum wait time in milliseconds, defaults to 30
  ///    seconds, pass `0` to disable the timeout. The default value can be
  ///    changed by using the [page.defaultTimeout] property.
  ///  - returns: [Future<FileChooser>] A promise that resolves after a page requests a file picker.
  Future<FileChooser> waitForFileChooser({Duration? timeout}) async {
    if (_fileChooserInterceptors.isEmpty) {
      await devTools.page.setInterceptFileChooserDialog(true);
    }

    timeout ??= defaultTimeout ?? globalDefaultTimeout;
    var callback = Completer<FileChooser>();
    _fileChooserInterceptors.add(callback);

    return callback.future.timeout(timeout).whenComplete(() {
      _fileChooserInterceptors.remove(callback);
    });
  }

  Session get session => devTools.client as Session;

  /// Get the browser the page belongs to.
  Browser get browser => target.browser;

  /// Get the browser context that the page belongs to.
  BrowserContext get browserContext => target.browserContext;

  void _dispose(String reason) {
    session.dispose(reason: reason);

    _frameManager.dispose();
    _workerCreated.close();
    _workerDestroyed.close();
    _onErrorController.close();
    _onPopupController.close();
    _onConsoleController.close();
    _onDialogController.close();
  }

  NetworkManager get _networkManager => _frameManager.networkManager;

  Duration? get navigationTimeoutOrDefault =>
      defaultNavigationTimeout ?? defaultTimeout;

  Stream<Worker> get onWorkerCreated => _workerCreated.stream;

  Stream<Worker> get onWorkerDestroyed => _workerDestroyed.stream;

  /// Emitted when the page crashes.
  Stream get onPageCrashed => devTools.inspector.onTargetCrashed;

  /// Emitted when a frame is attached.
  Stream<Frame> get onFrameAttached => _frameManager.onFrameAttached;

  /// Emitted when a frame is detached.
  Stream<Frame> get onFrameDetached => _frameManager.onFrameDetached;

  /// Emitted when a frame is navigated to a new url.
  Stream<Frame> get onFrameNavigated => _frameManager.onFrameNavigated;

  /// Emitted when a page issues a request.
  /// In order to intercept and mutate requests, see [Page.setRequestInterception].
  Stream<Request> get onRequest => _networkManager.onRequest;

  /// Emitted when a [response] is received.
  Stream<Response> get onResponse => _networkManager.onResponse;

  /// Emitted when a request fails, for example by timing out.
  Stream<Request> get onRequestFailed => _networkManager.onRequestFailed;

  /// Emitted when a request finishes successfully.
  Stream<Request> get onRequestFinished => _networkManager.onRequestFinished;

  /// Emitted when the page opens a new tab or window.
  /// ```dart
  /// var popupFuture = page.onPopup.first;
  /// await page.click('a[target=_blank]');
  /// var popup = await popupFuture;
  /// ```
  ///
  /// ```dart
  /// var popupFuture = page.onPopup.first;
  /// await page.evaluate("() => window.open('https://example.com')");
  /// var popup = await popupFuture;
  /// ```
  Stream<Page> get onPopup => _onPopupController.stream;

  /// Complete when the page closes.
  Future<void> get onClose => target.onClose;

  /// Emitted when JavaScript within the page calls one of console API methods,
  /// e.g. console.log or console.dir. Also emitted if the page throws an error
  /// or a warning.
  ///
  /// The arguments passed into console.log appear as arguments on the event
  /// handler.
  ///
  /// An example of handling console event:
  ///
  /// ```dart
  /// page.onConsole.listen((msg) {
  ///   for (var i = 0; i < msg.args.length; ++i) {
  ///     print('$i: ${msg.args[i]}');
  ///   }
  /// });
  /// await page.evaluate("() => console.log('hello', 5, {foo: 'bar'})");
  /// ```
  Stream<ConsoleMessage> get onConsole => _onConsoleController.stream;

  /// Emitted when the JavaScript [`DOMContentLoaded`](https://developer.mozilla.org/en-US/docs/Web/Events/DOMContentLoaded)
  /// event is dispatched.
  Stream<MonotonicTime> get onDomContentLoaded =>
      devTools.page.onDomContentEventFired;

  /// Emitted when the JavaScript [`load`](https://developer.mozilla.org/en-US/docs/Web/Events/load)
  /// event is dispatched.
  Stream<MonotonicTime> get onLoad => devTools.page.onLoadEventFired;

  /// Emitted when an uncaught exception happens within the page.
  Stream<ClientError> get onError => _onErrorController.stream;

  /// Emitted when a JavaScript dialog appears, such as `alert`, `prompt`,
  /// `confirm` or `beforeunload`. Puppeteer can respond to the dialog via
  /// [Dialog.accept] or [Dialog.dismiss] methods.
  Stream<Dialog> get onDialog => _onDialogController.stream;

  /// Emitted when the JavaScript code makes a call to `console.timeStamp`.
  /// For the list of metrics see `page.metrics`.
  ///
  /// Result:
  ///  - `title` The title passed to `console.timeStamp`.
  ///  - `metrics` Object containing the metrics.
  Stream<MetricsEvent> get onMetrics => devTools.performance.onMetrics
      .map((e) => MetricsEvent(e.title, Metrics.fromBrowser(e.metrics)));

  FrameManager get frameManager => _frameManager;

  /// Indicates that the page has been closed.
  bool get isClosed => session.isClosed;

  /// The page's main frame.
  ///
  /// Page is guaranteed to have a main frame which persists during navigations.
  Frame get mainFrame => _frameManager.mainFrame!;

  bool get hasMainFrame => _frameManager.mainFrame != null;

  Keyboard get keyboard => _keyboard;

  Touchscreen get touchscreen => _touchscreen;

  Mouse get mouse => _mouse;

  bool get isDragInterceptionEnabled => _userDragInterceptionEnabled;

  /// An array of all frames attached to the page.
  List<Frame> get frames => frameManager.frames;

  /// This method returns all of the dedicated [WebWorkers](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API)
  /// associated with the page.
  ///
  /// > **NOTE** This does not contain ServiceWorkers
  List<Worker> get workers => _workers.values.toList();

  void _onDialog(JavascriptDialogOpeningEvent event) {
    var dialog = Dialog(this, event);
    _onDialogController.add(dialog);
  }

  void _onConsoleApi(ConsoleAPICalledEvent event) {
    if (event.executionContextId.value == 0) {
      // DevTools protocol stores the last 1000 console messages. These
      // messages are always reported even for removed execution contexts. In
      // this case, they are marked with executionContextId = 0 and are
      // reported upon enabling Runtime agent.
      //
      // Ignore these messages since:
      // - there's no execution context we can use to operate with message
      //   arguments
      // - these messages are reported before Puppeteer clients can subscribe
      //   to the 'console'
      //   page event.
      //
      // @see https://github.com/GoogleChrome/puppeteer/issues/3865
      return;
    }
    var context = frameManager.executionContextById(event.executionContextId);
    var values = event.args
        .map((arg) => JsHandle.fromRemoteObject(context, arg))
        .toList();
    _addConsoleMessage(event.type, values, event.stackTrace);
  }

  void _addConsoleMessage(ConsoleAPICalledEventType type, List<JsHandle> args,
      StackTraceData? stackTrace) {
    if (!_onConsoleController.hasListener) {
      args.forEach((arg) => arg.dispose());
      return;
    }
    var textTokens = [];
    for (var arg in args) {
      var remoteObject = arg.remoteObject;
      if (remoteObject.objectId != null) {
        textTokens.add(arg.toString());
      } else {
        textTokens.add(valueFromRemoteObject(remoteObject));
      }
    }

    String? url;
    int? lineNumber, columnNumber;
    if (stackTrace != null && stackTrace.callFrames.isNotEmpty) {
      url = stackTrace.callFrames[0].url;
      lineNumber = stackTrace.callFrames[0].lineNumber;
      columnNumber = stackTrace.callFrames[0].columnNumber;
    }
    var message = ConsoleMessage(ConsoleMessageType._fromEventType(type),
        type.value, textTokens.join(' '), args,
        url: url, lineNumber: lineNumber, columnNumber: columnNumber);
    _onConsoleController.add(message);
  }

  void _onLogEntryAdded(LogEntry event) {
    if (event.args != null && event.args!.isNotEmpty) {
      event.args!.map((arg) => releaseObject(devTools.runtime, arg));
    }
    if (event.source != LogEntrySource.worker) {
      _onConsoleController.add(ConsoleMessage(
          ConsoleMessageType._fromLogLevel(event.level),
          event.level.value,
          event.text,
          [],
          url: event.url,
          lineNumber: event.lineNumber));
    }
  }

  /// Whether to enable request interception.
  ///
  /// Activating request interception enables `request.abort`, `request.continue`
  /// and `request.respond` methods. This provides the capability to modify
  /// network requests that are made by a page.
  ///
  /// Once request interception is enabled, every request will stall unless it's
  /// continued, responded or aborted.
  /// An example of a naïve request interceptor that aborts all image requests:
  ///
  /// ```dart
  /// var browser = await puppeteer.launch();
  /// var page = await browser.newPage();
  /// await page.setRequestInterception(true);
  /// page.onRequest.listen((interceptedRequest) {
  ///   if (interceptedRequest.url.endsWith('.png') ||
  ///       interceptedRequest.url.endsWith('.jpg')) {
  ///     interceptedRequest.abort();
  ///   } else {
  ///     interceptedRequest.continueRequest();
  ///   }
  /// });
  /// await page.goto('https://example.com');
  /// await browser.close();
  /// ```
  ///
  /// > **NOTE** Enabling request interception disables page caching.
  Future<void> setRequestInterception(bool value) {
    return _frameManager.networkManager.setRequestInterception(value);
  }

  /// @param enabled - Whether to enable drag interception.
  ///
  /// @remarks
  /// Activating drag interception enables the {@link Input.drag},
  /// methods  This provides the capability to capture drag events emitted
  /// on the page, which can then be used to simulate drag-and-drop.
  Future<void> setDragInterception(bool enabled) async {
    _userDragInterceptionEnabled = enabled;
    await devTools.input.setInterceptDrags(enabled);
  }

  /// When `true`, enables offline mode for the page.
  Future<void> setOfflineMode(bool enabled) {
    return _frameManager.networkManager.setOfflineMode(enabled);
  }

  /// The method runs `document.querySelector` within the page. If no element matches the selector, it throws an exception.
  /// If you know that no element may match use `$OrNull(selector)` which will return `null` if no element matches the selector.
  ///
  /// Shortcut for [Page.mainFrame.$(selector)].
  ///
  /// A [selector] to query page for
  Future<ElementHandle> $(String selector) {
    return mainFrame.$(selector);
  }

  /// The method runs `document.querySelector` within the page. If no element matches the selector, the return value resolves to `null`.
  ///
  /// Shortcut for [Page.mainFrame.$(selector)].
  ///
  /// A [selector] to query page for
  Future<ElementHandle?> $OrNull(String selector) {
    return mainFrame.$OrNull(selector);
  }

  /// The only difference between [Page.evaluate] and [Page.evaluateHandle] is
  /// that [Page.evaluateHandle] returns in-page object (JSHandle).
  ///
  /// If the function passed to the [Page.evaluateHandle] returns a [Promise],
  /// then [Page.evaluateHandle] would wait for the promise to resolve and
  /// return its value.
  ///
  /// A JavaScript expression can also be passed in instead of a function:
  /// ```dart
  /// // Get an handle for the 'document'
  /// var aHandle = await page.evaluateHandle('document');
  /// ```
  ///
  /// [JSHandle] instances can be passed as arguments to the [Page.evaluateHandle]:
  /// ```dart
  /// var aHandle = await page.evaluateHandle('() => document.body');
  /// var resultHandle =
  ///     await page.evaluateHandle('body => body.innerHTML', args: [aHandle]);
  /// print(await resultHandle.jsonValue);
  /// await resultHandle.dispose();
  /// ```
  ///
  /// Shortcut for [Page.mainFrame.executionContext.evaluateHandle].
  ///
  /// Parameters:
  /// - [pageFunction] Function to be evaluated in the page context
  /// - [args] Arguments to pass to [pageFunction]
  ///
  /// returns: Future which resolves to the return value of `pageFunction` as
  /// in-page object (JSHandle)
  Future<T> evaluateHandle<T extends JsHandle>(
      @Language('js') String pageFunction,
      {List? args}) async {
    var context = await mainFrame.executionContext;
    return context.evaluateHandle(pageFunction, args: args);
  }

  /// The method iterates the JavaScript heap and finds all the objects with the
  /// given prototype.
  ///
  /// ```dart
  /// // Create a Map object
  /// await page.evaluate('() => window.map = new Map()');
  /// // Get a handle to the Map object prototype
  /// var mapPrototype = await page.evaluateHandle('() => Map.prototype');
  /// // Query all map instances into an array
  /// var mapInstances = await page.queryObjects(mapPrototype);
  /// // Count amount of map objects in heap
  /// var count = await page.evaluate('maps => maps.length', args: [mapInstances]);
  /// await mapInstances.dispose();
  /// await mapPrototype.dispose();
  /// ```
  ///
  /// Shortcut for [Page.mainFrame.executionContext.queryObjects].
  ///
  /// Parameters:
  /// [prototypeHandle]: A handle to the object prototype.
  ///
  /// Returns a [Future] which completes to a handle to an array of objects with
  /// this prototype.
  Future<JsHandle> queryObjects(JsHandle prototypeHandle) async {
    var context = await mainFrame.executionContext;
    return context.queryObjects(prototypeHandle);
  }

  /// This method runs `document.querySelector` within the page and passes it as
  /// the first argument to `pageFunction`. If there's no element matching
  /// `selector`, the method throws an error.
  ///
  /// If `pageFunction` returns a [Promise], then `page.$eval` would wait for
  /// the promise to resolve and return its value.
  ///
  /// Examples:
  /// ```dart
  /// var searchValue =
  ///     await page.$eval('#search', 'function (el) { return el.value; }');
  /// var preloadHref = await page.$eval(
  ///     'link[rel=preload]', 'function (el) { return el.href; }');
  /// var html = await page.$eval(
  ///     '.main-container', 'function (e) { return e.outerHTML; }');
  /// ```
  ///
  /// Shortcut for [Page.mainFrame.$eval(selector, pageFunction)].
  Future<T?> $eval<T>(String selector, @Language('js') String pageFunction,
      {List? args}) {
    return mainFrame.$eval<T>(selector, pageFunction, args: args);
  }

  /// This method runs `Array.from(document.querySelectorAll(selector))` within
  /// the page and passes it as the first argument to `pageFunction`.
  ///
  /// If `pageFunction` returns a [Promise], then `page.$$eval` would wait for
  /// the promise to resolve and return its value.
  ///
  /// Examples:
  /// ```dart
  /// var divsCounts = await page.$$eval('div', 'divs => divs.length');
  /// ```
  ///
  /// Parameters:
  /// A [selector] to query page for
  /// [pageFunction] Function to be evaluated in browser context
  /// [args] Arguments to pass to `pageFunction`
  /// Returns a [Future] which resolves to the return value of `pageFunction`
  Future<T?> $$eval<T>(String selector, @Language('js') String pageFunction,
      {List? args}) {
    return mainFrame.$$eval<T>(selector, pageFunction, args: args);
  }

  /// The method runs `document.querySelectorAll` within the page.
  /// If no elements match the selector, the return value resolves to `[]`.
  ///
  /// Shortcut for [Page.mainFrame.$$(selector)].
  Future<List<ElementHandle>> $$(String selector) {
    return mainFrame.$$(selector);
  }

  /// The method evaluates the XPath expression.
  ///
  /// Shortcut for [Page.mainFrame.$x(expression)]
  ///
  /// Parameters:
  /// [expression]: Expression to [evaluate](https://developer.mozilla.org/en-US/docs/Web/API/Document/evaluate)
  Future<List<ElementHandle>> $x(String expression) {
    return mainFrame.$x(expression);
  }

  /// If no URLs are specified, this method returns cookies for the current page URL.
  /// If URLs are specified, only cookies for those URLs are returned.
  Future<List<Cookie>> cookies({List<String>? urls}) {
    return devTools.network.getCookies(urls: urls);
  }

  Future<void> deleteCookie(String name, {String? domain, String? path}) async {
    var pageUrl = url!;
    await devTools.network.deleteCookies(name,
        url: pageUrl.startsWith('http') ? pageUrl : null,
        domain: domain,
        path: path);
  }

  Future<void> setCookies(List<CookieParam> cookies) async {
    var pageURL = url!;
    var startsWithHTTP = pageURL.startsWith('http');
    var items = cookies.map((cookie) {
      String? cookieUrl;
      if (cookie.url == null && startsWithHTTP) {
        cookieUrl = pageURL;
      }
      if (cookieUrl != null) {
        assert(cookieUrl != 'about:blank',
            'Blank page can not have cookie "${cookie.name}"');
        assert(!cookieUrl.startsWith('data:'),
            'Data URL page can not have cookie "${cookie.name}"');
      }
      return CookieParam(
          name: cookie.name,
          value: cookie.value,
          url: cookieUrl,
          domain: cookie.domain,
          path: cookie.path,
          secure: cookie.secure,
          httpOnly: cookie.httpOnly,
          sameSite: cookie.sameSite,
          expires: cookie.expires);
    }).toList();
    for (var cookie in items) {
      await deleteCookie(cookie.name, domain: cookie.domain, path: cookie.path);
    }
    if (items.isNotEmpty) {
      await devTools.network.setCookies(items);
    }
  }

  /// Sets the page's geolocation.
  ///
  /// ```dart
  /// await page.setGeolocation(latitude: 59.95, longitude: 30.31667);
  /// ```
  ///
  /// > **NOTE** Consider using [BrowserContext.overridePermissions] to grant
  /// permissions for the page to read its geolocation.
  Future<void> setGeolocation(
      {required num latitude, required num longitude, num? accuracy}) async {
    accuracy ??= 0;
    assert(longitude >= -180 && longitude <= 180,
        'Invalid longitude "$longitude": precondition -180 <= LONGITUDE <= 180 failed.');
    assert(latitude >= -90 && latitude <= 90,
        'Invalid latitude "$latitude": precondition -90 <= LATITUDE <= 90 failed.');
    assert(accuracy >= 0,
        'Invalid accuracy "$accuracy": precondition 0 <= ACCURACY failed.');
    await devTools.emulation.setGeolocationOverride(
        latitude: latitude, longitude: longitude, accuracy: accuracy);
  }

  /// Adds a `<script>` tag into the page with the desired url or content.
  ///
  /// Shortcut for [Page.mainFrame.addScriptTag].
  ///
  /// Parameters:
  /// [url]: URL of a script to be added.
  /// [file]: JavaScript file to be injected into frame
  /// [content]: Raw JavaScript content to be injected into frame.
  /// [type]: Script type. Use 'module' in order to load a Javascript ES6 module.
  /// See [script](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script)
  /// for more details.
  ///
  /// Returns a [Future<ElementHandle>] which resolves to the added tag when the
  /// script's onload fires or when the script content was injected into frame.
  Future<ElementHandle> addScriptTag(
      {String? url, File? file, String? content, String? type}) {
    return mainFrame.addScriptTag(
        url: url, file: file, content: content, type: type);
  }

  /// Adds a `<link rel="stylesheet">` tag into the page with the desired url or
  /// a `<style type="text/css">` tag with the content.
  ///
  /// Shortcut for [Page.mainFrame.addStyleTag].
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
    return mainFrame.addStyleTag(url: url, file: file, content: content);
  }

  static final _addPageBinding =
      //language=js
      '''
function addPageBinding(bindingName) {
  const binding = window[bindingName];
  window[bindingName] = (...args) => {
    const me = window[bindingName];
    let callbacks = me['callbacks'];
    if (!callbacks) {
      callbacks = new Map();
      me['callbacks'] = callbacks;
    }
    const seq = (me['lastSeq'] || 0) + 1;
    me['lastSeq'] = seq;
    const promise = new Promise((resolve, reject) => callbacks.set(seq, {resolve, reject}));
    binding(JSON.stringify({name: bindingName, seq, args}));
    return promise;
  };
}
''';

  /// The method adds a function called `name` on the page's `window` object.
  /// When called, the function executes `puppeteerFunction` in Dart and
  /// returns a [Promise] which resolves to the return value of `puppeteerFunction`.
  ///
  /// If the `puppeteerFunction` returns a [Future], it will be awaited.
  ///
  /// > **NOTE** Functions installed via `page.exposeFunction` survive navigations.
  ///
  /// An example of adding an `md5` function into the page:
  /// ```dart
  /// import 'dart:convert';
  /// import 'package:puppeteer/puppeteer.dart';
  /// import 'package:crypto/crypto.dart' as crypto;
  ///
  /// void main() async {
  ///   var browser = await puppeteer.launch();
  ///   var page = await browser.newPage();
  ///   page.onConsole.listen((msg) => print(msg.text));
  ///   await page.exposeFunction('md5',
  ///       (String text) => crypto.md5.convert(utf8.encode(text)).toString());
  ///   await page.evaluate(r'''async () => {
  ///             // use window.md5 to compute hashes
  ///             const myString = 'PUPPETEER';
  ///             const myHash = await window.md5(myString);
  ///             console.log(`md5 of ${myString} is ${myHash}`);
  ///           }''');
  ///   await browser.close();
  /// }
  /// ```
  ///
  /// An example of adding a `window.readfile` function into the page:
  ///
  /// ```dart
  /// import 'dart:io';
  /// import 'package:puppeteer/puppeteer.dart';
  ///
  /// void main() async {
  ///   var browser = await puppeteer.launch();
  ///   var page = await browser.newPage();
  ///   page.onConsole.listen((msg) => print(msg.text));
  ///   await page.exposeFunction('readfile', (String path) async {
  ///     return File(path).readAsString();
  ///   });
  ///   await page.evaluate('''async () => {
  ///             // use window.readfile to read contents of a file
  ///             const content = await window.readfile('test/assets/simple.json');
  ///             console.log(content);
  ///           }''');
  ///   await browser.close();
  /// }
  /// ```
  ///
  /// Parameters:
  /// - [name]: Name of the function on the window object
  //- [puppeteerFunction]: Callback function which will be called in Dart's context.
  Future<void> exposeFunction(String name, Function callbackFunction) async {
    if (_pageBindings.containsKey(name)) {
      throw Exception(
          'Failed to add page binding with name $name: window["$name"] already exists!');
    }
    _pageBindings[name] = callbackFunction;

    var expression = evaluationString(_addPageBinding, [name]);
    await devTools.runtime.addBinding(name);
    await devTools.page.addScriptToEvaluateOnNewDocument(expression);
    await Future.wait(
        frameManager.frames.map((frame) => frame.evaluate(expression)));
  }

  /// Provide credentials for [HTTP authentication](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication).
  ///
  /// To disable authentication, pass `null`.
  Future<void> authenticate({String? username, String? password}) {
    return _frameManager.networkManager.authenticate(
        username == null ? null : Credentials(username, password));
  }

  /// The extra HTTP headers will be sent with every request the page initiates.
  ///
  /// > **NOTE** page.setExtraHTTPHeaders does not guarantee the order of headers
  ///  in the outgoing requests.
  Future<void> setExtraHTTPHeaders(Map<String, String> headers) async {
    await _frameManager.networkManager.setExtraHTTPHeaders(headers);
  }

  /// Specific user agent to use in this page
  Future<void> setUserAgent(String userAgent) async {
    await _frameManager.networkManager.setUserAgent(userAgent);
  }

  /// Returns an object containing metrics of the page.
  ///   - `Timestamp` The timestamp when the metrics sample was taken.
  ///   - `Documents` Number of documents in the page.
  ///   - `Frames` Number of frames in the page.
  ///   - `JSEventListeners` Number of events in the page.
  ///   - `Nodes` Number of DOM nodes in the page.
  ///   - `LayoutCount` Total number of full or partial page layout.
  ///   - `RecalcStyleCount` Total number of page style recalculations.
  ///   - `LayoutDuration` Combined durations of all page layouts.
  ///   - `RecalcStyleDuration` Combined duration of all page style recalculations.
  ///   - `ScriptDuration` Combined duration of JavaScript execution.
  ///   - `TaskDuration` Combined duration of all tasks performed by the browser.
  ///   - `JSHeapUsedSize` Used JavaScript heap size.
  ///   - `JSHeapTotalSize` Total JavaScript heap size.
  ///
  /// > **NOTE** All timestamps are in monotonic time: monotonically increasing
  /// time in seconds since an arbitrary point in the past.
  Future<Metrics> metrics() async {
    return Metrics.fromBrowser(await devTools.performance.getMetrics());
  }

  void _handleException(ExceptionThrownEvent event) {
    _onErrorController.add(ClientError(event.exceptionDetails));
  }

  void _handleTargetCrashed(_) {
    _onErrorController.add(ClientError.pageCrashed());
    Future(() => _dispose('Target crashed'));
  }

  Future _onBindingCalled(BindingCalledEvent event) async {
    var payload = jsonDecode(event.payload) as Map<String, dynamic>;
    var name = payload['name'] as String?;
    var seq = payload['seq'] as int?;
    var args = payload['args'] as List?;

    String expression;
    try {
      var callback = _pageBindings[name!]!;
      var result = await Function.apply(callback, args);
      expression = evaluationString(_deliverResult, [name, seq, result]);
    } catch (error, stackTrace) {
      expression = evaluationString(
          _deliverError, [name, seq, error.toString(), stackTrace.toString()]);
    }
    try {
      await devTools.runtime
          .evaluate(expression, contextId: event.executionContextId);
    } on TargetClosedException catch (_) {
      // It is possible to have a data race, so we don't care if we don't
      // receive the response here.
    }
  }

  static final _deliverResult = '''
function deliverResult(name, seq, result) {
  window[name]['callbacks'].get(seq).resolve(result);
  window[name]['callbacks'].delete(seq);
}  
''';

  static final _deliverError = '''
function deliverError(name, seq, message, stack) {
  const error = new Error(message);
  error.stack = stack;
  window[name]['callbacks'].get(seq).reject(error);
  window[name]['callbacks'].delete(seq);
}
''';

  /// This is a shortcut for [page.mainFrame.url]
  String? get url {
    return mainFrame.url;
  }

  /// Gets the full HTML contents of the page, including the doctype.
  Future<String?> get content {
    return mainFrame.content;
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
    return mainFrame.setContent(html, timeout: timeout, wait: wait);
  }

  /// The [Page.goto] will throw an error if:
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
  /// Shortcut for [Page.mainFrame.goto]
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
    return mainFrame.goto(url,
        referrer: referrer, timeout: timeout, wait: wait);
  }

  /// Parameters:
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
  Future<Response> reload({Duration? timeout, Until? wait}) async {
    var responseFuture = waitForNavigation(timeout: timeout, wait: wait);

    await devTools.page.reload();
    return await responseFuture;
  }

  /// This resolves when the page navigates to a new URL or reloads. It is useful
  /// for when you run code which will indirectly cause the page to navigate.
  /// Consider this example:
  ///
  /// ```dart
  /// await Future.wait([
  ///   // The future completes after navigation has finished
  ///   page.waitForNavigation(),
  ///   // Clicking the link will indirectly cause a navigation
  ///   page.click('a.my-link'),
  /// ]);
  /// ```
  ///
  /// **NOTE** Usage of the [History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API)
  /// to change the URL is considered a navigation.
  ///
  /// Shortcut for [page.mainFrame.waitForNavigation].
  ///
  /// Parameters:
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
  ///
  /// Returns: [Future] which resolves to the main resource response. In case
  /// of multiple redirects, the navigation will resolve with the response of
  /// the last redirect.
  /// In case of navigation to a different anchor or navigation due to History
  /// API usage, the navigation will resolve with `null`.
  Future<Response> waitForNavigation({Duration? timeout, Until? wait}) {
    return mainFrame.waitForNavigation(timeout: timeout, wait: wait);
  }

  /// Example:
  /// ```dart
  /// var firstRequest = page.waitForRequest('https://example.com');
  ///
  /// // You can achieve the same effect (and more powerful) with the `onRequest`
  /// // stream.
  /// var finalRequest = page.onRequest
  ///     .where((request) =>
  ///         request.url.startsWith('https://example.com') &&
  ///         request.method == 'GET')
  ///     .first
  ///     .timeout(Duration(seconds: 30));
  ///
  /// await page.goto('https://example.com');
  /// await Future.wait([firstRequest, finalRequest]);
  /// ```
  Future<Request> waitForRequest(String url, {Duration? timeout}) async {
    timeout ??= defaultTimeout ?? globalDefaultTimeout;

    return onRequest
        .where((request) =>
            path.url.normalize(request.url) == path.url.normalize(url))
        .first
        .timeout(timeout);
  }

  Future<Response> waitForResponse(String url, {Duration? timeout}) {
    timeout ??= defaultTimeout ?? globalDefaultTimeout;

    return frameManager.networkManager.onResponse
        .where((response) =>
            path.url.normalize(response.url) == path.url.normalize(url))
        .first
        .timeout(timeout);
  }

  /// Navigate to the previous page in history.
  ///
  /// Parameters:
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
  ///
  /// Returns: [Future<Response>] which resolves to the main resource
  /// response. In case of multiple redirects, the navigation will resolve with
  /// the response of the last redirect. If can not go back, resolves to `null`.
  Future<Response?> goBack({Duration? timeout, Until? wait}) {
    return _go(-1, timeout: timeout, wait: wait);
  }

  /// Navigate to the next page in history.
  ///
  /// Parameters:
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
  ///
  /// Returns: [Future<Response>] which resolves to the main resource
  /// response. In case of multiple redirects, the navigation will resolve with
  /// the response of the last redirect. If can not go back, resolves to `null`.
  Future<Response?> goForward({Duration? timeout, Until? wait}) {
    return _go(1, timeout: timeout, wait: wait);
  }

  Future<Response?> _go(int delta, {Duration? timeout, Until? wait}) async {
    var history = await devTools.page.getNavigationHistory();
    var index = history.currentIndex + delta;
    if (index < 0 || index >= history.entries.length) {
      return null;
    }
    var entry = history.entries[index];
    var navigationFuture = waitForNavigation(timeout: timeout, wait: wait);
    await devTools.page.navigateToHistoryEntry(entry.id);
    return await navigationFuture;
  }

  /// Brings page to front (activates tab).
  Future<void> bringToFront() async {
    await devTools.page.bringToFront();
  }

  /// Emulates given device metrics and user agent. This method is a shortcut
  /// for calling two methods:
  /// - [Page.setUserAgent]
  /// - [Page.setViewport]
  ///
  /// To aid emulation, puppeteer provides a list of device descriptors which can
  ///  be obtained via the [puppeteer.devices].
  ///
  /// `page.emulate` will resize the page. A lot of websites don't expect phones
  /// to change size, so you should emulate before navigating to the page.
  ///
  /// ```dart
  /// var iPhone = puppeteer.devices.iPhone6;
  ///
  /// var browser = await puppeteer.launch();
  /// var page = await browser.newPage();
  /// await page.emulate(iPhone);
  /// await page.goto('https://example.com');
  /// // other actions...
  /// await browser.close();
  /// ```
  ///
  /// List of all available devices is available in the source code:
  /// [devices.dart](https://github.com/xvrh/puppeteer-dart/blob/master/lib/src/devices.dart).
  Future<void> emulate(Device device) async {
    await setViewport(device.viewport);
    await setUserAgent(device.userAgent(
        (await devTools.browser.getVersion()).product.split('/').last));
  }

  bool get javascriptEnabled => _javascriptEnabled;

  /// Whether or not to enable JavaScript on the page.
  ///
  /// > **NOTE** changing this value won't affect scripts that have already been
  /// run. It will take full effect on the next [navigation].
  Future<void> setJavaScriptEnabled(bool enabled) async {
    if (_javascriptEnabled == enabled) {
      return;
    }
    _javascriptEnabled = enabled;

    await devTools.emulation.setScriptExecutionDisabled(!enabled);
  }

  /// Toggles bypassing page's Content-Security-Policy.
  ///
  /// > **NOTE** CSP bypassing happens at the moment of CSP initialization rather
  /// then evaluation. Usually this means that `page.setBypassCSP` should be called
  /// before navigating to the domain.
  Future<void> setBypassCSP(bool enabled) {
    return devTools.page.setBypassCSP(enabled);
  }

  @Deprecated('Use emulateMediaType(mediaType)')
  Future<void> emulateMedia(String? mediaType) {
    assert(mediaType == 'screen' || mediaType == 'print' || mediaType == null,
        'Unsupported media type: $mediaType');
    mediaType ??= '';
    return devTools.emulation.setEmulatedMedia(media: mediaType);
  }

  /// Changes the CSS media type of the page.
  /// The only allowed values are `'screen'`, `'print'` and `null`.
  /// Passing `null` disables media emulation.
  /// ```dart
  /// expect(await page.evaluate("() => matchMedia('screen').matches"), isTrue);
  /// expect(await page.evaluate("() => matchMedia('print').matches"), isFalse);
  ///
  /// await page.emulateMediaType(MediaType.print);
  /// expect(await page.evaluate("() => matchMedia('screen').matches"), isFalse);
  /// expect(await page.evaluate("() => matchMedia('print').matches"), isTrue);
  ///
  /// await page.emulateMediaType(null);
  /// expect(await page.evaluate("() => matchMedia('screen').matches"), isTrue);
  /// expect(await page.evaluate("() => matchMedia('print').matches"), isFalse);
  /// ```
  Future<void> emulateMediaType(MediaType? mediaType) {
    var mediaTypeName = mediaType?.name ?? '';
    return devTools.emulation.setEmulatedMedia(media: mediaTypeName);
  }

  /// Given an array of media feature objects, emulates CSS media features on
  /// the page.
  Future<void> emulateMediaFeatures(List<MediaFeature>? features) async {
    if (features == null || features.isEmpty) {
      // We cannot use the generated client because sending null or omiting the
      // value has different signification
      await devTools.client
          .send('Emulation.setEmulatedMedia', {'features': null});
    } else {
      await devTools.emulation.setEmulatedMedia(
          features: features
              .map((f) => protocol.MediaFeature(name: f.name, value: f.value))
              .toList());
    }
  }

  Future<void> emulateTimezone(String timezoneId) async {
    try {
      await devTools.emulation.setTimezoneOverride(timezoneId);
    } catch (exception) {
      if ('$exception'.contains('Invalid timezone')) {
        throw Exception('Invalid timezone ID: $timezoneId');
      }
      rethrow;
    }
  }

  /// > **NOTE** in certain cases, setting viewport will reload the page in order
  /// to set the `isMobile` or `hasTouch` properties.
  ///
  /// In the case of multiple pages in a single browser, each page can have its
  /// own viewport size.
  Future<void> setViewport(DeviceViewport viewport) async {
    var needsReload = await _emulationManager.emulateViewport(viewport);
    _viewport = viewport;
    if (needsReload) {
      await reload();
    }
  }

  DeviceViewport? get viewport => _viewport;

  /// If the function passed to the [Page.evaluate] returns a [Promise], then
  /// [Page.evaluate] would wait for the promise to resolve and return its value.
  ///
  /// If the function passed to the [page.evaluate] returns a non-[Serializable]
  /// value, then `page.evaluate` resolves to null.
  /// DevTools Protocol also supports transferring some additional values that
  /// are not serializable by `JSON`: `-0`, `NaN`, `Infinity`, `-Infinity`, and
  /// bigint literals.
  ///
  /// Passing arguments to `pageFunction`:
  /// ```dart
  /// var result = await page.evaluate<int>('''x => {
  ///           return Promise.resolve(8 * x);
  ///         }''', args: [7]);
  /// print(result); // prints "56"
  /// ```
  ///
  /// An expression can also be passed in instead of a function:
  /// ```dart
  /// print(await page.evaluate('1 + 2')); // prints "3"
  /// var x = 10;
  /// print(await page.evaluate('1 + $x')); // prints "11"
  /// ```
  ///
  /// [ElementHandle] instances can be passed as arguments to the [Page.evaluate]:
  /// ```dart
  /// var bodyHandle = await page.$('body');
  /// var html = await page.evaluate('body => body.innerHTML', args: [bodyHandle]);
  /// await bodyHandle.dispose();
  /// print(html);
  /// ```
  ///
  /// Shortcut for [Page.mainFrame.evaluate].
  ///
  /// Parameters:
  /// - [pageFunction] Function to be evaluated in the page context
  /// - [args] Arguments to pass to `pageFunction`
  /// - Returns: Future which resolves to the return value of `pageFunction`
  Future<T> evaluate<T>(@Language('js') String pageFunction, {List? args}) {
    return mainFrame.evaluate<T>(pageFunction, args: args);
  }

  /// Adds a function which would be invoked in one of the following scenarios:
  /// - whenever the page is navigated
  /// - whenever the child frame is attached or navigated. In this case, the
  /// function is invoked in the context of the newly attached frame
  ///
  /// The function is invoked after the document was created but before any of
  /// its scripts were run. This is useful to amend the JavaScript environment,
  /// e.g. to seed `Math.random`.
  ///
  /// An example of overriding the navigator.languages property before the page
  /// loads:
  ///
  /// ```javascript
  /// // preload.js
  ///
  /// // overwrite the `languages` property to use a custom getter
  /// Object.defineProperty(navigator, "languages", {
  ///   get: function() {
  ///     return ["en-US", "en", "bn"];
  ///   }
  /// });
  /// ```
  ///
  /// ```dart
  /// var preloadFile = File('test/assets/preload.js').readAsStringSync();
  /// await page.evaluateOnNewDocument(preloadFile);
  /// ```
  ///
  /// Parameters:
  /// - [pageFunction] Function to be evaluated in browser context
  /// - [args] Arguments to pass to [pageFunction]
  Future<void> evaluateOnNewDocument(String pageFunction, {List? args}) async {
    var source = evaluationString(pageFunction, args);
    await devTools.page.addScriptToEvaluateOnNewDocument(source);
  }

  /// Toggles ignoring cache for each request based on the enabled state. By
  /// default, caching is enabled.
  Future<void> setCacheEnabled(bool enabled) {
    return _frameManager.networkManager.setCacheEnabled(enabled);
  }

  /// Parameters:
  /// - [format]: Specify screenshot type, can be either `ScreenshotFormat.jpeg`
  ///   or `ScreenshotFormat.png`. Defaults to 'png'.
  /// - [quality]: The quality of the image, between 0-100. Not applicable to
  ///   `png` images.
  /// - [fullPage]: When true, takes a screenshot of the full scrollable page.
  ///   Defaults to `false`.
  /// - [clip]: a [Rectangle] which specifies clipping region of the page.
  /// - [omitBackground]: Hides default white background and allows capturing
  ///   screenshots with transparency. Defaults to `false`.
  ///
  /// Returns:
  /// [Future] which resolves to a list of bytes with captured screenshot.
  ///
  /// > **NOTE** Screenshots take at least 1/6 second on OS X. See
  /// https://crbug.com/741689 for discussion.
  Future<Uint8List> screenshot(
      {ScreenshotFormat? format,
      bool? fullPage,
      Rectangle? clip,
      int? quality,
      bool? omitBackground}) async {
    return base64Decode(await screenshotBase64(
        format: format,
        fullPage: fullPage,
        clip: clip,
        quality: quality,
        omitBackground: omitBackground));
  }

  /// Parameters:
  /// - [format]: Specify screenshot type, can be either `ScreenshotFormat.jpeg`
  ///   or `ScreenshotFormat.png`. Defaults to 'png'.
  /// - [quality]: The quality of the image, between 0-100. Not applicable to
  ///   `png` images.
  /// - [fullPage]: When true, takes a screenshot of the full scrollable page.
  ///   Defaults to `false`.
  /// - [clip]: a [Rectangle] which specifies clipping region of the page.
  /// - [omitBackground]: Hides default white background and allows capturing
  ///   screenshots with transparency. Defaults to `false`.
  ///
  /// Returns:
  /// [Future<String>] which resolves to the captured screenshot encoded in `base64`.
  ///
  /// > **NOTE** Screenshots take at least 1/6 second on OS X. See
  /// https://crbug.com/741689 for discussion.
  Future<String> screenshotBase64(
      {ScreenshotFormat? format,
      bool? fullPage,
      Rectangle? clip,
      int? quality,
      bool? omitBackground}) {
    final localFormat = format ?? ScreenshotFormat.png;
    final localFullPage = fullPage ?? false;
    omitBackground ??= false;

    assert(quality == null || localFormat == ScreenshotFormat.jpeg,
        'Quality is only supported for the jpeg screenshots');
    assert(clip == null || !localFullPage, 'clip and fullPage are exclusive');

    return screenshotPool(target.browser).withResource(() async {
      await devTools.target.activateTarget(target.targetID);

      Viewport? roundedClip;
      if (clip != null) {
        roundedClip = Viewport(
            x: clip.left.round(),
            y: clip.top.round(),
            width: (clip.width + clip.left - clip.left.round()).round(),
            height: (clip.height + clip.top - clip.top.round()).round(),
            scale: 1);
      }

      if (localFullPage) {
        var metrics = await devTools.page.getLayoutMetrics();

        // Overwrite clip for full page
        roundedClip = Viewport(
            x: 0,
            y: 0,
            width: metrics.cssContentSize.width.ceil(),
            height: metrics.cssContentSize.height.ceil(),
            scale: 1);
      }
      var shouldSetDefaultBackground =
          omitBackground! && localFormat == ScreenshotFormat.png;
      if (shouldSetDefaultBackground) {
        await devTools.emulation.setDefaultBackgroundColorOverride(
            color: RGBA(r: 0, g: 0, b: 0, a: 0));
      }
      var result = await devTools.page.captureScreenshot(
          format: localFormat.name,
          quality: quality,
          clip: roundedClip,
          captureBeyondViewport: true);
      if (shouldSetDefaultBackground) {
        await devTools.emulation.setDefaultBackgroundColorOverride();
      }

      if (localFullPage && _viewport != null) {
        await setViewport(_viewport!);
      }

      return result;
    });
  }

  /// Generates a pdf of the page with `print` css media. To generate a pdf with
  /// `screen` media, call [Page.emulateMedia('screen')] before calling `page.pdf()`:
  ///
  /// > **NOTE** Generating a pdf is currently only supported in Chrome headless.
  /// > **NOTE** By default, `page.pdf()` generates a pdf with modified colors
  /// for printing. Use the [`-webkit-print-color-adjust`](https://developer.mozilla.org/en-US/docs/Web/CSS/-webkit-print-color-adjust)
  /// property to force rendering of exact colors.
  ///
  /// ```dart
  /// // Generates a PDF with 'screen' media type.
  /// await page.emulateMediaType(MediaType.screen);
  /// await page.pdf(output: File('page.pdf').openWrite());
  /// ```
  ///
  /// Parameters:
  /// - [scale]: Scale of the webpage rendering. Defaults to `1`. Scale amount
  ///   must be between 0.1 and 2.
  /// - [displayHeaderFooter]: Display header and footer. Defaults to `false`.
  /// - [headerTemplate]: HTML template for the print header. Should be valid
  ///   HTML markup with following classes used to inject printing values into them:
  ///    - `date` formatted print date
  ///    - `title` document title
  ///    - `url` document location
  ///    - `pageNumber` current page number
  ///    - `totalPages` total pages in the document
  /// - [footerTemplate]: HTML template for the print footer. Should use the
  ///    same format as the [headerTemplate].
  /// - [printBackground]: Print background graphics. Defaults to `false`.
  /// - [landscape]: Paper orientation. Defaults to `false`.
  /// - [pageRanges]: Paper ranges to print, e.g., '1-5, 8, 11-13'. Defaults to
  ///   the empty string, which means print all pages.
  /// - [format]: Paper format. Defaults to [PageFormat.letter] (8.5 inches x 11 inches).
  /// - [margins]: Paper margins, defaults to none.
  /// - [preferCssPageSize]: Give any CSS `@page` size declared in the page
  ///   priority over what is declared in [format]. Defaults to `false`,
  ///   which will scale the content to fit the paper size.
  /// - [output] an IOSink where to write the PDF bytes. This parameter is optional,
  ///   if it is not provided, the bytes are returned as an in-memory list of bytes
  ///   from the function.
  ///
  /// If [output] parameter is null, this returns a [Future<Uint8List>]
  /// which resolves with PDF bytes. If [output] is not null, the method return null
  /// and the PDF bytes are written in the [output] sink.
  ///
  /// > **NOTE** `headerTemplate` and `footerTemplate` markup have the following
  /// limitations:
  /// > 1. Script tags inside templates are not evaluated.
  /// > 2. Page styles are not visible inside templates.
  Future<Uint8List?> pdf(
      {PaperFormat? format,
      num? scale,
      bool? displayHeaderFooter,
      String? headerTemplate,
      String? footerTemplate,
      bool? printBackground,
      bool? landscape,
      String? pageRanges,
      bool? preferCssPageSize,
      PdfMargins? margins,
      IOSink? output}) async {
    scale ??= 1;
    displayHeaderFooter ??= false;
    headerTemplate ??= '';
    footerTemplate ??= '';
    printBackground ??= false;
    landscape ??= false;
    pageRanges ??= '';
    preferCssPageSize ??= false;
    format ??= PaperFormat.letter;
    margins ??= PdfMargins.zero;

    var result = await devTools.page.printToPDF(
        transferMode: output == null ? 'ReturnAsBase64' : 'ReturnAsStream',
        landscape: landscape,
        displayHeaderFooter: displayHeaderFooter,
        headerTemplate: headerTemplate,
        footerTemplate: footerTemplate,
        printBackground: printBackground,
        scale: scale,
        paperWidth: format.width,
        paperHeight: format.height,
        marginTop: margins.top,
        marginBottom: margins.bottom,
        marginLeft: margins.left,
        marginRight: margins.right,
        pageRanges: pageRanges,
        preferCSSPageSize: preferCssPageSize);

    if (output == null) {
      return base64Decode(result.data);
    } else {
      await readStream(devTools.io, result.stream!, output);
      await output.close();
      return null;
    }
  }

  /// The page's title.
  ///
  /// Shortcut for [Page.mainFrame.title].
  Future<String?> get title {
    return mainFrame.title;
  }

  /// By default, [Page.close] **does not** run beforeunload handlers.
  ///
  /// **NOTE** if `runBeforeUnload` is passed as true, a `beforeunload` dialog
  /// might be summoned and should be handled manually via page's ['dialog'](#event-dialog) event.
  ///
  /// Parameters:
  /// [runBeforeUnload]: Whether to run the
  ///    [before unload](https://developer.mozilla.org/en-US/docs/Web/Events/beforeunload)
  Future<void> close({bool? runBeforeUnload}) async {
    runBeforeUnload ??= false;
    if (runBeforeUnload) {
      await devTools.page.close();
    } else {
      await target.browser.targetApi.closeTarget(target.targetID);
      await target.onClose;
    }
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
  /// await page.click('a');
  /// var response = await responseFuture;
  /// ```
  ///
  /// Or simpler, if you don't need the [Response]
  /// ```dart
  /// await Future.wait([
  ///   page.waitForNavigation(),
  ///   page.click('a'),
  /// ]);
  /// ```
  ///
  /// Shortcut for [Page.mainFrame.click]
  ///
  /// Parameters:
  /// [selector]: A [selector] to search for element to click. If there are
  /// multiple elements satisfying the selector, the first will be clicked.
  ///
  /// [button]: <"left"|"right"|"middle"> Defaults to `left`
  ///
  /// [clickCount]: defaults to 1
  ///
  /// [delay]: Time to wait between `mousedown` and `mouseup`. Default to zero.
  Future<void> click(String selector,
      {Duration? delay, MouseButton? button, int? clickCount}) {
    return mainFrame.click(selector,
        delay: delay, button: button, clickCount: clickCount);
  }

  /// Convenience function to wait for navigation to complete after clicking on an element.
  ///
  /// See this issue for more context: https://github.com/GoogleChrome/puppeteer/issues/1421
  ///
  /// > Note: Be wary of ajax powered pages where the navigation event is not triggered.
  ///
  /// ```dart
  /// await page.clickAndWaitForNavigation('input#submitData');
  /// ```
  /// as opposed to:
  ///
  /// ```dart
  /// await Future.wait([
  ///   page.waitForNavigation(),
  ///   page.click('input#submitData'),
  /// ]);
  /// ```
  Future<Response?> clickAndWaitForNavigation(String selector,
      {Duration? timeout, Until? wait}) async {
    var navigationFuture = waitForNavigation(timeout: timeout, wait: wait);
    await click(selector);
    return await navigationFuture;
  }

  /// This method fetches an element with `selector` and focuses it.
  /// If there's no element matching `selector`, the method throws an error.
  ///
  /// Shortcut for [page.mainFrame.focus].
  ///
  /// Parameters:
  /// - A [selector] of an element to focus. If there are multiple elements
  ///   satisfying the selector, the first will be focused.
  /// - Promise which resolves when the element matching `selector` is successfully
  ///   focused. The promise will be rejected if there is no element matching `selector`.
  Future<void> focus(String selector) {
    return mainFrame.focus(selector);
  }

  /// This method fetches an element with [selector], scrolls it into view if
  /// needed, and then uses [Page.mouse] to hover over the center of
  /// the element.
  /// If there's no element matching [selector], the method throws an error.
  ///
  /// Shortcut for [Page.mainFrame.hover].
  ///
  /// Parameters:
  /// A [selector] to search for element to hover. If there are multiple elements
  /// satisfying the selector, the first will be hovered.
  ///
  /// Returns: [Future] which resolves when the element matching [selector] is
  /// successfully hovered. Future gets rejected if there's no element matching
  /// [selector].
  Future<void> hover(String selector) {
    return mainFrame.hover(selector);
  }

  /// Triggers a `change` and `input` event once all the provided options have
  /// been selected.
  /// If there's no `<select>` element matching `selector`, the method throws an
  /// error.
  ///
  /// ```dart
  /// await page.select('select#colors', ['blue']); // single selection
  /// await page
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
    return mainFrame.select(selector, values);
  }

  /// This method fetches an element with `selector`, scrolls it into view if
  /// needed, and then uses [page.touchscreen] to tap in the center of the element.
  /// If there's no element matching `selector`, the method throws an error.
  ///
  /// Shortcut for [page.mainFrame.tap].
  ///
  /// Parameters:
  /// A [selector] to search for element to tap. If there are multiple
  /// elements satisfying the selector, the first will be tapped.
  Future<void> tap(String selector) {
    return mainFrame.tap(selector);
  }

  /// Sends a `keydown`, `keypress`/`input`, and `keyup` event for each character
  /// in the text.
  ///
  /// To press a special key, like `Control` or `ArrowDown`, use [`keyboard.press`].
  ///
  /// ```dart
  /// // Types instantly
  /// await page.type('#mytextarea', 'Hello');
  ///
  /// // Types slower, like a user
  /// await page.type('#mytextarea', 'World', delay: Duration(milliseconds: 100));
  /// ```
  ///
  /// Shortcut for [page.mainFrame.type].
  Future<void> type(String selector, String text, {Duration? delay}) {
    return mainFrame.type(selector, text, delay: delay);
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
  ///   var watchImg = page.waitForSelector('img');
  ///   await page.goto('https://example.com');
  ///   var image = await watchImg;
  ///   print(await image!.propertyValue('src'));
  ///   await browser.close();
  /// }
  /// ```
  /// Shortcut for [page.mainFrame.waitForSelector].
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
      {bool? visible, bool? hidden, Duration? timeout}) {
    return mainFrame.waitForSelector(selector,
        visible: visible, hidden: hidden, timeout: timeout);
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
  ///   var watchImg = page.waitForXPath('//img');
  ///   await page.goto('https://example.com');
  ///   var image = await watchImg;
  ///   print(await image!.propertyValue('src'));
  ///   await browser.close();
  /// }
  /// ```
  /// Shortcut for [page.mainFrame.waitForXPath].
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
      {bool? visible, bool? hidden, Duration? timeout}) {
    return mainFrame.waitForXPath(xpath,
        visible: visible, hidden: hidden, timeout: timeout);
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
  ///   var watchDog = page.waitForFunction('window.innerWidth < 100');
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
  /// await page.waitForFunction('selector => !!document.querySelector(selector)',
  ///     args: [selector]);
  /// ```
  ///
  /// Shortcut for [page.mainFrame().waitForFunction(pageFunction[, options[, ...args]])](#framewaitforfunctionpagefunction-options-args).
  Future<JsHandle> waitForFunction(@Language('js') String pageFunction,
      {List? args, Duration? timeout, Polling? polling}) {
    return mainFrame.waitForFunction(pageFunction,
        args: args, timeout: timeout, polling: polling);
  }

  bool get hasPopupListener => _onPopupController.hasListener;

  void emitPopup(Page popup) {
    _onPopupController.add(popup);
  }
}

/// [ConsoleMessage] objects are dispatched by page via the [console] event.
class ConsoleMessage {
  final ConsoleMessageType type;
  final String typeName;
  final String? text;
  final List<JsHandle> args;
  final String? url;
  final int? lineNumber, columnNumber;

  ConsoleMessage(this.type, this.typeName, this.text, this.args,
      {this.url, this.lineNumber, this.columnNumber});

  @override
  String toString() =>
      'ConsoleMessage(type: $typeName, text: $text, args: $args, url: $url, '
      'lineNumber: $lineNumber, columnNumber: $columnNumber)';
}

class ConsoleMessageType {
  static const log = ConsoleMessageType._('log');
  static const debug = ConsoleMessageType._('debug');
  static const info = ConsoleMessageType._('info');
  static const error = ConsoleMessageType._('error');
  static const warning = ConsoleMessageType._('warning');
  static const other = ConsoleMessageType._('other');
  static const values = {
    'log': log,
    'debug': debug,
    'info': info,
    'error': error,
    'warning': warning,
    'other': other,
  };

  final String name;

  const ConsoleMessageType._(this.name);

  factory ConsoleMessageType._fromEventType(ConsoleAPICalledEventType type) {
    return values[type.value] ?? other;
  }

  factory ConsoleMessageType._fromLogLevel(LogEntryLevel level) {
    return {
          LogEntryLevel.verbose: ConsoleMessageType.debug,
        }[level] ??
        values[level.value] ??
        other;
  }

  @override
  String toString() => name;
}

class ScreenshotFormat {
  static const jpeg = ScreenshotFormat._('jpeg');
  static const png = ScreenshotFormat._('png');
  final String name;

  const ScreenshotFormat._(this.name);

  @override
  String toString() => name;
}

class PaperFormat {
  static const letter = PaperFormat.inches(width: 8.5, height: 11);
  static const legal = PaperFormat.inches(width: 8.5, height: 14);
  static const tabloid = PaperFormat.inches(width: 11, height: 17);
  static const ledger = PaperFormat.inches(width: 17, height: 11);
  static const a0 = PaperFormat.inches(width: 33.1, height: 46.8);
  static const a1 = PaperFormat.inches(width: 23.4, height: 33.1);
  static const a2 = PaperFormat.inches(width: 16.54, height: 23.4);
  static const a3 = PaperFormat.inches(width: 11.7, height: 16.54);
  static const a4 = PaperFormat.inches(width: 8.27, height: 11.7);
  static const a5 = PaperFormat.inches(width: 5.83, height: 8.27);
  static const a6 = PaperFormat.inches(width: 4.13, height: 5.83);

  final num width, height;

  const PaperFormat.inches({required this.width, required this.height});

  PaperFormat.px({required int width, required int height})
      : width = _pxToInches(width),
        height = _pxToInches(height);

  PaperFormat.cm({required num width, required num height})
      : width = _cmToInches(width),
        height = _cmToInches(height);

  PaperFormat.mm({required num width, required num height})
      : width = _mmToInches(width),
        height = _mmToInches(height);

  @override
  String toString() => 'PaperFormat.inches(width: $width, height: $height)';
}

num _pxToInches(num px) => px / 96;

num _cmToInches(num cm) => _pxToInches(cm * 37.8);

num _mmToInches(num mm) => _cmToInches(mm / 10);

class PdfMargins {
  final num top, bottom, left, right;

  static final zero = PdfMargins.inches();

  PdfMargins.inches({num? top, num? bottom, num? left, num? right})
      : top = top ?? 0,
        bottom = bottom ?? 0,
        left = left ?? 0,
        right = right ?? 0;

  factory PdfMargins.px({int? top, int? bottom, int? left, int? right}) {
    return PdfMargins.inches(
      top: top != null ? _pxToInches(top) : null,
      bottom: bottom != null ? _pxToInches(bottom) : null,
      left: left != null ? _pxToInches(left) : null,
      right: right != null ? _pxToInches(right) : null,
    );
  }

  factory PdfMargins.cm({num? top, num? bottom, num? left, num? right}) {
    return PdfMargins.inches(
      top: top != null ? _cmToInches(top) : null,
      bottom: bottom != null ? _cmToInches(bottom) : null,
      left: left != null ? _cmToInches(left) : null,
      right: right != null ? _cmToInches(right) : null,
    );
  }

  factory PdfMargins.mm({num? top, num? bottom, num? left, num? right}) {
    return PdfMargins.inches(
      top: top != null ? _mmToInches(top) : null,
      bottom: bottom != null ? _mmToInches(bottom) : null,
      left: left != null ? _mmToInches(left) : null,
      right: right != null ? _mmToInches(right) : null,
    );
  }

  @override
  String toString() =>
      'PdfMargins.inches(top: $top, bottom: $bottom, left: $left, right: $right)';
}

class ClientError implements Exception {
  final ExceptionDetails? details;
  final String? message;

  ClientError(ExceptionDetails this.details) : message = _message(details);

  ClientError.pageCrashed()
      : message = 'Page crashed!',
        details = null;

  @override
  String toString() => 'Evaluation failed: $message';

  static String? _message(ExceptionDetails details) {
    var exception = details.exception;
    if (exception != null) {
      if (exception.description != null) {
        return exception.description;
      }
      var value = exception.value;
      if (value != null) {
        return '$value';
      }
      return null;
    } else {
      var message = details.text;
      if (details.stackTrace != null) {
        for (var callFrame in details.stackTrace!.callFrames) {
          var location =
              '${callFrame.url}:${callFrame.lineNumber}:${callFrame.columnNumber}';
          var functionName = callFrame.functionName.isEmpty
              ? '<anonymous>'
              : callFrame.functionName;
          message += '\n    at $functionName ($location)';
        }
      }
      return message;
    }
  }
}

/// [FileChooser] objects are returned via the ['page.waitForFileChooser'] method.
///
/// File choosers let you react to the page requesting for a file.
///
/// An example of using [FileChooser]:
///
/// ```dart
/// var futureFileChooser = page.waitForFileChooser();
/// // some button that triggers file selection
/// await page.click('#upload-file-button');
/// var fileChooser = await futureFileChooser;
///
/// await fileChooser.accept([File('myfile.pdf')]);
/// ```
///
/// > **NOTE** In browsers, only one file chooser can be opened at a time.
/// > All file choosers must be accepted or canceled. Not doing so will prevent subsequent file choosers from appearing.
class FileChooser {
  final DevTools devTools;
  final ElementHandle element;

  /// Whether file chooser allow for [multiple](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/file#attr-multiple)
  /// file selection.
  final bool isMultiple;
  bool _handled = false;

  FileChooser(this.devTools, this.element, FileChooserOpenedEvent event)
      : isMultiple = event.mode != FileChooserOpenedEventMode.selectSingle;

  /// Accept the file chooser request with given files.
  Future<void> accept(List<File> files) async {
    assert(!_handled, 'Cannot accept FileChooser which is already handled!');
    _handled = true;
    await element.uploadFile(files);
  }

  /// Closes the file chooser without selecting any files.
  Future<void> cancel() async {
    assert(!_handled, 'Cannot cancel FileChooser which is already handled!');
    _handled = true;
  }
}

class MediaType {
  static final screen = MediaType._('screen');
  static final print = MediaType._('print');
  static final noEmulation = MediaType._('');

  final String name;

  MediaType._(this.name);
}

class MediaFeature {
  /// The CSS media feature name. Supported names are `'prefers-colors-scheme'`
  /// and `'prefers-reduced-motion'`.
  final String name;

  /// The value for the given CSS media feature.
  final String value;

  MediaFeature._(this.name, this.value);

  factory MediaFeature.prefersColorsScheme(String value) =>
      MediaFeature._('prefers-colors-scheme', value);
  factory MediaFeature.prefersReducedMotion(String value) =>
      MediaFeature._('prefers-reduced-motion', value);

  @override
  String toString() => '$name: $value';
}
