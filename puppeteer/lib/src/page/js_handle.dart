import 'dart:io';
import 'dart:math';
import 'package:chrome_dev_tools/dom.dart';
import 'package:chrome_dev_tools/runtime.dart';
import '../connection.dart';
import 'execution_context.dart';
import 'frame_manager.dart';
import 'helper.dart';
import 'keyboard.dart';
import 'mouse.dart';
import 'page.dart';

export 'package:chrome_dev_tools/dom.dart' show BoxModel;

/// JSHandle represents an in-page JavaScript object. JSHandles can be created
/// with the [page.evaluateHandle] method.
///
/// ```dart
/// var windowHandle = await page.evaluateHandle('() => window');
/// ```
///
/// JSHandle prevents the referenced JavaScript object being garbage collected
/// unless the handle is [disposed]. JSHandles are auto-disposed when their
/// origin frame gets navigated or the parent context gets destroyed.
///
/// JSHandle instances can be used as arguments in [page.$eval], [page.evaluate]
/// and [page.evaluateHandle] methods.
class JsHandle {
  /// Returns execution context the handle belongs to.
  final ExecutionContext executionContext;
  final RemoteObject remoteObject;
  bool _disposed = false;

  JsHandle(this.executionContext, this.remoteObject);

  factory JsHandle.fromRemoteObject(
      ExecutionContext context, RemoteObject remoteObject) {
    var frame = context.frame;
    if (remoteObject.subtype == RemoteObjectSubtype.node && frame != null) {
      var frameManager = context.world.frameManager;
      return ElementHandle(context, remoteObject, context.frame, frameManager);
    }
    return JsHandle(context, remoteObject);
  }

  bool get isDisposed => _disposed;

  /// Fetches a single property from the referenced object.
  Future<JsHandle> property(String propertyName) async {
    var objectHandle = await executionContext.evaluateHandle(
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

  /// Fetches the jsonValue of a single property from the referenced object.
  Future<T> propertyValue<T>(String propertyName) async {
    T value = await (await property(propertyName)).jsonValue;
    return value;
  }

  /// The method returns a map with property names as keys and JSHandle instances
  /// for the property values.
  ///
  /// ```dart
  /// var handle = await page.evaluateHandle('() => ({window, document})');
  /// var properties = await handle.properties;
  /// JsHandle windowHandle = properties['window'];
  /// ElementHandle documentHandle = properties['document'];
  /// await handle.dispose();
  /// ```
  Future<Map<String, JsHandle>> get properties async {
    var response = await executionContext.runtimeApi
        .getProperties(remoteObject.objectId, ownProperties: true);
    var result = <String, JsHandle>{};
    for (var property in response.result) {
      if (!property.enumerable) continue;
      result[property.name] =
          JsHandle.fromRemoteObject(executionContext, property.value);
    }
    return result;
  }

  /// Returns a JSON representation of the object. If the object has a
  /// [`toJSON`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify#toJSON()_behavior)
  /// function, it **will not be called**.
  ///
  /// > **NOTE** The method will return an empty JSON object if the referenced
  /// object is not stringifiable.
  /// It will throw an error if the object has circular references.
  Future<dynamic> get jsonValue async {
    if (remoteObject.objectId != null) {
      var response = await executionContext.runtimeApi.callFunctionOn(
          'function() { return this; }',
          objectId: remoteObject.objectId,
          returnByValue: true,
          awaitPromise: true);

      return valueFromRemoteObject(response.result);
    }
    return valueFromRemoteObject(remoteObject);
  }

  /// Returns either `null` or the object handle itself, if the object handle is
  /// an instance of [ElementHandle].
  ElementHandle get asElement => null;

  /// Stops referencing the element handle.
  ///
  /// Returns a Future which completes when the object handle is successfully
  /// disposed.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    if (remoteObject.objectId != null) {
      await executionContext.runtimeApi
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
      return 'JSHandle@$type';
    }
    return 'JSHandle:${valueFromRemoteObject(remoteObject)}';
  }
}

/// ElementHandle represents an in-page DOM element. ElementHandles can be
/// created with the [page.$] method.
///
/// ```dart
/// import 'package:puppeteer/puppeteer.dart';
///
/// main() async {
///   var browser = await puppeteer.launch();
///
///   var page = await browser.newPage();
///   await page.goto('https://example.com');
///   var hrefElement = await page.$('a');
///   await hrefElement.click();
///
///   await browser.close();
/// }
/// ```
///
/// ElementHandle prevents DOM element from garbage collection unless the handle
///  is [disposed]. ElementHandles are auto-disposed when their origin frame gets
///  navigated.
///
/// ElementHandle instances can be used as arguments in [page.$eval] and
/// [page.evaluate] methods.
class ElementHandle extends JsHandle {
  final PageFrame frame;
  final FrameManager frameManager;

  ElementHandle(ExecutionContext context, RemoteObject remoteObject, this.frame,
      this.frameManager)
      : super(context, remoteObject);

  Page get page => frameManager.page;

  @override
  ElementHandle get asElement => this;

