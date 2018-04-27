import 'dart:async';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:io';

const _inspectorJson =
    'https://chromium.googlesource.com/chromium/src/+/master/third_party/blink/renderer/core/inspector/browser_protocol-1.3.json?format=TEXT';
const _v8Json =
    'https://chromium.googlesource.com/v8/v8/+/master/src/inspector/js_protocol.json?format=TEXT';

main() async {
  await _download(_inspectorJson, 'browser_protocol.json');
  await _download(_v8Json, 'js_protocol.json');
}

Future _download(String url, String fileName) async {
  List<int> json = BASE64.decode(await read(url));
  await new File.fromUri(Platform.script.resolve(fileName)).writeAsBytes(json);
}
