import 'dart:async';
import 'package:collection/collection.dart';
import '../../protocol/input.dart';

/// Keyboard provides an api for managing a virtual keyboard. The high level api
/// is [Keyboard.type], which takes raw characters and generates proper keydown,
/// keypress/input, and keyup events on your page.
///
/// For finer control, you can use [Keyboard.down], [keyboard.up], and
/// [keyboard.sendCharacter] to manually fire events as if they were generated
/// from a real keyboard.
///
/// An example of holding down `Shift` in order to select and delete some text:
/// ```dart
/// await page.keyboard.type('Hello World!');
/// await page.keyboard.press(Key.arrowLeft);
/// await page.keyboard.down(Key.shift);
/// for (var i = 0; i < ' World'.length; i++) {
///   await page.keyboard.press(Key.arrowLeft);
/// }
/// await page.keyboard.up(Key.shift);
/// await page.keyboard.press(Key.backspace);
/// // Result text will end up saying 'Hello!'
/// ```
///
/// An example of pressing `A`
/// ```dart
/// await page.keyboard.down(Key.shift);
/// await page.keyboard.press(Key.keyA, text: 'A');
/// await page.keyboard.up(Key.shift);
/// ```
///
/// > **NOTE** On MacOS, keyboard shortcuts like `⌘ A` -> Select All do not work. See [#1313](https://github.com/GoogleChrome/puppeteer/issues/1313)
class Keyboard {
  final InputApi _inputApi;
  final Set<String?> _pressedKeys = {};
  int _modifiers = 0;

  Keyboard(this._inputApi);

  int get modifiers => _modifiers;

  /// Dispatches a `keydown` event.
  ///
  /// If `key` is a modifier key, `Shift`, `Meta`, `Control`, or `Alt`,
  /// subsequent key presses will be sent with that modifier active. To release
  /// the modifier key, use [keyboard.up].
  ///
  /// After the key is pressed once, subsequent calls to [keyboard.down] will
  /// have [repeat](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/repeat)
  /// set to true. To release the key, use [keyboard.up].
  ///
  /// > **NOTE** Modifier keys DO influence `keyboard.down`. Holding down `Shift`
  /// will type the text in upper case.
  ///
  /// Parameters:
  /// [text]: If specified, generates an input event with this text.
  Future<void> down(Key key, {String? text}) async {
    var description = _keyDescription(key);

    var autoRepeat = _pressedKeys.contains(description.code);
    _pressedKeys.add(description.code);
    _modifiers |= _modifierBit(description.key);

    text ??= description.text;
    await _inputApi.dispatchKeyEvent(
        text != null && text.isNotEmpty ? 'keyDown' : 'rawKeyDown',
        modifiers: _modifiers,
        windowsVirtualKeyCode: description.keyCode,
        code: description.code,
        key: description.key,
        text: text,
        unmodifiedText: text,
        autoRepeat: autoRepeat,
        location: description.location!.index,
        isKeypad: description.location == KeyLocation.numpad);
  }

  /// Dispatches a `keyup` event.
  Future<void> up(Key key) async {
    var description = _keyDescription(key);

    _modifiers &= ~_modifierBit(description.key);
    _pressedKeys.remove(description.code);
    await _inputApi.dispatchKeyEvent('keyUp',
        modifiers: _modifiers,
        key: description.key,
        windowsVirtualKeyCode: description.keyCode,
        code: description.code,
        location: description.location!.index);
  }

  /// Dispatches a keypress and input event. This does not send a keydown or
  /// keyup event.
  ///
  /// NOTE Modifier keys DO NOT effect keyboard.sendCharacter. Holding down
  /// Shift will not type the text in upper case.
  ///
  /// ```dart
  /// await page.keyboard.sendCharacter('嗨');
  /// ```
  Future<void> sendCharacter(String text) async {
    await _inputApi.insertText(text);
  }

  /// Sends a keydown, keypress/input, and keyup event for each character in the
  /// text.
  ///
  /// [text]: A text to type into a focused element.
  /// [delay]: Time to wait between key presses. Defaults to 0.
  ///
  /// ```dart
  /// // Types instantly
  /// await page.keyboard.type('Hello');
  ///
  /// // Types slower, like a user
  /// await page.keyboard.type('World', delay: Duration(milliseconds: 10));
  /// ```
  Future<void> type(String text, {Duration? delay}) async {
    for (var rune in text.runes) {
      var char = String.fromCharCode(rune);

      var keyForChar = _characters[char];

      if (keyForChar != null) {
        await press(keyForChar, delay: delay);
      } else {
        await sendCharacter(char);
      }
      if (delay != null) {
        await Future.delayed(delay);
      }
    }
  }

  /// Shortcut for [Keyboard.down] and [Keyboard.up].
  ///
  /// > **NOTE** Modifier keys DO effect `keyboard.press`. Holding down `Shift`
  /// will type the text in upper case.
  ///
  /// [text]: If specified, generates an input event with this text.
  /// [delay]: Time to wait between `keydown` and `keyup`. Defaults to 0.
  Future<void> press(Key key, {Duration? delay, String? text}) async {
    await down(key, text: text);
    if (delay != null) {
      await Future.delayed(delay);
    }
    await up(key);
  }

