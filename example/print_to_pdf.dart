import 'dart:convert';
import 'dart:io';
import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chrome_downloader.dart';
import 'package:chrome_dev_tools/domains/emulation.dart';
import 'package:chrome_dev_tools/domains/page.dart';
import 'package:chrome_dev_tools/src/wait_until.dart';
import 'package:logging/logging.dart';

main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  String chromePath = (await downloadChrome()).executablePath;

  Chrome chrome = await Chrome.launch(chromePath, headless: true);

  TargetID targetId =
      await chrome.targets.createTarget('https://www.github.com');
  Session session = await chrome.connection.createSession(targetId);

  PageManager page = new PageManager(session);

  // Force the "screen" media or some CSS @media print can change the look
  EmulationManager emulation = new EmulationManager(session);
  await emulation.setEmulatedMedia('screen');

  await waitUntilNetworkIdle(session);

  List<int> pdf = BASE64.decode(await page.printToPDF(
      pageRanges: '1',
      landscape: true,
      printBackground: true,
      marginBottom: 0,
      marginLeft: 0,
      marginRight: 0,
      marginTop: 0));

  await new File.fromUri(Platform.script.resolve('_github.pdf'))
      .writeAsBytes(pdf);

  await chrome.close();
}
