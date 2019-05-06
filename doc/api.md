# Puppeteer API

##### Table of Contents

- [class: Browser](#class-browser)
  * [browser.browserContexts](#browserbrowsercontexts)
  * [browser.close](#browserclose)
  * [browser.createIncognitoBrowserContext](#browsercreateincognitobrowsercontext)
  * [browser.defaultBrowserContext](#browserdefaultbrowsercontext)
  * [browser.newPage](#browsernewpage)
  * [browser.onTargetChanged](#browserontargetchanged)
  * [browser.onTargetCreated](#browserontargetcreated)
  * [browser.onTargetDestroyed](#browserontargetdestroyed)
  * [browser.pages](#browserpages)
  * [browser.target](#browsertarget)
  * [browser.targets](#browsertargets)
  * [browser.userAgent](#browseruseragent)
  * [browser.version](#browserversion)
  * [browser.waitForTarget](#browserwaitfortargetbool-functiontarget-predicate-duration-timeout)
- [class: BrowserContext](#class-browsercontext)
  * [browserContext.browser](#browsercontextbrowser)
  * [browserContext.clearPermissionOverrides](#browsercontextclearpermissionoverrides)
  * [browserContext.close](#browsercontextclose)
  * [browserContext.isIncognito](#browsercontextisincognito)
  * [browserContext.newPage](#browsercontextnewpage)
  * [browserContext.onTargetChanged](#browsercontextontargetchanged)
  * [browserContext.onTargetCreated](#browsercontextontargetcreated)
  * [browserContext.onTargetDestroyed](#browsercontextontargetdestroyed)
  * [browserContext.overridePermissions](#browsercontextoverridepermissionsstring-origin-listpermissiontype-permissions)
  * [browserContext.pages](#browsercontextpages)
  * [browserContext.targets](#browsercontexttargets)
  * [browserContext.waitForTarget](#browsercontextwaitfortarget-functiontarget-predicate-duration-timeout)
- [class: Page](#class-page)
  * [page.$](#pagestring-selector)
  * [page.$$](#pagestring-selector)
  * [page.$$eval](#pageevalstring-selector-languagejs-string-pagefunction-list-args)
  * [page.$eval](#pageevalstring-selector-languagejs-string-pagefunction-list-args)
  * [page.$x](#pagexstring-expression)
  * [page.addScriptTag](#pageaddscripttagstring-url-file-file-string-content-string-type)
  * [page.addStyleTag](#pageaddstyletagstring-url-file-file-string-content)
  * [page.authenticate](#pageauthenticatestring-username-string-password)
  * [page.bringToFront](#pagebringtofront)
  * [page.browser](#pagebrowser)
  * [page.browserContext](#pagebrowsercontext)
  * [page.click](#pageclickstring-selector-duration-delay-mousebutton-button-int-clickcount)
  * [page.close](#pageclosebool-runbeforeunload)
  * [page.content](#pagecontent)
  * [page.cookies](#pagecookiesliststring-urls)
  * [page.defaultNavigationTimeout](#pagedefaultnavigationtimeout)
  * [page.defaultTimeout](#pagedefaulttimeout)
  * [page.emulate](#pageemulatedevice-device)
  * [page.emulateMedia](#pageemulatemediastring-mediatype)
  * [page.evaluate](#pageevaluatelanguagejs-string-pagefunction-list-args)
  * [page.evaluateHandle](#pageevaluatehandlelanguagejs-string-pagefunction-list-args)
  * [page.evaluateOnNewDocument](#pageevaluateonnewdocumentstring-pagefunction-list-args)
  * [page.exposeFunction](#pageexposefunctionstring-name-function-callbackfunction)
  * [page.frames](#pageframes)
  * [page.goBack](#pagegobackduration-timeout-until-wait)
  * [page.goForward](#pagegoforwardduration-timeout-until-wait)
  * [page.goto](#pagegotostring-url-string-referrer-duration-timeout-until-wait)
  * [page.hover](#pagehoverstring-selector)
  * [page.isClosed](#pageisclosed)
  * [page.mainFrame](#pagemainframe)
  * [page.onClose](#pageonclose)
  * [page.onConsole](#pageonconsole)
  * [page.onDialog](#pageondialog)
  * [page.onDomContentLoaded](#pageondomcontentloaded)
  * [page.onError](#pageonerror)
  * [page.onFrameAttached](#pageonframeattached)
  * [page.onFrameDetached](#pageonframedetached)
  * [page.onFrameNavigated](#pageonframenavigated)
  * [page.onLoad](#pageonload)
  * [page.onPageCrashed](#pageonpagecrashed)
  * [page.onPopup](#pageonpopup)
  * [page.onRequest](#pageonrequest)
  * [page.onRequestFailed](#pageonrequestfailed)
  * [page.onRequestFinished](#pageonrequestfinished)
  * [page.onResponse](#pageonresponse)
  * [page.pdf](#pagepdfpaperformat-format-num-scale-bool-displayheaderfooter-string-headertemplate-string-footertemplate-bool-printbackground-bool-landscape-string-pageranges-bool-prefercsspagesize-pdfmargins-margins)
  * [page.queryObjects](#pagequeryobjectsjshandle-prototypehandle)
  * [page.reload](#pagereloadduration-timeout-until-wait)
  * [page.screenshot](#pagescreenshotscreenshotformat-format-bool-fullpage-rectangle-clip-num-quality-bool-omitbackground)
  * [page.screenshotBase64](#pagescreenshotbase64screenshotformat-format-bool-fullpage-rectangle-clip-num-quality-bool-omitbackground)
  * [page.select](#pageselectstring-selector-liststring-values)
  * [page.setBypassCSP](#pagesetbypasscspbool-enabled)
  * [page.setCacheEnabled](#pagesetcacheenabledenabled)
  * [page.setContent](#pagesetcontentstring-html-duration-timeout-until-wait)
  * [page.setExtraHTTPHeaders](#pagesetextrahttpheadersmapstring-string-headers)
  * [page.setGeolocation](#pagesetgeolocationnum-latitude-num-longitude-num-accuracy)
  * [page.setJavaScriptEnabled](#pagesetjavascriptenabledenabled)
  * [page.setOfflineMode](#pagesetofflinemodebool-enabled)
  * [page.setRequestInterception](#pagesetrequestinterceptionbool-value)
  * [page.setUserAgent](#pagesetuseragentstring-useragent)
  * [page.setViewport](#pagesetviewportdeviceviewport-viewport)
  * [page.tap](#pagetapstring-selector)
  * [page.target](#pagetarget)
  * [page.title](#pagetitle)
  * [page.type](#pagetypestring-selector-string-text-duration-delay)
  * [page.url](#pageurl)
  * [page.waitForFunction](#pagewaitforfunctionlanguagejs-string-pagefunction-list-args-duration-timeout-polling-polling)
  * [page.waitForNavigation](#pagewaitfornavigationduration-timeout-until-wait)
  * [page.waitForRequest](#pagewaitforrequeststring-url-duration-timeout)
  * [page.waitForSelector](#pagewaitforselectorstring-selector-bool-visible-bool-hidden-duration-timeout)
  * [page.waitForXPath](#pagewaitforxpathstring-xpath-bool-visible-bool-hidden-duration-timeout)
- [class: Keyboard](#class-keyboard)
  * [keyboard.down](#keyboarddownkey-key-string-text)
  * [keyboard.press](#keyboardpresskey-key-duration-delay-string-text)
  * [keyboard.sendCharacter](#keyboardsendcharacterstring-text)
  * [keyboard.type](#keyboardtypestring-text-duration-delay)
  * [keyboard.up](#keyboardupkey-key)
- [class: Mouse](#class-mouse)
  * [mouse.click](#mouseclickpoint-position-duration-delay-mousebutton-button-int-clickcount)
  * [mouse.down](#mousedownmousebutton-button-int-clickcount)
  * [mouse.move](#mousemovepoint-position-int-steps)
  * [mouse.up](#mouseupmousebutton-button-int-clickcount)
- [class: Touchscreen](#class-touchscreen)
  * [touchscreen.tap](#touchscreentappoint-position)
- [class: Dialog](#class-dialog)
  * [dialog.accept](#dialogacceptstring-prompttext)
  * [dialog.defaultValue](#dialogdefaultvalue)
  * [dialog.dismiss](#dialogdismiss)
  * [dialog.message](#dialogmessage)
  * [dialog.type](#dialogtype)
- [class: ConsoleMessage](#class-consolemessage)
- [class: Frame](#class-pageframe)
  * [pageFrame.$](#pageframestring-selector)
  * [pageFrame.$$](#pageframestring-selector)
  * [pageFrame.$$eval](#pageframeevalstring-selector-languagejs-string-pagefunction-list-args)
  * [pageFrame.$eval](#pageframeevalstring-selector-languagejs-string-pagefunction-list-args)
  * [pageFrame.$x](#pageframexstring-expression)
  * [pageFrame.name](#pageframename)
- [class: ExecutionContext](#class-executioncontext)
  * [executionContext.evaluate](#executioncontextevaluatelanguagejs-string-pagefunction-list-args)
  * [executionContext.evaluateHandle](#executioncontextevaluatehandlelanguagejs-string-pagefunction-list-args)
  * [executionContext.frame](#executioncontextframe)
  * [executionContext.queryObjects](#executioncontextqueryobjectsjshandle-prototypehandle)
- [class: JsHandle](#class-jshandle)
  * [jsHandle.asElement](#jshandleaselement)
  * [jsHandle.dispose](#jshandledispose)
  * [jsHandle.executionContext](#jshandleexecutioncontext)
  * [jsHandle.jsonValue](#jshandlejsonvalue)
  * [jsHandle.properties](#jshandleproperties)
  * [jsHandle.property](#jshandlepropertystring-propertyname)
  * [jsHandle.propertyValue](#jshandlepropertyvaluestring-propertyname)
- [class: ElementHandle](#class-elementhandle)
  * [elementHandle.$](#elementhandlestring-selector)
  * [elementHandle.$$](#elementhandlestring-selector)
  * [elementHandle.$$eval](#elementhandleevalstring-selector-languagejs-string-pagefunction-list-args)
  * [elementHandle.$eval](#elementhandleevalstring-selector-languagejs-string-pagefunction-list-args)
  * [elementHandle.$x](#elementhandlexstring-expression)
  * [elementHandle.boundingBox](#elementhandleboundingbox)
  * [elementHandle.boxModel](#elementhandleboxmodel)
  * [elementHandle.click](#elementhandleclickduration-delay-mousebutton-button-int-clickcount)
  * [elementHandle.contentFrame](#elementhandlecontentframe)
  * [elementHandle.focus](#elementhandlefocus)
  * [elementHandle.isIntersectingViewport](#elementhandleisintersectingviewport)
  * [elementHandle.press](#elementhandlepresskey-key-duration-delay-string-text)
  * [elementHandle.screenshot](#elementhandlescreenshotscreenshotformat-format-num-quality-bool-omitbackground)
  * [elementHandle.tap](#elementhandletap)
  * [elementHandle.type](#elementhandletypestring-text-duration-delay)
  * [elementHandle.uploadFile](#elementhandleuploadfilelistfile-files)
- [class: Request](#class-networkrequest)
  * [networkRequest.abort](#networkrequestaborterrorreason-error)
  * [networkRequest.continueRequest](#networkrequestcontinuerequeststring-url-string-method-string-postdata-map-headers)
  * [networkRequest.failure](#networkrequestfailure)
  * [networkRequest.frame](#networkrequestframe)
  * [networkRequest.headers](#networkrequestheaders)
  * [networkRequest.isNavigationRequest](#networkrequestisnavigationrequest)
  * [networkRequest.method](#networkrequestmethod)
  * [networkRequest.postData](#networkrequestpostdata)
  * [networkRequest.redirectChain](#networkrequestredirectchain)
  * [networkRequest.resourceType](#networkrequestresourcetype)
  * [networkRequest.respond](#networkrequestrespondint-status-mapstring-string-headers-string-contenttype-body)
  * [networkRequest.response](#networkrequestresponse)
  * [networkRequest.url](#networkrequesturl)
- [class: Response](#class-networkresponse)
  * [networkResponse.bytes](#networkresponsebytes)
  * [networkResponse.frame](#networkresponseframe)
  * [networkResponse.fromCache](#networkresponsefromcache)
  * [networkResponse.fromServiceWorker](#networkresponsefromserviceworker)
  * [networkResponse.headers](#networkresponseheaders)
  * [networkResponse.json](#networkresponsejson)
  * [networkResponse.ok](#networkresponseok)
  * [networkResponse.remoteIPAddress](#networkresponseremoteipaddress)
  * [networkResponse.remotePort](#networkresponseremoteport)
  * [networkResponse.request](#networkresponserequest)
  * [networkResponse.securityDetails](#networkresponsesecuritydetails)
  * [networkResponse.status](#networkresponsestatus)
  * [networkResponse.statusText](#networkresponsestatustext)
  * [networkResponse.text](#networkresponsetext)
  * [networkResponse.url](#networkresponseurl)

### class: Browser
A Browser is created when Puppeteer connects to a Chromium instance, either
through puppeteer.launch or puppeteer.connect.

An example of using a Browser to create a Page:

```dart
main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.goto('https://example.com');
  await browser.close();
}
```

#### browser.browserContexts
Returns a list of all open browser contexts. In a newly created browser,
this will return a single instance of BrowserContext.

```dart
browser.browserContexts → List<BrowserContext>
```

#### browser.close()
Closes Chromium and all of its pages (if any were opened). The Browser
object itself is considered to be disposed and cannot be used anymore.

```dart
browser.close() → Future
```

#### browser.createIncognitoBrowserContext()
Creates a new incognito browser context. This won't share cookies/cache
with other browser contexts.

```dart
main() async {
  var browser = await puppeteer.launch();
  // Create a new incognito browser context.
  var context = await browser.createIncognitoBrowserContext();
  // Create a new page in a pristine context.
  var page = await context.newPage();
  // Do stuff
  await page.goto('https://example.com');
  await browser.close();
}
```

```dart
browser.createIncognitoBrowserContext() → Future<BrowserContext>
```

#### browser.defaultBrowserContext
Returns the default browser context. The default browser context can not
be closed.

```dart
browser.defaultBrowserContext → BrowserContext
```

#### browser.newPage()
Future which resolves to a new Page object. The Page is created in a
default browser context.

```dart
browser.newPage() → Future<Page>
```

#### browser.onTargetChanged
Emitted when the url of a target changes.

NOTE This includes target changes in incognito browser contexts.

```dart
browser.onTargetChanged → Stream<Target>
```

#### browser.onTargetCreated
Emitted when a target is created, for example when a new page is opened by
[window.open](https://developer.mozilla.org/en-US/docs/Web/API/Window/open)
or [Browser.newPage].

NOTE This includes target creations in incognito browser contexts.

```dart
browser.onTargetCreated → Stream<Target>
```

#### browser.onTargetDestroyed
Emitted when a target is destroyed, for example when a page is closed.

NOTE This includes target destructions in incognito browser contexts.

```dart
browser.onTargetDestroyed → Stream<Target>
```

#### browser.pages
Future which resolves to a list of all open pages. Non visible pages,
such as "background_page", will not be listed here. You can find them
using [Target.page].

A list of all pages inside the Browser. In case of multiple browser
contexts, the method will return an array with all the pages in all
browser contexts.

```dart
browser.pages → Future<List<Page>>
```

#### browser.target
A target associated with the browser.

```dart
browser.target → Target
```

#### browser.targets
A list of all active targets inside the Browser. In case of multiple
browser contexts, the method will return an array with all the targets in
all browser contexts.

```dart
browser.targets → List<Target>
```

#### browser.userAgent
Future which resolves to the browser's original user agent.

NOTE Pages can override browser user agent with [Page.setUserAgent]

```dart
browser.userAgent → Future<String>
```

#### browser.version
For headless Chromium, this is similar to HeadlessChrome/61.0.3153.0. For
non-headless, this is similar to Chrome/61.0.3153.0.

```dart
browser.version → Future<String>
```

#### browser.waitForTarget(bool Function(Target) predicate, {Duration timeout})
This searches for a target in all browser contexts.

An example of finding a target for a page opened via window.open:
```dart
var newWindowTarget =
    browser.waitForTarget((target) => target.url == 'https://example.com/');
await page.evaluate("() => window.open('https://example.com/')");
await newWindowTarget;
```

```dart
browser.waitForTarget(bool Function(Target) predicate, {Duration timeout}) → Future<Target>
```

### class: BrowserContext
BrowserContexts provide a way to operate multiple independent browser
sessions. When a browser is launched, it has a single BrowserContext used by
default. The method [Browser.newPage] creates a page in the default browser
context.

If a page opens another page, e.g. with a window.open call, the popup will
belong to the parent page's browser context.

Puppeteer allows creation of "incognito" browser contexts with
[Browser.createIncognitoBrowserContext] method. "Incognito" browser contexts
don't write any browsing data to disk.

#### browserContext.browser
The browser this browser context belongs to.

```dart
browserContext.browser → Browser
```

#### browserContext.clearPermissionOverrides()
Clears all permission overrides for the browser context.

```dart
var context = browser.defaultBrowserContext;
await context.overridePermissions(
    'https://example.com', [PermissionType.clipboardRead]);
// do stuff ..
await context.clearPermissionOverrides();
```

```dart
browserContext.clearPermissionOverrides() → Future<void>
```

#### browserContext.close()
Closes the browser context. All the targets that belong to the browser
context will be closed.

OTE only incognito browser contexts can be closed.

```dart
browserContext.close() → Future<void>
```

#### browserContext.isIncognito
Returns whether BrowserContext is incognito. The default browser context
is the only non-incognito browser context.

```dart
browserContext.isIncognito → bool
```

#### browserContext.newPage()
Creates a new page in the browser context.

```dart
browserContext.newPage() → Future<Page>
```

#### browserContext.onTargetChanged
Emitted when the url of a target inside the browser context changes.

```dart
browserContext.onTargetChanged → Stream<Target>
```

#### browserContext.onTargetCreated
Emitted when a new target is created inside the browser context, for
example when a new page is opened by window.open or browserContext.newPage.

```dart
browserContext.onTargetCreated → Stream<Target>
```

#### browserContext.onTargetDestroyed
Emitted when a target inside the browser context is destroyed, for example
when a page is closed.

```dart
browserContext.onTargetDestroyed → Stream<Target>
```

#### browserContext.overridePermissions(String origin, List\<PermissionType> permissions)
origin <string> The origin to grant permissions to, e.g. "https://example.com".
permissions <Array<string>> An array of permissions to grant. All
permissions that are not listed here will be automatically denied.

```dart
var context = browser.defaultBrowserContext;
await context.overridePermissions(
    'https://html5demos.com', [PermissionType.geolocation]);
```

```dart
browserContext.overridePermissions(String origin, List<PermissionType> permissions) → Future<void>
```

#### browserContext.pages
An array of all pages inside the browser context.

```dart
browserContext.pages → Future<List<Page>>
```

#### browserContext.targets
An array of all active targets inside the browser context.

```dart
browserContext.targets → List<Target>
```

#### browserContext.waitForTarget( Function(Target) predicate, {Duration timeout})
This searches for a target in this specific browser context.

```dart
browserContext.waitForTarget( Function(Target) predicate, {Duration timeout}) → Future<Target>
```

### class: Page
Page provides methods to interact with a single tab or extension background
page in Chromium. One Browser instance might have multiple Page instances.

This example creates a page, navigates it to a URL, and then saves a
screenshot:

```dart
 import 'dart:io';
 import 'package:puppeteer/puppeteer.dart';

main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.goto('https://example.com');
  await File('screenshot.png').writeAsBytes(await page.screenshot());
  await browser.close();
}
```

The Page class emits various events which can be handled using any of Dart'
native Stream methods, such as listen, first, map, where...

```dart
page.onLoad.listen((_) => print('Page loaded!'));
```

To unsubscribe from events use the [StreamSubscription.cancel] method:
```dart
logRequest(Request interceptedRequest) {
  print('A request was made: ${interceptedRequest.url}');
}

var subscription = page.onRequest.listen(logRequest);
await subscription.cancel();
```

#### page.$(String selector)
The method runs `document.querySelector` within the page. If no element matches the selector, the return value resolves to `null`.

Shortcut for [Page.mainFrame.$(selector)].

A [selector] to query page for

```dart
page.$(String selector) → Future<ElementHandle>
```

#### page.$$(String selector)
The method runs `document.querySelectorAll` within the page.
If no elements match the selector, the return value resolves to `[]`.

Shortcut for [Page.mainFrame.$$(selector)].

```dart
page.$$(String selector) → Future<List<ElementHandle>>
```

#### page.$$eval(String selector, @Language('js') String pageFunction, {List args})
This method runs `Array.from(document.querySelectorAll(selector))` within
the page and passes it as the first argument to `pageFunction`.

If `pageFunction` returns a [Promise], then `page.$$eval` would wait for
the promise to resolve and return its value.

Examples:
```dart
var divsCounts = await page.$$eval('div', 'divs => divs.length');
```

Parameters:
A [selector] to query page for
[pageFunction] Function to be evaluated in browser context
[args] Arguments to pass to `pageFunction`
Returns a [Future] which resolves to the return value of `pageFunction`

```dart
page.$$eval(String selector, @Language('js') String pageFunction, {List args}) → Future<T>
```

#### page.$eval(String selector, @Language('js') String pageFunction, {List args})
This method runs `document.querySelector` within the page and passes it as
the first argument to `pageFunction`. If there's no element matching
`selector`, the method throws an error.

If `pageFunction` returns a [Promise], then `page.$eval` would wait for
the promise to resolve and return its value.

Examples:
```dart
var searchValue =
    await page.$eval('#search', 'function (el) { return el.value; }');
var preloadHref = await page.$eval(
    'link[rel=preload]', 'function (el) { return el.href; }');
var html = await page.$eval(
    '.main-container', 'function (e) { return e.outerHTML; }');
```

Shortcut for [Page.mainFrame.$eval(selector, pageFunction)].

```dart
page.$eval(String selector, @Language('js') String pageFunction, {List args}) → Future<T>
```

#### page.$x(String expression)
The method evaluates the XPath expression.

Shortcut for [Page.mainFrame.$x(expression)]

Parameters:
[expression]: Expression to [evaluate](https://developer.mozilla.org/en-US/docs/Web/API/Document/evaluate)

```dart
page.$x(String expression) → Future<List<ElementHandle>>
```

#### page.addScriptTag({String url, File file, String content, String type})
Adds a `<script>` tag into the page with the desired url or content.

Shortcut for [Page.mainFrame.addScriptTag].

Parameters:
[url]: URL of a script to be added.
[file]: JavaScript file to be injected into frame
[content]: Raw JavaScript content to be injected into frame.
[type]: Script type. Use 'module' in order to load a Javascript ES6 module.
See [script](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script)
for more details.

Returns a [Future<ElementHandle>] which resolves to the added tag when the
script's onload fires or when the script content was injected into frame.

```dart
page.addScriptTag({String url, File file, String content, String type}) → Future<ElementHandle>
```

#### page.addStyleTag({String url, File file, String content})
Adds a `<link rel="stylesheet">` tag into the page with the desired url or
a `<style type="text/css">` tag with the content.

Shortcut for [Page.mainFrame.addStyleTag].

Parameters:
[url]: URL of the `<link>` tag.
[file]: CSS file to be injected into frame.
[content]: Raw CSS content to be injected into frame.

Returns a [Future<ElementHandle>] which resolves to the added tag when the
stylesheet's onload fires or when the CSS content was injected into frame.

```dart
page.addStyleTag({String url, File file, String content}) → Future<ElementHandle>
```

#### page.authenticate({String userName, String password})
Provide credentials for [HTTP authentication](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication).

To disable authentication, pass `null`.

```dart
page.authenticate({String userName, String password}) → Future<void>
```

#### page.bringToFront()
Brings page to front (activates tab).

```dart
page.bringToFront() → Future<void>
```

#### page.browser
Get the browser the page belongs to.

```dart
page.browser → Browser
```

#### page.browserContext
Get the browser context that the page belongs to.

```dart
page.browserContext → BrowserContext
```

#### page.click(String selector, {Duration delay, MouseButton button, int clickCount})
This method fetches an element with `selector`, scrolls it into view if
needed, and then uses [Page.mouse] to click in the center of the element.
If there's no element matching `selector`, the method throws an error.

Bear in mind that if `click()` triggers a navigation event and there's a
separate `page.waitForNavigation()` promise to be resolved, you may end
up with a race condition that yields unexpected results. The correct
pattern for click and wait for navigation is the following:

```dart
var responseFuture = page.waitForNavigation();
await page.click('a');
var response = await responseFuture;
```

Or simpler, if you don't need the [Response]
```dart
await Future.wait([
  page.waitForNavigation(),
  page.click('a'),
]);
```

Shortcut for [Page.mainFrame.click]

Parameters:
[selector]: A [selector] to search for element to click. If there are
multiple elements satisfying the selector, the first will be clicked.

[button]: <"left"|"right"|"middle"> Defaults to `left`

[clickCount]: defaults to 1

[delay]: Time to wait between `mousedown` and `mouseup`. Default to zero.

```dart
page.click(String selector, {Duration delay, MouseButton button, int clickCount}) → Future<void>
```

#### page.close({bool runBeforeUnload})
By default, [Page.close] **does not** run beforeunload handlers.

**NOTE** if `runBeforeUnload` is passed as true, a `beforeunload` dialog
might be summoned and should be handled manually via page's ['dialog'](#event-dialog) event.

Parameters:
[runBeforeUnload]: Whether to run the
   [before unload](https://developer.mozilla.org/en-US/docs/Web/Events/beforeunload)

```dart
page.close({bool runBeforeUnload}) → Future<void>
```

#### page.content
Gets the full HTML contents of the page, including the doctype.

```dart
page.content → Future<String>
```

#### page.cookies({List\<String> urls})
If no URLs are specified, this method returns cookies for the current page URL.
If URLs are specified, only cookies for those URLs are returned.

```dart
page.cookies({List<String> urls}) → Future<List<Cookie>>
```

#### page.defaultNavigationTimeout
Maximum navigation time in milliseconds
This setting will change the default maximum navigation time for the
following methods and related shortcuts:
- [Page.goBack]
- [Page.goForward]
- [Page.goto]
- [Page.reload]
- [Page.setContent]
- [Page.waitForNavigation]

> **NOTE** [page.defaultNavigationTimeout] takes priority over [page.defaultTimeout]

```dart
page.defaultNavigationTimeout → Duration
```

#### page.defaultTimeout
Maximum time in milliseconds

This setting will change the default maximum time for the following methods
and related shortcuts:
- [Page.goBack]
- [Page.goForward]
- [Page.goto]
- [Page.reload]
- [Page.setContent]
- [Page.waitForFunction]
- [Page.waitForNavigation]
- [Page.waitForRequest]
- [Page.waitForResponse]
- [Page.waitForSelector]
- [Page.waitForXPath]

> **NOTE** [`page.defaultNavigationTimeout`] takes priority over [`page.defaultTimeout`]

```dart
page.defaultTimeout → Duration
```

#### page.emulate(Device device)
Emulates given device metrics and user agent. This method is a shortcut
for calling two methods:
- [Page.setUserAgent]
- [Page.setViewport]

To aid emulation, puppeteer provides a list of device descriptors which can
 be obtained via the [puppeteer.devices].
Below is an example of emulating an iPhone 6 in puppeteer:

```dart
var iPhone = puppeteer.devices.iPhone6;

var browser = await puppeteer.launch();
var page = await browser.newPage();
await page.emulate(iPhone);
await page.goto('https://example.com');
// other actions...
await browser.close();
```

List of all available devices is available in the source code:
[devices.dart](https://github.com/xvrh/puppeteer-dart/blob/master/lib/src/devices.dart).

```dart
page.emulate(Device device) → Future<void>
```

#### page.emulateMedia(String mediaType)
Changes the CSS media type of the page.
The only allowed values are `'screen'`, `'print'` and `null`.
Passing `null` disables media emulation.

```dart
page.emulateMedia(String mediaType) → Future<void>
```

#### page.evaluate(@Language('js') String pageFunction, {List args})
If the function passed to the [Page.evaluate] returns a [Promise], then
[Page.evaluate] would wait for the promise to resolve and return its value.

If the function passed to the [page.evaluate] returns a non-[Serializable]
value, then `page.evaluate` resolves to null.
DevTools Protocol also supports transferring some additional values that
are not serializable by `JSON`: `-0`, `NaN`, `Infinity`, `-Infinity`, and
bigint literals.

Passing arguments to `pageFunction`:
```dart
int result = await page.evaluate('''x => {
        return Promise.resolve(8 * x);
      }''', args: [7]);
print(result); // prints "56"
```

An expression can also be passed in instead of a function:
```dart
print(await page.evaluate('1 + 2')); // prints "3"
var x = 10;
print(await page.evaluate('1 + $x')); // prints "11"
```

[ElementHandle] instances can be passed as arguments to the [Page.evaluate]:
```dart
var bodyHandle = await page.$('body');
var html = await page.evaluate('body => body.innerHTML', args: [bodyHandle]);
await bodyHandle.dispose();
print(html);
```

Shortcut for [Page.mainFrame.evaluate].

Parameters:
- [pageFunction] Function to be evaluated in the page context
- [args] Arguments to pass to `pageFunction`
- Returns: Future which resolves to the return value of `pageFunction`

```dart
page.evaluate(@Language('js') String pageFunction, {List args}) → Future<T>
```

#### page.evaluateHandle(@Language('js') String pageFunction, {List args})
The only difference between [Page.evaluate] and [Page.evaluateHandle] is
that [Page.evaluateHandle] returns in-page object (JSHandle).

If the function passed to the [Page.evaluateHandle] returns a [Promise],
then [Page.evaluateHandle] would wait for the promise to resolve and
return its value.

A JavaScript expression can also be passed in instead of a function:
```dart
// Get an handle for the 'document'
var aHandle = await page.evaluateHandle('document');
```

[JSHandle] instances can be passed as arguments to the [Page.evaluateHandle]:
```dart
var aHandle = await page.evaluateHandle('() => document.body');
var resultHandle =
    await page.evaluateHandle('body => body.innerHTML', args: [aHandle]);
print(await resultHandle.jsonValue);
await resultHandle.dispose();
```

Shortcut for [Page.mainFrame.executionContext.evaluateHandle].

Parameters:
- [pageFunction] Function to be evaluated in the page context
- [args] Arguments to pass to [pageFunction]

returns: Future which resolves to the return value of `pageFunction` as
in-page object (JSHandle)

```dart
page.evaluateHandle(@Language('js') String pageFunction, {List args}) → Future<JsHandle>
```

#### page.evaluateOnNewDocument(String pageFunction, {List args})
Adds a function which would be invoked in one of the following scenarios:
- whenever the page is navigated
- whenever the child frame is attached or navigated. In this case, the
function is invoked in the context of the newly attached frame

The function is invoked after the document was created but before any of
its scripts were run. This is useful to amend the JavaScript environment,
e.g. to seed `Math.random`.

An example of overriding the navigator.languages property before the page
loads:

```javascript
// preload.js

// overwrite the `languages` property to use a custom getter
Object.defineProperty(navigator, "languages", {
  get: function() {
    return ["en-US", "en", "bn"];
  }
});
```

```dart
var preloadFile = File('test/assets/preload.js').readAsStringSync();
await page.evaluateOnNewDocument(preloadFile);
```

Parameters:
- [pageFunction] Function to be evaluated in browser context
- [args] Arguments to pass to [pageFunction]

```dart
page.evaluateOnNewDocument(String pageFunction, {List args}) → Future<void>
```

#### page.exposeFunction(String name, Function callbackFunction)
The method adds a function called `name` on the page's `window` object.
When called, the function executes `puppeteerFunction` in Dart and
returns a [Promise] which resolves to the return value of `puppeteerFunction`.

If the `puppeteerFunction` returns a [Future], it will be awaited.

> **NOTE** Functions installed via `page.exposeFunction` survive navigations.

An example of adding an `md5` function into the page:
```dart
import 'dart:convert';
import 'package:puppeteer/puppeteer.dart';
import 'package:crypto/crypto.dart' as crypto;

main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  page.onConsole.listen((msg) => print(msg.text));
  await page.exposeFunction(
      'md5', (text) => crypto.md5.convert(utf8.encode(text)).toString());
  await page.evaluate(r'''async () => {
          // use window.md5 to compute hashes
          const myString = 'PUPPETEER';
          const myHash = await window.md5(myString);
          console.log(`md5 of ${myString} is ${myHash}`);
        }''');
  await browser.close();
}
```

An example of adding a `window.readfile` function into the page:

```dart
import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  page.onConsole.listen((msg) => print(msg.text));
  await page.exposeFunction('readfile', (String path) async {
    return File(path).readAsString();
  });
  await page.evaluate('''async () => {
          // use window.readfile to read contents of a file
          const content = await window.readfile('test/assets/simple.json');
          console.log(content);
        }''');
  await browser.close();
}
```

Parameters:
- [name]: Name of the function on the window object

```dart
page.exposeFunction(String name, Function callbackFunction) → Future<void>
```

#### page.frames
An array of all frames attached to the page.

```dart
page.frames → List<Frame>
```

#### page.goBack({Duration timeout, Until wait})
Navigate to the previous page in history.

Parameters:
- [timeout] Maximum navigation time in milliseconds, defaults
    to 30 seconds, pass [Duration.zero] to disable timeout. The default value
    can be changed by using the [Page.defaultNavigationTimeout] or
    [Page.defaultTimeout] properties.
- [wait] When to consider navigation succeeded, defaults to [Until.load].
    Given an array of event strings, navigation is considered to be
    successful after all events have been fired. Events can be either:
  - [Until.load] - consider navigation to be finished when the `load`
    event is fired.
  - [Until.domContentLoaded] - consider navigation to be finished when the
    `DOMContentLoaded` event is fired.
  - [Until.networkIdle] - consider navigation to be finished when there
    are no more than 0 network connections for at least `500` ms.
  - [Until.networkAlmostIdle] - consider navigation to be finished when
    there are no more than 2 network connections for at least `500` ms.

Returns: [Future<Response>] which resolves to the main resource
response. In case of multiple redirects, the navigation will resolve with
the response of the last redirect. If can not go back, resolves to `null`.

```dart
page.goBack({Duration timeout, Until wait}) → Future<Response>
```

#### page.goForward({Duration timeout, Until wait})
Navigate to the next page in history.

Parameters:
- [timeout] Maximum navigation time in milliseconds, defaults
    to 30 seconds, pass [Duration.zero] to disable timeout. The default value
    can be changed by using the [Page.defaultNavigationTimeout] or
    [Page.defaultTimeout] properties.
- [wait] When to consider navigation succeeded, defaults to [Until.load].
    Given an array of event strings, navigation is considered to be
    successful after all events have been fired. Events can be either:
  - [Until.load] - consider navigation to be finished when the `load`
    event is fired.
  - [Until.domContentLoaded] - consider navigation to be finished when the
    `DOMContentLoaded` event is fired.
  - [Until.networkIdle] - consider navigation to be finished when there
    are no more than 0 network connections for at least `500` ms.
  - [Until.networkAlmostIdle] - consider navigation to be finished when
    there are no more than 2 network connections for at least `500` ms.

Returns: [Future<Response>] which resolves to the main resource
response. In case of multiple redirects, the navigation will resolve with
the response of the last redirect. If can not go back, resolves to `null`.

```dart
page.goForward({Duration timeout, Until wait}) → Future<Response>
```

#### page.goto(String url, {String referrer, Duration timeout, Until wait})
The [Page.goto] will throw an error if:
- there's an SSL error (e.g. in case of self-signed certificates).
- target URL is invalid.
- the `timeout` is exceeded during navigation.
- the main resource failed to load.

> **NOTE** [Page.goto] either throw or return a main resource response.
The only exceptions are navigation to `about:blank` or navigation to the
same URL with a different hash, which would succeed and return `null`.

> **NOTE** Headless mode doesn't support navigation to a PDF document. See
the [upstream issue](https://bugs.chromium.org/p/chromium/issues/detail?id=761295).

Shortcut for [Page.mainFrame.goto]

Parameters:
- [url]: URL to navigate page to. The url should include scheme, e.g. `https://`.
- [timeout] Maximum navigation time in milliseconds, defaults
    to 30 seconds, pass [Duration.zero] to disable timeout. The default value
    can be changed by using the [Page.defaultNavigationTimeout] or
    [Page.defaultTimeout] properties.
- [wait] When to consider navigation succeeded, defaults to [Until.load].
    Given an array of event strings, navigation is considered to be
    successful after all events have been fired. Events can be either:
  - [Until.load] - consider navigation to be finished when the `load`
    event is fired.
  - [Until.domContentLoaded] - consider navigation to be finished when the
    `DOMContentLoaded` event is fired.
  - [Until.networkIdle] - consider navigation to be finished when there
    are no more than 0 network connections for at least `500` ms.
  - [Until.networkAlmostIdle] - consider navigation to be finished when
    there are no more than 2 network connections for at least `500` ms.
- [referrer] Referer header value. If provided it will take preference
  over the referer header value set by [Page.setExtraHTTPHeaders].

Returns: [Future] which resolves to the main resource response. In case
of multiple redirects, the navigation will resolve with the response of
the last redirect.

```dart
page.goto(String url, {String referrer, Duration timeout, Until wait}) → Future<Response>
```

#### page.hover(String selector)
This method fetches an element with [selector], scrolls it into view if
needed, and then uses [Page.mouse] to hover over the center of
the element.
If there's no element matching [selector], the method throws an error.

Shortcut for [Page.mainFrame.hover].

Parameters:
A [selector] to search for element to hover. If there are multiple elements
satisfying the selector, the first will be hovered.

Returns: [Future] which resolves when the element matching [selector] is
successfully hovered. Future gets rejected if there's no element matching
[selector].

```dart
page.hover(String selector) → Future<void>
```

#### page.isClosed
Indicates that the page has been closed.

```dart
page.isClosed → bool
```

#### page.mainFrame
The page's main frame.

Page is guaranteed to have a main frame which persists during navigations.

```dart
page.mainFrame → Frame
```

#### page.onClose
Complete when the page closes.

```dart
page.onClose → Future<void>
```

#### page.onConsole
Emitted when JavaScript within the page calls one of console API methods,
e.g. console.log or console.dir. Also emitted if the page throws an error
or a warning.

The arguments passed into console.log appear as arguments on the event
handler.

An example of handling console event:

```dart
page.onConsole.listen((msg) {
  for (var i = 0; i < msg.args.length; ++i) {
    print('$i: ${msg.args[i]}');
  }
});
await page.evaluate("() => console.log('hello', 5, {foo: 'bar'})");
```

```dart
page.onConsole → Stream<ConsoleMessage>
```

#### page.onDialog
Emitted when a JavaScript dialog appears, such as `alert`, `prompt`,
`confirm` or `beforeunload`. Puppeteer can respond to the dialog via
[Dialog.accept] or [Dialog.dismiss] methods.

```dart
page.onDialog → Stream<Dialog>
```

#### page.onDomContentLoaded
Emitted when the JavaScript [`DOMContentLoaded`](https://developer.mozilla.org/en-US/docs/Web/Events/DOMContentLoaded)
event is dispatched.

```dart
page.onDomContentLoaded → Stream<MonotonicTime>
```

#### page.onError
Emitted when an uncaught exception happens within the page.

```dart
page.onError → Stream<ClientError>
```

#### page.onFrameAttached
Emitted when a frame is attached.

```dart
page.onFrameAttached → Stream<Frame>
```

#### page.onFrameDetached
Emitted when a frame is detached.

```dart
page.onFrameDetached → Stream<Frame>
```

#### page.onFrameNavigated
Emitted when a frame is navigated to a new url.

```dart
page.onFrameNavigated → Stream<Frame>
```

#### page.onLoad
Emitted when the JavaScript [`load`](https://developer.mozilla.org/en-US/docs/Web/Events/load)
event is dispatched.

```dart
page.onLoad → Stream<MonotonicTime>
```

#### page.onPageCrashed
Emitted when the page crashes.

```dart
page.onPageCrashed → Stream
```

#### page.onPopup
Emitted when the page opens a new tab or window.
```dart
var popupFuture = page.onPopup.first;
await page.click('a[target=_blank]');
Page popup = await popupFuture;
```

```dart
var popupFuture = page.onPopup.first;
await page.evaluate("() => window.open('https://example.com')");
Page popup = await popupFuture;
```

```dart
page.onPopup → Stream<Page>
```

#### page.onRequest
Emitted when a page issues a request.
In order to intercept and mutate requests, see [Page.setRequestInterception].

```dart
page.onRequest → Stream<Request>
```

#### page.onRequestFailed
Emitted when a request fails, for example by timing out.

```dart
page.onRequestFailed → Stream<Request>
```

#### page.onRequestFinished
Emitted when a request finishes successfully.

```dart
page.onRequestFinished → Stream<Request>
```

#### page.onResponse
Emitted when a [response] is received.

```dart
page.onResponse → Stream<Response>
```

#### page.pdf({PaperFormat format, num scale, bool displayHeaderFooter, String headerTemplate, String footerTemplate, bool printBackground, bool landscape, String pageRanges, bool preferCssPageSize, PdfMargins margins})
Generates a pdf of the page with `print` css media. To generate a pdf with
`screen` media, call [Page.emulateMedia('screen')] before calling `page.pdf()`:

> **NOTE** Generating a pdf is currently only supported in Chrome headless.
> **NOTE** By default, `page.pdf()` generates a pdf with modified colors
for printing. Use the [`-webkit-print-color-adjust`](https://developer.mozilla.org/en-US/docs/Web/CSS/-webkit-print-color-adjust)
property to force rendering of exact colors.

```dart
// Generates a PDF with 'screen' media type.
await page.emulateMedia('screen');
var pdfBytes = await page.pdf();
await File('page.pdf').writeAsBytes(pdfBytes);
```

Parameters:
- [scale]: Scale of the webpage rendering. Defaults to `1`. Scale amount
  must be between 0.1 and 2.
- [displayHeaderFooter]: Display header and footer. Defaults to `false`.
- [headerTemplate]: HTML template for the print header. Should be valid
  HTML markup with following classes used to inject printing values into them:
   - `date` formatted print date
   - `title` document title
   - `url` document location
   - `pageNumber` current page number
   - `totalPages` total pages in the document
- [footerTemplate]: HTML template for the print footer. Should use the
   same format as the [headerTemplate].
- [printBackground]: Print background graphics. Defaults to `false`.
- [landscape]: Paper orientation. Defaults to `false`.
- [pageRanges]: Paper ranges to print, e.g., '1-5, 8, 11-13'. Defaults to
  the empty string, which means print all pages.
- [format]: Paper format. Defaults to [PageFormat.letter] (8.5 inches x 11 inches).
- [margins]: Paper margins, defaults to none.
- [preferCssPageSize]: Give any CSS `@page` size declared in the page
  priority over what is declared in [format]. Defaults to `false`,
  which will scale the content to fit the paper size.

Returns: [Future<Uint8List>] which resolves with PDF bytes.

> **NOTE** `headerTemplate` and `footerTemplate` markup have the following
limitations:
> 1. Script tags inside templates are not evaluated.
> 2. Page styles are not visible inside templates.

```dart
page.pdf({PaperFormat format, num scale, bool displayHeaderFooter, String headerTemplate, String footerTemplate, bool printBackground, bool landscape, String pageRanges, bool preferCssPageSize, PdfMargins margins}) → Future<Uint8List>
```

#### page.queryObjects(JsHandle prototypeHandle)
The method iterates the JavaScript heap and finds all the objects with the
given prototype.

```dart
// Create a Map object
await page.evaluate('() => window.map = new Map()');
// Get a handle to the Map object prototype
var mapPrototype = await page.evaluateHandle('() => Map.prototype');
// Query all map instances into an array
var mapInstances = await page.queryObjects(mapPrototype);
// Count amount of map objects in heap
var count = await page.evaluate('maps => maps.length', args: [mapInstances]);
await mapInstances.dispose();
await mapPrototype.dispose();
```

Shortcut for [Page.mainFrame.executionContext.queryObjects].

Parameters:
[prototypeHandle]: A handle to the object prototype.

Returns a [Future] which completes to a handle to an array of objects with
this prototype.

```dart
page.queryObjects(JsHandle prototypeHandle) → Future<JsHandle>
```

#### page.reload({Duration timeout, Until wait})
Parameters:
- [timeout] Maximum navigation time in milliseconds, defaults
    to 30 seconds, pass [Duration.zero] to disable timeout. The default value
    can be changed by using the [Page.defaultNavigationTimeout] or
    [Page.defaultTimeout] properties.
- [wait] When to consider navigation succeeded, defaults to [Until.load].
    Given an array of event strings, navigation is considered to be
    successful after all events have been fired. Events can be either:
  - [Until.load] - consider navigation to be finished when the `load`
    event is fired.
  - [Until.domContentLoaded] - consider navigation to be finished when the
    `DOMContentLoaded` event is fired.
  - [Until.networkIdle] - consider navigation to be finished when there
    are no more than 0 network connections for at least `500` ms.
  - [Until.networkAlmostIdle] - consider navigation to be finished when
    there are no more than 2 network connections for at least `500` ms.
- [referrer] Referer header value. If provided it will take preference
  over the referer header value set by [Page.setExtraHTTPHeaders].

Returns: [Future] which resolves to the main resource response. In case
of multiple redirects, the navigation will resolve with the response of
the last redirect.

```dart
page.reload({Duration timeout, Until wait}) → Future<Response>
```

#### page.screenshot({ScreenshotFormat format, bool fullPage, Rectangle clip, num quality, bool omitBackground})
Parameters:
- [format]: Specify screenshot type, can be either `ScreenshotFormat.jpeg`
  or `ScreenshotFormat.png`. Defaults to 'png'.
- [quality]: The quality of the image, between 0-100. Not applicable to
  `png` images.
- [fullPage]: When true, takes a screenshot of the full scrollable page.
  Defaults to `false`.
- [clip]: a [Rectangle] which specifies clipping region of the page.
- [omitBackground]: Hides default white background and allows capturing
  screenshots with transparency. Defaults to `false`.

Returns:
[Future] which resolves to a list of bytes with captured screenshot.

> **NOTE** Screenshots take at least 1/6 second on OS X. See
https://crbug.com/741689 for discussion.

```dart
page.screenshot({ScreenshotFormat format, bool fullPage, Rectangle clip, num quality, bool omitBackground}) → Future<Uint8List>
```

#### page.screenshotBase64({ScreenshotFormat format, bool fullPage, Rectangle clip, num quality, bool omitBackground})
Parameters:
- [format]: Specify screenshot type, can be either `ScreenshotFormat.jpeg`
  or `ScreenshotFormat.png`. Defaults to 'png'.
- [quality]: The quality of the image, between 0-100. Not applicable to
  `png` images.
- [fullPage]: When true, takes a screenshot of the full scrollable page.
  Defaults to `false`.
- [clip]: a [Rectangle] which specifies clipping region of the page.
- [omitBackground]: Hides default white background and allows capturing
  screenshots with transparency. Defaults to `false`.

Returns:
[Future<String>] which resolves to the captured screenshot encoded in `base64`.

> **NOTE** Screenshots take at least 1/6 second on OS X. See
https://crbug.com/741689 for discussion.

```dart
page.screenshotBase64({ScreenshotFormat format, bool fullPage, Rectangle clip, num quality, bool omitBackground}) → Future<String>
```

#### page.select(String selector, List\<String> values)
Triggers a `change` and `input` event once all the provided options have
been selected.
If there's no `<select>` element matching `selector`, the method throws an
error.

```dart
await page.select('select#colors', ['blue']); // single selection
await page
    .select('select#colors', ['red', 'green', 'blue']); // multiple selections
```

Shortcut for [Page.mainFrame.select]

Parameters:
- [selector]: A [selector] to query page for
- [values]: Values of options to select. If the `<select>` has the
  `multiple` attribute, all values are considered, otherwise only the
  first one is taken into account.

Returns an array of option values that have been successfully selected.

```dart
page.select(String selector, List<String> values) → Future<List<String>>
```

#### page.setBypassCSP(bool enabled)
Toggles bypassing page's Content-Security-Policy.

> **NOTE** CSP bypassing happens at the moment of CSP initialization rather
then evaluation. Usually this means that `page.setBypassCSP` should be called
before navigating to the domain.

```dart
page.setBypassCSP(bool enabled) → Future<void>
```

#### page.setCacheEnabled(enabled)
Toggles ignoring cache for each request based on the enabled state. By
default, caching is enabled.

```dart
page.setCacheEnabled(enabled) → Future<void>
```

#### page.setContent(String html, {Duration timeout, Until wait})
Parameters:
[html]: HTML markup to assign to the page.

```dart
page.setContent(String html, {Duration timeout, Until wait}) → Future<void>
```

#### page.setExtraHTTPHeaders(Map\<String, String> headers)
The extra HTTP headers will be sent with every request the page initiates.

> **NOTE** page.setExtraHTTPHeaders does not guarantee the order of headers
 in the outgoing requests.

```dart
page.setExtraHTTPHeaders(Map<String, String> headers) → Future<void>
```

#### page.setGeolocation({num latitude, num longitude, num accuracy})
Sets the page's geolocation.

```dart
await page.setGeolocation(latitude: 59.95, longitude: 30.31667);
```

> **NOTE** Consider using [BrowserContext.overridePermissions] to grant
permissions for the page to read its geolocation.

```dart
page.setGeolocation({num latitude, num longitude, num accuracy}) → Future<void>
```

#### page.setJavaScriptEnabled(enabled)
Whether or not to enable JavaScript on the page.

> **NOTE** changing this value won't affect scripts that have already been
run. It will take full effect on the next [navigation].

```dart
page.setJavaScriptEnabled(enabled) → Future<void>
```

#### page.setOfflineMode(bool enabled)
When `true`, enables offline mode for the page.

```dart
page.setOfflineMode(bool enabled) → Future<void>
```

#### page.setRequestInterception(bool value)
Whether to enable request interception.

Activating request interception enables `request.abort`, `request.continue`
and `request.respond` methods. This provides the capability to modify
network requests that are made by a page.

Once request interception is enabled, every request will stall unless it's
continued, responded or aborted.
An example of a naïve request interceptor that aborts all image requests:

```dart
var browser = await puppeteer.launch();
var page = await browser.newPage();
await page.setRequestInterception(true);
page.onRequest.listen((interceptedRequest) {
  if (interceptedRequest.url.endsWith('.png') ||
      interceptedRequest.url.endsWith('.jpg')) {
    interceptedRequest.abort();
  } else {
    interceptedRequest.continueRequest();
  }
});
await page.goto('https://example.com');
await browser.close();
```

> **NOTE** Enabling request interception disables page caching.

```dart
page.setRequestInterception(bool value) → Future<void>
```

#### page.setUserAgent(String userAgent)
Specific user agent to use in this page

```dart
page.setUserAgent(String userAgent) → Future<void>
```

#### page.setViewport(DeviceViewport viewport)
> **NOTE** in certain cases, setting viewport will reload the page in order
to set the `isMobile` or `hasTouch` properties.

In the case of multiple pages in a single browser, each page can have its
own viewport size.

```dart
page.setViewport(DeviceViewport viewport) → Future<void>
```

#### page.tap(String selector)
This method fetches an element with `selector`, scrolls it into view if
needed, and then uses [page.touchscreen] to tap in the center of the element.
If there's no element matching `selector`, the method throws an error.

Shortcut for [page.mainFrame.tap].

Parameters:
A [selector] to search for element to tap. If there are multiple
elements satisfying the selector, the first will be tapped.

```dart
page.tap(String selector) → Future<void>
```

#### page.target
A target this page was created from.

```dart
page.target → Target
```

#### page.title
The page's title.

Shortcut for [Page.mainFrame.title].

```dart
page.title → Future<String>
```

#### page.type(String selector, String text, {Duration delay})
Sends a `keydown`, `keypress`/`input`, and `keyup` event for each character
in the text.

To press a special key, like `Control` or `ArrowDown`, use [`keyboard.press`].

```dart
// Types instantly
await page.type('#mytextarea', 'Hello');

// Types slower, like a user
await page.type('#mytextarea', 'World', delay: Duration(milliseconds: 100));
```

Shortcut for [page.mainFrame.type].

```dart
page.type(String selector, String text, {Duration delay}) → Future<void>
```

#### page.url
This is a shortcut for [page.mainFrame.url]

```dart
page.url → String
```

#### page.waitForFunction(@Language('js') String pageFunction, {List args, Duration timeout, Polling polling})
Parameters:
- [pageFunction]: Function to be evaluated in browser context
- [polling]: An interval at which the `pageFunction` is executed, defaults
  to `everyFrame`.
  - [Polling.everyFrame]: to constantly execute `pageFunction` in
    `requestAnimationFrame` callback. This is the tightest polling mode
    which is suitable to observe styling changes.
  - [Polling.mutation]: to execute `pageFunction` on every DOM mutation.
  - [Polling.interval]: An interval at which the function would be executed
- [args]: Arguments to pass to  `pageFunction`

Returns a [Future] which resolves when the `pageFunction` returns a truthy
value. It resolves to a JSHandle of the truthy value.

The `waitForFunction` can be used to observe viewport size change:
```dart
import 'package:puppeteer/puppeteer.dart';

main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  var watchDog = page.waitForFunction('window.innerWidth < 100');
  await page.setViewport(DeviceViewport(width: 50, height: 50));
  await watchDog;
  await browser.close();
}
```

To pass arguments from node.js to the predicate of `page.waitForFunction` function:

```dart
var selector = '.foo';
await page.waitForFunction('selector => !!document.querySelector(selector)',
    args: [selector]);
```

Shortcut for [page.mainFrame().waitForFunction(pageFunction[, options[, ...args]])](#framewaitforfunctionpagefunction-options-args).

```dart
page.waitForFunction(@Language('js') String pageFunction, {List args, Duration timeout, Polling polling}) → Future<JsHandle>
```

#### page.waitForNavigation({Duration timeout, Until wait})
This resolves when the page navigates to a new URL or reloads. It is useful
for when you run code which will indirectly cause the page to navigate.
Consider this example:

```dart
await Future.wait([
  // The future completes after navigation has finished
  page.waitForNavigation(),
  // Clicking the link will indirectly cause a navigation
  page.click('a.my-link'),
]);
```

**NOTE** Usage of the [History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API)
to change the URL is considered a navigation.

Shortcut for [page.mainFrame.waitForNavigation].

Parameters:
- [timeout] Maximum navigation time in milliseconds, defaults
    to 30 seconds, pass [Duration.zero] to disable timeout. The default value
    can be changed by using the [Page.defaultNavigationTimeout] or
    [Page.defaultTimeout] properties.
- [wait] When to consider navigation succeeded, defaults to [Until.load].
    Given an array of event strings, navigation is considered to be
    successful after all events have been fired. Events can be either:
  - [Until.load] - consider navigation to be finished when the `load`
    event is fired.
  - [Until.domContentLoaded] - consider navigation to be finished when the
    `DOMContentLoaded` event is fired.
  - [Until.networkIdle] - consider navigation to be finished when there
    are no more than 0 network connections for at least `500` ms.
  - [Until.networkAlmostIdle] - consider navigation to be finished when
    there are no more than 2 network connections for at least `500` ms.

Returns: [Future] which resolves to the main resource response. In case
of multiple redirects, the navigation will resolve with the response of
the last redirect.
In case of navigation to a different anchor or navigation due to History
API usage, the navigation will resolve with `null`.

```dart
page.waitForNavigation({Duration timeout, Until wait}) → Future<Response>
```

#### page.waitForRequest(String url, {Duration timeout})
Example:
```dart
var firstRequest = page.waitForRequest('https://example.com');

// You can achieve the same effect (and more powerful) with the `onRequest`
// stream.
var finalRequest = page.onRequest
    .where((request) =>
        request.url.startsWith('https://example.com') &&
        request.method == 'GET')
    .first
    .timeout(Duration(seconds: 30));

await page.goto('https://example.com');
await Future.wait([firstRequest, finalRequest]);
```

```dart
page.waitForRequest(String url, {Duration timeout}) → Future<Request>
```

#### page.waitForSelector(String selector, {bool visible, bool hidden, Duration timeout})
Wait for the `selector` to appear in page. If at the moment of calling
the method the `selector` already exists, the method will return
immediately. If the selector doesn't appear after the `timeout` of waiting,
the function will throw.

This method works across navigations:
```dart
import 'package:puppeteer/puppeteer.dart';

main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  var watchImg = page.waitForSelector('img');
  await page.goto('https://example.com');
  var image = await watchImg;
  print(await image.propertyValue('src'));
  await browser.close();
}
```
Shortcut for [page.mainFrame.waitForSelector].

Parameters:
- A [selector] of an element to wait for
- [visible]: wait for element to be present in DOM and to be visible,
  i.e. to not have `display: none` or `visibility: hidden` CSS properties.
  Defaults to `false`.
- [hidden]: wait for element to not be found in the DOM or to be hidden,
  i.e. have `display: none` or `visibility: hidden` CSS properties.
  Defaults to `false`.
- [timeout]:  maximum time to wait for. Pass [Duration.zero]
  to disable timeout. The default value can be changed by using the
  [page.defaultTimeout] property.

Returns a [Future] which resolves when element specified by selector string
is added to DOM. Resolves to `null` if waiting for `hidden: true` and selector
is not found in DOM.

```dart
page.waitForSelector(String selector, {bool visible, bool hidden, Duration timeout}) → Future<ElementHandle>
```

#### page.waitForXPath(String xpath, {bool visible, bool hidden, Duration timeout})
Wait for the `xpath` to appear in page. If at the moment of calling
the method the `xpath` already exists, the method will return
immediately. If the xpath doesn't appear after the `timeout` of waiting,
the function will throw.

This method works across navigations:
```dart
import 'package:puppeteer/puppeteer.dart';

main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  var watchImg = page.waitForXPath('//img');
  await page.goto('https://example.com');
  var image = await watchImg;
  print(await image.propertyValue('src'));
  await browser.close();
}
```
Shortcut for [page.mainFrame.waitForXPath].

Parameters:
- A [xpath] of an element to wait for
- [visible]: wait for element to be present in DOM and to be visible,
  i.e. to not have `display: none` or `visibility: hidden` CSS properties.
  Defaults to `false`.
- [hidden]: wait for element to not be found in the DOM or to be hidden,
  i.e. have `display: none` or `visibility: hidden` CSS properties.
  Defaults to `false`.
- [timeout]:  maximum time to wait for. Pass [Duration.zero]
  to disable timeout. The default value can be changed by using the
  [page.defaultTimeout] property.

Returns a [Future] which resolves when element specified by xpath string
is added to DOM. Resolves to `null` if waiting for `hidden: true` and selector
is not found in DOM.

```dart
page.waitForXPath(String xpath, {bool visible, bool hidden, Duration timeout}) → Future<ElementHandle>
```

### class: Keyboard
Keyboard provides an api for managing a virtual keyboard. The high level api
is [Keyboard.type], which takes raw characters and generates proper keydown,
keypress/input, and keyup events on your page.

For finer control, you can use [Keyboard.down], [keyboard.up], and
[keyboard.sendCharacter] to manually fire events as if they were generated
from a real keyboard.

An example of holding down `Shift` in order to select and delete some text:
```dart
await page.keyboard.type('Hello World!');
await page.keyboard.press(Key.arrowLeft);
await page.keyboard.down(Key.shift);
for (var i = 0; i < ' World'.length; i++) {
  await page.keyboard.press(Key.arrowLeft);
}
await page.keyboard.up(Key.shift);
await page.keyboard.press(Key.backspace);
// Result text will end up saying 'Hello!'
```

An example of pressing `A`
```dart
await page.keyboard.down(Key.shift);
await page.keyboard.press(Key.keyA, text: 'A');
await page.keyboard.up(Key.shift);
```

> **NOTE** On MacOS, keyboard shortcuts like `⌘ A` -> Select All do not work. See [#1313](https://github.com/GoogleChrome/puppeteer/issues/1313)

#### keyboard.down(Key key, {String text})
Dispatches a `keydown` event.

If `key` is a modifier key, `Shift`, `Meta`, `Control`, or `Alt`,
subsequent key presses will be sent with that modifier active. To release
the modifier key, use [keyboard.up].

After the key is pressed once, subsequent calls to [keyboard.down] will
have [repeat](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/repeat)
set to true. To release the key, use [keyboard.up].

> **NOTE** Modifier keys DO influence `keyboard.down`. Holding down `Shift`
will type the text in upper case.

Parameters:
[text]: If specified, generates an input event with this text.

```dart
keyboard.down(Key key, {String text}) → Future<void>
```

#### keyboard.press(Key key, {Duration delay, String text})
Shortcut for [Keyboard.down] and [Keyboard.up].

> **NOTE** Modifier keys DO effect `keyboard.press`. Holding down `Shift`
will type the text in upper case.

[text]: If specified, generates an input event with this text.
[delay]: Time to wait between `keydown` and `keyup`. Defaults to 0.

```dart
keyboard.press(Key key, {Duration delay, String text}) → Future<void>
```

#### keyboard.sendCharacter(String text)
Dispatches a keypress and input event. This does not send a keydown or
keyup event.

NOTE Modifier keys DO NOT effect keyboard.sendCharacter. Holding down
Shift will not type the text in upper case.

```dart
await page.keyboard.sendCharacter('嗨');
```

```dart
keyboard.sendCharacter(String text) → Future<void>
```

#### keyboard.type(String text, {Duration delay})
Sends a keydown, keypress/input, and keyup event for each character in the
text.

[text]: A text to type into a focused element.
[delay]: Time to wait between key presses. Defaults to 0.

```dart
// Types instantly
await page.keyboard.type('Hello');

// Types slower, like a user
await page.keyboard.type('World', delay: Duration(milliseconds: 10));
```

```dart
keyboard.type(String text, {Duration delay}) → Future<void>
```

#### keyboard.up(Key key)
Dispatches a `keyup` event.

```dart
keyboard.up(Key key) → Future<void>
```

### class: Mouse
The Mouse class operates in main-frame CSS pixels relative to the top-left
corner of the viewport.

Every `page` object has its own Mouse, accessible with [page.mouse].

```dart
// Using ‘page.mouse’ to trace a 100x100 square.
await page.mouse.move(Point(0, 0));
await page.mouse.down();
await page.mouse.move(Point(0, 100));
await page.mouse.move(Point(100, 100));
await page.mouse.move(Point(100, 0));
await page.mouse.move(Point(0, 0));
await page.mouse.up();
```

#### mouse.click(Point position, {Duration delay, MouseButton button, int clickCount})
Shortcut for [mouse.move], [mouse.down] and [mouse.up].

[delay]: Time to wait between `mousedown` and `mouseup`. Defaults to 0.

```dart
mouse.click(Point position, {Duration delay, MouseButton button, int clickCount}) → Future<void>
```

#### mouse.down({MouseButton button, int clickCount})
Dispatches a `mousedown` event.

```dart
mouse.down({MouseButton button, int clickCount}) → Future<void>
```

#### mouse.move(Point position, {int steps})
Dispatches a `mousemove` event.

```dart
mouse.move(Point position, {int steps}) → Future<void>
```

#### mouse.up({MouseButton button, int clickCount})
Dispatches a `mouseup` event.

```dart
mouse.up({MouseButton button, int clickCount}) → Future<void>
```

### class: Touchscreen
[Touchscreen] provides an api for dispatching touch events.

#### touchscreen.tap(Point position)
Dispatches a `touchstart` and `touchend` event.

```dart
touchscreen.tap(Point position) → Future<void>
```

### class: Dialog
Dialog objects are dispatched by page via the 'onDialog' event.

An example of using Dialog class:

```dart
var browser = await puppeteer.launch();
var page = await browser.newPage();
page.onDialog.listen((dialog) async {
  print(dialog.message);
  await dialog.dismiss();
});
await page.evaluate("() => alert('1')");
await browser.close();
```

#### dialog.accept({String promptText})
[promptText]: A text to enter in prompt. Does not cause any effects if
the dialog's `type` is not prompt.

Returns [Future] which resolves when the dialog has been accepted.

```dart
dialog.accept({String promptText}) → Future<void>
```

#### dialog.defaultValue
If dialog is prompt, returns default prompt value. Otherwise, returns
empty string.

```dart
dialog.defaultValue → String
```

#### dialog.dismiss()
Returns [Future] which resolves when the dialog has been dismissed.

```dart
dialog.dismiss() → Future<void>
```

#### dialog.message
A message displayed in the dialog.

```dart
dialog.message → String
```

#### dialog.type
Dialog's type, can be one of `alert`, `beforeunload`, `confirm` or `prompt`.

```dart
dialog.type → DialogType
```

### class: ConsoleMessage
[ConsoleMessage] objects are dispatched by page via the [console] event.

### class: Frame
At every point of time, page exposes its current frame tree via the
[page.mainFrame] and [frame.childFrames] methods.

[Frame] object's lifecycle is controlled by three events, dispatched on the
page object:
- [Page.onFrameAttached] - fired when the frame gets attached to the page.
  A Frame can be attached to the page only once.
- [Page.onFrameNavigated] - fired when the frame commits navigation to a
  different URL.
- [Page.onFrameDetached] - fired when the frame gets detached from the page.
  A Frame can be detached from the page only once.

An example of dumping frame tree:

```dart
dumpFrameTree(Frame frame, String indent) {
  print(indent + frame.url);
  for (var child in frame.childFrames) {
    dumpFrameTree(child, indent + '  ');
  }
}

var browser = await puppeteer.launch();
var page = await browser.newPage();
await page.goto('https://example.com');
dumpFrameTree(page.mainFrame, '');
await browser.close();
```

An example of getting text from an iframe element:

```dart
var frame = page.frames.firstWhere((frame) => frame.name == 'myframe');
var text = await frame.$eval('.selector', 'el => el.textContent');
print(text);
```

#### pageFrame.$(String selector)
The method queries frame for the selector. If there's no such element
within the frame, the method will resolve to null.

[selector]: A selector to query frame for
Returns a Future which resolves to ElementHandle pointing to the frame
element.

```dart
pageFrame.$(String selector) → Future<ElementHandle>
```

#### pageFrame.$$(String selector)
The method runs `document.querySelectorAll` within the frame. If no
elements match the selector, the return value resolves to `[]`.

Parameters:
A [selector] to query frame for

Returns a [Future] which resolves to ElementHandles pointing to the frame
elements.

```dart
pageFrame.$$(String selector) → Future<List<ElementHandle>>
```

#### pageFrame.$$eval(String selector, @Language('js') String pageFunction, {List args})
This method runs `Array.from(document.querySelectorAll(selector))` within
the frame and passes it as the first argument to `pageFunction`.

If `pageFunction` returns a [Promise], then `frame.$$eval` would wait for
the promise to resolve and return its value.

Examples:
```dart
var divsCounts = await frame.$$eval('div', 'divs => divs.length');
```

```dart
pageFrame.$$eval(String selector, @Language('js') String pageFunction, {List args}) → Future<T>
```

#### pageFrame.$eval(String selector, @Language('js') String pageFunction, {List args})
This method runs document.querySelector within the frame and passes it as
the first argument to pageFunction. If there's no element matching
selector, the method throws an error.

 If pageFunction returns a Promise, then frame.$eval would wait for the
 promise to resolve and return its value.

Examples:

```dart
var searchValue =
    await frame.$eval('#search', 'function (el) { return el.value; }');
var preloadHref = await frame.$eval(
    'link[rel=preload]', 'function (el) { return el.href; }');
var html = await frame.$eval(
    '.main-container', 'function (e) { return e.outerHTML; }');
```

[selector]: A selector to query frame for
[pageFunction]: Function to be evaluated in browser context
[args]: Arguments to pass to pageFunction
Returns a Future which resolves to the return value of pageFunction

```dart
pageFrame.$eval(String selector, @Language('js') String pageFunction, {List args}) → Future<T>
```

#### pageFrame.$x(String expression)
Evaluates the XPath expression.

```dart
pageFrame.$x(String expression) → Future<List<ElementHandle>>
```

#### pageFrame.name
Returns frame's name attribute as specified in the tag.

If the name is empty, returns the id attribute instead.

> **NOTE** This value is calculated once when the frame is created, and
will not update if the attribute is changed later.

```dart
pageFrame.name → String
```

### class: ExecutionContext
The class represents a context for JavaScript execution. A [Page] might have
many execution contexts:
- each [frame](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe)
  has "default" execution context that is always created after frame is attached
  to DOM. This context is returned by the [frame.executionContext] method.
- [Extensions](https://developer.chrome.com/extensions)'s content scripts
  create additional execution contexts.

Besides pages, execution contexts can be found in [workers](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API).

#### executionContext.evaluate(@Language('js') String pageFunction, {List args})
If the function passed to the `executionContext.evaluate` returns a [Promise],
then `executionContext.evaluate` would wait for the promise to resolve and
return its value.

If the function passed to the `executionContext.evaluate` returns a
non-[Serializable] value, then `executionContext.evaluate` resolves to `null`.
DevTools Protocol also supports transferring some additional values that
are not serializable by `JSON`: `-0`, `NaN`, `Infinity`, `-Infinity`, and
bigint literals.

```dart
var executionContext = await page.mainFrame.executionContext;
var result = await executionContext.evaluate('() => Promise.resolve(8 * 7)');
print(result); // prints "56"
```

An expression can also be passed in instead of a function.

```dart
print(await executionContext.evaluate('1 + 2')); // prints "3"
```

Parameters:
- `pageFunction`:  Function to be evaluated in `executionContext`
- [args]:  Arguments to pass to `pageFunction`

Returns [Future] which resolves to the return value of `pageFunction`

```dart
executionContext.evaluate(@Language('js') String pageFunction, {List args}) → Future<T>
```

#### executionContext.evaluateHandle(@Language('js') String pageFunction, {List args})
The only difference between `executionContext.evaluate` and
`executionContext.evaluateHandle` is that `executionContext.evaluateHandle`
returns in-page object (JSHandle).

If the function passed to the `executionContext.evaluateHandle` returns a
[Promise], then `executionContext.evaluateHandle` would wait for the promise
to resolve and return its value.

```dart
var context = await page.mainFrame.executionContext;
var aHandle = await context.evaluateHandle('() => Promise.resolve(self)');
aHandle; // Handle for the global object.
```

A string can also be passed in instead of a function.

```dart
var aHandle =
    await context.evaluateHandle('1 + 2'); // Handle for the '3' object.
```

[JSHandle] instances can be passed as arguments to the `executionContext.evaluateHandle`:
```dart
var aHandle = await context.evaluateHandle('() => document.body');
var resultHandle =
    await context.evaluateHandle('body => body.innerHTML', args: [aHandle]);
print(await resultHandle.jsonValue); // prints body's innerHTML
await aHandle.dispose();
await resultHandle.dispose();
```

```dart
executionContext.evaluateHandle(@Language('js') String pageFunction, {List args}) → Future<JsHandle>
```

#### executionContext.frame
Frame associated with this execution context.

> **NOTE** Not every execution context is associated with a frame. For
example, workers and extensions have execution contexts that are not
associated with frames.

```dart
executionContext.frame → Frame
```

#### executionContext.queryObjects(JsHandle prototypeHandle)
The method iterates the JavaScript heap and finds all the objects with the
given prototype.

```dart
executionContext.queryObjects(JsHandle prototypeHandle) → Future<JsHandle>
```

### class: JsHandle
JSHandle represents an in-page JavaScript object. JSHandles can be created
with the [page.evaluateHandle] method.

```dart
var windowHandle = await page.evaluateHandle('() => window');
```

JSHandle prevents the referenced JavaScript object being garbage collected
unless the handle is [disposed]. JSHandles are auto-disposed when their
origin frame gets navigated or the parent context gets destroyed.

JSHandle instances can be used as arguments in [page.$eval], [page.evaluate]
and [page.evaluateHandle] methods.

#### jsHandle.asElement
Returns either `null` or the object handle itself, if the object handle is
an instance of [ElementHandle].

```dart
jsHandle.asElement → ElementHandle
```

#### jsHandle.dispose()
Stops referencing the element handle.

Returns a Future which completes when the object handle is successfully
disposed.

```dart
jsHandle.dispose() → Future<void>
```

#### jsHandle.executionContext
Returns execution context the handle belongs to.

```dart
jsHandle.executionContext → ExecutionContext
```

#### jsHandle.jsonValue
Returns a JSON representation of the object. If the object has a
[`toJSON`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify#toJSON()_behavior)
function, it **will not be called**.

> **NOTE** The method will return an empty JSON object if the referenced
object is not stringifiable.
It will throw an error if the object has circular references.

```dart
jsHandle.jsonValue → Future<dynamic>
```

#### jsHandle.properties
The method returns a map with property names as keys and JSHandle instances
for the property values.

```dart
var handle = await page.evaluateHandle('() => ({window, document})');
var properties = await handle.properties;
JsHandle windowHandle = properties['window'];
ElementHandle documentHandle = properties['document'];
await handle.dispose();
```

```dart
jsHandle.properties → Future<Map<String, JsHandle>>
```

#### jsHandle.property(String propertyName)
Fetches a single property from the referenced object.

```dart
jsHandle.property(String propertyName) → Future<JsHandle>
```

#### jsHandle.propertyValue(String propertyName)
Fetches the jsonValue of a single property from the referenced object.

```dart
jsHandle.propertyValue(String propertyName) → Future<T>
```

### class: ElementHandle
ElementHandle represents an in-page DOM element. ElementHandles can be
created with the [page.$] method.

```dart
import 'package:puppeteer/puppeteer.dart';

main() async {
  var browser = await puppeteer.launch();

  var page = await browser.newPage();
  await page.goto('https://example.com');
  var hrefElement = await page.$('a');
  await hrefElement.click();

  await browser.close();
}
```

ElementHandle prevents DOM element from garbage collection unless the handle
 is [disposed]. ElementHandles are auto-disposed when their origin frame gets
 navigated.

ElementHandle instances can be used as arguments in [page.$eval] and
[page.evaluate] methods.

#### elementHandle.$(String selector)
The method runs `element.querySelector` within the page. If no element
matches the selector, the return value resolves to `null`.

```dart
elementHandle.$(String selector) → Future<ElementHandle>
```

#### elementHandle.$$(String selector)
The method runs `element.querySelectorAll` within the page. If no elements
match the selector, the return value resolves to `[]`.

```dart
elementHandle.$$(String selector) → Future<List<ElementHandle>>
```

#### elementHandle.$$eval(String selector, @Language('js') String pageFunction, {List args})
This method runs `document.querySelectorAll` within the element and passes
it as the first argument to `pageFunction`. If there's no element matching
`selector`, the method throws an error.

If `pageFunction` returns a [Promise], then `frame.$$eval` would wait for
the promise to resolve and return its value.

Examples:
```html
<div class="feed">
  <div class="tweet">Hello!</div>
  <div class="tweet">Hi!</div>
</div>
```
```dart
var feedHandle = await page.$('.feed');
expect(
    await feedHandle.$$eval('.tweet', 'nodes => nodes.map(n => n.innerText)'),
    equals(['Hello!', 'Hi!']));
```

Parameters:
- A [selector] to query page for
- [pageFunction]: Function to be evaluated in browser context
- [args]: Arguments to pass to `pageFunction`

Returns: [Future] which resolves to the return value of `pageFunction`

```dart
elementHandle.$$eval(String selector, @Language('js') String pageFunction, {List args}) → Future<T>
```

#### elementHandle.$eval(String selector, @Language('js') String pageFunction, {List args})
This method runs `document.querySelector` within the element and passes it
as the first argument to `pageFunction`. If there's no element matching
`selector`, the method throws an error.

If `pageFunction` returns a [Promise], then `frame.$eval` would wait for
the promise to resolve and return its value.

Examples:
```dart
var tweetHandle = await page.$('.tweet');
expect(await tweetHandle.$eval('.like', 'node => node.innerText'),
    equals('100'));
expect(await tweetHandle.$eval('.retweets', 'node => node.innerText'),
    equals('10'));
```

Parameters:
- A [selector] to query page for
- [pageFunction]: Function to be evaluated in browser context
- [args]: Arguments to pass to `pageFunction`

Returns [Future] which resolves to the return value of `pageFunction`.

```dart
elementHandle.$eval(String selector, @Language('js') String pageFunction, {List args}) → Future<T>
```

#### elementHandle.$x(String expression)
The method evaluates the XPath expression relative to the elementHandle.
If there are no such elements, the method will resolve to an empty array.

```dart
elementHandle.$x(String expression) → Future<List<ElementHandle>>
```

#### elementHandle.boundingBox
This method returns the bounding box of the element (relative to the main
frame), or `null` if the element is not visible.

```dart
elementHandle.boundingBox → Future<Rectangle>
```

#### elementHandle.boxModel
This method returns boxes of the element, or `null` if the element is not
visible.
Boxes are represented as an array of points;
Box points are sorted clock-wise.

```dart
elementHandle.boxModel → Future<BoxModel>
```

#### elementHandle.click({Duration delay, MouseButton button, int clickCount})
This method scrolls element into view if needed, and then uses [page.mouse]
to click in the center of the element.
If the element is detached from DOM, the method throws an error.

Parameters:
- [button]: Defaults to [MouseButton.left]
- [clickCount]: Defaults to 1
- [delay]: Time to wait between `mousedown` and `mouseup`. Defaults to 0.

Returns [Future] which resolves when the element is successfully clicked.
[Future] gets rejected if the element is detached from DOM.

```dart
elementHandle.click({Duration delay, MouseButton button, int clickCount}) → Future<void>
```

#### elementHandle.contentFrame
Resolves to the content frame for element handles referencing iframe nodes,
or null otherwise

```dart
elementHandle.contentFrame → Future<Frame>
```

#### elementHandle.focus()
Calls [focus](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/focus)
on the element.

```dart
elementHandle.focus() → Future<void>
```

#### elementHandle.isIntersectingViewport
Resolves to true if the element is visible in the current viewport.

```dart
elementHandle.isIntersectingViewport → Future<bool>
```

#### elementHandle.press(Key key, {Duration delay, String text})
Focuses the element, and then uses [`keyboard.down`] and [`keyboard.up`].

If `key` is a single character and no modifier keys besides `Shift` are
being held down, a `keypress`/`input` event will also be generated. The
`text` option can be specified to force an input event to be generated.

> **NOTE** Modifier keys DO effect `elementHandle.press`. Holding down
`Shift` will type the text in upper case.

Parameters:
- [text]: If specified, generates an input event with this text.
- [delay]: Time to wait between `keydown` and `keyup`. Defaults to 0.

```dart
elementHandle.press(Key key, {Duration delay, String text}) → Future<void>
```

#### elementHandle.screenshot({ScreenshotFormat format, num quality, bool omitBackground})
This method scrolls element into view if needed, and then uses [page.screenshot]
to take a screenshot of the element.
If the element is detached from DOM, the method throws an error.

See [Page.screenshot] for more info.

```dart
elementHandle.screenshot({ScreenshotFormat format, num quality, bool omitBackground}) → Future<List<int>>
```

#### elementHandle.tap()
This method scrolls element into view if needed, and then uses [touchscreen.tap]
to tap in the center of the element.
If the element is detached from DOM, the method throws an error.

```dart
elementHandle.tap() → Future<void>
```

#### elementHandle.type(String text, {Duration delay})
Focuses the element, and then sends a `keydown`, `keypress`/`input`, and
`keyup` event for each character in the text.

To press a special key, like `Control` or `ArrowDown`, use [`elementHandle.press`].

```dart
await elementHandle.type('Hello'); // Types instantly

// Types slower, like a user
await elementHandle.type('World', delay: Duration(milliseconds: 100));

///---
```

An example of typing into a text field and then submitting the form:
```dart
var elementHandle = await page.$('input');
await elementHandle.type('some text');
await elementHandle.press(Key.enter);
```

```dart
elementHandle.type(String text, {Duration delay}) → Future<void>
```

#### elementHandle.uploadFile(List\<File> files)
This method expects `elementHandle` to point to an [input element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input).

Sets the value of the file input these paths.

```dart
elementHandle.uploadFile(List<File> files) → Future<void>
```

### class: Request
Whenever the page sends a request, such as for a network resource, the
following events are emitted by puppeteer's page:
- [onRequest] emitted when the request is issued by the page.
- [onResponse] emitted when/if the response is received for the request.
- [onRequestFinished] emitted when the response body is downloaded and the
   request is complete.

If request fails at some point, then instead of 'onRequestFinished' event
(and possibly instead of 'response' event), the  [onRequestFailed] event is
emitted.

If request gets a 'redirect' response, the request is successfully finished
with the 'onRequestFinished' event, and a new request is  issued to a
redirected url.

#### networkRequest.abort({ErrorReason error})
Aborts request. To use this, request interception should be enabled with
`page.setRequestInterception`.
Exception is immediately thrown if the request interception is not enabled.

Parameters:
[error]: Optional error code. Defaults to `failed`

```dart
networkRequest.abort({ErrorReason error}) → Future<void>
```

#### networkRequest.continueRequest({String url, String method, String postData, Map headers})
Continues request with optional request overrides. To use this, request
interception should be enabled with `page.setRequestInterception`.
Exception is immediately thrown if the request interception is not enabled.

```dart
await page.setRequestInterception(true);
page.onRequest.listen((request) {
  // Override headers
  var headers = Map<String, String>.from(request.headers)..['foo'] = 'bar';
  headers.remove('origin');
  request.continueRequest(headers: headers);
});
```

Parameters:
- [url]: If set, the request url will be changed. This is not a redirect.
  The request will be silently forwarded to the new url. For example, the
  address bar will show the original url.
- [method]: If set changes the request method (e.g. `GET` or `POST`)
- [postData]: If set changes the post data of request
- [headers]: If set changes the request HTTP headers

```dart
networkRequest.continueRequest({String url, String method, String postData, Map headers}) → Future<void>
```

#### networkRequest.failure
The method returns `null` unless this request was failed, as reported by
`onRequestFailed` event.

Example of logging all failed requests:

```dart
page.onRequestFailed.listen((request) {
  print(request.url + ' ' + request.failure);
});
```

```dart
networkRequest.failure → String
```

#### networkRequest.frame
A [Frame] that initiated this request, or `null` if navigating to
error pages.

```dart
networkRequest.frame → Frame
```

#### networkRequest.headers
An object with HTTP headers associated with the request. All header names
are lower-case.

```dart
networkRequest.headers → Map<String, String>
```

#### networkRequest.isNavigationRequest
Whether this request is driving frame's navigation.

```dart
networkRequest.isNavigationRequest → bool
```

#### networkRequest.method
Request's method (GET, POST, etc.)

```dart
networkRequest.method → String
```

#### networkRequest.postData
Request's post body, if any.

```dart
networkRequest.postData → String
```

#### networkRequest.redirectChain
A `redirectChain` is a chain of requests initiated to fetch a resource.
- If there are no redirects and the request was successful, the chain will
  be empty.
- If a server responds with at least a single redirect, then the chain will
  contain all the requests that were redirected.

`redirectChain` is shared between all the requests of the same chain.

For example, if the website `http://example.com` has a single redirect to
`https://example.com`, then the chain will contain one request:

```dart
var response = await page.goto('http://example.com');
var chain = response.request.redirectChain;
expect(chain, hasLength(1));
expect(chain[0].url, equals('http://example.com'));
```

If the website `https://example.com` has no redirects, then the chain will
be empty:
```dart
var response = await page.goto('https://example.com');
var chain = response.request.redirectChain;
expect(chain, isEmpty);
```

```dart
networkRequest.redirectChain → List<Request>
```

#### networkRequest.resourceType
Contains the request's resource type as it was perceived by the rendering
engine.

```dart
networkRequest.resourceType → ResourceType
```

#### networkRequest.respond({int status, Map\<String, String> headers, String contentType, body})
Fulfills request with given response. To use this, request interception should
be enabled with `page.setRequestInterception`. Exception is thrown if
request interception is not enabled.

An example of fulfilling all requests with 404 responses:

```dart
await page.setRequestInterception(true);
page.onRequest.listen((request) {
  request.respond(status: 404, contentType: 'text/plain', body: 'Not Found!');
});
```

> **NOTE** Mocking responses for dataURL requests is not supported.
> Calling `request.respond` for a dataURL request is a noop.

Parameters:
- [status]: Response status code, defaults to `200`.
- [headers]: Optional response headers
- [contentType]: If set, equals to setting `Content-Type` response header
- [body]: Optional response body

```dart
networkRequest.respond({int status, Map<String, String> headers, String contentType, body}) → Future<void>
```

#### networkRequest.response
A matching [Response] object, or `null` if the response has not been
received yet.

```dart
networkRequest.response → Response
```

#### networkRequest.url
URL of the request.

```dart
networkRequest.url → String
```

### class: Response
[Response] class represents responses which are received by page.

#### networkResponse.bytes
Promise which resolves to the bytes with response body.

```dart
networkResponse.bytes → Future<List<int>>
```

#### networkResponse.frame
A [Frame] that initiated this response, or `null` if navigating to error
pages.

```dart
networkResponse.frame → Frame
```

#### networkResponse.fromCache
True if the response was served from either the browser's disk cache or
memory cache.

```dart
networkResponse.fromCache → bool
```

#### networkResponse.fromServiceWorker
True if the response was served by a service worker.

```dart
networkResponse.fromServiceWorker → bool
```

#### networkResponse.headers
An object with HTTP headers associated with the response. All header names are lower-case.

```dart
networkResponse.headers → Map
```

#### networkResponse.json
This method will throw if the response body is not parsable via `jsonDecode`.

```dart
networkResponse.json → Future<dynamic>
```

#### networkResponse.ok
Contains a boolean stating whether the response was successful (status in
the range 200-299) or not.

```dart
networkResponse.ok → bool
```

#### networkResponse.remoteIPAddress
The IP address of the remote server

```dart
networkResponse.remoteIPAddress → String
```

#### networkResponse.remotePort
The port used to connect to the remote server

```dart
networkResponse.remotePort → int
```

#### networkResponse.request
A matching [Request] object.

```dart
networkResponse.request → Request
```

#### networkResponse.securityDetails
Security details if the response was received over the secure connection,
or `null` otherwise.

```dart
networkResponse.securityDetails → SecurityDetails
```

#### networkResponse.status
Contains the status code of the response (e.g., 200 for a success).

```dart
networkResponse.status → int
```

#### networkResponse.statusText
Contains the status text of the response (e.g. usually an "OK" for a success).

```dart
networkResponse.statusText → String
```

#### networkResponse.text
Promise which resolves to a text representation of response body.

```dart
networkResponse.text → Future<String>
```

#### networkResponse.url
Contains the URL of the response.

```dart
networkResponse.url → String
```

