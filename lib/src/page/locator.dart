import 'dart:async';
import '../../protocol/input.dart';
import 'execution_context.dart';
import 'frame_manager.dart';
import 'js_handle.dart';
import 'page.dart';

/// The delay between two consecutive retries of a locator action or condition.
///
/// For pipelines coming from futures, a delay is needed, otherwise the retry
/// loop would busy-spin in a permanent failure case.
const _retryDelay = Duration(milliseconds: 100);

/// Whether to wait for the element to be [visible] or [hidden]. `null` disables
/// the visibility check.
enum LocatorVisibility { visible, hidden }

/// Thrown when a locator action is aborted through its `signal`.
class LocatorAbortedException implements Exception {
  @override
  String toString() => 'Locator action was aborted';
}

/// Locators describe a strategy of locating objects and performing an action on
/// them. If the action fails because the object is not ready for the action,
/// the whole operation is retried. Various preconditions for a successful
/// action are checked automatically.
///
/// Locators are created with [Page.locator] or [Frame.locator].
///
/// ```dart
/// await page.locator('button').click();
/// ```
abstract class Locator {
  Duration _timeout;
  LocatorVisibility? visibility;
  bool waitForEnabled = true;
  bool ensureElementIsInTheViewport = true;
  bool waitForStableBoundingBox = true;

  final _actionListeners = <void Function()>[];

  Locator(this._timeout);

  /// Determines when the locator will time out for actions.
  Duration get timeout => _timeout;

  /// Creates a race between multiple locators trying to locate elements in
  /// parallel but ensures that only a single element receives the action.
  static Locator race(List<Locator> locators) => RaceLocator(locators.toList());

  /// Internal: clones the locator (without action listeners).
  Locator _clone();

  /// Internal: resolves a handle for the located object, applying the
  /// per-locator preconditions (e.g. visibility).
  Future<JsHandle> _wait(Future<void>? signal);

  /// Clones the locator.
  Locator clone() => _clone();

  /// Creates a new locator instance by cloning the current locator and setting
  /// the total timeout for the locator actions.
  ///
  /// Pass [Duration.zero] to disable the timeout.
  Locator setTimeout(Duration timeout) {
    var locator = _clone();
    locator._timeout = timeout;
    return locator;
  }

  /// Creates a new locator instance by cloning the current locator with the
  /// visibility property changed to the specified value.
  Locator setVisibility(LocatorVisibility? visibility) {
    var locator = _clone();
    locator.visibility = visibility;
    return locator;
  }

  /// Creates a new locator instance by cloning the current locator and
  /// specifying whether to wait for input elements to become enabled before the
  /// action. Applicable to `click` and `fill` actions.
  Locator setWaitForEnabled(bool value) {
    var locator = _clone();
    locator.waitForEnabled = value;
    return locator;
  }

  /// Creates a new locator instance by cloning the current locator and
  /// specifying whether the locator should scroll the element into the viewport
  /// if it is not in the viewport already.
  Locator setEnsureElementIsInTheViewport(bool value) {
    var locator = _clone();
    locator.ensureElementIsInTheViewport = value;
    return locator;
  }

  /// Creates a new locator instance by cloning the current locator and
  /// specifying whether the locator has to wait for the element's bounding box
  /// to be the same between two consecutive animation frames.
  Locator setWaitForStableBoundingBox(bool value) {
    var locator = _clone();
    locator.waitForStableBoundingBox = value;
    return locator;
  }

  /// Internal: copies the options (but not the listeners) of [other] onto this.
  Locator copyOptions(Locator other) {
    _timeout = other._timeout;
    visibility = other.visibility;
    waitForEnabled = other.waitForEnabled;
    ensureElementIsInTheViewport = other.ensureElementIsInTheViewport;
    waitForStableBoundingBox = other.waitForStableBoundingBox;
    return this;
  }

  /// Registers a callback that is invoked every time before the locator
  /// performs an action on the located element. Returns the same locator to
  /// allow chaining, e.g. `locator.onAction(() {...}).click()`.
  ///
  /// > **NOTE** Listeners are not carried over when the locator is cloned, so
  /// call this last in a chain (after any `set*` calls).
  Locator onAction(void Function() callback) {
    _actionListeners.add(callback);
    return this;
  }

