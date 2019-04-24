import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'debugger.dart' as debugger;
import 'dom.dart' as dom;
import 'emulation.dart' as emulation;
import 'network.dart' as network;
import 'runtime.dart' as runtime;

/// Actions and events related to the inspected page belong to the page domain.
class PageApi {
  final Client _client;

  PageApi(this._client);

  Stream<network.MonotonicTime> get onDomContentEventFired => _client.onEvent
      .where((Event event) => event.name == 'Page.domContentEventFired')
      .map((Event event) =>
          network.MonotonicTime.fromJson(event.parameters['timestamp']));

  /// Fired when frame has been attached to its parent.
  Stream<FrameAttachedEvent> get onFrameAttached => _client.onEvent
      .where((Event event) => event.name == 'Page.frameAttached')
      .map((Event event) => FrameAttachedEvent.fromJson(event.parameters));

  /// Fired when frame no longer has a scheduled navigation.
  Stream<FrameId> get onFrameClearedScheduledNavigation => _client.onEvent
      .where(
          (Event event) => event.name == 'Page.frameClearedScheduledNavigation')
      .map((Event event) => FrameId.fromJson(event.parameters['frameId']));

  /// Fired when frame has been detached from its parent.
  Stream<FrameId> get onFrameDetached => _client.onEvent
      .where((Event event) => event.name == 'Page.frameDetached')
      .map((Event event) => FrameId.fromJson(event.parameters['frameId']));

  /// Fired once navigation of the frame has completed. Frame is now associated with the new loader.
  Stream<Frame> get onFrameNavigated => _client.onEvent
      .where((Event event) => event.name == 'Page.frameNavigated')
      .map((Event event) => Frame.fromJson(event.parameters['frame']));

  Stream get onFrameResized =>
      _client.onEvent.where((Event event) => event.name == 'Page.frameResized');

  /// Fired when a renderer-initiated navigation is requested.
  /// Navigation may still be cancelled after the event is issued.
  Stream<FrameRequestedNavigationEvent> get onFrameRequestedNavigation =>
      _client.onEvent
          .where((Event event) => event.name == 'Page.frameRequestedNavigation')
          .map((Event event) =>
              FrameRequestedNavigationEvent.fromJson(event.parameters));

  /// Fired when frame schedules a potential navigation.
  Stream<FrameScheduledNavigationEvent> get onFrameScheduledNavigation =>
      _client.onEvent
          .where((Event event) => event.name == 'Page.frameScheduledNavigation')
          .map((Event event) =>
              FrameScheduledNavigationEvent.fromJson(event.parameters));

  /// Fired when frame has started loading.
  Stream<FrameId> get onFrameStartedLoading => _client.onEvent
      .where((Event event) => event.name == 'Page.frameStartedLoading')
      .map((Event event) => FrameId.fromJson(event.parameters['frameId']));

  /// Fired when frame has stopped loading.
  Stream<FrameId> get onFrameStoppedLoading => _client.onEvent
      .where((Event event) => event.name == 'Page.frameStoppedLoading')
      .map((Event event) => FrameId.fromJson(event.parameters['frameId']));

  /// Fired when interstitial page was hidden
  Stream get onInterstitialHidden => _client.onEvent
      .where((Event event) => event.name == 'Page.interstitialHidden');

  /// Fired when interstitial page was shown
  Stream get onInterstitialShown => _client.onEvent
      .where((Event event) => event.name == 'Page.interstitialShown');

  /// Fired when a JavaScript initiated dialog (alert, confirm, prompt, or onbeforeunload) has been
  /// closed.
  Stream<JavascriptDialogClosedEvent> get onJavascriptDialogClosed =>
      _client.onEvent
          .where((Event event) => event.name == 'Page.javascriptDialogClosed')
          .map((Event event) =>
              JavascriptDialogClosedEvent.fromJson(event.parameters));

  /// Fired when a JavaScript initiated dialog (alert, confirm, prompt, or onbeforeunload) is about to
  /// open.
  Stream<JavascriptDialogOpeningEvent> get onJavascriptDialogOpening =>
      _client.onEvent
          .where((Event event) => event.name == 'Page.javascriptDialogOpening')
          .map((Event event) =>
              JavascriptDialogOpeningEvent.fromJson(event.parameters));

  /// Fired for top level page lifecycle events such as navigation, load, paint, etc.
  Stream<LifecycleEventEvent> get onLifecycleEvent => _client.onEvent
      .where((Event event) => event.name == 'Page.lifecycleEvent')
      .map((Event event) => LifecycleEventEvent.fromJson(event.parameters));

  Stream<network.MonotonicTime> get onLoadEventFired => _client.onEvent
      .where((Event event) => event.name == 'Page.loadEventFired')
      .map((Event event) =>
          network.MonotonicTime.fromJson(event.parameters['timestamp']));

  /// Fired when same-document navigation happens, e.g. due to history API usage or anchor navigation.
  Stream<NavigatedWithinDocumentEvent> get onNavigatedWithinDocument =>
      _client.onEvent
          .where((Event event) => event.name == 'Page.navigatedWithinDocument')
          .map((Event event) =>
              NavigatedWithinDocumentEvent.fromJson(event.parameters));

  /// Compressed image data requested by the `startScreencast`.
  Stream<ScreencastFrameEvent> get onScreencastFrame => _client.onEvent
      .where((Event event) => event.name == 'Page.screencastFrame')
      .map((Event event) => ScreencastFrameEvent.fromJson(event.parameters));

  /// Fired when the page with currently enabled screencast was shown or hidden `.
  Stream<bool> get onScreencastVisibilityChanged => _client.onEvent
      .where((Event event) => event.name == 'Page.screencastVisibilityChanged')
      .map((Event event) => event.parameters['visible'] as bool);

  /// Fired when a new window is going to be opened, via window.open(), link click, form submission,
  /// etc.
  Stream<WindowOpenEvent> get onWindowOpen => _client.onEvent
      .where((Event event) => event.name == 'Page.windowOpen')
      .map((Event event) => WindowOpenEvent.fromJson(event.parameters));

  /// Issued for every compilation cache generated. Is only available
  /// if Page.setGenerateCompilationCache is enabled.
  Stream<CompilationCacheProducedEvent> get onCompilationCacheProduced =>
      _client.onEvent
          .where((Event event) => event.name == 'Page.compilationCacheProduced')
          .map((Event event) =>
              CompilationCacheProducedEvent.fromJson(event.parameters));

  /// Deprecated, please use addScriptToEvaluateOnNewDocument instead.
  /// Returns: Identifier of the added script.
  @deprecated
  Future<ScriptIdentifier> addScriptToEvaluateOnLoad(
      String scriptSource) async {
    var parameters = <String, dynamic>{
      'scriptSource': scriptSource,
    };
    var result =
        await _client.send('Page.addScriptToEvaluateOnLoad', parameters);
    return ScriptIdentifier.fromJson(result['identifier']);
  }

  /// Evaluates given script in every frame upon creation (before loading frame's scripts).
  /// [worldName] If specified, creates an isolated world with the given name and evaluates given script in it.
  /// This world name will be used as the ExecutionContextDescription::name when the corresponding
  /// event is emitted.
  /// Returns: Identifier of the added script.
  Future<ScriptIdentifier> addScriptToEvaluateOnNewDocument(String source,
      {String worldName}) async {
    var parameters = <String, dynamic>{
      'source': source,
    };
    if (worldName != null) {
      parameters['worldName'] = worldName;
    }
    var result =
        await _client.send('Page.addScriptToEvaluateOnNewDocument', parameters);
    return ScriptIdentifier.fromJson(result['identifier']);
  }

