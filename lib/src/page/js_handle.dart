import 'dart:io';
import 'dart:math';

import 'package:chrome_dev_tools/domains/dom.dart';
import 'package:chrome_dev_tools/domains/runtime.dart';
import 'package:chrome_dev_tools/src/connection.dart';
import 'package:chrome_dev_tools/src/page/execution_context.dart';
import 'package:chrome_dev_tools/src/page/frame_manager.dart';
import 'package:chrome_dev_tools/src/page/helper.dart';
import 'package:chrome_dev_tools/src/page/keyboard.dart';
import 'package:chrome_dev_tools/src/page/mouse.dart';
import 'package:chrome_dev_tools/src/page/page.dart';

export 'package:chrome_dev_tools/domains/dom.dart' show BoxModel;

class JsHandle {
  final ExecutionContext context;
  final RemoteObject remoteObject;
  bool _disposed = false;

  JsHandle(this.context, this.remoteObject);

  factory JsHandle.fromRemoteObject(ExecutionContext context,
      RemoteObject remoteObject) {
    var frame = context.frame;
    if (remoteObject.subtype == RemoteObjectSubtype.node && frame != null) {
      var frameManager = context.world.frameManager;
      return ElementHandle(context, remoteObject, context.frame, frameManager);
    }
    return JsHandle(context, remoteObject);
  }

  bool get isDisposed => _disposed;

  Future<JsHandle> property(String propertyName) async {
    var objectHandle = await context.evaluateHandle(
      //language=js
        '''
function _(object, propertyName) {
  const result = {__proto__: null};
  result[propertyName] = object[propertyName];
  return result;
}
''', args: [this, propertyName]);
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
    var error = await context.evaluate(
      //language=js
        '''
async function _(element, pageJavascriptEnabled) {
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
}
''', args: [this, page.javascriptEnabled]);
    if (error != null && error != false) {
      throw Exception(error);
    }
  }

  Future<Point> _clickablePoint() async {
    var quads =
    await context.domApi.getContentQuads(objectId: remoteObject.objectId)
        .catchError((_) => null,
        test: ServerException.matcher('Could not compute content quads.'));
        var layoutMetrics = await context.pageApi.getLayoutMetrics();

    if (quads == null || quads.isEmpty) {
      throw NodeIsNotVisibleException();
    }

    var layoutViewport = layoutMetrics.layoutViewport;

    // Filter out quads that have too small area to click into.
    var pointsList = quads
        .map(quadToPoints)
        .map((quad) =>
        _intersectQuadWithViewport(
            quad, layoutViewport.clientWidth, layoutViewport.clientHeight))
        .where((quad) => _computeQuadArea(quad) > 1)
        .toList();
    if (pointsList.isEmpty) {
      throw NodeIsNotVisibleException();
    }
    // Return the middle point of the first quad.
    var points = pointsList[0];
    num x = 0;
    num y = 0;
    for (var point in points) {
      x += point.x;
      y += point.y;
    }
    return Point(x / 4, y / 4);
  }

  static List<Point> quadToPoints(Quad quad) {
    return [
      Point(quad.value[0], quad.value[1]),
      Point(quad.value[2], quad.value[3]),
      Point(quad.value[4], quad.value[5]),
      Point(quad.value[6], quad.value[7])
    ];
  }

  List<Point> _intersectQuadWithViewport(List<Point> quad, num width,
      num height) {
    return quad
        .map((point) =>
        Point(min(max(point.x, 0), width), min(max(point.y, 0), height)))
        .toList();
  }

  static num _computeQuadArea(List<Point> quad) {
    // Compute sum of all directed areas of adjacent triangles
    // https://en.wikipedia.org/wiki/Polygon#Simple_polygons
    num area = 0;
    for (var i = 0; i < quad.length; ++i) {
      var p1 = quad[i];
      var p2 = quad[(i + 1) % quad.length];
      area += (p1.x * p2.y - p2.x * p1.y) / 2;
    }
    return area.abs();
  }

  Future<void> hover() async {
    await _scrollIntoViewIfNeeded();
    var point = await _clickablePoint();
    await page.mouse.move(point);
  }

  Future<void> click(
      {Duration delay, MouseButton button, int clickCount}) async {
    await _scrollIntoViewIfNeeded();
    var point = await _clickablePoint();
    await page.mouse
        .click(point, delay: delay, button: button, clickCount: clickCount);
  }

  Future<void> uploadFile(List<File> files) async {
    await context.domApi.setFileInputFiles(
        files.map((file) => file.absolute.path).toList(),
        objectId: remoteObject.objectId);
  }

  Future<void> tap() async {
    await _scrollIntoViewIfNeeded();
    var point = await _clickablePoint();
    await page.touchscreen.tap(point);
  }

