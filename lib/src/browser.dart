import 'dart:async';
import 'package:async/async.dart';
import 'package:meta/meta.dart';
import 'package:pool/pool.dart';
import '../protocol/browser.dart';
import '../protocol/system_info.dart';
import '../protocol/target.dart';
import 'connection.dart';
import 'page/emulation_manager.dart';
import 'page/page.dart';
import 'target.dart';

export '../protocol/browser.dart' show PermissionType;

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

  void _dispose() {
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

  TargetApi get targetApi => connection.targetApi;

  Future<void> _targetCreated(TargetInfo event) async {
    BrowserContext context =
        _contexts[event.browserContextId] ?? _defaultContext;

    Target target = Target(this, event, () => connection.createSession(event),
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

  Future<List<Page>> get pages async {
    var contextPages =
        await Future.wait(browserContexts.map((context) => context.pages));
    return contextPages.expand((l) => l).toList();
  }

  Future<Target> waitForTarget(bool Function(Target) predicate,
      {Duration timeout}) {
    timeout ??= const Duration(seconds: 30);
    return StreamGroup.merge([onTargetCreated, onTargetChanged])
        .where(predicate)
        .first
        .timeout(timeout);
  }

  Future<String> get version async {
    var version = await browser.getVersion();
    return version.product;
  }

  Future<String> get userAgent async {
    var version = await browser.getVersion();
    return version.userAgent;
  }

  Future<void> _disposeContext(BrowserContextID contextId) async {
    await targetApi.disposeBrowserContext(contextId);
    _contexts.remove(contextId);
  }

  Future close() async {
    await _closeCallback();
    _dispose();
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

  Future<Target> waitForTarget(Function(Target) predicate, {Duration timeout}) {
    return browser.waitForTarget(
        (target) => target.browserContext == this && predicate(target),
        timeout: timeout);
  }

  Future<void> close() async {
    assert(id != null, 'Non-incognito profiles cannot be closed!');
    await browser._disposeContext(id);
  }
}
