import 'dart:io';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chrome_downloader.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;

const protocolFile = 'protocol_from_chrome.json';

/// Download the Chrome Dev Tools protocol (json file) directly from a running Chrome instance.
main() async {
  String chromePath =
      (await downloadChrome(cachePath: '_chrome')).executablePath;
  Chrome chrome = await Chrome.start(chromePath);

  try {
    String url = chrome.connection.url.replaceAll('ws://', 'http://');
    String response = await read(p.url.join(url, '/json/protocol'));

    new File('tool/json/$protocolFile').writeAsStringSync(response);
  } finally {
    await chrome.close();
  }
}
