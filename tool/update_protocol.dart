import 'dart:async';
import 'package:http/http.dart';
import 'dart:io';

final Map<String, String> protocols = {
  'browser_protocol.json':
      'https://raw.githubusercontent.com/ChromeDevTools/devtools-protocol/master/json/browser_protocol.json',
  'js_protocol.json':
      'https://raw.githubusercontent.com/ChromeDevTools/devtools-protocol/master/json/js_protocol.json',
};

main() async {
  for (String protocolName in protocols.keys) {
    await _download(protocols[protocolName], protocolName);
  }
}

Future _download(String url, String fileName) async {
  String json = await read(url);
  await new File.fromUri(Platform.script.resolve(fileName)).writeAsString(json);
}
