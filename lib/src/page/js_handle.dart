import 'dart:math';

import 'package:chrome_dev_tools/domains/runtime.dart';
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
    if (remoteObject.subtype == 'node' && frame != null) {
      var frameManager = context.world.frameManager;
      return ElementHandle(
          context, remoteObject, frameManager.page, frameManager);
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

  Future propertyValue(String propertyName) async {
    return (await property(propertyName)).jsonValue;
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

  Future get jsonValue async {
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

  Future dispose() async {
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
      var type = remoteObject.subtype ?? remoteObject.type;
      return 'JSHandle@' + type;
    }
    return 'JSHandle:' + valueFromRemoteObject(remoteObject);
  }
}

class ElementHandle extends JsHandle {
  final Page page;
  final FrameManager frameManager;

  ElementHandle(ExecutionContext context, RemoteObject remoteObject, this.page,
      this.frameManager)
      : super(context, remoteObject);

  @override
  ElementHandle get asElement => this;

  /*Future<List<ElementHandle>> $x(String expression) async {
    return null;
  }

  Future<ElementHandle> $(String selector) async {}

  Future<List<ElementHandle>> $$(String selector) async {}

  Future $eval(String selector, String pageFunction,
      [Map<String, dynamic> args]) async {}

  Future $$eval(String selector, String pageFunction,
      [Map<String, dynamic> args]) async {}*/

  /**
   * @return {!Promise<?Puppeteer.Frame>}
   */
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

  Future hover() {
    //TODO(xha)
  }

  /**
   * @param {!{delay?: number, button?: "left"|"right"|"middle", clickCount?: number}=} options
   */
  Future click(options) {
    //TODO(xha)
  }

  /**
   * @param {!Array<string>} filePaths
   */
  Future uploadFile(List<String> filePaths) {
//TODO(xha)
  }

  Future tap() {
//TODO(xha)
  }

  Future focus() {
//TODO(xha)
  }

  /**
   * @param {string} text
   * @param {{delay: (number|undefined)}=} options
   */
  Future type(text, options) {
//TODO(xha)
  }

  /**
   * @param {string} key
   * @param {!{delay?: number, text?: string}=} options
   */
  Future press(key, options) {
//TODO(xha)
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

  Future $eval(String selector, Js pageFunction, {List args}) async {
    var elementHandle = await $(selector);
    if (elementHandle == null) {
      throw Exception(
          'Error: failed to find element matching selector "$selector"');
    }

    List allArgs = [elementHandle];
    if (args != null) {
      allArgs.addAll(args);
    }

    var result = await context.evaluate(pageFunction, args: allArgs);
    await elementHandle.dispose();
    return result;
  }

  Future $$eval(String selector, Js pageFunction, {List args}) async {
    var arrayHandle = await context.evaluateHandle(
        Js.function(['element', 'selector'],
            'return Array.from(element.querySelectorAll(selector))'),
        args: [this, selector]);

    List allArgs = [arrayHandle];
    if (args != null) {
      allArgs.addAll(args);
    }

    var result = await context.evaluate(pageFunction, args: allArgs);
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
