import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';
import 'package:path/path.dart' as p;

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
  await File.fromUri(Platform.script.resolve(p.posix.join('json', fileName)))
      .writeAsString(json);
}
