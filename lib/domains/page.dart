/// Actions and events related to the inspected page belong to the page domain.

import 'dart:async';
// ignore: unused_import
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'network.dart' as network;
import 'debugger.dart' as debugger;
import 'emulation.dart' as emulation;
import 'dom.dart' as dom;
import 'runtime.dart' as runtime;

class PageManager {
  final Client _client;

  PageManager(this._client);

  Stream<network.MonotonicTime> get onDomContentEventFired => _client.onEvent
      .where((Event event) => event.name == 'Page.domContentEventFired')
      .map((Event event) =>
          new network.MonotonicTime.fromJson(event.parameters['timestamp']));

  Stream<network.MonotonicTime> get onLoadEventFired => _client.onEvent
      .where((Event event) => event.name == 'Page.loadEventFired')
      .map((Event event) =>
          new network.MonotonicTime.fromJson(event.parameters['timestamp']));

  /// Fired for top level page lifecycle events such as navigation, load, paint, etc.
  Stream<LifecycleEventEvent> get onLifecycleEvent => _client.onEvent
      .where((Event event) => event.name == 'Page.lifecycleEvent')
      .map((Event event) => new LifecycleEventEvent.fromJson(event.parameters));

  /// Fired when frame has been attached to its parent.
  Stream<FrameAttachedEvent> get onFrameAttached => _client.onEvent
      .where((Event event) => event.name == 'Page.frameAttached')
      .map((Event event) => new FrameAttachedEvent.fromJson(event.parameters));

  /// Fired once navigation of the frame has completed. Frame is now associated with the new loader.
  Stream<Frame> get onFrameNavigated => _client.onEvent
      .where((Event event) => event.name == 'Page.frameNavigated')
      .map((Event event) => new Frame.fromJson(event.parameters['frame']));

  /// Fired when frame has been detached from its parent.
  Stream<FrameId> get onFrameDetached => _client.onEvent
      .where((Event event) => event.name == 'Page.frameDetached')
      .map((Event event) => new FrameId.fromJson(event.parameters['frameId']));

  /// Fired when frame has started loading.
  Stream<FrameId> get onFrameStartedLoading => _client.onEvent
      .where((Event event) => event.name == 'Page.frameStartedLoading')
      .map((Event event) => new FrameId.fromJson(event.parameters['frameId']));

  /// Fired when frame has stopped loading.
  Stream<FrameId> get onFrameStoppedLoading => _client.onEvent
      .where((Event event) => event.name == 'Page.frameStoppedLoading')
      .map((Event event) => new FrameId.fromJson(event.parameters['frameId']));

  /// Fired when frame schedules a potential navigation.
  Stream<FrameScheduledNavigationEvent> get onFrameScheduledNavigation =>
      _client.onEvent
          .where((Event event) => event.name == 'Page.frameScheduledNavigation')
          .map((Event event) =>
              new FrameScheduledNavigationEvent.fromJson(event.parameters));

  /// Fired when frame no longer has a scheduled navigation.
  Stream<FrameId> get onFrameClearedScheduledNavigation => _client.onEvent
      .where(
          (Event event) => event.name == 'Page.frameClearedScheduledNavigation')
      .map((Event event) => new FrameId.fromJson(event.parameters['frameId']));

  Stream get onFrameResized =>
      _client.onEvent.where((Event event) => event.name == 'Page.frameResized');

  /// Fired when a JavaScript initiated dialog (alert, confirm, prompt, or onbeforeunload) is about to open.
  Stream<JavascriptDialogOpeningEvent> get onJavascriptDialogOpening =>
      _client.onEvent
          .where((Event event) => event.name == 'Page.javascriptDialogOpening')
          .map((Event event) =>
              new JavascriptDialogOpeningEvent.fromJson(event.parameters));

  /// Fired when a JavaScript initiated dialog (alert, confirm, prompt, or onbeforeunload) has been closed.
  Stream<JavascriptDialogClosedEvent> get onJavascriptDialogClosed =>
      _client.onEvent
          .where((Event event) => event.name == 'Page.javascriptDialogClosed')
          .map((Event event) =>
              new JavascriptDialogClosedEvent.fromJson(event.parameters));

  /// Compressed image data requested by the <code>startScreencast</code>.
  Stream<ScreencastFrameEvent> get onScreencastFrame => _client.onEvent
      .where((Event event) => event.name == 'Page.screencastFrame')
      .map(
          (Event event) => new ScreencastFrameEvent.fromJson(event.parameters));

