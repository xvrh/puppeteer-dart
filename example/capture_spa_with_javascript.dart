import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chromium_downloader.dart';
import 'package:chrome_dev_tools/domains/runtime.dart';
import 'package:chrome_dev_tools/src/wait_until.dart';
import 'package:logging/logging.dart';

main() async {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);

  Chromium chromium =
      await Chromium.launch((await downloadChromium()).executablePath);

  TargetID targetId =
      await chromium.targets.createTarget('https://news.ycombinator.com/news');
  Session session = await chromium.connection.createSession(targetId);

  await waitUntilNetworkIdle(session);

  RuntimeManager runtime = new RuntimeManager(session);
  var result = await runtime.evaluate('document.documentElement.outerHTML;',
      returnByValue: true);

  String pageContent = result.result.value;
  print(pageContent);

  await chromium.close();
}