  /// Brings page to front (activates tab).
  Future<void> bringToFront() async {
    await _client.send('Page.bringToFront');
  }

  /// Capture page screenshot.
  /// [format] Image compression format (defaults to png).
  /// [quality] Compression quality from range [0..100] (jpeg only).
  /// [clip] Capture the screenshot of a given region only.
  /// [fromSurface] Capture the screenshot from the surface, rather than the view. Defaults to true.
  /// Returns: Base64-encoded image data.
  Future<String> captureScreenshot(
      {@Enum(['jpeg', 'png']) String format,
      int quality,
      Viewport clip,
      bool fromSurface}) async {
    assert(format == null || const ['jpeg', 'png'].contains(format));
    var parameters = <String, dynamic>{};
    if (format != null) {
      parameters['format'] = format;
    }
    if (quality != null) {
      parameters['quality'] = quality;
    }
    if (clip != null) {
      parameters['clip'] = clip.toJson();
    }
    if (fromSurface != null) {
      parameters['fromSurface'] = fromSurface;
    }
    var result = await _client.send('Page.captureScreenshot', parameters);
    return result['data'];
  }

  /// Returns a snapshot of the page as a string. For MHTML format, the serialization includes
  /// iframes, shadow DOM, external resources, and element-inline styles.
  /// [format] Format (defaults to mhtml).
  /// Returns: Serialized page data.
  Future<String> captureSnapshot({@Enum(['mhtml']) String format}) async {
    assert(format == null || const ['mhtml'].contains(format));
    var parameters = <String, dynamic>{};
    if (format != null) {
      parameters['format'] = format;
    }
    var result = await _client.send('Page.captureSnapshot', parameters);
    return result['data'];
  }

  /// Clears the overriden device metrics.
  @deprecated
  Future<void> clearDeviceMetricsOverride() async {
    await _client.send('Page.clearDeviceMetricsOverride');
  }

  /// Clears the overridden Device Orientation.
  @deprecated
  Future<void> clearDeviceOrientationOverride() async {
    await _client.send('Page.clearDeviceOrientationOverride');
  }

  /// Clears the overriden Geolocation Position and Error.
  @deprecated
  Future<void> clearGeolocationOverride() async {
    await _client.send('Page.clearGeolocationOverride');
  }

  /// Creates an isolated world for the given frame.
  /// [frameId] Id of the frame in which the isolated world should be created.
  /// [worldName] An optional name which is reported in the Execution Context.
  /// [grantUniveralAccess] Whether or not universal access should be granted to the isolated world. This is a powerful
  /// option, use with caution.
  /// Returns: Execution context of the isolated world.
  Future<runtime.ExecutionContextId> createIsolatedWorld(FrameId frameId,
      {String worldName, bool grantUniveralAccess}) async {
    var parameters = <String, dynamic>{
      'frameId': frameId.toJson(),
    };
    if (worldName != null) {
      parameters['worldName'] = worldName;
    }
    if (grantUniveralAccess != null) {
      parameters['grantUniveralAccess'] = grantUniveralAccess;
    }
    var result = await _client.send('Page.createIsolatedWorld', parameters);
    return runtime.ExecutionContextId.fromJson(result['executionContextId']);
  }

  /// Deletes browser cookie with given name, domain and path.
  /// [cookieName] Name of the cookie to remove.
  /// [url] URL to match cooke domain and path.
  @deprecated
  Future<void> deleteCookie(String cookieName, String url) async {
    var parameters = <String, dynamic>{
      'cookieName': cookieName,
      'url': url,
    };
    await _client.send('Page.deleteCookie', parameters);
  }

  /// Disables page domain notifications.
  Future<void> disable() async {
    await _client.send('Page.disable');
  }

  /// Enables page domain notifications.
  Future<void> enable() async {
    await _client.send('Page.enable');
  }

  Future<GetAppManifestResult> getAppManifest() async {
    var result = await _client.send('Page.getAppManifest');
    return GetAppManifestResult.fromJson(result);
  }

  Future<List<String>> getInstallabilityErrors() async {
    var result = await _client.send('Page.getInstallabilityErrors');
    return (result['errors'] as List).map((e) => e as String).toList();
  }

  /// Returns all browser cookies. Depending on the backend support, will return detailed cookie
  /// information in the `cookies` field.
  /// Returns: Array of cookie objects.
  @deprecated
  Future<List<network.Cookie>> getCookies() async {
    var result = await _client.send('Page.getCookies');
    return (result['cookies'] as List)
        .map((e) => network.Cookie.fromJson(e))
        .toList();
  }

  /// Returns present frame tree structure.
  /// Returns: Present frame tree structure.
  Future<FrameTree> getFrameTree() async {
    var result = await _client.send('Page.getFrameTree');
    return FrameTree.fromJson(result['frameTree']);
  }

  /// Returns metrics relating to the layouting of the page, such as viewport bounds/scale.
  Future<GetLayoutMetricsResult> getLayoutMetrics() async {
    var result = await _client.send('Page.getLayoutMetrics');
    return GetLayoutMetricsResult.fromJson(result);
  }

  /// Returns navigation history for the current page.
  Future<GetNavigationHistoryResult> getNavigationHistory() async {
    var result = await _client.send('Page.getNavigationHistory');
    return GetNavigationHistoryResult.fromJson(result);
  }

  /// Resets navigation history for the current page.
  Future<void> resetNavigationHistory() async {
    await _client.send('Page.resetNavigationHistory');
  }

  /// Returns content of the given resource.
  /// [frameId] Frame id to get resource for.
  /// [url] URL of the resource to get content for.
  Future<GetResourceContentResult> getResourceContent(
      FrameId frameId, String url) async {
    var parameters = <String, dynamic>{
      'frameId': frameId.toJson(),
      'url': url,
    };
    var result = await _client.send('Page.getResourceContent', parameters);
    return GetResourceContentResult.fromJson(result);
  }

  /// Returns present frame / resource tree structure.
  /// Returns: Present frame / resource tree structure.
  Future<FrameResourceTree> getResourceTree() async {
    var result = await _client.send('Page.getResourceTree');
    return FrameResourceTree.fromJson(result['frameTree']);
  }

  /// Accepts or dismisses a JavaScript initiated dialog (alert, confirm, prompt, or onbeforeunload).
  /// [accept] Whether to accept or dismiss the dialog.
  /// [promptText] The text to enter into the dialog prompt before accepting. Used only if this is a prompt
  /// dialog.
  Future<void> handleJavaScriptDialog(bool accept, {String promptText}) async {
    var parameters = <String, dynamic>{
      'accept': accept,
    };
    if (promptText != null) {
      parameters['promptText'] = promptText;
    }
    await _client.send('Page.handleJavaScriptDialog', parameters);
  }

  /// Navigates current page to the given URL.
  /// [url] URL to navigate the page to.
  /// [referrer] Referrer URL.
  /// [transitionType] Intended transition type.
  /// [frameId] Frame id to navigate, if not specified navigates the top frame.
  Future<NavigateResult> navigate(String url,
      {String referrer, TransitionType transitionType, FrameId frameId}) async {
    var parameters = <String, dynamic>{
      'url': url,
    };
    if (referrer != null) {
      parameters['referrer'] = referrer;
    }
    if (transitionType != null) {
      parameters['transitionType'] = transitionType.toJson();
    }
    if (frameId != null) {
      parameters['frameId'] = frameId.toJson();
    }
    var result = await _client.send('Page.navigate', parameters);
    return NavigateResult.fromJson(result);
  }

  /// Navigates current page to the given history entry.
  /// [entryId] Unique id of the entry to navigate to.
  Future<void> navigateToHistoryEntry(int entryId) async {
    var parameters = <String, dynamic>{
      'entryId': entryId,
    };
    await _client.send('Page.navigateToHistoryEntry', parameters);
  }

