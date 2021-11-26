import 'dart:async';
import 'dart:io';
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
    await page.close();
  });

  group('Page.Events.Request', () {
    test('should fire for navigation requests', () async {
      var requests = <Request>[];
      page.onRequest.listen((request) {
        if (!isFavicon(request.url)) {
          requests.add(request);
        }
      });
      await page.goto(server.emptyPage);
      expect(requests.length, equals(1));
    });
    test('should fire for iframes', () async {
      var requests = <Request>[];
      page.onRequest.listen((request) {
        if (!isFavicon(request.url)) {
          requests.add(request);
        }
      });
      await page.goto(server.emptyPage);
      await attachFrame(page, 'frame1', server.emptyPage);
      expect(requests.length, equals(2));
    });
    test('should fire for fetches', () async {
      var requests = <Request>[];
      page.onRequest.listen((request) {
        if (!isFavicon(request.url)) {
          requests.add(request);
        }
      });
      await page.goto(server.emptyPage);
      await page.evaluate("() => fetch('/empty.html')");
      expect(requests.length, equals(2));
    });
  });

  group('Request.frame', () {
    test('should work for main frame navigation request', () async {
      var requests = <Request>[];
      page.onRequest.listen((request) {
        if (!isFavicon(request.url)) {
          requests.add(request);
        }
      });
      await page.goto(server.emptyPage);
      expect(requests.length, equals(1));
      expect(requests[0].frame, equals(page.mainFrame));
    });
    test('should work for subframe navigation request', () async {
      await page.goto(server.emptyPage);
      var requests = <Request>[];
      page.onRequest.listen((request) {
        if (!isFavicon(request.url)) {
          requests.add(request);
        }
      });
      await attachFrame(page, 'frame1', server.emptyPage);
      expect(requests.length, equals(1));
      expect(requests[0].frame, equals(page.frames[1]));
    });
    test('should work for fetch requests', () async {
      await page.goto(server.emptyPage);
      var requests = <Request>[];
      page.onRequest.listen((request) {
        if (!isFavicon(request.url)) {
          requests.add(request);
        }
      });
      await page.evaluate("() => fetch('/digits/1.png')");
      requests = requests
          .where((request) => !request.url.contains('favicon'))
          .toList();
      expect(requests.length, equals(1));
      expect(requests[0].frame, equals(page.mainFrame));
    });
  });

  group('Request.headers', () {
    test('should work', () async {
      var response = await page.goto(server.emptyPage);
      expect(response.request.headers['user-agent'], contains('Chrome'));
    });
  });

  group('Response.headers', () {
    test('should work', () async {
      server.setRoute('/empty.html', (req) {
        return shelf.Response.ok('', headers: {'foo': 'bar'});
      });
      var response = await page.goto(server.emptyPage);
      expect(response.headers['foo'], equals('bar'));
    });
  });

  group('Response.fromCache', () {
    test('should return |false| for non-cached content', () async {
      var response = await page.goto(server.emptyPage);
      expect(response.fromCache, isFalse);
    });

    test('should work', () async {
      var responses = <String, Response>{};
      page.onResponse.listen((r) {
        if (!isFavicon(r.url)) {
          responses[r.url.split('/').last] = r;
        }
      });

      // Load and re-load to make sure it's cached.
      await page.goto(server.prefix + '/cached/one-style.html');
      await page.reload();

      expect(responses.length, equals(2));
      expect(responses['one-style.css']!.status, equals(200));
      expect(responses['one-style.css']!.fromCache, isTrue);
      expect(responses['one-style.html']!.status, equals(200));
      expect(responses['one-style.html']!.fromCache, isFalse);
    });
  });

  group('Response.fromServiceWorker', () {
    test('should return |false| for non-service-worker content', () async {
      var response = await page.goto(server.emptyPage);
      expect(response.fromServiceWorker, isFalse);
    });

    test('Response.fromServiceWorker', () async {
      var responses = <String, Response>{};
      page.onResponse.listen((r) {
        responses[r.url.split('/').last] = r;
      });

      // Load and re-load to make sure serviceworker is installed and running.
      await page.goto(server.prefix + '/serviceworkers/fetch/sw.html',
          wait: Until.networkAlmostIdle);
      await page.evaluate('async() => await window.activationPromise');
      await page.reload();

      expect(responses.length, equals(2));
      expect(responses['sw.html']!.status, equals(200));
      expect(responses['sw.html']!.fromServiceWorker, isTrue);
      expect(responses['style.css']!.status, equals(200));
      expect(responses['style.css']!.fromServiceWorker, isTrue);
    });
  });

  group('Request.postData', () {
    test('should work', () async {
      await page.goto(server.emptyPage);
      server.setRoute('/post', (req) => shelf.Response.ok(''));
      late Request request;
      page.onRequest.listen((r) {
        request = r;
      });
      await page.evaluate(
          "() => fetch('./post', { method: 'POST', body: JSON.stringify({foo: 'bar'})})");
      expect(request, isNotNull);
      expect(request.postData, equals('{"foo":"bar"}'));
    });
    test('should be |undefined| when there is no post data', () async {
      var response = await page.goto(server.emptyPage);
      expect(response.request.postData, isNull);
    });
  });

  group('Response.text', () {
    test('should work', () async {
      var response = await page.goto(server.prefix + '/simple.json');
      expect(await response.text, startsWith('{"foo": "bar"}'));
    });
    test('should return uncompressed text', () async {
      //TODO(xha): add feature to server and enable test
      //server.enableGzip('/simple.json');
      var response = await page.goto(server.prefix + '/simple.json');
      expect(response.headers['content-encoding'], equals('gzip'));
      expect(await response.text, equals('{"foo": "bar"}\n'));
    }, skip: "Test server doesn't have enableGzip");
    test('should throw when requesting body of redirected response', () async {
      server.setRedirect('/foo.html', '/empty.html');
      var response = await page.goto(server.prefix + '/foo.html');
      var redirectChain = response.request.redirectChain;
      expect(redirectChain.length, equals(1));
      var redirected = redirectChain[0].response!;
      expect(redirected.status, equals(302));
      expect(
          () => redirected.text,
          throwsA(predicate((e) => '$e'.contains(
              'Response body is unavailable for redirect responses'))));
    });
    test('should wait until response completes', () async {
      await page.goto(server.emptyPage);
      // Setup server to trap request.
      late IOSink serverResponse;
      late StreamController<List<int>> responseStream;
      server.setRoute('/get', (req) {
        responseStream = StreamController<List<int>>();
        serverResponse = IOSink(responseStream);
        serverResponse.write('hello ');

        // In Firefox, |fetch| will be hanging until it receives |Content-Type| header
        // from server.
        return shelf.Response.ok(responseStream.stream,
            headers: {'Content-Type': 'text/plain; charset=utf-8'});
      });
      // Setup page to trap response.
      var requestFinished = false;
      page.onRequestFinished.listen((r) {
        requestFinished = requestFinished || r.url.contains('/get');
      });
      // send request and wait for server response
      var pageResponse = await waitFutures(
          page.onResponse.where((r) => !isFavicon(r.url)).first, [
        page.evaluate("() => fetch('./get', { method: 'GET'})"),
        server.waitForRequest('/get'),
      ]);

      expect(serverResponse, isNotNull);
      expect(pageResponse, isNotNull);
      expect(pageResponse.status, equals(200));
      expect(requestFinished, isFalse);

      var responseText = pageResponse.text;
      // Write part of the response and wait for it to be flushed.
      serverResponse.write('wor');
      await serverResponse.flush();
      // Finish response.
      serverResponse.write('ld!');
      await serverResponse.close();
      await responseStream.close();
      expect(await responseText, equals('hello world!'));
    });
  });

  group('Response.json', () {
    test('should work', () async {
      var response = await page.goto(server.prefix + '/simple.json');
      expect(await response.json, equals({'foo': 'bar'}));
    });
  });

  group('Response.buffer', () {
    test('should work', () async {
      var response = await page.goto(server.prefix + '/pptr.png');
      var imageBuffer = File('test/assets/pptr.png').readAsBytesSync();
      var responseBuffer = await response.bytes;
      expect(responseBuffer, equals(imageBuffer));
    });
    test('should work with compression', () async {
      //server.enableGzip('/pptr.png');
      var response = await page.goto(server.prefix + '/pptr.png');
      var imageBuffer = File('test/assets/pptr.png').readAsBytesSync();
      var responseBuffer = await response.bytes;
      expect(responseBuffer, equals(imageBuffer));
    }, skip: true);
  });

  group('Response.statusText', () {
    test('should work', () async {
      server.setRoute('/cool', (req) {
        return shelf.Response(200);
      });
      var response = await page.goto(server.prefix + '/cool');
      expect(response.statusText, equals('OK'));
    });
  });

  group('Network Events', () {
    test('Page.Events.Request', () async {
      var requests = <Request>[];
      page.onRequest.listen(requests.add);
      await page.goto(server.emptyPage);
      expect(requests.length, equals(1));
      expect(requests[0].url, equals(server.emptyPage));
      expect(requests[0].resourceType, equals(ResourceType.document));
      expect(requests[0].method, equals('GET'));
      expect(requests[0].response, isNotNull);
      expect(requests[0].frame == page.mainFrame, isTrue);
      expect(requests[0].frame!.url, equals(server.emptyPage));
    });
    test('Page.Events.Response', () async {
      var responses = <Response>[];
      page.onResponse.listen(responses.add);
      await page.goto(server.emptyPage);
      expect(responses.length, equals(1));
      expect(responses[0].url, equals(server.emptyPage));
      expect(responses[0].status, equals(200));
      expect(responses[0].ok, isTrue);
      expect(responses[0].request, isNotNull);
      // Either IPv6 or IPv4, depending on environment.
      expect(
          responses[0].remoteIPAddress!.contains('::1') ||
              responses[0].remoteIPAddress == '127.0.0.1',
          isTrue);
      expect(responses[0].remotePort, equals(server.port));
    });

    test('Page.Events.RequestFailed', () async {
      await page.setRequestInterception(true);
      page.onRequest.listen((request) {
        if (request.url.endsWith('css')) {
          request.abort();
        } else {
          request.continueRequest();
        }
      });
      var failedRequests = <Request>[];
      page.onRequestFailed.listen((request) => failedRequests.add(request));
      await page.goto(server.prefix + '/one-style.html');
      expect(failedRequests.length, equals(1));
      expect(failedRequests[0].url, contains('one-style.css'));
      expect(failedRequests[0].response, isNull);
      expect(failedRequests[0].resourceType, equals(ResourceType.stylesheet));
      expect(failedRequests[0].failure, equals('net::ERR_FAILED'));
      expect(failedRequests[0].frame, isNotNull);
    });
    test('Page.Events.RequestFinished', () async {
      var requests = <Request>[];
      page.onRequestFinished.listen(requests.add);
      await page.goto(server.emptyPage);
      expect(requests.length, equals(1));
      expect(requests[0].url, equals(server.emptyPage));
      expect(requests[0].response, isNotNull);
      expect(requests[0].frame == page.mainFrame, isTrue);
      expect(requests[0].frame!.url, equals(server.emptyPage));
    });
    test('should fire events in proper order', () async {
      var events = <String>[];
      page.onRequest.listen((request) => events.add('request'));
      page.onResponse.listen((response) => events.add('response'));
      page.onRequestFinished.listen((request) => events.add('requestfinished'));
      await page.goto(server.emptyPage);
      expect(events, equals(['request', 'response', 'requestfinished']));
    });
    test('should support redirects', () async {
      var events = <String>[];
      page.onRequest
          .listen((request) => events.add('${request.method} ${request.url}'));
      page.onResponse.listen(
          (response) => events.add('${response.status} ${response.url}'));
      page.onRequestFinished
          .listen((request) => events.add('DONE ${request.url}'));
      page.onRequestFailed
          .listen((request) => events.add('FAIL ${request.url}'));
      server.setRedirect('/foo.html', '/empty.html');
      var fooUrl = server.prefix + '/foo.html';
      var response = await page.goto(fooUrl);
      expect(
          events,
          equals([
            'GET $fooUrl',
            '302 $fooUrl',
            'DONE $fooUrl',
            'GET ${server.emptyPage}',
            '200 ${server.emptyPage}',
            'DONE ${server.emptyPage}'
          ]));

      // Check redirect chain
      var redirectChain = response.request.redirectChain;
      expect(redirectChain.length, equals(1));
      expect(redirectChain[0].url, contains('/foo.html'));
      expect(redirectChain[0].response!.remotePort, equals(server.port));
    });
  });

  group('Request.isNavigationRequest', () {
    test('should work', () async {
      var requests = <String, Request>{};
      page.onRequest
          .listen((request) => requests[request.url.split('/').last] = request);
      server.setRedirect('/rrredirect', '/frames/one-frame.html');
      await page.goto(server.prefix + '/rrredirect');
      expect(requests['rrredirect']!.isNavigationRequest, isTrue);
      expect(requests['one-frame.html']!.isNavigationRequest, isTrue);
      expect(requests['frame.html']!.isNavigationRequest, isTrue);
      expect(requests['script.js']!.isNavigationRequest, isFalse);
      expect(requests['style.css']!.isNavigationRequest, isFalse);
    });
    test('should work with request interception', () async {
      var requests = <String, Request>{};
      page.onRequest.listen((request) {
        requests[request.url.split('/').last] = request;
        request.continueRequest();
      });
      await page.setRequestInterception(true);
      server.setRedirect('/rrredirect', '/frames/one-frame.html');
      await page.goto(server.prefix + '/rrredirect');
      expect(requests['rrredirect']!.isNavigationRequest, isTrue);
      expect(requests['one-frame.html']!.isNavigationRequest, isTrue);
      expect(requests['frame.html']!.isNavigationRequest, isTrue);
      expect(requests['script.js']!.isNavigationRequest, isFalse);
      expect(requests['style.css']!.isNavigationRequest, isFalse);
    });
    test('should work when navigating to image', () async {
      var requests = <Request>[];
      page.onRequest.listen(requests.add);
      await page.goto(server.prefix + '/pptr.png');
      expect(requests[0].isNavigationRequest, isTrue);
    });
  });

  group('Page.setExtraHTTPHeaders', () {
    test('should work', () async {
      await page.setExtraHTTPHeaders({'foo': 'bar'});
      var request = await waitFutures(server.waitForRequest('/simple.html'), [
        page.goto(server.assetUrl('simple.html')),
      ]);
      expect(request.headers['foo'], equals('bar'));
    });
  });

  group('Page.authenticate', () {
    test('should work', () async {
      //TODO(xha): add auth to test server and re-enable test
      //server.setAuth('/empty.html', 'user', 'pass');
      var response = await page.goto(server.emptyPage);
      expect(response.status, equals(401));
      await page.authenticate(username: 'user', password: 'pass');
      response = await page.reload();
      expect(response.status, equals(200));
    });
    test('should fail if wrong credentials', () async {
      // Use unique user/password since Chrome caches credentials per origin.
      //server.setAuth('/empty.html', 'user2', 'pass2');
      await page.authenticate(username: 'foo', password: 'bar');
      var response = await page.goto(server.emptyPage);
      expect(response.status, equals(401));
    });
    test('should allow disable authentication', () async {
      // Use unique user/password since Chrome caches credentials per origin.
      //server.setAuth('/empty.html', 'user3', 'pass3');
      await page.authenticate(username: 'user3', password: 'pass3');
      var response = await page.goto(server.emptyPage);
      expect(response.status, equals(200));
      await page.authenticate();
      // Navigate to a different origin to bust Chrome's credential caching.
      response = await page.goto(server.crossProcessPrefix + '/empty.html');
      expect(response.status, equals(401));
    });
  }, skip: 'Test server dont have setAuth yet');
}
