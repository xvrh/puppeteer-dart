import 'dart:async';
import '../src/connection.dart';
import 'debugger.dart' as debugger;
import 'dom.dart' as dom;
import 'emulation.dart' as emulation;
import 'io.dart' as io;
import 'network.dart' as network;
import 'runtime.dart' as runtime;

/// Actions and events related to the inspected page belong to the page domain.
class PageApi {
  final Client _client;

  PageApi(this._client);

  Stream<network.MonotonicTime> get onDomContentEventFired => _client.onEvent
      .where((event) => event.name == 'Page.domContentEventFired')
      .map(
        (event) => network.MonotonicTime.fromJson(
          event.parameters['timestamp'] as num,
        ),
      );

  /// Emitted only when `page.interceptFileChooser` is enabled.
  Stream<FileChooserOpenedEvent> get onFileChooserOpened => _client.onEvent
      .where((event) => event.name == 'Page.fileChooserOpened')
      .map((event) => FileChooserOpenedEvent.fromJson(event.parameters));

  /// Fired when frame has been attached to its parent.
  Stream<FrameAttachedEvent> get onFrameAttached => _client.onEvent
      .where((event) => event.name == 'Page.frameAttached')
      .map((event) => FrameAttachedEvent.fromJson(event.parameters));

  /// Fired when frame no longer has a scheduled navigation.
  Stream<FrameId> get onFrameClearedScheduledNavigation => _client.onEvent
      .where((event) => event.name == 'Page.frameClearedScheduledNavigation')
      .map((event) => FrameId.fromJson(event.parameters['frameId'] as String));

  /// Fired when frame has been detached from its parent.
  Stream<FrameDetachedEvent> get onFrameDetached => _client.onEvent
      .where((event) => event.name == 'Page.frameDetached')
      .map((event) => FrameDetachedEvent.fromJson(event.parameters));

  /// Fired before frame subtree is detached. Emitted before any frame of the
  /// subtree is actually detached.
  Stream<FrameId> get onFrameSubtreeWillBeDetached => _client.onEvent
      .where((event) => event.name == 'Page.frameSubtreeWillBeDetached')
      .map((event) => FrameId.fromJson(event.parameters['frameId'] as String));

  /// Fired once navigation of the frame has completed. Frame is now associated with the new loader.
  Stream<FrameNavigatedEvent> get onFrameNavigated => _client.onEvent
      .where((event) => event.name == 'Page.frameNavigated')
      .map((event) => FrameNavigatedEvent.fromJson(event.parameters));

  /// Fired when opening document to write to.
  Stream<FrameInfo> get onDocumentOpened => _client.onEvent
      .where((event) => event.name == 'Page.documentOpened')
      .map(
        (event) => FrameInfo.fromJson(
          event.parameters['frame'] as Map<String, dynamic>,
        ),
      );

  Stream<void> get onFrameResized =>
      _client.onEvent.where((event) => event.name == 'Page.frameResized');

  /// Fired when a navigation starts. This event is fired for both
  /// renderer-initiated and browser-initiated navigations. For renderer-initiated
  /// navigations, the event is fired after `frameRequestedNavigation`.
  /// Navigation may still be cancelled after the event is issued. Multiple events
  /// can be fired for a single navigation, for example, when a same-document
  /// navigation becomes a cross-document navigation (such as in the case of a
  /// frameset).
  Stream<FrameStartedNavigatingEvent> get onFrameStartedNavigating => _client
      .onEvent
      .where((event) => event.name == 'Page.frameStartedNavigating')
      .map((event) => FrameStartedNavigatingEvent.fromJson(event.parameters));

  /// Fired when a renderer-initiated navigation is requested.
  /// Navigation may still be cancelled after the event is issued.
  Stream<FrameRequestedNavigationEvent> get onFrameRequestedNavigation =>
      _client.onEvent
          .where((event) => event.name == 'Page.frameRequestedNavigation')
          .map(
            (event) => FrameRequestedNavigationEvent.fromJson(event.parameters),
          );

  /// Fired when frame schedules a potential navigation.
  Stream<FrameScheduledNavigationEvent> get onFrameScheduledNavigation =>
      _client.onEvent
          .where((event) => event.name == 'Page.frameScheduledNavigation')
          .map(
            (event) => FrameScheduledNavigationEvent.fromJson(event.parameters),
          );

  /// Fired when frame has started loading.
  Stream<FrameId> get onFrameStartedLoading => _client.onEvent
      .where((event) => event.name == 'Page.frameStartedLoading')
      .map((event) => FrameId.fromJson(event.parameters['frameId'] as String));

  /// Fired when frame has stopped loading.
  Stream<FrameId> get onFrameStoppedLoading => _client.onEvent
      .where((event) => event.name == 'Page.frameStoppedLoading')
      .map((event) => FrameId.fromJson(event.parameters['frameId'] as String));

  /// Fired when page is about to start a download.
  /// Deprecated. Use Browser.downloadWillBegin instead.
  Stream<DownloadWillBeginEvent> get onDownloadWillBegin => _client.onEvent
      .where((event) => event.name == 'Page.downloadWillBegin')
      .map((event) => DownloadWillBeginEvent.fromJson(event.parameters));

  /// Fired when download makes progress. Last call has |done| == true.
  /// Deprecated. Use Browser.downloadProgress instead.
  Stream<DownloadProgressEvent> get onDownloadProgress => _client.onEvent
      .where((event) => event.name == 'Page.downloadProgress')
      .map((event) => DownloadProgressEvent.fromJson(event.parameters));

  /// Fired when interstitial page was hidden
  Stream<void> get onInterstitialHidden =>
      _client.onEvent.where((event) => event.name == 'Page.interstitialHidden');

  /// Fired when interstitial page was shown
  Stream<void> get onInterstitialShown =>
      _client.onEvent.where((event) => event.name == 'Page.interstitialShown');

  /// Fired when a JavaScript initiated dialog (alert, confirm, prompt, or onbeforeunload) has been
  /// closed.
  Stream<JavascriptDialogClosedEvent> get onJavascriptDialogClosed => _client
      .onEvent
      .where((event) => event.name == 'Page.javascriptDialogClosed')
      .map((event) => JavascriptDialogClosedEvent.fromJson(event.parameters));

  /// Fired when a JavaScript initiated dialog (alert, confirm, prompt, or onbeforeunload) is about to
  /// open.
  Stream<JavascriptDialogOpeningEvent> get onJavascriptDialogOpening => _client
      .onEvent
      .where((event) => event.name == 'Page.javascriptDialogOpening')
      .map((event) => JavascriptDialogOpeningEvent.fromJson(event.parameters));

  /// Fired for lifecycle events (navigation, load, paint, etc) in the current
  /// target (including local frames).
  Stream<LifecycleEventEvent> get onLifecycleEvent => _client.onEvent
      .where((event) => event.name == 'Page.lifecycleEvent')
      .map((event) => LifecycleEventEvent.fromJson(event.parameters));

  /// Fired for failed bfcache history navigations if BackForwardCache feature is enabled. Do
  /// not assume any ordering with the Page.frameNavigated event. This event is fired only for
  /// main-frame history navigation where the document changes (non-same-document navigations),
  /// when bfcache navigation fails.
  Stream<BackForwardCacheNotUsedEvent> get onBackForwardCacheNotUsed => _client
      .onEvent
      .where((event) => event.name == 'Page.backForwardCacheNotUsed')
      .map((event) => BackForwardCacheNotUsedEvent.fromJson(event.parameters));

  Stream<network.MonotonicTime> get onLoadEventFired => _client.onEvent
      .where((event) => event.name == 'Page.loadEventFired')
      .map(
        (event) => network.MonotonicTime.fromJson(
          event.parameters['timestamp'] as num,
        ),
      );

  /// Fired when same-document navigation happens, e.g. due to history API usage or anchor navigation.
  Stream<NavigatedWithinDocumentEvent> get onNavigatedWithinDocument => _client
      .onEvent
      .where((event) => event.name == 'Page.navigatedWithinDocument')
      .map((event) => NavigatedWithinDocumentEvent.fromJson(event.parameters));

  /// Compressed image data requested by the `startScreencast`.
  Stream<ScreencastFrameEvent> get onScreencastFrame => _client.onEvent
      .where((event) => event.name == 'Page.screencastFrame')
      .map((event) => ScreencastFrameEvent.fromJson(event.parameters));

  /// Fired when the page with currently enabled screencast was shown or hidden `.
  Stream<bool> get onScreencastVisibilityChanged => _client.onEvent
      .where((event) => event.name == 'Page.screencastVisibilityChanged')
      .map((event) => event.parameters['visible'] as bool);

  /// Fired when a new window is going to be opened, via window.open(), link click, form submission,
  /// etc.
  Stream<WindowOpenEvent> get onWindowOpen => _client.onEvent
      .where((event) => event.name == 'Page.windowOpen')
      .map((event) => WindowOpenEvent.fromJson(event.parameters));

  /// Issued for every compilation cache generated. Is only available
  /// if Page.setGenerateCompilationCache is enabled.
  Stream<CompilationCacheProducedEvent> get onCompilationCacheProduced =>
      _client.onEvent
          .where((event) => event.name == 'Page.compilationCacheProduced')
          .map(
            (event) => CompilationCacheProducedEvent.fromJson(event.parameters),
          );

  /// Deprecated, please use addScriptToEvaluateOnNewDocument instead.
  /// Returns: Identifier of the added script.
  @Deprecated('use addScriptToEvaluateOnNewDocument instead')
  Future<ScriptIdentifier> addScriptToEvaluateOnLoad(
    String scriptSource,
  ) async {
    var result = await _client.send('Page.addScriptToEvaluateOnLoad', {
      'scriptSource': scriptSource,
    });
    return ScriptIdentifier.fromJson(result['identifier'] as String);
  }