  /// Resolves to the content frame for element handles referencing iframe nodes,
  /// or null otherwise
  Future<PageFrame> get contentFrame async {
    var nodeInfo = await executionContext.domApi
        .describeNode(objectId: remoteObject.objectId);

    if (nodeInfo.frameId == null) return null;
    return frameManager.frame(nodeInfo.frameId);
  }

  Future<void> _scrollIntoViewIfNeeded() async {
    var error = await executionContext.evaluate(
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
    var quads = await executionContext.domApi
        .getContentQuads(objectId: remoteObject.objectId)
        .catchError((_) => null,
            test: ServerException.matcher('Could not compute content quads.'));
    var layoutMetrics = await executionContext.pageApi.getLayoutMetrics();

    if (quads == null || quads.isEmpty) {
      throw NodeIsNotVisibleException();
    }

    var layoutViewport = layoutMetrics.layoutViewport;

    // Filter out quads that have too small area to click into.
    var pointsList = quads
        .map(quadToPoints)
        .map((quad) => _intersectQuadWithViewport(
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

  List<Point> _intersectQuadWithViewport(
      List<Point> quad, num width, num height) {
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

  /// This method scrolls element into view if needed, and then uses [page.mouse]
  /// to click in the center of the element.
  /// If the element is detached from DOM, the method throws an error.
  ///
  /// Parameters:
  /// - [button]: Defaults to [MouseButton.left]
  /// - [clickCount]: Defaults to 1
  /// - [delay]: Time to wait between `mousedown` and `mouseup`. Defaults to 0.
  ///
  /// Returns [Future] which resolves when the element is successfully clicked.
  /// [Future] gets rejected if the element is detached from DOM.
  Future<void> click(
      {Duration delay, MouseButton button, int clickCount}) async {
    await _scrollIntoViewIfNeeded();
    var point = await _clickablePoint();
    await page.mouse
        .click(point, delay: delay, button: button, clickCount: clickCount);
  }

  /// This method expects `elementHandle` to point to an [input element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input).
  ///
  /// Sets the value of the file input these paths.
  Future<void> uploadFile(List<File> files) async {
    await executionContext.domApi.setFileInputFiles(
        files.map((file) => file.absolute.path).toList(),
        objectId: remoteObject.objectId);
  }

  /// This method scrolls element into view if needed, and then uses [touchscreen.tap]
  /// to tap in the center of the element.
  /// If the element is detached from DOM, the method throws an error.
  Future<void> tap() async {
    await _scrollIntoViewIfNeeded();
    var point = await _clickablePoint();
    await page.touchscreen.tap(point);
  }

  /// Calls [focus](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/focus)
  /// on the element.
  Future<void> focus() {
    return executionContext.evaluate(
        //language=js
        'function _(element) {return element.focus();}',
        args: [this]);
  }

  /// Focuses the element, and then sends a `keydown`, `keypress`/`input`, and
  /// `keyup` event for each character in the text.
  ///
  /// To press a special key, like `Control` or `ArrowDown`, use [`elementHandle.press`].
  ///
  /// ```dart
  /// await elementHandle.type('Hello'); // Types instantly
  ///
  /// // Types slower, like a user
  /// await elementHandle.type('World', delay: Duration(milliseconds: 100));
  ///
  /// ///---
  /// ```
  ///
  /// An example of typing into a text field and then submitting the form:
  /// ```dart
  /// var elementHandle = await page.$('input');
  /// await elementHandle.type('some text');
  /// await elementHandle.press(Key.enter);
  /// ```
  Future<void> type(String text, {Duration delay}) async {
    await focus();
    await page.keyboard.type(text, delay: delay);
  }

  /// Focuses the element, and then uses [`keyboard.down`] and [`keyboard.up`].
  ///
  /// If `key` is a single character and no modifier keys besides `Shift` are
  /// being held down, a `keypress`/`input` event will also be generated. The
  /// `text` option can be specified to force an input event to be generated.
  ///
  /// > **NOTE** Modifier keys DO effect `elementHandle.press`. Holding down
  /// `Shift` will type the text in upper case.
  ///
  /// Parameters:
  /// - [text]: If specified, generates an input event with this text.
  /// - [delay]: Time to wait between `keydown` and `keyup`. Defaults to 0.
  Future<void> press(Key key, {Duration delay, String text}) async {
    await focus();
    await page.keyboard.press(key, delay: delay, text: text);
  }

  /// This method returns the bounding box of the element (relative to the main
  /// frame), or `null` if the element is not visible.
  Future<Rectangle> get boundingBox async {
    var result = await boxModel;

    if (result == null) return null;

    var quad = result.border;
    var x = [0, 2, 4, 6].map((i) => quad.value[i]).reduce(min);
    var y = [1, 3, 5, 7].map((i) => quad.value[i]).reduce(min);
    var width = [0, 2, 4, 6].map((i) => quad.value[i]).reduce(max) - x;
    var height = [1, 3, 5, 7].map((i) => quad.value[i]).reduce(max) - y;

    return Rectangle(x, y, width, height);
  }

  /// This method returns boxes of the element, or `null` if the element is not
  /// visible.
  /// Boxes are represented as an array of points;
  /// Box points are sorted clock-wise.
  Future<BoxModel> get boxModel {
    return executionContext.domApi
        .getBoxModel(objectId: remoteObject.objectId)
        .catchError((_) => null,
            test: ServerException.matcher('Could not compute box model.'));
  }

  /// This method scrolls element into view if needed, and then uses [page.screenshot]
  /// to take a screenshot of the element.
  /// If the element is detached from DOM, the method throws an error.
  ///
  /// See [Page.screenshot] for more info.
  Future<List<int>> screenshot(
      {ScreenshotFormat format, num quality, bool omitBackground}) async {
    var needsViewportReset = false;

    var boundingBox = await this.boundingBox;
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

    boundingBox = await this.boundingBox;
    assert(boundingBox != null,
        'Node is either not visible or not an HTMLElement');
    assert(boundingBox.width != 0, 'Node has 0 width.');
    assert(boundingBox.height != 0, 'Node has 0 height.');

    var layoutViewPort =
        (await executionContext.pageApi.getLayoutMetrics()).layoutViewport;

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

  /// The method runs `element.querySelector` within the page. If no element
  /// matches the selector, the return value resolves to `null`.
  Future<ElementHandle> $(String selector) async {
    var handle = await executionContext.evaluateHandle(
        //language=js
        '(element, selector) => element.querySelector(selector);',
        args: [this, selector]);
    var element = handle.asElement;
    if (element != null) return element;
    await handle.dispose();
    return null;
  }

  /// The method runs `element.querySelectorAll` within the page. If no elements
  /// match the selector, the return value resolves to `[]`.
  Future<List<ElementHandle>> $$(String selector) async {
    var arrayHandle = await executionContext.evaluateHandle(
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

  /// This method runs `document.querySelector` within the element and passes it
  /// as the first argument to `pageFunction`. If there's no element matching
  /// `selector`, the method throws an error.
  ///
  /// If `pageFunction` returns a [Promise], then `frame.$eval` would wait for
  /// the promise to resolve and return its value.
  ///
  /// Examples:
  /// ```dart
  /// var tweetHandle = await page.$('.tweet');
  /// expect(await tweetHandle.$eval('.like', 'node => node.innerText'),
  ///     equals('100'));
  /// expect(await tweetHandle.$eval('.retweets', 'node => node.innerText'),
  ///     equals('10'));
  /// ```
  ///
  /// Parameters:
  /// - A [selector] to query page for
  /// - [pageFunction]: Function to be evaluated in browser context
  /// - [args]: Arguments to pass to `pageFunction`
  ///
  /// Returns [Future] which resolves to the return value of `pageFunction`.
  Future<T> $eval<T>(String selector, @Language('js') String pageFunction,
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

    T result = await executionContext.evaluate<T>(pageFunction, args: allArgs);
    await elementHandle.dispose();
    return result;
  }

  /// This method runs `document.querySelectorAll` within the element and passes
  /// it as the first argument to `pageFunction`. If there's no element matching
  /// `selector`, the method throws an error.
  ///
  /// If `pageFunction` returns a [Promise], then `frame.$$eval` would wait for
  /// the promise to resolve and return its value.
  ///
  /// Examples:
  /// ```html
  /// <div class="feed">
  ///   <div class="tweet">Hello!</div>
  ///   <div class="tweet">Hi!</div>
  /// </div>
  /// ```
  /// ```dart
  /// var feedHandle = await page.$('.feed');
  /// expect(
  ///     await feedHandle.$$eval('.tweet', 'nodes => nodes.map(n => n.innerText)'),
  ///     equals(['Hello!', 'Hi!']));
  /// ```
  ///
  /// Parameters:
  /// - A [selector] to query page for
  /// - [pageFunction]: Function to be evaluated in browser context
  /// - [args]: Arguments to pass to `pageFunction`
  ///
  /// Returns: [Future] which resolves to the return value of `pageFunction`
  Future<T> $$eval<T>(String selector, @Language('js') String pageFunction,
      {List args}) async {
    var arrayHandle = await executionContext.evaluateHandle(
        //language=js
        'function _(element, selector) {return Array.from(element.querySelectorAll(selector));}',
        args: [this, selector]);

    List allArgs = [arrayHandle];
    if (args != null) {
      allArgs.addAll(args);
    }

    T result = await executionContext.evaluate<T>(pageFunction, args: allArgs);
    await arrayHandle.dispose();
    return result;
  }

  /// The method evaluates the XPath expression relative to the elementHandle.
  /// If there are no such elements, the method will resolve to an empty array.
  Future<List<ElementHandle>> $x(String expression) async {
    var arrayHandle = await executionContext.evaluateHandle(
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

  /// Resolves to true if the element is visible in the current viewport.
  Future<bool> get isIntersectingViewport {
    return executionContext.evaluate(
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
  @override
  String toString() => 'Node is either not visible or not an HTMLElement';
}
