import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';

void main() {
  late Browser browser;
  //late Page page;
  late Directory userDataDir;

  setUp(() async {
    var extensionPath = p.join('test', 'assets', 'simple-devtools-extension');
    var extensionOptions = [
      '--disable-extensions-except=$extensionPath',
      '--load-extension=$extensionPath',
      '--window-size=1800,1000',
    ];
    userDataDir = _createUserDataDirectory(preferences: {
      'devtools': {
        'preferences': {
          'panel-selectedTab': jsonEncode('network'),
          'currentDockState': jsonEncode('bottom'),
        }
      }
    });
    browser = await puppeteer.launch(
        devTools: true, args: extensionOptions, userDataDir: userDataDir.path);
    //page = await browser.newPage();
    //print("User ${userDataDir.path}");
  });

  tearDown(() async {
    //await context.close();
    //await browser.close();
    //userDataDir.deleteSync(recursive: true);
  });

  group('Chrome DevTools', () {
    test('should be able to set type to be a "page"', () async {
      final devToolsTarget = browser.targets
          .firstWhere((target) => target.url.startsWith('devtools://devtools'));
      expect(devToolsTarget.isPage, isFalse);
      devToolsTarget.type = 'page';
      expect(devToolsTarget.isPage, isTrue);
    });

    // Note: The following test checks that an extension panel added by
    // a Chrome Extension can be interacted with as described in:
    // https://github.com/puppeteer/puppeteer/issues/4247#issue-429876229
    test('should be able to interact with a DevTools Chrome Extension',
        () async {
      // Set the devtools target type to be a "page":
      final devToolsTarget = browser.targets
          .lastWhere((target) => target.url.startsWith('devtools://devtools'));
      devToolsTarget.type = 'page';
      final devToolsPage = await devToolsTarget.page;
      for (var target in browser.targets) {
        print("${target.url} ${target.type}");
      }

      //print(await devToolsPage.evaluate<String>('document.documentElement.outerHTML'));
      await Future.delayed(const Duration(seconds: 2));
      //print(await devToolsPage.evaluate<String>('document.documentElement.outerHTML'));
      for (var target in browser.targets) {
        print("${target.url} ${target.type}");
      }
      var extensionTab = await devToolsPage.waitForXPath("//span[contains(text(), 'Simple DevTools Extension')]");
      await extensionTab!.click();

      // Preselect devtools.preferences.panel-selectedTab: ""
      /*await devToolsPage.click('[title="More tabs"]');
      //<span class="tabbed-pane-header-tab-title" title="">Simple DevTools Extension</span>
      // Toggle to the last panel in Chrome DevTools:
      await devToolsPage.keyboard.down(_modifierKey);
      await devToolsPage.keyboard.press(Key.allKeys[r'$']!);
      await devToolsPage.keyboard.press(_modifierKey);*/
      // Set the panel target type to be a "page":
      var panelTarget = await browser
          .waitForTarget((target) => target.url.contains('panel.html'));

      panelTarget.type = 'page';
      var panelPage = await panelTarget.page;
      // The DOM added by the Chrome Extension is in the panel's frame:
      var frame = panelPage.frames[0];
      var panelElement = await frame.$OrNull('#simple-devtools-extension');
      expect(panelElement, isNotNull);
    });
  });
}

Key get _modifierKey => Platform.isMacOS ? Key.meta : Key.control;

Directory _createUserDataDirectory({Map<String, dynamic>? preferences}) {
  var dir = Directory.systemTemp.createTempSync('user_pref');
  var defaultDir = Directory(p.join(dir.path, 'Default'))
    ..createSync(recursive: true);
  if (preferences != null) {
    File(p.join(defaultDir.path, 'Preferences'))
        .writeAsStringSync(jsonEncode(preferences));
  }
  return dir;
}
