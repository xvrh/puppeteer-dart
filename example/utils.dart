import 'dart:async';
import 'dart:io';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chrome_downloader.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';
import 'package:path/path.dart' as p;

void setupLogger() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);
}

Future chromeTab(Function(Tab) callback) async {
  Chrome chrome = await Chrome.start();
  Tab tab = await chrome.newTab();

  try {
    await callback(tab);
  } finally {
    await chrome.close();
  }
}

Future chromePage(Function(Page) callback) async {
  Chrome chrome = await Chrome.start();
  Page page = await chrome.newPage();

  try {
    await callback(page);
  } finally {
    await chrome.close();
  }
}

Future server(Function(String) callback) async {
  var handler = createStaticHandler('example');

  var host = 'localhost';
  HttpServer server = await io.serve(handler, host, 0);
  try {
    await callback('http://$host:${server.port}');
  } finally {
    await server.close();
  }
}

Future page(Function(Page, String hostUrl) callback) async {
  await server((String url) async {
    await chromePage((Page page) async {
      await callback(page, url);
    });
  });
}