  /// Fired when the page with currently enabled screencast was shown or hidden </code>.
  Stream<bool> get onScreencastVisibilityChanged => _client.onEvent
      .where((Event event) => event.name == 'Page.screencastVisibilityChanged')
      .map((Event event) => event.parameters['visible'] as bool);

  /// Fired when interstitial page was shown
  Stream get onInterstitialShown => _client.onEvent
      .where((Event event) => event.name == 'Page.interstitialShown');

  /// Fired when interstitial page was hidden
  Stream get onInterstitialHidden => _client.onEvent
      .where((Event event) => event.name == 'Page.interstitialHidden');

  /// Enables page domain notifications.
  Future enable() async {
    await _client.send('Page.enable');
  }

  /// Disables page domain notifications.
  Future disable() async {
    await _client.send('Page.disable');
  }

  /// Deprecated, please use addScriptToEvaluateOnNewDocument instead.
  /// Return: Identifier of the added script.
  Future<ScriptIdentifier> addScriptToEvaluateOnLoad(
    String scriptSource,
  ) async {
    Map parameters = {
      'scriptSource': scriptSource,
    };
    Map result =
        await _client.send('Page.addScriptToEvaluateOnLoad', parameters);
    return new ScriptIdentifier.fromJson(result['identifier']);
  }

  /// Deprecated, please use removeScriptToEvaluateOnNewDocument instead.
  Future removeScriptToEvaluateOnLoad(
    ScriptIdentifier identifier,
  ) async {
    Map parameters = {
      'identifier': identifier.toJson(),
    };
    await _client.send('Page.removeScriptToEvaluateOnLoad', parameters);
  }

  /// Evaluates given script in every frame upon creation (before loading frame's scripts).
  /// Return: Identifier of the added script.
  Future<ScriptIdentifier> addScriptToEvaluateOnNewDocument(
    String source,
  ) async {
    Map parameters = {
      'source': source,
    };
    Map result =
        await _client.send('Page.addScriptToEvaluateOnNewDocument', parameters);
    return new ScriptIdentifier.fromJson(result['identifier']);
  }

  /// Removes given script from the list.
  Future removeScriptToEvaluateOnNewDocument(
    ScriptIdentifier identifier,
  ) async {
    Map parameters = {
      'identifier': identifier.toJson(),
    };
    await _client.send('Page.removeScriptToEvaluateOnNewDocument', parameters);
  }

  /// Controls whether browser will open a new inspector window for connected pages.
  /// [autoAttach] If true, browser will open a new inspector window for every page created from this one.
  Future setAutoAttachToCreatedPages(
    bool autoAttach,
  ) async {
    Map parameters = {
      'autoAttach': autoAttach,
    };
    await _client.send('Page.setAutoAttachToCreatedPages', parameters);
  }

  /// Reloads given page optionally ignoring the cache.
  /// [ignoreCache] If true, browser cache is ignored (as if the user pressed Shift+refresh).
  /// [scriptToEvaluateOnLoad] If set, the script will be injected into all frames of the inspected page after reload.
  Future reload({
    bool ignoreCache,
    String scriptToEvaluateOnLoad,
  }) async {
    Map parameters = {};
    if (ignoreCache != null) {
      parameters['ignoreCache'] = ignoreCache;
    }
    if (scriptToEvaluateOnLoad != null) {
      parameters['scriptToEvaluateOnLoad'] = scriptToEvaluateOnLoad;
    }
    await _client.send('Page.reload', parameters);
  }

  /// Enable Chrome's experimental ad filter on all sites.
  /// [enabled] Whether to block ads.
  Future setAdBlockingEnabled(
    bool enabled,
  ) async {
    Map parameters = {
      'enabled': enabled,
    };
    await _client.send('Page.setAdBlockingEnabled', parameters);
  }

  /// Navigates current page to the given URL.
  /// [url] URL to navigate the page to.
  /// [referrer] Referrer URL.
  /// [transitionType] Intended transition type.
  /// Return: Frame id that will be navigated.
  Future<FrameId> navigate(
    String url, {
    String referrer,
    TransitionType transitionType,
  }) async {
    Map parameters = {
      'url': url,
    };
    if (referrer != null) {
      parameters['referrer'] = referrer;
    }
    if (transitionType != null) {
      parameters['transitionType'] = transitionType.toJson();
    }
    Map result = await _client.send('Page.navigate', parameters);
    return new FrameId.fromJson(result['frameId']);
  }

