import 'dart:async';
import 'dart:io';
import '../javascript_function_parser.dart';
import 'execution_context.dart';
import 'frame_manager.dart';
import 'js_handle.dart';
import 'lifecycle_watcher.dart';
import 'mouse.dart';

class DomWorld {
  final FrameManager frameManager;
  final Frame frame;
  final _waitTasks = <WaitTask>{};
  Completer<ExecutionContext>? _contextCompleter;
  Future<ElementHandle>? _documentFuture;
  bool _detached = false;

  DomWorld(this.frameManager, this.frame) {
    setContext(null);
  }

  void setContext(ExecutionContext? context) {
    if (context != null) {
      _documentFuture = null;
      _contextCompleter!.complete(context);

      for (var waitTask in _waitTasks) {
        waitTask.rerun();
      }
    } else {
      if (_contextCompleter != null && !_contextCompleter!.isCompleted) {
        _contextCompleter!.completeError('Context is disposed');
      }
      _contextCompleter = Completer<ExecutionContext>();
    }
  }

  bool get hasContext =>
      _contextCompleter != null && _contextCompleter!.isCompleted;

  void detach() {
    _detached = true;
    for (var waitTask in _waitTasks.toList()) {
      waitTask
          .terminate(Exception('waitForFunction failed: frame got detached.'));
    }
  }

  Future<ExecutionContext> get executionContext {
    if (_detached) {
      throw Exception(
          'Execution Context is not available in detached frame "${frame.url}" (are you trying to evaluate?)');
    }
    return _contextCompleter!.future;
  }

  Future<T> evaluateHandle<T extends JsHandle>(
      @Language('js') String pageFunction,
      {List? args}) async {
    var context = await executionContext;
    return context.evaluateHandle(pageFunction, args: args);
  }

  Future<T> evaluate<T>(@Language('js') String pageFunction,
      {List? args}) async {
    var context = await executionContext;
    return context.evaluate<T>(pageFunction, args: args);
  }

  Future<ElementHandle> $(String selector) async {
    var document = await _document;
    var value = document.$(selector);
    return value;
  }

  Future<ElementHandle?> $OrNull(String selector) async {
    var document = await _document;
    return document.$OrNull(selector);
  }

  Future<ElementHandle> get _document {
    if (_documentFuture != null) {
      return _documentFuture!;
    }
    _documentFuture = executionContext.then((context) async {
      var document = await context.evaluateHandle('document');
      return document.asElement!;
    });
    return _documentFuture!;
  }

  Future<List<ElementHandle>> $x(String expression) async {
    var document = await _document;
    var value = await document.$x(expression);
    return value;
  }

  Future<T?> $eval<T>(String selector, @Language('js') String pageFunction,
      {List? args}) async {
    var document = await _document;
    return document.$eval<T>(selector, pageFunction, args: args);
  }

  Future<T?> $$eval<T>(String selector, @Language('js') String pageFunction,
      {List? args}) async {
    var document = await _document;
    return document.$$eval<T>(selector, pageFunction, args: args);
  }

  Future<List<ElementHandle>> $$(String selector) async {
    var document = await _document;
    var value = await document.$$(selector);
    return value;
  }

  Future<String?> get content async {
    return await evaluate(
        //language=js
        '''
function _() {
  let retVal = '';
  if (document.doctype) {
    retVal = new XMLSerializer().serializeToString(document.doctype);
  }
  if (document.documentElement) {
    retVal += document.documentElement.outerHTML;
  }
  return retVal;
}
''');
  }

  Future<void> setContent(String html, {Duration? timeout, Until? wait}) async {
    timeout ??= frameManager.page.navigationTimeoutOrDefault;
    wait ??= Until.load;

    // We rely upon the fact that document.open() will reset frame lifecycle with "init"
    // lifecycle event. @see https://crrev.com/608658
    await evaluate(
        //language=js
        '''
function _(html) {
  document.open();
  document.write(html);
  document.close();
}
''', args: [html]);
    var watcher =
        LifecycleWatcher(frameManager, frame, wait: wait, timeout: timeout);
    var error = await Future.any([
      watcher.timeoutOrTermination,
      watcher.lifecycle,
    ]);
    watcher.dispose();
    if (error != null) {
      throw error;
    }
  }

