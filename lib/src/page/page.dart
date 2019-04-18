import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:chrome_dev_tools/domains/dom.dart';
import 'package:chrome_dev_tools/domains/domains.dart';
import 'package:chrome_dev_tools/domains/network.dart';
import 'package:chrome_dev_tools/domains/page.dart';
import 'package:chrome_dev_tools/domains/runtime.dart';
import 'package:chrome_dev_tools/domains/target.dart';
import 'package:chrome_dev_tools/src/chrome.dart';
import 'package:chrome_dev_tools/src/connection.dart';
import 'package:chrome_dev_tools/src/page/dom_world.dart';
import 'package:chrome_dev_tools/src/page/emulation_manager.dart';
import 'package:chrome_dev_tools/src/page/execution_context.dart';
import 'package:chrome_dev_tools/src/page/frame_manager.dart';
import 'package:chrome_dev_tools/src/page/helper.dart';
import 'package:chrome_dev_tools/src/page/js_handle.dart';
import 'package:chrome_dev_tools/src/page/keyboard.dart';
import 'package:chrome_dev_tools/src/page/lifecycle_watcher.dart';
import 'package:chrome_dev_tools/src/page/mouse.dart';
import 'package:chrome_dev_tools/src/page/network_manager.dart';
import 'package:chrome_dev_tools/src/page/touchscreen.dart';
import 'package:chrome_dev_tools/src/page/worker.dart';
import 'package:chrome_dev_tools/src/target.dart';
import 'package:meta/meta.dart';
import '../connection.dart' show Session;

class Page {
  final Target target;
  final Domains domains;
  final _pageBindings = <String, Function>{};
  final _workers = <SessionID, Worker>{};
  FrameManager _frameManager;
  final StreamController _workerCreated = StreamController<Worker>.broadcast(),
      _workerDestroyed = StreamController<Worker>.broadcast(),
      _onErrorController = StreamController<ClientError>.broadcast(),
     _onPopupController = StreamController<Page>.broadcast();
  bool _javascriptEnabled = true;
  Duration navigationTimeout;
  Duration defaultTimeout = Duration(seconds: 30);
  DeviceViewport _viewport;
  final EmulationManager _emulationManager;
  Mouse _mouse;
  Touchscreen _touchscreen;
  Keyboard _keyboard;

  Page._(this.target, this.domains) : _emulationManager = EmulationManager(domains) {
    _frameManager = FrameManager(this);
    _keyboard = Keyboard(domains.input);
    _mouse = Mouse(domains.input, _keyboard);
    _touchscreen = Touchscreen(domains.runtime, domains.input, _keyboard);

    domains.target.onAttachedToTarget.listen((e) {
      if (e.targetInfo.type != 'worker') {
        // If we don't detach from service workers, they will never die.
        domains.target.detachFromTarget(sessionId: e.sessionId);
      } else {
        var session = target.browser.connection.sessions[e.sessionId.value];
        assert(session != null);
        var worker = new Worker(session, e.targetInfo.url);
        _workers[e.sessionId] = worker;
        _workerCreated.add(worker);
      }
    });
    domains.target.onDetachedFromTarget.listen((e) {
      var worker = _workers[e.sessionId];
      if (worker != null) {
        _workerDestroyed.add(worker);
        _workers.remove(e.sessionId);
      }
    });

    // TODO(xha): onConsoleAPI: récupérer tous les arguments du console.xx et les convertir en string
    domains.runtime.onConsoleAPICalled.listen((e) {
      //If I recall correctly Log.entryAdded() shows errors and warning from Chrome (e.g., XSS violations and such), not necessarily coming from the console.* API.
    });

    domains.runtime.onBindingCalled.listen(_onBindingCalled);
    domains.page.onJavascriptDialogOpening.listen(_onDialog);
    domains.runtime.onExceptionThrown.listen(_handleException);
    domains.log.onEntryAdded.listen(_onLogEntryAdded);
  }

  static Future<Page> create(Target target, Session session, {DeviceViewport viewport}) async {
    var domains = Domains(session);
    var page = Page._(target, domains);

    await Future.wait([
      page._frameManager.initialize(),
      domains.target.setAutoAttach(true, false, flatten: true),
      domains.performance.enable(),
      domains.log.enable(),
    ]);

    if (viewport != null) {
      await page.setViewport(viewport);
    }

    return page;
  }

  Session get session => domains.session;

  Browser get browser => target.browser;

  void dispose() {
    _frameManager.dispose();
    _workerCreated.close();
    _workerDestroyed.close();
    _onErrorController.close();
    _onPopupController.close();
  }