  /// Force the page stop all navigations and pending resource fetches.
  Future stopLoading() async {
    await _client.send('Page.stopLoading');
  }

  /// Returns navigation history for the current page.
  Future<GetNavigationHistoryResult> getNavigationHistory() async {
    Map result = await _client.send('Page.getNavigationHistory');
    return new GetNavigationHistoryResult.fromJson(result);
  }

  /// Navigates current page to the given history entry.
  /// [entryId] Unique id of the entry to navigate to.
  Future navigateToHistoryEntry(
    int entryId,
  ) async {
    Map parameters = {
      'entryId': entryId,
    };
    await _client.send('Page.navigateToHistoryEntry', parameters);
  }

  /// Returns all browser cookies. Depending on the backend support, will return detailed cookie information in the <code>cookies</code> field.
  /// Return: Array of cookie objects.
  Future<List<network.Cookie>> getCookies() async {
    Map result = await _client.send('Page.getCookies');
    return (result['cookies'] as List)
        .map((e) => new network.Cookie.fromJson(e))
        .toList();
  }

  /// Deletes browser cookie with given name, domain and path.
  /// [cookieName] Name of the cookie to remove.
  /// [url] URL to match cooke domain and path.
  Future deleteCookie(
    String cookieName,
    String url,
  ) async {
    Map parameters = {
      'cookieName': cookieName,
      'url': url,
    };
    await _client.send('Page.deleteCookie', parameters);
  }

  /// Returns present frame / resource tree structure.
  /// Return: Present frame / resource tree structure.
  Future<FrameResourceTree> getResourceTree() async {
    Map result = await _client.send('Page.getResourceTree');
    return new FrameResourceTree.fromJson(result['frameTree']);
  }

  /// Returns content of the given resource.
  /// [frameId] Frame id to get resource for.
  /// [url] URL of the resource to get content for.
  Future<GetResourceContentResult> getResourceContent(
    FrameId frameId,
    String url,
  ) async {
    Map parameters = {
      'frameId': frameId.toJson(),
      'url': url,
    };
    Map result = await _client.send('Page.getResourceContent', parameters);
    return new GetResourceContentResult.fromJson(result);
  }