  int _modifierBit(String? key) {
    if (key == Key.alt.key) return 1;
    if (key == Key.control.key) return 2;
    if (key == Key.meta.key) return 4;
    if (key == Key.shift.key) return 8;
    return 0;
  }

  _KeyDescription _keyDescription(Key key) {
    var shift = _modifiers & 8 != 0;
    var description = _KeyDescription()
      ..key = shift && key.shiftKey != null ? key.shiftKey : key.key
      ..keyCode =
          shift && key.shiftKeyCode != null ? key.shiftKeyCode : key.keyCode
      ..code = key.code
      ..location = key.location ?? KeyLocation.standard
      ..text = key.text;

    // if any modifiers besides shift are pressed, no text should be sent
    if (_modifiers & ~8 != 0) {
      description.text = null;
    }

    return description;
  }
}

class _KeyDescription {
  String? key;
  int? keyCode;
  String? code;
  String? text;
  KeyLocation? location;
}

class Key {
  static const Key power = Key._(key: 'Power', code: 'Power');
  static const Key eject = Key._(key: 'Eject', code: 'Eject');
  static const Key abort = Key._(keyCode: 3, code: 'Abort', key: 'Cancel');
  static const Key help = Key._(keyCode: 6, code: 'Help', key: 'Help');
  static const Key backspace =
      Key._(keyCode: 8, code: 'Backspace', key: 'Backspace');
  static const Key tab = Key._(keyCode: 9, code: 'Tab', key: 'Tab');
  static const Key numpadEnter = Key._(
      keyCode: 13,
      code: 'NumpadEnter',
      key: 'Enter',
      text: '\r',
      location: KeyLocation.numpad);
  static const Key enter =
      Key._(keyCode: 13, code: 'Enter', key: 'Enter', text: '\r');
  static const Key shiftLeft = Key._(
      keyCode: 16, code: 'ShiftLeft', key: 'Shift', location: KeyLocation.left);
  static const Key shiftRight = Key._(
      keyCode: 16,
      code: 'ShiftRight',
      key: 'Shift',
      location: KeyLocation.right);
  static const Key controlLeft = Key._(
      keyCode: 17,
      code: 'ControlLeft',
      key: 'Control',
      location: KeyLocation.left);
  static const Key controlRight = Key._(
      keyCode: 17,
      code: 'ControlRight',
      key: 'Control',
      location: KeyLocation.right);
  static const Key altLeft = Key._(
      keyCode: 18, code: 'AltLeft', key: 'Alt', location: KeyLocation.left);
  static const Key altRight = Key._(
      keyCode: 18, code: 'AltRight', key: 'Alt', location: KeyLocation.right);
  static const Key pause = Key._(keyCode: 19, code: 'Pause', key: 'Pause');
  static const Key capsLock =
      Key._(keyCode: 20, code: 'CapsLock', key: 'CapsLock');
  static const Key escape = Key._(keyCode: 27, code: 'Escape', key: 'Escape');
  static const Key convert =
      Key._(keyCode: 28, code: 'Convert', key: 'Convert');
  static const Key nonConvert =
      Key._(keyCode: 29, code: 'NonConvert', key: 'NonConvert');
  static const Key space = Key._(keyCode: 32, code: 'Space', key: ' ');
  static const Key pageUp = Key._(keyCode: 33, code: 'PageUp', key: 'PageUp');
  static const Key pageDown =
      Key._(keyCode: 34, code: 'PageDown', key: 'PageDown');
  static const Key end = Key._(keyCode: 35, code: 'End', key: 'End');
  static const Key home = Key._(keyCode: 36, code: 'Home', key: 'Home');
  static const Key arrowLeft =
      Key._(keyCode: 37, code: 'ArrowLeft', key: 'ArrowLeft');
  static const Key arrowUp =
      Key._(keyCode: 38, code: 'ArrowUp', key: 'ArrowUp');
  static const Key arrowRight =
      Key._(keyCode: 39, code: 'ArrowRight', key: 'ArrowRight');
  static const Key arrowDown =
      Key._(keyCode: 40, code: 'ArrowDown', key: 'ArrowDown');
  static const Key select = Key._(keyCode: 41, code: 'Select', key: 'Select');
  static const Key open = Key._(keyCode: 43, code: 'Open', key: 'Execute');
  static const Key printScreen =
      Key._(keyCode: 44, code: 'PrintScreen', key: 'PrintScreen');
  static const Key insert = Key._(keyCode: 45, code: 'Insert', key: 'Insert');
  static const Key numpad0 = Key._(
      keyCode: 45,
      shiftKeyCode: 96,
      key: 'Insert',
      code: 'Numpad0',
      shiftKey: '0',
      location: KeyLocation.numpad);
  static const Key delete = Key._(keyCode: 46, code: 'Delete', key: 'Delete');
  static const Key numpadDecimal = Key._(
      keyCode: 46,
      shiftKeyCode: 110,
      code: 'NumpadDecimal',
      key: '\u0000',
      shiftKey: '.',
      location: KeyLocation.numpad);
  static const Key metaLeft = Key._(
      keyCode: 91, code: 'MetaLeft', key: 'Meta', location: KeyLocation.left);
  static const Key metaRight = Key._(
      keyCode: 92, code: 'MetaRight', key: 'Meta', location: KeyLocation.right);
  static const Key contextMenu =
      Key._(keyCode: 93, code: 'ContextMenu', key: 'ContextMenu');
  static const Key numpadMultiply = Key._(
      keyCode: 106,
      code: 'NumpadMultiply',
      key: '*',
      location: KeyLocation.numpad);
  static const Key numpadAdd = Key._(
      keyCode: 107, code: 'NumpadAdd', key: '+', location: KeyLocation.numpad);
  static const Key numpadSubtract = Key._(
      keyCode: 109,
      code: 'NumpadSubtract',
      key: '-',
      location: KeyLocation.numpad);
  static const Key numpadDivide = Key._(
      keyCode: 111,
      code: 'NumpadDivide',
      key: '/',
      location: KeyLocation.numpad);
  static const Key f1 = Key._(keyCode: 112, code: 'F1', key: 'F1');
  static const Key f2 = Key._(keyCode: 113, code: 'F2', key: 'F2');
  static const Key f3 = Key._(keyCode: 114, code: 'F3', key: 'F3');
  static const Key f4 = Key._(keyCode: 115, code: 'F4', key: 'F4');
  static const Key f5 = Key._(keyCode: 116, code: 'F5', key: 'F5');
  static const Key f6 = Key._(keyCode: 117, code: 'F6', key: 'F6');
  static const Key f7 = Key._(keyCode: 118, code: 'F7', key: 'F7');
  static const Key f8 = Key._(keyCode: 119, code: 'F8', key: 'F8');
  static const Key f9 = Key._(keyCode: 120, code: 'F9', key: 'F9');
  static const Key f10 = Key._(keyCode: 121, code: 'F10', key: 'F10');
  static const Key f11 = Key._(keyCode: 122, code: 'F11', key: 'F11');
  static const Key f12 = Key._(keyCode: 123, code: 'F12', key: 'F12');
  static const Key f13 = Key._(keyCode: 124, code: 'F13', key: 'F13');
  static const Key f14 = Key._(keyCode: 125, code: 'F14', key: 'F14');
  static const Key f15 = Key._(keyCode: 126, code: 'F15', key: 'F15');
  static const Key f16 = Key._(keyCode: 127, code: 'F16', key: 'F16');
  static const Key f17 = Key._(keyCode: 128, code: 'F17', key: 'F17');
  static const Key f18 = Key._(keyCode: 129, code: 'F18', key: 'F18');
  static const Key f19 = Key._(keyCode: 130, code: 'F19', key: 'F19');
  static const Key f20 = Key._(keyCode: 131, code: 'F20', key: 'F20');
  static const Key f21 = Key._(keyCode: 132, code: 'F21', key: 'F21');
  static const Key f22 = Key._(keyCode: 133, code: 'F22', key: 'F22');
  static const Key f23 = Key._(keyCode: 134, code: 'F23', key: 'F23');
  static const Key f24 = Key._(keyCode: 135, code: 'F24', key: 'F24');
  static const Key numLock =
      Key._(keyCode: 144, code: 'NumLock', key: 'NumLock');
  static const Key scrollLock =
      Key._(keyCode: 145, code: 'ScrollLock', key: 'ScrollLock');
  static const Key audioVolumeMute =
      Key._(keyCode: 173, code: 'AudioVolumeMute', key: 'AudioVolumeMute');
  static const Key audioVolumeDown =
      Key._(keyCode: 174, code: 'AudioVolumeDown', key: 'AudioVolumeDown');
  static const Key audioVolumeUp =
      Key._(keyCode: 175, code: 'AudioVolumeUp', key: 'AudioVolumeUp');
  static const Key mediaTrackNext =
      Key._(keyCode: 176, code: 'MediaTrackNext', key: 'MediaTrackNext');
  static const Key mediaTrackPrevious = Key._(
      keyCode: 177, code: 'MediaTrackPrevious', key: 'MediaTrackPrevious');
  static const Key mediaStop =
      Key._(keyCode: 178, code: 'MediaStop', key: 'MediaStop');
  static const Key mediaPlayPause =
      Key._(keyCode: 179, code: 'MediaPlayPause', key: 'MediaPlayPause');
  static const Key semicolon =
      Key._(keyCode: 186, code: 'Semicolon', shiftKey: ':', key: ';');
  static const Key equal =
      Key._(keyCode: 187, code: 'Equal', shiftKey: '+', key: '=');
  static const Key numpadEqual = Key._(
      keyCode: 187,
      code: 'NumpadEqual',
      key: '=',
      location: KeyLocation.numpad);
  static const Key comma =
      Key._(keyCode: 188, code: 'Comma', shiftKey: '\<', key: ',');
  static const Key minus =
      Key._(keyCode: 189, code: 'Minus', shiftKey: '_', key: '-');
  static const Key period =
      Key._(keyCode: 190, code: 'Period', shiftKey: '>', key: '.');
  static const Key slash =
      Key._(keyCode: 191, code: 'Slash', shiftKey: '?', key: '/');
  static const Key backquote =
      Key._(keyCode: 192, code: 'Backquote', shiftKey: '~', key: '`');
  static const Key bracketLeft =
      Key._(keyCode: 219, code: 'BracketLeft', shiftKey: '{', key: '[');
  static const Key backslash =
      Key._(keyCode: 220, code: 'Backslash', shiftKey: '|', key: '\\');
  static const Key bracketRight =
      Key._(keyCode: 221, code: 'BracketRight', shiftKey: '}', key: ']');
  static const Key quote =
      Key._(keyCode: 222, code: 'Quote', shiftKey: '"', key: '\'');
  static const Key altGraph =
      Key._(keyCode: 225, code: 'AltGraph', key: 'AltGraph');
  static const Key props = Key._(keyCode: 247, code: 'Props', key: 'CrSel');
  static const Key cancel = Key._(keyCode: 3, key: 'Cancel', code: 'Abort');
  static const Key clear = Key._(
      keyCode: 12, key: 'Clear', code: 'Numpad5', location: KeyLocation.numpad);
  static const Key shift = Key._(
      keyCode: 16, key: 'Shift', code: 'ShiftLeft', location: KeyLocation.left);
  static const Key control = Key._(
      keyCode: 17,
      key: 'Control',
      code: 'ControlLeft',
      location: KeyLocation.left);
  static const Key alt = Key._(
      keyCode: 18, key: 'Alt', code: 'AltLeft', location: KeyLocation.left);
  static const Key accept = Key._(keyCode: 30, key: 'Accept');
  static const Key modeChange = Key._(keyCode: 31, key: 'ModeChange');
  static const Key print = Key._(keyCode: 42, key: 'Print');
  static const Key execute = Key._(keyCode: 43, key: 'Execute', code: 'Open');
  static const Key meta = Key._(
      keyCode: 91, key: 'Meta', code: 'MetaLeft', location: KeyLocation.left);
  static const Key attn = Key._(keyCode: 246, key: 'Attn');
  static const Key crSel = Key._(keyCode: 247, key: 'CrSel', code: 'Props');
  static const Key exSel = Key._(keyCode: 248, key: 'ExSel');
  static const Key eraseEof = Key._(keyCode: 249, key: 'EraseEof');
  static const Key play = Key._(keyCode: 250, key: 'Play');
  static const Key zoomOut = Key._(keyCode: 251, key: 'ZoomOut');
  static const Key numpad1 = Key._(
      keyCode: 35,
      shiftKeyCode: 97,
      key: 'End',
      code: 'Numpad1',
      shiftKey: '1',
      location: KeyLocation.numpad);
  static const Key numpad4 = Key._(
      keyCode: 37,
      shiftKeyCode: 100,
      key: 'ArrowLeft',
      code: 'Numpad4',
      shiftKey: '4',
      location: KeyLocation.numpad);
  static const Key numpad8 = Key._(
      keyCode: 38,
      shiftKeyCode: 104,
      key: 'ArrowUp',
      code: 'Numpad8',
      shiftKey: '8',
      location: KeyLocation.numpad);
  static const Key numpad7 = Key._(
      keyCode: 36,
      shiftKeyCode: 103,
      key: 'Home',
      code: 'Numpad7',
      shiftKey: '7',
      location: KeyLocation.numpad);
  static const Key numpad3 = Key._(
      keyCode: 34,
      shiftKeyCode: 99,
      key: 'PageDown',
      code: 'Numpad3',
      shiftKey: '3',
      location: KeyLocation.numpad);
  static const Key numpad9 = Key._(
      keyCode: 33,
      shiftKeyCode: 105,
      key: 'PageUp',
      code: 'Numpad9',
      shiftKey: '9',
      location: KeyLocation.numpad);
  static const Key numpad6 = Key._(
      keyCode: 39,
      shiftKeyCode: 102,
      key: 'ArrowRight',
      code: 'Numpad6',
      shiftKey: '6',
      location: KeyLocation.numpad);
  static const Key numpad2 = Key._(
      keyCode: 40,
      shiftKeyCode: 98,
      key: 'ArrowDown',
      code: 'Numpad2',
      shiftKey: '2',
      location: KeyLocation.numpad);
  static const Key numpad5 = Key._(
      keyCode: 12,
      shiftKeyCode: 101,
      key: 'Clear',
      code: 'Numpad5',
      shiftKey: '5',
      location: KeyLocation.numpad);
  static const Key digit0 =
      Key._(keyCode: 48, code: 'Digit0', shiftKey: ')', key: '0');
  static const Key digit1 =
      Key._(keyCode: 49, code: 'Digit1', shiftKey: '!', key: '1');
  static const Key digit2 =
      Key._(keyCode: 50, code: 'Digit2', shiftKey: '@', key: '2');
  static const Key digit3 =
      Key._(keyCode: 51, code: 'Digit3', shiftKey: '#', key: '3');
  static const Key digit4 =
      Key._(keyCode: 52, code: 'Digit4', shiftKey: r'$', key: '4');
  static const Key digit5 =
      Key._(keyCode: 53, code: 'Digit5', shiftKey: '%', key: '5');
  static const Key digit6 =
      Key._(keyCode: 54, code: 'Digit6', shiftKey: '^', key: '6');
  static const Key digit7 =
      Key._(keyCode: 55, code: 'Digit7', shiftKey: '&', key: '7');
  static const Key digit8 =
      Key._(keyCode: 56, code: 'Digit8', shiftKey: '*', key: '8');
  static const Key digit9 =
      Key._(keyCode: 57, code: 'Digit9', shiftKey: '\(', key: '9');
  static const Key keyA =
      Key._(keyCode: 65, code: 'KeyA', shiftKey: 'A', key: 'a');
  static const Key keyB =
      Key._(keyCode: 66, code: 'KeyB', shiftKey: 'B', key: 'b');
  static const Key keyC =
      Key._(keyCode: 67, code: 'KeyC', shiftKey: 'C', key: 'c');
  static const Key keyD =
      Key._(keyCode: 68, code: 'KeyD', shiftKey: 'D', key: 'd');
  static const Key keyE =
      Key._(keyCode: 69, code: 'KeyE', shiftKey: 'E', key: 'e');
  static const Key keyF =
      Key._(keyCode: 70, code: 'KeyF', shiftKey: 'F', key: 'f');
  static const Key keyG =
      Key._(keyCode: 71, code: 'KeyG', shiftKey: 'G', key: 'g');
  static const Key keyH =
      Key._(keyCode: 72, code: 'KeyH', shiftKey: 'H', key: 'h');
  static const Key keyI =
      Key._(keyCode: 73, code: 'KeyI', shiftKey: 'I', key: 'i');
  static const Key keyJ =
      Key._(keyCode: 74, code: 'KeyJ', shiftKey: 'J', key: 'j');
  static const Key keyK =
      Key._(keyCode: 75, code: 'KeyK', shiftKey: 'K', key: 'k');
  static const Key keyL =
      Key._(keyCode: 76, code: 'KeyL', shiftKey: 'L', key: 'l');
  static const Key keyM =
      Key._(keyCode: 77, code: 'KeyM', shiftKey: 'M', key: 'm');
  static const Key keyN =
      Key._(keyCode: 78, code: 'KeyN', shiftKey: 'N', key: 'n');
  static const Key keyO =
      Key._(keyCode: 79, code: 'KeyO', shiftKey: 'O', key: 'o');
  static const Key keyP =
      Key._(keyCode: 80, code: 'KeyP', shiftKey: 'P', key: 'p');
  static const Key keyQ =
      Key._(keyCode: 81, code: 'KeyQ', shiftKey: 'Q', key: 'q');
  static const Key keyR =
      Key._(keyCode: 82, code: 'KeyR', shiftKey: 'R', key: 'r');
  static const Key keyS =
      Key._(keyCode: 83, code: 'KeyS', shiftKey: 'S', key: 's');
  static const Key keyT =
      Key._(keyCode: 84, code: 'KeyT', shiftKey: 'T', key: 't');
  static const Key keyU =
      Key._(keyCode: 85, code: 'KeyU', shiftKey: 'U', key: 'u');
  static const Key keyV =
      Key._(keyCode: 86, code: 'KeyV', shiftKey: 'V', key: 'v');
  static const Key keyW =
      Key._(keyCode: 87, code: 'KeyW', shiftKey: 'W', key: 'w');
  static const Key keyX =
      Key._(keyCode: 88, code: 'KeyX', shiftKey: 'X', key: 'x');
  static const Key keyY =
      Key._(keyCode: 89, code: 'KeyY', shiftKey: 'Y', key: 'y');
  static const Key keyZ =
      Key._(keyCode: 90, code: 'KeyZ', shiftKey: 'Z', key: 'z');

