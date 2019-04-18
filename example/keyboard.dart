import 'dart:io';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/domains/dom.dart';
import 'package:chrome_dev_tools/domains/runtime.dart';
import 'package:chrome_dev_tools/src/page/keyboard.dart';
import 'package:path/path.dart' as p;

import 'utils.dart';

//http://w3c.github.io/uievents/tools/key-event-viewer
main() async {
  await page((Page page, String url) async {
    await page.goto(p.url.join(url, 'html/keyboard.html'));

    Node document = await page.tab.dom.getDocument();

    NodeId input = await page.tab.dom.querySelector(document.nodeId, 'input');
    RemoteObject element = await page.tab.dom.resolveNode(nodeId: input);

    await page.tab.dom.focus(nodeId: input);

    await page.bringToFront();

    await page.keyboard.type("éèà Hello");

    await page.keyboard.down(Key.shift);
    await page.keyboard.press(Key.arrowLeft);
    await page.keyboard.press(Key.arrowLeft);
    await page.keyboard.press(Key.backspace);
    await page.keyboard.up(Key.shift);
    await page.keyboard.press(Key.arrowLeft);
    await page.keyboard.press(Key.arrowLeft);

    var properties = await page.tab.remoteObjectProperties(element);
    print(properties['value']);

    print(properties);

    var screenshot = await (await page.$('input')).screenshot();
    File('example/_input.png').writeAsBytesSync(screenshot);

    // - Ecrire du texte
    // - revenir en arrière et effacer certains mot (flèches + backspace)
    // - Gérer la selection (flèche, ctrl, backspace)
    // - faire les raccourcit clavier


    // Tester les events sur la page: http://w3c.github.io/uievents/tools/key-event-viewer?
  });
}
