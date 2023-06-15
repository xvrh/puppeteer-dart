import 'dart:async';
import '../src/connection.dart';

class InputApi {
  final Client _client;

  InputApi(this._client);

  /// Emitted only when `Input.setInterceptDrags` is enabled. Use this data with `Input.dispatchDragEvent` to
  /// restore normal drag and drop behavior.
  Stream<DragData> get onDragIntercepted => _client.onEvent
      .where((event) => event.name == 'Input.dragIntercepted')
      .map((event) =>
          DragData.fromJson(event.parameters['data'] as Map<String, dynamic>));

  /// Dispatches a drag event into the page.
  /// [type] Type of the drag event.
  /// [x] X coordinate of the event relative to the main frame's viewport in CSS pixels.
  /// [y] Y coordinate of the event relative to the main frame's viewport in CSS pixels. 0 refers to
  /// the top of the viewport and Y increases as it proceeds towards the bottom of the viewport.
  /// [modifiers] Bit field representing pressed modifier keys. Alt=1, Ctrl=2, Meta/Command=4, Shift=8
  /// (default: 0).
  Future<void> dispatchDragEvent(
      @Enum(['dragEnter', 'dragOver', 'drop', 'dragCancel']) String type,
      num x,
      num y,
      DragData data,
      {int? modifiers}) async {
    assert(
        const ['dragEnter', 'dragOver', 'drop', 'dragCancel'].contains(type));
    await _client.send('Input.dispatchDragEvent', {
      'type': type,
      'x': x,
      'y': y,
      'data': data,
      if (modifiers != null) 'modifiers': modifiers,
    });
  }

  /// Dispatches a key event to the page.
  /// [type] Type of the key event.
  /// [modifiers] Bit field representing pressed modifier keys. Alt=1, Ctrl=2, Meta/Command=4, Shift=8
  /// (default: 0).
  /// [timestamp] Time at which the event occurred.
  /// [text] Text as generated by processing a virtual key code with a keyboard layout. Not needed for
  /// for `keyUp` and `rawKeyDown` events (default: "")
  /// [unmodifiedText] Text that would have been generated by the keyboard if no modifiers were pressed (except for
  /// shift). Useful for shortcut (accelerator) key handling (default: "").
  /// [keyIdentifier] Unique key identifier (e.g., 'U+0041') (default: "").
  /// [code] Unique DOM defined string value for each physical key (e.g., 'KeyA') (default: "").
  /// [key] Unique DOM defined string value describing the meaning of the key in the context of active
  /// modifiers, keyboard layout, etc (e.g., 'AltGr') (default: "").
  /// [windowsVirtualKeyCode] Windows virtual key code (default: 0).
  /// [nativeVirtualKeyCode] Native virtual key code (default: 0).
  /// [autoRepeat] Whether the event was generated from auto repeat (default: false).
  /// [isKeypad] Whether the event was generated from the keypad (default: false).
  /// [isSystemKey] Whether the event was a system key event (default: false).
  /// [location] Whether the event was from the left or right side of the keyboard. 1=Left, 2=Right (default:
  /// 0).
  /// [commands] Editing commands to send with the key event (e.g., 'selectAll') (default: []).
  /// These are related to but not equal the command names used in `document.execCommand` and NSStandardKeyBindingResponding.
  /// See https://source.chromium.org/chromium/chromium/src/+/main:third_party/blink/renderer/core/editing/commands/editor_command_names.h for valid command names.
  Future<void> dispatchKeyEvent(
      @Enum(['keyDown', 'keyUp', 'rawKeyDown', 'char']) String type,
      {int? modifiers,
      TimeSinceEpoch? timestamp,
      String? text,
      String? unmodifiedText,
      String? keyIdentifier,
      String? code,
      String? key,
      int? windowsVirtualKeyCode,
      int? nativeVirtualKeyCode,
      bool? autoRepeat,
      bool? isKeypad,
      bool? isSystemKey,
      int? location,
      List<String>? commands}) async {
    assert(const ['keyDown', 'keyUp', 'rawKeyDown', 'char'].contains(type));
    await _client.send('Input.dispatchKeyEvent', {
      'type': type,
      if (modifiers != null) 'modifiers': modifiers,
      if (timestamp != null) 'timestamp': timestamp,
      if (text != null) 'text': text,
      if (unmodifiedText != null) 'unmodifiedText': unmodifiedText,
      if (keyIdentifier != null) 'keyIdentifier': keyIdentifier,
      if (code != null) 'code': code,
      if (key != null) 'key': key,
      if (windowsVirtualKeyCode != null)
        'windowsVirtualKeyCode': windowsVirtualKeyCode,
      if (nativeVirtualKeyCode != null)
        'nativeVirtualKeyCode': nativeVirtualKeyCode,
      if (autoRepeat != null) 'autoRepeat': autoRepeat,
      if (isKeypad != null) 'isKeypad': isKeypad,
      if (isSystemKey != null) 'isSystemKey': isSystemKey,
      if (location != null) 'location': location,
      if (commands != null) 'commands': [...commands],
    });
  }

