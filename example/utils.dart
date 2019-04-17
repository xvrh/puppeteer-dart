import 'dart:async';
import 'dart:io';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/chrome_downloader.dart';
import 'package:chrome_dev_tools/src/page.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';
import 'package:path/path.dart' as p;

Future chromeTab(String url, Function(Tab) callback,
    {bool setupLogger = true}) async {
  if (setupLogger) {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen(print);
  }

  String chromeExecutable = (await downloadChrome()).executablePath;
  Chrome chrome = await Chrome.start(chromeExecutable);
  Tab tab = await chrome.newTab();

  try {
    await callback(tab);
  } finally {
    await chrome.close();
  }
}

Future chromePage(Function(Page) callback,
    {bool setupLogger = true}) async {
  if (setupLogger) {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen(print);
  }

  String chromeExecutable = (await downloadChrome()).executablePath;
  Chrome chrome = await Chrome.start(chromeExecutable);
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

Future tabOnPage(String path, Function(Tab) callback) async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  await server((String url) async {
    await chromeTab(p.url.join(url, path), (Tab tab) async {
      await callback(tab);
    });
  });
}

Future page(String path, Function(Page) callback) async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  await server((String url) async {
    await chromePage(p.url.join(url, path), (Page page) async {
      await callback(page);
    });
  });
}