  /// Print page as PDF.
  /// [landscape] Paper orientation. Defaults to false.
  /// [displayHeaderFooter] Display header and footer. Defaults to false.
  /// [printBackground] Print background graphics. Defaults to false.
  /// [scale] Scale of the webpage rendering. Defaults to 1.
  /// [paperWidth] Paper width in inches. Defaults to 8.5 inches.
  /// [paperHeight] Paper height in inches. Defaults to 11 inches.
  /// [marginTop] Top margin in inches. Defaults to 1cm (~0.4 inches).
  /// [marginBottom] Bottom margin in inches. Defaults to 1cm (~0.4 inches).
  /// [marginLeft] Left margin in inches. Defaults to 1cm (~0.4 inches).
  /// [marginRight] Right margin in inches. Defaults to 1cm (~0.4 inches).
  /// [pageRanges] Paper ranges to print, e.g., '1-5, 8, 11-13'. Defaults to the empty string, which means
  /// print all pages.
  /// [ignoreInvalidPageRanges] Whether to silently ignore invalid but successfully parsed page ranges, such as '3-2'.
  /// Defaults to false.
  /// [headerTemplate] HTML template for the print header. Should be valid HTML markup with following
  /// classes used to inject printing values into them:
  /// - `date`: formatted print date
  /// - `title`: document title
  /// - `url`: document location
  /// - `pageNumber`: current page number
  /// - `totalPages`: total pages in the document
  ///
  /// For example, `<span class=title></span>` would generate span containing the title.
  /// [footerTemplate] HTML template for the print footer. Should use the same format as the `headerTemplate`.
  /// [preferCSSPageSize] Whether or not to prefer page size as defined by css. Defaults to false,
  /// in which case the content will be scaled to fit the paper size.
  /// Returns: Base64-encoded pdf data.
  Future<String> printToPDF(
      {bool landscape,
      bool displayHeaderFooter,
      bool printBackground,
      num scale,
      num paperWidth,
      num paperHeight,
      num marginTop,
      num marginBottom,
      num marginLeft,
      num marginRight,
      String pageRanges,
      bool ignoreInvalidPageRanges,
      String headerTemplate,
      String footerTemplate,
      bool preferCSSPageSize}) async {
    var parameters = <String, dynamic>{};
    if (landscape != null) {
      parameters['landscape'] = landscape;
    }
    if (displayHeaderFooter != null) {
      parameters['displayHeaderFooter'] = displayHeaderFooter;
    }
    if (printBackground != null) {
      parameters['printBackground'] = printBackground;
    }
    if (scale != null) {
      parameters['scale'] = scale;
    }
    if (paperWidth != null) {
      parameters['paperWidth'] = paperWidth;
    }
    if (paperHeight != null) {
      parameters['paperHeight'] = paperHeight;
    }
    if (marginTop != null) {
      parameters['marginTop'] = marginTop;
    }
    if (marginBottom != null) {
      parameters['marginBottom'] = marginBottom;
    }
    if (marginLeft != null) {
      parameters['marginLeft'] = marginLeft;
    }
    if (marginRight != null) {
      parameters['marginRight'] = marginRight;
    }
    if (pageRanges != null) {
      parameters['pageRanges'] = pageRanges;
    }
    if (ignoreInvalidPageRanges != null) {
      parameters['ignoreInvalidPageRanges'] = ignoreInvalidPageRanges;
    }
    if (headerTemplate != null) {
      parameters['headerTemplate'] = headerTemplate;
    }
    if (footerTemplate != null) {
      parameters['footerTemplate'] = footerTemplate;
    }
    if (preferCSSPageSize != null) {
      parameters['preferCSSPageSize'] = preferCSSPageSize;
    }
    var result = await _client.send('Page.printToPDF', parameters);
    return result['data'];
  }

  /// Reloads given page optionally ignoring the cache.
  /// [ignoreCache] If true, browser cache is ignored (as if the user pressed Shift+refresh).
  /// [scriptToEvaluateOnLoad] If set, the script will be injected into all frames of the inspected page after reload.
  /// Argument will be ignored if reloading dataURL origin.
  Future<void> reload({bool ignoreCache, String scriptToEvaluateOnLoad}) async {
    var parameters = <String, dynamic>{};
    if (ignoreCache != null) {
      parameters['ignoreCache'] = ignoreCache;
    }
    if (scriptToEvaluateOnLoad != null) {
      parameters['scriptToEvaluateOnLoad'] = scriptToEvaluateOnLoad;
    }
    await _client.send('Page.reload', parameters);
  }

  /// Deprecated, please use removeScriptToEvaluateOnNewDocument instead.
  @deprecated
  Future<void> removeScriptToEvaluateOnLoad(ScriptIdentifier identifier) async {
    var parameters = <String, dynamic>{
      'identifier': identifier.toJson(),
    };
    await _client.send('Page.removeScriptToEvaluateOnLoad', parameters);
  }

  /// Removes given script from the list.
  Future<void> removeScriptToEvaluateOnNewDocument(
      ScriptIdentifier identifier) async {
    var parameters = <String, dynamic>{
      'identifier': identifier.toJson(),
    };
    await _client.send('Page.removeScriptToEvaluateOnNewDocument', parameters);
  }

  /// Acknowledges that a screencast frame has been received by the frontend.
  /// [sessionId] Frame number.
  Future<void> screencastFrameAck(int sessionId) async {
    var parameters = <String, dynamic>{
      'sessionId': sessionId,
    };
    await _client.send('Page.screencastFrameAck', parameters);
  }

  /// Searches for given string in resource content.
  /// [frameId] Frame id for resource to search in.
  /// [url] URL of the resource to search in.
  /// [query] String to search for.
  /// [caseSensitive] If true, search is case sensitive.
  /// [isRegex] If true, treats string parameter as regex.
  /// Returns: List of search matches.
  Future<List<debugger.SearchMatch>> searchInResource(
      FrameId frameId, String url, String query,
      {bool caseSensitive, bool isRegex}) async {
    var parameters = <String, dynamic>{
      'frameId': frameId.toJson(),
      'url': url,
      'query': query,
    };
    if (caseSensitive != null) {
      parameters['caseSensitive'] = caseSensitive;
    }
    if (isRegex != null) {
      parameters['isRegex'] = isRegex;
    }
    var result = await _client.send('Page.searchInResource', parameters);
    return (result['result'] as List)
        .map((e) => debugger.SearchMatch.fromJson(e))
        .toList();
  }

  /// Enable Chrome's experimental ad filter on all sites.
  /// [enabled] Whether to block ads.
  Future<void> setAdBlockingEnabled(bool enabled) async {
    var parameters = <String, dynamic>{
      'enabled': enabled,
    };
    await _client.send('Page.setAdBlockingEnabled', parameters);
  }

  /// Enable page Content Security Policy by-passing.
  /// [enabled] Whether to bypass page CSP.
  Future<void> setBypassCSP(bool enabled) async {
    var parameters = <String, dynamic>{
      'enabled': enabled,
    };
    await _client.send('Page.setBypassCSP', parameters);
  }

