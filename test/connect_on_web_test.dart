import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:puppeteer/puppeteer.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Test that we can use puppeteer.connect from a web page (dart compiled with Dart2js)
void main() {
  test('Can use puppeteer on the web', () async {
    var browser = await puppeteer.launch();
    var tempDirectory = Directory.systemTemp.createTempSync();

    late HttpServer httpServer;
    var router = Router()
      ..get('/index.html', (request) {
        return shelf.Response.ok('''
<html>
  <head>
    <title>Puppeteer</title>
    <script async src="/script.js"></script>
  </head>
 
  <body x-puppeteer-endpoint="ws://localhost:${httpServer.port}/proxy">
    <h1>Puppeteer</h1>
  </body>
</html>          
''', headers: {
          'content-type': 'text/html',
        });
      })
      // Since chromium 111, the chromium devtools server doesn't accept a connection from a web page
      // The test workaround this by adding a proxy in-between.
      // Ideally we can just pass x-puppeteer-endpoint="${browser.wsEndpoint}" in the html
      ..mount('/proxy', webSocketHandler((WebSocketChannel webSocket) async {
        var browserSocket = await WebSocket.connect(browser.wsEndpoint);
        var websocketSubscription = webSocket.stream.listen((message) {
          browserSocket.add(message);
        }, onDone: () {
          browserSocket.close();
        });
        browserSocket.listen((event) {
          webSocket.sink.add(event);
        }, onDone: () {
          websocketSubscription.cancel();
        });
      }))
      ..mount('/', createStaticHandler(tempDirectory.path));

    httpServer = await shelf.serve(router, InternetAddress.anyIPv4, 0);

    try {
      var jsFile = p.join(tempDirectory.path, 'script.js');
      var compileResult = await Process.run(Platform.resolvedExecutable, [
        'compile',
        'js',
        '--output',
        jsFile,
        'test/connect_on_web_part.dart'
      ]);
      expect(compileResult.exitCode, 0,
          reason: '${compileResult.stdout}\n${compileResult.stderr}');
      assert(File(jsFile).existsSync());

      var page = await browser.newPage();
      await page.goto('http://localhost:${httpServer.port}/index.html');

      await page.onConsole
          .firstWhere((e) => e.text == 'Hello from puppeteer in js');
    } finally {
      await httpServer.close();
      tempDirectory.deleteSync(recursive: true);
      await browser.close();
    }
  }, timeout: Timeout.factor(3));
}
