library;

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:puppeteer/puppeteer.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf;
import 'package:shelf_static/shelf_static.dart';
import 'package:test/test.dart';

// Test that we can use puppeteer.connect from a web page (dart compiled with Dart2js)
void main() {
  // Guards WASM compatibility: `puppeteer.connect()` and the page API must stay
  // reachable without `dart:io` (which would otherwise leak in via the
  // web-unreachable launch/download paths). If this fails, a `dart:io` import
  // crept into the web-reachable graph — use `lib/src/io/io.dart` instead.
  test('connect() entrypoint compiles to WASM', () async {
    var tempDirectory = Directory.systemTemp.createTempSync();
    try {
      var wasmFile = p.join(tempDirectory.path, 'script.wasm');
      var compileResult = await Process.run(Platform.resolvedExecutable, [
        'compile',
        'wasm',
        '--output',
        wasmFile,
        'test/connect_on_web_part.dart',
      ]);
      expect(
        compileResult.exitCode,
        0,
        reason:
            'Compiling the connect() entrypoint to WASM failed. A `dart:io` '
            'import likely leaked into the web-reachable graph.\n'
            '${compileResult.stdout}\n${compileResult.stderr}',
      );
      expect(File(wasmFile).existsSync(), isTrue);
    } finally {
      tempDirectory.deleteSync(recursive: true);
    }
  }, timeout: Timeout.factor(6));

  test('Can use puppeteer on the web compiled to WASM', () async {
    var browser = await puppeteer.launch(args: ['--remote-allow-origins=*']);
    var tempDirectory = Directory.systemTemp.createTempSync();

    String contentTypeFor(String path) {
      if (path.endsWith('.wasm')) return 'application/wasm';
      if (path.endsWith('.mjs') || path.endsWith('.js')) {
        return 'text/javascript';
      }
      return 'application/octet-stream';
    }

    var httpServer = await shelf.serve(
      (request) async {
        var uri = request.requestedUri;
        if (uri.path == '/index.html') {
          return shelf.Response.ok(
            '''
<html>
  <head><title>Puppeteer</title></head>
  <body x-puppeteer-endpoint="${browser.wsEndpoint}">
    <h1>Puppeteer</h1>
    <script type="module">
      import { compile } from '/script.mjs';
      const bytes = await (await fetch('/script.wasm')).arrayBuffer();
      const app = await compile(bytes);
      const instantiated = await app.instantiate({});
      instantiated.invokeMain();
    </script>
  </body>
</html>
''',
            headers: {'content-type': 'text/html'},
          );
        } else if (uri.path == '/favicon.ico') {
          return shelf.Response.ok('');
        }

        var file = File(p.join(tempDirectory.path, p.basename(uri.path)));
        if (file.existsSync()) {
          return shelf.Response.ok(
            file.readAsBytesSync(),
            headers: {'content-type': contentTypeFor(uri.path)},
          );
        }
        return shelf.Response.notFound('');
      },
      InternetAddress.anyIPv4,
      0,
    );

    try {
      var compileResult = await Process.run(Platform.resolvedExecutable, [
        'compile',
        'wasm',
        '--output',
        p.join(tempDirectory.path, 'script.wasm'),
        'test/connect_on_web_part.dart',
      ]);
      expect(
        compileResult.exitCode,
        0,
        reason: '${compileResult.stdout}\n${compileResult.stderr}',
      );

      var page = await browser.newPage();
      await page.goto('http://localhost:${httpServer.port}/index.html');

      await page.onConsole.firstWhere(
        (e) => e.text == 'Hello from puppeteer in js',
      );
    } finally {
      await httpServer.close();
      tempDirectory.deleteSync(recursive: true);
      await browser.close();
    }
  }, timeout: Timeout.factor(6));

  test('Can use puppeteer on the web (directly)', () async {
    var browser = await puppeteer.launch(args: ['--remote-allow-origins=*']);
    var tempDirectory = Directory.systemTemp.createTempSync();

    var httpServer = await shelf.serve(
      (request) async {
        var uri = request.requestedUri;
        if (uri.path == '/script.js') {
          return createStaticHandler(tempDirectory.path)(request);
        } else if (uri.path == '/index.html') {
          return shelf.Response.ok(
            '''
<html>
  <head>
    <title>Puppeteer</title>
    <script async src="/script.js"></script>
  </head>
  <body x-puppeteer-endpoint="${browser.wsEndpoint}">
    <h1>Puppeteer</h1>
  </body>
</html>          
''',
            headers: {'content-type': 'text/html'},
          );
        } else if (uri.path == '/favicon.ico') {
          return shelf.Response.ok('');
        } else {
          return shelf.Response.notFound('');
        }
      },
      InternetAddress.anyIPv4,
      0,
    );

    try {
      var jsFile = p.join(tempDirectory.path, 'script.js');
      var compileResult = await Process.run(Platform.resolvedExecutable, [
        'compile',
        'js',
        '--output',
        jsFile,
        'test/connect_on_web_part.dart',
      ]);
      expect(
        compileResult.exitCode,
        0,
        reason: '${compileResult.stdout}\n${compileResult.stderr}',
      );
      assert(File(jsFile).existsSync());

      var page = await browser.newPage();
      await page.goto('http://localhost:${httpServer.port}/index.html');

      await page.onConsole.firstWhere(
        (e) => e.text == 'Hello from puppeteer in js',
      );
    } finally {
      await httpServer.close();
      tempDirectory.deleteSync(recursive: true);
      await browser.close();
    }
  }, timeout: Timeout.factor(3));
}
