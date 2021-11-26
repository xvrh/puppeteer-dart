import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:puppeteer/puppeteer.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:test/test.dart';
import 'utils/utils.dart';
import 'utils/utils_golden.dart';

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

  group('Page.setRequestInterception', () {
    test('should intercept', () async {
      await page.setRequestInterception(true);
      page.onRequest.listen((request) {
        if (request.url.contains('favicon.ico')) {
          request.continueRequest();
          return;
        }
        expect(request.url, contains('empty.html'));
        expect(request.headers['user-agent'], isNotNull);
        expect(request.method, equals('GET'));
        expect(request.postData, isNull);
        expect(request.isNavigationRequest, isTrue);
        expect(request.resourceType, equals(ResourceType.document));
        expect(request.frame == page.mainFrame, isTrue);
        expect(request.frame!.url, equals('about:blank'));
        request.continueRequest();
      });
      var response = await page.goto(server.emptyPage);
      expect(response.ok, isTrue);
      expect(response.remotePort, equals(server.port));
    });
    test('should work when POST is redirected with 302', () async {
      server.setRedirect('/rredirect', '/empty.html');
      await page.goto(server.emptyPage);
      await page.setRequestInterception(true);
      page.onRequest.listen((request) => request.continueRequest());
      await page.setContent('''
      <form action='/rredirect' method='post'>
      <input type="hidden" id="foo" name="foo" value="FOOBAR">
      </form>
      ''');
      await Future.wait([
        page.$eval('form', 'form => form.submit()'),
        page.waitForNavigation()
      ]);
    });
    // @see https://github.com/GoogleChrome/puppeteer/issues/3973
    test('should work when header manipulation headers with redirect',
        () async {
      server.setRedirect('/rrredirect', '/empty.html');
      await page.setRequestInterception(true);
      page.onRequest.listen((request) {
        var headers = Map<String, String>.from(request.headers)
          ..['foo'] = 'bar';
        request.continueRequest(headers: headers);
      });
      await page.goto(server.prefix + '/rrredirect');
    });
    // @see https://github.com/GoogleChrome/puppeteer/issues/4743
    test('should be able to remove headers', () async {
      await page.setRequestInterception(true);
      page.onRequest.listen((request) {
        var headers = request.headers;
        headers['foo'] = 'bar';
        headers.remove('origin');
        request.continueRequest(headers: headers);
      });

      var serverRequest = await waitFutures(
          server.waitForRequest('/empty.html'),
          [page.goto(server.prefix + '/empty.html')]);

      expect(serverRequest.headers['origin'], isNull);
    });
    test('should contain referer header', () async {
      await page.setRequestInterception(true);
      var requests = <Request>[];
      page.onRequest.listen((request) {
        if (!request.url.contains('favicon.ico')) requests.add(request);
        request.continueRequest();
      });
      await page.goto(server.prefix + '/one-style.html');
      expect(requests[1].url, contains('/one-style.css'));
      expect(requests[1].headers['referer'], contains('/one-style.html'));
    });
    test('should properly return navigation response when URL has cookies',
        () async {
      // Setup cookie.
      await page.goto(server.emptyPage);
      await page.setCookies([CookieParam(name: 'foo', value: 'bar')]);

      // Setup request interception.
      await page.setRequestInterception(true);
      page.onRequest.listen((request) => request.continueRequest());
      var response = await page.reload();
      expect(response.status, equals(200));
    });
    test('should stop intercepting', () async {
      await page.setRequestInterception(true);
      var interception =
          page.onRequest.listen((request) => request.continueRequest());
      await page.goto(server.emptyPage);
      await page.setRequestInterception(false);
      await interception.cancel();
      await page.goto(server.emptyPage);
    });
    test('should show custom HTTP headers', () async {
      await page.setExtraHTTPHeaders({'foo': 'bar'});
      await page.setRequestInterception(true);
      page.onRequest.listen((request) {
        expect(request.headers['foo'], equals('bar'));
        request.continueRequest();
      });
      var response = await page.goto(server.emptyPage);
      expect(response.ok, isTrue);
    });
    test('should work with redirect inside sync XHR', () async {
      await page.goto(server.emptyPage);
      server.setRedirect('/logo.png', '/pptr.png');
      await page.setRequestInterception(true);
      page.onRequest.listen((request) => request.continueRequest());
      var status = await page.evaluate('''async() => {
      var request = new XMLHttpRequest();
      request.open('GET', '/logo.png', false);  // `false` makes the request synchronous
      request.send(null);
      return request.status;
      }''');
      expect(status, equals(200));
    });
    test('should works with customizing referer headers', () async {
      await page.setExtraHTTPHeaders({'referer': server.emptyPage});
      await page.setRequestInterception(true);
      page.onRequest.listen((request) {
        expect(request.headers['referer'], equals(server.emptyPage));
        request.continueRequest();
      });
      var response = await page.goto(server.emptyPage);
      expect(response.ok, isTrue);
    });
    test('should be abortable', () async {
      await page.setRequestInterception(true);
      page.onRequest.listen((request) {
        if (request.url.endsWith('.css')) {
          request.abort();
        } else {
          request.continueRequest();
        }
      });
      var failedRequests = 0;
      page.onRequestFailed.listen((event) {
        ++failedRequests;
      });
      var response = await page.goto(server.prefix + '/one-style.html');
      expect(response.ok, isTrue);
      expect(response.request.failure, isNull);
      expect(failedRequests, equals(1));
    });
    test('should be abortable with custom error codes', () async {
      await page.setRequestInterception(true);
      page.onRequest.listen((request) {
        request.abort(error: ErrorReason.internetDisconnected);
      });
      Request? failedRequest;
      page.onRequestFailed.listen((request) => failedRequest = request);
      try {
        await page.goto(server.emptyPage);
      } catch (e) {
        // ok
      }
      expect(failedRequest, isNotNull);
      expect(failedRequest!.failure, 'net::ERR_INTERNET_DISCONNECTED');
    });
    test('should send referer', () async {
      await page.setExtraHTTPHeaders({'referer': 'http://google.com/'});
      await page.setRequestInterception(true);
      page.onRequest.listen((request) => request.continueRequest());
      var request = await waitFutures(server.waitForRequest('/grid.html'), [
        page.goto(server.prefix + '/grid.html'),
      ]);
      expect(request.headers['referer'], equals('http://google.com/'));
    });
    test('should fail navigation when aborting main resource', () async {
      await page.setRequestInterception(true);
      page.onRequest.listen((request) => request.abort());
      expect(() => page.goto(server.emptyPage),
          throwsA(predicate((e) => '$e'.contains('net::ERR_FAILED'))));
    });
    test('should work with redirects', () async {
      await page.setRequestInterception(true);
      var requests = <Request>[];
      page.onRequest.listen((request) {
        request.continueRequest();
        requests.add(request);
      });
      server.setRedirect(
          '/non-existing-page.html', '/non-existing-page-2.html');
      server.setRedirect(
          '/non-existing-page-2.html', '/non-existing-page-3.html');
      server.setRedirect(
          '/non-existing-page-3.html', '/non-existing-page-4.html');
      server.setRedirect('/non-existing-page-4.html', '/empty.html');
      var response = await page.goto(server.prefix + '/non-existing-page.html');
      expect(response.status, equals(200));
      expect(response.url, contains('empty.html'));
      expect(requests.length, equals(5));
      expect(requests[2].resourceType, equals(ResourceType.document));
      // Check redirect chain
      var redirectChain = response.request.redirectChain;
      expect(redirectChain.length, equals(4));
      expect(redirectChain[0].url, contains('/non-existing-page.html'));
      expect(redirectChain[2].url, contains('/non-existing-page-3.html'));
      for (var i = 0; i < redirectChain.length; ++i) {
        var request = redirectChain[i];
        expect(request.isNavigationRequest, isTrue);
        expect(request.redirectChain.indexOf(request), equals(i));
      }
    });
    test('should work with redirects for subresources', () async {
      await page.setRequestInterception(true);
      var requests = <Request>[];
      page.onRequest.listen((request) {
        request.continueRequest();
        if (!request.url.contains('favicon.ico')) requests.add(request);
      });
      server.setRedirect('/one-style.css', '/two-style.css');
      server.setRedirect('/two-style.css', '/three-style.css');
      server.setRedirect('/three-style.css', '/four-style.css');
      server.setRoute('/four-style.css',
          (req) => shelf.Response.ok('body {box-sizing: border-box; }'));

      var response = await page.goto(server.prefix + '/one-style.html');
      expect(response.status, equals(200));
      expect(response.url, contains('one-style.html'));
      expect(requests.length, equals(5));
      expect(requests[0].resourceType, equals(ResourceType.document));
      expect(requests[1].resourceType, equals(ResourceType.stylesheet));
      // Check redirect chain
      var redirectChain = requests[1].redirectChain;
      expect(redirectChain.length, equals(3));
      expect(redirectChain[0].url, contains('/one-style.css'));
      expect(redirectChain[2].url, contains('/three-style.css'));
    });
    test('should be able to abort redirects', () async {
      await page.setRequestInterception(true);
      server.setRedirect('/non-existing.json', '/non-existing-2.json');
      server.setRedirect('/non-existing-2.json', '/simple.html');
      page.onRequest.listen((request) {
        if (request.url.contains('non-existing-2')) {
          request.abort();
        } else {
          request.continueRequest();
        }
      });
      await page.goto(server.emptyPage);
      var result = await page.evaluate('''async() => {
      try {
      await fetch('/non-existing.json');
      } catch (e) {
      return e.message;
      }
      }''');
      expect(result, contains('Failed to fetch'));
    });
    test('should work with equal requests', () async {
      await page.goto(server.emptyPage);
      var responseCount = 1;
      server.setRoute(
          '/zzz', (req) => shelf.Response.ok('${(responseCount++) * 11}'));
      await page.setRequestInterception(true);

      var spinner = false;
      // Cancel 2nd request.
      page.onRequest.listen((request) {
        if (request.url.contains('favicon.ico')) {
          request.continueRequest();
          return;
        }
        spinner ? request.abort() : request.continueRequest();
        spinner = !spinner;
      });
      var results = await page.evaluate('''() => Promise.all([
      fetch('/zzz').then(response => response.text()).catch(e => 'FAILED'),
      fetch('/zzz').then(response => response.text()).catch(e => 'FAILED'),
      fetch('/zzz').then(response => response.text()).catch(e => 'FAILED'),
      ])''');
      expect(results, equals(['11', 'FAILED', '22']));
    });
    test('should navigate to dataURL and fire dataURL requests', () async {
      await page.setRequestInterception(true);
      var requests = [];
      page.onRequest.listen((request) {
        requests.add(request);
        request.continueRequest();
      });
      var dataURL = 'data:text/html,<div>yo</div>';
      var response = await page.goto(dataURL);
      expect(response.status, equals(200));
      expect(requests.length, equals(1));
      expect(requests[0].url, equals(dataURL));
    });
    test('should be able to fetch dataURL and fire dataURL requests', () async {
      await page.goto(server.emptyPage);
      await page.setRequestInterception(true);
      var requests = <Request>[];
      page.onRequest.listen((request) {
        requests.add(request);
        request.continueRequest();
      });
      var dataURL = 'data:text/html,<div>yo</div>';
      var text = await page
          .evaluate('url => fetch(url).then(r => r.text())', args: [dataURL]);
      expect(requests, hasLength(1));
      expect(requests[0].url, equals(dataURL));
      expect(text, equals('<div>yo</div>'));
    });
    test('should navigate to URL with hash and and fire requests without hash',
        () async {
      await page.setRequestInterception(true);
      var requests = [];
      page.onRequest.listen((request) {
        requests.add(request);
        request.continueRequest();
      });
      var response = await page.goto(server.emptyPage + '#hash');
      expect(response.status, equals(200));
      expect(response.url, equals(server.emptyPage));
      expect(requests.length, equals(1));
      expect(requests[0].url, equals(server.emptyPage));
    });
    test('should work with encoded server', () async {
      // The requestWillBeSent will report encoded URL, whereas interception will
      // report URL as-is. @see crbug.com/759388
      await page.setRequestInterception(true);
      page.onRequest.listen((request) => request.continueRequest());
      var response = await page.goto(server.prefix + '/some nonexisting page');
      expect(response.status, equals(404));
    });
    test('should work with badly encoded server', () async {
      await page.setRequestInterception(true);
      server.setRoute('/malformed', (req) => shelf.Response.ok(''));
      page.onRequest.listen((request) => request.continueRequest());
      var response = await page.goto(server.prefix + '/malformed?rnd=%911');
      expect(response.status, equals(200));
    }, skip: 'Has error with URI parsing');
    test('should work with encoded server - 2', () async {
      // The requestWillBeSent will report URL as-is, whereas interception will
      // report encoded URL for stylesheet. @see crbug.com/759388
      await page.setRequestInterception(true);
      var requests = <Request>[];
      page.onRequest.listen((request) {
        request.continueRequest();
        requests.add(request);
      });
      var response = await page.goto(
          'data:text/html,<link rel="stylesheet" href="${server.prefix}/fonts?helvetica|arial"/>');
      expect(response.status, equals(200));
      expect(requests.length, equals(2));
      expect(requests[1].response!.status, equals(404));
    });
    test(
        'should not throw Invalid Interception Id if the request was cancelled',
        () async {
      await page.setContent('<iframe></iframe>');
      await page.setRequestInterception(true);
      Request? request;
      page.onRequest.listen((r) {
        request = r;
      });
      // ignore: unawaited_futures
      page.$eval('iframe', '(frame, url) => frame.src = url',
          args: [server.emptyPage]);
      // Wait for request interception.
      await page.onRequest.first;
      // Delete frame to cause request to be canceled.
      await page.$eval('iframe', 'frame => frame.remove()');
      await request!.continueRequest();
    });
    test('should throw if interception is not enabled', () async {
      AssertionError? error;
      page.onRequest.listen((request) async {
        try {
          await request.continueRequest();
        } on AssertionError catch (e) {
          error = e;
        }
      });
      await page.goto(server.emptyPage);
      expect(error!.message, contains('Request Interception is not enabled'));
    });
    test('should work with file URLs', () async {
      await page.setRequestInterception(true);
      var urls = <String>{};
      page.onRequest.listen((request) {
        urls.add(request.url.split('/').last);
        request.continueRequest();
      });
      await page.goto(Uri.file(
              File(p.join('test', 'assets', 'one-style.html')).absolute.path)
          .toString());
      expect(urls.length, equals(2));
      expect(urls.contains('one-style.html'), isTrue);
      expect(urls.contains('one-style.css'), isTrue);
    });
  });

  group('Request.continue', () {
    test('should work', () async {
      await page.setRequestInterception(true);
      page.onRequest.listen((request) => request.continueRequest());
      await page.goto(server.emptyPage);
    });
    test('should amend HTTP headers', () async {
      await page.setRequestInterception(true);
      page.onRequest.listen((request) {
        var headers = Map<String, String>.from(request.headers)
          ..['FOO'] = 'bar';
        request.continueRequest(headers: headers);
      });
      await page.goto(server.emptyPage);
      var request = await waitFutures(server.waitForRequest('/sleep.zzz'),
          [page.evaluate("() => fetch('/sleep.zzz')")]);
      expect(request.headers['foo'], equals('bar'));
    });
    test('should redirect in a way non-observable to page', () async {
      await page.setRequestInterception(true);
      page.onRequest.listen((request) {
        var redirectURL = request.url.contains('/empty.html')
            ? server.prefix + '/consolelog.html'
            : null;
        request.continueRequest(url: redirectURL);
      });
      ConsoleMessage? consoleMessage;
      page.onConsole.listen((msg) => consoleMessage = msg);
      await page.goto(server.emptyPage);
      expect(page.url, equals(server.emptyPage));
      expect(consoleMessage!.text, equals('yellow'));
    });
    test('should amend method', () async {
      await page.goto(server.emptyPage);

      await page.setRequestInterception(true);
      page.onRequest.listen((request) {
        request.continueRequest(method: 'POST');
      });
      var request = await waitFutures(server.waitForRequest('/sleep.zzz'),
          [page.evaluate("() => fetch('/sleep.zzz')")]);
      expect(request.method, equals('POST'));
    });
    test('should amend post data', () async {
      await page.goto(server.emptyPage);

      await page.setRequestInterception(true);
      page.onRequest.listen((request) {
        request.continueRequest(postData: 'doggo');
      });
      String? body;
      server.setRoute('sleep.zzz', (request) async {
        body = await request.readAsString();
        return shelf.Response.ok('ok');
      });
      var serverRequest = await waitFutures(
          server.waitForRequest('/sleep.zzz'), [
        page.evaluate(
            "() => fetch('/sleep.zzz', { method: 'POST', body: 'birdy' })")
      ]);
      expect(serverRequest, isNotNull);
      expect(body, equals('doggo'));
    });
    test('should amend both post data and method on navigation', () async {
      await page.setRequestInterception(true);
      page.onRequest.listen((request) {
        request.continueRequest(method: 'POST', postData: 'doggo');
      });
      String? body;
      server.setRoute('empty.html', (request) async {
        body = await request.readAsString();
        return shelf.Response.ok('ok');
      });
      var serverRequest =
          await waitFutures(server.waitForRequest('/empty.html'), [
        page.goto(server.emptyPage),
      ]);
      expect(serverRequest.method, equals('POST'));
      expect(body, equals('doggo'));
    });
  });

  group('Request.respond', () {
    test('should work', () async {
      await page.setRequestInterception(true);
      page.onRequest.listen((request) {
        request.respond(
            status: 201, headers: {'foo': 'bar'}, body: 'Yo, page!');
      });
      var response = await page.goto(server.emptyPage);
      expect(response.status, equals(201));
      expect(response.headers['foo'], equals('bar'));
      expect(await page.evaluate('() => document.body.textContent'),
          equals('Yo, page!'));
    });
    test('should work with status code 422', () async {
      await page.setRequestInterception(true);
      page.onRequest.listen((request) {
        request.respond(status: 422, body: 'Yo, page!');
      });
      var response = await page.goto(server.emptyPage);
      expect(response.status, equals(422));
      expect(response.statusText, equals('Unprocessable Entity'));
      expect(await page.evaluate('() => document.body.textContent'),
          equals('Yo, page!'));
    });
    test('should redirect', () async {
      await page.setRequestInterception(true);
      page.onRequest.listen((request) {
        if (!request.url.contains('rrredirect')) {
          request.continueRequest();
          return;
        }
        request.respond(
          status: 302,
          headers: {
            'location': server.emptyPage,
          },
        );
      });
      var response = await page.goto(server.prefix + '/rrredirect');
      expect(response.request.redirectChain.length, equals(1));
      expect(response.request.redirectChain[0].url,
          equals(server.prefix + '/rrredirect'));
      expect(response.url, equals(server.emptyPage));
    });
    test('should allow mocking binary responses', () async {
      await page.emulate(puppeteer.devices.laptopWithMDPIScreen);
      await page.setRequestInterception(true);
      page.onRequest.listen((request) {
        var imageBuffer =
            File(p.join('test', 'assets', 'pptr.png')).readAsBytesSync();
        request.respond(contentType: 'image/png', body: imageBuffer);
      });
      await page.evaluate('''PREFIX => {
      var img = document.createElement('img');
      img.src = PREFIX + '/does-not-exist.png';
      document.body.appendChild(img);
      return new Promise(fulfill => img.onload = fulfill);
      }''', args: [server.prefix]);
      var img = await page.$('img');
      expect(await img.screenshot(),
          equalsGolden('test/golden/mock-binary-response.png'));
    }, tags: ['golden']);
  });
}