  Future<ElementHandle> addScriptTag(
      {String? url, File? file, String? content, String? type}) async {
    assert(url != null || file != null || content != null);
    type ??= '';

    var context = await executionContext;

    if (url != null) {
      return (await context.evaluateHandle(
          //language=js
          '''
async function _(url, type) {
  const script = document.createElement('script');
  script.src = url;
  if (type)
    script.type = type;
  const promise = new Promise((res, rej) => {
    script.onload = res;
    script.onerror = rej;
  });
  document.head.appendChild(script);
  await promise;
  return script;
}
''', args: [url, type])).asElement!;
    }

    var addScriptContent =
        //language=js
        '''
function _(content, type) {
  const script = document.createElement('script');
  script.type = type;
  script.text = content;
  let error = null;
  script.onerror = e => error = e;
  document.head.appendChild(script);
  if (error)
    throw error;
  return script;
}
''';

    if (file != null) {
      var contents = await file.readAsString();
      contents += '//# sourceURL=${file.absolute.path}';
      return (await context
              .evaluateHandle(addScriptContent, args: [contents, type]))
          .asElement!;
    }

    if (content != null) {
      return (await context
              .evaluateHandle(addScriptContent, args: [content, type]))
          .asElement!;
    }

    throw StateError('');
  }

  Future<ElementHandle> addStyleTag(
      {String? url, File? file, String? content}) async {
    assert(url != null || file != null || content != null);

    var context = await executionContext;

    if (url != null) {
      return (await context.evaluateHandle(
          //language=js
          '''
async function _(url) {
  const link = document.createElement('link');
  link.rel = 'stylesheet';
  link.href = url;
  const promise = new Promise((res, rej) => {
    link.onload = res;
    link.onerror = rej;
  });
  document.head.appendChild(link);
  await promise;
  return link;   
}
''', args: [url])).asElement!;
    }

    var addStyleContent =
        //language=js
        '''
async function _(content) {
  const style = document.createElement('style');
  style.type = 'text/css';
  style.appendChild(document.createTextNode(content));
  const promise = new Promise((res, rej) => {
    style.onload = res;
    style.onerror = rej;
  });
  document.head.appendChild(style);
  await promise;
  return style;
}
''';

    if (file != null) {
      var contents = await file.readAsString();
      contents += '/*# sourceURL=${file.absolute.path}*/';
      return (await context.evaluateHandle(addStyleContent, args: [contents]))
          .asElement!;
    }

    if (content != null) {
      return (await context.evaluateHandle(addStyleContent, args: [content]))
          .asElement!;
    }

    throw StateError('');
  }

  Future<void> click(String selector,
      {Duration? delay, MouseButton? button, int? clickCount}) async {
    var handle = await $OrNull(selector);
    if (handle == null) {
      throw Exception('No node found for selector: $selector');
    }
    await handle.click(delay: delay, button: button, clickCount: clickCount);
    await handle.dispose();
  }

  Future<void> focus(String selector) async {
    var handle = await $(selector);
    await handle.focus();
    await handle.dispose();
  }

  Future<void> hover(String selector) async {
    var handle = await $(selector);
    await handle.hover();
    await handle.dispose();
  }

  Future<List<String>> select(String selector, List<String> values) async {
    var handle = await $(selector);
    var result = await handle.select(values);
    await handle.dispose();
    return result;
  }

  Future<void> tap(String selector) async {
    var handle = await $(selector);
    await handle.tap();
    await handle.dispose();
  }

  Future<void> type(String selector, String text, {Duration? delay}) async {
    var handle = await $(selector);
    await handle.type(text, delay: delay);
    await handle.dispose();
  }