  void _emitAction() {
    for (var listener in [..._actionListeners]) {
      listener();
    }
  }

  /// Maps the located handle using the provided JavaScript [pageFunction].
  Locator map(@Language('js') String pageFunction) {
    return MappedLocator(_clone(), (handle) {
      return handle.evaluateHandle(pageFunction);
    });
  }

  /// Creates an expectation that is evaluated against the located handle using
  /// the provided JavaScript [predicate].
  ///
  /// If the expectation does not match, then the locator will retry.
  Locator filter(@Language('js') String predicate) {
    return FilteredLocator(_clone(), predicate);
  }

  /// Clicks the located element.
  Future<void> click({
    Duration? delay,
    MouseButton? button,
    int? clickCount,
    Future<void>? signal,
  }) {
    return _run(
      signal,
      [
        _ensureInViewportIfNeeded,
        _waitForStableBoundingBoxIfNeeded,
        _waitForEnabledIfNeeded,
      ],
      (handle) {
        return handle.click(
          delay: delay,
          button: button,
          clickCount: clickCount,
        );
      },
    );
  }

  /// Hovers over the located element.
  Future<void> hover({Future<void>? signal}) {
    return _run(signal, [
      _ensureInViewportIfNeeded,
      _waitForStableBoundingBoxIfNeeded,
    ], (handle) => handle.hover());
  }

  /// Scrolls the located element.
  Future<void> scroll({num? scrollTop, num? scrollLeft, Future<void>? signal}) {
    return _run(
      signal,
      [_ensureInViewportIfNeeded, _waitForStableBoundingBoxIfNeeded],
      (handle) {
        return handle.evaluate(
          //language=js
          '''
function _(el, scrollTop, scrollLeft) {
  if (scrollTop !== undefined) el.scrollTop = scrollTop;
  if (scrollLeft !== undefined) el.scrollLeft = scrollLeft;
}''',
          args: [scrollTop, scrollLeft],
        );
      },
    );
  }

  /// Fills out the input identified by the locator using the provided value.
  ///
  /// The type of the input is determined at runtime and the appropriate
  /// fill-out method is chosen based on the type. `contenteditable`, `select`,
  /// `textarea` and `input` elements are supported. For checkboxes, radio
  /// buttons and switches specify a boolean value.
  Future<void> fill(
    Object value, {
    int typingThreshold = 100,
    Future<void>? signal,
  }) {
    return _run(signal, [
      _ensureInViewportIfNeeded,
      _waitForStableBoundingBoxIfNeeded,
      _waitForEnabledIfNeeded,
    ], (handle) => _fill(handle, value, typingThreshold));
  }

  /// Waits for the locator to get a handle from the page.
  Future<JsHandle> waitHandle({Future<void>? signal}) {
    return _runWithRetryAndTimeout(() => _wait(signal), signal);
  }

  /// Waits for the locator to get the serialized value from the page.
  ///
  /// Note this requires the value to be JSON-serializable.
  Future<dynamic> wait({Future<void>? signal}) async {
    var handle = await waitHandle(signal: signal);
    try {
      return await handle.jsonValue;
    } finally {
      await handle.dispose();
    }
  }

  Future<void> _run(
    Future<void>? signal,
    List<Future<void> Function(ElementHandle)> conditions,
    Future<void> Function(ElementHandle) action,
  ) {
    return _runWithRetryAndTimeout(() async {
      var handle = (await _wait(signal)) as ElementHandle;
      try {
        await Future.wait(conditions.map((condition) => condition(handle)));
        _emitAction();
        await action(handle);
      } catch (_) {
        await handle.dispose().catchError((_) {});
        rethrow;
      }
    }, signal);
  }

