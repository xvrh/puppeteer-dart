import 'dart:math';
import '../../protocol/input.dart';
import 'keyboard.dart';

export '../../protocol/input.dart' show MouseButton;

/// The Mouse class operates in main-frame CSS pixels relative to the top-left
/// corner of the viewport.
///
/// Every `page` object has its own Mouse, accessible with [page.mouse].
///
/// ```dart
/// // Using ‘page.mouse’ to trace a 100x100 square.
/// await page.mouse.move(Point(0, 0));
/// await page.mouse.down();
/// await page.mouse.move(Point(0, 100));
/// await page.mouse.move(Point(100, 100));
/// await page.mouse.move(Point(100, 0));
/// await page.mouse.move(Point(0, 0));
/// await page.mouse.up();
/// ```
class Mouse {
  final InputApi inputApi;
  final Keyboard keyboard;
  Point _position = Point(0, 0);
  MouseButton? _button;

  Mouse(this.inputApi, this.keyboard);

  /// Dispatches a `mousemove` event.
  Future<void> move(Point position, {int? steps}) async {
    steps ??= 1;
    var from = _position;
    _position = position;
    for (var i = 1; i <= steps; i++) {
      await inputApi.dispatchMouseEvent(
          'mouseMoved',
          from.x + (position.x - from.x) * (i / steps),
          from.y + (position.y - from.y) * (i / steps),
          button: _button ?? MouseButton.none,
          modifiers: keyboard.modifiers);
    }
  }

  /// Shortcut for [mouse.move], [mouse.down] and [mouse.up].
  ///
  /// [delay]: Time to wait between `mousedown` and `mouseup`. Defaults to 0.
  Future<void> click(Point position,
      {Duration? delay, MouseButton? button, int? clickCount}) async {
    await move(position);
    await down(button: button, clickCount: clickCount);
    if (delay != null) await Future.delayed(delay);
    await up(button: button, clickCount: clickCount);
  }

  /// Dispatches a `mousedown` event.
  Future<void> down({MouseButton? button, int? clickCount}) async {
    button ??= MouseButton.left;
    clickCount ??= 1;
    _button = button;
    await inputApi.dispatchMouseEvent('mousePressed', _position.x, _position.y,
        button: button, modifiers: keyboard.modifiers, clickCount: clickCount);
  }

  /// Dispatches a `mouseup` event.
  Future<void> up({MouseButton? button, int? clickCount}) async {
    button ??= MouseButton.left;
    clickCount ??= 1;
    _button = null;
    await inputApi.dispatchMouseEvent('mouseReleased', _position.x, _position.y,
        button: button, modifiers: keyboard.modifiers, clickCount: clickCount);
  }

  /// Dispatches a `mousewheel` event.
  /// @param options - Optional: `MouseWheelOptions`.
  ///
  /// @example
  /// An example of zooming into an element:
  /// ```dart
  /// await page.goto(
  ///     r'https://mdn.mozillademos.org/en-US/docs/Web/API/Element/wheel_event$samples/Scaling_an_element_via_the_wheel?revision=1587366');
  /// var elem = await page.$('div');
  /// var boundingBox = (await elem.boundingBox)!;
  /// await page.mouse.move(Point(boundingBox.left + boundingBox.width / 2,
  ///     boundingBox.top + boundingBox.height / 2));
  /// await page.mouse.wheel(deltaY: -100);
  /// ```
  Future<void> wheel({num? deltaX, num? deltaY}) async {
    await inputApi.dispatchMouseEvent('mouseWheel', _position.x, _position.y,
        deltaX: deltaX ?? 0,
        deltaY: deltaY ?? 0,
        modifiers: keyboard.modifiers,
        pointerType: 'mouse');
  }

  /// Dispatches a `drag` event.
  /// @param start - starting point for drag
  /// @param target - point to drag to
  /// ```
  Future<DragData> drag(Point start, Point target) async {
    var future = inputApi.onDragIntercepted.first;
    await move(start);
    await down();
    await move(target);
    return future;
  }

  /// Dispatches a `dragenter` event.
  /// @param target - point for emitting `dragenter` event
  /// ```
  Future<void> dragEnter(Point target, DragData data) async {
    await inputApi.dispatchDragEvent('dragEnter', target.x, target.y, data,
        modifiers: keyboard.modifiers);
  }

  /// Dispatches a `dragover` event.
  /// @param target - point for emitting `dragover` event
  /// ```
  Future<void> dragOver(Point target, DragData data) async {
    await inputApi.dispatchDragEvent('dragOver', target.x, target.y, data,
        modifiers: keyboard.modifiers);
  }

  /// Performs a dragenter, dragover, and drop in sequence.
  /// @param target - point to drop on
  /// @param data - drag data containing items and operations mask
  /// @param options - An object of options. Accepts delay which,
  /// if specified, is the time to wait between `dragover` and `drop` in milliseconds.
  /// Defaults to 0.
  /// ```
  Future<void> drop(Point target, DragData data) async {
    await inputApi.dispatchDragEvent('drop', target.x, target.y, data,
        modifiers: keyboard.modifiers);
  }

  /// Performs a drag, dragenter, dragover, and drop in sequence.
  /// @param target - point to drag from
  /// @param target - point to drop on
  /// @param options - An object of options. Accepts delay which,
  /// if specified, is the time to wait between `dragover` and `drop` in milliseconds.
  /// Defaults to 0.
  /// ```
  Future<void> dragAndDrop(Point start, Point target, {Duration? delay}) async {
    var data = await drag(start, target);
    await dragEnter(target, data);
    await dragOver(target, data);
    if (delay != null) await Future.delayed(delay);
    await drop(target, data);
    await up();
  }
}