  Future<ElementHandle?> waitForSelector(String selector,
      {bool? visible, bool? hidden, Duration? timeout}) {
    return _waitForSelectorOrXPath(selector,
        isXPath: false, visible: visible, hidden: hidden, timeout: timeout);
  }

  Future<ElementHandle?> waitForXPath(String xpath,
      {bool? visible, bool? hidden, Duration? timeout}) {
    return _waitForSelectorOrXPath(xpath,
        isXPath: true, visible: visible, hidden: hidden, timeout: timeout);
  }

  Future<JsHandle> waitForFunction(
      @Language('js') String pageFunction, List? args,
      {Duration? timeout, Polling? polling}) async {
    var functionDeclaration = convertToFunctionDeclaration(pageFunction);
    if (functionDeclaration == null) {
      pageFunction = 'function _() { return $pageFunction; }';
    }

    return await WaitTask(this, pageFunction,
            title: 'function',
            polling: polling ?? Polling.everyFrame,
            timeout: timeout ?? frameManager.page.defaultTimeout,
            predicateArgs: args)
        .future;
  }

  static final _predicate =
      //language=js
      '''
function _(selectorOrXPath, isXPath, waitForVisible, waitForHidden) {
  const node = isXPath
    ? document.evaluate(selectorOrXPath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue
    : document.querySelector(selectorOrXPath);
  if (!node)
    return waitForHidden;
  if (!waitForVisible && !waitForHidden)
    return node;
  const element = /** @type {Element} */ (node.nodeType === Node.TEXT_NODE ? node.parentElement : node);
  
  const style = window.getComputedStyle(element);
  const isVisible = style && style.visibility !== 'hidden' && hasVisibleBoundingBox();
  const success = (waitForVisible === isVisible || waitForHidden === !isVisible);
  return success ? node : null;
  
  /**
   * @return {boolean}
   */
  function hasVisibleBoundingBox() {
    const rect = element.getBoundingClientRect();
    return !!(rect.top || rect.bottom || rect.width || rect.height);
  }      
}
''';

  Future<ElementHandle?> _waitForSelectorOrXPath(String selectorOrXPath,
      {bool isXPath = false,
      bool? visible,
      bool? hidden,
      Duration? timeout}) async {
    var waitForVisible = visible ?? false;
    var waitForHidden = hidden ?? false;

    var polling =
        waitForVisible || waitForHidden ? Polling.everyFrame : Polling.mutation;
    var title =
        '${isXPath ? 'XPath' : 'selector'} "$selectorOrXPath"${waitForHidden ? ' to be hidden' : ''}';
    var waitTask = WaitTask(this, _predicate,
        title: title,
        polling: polling,
        timeout: timeout ?? frameManager.page.defaultTimeout,
        predicateArgs: [
          selectorOrXPath,
          isXPath,
          waitForVisible,
          waitForHidden
        ]);
    var handle = await waitTask.future;
    if (handle.asElement == null) {
      await handle.dispose();
      //throw Exception(
      //    "selector $selectorOrXPath doesn't resolve to an element");
      return null;
    }
    return handle.asElement;
  }

  Future<String?> get title => evaluate('document.title');
}

class WaitTask {
  final DomWorld domWorld;
  @Language('js')
  final String predicate;
  final String title;
  final Polling polling;
  final Duration? timeout;
  final List? predicateArgs;
  final _completer = Completer<JsHandle>();
  int _runCount = 0;
  late Timer _timeoutTimer;
  bool _terminated = false;

  WaitTask(this.domWorld, @Language('js') this.predicate,
      {required this.title,
      required this.polling,
      required this.timeout,
      required this.predicateArgs}) {
    domWorld._waitTasks.add(this);

    // Since page navigation requires us to re-install the pageScript, we should track
    // timeout on our end.
    if (timeout != null) {
      var timeoutError = TimeoutException(
          'waiting for $title failed: timeout ${timeout!.inMilliseconds}ms exceeded');
      _timeoutTimer = Timer(timeout!, () => terminate(timeoutError));
    }
    rerun();
  }