  /// Runs [attempt], retrying it after [_retryDelay] whenever it fails, until it
  /// succeeds, the [_timeout] elapses or the [signal] aborts.
  Future<R> _runWithRetryAndTimeout<R>(
    Future<R> Function() attempt,
    Future<void>? signal,
  ) {
    var completer = Completer<R>();
    var done = false;
    Timer? timer;

    void fail(Object error, [StackTrace? stackTrace]) {
      if (done) return;
      done = true;
      if (!completer.isCompleted) {
        completer.completeError(error, stackTrace ?? StackTrace.current);
      }
    }

    void succeed(R value) {
      if (done) return;
      done = true;
      if (!completer.isCompleted) {
        completer.complete(value);
      }
    }

    if (_timeout > Duration.zero) {
      timer = Timer(_timeout, () {
        fail(
          TimeoutException(
            'Timed out after waiting ${_timeout.inMilliseconds}ms',
          ),
        );
      });
    }

    signal?.then((_) => fail(LocatorAbortedException()), onError: (_) {});

    () async {
      while (!done) {
        try {
          succeed(await attempt());
          return;
        } catch (_) {
          if (done) return;
          await Future.delayed(_retryDelay);
        }
      }
    }();

    return completer.future.whenComplete(() => timer?.cancel());
  }

  // Conditions.

  Duration? get _conditionTimeout => _timeout > Duration.zero ? _timeout : null;

  DateTime? get _conditionDeadline {
    var timeout = _conditionTimeout;
    return timeout == null ? null : DateTime.now().add(timeout);
  }

  /// Checks if the element is in the viewport and auto-scrolls it if it is not.
  Future<void> _ensureInViewportIfNeeded(ElementHandle handle) async {
    if (!ensureElementIsInTheViewport) return;
    if (await handle.isIntersectingViewport == true) return;

    await handle.scrollIntoViewIfNeeded();

    var deadline = _conditionDeadline;
    while (true) {
      if (await handle.isIntersectingViewport == true) return;
      if (deadline != null && DateTime.now().isAfter(deadline)) {
        throw TimeoutException(
          'Timed out waiting for the element to be in the viewport',
        );
      }
      await Future.delayed(_retryDelay);
    }
  }

  /// Compares the bounding box of the element for two consecutive animation
  /// frames and waits until they are the same.
  Future<void> _waitForStableBoundingBoxIfNeeded(ElementHandle handle) async {
    if (!waitForStableBoundingBox) return;

    var deadline = _conditionDeadline;
    while (true) {
      var rects = await handle.evaluate<List<dynamic>>(
        //language=js
        '''
function _(element) {
  return new Promise(resolve => {
    window.requestAnimationFrame(() => {
      const rect1 = element.getBoundingClientRect();
      window.requestAnimationFrame(() => {
        const rect2 = element.getBoundingClientRect();
        resolve([
          [rect1.x, rect1.y, rect1.width, rect1.height],
          [rect2.x, rect2.y, rect2.width, rect2.height],
        ]);
      });
    });
  });
}''',
      );
      var rect1 = (rects![0] as List).cast<num>();
      var rect2 = (rects[1] as List).cast<num>();
      if (rect1[0] == rect2[0] &&
          rect1[1] == rect2[1] &&
          rect1[2] == rect2[2] &&
          rect1[3] == rect2[3]) {
        return;
      }
      if (deadline != null && DateTime.now().isAfter(deadline)) {
        throw TimeoutException(
          'Timed out waiting for the element bounding box to be stable',
        );
      }
      await Future.delayed(_retryDelay);
    }
  }

  /// If the element has a "disabled" property, waits for the element to be
  /// enabled.
  Future<void> _waitForEnabledIfNeeded(ElementHandle handle) async {
    if (!waitForEnabled) return;

    await handle.frame!.waitForFunction(
      //language=js
      '''
function _(element) {
  if (!(element instanceof HTMLElement)) {
    return true;
  }
  const isNativeFormControl = [
    'BUTTON', 'INPUT', 'SELECT', 'TEXTAREA', 'OPTION', 'OPTGROUP',
  ].includes(element.nodeName);
  return !isNativeFormControl || !element.hasAttribute('disabled');
}''',
      args: [handle],
      timeout: _conditionTimeout,
    );
  }