  final int? keyCode, shiftKeyCode;
  final KeyLocation? location;
  final String? key, shiftKey, code, text;

  static final Map<String, Key> allKeys =
      CanonicalizedMap<String, String, Key>.from({
    'Power': power,
    'Eject': eject,
    'Abort': abort,
    'Help': help,
    'Backspace': backspace,
    'Tab': tab,
    'NumpadEnter': numpadEnter,
    'Enter': enter,
    'ShiftLeft': shiftLeft,
    'ShiftRight': shiftRight,
    'ControlLeft': controlLeft,
    'ControlRight': controlRight,
    'AltLeft': altLeft,
    'AltRight': altRight,
    'Pause': pause,
    'CapsLock': capsLock,
    'Escape': escape,
    'Convert': convert,
    'NonConvert': nonConvert,
    'Space': space,
    'PageUp': pageUp,
    'PageDown': pageDown,
    'End': end,
    'Home': home,
    'ArrowLeft': arrowLeft,
    'ArrowUp': arrowUp,
    'ArrowRight': arrowRight,
    'ArrowDown': arrowDown,
    'Select': select,
    'Open': open,
    'PrintScreen': printScreen,
    'Insert': insert,
    'Numpad0': numpad0,
    'Delete': delete,
    'NumpadDecimal': numpadDecimal,
    'MetaLeft': metaLeft,
    'MetaRight': metaRight,
    'ContextMenu': contextMenu,
    'NumpadMultiply': numpadMultiply,
    'NumpadAdd': numpadAdd,
    'NumpadSubtract': numpadSubtract,
    'NumpadDivide': numpadDivide,
    'F1': f1,
    'F2': f2,
    'F3': f3,
    'F4': f4,
    'F5': f5,
    'F6': f6,
    'F7': f7,
    'F8': f8,
    'F9': f9,
    'F10': f10,
    'F11': f11,
    'F12': f12,
    'F13': f13,
    'F14': f14,
    'F15': f15,
    'F16': f16,
    'F17': f17,
    'F18': f18,
    'F19': f19,
    'F20': f20,
    'F21': f21,
    'F22': f22,
    'F23': f23,
    'F24': f24,
    'NumLock': numLock,
    'ScrollLock': scrollLock,
    'AudioVolumeMute': audioVolumeMute,
    'AudioVolumeDown': audioVolumeDown,
    'AudioVolumeUp': audioVolumeUp,
    'MediaTrackNext': mediaTrackNext,
    'MediaTrackPrevious': mediaTrackPrevious,
    'MediaStop': mediaStop,
    'MediaPlayPause': mediaPlayPause,
    'Semicolon': semicolon,
    'Equal': equal,
    'NumpadEqual': numpadEqual,
    'Comma': comma,
    'Minus': minus,
    'Period': period,
    'Slash': slash,
    'Backquote': backquote,
    'BracketLeft': bracketLeft,
    'Backslash': backslash,
    'BracketRight': bracketRight,
    'Quote': quote,
    'AltGraph': altGraph,
    'Props': props,
    'Cancel': cancel,
    'Clear': clear,
    'Shift': shift,
    'Control': control,
    'Alt': alt,
    'Accept': accept,
    'ModeChange': modeChange,
    'Print': print,
    'Execute': execute,
    'Meta': meta,
    'Attn': attn,
    'CrSel': crSel,
    'ExSel': exSel,
    'EraseEof': eraseEof,
    'Play': play,
    'ZoomOut': zoomOut,
    'Numpad1': numpad1,
    'Numpad4': numpad4,
    'Numpad8': numpad8,
    'Numpad7': numpad7,
    'Numpad3': numpad3,
    'Numpad9': numpad9,
    'Numpad6': numpad6,
    'Numpad2': numpad2,
    'Numpad5': numpad5,
    'Digit0': digit0,
    'Digit1': digit1,
    'Digit2': digit2,
    'Digit3': digit3,
    'Digit4': digit4,
    'Digit5': digit5,
    'Digit6': digit6,
    'Digit7': digit7,
    'Digit8': digit8,
    'Digit9': digit9,
    'KeyA': keyA,
    'KeyB': keyB,
    'KeyC': keyC,
    'KeyD': keyD,
    'KeyE': keyE,
    'KeyF': keyF,
    'KeyG': keyG,
    'KeyH': keyH,
    'KeyI': keyI,
    'KeyJ': keyJ,
    'KeyK': keyK,
    'KeyL': keyL,
    'KeyM': keyM,
    'KeyN': keyN,
    'KeyO': keyO,
    'KeyP': keyP,
    'KeyQ': keyQ,
    'KeyR': keyR,
    'KeyS': keyS,
    'KeyT': keyT,
    'KeyU': keyU,
    'KeyV': keyV,
    'KeyW': keyW,
    'KeyX': keyX,
    'KeyY': keyY,
    'KeyZ': keyZ,
  }, (key) => key.toLowerCase().replaceAll(' ', ''));