  /// Evaluates given script in every frame upon creation (before loading frame's scripts).
  /// [worldName] If specified, creates an isolated world with the given name and evaluates given script in it.
  /// This world name will be used as the ExecutionContextDescription::name when the corresponding
  /// event is emitted.
  /// [includeCommandLineAPI] Specifies whether command line API should be available to the script, defaults
  /// to false.
  /// [runImmediately] If true, runs the script immediately on existing execution contexts or worlds.
  /// Default: false.
  /// Returns: Identifier of the added script.
  Future<ScriptIdentifier> addScriptToEvaluateOnNewDocument(
    String source, {
    String? worldName,
    bool? includeCommandLineAPI,
    bool? runImmediately,
  }) async {
    var result = await _client.send('Page.addScriptToEvaluateOnNewDocument', {
      'source': source,
      if (worldName != null) 'worldName': worldName,
      if (includeCommandLineAPI != null)
        'includeCommandLineAPI': includeCommandLineAPI,
      if (runImmediately != null) 'runImmediately': runImmediately,
    });
    return ScriptIdentifier.fromJson(result['identifier'] as String);
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
  /// [captureBeyondViewport] Capture the screenshot beyond the viewport. Defaults to false.
  /// [optimizeForSpeed] Optimize image encoding for speed, not for resulting size (defaults to false)
  /// Returns: Base64-encoded image data.
  Future<String> captureScreenshot({
    @Enum(['jpeg', 'png', 'webp']) String? format,
    int? quality,
    Viewport? clip,
    bool? fromSurface,
    bool? captureBeyondViewport,
    bool? optimizeForSpeed,
  }) async {
    assert(format == null || const ['jpeg', 'png', 'webp'].contains(format));
    var result = await _client.send('Page.captureScreenshot', {
      if (format != null) 'format': format,
      if (quality != null) 'quality': quality,
      if (clip != null) 'clip': clip,
      if (fromSurface != null) 'fromSurface': fromSurface,
      if (captureBeyondViewport != null)
        'captureBeyondViewport': captureBeyondViewport,
      if (optimizeForSpeed != null) 'optimizeForSpeed': optimizeForSpeed,
    });
    return result['data'] as String;
  }

  /// Returns a snapshot of the page as a string. For MHTML format, the serialization includes
  /// iframes, shadow DOM, external resources, and element-inline styles.
  /// [format] Format (defaults to mhtml).
  /// Returns: Serialized page data.
  Future<String> captureSnapshot({@Enum(['mhtml']) String? format}) async {
    assert(format == null || const ['mhtml'].contains(format));
    var result = await _client.send('Page.captureSnapshot', {
      if (format != null) 'format': format,
    });
    return result['data'] as String;
  }

  /// Clears the overridden device metrics.
  @Deprecated('This command is deprecated')
  Future<void> clearDeviceMetricsOverride() async {
    await _client.send('Page.clearDeviceMetricsOverride');
  }

  /// Clears the overridden Device Orientation.
  @Deprecated('This command is deprecated')
  Future<void> clearDeviceOrientationOverride() async {
    await _client.send('Page.clearDeviceOrientationOverride');
  }

  /// Clears the overridden Geolocation Position and Error.
  @Deprecated('This command is deprecated')
  Future<void> clearGeolocationOverride() async {
    await _client.send('Page.clearGeolocationOverride');
  }

  /// Creates an isolated world for the given frame.
  /// [frameId] Id of the frame in which the isolated world should be created.
  /// [worldName] An optional name which is reported in the Execution Context.
  /// [grantUniveralAccess] Whether or not universal access should be granted to the isolated world. This is a powerful
  /// option, use with caution.
  /// Returns: Execution context of the isolated world.
  Future<runtime.ExecutionContextId> createIsolatedWorld(
    FrameId frameId, {
    String? worldName,
    bool? grantUniveralAccess,
  }) async {
    var result = await _client.send('Page.createIsolatedWorld', {
      'frameId': frameId,
      if (worldName != null) 'worldName': worldName,
      if (grantUniveralAccess != null)
        'grantUniveralAccess': grantUniveralAccess,
    });
    return runtime.ExecutionContextId.fromJson(
      result['executionContextId'] as int,
    );
  }

  /// Deletes browser cookie with given name, domain and path.
  /// [cookieName] Name of the cookie to remove.
  /// [url] URL to match cooke domain and path.
  @Deprecated('This command is deprecated')
  Future<void> deleteCookie(String cookieName, String url) async {
    await _client.send('Page.deleteCookie', {
      'cookieName': cookieName,
      'url': url,
    });
  }

  /// Disables page domain notifications.
  Future<void> disable() async {
    await _client.send('Page.disable');
  }

  /// Enables page domain notifications.
  /// [enableFileChooserOpenedEvent] If true, the `Page.fileChooserOpened` event will be emitted regardless of the state set by
  /// `Page.setInterceptFileChooserDialog` command (default: false).
  Future<void> enable({bool? enableFileChooserOpenedEvent}) async {
    await _client.send('Page.enable', {
      if (enableFileChooserOpenedEvent != null)
        'enableFileChooserOpenedEvent': enableFileChooserOpenedEvent,
    });
  }

  /// Gets the processed manifest for this current document.
  ///   This API always waits for the manifest to be loaded.
  ///   If manifestId is provided, and it does not match the manifest of the
  ///     current document, this API errors out.
  ///   If there is not a loaded page, this API errors out immediately.
  Future<GetAppManifestResult> getAppManifest({String? manifestId}) async {
    var result = await _client.send('Page.getAppManifest', {
      if (manifestId != null) 'manifestId': manifestId,
    });
    return GetAppManifestResult.fromJson(result);
  }

  Future<List<InstallabilityError>> getInstallabilityErrors() async {
    var result = await _client.send('Page.getInstallabilityErrors');
    return (result['installabilityErrors'] as List)
        .map((e) => InstallabilityError.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Deprecated because it's not guaranteed that the returned icon is in fact the one used for PWA installation.
  @Deprecated('This command is deprecated')
  Future<String> getManifestIcons() async {
    var result = await _client.send('Page.getManifestIcons');
    return result['primaryIcon'] as String;
  }

  /// Returns the unique (PWA) app id.
  /// Only returns values if the feature flag 'WebAppEnableManifestId' is enabled
  Future<GetAppIdResult> getAppId() async {
    var result = await _client.send('Page.getAppId');
    return GetAppIdResult.fromJson(result);
  }

  /// Returns: The ancestry chain of ad script identifiers leading to this frame's
  /// creation, ordered from the most immediate script (in the frame creation
  /// stack) to more distant ancestors (that created the immediately preceding
  /// script). Only sent if frame is labelled as an ad and ids are available.
  Future<List<AdScriptId>> getAdScriptAncestryIds(FrameId frameId) async {
    var result = await _client.send('Page.getAdScriptAncestryIds', {
      'frameId': frameId,
    });
    return (result['adScriptAncestryIds'] as List)
        .map((e) => AdScriptId.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns present frame tree structure.
  /// Returns: Present frame tree structure.
  Future<FrameTree> getFrameTree() async {
    var result = await _client.send('Page.getFrameTree');
    return FrameTree.fromJson(result['frameTree'] as Map<String, dynamic>);
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
    FrameId frameId,
    String url,
  ) async {
    var result = await _client.send('Page.getResourceContent', {
      'frameId': frameId,
      'url': url,
    });
    return GetResourceContentResult.fromJson(result);
  }

  /// Returns present frame / resource tree structure.
  /// Returns: Present frame / resource tree structure.
  Future<FrameResourceTree> getResourceTree() async {
    var result = await _client.send('Page.getResourceTree');
    return FrameResourceTree.fromJson(
      result['frameTree'] as Map<String, dynamic>,
    );
  }

  /// Accepts or dismisses a JavaScript initiated dialog (alert, confirm, prompt, or onbeforeunload).
  /// [accept] Whether to accept or dismiss the dialog.
  /// [promptText] The text to enter into the dialog prompt before accepting. Used only if this is a prompt
  /// dialog.
  Future<void> handleJavaScriptDialog(bool accept, {String? promptText}) async {
    await _client.send('Page.handleJavaScriptDialog', {
      'accept': accept,
      if (promptText != null) 'promptText': promptText,
    });
  }

  /// Navigates current page to the given URL.
  /// [url] URL to navigate the page to.
  /// [referrer] Referrer URL.
  /// [transitionType] Intended transition type.
  /// [frameId] Frame id to navigate, if not specified navigates the top frame.
  /// [referrerPolicy] Referrer-policy used for the navigation.
  Future<NavigateResult> navigate(
    String url, {
    String? referrer,
    TransitionType? transitionType,
    FrameId? frameId,
    ReferrerPolicy? referrerPolicy,
  }) async {
    var result = await _client.send('Page.navigate', {
      'url': url,
      if (referrer != null) 'referrer': referrer,
      if (transitionType != null) 'transitionType': transitionType,
      if (frameId != null) 'frameId': frameId,
      if (referrerPolicy != null) 'referrerPolicy': referrerPolicy,
    });
    return NavigateResult.fromJson(result);
  }

  /// Navigates current page to the given history entry.
  /// [entryId] Unique id of the entry to navigate to.
  Future<void> navigateToHistoryEntry(int entryId) async {
    await _client.send('Page.navigateToHistoryEntry', {'entryId': entryId});
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
  /// [pageRanges] Paper ranges to print, one based, e.g., '1-5, 8, 11-13'. Pages are
  /// printed in the document order, not in the order specified, and no
  /// more than once.
  /// Defaults to empty string, which implies the entire document is printed.
  /// The page numbers are quietly capped to actual page count of the
  /// document, and ranges beyond the end of the document are ignored.
  /// If this results in no pages to print, an error is reported.
  /// It is an error to specify a range with start greater than end.
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
  /// [transferMode] return as stream
  /// [generateTaggedPDF] Whether or not to generate tagged (accessible) PDF. Defaults to embedder choice.
  /// [generateDocumentOutline] Whether or not to embed the document outline into the PDF.
  Future<PrintToPDFResult> printToPDF({
    bool? landscape,
    bool? displayHeaderFooter,
    bool? printBackground,
    num? scale,
    num? paperWidth,
    num? paperHeight,
    num? marginTop,
    num? marginBottom,
    num? marginLeft,
    num? marginRight,
    String? pageRanges,
    String? headerTemplate,
    String? footerTemplate,
    bool? preferCSSPageSize,
    @Enum(['ReturnAsBase64', 'ReturnAsStream']) String? transferMode,
    bool? generateTaggedPDF,
    bool? generateDocumentOutline,
  }) async {
    assert(
      transferMode == null ||
          const ['ReturnAsBase64', 'ReturnAsStream'].contains(transferMode),
    );
    var result = await _client.send('Page.printToPDF', {
      if (landscape != null) 'landscape': landscape,
      if (displayHeaderFooter != null)
        'displayHeaderFooter': displayHeaderFooter,
      if (printBackground != null) 'printBackground': printBackground,
      if (scale != null) 'scale': scale,
      if (paperWidth != null) 'paperWidth': paperWidth,
      if (paperHeight != null) 'paperHeight': paperHeight,
      if (marginTop != null) 'marginTop': marginTop,
      if (marginBottom != null) 'marginBottom': marginBottom,
      if (marginLeft != null) 'marginLeft': marginLeft,
      if (marginRight != null) 'marginRight': marginRight,
      if (pageRanges != null) 'pageRanges': pageRanges,
      if (headerTemplate != null) 'headerTemplate': headerTemplate,
      if (footerTemplate != null) 'footerTemplate': footerTemplate,
      if (preferCSSPageSize != null) 'preferCSSPageSize': preferCSSPageSize,
      if (transferMode != null) 'transferMode': transferMode,
      if (generateTaggedPDF != null) 'generateTaggedPDF': generateTaggedPDF,
      if (generateDocumentOutline != null)
        'generateDocumentOutline': generateDocumentOutline,
    });
    return PrintToPDFResult.fromJson(result);
  }

  /// Reloads given page optionally ignoring the cache.
  /// [ignoreCache] If true, browser cache is ignored (as if the user pressed Shift+refresh).
  /// [scriptToEvaluateOnLoad] If set, the script will be injected into all frames of the inspected page after reload.
  /// Argument will be ignored if reloading dataURL origin.
  /// [loaderId] If set, an error will be thrown if the target page's main frame's
  /// loader id does not match the provided id. This prevents accidentally
  /// reloading an unintended target in case there's a racing navigation.
  Future<void> reload({
    bool? ignoreCache,
    String? scriptToEvaluateOnLoad,
    network.LoaderId? loaderId,
  }) async {
    await _client.send('Page.reload', {
      if (ignoreCache != null) 'ignoreCache': ignoreCache,
      if (scriptToEvaluateOnLoad != null)
        'scriptToEvaluateOnLoad': scriptToEvaluateOnLoad,
      if (loaderId != null) 'loaderId': loaderId,
    });
  }

  /// Deprecated, please use removeScriptToEvaluateOnNewDocument instead.
  @Deprecated('use removeScriptToEvaluateOnNewDocument instead')
  Future<void> removeScriptToEvaluateOnLoad(ScriptIdentifier identifier) async {
    await _client.send('Page.removeScriptToEvaluateOnLoad', {
      'identifier': identifier,
    });
  }

  /// Removes given script from the list.
  Future<void> removeScriptToEvaluateOnNewDocument(
    ScriptIdentifier identifier,
  ) async {
    await _client.send('Page.removeScriptToEvaluateOnNewDocument', {
      'identifier': identifier,
    });
  }

  /// Acknowledges that a screencast frame has been received by the frontend.
  /// [sessionId] Frame number.
  Future<void> screencastFrameAck(int sessionId) async {
    await _client.send('Page.screencastFrameAck', {'sessionId': sessionId});
  }

  /// Searches for given string in resource content.
  /// [frameId] Frame id for resource to search in.
  /// [url] URL of the resource to search in.
  /// [query] String to search for.
  /// [caseSensitive] If true, search is case sensitive.
  /// [isRegex] If true, treats string parameter as regex.
  /// Returns: List of search matches.
  Future<List<debugger.SearchMatch>> searchInResource(
    FrameId frameId,
    String url,
    String query, {
    bool? caseSensitive,
    bool? isRegex,
  }) async {
    var result = await _client.send('Page.searchInResource', {
      'frameId': frameId,
      'url': url,
      'query': query,
      if (caseSensitive != null) 'caseSensitive': caseSensitive,
      if (isRegex != null) 'isRegex': isRegex,
    });
    return (result['result'] as List)
        .map((e) => debugger.SearchMatch.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Enable Chrome's experimental ad filter on all sites.
  /// [enabled] Whether to block ads.
  Future<void> setAdBlockingEnabled(bool enabled) async {
    await _client.send('Page.setAdBlockingEnabled', {'enabled': enabled});
  }

  /// Enable page Content Security Policy by-passing.
  /// [enabled] Whether to bypass page CSP.
  Future<void> setBypassCSP(bool enabled) async {
    await _client.send('Page.setBypassCSP', {'enabled': enabled});
  }

  /// Get Permissions Policy state on given frame.
  Future<List<PermissionsPolicyFeatureState>> getPermissionsPolicyState(
    FrameId frameId,
  ) async {
    var result = await _client.send('Page.getPermissionsPolicyState', {
      'frameId': frameId,
    });
    return (result['states'] as List)
        .map(
          (e) =>
              PermissionsPolicyFeatureState.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  /// Get Origin Trials on given frame.
  Future<List<OriginTrial>> getOriginTrials(FrameId frameId) async {
    var result = await _client.send('Page.getOriginTrials', {
      'frameId': frameId,
    });
    return (result['originTrials'] as List)
        .map((e) => OriginTrial.fromJson(e as Map<String, dynamic>))
        .toList();
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
  @Deprecated('This command is deprecated')
  Future<void> setDeviceMetricsOverride(
    int width,
    int height,
    num deviceScaleFactor,
    bool mobile, {
    num? scale,
    int? screenWidth,
    int? screenHeight,
    int? positionX,
    int? positionY,
    bool? dontSetVisibleSize,
    emulation.ScreenOrientation? screenOrientation,
    Viewport? viewport,
  }) async {
    await _client.send('Page.setDeviceMetricsOverride', {
      'width': width,
      'height': height,
      'deviceScaleFactor': deviceScaleFactor,
      'mobile': mobile,
      if (scale != null) 'scale': scale,
      if (screenWidth != null) 'screenWidth': screenWidth,
      if (screenHeight != null) 'screenHeight': screenHeight,
      if (positionX != null) 'positionX': positionX,
      if (positionY != null) 'positionY': positionY,
      if (dontSetVisibleSize != null) 'dontSetVisibleSize': dontSetVisibleSize,
      if (screenOrientation != null) 'screenOrientation': screenOrientation,
      if (viewport != null) 'viewport': viewport,
    });
  }

  /// Overrides the Device Orientation.
  /// [alpha] Mock alpha
  /// [beta] Mock beta
  /// [gamma] Mock gamma
  @Deprecated('This command is deprecated')
  Future<void> setDeviceOrientationOverride(
    num alpha,
    num beta,
    num gamma,
  ) async {
    await _client.send('Page.setDeviceOrientationOverride', {
      'alpha': alpha,
      'beta': beta,
      'gamma': gamma,
    });
  }

  /// Set generic font families.
  /// [fontFamilies] Specifies font families to set. If a font family is not specified, it won't be changed.
  /// [forScripts] Specifies font families to set for individual scripts.
  Future<void> setFontFamilies(
    FontFamilies fontFamilies, {
    List<ScriptFontFamilies>? forScripts,
  }) async {
    await _client.send('Page.setFontFamilies', {
      'fontFamilies': fontFamilies,
      if (forScripts != null) 'forScripts': [...forScripts],
    });
  }

  /// Set default font sizes.
  /// [fontSizes] Specifies font sizes to set. If a font size is not specified, it won't be changed.
  Future<void> setFontSizes(FontSizes fontSizes) async {
    await _client.send('Page.setFontSizes', {'fontSizes': fontSizes});
  }

  /// Sets given markup as the document's HTML.
  /// [frameId] Frame id to set HTML for.
  /// [html] HTML content to set.
  Future<void> setDocumentContent(FrameId frameId, String html) async {
    await _client.send('Page.setDocumentContent', {
      'frameId': frameId,
      'html': html,
    });
  }

  /// Set the behavior when downloading a file.
  /// [behavior] Whether to allow all or deny all download requests, or use default Chrome behavior if
  /// available (otherwise deny).
  /// [downloadPath] The default path to save downloaded files to. This is required if behavior is set to 'allow'
  @Deprecated('This command is deprecated')
  Future<void> setDownloadBehavior(
    @Enum(['deny', 'allow', 'default']) String behavior, {
    String? downloadPath,
  }) async {
    assert(const ['deny', 'allow', 'default'].contains(behavior));
    await _client.send('Page.setDownloadBehavior', {
      'behavior': behavior,
      if (downloadPath != null) 'downloadPath': downloadPath,
    });
  }

  /// Overrides the Geolocation Position or Error. Omitting any of the parameters emulates position
  /// unavailable.
  /// [latitude] Mock latitude
  /// [longitude] Mock longitude
  /// [accuracy] Mock accuracy
  @Deprecated('This command is deprecated')
  Future<void> setGeolocationOverride({
    num? latitude,
    num? longitude,
    num? accuracy,
  }) async {
    await _client.send('Page.setGeolocationOverride', {
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
    });
  }

  /// Controls whether page will emit lifecycle events.
  /// [enabled] If true, starts emitting lifecycle events.
  Future<void> setLifecycleEventsEnabled(bool enabled) async {
    await _client.send('Page.setLifecycleEventsEnabled', {'enabled': enabled});
  }

  /// Toggles mouse event-based touch event emulation.
  /// [enabled] Whether the touch event emulation should be enabled.
  /// [configuration] Touch/gesture events configuration. Default: current platform.
  @Deprecated('This command is deprecated')
  Future<void> setTouchEmulationEnabled(
    bool enabled, {
    @Enum(['mobile', 'desktop']) String? configuration,
  }) async {
    assert(
      configuration == null ||
          const ['mobile', 'desktop'].contains(configuration),
    );
    await _client.send('Page.setTouchEmulationEnabled', {
      'enabled': enabled,
      if (configuration != null) 'configuration': configuration,
    });
  }

  /// Starts sending each frame using the `screencastFrame` event.
  /// [format] Image compression format.
  /// [quality] Compression quality from range [0..100].
  /// [maxWidth] Maximum screenshot width.
  /// [maxHeight] Maximum screenshot height.
  /// [everyNthFrame] Send every n-th frame.
  Future<void> startScreencast({
    @Enum(['jpeg', 'png']) String? format,
    int? quality,
    int? maxWidth,
    int? maxHeight,
    int? everyNthFrame,
  }) async {
    assert(format == null || const ['jpeg', 'png'].contains(format));
    await _client.send('Page.startScreencast', {
      if (format != null) 'format': format,
      if (quality != null) 'quality': quality,
      if (maxWidth != null) 'maxWidth': maxWidth,
      if (maxHeight != null) 'maxHeight': maxHeight,
      if (everyNthFrame != null) 'everyNthFrame': everyNthFrame,
    });
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
    @Enum(['frozen', 'active']) String state,
  ) async {
    assert(const ['frozen', 'active'].contains(state));
    await _client.send('Page.setWebLifecycleState', {'state': state});
  }

  /// Stops sending each frame in the `screencastFrame`.
  Future<void> stopScreencast() async {
    await _client.send('Page.stopScreencast');
  }

  /// Requests backend to produce compilation cache for the specified scripts.
  /// `scripts` are appended to the list of scripts for which the cache
  /// would be produced. The list may be reset during page navigation.
  /// When script with a matching URL is encountered, the cache is optionally
  /// produced upon backend discretion, based on internal heuristics.
  /// See also: `Page.compilationCacheProduced`.
  Future<void> produceCompilationCache(
    List<CompilationCacheParams> scripts,
  ) async {
    await _client.send('Page.produceCompilationCache', {
      'scripts': [...scripts],
    });
  }

  /// Seeds compilation cache for given url. Compilation cache does not survive
  /// cross-process navigation.
  /// [data] Base64-encoded data
  Future<void> addCompilationCache(String url, String data) async {
    await _client.send('Page.addCompilationCache', {'url': url, 'data': data});
  }

  /// Clears seeded compilation cache.
  Future<void> clearCompilationCache() async {
    await _client.send('Page.clearCompilationCache');
  }

  /// Sets the Secure Payment Confirmation transaction mode.
  /// https://w3c.github.io/secure-payment-confirmation/#sctn-automation-set-spc-transaction-mode
  Future<void> setSPCTransactionMode(AutoResponseMode mode) async {
    await _client.send('Page.setSPCTransactionMode', {'mode': mode});
  }

  /// Extensions for Custom Handlers API:
  /// https://html.spec.whatwg.org/multipage/system-state.html#rph-automation
  Future<void> setRPHRegistrationMode(AutoResponseMode mode) async {
    await _client.send('Page.setRPHRegistrationMode', {'mode': mode});
  }

  /// Generates a report for testing.
  /// [message] Message to be displayed in the report.
  /// [group] Specifies the endpoint group to deliver the report to.
  Future<void> generateTestReport(String message, {String? group}) async {
    await _client.send('Page.generateTestReport', {
      'message': message,
      if (group != null) 'group': group,
    });
  }

  /// Pauses page execution. Can be resumed using generic Runtime.runIfWaitingForDebugger.
  Future<void> waitForDebugger() async {
    await _client.send('Page.waitForDebugger');
  }

  /// Intercept file chooser requests and transfer control to protocol clients.
  /// When file chooser interception is enabled, native file chooser dialog is not shown.
  /// Instead, a protocol event `Page.fileChooserOpened` is emitted.
  /// [cancel] If true, cancels the dialog by emitting relevant events (if any)
  /// in addition to not showing it if the interception is enabled
  /// (default: false).
  Future<void> setInterceptFileChooserDialog(
    bool enabled, {
    bool? cancel,
  }) async {
    await _client.send('Page.setInterceptFileChooserDialog', {
      'enabled': enabled,
      if (cancel != null) 'cancel': cancel,
    });
  }

  /// Enable/disable prerendering manually.
  ///
  /// This command is a short-term solution for https://crbug.com/1440085.
  /// See https://docs.google.com/document/d/12HVmFxYj5Jc-eJr5OmWsa2bqTJsbgGLKI6ZIyx0_wpA
  /// for more details.
  ///
  /// TODO(https://crbug.com/1440085): Remove this once Puppeteer supports tab targets.
  Future<void> setPrerenderingAllowed(bool isAllowed) async {
    await _client.send('Page.setPrerenderingAllowed', {'isAllowed': isAllowed});
  }
}

class FileChooserOpenedEvent {
  /// Id of the frame containing input node.
  final FrameId frameId;

  /// Input mode.
  final FileChooserOpenedEventMode mode;

  /// Input node id. Only present for file choosers opened via an `<input type="file">` element.
  final dom.BackendNodeId? backendNodeId;

  FileChooserOpenedEvent({
    required this.frameId,
    required this.mode,
    this.backendNodeId,
  });

  factory FileChooserOpenedEvent.fromJson(Map<String, dynamic> json) {
    return FileChooserOpenedEvent(
      frameId: FrameId.fromJson(json['frameId'] as String),
      mode: FileChooserOpenedEventMode.fromJson(json['mode'] as String),
      backendNodeId: json.containsKey('backendNodeId')
          ? dom.BackendNodeId.fromJson(json['backendNodeId'] as int)
          : null,
    );
  }
}

class FrameAttachedEvent {
  /// Id of the frame that has been attached.
  final FrameId frameId;

  /// Parent frame identifier.
  final FrameId parentFrameId;

  /// JavaScript stack trace of when frame was attached, only set if frame initiated from script.
  final runtime.StackTraceData? stack;

  FrameAttachedEvent({
    required this.frameId,
    required this.parentFrameId,
    this.stack,
  });

  factory FrameAttachedEvent.fromJson(Map<String, dynamic> json) {
    return FrameAttachedEvent(
      frameId: FrameId.fromJson(json['frameId'] as String),
      parentFrameId: FrameId.fromJson(json['parentFrameId'] as String),
      stack: json.containsKey('stack')
          ? runtime.StackTraceData.fromJson(
              json['stack'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class FrameDetachedEvent {
  /// Id of the frame that has been detached.
  final FrameId frameId;

  final FrameDetachedEventReason reason;

  FrameDetachedEvent({required this.frameId, required this.reason});

  factory FrameDetachedEvent.fromJson(Map<String, dynamic> json) {
    return FrameDetachedEvent(
      frameId: FrameId.fromJson(json['frameId'] as String),
      reason: FrameDetachedEventReason.fromJson(json['reason'] as String),
    );
  }
}

class FrameNavigatedEvent {
  /// Frame object.
  final FrameInfo frame;

  final NavigationType type;

  FrameNavigatedEvent({required this.frame, required this.type});

  factory FrameNavigatedEvent.fromJson(Map<String, dynamic> json) {
    return FrameNavigatedEvent(
      frame: FrameInfo.fromJson(json['frame'] as Map<String, dynamic>),
      type: NavigationType.fromJson(json['type'] as String),
    );
  }
}

class FrameStartedNavigatingEvent {
  /// ID of the frame that is being navigated.
  final FrameId frameId;

  /// The URL the navigation started with. The final URL can be different.
  final String url;

  /// Loader identifier. Even though it is present in case of same-document
  /// navigation, the previously committed loaderId would not change unless
  /// the navigation changes from a same-document to a cross-document
  /// navigation.
  final network.LoaderId loaderId;

  final FrameStartedNavigatingEventNavigationType navigationType;

  FrameStartedNavigatingEvent({
    required this.frameId,
    required this.url,
    required this.loaderId,
    required this.navigationType,
  });

  factory FrameStartedNavigatingEvent.fromJson(Map<String, dynamic> json) {
    return FrameStartedNavigatingEvent(
      frameId: FrameId.fromJson(json['frameId'] as String),
      url: json['url'] as String,
      loaderId: network.LoaderId.fromJson(json['loaderId'] as String),
      navigationType: FrameStartedNavigatingEventNavigationType.fromJson(
        json['navigationType'] as String,
      ),
    );
  }
}

class FrameRequestedNavigationEvent {
  /// Id of the frame that is being navigated.
  final FrameId frameId;

  /// The reason for the navigation.
  final ClientNavigationReason reason;

  /// The destination URL for the requested navigation.
  final String url;

  /// The disposition for the navigation.
  final ClientNavigationDisposition disposition;

  FrameRequestedNavigationEvent({
    required this.frameId,
    required this.reason,
    required this.url,
    required this.disposition,
  });

  factory FrameRequestedNavigationEvent.fromJson(Map<String, dynamic> json) {
    return FrameRequestedNavigationEvent(
      frameId: FrameId.fromJson(json['frameId'] as String),
      reason: ClientNavigationReason.fromJson(json['reason'] as String),
      url: json['url'] as String,
      disposition: ClientNavigationDisposition.fromJson(
        json['disposition'] as String,
      ),
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
  final ClientNavigationReason reason;

  /// The destination URL for the scheduled navigation.
  final String url;

  FrameScheduledNavigationEvent({
    required this.frameId,
    required this.delay,
    required this.reason,
    required this.url,
  });

  factory FrameScheduledNavigationEvent.fromJson(Map<String, dynamic> json) {
    return FrameScheduledNavigationEvent(
      frameId: FrameId.fromJson(json['frameId'] as String),
      delay: json['delay'] as num,
      reason: ClientNavigationReason.fromJson(json['reason'] as String),
      url: json['url'] as String,
    );
  }
}

class DownloadWillBeginEvent {
  /// Id of the frame that caused download to begin.
  final FrameId frameId;

  /// Global unique identifier of the download.
  final String guid;

  /// URL of the resource being downloaded.
  final String url;

  /// Suggested file name of the resource (the actual name of the file saved on disk may differ).
  final String suggestedFilename;

  DownloadWillBeginEvent({
    required this.frameId,
    required this.guid,
    required this.url,
    required this.suggestedFilename,
  });

  factory DownloadWillBeginEvent.fromJson(Map<String, dynamic> json) {
    return DownloadWillBeginEvent(
      frameId: FrameId.fromJson(json['frameId'] as String),
      guid: json['guid'] as String,
      url: json['url'] as String,
      suggestedFilename: json['suggestedFilename'] as String,
    );
  }
}

class DownloadProgressEvent {
  /// Global unique identifier of the download.
  final String guid;

  /// Total expected bytes to download.
  final num totalBytes;

  /// Total bytes received.
  final num receivedBytes;

  /// Download status.
  final DownloadProgressEventState state;

  DownloadProgressEvent({
    required this.guid,
    required this.totalBytes,
    required this.receivedBytes,
    required this.state,
  });

  factory DownloadProgressEvent.fromJson(Map<String, dynamic> json) {
    return DownloadProgressEvent(
      guid: json['guid'] as String,
      totalBytes: json['totalBytes'] as num,
      receivedBytes: json['receivedBytes'] as num,
      state: DownloadProgressEventState.fromJson(json['state'] as String),
    );
  }
}

class JavascriptDialogClosedEvent {
  /// Frame id.
  final FrameId frameId;

  /// Whether dialog was confirmed.
  final bool result;

  /// User input in case of prompt.
  final String userInput;

  JavascriptDialogClosedEvent({
    required this.frameId,
    required this.result,
    required this.userInput,
  });

  factory JavascriptDialogClosedEvent.fromJson(Map<String, dynamic> json) {
    return JavascriptDialogClosedEvent(
      frameId: FrameId.fromJson(json['frameId'] as String),
      result: json['result'] as bool? ?? false,
      userInput: json['userInput'] as String,
    );
  }
}

class JavascriptDialogOpeningEvent {
  /// Frame url.
  final String url;

  /// Frame id.
  final FrameId frameId;

  /// Message that will be displayed by the dialog.
  final String message;

  /// Dialog type.
  final DialogType type;

  /// True iff browser is capable showing or acting on the given dialog. When browser has no
  /// dialog handler for given target, calling alert while Page domain is engaged will stall
  /// the page execution. Execution can be resumed via calling Page.handleJavaScriptDialog.
  final bool hasBrowserHandler;

  /// Default dialog prompt.
  final String? defaultPrompt;

  JavascriptDialogOpeningEvent({
    required this.url,
    required this.frameId,
    required this.message,
    required this.type,
    required this.hasBrowserHandler,
    this.defaultPrompt,
  });

  factory JavascriptDialogOpeningEvent.fromJson(Map<String, dynamic> json) {
    return JavascriptDialogOpeningEvent(
      url: json['url'] as String,
      frameId: FrameId.fromJson(json['frameId'] as String),
      message: json['message'] as String,
      type: DialogType.fromJson(json['type'] as String),
      hasBrowserHandler: json['hasBrowserHandler'] as bool? ?? false,
      defaultPrompt: json.containsKey('defaultPrompt')
          ? json['defaultPrompt'] as String
          : null,
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

  LifecycleEventEvent({
    required this.frameId,
    required this.loaderId,
    required this.name,
    required this.timestamp,
  });

  factory LifecycleEventEvent.fromJson(Map<String, dynamic> json) {
    return LifecycleEventEvent(
      frameId: FrameId.fromJson(json['frameId'] as String),
      loaderId: network.LoaderId.fromJson(json['loaderId'] as String),
      name: json['name'] as String,
      timestamp: network.MonotonicTime.fromJson(json['timestamp'] as num),
    );
  }
}

class BackForwardCacheNotUsedEvent {
  /// The loader id for the associated navigation.
  final network.LoaderId loaderId;

  /// The frame id of the associated frame.
  final FrameId frameId;

  /// Array of reasons why the page could not be cached. This must not be empty.
  final List<BackForwardCacheNotRestoredExplanation> notRestoredExplanations;

  /// Tree structure of reasons why the page could not be cached for each frame.
  final BackForwardCacheNotRestoredExplanationTree? notRestoredExplanationsTree;

  BackForwardCacheNotUsedEvent({
    required this.loaderId,
    required this.frameId,
    required this.notRestoredExplanations,
    this.notRestoredExplanationsTree,
  });

  factory BackForwardCacheNotUsedEvent.fromJson(Map<String, dynamic> json) {
    return BackForwardCacheNotUsedEvent(
      loaderId: network.LoaderId.fromJson(json['loaderId'] as String),
      frameId: FrameId.fromJson(json['frameId'] as String),
      notRestoredExplanations: (json['notRestoredExplanations'] as List)
          .map(
            (e) => BackForwardCacheNotRestoredExplanation.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      notRestoredExplanationsTree:
          json.containsKey('notRestoredExplanationsTree')
          ? BackForwardCacheNotRestoredExplanationTree.fromJson(
              json['notRestoredExplanationsTree'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class NavigatedWithinDocumentEvent {
  /// Id of the frame.
  final FrameId frameId;

  /// Frame's new url.
  final String url;

  /// Navigation type
  final NavigatedWithinDocumentEventNavigationType navigationType;

  NavigatedWithinDocumentEvent({
    required this.frameId,
    required this.url,
    required this.navigationType,
  });

  factory NavigatedWithinDocumentEvent.fromJson(Map<String, dynamic> json) {
    return NavigatedWithinDocumentEvent(
      frameId: FrameId.fromJson(json['frameId'] as String),
      url: json['url'] as String,
      navigationType: NavigatedWithinDocumentEventNavigationType.fromJson(
        json['navigationType'] as String,
      ),
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

  ScreencastFrameEvent({
    required this.data,
    required this.metadata,
    required this.sessionId,
  });

  factory ScreencastFrameEvent.fromJson(Map<String, dynamic> json) {
    return ScreencastFrameEvent(
      data: json['data'] as String,
      metadata: ScreencastFrameMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
      sessionId: json['sessionId'] as int,
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

  WindowOpenEvent({
    required this.url,
    required this.windowName,
    required this.windowFeatures,
    required this.userGesture,
  });

  factory WindowOpenEvent.fromJson(Map<String, dynamic> json) {
    return WindowOpenEvent(
      url: json['url'] as String,
      windowName: json['windowName'] as String,
      windowFeatures: (json['windowFeatures'] as List)
          .map((e) => e as String)
          .toList(),
      userGesture: json['userGesture'] as bool? ?? false,
    );
  }
}

class CompilationCacheProducedEvent {
  final String url;

  /// Base64-encoded data
  final String data;

  CompilationCacheProducedEvent({required this.url, required this.data});

  factory CompilationCacheProducedEvent.fromJson(Map<String, dynamic> json) {
    return CompilationCacheProducedEvent(
      url: json['url'] as String,
      data: json['data'] as String,
    );
  }
}

class GetAppManifestResult {
  /// Manifest location.
  final String url;

  final List<AppManifestError> errors;

  /// Manifest content.
  final String? data;

  final WebAppManifest manifest;

  GetAppManifestResult({
    required this.url,
    required this.errors,
    this.data,
    required this.manifest,
  });

  factory GetAppManifestResult.fromJson(Map<String, dynamic> json) {
    return GetAppManifestResult(
      url: json['url'] as String,
      errors: (json['errors'] as List)
          .map((e) => AppManifestError.fromJson(e as Map<String, dynamic>))
          .toList(),
      data: json.containsKey('data') ? json['data'] as String : null,
      manifest: WebAppManifest.fromJson(
        json['manifest'] as Map<String, dynamic>,
      ),
    );
  }
}

class GetAppIdResult {
  /// App id, either from manifest's id attribute or computed from start_url
  final String? appId;

  /// Recommendation for manifest's id attribute to match current id computed from start_url
  final String? recommendedId;

  GetAppIdResult({this.appId, this.recommendedId});

  factory GetAppIdResult.fromJson(Map<String, dynamic> json) {
    return GetAppIdResult(
      appId: json.containsKey('appId') ? json['appId'] as String : null,
      recommendedId: json.containsKey('recommendedId')
          ? json['recommendedId'] as String
          : null,
    );
  }
}

class GetLayoutMetricsResult {
  /// Metrics relating to the layout viewport in CSS pixels.
  final LayoutViewport cssLayoutViewport;

  /// Metrics relating to the visual viewport in CSS pixels.
  final VisualViewport cssVisualViewport;

  /// Size of scrollable area in CSS pixels.
  final dom.Rect cssContentSize;

  GetLayoutMetricsResult({
    required this.cssLayoutViewport,
    required this.cssVisualViewport,
    required this.cssContentSize,
  });

  factory GetLayoutMetricsResult.fromJson(Map<String, dynamic> json) {
    return GetLayoutMetricsResult(
      cssLayoutViewport: LayoutViewport.fromJson(
        json['cssLayoutViewport'] as Map<String, dynamic>,
      ),
      cssVisualViewport: VisualViewport.fromJson(
        json['cssVisualViewport'] as Map<String, dynamic>,
      ),
      cssContentSize: dom.Rect.fromJson(
        json['cssContentSize'] as Map<String, dynamic>,
      ),
    );
  }
}

class GetNavigationHistoryResult {
  /// Index of the current navigation history entry.
  final int currentIndex;

  /// Array of navigation history entries.
  final List<NavigationEntry> entries;

  GetNavigationHistoryResult({
    required this.currentIndex,
    required this.entries,
  });

  factory GetNavigationHistoryResult.fromJson(Map<String, dynamic> json) {
    return GetNavigationHistoryResult(
      currentIndex: json['currentIndex'] as int,
      entries: (json['entries'] as List)
          .map((e) => NavigationEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GetResourceContentResult {
  /// Resource content.
  final String content;

  /// True, if content was served as base64.
  final bool base64Encoded;

  GetResourceContentResult({
    required this.content,
    required this.base64Encoded,
  });

  factory GetResourceContentResult.fromJson(Map<String, dynamic> json) {
    return GetResourceContentResult(
      content: json['content'] as String,
      base64Encoded: json['base64Encoded'] as bool? ?? false,
    );
  }
}

class NavigateResult {
  /// Frame id that has navigated (or failed to navigate)
  final FrameId frameId;

  /// Loader identifier. This is omitted in case of same-document navigation,
  /// as the previously committed loaderId would not change.
  final network.LoaderId? loaderId;

  /// User friendly error message, present if and only if navigation has failed.
  final String? errorText;

  NavigateResult({required this.frameId, this.loaderId, this.errorText});

  factory NavigateResult.fromJson(Map<String, dynamic> json) {
    return NavigateResult(
      frameId: FrameId.fromJson(json['frameId'] as String),
      loaderId: json.containsKey('loaderId')
          ? network.LoaderId.fromJson(json['loaderId'] as String)
          : null,
      errorText: json.containsKey('errorText')
          ? json['errorText'] as String
          : null,
    );
  }
}

class PrintToPDFResult {
  /// Base64-encoded pdf data. Empty if |returnAsStream| is specified.
  final String data;

  /// A handle of the stream that holds resulting PDF data.
  final io.StreamHandle? stream;

  PrintToPDFResult({required this.data, this.stream});

  factory PrintToPDFResult.fromJson(Map<String, dynamic> json) {
    return PrintToPDFResult(
      data: json['data'] as String,
      stream: json.containsKey('stream')
          ? io.StreamHandle.fromJson(json['stream'] as String)
          : null,
    );
  }
}

/// Unique frame identifier.
extension type FrameId(String value) {
  factory FrameId.fromJson(String value) => FrameId(value);

  String toJson() => value;
}

/// Indicates whether a frame has been identified as an ad.
enum AdFrameType {
  none('none'),
  child('child'),
  root('root');

  final String value;

  const AdFrameType(this.value);

  factory AdFrameType.fromJson(String value) =>
      AdFrameType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum AdFrameExplanation {
  parentIsAd('ParentIsAd'),
  createdByAdScript('CreatedByAdScript'),
  matchedBlockingRule('MatchedBlockingRule');

  final String value;

  const AdFrameExplanation(this.value);

  factory AdFrameExplanation.fromJson(String value) =>
      AdFrameExplanation.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Indicates whether a frame has been identified as an ad and why.
class AdFrameStatus {
  final AdFrameType adFrameType;

  final List<AdFrameExplanation>? explanations;

  AdFrameStatus({required this.adFrameType, this.explanations});

  factory AdFrameStatus.fromJson(Map<String, dynamic> json) {
    return AdFrameStatus(
      adFrameType: AdFrameType.fromJson(json['adFrameType'] as String),
      explanations: json.containsKey('explanations')
          ? (json['explanations'] as List)
                .map((e) => AdFrameExplanation.fromJson(e as String))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adFrameType': adFrameType.toJson(),
      if (explanations != null)
        'explanations': explanations!.map((e) => e.toJson()).toList(),
    };
  }
}

/// Identifies the bottom-most script which caused the frame to be labelled
/// as an ad.
class AdScriptId {
  /// Script Id of the bottom-most script which caused the frame to be labelled
  /// as an ad.
  final runtime.ScriptId scriptId;

  /// Id of adScriptId's debugger.
  final runtime.UniqueDebuggerId debuggerId;

  AdScriptId({required this.scriptId, required this.debuggerId});

  factory AdScriptId.fromJson(Map<String, dynamic> json) {
    return AdScriptId(
      scriptId: runtime.ScriptId.fromJson(json['scriptId'] as String),
      debuggerId: runtime.UniqueDebuggerId.fromJson(
        json['debuggerId'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'scriptId': scriptId.toJson(), 'debuggerId': debuggerId.toJson()};
  }
}

/// Indicates whether the frame is a secure context and why it is the case.
enum SecureContextType {
  secure('Secure'),
  secureLocalhost('SecureLocalhost'),
  insecureScheme('InsecureScheme'),
  insecureAncestor('InsecureAncestor');

  final String value;

  const SecureContextType(this.value);

  factory SecureContextType.fromJson(String value) =>
      SecureContextType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Indicates whether the frame is cross-origin isolated and why it is the case.
enum CrossOriginIsolatedContextType {
  isolated('Isolated'),
  notIsolated('NotIsolated'),
  notIsolatedFeatureDisabled('NotIsolatedFeatureDisabled');

  final String value;

  const CrossOriginIsolatedContextType(this.value);

  factory CrossOriginIsolatedContextType.fromJson(String value) =>
      CrossOriginIsolatedContextType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum GatedAPIFeatures {
  sharedArrayBuffers('SharedArrayBuffers'),
  sharedArrayBuffersTransferAllowed('SharedArrayBuffersTransferAllowed'),
  performanceMeasureMemory('PerformanceMeasureMemory'),
  performanceProfile('PerformanceProfile');

  final String value;

  const GatedAPIFeatures(this.value);

  factory GatedAPIFeatures.fromJson(String value) =>
      GatedAPIFeatures.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// All Permissions Policy features. This enum should match the one defined
/// in services/network/public/cpp/permissions_policy/permissions_policy_features.json5.
/// LINT.IfChange(PermissionsPolicyFeature)
enum PermissionsPolicyFeature {
  accelerometer('accelerometer'),
  allScreensCapture('all-screens-capture'),
  ambientLightSensor('ambient-light-sensor'),
  attributionReporting('attribution-reporting'),
  autoplay('autoplay'),
  bluetooth('bluetooth'),
  browsingTopics('browsing-topics'),
  camera('camera'),
  capturedSurfaceControl('captured-surface-control'),
  chDpr('ch-dpr'),
  chDeviceMemory('ch-device-memory'),
  chDownlink('ch-downlink'),
  chEct('ch-ect'),
  chPrefersColorScheme('ch-prefers-color-scheme'),
  chPrefersReducedMotion('ch-prefers-reduced-motion'),
  chPrefersReducedTransparency('ch-prefers-reduced-transparency'),
  chRtt('ch-rtt'),
  chSaveData('ch-save-data'),
  chUa('ch-ua'),
  chUaArch('ch-ua-arch'),
  chUaBitness('ch-ua-bitness'),
  chUaHighEntropyValues('ch-ua-high-entropy-values'),
  chUaPlatform('ch-ua-platform'),
  chUaModel('ch-ua-model'),
  chUaMobile('ch-ua-mobile'),
  chUaFormFactors('ch-ua-form-factors'),
  chUaFullVersion('ch-ua-full-version'),
  chUaFullVersionList('ch-ua-full-version-list'),
  chUaPlatformVersion('ch-ua-platform-version'),
  chUaWow64('ch-ua-wow64'),
  chViewportHeight('ch-viewport-height'),
  chViewportWidth('ch-viewport-width'),
  chWidth('ch-width'),
  clipboardRead('clipboard-read'),
  clipboardWrite('clipboard-write'),
  computePressure('compute-pressure'),
  controlledFrame('controlled-frame'),
  crossOriginIsolated('cross-origin-isolated'),
  deferredFetch('deferred-fetch'),
  deferredFetchMinimal('deferred-fetch-minimal'),
  deviceAttributes('device-attributes'),
  digitalCredentialsGet('digital-credentials-get'),
  directSockets('direct-sockets'),
  directSocketsPrivate('direct-sockets-private'),
  displayCapture('display-capture'),
  documentDomain('document-domain'),
  encryptedMedia('encrypted-media'),
  executionWhileOutOfViewport('execution-while-out-of-viewport'),
  executionWhileNotRendered('execution-while-not-rendered'),
  fencedUnpartitionedStorageRead('fenced-unpartitioned-storage-read'),
  focusWithoutUserActivation('focus-without-user-activation'),
  fullscreen('fullscreen'),
  frobulate('frobulate'),
  gamepad('gamepad'),
  geolocation('geolocation'),
  gyroscope('gyroscope'),
  hid('hid'),
  identityCredentialsGet('identity-credentials-get'),
  idleDetection('idle-detection'),
  interestCohort('interest-cohort'),
  joinAdInterestGroup('join-ad-interest-group'),
  keyboardMap('keyboard-map'),
  languageDetector('language-detector'),
  localFonts('local-fonts'),
  localNetworkAccess('local-network-access'),
  magnetometer('magnetometer'),
  mediaPlaybackWhileNotVisible('media-playback-while-not-visible'),
  microphone('microphone'),
  midi('midi'),
  onDeviceSpeechRecognition('on-device-speech-recognition'),
  otpCredentials('otp-credentials'),
  payment('payment'),
  pictureInPicture('picture-in-picture'),
  popins('popins'),
  privateAggregation('private-aggregation'),
  privateStateTokenIssuance('private-state-token-issuance'),
  privateStateTokenRedemption('private-state-token-redemption'),
  publickeyCredentialsCreate('publickey-credentials-create'),
  publickeyCredentialsGet('publickey-credentials-get'),
  recordAdAuctionEvents('record-ad-auction-events'),
  rewriter('rewriter'),
  runAdAuction('run-ad-auction'),
  screenWakeLock('screen-wake-lock'),
  serial('serial'),
  sharedAutofill('shared-autofill'),
  sharedStorage('shared-storage'),
  sharedStorageSelectUrl('shared-storage-select-url'),
  smartCard('smart-card'),
  speakerSelection('speaker-selection'),
  storageAccess('storage-access'),
  subApps('sub-apps'),
  summarizer('summarizer'),
  syncXhr('sync-xhr'),
  translator('translator'),
  unload('unload'),
  usb('usb'),
  usbUnrestricted('usb-unrestricted'),
  verticalScroll('vertical-scroll'),
  webAppInstallation('web-app-installation'),
  webPrinting('web-printing'),
  webShare('web-share'),
  windowManagement('window-management'),
  writer('writer'),
  xrSpatialTracking('xr-spatial-tracking');

  final String value;

  const PermissionsPolicyFeature(this.value);

  factory PermissionsPolicyFeature.fromJson(String value) =>
      PermissionsPolicyFeature.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Reason for a permissions policy feature to be disabled.
enum PermissionsPolicyBlockReason {
  header('Header'),
  iframeAttribute('IframeAttribute'),
  inFencedFrameTree('InFencedFrameTree'),
  inIsolatedApp('InIsolatedApp');

  final String value;

  const PermissionsPolicyBlockReason(this.value);

  factory PermissionsPolicyBlockReason.fromJson(String value) =>
      PermissionsPolicyBlockReason.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class PermissionsPolicyBlockLocator {
  final FrameId frameId;

  final PermissionsPolicyBlockReason blockReason;

  PermissionsPolicyBlockLocator({
    required this.frameId,
    required this.blockReason,
  });

  factory PermissionsPolicyBlockLocator.fromJson(Map<String, dynamic> json) {
    return PermissionsPolicyBlockLocator(
      frameId: FrameId.fromJson(json['frameId'] as String),
      blockReason: PermissionsPolicyBlockReason.fromJson(
        json['blockReason'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'frameId': frameId.toJson(), 'blockReason': blockReason.toJson()};
  }
}

class PermissionsPolicyFeatureState {
  final PermissionsPolicyFeature feature;

  final bool allowed;

  final PermissionsPolicyBlockLocator? locator;

  PermissionsPolicyFeatureState({
    required this.feature,
    required this.allowed,
    this.locator,
  });

  factory PermissionsPolicyFeatureState.fromJson(Map<String, dynamic> json) {
    return PermissionsPolicyFeatureState(
      feature: PermissionsPolicyFeature.fromJson(json['feature'] as String),
      allowed: json['allowed'] as bool? ?? false,
      locator: json.containsKey('locator')
          ? PermissionsPolicyBlockLocator.fromJson(
              json['locator'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feature': feature.toJson(),
      'allowed': allowed,
      if (locator != null) 'locator': locator!.toJson(),
    };
  }
}

/// Origin Trial(https://www.chromium.org/blink/origin-trials) support.
/// Status for an Origin Trial token.
enum OriginTrialTokenStatus {
  success('Success'),
  notSupported('NotSupported'),
  insecure('Insecure'),
  expired('Expired'),
  wrongOrigin('WrongOrigin'),
  invalidSignature('InvalidSignature'),
  malformed('Malformed'),
  wrongVersion('WrongVersion'),
  featureDisabled('FeatureDisabled'),
  tokenDisabled('TokenDisabled'),
  featureDisabledForUser('FeatureDisabledForUser'),
  unknownTrial('UnknownTrial');

  final String value;

  const OriginTrialTokenStatus(this.value);

  factory OriginTrialTokenStatus.fromJson(String value) =>
      OriginTrialTokenStatus.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Status for an Origin Trial.
enum OriginTrialStatus {
  enabled('Enabled'),
  validTokenNotProvided('ValidTokenNotProvided'),
  osNotSupported('OSNotSupported'),
  trialNotAllowed('TrialNotAllowed');

  final String value;

  const OriginTrialStatus(this.value);

  factory OriginTrialStatus.fromJson(String value) =>
      OriginTrialStatus.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum OriginTrialUsageRestriction {
  none('None'),
  subset('Subset');

  final String value;

  const OriginTrialUsageRestriction(this.value);

  factory OriginTrialUsageRestriction.fromJson(String value) =>
      OriginTrialUsageRestriction.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class OriginTrialToken {
  final String origin;

  final bool matchSubDomains;

  final String trialName;

  final network.TimeSinceEpoch expiryTime;

  final bool isThirdParty;

  final OriginTrialUsageRestriction usageRestriction;

  OriginTrialToken({
    required this.origin,
    required this.matchSubDomains,
    required this.trialName,
    required this.expiryTime,
    required this.isThirdParty,
    required this.usageRestriction,
  });

  factory OriginTrialToken.fromJson(Map<String, dynamic> json) {
    return OriginTrialToken(
      origin: json['origin'] as String,
      matchSubDomains: json['matchSubDomains'] as bool? ?? false,
      trialName: json['trialName'] as String,
      expiryTime: network.TimeSinceEpoch.fromJson(json['expiryTime'] as num),
      isThirdParty: json['isThirdParty'] as bool? ?? false,
      usageRestriction: OriginTrialUsageRestriction.fromJson(
        json['usageRestriction'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'origin': origin,
      'matchSubDomains': matchSubDomains,
      'trialName': trialName,
      'expiryTime': expiryTime.toJson(),
      'isThirdParty': isThirdParty,
      'usageRestriction': usageRestriction.toJson(),
    };
  }
}

class OriginTrialTokenWithStatus {
  final String rawTokenText;

  /// `parsedToken` is present only when the token is extractable and
  /// parsable.
  final OriginTrialToken? parsedToken;

  final OriginTrialTokenStatus status;

  OriginTrialTokenWithStatus({
    required this.rawTokenText,
    this.parsedToken,
    required this.status,
  });

  factory OriginTrialTokenWithStatus.fromJson(Map<String, dynamic> json) {
    return OriginTrialTokenWithStatus(
      rawTokenText: json['rawTokenText'] as String,
      parsedToken: json.containsKey('parsedToken')
          ? OriginTrialToken.fromJson(
              json['parsedToken'] as Map<String, dynamic>,
            )
          : null,
      status: OriginTrialTokenStatus.fromJson(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rawTokenText': rawTokenText,
      'status': status.toJson(),
      if (parsedToken != null) 'parsedToken': parsedToken!.toJson(),
    };
  }
}

class OriginTrial {
  final String trialName;

  final OriginTrialStatus status;

  final List<OriginTrialTokenWithStatus> tokensWithStatus;

  OriginTrial({
    required this.trialName,
    required this.status,
    required this.tokensWithStatus,
  });

  factory OriginTrial.fromJson(Map<String, dynamic> json) {
    return OriginTrial(
      trialName: json['trialName'] as String,
      status: OriginTrialStatus.fromJson(json['status'] as String),
      tokensWithStatus: (json['tokensWithStatus'] as List)
          .map(
            (e) =>
                OriginTrialTokenWithStatus.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trialName': trialName,
      'status': status.toJson(),
      'tokensWithStatus': tokensWithStatus.map((e) => e.toJson()).toList(),
    };
  }
}

/// Additional information about the frame document's security origin.
class SecurityOriginDetails {
  /// Indicates whether the frame document's security origin is one
  /// of the local hostnames (e.g. "localhost") or IP addresses (IPv4
  /// 127.0.0.0/8 or IPv6 ::1).
  final bool isLocalhost;

  SecurityOriginDetails({required this.isLocalhost});

  factory SecurityOriginDetails.fromJson(Map<String, dynamic> json) {
    return SecurityOriginDetails(
      isLocalhost: json['isLocalhost'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'isLocalhost': isLocalhost};
  }
}

/// Information about the Frame on the page.
class FrameInfo {
  /// Frame unique identifier.
  final FrameId id;

  /// Parent frame identifier.
  final FrameId? parentId;

  /// Identifier of the loader associated with this frame.
  final network.LoaderId loaderId;

  /// Frame's name as specified in the tag.
  final String? name;

  /// Frame document's URL without fragment.
  final String url;

  /// Frame document's URL fragment including the '#'.
  final String? urlFragment;

  /// Frame document's registered domain, taking the public suffixes list into account.
  /// Extracted from the Frame's url.
  /// Example URLs: http://www.google.com/file.html -> "google.com"
  ///               http://a.b.co.uk/file.html      -> "b.co.uk"
  final String domainAndRegistry;

  /// Frame document's security origin.
  final String securityOrigin;

  /// Additional details about the frame document's security origin.
  final SecurityOriginDetails? securityOriginDetails;

  /// Frame document's mimeType as determined by the browser.
  final String mimeType;

  /// If the frame failed to load, this contains the URL that could not be loaded. Note that unlike url above, this URL may contain a fragment.
  final String? unreachableUrl;

  /// Indicates whether this frame was tagged as an ad and why.
  final AdFrameStatus? adFrameStatus;

  /// Indicates whether the main document is a secure context and explains why that is the case.
  final SecureContextType secureContextType;

  /// Indicates whether this is a cross origin isolated context.
  final CrossOriginIsolatedContextType crossOriginIsolatedContextType;

  /// Indicated which gated APIs / features are available.
  final List<GatedAPIFeatures> gatedAPIFeatures;

  FrameInfo({
    required this.id,
    this.parentId,
    required this.loaderId,
    this.name,
    required this.url,
    this.urlFragment,
    required this.domainAndRegistry,
    required this.securityOrigin,
    this.securityOriginDetails,
    required this.mimeType,
    this.unreachableUrl,
    this.adFrameStatus,
    required this.secureContextType,
    required this.crossOriginIsolatedContextType,
    required this.gatedAPIFeatures,
  });

  factory FrameInfo.fromJson(Map<String, dynamic> json) {
    return FrameInfo(
      id: FrameId.fromJson(json['id'] as String),
      parentId: json.containsKey('parentId')
          ? FrameId.fromJson(json['parentId'] as String)
          : null,
      loaderId: network.LoaderId.fromJson(json['loaderId'] as String),
      name: json.containsKey('name') ? json['name'] as String : null,
      url: json['url'] as String,
      urlFragment: json.containsKey('urlFragment')
          ? json['urlFragment'] as String
          : null,
      domainAndRegistry: json['domainAndRegistry'] as String,
      securityOrigin: json['securityOrigin'] as String,
      securityOriginDetails: json.containsKey('securityOriginDetails')
          ? SecurityOriginDetails.fromJson(
              json['securityOriginDetails'] as Map<String, dynamic>,
            )
          : null,
      mimeType: json['mimeType'] as String,
      unreachableUrl: json.containsKey('unreachableUrl')
          ? json['unreachableUrl'] as String
          : null,
      adFrameStatus: json.containsKey('adFrameStatus')
          ? AdFrameStatus.fromJson(
              json['adFrameStatus'] as Map<String, dynamic>,
            )
          : null,
      secureContextType: SecureContextType.fromJson(
        json['secureContextType'] as String,
      ),
      crossOriginIsolatedContextType: CrossOriginIsolatedContextType.fromJson(
        json['crossOriginIsolatedContextType'] as String,
      ),
      gatedAPIFeatures: (json['gatedAPIFeatures'] as List)
          .map((e) => GatedAPIFeatures.fromJson(e as String))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toJson(),
      'loaderId': loaderId.toJson(),
      'url': url,
      'domainAndRegistry': domainAndRegistry,
      'securityOrigin': securityOrigin,
      'mimeType': mimeType,
      'secureContextType': secureContextType.toJson(),
      'crossOriginIsolatedContextType': crossOriginIsolatedContextType.toJson(),
      'gatedAPIFeatures': gatedAPIFeatures.map((e) => e.toJson()).toList(),
      if (parentId != null) 'parentId': parentId!.toJson(),
      if (name != null) 'name': name,
      if (urlFragment != null) 'urlFragment': urlFragment,
      if (securityOriginDetails != null)
        'securityOriginDetails': securityOriginDetails!.toJson(),
      if (unreachableUrl != null) 'unreachableUrl': unreachableUrl,
      if (adFrameStatus != null) 'adFrameStatus': adFrameStatus!.toJson(),
    };
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
  final network.TimeSinceEpoch? lastModified;

  /// Resource content size.
  final num? contentSize;

  /// True if the resource failed to load.
  final bool? failed;

  /// True if the resource was canceled during loading.
  final bool? canceled;

  FrameResource({
    required this.url,
    required this.type,
    required this.mimeType,
    this.lastModified,
    this.contentSize,
    this.failed,
    this.canceled,
  });

  factory FrameResource.fromJson(Map<String, dynamic> json) {
    return FrameResource(
      url: json['url'] as String,
      type: network.ResourceType.fromJson(json['type'] as String),
      mimeType: json['mimeType'] as String,
      lastModified: json.containsKey('lastModified')
          ? network.TimeSinceEpoch.fromJson(json['lastModified'] as num)
          : null,
      contentSize: json.containsKey('contentSize')
          ? json['contentSize'] as num
          : null,
      failed: json.containsKey('failed') ? json['failed'] as bool : null,
      canceled: json.containsKey('canceled') ? json['canceled'] as bool : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'type': type.toJson(),
      'mimeType': mimeType,
      if (lastModified != null) 'lastModified': lastModified!.toJson(),
      if (contentSize != null) 'contentSize': contentSize,
      if (failed != null) 'failed': failed,
      if (canceled != null) 'canceled': canceled,
    };
  }
}

/// Information about the Frame hierarchy along with their cached resources.
class FrameResourceTree {
  /// Frame information for this tree item.
  final FrameInfo frame;

  /// Child frames.
  final List<FrameResourceTree>? childFrames;

  /// Information about frame resources.
  final List<FrameResource> resources;

  FrameResourceTree({
    required this.frame,
    this.childFrames,
    required this.resources,
  });

  factory FrameResourceTree.fromJson(Map<String, dynamic> json) {
    return FrameResourceTree(
      frame: FrameInfo.fromJson(json['frame'] as Map<String, dynamic>),
      childFrames: json.containsKey('childFrames')
          ? (json['childFrames'] as List)
                .map(
                  (e) => FrameResourceTree.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      resources: (json['resources'] as List)
          .map((e) => FrameResource.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frame': frame.toJson(),
      'resources': resources.map((e) => e.toJson()).toList(),
      if (childFrames != null)
        'childFrames': childFrames!.map((e) => e.toJson()).toList(),
    };
  }
}

/// Information about the Frame hierarchy.
class FrameTree {
  /// Frame information for this tree item.
  final FrameInfo frame;

  /// Child frames.
  final List<FrameTree>? childFrames;

  FrameTree({required this.frame, this.childFrames});

  factory FrameTree.fromJson(Map<String, dynamic> json) {
    return FrameTree(
      frame: FrameInfo.fromJson(json['frame'] as Map<String, dynamic>),
      childFrames: json.containsKey('childFrames')
          ? (json['childFrames'] as List)
                .map((e) => FrameTree.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frame': frame.toJson(),
      if (childFrames != null)
        'childFrames': childFrames!.map((e) => e.toJson()).toList(),
    };
  }
}

/// Unique script identifier.
extension type ScriptIdentifier(String value) {
  factory ScriptIdentifier.fromJson(String value) => ScriptIdentifier(value);

  String toJson() => value;
}

/// Transition type.
enum TransitionType {
  link('link'),
  typed('typed'),
  addressBar('address_bar'),
  autoBookmark('auto_bookmark'),
  autoSubframe('auto_subframe'),
  manualSubframe('manual_subframe'),
  generated('generated'),
  autoToplevel('auto_toplevel'),
  formSubmit('form_submit'),
  reload('reload'),
  keyword('keyword'),
  keywordGenerated('keyword_generated'),
  other('other');

  final String value;

  const TransitionType(this.value);

  factory TransitionType.fromJson(String value) =>
      TransitionType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

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

  NavigationEntry({
    required this.id,
    required this.url,
    required this.userTypedURL,
    required this.title,
    required this.transitionType,
  });

  factory NavigationEntry.fromJson(Map<String, dynamic> json) {
    return NavigationEntry(
      id: json['id'] as int,
      url: json['url'] as String,
      userTypedURL: json['userTypedURL'] as String,
      title: json['title'] as String,
      transitionType: TransitionType.fromJson(json['transitionType'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'userTypedURL': userTypedURL,
      'title': title,
      'transitionType': transitionType.toJson(),
    };
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
  final network.TimeSinceEpoch? timestamp;

  ScreencastFrameMetadata({
    required this.offsetTop,
    required this.pageScaleFactor,
    required this.deviceWidth,
    required this.deviceHeight,
    required this.scrollOffsetX,
    required this.scrollOffsetY,
    this.timestamp,
  });

  factory ScreencastFrameMetadata.fromJson(Map<String, dynamic> json) {
    return ScreencastFrameMetadata(
      offsetTop: json['offsetTop'] as num,
      pageScaleFactor: json['pageScaleFactor'] as num,
      deviceWidth: json['deviceWidth'] as num,
      deviceHeight: json['deviceHeight'] as num,
      scrollOffsetX: json['scrollOffsetX'] as num,
      scrollOffsetY: json['scrollOffsetY'] as num,
      timestamp: json.containsKey('timestamp')
          ? network.TimeSinceEpoch.fromJson(json['timestamp'] as num)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offsetTop': offsetTop,
      'pageScaleFactor': pageScaleFactor,
      'deviceWidth': deviceWidth,
      'deviceHeight': deviceHeight,
      'scrollOffsetX': scrollOffsetX,
      'scrollOffsetY': scrollOffsetY,
      if (timestamp != null) 'timestamp': timestamp!.toJson(),
    };
  }
}

/// Javascript dialog type.
enum DialogType {
  alert('alert'),
  confirm('confirm'),
  prompt('prompt'),
  beforeunload('beforeunload');

  final String value;

  const DialogType(this.value);

  factory DialogType.fromJson(String value) =>
      DialogType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Error while paring app manifest.
class AppManifestError {
  /// Error message.
  final String message;

  /// If critical, this is a non-recoverable parse error.
  final int critical;

  /// Error line.
  final int line;

  /// Error column.
  final int column;

  AppManifestError({
    required this.message,
    required this.critical,
    required this.line,
    required this.column,
  });

  factory AppManifestError.fromJson(Map<String, dynamic> json) {
    return AppManifestError(
      message: json['message'] as String,
      critical: json['critical'] as int,
      line: json['line'] as int,
      column: json['column'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'critical': critical,
      'line': line,
      'column': column,
    };
  }
}

/// Parsed app manifest properties.
class AppManifestParsedProperties {
  /// Computed scope value
  final String scope;

  AppManifestParsedProperties({required this.scope});

  factory AppManifestParsedProperties.fromJson(Map<String, dynamic> json) {
    return AppManifestParsedProperties(scope: json['scope'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'scope': scope};
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

  LayoutViewport({
    required this.pageX,
    required this.pageY,
    required this.clientWidth,
    required this.clientHeight,
  });

  factory LayoutViewport.fromJson(Map<String, dynamic> json) {
    return LayoutViewport(
      pageX: json['pageX'] as int,
      pageY: json['pageY'] as int,
      clientWidth: json['clientWidth'] as int,
      clientHeight: json['clientHeight'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageX': pageX,
      'pageY': pageY,
      'clientWidth': clientWidth,
      'clientHeight': clientHeight,
    };
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
  final num? zoom;

  VisualViewport({
    required this.offsetX,
    required this.offsetY,
    required this.pageX,
    required this.pageY,
    required this.clientWidth,
    required this.clientHeight,
    required this.scale,
    this.zoom,
  });

  factory VisualViewport.fromJson(Map<String, dynamic> json) {
    return VisualViewport(
      offsetX: json['offsetX'] as num,
      offsetY: json['offsetY'] as num,
      pageX: json['pageX'] as num,
      pageY: json['pageY'] as num,
      clientWidth: json['clientWidth'] as num,
      clientHeight: json['clientHeight'] as num,
      scale: json['scale'] as num,
      zoom: json.containsKey('zoom') ? json['zoom'] as num : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offsetX': offsetX,
      'offsetY': offsetY,
      'pageX': pageX,
      'pageY': pageY,
      'clientWidth': clientWidth,
      'clientHeight': clientHeight,
      'scale': scale,
      if (zoom != null) 'zoom': zoom,
    };
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

  Viewport({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.scale,
  });

  factory Viewport.fromJson(Map<String, dynamic> json) {
    return Viewport(
      x: json['x'] as num,
      y: json['y'] as num,
      width: json['width'] as num,
      height: json['height'] as num,
      scale: json['scale'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y, 'width': width, 'height': height, 'scale': scale};
  }
}

/// Generic font families collection.
class FontFamilies {
  /// The standard font-family.
  final String? standard;

  /// The fixed font-family.
  final String? fixed;

  /// The serif font-family.
  final String? serif;

  /// The sansSerif font-family.
  final String? sansSerif;

  /// The cursive font-family.
  final String? cursive;

  /// The fantasy font-family.
  final String? fantasy;

  /// The math font-family.
  final String? math;

  FontFamilies({
    this.standard,
    this.fixed,
    this.serif,
    this.sansSerif,
    this.cursive,
    this.fantasy,
    this.math,
  });

  factory FontFamilies.fromJson(Map<String, dynamic> json) {
    return FontFamilies(
      standard: json.containsKey('standard')
          ? json['standard'] as String
          : null,
      fixed: json.containsKey('fixed') ? json['fixed'] as String : null,
      serif: json.containsKey('serif') ? json['serif'] as String : null,
      sansSerif: json.containsKey('sansSerif')
          ? json['sansSerif'] as String
          : null,
      cursive: json.containsKey('cursive') ? json['cursive'] as String : null,
      fantasy: json.containsKey('fantasy') ? json['fantasy'] as String : null,
      math: json.containsKey('math') ? json['math'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (standard != null) 'standard': standard,
      if (fixed != null) 'fixed': fixed,
      if (serif != null) 'serif': serif,
      if (sansSerif != null) 'sansSerif': sansSerif,
      if (cursive != null) 'cursive': cursive,
      if (fantasy != null) 'fantasy': fantasy,
      if (math != null) 'math': math,
    };
  }
}

/// Font families collection for a script.
class ScriptFontFamilies {
  /// Name of the script which these font families are defined for.
  final String script;

  /// Generic font families collection for the script.
  final FontFamilies fontFamilies;

  ScriptFontFamilies({required this.script, required this.fontFamilies});

  factory ScriptFontFamilies.fromJson(Map<String, dynamic> json) {
    return ScriptFontFamilies(
      script: json['script'] as String,
      fontFamilies: FontFamilies.fromJson(
        json['fontFamilies'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'script': script, 'fontFamilies': fontFamilies.toJson()};
  }
}

/// Default font sizes.
class FontSizes {
  /// Default standard font size.
  final int? standard;

  /// Default fixed font size.
  final int? fixed;

  FontSizes({this.standard, this.fixed});

  factory FontSizes.fromJson(Map<String, dynamic> json) {
    return FontSizes(
      standard: json.containsKey('standard') ? json['standard'] as int : null,
      fixed: json.containsKey('fixed') ? json['fixed'] as int : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (standard != null) 'standard': standard,
      if (fixed != null) 'fixed': fixed,
    };
  }
}

enum ClientNavigationReason {
  anchorClick('anchorClick'),
  formSubmissionGet('formSubmissionGet'),
  formSubmissionPost('formSubmissionPost'),
  httpHeaderRefresh('httpHeaderRefresh'),
  initialFrameNavigation('initialFrameNavigation'),
  metaTagRefresh('metaTagRefresh'),
  other('other'),
  pageBlockInterstitial('pageBlockInterstitial'),
  reload('reload'),
  scriptInitiated('scriptInitiated');

  final String value;

  const ClientNavigationReason(this.value);

  factory ClientNavigationReason.fromJson(String value) =>
      ClientNavigationReason.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum ClientNavigationDisposition {
  currentTab('currentTab'),
  newTab('newTab'),
  newWindow('newWindow'),
  download('download');

  final String value;

  const ClientNavigationDisposition(this.value);

  factory ClientNavigationDisposition.fromJson(String value) =>
      ClientNavigationDisposition.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class InstallabilityErrorArgument {
  /// Argument name (e.g. name:'minimum-icon-size-in-pixels').
  final String name;

  /// Argument value (e.g. value:'64').
  final String value;

  InstallabilityErrorArgument({required this.name, required this.value});

  factory InstallabilityErrorArgument.fromJson(Map<String, dynamic> json) {
    return InstallabilityErrorArgument(
      name: json['name'] as String,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'value': value};
  }
}

/// The installability error
class InstallabilityError {
  /// The error id (e.g. 'manifest-missing-suitable-icon').
  final String errorId;

  /// The list of error arguments (e.g. {name:'minimum-icon-size-in-pixels', value:'64'}).
  final List<InstallabilityErrorArgument> errorArguments;

  InstallabilityError({required this.errorId, required this.errorArguments});

  factory InstallabilityError.fromJson(Map<String, dynamic> json) {
    return InstallabilityError(
      errorId: json['errorId'] as String,
      errorArguments: (json['errorArguments'] as List)
          .map(
            (e) =>
                InstallabilityErrorArgument.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'errorId': errorId,
      'errorArguments': errorArguments.map((e) => e.toJson()).toList(),
    };
  }
}

/// The referring-policy used for the navigation.
enum ReferrerPolicy {
  noReferrer('noReferrer'),
  noReferrerWhenDowngrade('noReferrerWhenDowngrade'),
  origin('origin'),
  originWhenCrossOrigin('originWhenCrossOrigin'),
  sameOrigin('sameOrigin'),
  strictOrigin('strictOrigin'),
  strictOriginWhenCrossOrigin('strictOriginWhenCrossOrigin'),
  unsafeUrl('unsafeUrl');

  final String value;

  const ReferrerPolicy(this.value);

  factory ReferrerPolicy.fromJson(String value) =>
      ReferrerPolicy.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Per-script compilation cache parameters for `Page.produceCompilationCache`
class CompilationCacheParams {
  /// The URL of the script to produce a compilation cache entry for.
  final String url;

  /// A hint to the backend whether eager compilation is recommended.
  /// (the actual compilation mode used is upon backend discretion).
  final bool? eager;

  CompilationCacheParams({required this.url, this.eager});

  factory CompilationCacheParams.fromJson(Map<String, dynamic> json) {
    return CompilationCacheParams(
      url: json['url'] as String,
      eager: json.containsKey('eager') ? json['eager'] as bool : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, if (eager != null) 'eager': eager};
  }
}

class FileFilter {
  final String? name;

  final List<String>? accepts;

  FileFilter({this.name, this.accepts});

  factory FileFilter.fromJson(Map<String, dynamic> json) {
    return FileFilter(
      name: json.containsKey('name') ? json['name'] as String : null,
      accepts: json.containsKey('accepts')
          ? (json['accepts'] as List).map((e) => e as String).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (accepts != null) 'accepts': [...?accepts],
    };
  }
}

class FileHandler {
  final String action;

  final String name;

  final List<ImageResource>? icons;

  /// Mimic a map, name is the key, accepts is the value.
  final List<FileFilter>? accepts;

  /// Won't repeat the enums, using string for easy comparison. Same as the
  /// other enums below.
  final String launchType;

  FileHandler({
    required this.action,
    required this.name,
    this.icons,
    this.accepts,
    required this.launchType,
  });

  factory FileHandler.fromJson(Map<String, dynamic> json) {
    return FileHandler(
      action: json['action'] as String,
      name: json['name'] as String,
      icons: json.containsKey('icons')
          ? (json['icons'] as List)
                .map((e) => ImageResource.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      accepts: json.containsKey('accepts')
          ? (json['accepts'] as List)
                .map((e) => FileFilter.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      launchType: json['launchType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'name': name,
      'launchType': launchType,
      if (icons != null) 'icons': icons!.map((e) => e.toJson()).toList(),
      if (accepts != null) 'accepts': accepts!.map((e) => e.toJson()).toList(),
    };
  }
}

/// The image definition used in both icon and screenshot.
class ImageResource {
  /// The src field in the definition, but changing to url in favor of
  /// consistency.
  final String url;

  final String? sizes;

  final String? type;

  ImageResource({required this.url, this.sizes, this.type});

  factory ImageResource.fromJson(Map<String, dynamic> json) {
    return ImageResource(
      url: json['url'] as String,
      sizes: json.containsKey('sizes') ? json['sizes'] as String : null,
      type: json.containsKey('type') ? json['type'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      if (sizes != null) 'sizes': sizes,
      if (type != null) 'type': type,
    };
  }
}

class LaunchHandler {
  final String clientMode;

  LaunchHandler({required this.clientMode});

  factory LaunchHandler.fromJson(Map<String, dynamic> json) {
    return LaunchHandler(clientMode: json['clientMode'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'clientMode': clientMode};
  }
}

class ProtocolHandler {
  final String protocol;

  final String url;

  ProtocolHandler({required this.protocol, required this.url});

  factory ProtocolHandler.fromJson(Map<String, dynamic> json) {
    return ProtocolHandler(
      protocol: json['protocol'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'protocol': protocol, 'url': url};
  }
}

class RelatedApplication {
  final String? id;

  final String url;

  RelatedApplication({this.id, required this.url});

  factory RelatedApplication.fromJson(Map<String, dynamic> json) {
    return RelatedApplication(
      id: json.containsKey('id') ? json['id'] as String : null,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, if (id != null) 'id': id};
  }
}

class ScopeExtension {
  /// Instead of using tuple, this field always returns the serialized string
  /// for easy understanding and comparison.
  final String origin;

  final bool hasOriginWildcard;

  ScopeExtension({required this.origin, required this.hasOriginWildcard});

  factory ScopeExtension.fromJson(Map<String, dynamic> json) {
    return ScopeExtension(
      origin: json['origin'] as String,
      hasOriginWildcard: json['hasOriginWildcard'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'origin': origin, 'hasOriginWildcard': hasOriginWildcard};
  }
}

class Screenshot {
  final ImageResource image;

  final String formFactor;

  final String? label;

  Screenshot({required this.image, required this.formFactor, this.label});

  factory Screenshot.fromJson(Map<String, dynamic> json) {
    return Screenshot(
      image: ImageResource.fromJson(json['image'] as Map<String, dynamic>),
      formFactor: json['formFactor'] as String,
      label: json.containsKey('label') ? json['label'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image.toJson(),
      'formFactor': formFactor,
      if (label != null) 'label': label,
    };
  }
}

class ShareTarget {
  final String action;

  final String method;

  final String enctype;

  /// Embed the ShareTargetParams
  final String? title;

  final String? text;

  final String? url;

  final List<FileFilter>? files;

  ShareTarget({
    required this.action,
    required this.method,
    required this.enctype,
    this.title,
    this.text,
    this.url,
    this.files,
  });

  factory ShareTarget.fromJson(Map<String, dynamic> json) {
    return ShareTarget(
      action: json['action'] as String,
      method: json['method'] as String,
      enctype: json['enctype'] as String,
      title: json.containsKey('title') ? json['title'] as String : null,
      text: json.containsKey('text') ? json['text'] as String : null,
      url: json.containsKey('url') ? json['url'] as String : null,
      files: json.containsKey('files')
          ? (json['files'] as List)
                .map((e) => FileFilter.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'method': method,
      'enctype': enctype,
      if (title != null) 'title': title,
      if (text != null) 'text': text,
      if (url != null) 'url': url,
      if (files != null) 'files': files!.map((e) => e.toJson()).toList(),
    };
  }
}

class Shortcut {
  final String name;

  final String url;

  Shortcut({required this.name, required this.url});

  factory Shortcut.fromJson(Map<String, dynamic> json) {
    return Shortcut(name: json['name'] as String, url: json['url'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url};
  }
}

class WebAppManifest {
  final String? backgroundColor;

  /// The extra description provided by the manifest.
  final String? description;

  final String? dir;

  final String? display;

  /// The overrided display mode controlled by the user.
  final List<String>? displayOverrides;

  /// The handlers to open files.
  final List<FileHandler>? fileHandlers;

  final List<ImageResource>? icons;

  final String? id;

  final String? lang;

  /// TODO(crbug.com/1231886): This field is non-standard and part of a Chrome
  /// experiment. See:
  /// https://github.com/WICG/web-app-launch/blob/main/launch_handler.md
  final LaunchHandler? launchHandler;

  final String? name;

  final String? orientation;

  final bool? preferRelatedApplications;

  /// The handlers to open protocols.
  final List<ProtocolHandler>? protocolHandlers;

  final List<RelatedApplication>? relatedApplications;

  final String? scope;

  /// Non-standard, see
  /// https://github.com/WICG/manifest-incubations/blob/gh-pages/scope_extensions-explainer.md
  final List<ScopeExtension>? scopeExtensions;

  /// The screenshots used by chromium.
  final List<Screenshot>? screenshots;

  final ShareTarget? shareTarget;

  final String? shortName;

  final List<Shortcut>? shortcuts;

  final String? startUrl;

  final String? themeColor;

  WebAppManifest({
    this.backgroundColor,
    this.description,
    this.dir,
    this.display,
    this.displayOverrides,
    this.fileHandlers,
    this.icons,
    this.id,
    this.lang,
    this.launchHandler,
    this.name,
    this.orientation,
    this.preferRelatedApplications,
    this.protocolHandlers,
    this.relatedApplications,
    this.scope,
    this.scopeExtensions,
    this.screenshots,
    this.shareTarget,
    this.shortName,
    this.shortcuts,
    this.startUrl,
    this.themeColor,
  });

  factory WebAppManifest.fromJson(Map<String, dynamic> json) {
    return WebAppManifest(
      backgroundColor: json.containsKey('backgroundColor')
          ? json['backgroundColor'] as String
          : null,
      description: json.containsKey('description')
          ? json['description'] as String
          : null,
      dir: json.containsKey('dir') ? json['dir'] as String : null,
      display: json.containsKey('display') ? json['display'] as String : null,
      displayOverrides: json.containsKey('displayOverrides')
          ? (json['displayOverrides'] as List).map((e) => e as String).toList()
          : null,
      fileHandlers: json.containsKey('fileHandlers')
          ? (json['fileHandlers'] as List)
                .map((e) => FileHandler.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      icons: json.containsKey('icons')
          ? (json['icons'] as List)
                .map((e) => ImageResource.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      id: json.containsKey('id') ? json['id'] as String : null,
      lang: json.containsKey('lang') ? json['lang'] as String : null,
      launchHandler: json.containsKey('launchHandler')
          ? LaunchHandler.fromJson(
              json['launchHandler'] as Map<String, dynamic>,
            )
          : null,
      name: json.containsKey('name') ? json['name'] as String : null,
      orientation: json.containsKey('orientation')
          ? json['orientation'] as String
          : null,
      preferRelatedApplications: json.containsKey('preferRelatedApplications')
          ? json['preferRelatedApplications'] as bool
          : null,
      protocolHandlers: json.containsKey('protocolHandlers')
          ? (json['protocolHandlers'] as List)
                .map((e) => ProtocolHandler.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      relatedApplications: json.containsKey('relatedApplications')
          ? (json['relatedApplications'] as List)
                .map(
                  (e) => RelatedApplication.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      scope: json.containsKey('scope') ? json['scope'] as String : null,
      scopeExtensions: json.containsKey('scopeExtensions')
          ? (json['scopeExtensions'] as List)
                .map((e) => ScopeExtension.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      screenshots: json.containsKey('screenshots')
          ? (json['screenshots'] as List)
                .map((e) => Screenshot.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      shareTarget: json.containsKey('shareTarget')
          ? ShareTarget.fromJson(json['shareTarget'] as Map<String, dynamic>)
          : null,
      shortName: json.containsKey('shortName')
          ? json['shortName'] as String
          : null,
      shortcuts: json.containsKey('shortcuts')
          ? (json['shortcuts'] as List)
                .map((e) => Shortcut.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      startUrl: json.containsKey('startUrl')
          ? json['startUrl'] as String
          : null,
      themeColor: json.containsKey('themeColor')
          ? json['themeColor'] as String
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (backgroundColor != null) 'backgroundColor': backgroundColor,
      if (description != null) 'description': description,
      if (dir != null) 'dir': dir,
      if (display != null) 'display': display,
      if (displayOverrides != null) 'displayOverrides': [...?displayOverrides],
      if (fileHandlers != null)
        'fileHandlers': fileHandlers!.map((e) => e.toJson()).toList(),
      if (icons != null) 'icons': icons!.map((e) => e.toJson()).toList(),
      if (id != null) 'id': id,
      if (lang != null) 'lang': lang,
      if (launchHandler != null) 'launchHandler': launchHandler!.toJson(),
      if (name != null) 'name': name,
      if (orientation != null) 'orientation': orientation,
      if (preferRelatedApplications != null)
        'preferRelatedApplications': preferRelatedApplications,
      if (protocolHandlers != null)
        'protocolHandlers': protocolHandlers!.map((e) => e.toJson()).toList(),
      if (relatedApplications != null)
        'relatedApplications': relatedApplications!
            .map((e) => e.toJson())
            .toList(),
      if (scope != null) 'scope': scope,
      if (scopeExtensions != null)
        'scopeExtensions': scopeExtensions!.map((e) => e.toJson()).toList(),
      if (screenshots != null)
        'screenshots': screenshots!.map((e) => e.toJson()).toList(),
      if (shareTarget != null) 'shareTarget': shareTarget!.toJson(),
      if (shortName != null) 'shortName': shortName,
      if (shortcuts != null)
        'shortcuts': shortcuts!.map((e) => e.toJson()).toList(),
      if (startUrl != null) 'startUrl': startUrl,
      if (themeColor != null) 'themeColor': themeColor,
    };
  }
}

/// Enum of possible auto-response for permission / prompt dialogs.
enum AutoResponseMode {
  none('none'),
  autoAccept('autoAccept'),
  autoReject('autoReject'),
  autoOptOut('autoOptOut');

  final String value;

  const AutoResponseMode(this.value);

  factory AutoResponseMode.fromJson(String value) =>
      AutoResponseMode.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// The type of a frameNavigated event.
enum NavigationType {
  navigation('Navigation'),
  backForwardCacheRestore('BackForwardCacheRestore');

  final String value;

  const NavigationType(this.value);

  factory NavigationType.fromJson(String value) =>
      NavigationType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// List of not restored reasons for back-forward cache.
enum BackForwardCacheNotRestoredReason {
  notPrimaryMainFrame('NotPrimaryMainFrame'),
  backForwardCacheDisabled('BackForwardCacheDisabled'),
  relatedActiveContentsExist('RelatedActiveContentsExist'),
  httpStatusNotOk('HTTPStatusNotOK'),
  schemeNotHttpOrHttps('SchemeNotHTTPOrHTTPS'),
  loading('Loading'),
  wasGrantedMediaAccess('WasGrantedMediaAccess'),
  disableForRenderFrameHostCalled('DisableForRenderFrameHostCalled'),
  domainNotAllowed('DomainNotAllowed'),
  httpMethodNotGet('HTTPMethodNotGET'),
  subframeIsNavigating('SubframeIsNavigating'),
  timeout('Timeout'),
  cacheLimit('CacheLimit'),
  javaScriptExecution('JavaScriptExecution'),
  rendererProcessKilled('RendererProcessKilled'),
  rendererProcessCrashed('RendererProcessCrashed'),
  schedulerTrackedFeatureUsed('SchedulerTrackedFeatureUsed'),
  conflictingBrowsingInstance('ConflictingBrowsingInstance'),
  cacheFlushed('CacheFlushed'),
  serviceWorkerVersionActivation('ServiceWorkerVersionActivation'),
  sessionRestored('SessionRestored'),
  serviceWorkerPostMessage('ServiceWorkerPostMessage'),
  enteredBackForwardCacheBeforeServiceWorkerHostAdded(
    'EnteredBackForwardCacheBeforeServiceWorkerHostAdded',
  ),
  renderFrameHostReusedSameSite('RenderFrameHostReused_SameSite'),
  renderFrameHostReusedCrossSite('RenderFrameHostReused_CrossSite'),
  serviceWorkerClaim('ServiceWorkerClaim'),
  ignoreEventAndEvict('IgnoreEventAndEvict'),
  haveInnerContents('HaveInnerContents'),
  timeoutPuttingInCache('TimeoutPuttingInCache'),
  backForwardCacheDisabledByLowMemory('BackForwardCacheDisabledByLowMemory'),
  backForwardCacheDisabledByCommandLine(
    'BackForwardCacheDisabledByCommandLine',
  ),
  networkRequestDatapipeDrainedAsBytesConsumer(
    'NetworkRequestDatapipeDrainedAsBytesConsumer',
  ),
  networkRequestRedirected('NetworkRequestRedirected'),
  networkRequestTimeout('NetworkRequestTimeout'),
  networkExceedsBufferLimit('NetworkExceedsBufferLimit'),
  navigationCancelledWhileRestoring('NavigationCancelledWhileRestoring'),
  notMostRecentNavigationEntry('NotMostRecentNavigationEntry'),
  backForwardCacheDisabledForPrerender('BackForwardCacheDisabledForPrerender'),
  userAgentOverrideDiffers('UserAgentOverrideDiffers'),
  foregroundCacheLimit('ForegroundCacheLimit'),
  browsingInstanceNotSwapped('BrowsingInstanceNotSwapped'),
  backForwardCacheDisabledForDelegate('BackForwardCacheDisabledForDelegate'),
  unloadHandlerExistsInMainFrame('UnloadHandlerExistsInMainFrame'),
  unloadHandlerExistsInSubFrame('UnloadHandlerExistsInSubFrame'),
  serviceWorkerUnregistration('ServiceWorkerUnregistration'),
  cacheControlNoStore('CacheControlNoStore'),
  cacheControlNoStoreCookieModified('CacheControlNoStoreCookieModified'),
  cacheControlNoStoreHttpOnlyCookieModified(
    'CacheControlNoStoreHTTPOnlyCookieModified',
  ),
  noResponseHead('NoResponseHead'),
  unknown('Unknown'),
  activationNavigationsDisallowedForBug1234857(
    'ActivationNavigationsDisallowedForBug1234857',
  ),
  errorDocument('ErrorDocument'),
  fencedFramesEmbedder('FencedFramesEmbedder'),
  cookieDisabled('CookieDisabled'),
  httpAuthRequired('HTTPAuthRequired'),
  cookieFlushed('CookieFlushed'),
  broadcastChannelOnMessage('BroadcastChannelOnMessage'),
  webViewSettingsChanged('WebViewSettingsChanged'),
  webViewJavaScriptObjectChanged('WebViewJavaScriptObjectChanged'),
  webViewMessageListenerInjected('WebViewMessageListenerInjected'),
  webViewSafeBrowsingAllowlistChanged('WebViewSafeBrowsingAllowlistChanged'),
  webViewDocumentStartJavascriptChanged(
    'WebViewDocumentStartJavascriptChanged',
  ),
  webSocket('WebSocket'),
  webTransport('WebTransport'),
  webRtc('WebRTC'),
  mainResourceHasCacheControlNoStore('MainResourceHasCacheControlNoStore'),
  mainResourceHasCacheControlNoCache('MainResourceHasCacheControlNoCache'),
  subresourceHasCacheControlNoStore('SubresourceHasCacheControlNoStore'),
  subresourceHasCacheControlNoCache('SubresourceHasCacheControlNoCache'),
  containsPlugins('ContainsPlugins'),
  documentLoaded('DocumentLoaded'),
  outstandingNetworkRequestOthers('OutstandingNetworkRequestOthers'),
  requestedMidiPermission('RequestedMIDIPermission'),
  requestedAudioCapturePermission('RequestedAudioCapturePermission'),
  requestedVideoCapturePermission('RequestedVideoCapturePermission'),
  requestedBackForwardCacheBlockedSensors(
    'RequestedBackForwardCacheBlockedSensors',
  ),
  requestedBackgroundWorkPermission('RequestedBackgroundWorkPermission'),
  broadcastChannel('BroadcastChannel'),
  webXr('WebXR'),
  sharedWorker('SharedWorker'),
  webLocks('WebLocks'),
  webHid('WebHID'),
  webShare('WebShare'),
  requestedStorageAccessGrant('RequestedStorageAccessGrant'),
  webNfc('WebNfc'),
  outstandingNetworkRequestFetch('OutstandingNetworkRequestFetch'),
  outstandingNetworkRequestXhr('OutstandingNetworkRequestXHR'),
  appBanner('AppBanner'),
  printing('Printing'),
  webDatabase('WebDatabase'),
  pictureInPicture('PictureInPicture'),
  speechRecognizer('SpeechRecognizer'),
  idleManager('IdleManager'),
  paymentManager('PaymentManager'),
  speechSynthesis('SpeechSynthesis'),
  keyboardLock('KeyboardLock'),
  webOtpService('WebOTPService'),
  outstandingNetworkRequestDirectSocket(
    'OutstandingNetworkRequestDirectSocket',
  ),
  injectedJavascript('InjectedJavascript'),
  injectedStyleSheet('InjectedStyleSheet'),
  keepaliveRequest('KeepaliveRequest'),
  indexedDbEvent('IndexedDBEvent'),
  dummy('Dummy'),
  jsNetworkRequestReceivedCacheControlNoStoreResource(
    'JsNetworkRequestReceivedCacheControlNoStoreResource',
  ),
  webRtcSticky('WebRTCSticky'),
  webTransportSticky('WebTransportSticky'),
  webSocketSticky('WebSocketSticky'),
  smartCard('SmartCard'),
  liveMediaStreamTrack('LiveMediaStreamTrack'),
  unloadHandler('UnloadHandler'),
  parserAborted('ParserAborted'),
  contentSecurityHandler('ContentSecurityHandler'),
  contentWebAuthenticationApi('ContentWebAuthenticationAPI'),
  contentFileChooser('ContentFileChooser'),
  contentSerial('ContentSerial'),
  contentFileSystemAccess('ContentFileSystemAccess'),
  contentMediaDevicesDispatcherHost('ContentMediaDevicesDispatcherHost'),
  contentWebBluetooth('ContentWebBluetooth'),
  contentWebUsb('ContentWebUSB'),
  contentMediaSessionService('ContentMediaSessionService'),
  contentScreenReader('ContentScreenReader'),
  contentDiscarded('ContentDiscarded'),
  embedderPopupBlockerTabHelper('EmbedderPopupBlockerTabHelper'),
  embedderSafeBrowsingTriggeredPopupBlocker(
    'EmbedderSafeBrowsingTriggeredPopupBlocker',
  ),
  embedderSafeBrowsingThreatDetails('EmbedderSafeBrowsingThreatDetails'),
  embedderAppBannerManager('EmbedderAppBannerManager'),
  embedderDomDistillerViewerSource('EmbedderDomDistillerViewerSource'),
  embedderDomDistillerSelfDeletingRequestDelegate(
    'EmbedderDomDistillerSelfDeletingRequestDelegate',
  ),
  embedderOomInterventionTabHelper('EmbedderOomInterventionTabHelper'),
  embedderOfflinePage('EmbedderOfflinePage'),
  embedderChromePasswordManagerClientBindCredentialManager(
    'EmbedderChromePasswordManagerClientBindCredentialManager',
  ),
  embedderPermissionRequestManager('EmbedderPermissionRequestManager'),
  embedderModalDialog('EmbedderModalDialog'),
  embedderExtensions('EmbedderExtensions'),
  embedderExtensionMessaging('EmbedderExtensionMessaging'),
  embedderExtensionMessagingForOpenPort(
    'EmbedderExtensionMessagingForOpenPort',
  ),
  embedderExtensionSentMessageToCachedFrame(
    'EmbedderExtensionSentMessageToCachedFrame',
  ),
  requestedByWebViewClient('RequestedByWebViewClient'),
  postMessageByWebViewClient('PostMessageByWebViewClient'),
  cacheControlNoStoreDeviceBoundSessionTerminated(
    'CacheControlNoStoreDeviceBoundSessionTerminated',
  ),
  cacheLimitPrunedOnModerateMemoryPressure(
    'CacheLimitPrunedOnModerateMemoryPressure',
  ),
  cacheLimitPrunedOnCriticalMemoryPressure(
    'CacheLimitPrunedOnCriticalMemoryPressure',
  );

  final String value;

  const BackForwardCacheNotRestoredReason(this.value);

  factory BackForwardCacheNotRestoredReason.fromJson(String value) =>
      BackForwardCacheNotRestoredReason.values.firstWhere(
        (e) => e.value == value,
      );

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Types of not restored reasons for back-forward cache.
enum BackForwardCacheNotRestoredReasonType {
  supportPending('SupportPending'),
  pageSupportNeeded('PageSupportNeeded'),
  circumstantial('Circumstantial');

  final String value;

  const BackForwardCacheNotRestoredReasonType(this.value);

  factory BackForwardCacheNotRestoredReasonType.fromJson(String value) =>
      BackForwardCacheNotRestoredReasonType.values.firstWhere(
        (e) => e.value == value,
      );

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class BackForwardCacheBlockingDetails {
  /// Url of the file where blockage happened. Optional because of tests.
  final String? url;

  /// Function name where blockage happened. Optional because of anonymous functions and tests.
  final String? function;

  /// Line number in the script (0-based).
  final int lineNumber;

  /// Column number in the script (0-based).
  final int columnNumber;

  BackForwardCacheBlockingDetails({
    this.url,
    this.function,
    required this.lineNumber,
    required this.columnNumber,
  });

  factory BackForwardCacheBlockingDetails.fromJson(Map<String, dynamic> json) {
    return BackForwardCacheBlockingDetails(
      url: json.containsKey('url') ? json['url'] as String : null,
      function: json.containsKey('function')
          ? json['function'] as String
          : null,
      lineNumber: json['lineNumber'] as int,
      columnNumber: json['columnNumber'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lineNumber': lineNumber,
      'columnNumber': columnNumber,
      if (url != null) 'url': url,
      if (function != null) 'function': function,
    };
  }
}

class BackForwardCacheNotRestoredExplanation {
  /// Type of the reason
  final BackForwardCacheNotRestoredReasonType type;

  /// Not restored reason
  final BackForwardCacheNotRestoredReason reason;

  /// Context associated with the reason. The meaning of this context is
  /// dependent on the reason:
  /// - EmbedderExtensionSentMessageToCachedFrame: the extension ID.
  final String? context;

  final List<BackForwardCacheBlockingDetails>? details;

  BackForwardCacheNotRestoredExplanation({
    required this.type,
    required this.reason,
    this.context,
    this.details,
  });

  factory BackForwardCacheNotRestoredExplanation.fromJson(
    Map<String, dynamic> json,
  ) {
    return BackForwardCacheNotRestoredExplanation(
      type: BackForwardCacheNotRestoredReasonType.fromJson(
        json['type'] as String,
      ),
      reason: BackForwardCacheNotRestoredReason.fromJson(
        json['reason'] as String,
      ),
      context: json.containsKey('context') ? json['context'] as String : null,
      details: json.containsKey('details')
          ? (json['details'] as List)
                .map(
                  (e) => BackForwardCacheBlockingDetails.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      'reason': reason.toJson(),
      if (context != null) 'context': context,
      if (details != null) 'details': details!.map((e) => e.toJson()).toList(),
    };
  }
}

class BackForwardCacheNotRestoredExplanationTree {
  /// URL of each frame
  final String url;

  /// Not restored reasons of each frame
  final List<BackForwardCacheNotRestoredExplanation> explanations;

  /// Array of children frame
  final List<BackForwardCacheNotRestoredExplanationTree> children;

  BackForwardCacheNotRestoredExplanationTree({
    required this.url,
    required this.explanations,
    required this.children,
  });

  factory BackForwardCacheNotRestoredExplanationTree.fromJson(
    Map<String, dynamic> json,
  ) {
    return BackForwardCacheNotRestoredExplanationTree(
      url: json['url'] as String,
      explanations: (json['explanations'] as List)
          .map(
            (e) => BackForwardCacheNotRestoredExplanation.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      children: (json['children'] as List)
          .map(
            (e) => BackForwardCacheNotRestoredExplanationTree.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'explanations': explanations.map((e) => e.toJson()).toList(),
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}

enum FileChooserOpenedEventMode {
  selectSingle('selectSingle'),
  selectMultiple('selectMultiple');

  final String value;

  const FileChooserOpenedEventMode(this.value);

  factory FileChooserOpenedEventMode.fromJson(String value) =>
      FileChooserOpenedEventMode.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum FrameDetachedEventReason {
  remove('remove'),
  swap('swap');

  final String value;

  const FrameDetachedEventReason(this.value);

  factory FrameDetachedEventReason.fromJson(String value) =>
      FrameDetachedEventReason.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum FrameStartedNavigatingEventNavigationType {
  reload('reload'),
  reloadBypassingCache('reloadBypassingCache'),
  restore('restore'),
  restoreWithPost('restoreWithPost'),
  historySameDocument('historySameDocument'),
  historyDifferentDocument('historyDifferentDocument'),
  sameDocument('sameDocument'),
  differentDocument('differentDocument');

  final String value;

  const FrameStartedNavigatingEventNavigationType(this.value);

  factory FrameStartedNavigatingEventNavigationType.fromJson(String value) =>
      FrameStartedNavigatingEventNavigationType.values.firstWhere(
        (e) => e.value == value,
      );

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum DownloadProgressEventState {
  inProgress('inProgress'),
  completed('completed'),
  canceled('canceled');

  final String value;

  const DownloadProgressEventState(this.value);

  factory DownloadProgressEventState.fromJson(String value) =>
      DownloadProgressEventState.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum NavigatedWithinDocumentEventNavigationType {
  fragment('fragment'),
  historyApi('historyApi'),
  other('other');

  final String value;

  const NavigatedWithinDocumentEventNavigationType(this.value);

  factory NavigatedWithinDocumentEventNavigationType.fromJson(String value) =>
      NavigatedWithinDocumentEventNavigationType.values.firstWhere(
        (e) => e.value == value,
      );

  String toJson() => value;

  @override
  String toString() => value.toString();
}
