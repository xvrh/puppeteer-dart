import 'dart:async';
import '../protocol/extensions.dart';
import '../protocol/target.dart';
import 'browser.dart';
import 'connection.dart';
import 'page/page.dart';
import 'page/worker.dart';
import 'target.dart';

/// An unpacked extension installed in the browser.
///
/// Get the installed extensions with [Browser.extensions], or install one with
/// [Browser.installExtension].
class Extension {
  final Browser browser;

  /// The extension id.
  final String id;

  /// The name from the extension's manifest.
  final String name;

  /// The version from the extension's manifest.
  final String version;

  /// The directory the extension was loaded from.
  final String path;

  /// Whether the extension is enabled.
  final bool enabled;

  Extension(
    this.browser, {
    required this.id,
    required this.name,
    required this.version,
    required this.path,
    required this.enabled,
  });

  factory Extension.fromInfo(Browser browser, ExtensionInfo info) => Extension(
    browser,
    id: info.id,
    name: info.name,
    version: info.version,
    path: info.path,
    enabled: info.enabled,
  );

  bool _belongsToExtension(Target target) =>
      target.url.startsWith('chrome-extension://$id/');

  /// The running service workers of the extension.
  ///
  /// The service worker of a Manifest V3 extension is stopped when idle, so
  /// this list can be empty.
  Future<List<Worker>> get workers async {
    var targets = browser.targets.where(
      (t) => t.type == 'service_worker' && _belongsToExtension(t),
    );
    var workers = await Future.wait(
      targets.map((t) => _ignoreClosedTarget(() => t.worker)),
    );
    return workers.nonNulls.toList();
  }

  /// The open pages of the extension, such as an opened popup or options page.
  Future<List<Page>> get pages async {
    var targets = browser.targets.where(
      (t) =>
          (t.type == 'page' || t.type == 'background_page') &&
          _belongsToExtension(t),
    );
    var pages = await Future.wait(
      targets.map((t) => _ignoreClosedTarget(() => t.pageOrNull)),
    );
    return pages.nonNulls.toList();
  }

  /// Runs the extension's action on [page], as if the user clicked the
  /// extension's toolbar icon. If the extension has a popup, it opens as a new
  /// page target.
  ///
  /// For a page in an incognito browser context, the extension must be
  /// installed with `enabledInIncognito: true`.
  Future<void> triggerAction(Page page) async {
    var tabId = await _tabIdOf(page);
    await ExtensionsApi(browser.connection).triggerAction(id, tabId.value);
  }

  /// Finds the tab target that holds [page].
  ///
  /// `Extensions.triggerAction` expects a tab target id, but puppeteer only
  /// attaches to page targets. Attaching to a tab with auto-attach reports its
  /// page as a child, before `setAutoAttach` returns.
  Future<TargetID> _tabIdOf(Page page) async {
    var connection = browser.connection;
    var pageInfo = page.target.targetInfo;
    var tabs = await connection.targetApi.getTargets(
      filter: TargetFilter([FilterEntry(type: 'tab')]),
    );
    for (var tab in tabs) {
      if (tab.type != 'tab' ||
          tab.browserContextId != pageInfo.browserContextId) {
        continue;
      }
      var session = await connection.createSession(
        tab,
        isAutoAttachEmulated: false,
      );
      var tabApi = TargetApi(session);
      var children = <AttachedToTargetEvent>[];
      var subscription = tabApi.onAttachedToTarget.listen(children.add);
      try {
        await tabApi.setAutoAttach(true, false, flatten: true);
      } finally {
        await subscription.cancel();
        for (var child in children) {
          await tabApi.detachFromTarget(sessionId: child.sessionId);
        }
        await session.detach();
      }
      if (children.any((c) => c.targetInfo.targetId == pageInfo.targetId)) {
        return tab.targetId;
      }
    }
    throw Exception('Could not find the tab of page ${page.target.targetID}');
  }

  @override
  String toString() => 'Extension($id, $name $version)';
}

Future<T?> _ignoreClosedTarget<T>(Future<T?> Function() callback) async {
  try {
    return await callback();
  } on TargetClosedException {
    return null;
  } on ServerException catch (e) {
    if (e.message.contains('No target with given id found')) return null;
    rethrow;
  }
}
