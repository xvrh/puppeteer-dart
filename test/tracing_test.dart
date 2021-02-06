import 'dart:convert';
import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils/utils.dart';

// ignore_for_file: prefer_interpolation_to_compose_strings

void main() {
  late Server server;
  late Browser browser;
  late BrowserContext context;
  late Page page;
  setUpAll(() async {
    server = await Server.create();
    browser = await puppeteer.launch();
  });

  tearDownAll(() async {
    await server.close();
    await browser.close();
  });

  setUp(() async {
    context = await browser.createIncognitoBrowserContext();
    page = await context.newPage();
  });

  tearDown(() async {
    server.clearRoutes();
    await context.close();
  });

  group('Tracing', () {
    test('should output a trace', () async {
      await page.tracing.start(screenshots: true);
      await page.goto(server.prefix + '/grid.html');
      var result = StringBuffer();
      await page.tracing.stop(result);
      expect(result.toString().length, greaterThan(0));
    });
    test('should run with custom categories if provided', () async {
      await page.tracing
          .start(categories: ['disabled-by-default-v8.cpu_profiler.hires']);
      var buffer = StringBuffer();
      await page.tracing.stop(buffer);
      var traceJson = jsonDecode(buffer.toString()) as Map<String, dynamic>;

      expect(traceJson['metadata']['trace-config'],
          contains('disabled-by-default-v8.cpu_profiler.hires'));
    });
    test('should throw if tracing on two pages', () async {
      await page.tracing.start();
      var newPage = await browser.newPage();
      await expectLater(() => newPage.tracing.start(), throwsA(anything));
      await newPage.close();
      await page.tracing.stop(StringBuffer());
    });
    test('should work without options', () async {
      await page.tracing.start();
      await page.goto(server.prefix + '/grid.html');
      var buffer = StringBuffer();
      await page.tracing.stop(buffer);
      expect(buffer.toString(), isNotNull);
    });
  });
}
