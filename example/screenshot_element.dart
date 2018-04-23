import 'dart:convert';
import 'dart:io';
import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chromium_downloader.dart';
import 'package:chrome_dev_tools/domains/page.dart';
import 'package:chrome_dev_tools/domains/runtime.dart';
import 'package:chrome_dev_tools/src/remote_object.dart';
import 'package:chrome_dev_tools/src/wait_until.dart';
import 'package:logging/logging.dart';

main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  Chromium chromium =
      await Chromium.launch((await downloadChromium()).executablePath);

  TargetID targetId =
      await chromium.targets.createTarget('https://www.github.com');
  Session session = await chromium.connection.createSession(targetId);

  await waitUntilNetworkIdle(session);

  RuntimeManager runtime = new RuntimeManager(session);
  var result = await runtime.evaluate(
      '''document.querySelector('form[action="/join"]').getBoundingClientRect();''');

  Map rect = await getProperties(session, result.result);

  Viewport clip = new Viewport(
      x: rect['x'],
      y: rect['y'],
      width: rect['width'],
      height: rect['height'],
      scale: 1);

  PageManager page = new PageManager(session);
  String screenshot = await page.captureScreenshot(clip: clip);

  await new File.fromUri(Platform.script.resolve('_github_form.png'))
      .writeAsBytes(BASE64.decode(screenshot));

  await chromium.close();
}
