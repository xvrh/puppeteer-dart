import 'dart:io';

import 'package:http/http.dart';
import 'package:path/path.dart' as p;
import 'package:puppeteer/puppeteer.dart';

import 'generate_domains.dart';

/// Download the Chrome Dev Tools protocol (json file) directly from a running Chrome instance.
main() async {
  Browser chrome = await Browser.start();

  try {
    String url = chrome.connection.url.replaceAll('ws://', 'http://');
    String response = await read(p.url.join(url, '/json/protocol'));

    new File('tool/json/$protocolFromChromeFile').writeAsStringSync(response);
  } finally {
    await chrome.close();
  }
}
