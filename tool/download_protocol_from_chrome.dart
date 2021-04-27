import 'dart:io';
import 'package:http/http.dart';
import 'package:puppeteer/puppeteer.dart';
import 'generate_protocol.dart';

/// Download the Chrome Dev Tools protocol (json file) directly from a running Chrome instance.
void main() async {
  var chrome = await puppeteer.launch();

  try {
    var url = Uri.parse(chrome.connection.url);
    url = url.replace(scheme: 'http', path: '/json/protocol');
    var response = await read(url);

    File('tool/json/$protocolFromChromeFile').writeAsStringSync(response);
  } finally {
    await chrome.close();
  }
}
