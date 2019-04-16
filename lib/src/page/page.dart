import 'dart:async';
import 'dart:io';

import 'package:chrome_dev_tools/domains/log.dart';
import 'package:chrome_dev_tools/domains/network.dart';
import 'package:chrome_dev_tools/domains/page.dart' hide Frame, Viewport;
import 'package:chrome_dev_tools/domains/performance.dart';
import 'package:chrome_dev_tools/domains/runtime.dart';
import 'package:chrome_dev_tools/domains/target.dart';
import 'package:chrome_dev_tools/src/connection.dart';
import 'package:chrome_dev_tools/src/page/dom_world.dart';
import 'package:chrome_dev_tools/src/page/emulation_manager.dart';
import 'package:chrome_dev_tools/src/page/execution_context.dart';
import 'package:chrome_dev_tools/src/page/frame_manager.dart';
import 'package:chrome_dev_tools/src/page/helper.dart';
import 'package:chrome_dev_tools/src/page/js_handle.dart';
import 'package:chrome_dev_tools/src/page/lifecycle_watcher.dart';
import 'package:chrome_dev_tools/src/page/network_manager.dart';
import 'package:chrome_dev_tools/src/page/worker.dart';
import 'package:chrome_dev_tools/src/tab.dart';
import 'package:meta/meta.dart';
import '../connection.dart' show Session;

class Page {
  static Future<Page> create(Tab tab, {DeviceViewport viewport}) async {
    var page = Page._(tab);

    await Future.wait([
      page._frameManager.initialize(),
      tab.target.setAutoAttach(true, false, flatten: true),
      tab.performance.enable(),
    ]);

    if (viewport != null) {
      await page.setViewport(viewport);
    }

    return page;
  }

  Page._(this.tab): _emulationManager = EmulationManager(tab) {
    _frameManager = FrameManager(this);

    tab.target.onAttachedToTarget.listen((e) {
      if (e.targetInfo.type != 'worker') {
        // If we don't detach from service workers, they will never die.
        tab.target.detachFromTarget(sessionId: e.sessionId);
      } else {
        var session = Session(tab.target, e.sessionId);
        var worker = new Worker(session, e.targetInfo.url);
        _workers[e.sessionId] = worker;
        _workerCreated.add(worker);
      }
    });
    tab.target.onDetachedFromTarget.listen((e) {
      var worker = _workers[e.sessionId];
      if (worker != null) {
        _workerDestroyed.add(worker);
        _workers.remove(e.sessionId);
      }
    });

    // TODO(xha): onConsoleAPI: récupérer tous les arguments du console.xx et les convertir en string
    tab.runtime.onConsoleAPICalled.listen((e) {
      //If I recall correctly Log.entryAdded() shows errors and warning from Chrome (e.g., XSS violations and such), not necessarily coming from the console.* API.
    });

    tab.runtime.onBindingCalled.listen(_onBindingCalled);
    tab.page.onJavascriptDialogOpening.listen(_onDialog);
    tab.runtime.onExceptionThrown.listen(_handleException);
    tab.performance.onMetrics.listen(_emitMetrics);
    tab.log.onEntryAdded.listen(_onLogEntryAdded);
  }

  final Tab tab;
  final _pageBindings = <String, Function>{};
  final _workers = <SessionID, Worker>{};
  FrameManager _frameManager;
  final StreamController _workerCreated = StreamController.broadcast(),
      _workerDestroyed = StreamController.broadcast();
  bool _javascriptEnabled = true;
  Duration navigationTimeout;
  Duration defaultTimeout = Duration(seconds: 30);
  DeviceViewport _viewport;
  final EmulationManager _emulationManager;

  void dispose() {
    _frameManager.dispose();
    _workerCreated.close();
    _workerDestroyed.close();
  }

  Duration get navigationTimeoutOrDefault => navigationTimeout ?? defaultTimeout;

  Client get client => tab.session;

  Stream<Worker> get onWorkerCreated => _workerCreated.stream;

  Stream<Worker> get onWorkerDestroyed => _workerDestroyed.stream;

  Stream get onPageCrashed => tab.inspector.onTargetCrashed;