  /// Overrides the values of device screen dimensions (window.screen.width, window.screen.height,
  /// window.innerWidth, window.innerHeight, and "device-width"/"device-height"-related CSS media
  /// query results).
  /// [width] Overriding width value in pixels (minimum 0, maximum 10000000). 0 disables the override.
  /// [height] Overriding height value in pixels (minimum 0, maximum 10000000). 0 disables the override.
  /// [deviceScaleFactor] Overriding device scale factor value. 0 disables the override.
  /// [mobile] Whether to emulate mobile device. This includes viewport meta tag, overlay scrollbars, text
  /// autosizing and more.
  /// [scale] Scale to apply to resulting view image.
  /// [screenWidth] Overriding screen width value in pixels (minimum 0, maximum 10000000).
  /// [screenHeight] Overriding screen height value in pixels (minimum 0, maximum 10000000).
  /// [positionX] Overriding view X position on screen in pixels (minimum 0, maximum 10000000).
  /// [positionY] Overriding view Y position on screen in pixels (minimum 0, maximum 10000000).
  /// [dontSetVisibleSize] Do not set visible view size, rely upon explicit setVisibleSize call.
  /// [screenOrientation] Screen orientation override.
  /// [viewport] The viewport dimensions and scale. If not set, the override is cleared.
  @deprecated
  Future<void> setDeviceMetricsOverride(
      int width, int height, num deviceScaleFactor, bool mobile,
      {num scale,
      int screenWidth,
      int screenHeight,
      int positionX,
      int positionY,
      bool dontSetVisibleSize,
      emulation.ScreenOrientation screenOrientation,
      Viewport viewport}) async {
    var parameters = <String, dynamic>{
      'width': width,
      'height': height,
      'deviceScaleFactor': deviceScaleFactor,
      'mobile': mobile,
    };
    if (scale != null) {
      parameters['scale'] = scale;
    }
    if (screenWidth != null) {
      parameters['screenWidth'] = screenWidth;
    }
    if (screenHeight != null) {
      parameters['screenHeight'] = screenHeight;
    }
    if (positionX != null) {
      parameters['positionX'] = positionX;
    }
    if (positionY != null) {
      parameters['positionY'] = positionY;
    }
    if (dontSetVisibleSize != null) {
      parameters['dontSetVisibleSize'] = dontSetVisibleSize;
    }
    if (screenOrientation != null) {
      parameters['screenOrientation'] = screenOrientation.toJson();
    }
    if (viewport != null) {
      parameters['viewport'] = viewport.toJson();
    }
    await _client.send('Page.setDeviceMetricsOverride', parameters);
  }

  /// Overrides the Device Orientation.
  /// [alpha] Mock alpha
  /// [beta] Mock beta
  /// [gamma] Mock gamma
  @deprecated
  Future<void> setDeviceOrientationOverride(
      num alpha, num beta, num gamma) async {
    var parameters = <String, dynamic>{
      'alpha': alpha,
      'beta': beta,
      'gamma': gamma,
    };
    await _client.send('Page.setDeviceOrientationOverride', parameters);
  }

  /// Set generic font families.
  /// [fontFamilies] Specifies font families to set. If a font family is not specified, it won't be changed.
  Future<void> setFontFamilies(FontFamilies fontFamilies) async {
    var parameters = <String, dynamic>{
      'fontFamilies': fontFamilies.toJson(),
    };
    await _client.send('Page.setFontFamilies', parameters);
  }

  /// Set default font sizes.
  /// [fontSizes] Specifies font sizes to set. If a font size is not specified, it won't be changed.
  Future<void> setFontSizes(FontSizes fontSizes) async {
    var parameters = <String, dynamic>{
      'fontSizes': fontSizes.toJson(),
    };
    await _client.send('Page.setFontSizes', parameters);
  }

  /// Sets given markup as the document's HTML.
  /// [frameId] Frame id to set HTML for.
  /// [html] HTML content to set.
  Future<void> setDocumentContent(FrameId frameId, String html) async {
    var parameters = <String, dynamic>{
      'frameId': frameId.toJson(),
      'html': html,
    };
    await _client.send('Page.setDocumentContent', parameters);
  }

  /// Set the behavior when downloading a file.
  /// [behavior] Whether to allow all or deny all download requests, or use default Chrome behavior if
  /// available (otherwise deny).
  /// [downloadPath] The default path to save downloaded files to. This is requred if behavior is set to 'allow'
  Future<void> setDownloadBehavior(
      @Enum(['deny', 'allow', 'default']) String behavior,
      {String downloadPath}) async {
    assert(const ['deny', 'allow', 'default'].contains(behavior));
    var parameters = <String, dynamic>{
      'behavior': behavior,
    };
    if (downloadPath != null) {
      parameters['downloadPath'] = downloadPath;
    }
    await _client.send('Page.setDownloadBehavior', parameters);
  }

  /// Overrides the Geolocation Position or Error. Omitting any of the parameters emulates position
  /// unavailable.
  /// [latitude] Mock latitude
  /// [longitude] Mock longitude
  /// [accuracy] Mock accuracy
  @deprecated
  Future<void> setGeolocationOverride(
      {num latitude, num longitude, num accuracy}) async {
    var parameters = <String, dynamic>{};
    if (latitude != null) {
      parameters['latitude'] = latitude;
    }
    if (longitude != null) {
      parameters['longitude'] = longitude;
    }
    if (accuracy != null) {
      parameters['accuracy'] = accuracy;
    }
    await _client.send('Page.setGeolocationOverride', parameters);
  }

  /// Controls whether page will emit lifecycle events.
  /// [enabled] If true, starts emitting lifecycle events.
  Future<void> setLifecycleEventsEnabled(bool enabled) async {
    var parameters = <String, dynamic>{
      'enabled': enabled,
    };
    await _client.send('Page.setLifecycleEventsEnabled', parameters);
  }

  /// Toggles mouse event-based touch event emulation.
  /// [enabled] Whether the touch event emulation should be enabled.
  /// [configuration] Touch/gesture events configuration. Default: current platform.
  @deprecated
  Future<void> setTouchEmulationEnabled(bool enabled,
      {@Enum(['mobile', 'desktop']) String configuration}) async {
    assert(configuration == null ||
        const ['mobile', 'desktop'].contains(configuration));
    var parameters = <String, dynamic>{
      'enabled': enabled,
    };
    if (configuration != null) {
      parameters['configuration'] = configuration;
    }
    await _client.send('Page.setTouchEmulationEnabled', parameters);
  }

  /// Starts sending each frame using the `screencastFrame` event.
  /// [format] Image compression format.
  /// [quality] Compression quality from range [0..100].
  /// [maxWidth] Maximum screenshot width.
  /// [maxHeight] Maximum screenshot height.
  /// [everyNthFrame] Send every n-th frame.
  Future<void> startScreencast(
      {@Enum(['jpeg', 'png']) String format,
      int quality,
      int maxWidth,
      int maxHeight,
      int everyNthFrame}) async {
    assert(format == null || const ['jpeg', 'png'].contains(format));
    var parameters = <String, dynamic>{};
    if (format != null) {
      parameters['format'] = format;
    }
    if (quality != null) {
      parameters['quality'] = quality;
    }
    if (maxWidth != null) {
      parameters['maxWidth'] = maxWidth;
    }
    if (maxHeight != null) {
      parameters['maxHeight'] = maxHeight;
    }
    if (everyNthFrame != null) {
      parameters['everyNthFrame'] = everyNthFrame;
    }
    await _client.send('Page.startScreencast', parameters);
  }

  /// Force the page stop all navigations and pending resource fetches.
  Future<void> stopLoading() async {
    await _client.send('Page.stopLoading');
  }

  /// Crashes renderer on the IO thread, generates minidumps.
  Future<void> crash() async {
    await _client.send('Page.crash');
  }

  /// Tries to close page, running its beforeunload hooks, if any.
  Future<void> close() async {
    await _client.send('Page.close');
  }

