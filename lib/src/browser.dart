import 'dart:async';
import 'dart:io';
import 'package:async/async.dart';
import 'package:pool/pool.dart';
import '../plugin.dart';
import '../protocol/browser.dart';
import '../protocol/system_info.dart';
import '../protocol/target.dart';
import 'connection.dart';
import 'page/emulation_manager.dart';
import 'page/page.dart';
import 'target.dart';
import 'target_manager.dart';

export '../protocol/browser.dart' show PermissionType;

/// A Browser is created when Puppeteer connects to a Chromium instance, either
/// through puppeteer.launch or puppeteer.connect.
///
/// An example of using a Browser to create a Page:
///
/// ```dart
/// void main() async {
///   var browser = await puppeteer.launch();
///   var page = await browser.newPage();
///   await page.goto('https://example.com');
///   await browser.close();
/// }
/// ```
class Browser {
  final Process? process;
  final Connection connection;
  final BrowserApi browser;
  final SystemInfoApi systemInfo;
  final Pool _screenshotsPool = Pool(1);
  final bool ignoreHttpsErrors;
  final DeviceViewport? defaultViewport;
  final Future<void> Function() _closeCallback;
  final _contexts = <BrowserContextID, BrowserContext>{};
  late final _targetManager = TargetManager(connection, _createTarget);
  late final BrowserContext _defaultContext;
  final _onTargetCreatedController = StreamController<Target>.broadcast(),
      _onTargetDestroyedController = StreamController<Target>.broadcast(),
      _onTargetChangedController = StreamController<Target>.broadcast();
  final _plugins = <Plugin>[];

  Browser._(
    this.process,
    this.connection, {
    required this.defaultViewport,
    required List<BrowserContextID>? browserContextIds,
    required bool? ignoreHttpsErrors,
    required Future<void> Function() closeCallback,
    required List<Plugin> plugins,
  }) : _closeCallback = closeCallback,
       ignoreHttpsErrors = ignoreHttpsErrors ?? false,
       browser = BrowserApi(connection),
       systemInfo = SystemInfoApi(connection) {
    _defaultContext = BrowserContext(connection, this, null);

    _plugins.addAll(plugins);

    if (browserContextIds != null) {
      for (var contextId in browserContextIds) {
        _contexts[contextId] = BrowserContext(connection, this, contextId);
      }
    }
  }

  /// Emitted when the url of a target changes.
  ///
  /// NOTE This includes target changes in incognito browser contexts.
  Stream<Target> get onTargetChanged => _onTargetChangedController.stream;

  Stream<TargetInfo> get onTargetDiscovered =>
      _targetManager.onTargetDiscovered;

  Future<void> _attach() async {
    _targetManager.onTargetAvailable.listen(_onAttachedToTarget);
    _targetManager.onTargetGone.listen(_onDetachedFromTarget);
    _targetManager.onTargetChanged.listen(_onTargetChanged);

    await _targetManager.initialize();
  }

  void _dispose() {
    _targetManager.dispose();
    _onTargetCreatedController.close();
    _onTargetDestroyedController.close();
    _onTargetChangedController.close();
  }

  Iterable<Plugin> get plugins => List.unmodifiable(_plugins);

  /// Emitted when a target is created, for example when a new page is opened by
  /// [window.open](https://developer.mozilla.org/en-US/docs/Web/API/Window/open)
  /// or [Browser.newPage].
  ///
  /// NOTE This includes target creations in incognito browser contexts.
  Stream<Target> get onTargetCreated => _onTargetCreatedController.stream;

  /// Emitted when a target is destroyed, for example when a page is closed.
  ///
  /// NOTE This includes target destructions in incognito browser contexts.
  Stream<Target> get onTargetDestroyed => _onTargetDestroyedController.stream;

  Future<void> get disconnected => connection.disconnected;

  /// Creates a new incognito browser context. This won't share cookies/cache
  /// with other browser contexts.
  ///
  /// ```dart
  /// void main() async {
  ///   var browser = await puppeteer.launch();
  ///   // Create a new incognito browser context.
  ///   var context = await browser.createIncognitoBrowserContext();
  ///   // Create a new page in a pristine context.
  ///   var page = await context.newPage();
  ///   // Do stuff
  ///   await page.goto('https://example.com');
  ///   await browser.close();
  /// }
  /// ```
  Future<BrowserContext> createIncognitoBrowserContext() async {
    var browserContextId = await connection.targetApi.createBrowserContext();
    var context = BrowserContext(connection, this, browserContextId);
    _contexts[browserContextId] = context;
    return context;
  }