  Future<void> focus() {
    return context.evaluate(
      //language=js
        'function _(element) {return element.focus();}',
        args: [this]);
  }

  Future<void> type(String text, {Duration delay}) async {
    await focus();
    await page.keyboard.type(text, delay: delay);
  }

  Future<void> press(Key key, {Duration delay, String text}) async {
    await focus();
    await page.keyboard.press(key, delay: delay, text: text);
  }

  Future<Rectangle> boundingBox() async {
    var result = await boxModel();

    if (result == null) return null;

    var quad = result.border;
    var x = [0, 2, 4, 6].map((i) => quad.value[i]).reduce(min);
    var y = [1, 3, 5, 7].map((i) => quad.value[i]).reduce(min);
    var width = [0, 2, 4, 6].map((i) => quad.value[i]).reduce(max) - x;
    var height = [1, 3, 5, 7].map((i) => quad.value[i]).reduce(max) - y;

    return Rectangle(x, y, width, height);
  }

  Future<BoxModel> boxModel() {
    return context.domApi
        .getBoxModel(objectId: remoteObject.objectId)
        .catchError((_) => null,
        test: ServerException.matcher('Could not compute box model.'));
  }

  Future<List<int>> screenshot(
      {ScreenshotFormat format, num quality, bool omitBackground}) async {
    var needsViewportReset = false;

    var boundingBox = await this.boundingBox();
    assert(boundingBox != null,
    'Node is either not visible or not an HTMLElement');

    var viewport = page.viewport;

    if (viewport != null &&
        (boundingBox.width > viewport.width ||
            boundingBox.height > viewport.height)) {
      await page.setViewport(viewport.copyWith(
          width: max(viewport.width, boundingBox.width.ceil()),
          height: max(viewport.height, boundingBox.height.ceil())));

      needsViewportReset = true;
    }

    await _scrollIntoViewIfNeeded();

    boundingBox = await this.boundingBox();
    assert(boundingBox != null,
    'Node is either not visible or not an HTMLElement');
    assert(boundingBox.width != 0, 'Node has 0 width.');
    assert(boundingBox.height != 0, 'Node has 0 height.');

    var layoutViewPort =
        (await context.pageApi.getLayoutMetrics()).layoutViewport;

    var clip = Rectangle(
        boundingBox.left + layoutViewPort.pageX,
        boundingBox.top + layoutViewPort.pageY,
        boundingBox.width,
        boundingBox.height);

    var imageData = await page.screenshot(
        format: format,
        clip: clip,
        quality: quality,
        omitBackground: omitBackground);

    if (needsViewportReset) {
      await page.setViewport(viewport);
    }

    return imageData;
  }

  Future<ElementHandle> $(String selector) async {
    var handle = await context.evaluateHandle(
      //language=js
        '(element, selector) => element.querySelector(selector);',
        args: [this, selector]);
    var element = handle.asElement;
    if (element != null) return element;
    await handle.dispose();
    return null;
  }

  Future<List<ElementHandle>> $$(String selector) async {
    var arrayHandle = await context.evaluateHandle(
      //language=js
        'function _(element, selector) {return element.querySelectorAll(selector);}',
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

  Future<T> $eval<T>(String selector, @javascript String pageFunction,
      {List args}) async {
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

  Future<T> $$eval<T>(String selector, @javascript String pageFunction,
      {List args}) async {
    var arrayHandle = await context.evaluateHandle(
      //language=js
        'function _(element, selector) {return Array.from(element.querySelectorAll(selector));}',
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
    var arrayHandle = await context.evaluateHandle(
      //language=js
        '''
function _(element, expression) {
  const document = element.ownerDocument || element;
  const iterator = document.evaluate(expression, element, null, XPathResult.ORDERED_NODE_ITERATOR_TYPE);
  const array = [];
  let item;
  while ((item = iterator.iterateNext()))
    array.push(item);
  return array;
}
''', args: [this, expression]);
    var properties = await arrayHandle.properties;
    await arrayHandle.dispose();
    var result = <ElementHandle>[];
    for (var property in properties.values) {
      var elementHandle = property.asElement;
      if (elementHandle != null) result.add(elementHandle);
    }
    return result;
  }

  Future<bool> get isIntersectingViewport {
    return context.evaluate(
      //language=js
        '''
async function _(element) {
  const visibleRatio = await new Promise(resolve => {
    const observer = new IntersectionObserver(entries => {
      resolve(entries[0].intersectionRatio);
      observer.disconnect();
    });
    observer.observe(element);
  });
  return visibleRatio > 0;
}''', args: [this]);
  }
}

class NodeIsNotVisibleException {
  String toString() => 'Node is either not visible or not an HTMLElement';
}