  /// Tries to update the web lifecycle state of the page.
  /// It will transition the page to the given state according to:
  /// https://github.com/WICG/web-lifecycle/
  /// [state] Target lifecycle state
  Future<void> setWebLifecycleState(
      @Enum(['frozen', 'active']) String state) async {
    assert(const ['frozen', 'active'].contains(state));
    var parameters = <String, dynamic>{
      'state': state,
    };
    await _client.send('Page.setWebLifecycleState', parameters);
  }

  /// Stops sending each frame in the `screencastFrame`.
  Future<void> stopScreencast() async {
    await _client.send('Page.stopScreencast');
  }

  /// Forces compilation cache to be generated for every subresource script.
  Future<void> setProduceCompilationCache(bool enabled) async {
    var parameters = <String, dynamic>{
      'enabled': enabled,
    };
    await _client.send('Page.setProduceCompilationCache', parameters);
  }

  /// Seeds compilation cache for given url. Compilation cache does not survive
  /// cross-process navigation.
  /// [data] Base64-encoded data
  Future<void> addCompilationCache(String url, String data) async {
    var parameters = <String, dynamic>{
      'url': url,
      'data': data,
    };
    await _client.send('Page.addCompilationCache', parameters);
  }

  /// Clears seeded compilation cache.
  Future<void> clearCompilationCache() async {
    await _client.send('Page.clearCompilationCache');
  }

  /// Generates a report for testing.
  /// [message] Message to be displayed in the report.
  /// [group] Specifies the endpoint group to deliver the report to.
  Future<void> generateTestReport(String message, {String group}) async {
    var parameters = <String, dynamic>{
      'message': message,
    };
    if (group != null) {
      parameters['group'] = group;
    }
    await _client.send('Page.generateTestReport', parameters);
  }

  /// Pauses page execution. Can be resumed using generic Runtime.runIfWaitingForDebugger.
  Future<void> waitForDebugger() async {
    await _client.send('Page.waitForDebugger');
  }
}

class FrameAttachedEvent {
  /// Id of the frame that has been attached.
  final FrameId frameId;

  /// Parent frame identifier.
  final FrameId parentFrameId;

  /// JavaScript stack trace of when frame was attached, only set if frame initiated from script.
  final runtime.StackTrace stack;

  FrameAttachedEvent(
      {@required this.frameId, @required this.parentFrameId, this.stack});

  factory FrameAttachedEvent.fromJson(Map<String, dynamic> json) {
    return FrameAttachedEvent(
      frameId: FrameId.fromJson(json['frameId']),
      parentFrameId: FrameId.fromJson(json['parentFrameId']),
      stack: json.containsKey('stack')
          ? runtime.StackTrace.fromJson(json['stack'])
          : null,
    );
  }
}

class FrameRequestedNavigationEvent {
  /// Id of the frame that has scheduled a navigation.
  final FrameId frameId;

  /// The reason for the navigation.
  final ClientNavigationReason reason;

  /// The destination URL for the requested navigation.
  final String url;

  FrameRequestedNavigationEvent(
      {@required this.frameId, @required this.reason, @required this.url});

  factory FrameRequestedNavigationEvent.fromJson(Map<String, dynamic> json) {
    return FrameRequestedNavigationEvent(
      frameId: FrameId.fromJson(json['frameId']),
      reason: ClientNavigationReason.fromJson(json['reason']),
      url: json['url'],
    );
  }
}

class FrameScheduledNavigationEvent {
  /// Id of the frame that has scheduled a navigation.
  final FrameId frameId;

  /// Delay (in seconds) until the navigation is scheduled to begin. The navigation is not
  /// guaranteed to start.
  final num delay;

  /// The reason for the navigation.
  final FrameScheduledNavigationEventReason reason;

  /// The destination URL for the scheduled navigation.
  final String url;

  FrameScheduledNavigationEvent(
      {@required this.frameId,
      @required this.delay,
      @required this.reason,
      @required this.url});

  factory FrameScheduledNavigationEvent.fromJson(Map<String, dynamic> json) {
    return FrameScheduledNavigationEvent(
      frameId: FrameId.fromJson(json['frameId']),
      delay: json['delay'],
      reason: FrameScheduledNavigationEventReason.fromJson(json['reason']),
      url: json['url'],
    );
  }
}

class JavascriptDialogClosedEvent {
  /// Whether dialog was confirmed.
  final bool result;

  /// User input in case of prompt.
  final String userInput;

  JavascriptDialogClosedEvent(
      {@required this.result, @required this.userInput});

  factory JavascriptDialogClosedEvent.fromJson(Map<String, dynamic> json) {
    return JavascriptDialogClosedEvent(
      result: json['result'],
      userInput: json['userInput'],
    );
  }
}

class JavascriptDialogOpeningEvent {
  /// Frame url.
  final String url;

  /// Message that will be displayed by the dialog.
  final String message;

  /// Dialog type.
  final DialogType type;

  /// True iff browser is capable showing or acting on the given dialog. When browser has no
  /// dialog handler for given target, calling alert while Page domain is engaged will stall
  /// the page execution. Execution can be resumed via calling Page.handleJavaScriptDialog.
  final bool hasBrowserHandler;

  /// Default dialog prompt.
  final String defaultPrompt;

  JavascriptDialogOpeningEvent(
      {@required this.url,
      @required this.message,
      @required this.type,
      @required this.hasBrowserHandler,
      this.defaultPrompt});

  factory JavascriptDialogOpeningEvent.fromJson(Map<String, dynamic> json) {
    return JavascriptDialogOpeningEvent(
      url: json['url'],
      message: json['message'],
      type: DialogType.fromJson(json['type']),
      hasBrowserHandler: json['hasBrowserHandler'],
      defaultPrompt:
          json.containsKey('defaultPrompt') ? json['defaultPrompt'] : null,
    );
  }
}

class LifecycleEventEvent {
  /// Id of the frame.
  final FrameId frameId;

  /// Loader identifier. Empty string if the request is fetched from worker.
  final network.LoaderId loaderId;

  final String name;

  final network.MonotonicTime timestamp;

  LifecycleEventEvent(
      {@required this.frameId,
      @required this.loaderId,
      @required this.name,
      @required this.timestamp});

  factory LifecycleEventEvent.fromJson(Map<String, dynamic> json) {
    return LifecycleEventEvent(
      frameId: FrameId.fromJson(json['frameId']),
      loaderId: network.LoaderId.fromJson(json['loaderId']),
      name: json['name'],
      timestamp: network.MonotonicTime.fromJson(json['timestamp']),
    );
  }
}

class NavigatedWithinDocumentEvent {
  /// Id of the frame.
  final FrameId frameId;

  /// Frame's new url.
  final String url;

  NavigatedWithinDocumentEvent({@required this.frameId, @required this.url});

  factory NavigatedWithinDocumentEvent.fromJson(Map<String, dynamic> json) {
    return NavigatedWithinDocumentEvent(
      frameId: FrameId.fromJson(json['frameId']),
      url: json['url'],
    );
  }
}

class ScreencastFrameEvent {
  /// Base64-encoded compressed image.
  final String data;

  /// Screencast frame metadata.
  final ScreencastFrameMetadata metadata;

  /// Frame number.
  final int sessionId;

  ScreencastFrameEvent(
      {@required this.data, @required this.metadata, @required this.sessionId});

  factory ScreencastFrameEvent.fromJson(Map<String, dynamic> json) {
    return ScreencastFrameEvent(
      data: json['data'],
      metadata: ScreencastFrameMetadata.fromJson(json['metadata']),
      sessionId: json['sessionId'],
    );
  }
}

class WindowOpenEvent {
  /// The URL for the new window.
  final String url;

  /// Window name.
  final String windowName;

  /// An array of enabled window features.
  final List<String> windowFeatures;

