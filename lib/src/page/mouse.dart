import 'dart:math';

import 'package:chrome_dev_tools/domains/input.dart';
import 'package:chrome_dev_tools/src/page/keyboard.dart';

class MouseButton {
  static const left = MouseButton._('left');
  static const right = MouseButton._('right');
  static const middle = MouseButton._('middle');

  final String name;

  const MouseButton._(this.name);
}

class Mouse {
  final InputApi inputApi;
  final Keyboard keyboard;
  Point _position = Point(0, 0);
  MouseButton _button;

  Mouse(this.inputApi, this.keyboard);

  static String _buttonName(MouseButton button) => button?.name ?? 'none';

  Future<void> move(Point position, {int steps}) async {
    steps ??= 1;
    var from = _position;
    _position = position;
    for (var i = 1; i <= steps; i++) {
      await inputApi.dispatchMouseEvent('mouseMoved',
          from.x + (position.x - from.x) * (i / steps),
          from.y + (position.y - from.y) * (i / steps),
          button: _buttonName(_button),
          modifiers: keyboard.modifiers);
    }
  }

  Future<void> click(Point position,
      {Duration delay, MouseButton button, int clickCount}) async {
    await move(position);
    await down(button: button, clickCount: clickCount);
    if (delay != null)
      await Future.delayed(delay);
    await up(button: button, clickCount: clickCount);
  }

  Future<void> down({MouseButton button, int clickCount}) async {
    button ??= MouseButton.left;
    clickCount ??= 1;
    _button = button;
    await inputApi.dispatchMouseEvent(
        'mousePressed', _position.x, _position.y, button: _buttonName(button),
        modifiers: keyboard.modifiers,
        clickCount: clickCount);
  }

  Future<void> up({MouseButton button, int clickCount}) async {
    button ??= MouseButton.left;
    clickCount ??= 1;
    _button = null;
    await inputApi.dispatchMouseEvent(
        'mouseReleased', _position.x, _position.y, button: _buttonName(button),
        modifiers: keyboard.modifiers,
        clickCount: clickCount);
  }
}
