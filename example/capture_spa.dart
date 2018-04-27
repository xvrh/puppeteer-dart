import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chrome_downloader.dart';
import 'package:chrome_dev_tools/domains/dom_snapshot.dart';
import 'package:chrome_dev_tools/src/wait_until.dart';
import 'package:logging/logging.dart';

main() async {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);

  Chrome chrome = await Chrome.launch((await downloadChrome()).executablePath);

  TargetID targetId =
      await chrome.targets.createTarget('https://www.google.com');
  Session session = await chrome.connection.createSession(targetId);

  await waitUntilNetworkIdle(session);

  DOMSnapshotManager dom = new DOMSnapshotManager(session);
  var result = await dom.getSnapshot([]);

  for (DOMNode node in result.domNodes) {
    String nodeString = '<${node.nodeName}';
    if (node.attributes != null) {
      nodeString +=
          ' ${node.attributes.map((n) => '${n.name}=${n.value}').toList()}';
    }
    nodeString += '>';
    print(nodeString);
  }

  await chrome.close();
}