  /// Returns a list of all open browser contexts. In a newly created browser,
  /// this will return a single instance of BrowserContext.
  List<BrowserContext> get browserContexts => [
    _defaultContext,
    ..._contexts.values,
  ];

  /// Returns the default browser context. The default browser context can not
  /// be closed.
  BrowserContext get defaultBrowserContext => _defaultContext;

  Target _createTarget(TargetInfo event, Session? session) {
    var context = _contexts[event.browserContextId] ?? _defaultContext;

    return Target(
      session,
      _targetManager,
      event,
      ({required isAutoAttachEmulated}) => connection.createSession(
        event,
        isAutoAttachEmulated: isAutoAttachEmulated,
      ),
      browserContext: context,
    );
  }

  void _onAttachedToTarget(Target target) async {
    if (await target.initialized) {
      if (!_onTargetCreatedController.isClosed) {
        _onTargetCreatedController.add(target);
      }
    }
  }

  void _onDetachedFromTarget(Target target) async {
    target.onDestroyed();
    if (await target.initialized) {
      _onTargetDestroyedController.add(target);
    }
  }

  void _onTargetChanged(TargetChangedEvent event) {
    var target = event.target;
    var info = event.targetInfo;

    var previousURL = target.url;
    var wasInitialized = target.isInitialized;
    target.changeInfo(info);
    if (wasInitialized && previousURL != target.url) {
      _onTargetChangedController.add(target);
    }
  }

  String get wsEndpoint {
    return connection.url;
  }

  /// Future which resolves to a new Page object. The Page is created in a
  /// default browser context.
  Future<Page> newPage() async {
    return _defaultContext.newPage();
  }

  Future<Page> _createPageInContext(BrowserContextID? contextId) async {
    var targetId = await connection.targetApi.createTarget(
      'about:blank',
      browserContextId: contextId,
    );
    var target = _targetManager.availableTargets()[targetId];
    if (target == null) {
      throw Exception('Missing target for page (id = $targetId)');
    }
    assert(await target.initialized, 'Failed to create target for page');
    var page = await target.pageOrNull;
    if (page == null) {
      throw Exception('Failed to create a page for context (id = $contextId)');
    }
    return page;
  }

  /// A list of all active targets inside the Browser. In case of multiple
  /// browser contexts, the method will return an array with all the targets in
  /// all browser contexts.
  List<Target> get targets => _targetManager
      .availableTargets()
      .values
      .where((target) => target.isInitialized)
      .toList();

  /// A target associated with the browser.
  Target get target => targets.firstWhere((t) => t.type == 'browser');

  /// Future which resolves to a list of all open pages. Non visible pages,
  /// such as "background_page", will not be listed here. You can find them
  /// using [Target.page].
  ///
  /// A list of all pages inside the Browser. In case of multiple browser
  /// contexts, the method will return an array with all the pages in all
  /// browser contexts.
  Future<List<Page>> get pages async {
    var contextPages = await Future.wait(
      browserContexts.map((context) => context.pages),
    );
    return contextPages.expand((l) => l).toList();
  }

  /// This searches for a target in all browser contexts.
  ///
  /// An example of finding a target for a page opened via window.open:
  /// ```dart
  /// var newWindowTarget = browser.waitForTarget(
  ///   (target) => target.url == 'https://example.com/',
  /// );
  /// await page.evaluate("() => window.open('https://example.com/')");
  /// await newWindowTarget;
  /// ```
  Future<Target> waitForTarget(
    bool Function(Target) predicate, {
    Duration? timeout,
  }) {
    timeout ??= const Duration(seconds: 30);
    for (var target in targets) {
      if (predicate(target)) return Future.value(target);
    }

    return StreamGroup.merge([
      onTargetCreated,
      onTargetChanged,
    ]).where(predicate).first.timeout(timeout);
  }

  /// For headless Chrome, this is similar to HeadlessChrome/61.0.3153.0. For
  /// non-headless, this is similar to Chrome/61.0.3153.0.
  Future<String> get version async {
    var version = await browser.getVersion();
    return version.product;
  }

  /// Future which resolves to the browser's original user agent.
  ///
  /// NOTE Pages can override browser user agent with [Page.setUserAgent]
  Future<String> get userAgent async {
    var version = await browser.getVersion();
    return version.userAgent;
  }

  Future<void> _disposeContext(BrowserContextID contextId) async {
    await connection.targetApi.disposeBrowserContext(contextId);
    _contexts.remove(contextId);
  }

  /// Closes Chromium and all of its pages (if any were opened). The Browser
  /// object itself is considered to be disposed and cannot be used anymore.
  Future<void> close() async {
    // Try to give a chance to other message to arrive before we complete the future
    // with an error
    await Future.delayed(Duration.zero);
    await _closeCallback();

    await connection.dispose('Browser.close');
    _dispose();
  }