  /// Whether or not it was triggered by user gesture.
  final bool userGesture;

  WindowOpenEvent(
      {@required this.url,
      @required this.windowName,
      @required this.windowFeatures,
      @required this.userGesture});

  factory WindowOpenEvent.fromJson(Map<String, dynamic> json) {
    return WindowOpenEvent(
      url: json['url'],
      windowName: json['windowName'],
      windowFeatures:
          (json['windowFeatures'] as List).map((e) => e as String).toList(),
      userGesture: json['userGesture'],
    );
  }
}

class CompilationCacheProducedEvent {
  final String url;

  /// Base64-encoded data
  final String data;

  CompilationCacheProducedEvent({@required this.url, @required this.data});

  factory CompilationCacheProducedEvent.fromJson(Map<String, dynamic> json) {
    return CompilationCacheProducedEvent(
      url: json['url'],
      data: json['data'],
    );
  }
}

class GetAppManifestResult {
  /// Manifest location.
  final String url;

  final List<AppManifestError> errors;

  /// Manifest content.
  final String data;

  GetAppManifestResult({@required this.url, @required this.errors, this.data});

  factory GetAppManifestResult.fromJson(Map<String, dynamic> json) {
    return GetAppManifestResult(
      url: json['url'],
      errors: (json['errors'] as List)
          .map((e) => AppManifestError.fromJson(e))
          .toList(),
      data: json.containsKey('data') ? json['data'] : null,
    );
  }
}

class GetLayoutMetricsResult {
  /// Metrics relating to the layout viewport.
  final LayoutViewport layoutViewport;

  /// Metrics relating to the visual viewport.
  final VisualViewport visualViewport;

  /// Size of scrollable area.
  final dom.Rect contentSize;

  GetLayoutMetricsResult(
      {@required this.layoutViewport,
      @required this.visualViewport,
      @required this.contentSize});

  factory GetLayoutMetricsResult.fromJson(Map<String, dynamic> json) {
    return GetLayoutMetricsResult(
      layoutViewport: LayoutViewport.fromJson(json['layoutViewport']),
      visualViewport: VisualViewport.fromJson(json['visualViewport']),
      contentSize: dom.Rect.fromJson(json['contentSize']),
    );
  }
}

class GetNavigationHistoryResult {
  /// Index of the current navigation history entry.
  final int currentIndex;

  /// Array of navigation history entries.
  final List<NavigationEntry> entries;

  GetNavigationHistoryResult(
      {@required this.currentIndex, @required this.entries});

  factory GetNavigationHistoryResult.fromJson(Map<String, dynamic> json) {
    return GetNavigationHistoryResult(
      currentIndex: json['currentIndex'],
      entries: (json['entries'] as List)
          .map((e) => NavigationEntry.fromJson(e))
          .toList(),
    );
  }
}

class GetResourceContentResult {
  /// Resource content.
  final String content;

  /// True, if content was served as base64.
  final bool base64Encoded;

  GetResourceContentResult(
      {@required this.content, @required this.base64Encoded});

  factory GetResourceContentResult.fromJson(Map<String, dynamic> json) {
    return GetResourceContentResult(
      content: json['content'],
      base64Encoded: json['base64Encoded'],
    );
  }
}

class NavigateResult {
  /// Frame id that has navigated (or failed to navigate)
  final FrameId frameId;

  /// Loader identifier.
  final network.LoaderId loaderId;

  /// User friendly error message, present if and only if navigation has failed.
  final String errorText;

  NavigateResult({@required this.frameId, this.loaderId, this.errorText});

  factory NavigateResult.fromJson(Map<String, dynamic> json) {
    return NavigateResult(
      frameId: FrameId.fromJson(json['frameId']),
      loaderId: json.containsKey('loaderId')
          ? network.LoaderId.fromJson(json['loaderId'])
          : null,
      errorText: json.containsKey('errorText') ? json['errorText'] : null,
    );
  }
}

/// Unique frame identifier.
class FrameId {
  final String value;

  FrameId(this.value);

  factory FrameId.fromJson(String value) => FrameId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is FrameId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Information about the Frame on the page.
class Frame {
  /// Frame unique identifier.
  final String id;

  /// Parent frame identifier.
  final String parentId;

  /// Identifier of the loader associated with this frame.
  final network.LoaderId loaderId;

  /// Frame's name as specified in the tag.
  final String name;

  /// Frame document's URL.
  final String url;

  /// Frame document's security origin.
  final String securityOrigin;

  /// Frame document's mimeType as determined by the browser.
  final String mimeType;

  /// If the frame failed to load, this contains the URL that could not be loaded.
  final String unreachableUrl;

  Frame(
      {@required this.id,
      this.parentId,
      @required this.loaderId,
      this.name,
      @required this.url,
      @required this.securityOrigin,
      @required this.mimeType,
      this.unreachableUrl});

  factory Frame.fromJson(Map<String, dynamic> json) {
    return Frame(
      id: json['id'],
      parentId: json.containsKey('parentId') ? json['parentId'] : null,
      loaderId: network.LoaderId.fromJson(json['loaderId']),
      name: json.containsKey('name') ? json['name'] : null,
      url: json['url'],
      securityOrigin: json['securityOrigin'],
      mimeType: json['mimeType'],
      unreachableUrl:
          json.containsKey('unreachableUrl') ? json['unreachableUrl'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'id': id,
      'loaderId': loaderId.toJson(),
      'url': url,
      'securityOrigin': securityOrigin,
      'mimeType': mimeType,
    };
    if (parentId != null) {
      json['parentId'] = parentId;
    }
    if (name != null) {
      json['name'] = name;
    }
    if (unreachableUrl != null) {
      json['unreachableUrl'] = unreachableUrl;
    }
    return json;
  }
}

/// Information about the Resource on the page.
class FrameResource {
  /// Resource URL.
  final String url;

  /// Type of this resource.
  final network.ResourceType type;

  /// Resource mimeType as determined by the browser.
  final String mimeType;

  /// last-modified timestamp as reported by server.
  final network.TimeSinceEpoch lastModified;

  /// Resource content size.
  final num contentSize;

  /// True if the resource failed to load.
  final bool failed;

  /// True if the resource was canceled during loading.
  final bool canceled;

  FrameResource(
      {@required this.url,
      @required this.type,
      @required this.mimeType,
      this.lastModified,
      this.contentSize,
      this.failed,
      this.canceled});

  factory FrameResource.fromJson(Map<String, dynamic> json) {
    return FrameResource(
      url: json['url'],
      type: network.ResourceType.fromJson(json['type']),
      mimeType: json['mimeType'],
      lastModified: json.containsKey('lastModified')
          ? network.TimeSinceEpoch.fromJson(json['lastModified'])
          : null,
      contentSize: json.containsKey('contentSize') ? json['contentSize'] : null,
      failed: json.containsKey('failed') ? json['failed'] : null,
      canceled: json.containsKey('canceled') ? json['canceled'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'url': url,
      'type': type.toJson(),
      'mimeType': mimeType,
    };
    if (lastModified != null) {
      json['lastModified'] = lastModified.toJson();
    }
    if (contentSize != null) {
      json['contentSize'] = contentSize;
    }
    if (failed != null) {
      json['failed'] = failed;
    }
    if (canceled != null) {
      json['canceled'] = canceled;
    }
    return json;
  }
}

/// Information about the Frame hierarchy along with their cached resources.
class FrameResourceTree {
  /// Frame information for this tree item.
  final Frame frame;

  /// Child frames.
  final List<FrameResourceTree> childFrames;

  /// Information about frame resources.
  final List<FrameResource> resources;

  FrameResourceTree(
      {@required this.frame, this.childFrames, @required this.resources});