  /// Searches for given string in resource content.
  /// [frameId] Frame id for resource to search in.
  /// [url] URL of the resource to search in.
  /// [query] String to search for.
  /// [caseSensitive] If true, search is case sensitive.
  /// [isRegex] If true, treats string parameter as regex.
  /// Return: List of search matches.
  Future<List<debugger.SearchMatch>> searchInResource(
    FrameId frameId,
    String url,
    String query, {
    bool caseSensitive,
    bool isRegex,
  }) async {
    Map parameters = {
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
    Map result = await _client.send('Page.searchInResource', parameters);
    return (result['result'] as List)
        .map((e) => new debugger.SearchMatch.fromJson(e))
        .toList();
  }

  /// Sets given markup as the document's HTML.
  /// [frameId] Frame id to set HTML for.
  /// [html] HTML content to set.
  Future setDocumentContent(
    FrameId frameId,
    String html,
  ) async {
    Map parameters = {
      'frameId': frameId.toJson(),
      'html': html,
    };
    await _client.send('Page.setDocumentContent', parameters);
  }

  /// Overrides the values of device screen dimensions (window.screen.width, window.screen.height, window.innerWidth, window.innerHeight, and "device-width"/"device-height"-related CSS media query results).
  /// [width] Overriding width value in pixels (minimum 0, maximum 10000000). 0 disables the override.
  /// [height] Overriding height value in pixels (minimum 0, maximum 10000000). 0 disables the override.
  /// [deviceScaleFactor] Overriding device scale factor value. 0 disables the override.
  /// [mobile] Whether to emulate mobile device. This includes viewport meta tag, overlay scrollbars, text autosizing and more.
  /// [scale] Scale to apply to resulting view image. Ignored in |fitWindow| mode.
  /// [screenWidth] Overriding screen width value in pixels (minimum 0, maximum 10000000). Only used for |mobile==true|.
  /// [screenHeight] Overriding screen height value in pixels (minimum 0, maximum 10000000). Only used for |mobile==true|.
  /// [positionX] Overriding view X position on screen in pixels (minimum 0, maximum 10000000). Only used for |mobile==true|.
  /// [positionY] Overriding view Y position on screen in pixels (minimum 0, maximum 10000000). Only used for |mobile==true|.
  /// [dontSetVisibleSize] Do not set visible view size, rely upon explicit setVisibleSize call.
  /// [screenOrientation] Screen orientation override.
  Future setDeviceMetricsOverride(
    int width,
    int height,
    num deviceScaleFactor,
    bool mobile, {
    num scale,
    int screenWidth,
    int screenHeight,
    int positionX,
    int positionY,
    bool dontSetVisibleSize,
    emulation.ScreenOrientation screenOrientation,
  }) async {
    Map parameters = {
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
    await _client.send('Page.setDeviceMetricsOverride', parameters);
  }

  /// Clears the overriden device metrics.
  Future clearDeviceMetricsOverride() async {
    await _client.send('Page.clearDeviceMetricsOverride');
  }

  /// Overrides the Geolocation Position or Error. Omitting any of the parameters emulates position unavailable.
  /// [latitude] Mock latitude
  /// [longitude] Mock longitude
  /// [accuracy] Mock accuracy
  Future setGeolocationOverride({
    num latitude,
    num longitude,
    num accuracy,
  }) async {
    Map parameters = {};
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

  /// Clears the overriden Geolocation Position and Error.
  Future clearGeolocationOverride() async {
    await _client.send('Page.clearGeolocationOverride');
  }

  /// Overrides the Device Orientation.
  /// [alpha] Mock alpha
  /// [beta] Mock beta
  /// [gamma] Mock gamma
  Future setDeviceOrientationOverride(
    num alpha,
    num beta,
    num gamma,
  ) async {
    Map parameters = {
      'alpha': alpha,
      'beta': beta,
      'gamma': gamma,
    };
    await _client.send('Page.setDeviceOrientationOverride', parameters);
  }

  /// Clears the overridden Device Orientation.
  Future clearDeviceOrientationOverride() async {
    await _client.send('Page.clearDeviceOrientationOverride');
  }

  /// Toggles mouse event-based touch event emulation.
  /// [enabled] Whether the touch event emulation should be enabled.
  /// [configuration] Touch/gesture events configuration. Default: current platform.
  Future setTouchEmulationEnabled(
    bool enabled, {
    String configuration,
  }) async {
    Map parameters = {
      'enabled': enabled,
    };
    if (configuration != null) {
      parameters['configuration'] = configuration;
    }
    await _client.send('Page.setTouchEmulationEnabled', parameters);
  }

  /// Capture page screenshot.
  /// [format] Image compression format (defaults to png).
  /// [quality] Compression quality from range [0..100] (jpeg only).
  /// [clip] Capture the screenshot of a given region only.
  /// [fromSurface] Capture the screenshot from the surface, rather than the view. Defaults to true.
  /// Return: Base64-encoded image data.
  Future<String> captureScreenshot({
    String format,
    int quality,
    Viewport clip,
    bool fromSurface,
  }) async {
    Map parameters = {};
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
    Map result = await _client.send('Page.captureScreenshot', parameters);
    return result['data'];
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
  /// [pageRanges] Paper ranges to print, e.g., '1-5, 8, 11-13'. Defaults to the empty string, which means print all pages.
  /// [ignoreInvalidPageRanges] Whether to silently ignore invalid but successfully parsed page ranges, such as '3-2'. Defaults to false.
  /// Return: Base64-encoded pdf data.
  Future<String> printToPDF({
    bool landscape,
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
  }) async {
    Map parameters = {};
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
    Map result = await _client.send('Page.printToPDF', parameters);
    return result['data'];
  }

  /// Starts sending each frame using the <code>screencastFrame</code> event.
  /// [format] Image compression format.
  /// [quality] Compression quality from range [0..100].
  /// [maxWidth] Maximum screenshot width.
  /// [maxHeight] Maximum screenshot height.
  /// [everyNthFrame] Send every n-th frame.
  Future startScreencast({
    String format,
    int quality,
    int maxWidth,
    int maxHeight,
    int everyNthFrame,
  }) async {
    Map parameters = {};
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

  /// Stops sending each frame in the <code>screencastFrame</code>.
  Future stopScreencast() async {
    await _client.send('Page.stopScreencast');
  }

  /// Acknowledges that a screencast frame has been received by the frontend.
  /// [sessionId] Frame number.
  Future screencastFrameAck(
    int sessionId,
  ) async {
    Map parameters = {
      'sessionId': sessionId,
    };
    await _client.send('Page.screencastFrameAck', parameters);
  }

  /// Accepts or dismisses a JavaScript initiated dialog (alert, confirm, prompt, or onbeforeunload).
  /// [accept] Whether to accept or dismiss the dialog.
  /// [promptText] The text to enter into the dialog prompt before accepting. Used only if this is a prompt dialog.
  Future handleJavaScriptDialog(
    bool accept, {
    String promptText,
  }) async {
    Map parameters = {
      'accept': accept,
    };
    if (promptText != null) {
      parameters['promptText'] = promptText;
    }
    await _client.send('Page.handleJavaScriptDialog', parameters);
  }

  Future<GetAppManifestResult> getAppManifest() async {
    Map result = await _client.send('Page.getAppManifest');
    return new GetAppManifestResult.fromJson(result);
  }

  Future requestAppBanner() async {
    await _client.send('Page.requestAppBanner');
  }

  /// Returns metrics relating to the layouting of the page, such as viewport bounds/scale.
  Future<GetLayoutMetricsResult> getLayoutMetrics() async {
    Map result = await _client.send('Page.getLayoutMetrics');
    return new GetLayoutMetricsResult.fromJson(result);
  }

  /// Creates an isolated world for the given frame.
  /// [frameId] Id of the frame in which the isolated world should be created.
  /// [worldName] An optional name which is reported in the Execution Context.
  /// [grantUniveralAccess] Whether or not universal access should be granted to the isolated world. This is a powerful option, use with caution.
  /// Return: Execution context of the isolated world.
  Future<runtime.ExecutionContextId> createIsolatedWorld(
    FrameId frameId, {
    String worldName,
    bool grantUniveralAccess,
  }) async {
    Map parameters = {
      'frameId': frameId.toJson(),
    };
    if (worldName != null) {
      parameters['worldName'] = worldName;
    }
    if (grantUniveralAccess != null) {
      parameters['grantUniveralAccess'] = grantUniveralAccess;
    }
    Map result = await _client.send('Page.createIsolatedWorld', parameters);
    return new runtime.ExecutionContextId.fromJson(
        result['executionContextId']);
  }

  /// Brings page to front (activates tab).
  Future bringToFront() async {
    await _client.send('Page.bringToFront');
  }

  /// Set the behavior when downloading a file.
  /// [behavior] Whether to allow all or deny all download requests, or use default Chrome behavior if available (otherwise deny).
  /// [downloadPath] The default path to save downloaded files to. This is requred if behavior is set to 'allow'
  Future setDownloadBehavior(
    String behavior, {
    String downloadPath,
  }) async {
    Map parameters = {
      'behavior': behavior,
    };
    if (downloadPath != null) {
      parameters['downloadPath'] = downloadPath;
    }
    await _client.send('Page.setDownloadBehavior', parameters);
  }
}

class LifecycleEventEvent {
  final String name;

  final network.MonotonicTime timestamp;

  LifecycleEventEvent({
    @required this.name,
    @required this.timestamp,
  });

  factory LifecycleEventEvent.fromJson(Map json) {
    return new LifecycleEventEvent(
      name: json['name'],
      timestamp: new network.MonotonicTime.fromJson(json['timestamp']),
    );
  }
}

class FrameAttachedEvent {
  /// Id of the frame that has been attached.
  final FrameId frameId;

  /// Parent frame identifier.
  final FrameId parentFrameId;

  /// JavaScript stack trace of when frame was attached, only set if frame initiated from script.
  final runtime.StackTrace stack;

  FrameAttachedEvent({
    @required this.frameId,
    @required this.parentFrameId,
    this.stack,
  });

  factory FrameAttachedEvent.fromJson(Map json) {
    return new FrameAttachedEvent(
      frameId: new FrameId.fromJson(json['frameId']),
      parentFrameId: new FrameId.fromJson(json['parentFrameId']),
      stack: json.containsKey('stack')
          ? new runtime.StackTrace.fromJson(json['stack'])
          : null,
    );
  }
}

class FrameScheduledNavigationEvent {
  /// Id of the frame that has scheduled a navigation.
  final FrameId frameId;

  /// Delay (in seconds) until the navigation is scheduled to begin. The navigation is not guaranteed to start.
  final num delay;

  /// The reason for the navigation.
  final String reason;

  /// The destination URL for the scheduled navigation.
  final String url;

  FrameScheduledNavigationEvent({
    @required this.frameId,
    @required this.delay,
    @required this.reason,
    @required this.url,
  });

  factory FrameScheduledNavigationEvent.fromJson(Map json) {
    return new FrameScheduledNavigationEvent(
      frameId: new FrameId.fromJson(json['frameId']),
      delay: json['delay'],
      reason: json['reason'],
      url: json['url'],
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

  /// Default dialog prompt.
  final String defaultPrompt;

  JavascriptDialogOpeningEvent({
    @required this.url,
    @required this.message,
    @required this.type,
    this.defaultPrompt,
  });

  factory JavascriptDialogOpeningEvent.fromJson(Map json) {
    return new JavascriptDialogOpeningEvent(
      url: json['url'],
      message: json['message'],
      type: new DialogType.fromJson(json['type']),
      defaultPrompt:
          json.containsKey('defaultPrompt') ? json['defaultPrompt'] : null,
    );
  }
}

class JavascriptDialogClosedEvent {
  /// Whether dialog was confirmed.
  final bool result;

  /// User input in case of prompt.
  final String userInput;

  JavascriptDialogClosedEvent({
    @required this.result,
    @required this.userInput,
  });

  factory JavascriptDialogClosedEvent.fromJson(Map json) {
    return new JavascriptDialogClosedEvent(
      result: json['result'],
      userInput: json['userInput'],
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
    @required this.data,
    @required this.metadata,
    @required this.sessionId,
  });

  factory ScreencastFrameEvent.fromJson(Map json) {
    return new ScreencastFrameEvent(
      data: json['data'],
      metadata: new ScreencastFrameMetadata.fromJson(json['metadata']),
      sessionId: json['sessionId'],
    );
  }
}

class GetNavigationHistoryResult {
  /// Index of the current navigation history entry.
  final int currentIndex;

  /// Array of navigation history entries.
  final List<NavigationEntry> entries;

  GetNavigationHistoryResult({
    @required this.currentIndex,
    @required this.entries,
  });

  factory GetNavigationHistoryResult.fromJson(Map json) {
    return new GetNavigationHistoryResult(
      currentIndex: json['currentIndex'],
      entries: (json['entries'] as List)
          .map((e) => new NavigationEntry.fromJson(e))
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
    @required this.content,
    @required this.base64Encoded,
  });

  factory GetResourceContentResult.fromJson(Map json) {
    return new GetResourceContentResult(
      content: json['content'],
      base64Encoded: json['base64Encoded'],
    );
  }
}

class GetAppManifestResult {
  /// Manifest location.
  final String url;

  final List<AppManifestError> errors;

  /// Manifest content.
  final String data;

  GetAppManifestResult({
    @required this.url,
    @required this.errors,
    this.data,
  });

  factory GetAppManifestResult.fromJson(Map json) {
    return new GetAppManifestResult(
      url: json['url'],
      errors: (json['errors'] as List)
          .map((e) => new AppManifestError.fromJson(e))
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

  GetLayoutMetricsResult({
    @required this.layoutViewport,
    @required this.visualViewport,
    @required this.contentSize,
  });

  factory GetLayoutMetricsResult.fromJson(Map json) {
    return new GetLayoutMetricsResult(
      layoutViewport: new LayoutViewport.fromJson(json['layoutViewport']),
      visualViewport: new VisualViewport.fromJson(json['visualViewport']),
      contentSize: new dom.Rect.fromJson(json['contentSize']),
    );
  }
}

/// Resource type as it was perceived by the rendering engine.
class ResourceType {
  static const ResourceType document = const ResourceType._('Document');
  static const ResourceType stylesheet = const ResourceType._('Stylesheet');
  static const ResourceType image = const ResourceType._('Image');
  static const ResourceType media = const ResourceType._('Media');
  static const ResourceType font = const ResourceType._('Font');
  static const ResourceType script = const ResourceType._('Script');
  static const ResourceType textTrack = const ResourceType._('TextTrack');
  static const ResourceType xHR = const ResourceType._('XHR');
  static const ResourceType fetch = const ResourceType._('Fetch');
  static const ResourceType eventSource = const ResourceType._('EventSource');
  static const ResourceType webSocket = const ResourceType._('WebSocket');
  static const ResourceType manifest = const ResourceType._('Manifest');
  static const ResourceType other = const ResourceType._('Other');
  static const values = const {
    'Document': document,
    'Stylesheet': stylesheet,
    'Image': image,
    'Media': media,
    'Font': font,
    'Script': script,
    'TextTrack': textTrack,
    'XHR': xHR,
    'Fetch': fetch,
    'EventSource': eventSource,
    'WebSocket': webSocket,
    'Manifest': manifest,
    'Other': other,
  };

  final String value;

  const ResourceType._(this.value);

  factory ResourceType.fromJson(String value) => values[value];

  String toJson() => value;
}

/// Unique frame identifier.
class FrameId {
  final String value;

  FrameId(this.value);

  factory FrameId.fromJson(String value) => new FrameId(value);

  String toJson() => value;
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

  Frame({
    @required this.id,
    this.parentId,
    @required this.loaderId,
    this.name,
    @required this.url,
    @required this.securityOrigin,
    @required this.mimeType,
    this.unreachableUrl,
  });

  factory Frame.fromJson(Map json) {
    return new Frame(
      id: json['id'],
      parentId: json.containsKey('parentId') ? json['parentId'] : null,
      loaderId: new network.LoaderId.fromJson(json['loaderId']),
      name: json.containsKey('name') ? json['name'] : null,
      url: json['url'],
      securityOrigin: json['securityOrigin'],
      mimeType: json['mimeType'],
      unreachableUrl:
          json.containsKey('unreachableUrl') ? json['unreachableUrl'] : null,
    );
  }

  Map toJson() {
    Map json = {
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
  final ResourceType type;

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

  FrameResource({
    @required this.url,
    @required this.type,
    @required this.mimeType,
    this.lastModified,
    this.contentSize,
    this.failed,
    this.canceled,
  });

  factory FrameResource.fromJson(Map json) {
    return new FrameResource(
      url: json['url'],
      type: new ResourceType.fromJson(json['type']),
      mimeType: json['mimeType'],
      lastModified: json.containsKey('lastModified')
          ? new network.TimeSinceEpoch.fromJson(json['lastModified'])
          : null,
      contentSize: json.containsKey('contentSize') ? json['contentSize'] : null,
      failed: json.containsKey('failed') ? json['failed'] : null,
      canceled: json.containsKey('canceled') ? json['canceled'] : null,
    );
  }

  Map toJson() {
    Map json = {
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

  FrameResourceTree({
    @required this.frame,
    this.childFrames,
    @required this.resources,
  });

  factory FrameResourceTree.fromJson(Map json) {
    return new FrameResourceTree(
      frame: new Frame.fromJson(json['frame']),
      childFrames: json.containsKey('childFrames')
          ? (json['childFrames'] as List)
              .map((e) => new FrameResourceTree.fromJson(e))
              .toList()
          : null,
      resources: (json['resources'] as List)
          .map((e) => new FrameResource.fromJson(e))
          .toList(),
    );
  }

  Map toJson() {
    Map json = {
      'frame': frame.toJson(),
      'resources': resources.map((e) => e.toJson()).toList(),
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

  factory ScriptIdentifier.fromJson(String value) =>
      new ScriptIdentifier(value);

  String toJson() => value;
}

/// Transition type.
class TransitionType {
  static const TransitionType link = const TransitionType._('link');
  static const TransitionType typed = const TransitionType._('typed');
  static const TransitionType autoBookmark =
      const TransitionType._('auto_bookmark');
  static const TransitionType autoSubframe =
      const TransitionType._('auto_subframe');
  static const TransitionType manualSubframe =
      const TransitionType._('manual_subframe');
  static const TransitionType generated = const TransitionType._('generated');
  static const TransitionType autoToplevel =
      const TransitionType._('auto_toplevel');
  static const TransitionType formSubmit =
      const TransitionType._('form_submit');
  static const TransitionType reload = const TransitionType._('reload');
  static const TransitionType keyword = const TransitionType._('keyword');
  static const TransitionType keywordGenerated =
      const TransitionType._('keyword_generated');
  static const TransitionType other = const TransitionType._('other');
  static const values = const {
    'link': link,
    'typed': typed,
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
    @required this.id,
    @required this.url,
    @required this.userTypedURL,
    @required this.title,
    @required this.transitionType,
  });

  factory NavigationEntry.fromJson(Map json) {
    return new NavigationEntry(
      id: json['id'],
      url: json['url'],
      userTypedURL: json['userTypedURL'],
      title: json['title'],
      transitionType: new TransitionType.fromJson(json['transitionType']),
    );
  }

  Map toJson() {
    Map json = {
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

  ScreencastFrameMetadata({
    @required this.offsetTop,
    @required this.pageScaleFactor,
    @required this.deviceWidth,
    @required this.deviceHeight,
    @required this.scrollOffsetX,
    @required this.scrollOffsetY,
    this.timestamp,
  });

  factory ScreencastFrameMetadata.fromJson(Map json) {
    return new ScreencastFrameMetadata(
      offsetTop: json['offsetTop'],
      pageScaleFactor: json['pageScaleFactor'],
      deviceWidth: json['deviceWidth'],
      deviceHeight: json['deviceHeight'],
      scrollOffsetX: json['scrollOffsetX'],
      scrollOffsetY: json['scrollOffsetY'],
      timestamp: json.containsKey('timestamp')
          ? new network.TimeSinceEpoch.fromJson(json['timestamp'])
          : null,
    );
  }

  Map toJson() {
    Map json = {
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
  static const DialogType alert = const DialogType._('alert');
  static const DialogType confirm = const DialogType._('confirm');
  static const DialogType prompt = const DialogType._('prompt');
  static const DialogType beforeunload = const DialogType._('beforeunload');
  static const values = const {
    'alert': alert,
    'confirm': confirm,
    'prompt': prompt,
    'beforeunload': beforeunload,
  };

  final String value;

  const DialogType._(this.value);

  factory DialogType.fromJson(String value) => values[value];

  String toJson() => value;
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

  AppManifestError({
    @required this.message,
    @required this.critical,
    @required this.line,
    @required this.column,
  });

  factory AppManifestError.fromJson(Map json) {
    return new AppManifestError(
      message: json['message'],
      critical: json['critical'],
      line: json['line'],
      column: json['column'],
    );
  }

  Map toJson() {
    Map json = {
      'message': message,
      'critical': critical,
      'line': line,
      'column': column,
    };
    return json;
  }
}

/// Proceed: allow the navigation; Cancel: cancel the navigation; CancelAndIgnore: cancels the navigation and makes the requester of the navigation acts like the request was never made.
class NavigationResponse {
  static const NavigationResponse proceed =
      const NavigationResponse._('Proceed');
  static const NavigationResponse cancel = const NavigationResponse._('Cancel');
  static const NavigationResponse cancelAndIgnore =
      const NavigationResponse._('CancelAndIgnore');
  static const values = const {
    'Proceed': proceed,
    'Cancel': cancel,
    'CancelAndIgnore': cancelAndIgnore,
  };

  final String value;

  const NavigationResponse._(this.value);

  factory NavigationResponse.fromJson(String value) => values[value];

  String toJson() => value;
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
    @required this.pageX,
    @required this.pageY,
    @required this.clientWidth,
    @required this.clientHeight,
  });

  factory LayoutViewport.fromJson(Map json) {
    return new LayoutViewport(
      pageX: json['pageX'],
      pageY: json['pageY'],
      clientWidth: json['clientWidth'],
      clientHeight: json['clientHeight'],
    );
  }

  Map toJson() {
    Map json = {
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

  VisualViewport({
    @required this.offsetX,
    @required this.offsetY,
    @required this.pageX,
    @required this.pageY,
    @required this.clientWidth,
    @required this.clientHeight,
    @required this.scale,
  });

  factory VisualViewport.fromJson(Map json) {
    return new VisualViewport(
      offsetX: json['offsetX'],
      offsetY: json['offsetY'],
      pageX: json['pageX'],
      pageY: json['pageY'],
      clientWidth: json['clientWidth'],
      clientHeight: json['clientHeight'],
      scale: json['scale'],
    );
  }

  Map toJson() {
    Map json = {
      'offsetX': offsetX,
      'offsetY': offsetY,
      'pageX': pageX,
      'pageY': pageY,
      'clientWidth': clientWidth,
      'clientHeight': clientHeight,
      'scale': scale,
    };
    return json;
  }
}

/// Viewport for capturing screenshot.
class Viewport {
  /// X offset in CSS pixels.
  final num x;

  /// Y offset in CSS pixels
  final num y;

  /// Rectangle width in CSS pixels
  final num width;

  /// Rectangle height in CSS pixels
  final num height;

  /// Page scale factor.
  final num scale;

  Viewport({
    @required this.x,
    @required this.y,
    @required this.width,
    @required this.height,
    @required this.scale,
  });

  factory Viewport.fromJson(Map json) {
    return new Viewport(
      x: json['x'],
      y: json['y'],
      width: json['width'],
      height: json['height'],
      scale: json['scale'],
    );
  }

  Map toJson() {
    Map json = {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'scale': scale,
    };
    return json;
  }
}
