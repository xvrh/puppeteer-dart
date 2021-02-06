import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'utils/utils.dart';

// ignore_for_file: prefer_interpolation_to_compose_strings

void main() {
  late Server server;
  late Browser browser;
  late Page page;
  setUpAll(() async {
    server = await Server.create();
    browser = await puppeteer.launch(
        defaultViewport: DeviceViewport(width: 800, height: 600));
  });

  tearDownAll(() async {
    await browser.close();
    await server.close();
  });

  setUp(() async {
    page = await browser.newPage();
    await page.goto(server.emptyPage);
  });

  tearDown(() async {
    server.clearRoutes();
    await page.close();
  });

  group('Frame.executionContext', () {
    test('should work', () async {
      await page.goto(server.emptyPage);
      await attachFrame(page, 'frame1', server.emptyPage);
      expect(page.frames.length, equals(2));
      var frames = page.frames;
      var frame1 = frames[0];
      var frame2 = frames[1];
      var context1 = await frame1.executionContext;
      var context2 = await frame2.executionContext;
      expect(context1, isNotNull);
      expect(context2, isNotNull);
      expect(context1 != context2, isNotNull);
      expect(context1.frame, equals(frame1));
      expect(context2.frame, equals(frame2));

      await Future.wait([
        context1.evaluate('() => window.a = 1'),
        context2.evaluate('() => window.a = 2')
      ]);
      var as = await Future.wait([
        context1.evaluate('() => window.a'),
        context2.evaluate('() => window.a')
      ]);
      expect(as[0], equals(1));
      expect(as[1], equals(2));
    });
  });

  group('Frame.evaluateHandle', () {
    test('should work', () async {
      await page.goto(server.emptyPage);
      var mainFrame = page.mainFrame;
      var windowHandle = await mainFrame.evaluateHandle('() => window');
      expect(windowHandle, isNotNull);
    });
  });

  group('Frame.evaluate', () {
    test('should throw for detached frames', () async {
      var frame1 = await attachFrame(page, 'frame1', server.emptyPage);
      await detachFrame(page, 'frame1');
      expect(
          () => frame1.evaluate('() => 7 * 8'),
          throwsA(predicate((e) => '$e'.contains(
              'Execution Context is not available in detached frame'))));
    });
  });

  group('Frame Management', () {
    test('should handle nested frames', () async {
      await page.goto(server.prefix + '/frames/nested-frames.html');
      expect(
          dumpFrames(page.mainFrame),
          equals([
            'http://<host>/frames/nested-frames.html',
            '    http://<host>/frames/two-frames.html (2frames)',
            '        http://<host>/frames/frame.html (uno)',
            '        http://<host>/frames/frame.html (dos)',
            '    http://<host>/frames/frame.html (aframe)'
          ]));
    });
    test('should send events when frames are manipulated dynamically',
        () async {
      await page.goto(server.emptyPage);
      // validate frameattached events
      var attachedFrames = <Frame>[];
      page.onFrameAttached.listen((frame) => attachedFrames.add(frame));
      await attachFrame(page, 'frame1', './frame.html');
      expect(attachedFrames.length, equals(1));
      expect(attachedFrames[0].url, contains('/frame.html'));

      // validate framenavigated events
      var navigatedFrames = <Frame>[];
      page.onFrameNavigated.listen((frame) => navigatedFrames.add(frame));
      await navigateFrame(page, 'frame1', './empty.html');
      expect(navigatedFrames.length, equals(1));
      expect(navigatedFrames[0].url, equals(server.emptyPage));

      // validate framedetached events
      var detachedFrames = <Frame>[];
      page.onFrameDetached.listen((frame) => detachedFrames.add(frame));
      await detachFrame(page, 'frame1');
      expect(detachedFrames.length, equals(1));
      expect(detachedFrames[0].isDetached, isTrue);
    });
    test('should send "framenavigated" when navigating on anchor URLs',
        () async {
      await page.goto(server.emptyPage);
      await Future.wait([
        page.onFrameNavigated.first,
        page.goto(server.emptyPage + '#foo'),
      ]);
      expect(page.url, equals(server.emptyPage + '#foo'));
    });
    test('should persist mainFrame on cross-process navigation', () async {
      await page.goto(server.emptyPage);
      var mainFrame = page.mainFrame;
      await page.goto(server.crossProcessPrefix + '/empty.html');
      expect(page.mainFrame, equals(mainFrame));
    });
    test('should not send attach/detach events for main frame', () async {
      var hasEvents = false;
      page.onFrameAttached.listen((frame) => hasEvents = true);
      page.onFrameDetached.listen((frame) => hasEvents = true);
      await page.goto(server.emptyPage);
      expect(hasEvents, isFalse);
    });
    test('should detach child frames on navigation', () async {
      var attachedFrames = <Frame>[];
      var detachedFrames = <Frame>[];
      var navigatedFrames = <Frame>[];
      page.onFrameAttached.listen((frame) => attachedFrames.add(frame));
      page.onFrameDetached.listen((frame) => detachedFrames.add(frame));
      page.onFrameNavigated.listen((frame) => navigatedFrames.add(frame));

      var eventsFuture = Future.wait([
        page.onFrameAttached.take(4).toList(),
        page.onFrameNavigated.take(5).toList()
      ]);

      await page.goto(server.prefix + '/frames/nested-frames.html');

      // Give a bit of time for the events to fire
      await eventsFuture.timeout(Duration(milliseconds: 1000));

      expect(attachedFrames.length, equals(4));
      expect(detachedFrames.length, equals(0));
      expect(navigatedFrames.length, equals(5));

      attachedFrames.clear();
      detachedFrames.clear();
      navigatedFrames.clear();

      eventsFuture = Future.wait([
        page.onFrameDetached.take(4).toList(),
        page.onFrameNavigated.take(1).toList()
      ]);

      await page.goto(server.emptyPage);

      // Give a bit of time for the events to fire
      await eventsFuture.timeout(Duration(milliseconds: 1000));

      expect(attachedFrames.length, equals(0));
      expect(detachedFrames.length, equals(4));
      expect(navigatedFrames.length, equals(1));
    });
    test('should support framesets', () async {
      var attachedFrames = <Frame>[];
      var detachedFrames = <Frame>[];
      var navigatedFrames = <Frame>[];
      page.onFrameAttached.listen((frame) => attachedFrames.add(frame));
      page.onFrameDetached.listen((frame) => detachedFrames.add(frame));
      page.onFrameNavigated.listen((frame) => navigatedFrames.add(frame));

      var eventsFuture = Future.wait([
        page.onFrameAttached.take(4).toList(),
        page.onFrameNavigated.take(5).toList()
      ]);

      await page.goto(server.prefix + '/frames/frameset.html');

      // Give a bit of time for the events to fire
      await eventsFuture.timeout(Duration(milliseconds: 1000));

      expect(attachedFrames.length, equals(4));
      expect(detachedFrames.length, equals(0));
      expect(navigatedFrames.length, equals(5));

      attachedFrames.clear();
      detachedFrames.clear();
      navigatedFrames.clear();

      eventsFuture = Future.wait([
        page.onFrameDetached.take(4).toList(),
        page.onFrameNavigated.take(1).toList()
      ]);

      await page.goto(server.emptyPage);

      // Give a bit of time for the events to fire
      await eventsFuture.timeout(Duration(milliseconds: 1000));

      expect(attachedFrames.length, equals(0));
      expect(detachedFrames.length, equals(4));
      expect(navigatedFrames.length, equals(1));
    });
    test('should report frame from-inside shadow DOM', () async {
      await page.goto(server.prefix + '/shadow.html');
      await page.evaluate('''async url => {
      var frame = document.createElement('iframe');
      frame.src = url;
      document.body.shadowRoot.appendChild(frame);
      await new Promise(x => frame.onload = x);
      }''', args: [server.emptyPage]);
      expect(page.frames.length, equals(2));
      expect(page.frames[1].url, equals(server.emptyPage));
    });
    test('should report frame.name()', () async {
      await attachFrame(page, 'theFrameId', server.emptyPage);
      await page.evaluate('''url => {
      var frame = document.createElement('iframe');
      frame.name = 'theFrameName';
      frame.src = url;
      document.body.appendChild(frame);
      return new Promise(x => frame.onload = x);
      }''', args: [server.emptyPage]);
      expect(page.frames[0].name, isNull);
      expect(page.frames[1].name, equals('theFrameId'));
      expect(page.frames[2].name, equals('theFrameName'));
    });
    test('should report frame.parent()', () async {
      await attachFrame(page, 'frame1', server.emptyPage);
      await attachFrame(page, 'frame2', server.emptyPage);
      expect(page.frames[0].parentFrame, isNull);
      expect(page.frames[1].parentFrame, equals(page.mainFrame));
      expect(page.frames[2].parentFrame, equals(page.mainFrame));
    });
    test('should report different frame instance when frame re-attaches',
        () async {
      var frame1 = await attachFrame(page, 'frame1', server.emptyPage);
      await page.evaluate('''() => {
      window.frame = document.querySelector('#frame1');
          window.frame.remove();
    }''');
      expect(frame1.isDetached, isTrue);
      var frame2 = await waitFutures(page.onFrameAttached.first, [
        page.evaluate('() => document.body.appendChild(window.frame)'),
      ]);
      expect(frame2.isDetached, isFalse);
      expect(frame1, isNot(equals(frame2)));
    });
    test('should support url fragment', () async {
      await page.goto(server.prefix + '/frames/one-frame-url-fragment.html');

      expect(page.frames.length, 2);
      expect(page.frames[1].url,
          server.prefix + '/frames/frame.html&test=fragment');
      print(page.frames[1].url);
    });
  });
}