  Duration get navigationTimeoutOrDefault =>
      navigationTimeout ?? defaultTimeout;

  Stream<Worker> get onWorkerCreated => _workerCreated.stream;

  Stream<Worker> get onWorkerDestroyed => _workerDestroyed.stream;

  Stream get onPageCrashed => domains.inspector.onTargetCrashed;

  Stream<PageFrame> get onFrameAttached => _frameManager.onFrameAttached;

  Stream<PageFrame> get onFrameDetached => _frameManager.onFrameDetached;

  Stream<PageFrame> get onFrameNavigated => _frameManager.onFrameNavigated;

  Stream<MonotonicTime> get onDomContentLoaded =>
      domains.page.onDomContentEventFired;

  Stream<MonotonicTime> get onLoad => domains.page.onLoadEventFired;

  Stream<ClientError> get onError => _onErrorController.stream;

  FrameManager get frameManager => _frameManager;

  Future get onClose => target.onClose;

  bool get isClosed => domains.session.isClosed;

  PageFrame get mainFrame => _frameManager.mainFrame;

  Keyboard get keyboard => _keyboard;

  Touchscreen get touchscreen => _touchscreen;

  Mouse get mouse => _mouse;

  _onLogEntryAdded(event) {
    //TODO(xha)
  }

  Future<ElementHandle> $(String selector) {
    return mainFrame.$(selector);
  }

  Future<JsHandle> evaluateHandle(Js pageFunction, {List args}) async {
    var context = await mainFrame.executionContext;
    return context.evaluateHandle(pageFunction, args: args);
  }

  Future<JsHandle> queryObjects(JsHandle prototypeHandle) async {
    var context = await mainFrame.executionContext;
    return context.queryObjects(prototypeHandle);
  }

  Future<T> $eval<T>(String selector, Js pageFunction, {List args}) {
    return mainFrame.$eval<T>(selector, pageFunction, args: args);
  }

  Future<T> $$eval<T>(String selector, Js pageFunction, {List args}) {
    return mainFrame.$$eval<T>(selector, pageFunction, args: args);
  }

  Future<List<ElementHandle>> $$(String selector) {
    return mainFrame.$$(selector);
  }

  Future<List<ElementHandle>> $x(String expression) {
    return mainFrame.$x(expression);
  }

  Future<List<Cookie>> cookies(List<String> urls) {
    return domains.network.getCookies(urls: urls);
  }

  Future<void> deleteCookies(List<Cookie> cookies) async {
    var pageUrl = url;
    for (var cookie in cookies) {
      await domains.network.deleteCookies(cookie.name,
          url: pageUrl.startsWith('http') ? pageUrl : null,
          domain: cookie.domain,
          path: cookie.path);
    }
  }

  Future<void> setCookies(List<CookieParam> cookies) async {
    await domains.network.setCookies(cookies);
  }

  Future<ElementHandle> addScriptTag(
      {String url, File file, String content, String type}) {
    return mainFrame.addScriptTag(
        url: url, file: file, content: content, type: type);
  }

