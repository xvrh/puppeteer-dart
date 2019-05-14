import 'dart:async';
import '../puppeteer.dart';
import 'puppeteer.dart';

abstract class Plugin {
  FutureOr<LaunchOptions> willLaunchBrowser(LaunchOptions options) => options;
  pageCreated(Page page) {}
}