  Future<JsHandle> get future => _completer.future;

  void terminate(Exception error) {
    _terminated = true;
    _completer.completeError(error);
    _cleanup();
  }

  Future<void> rerun() async {
    var runCount = ++_runCount;
    try {
      var args = <dynamic>[
        'return ($predicate)(...args)',
        polling.value,
        timeout!.inMilliseconds
      ];
      if (predicateArgs != null) {
        args.addAll(predicateArgs!);
      }
      var success = await domWorld.evaluateHandle(_waitForPredicatePageFunction,
          args: args);

      if (_terminated || runCount != _runCount) {
        await success.dispose();
        return;
      }

      // Ignore timeouts in pageScript - we track timeouts ourselves.
      // If the frame's execution context has already changed, `frame.evaluate` will
      // throw an error - ignore this predicate run altogether.
      if (await domWorld.evaluate<bool>('function(s) { return !s; }',
          args: [success]).catchError((_) => true)) {
        await success.dispose();
        return;
      }

      _completer.complete(success);
    } on Exception catch (error) {
      // When the page is navigated, the promise is rejected.
      // We will try again in the new execution context.
      if (error is ExecutionContextDestroyedException) {
        return;
      }

      if (!_completer.isCompleted) {
        _completer.completeError(error);
      }
    }

    _cleanup();
  }

  void _cleanup() {
    _timeoutTimer.cancel();
    domWorld._waitTasks.remove(this);
  }
}

final _waitForPredicatePageFunction =
    //language=js
    '''
async function _(predicateBody, polling, timeout, ...args) {
  const predicate = new Function('...args', predicateBody);
  let timedOut = false;
  if (timeout)
    setTimeout(() => timedOut = true, timeout);
  if (polling === 'raf')
    return await pollRaf();
  if (polling === 'mutation')
    return await pollMutation();
  if (typeof polling === 'number')
    return await pollInterval(polling);

  /**
   * @return {!Promise<*>}
   */
  function pollMutation() {
    const success = predicate.apply(null, args);
    if (success)
      return Promise.resolve(success);

    let fulfill;
    const result = new Promise(x => fulfill = x);
    const observer = new MutationObserver(mutations => {
      if (timedOut) {
        observer.disconnect();
        fulfill();
      }
      const success = predicate.apply(null, args);
      if (success) {
        observer.disconnect();
        fulfill(success);
      }
    });
    observer.observe(document, {
      childList: true,
      subtree: true,
      attributes: true
    });
    return result;
  }

  /**
   * @return {!Promise<*>}
   */
  function pollRaf() {
    let fulfill;
    const result = new Promise(x => fulfill = x);
    onRaf();
    return result;

    function onRaf() {
      if (timedOut) {
        fulfill();
        return;
      }
      const success = predicate.apply(null, args);
      if (success)
        fulfill(success);
      else
        requestAnimationFrame(onRaf);
    }
  }

  /**
   * @param {number} pollInterval
   * @return {!Promise<*>}
   */
  function pollInterval(pollInterval) {
    let fulfill;
    const result = new Promise(x => fulfill = x);
    onTimeout();
    return result;

    function onTimeout() {
      if (timedOut) {
        fulfill();
        return;
      }
      const success = predicate.apply(null, args);
      if (success)
        fulfill(success);
      else
        setTimeout(onTimeout, pollInterval);
    }
  }
}
''';

class Polling {
  static const everyFrame = Polling._raf();
  static const mutation = Polling._mutation();

  final dynamic _value;

  const Polling._raf() : _value = 'raf';

  const Polling._mutation() : _value = 'mutation';

  Polling.interval(Duration duration) : _value = duration.inMilliseconds {
    assert(duration.inMilliseconds > 0);
  }

  dynamic get value => _value;
}
