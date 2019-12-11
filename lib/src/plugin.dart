import 'dart:async';
import '../puppeteer.dart';
import 'puppeteer.dart';

abstract class Plugin {
  FutureOr<LaunchOptions> willLaunchBrowser(LaunchOptions options) => options;
  Future<void> pageCreated(Page page) async {}
}
