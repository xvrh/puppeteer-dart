import 'dart:async';
import 'dart:io';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chrome_downloader.dart';
import 'package:chrome_dev_tools/domains/log.dart';
import 'package:chrome_dev_tools/src/page.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

Future waitForLog(Tab tab, String logToContain) async {
  await for (LogEntry log in tab.log.onEntryAdded) {
    if (log.text.contains(logToContain)) {
      return;
    }
  }
}

Future chromeTab(String url, Function(Tab) callback) async {
  String chromeExecutable = (await downloadChrome()).executablePath;
  Chrome chrome = await Chrome.start(chromeExecutable);
  Tab tab = await chrome.newTab(url);

  try {
    await callback(tab);
  } finally {
    await chrome.close();
  }
}

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

class ChromeTester {
  Chrome chrome;
  String url;
  HttpServer server;

  ChromeTester._();

  static ChromeTester create(String serveDirectory) {
    ChromeTester chrome = ChromeTester._();
    chrome._setup(serveDirectory);
    return chrome;
  }

  _setup(String serveDirectory) {
    setUpAll(() async {
      String chromeExecutable = (await downloadChrome()).executablePath;
      chrome = await Chrome.start(chromeExecutable);

      var handler = createStaticHandler(serveDirectory);
      var host = 'localhost';
      server = await io.serve(handler, host, 0);
      url = 'http://$host:${server.port}';
    });

    tearDownAll(() async {
      await chrome.close();
      await server.close(force: true);
    });
  }

  Future<Tab> newTab(String page) {
    return chrome.newTab(p.url.join(url, page));
  }

  Future<Page> newPage(String page) {
    return chrome.newPage(p.url.join(url, page));
  }
}