  factory FrameResourceTree.fromJson(Map<String, dynamic> json) {
    return FrameResourceTree(
      frame: Frame.fromJson(json['frame']),
      childFrames: json.containsKey('childFrames')
          ? (json['childFrames'] as List)
              .map((e) => FrameResourceTree.fromJson(e))
              .toList()
          : null,
      resources: (json['resources'] as List)
          .map((e) => FrameResource.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'frame': frame.toJson(),
      'resources': resources.map((e) => e.toJson()).toList(),
    };
    if (childFrames != null) {
      json['childFrames'] = childFrames.map((e) => e.toJson()).toList();
    }
    return json;
  }
}

/// Information about the Frame hierarchy.
class FrameTree {
  /// Frame information for this tree item.
  final Frame frame;

  /// Child frames.
  final List<FrameTree> childFrames;

  FrameTree({@required this.frame, this.childFrames});

  factory FrameTree.fromJson(Map<String, dynamic> json) {
    return FrameTree(
      frame: Frame.fromJson(json['frame']),
      childFrames: json.containsKey('childFrames')
          ? (json['childFrames'] as List)
              .map((e) => FrameTree.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'frame': frame.toJson(),
    };
    if (childFrames != null) {
      json['childFrames'] = childFrames.map((e) => e.toJson()).toList();
    }
    return json;
  }
}

/// Unique script identifier.
class ScriptIdentifier {
  final String value;

  ScriptIdentifier(this.value);