  Stream<PageFrame> get onFrameAttached => _frameManager.onFrameAttached;

  Stream<PageFrame> get onFrameDetached => _frameManager.onFrameDetached;

  Stream<PageFrame> get onFrameNavigated => _frameManager.onFrameNavigated;

  Stream<MonotonicTime> get onDomContentLoaded =>
      tab.page.onDomContentEventFired;

  Stream<MonotonicTime> get onLoad => tab.page.onLoadEventFired;

  FrameManager get frames => _frameManager;

  Future get onClose => tab.onClose;

  bool get isClosed => tab.session.isClosed;

  PageFrame get mainFrame => _frameManager.mainFrame;

  get keyboard => null;

  get touchscreen => null;

  get mouse => null;

  _onLogEntryAdded(event) {
    //TODO(xha)
  }

  Future<ElementHandle> $(String selector) {
    return mainFrame.$(selector);
  }

  Future<JsHandle> evaluateHandle(Js pageFunction,
  {List args}) async {
    var context = await mainFrame.executionContext;
    return context.evaluateHandle(pageFunction, args: args);
  }

  Future<JsHandle> queryObjects(JsHandle prototypeHandle) async {
    var context = await mainFrame.executionContext;
    return context.queryObjects(prototypeHandle);
  }

  Future<T> $eval<T>(String selector, Js pageFunction, {List args}) {
    return mainFrame.$eval<T>(selector, pageFunction, args:args);
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
    return tab.network.getCookies(urls: urls);
  }

  Future<void> deleteCookie(List<Cookie> cookies) async {
    var pageUrl = url;
    for (var cookie in cookies) {
      await tab.network.deleteCookies(cookie.name,
          url: pageUrl.startsWith('http') ? pageUrl : null,
          domain: cookie.domain,
          path: cookie.path);
    }
  }

  Future setCookie(List<Cookie> cookies) {
    //TODO(xha)
  }

  Future<ElementHandle> addScriptTag(
      {String url, File file, String content, String type}) {
    return mainFrame.addScriptTag(
        url: url, file: file, content: content, type: type);
  }

  Future<ElementHandle> addStyleTag({String url, File file, String content}) {
    return mainFrame.addStyleTag(url: url, file: file, content: content);
  }

  Future exposeFunction(String name, Function callbackFunction) async {
    if (_pageBindings.containsKey(name))
      throw Exception(
          'Failed to add page binding with name $name: window["$name"] already exists!');
    _pageBindings[name] = callbackFunction;

    //TODO(xha)
  }

  Future authenticate({String username, String password}) {
    //TODO(xha)
  }

  /**
   * @param {!Object<string, string>} headers
   */
  Future setExtraHTTPHeaders(headers) {
//TODO(xha)
  }

  /**
   * @param {string} userAgent
   */
  Future setUserAgent(userAgent) {
//TODO(xha)
  }

  /**
   * @return {!Promise<!Metrics>}
   */
  Future metrics() {
//TODO(xha)
  }

  /**
   * @param {!Protocol.Performance.metricsPayload} event
   */
  _emitMetrics(event) {
//TODO(xha)
  }

  /**
   * @param {?Array<!Protocol.Performance.Metric>} metrics
   * @return {!Metrics}
   */
  _buildMetricsObject(metrics) {
//TODO(xha)
  }

  /**
   * @param {!Protocol.Runtime.ExceptionDetails} exceptionDetails
   */
  _handleException(exceptionDetails) {
//TODO(xha)
  }

  /**
   * @param {!Protocol.Runtime.consoleAPICalledPayload} event
   */
  Future _onConsoleAPI(event) {
//TODO(xha)
  }

  /**
   * @param {!Protocol.Runtime.bindingCalledPayload} event
   */
  Future _onBindingCalled(event) {
//TODO(xha)
  }

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

  Future<void> setContent(String html, {Duration timeout, WaitUntil waitUntil}) {
    return _frameManager.mainFrame
        .setContent(html, timeout: timeout, waitUntil: waitUntil);
  }

