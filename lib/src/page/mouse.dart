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
  MouseButton _button;

  Mouse(this.inputApi, this.keyboard);

  /// Dispatches a `mousemove` event.
  Future<void> move(Point position, {int steps}) async {
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
      {Duration delay, MouseButton button, int clickCount}) async {
    await move(position);
    await down(button: button, clickCount: clickCount);
    if (delay != null) await Future.delayed(delay);
    await up(button: button, clickCount: clickCount);
  }

  /// Dispatches a `mousedown` event.
  Future<void> down({MouseButton button, int clickCount}) async {
    button ??= MouseButton.left;
    clickCount ??= 1;
    _button = button;
    await inputApi.dispatchMouseEvent('mousePressed', _position.x, _position.y,
        button: button, modifiers: keyboard.modifiers, clickCount: clickCount);
  }

  /// Dispatches a `mouseup` event.
  Future<void> up({MouseButton button, int clickCount}) async {
    button ??= MouseButton.left;
    clickCount ??= 1;
    _button = null;
    await inputApi.dispatchMouseEvent('mouseReleased', _position.x, _position.y,
        button: button, modifiers: keyboard.modifiers, clickCount: clickCount);
  }
}
