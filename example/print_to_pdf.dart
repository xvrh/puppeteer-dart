import 'dart:convert';
import 'dart:io';
import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/src/connection.dart';
import 'package:chrome_dev_tools/domains/network.dart';
import 'package:chrome_dev_tools/domains/page.dart';
import 'package:chrome_dev_tools/domains/target.dart';
import 'package:chrome_dev_tools/src/wait_until.dart';
import 'package:logging/logging.dart';

//TODO(xha): manage an internal version of chromium
const _chromePath =
    r'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe';

const _canary =
    r'C:\Users\xavier.hainaux\AppData\Local\Google\Chrome SxS\Application\chrome.exe';

main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  Chrome chrome = await Chrome.launch(_canary, headless: true);

  TargetID targetId = await chrome.targets.createTarget('https://github.com');
  Session session = await chrome.connection.createSession(targetId);

  PageManager page = new PageManager(session);

  NetworkManager networkManager = new NetworkManager(session);
  await networkManager.enable();
  await waitUntilNetworkIdle(networkManager);

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

  chrome.kill();
  await chrome.onClose;
  exit(0);
}
