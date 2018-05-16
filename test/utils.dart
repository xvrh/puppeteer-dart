import 'dart:async';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/domains/log.dart';

Future waitForLog(Tab tab, String logToContain) async {
  await tab.log.enable();

  await for (LogEntry log in tab.log.onEntryAdded) {
    if (log.text.contains(logToContain)) {
      return;
    }
  }
}