  /// Waits for the element to become visible or hidden.
  Future<void> waitForVisibilityIfNeeded(ElementHandle handle) async {
    if (visibility == null) return;

    await handle.frame!.waitForFunction(
      //language=js
      '''
function _(element, visible) {
  const style = window.getComputedStyle(element);
  const isVisible = style && style.visibility !== 'hidden' && hasVisibleBoundingBox();
  return visible ? isVisible : !isVisible;

  function hasVisibleBoundingBox() {
    const rect = element.getBoundingClientRect();
    return !!(rect.top || rect.bottom || rect.width || rect.height);
  }
}''',
      args: [handle, visibility == LocatorVisibility.visible],
      timeout: _conditionTimeout,
    );
  }

  Future<void> _fill(
    ElementHandle handle,
    Object value,
    int typingThreshold,
  ) async {
    var inputType = await handle.evaluate<String>(
      //language=js
      '''
function _(el) {
  if (el instanceof HTMLSelectElement) return 'select';
  if (el instanceof HTMLTextAreaElement) return 'typeable-input';
  if (el instanceof HTMLInputElement) {
    switch (el.type) {
      case 'checkbox':
      case 'radio':
        return 'checkable-input';
      case 'text':
      case 'url':
      case 'tel':
      case 'search':
      case 'password':
      case 'number':
      case 'email':
        return 'typeable-input';
      default:
        return 'other-input';
    }
  }
  switch (el.getAttribute('role')) {
    case 'checkbox':
    case 'radio':
    case 'switch':
      return 'checkable-input';
  }
  if (el.isContentEditable) return 'contenteditable';
  return 'unknown';
}''',
    );

    switch (inputType) {
      case 'checkable-input':
        await _toggleIfNeeded(handle, value);
        return;
      case 'select':
        await handle.select([value as String]);
        return;
      case 'contenteditable':
      case 'typeable-input':
        if (value is String && value.length < typingThreshold) {
          var textToType = await handle.evaluate<String>(
            //language=js
            '''
function _(input, newValue) {
  const element = input;
  const valString = String(newValue);
  const currentValue = element.isContentEditable
    ? element.innerText
    : input.value;
  if (currentValue === valString) return '';
  // Clear the input if the current value does not match the filled out value.
  if (!valString.startsWith(currentValue) || !currentValue) {
    if (element.isContentEditable) {
      element.innerText = '';
    } else {
      input.value = '';
    }
    return valString;
  }
  // If the value is partially filled out, only type the rest. Move cursor to
  // the end of the common prefix.
  if (element.isContentEditable) {
    element.innerText = '';
    element.innerText = currentValue;
  } else {
    input.value = '';
    input.value = currentValue;
  }
  return valString.substring(currentValue.length);
}''',
            args: [value],
          );
          if (textToType != null && textToType.isNotEmpty) {
            await handle.type(textToType);
          }
          return;
        }
        await _fillDirectly(handle, value);
        return;
      case 'other-input':
        await _fillDirectly(handle, value);
        return;
      default:
        throw Exception('Element cannot be filled out.');
    }
  }

  Future<void> _fillDirectly(ElementHandle handle, Object value) async {
    await handle.focus();
    await handle.evaluate(
      //language=js
      '''
function _(input, newValue) {
  const element = input;
  const valString = String(newValue);
  const currentValue = element.isContentEditable ? element.innerText : input.value;
  if (currentValue === valString) return;
  if (element.isContentEditable) {
    element.innerText = valString;
  } else {
    input.value = valString;
  }
  element.dispatchEvent(new Event('input', {bubbles: true}));
  element.dispatchEvent(new Event('change', {bubbles: true}));
}''',
      args: [value],
    );
  }

  Future<void> _toggleIfNeeded(ElementHandle handle, Object value) async {
    var currentState = await handle.evaluate(
      //language=js
      '''
function _(el) {
  if (el.indeterminate || el.getAttribute('aria-checked') === 'mixed') {
    return 'mixed';
  }
  return el.checked || el.getAttribute('aria-checked') === 'true';
}''',
    );
    if (currentState == 'mixed' || currentState != value) {
      await handle.click();
    }
  }
}

