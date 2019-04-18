import 'dart:async';
import 'dart:io';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

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

class TestUtils {
  Chrome chrome;
  String _hostUrl;
  HttpServer server;

  TestUtils._();

  static TestUtils create() {
    TestUtils utils = TestUtils._();
    utils._setup();
    return utils;
  }

  _setup() {
    setUpAll(() async {
      chrome = await Chrome.start();

      var staticHandler = createStaticHandler('test/assets');
      var host = 'localhost';
      server = await io.serve((request) {
        if (request.url.path.startsWith('assets/')) {
          return staticHandler(request.change(path: 'assets'));
        } else {
          // TODO(xha): tests can add custom handler.

          throw UnimplementedError();
        }
      }, host, 0);
      _hostUrl = 'http://$host:${server.port}';
    });

    tearDownAll(() async {
      await chrome.close();
      await server.close(force: true);
    });
  }

  String get hostUrl => _hostUrl;

  String assetUrl(String page) {
    return p.url.join(_hostUrl, 'assets', page);
  }

  Future<Tab> newTab(String page) {
    return chrome.newTab();
  }

  Future<Page> newPage(String page) {
    return chrome.newPage();
  }
}
