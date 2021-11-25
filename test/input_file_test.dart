import 'dart:async';
import 'dart:io';
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

  const fileToUpload = 'test/assets/file-to-upload.txt';

  group('input', () {
    test('should upload the file', () async {
      await page.goto(server.prefix + '/input/fileupload.html');
      var filePath = File(fileToUpload);
      var input = await page.$('input');
      await input.uploadFile([filePath]);
      expect(await page.evaluate('e => e.files[0].name', args: [input]),
          equals('file-to-upload.txt'));
      expect(await page.evaluate('e => e.files[0].type', args: [input]),
          'text/plain');
      expect(await page.evaluate('''e => {
      var reader = new FileReader();
      var promise = new Promise(fulfill => reader.onload = fulfill);
      reader.readAsText(e.files[0]);
      return promise.then(() => reader.result);
      }''', args: [input]), equals('contents of the file'));
    });
  });

  group('Page.waitForFileChooser', () {
    test('should work when file input is attached to DOM', () async {
      await page.setContent('<input type=file>');
      var chooser =
          await waitFutures(page.waitForFileChooser(), [page.click('input')]);
      expect(chooser, isNotNull);
    });
    test('should work when file input is not attached to DOM', () async {
      var chooser = await waitFutures(page.waitForFileChooser(), [
        page.evaluate('''() => {
        var el = document.createElement('input');
        el.type = 'file';
        el.click();
      }''')
      ]);

      expect(chooser, isNotNull);
    });
    test('should respect timeout', () async {
      expect(
          () =>
              page.waitForFileChooser(timeout: const Duration(milliseconds: 1)),
          throwsA(isA<TimeoutException>()));
    });
    test('should respect default timeout when there is no custom timeout',
        () async {
      page.defaultTimeout = Duration(milliseconds: 1);
      expect(() => page.waitForFileChooser(), throwsA(isA<TimeoutException>()));
    });
    test('should prioritize exact timeout over default timeout', () async {
      page.defaultTimeout = null;
      expect(
          () =>
              page.waitForFileChooser(timeout: const Duration(milliseconds: 1)),
          throwsA(isA<TimeoutException>()));
    });
    test('should work with no timeout', () async {
      var chooser = await waitFutures(page.waitForFileChooser(), [
        page.evaluate('''() => setTimeout(() => {
      var el = document.createElement('input');
      el.type = 'file';
      el.click();
      }, 50)''')
      ]);
      expect(chooser, isNotNull);
    });
    test(
        'should return the same file chooser when there are many watchdogs simultaneously',
        () async {
      await page.setContent('<input type=file>');
      var choosers = await Future.wait([
        page.waitForFileChooser(),
        page.waitForFileChooser(),
        page.$eval('input', 'input => input.click()'),
      ]);
      var fileChooser1 = choosers[0] as FileChooser;
      var fileChooser2 = choosers[1] as FileChooser;
      expect(fileChooser1, equals(fileChooser2));
    });
  });

  group('FileChooser.accept', () {
    test('should accept single file', () async {
      await page.setContent(
          '''<input type=file oninput='javascript:console.timeStamp()'>''');
      var chooser = await waitFutures(page.waitForFileChooser(), [
        page.click('input'),
      ]);
      await Future.wait([
        chooser.accept([File(fileToUpload)]),
        page.onMetrics.first
      ]);
      expect(
          await page.$eval('input', 'input => input.files.length'), equals(1));
      expect(await page.$eval('input', 'input => input.files[0].name'),
          equals('file-to-upload.txt'));
    });
    test('should be able to read selected file', () async {
      await page.setContent('<input type=file>');
      // ignore: unawaited_futures
      page
          .waitForFileChooser()
          .then((chooser) => chooser.accept([File(fileToUpload)]));
      expect(await page.$eval('input', '''async picker => {
      picker.click();
      await new Promise(x => picker.oninput = x);
      var reader = new FileReader();
      var promise = new Promise(fulfill => reader.onload = fulfill);
      reader.readAsText(picker.files[0]);
      return promise.then(() => reader.result);
      }'''), equals('contents of the file'));
    });
    test('should be able to reset selected files with empty file list',
        () async {
      await page.setContent('<input type=file>');
      // ignore: unawaited_futures
      page
          .waitForFileChooser()
          .then((chooser) => chooser.accept([File(fileToUpload)]));
      expect(await page.$eval('input', '''async picker => {
      picker.click();
      await new Promise(x => picker.oninput = x);
      return picker.files.length;
      }'''), equals(1));
      // ignore: unawaited_futures
      page.waitForFileChooser().then((chooser) => chooser.accept([]));
      expect(await page.$eval('input', '''async picker => {
      picker.click();
      await new Promise(x => picker.oninput = x);
      return picker.files.length;
      }'''), equals(0));
    });
    test('should not accept multiple files for single-file input', () async {
      await page.setContent('<input type=file>');
      var chooser = await waitFutures(page.waitForFileChooser(), [
        page.click('input'),
      ]);
      expect(
          () => chooser.accept([
                File('test/assets/file-to-upload.txt'),
                File('test/assets/pptr.png'),
              ]),
          throwsA(anything));
    });
    test('should fail when accepting file chooser twice', () async {
      await page.setContent('<input type=file>');
      var fileChooser = await waitFutures(page.waitForFileChooser(), [
        page.$eval('input', 'input => input.click()'),
      ]);
      await fileChooser.accept([]);
      expect(
          () => fileChooser.accept([]),
          throwsA(predicate((e) => '$e'.contains(
              'Cannot accept FileChooser which is already handled!'))));
    });
  });

  group('FileChooser.cancel', () {
    test('should cancel dialog', () async {
      // Consider file chooser canceled if we can summon another one.
      // There's no reliable way in WebPlatform to see that FileChooser was
      // canceled.
      await page.setContent('<input type=file>');
      var fileChooser1 = await waitFutures(page.waitForFileChooser(), [
        page.$eval('input', 'input => input.click()'),
      ]);
      await fileChooser1.cancel();
      // If this resolves, than we successfully canceled file chooser.
      await Future.wait([
        page.waitForFileChooser(),
        page.$eval('input', 'input => input.click()'),
      ]);
    });
    test('should fail when canceling file chooser twice', () async {
      await page.setContent('<input type=file>');
      var fileChooser = await waitFutures(page.waitForFileChooser(), [
        page.$eval('input', 'input => input.click()'),
      ]);
      await fileChooser.cancel();

      expect(
          () => fileChooser.cancel(),
          throwsA(predicate((e) => '$e'.contains(
              'Cannot cancel FileChooser which is already handled!'))));
    });
  });

  group('FileChooser.isMultiple', () {
    test('should work for single file pick', () async {
      await page.setContent('<input type=file>');
      var chooser = await waitFutures(page.waitForFileChooser(), [
        page.click('input'),
      ]);
      expect(chooser.isMultiple, isFalse);
    });
    test('should work for "multiple"', () async {
      await page.setContent('<input multiple type=file>');
      var chooser = await waitFutures(page.waitForFileChooser(), [
        page.click('input'),
      ]);
      expect(chooser.isMultiple, isTrue);
    });
    test('should work for "webkitdirectory"', () async {
      await page.setContent('<input multiple webkitdirectory type=file>');
      var chooser = await waitFutures(page.waitForFileChooser(), [
        page.click('input'),
      ]);
      expect(chooser.isMultiple, isTrue);
    });
  });
}
