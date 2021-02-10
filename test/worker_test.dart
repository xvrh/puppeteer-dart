import 'dart:async';
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
    await browser.close();
    await server.close();
  });

  setUp(() async {
    context = await browser.createIncognitoBrowserContext();
    page = await context.newPage();
  });

  tearDown(() async {
    server.clearRoutes();
    await page.close();
  });

  group('Workers', () {
    test('Page.workers', () async {
      await Future.wait([
        page.onWorkerCreated.first,
        page.goto(server.prefix + '/worker/worker.html')
      ]);
      var worker = page.workers[0];
      expect(worker.url, contains('worker.js'));

      expect(await worker.evaluate('() => self.workerFunction()'),
          equals('worker function result'));

      await page.goto(server.emptyPage);
      expect(page.workers.length, equals(0));
    });

    test('should emit created and destroyed events', () async {
      var workerCreatedFuture = page.onWorkerCreated.first;
      var workerObj = await page
          .evaluateHandle("() => new Worker('data:text/javascript,1')");
      var worker = await workerCreatedFuture;
      var workerThisObj = await worker.evaluateHandle('() => this');
      var workerDestroyedFuture = page.onWorkerDestroyed.first;
      await page
          .evaluate('workerObj => workerObj.terminate()', args: [workerObj]);
      expect(await workerDestroyedFuture, equals(worker));
      expect(
          () => workerThisObj.property('self'),
          throwsA(predicate((e) =>
              '$e'.contains('Most likely the worker has been closed.'))));
    });
    test('should report console logs', () async {
      var message = await waitFutures(page.onConsole.first, [
        page.evaluate(
            '() => new Worker(`data:text/javascript,console.log(1)`)'),
      ]);
      expect(message.text, equals('1'));
      expect(message.url, equals(''));
      expect(message.lineNumber, equals(0));
      expect(message.columnNumber, equals(8));
    });
    test('should have JSHandles for console logs', () async {
      var logPromise = page.onConsole.first;
      await page.evaluate(
          '() => new Worker(`data:text/javascript,console.log(1,2,3,this)`)');
      var log = await logPromise;
      expect(log.text, equals('1 2 3 JSHandle@object'));
      expect(log.args.length, equals(4));
      expect(await (await log.args[3].property('origin')).jsonValue,
          equals('null'));
    });
    test('should have an execution context', () async {
      var workerCreatedPromise = page.onWorkerCreated.first;
      await page
          .evaluate('() => new Worker(`data:text/javascript,console.log(1)`)');
      var worker = await workerCreatedPromise;
      expect(await (await worker.executionContext).evaluate('1+1'), equals(2));
    });
    test('should report errors', () async {
      var errorPromise = page.onError.first;
      await page.evaluate(
          "() => new Worker(`data:text/javascript, throw new Error('this is my error');`)");
      var errorLog = await errorPromise;
      expect(errorLog.message, contains('this is my error'));
    });
  });
}
