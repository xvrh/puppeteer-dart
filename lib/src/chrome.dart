import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chrome_dev_tools/domains/browser.dart';
import 'package:chrome_dev_tools/domains/system_info.dart';
import 'package:chrome_dev_tools/src/downloader.dart';
import 'package:chrome_dev_tools/src/launcher.dart';
import 'package:chrome_dev_tools/src/page/page.dart';
import 'package:chrome_dev_tools/src/page/emulation_manager.dart';
import 'package:chrome_dev_tools/src/target.dart';
import 'package:meta/meta.dart';
import 'package:pool/pool.dart';

import '../domains/target.dart';
import 'package:chrome_dev_tools/src/connection.dart';
import 'tab.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('chrome_dev_tools');

class Browser {
  final Connection connection;
  final BrowserApi browser;
  final SystemInfoApi systemInfo;
  final Pool _screenshotsPool = Pool(1);
  final DeviceViewport defaultViewport;
  final Future Function() _closeCallback;
  final _contexts = <BrowserContextID, BrowserContext>{};
  final _targets = <TargetID, Target>{};
  BrowserContext _defaultContext;

  Browser._(this.connection, {@required this.defaultViewport,
    @required Future Function() closeCallback})
      :
        _closeCallback = closeCallback,
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
  /// `CHROME_DEV_TOOLS_PATH` is present, it will download the Chromium binaries
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

  Future get disconnected => connection.disconnected;

  Future<BrowserContext> createIncognitoBrowserContext() async {
    var browserContextId = await targetApi.createBrowserContext();
    var context = BrowserContext(connection, this, browserContextId);
    _contexts[browserContextId] = context;
    return context;
  }

  List<BrowserContext> get browserContexts => [_defaultContext]..addAll(_contexts.values);

  BrowserContext get defaultBrowserContext => _defaultContext;

  Future<void> disposeContext(BrowserContextID contextId) async {
    await targetApi.disposeBrowserContext(contextId);
    _contexts.remove(contextId);
  }

  TargetApi get targetApi => connection.targetApi;
  
  Future<void> _targetCreated(TargetInfo event) async {
    BrowserContext context = _contexts[event.browserContextId] ?? _defaultContext;

    Target target = new Target(this, event, () => connection.createSession(event), ignoreHttpsErrors: ignoreHttpsErrors, viewport: defaultViewport);
    _targets[event.targetId] = target;

    if (await target.initialize()) {
      _onTargetCreatedController.add(target);
      context._onTargetCreatedController.add(target);
    }
  }

  /**
   * @param {{targetId: string}} event
   */
  async _targetDestroyed(event) {
    const target = this._targets.get(event.targetId);
    target._initializedCallback(false);
    this._targets.delete(event.targetId);
    target._closedCallback();
    if (await target._initializedPromise) {
      this.emit(Events.Browser.TargetDestroyed, target);
      target.browserContext().emit(Events.BrowserContext.TargetDestroyed, target);
    }
  }

  /**
   * @param {!Protocol.Target.targetInfoChangedPayload} event
   */
  _targetInfoChanged(event) {
    const target = this._targets.get(event.targetInfo.targetId);
    assert(target, 'target should exist before targetInfoChanged');
    const previousURL = target.url();
    const wasInitialized = target._isInitialized;
    target._targetInfoChanged(event.targetInfo);
    if (wasInitialized && previousURL !== target.url()) {
    this.emit(Events.Browser.TargetChanged, target);
    target.browserContext().emit(Events.BrowserContext.TargetChanged, target);
    }
  }

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

  Future close() async {
    await _closeCallback();
    connection.dispose();
  }
}

Browser createBrowser(Connection connection,
        {@required DeviceViewport defaultViewport, @required Future Function() closeCallback}) =>
    Browser._(connection, defaultViewport: defaultViewport, closeCallback: closeCallback);

Pool screenshotPool(Browser browser) => browser._screenshotsPool;

class BrowserContext {
  final Connection connection;
  final Browser browser;
  final BrowserContextID id;

  BrowserContext(this.connection, this.browser, this.id);

  /**
   * @return {!Array<!Target>} target
   */
  targets() {
    return this._browser.targets().filter(target => target.browserContext() === this);
  }

  /**
   * @param {function(!Target):boolean} predicate
   * @param {{timeout?: number}=} options
   * @return {!Promise<!Target>}
   */
  waitForTarget(predicate, options) {
    return this._browser.waitForTarget(target => target.browserContext() === this && predicate(target), options);
  }

  Future<List<Page>> get pages {
    const pages = await Promise.all(
        this.targets()
            .filter(target => target.type() === 'page')
        .map(target => target.page())
    );
    return pages.filter(page => !!page);
  }

  bool get isIncognito {
    return id != null;
  }

  /**
   * @param {string} origin
   * @param {!Array<string>} permissions
   */
  async overridePermissions(origin, permissions) {
    const webPermissionToProtocol = new Map([
      ['geolocation', 'geolocation'],
      ['midi', 'midi'],
      ['notifications', 'notifications'],
      ['push', 'push'],
      ['camera', 'videoCapture'],
      ['microphone', 'audioCapture'],
      ['background-sync', 'backgroundSync'],
      ['ambient-light-sensor', 'sensors'],
      ['accelerometer', 'sensors'],
      ['gyroscope', 'sensors'],
      ['magnetometer', 'sensors'],
      ['accessibility-events', 'accessibilityEvents'],
      ['clipboard-read', 'clipboardRead'],
      ['clipboard-write', 'clipboardWrite'],
      ['payment-handler', 'paymentHandler'],
      // chrome-specific permissions we have.
      ['midi-sysex', 'midiSysex'],
    ]);
    permissions = permissions.map(permission => {
    const protocolPermission = webPermissionToProtocol.get(permission);
    if (!protocolPermission)
    throw new Error('Unknown permission: ' + permission);
    return protocolPermission;
    });
    await this._connection.send('Browser.grantPermissions', {origin, browserContextId: this._id || undefined, permissions});
  }

  async clearPermissionOverrides() {
    await this._connection.send('Browser.resetPermissions', {browserContextId: this._id || undefined});
  }

  Future<Page> newPage() {
    return browser._createPageInContext(id);
  }

  Future close() async {
    assert(id != null, 'Non-incognito profiles cannot be closed!');
    await this._browser._disposeContext(id);
  }
}