  factory ScriptIdentifier.fromJson(String value) => ScriptIdentifier(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ScriptIdentifier && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Transition type.
class TransitionType {
  static const TransitionType link = TransitionType._('link');
  static const TransitionType typed = TransitionType._('typed');
  static const TransitionType addressBar = TransitionType._('address_bar');
  static const TransitionType autoBookmark = TransitionType._('auto_bookmark');
  static const TransitionType autoSubframe = TransitionType._('auto_subframe');
  static const TransitionType manualSubframe =
      TransitionType._('manual_subframe');
  static const TransitionType generated = TransitionType._('generated');
  static const TransitionType autoToplevel = TransitionType._('auto_toplevel');
  static const TransitionType formSubmit = TransitionType._('form_submit');
  static const TransitionType reload = TransitionType._('reload');
  static const TransitionType keyword = TransitionType._('keyword');
  static const TransitionType keywordGenerated =
      TransitionType._('keyword_generated');
  static const TransitionType other = TransitionType._('other');
  static const values = {
    'link': link,
    'typed': typed,
    'address_bar': addressBar,
    'auto_bookmark': autoBookmark,
    'auto_subframe': autoSubframe,
    'manual_subframe': manualSubframe,
    'generated': generated,
    'auto_toplevel': autoToplevel,
    'form_submit': formSubmit,
    'reload': reload,
    'keyword': keyword,
    'keyword_generated': keywordGenerated,
    'other': other,
  };

  final String value;

  const TransitionType._(this.value);

  factory TransitionType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is TransitionType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Navigation history entry.
class NavigationEntry {
  /// Unique id of the navigation history entry.
  final int id;

  /// URL of the navigation history entry.
  final String url;

  /// URL that the user typed in the url bar.
  final String userTypedURL;

  /// Title of the navigation history entry.
  final String title;

  /// Transition type.
  final TransitionType transitionType;

  NavigationEntry(
      {@required this.id,
      @required this.url,
      @required this.userTypedURL,
      @required this.title,
      @required this.transitionType});

  factory NavigationEntry.fromJson(Map<String, dynamic> json) {
    return NavigationEntry(
      id: json['id'],
      url: json['url'],
      userTypedURL: json['userTypedURL'],
      title: json['title'],
      transitionType: TransitionType.fromJson(json['transitionType']),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'id': id,
      'url': url,
      'userTypedURL': userTypedURL,
      'title': title,
      'transitionType': transitionType.toJson(),
    };
    return json;
  }
}

/// Screencast frame metadata.
class ScreencastFrameMetadata {
  /// Top offset in DIP.
  final num offsetTop;

  /// Page scale factor.
  final num pageScaleFactor;

  /// Device screen width in DIP.
  final num deviceWidth;

  /// Device screen height in DIP.
  final num deviceHeight;

  /// Position of horizontal scroll in CSS pixels.
  final num scrollOffsetX;

  /// Position of vertical scroll in CSS pixels.
  final num scrollOffsetY;

  /// Frame swap timestamp.
  final network.TimeSinceEpoch timestamp;

  ScreencastFrameMetadata(
      {@required this.offsetTop,
      @required this.pageScaleFactor,
      @required this.deviceWidth,
      @required this.deviceHeight,
      @required this.scrollOffsetX,
      @required this.scrollOffsetY,
      this.timestamp});

  factory ScreencastFrameMetadata.fromJson(Map<String, dynamic> json) {
    return ScreencastFrameMetadata(
      offsetTop: json['offsetTop'],
      pageScaleFactor: json['pageScaleFactor'],
      deviceWidth: json['deviceWidth'],
      deviceHeight: json['deviceHeight'],
      scrollOffsetX: json['scrollOffsetX'],
      scrollOffsetY: json['scrollOffsetY'],
      timestamp: json.containsKey('timestamp')
          ? network.TimeSinceEpoch.fromJson(json['timestamp'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'offsetTop': offsetTop,
      'pageScaleFactor': pageScaleFactor,
      'deviceWidth': deviceWidth,
      'deviceHeight': deviceHeight,
      'scrollOffsetX': scrollOffsetX,
      'scrollOffsetY': scrollOffsetY,
    };
    if (timestamp != null) {
      json['timestamp'] = timestamp.toJson();
    }
    return json;
  }
}

/// Javascript dialog type.
class DialogType {
  static const DialogType alert = DialogType._('alert');
  static const DialogType confirm = DialogType._('confirm');
  static const DialogType prompt = DialogType._('prompt');
  static const DialogType beforeunload = DialogType._('beforeunload');
  static const values = {
    'alert': alert,
    'confirm': confirm,
    'prompt': prompt,
    'beforeunload': beforeunload,
  };

  final String value;

  const DialogType._(this.value);

  factory DialogType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is DialogType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Error while paring app manifest.
class AppManifestError {
  /// Error message.
  final String message;

  /// If criticial, this is a non-recoverable parse error.
  final int critical;

  /// Error line.
  final int line;

  /// Error column.
  final int column;

  AppManifestError(
      {@required this.message,
      @required this.critical,
      @required this.line,
      @required this.column});

  factory AppManifestError.fromJson(Map<String, dynamic> json) {
    return AppManifestError(
      message: json['message'],
      critical: json['critical'],
      line: json['line'],
      column: json['column'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'message': message,
      'critical': critical,
      'line': line,
      'column': column,
    };
    return json;
  }
}

/// Layout viewport position and dimensions.
class LayoutViewport {
  /// Horizontal offset relative to the document (CSS pixels).
  final int pageX;

  /// Vertical offset relative to the document (CSS pixels).
  final int pageY;

  /// Width (CSS pixels), excludes scrollbar if present.
  final int clientWidth;

  /// Height (CSS pixels), excludes scrollbar if present.
  final int clientHeight;

  LayoutViewport(
      {@required this.pageX,
      @required this.pageY,
      @required this.clientWidth,
      @required this.clientHeight});

  factory LayoutViewport.fromJson(Map<String, dynamic> json) {
    return LayoutViewport(
      pageX: json['pageX'],
      pageY: json['pageY'],
      clientWidth: json['clientWidth'],
      clientHeight: json['clientHeight'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'pageX': pageX,
      'pageY': pageY,
      'clientWidth': clientWidth,
      'clientHeight': clientHeight,
    };
    return json;
  }
}

/// Visual viewport position, dimensions, and scale.
class VisualViewport {
  /// Horizontal offset relative to the layout viewport (CSS pixels).
  final num offsetX;

  /// Vertical offset relative to the layout viewport (CSS pixels).
  final num offsetY;

  /// Horizontal offset relative to the document (CSS pixels).
  final num pageX;

  /// Vertical offset relative to the document (CSS pixels).
  final num pageY;

  /// Width (CSS pixels), excludes scrollbar if present.
  final num clientWidth;

  /// Height (CSS pixels), excludes scrollbar if present.
  final num clientHeight;

  /// Scale relative to the ideal viewport (size at width=device-width).
  final num scale;

  /// Page zoom factor (CSS to device independent pixels ratio).
  final num zoom;

  VisualViewport(
      {@required this.offsetX,
      @required this.offsetY,
      @required this.pageX,
      @required this.pageY,
      @required this.clientWidth,
      @required this.clientHeight,
      @required this.scale,
      this.zoom});

  factory VisualViewport.fromJson(Map<String, dynamic> json) {
    return VisualViewport(
      offsetX: json['offsetX'],
      offsetY: json['offsetY'],
      pageX: json['pageX'],
      pageY: json['pageY'],
      clientWidth: json['clientWidth'],
      clientHeight: json['clientHeight'],
      scale: json['scale'],
      zoom: json.containsKey('zoom') ? json['zoom'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'offsetX': offsetX,
      'offsetY': offsetY,
      'pageX': pageX,
      'pageY': pageY,
      'clientWidth': clientWidth,
      'clientHeight': clientHeight,
      'scale': scale,
    };
    if (zoom != null) {
      json['zoom'] = zoom;
    }
    return json;
  }
}

/// Viewport for capturing screenshot.
class Viewport {
  /// X offset in device independent pixels (dip).
  final num x;

  /// Y offset in device independent pixels (dip).
  final num y;

  /// Rectangle width in device independent pixels (dip).
  final num width;

  /// Rectangle height in device independent pixels (dip).
  final num height;

  /// Page scale factor.
  final num scale;

  Viewport(
      {@required this.x,
      @required this.y,
      @required this.width,
      @required this.height,
      @required this.scale});

  factory Viewport.fromJson(Map<String, dynamic> json) {
    return Viewport(
      x: json['x'],
      y: json['y'],
      width: json['width'],
      height: json['height'],
      scale: json['scale'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'scale': scale,
    };
    return json;
  }
}

/// Generic font families collection.
class FontFamilies {
  /// The standard font-family.
  final String standard;

  /// The fixed font-family.
  final String fixed;

  /// The serif font-family.
  final String serif;

  /// The sansSerif font-family.
  final String sansSerif;

  /// The cursive font-family.
  final String cursive;

  /// The fantasy font-family.
  final String fantasy;

  /// The pictograph font-family.
  final String pictograph;

  FontFamilies(
      {this.standard,
      this.fixed,
      this.serif,
      this.sansSerif,
      this.cursive,
      this.fantasy,
      this.pictograph});

  factory FontFamilies.fromJson(Map<String, dynamic> json) {
    return FontFamilies(
      standard: json.containsKey('standard') ? json['standard'] : null,
      fixed: json.containsKey('fixed') ? json['fixed'] : null,
      serif: json.containsKey('serif') ? json['serif'] : null,
      sansSerif: json.containsKey('sansSerif') ? json['sansSerif'] : null,
      cursive: json.containsKey('cursive') ? json['cursive'] : null,
      fantasy: json.containsKey('fantasy') ? json['fantasy'] : null,
      pictograph: json.containsKey('pictograph') ? json['pictograph'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};
    if (standard != null) {
      json['standard'] = standard;
    }
    if (fixed != null) {
      json['fixed'] = fixed;
    }
    if (serif != null) {
      json['serif'] = serif;
    }
    if (sansSerif != null) {
      json['sansSerif'] = sansSerif;
    }
    if (cursive != null) {
      json['cursive'] = cursive;
    }
    if (fantasy != null) {
      json['fantasy'] = fantasy;
    }
    if (pictograph != null) {
      json['pictograph'] = pictograph;
    }
    return json;
  }
}

/// Default font sizes.
class FontSizes {
  /// Default standard font size.
  final int standard;

  /// Default fixed font size.
  final int fixed;

  FontSizes({this.standard, this.fixed});

  factory FontSizes.fromJson(Map<String, dynamic> json) {
    return FontSizes(
      standard: json.containsKey('standard') ? json['standard'] : null,
      fixed: json.containsKey('fixed') ? json['fixed'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};
    if (standard != null) {
      json['standard'] = standard;
    }
    if (fixed != null) {
      json['fixed'] = fixed;
    }
    return json;
  }
}

class ClientNavigationReason {
  static const ClientNavigationReason formSubmissionGet =
      ClientNavigationReason._('formSubmissionGet');
  static const ClientNavigationReason formSubmissionPost =
      ClientNavigationReason._('formSubmissionPost');
  static const ClientNavigationReason httpHeaderRefresh =
      ClientNavigationReason._('httpHeaderRefresh');
  static const ClientNavigationReason scriptInitiated =
      ClientNavigationReason._('scriptInitiated');
  static const ClientNavigationReason metaTagRefresh =
      ClientNavigationReason._('metaTagRefresh');
  static const ClientNavigationReason pageBlockInterstitial =
      ClientNavigationReason._('pageBlockInterstitial');
  static const ClientNavigationReason reload =
      ClientNavigationReason._('reload');
  static const values = {
    'formSubmissionGet': formSubmissionGet,
    'formSubmissionPost': formSubmissionPost,
    'httpHeaderRefresh': httpHeaderRefresh,
    'scriptInitiated': scriptInitiated,
    'metaTagRefresh': metaTagRefresh,
    'pageBlockInterstitial': pageBlockInterstitial,
    'reload': reload,
  };

  final String value;

  const ClientNavigationReason._(this.value);

  factory ClientNavigationReason.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ClientNavigationReason && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class FrameScheduledNavigationEventReason {
  static const FrameScheduledNavigationEventReason formSubmissionGet =
      FrameScheduledNavigationEventReason._('formSubmissionGet');
  static const FrameScheduledNavigationEventReason formSubmissionPost =
      FrameScheduledNavigationEventReason._('formSubmissionPost');
  static const FrameScheduledNavigationEventReason httpHeaderRefresh =
      FrameScheduledNavigationEventReason._('httpHeaderRefresh');
  static const FrameScheduledNavigationEventReason scriptInitiated =
      FrameScheduledNavigationEventReason._('scriptInitiated');
  static const FrameScheduledNavigationEventReason metaTagRefresh =
      FrameScheduledNavigationEventReason._('metaTagRefresh');
  static const FrameScheduledNavigationEventReason pageBlockInterstitial =
      FrameScheduledNavigationEventReason._('pageBlockInterstitial');
  static const FrameScheduledNavigationEventReason reload =
      FrameScheduledNavigationEventReason._('reload');
  static const values = {
    'formSubmissionGet': formSubmissionGet,
    'formSubmissionPost': formSubmissionPost,
    'httpHeaderRefresh': httpHeaderRefresh,
    'scriptInitiated': scriptInitiated,
    'metaTagRefresh': metaTagRefresh,
    'pageBlockInterstitial': pageBlockInterstitial,
    'reload': reload,
  };

  final String value;

  const FrameScheduledNavigationEventReason._(this.value);

  factory FrameScheduledNavigationEventReason.fromJson(String value) =>
      values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is FrameScheduledNavigationEventReason && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
