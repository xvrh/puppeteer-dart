import 'dart:async';

import 'package:async/async.dart';
import 'package:meta/meta.dart';
import 'package:pool/pool.dart';
import 'package:puppeteer/protocol/browser.dart';
import 'package:puppeteer/protocol/system_info.dart';
import 'package:puppeteer/src/connection.dart';
import 'package:puppeteer/src/launcher.dart';
import 'package:puppeteer/src/page/emulation_manager.dart';
import 'package:puppeteer/src/page/page.dart';
import 'package:puppeteer/src/target.dart';

import '../protocol/target.dart';

class Browser {
  final Connection connection;
  final BrowserApi browser;
  final SystemInfoApi systemInfo;
  final Pool _screenshotsPool = Pool(1);
  final bool ignoreHttpsErrors;
  final DeviceViewport defaultViewport;
  final Future Function() _closeCallback;
  final _contexts = <BrowserContextID, BrowserContext>{};
  final _targets = <TargetID, Target>{};
  BrowserContext _defaultContext;
  final _onTargetCreatedController = StreamController<Target>.broadcast(),
      _onTargetDestroyedController = StreamController<Target>.broadcast(),
      _onTargetChangedController = StreamController<Target>.broadcast();

  Browser._(this.connection,
      {@required this.defaultViewport,
      @required bool ignoreHttpsErrors,
      @required Future Function() closeCallback})
      : _closeCallback = closeCallback,
        ignoreHttpsErrors = ignoreHttpsErrors ?? false,
        browser = BrowserApi(connection),
        systemInfo = SystemInfoApi(connection) {
    _defaultContext = BrowserContext(connection, this, null);

    targetApi.onTargetCreated.listen(_targetCreated);
    targetApi.onTargetDestroyed.listen(_targetDestroyed);
    targetApi.onTargetInfoChanged.listen(_targetInfoChanged);
  }

  /// Start a Chrome instance and connect to the DevTools endpoint.
  ///
  /// If [executablePath] is not provided and no environment variable
  /// `puppeteer_PATH` is present, it will download the Chromium binaries
  /// in a local folder (.local-chromium by default).
  ///
  /// ```
  /// main() {
  ///   Chrome.start();
  /// }
  /// ```
  static Future<Browser> start(
      {String executablePath,
      bool headless = true,
      bool useTemporaryUserData = false,
      bool noSandboxFlag,
      DeviceViewport defaultViewport}) async {
    return launch(
        executablePath: executablePath,
        useTemporaryUserData: useTemporaryUserData,
        noSandboxFlag: noSandboxFlag,
        defaultViewport: defaultViewport);
  }

  void dispose() {
    _onTargetCreatedController.close();
    _onTargetDestroyedController.close();
    _onTargetChangedController.close();
  }

  Stream<Target> get onTargetCreated => _onTargetCreatedController.stream;
  Stream<Target> get onTargetDestroyed => _onTargetDestroyedController.stream;
  Stream<Target> get onTargetChanged => _onTargetChangedController.stream;

  Future get disconnected => connection.disconnected;

  Future<BrowserContext> createIncognitoBrowserContext() async {
    var browserContextId = await targetApi.createBrowserContext();
    var context = BrowserContext(connection, this, browserContextId);
    _contexts[browserContextId] = context;
    return context;
  }

  List<BrowserContext> get browserContexts =>
      [_defaultContext]..addAll(_contexts.values);

  BrowserContext get defaultBrowserContext => _defaultContext;

  Future<void> disposeContext(BrowserContextID contextId) async {
    await targetApi.disposeBrowserContext(contextId);
    _contexts.remove(contextId);
  }

  TargetApi get targetApi => connection.targetApi;

  Future<void> _targetCreated(TargetInfo event) async {
    BrowserContext context =
        _contexts[event.browserContextId] ?? _defaultContext;

    Target target = new Target(
        this, event, () => connection.createSession(event),
        browserContext: context);
    _targets[event.targetId] = target;

    if (await target.initialized) {
      _onTargetCreatedController.add(target);
    }
  }

  Future<void> _targetDestroyed(TargetID targetId) async {
    var target = _targets[targetId];
    _targets.remove(targetId);
    target.onDestroyed();
    if (await target.initialized) {
      _onTargetDestroyedController.add(target);
    }
  }

