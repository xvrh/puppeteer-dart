import 'dart:async';
import 'package:logging/logging.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

void main() async {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);

  var handler = createStaticHandler('example');
  var server = await io.serve(handler, 'localhost', 0);

  var chrome = await puppeteer.launch();

  var pageUrl = 'http://localhost:${server.port}/html/incognito.html';
  var normalTab1 = await chrome.newPage();
  var normalTab2 = await chrome.newPage();
  var incognitoContext = await chrome.createIncognitoBrowserContext();
  var incognitoTab1 = await incognitoContext.newPage();

  await Future.wait([
    normalTab1.goto(pageUrl, wait: Until.networkIdle),
    normalTab2.goto(pageUrl, wait: Until.networkIdle),
    incognitoTab1.goto(pageUrl, wait: Until.networkIdle),
  ]);

  await normalTab1.evaluate('window.localStorage.setItem("name", "xavier")');

  var itemValue =
      await normalTab2.evaluate<String>('window.localStorage.getItem("name")');
  assert(itemValue == 'xavier');

  var incognitoValue = await incognitoTab1
      .evaluate<String?>('window.localStorage.getItem("name")');
  assert(incognitoValue == null);

  print('$itemValue vs $incognitoValue');
  await chrome.close();

  await server.close(force: true);
}
