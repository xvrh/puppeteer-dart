import 'dart:math';

import 'package:chrome_dev_tools/domains/runtime.dart';
import 'package:chrome_dev_tools/src/page/dom_world.dart';
import 'package:chrome_dev_tools/src/page/execution_context.dart';
import 'package:chrome_dev_tools/src/page/frame_manager.dart';
import 'package:chrome_dev_tools/src/page/helper.dart';
import 'package:chrome_dev_tools/src/page/page.dart';

class JsHandle {
  final ExecutionContext context;
  final RemoteObject remoteObject;
  bool _disposed = false;

  JsHandle(this.context, this.remoteObject);

  factory JsHandle.fromRemoteObject(
      ExecutionContext context, RemoteObject remoteObject) {
    var frame = context.frame;
    if (remoteObject.subtype == RemoteObjectSubtype.node && frame != null) {
      var frameManager = context.world.frameManager;
      return ElementHandle(
          context, remoteObject, context.frame, frameManager);
    }
    return JsHandle(context, remoteObject);
  }

  bool get isDisposed => _disposed;

  Future<JsHandle> property(String propertyName) async {
    var objectHandle =
        await context.evaluateHandle(Js.function(['object', 'propertyName'], '''
const result = {__proto__: null};
result[propertyName] = object[propertyName];
return result;
'''), args: [this, propertyName]);
    var properties = await objectHandle.properties;
    var result = properties[propertyName];
    await objectHandle.dispose();
    return result;
  }

  Future<T> propertyValue<T>(String propertyName) async {
    T value = await (await property(propertyName)).jsonValue;
    return value;
  }

  Future<Map<String, JsHandle>> get properties async {
    var response = await context.runtimeApi
        .getProperties(remoteObject.objectId, ownProperties: true);
    var result = <String, JsHandle>{};
    for (var property in response.result) {
      if (!property.enumerable) continue;
      result[property.name] =
          JsHandle.fromRemoteObject(context, property.value);
    }
    return result;
  }

  Future<dynamic> get jsonValue async {
    if (remoteObject.objectId != null) {
      var response = await context.runtimeApi.callFunctionOn(
          'function() { return this; }',
          objectId: remoteObject.objectId,
          returnByValue: true,
          awaitPromise: true);

      return valueFromRemoteObject(response.result);
    }
    return valueFromRemoteObject(remoteObject);
  }

  ElementHandle get asElement => null;

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    if (remoteObject.objectId != null) {
      await context.runtimeApi
          .releaseObject(remoteObject.objectId)
          .catchError((_) {
        // Exceptions might happen in case of a page been navigated or closed.
        // Swallow these since they are harmless and we don't leak anything in this case.
      });
    }
  }

  @override
  String toString() {
    if (remoteObject.objectId != null) {
      String type = remoteObject.subtype?.value ?? remoteObject.type?.value;
      return 'JSHandle@' + type;
    }
    return 'JSHandle:' + valueFromRemoteObject(remoteObject);
  }
}

class ElementHandle extends JsHandle {
  final PageFrame frame;
  final FrameManager frameManager;

  ElementHandle(ExecutionContext context, RemoteObject remoteObject, this.frame,
      this.frameManager)
      : super(context, remoteObject);

  Page get page => frameManager.page;

  @override
  ElementHandle get asElement => this;

  Future<PageFrame> get contentFrame async {
    var nodeInfo =
        await context.domApi.describeNode(objectId: remoteObject.objectId);

    if (nodeInfo.frameId == null) return null;
    return frameManager.frame(nodeInfo.frameId);
  }

  Future _scrollIntoViewIfNeeded() async {
    var error = await context
        .evaluate(Js.function(['element', 'pageJavascriptEnabled'], '''
if (!element.isConnected) {
  return 'Node is detached from document';
}
if (element.nodeType !== Node.ELEMENT_NODE) {
  return 'Node is not of type HTMLElement';
}
// force-scroll if page's javascript is disabled.
if (!pageJavascriptEnabled) {
  element.scrollIntoView({block: 'center', inline: 'center', behavior: 'instant'});
  return false;
}
const visibleRatio = await new Promise(resolve => {
  const observer = new IntersectionObserver(entries => {
    resolve(entries[0].intersectionRatio);
    observer.disconnect();
  });
  observer.observe(element);
});
if (visibleRatio !== 1.0) {
  element.scrollIntoView({block: 'center', inline: 'center', behavior: 'instant'});
}
return false;
''', isAsync: true), args: [this, page.javascriptEnabled]);
    if (error != null && error != false) {
      throw Exception(error);
    }
  }

