import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:puppeteer/puppeteer.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

Future server(String location, Function(String) callback) async {
  var handler = createStaticHandler(location);

  var host = 'localhost';
  HttpServer server = await io.serve(handler, host, 0);
  try {
    await callback('http://$host:${server.port}');
  } finally {
    await server.close();
  }
}

class Server {
  static const _assetFolder = 'assets';
  HttpServer _httpServer;

  Server._();

  static Future<Server> create() async {
    Server server = Server._();
    await server._setup();
    return server;
  }

  Future _setup() async {
    var staticHandler = createStaticHandler('test/$_assetFolder');
    var host = 'localhost';
    _httpServer = await io.serve((request) {
      if (request.url.path.startsWith('$_assetFolder/')) {
        return staticHandler(request.change(path: _assetFolder));
      } else {
        // TODO(xha): tests can add custom handler.
        throw UnimplementedError();
      }
    }, host, 0);
  }

  String get hostUrl =>
      'http://${_httpServer.address.host}:${_httpServer.port}';

  String get prefix => p.url.join(hostUrl, _assetFolder);
  String get crossProcessPrefix =>
      p.url.join('http://127.0.0.1:${_httpServer.port}', _assetFolder);

  String get emptyPage => assetUrl('empty.html');

  String assetUrl(String page) {
    assert(!page.startsWith('/'));
    return p.url.join(hostUrl, _assetFolder, page);
  }

  Future close() => _httpServer.close(force: true);
}

Future attachFrame(Page page, String frameId, String url) async {
  var handle = await page.evaluateHandle(
      //language=js
      '''
async function attachFrame(frameId, url) {
    const frame = document.createElement('iframe');
    frame.src = url;
    frame.id = frameId;
    document.body.appendChild(frame);
    await new Promise(x => frame.onload = x);
    return frame;
  }  
''', args: [frameId, url]);
  return await handle.asElement.contentFrame;
}
