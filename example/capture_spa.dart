import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/domains/dom_snapshot.dart';
import 'utils.dart';

main() {
  chromeTab('https://www.google.com', (Tab tab) async {
    // A small helper to wait until the network is quiet
    await tab.waitUntilNetworkIdle();

    // Take a snapshot of the DOM of the current page
    GetSnapshotResult result = await tab.domSnapshot.getSnapshot([]);

    // Iterate the nodes and output some HTML.
    for (DOMNode node in result.domNodes) {
      String nodeString = '<${node.nodeName}';
      if (node.attributes != null) {
        nodeString +=
            ' ${node.attributes.map((n) => '${n.name}=${n.value}').toList()}';
      }
      nodeString += '>';
      print(nodeString);
    }
  });
}