  void disconnect() {
    connection.dispose('Browser.disconnect');
    _dispose();
  }

  bool get isConnected {
    return !connection.isClosed;
  }
}

Future<Browser> createBrowser(
  Process? process,
  Connection connection, {
  required DeviceViewport? defaultViewport,
  List<BrowserContextID>? browserContextIds,
  required Future<void> Function() closeCallback,
  required bool? ignoreHttpsErrors,
  required List<Plugin> plugins,
}) async {
  var browser = Browser._(
    process,
    connection,
    defaultViewport: defaultViewport,
    browserContextIds: browserContextIds,
    closeCallback: closeCallback,
    ignoreHttpsErrors: ignoreHttpsErrors,
    plugins: plugins,
  );
  return browser;
}

Future<void> attachBrowser(Browser browser) async {
  await browser._attach();
}

Pool screenshotPool(Browser browser) => browser._screenshotsPool;

/// BrowserContexts provide a way to operate multiple independent browser
/// sessions. When a browser is launched, it has a single BrowserContext used by
/// default. The method [Browser.newPage] creates a page in the default browser
/// context.
///
/// If a page opens another page, e.g. with a window.open call, the popup will
/// belong to the parent page's browser context.
///
/// Puppeteer allows creation of "incognito" browser contexts with
/// [Browser.createIncognitoBrowserContext] method. "Incognito" browser contexts
/// don't write any browsing data to disk.
class BrowserContext {
  final Connection? connection;

  /// The browser this browser context belongs to.
  final Browser browser;

  final BrowserContextID? id;

  BrowserContext(this.connection, this.browser, this.id);

  /// Emitted when a new target is created inside the browser context, for
  /// example when a new page is opened by window.open or browserContext.newPage.
  Stream<Target> get onTargetCreated =>
      browser.onTargetCreated.where((t) => t.browserContext == this);

  /// Emitted when a target inside the browser context is destroyed, for example
  /// when a page is closed.
  Stream<Target> get onTargetDestroyed =>
      browser.onTargetDestroyed.where((t) => t.browserContext == this);

  /// Emitted when the url of a target inside the browser context changes.
  Stream<Target> get onTargetChanged =>
      browser.onTargetChanged.where((t) => t.browserContext == this);

  /// An array of all active targets inside the browser context.
  List<Target> get targets {
    return browser.targets
        .where((target) => target.browserContext == this)
        .toList();
  }

  /// An array of all pages inside the browser context.
  Future<List<Page>> get pages async {
    var pages = await Future.wait(
      targets
          .where((target) => target.type == 'page')
          .map((target) => target.page),
    );
    return pages.nonNulls.toList();
  }

  /// Returns whether BrowserContext is incognito. The default browser context
  /// is the only non-incognito browser context.
  bool get isIncognito {
    return id != null;
  }

  /// origin [string] The origin to grant permissions to, e.g. "https://example.com".
  /// permissions [Array<string>] An array of permissions to grant. All
  /// permissions that are not listed here will be automatically denied.
  ///
  /// ```dart
  /// var context = browser.defaultBrowserContext;
  /// await context.overridePermissions('https://html5demos.com', [
  ///   PermissionType.geolocation,
  /// ]);
  /// ```
  Future<void> overridePermissions(
    String origin,
    List<PermissionType> permissions,
  ) async {
    await browser.browser.grantPermissions(
      permissions,
      origin: origin,
      browserContextId: id,
    );
  }

  /// Clears all permission overrides for the browser context.
  ///
  /// ```dart
  /// var context = browser.defaultBrowserContext;
  /// await context.overridePermissions('https://example.com', [
  ///   PermissionType.clipboardReadWrite,
  /// ]);
  /// // do stuff ..
  /// await context.clearPermissionOverrides();
  /// ```
  Future<void> clearPermissionOverrides() {
    return browser.browser.resetPermissions(browserContextId: id);
  }

  /// Creates a new page in the browser context.
  Future<Page> newPage() {
    return browser._createPageInContext(id);
  }

  /// This searches for a target in this specific browser context.
  Future<Target> waitForTarget(
    bool Function(Target) predicate, {
    Duration? timeout,
  }) {
    return browser.waitForTarget(
      (target) => target.browserContext == this && predicate(target),
      timeout: timeout,
    );
  }

  /// Closes the browser context. All the targets that belong to the browser
  /// context will be closed.
  ///
  ///NOTE only incognito browser contexts can be closed.
  Future<void> close() async {
    assert(id != null, 'Non-incognito profiles cannot be closed!');
    await browser._disposeContext(id!);
  }
}
