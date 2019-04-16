import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/domains/dom.dart';
import 'package:chrome_dev_tools/domains/runtime.dart';
import 'package:chrome_dev_tools/src/page.dart';
import 'package:chrome_dev_tools/src/page/keyboard.dart';

import 'utils.dart';

//http://w3c.github.io/uievents/tools/key-event-viewer
main() async {
  await page('html/keyboard.html', (Page page) async {
    await page.tab.waitUntilNetworkIdle();

    Node document = await page.tab.dom.getDocument();

    NodeId input = await page.tab.dom.querySelector(document.nodeId, 'input');
    RemoteObject element = await page.tab.dom.resolveNode(nodeId: input);

    await page.tab.dom.focus(nodeId: input);

    await page.keyboard.type("éàê Hello");

    await page.keyboard.down(Key.shift);
    await page.keyboard.press(Key.arrowLeft);
    await page.keyboard.press(Key.arrowLeft);
    await page.keyboard.press(Key.backspace);
    await page.keyboard.up(Key.shift);


    var properties = await page.tab.remoteObjectProperties(element);
    print(properties['value']);

    print(properties);


    // - Ecrire du texte
    // - revenir en arrière et effacer certains mot (flèches + backspace)
    // - Gérer la selection (flèche, ctrl, backspace)
    // - faire les raccourcit clavier


    // Tester les events sur la page: http://w3c.github.io/uievents/tools/key-event-viewer?
  });
}