  /// This method emulates inserting text that doesn't come from a key press,
  /// for example an emoji keyboard or an IME.
  /// [text] The text to insert.
  Future<void> insertText(String text) async {
    await _client.send('Input.insertText', {
      'text': text,
    });
  }

  /// This method sets the current candidate text for ime.
  /// Use imeCommitComposition to commit the final text.
  /// Use imeSetComposition with empty string as text to cancel composition.
  /// [text] The text to insert
  /// [selectionStart] selection start
  /// [selectionEnd] selection end
  /// [replacementStart] replacement start
  /// [replacementEnd] replacement end
  Future<void> imeSetComposition(
      String text, int selectionStart, int selectionEnd,
      {int? replacementStart, int? replacementEnd}) async {
    await _client.send('Input.imeSetComposition', {
      'text': text,
      'selectionStart': selectionStart,
      'selectionEnd': selectionEnd,
      if (replacementStart != null) 'replacementStart': replacementStart,
      if (replacementEnd != null) 'replacementEnd': replacementEnd,
    });
  }

  /// Dispatches a mouse event to the page.
  /// [type] Type of the mouse event.
  /// [x] X coordinate of the event relative to the main frame's viewport in CSS pixels.
  /// [y] Y coordinate of the event relative to the main frame's viewport in CSS pixels. 0 refers to
  /// the top of the viewport and Y increases as it proceeds towards the bottom of the viewport.
  /// [modifiers] Bit field representing pressed modifier keys. Alt=1, Ctrl=2, Meta/Command=4, Shift=8
  /// (default: 0).
  /// [timestamp] Time at which the event occurred.
  /// [button] Mouse button (default: "none").
  /// [buttons] A number indicating which buttons are pressed on the mouse when a mouse event is triggered.
  /// Left=1, Right=2, Middle=4, Back=8, Forward=16, None=0.
  /// [clickCount] Number of times the mouse button was clicked (default: 0).
  /// [force] The normalized pressure, which has a range of [0,1] (default: 0).
  /// [tangentialPressure] The normalized tangential pressure, which has a range of [-1,1] (default: 0).
  /// [tiltX] The plane angle between the Y-Z plane and the plane containing both the stylus axis and the Y axis, in degrees of the range [-90,90], a positive tiltX is to the right (default: 0).
  /// [tiltY] The plane angle between the X-Z plane and the plane containing both the stylus axis and the X axis, in degrees of the range [-90,90], a positive tiltY is towards the user (default: 0).
  /// [twist] The clockwise rotation of a pen stylus around its own major axis, in degrees in the range [0,359] (default: 0).
  /// [deltaX] X delta in CSS pixels for mouse wheel event (default: 0).
  /// [deltaY] Y delta in CSS pixels for mouse wheel event (default: 0).
  /// [pointerType] Pointer type (default: "mouse").
  Future<void> dispatchMouseEvent(
      @Enum(['mousePressed', 'mouseReleased', 'mouseMoved', 'mouseWheel'])
      String type,
      num x,
      num y,
      {int? modifiers,
      TimeSinceEpoch? timestamp,
      MouseButton? button,
      int? buttons,
      int? clickCount,
      num? force,
      num? tangentialPressure,
      int? tiltX,
      int? tiltY,
      int? twist,
      num? deltaX,
      num? deltaY,
      @Enum(['mouse', 'pen']) String? pointerType}) async {
    assert(const ['mousePressed', 'mouseReleased', 'mouseMoved', 'mouseWheel']
        .contains(type));
    assert(pointerType == null || const ['mouse', 'pen'].contains(pointerType));
    await _client.send('Input.dispatchMouseEvent', {
      'type': type,
      'x': x,
      'y': y,
      if (modifiers != null) 'modifiers': modifiers,
      if (timestamp != null) 'timestamp': timestamp,
      if (button != null) 'button': button,
      if (buttons != null) 'buttons': buttons,
      if (clickCount != null) 'clickCount': clickCount,
      if (force != null) 'force': force,
      if (tangentialPressure != null) 'tangentialPressure': tangentialPressure,
      if (tiltX != null) 'tiltX': tiltX,
      if (tiltY != null) 'tiltY': tiltY,
      if (twist != null) 'twist': twist,
      if (deltaX != null) 'deltaX': deltaX,
      if (deltaY != null) 'deltaY': deltaY,
      if (pointerType != null) 'pointerType': pointerType,
    });
  }

