import 'dart:async';

import 'package:chrome_dev_tools/src/page/execution_context.dart';
import 'package:chrome_dev_tools/src/page/frame_manager.dart';
import 'package:chrome_dev_tools/src/page/js_handle.dart';
import 'package:chrome_dev_tools/src/page/lifecycle_watcher.dart';

class DomWorld {
  final FrameManager frameManager;
  final PageFrame frame;
  final _waitTasks = <WaitTask>{};
  Completer<ExecutionContext> _contextCompleter;
  Future<ElementHandle> _documentFuture;
  bool _detached = false;

  DomWorld(this.frameManager, this.frame) {
    setContext(null);
  }

  void setContext(ExecutionContext context) {
    if (context != null) {
      assert(_contextCompleter != null);

      _contextCompleter.complete(context);

      for (var waitTask in _waitTasks) {
        waitTask.rerun();
      }
    } else {
      if (_contextCompleter != null && !_contextCompleter.isCompleted) {
        // TODO(xha): see if this is the behavior we want
        _contextCompleter.completeError('Context is disposed');
      }
      _contextCompleter = Completer<ExecutionContext>();
    }
  }

  bool get hasContext =>
      _contextCompleter != null && _contextCompleter.isCompleted;

  void detach() {
    _detached = true;
    for (var waitTask in _waitTasks) {
      waitTask.terminate(
          new Exception('waitForFunction failed: frame got detached.'));
    }
  }

  Future<ExecutionContext> get executionContext {
    if (_detached) {
      throw Exception(
          'Execution Context is not available in detached frame "${frame.url}" (are you trying to evaluate?)');
    }
    return _contextCompleter.future;
  }

  Future<JsHandle> evaluateHandle(Js js, {List args}) async {
    var context = await executionContext;
    return context.evaluateHandle(js, args: args);
  }

  Future evaluate(Js pageFunction, {List args}) async {
    var context = await executionContext;
    return context.evaluate(pageFunction, args: args);
  }

  Future<ElementHandle> $(String selector) async {
    var document = await _document;
    var value = document.$(selector);
    return value;
  }

  Future<ElementHandle> get _document {
    if (_documentFuture != null) {
      return _documentFuture;
    }
    _documentFuture = executionContext.then((context) async {
      var document = await context.evaluateHandle(Js.expression('document'));
      return document.asElement;
    });
    return _documentFuture;
  }

  Future<List<ElementHandle>> $x(expression) async {
    var document = await _document;
    var value = await document.$x(expression);
    return value;
  }

  Future $eval(String selector, Js js, {List  args}) async {
    var document = await _document;
    return document.$eval(selector, js, args: args);
  }

  Future $$eval(String selector, Js pageFunction, {List args}) async {
    var document = await _document;
    var value = await document.$$eval(selector, pageFunction, args: args);
    return value;
  }

  Future<List<ElementHandle>> $$(String selector) async {
    var document = await _document;
    var value = await document.$$(selector);
    return value;
  }

  Future<String> get content async {
    return await evaluate(Js.function([], '''
let retVal = '';
if (document.doctype) {
  retVal = new XMLSerializer().serializeToString(document.doctype);
}
if (document.documentElement) {
  retVal += document.documentElement.outerHTML;
}
return retVal;
'''));
  }

  Future setContent(String html, {Duration timeout, WaitUntil waitUntil}) {}

  addScriptTag({String url, String path, String content, String type}) {}

  Future<ElementHandle> addStyleTag({String url, String path, String content}) {}

  Future click(String selector, {Duration delay, MouseButton button, int clickCount}) {}

  Future focus(String selector) {}

  Future hover(String selector) {}

  Future<List<String>> select(String selector, List<String> values) {
    return $eval(selector, Js.function(['element', 'values'], '''
        if (element.nodeName.toLowerCase() !== 'select')
    throw new Error('Element is not a <select> element.');

    const options = Array.from(element.options);
    element.value = undefined;
    for (const option of options) {
    option.selected = values.includes(option.value);
    if (option.selected && !element.multiple)
    break;
    }
    element.dispatchEvent(new Event('input', { 'bubbles': true }));
    element.dispatchEvent(new Event('change', { 'bubbles': true }));
    return options.filter(option => option.selected).map(option => option.value);
    '''), args: [values]);
  }

  Future tap(String selector) {}

  Future type(String selector, String text, {Duration delay}) {}

  Future<ElementHandle> waitForSelector(String selector, {bool visible, bool hidden, Duration timeout}) {}

  Future<ElementHandle> waitForXPath(String xpath, {bool visible, bool hidden, Duration timeout}) {}

  Future<JsHandle> waitForFunction(String pageFunction, Map<String, dynamic> args, {Duration timeout, Polling polling}) {}

  Future<String> get title => null;
}

class WaitTask {
  rerun() {}

  terminate(Exception exception) {}
}

class Polling {
  Polling.raf();
  Polling.mutation();
  Polling.interval(Duration duration);
}

enum MouseButton {
  left, right, middle
}
