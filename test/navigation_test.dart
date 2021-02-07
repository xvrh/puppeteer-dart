import 'dart:async';
import 'package:puppeteer/puppeteer.dart';
import 'package:shelf/shelf.dart' as shelf;
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
    await context.close();
  });

  group('Page.goto', () {
    test('should work', () async {
      await page.goto(server.emptyPage);
      expect(page.url, equals(server.emptyPage));
    });
    test('should work with anchor navigation', () async {
      await page.goto(server.emptyPage);
      expect(page.url, equals(server.emptyPage));
      await page.goto(server.emptyPage + '#foo');
      expect(page.url, equals(server.emptyPage + '#foo'));
      await page.goto(server.emptyPage + '#bar');
      expect(page.url, equals(server.emptyPage + '#bar'));
    });
    test('should work with redirects', () async {
      server.setRedirect('/redirect/1.html', '/redirect/2.html');
      server.setRedirect('/redirect/2.html', '/simple.html');
      await page.goto(server.prefix + '/redirect/1.html');
      expect(page.url, equals(server.assetUrl('simple.html')));
    });
    test('should navigate to about:blank', () async {
      var response = await page.goto('about:blank');
      expect(response.status, 0);
    });
    test('should return response when page changes its URL after load',
        () async {
      var response = await page.goto(server.prefix + '/historyapi.html');
      expect(response.status, equals(200));
    });
    test('should work with subframes return 204', () async {
      server.setRoute('/frames/frame.html', (req) {
        return shelf.Response(204);
      });
      await page.goto(server.prefix + '/frames/one-frame.html');
    });
    test('should fail when server returns 204', () async {
      server.setRoute('/204.html', (req) => shelf.Response(204));
      expect(() => page.goto(server.assetUrl('204.html')),
          throwsA(predicate((e) => '$e'.contains('net::ERR_ABORTED'))));
    });
    test('should navigate to empty page with domcontentloaded', () async {
      var response =
          await page.goto(server.emptyPage, wait: Until.domContentLoaded);
      expect(response.status, equals(200));
    });
    test('should work when page calls history API in beforeunload', () async {
      await page.goto(server.emptyPage);
      await page.evaluate('''() => {
      window.addEventListener('beforeunload', () => history.replaceState(null, 'initial', window.location.href), false);
      }''');
      var response = await page.goto(server.prefix + '/grid.html');
      expect(response.status, equals(200));
    });
    test('should navigate to empty page with networkidle0', () async {
      var response = await page.goto(server.emptyPage, wait: Until.networkIdle);
      expect(response.status, equals(200));
    });
    test('should navigate to empty page with networkidle2', () async {
      var response =
          await page.goto(server.emptyPage, wait: Until.networkAlmostIdle);
      expect(response.status, equals(200));
    });
    test('should fail when navigating to bad url', () async {
      expect(
          () => page.goto('asdfasdf'),
          throwsA(predicate(
              (e) => '$e'.contains('Cannot navigate to invalid URL'))));
    });
    test('should fail when navigating to bad SSL', () async {
      // Make sure that network events do not emit 'undefined'.
      // @see https://crbug.com/750469
      page.onRequest.listen((request) => expect(request, isNotNull));
      page.onRequestFinished.listen((request) => expect(request, isNotNull));
      page.onRequestFailed.listen((request) => expect(request, isNotNull));

      //expect(() => page.goto(httpsServer.emptyPage), throwsA(predicate((e) => '$e'.contains('net::ERR_CERT_AUTHORITY_INVALID'))));
    }, skip: "Test server doesn't support https yet");
    test('should fail when navigating to bad SSL after redirects', () async {
      server.setRedirect('/redirect/1.html', '/redirect/2.html');
      server.setRedirect('/redirect/2.html', '/empty.html');

      //expect(() => page.goto(httpsServer.prefix + '/redirect/1.html'), throwsA(predicate((e) => '$e'.contains('net::ERR_CERT_AUTHORITY_INVALID'))));
    }, skip: "Test server doesn't support https yet");
    test('should fail when main resources failed to load', () async {
      expect(
          () => page.goto('http://localhost:44123/non-existing-url'),
          throwsA(
              predicate((e) => '$e'.contains('net::ERR_CONNECTION_REFUSED'))));
    });
    test('should fail when exceeding maximum navigation timeout', () async {
      // Hang for request to the infinite.html
      server.setRoute(
          '/infinite.html', (request) => Completer<shelf.Response>().future);
      expect(
          () => page.goto(server.prefix + '/infinite.html',
              timeout: Duration(milliseconds: 1)),
          throwsA(TypeMatcher<TimeoutException>()));
    });
    test('should fail when exceeding default maximum navigation timeout',
        () async {
      // Hang for request to the infinite.html
      server.setRoute(
          '/infinite.html', (request) => Completer<shelf.Response>().future);
      page.defaultNavigationTimeout = Duration(milliseconds: 1);
      expect(() => page.goto(server.prefix + '/infinite.html'),
          throwsA(TypeMatcher<TimeoutException>()));
    });
    test('should fail when exceeding default maximum timeout', () async {
      // Hang for request to the infinite.html
      server.setRoute(
          '/infinite.html', (request) => Completer<shelf.Response>().future);
      page.defaultTimeout = Duration(milliseconds: 1);
      expect(() => page.goto(server.prefix + '/infinite.html'),
          throwsA(TypeMatcher<TimeoutException>()));
    });
    test('should prioritize default navigation timeout over default timeout',
        () async {
      // Hang for request to the infinite.html
      server.setRoute(
          '/infinite.html', (request) => Completer<shelf.Response>().future);
      page.defaultTimeout = Duration.zero;
      page.defaultTimeout = Duration(milliseconds: 1);
      expect(() => page.goto(server.prefix + '/infinite.html'),
          throwsA(TypeMatcher<TimeoutException>()));
    });
    test('should disable timeout when its set to 0', () async {
      var loaded = false;
      page.onLoad.listen((_) {
        loaded = true;
      });
      await page.goto(server.prefix + '/grid.html',
          timeout: Duration.zero, wait: Until.load);
      expect(loaded, isTrue);
    });
    test('should work when navigating to valid url', () async {
      var response = await page.goto(server.assetUrl('simple.html'));
      expect(response.ok, isTrue);
    });
    test('should work when navigating to data url', () async {
      var response = await page.goto('data:text/html,hello');
      expect(response.ok, isTrue);
    });
    test('should work when navigating to 404', () async {
      var response = await page.goto(server.prefix + '/not-found');
      expect(response.ok, isFalse);
      expect(response.status, equals(404));
    });
    test('should return last response in redirect chain', () async {
      server.setRedirect('/redirect/1.html', '/redirect/2.html');
      server.setRedirect('/redirect/2.html', '/redirect/3.html');
      server.setRedirect('/redirect/3.html', server.emptyPage);
      var response = await page.goto(server.prefix + '/redirect/1.html');
      expect(response.ok, isTrue);
      expect(response.url, equals(server.emptyPage));
    });
    test('should wait for network idle to succeed navigation', () async {
      var responses = <Completer<shelf.Response>>[];
      Future<shelf.Response> addResponse() {
        var response = Completer<shelf.Response>();
        responses.add(response);
        return response.future;
      }

      // Hold on to a bunch of requests without answering.
      server.setRoute('/fetch-request-a.js', (req) {
        return addResponse();
      });
      server.setRoute('/fetch-request-b.js', (req) {
        return addResponse();
      });
      server.setRoute('/fetch-request-c.js', (req) {
        return addResponse();
      });
      server.setRoute('/fetch-request-d.js', (req) {
        return addResponse();
      });
      var initialFetchResourcesRequested = Future.wait([
        server.waitForRequest('/fetch-request-a.js'),
        server.waitForRequest('/fetch-request-b.js'),
        server.waitForRequest('/fetch-request-c.js'),
      ]);
      var secondFetchResourceRequested =
          server.waitForRequest('/fetch-request-d.js');

      // Navigate to a page which loads immediately and then does a bunch of
      // requests via javascript's fetch method.
      var navigationPromise = page.goto(server.prefix + '/networkidle.html',
          wait: Until.networkIdle);
      // Track when the navigation gets completed.
      var navigationFinished = false;
      // ignore: unawaited_futures
      navigationPromise.then((_) => navigationFinished = true);

      // Wait for the page's 'load' event.
      await page.onLoad.first;
      expect(navigationFinished, isFalse);

      // Wait for the initial three resources to be requested.
      await initialFetchResourcesRequested;

      // Expect navigation still to be not finished.
      expect(navigationFinished, isFalse);

      // Respond to initial requests.
      for (var response in responses) {
        response.complete(shelf.Response.notFound('File not found'));
      }

      // Reset responses array
      responses = [];

      // Wait for the second round to be requested.
      await secondFetchResourceRequested;
      // Expect navigation still to be not finished.
      expect(navigationFinished, isFalse);

      // Respond to requests.
      for (var response in responses) {
        response.complete(shelf.Response.notFound('File not found'));
      }

      var response = await navigationPromise;
      // Expect navigation to succeed.
      expect(response.ok, isTrue);
    });
    test('should not leak listeners during navigation', () async {
      //TODO(xha): implement, the test uses a warning listener on the process
    });
    test('should not leak listeners during bad navigation', () async {
      //TODO(xha): implement, the test uses a warning listener on the process
    });
    test('should not leak listeners during navigation of 11 pages', () async {
      //TODO(xha): implement, the test uses a warning listener on the process
    });
    test('should navigate to dataURL and fire dataURL requests', () async {
      var requests = <Request>[];
      page.onRequest.listen((request) {
        if (!request.url.contains('favicon.ico')) {
          requests.add(request);
        }
      });
      var dataURL = 'data:text/html,<div>yo</div>';
      var response = await page.goto(dataURL);
      expect(response.status, equals(200));
      expect(requests.length, equals(1));
      expect(requests[0].url, equals(dataURL));
    });
    test('should navigate to URL with hash and fire requests without hash',
        () async {
      var requests = [];
      page.onRequest.listen((request) {
        if (!request.url.contains('favicon.ico')) {
          requests.add(request);
        }
      });
      var response = await page.goto(server.emptyPage + '#hash');
      expect(response.status, equals(200));
      expect(response.url, equals(server.emptyPage));
      expect(requests.length, equals(1));
      expect(requests[0].url, equals(server.emptyPage));
    });
    test('should work with self requesting page', () async {
      var response = await page.goto(server.prefix + '/self-request.html');
      expect(response.status, equals(200));
      expect(response.url, contains('self-request.html'));
    });
    test('should fail when navigating and show the url at the error message',
        () async {
      var url = server.prefix + '/redirect/1.html';
      expect(
          () => page.goto(url), throwsA(predicate((e) => '$e'.contains(url))));
    }, skip: "Can't reproduce the original test (needs https)");
    test('should send referer', () async {
      var request1Future = server.waitForRequest('/grid.html');
      var request2Future = server.waitForRequest('/digits/1.png');

      await page.goto(
        server.prefix + '/grid.html',
        referrer: 'http://google.com/',
      );
      var request1 = await request1Future;
      var request2 = await request2Future;

      expect(request1.headers['referer'], equals('http://google.com/'));
      // Make sure subresources do not inherit referer.
      expect(request2.headers['referer'], equals(server.prefix + '/grid.html'));
    });
  });

  group('Page.waitForNavigation', () {
    test('should work', () async {
      await page.goto(server.emptyPage);
      var response = await waitFutures(page.waitForNavigation(), [
        page.evaluate('url => window.location.href = url',
            args: [server.prefix + '/grid.html'])
      ]);
      expect(response.ok, isTrue);
      expect(response.url, contains('grid.html'));
    });
    test('should work with both domcontentloaded and load', () async {
      var response = Completer<shelf.Response>();
      server.setRoute('/one-style.css', (req) {
        return response.future;
      });
      var navigationPromise = page.goto(server.prefix + '/one-style.html');
      var domContentLoadedPromise =
          page.waitForNavigation(wait: Until.domContentLoaded);

      var bothFired = false;
      var bothFiredPromise = page
          .waitForNavigation(
              wait: Until.all([Until.load, Until.domContentLoaded]))
          .then((_) => bothFired = true);

      await server.waitForRequest('/one-style.css');
      await domContentLoadedPromise;
      expect(bothFired, isFalse);
      response.complete(shelf.Response.ok(''));
      await bothFiredPromise;
      await navigationPromise;
    });
    test('should work with clicking on anchor links', () async {
      await page.goto(server.emptyPage);
      await page.setContent("<a href='#foobar'>foobar</a>");
      var response = await waitFutures(page.waitForNavigation(), [
        page.click('a'),
      ]);
      expect(response.status, 0);
      expect(page.url, equals(server.emptyPage + '#foobar'));
    });
    test('should work with history.pushState()', () async {
      await page.goto(server.emptyPage);
      await page.setContent('''
      <a onclick='javascript:pushState()'>SPA</a>
      <script>
      function pushState() { history.pushState({}, '', 'wow.html') }
      </script>
      ''');
      var response = await waitFutures(page.waitForNavigation(), [
        page.click('a'),
      ]);
      expect(response.status, 0);
      expect(page.url, equals(server.prefix + '/wow.html'));
    });
    test('should work with history.replaceState()', () async {
      await page.goto(server.emptyPage);
      await page.setContent('''
      <a onclick='javascript:replaceState()'>SPA</a>
      <script>
      function replaceState() { history.replaceState({}, '', '/replaced.html') }
      </script>
      ''');
      var response = await waitFutures(page.waitForNavigation(), [
        page.click('a'),
      ]);
      expect(response.status, 0);
      expect(page.url, equals(server.prefix + '/replaced.html'));
    });
    test('should work with DOM history.back()/history.forward()', () async {
      await page.goto(server.emptyPage);
      await page.setContent('''
      <a id=back onclick='javascript:goBack()'>back</a>
      <a id=forward onclick='javascript:goForward()'>forward</a>
      <script>
      function goBack() { history.back(); }
      function goForward() { history.forward(); }
      history.pushState({}, '', '/first.html');
      history.pushState({}, '', '/second.html');
      </script>
      ''');
      expect(page.url, equals(server.prefix + '/second.html'));
      var backResponse = await waitFutures(page.waitForNavigation(), [
        page.click('a#back'),
      ]);
      expect(backResponse.status, 0);
      expect(page.url, equals(server.prefix + '/first.html'));
      var forwardResponse = await waitFutures(page.waitForNavigation(), [
        page.click('a#forward'),
      ]);
      expect(forwardResponse.status, 0);
      expect(page.url, equals(server.prefix + '/second.html'));
    });
    test('should work when subframe issues window.stop()', () async {
      server.setRoute(
          '/frames/style.css', (req) => Completer<shelf.Response>().future);

      // ignore: unawaited_futures
      var frameAttachedFuture = page.onFrameAttached.first;
      var navigationPromise =
          page.goto(server.prefix + '/frames/one-frame.html');
      var frame = await frameAttachedFuture;

      await Future.wait(
          [frame.evaluate('() => window.stop()'), navigationPromise]);
    });
  });

  group('Page.goBack', () {
    test('should work', () async {
      await page.goto(server.emptyPage);
      await page.goto(server.prefix + '/grid.html');

      var response = await page.goBack();
      expect(response!.ok, isTrue);
      expect(response.url, contains(server.emptyPage));

      response = await page.goForward();
      expect(response!.ok, isTrue);
      expect(response.url, contains('/grid.html'));

      response = await page.goForward();
      expect(response, isNull);
    });
    test('should work with HistoryAPI', () async {
      await page.goto(server.emptyPage);
      await page.evaluate('''() => {
      history.pushState({}, '', '/first.html');
          history.pushState({}, '', '/second.html');
    }''');
      expect(page.url, equals(server.prefix + '/second.html'));

      await page.goBack();
      expect(page.url, equals(server.prefix + '/first.html'));
      await page.goBack();
      expect(page.url, equals(server.emptyPage));
      await page.goForward();
      expect(page.url, equals(server.prefix + '/first.html'));
    });
  });

  group('Frame.goto', () {
    test('should navigate subframes', () async {
      await page.goto(server.prefix + '/frames/one-frame.html');
      expect(page.frames[0].url, contains('/frames/one-frame.html'));
      expect(page.frames[1], isNotNull);

      var response = await page.frames[1].goto(server.emptyPage);
      expect(response.ok, isTrue);
      expect(response.frame, equals(page.frames[1]));
    });
    test('should reject when frame detaches', () async {
      await page.goto(server.prefix + '/frames/one-frame.html');

      server.setRoute(
          '/empty.html', (req) => Completer<shelf.Response>().future);
      Object? error;
      var navigationPromise = page.frames[1]
          .goto(server.emptyPage)
          .then<Response?>((e) => e)
          .catchError((e) {
        error = e;
      });
      await server.waitForRequest('/empty.html');

      await page.$eval('iframe', 'frame => frame.remove()');
      await navigationPromise;
      expect(
          error.toString(), equals('Exception: Navigating frame was detached'));
    });
    test('should return matching responses', () async {
      await page.goto(server.assetUrl('empty.html'));

      // Disable cache: otherwise, chromium will cache similar requests.
      await page.setCacheEnabled(false);

      // Attach three frames.
      var frames = await Future.wait([
        attachFrame(page, 'frame1', server.emptyPage),
        attachFrame(page, 'frame2', server.emptyPage),
        attachFrame(page, 'frame3', server.emptyPage),
      ]);
      // Navigate all frames to the same URL.
      var serverResponses = <Completer<shelf.Response>>[];
      Future<shelf.Response> addResponse() {
        var response = Completer<shelf.Response>();
        serverResponses.add(response);
        return response.future;
      }

      server.setRoute('/one-style.html', (req) => addResponse());
      var navigations = <Future<Response>>[];
      for (var i = 0; i < 3; ++i) {
        navigations.add(frames[i].goto(server.prefix + '/one-style.html'));
        await server.waitForRequest('/one-style.html');
      }
      // Respond from server out-of-order.
      var serverResponseTexts = ['AAA', 'BBB', 'CCC'];
      for (var i in [1, 2, 0]) {
        serverResponses[i].complete(shelf.Response.ok(serverResponseTexts[i]));
        var response = await navigations[i];
        expect(response.frame, equals(frames[i]));
        expect(await response.text, equals(serverResponseTexts[i]));
      }
    });
  });

  group('Frame.waitForNavigation', () {
    test('should work', () async {
      await page.goto(server.prefix + '/frames/one-frame.html');
      var frame = page.frames[1];
      var response = await waitFutures(frame.waitForNavigation(), [
        frame.evaluate('url => window.location.href = url',
            args: [server.prefix + '/grid.html'])
      ]);
      expect(response.ok, isTrue);
      expect(response.url, contains('grid.html'));
      expect(response.frame, equals(frame));
      expect(page.url, contains('/frames/one-frame.html'));
    });
    test('should fail when frame detaches', () async {
      await page.goto(server.prefix + '/frames/one-frame.html');
      var frame = page.frames[1];

      server.setRoute(
          '/empty-for-frame.html', (req) => Completer<shelf.Response>().future);
      Object? error;
      var navigationPromise =
          frame.waitForNavigation().then<Response?>((e) => e).catchError((e) {
        error = e;
      });
      await Future.wait([
        server.waitForRequest('/empty-for-frame.html'),
        frame.evaluate("() => window.location = '/empty-for-frame.html'")
      ]);
      await page.$eval('iframe', 'frame => frame.remove()');
      await navigationPromise;
      expect(
          error.toString(), equals('Exception: Navigating frame was detached'));
    });
  });

  group('Page.reload', () {
    test('should work', () async {
      await page.goto(server.emptyPage);
      await page.evaluate('() => window._foo = 10');
      await page.reload();
      expect(await page.evaluate('() => window._foo'), isNull);
    });
  });
}
