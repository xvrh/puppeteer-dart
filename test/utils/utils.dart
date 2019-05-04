import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:puppeteer/puppeteer.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

export 'package:shelf/shelf.dart' show Request, Response;

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

typedef _RouteCallback = FutureOr<Response> Function(Request);

class Server {
  HttpServer _httpServer;
  final _routes = CanonicalizedMap<String, String, _RouteCallback>(
      (key) => p.url.normalize(_removeLeadingSlash(key)));
  final _requestCallbacks =
      CanonicalizedMap<String, String, Completer<Request>>(
          (key) => p.url.normalize(_removeLeadingSlash(key)));

  Server._();

  static Future<Server> create() async {
    Server server = Server._();
    await server._setup();
    return server;
  }

  Future _setup() async {
    var staticHandler = createStaticHandler('test/assets');
    _httpServer = await io.serve((request) async {
      var notificationCompleter = _requestCallbacks[request.url.toString()];
      if (notificationCompleter != null) {
        notificationCompleter.complete(request);
        _requestCallbacks.remove(request.url.toString());
      }

      var callback = _routes[request.url.path];
      if (callback != null) {
        return callback(request);
      } else {
        Response staticResponse = await staticHandler(request);
        staticResponse
            .change(headers: {HttpHeaders.cacheControlHeader: 'no-cache'});
        return staticResponse;
      }
    }, InternetAddress.anyIPv4, 0);
  }

  String get hostUrl => 'http://localhost:${_httpServer.port}';

  int get port => _httpServer.port;

  String get docExamplesUrl => assetUrl('doc_examples.html');

  String get docExamples2Url => assetUrl('doc_examples_2.html');

  String get prefix => hostUrl;

  String get crossProcessPrefix => 'http://127.0.0.1:${_httpServer.port}';

  String get emptyPage => assetUrl('empty.html');

  String get empty2Page => assetUrl('empty2.html');

  String assetUrl(String page) {
    page = _removeLeadingSlash(page);
    return p.url.join(hostUrl, page);
  }

  static String _removeLeadingSlash(String path) {
    if (path.startsWith('/')) {
      return path.substring(1);
    }
    return path;
  }

  void setRoute(
      String url, FutureOr<Response> Function(Request request) callback) {
    _routes[url] = callback;
  }

  void setRedirect(String from, String to) {
    setRoute(from, (request) {
      if (!to.contains('://')) {
        to = assetUrl(to);
      }
      return Response.found(to);
    });
  }

  void clearRoutes() {
    _routes.clear();
    _requestCallbacks.clear();
  }

  Future<Request> waitForRequest(String path) {
    return (_requestCallbacks[_removeLeadingSlash(path)] ??=
            Completer<Request>())
        .future;
  }

  Future close() => _httpServer.close(force: true);
}

Future<PageFrame> attachFrame(Page page, String frameId, String url) async {
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

Future<void> detachFrame(Page page, String frameId) async {
  await page.evaluate('''
function detachFrame(frameId) {
    const frame = document.getElementById(frameId);
    frame.remove();
  }
''', args: [frameId]);
}

Future<T> waitFutures<T>(Future<T> firstFuture, List<Future> others) async {
  List<Future> futures = [firstFuture]..addAll(others);
  return (await Future.wait(futures))[0];
}

Future<void> navigateFrame(Page page, String frameId, String url) async {
  await page.evaluate('''
function navigateFrame(frameId, url) {
  const frame = document.getElementById(frameId);
  frame.src = url;
  return new Promise(x => frame.onload = x);
}  
''', args: [frameId, url]);
}

dumpFrames(PageFrame frame, [String indentation]) {
  indentation ??= '';
  var description = frame.url.replaceAll(RegExp(r'//[^/]+/'), '//<host>/');
  if (frame.name != null) description += ' (' + frame.name + ')';
  var result = [indentation + description];
  for (var child in frame.childFrames)
    result.addAll(dumpFrames(child, '    ' + indentation));
  return result;
}