  const Key._({
    this.keyCode,
    required this.key,
    this.shiftKey,
    this.shiftKeyCode,
    this.code,
    this.location,
    this.text,
  });

  @override
  String toString() => 'Key(keyCode: $keyCode, key: $key, shiftKey: $shiftKey, '
      'shiftKeyCode: $shiftKeyCode, code: $code, location: $location, text: $text)';
}

final _characters = const {
  '0': Key._(keyCode: 48, key: '0', code: 'Digit0', text: '0'),
  '1': Key._(keyCode: 49, key: '1', code: 'Digit1', text: '1'),
  '2': Key._(keyCode: 50, key: '2', code: 'Digit2', text: '2'),
  '3': Key._(keyCode: 51, key: '3', code: 'Digit3', text: '3'),
  '4': Key._(keyCode: 52, key: '4', code: 'Digit4', text: '4'),
  '5': Key._(keyCode: 53, key: '5', code: 'Digit5', text: '5'),
  '6': Key._(keyCode: 54, key: '6', code: 'Digit6', text: '6'),
  '7': Key._(keyCode: 55, key: '7', code: 'Digit7', text: '7'),
  '8': Key._(keyCode: 56, key: '8', code: 'Digit8', text: '8'),
  '9': Key._(keyCode: 57, key: '9', code: 'Digit9', text: '9'),
  '\r': Key._(keyCode: 13, key: 'Enter', code: 'Enter', text: '\r'),
  '\n': Key._(keyCode: 13, key: 'Enter', code: 'Enter', text: '\r'),
  ' ': Key._(keyCode: 32, key: ' ', code: 'Space', text: ' '),
  '\u0000': Key._(
      keyCode: 46,
      key: '\u0000',
      code: 'NumpadDecimal',
      text: '\u0000',
      location: KeyLocation.numpad),
  'a': Key._(keyCode: 65, key: 'a', code: 'KeyA', text: 'a'),
  'b': Key._(keyCode: 66, key: 'b', code: 'KeyB', text: 'b'),
  'c': Key._(keyCode: 67, key: 'c', code: 'KeyC', text: 'c'),
  'd': Key._(keyCode: 68, key: 'd', code: 'KeyD', text: 'd'),
  'e': Key._(keyCode: 69, key: 'e', code: 'KeyE', text: 'e'),
  'f': Key._(keyCode: 70, key: 'f', code: 'KeyF', text: 'f'),
  'g': Key._(keyCode: 71, key: 'g', code: 'KeyG', text: 'g'),
  'h': Key._(keyCode: 72, key: 'h', code: 'KeyH', text: 'h'),
  'i': Key._(keyCode: 73, key: 'i', code: 'KeyI', text: 'i'),
  'j': Key._(keyCode: 74, key: 'j', code: 'KeyJ', text: 'j'),
  'k': Key._(keyCode: 75, key: 'k', code: 'KeyK', text: 'k'),
  'l': Key._(keyCode: 76, key: 'l', code: 'KeyL', text: 'l'),
  'm': Key._(keyCode: 77, key: 'm', code: 'KeyM', text: 'm'),
  'n': Key._(keyCode: 78, key: 'n', code: 'KeyN', text: 'n'),
  'o': Key._(keyCode: 79, key: 'o', code: 'KeyO', text: 'o'),
  'p': Key._(keyCode: 80, key: 'p', code: 'KeyP', text: 'p'),
  'q': Key._(keyCode: 81, key: 'q', code: 'KeyQ', text: 'q'),
  'r': Key._(keyCode: 82, key: 'r', code: 'KeyR', text: 'r'),
  's': Key._(keyCode: 83, key: 's', code: 'KeyS', text: 's'),
  't': Key._(keyCode: 84, key: 't', code: 'KeyT', text: 't'),
  'u': Key._(keyCode: 85, key: 'u', code: 'KeyU', text: 'u'),
  'v': Key._(keyCode: 86, key: 'v', code: 'KeyV', text: 'v'),
  'w': Key._(keyCode: 87, key: 'w', code: 'KeyW', text: 'w'),
  'x': Key._(keyCode: 88, key: 'x', code: 'KeyX', text: 'x'),
  'y': Key._(keyCode: 89, key: 'y', code: 'KeyY', text: 'y'),
  'z': Key._(keyCode: 90, key: 'z', code: 'KeyZ', text: 'z'),
  '*': Key._(
      keyCode: 106,
      key: '*',
      code: 'NumpadMultiply',
      text: '*',
      location: KeyLocation.numpad),
  '+': Key._(
      keyCode: 107,
      key: '+',
      code: 'NumpadAdd',
      text: '+',
      location: KeyLocation.numpad),
  '-': Key._(
      keyCode: 109,
      key: '-',
      code: 'NumpadSubtract',
      text: '-',
      location: KeyLocation.numpad),
  '/': Key._(
      keyCode: 111,
      key: '/',
      code: 'NumpadDivide',
      text: '/',
      location: KeyLocation.numpad),
  ';': Key._(keyCode: 186, key: ';', code: 'Semicolon', text: ';'),
  '=': Key._(keyCode: 187, key: '=', code: 'Equal', text: '='),
  ',': Key._(keyCode: 188, key: ',', code: 'Comma', text: ','),
  '.': Key._(keyCode: 190, key: '.', code: 'Period', text: '.'),
  '`': Key._(keyCode: 192, key: '`', code: 'Backquote', text: '`'),
  '[': Key._(keyCode: 219, key: '[', code: 'BracketLeft', text: '['),
  r'\': Key._(keyCode: 220, key: r'\', code: 'Backslash', text: r'\'),
  ']': Key._(keyCode: 221, key: ']', code: 'BracketRight', text: ']'),
  '\'': Key._(keyCode: 222, key: '\'', code: 'Quote', text: '\''),
  ')': Key._(keyCode: 48, key: ')', code: 'Digit0', text: ')'),
  '!': Key._(keyCode: 49, key: '!', code: 'Digit1', text: '!'),
  '@': Key._(keyCode: 50, key: '@', code: 'Digit2', text: '@'),
  '#': Key._(keyCode: 51, key: '#', code: 'Digit3', text: '#'),
  r'$': Key._(keyCode: 52, key: r'$', code: 'Digit4', text: r'$'),
  '%': Key._(keyCode: 53, key: '%', code: 'Digit5', text: '%'),
  '^': Key._(keyCode: 54, key: '^', code: 'Digit6', text: '^'),
  '&': Key._(keyCode: 55, key: '&', code: 'Digit7', text: '&'),
  '(': Key._(keyCode: 57, key: '(', code: 'Digit9', text: '('),
  'A': Key._(keyCode: 65, key: 'A', code: 'KeyA', text: 'A'),
  'B': Key._(keyCode: 66, key: 'B', code: 'KeyB', text: 'B'),
  'C': Key._(keyCode: 67, key: 'C', code: 'KeyC', text: 'C'),
  'D': Key._(keyCode: 68, key: 'D', code: 'KeyD', text: 'D'),
  'E': Key._(keyCode: 69, key: 'E', code: 'KeyE', text: 'E'),
  'F': Key._(keyCode: 70, key: 'F', code: 'KeyF', text: 'F'),
  'G': Key._(keyCode: 71, key: 'G', code: 'KeyG', text: 'G'),
  'H': Key._(keyCode: 72, key: 'H', code: 'KeyH', text: 'H'),
  'I': Key._(keyCode: 73, key: 'I', code: 'KeyI', text: 'I'),
  'J': Key._(keyCode: 74, key: 'J', code: 'KeyJ', text: 'J'),
  'K': Key._(keyCode: 75, key: 'K', code: 'KeyK', text: 'K'),
  'L': Key._(keyCode: 76, key: 'L', code: 'KeyL', text: 'L'),
  'M': Key._(keyCode: 77, key: 'M', code: 'KeyM', text: 'M'),
  'N': Key._(keyCode: 78, key: 'N', code: 'KeyN', text: 'N'),
  'O': Key._(keyCode: 79, key: 'O', code: 'KeyO', text: 'O'),
  'P': Key._(keyCode: 80, key: 'P', code: 'KeyP', text: 'P'),
  'Q': Key._(keyCode: 81, key: 'Q', code: 'KeyQ', text: 'Q'),
  'R': Key._(keyCode: 82, key: 'R', code: 'KeyR', text: 'R'),
  'S': Key._(keyCode: 83, key: 'S', code: 'KeyS', text: 'S'),
  'T': Key._(keyCode: 84, key: 'T', code: 'KeyT', text: 'T'),
  'U': Key._(keyCode: 85, key: 'U', code: 'KeyU', text: 'U'),
  'V': Key._(keyCode: 86, key: 'V', code: 'KeyV', text: 'V'),
  'W': Key._(keyCode: 87, key: 'W', code: 'KeyW', text: 'W'),
  'X': Key._(keyCode: 88, key: 'X', code: 'KeyX', text: 'X'),
  'Y': Key._(keyCode: 89, key: 'Y', code: 'KeyY', text: 'Y'),
  'Z': Key._(keyCode: 90, key: 'Z', code: 'KeyZ', text: 'Z'),
  ':': Key._(keyCode: 186, key: ':', code: 'Semicolon', text: ':'),
  '<': Key._(keyCode: 188, key: '<', code: 'Comma', text: '<'),
  '_': Key._(keyCode: 189, key: '_', code: 'Minus', text: '_'),
  '>': Key._(keyCode: 190, key: '>', code: 'Period', text: '>'),
  '?': Key._(keyCode: 191, key: '?', code: 'Slash', text: '?'),
  '~': Key._(keyCode: 192, key: '~', code: 'Backquote', text: '~'),
  '{': Key._(keyCode: 219, key: '{', code: 'BracketLeft', text: '{'),
  '|': Key._(keyCode: 220, key: '|', code: 'Backslash', text: '|'),
  '}': Key._(keyCode: 221, key: '}', code: 'BracketRight', text: '}'),
  '"': Key._(keyCode: 222, key: '"', code: 'Quote', text: '"'),
};

enum KeyLocation {
  /// The event key is not distinguished as the left or right version
  /// of the key, and did not originate from the numeric keypad (or did not
  /// originate with a virtual key corresponding to the numeric keypad).
  standard,

  /// The event key is in the left key location.
  left,

  /// The event key is in the right key location.
  right,

  /// The event key originated on the numeric keypad or with a virtual key
  /// corresponding to the numeric keypad.
  numpad,

  /// The event key originated on a mobile device, either on a physical
  /// keypad or a virtual keyboard.
  mobile,

  /// The event key originated on a game controller or a joystick on a mobile
  /// device.
  joystick
}