  Future<ElementHandle> addStyleTag({String url, File file, String content}) {
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

  Future<void> exposeFunction(String name, Function callbackFunction) async {
    if (_pageBindings.containsKey(name)) {
      throw Exception(
          'Failed to add page binding with name $name: window["$name"] already exists!');
    }
    _pageBindings[name] = callbackFunction;

    var expression = evaluationString(_addPageBinding, [name]);
    await domains.runtime.addBinding(name);
    await domains.page.addScriptToEvaluateOnNewDocument(expression);
    await Future.wait(frameManager.frames
        .map((frame) => frame.evaluate(Js.expression(expression))));
  }

  Future<void> authenticate({String userName, String password}) {
    return _frameManager.networkManager
        .authenticate(Credentials(userName, password));
  }

  Future<void> setExtraHTTPHeaders(Map<String, String> headers) async {
    await _frameManager.networkManager.setExtraHTTPHeaders(headers);
  }

  Future<void> setUserAgent(String userAgent) async {
    await _frameManager.networkManager.setUserAgent(userAgent);
  }

  void _handleException(ExceptionThrownEvent event) {
    _onErrorController.add(ClientError(event.exceptionDetails));
  }

  /**
   * @param {!Protocol.Runtime.consoleAPICalledPayload} event
   */
  Future _onConsoleAPI(event) {
//TODO(xha)
  }

  Future _onBindingCalled(BindingCalledEvent event) async {
    Map<String, dynamic> payload = jsonDecode(event.payload);
    String name = payload['name'];
    int seq = payload['seq'];
    List args = payload['args'];

    String expression;
    try {
      Function callback = _pageBindings[name];
      var result = await Function.apply(callback, args);
      expression = evaluationString(_deliverResult, [name, seq, result]);
    } catch (error, stackTrace) {
      expression = evaluationString(
          _deliverError, [name, seq, error.toString(), stackTrace.toString()]);
    }
    await domains.runtime.evaluate(expression, contextId: event.executionContextId);
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

  /**
   * @param {string} type
   * @param {!Array<!Puppeteer.JSHandle>} args
   * @param {Protocol.Runtime.StackTrace=} stackTrace
   */
  void _addConsoleMessage(type, args, stackTrace) {
    //TODO(xha)
  }

  _onDialog(event) {
    //TODO(xha)
  }

  String get url {
    return mainFrame.url;
  }

  Future<String> get content {
    return _frameManager.mainFrame.content;
  }

  Future<void> setContent(String html,
      {Duration timeout, WaitUntil waitUntil}) {
    return _frameManager.mainFrame
        .setContent(html, timeout: timeout, waitUntil: waitUntil);
  }

  Future<NetworkResponse> goto(String url,
      {String referrer, Duration timeout, WaitUntil waitUntil}) {
    return _frameManager.mainFrame
        .goto(url, referrer: referrer, timeout: timeout, waitUntil: waitUntil);
  }

  Future<NetworkResponse> reload(
      {Duration timeout, WaitUntil waitUntil}) async {
    var responseFuture =
        waitForNavigation(timeout: timeout, waitUntil: waitUntil);

    await domains.page.reload();
    return await responseFuture;
  }

  Future<NetworkResponse> waitForNavigation(
      {Duration timeout, WaitUntil waitUntil}) {
    return _frameManager.mainFrame
        .waitForNavigation(timeout: timeout, waitUntil: waitUntil);
  }

  Future<NetworkRequest> waitForRequest(String url, {Duration timeout}) async {
    timeout ??= defaultTimeout;

    return frameManager.networkManager.onRequest
        .where((request) => request.url == url)
        .first
        .timeout(timeout);
  }

  Future<NetworkResponse> waitForResponse(String url, {Duration timeout}) {
    timeout ??= defaultTimeout;

    return frameManager.networkManager.onResponse
        .where((response) => response.url == url)
        .first
        .timeout(timeout);
  }

  Future<NetworkResponse> goBack({Duration timeout, WaitUntil waitUntil}) {
    return _go(-1, timeout: timeout, waitUntil: waitUntil);
  }

  Future<NetworkResponse> goForward({Duration timeout, WaitUntil waitUntil}) {
    return _go(1, timeout: timeout, waitUntil: waitUntil);
  }

  Future<NetworkResponse> _go(int delta,
      {Duration timeout, WaitUntil waitUntil}) async {
    var history = await domains.page.getNavigationHistory();
    int index = history.currentIndex + delta;
    if (index < 0 || index >= history.entries.length) {
      return null;
    }
    var entry = history.entries[index];
    var navigationFuture =
        waitForNavigation(timeout: timeout, waitUntil: waitUntil);
    await domains.page.navigateToHistoryEntry(entry.id);
    return await navigationFuture;
  }

  Future<void> bringToFront() async {
    await domains.page.bringToFront();
  }

  Future<void> emulate(Device device) async {
    await setViewport(device.viewport);
    await setUserAgent(device.userAgent(
        (await domains.browser.getVersion()).product.split('/').last));
  }

  bool get javascriptEnabled => _javascriptEnabled;

  Future<void> setJavaScriptEnabled(enabled) async {
    if (_javascriptEnabled == enabled) {
      return;
    }
    _javascriptEnabled = enabled;

    await domains.emulation.setScriptExecutionDisabled(!enabled);
  }

  Future<void> setBypassCSP(bool enabled) {
    return domains.page.setBypassCSP(enabled);
  }

  Future<void> emulateMedia(String mediaType) {
    assert(mediaType == 'screen' || mediaType == 'print' || mediaType == null,
        'Unsupported media type: ' + mediaType);
    return domains.emulation.setEmulatedMedia(mediaType);
  }

  Future setViewport(DeviceViewport viewport) async {
    var needsReload = await _emulationManager.emulateViewport(viewport);
    _viewport = viewport;
    if (needsReload) {
      await reload();
    }
  }

  DeviceViewport get viewport => _viewport;

  Future evaluate(Js pageFunction, {List args}) {
    return _frameManager.mainFrame.evaluate(pageFunction, args: args);
  }

  Future evaluateOnNewDocument(String pageFunction, {List args}) async {
    var source = evaluationString(pageFunction, args);
    await domains.page.addScriptToEvaluateOnNewDocument(source);
  }

  Future<void> setCacheEnabled(enabled) {
    return _frameManager.networkManager.setCacheEnabled(enabled);
  }

  Future<Uint8List> screenshot(
      {ScreenshotFormat format,
      bool fullPage,
      Rectangle clip,
      num quality,
      bool omitBackground}) {
    format ??= ScreenshotFormat.png;
    fullPage ??= false;
    omitBackground ??= false;

    assert(quality == null || format == ScreenshotFormat.jpeg,
        'Quality is only supported for the jpeg screenshots');
    assert(clip == null || !fullPage, "clip and fullPage are exclusive");

    return screenshotPool(target.browser).withResource(() async {
      await domains.target.activateTarget(target.targetID);

      Viewport roundedClip;
      if (clip != null) {
        roundedClip = Viewport(
            x: clip.left.round(),
            y: clip.top.round(),
            width: (clip.width + clip.left - clip.left.round()).round(),
            height: (clip.height + clip.top - clip.top.round()).round(),
            scale: 1);
      }

      if (fullPage) {
        var metrics = await domains.page.getLayoutMetrics();

        // Overwrite clip for full page at all times.
        roundedClip = Viewport(
            x: 0,
            y: 0,
            width: metrics.contentSize.width.ceil(),
            height: metrics.contentSize.height.ceil(),
            scale: 1);

        DeviceViewport viewport = this.viewport ?? DeviceViewport();

        var screenOrientation = viewport.isLandscape
            ? EmulationManager.landscape
            : EmulationManager.portrait;
        await domains.emulation.setDeviceMetricsOverride(roundedClip.width,
            roundedClip.height, viewport.deviceScaleFactor, viewport.isMobile,
            screenOrientation: screenOrientation);
      }
      var shouldSetDefaultBackground =
          omitBackground && format == ScreenshotFormat.png;
      if (shouldSetDefaultBackground) {
        await domains.emulation.setDefaultBackgroundColorOverride(
            color: RGBA(r: 0, g: 0, b: 0, a: 0));
      }
      var result = await domains.page.captureScreenshot(
          format: format.name, quality: quality, clip: roundedClip);
      if (shouldSetDefaultBackground) {
        await domains.emulation.setDefaultBackgroundColorOverride();
      }

      if (fullPage && _viewport != null) {
        await setViewport(_viewport);
      }

      return base64Decode(result);
    });
  }

  Future<Uint8List> pdf(
      {PaperFormat format,
      num scale,
      bool displayHeaderFooter,
      String headerTemplate,
      String footerTemplate,
      bool printBackground,
      bool landscape,
      String pageRanges,
      bool preferCssPageSize,
      PdfMargins margins}) async {
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

    var result = await domains.page.printToPDF(
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

    return base64Decode(result);
  }

  Future<String> get title {
    return mainFrame.title;
  }

  Future<void> close({bool runBeforeUnload}) async {
    runBeforeUnload ??= false;
    if (runBeforeUnload) {
      await domains.page.close();
    } else {
      await target.browser.targetApi.closeTarget(target.targetID);
      await target.onClose;
    }
  }

  Future<void> click(String selector,
      {Duration delay, MouseButton button, int clickCount}) {
    return mainFrame.click(selector,
        delay: delay, button: button, clickCount: clickCount);
  }

  Future<void> focus(String selector) {
    return mainFrame.focus(selector);
  }

  Future<void> hover(String selector) {
    return mainFrame.hover(selector);
  }

  Future<List<String>> select(String selector, List<String> values) {
    return mainFrame.select(selector, values);
  }

  Future<void> tap(String selector) {
    return mainFrame.tap(selector);
  }

  Future<void> type(String selector, String text, {Duration delay}) {
    return mainFrame.type(selector, text, delay: delay);
  }

  Future<ElementHandle> waitForSelector(String selector,
      {bool visible, bool hidden, Duration timeout}) {
    return mainFrame.waitForSelector(selector,
        visible: visible, hidden: hidden, timeout: timeout);
  }

  Future<ElementHandle> waitForXPath(String xpath,
      {bool visible, bool hidden, Duration timeout}) {
    return mainFrame.waitForXPath(xpath,
        visible: visible, hidden: hidden, timeout: timeout);
  }

  Future<JsHandle> waitForFunction(Js pageFunction, List args,
      {Duration timeout, Polling polling}) {
    return mainFrame.waitForFunction(pageFunction, args,
        timeout: timeout, polling: polling);
  }

  bool get hasPopupListener => _onPopupController.hasListener;
  void emitPopup(Page popup) {
    _onPopupController.add(popup);
  }
}

class ConsoleMessage {
  final String type, text;
  final List args;
  final ConsoleMessageLocation location;

  ConsoleMessage(this.type, this.text, this.args, {@required this.location}) {
    assert(type != null);
    assert(text != null);
    assert(args != null);
    assert(location != null);
  }
}

class ConsoleMessageLocation {
  final String url;
  final int lineNumber, columnNumber;

  ConsoleMessageLocation(this.url,
      {@required this.lineNumber, @required this.columnNumber});
}

class ScreenshotFormat {
  static const jpeg = ScreenshotFormat._('jpeg');
  static const png = ScreenshotFormat._('png');
  final String name;

  const ScreenshotFormat._(this.name);
}

class PaperFormat {
  static const letter = PaperFormat.inches(width: 8.5, height: 11);
  static const legal = PaperFormat.inches(width: 8.5, height: 14);
  static const tabloid = PaperFormat.inches(width: 11, height: 17);
  static const ledger = PaperFormat.inches(width: 17, height: 11);
  static const a0 = PaperFormat.inches(width: 33.1, height: 46.8);
  static const a1 = PaperFormat.inches(width: 23.4, height: 33.1);
  static const a2 = PaperFormat.inches(width: 16.5, height: 23.4);
  static const a3 = PaperFormat.inches(width: 11.7, height: 16.5);
  static const a4 = PaperFormat.inches(width: 8.27, height: 11.7);
  static const a5 = PaperFormat.inches(width: 5.83, height: 8.27);
  static const a6 = PaperFormat.inches(width: 4.13, height: 5.83);

  final num width, height;

  const PaperFormat.inches({@required this.width, @required this.height});

  PaperFormat.px({@required int width, @required int height})
      : width = _pxToInches(width),
        height = _pxToInches(height);

  PaperFormat.cm({@required num width, @required num height})
      : width = _cmToInches(width),
        height = _cmToInches(height);

  PaperFormat.mm({@required num width, @required num height})
      : width = _mmToInches(width),
        height = _mmToInches(height);
}

num _pxToInches(num px) => px / 96;

num _cmToInches(num cm) => _pxToInches(cm / 37.8);

num _mmToInches(num mm) => _cmToInches(mm / 10);

class PdfMargins {
  final num top, bottom, left, right;

  static final zero = PdfMargins.inches();

  PdfMargins.inches({num top, num bottom, num left, num right})
      : top = top ?? 0,
        bottom = bottom ?? 0,
        left = left ?? 0,
        right = right ?? 0;

  factory PdfMargins.px({int top, int bottom, int left, int right}) {
    return PdfMargins.inches(
      top: top != null ? _pxToInches(top) : null,
      bottom: bottom != null ? _pxToInches(bottom) : null,
      left: left != null ? _pxToInches(left) : null,
      right: right != null ? _pxToInches(right) : null,
    );
  }

  factory PdfMargins.cm({num top, num bottom, num left, num right}) {
    return PdfMargins.inches(
      top: top != null ? _cmToInches(top) : null,
      bottom: bottom != null ? _cmToInches(bottom) : null,
      left: left != null ? _cmToInches(left) : null,
      right: right != null ? _cmToInches(right) : null,
    );
  }

  factory PdfMargins.mm({num top, num bottom, num left, num right}) {
    return PdfMargins.inches(
      top: top != null ? _mmToInches(top) : null,
      bottom: bottom != null ? _mmToInches(bottom) : null,
      left: left != null ? _mmToInches(left) : null,
      right: right != null ? _mmToInches(right) : null,
    );
  }
}

class ClientError {
  final ExceptionDetails details;
  final String message;

  ClientError(this.details) : message = _message(details);

  static String _message(ExceptionDetails details) {
    if (details.exception != null) {
      return details.exception.description ?? details.exception.value;
    } else {
      var message = details.text;
      if (details.stackTrace != null) {
        for (var callFrame in details.stackTrace.callFrames) {
          var location =
              '${callFrame.url}:${callFrame.lineNumber}:${callFrame.columnNumber}';
          var functionName = callFrame.functionName ?? '<anonymous>';
          message += '\n    at $functionName ($location)';
        }
      }
      return message;
    }
  }
}
