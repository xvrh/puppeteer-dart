import 'dart:io';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;
import 'package:puppeteer/puppeteer.dart';
import 'generate_protocol.dart';

/// Download the Chrome Dev Tools protocol (json file) directly from a running Chrome instance.
main() async {
  var chrome = await puppeteer.launch();

  try {
    var url = chrome.connection.url.replaceAll('ws://', 'http://');
    var response = await read(p.url.join(url, '/json/protocol'));

    File('tool/json/$protocolFromChromeFile').writeAsStringSync(response);
  } finally {
    await chrome.close();
  }
}
