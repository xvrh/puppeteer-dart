import 'dart:io';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;

import 'generate_domains.dart';

/// Download the Chrome Dev Tools protocol (json file) directly from a running Chrome instance.
main() async {
  Chrome chrome = await Chrome.start();

  try {
    String url = chrome.connection.url.replaceAll('ws://', 'http://');
    String response = await read(p.url.join(url, '/json/protocol'));

    new File('tool/json/$protocolFromChromeFile').writeAsStringSync(response);
  } finally {
    await chrome.close();
  }
}