  Future<NetworkResponse> goto(String url,
      {String referrer, Duration timeout, WaitUntil waitUntil}) {
    return _frameManager.mainFrame
        .goto(url, referrer: referrer, timeout: timeout, waitUntil: waitUntil);
  }

  Future<NetworkResponse> reload({Duration timeout, WaitUntil waitUntil}) async {
    var responseFuture = waitForNavigation(timeout: timeout, waitUntil: waitUntil);

    await tab.page.reload();
    return await responseFuture;
  }

  Future<NetworkResponse> waitForNavigation({Duration timeout, WaitUntil waitUntil}) {
    return _frameManager.mainFrame.waitForNavigation(timeout: timeout, waitUntil: waitUntil);
  }

  /**
   * @param {(string|Function)} urlOrPredicate
   * @param {!{timeout?: number}=} options
   * @return {!Promise<!Puppeteer.Request>}
   */
  Future waitForRequest(urlOrPredicate, options) {
    //TODO(xha)
  }

  /**
   * @param {(string|Function)} urlOrPredicate
   * @param {!{timeout?: number}=} options
   * @return {!Promise<!Puppeteer.Response>}
   */
  Future waitForResponse(urlOrPredicate, options) {
    //TODO(xha)
  }

  /**
   * @param {!{timeout?: number, waitUntil?: string|!Array<string>}=} options
   * @return {!Promise<?Puppeteer.Response>}
   */
  Future goBack(options) {
    //TODO(xha)
  }

  /**
   * @param {!{timeout?: number, waitUntil?: string|!Array<string>}=} options
   * @return {!Promise<?Puppeteer.Response>}
   */
  Future goForward(options) {
    //TODO(xha)
  }

  /**
   * @param {!{timeout?: number, waitUntil?: string|!Array<string>}=} options
   * @return {!Promise<?Puppeteer.Response>}
   */
  Future _go(delta, options) {
    //TODO(xha)
  }

  Future bringToFront() {
    //TODO(xha)
  }

  /**
   * @param {!{viewport: !Puppeteer.Viewport, userAgent: string}} options
   */
  Future emulate(options) {
    //TODO(xha)
  }


  bool get javascriptEnabled => _javascriptEnabled;
  /**
   * @param {boolean} enabled
   */
  Future setJavaScriptEnabled(enabled) {
    _javascriptEnabled = enabled;
    //TODO(xha)
  }

  /**
   * @param {boolean} enabled
   */
  Future setBypassCSP(enabled) {
    //TODO(xha)
  }

  /**
   * @param {?string} mediaType
   */
  Future emulateMedia(mediaType) {
    //TODO(xha)
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

  Future evaluateOnNewDocument(String pageFunction, [Map<String, dynamic> args]) async {
    var source = evaluationString(pageFunction, args);
    await tab.page.addScriptToEvaluateOnNewDocument(source);
  }

  /**
   * @param {boolean} enabled
   */
  Future setCacheEnabled(enabled) {}

  /**
   * @param {!ScreenshotOptions=} options
   * @return {!Promise<!Buffer|!String>}
   */
  Future screenshot(options) {}

  /**
   * @param {"png"|"jpeg"} format
   * @param {!ScreenshotOptions=} options
   * @return {!Promise<!Buffer|!String>}
   */
  Future _screenshotTask(format, options) {}

  /**
   * @param {!PDFOptions=} options
   * @return {!Promise<!Buffer>}
   */
  Future pdf() {}

  Future<String> get title {
    return mainFrame.title;
  }

  Future<void> close({bool runBeforeUnload}) async {
    runBeforeUnload ??= false;
    if (runBeforeUnload) {
      await tab.page.close();
    } else {
      await tab.close();
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

  Future<ElementHandle> waitForXPath(String xpath, {bool visible, bool hidden, Duration timeout}) {
    return mainFrame.waitForXPath(xpath, visible: visible, hidden: hidden, timeout: timeout);
  }

  Future<JsHandle> waitForFunction(
      Js pageFunction, List args,
      {Duration timeout, Polling polling}) {
    return mainFrame.waitForFunction(pageFunction, args,
        timeout: timeout, polling: polling);
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
