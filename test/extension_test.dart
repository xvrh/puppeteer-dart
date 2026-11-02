import 'package:path/path.dart' as p;
import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils/utils.dart';

final _extensionPath = p.absolute(p.join('test', 'assets', 'extension'));

void main() {
  late Server server;
  late Browser browser;
  setUpAll(() async {
    server = await Server.create();
    browser = await puppeteer.launch(enableExtensions: true);
  });

  tearDownAll(() async {
    await browser.close();
    await server.close();
  });

  tearDown(() async {
    for (var id in (await browser.extensions).keys) {
      await browser.uninstallExtension(id);
    }
  });

  bool isServiceWorker(Target target, String id) =>
      target.type == 'service_worker' &&
      target.url.startsWith('chrome-extension://$id/');

  group('Extensions', () {
    test('installExtension', () async {
      var id = await browser.installExtension(_extensionPath);

      var extensions = await browser.extensions;
      expect(extensions.keys, [id]);
      var extension = extensions[id]!;
      expect(extension.id, id);
      expect(extension.name, 'Test extension');
      expect(extension.version, '1.2.3');
      expect(extension.path, _extensionPath);
      expect(extension.enabled, isTrue);
      expect('$extension', 'Extension($id, Test extension 1.2.3)');
    });

    test('evaluate in the service worker', () async {
      var id = await browser.installExtension(_extensionPath);
      await browser.waitForTarget((t) => isServiceWorker(t, id));

      var extension = (await browser.extensions)[id]!;
      var workers = await extension.workers;
      expect(workers, hasLength(1));
      expect(
        await workers.first.evaluate<String>('() => hello()'),
        'Hello from $id',
      );
    });

    test('triggerExtensionAction opens the popup', () async {
      var id = await browser.installExtension(_extensionPath);
      var extension = (await browser.extensions)[id]!;
      var page = await browser.newPage();
      await page.goto(server.emptyPage);

      var popupTarget = browser.waitForTarget(
        (t) => t.url == 'chrome-extension://$id/popup.html',
      );
      await page.triggerExtensionAction(extension);
      var popup = await (await popupTarget).page;
      await popup.waitForFunction('() => document.title.startsWith("Popup ")');
      expect(await popup.title, 'Popup $id');
      expect(await extension.pages, [popup]);

      await page.close();
    });

    test('triggerAction in an incognito context', () async {
      var id = await browser.installExtension(
        _extensionPath,
        enabledInIncognito: true,
      );
      var extension = (await browser.extensions)[id]!;
      var context = await browser.createIncognitoBrowserContext();
      var page = await context.newPage();
      await page.goto(server.emptyPage);

      var popupTarget = browser.waitForTarget(
        (t) => t.url == 'chrome-extension://$id/popup.html',
      );
      await extension.triggerAction(page);
      await popupTarget;

      await context.close();
    });

    test('triggerAction on a closed page', () async {
      var id = await browser.installExtension(_extensionPath);
      var extension = (await browser.extensions)[id]!;
      var page = await browser.newPage();
      await page.close();

      await expectLater(
        () => extension.triggerAction(page),
        throwsA(predicate((e) => '$e'.contains('Could not find the tab'))),
      );
    });

    test('uninstallExtension', () async {
      var id = await browser.installExtension(_extensionPath);
      var serviceWorker = await browser.waitForTarget(
        (t) => isServiceWorker(t, id),
      );
      var destroyed = browser.onTargetDestroyed.firstWhere(
        (t) => t == serviceWorker,
      );

      await browser.uninstallExtension(id);
      expect(await browser.extensions, isEmpty);
      expect(browser.targets.where((t) => isServiceWorker(t, id)), isEmpty);
      await destroyed;
    });

    test('uninstallExtension with a worker in use', () async {
      var id = await browser.installExtension(_extensionPath);
      var serviceWorker = await browser.waitForTarget(
        (t) => isServiceWorker(t, id),
      );
      // Chrome doesn't destroy the target of a service worker that has a
      // session attached.
      var worker = (await serviceWorker.worker)!;
      expect(await worker.evaluate<String>('() => hello()'), 'Hello from $id');
      var destroyed = browser.onTargetDestroyed.firstWhere(
        (t) => t == serviceWorker,
      );

      await browser.uninstallExtension(id);
      expect(await browser.extensions, isEmpty);
      expect(browser.targets.where((t) => isServiceWorker(t, id)), isEmpty);
      await destroyed;
      expect(serviceWorker.isDestroyed, isTrue);
    });

    test('reinstalling replaces the service worker', () async {
      var id = await browser.installExtension(_extensionPath);
      var first = await browser.waitForTarget((t) => isServiceWorker(t, id));
      await first.worker;

      expect(await browser.installExtension(_extensionPath), id);
      await first.onClose;
      var second = await browser.waitForTarget((t) => isServiceWorker(t, id));
      expect(second, isNot(first));
      expect(browser.targets.where((t) => isServiceWorker(t, id)), [second]);
    });
  });

  group('launch', () {
    test('installs the given extensions', () async {
      var browser = await puppeteer.launch(extensions: [_extensionPath]);
      try {
        var extensions = await browser.extensions;
        expect(extensions.values.map((e) => e.name), ['Test extension']);
      } finally {
        await browser.close();
      }
    });

    test('accepts a relative path', () async {
      var browser = await puppeteer.launch(
        extensions: ['test/assets/extension'],
      );
      try {
        var extensions = await browser.extensions;
        expect(extensions.values.map((e) => e.path), [_extensionPath]);
      } finally {
        await browser.close();
      }
    });

    test('rejects extensions when they are disabled', () async {
      await expectLater(
        () => puppeteer.launch(
          enableExtensions: false,
          extensions: [_extensionPath],
        ),
        throwsArgumentError,
      );
    });

    test('disables extensions by default', () async {
      var browser = await puppeteer.launch();
      try {
        await expectLater(
          () => browser.installExtension(_extensionPath),
          throwsA(predicate((e) => '$e'.contains('`enableExtensions: true`'))),
        );
      } finally {
        await browser.close();
      }
    });

    test('loads the devtools_page with devTools', () async {
      var browser = await puppeteer.launch(
        headless: true,
        devTools: true,
        extensions: [_extensionPath],
      );
      try {
        var id = (await browser.extensions).keys.single;
        // The devtools_page messages the service worker, which opens a tab.
        await browser.waitForTarget(
          (t) => t.url == 'chrome-extension://$id/popup.html?devtools_page',
        );
      } finally {
        await browser.close();
      }
    });
  });
}