/// A locator that locates a node by a CSS selector, or wraps an existing
/// element handle.
class NodeLocator extends Locator {
  final Frame frame;
  final String? selector;
  final ElementHandle? handle;

  NodeLocator._(super.timeout, this.frame, {this.selector, this.handle})
    : assert(selector != null || handle != null);

  factory NodeLocator.create(Page page, Frame frame, String selector) {
    return NodeLocator._(
      page.defaultTimeout ?? globalDefaultTimeout,
      frame,
      selector: selector,
    );
  }

  factory NodeLocator.fromHandle(Page page, Frame frame, ElementHandle handle) {
    return NodeLocator._(
      page.defaultTimeout ?? globalDefaultTimeout,
      frame,
      handle: handle,
    );
  }

  @override
  NodeLocator _clone() =>
      NodeLocator._(_timeout, frame, selector: selector, handle: handle)
        ..copyOptions(this);

  @override
  Future<JsHandle> _wait(Future<void>? signal) async {
    ElementHandle element;
    if (selector != null) {
      var found = await frame.waitForSelector(
        selector!,
        visible: false,
        timeout: _conditionTimeout,
      );
      if (found == null) {
        throw Exception('No element found for selector: $selector');
      }
      element = found;
    } else {
      element = handle!;
    }
    await waitForVisibilityIfNeeded(element);
    return element;
  }
}

/// Base class for locators that delegate the resolution of a handle to another
/// locator (e.g. [MappedLocator], [FilteredLocator]).
abstract class DelegatedLocator extends Locator {
  Locator delegate;

  DelegatedLocator(this.delegate) : super(delegate._timeout) {
    copyOptions(delegate);
  }

  @override
  Locator setTimeout(Duration timeout) {
    var locator = super.setTimeout(timeout) as DelegatedLocator;
    locator.delegate = delegate.setTimeout(timeout);
    return locator;
  }
}

/// A locator that maps the located handle using a mapper function.
class MappedLocator extends DelegatedLocator {
  final Future<JsHandle> Function(JsHandle) mapper;

  MappedLocator(super.delegate, this.mapper);

  @override
  MappedLocator _clone() =>
      MappedLocator(delegate.clone(), mapper)..copyOptions(this);

  @override
  Future<JsHandle> _wait(Future<void>? signal) async {
    var handle = await delegate._wait(signal);
    var mapped = await mapper(handle);
    if (!identical(mapped, handle)) {
      await handle.dispose().catchError((_) {});
    }
    return mapped;
  }
}

/// A locator that retries until a JavaScript predicate matches the located
/// handle.
class FilteredLocator extends DelegatedLocator {
  @Language('js')
  final String predicate;

  FilteredLocator(super.delegate, this.predicate);

  @override
  FilteredLocator _clone() =>
      FilteredLocator(delegate.clone(), predicate)..copyOptions(this);

  @override
  Future<JsHandle> _wait(Future<void>? signal) async {
    var handle = await delegate._wait(signal);
    var element = handle as ElementHandle;
    await element.frame!.waitForFunction(
      predicate,
      args: [handle],
      timeout: _conditionTimeout,
    );
    return handle;
  }
}

/// A locator that races multiple locators, performing the action on whichever
/// resolves a handle first.
class RaceLocator extends Locator {
  final List<Locator> locators;

  RaceLocator(this.locators) : super(_maxTimeout(locators));

  static Duration _maxTimeout(List<Locator> locators) {
    var result = Duration.zero;
    for (var locator in locators) {
      if (locator._timeout > result) result = locator._timeout;
    }
    return result;
  }

  @override
  RaceLocator _clone() =>
      RaceLocator(locators.map((locator) => locator.clone()).toList())
        ..copyOptions(this);

  @override
  Future<JsHandle> _wait(Future<void>? signal) {
    return Future.any(locators.map((locator) => locator._wait(signal)));
  }
}
