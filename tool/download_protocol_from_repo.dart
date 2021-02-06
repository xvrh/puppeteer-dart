import 'dart:async';
import 'dart:io';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;

final protocols = {
  'browser_protocol.json':
      'https://raw.githubusercontent.com/ChromeDevTools/devtools-protocol/master/json/browser_protocol.json',
  'js_protocol.json':
      'https://raw.githubusercontent.com/ChromeDevTools/devtools-protocol/master/json/js_protocol.json',
};

void main() async {
  for (var protocol in protocols.entries) {
    await _download(Uri.parse(protocol.value), protocol.key);
  }
}

Future<void> _download(Uri url, String fileName) async {
  var json = await read(url);
  await File.fromUri(Platform.script.resolve(p.posix.join('json', fileName)))
      .writeAsString(json);
}
