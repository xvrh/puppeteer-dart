import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chromium_downloader.dart';
import 'package:chrome_dev_tools/domains/dom_snapshot.dart';
import 'package:chrome_dev_tools/src/wait_until.dart';
import 'package:logging/logging.dart';

main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  Chromium chromium = await Chromium.launch(await downloadChromium());

  TargetID targetId =
      await chromium.targets.createTarget('https://www.google.com');
  Session session = await chromium.connection.createSession(targetId);

  await waitUntilNetworkIdle(session);

  DOMSnapshotDomain dom = new DOMSnapshotDomain(session);
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

  await chromium.close();
}