  /**
   * @return {!Promise<!{x: number, y: number}>}
   */
  Future<Point> _clickablePoint() async {
    //TODO(xha)
  }

  /**
   * @return {!Promise<void|Protocol.DOM.getBoxModelReturnValue>}
   */
  _getBoxModel() {
    //TODO(xha)
  }

  /**
   * @param {!Array<number>} quad
   * @return {!Array<{x: number, y: number}>}
   */
  _fromProtocolQuad(quad) {
    //TODO(xha)
  }

  Future<void> hover() async {
    await _scrollIntoViewIfNeeded();
    var point = await _clickablePoint();
    await page.mouse.move(point);
  }

  Future<void> click({Duration delay, MouseButton button, int clickCount}) async {
    await _scrollIntoViewIfNeeded();
    var point = await _clickablePoint();
    await page.mouse.click(point, delay: delay, button: button, clickCount: clickCount);
  }

  /**
   * @param {!Array<string>} filePaths
   */
  Future uploadFile(List<String> filePaths) {
//TODO(xha)
  }

  Future<void> tap() async {
    await _scrollIntoViewIfNeeded();
    var point = await _clickablePoint();
    await page.touchscreen.tap(point);
  }

  Future<void> focus() {
    return frame.evaluate(Js.function(['element'], 'return element.focus();'), args: [this]);
  }

  Future<void> type(String text, {Duration delay}) async {
    await focus();
    await page.keyboard.type(text, delay: delay);
  }

  Future<void> press(String key, {Duration delay, String text}) async {
    await focus();
    await page.keyboard.press(key, delay: delay, text: text);
  }

  /**
   * @return {!Promise<?{x: number, y: number, width: number, height: number}>}
   */
  Future boundingBox() {
//TODO(xha)
  }

  /**
   * @return {!Promise<?BoxModel>}
   */
  Future boxModel() {
//TODO(xha)
  }

  /**
   *
   * @param {!Object=} options
   * @returns {!Promise<string|!Buffer>}
   */
  Future screenshot(options) {
//TODO(xha)
  }

  Future<ElementHandle> $(String selector) async {
    var handle = await context.evaluateHandle(
        Js.function(
            ['element', 'selector'], 'return element.querySelector(selector)'),
        args: [this, selector]);
    var element = handle.asElement;
    if (element != null) return element;
    await handle.dispose();
    return null;
  }

  Future<List<ElementHandle>> $$(String selector) async {
    var arrayHandle = await context.evaluateHandle(
        Js.function(['element', 'selector'],
            'return element.querySelectorAll(selector)'),
        args: [this, selector]);
    var properties = await arrayHandle.properties;
    await arrayHandle.dispose();
    var result = <ElementHandle>[];
    for (var property in properties.values) {
      var elementHandle = property.asElement;
      if (elementHandle != null) result.add(elementHandle);
    }
    return result;
  }

  Future<T> $eval<T>(String selector, Js pageFunction, {List args}) async {
    var elementHandle = await $(selector);
    if (elementHandle == null) {
      throw Exception(
          'Error: failed to find element matching selector "$selector"');
    }

    List allArgs = [elementHandle];
    if (args != null) {
      allArgs.addAll(args);
    }

    T result = await context.evaluate<T>(pageFunction, args: allArgs);
    await elementHandle.dispose();
    return result;
  }

  Future<T> $$eval<T>(String selector, Js pageFunction, {List args}) async {
    var arrayHandle = await context.evaluateHandle(
        Js.function(['element', 'selector'],
            'return Array.from(element.querySelectorAll(selector))'),
        args: [this, selector]);

    List allArgs = [arrayHandle];
    if (args != null) {
      allArgs.addAll(args);
    }

    T result = await context.evaluate<T>(pageFunction, args: allArgs);
    await arrayHandle.dispose();
    return result;
  }

  Future<List<ElementHandle>> $x(String expression) async {
    var arrayHandle =
        await context.evaluateHandle(Js.function(['element', 'expression'], '''
const document = element.ownerDocument || element;
const iterator = document.evaluate(expression, element, null, XPathResult.ORDERED_NODE_ITERATOR_TYPE);
const array = [];
let item;
while ((item = iterator.iterateNext()))
  array.push(item);
return array;
'''), args: [this, expression]);
    var properties = await arrayHandle.properties;
    await arrayHandle.dispose();
    var result = <ElementHandle>[];
    for (var property in properties.values) {
      var elementHandle = property.asElement;
      if (elementHandle != null) result.add(elementHandle);
    }
    return result;
  }

  /**
   * @returns {!Promise<boolean>}
   */
  isIntersectingViewport() {
//TODO(xha)
  }
}