  /// Dispatches a touch event to the page.
  /// [type] Type of the touch event. TouchEnd and TouchCancel must not contain any touch points, while
  /// TouchStart and TouchMove must contains at least one.
  /// [touchPoints] Active touch points on the touch device. One event per any changed point (compared to
  /// previous touch event in a sequence) is generated, emulating pressing/moving/releasing points
  /// one by one.
  /// [modifiers] Bit field representing pressed modifier keys. Alt=1, Ctrl=2, Meta/Command=4, Shift=8
  /// (default: 0).
  /// [timestamp] Time at which the event occurred.
  Future<void> dispatchTouchEvent(
      @Enum(['touchStart', 'touchEnd', 'touchMove', 'touchCancel']) String type,
      List<TouchPoint> touchPoints,
      {int? modifiers,
      TimeSinceEpoch? timestamp}) async {
    assert(const ['touchStart', 'touchEnd', 'touchMove', 'touchCancel']
        .contains(type));
    await _client.send('Input.dispatchTouchEvent', {
      'type': type,
      'touchPoints': [...touchPoints],
      if (modifiers != null) 'modifiers': modifiers,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  /// Emulates touch event from the mouse event parameters.
  /// [type] Type of the mouse event.
  /// [x] X coordinate of the mouse pointer in DIP.
  /// [y] Y coordinate of the mouse pointer in DIP.
  /// [button] Mouse button. Only "none", "left", "right" are supported.
  /// [timestamp] Time at which the event occurred (default: current time).
  /// [deltaX] X delta in DIP for mouse wheel event (default: 0).
  /// [deltaY] Y delta in DIP for mouse wheel event (default: 0).
  /// [modifiers] Bit field representing pressed modifier keys. Alt=1, Ctrl=2, Meta/Command=4, Shift=8
  /// (default: 0).
  /// [clickCount] Number of times the mouse button was clicked (default: 0).
  Future<void> emulateTouchFromMouseEvent(
      @Enum(['mousePressed', 'mouseReleased', 'mouseMoved', 'mouseWheel'])
      String type,
      int x,
      int y,
      MouseButton button,
      {TimeSinceEpoch? timestamp,
      num? deltaX,
      num? deltaY,
      int? modifiers,
      int? clickCount}) async {
    assert(const ['mousePressed', 'mouseReleased', 'mouseMoved', 'mouseWheel']
        .contains(type));
    await _client.send('Input.emulateTouchFromMouseEvent', {
      'type': type,
      'x': x,
      'y': y,
      'button': button,
      if (timestamp != null) 'timestamp': timestamp,
      if (deltaX != null) 'deltaX': deltaX,
      if (deltaY != null) 'deltaY': deltaY,
      if (modifiers != null) 'modifiers': modifiers,
      if (clickCount != null) 'clickCount': clickCount,
    });
  }

  /// Ignores input events (useful while auditing page).
  /// [ignore] Ignores input events processing when set to true.
  Future<void> setIgnoreInputEvents(bool ignore) async {
    await _client.send('Input.setIgnoreInputEvents', {
      'ignore': ignore,
    });
  }

  /// Prevents default drag and drop behavior and instead emits `Input.dragIntercepted` events.
  /// Drag and drop behavior can be directly controlled via `Input.dispatchDragEvent`.
  Future<void> setInterceptDrags(bool enabled) async {
    await _client.send('Input.setInterceptDrags', {
      'enabled': enabled,
    });
  }

  /// Synthesizes a pinch gesture over a time period by issuing appropriate touch events.
  /// [x] X coordinate of the start of the gesture in CSS pixels.
  /// [y] Y coordinate of the start of the gesture in CSS pixels.
  /// [scaleFactor] Relative scale factor after zooming (>1.0 zooms in, <1.0 zooms out).
  /// [relativeSpeed] Relative pointer speed in pixels per second (default: 800).
  /// [gestureSourceType] Which type of input events to be generated (default: 'default', which queries the platform
  /// for the preferred input type).
  Future<void> synthesizePinchGesture(num x, num y, num scaleFactor,
      {int? relativeSpeed, GestureSourceType? gestureSourceType}) async {
    await _client.send('Input.synthesizePinchGesture', {
      'x': x,
      'y': y,
      'scaleFactor': scaleFactor,
      if (relativeSpeed != null) 'relativeSpeed': relativeSpeed,
      if (gestureSourceType != null) 'gestureSourceType': gestureSourceType,
    });
  }

  /// Synthesizes a scroll gesture over a time period by issuing appropriate touch events.
  /// [x] X coordinate of the start of the gesture in CSS pixels.
  /// [y] Y coordinate of the start of the gesture in CSS pixels.
  /// [xDistance] The distance to scroll along the X axis (positive to scroll left).
  /// [yDistance] The distance to scroll along the Y axis (positive to scroll up).
  /// [xOverscroll] The number of additional pixels to scroll back along the X axis, in addition to the given
  /// distance.
  /// [yOverscroll] The number of additional pixels to scroll back along the Y axis, in addition to the given
  /// distance.
  /// [preventFling] Prevent fling (default: true).
  /// [speed] Swipe speed in pixels per second (default: 800).
  /// [gestureSourceType] Which type of input events to be generated (default: 'default', which queries the platform
  /// for the preferred input type).
  /// [repeatCount] The number of times to repeat the gesture (default: 0).
  /// [repeatDelayMs] The number of milliseconds delay between each repeat. (default: 250).
  /// [interactionMarkerName] The name of the interaction markers to generate, if not empty (default: "").
  Future<void> synthesizeScrollGesture(num x, num y,
      {num? xDistance,
      num? yDistance,
      num? xOverscroll,
      num? yOverscroll,
      bool? preventFling,
      int? speed,
      GestureSourceType? gestureSourceType,
      int? repeatCount,
      int? repeatDelayMs,
      String? interactionMarkerName}) async {
    await _client.send('Input.synthesizeScrollGesture', {
      'x': x,
      'y': y,
      if (xDistance != null) 'xDistance': xDistance,
      if (yDistance != null) 'yDistance': yDistance,
      if (xOverscroll != null) 'xOverscroll': xOverscroll,
      if (yOverscroll != null) 'yOverscroll': yOverscroll,
      if (preventFling != null) 'preventFling': preventFling,
      if (speed != null) 'speed': speed,
      if (gestureSourceType != null) 'gestureSourceType': gestureSourceType,
      if (repeatCount != null) 'repeatCount': repeatCount,
      if (repeatDelayMs != null) 'repeatDelayMs': repeatDelayMs,
      if (interactionMarkerName != null)
        'interactionMarkerName': interactionMarkerName,
    });
  }

  /// Synthesizes a tap gesture over a time period by issuing appropriate touch events.
  /// [x] X coordinate of the start of the gesture in CSS pixels.
  /// [y] Y coordinate of the start of the gesture in CSS pixels.
  /// [duration] Duration between touchdown and touchup events in ms (default: 50).
  /// [tapCount] Number of times to perform the tap (e.g. 2 for double tap, default: 1).
  /// [gestureSourceType] Which type of input events to be generated (default: 'default', which queries the platform
  /// for the preferred input type).
  Future<void> synthesizeTapGesture(num x, num y,
      {int? duration,
      int? tapCount,
      GestureSourceType? gestureSourceType}) async {
    await _client.send('Input.synthesizeTapGesture', {
      'x': x,
      'y': y,
      if (duration != null) 'duration': duration,
      if (tapCount != null) 'tapCount': tapCount,
      if (gestureSourceType != null) 'gestureSourceType': gestureSourceType,
    });
  }
}

class TouchPoint {
  /// X coordinate of the event relative to the main frame's viewport in CSS pixels.
  final num x;

  /// Y coordinate of the event relative to the main frame's viewport in CSS pixels. 0 refers to
  /// the top of the viewport and Y increases as it proceeds towards the bottom of the viewport.
  final num y;

  /// X radius of the touch area (default: 1.0).
  final num? radiusX;

  /// Y radius of the touch area (default: 1.0).
  final num? radiusY;

  /// Rotation angle (default: 0.0).
  final num? rotationAngle;

  /// Force (default: 1.0).
  final num? force;

  /// The normalized tangential pressure, which has a range of [-1,1] (default: 0).
  final num? tangentialPressure;

  /// The plane angle between the Y-Z plane and the plane containing both the stylus axis and the Y axis, in degrees of the range [-90,90], a positive tiltX is to the right (default: 0)
  final int? tiltX;

  /// The plane angle between the X-Z plane and the plane containing both the stylus axis and the X axis, in degrees of the range [-90,90], a positive tiltY is towards the user (default: 0).
  final int? tiltY;

  /// The clockwise rotation of a pen stylus around its own major axis, in degrees in the range [0,359] (default: 0).
  final int? twist;

  /// Identifier used to track touch sources between events, must be unique within an event.
  final num? id;

  TouchPoint(
      {required this.x,
      required this.y,
      this.radiusX,
      this.radiusY,
      this.rotationAngle,
      this.force,
      this.tangentialPressure,
      this.tiltX,
      this.tiltY,
      this.twist,
      this.id});

  factory TouchPoint.fromJson(Map<String, dynamic> json) {
    return TouchPoint(
      x: json['x'] as num,
      y: json['y'] as num,
      radiusX: json.containsKey('radiusX') ? json['radiusX'] as num : null,
      radiusY: json.containsKey('radiusY') ? json['radiusY'] as num : null,
      rotationAngle: json.containsKey('rotationAngle')
          ? json['rotationAngle'] as num
          : null,
      force: json.containsKey('force') ? json['force'] as num : null,
      tangentialPressure: json.containsKey('tangentialPressure')
          ? json['tangentialPressure'] as num
          : null,
      tiltX: json.containsKey('tiltX') ? json['tiltX'] as int : null,
      tiltY: json.containsKey('tiltY') ? json['tiltY'] as int : null,
      twist: json.containsKey('twist') ? json['twist'] as int : null,
      id: json.containsKey('id') ? json['id'] as num : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      if (radiusX != null) 'radiusX': radiusX,
      if (radiusY != null) 'radiusY': radiusY,
      if (rotationAngle != null) 'rotationAngle': rotationAngle,
      if (force != null) 'force': force,
      if (tangentialPressure != null) 'tangentialPressure': tangentialPressure,
      if (tiltX != null) 'tiltX': tiltX,
      if (tiltY != null) 'tiltY': tiltY,
      if (twist != null) 'twist': twist,
      if (id != null) 'id': id,
    };
  }
}

enum GestureSourceType {
  default$('default'),
  touch('touch'),
  mouse('mouse'),
  ;

  final String value;

  const GestureSourceType(this.value);

  factory GestureSourceType.fromJson(String value) =>
      GestureSourceType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum MouseButton {
  none('none'),
  left('left'),
  middle('middle'),
  right('right'),
  back('back'),
  forward('forward'),
  ;

  final String value;

  const MouseButton(this.value);

  factory MouseButton.fromJson(String value) =>
      MouseButton.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// UTC time in seconds, counted from January 1, 1970.
class TimeSinceEpoch {
  final num value;

  TimeSinceEpoch(this.value);

  factory TimeSinceEpoch.fromJson(num value) => TimeSinceEpoch(value);

  num toJson() => value;

  @override
  bool operator ==(other) =>
      (other is TimeSinceEpoch && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class DragDataItem {
  /// Mime type of the dragged data.
  final String mimeType;

  /// Depending of the value of `mimeType`, it contains the dragged link,
  /// text, HTML markup or any other data.
  final String data;

  /// Title associated with a link. Only valid when `mimeType` == "text/uri-list".
  final String? title;

  /// Stores the base URL for the contained markup. Only valid when `mimeType`
  /// == "text/html".
  final String? baseURL;

  DragDataItem(
      {required this.mimeType, required this.data, this.title, this.baseURL});

  factory DragDataItem.fromJson(Map<String, dynamic> json) {
    return DragDataItem(
      mimeType: json['mimeType'] as String,
      data: json['data'] as String,
      title: json.containsKey('title') ? json['title'] as String : null,
      baseURL: json.containsKey('baseURL') ? json['baseURL'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mimeType': mimeType,
      'data': data,
      if (title != null) 'title': title,
      if (baseURL != null) 'baseURL': baseURL,
    };
  }
}

class DragData {
  final List<DragDataItem> items;

  /// List of filenames that should be included when dropping
  final List<String>? files;

  /// Bit field representing allowed drag operations. Copy = 1, Link = 2, Move = 16
  final int dragOperationsMask;

  DragData({required this.items, this.files, required this.dragOperationsMask});

  factory DragData.fromJson(Map<String, dynamic> json) {
    return DragData(
      items: (json['items'] as List)
          .map((e) => DragDataItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      files: json.containsKey('files')
          ? (json['files'] as List).map((e) => e as String).toList()
          : null,
      dragOperationsMask: json['dragOperationsMask'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'dragOperationsMask': dragOperationsMask,
      if (files != null) 'files': [...?files],
    };
  }
}