  void _targetInfoChanged(TargetInfo event) {
    var target = _targets[event.targetId];
    assert(target != null, 'target should exist before targetInfoChanged');
    var previousURL = target.url;
    var wasInitialized = target.isInitialized;
    target.changeInfo(event);
    if (wasInitialized && previousURL != target.url) {
      _onTargetChangedController.add(target);
    }
  }

  Future<Page> newPage() async {
    return _defaultContext.newPage();
  }

  Future<Page> _createPageInContext(BrowserContextID contextId) async {
    var targetId = await targetApi.createTarget('about:blank',
        browserContextId: contextId);
    var target = _targets[targetId];
    assert(await target.initialized, 'Failed to create target for page');
    var page = await target.page;
    return page;
  }

  List<Target> get targets =>
      _targets.values.where((target) => target.isInitialized).toList();
  Target get target => _targets.values
      .firstWhere((t) => t.type == 'browser', orElse: () => null);

  Future<Target> waitForTarget(bool Function(Target) predicate,
      {Duration timeout}) {
    timeout ??= const Duration(seconds: 30);
    return StreamGroup.merge([onTargetCreated, onTargetChanged])
        .where(predicate)
        .first
        .timeout(timeout);
  }

  Future _disposeContext(BrowserContextID contextId) async {
    await targetApi.disposeBrowserContext(contextId);
    _contexts.remove(contextId);
  }

  /*
  Future<Tab> newTab({bool incognito = false}) async {
    BrowserContextID contextID;
    if (incognito) {
      contextID = await targetApi.createBrowserContext();
    }

    TargetID targetId = await targetApi.createTarget('about:blank',
        browserContextId: contextID);
    Session session =
        await connection.createSession(targetId, browserContextID: contextID);

    return Tab(this, targetId, session, browserContextID: contextID);
  }

  Future<Page> newPage(
      {bool incognito = false, DeviceViewport viewport}) async {
    Tab tab = await newTab(incognito: incognito);
    return Page.create(tab, viewport: viewport ?? defaultViewport);
  }

  Future closeAllTabs() async {
    for (TargetInfo target in await targetApi.getTargets()) {
      await targetApi.closeTarget(target.targetId);
    }
  }
*/
  Future close() async {
    await _closeCallback();
    connection.dispose();
  }

  Target targetById(TargetID targetId) => _targets[targetId];
}

Browser createBrowser(Connection connection,
        {@required DeviceViewport defaultViewport,
        @required Future Function() closeCallback,
        @required bool ignoreHttpsErrors}) =>
    Browser._(connection,
        defaultViewport: defaultViewport,
        closeCallback: closeCallback,
        ignoreHttpsErrors: ignoreHttpsErrors);

Pool screenshotPool(Browser browser) => browser._screenshotsPool;

class BrowserContext {
  final Connection connection;
  final Browser browser;
  final BrowserContextID id;

  BrowserContext(this.connection, this.browser, this.id);

  Stream<Target> get onTargetCreated =>
      browser.onTargetCreated.where((t) => t.browserContext == this);
  Stream<Target> get onTargetDestroyed =>
      browser.onTargetDestroyed.where((t) => t.browserContext == this);
  Stream<Target> get onTargetChanged =>
      browser.onTargetChanged.where((t) => t.browserContext == this);

  List<Target> get targets {
    return browser.targets
        .where((target) => target.browserContext == this)
        .toList();
  }

  Future<List<Page>> get pages async {
    return await Future.wait(targets
        .where((target) => target.type == 'page')
        .map((target) => target.page)
        .where((pageFuture) => pageFuture != null));
  }

  bool get isIncognito {
    return id != null;
  }

  Future<void> overridePermissions(
      String origin, List<PermissionType> permissions) async {
    await browser.browser
        .grantPermissions(origin, permissions, browserContextId: id);
  }

  Future<void> clearPermissionOverrides() {
    return browser.browser.resetPermissions(browserContextId: id);
  }

  Future<Page> newPage() {
    return browser._createPageInContext(id);
  }

  Future close() async {
    assert(id != null, 'Non-incognito profiles cannot be closed!');
    await browser._disposeContext(id);
  }
}
