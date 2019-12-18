import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:puppeteer/puppeteer.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  var handler = createStaticHandler('example');
  var server = await io.serve(handler, 'localhost', 0);

  var browser = await puppeteer.launch();
  var page = await browser.newPage();

  await page.goto(p.url.join(
      'http://${server.address.host}:${server.port}', 'html/keyboard.html'));

  var input = await page.$('input');

  await input.focus();

  await page.bringToFront();

  await page.keyboard.type('éèà Hello');

  await page.keyboard.down(Key.shift);
  await page.keyboard.press(Key.arrowLeft);
  await page.keyboard.press(Key.arrowLeft);
  await page.keyboard.press(Key.backspace);
  await page.keyboard.up(Key.shift);
  await page.keyboard.press(Key.arrowLeft);
  await page.keyboard.press(Key.arrowLeft);

  var screenshot = await input.screenshot();
  File('example/_input.png').writeAsBytesSync(screenshot);

  await browser.close();
  await server.close();
  // Tester les events sur la page: http://w3c.github.io/uievents/tools/key-event-viewer?
}
