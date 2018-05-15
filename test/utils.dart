import 'dart:async';
import 'dart:io';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/domains/log.dart';

// In travis/docker we need the --no-sandbox flag in chrome
bool get forceNoSandboxFlag =>
    Platform.isLinux && Platform.environment['TRAVIS'] == 'true';

Future waitForLog(Tab tab, String logToContain) async {
  await tab.log.enable();

  await for (LogEntry log in tab.log.onEntryAdded) {
    if (log.text.contains(logToContain)) {
      return;
    }
  }
}
