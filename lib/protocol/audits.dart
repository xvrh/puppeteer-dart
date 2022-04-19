import 'dart:async';
import '../src/connection.dart';
import 'dom.dart' as dom;
import 'network.dart' as network;
import 'page.dart' as page;
import 'runtime.dart' as runtime;

/// Audits domain allows investigation of page violations and possible improvements.
class AuditsApi {
  final Client _client;

  AuditsApi(this._client);

  Stream<InspectorIssue> get onIssueAdded => _client.onEvent
      .where((event) => event.name == 'Audits.issueAdded')
      .map((event) => InspectorIssue.fromJson(
          event.parameters['issue'] as Map<String, dynamic>));

  /// Returns the response body and size if it were re-encoded with the specified settings. Only
  /// applies to images.
  /// [requestId] Identifier of the network request to get content for.
  /// [encoding] The encoding to use.
  /// [quality] The quality of the encoding (0-1). (defaults to 1)
  /// [sizeOnly] Whether to only return the size information (defaults to false).
  Future<GetEncodedResponseResult> getEncodedResponse(
      network.RequestId requestId,
      @Enum(['webp', 'jpeg', 'png']) String encoding,
      {num? quality,
      bool? sizeOnly}) async {
    assert(const ['webp', 'jpeg', 'png'].contains(encoding));
    var result = await _client.send('Audits.getEncodedResponse', {
      'requestId': requestId,
      'encoding': encoding,
      if (quality != null) 'quality': quality,
      if (sizeOnly != null) 'sizeOnly': sizeOnly,
    });
    return GetEncodedResponseResult.fromJson(result);
  }

  /// Disables issues domain, prevents further issues from being reported to the client.
  Future<void> disable() async {
    await _client.send('Audits.disable');
  }

  /// Enables issues domain, sends the issues collected so far to the client by means of the
  /// `issueAdded` event.
  Future<void> enable() async {
    await _client.send('Audits.enable');
  }

  /// Runs the contrast check for the target page. Found issues are reported
  /// using Audits.issueAdded event.
  /// [reportAAA] Whether to report WCAG AAA level issues. Default is false.
  Future<void> checkContrast({bool? reportAAA}) async {
    await _client.send('Audits.checkContrast', {
      if (reportAAA != null) 'reportAAA': reportAAA,
    });
  }
}

class GetEncodedResponseResult {
  /// The encoded body as a base64 string. Omitted if sizeOnly is true.
  final String? body;

  /// Size before re-encoding.
  final int originalSize;

  /// Size after re-encoding.
  final int encodedSize;

  GetEncodedResponseResult(
      {this.body, required this.originalSize, required this.encodedSize});

  factory GetEncodedResponseResult.fromJson(Map<String, dynamic> json) {
    return GetEncodedResponseResult(
      body: json.containsKey('body') ? json['body'] as String : null,
      originalSize: json['originalSize'] as int,
      encodedSize: json['encodedSize'] as int,
    );
  }
}

/// Information about a cookie that is affected by an inspector issue.
class AffectedCookie {
  /// The following three properties uniquely identify a cookie
  final String name;

  final String path;

  final String domain;

  AffectedCookie(
      {required this.name, required this.path, required this.domain});

  factory AffectedCookie.fromJson(Map<String, dynamic> json) {
    return AffectedCookie(
      name: json['name'] as String,
      path: json['path'] as String,
      domain: json['domain'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'domain': domain,
    };
  }
}

/// Information about a request that is affected by an inspector issue.
class AffectedRequest {
  /// The unique request id.
  final network.RequestId requestId;

  final String? url;

  AffectedRequest({required this.requestId, this.url});

  factory AffectedRequest.fromJson(Map<String, dynamic> json) {
    return AffectedRequest(
      requestId: network.RequestId.fromJson(json['requestId'] as String),
      url: json.containsKey('url') ? json['url'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId.toJson(),
      if (url != null) 'url': url,
    };
  }
}

/// Information about the frame affected by an inspector issue.
class AffectedFrame {
  final page.FrameId frameId;

  AffectedFrame({required this.frameId});

  factory AffectedFrame.fromJson(Map<String, dynamic> json) {
    return AffectedFrame(
      frameId: page.FrameId.fromJson(json['frameId'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frameId': frameId.toJson(),
    };
  }
}

class CookieExclusionReason {
  static const excludeSameSiteUnspecifiedTreatedAsLax =
      CookieExclusionReason._('ExcludeSameSiteUnspecifiedTreatedAsLax');
  static const excludeSameSiteNoneInsecure =
      CookieExclusionReason._('ExcludeSameSiteNoneInsecure');
  static const excludeSameSiteLax =
      CookieExclusionReason._('ExcludeSameSiteLax');
  static const excludeSameSiteStrict =
      CookieExclusionReason._('ExcludeSameSiteStrict');
  static const excludeInvalidSameParty =
      CookieExclusionReason._('ExcludeInvalidSameParty');
  static const excludeSamePartyCrossPartyContext =
      CookieExclusionReason._('ExcludeSamePartyCrossPartyContext');
  static const values = {
    'ExcludeSameSiteUnspecifiedTreatedAsLax':
        excludeSameSiteUnspecifiedTreatedAsLax,
    'ExcludeSameSiteNoneInsecure': excludeSameSiteNoneInsecure,
    'ExcludeSameSiteLax': excludeSameSiteLax,
    'ExcludeSameSiteStrict': excludeSameSiteStrict,
    'ExcludeInvalidSameParty': excludeInvalidSameParty,
    'ExcludeSamePartyCrossPartyContext': excludeSamePartyCrossPartyContext,
  };

  final String value;

  const CookieExclusionReason._(this.value);

  factory CookieExclusionReason.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CookieExclusionReason && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class CookieWarningReason {
  static const warnSameSiteUnspecifiedCrossSiteContext =
      CookieWarningReason._('WarnSameSiteUnspecifiedCrossSiteContext');
  static const warnSameSiteNoneInsecure =
      CookieWarningReason._('WarnSameSiteNoneInsecure');
  static const warnSameSiteUnspecifiedLaxAllowUnsafe =
      CookieWarningReason._('WarnSameSiteUnspecifiedLaxAllowUnsafe');
  static const warnSameSiteStrictLaxDowngradeStrict =
      CookieWarningReason._('WarnSameSiteStrictLaxDowngradeStrict');
  static const warnSameSiteStrictCrossDowngradeStrict =
      CookieWarningReason._('WarnSameSiteStrictCrossDowngradeStrict');
  static const warnSameSiteStrictCrossDowngradeLax =
      CookieWarningReason._('WarnSameSiteStrictCrossDowngradeLax');
  static const warnSameSiteLaxCrossDowngradeStrict =
      CookieWarningReason._('WarnSameSiteLaxCrossDowngradeStrict');
  static const warnSameSiteLaxCrossDowngradeLax =
      CookieWarningReason._('WarnSameSiteLaxCrossDowngradeLax');
  static const warnAttributeValueExceedsMaxSize =
      CookieWarningReason._('WarnAttributeValueExceedsMaxSize');
  static const values = {
    'WarnSameSiteUnspecifiedCrossSiteContext':
        warnSameSiteUnspecifiedCrossSiteContext,
    'WarnSameSiteNoneInsecure': warnSameSiteNoneInsecure,
    'WarnSameSiteUnspecifiedLaxAllowUnsafe':
        warnSameSiteUnspecifiedLaxAllowUnsafe,
    'WarnSameSiteStrictLaxDowngradeStrict':
        warnSameSiteStrictLaxDowngradeStrict,
    'WarnSameSiteStrictCrossDowngradeStrict':
        warnSameSiteStrictCrossDowngradeStrict,
    'WarnSameSiteStrictCrossDowngradeLax': warnSameSiteStrictCrossDowngradeLax,
    'WarnSameSiteLaxCrossDowngradeStrict': warnSameSiteLaxCrossDowngradeStrict,
    'WarnSameSiteLaxCrossDowngradeLax': warnSameSiteLaxCrossDowngradeLax,
    'WarnAttributeValueExceedsMaxSize': warnAttributeValueExceedsMaxSize,
  };

  final String value;

  const CookieWarningReason._(this.value);

  factory CookieWarningReason.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CookieWarningReason && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class CookieOperation {
  static const setCookie = CookieOperation._('SetCookie');
  static const readCookie = CookieOperation._('ReadCookie');
  static const values = {
    'SetCookie': setCookie,
    'ReadCookie': readCookie,
  };

  final String value;

  const CookieOperation._(this.value);

  factory CookieOperation.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CookieOperation && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// This information is currently necessary, as the front-end has a difficult
/// time finding a specific cookie. With this, we can convey specific error
/// information without the cookie.
class CookieIssueDetails {
  /// If AffectedCookie is not set then rawCookieLine contains the raw
  /// Set-Cookie header string. This hints at a problem where the
  /// cookie line is syntactically or semantically malformed in a way
  /// that no valid cookie could be created.
  final AffectedCookie? cookie;

  final String? rawCookieLine;

  final List<CookieWarningReason> cookieWarningReasons;

  final List<CookieExclusionReason> cookieExclusionReasons;

  /// Optionally identifies the site-for-cookies and the cookie url, which
  /// may be used by the front-end as additional context.
  final CookieOperation operation;

  final String? siteForCookies;

  final String? cookieUrl;

  final AffectedRequest? request;

  CookieIssueDetails(
      {this.cookie,
      this.rawCookieLine,
      required this.cookieWarningReasons,
      required this.cookieExclusionReasons,
      required this.operation,
      this.siteForCookies,
      this.cookieUrl,
      this.request});

  factory CookieIssueDetails.fromJson(Map<String, dynamic> json) {
    return CookieIssueDetails(
      cookie: json.containsKey('cookie')
          ? AffectedCookie.fromJson(json['cookie'] as Map<String, dynamic>)
          : null,
      rawCookieLine: json.containsKey('rawCookieLine')
          ? json['rawCookieLine'] as String
          : null,
      cookieWarningReasons: (json['cookieWarningReasons'] as List)
          .map((e) => CookieWarningReason.fromJson(e as String))
          .toList(),
      cookieExclusionReasons: (json['cookieExclusionReasons'] as List)
          .map((e) => CookieExclusionReason.fromJson(e as String))
          .toList(),
      operation: CookieOperation.fromJson(json['operation'] as String),
      siteForCookies: json.containsKey('siteForCookies')
          ? json['siteForCookies'] as String
          : null,
      cookieUrl:
          json.containsKey('cookieUrl') ? json['cookieUrl'] as String : null,
      request: json.containsKey('request')
          ? AffectedRequest.fromJson(json['request'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cookieWarningReasons':
          cookieWarningReasons.map((e) => e.toJson()).toList(),
      'cookieExclusionReasons':
          cookieExclusionReasons.map((e) => e.toJson()).toList(),
      'operation': operation.toJson(),
      if (cookie != null) 'cookie': cookie!.toJson(),
      if (rawCookieLine != null) 'rawCookieLine': rawCookieLine,
      if (siteForCookies != null) 'siteForCookies': siteForCookies,
      if (cookieUrl != null) 'cookieUrl': cookieUrl,
      if (request != null) 'request': request!.toJson(),
    };
  }
}

class MixedContentResolutionStatus {
  static const mixedContentBlocked =
      MixedContentResolutionStatus._('MixedContentBlocked');
  static const mixedContentAutomaticallyUpgraded =
      MixedContentResolutionStatus._('MixedContentAutomaticallyUpgraded');
  static const mixedContentWarning =
      MixedContentResolutionStatus._('MixedContentWarning');
  static const values = {
    'MixedContentBlocked': mixedContentBlocked,
    'MixedContentAutomaticallyUpgraded': mixedContentAutomaticallyUpgraded,
    'MixedContentWarning': mixedContentWarning,
  };

  final String value;

  const MixedContentResolutionStatus._(this.value);

  factory MixedContentResolutionStatus.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is MixedContentResolutionStatus && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class MixedContentResourceType {
  static const attributionSrc = MixedContentResourceType._('AttributionSrc');
  static const audio = MixedContentResourceType._('Audio');
  static const beacon = MixedContentResourceType._('Beacon');
  static const cspReport = MixedContentResourceType._('CSPReport');
  static const download = MixedContentResourceType._('Download');
  static const eventSource = MixedContentResourceType._('EventSource');
  static const favicon = MixedContentResourceType._('Favicon');
  static const font = MixedContentResourceType._('Font');
  static const form = MixedContentResourceType._('Form');
  static const frame = MixedContentResourceType._('Frame');
  static const image = MixedContentResourceType._('Image');
  static const import$ = MixedContentResourceType._('Import');
  static const manifest = MixedContentResourceType._('Manifest');
  static const ping = MixedContentResourceType._('Ping');
  static const pluginData = MixedContentResourceType._('PluginData');
  static const pluginResource = MixedContentResourceType._('PluginResource');
  static const prefetch = MixedContentResourceType._('Prefetch');
  static const resource = MixedContentResourceType._('Resource');
  static const script = MixedContentResourceType._('Script');
  static const serviceWorker = MixedContentResourceType._('ServiceWorker');
  static const sharedWorker = MixedContentResourceType._('SharedWorker');
  static const stylesheet = MixedContentResourceType._('Stylesheet');
  static const track = MixedContentResourceType._('Track');
  static const video = MixedContentResourceType._('Video');
  static const worker = MixedContentResourceType._('Worker');
  static const xmlHttpRequest = MixedContentResourceType._('XMLHttpRequest');
  static const xslt = MixedContentResourceType._('XSLT');
  static const values = {
    'AttributionSrc': attributionSrc,
    'Audio': audio,
    'Beacon': beacon,
    'CSPReport': cspReport,
    'Download': download,
    'EventSource': eventSource,
    'Favicon': favicon,
    'Font': font,
    'Form': form,
    'Frame': frame,
    'Image': image,
    'Import': import$,
    'Manifest': manifest,
    'Ping': ping,
    'PluginData': pluginData,
    'PluginResource': pluginResource,
    'Prefetch': prefetch,
    'Resource': resource,
    'Script': script,
    'ServiceWorker': serviceWorker,
    'SharedWorker': sharedWorker,
    'Stylesheet': stylesheet,
    'Track': track,
    'Video': video,
    'Worker': worker,
    'XMLHttpRequest': xmlHttpRequest,
    'XSLT': xslt,
  };

  final String value;

  const MixedContentResourceType._(this.value);

  factory MixedContentResourceType.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is MixedContentResourceType && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class MixedContentIssueDetails {
  /// The type of resource causing the mixed content issue (css, js, iframe,
  /// form,...). Marked as optional because it is mapped to from
  /// blink::mojom::RequestContextType, which will be replaced
  /// by network::mojom::RequestDestination
  final MixedContentResourceType? resourceType;

  /// The way the mixed content issue is being resolved.
  final MixedContentResolutionStatus resolutionStatus;

  /// The unsafe http url causing the mixed content issue.
  final String insecureURL;

  /// The url responsible for the call to an unsafe url.
  final String mainResourceURL;

  /// The mixed content request.
  /// Does not always exist (e.g. for unsafe form submission urls).
  final AffectedRequest? request;

  /// Optional because not every mixed content issue is necessarily linked to a frame.
  final AffectedFrame? frame;

  MixedContentIssueDetails(
      {this.resourceType,
      required this.resolutionStatus,
      required this.insecureURL,
      required this.mainResourceURL,
      this.request,
      this.frame});

  factory MixedContentIssueDetails.fromJson(Map<String, dynamic> json) {
    return MixedContentIssueDetails(
      resourceType: json.containsKey('resourceType')
          ? MixedContentResourceType.fromJson(json['resourceType'] as String)
          : null,
      resolutionStatus: MixedContentResolutionStatus.fromJson(
          json['resolutionStatus'] as String),
      insecureURL: json['insecureURL'] as String,
      mainResourceURL: json['mainResourceURL'] as String,
      request: json.containsKey('request')
          ? AffectedRequest.fromJson(json['request'] as Map<String, dynamic>)
          : null,
      frame: json.containsKey('frame')
          ? AffectedFrame.fromJson(json['frame'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resolutionStatus': resolutionStatus.toJson(),
      'insecureURL': insecureURL,
      'mainResourceURL': mainResourceURL,
      if (resourceType != null) 'resourceType': resourceType!.toJson(),
      if (request != null) 'request': request!.toJson(),
      if (frame != null) 'frame': frame!.toJson(),
    };
  }
}

/// Enum indicating the reason a response has been blocked. These reasons are
/// refinements of the net error BLOCKED_BY_RESPONSE.
class BlockedByResponseReason {
  static const coepFrameResourceNeedsCoepHeader =
      BlockedByResponseReason._('CoepFrameResourceNeedsCoepHeader');
  static const coopSandboxedIFrameCannotNavigateToCoopPage =
      BlockedByResponseReason._('CoopSandboxedIFrameCannotNavigateToCoopPage');
  static const corpNotSameOrigin =
      BlockedByResponseReason._('CorpNotSameOrigin');
  static const corpNotSameOriginAfterDefaultedToSameOriginByCoep =
      BlockedByResponseReason._(
          'CorpNotSameOriginAfterDefaultedToSameOriginByCoep');
  static const corpNotSameSite = BlockedByResponseReason._('CorpNotSameSite');
  static const values = {
    'CoepFrameResourceNeedsCoepHeader': coepFrameResourceNeedsCoepHeader,
    'CoopSandboxedIFrameCannotNavigateToCoopPage':
        coopSandboxedIFrameCannotNavigateToCoopPage,
    'CorpNotSameOrigin': corpNotSameOrigin,
    'CorpNotSameOriginAfterDefaultedToSameOriginByCoep':
        corpNotSameOriginAfterDefaultedToSameOriginByCoep,
    'CorpNotSameSite': corpNotSameSite,
  };

  final String value;

  const BlockedByResponseReason._(this.value);

  factory BlockedByResponseReason.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is BlockedByResponseReason && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Details for a request that has been blocked with the BLOCKED_BY_RESPONSE
/// code. Currently only used for COEP/COOP, but may be extended to include
/// some CSP errors in the future.
class BlockedByResponseIssueDetails {
  final AffectedRequest request;

  final AffectedFrame? parentFrame;

  final AffectedFrame? blockedFrame;

  final BlockedByResponseReason reason;

  BlockedByResponseIssueDetails(
      {required this.request,
      this.parentFrame,
      this.blockedFrame,
      required this.reason});

  factory BlockedByResponseIssueDetails.fromJson(Map<String, dynamic> json) {
    return BlockedByResponseIssueDetails(
      request:
          AffectedRequest.fromJson(json['request'] as Map<String, dynamic>),
      parentFrame: json.containsKey('parentFrame')
          ? AffectedFrame.fromJson(json['parentFrame'] as Map<String, dynamic>)
          : null,
      blockedFrame: json.containsKey('blockedFrame')
          ? AffectedFrame.fromJson(json['blockedFrame'] as Map<String, dynamic>)
          : null,
      reason: BlockedByResponseReason.fromJson(json['reason'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request': request.toJson(),
      'reason': reason.toJson(),
      if (parentFrame != null) 'parentFrame': parentFrame!.toJson(),
      if (blockedFrame != null) 'blockedFrame': blockedFrame!.toJson(),
    };
  }
}

class HeavyAdResolutionStatus {
  static const heavyAdBlocked = HeavyAdResolutionStatus._('HeavyAdBlocked');
  static const heavyAdWarning = HeavyAdResolutionStatus._('HeavyAdWarning');
  static const values = {
    'HeavyAdBlocked': heavyAdBlocked,
    'HeavyAdWarning': heavyAdWarning,
  };

  final String value;

  const HeavyAdResolutionStatus._(this.value);

  factory HeavyAdResolutionStatus.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is HeavyAdResolutionStatus && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class HeavyAdReason {
  static const networkTotalLimit = HeavyAdReason._('NetworkTotalLimit');
  static const cpuTotalLimit = HeavyAdReason._('CpuTotalLimit');
  static const cpuPeakLimit = HeavyAdReason._('CpuPeakLimit');
  static const values = {
    'NetworkTotalLimit': networkTotalLimit,
    'CpuTotalLimit': cpuTotalLimit,
    'CpuPeakLimit': cpuPeakLimit,
  };

  final String value;

  const HeavyAdReason._(this.value);

  factory HeavyAdReason.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is HeavyAdReason && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class HeavyAdIssueDetails {
  /// The resolution status, either blocking the content or warning.
  final HeavyAdResolutionStatus resolution;

  /// The reason the ad was blocked, total network or cpu or peak cpu.
  final HeavyAdReason reason;

  /// The frame that was blocked.
  final AffectedFrame frame;

  HeavyAdIssueDetails(
      {required this.resolution, required this.reason, required this.frame});

  factory HeavyAdIssueDetails.fromJson(Map<String, dynamic> json) {
    return HeavyAdIssueDetails(
      resolution:
          HeavyAdResolutionStatus.fromJson(json['resolution'] as String),
      reason: HeavyAdReason.fromJson(json['reason'] as String),
      frame: AffectedFrame.fromJson(json['frame'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resolution': resolution.toJson(),
      'reason': reason.toJson(),
      'frame': frame.toJson(),
    };
  }
}

class ContentSecurityPolicyViolationType {
  static const kInlineViolation =
      ContentSecurityPolicyViolationType._('kInlineViolation');
  static const kEvalViolation =
      ContentSecurityPolicyViolationType._('kEvalViolation');
  static const kUrlViolation =
      ContentSecurityPolicyViolationType._('kURLViolation');
  static const kTrustedTypesSinkViolation =
      ContentSecurityPolicyViolationType._('kTrustedTypesSinkViolation');
  static const kTrustedTypesPolicyViolation =
      ContentSecurityPolicyViolationType._('kTrustedTypesPolicyViolation');
  static const kWasmEvalViolation =
      ContentSecurityPolicyViolationType._('kWasmEvalViolation');
  static const values = {
    'kInlineViolation': kInlineViolation,
    'kEvalViolation': kEvalViolation,
    'kURLViolation': kUrlViolation,
    'kTrustedTypesSinkViolation': kTrustedTypesSinkViolation,
    'kTrustedTypesPolicyViolation': kTrustedTypesPolicyViolation,
    'kWasmEvalViolation': kWasmEvalViolation,
  };

  final String value;

  const ContentSecurityPolicyViolationType._(this.value);

  factory ContentSecurityPolicyViolationType.fromJson(String value) =>
      values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ContentSecurityPolicyViolationType && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class SourceCodeLocation {
  final runtime.ScriptId? scriptId;

  final String url;

  final int lineNumber;

  final int columnNumber;

  SourceCodeLocation(
      {this.scriptId,
      required this.url,
      required this.lineNumber,
      required this.columnNumber});

  factory SourceCodeLocation.fromJson(Map<String, dynamic> json) {
    return SourceCodeLocation(
      scriptId: json.containsKey('scriptId')
          ? runtime.ScriptId.fromJson(json['scriptId'] as String)
          : null,
      url: json['url'] as String,
      lineNumber: json['lineNumber'] as int,
      columnNumber: json['columnNumber'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'lineNumber': lineNumber,
      'columnNumber': columnNumber,
      if (scriptId != null) 'scriptId': scriptId!.toJson(),
    };
  }
}

class ContentSecurityPolicyIssueDetails {
  /// The url not included in allowed sources.
  final String? blockedURL;

  /// Specific directive that is violated, causing the CSP issue.
  final String violatedDirective;

  final bool isReportOnly;

  final ContentSecurityPolicyViolationType contentSecurityPolicyViolationType;

  final AffectedFrame? frameAncestor;

  final SourceCodeLocation? sourceCodeLocation;

  final dom.BackendNodeId? violatingNodeId;

  ContentSecurityPolicyIssueDetails(
      {this.blockedURL,
      required this.violatedDirective,
      required this.isReportOnly,
      required this.contentSecurityPolicyViolationType,
      this.frameAncestor,
      this.sourceCodeLocation,
      this.violatingNodeId});

  factory ContentSecurityPolicyIssueDetails.fromJson(
      Map<String, dynamic> json) {
    return ContentSecurityPolicyIssueDetails(
      blockedURL:
          json.containsKey('blockedURL') ? json['blockedURL'] as String : null,
      violatedDirective: json['violatedDirective'] as String,
      isReportOnly: json['isReportOnly'] as bool? ?? false,
      contentSecurityPolicyViolationType:
          ContentSecurityPolicyViolationType.fromJson(
              json['contentSecurityPolicyViolationType'] as String),
      frameAncestor: json.containsKey('frameAncestor')
          ? AffectedFrame.fromJson(
              json['frameAncestor'] as Map<String, dynamic>)
          : null,
      sourceCodeLocation: json.containsKey('sourceCodeLocation')
          ? SourceCodeLocation.fromJson(
              json['sourceCodeLocation'] as Map<String, dynamic>)
          : null,
      violatingNodeId: json.containsKey('violatingNodeId')
          ? dom.BackendNodeId.fromJson(json['violatingNodeId'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'violatedDirective': violatedDirective,
      'isReportOnly': isReportOnly,
      'contentSecurityPolicyViolationType':
          contentSecurityPolicyViolationType.toJson(),
      if (blockedURL != null) 'blockedURL': blockedURL,
      if (frameAncestor != null) 'frameAncestor': frameAncestor!.toJson(),
      if (sourceCodeLocation != null)
        'sourceCodeLocation': sourceCodeLocation!.toJson(),
      if (violatingNodeId != null) 'violatingNodeId': violatingNodeId!.toJson(),
    };
  }
}

class SharedArrayBufferIssueType {
  static const transferIssue = SharedArrayBufferIssueType._('TransferIssue');
  static const creationIssue = SharedArrayBufferIssueType._('CreationIssue');
  static const values = {
    'TransferIssue': transferIssue,
    'CreationIssue': creationIssue,
  };

  final String value;

  const SharedArrayBufferIssueType._(this.value);

  factory SharedArrayBufferIssueType.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is SharedArrayBufferIssueType && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Details for a issue arising from an SAB being instantiated in, or
/// transferred to a context that is not cross-origin isolated.
class SharedArrayBufferIssueDetails {
  final SourceCodeLocation sourceCodeLocation;

  final bool isWarning;

  final SharedArrayBufferIssueType type;

  SharedArrayBufferIssueDetails(
      {required this.sourceCodeLocation,
      required this.isWarning,
      required this.type});

  factory SharedArrayBufferIssueDetails.fromJson(Map<String, dynamic> json) {
    return SharedArrayBufferIssueDetails(
      sourceCodeLocation: SourceCodeLocation.fromJson(
          json['sourceCodeLocation'] as Map<String, dynamic>),
      isWarning: json['isWarning'] as bool? ?? false,
      type: SharedArrayBufferIssueType.fromJson(json['type'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceCodeLocation': sourceCodeLocation.toJson(),
      'isWarning': isWarning,
      'type': type.toJson(),
    };
  }
}

class TwaQualityEnforcementViolationType {
  static const kHttpError = TwaQualityEnforcementViolationType._('kHttpError');
  static const kUnavailableOffline =
      TwaQualityEnforcementViolationType._('kUnavailableOffline');
  static const kDigitalAssetLinks =
      TwaQualityEnforcementViolationType._('kDigitalAssetLinks');
  static const values = {
    'kHttpError': kHttpError,
    'kUnavailableOffline': kUnavailableOffline,
    'kDigitalAssetLinks': kDigitalAssetLinks,
  };

  final String value;

  const TwaQualityEnforcementViolationType._(this.value);

  factory TwaQualityEnforcementViolationType.fromJson(String value) =>
      values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is TwaQualityEnforcementViolationType && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class TrustedWebActivityIssueDetails {
  /// The url that triggers the violation.
  final String url;

  final TwaQualityEnforcementViolationType violationType;

  final int? httpStatusCode;

  /// The package name of the Trusted Web Activity client app. This field is
  /// only used when violation type is kDigitalAssetLinks.
  final String? packageName;

  /// The signature of the Trusted Web Activity client app. This field is only
  /// used when violation type is kDigitalAssetLinks.
  final String? signature;

  TrustedWebActivityIssueDetails(
      {required this.url,
      required this.violationType,
      this.httpStatusCode,
      this.packageName,
      this.signature});

  factory TrustedWebActivityIssueDetails.fromJson(Map<String, dynamic> json) {
    return TrustedWebActivityIssueDetails(
      url: json['url'] as String,
      violationType: TwaQualityEnforcementViolationType.fromJson(
          json['violationType'] as String),
      httpStatusCode: json.containsKey('httpStatusCode')
          ? json['httpStatusCode'] as int
          : null,
      packageName: json.containsKey('packageName')
          ? json['packageName'] as String
          : null,
      signature:
          json.containsKey('signature') ? json['signature'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'violationType': violationType.toJson(),
      if (httpStatusCode != null) 'httpStatusCode': httpStatusCode,
      if (packageName != null) 'packageName': packageName,
      if (signature != null) 'signature': signature,
    };
  }
}

class LowTextContrastIssueDetails {
  final dom.BackendNodeId violatingNodeId;

  final String violatingNodeSelector;

  final num contrastRatio;

  final num thresholdAA;

  final num thresholdAAA;

  final String fontSize;

  final String fontWeight;

  LowTextContrastIssueDetails(
      {required this.violatingNodeId,
      required this.violatingNodeSelector,
      required this.contrastRatio,
      required this.thresholdAA,
      required this.thresholdAAA,
      required this.fontSize,
      required this.fontWeight});

  factory LowTextContrastIssueDetails.fromJson(Map<String, dynamic> json) {
    return LowTextContrastIssueDetails(
      violatingNodeId:
          dom.BackendNodeId.fromJson(json['violatingNodeId'] as int),
      violatingNodeSelector: json['violatingNodeSelector'] as String,
      contrastRatio: json['contrastRatio'] as num,
      thresholdAA: json['thresholdAA'] as num,
      thresholdAAA: json['thresholdAAA'] as num,
      fontSize: json['fontSize'] as String,
      fontWeight: json['fontWeight'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'violatingNodeId': violatingNodeId.toJson(),
      'violatingNodeSelector': violatingNodeSelector,
      'contrastRatio': contrastRatio,
      'thresholdAA': thresholdAA,
      'thresholdAAA': thresholdAAA,
      'fontSize': fontSize,
      'fontWeight': fontWeight,
    };
  }
}

/// Details for a CORS related issue, e.g. a warning or error related to
/// CORS RFC1918 enforcement.
class CorsIssueDetails {
  final network.CorsErrorStatus corsErrorStatus;

  final bool isWarning;

  final AffectedRequest request;

  final SourceCodeLocation? location;

  final String? initiatorOrigin;

  final network.IPAddressSpace? resourceIPAddressSpace;

  final network.ClientSecurityState? clientSecurityState;

  CorsIssueDetails(
      {required this.corsErrorStatus,
      required this.isWarning,
      required this.request,
      this.location,
      this.initiatorOrigin,
      this.resourceIPAddressSpace,
      this.clientSecurityState});

  factory CorsIssueDetails.fromJson(Map<String, dynamic> json) {
    return CorsIssueDetails(
      corsErrorStatus: network.CorsErrorStatus.fromJson(
          json['corsErrorStatus'] as Map<String, dynamic>),
      isWarning: json['isWarning'] as bool? ?? false,
      request:
          AffectedRequest.fromJson(json['request'] as Map<String, dynamic>),
      location: json.containsKey('location')
          ? SourceCodeLocation.fromJson(
              json['location'] as Map<String, dynamic>)
          : null,
      initiatorOrigin: json.containsKey('initiatorOrigin')
          ? json['initiatorOrigin'] as String
          : null,
      resourceIPAddressSpace: json.containsKey('resourceIPAddressSpace')
          ? network.IPAddressSpace.fromJson(
              json['resourceIPAddressSpace'] as String)
          : null,
      clientSecurityState: json.containsKey('clientSecurityState')
          ? network.ClientSecurityState.fromJson(
              json['clientSecurityState'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'corsErrorStatus': corsErrorStatus.toJson(),
      'isWarning': isWarning,
      'request': request.toJson(),
      if (location != null) 'location': location!.toJson(),
      if (initiatorOrigin != null) 'initiatorOrigin': initiatorOrigin,
      if (resourceIPAddressSpace != null)
        'resourceIPAddressSpace': resourceIPAddressSpace!.toJson(),
      if (clientSecurityState != null)
        'clientSecurityState': clientSecurityState!.toJson(),
    };
  }
}

class AttributionReportingIssueType {
  static const permissionPolicyDisabled =
      AttributionReportingIssueType._('PermissionPolicyDisabled');
  static const invalidAttributionSourceEventId =
      AttributionReportingIssueType._('InvalidAttributionSourceEventId');
  static const invalidAttributionData =
      AttributionReportingIssueType._('InvalidAttributionData');
  static const attributionSourceUntrustworthyOrigin =
      AttributionReportingIssueType._('AttributionSourceUntrustworthyOrigin');
  static const attributionUntrustworthyOrigin =
      AttributionReportingIssueType._('AttributionUntrustworthyOrigin');
  static const attributionTriggerDataTooLarge =
      AttributionReportingIssueType._('AttributionTriggerDataTooLarge');
  static const attributionEventSourceTriggerDataTooLarge =
      AttributionReportingIssueType._(
          'AttributionEventSourceTriggerDataTooLarge');
  static const invalidAttributionSourceExpiry =
      AttributionReportingIssueType._('InvalidAttributionSourceExpiry');
  static const invalidAttributionSourcePriority =
      AttributionReportingIssueType._('InvalidAttributionSourcePriority');
  static const invalidEventSourceTriggerData =
      AttributionReportingIssueType._('InvalidEventSourceTriggerData');
  static const invalidTriggerPriority =
      AttributionReportingIssueType._('InvalidTriggerPriority');
  static const invalidTriggerDedupKey =
      AttributionReportingIssueType._('InvalidTriggerDedupKey');
  static const values = {
    'PermissionPolicyDisabled': permissionPolicyDisabled,
    'InvalidAttributionSourceEventId': invalidAttributionSourceEventId,
    'InvalidAttributionData': invalidAttributionData,
    'AttributionSourceUntrustworthyOrigin':
        attributionSourceUntrustworthyOrigin,
    'AttributionUntrustworthyOrigin': attributionUntrustworthyOrigin,
    'AttributionTriggerDataTooLarge': attributionTriggerDataTooLarge,
    'AttributionEventSourceTriggerDataTooLarge':
        attributionEventSourceTriggerDataTooLarge,
    'InvalidAttributionSourceExpiry': invalidAttributionSourceExpiry,
    'InvalidAttributionSourcePriority': invalidAttributionSourcePriority,
    'InvalidEventSourceTriggerData': invalidEventSourceTriggerData,
    'InvalidTriggerPriority': invalidTriggerPriority,
    'InvalidTriggerDedupKey': invalidTriggerDedupKey,
  };

  final String value;

  const AttributionReportingIssueType._(this.value);

  factory AttributionReportingIssueType.fromJson(String value) =>
      values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is AttributionReportingIssueType && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Details for issues around "Attribution Reporting API" usage.
/// Explainer: https://github.com/WICG/conversion-measurement-api
class AttributionReportingIssueDetails {
  final AttributionReportingIssueType violationType;

  final AffectedFrame? frame;

  final AffectedRequest? request;

  final dom.BackendNodeId? violatingNodeId;

  final String? invalidParameter;

  AttributionReportingIssueDetails(
      {required this.violationType,
      this.frame,
      this.request,
      this.violatingNodeId,
      this.invalidParameter});

  factory AttributionReportingIssueDetails.fromJson(Map<String, dynamic> json) {
    return AttributionReportingIssueDetails(
      violationType: AttributionReportingIssueType.fromJson(
          json['violationType'] as String),
      frame: json.containsKey('frame')
          ? AffectedFrame.fromJson(json['frame'] as Map<String, dynamic>)
          : null,
      request: json.containsKey('request')
          ? AffectedRequest.fromJson(json['request'] as Map<String, dynamic>)
          : null,
      violatingNodeId: json.containsKey('violatingNodeId')
          ? dom.BackendNodeId.fromJson(json['violatingNodeId'] as int)
          : null,
      invalidParameter: json.containsKey('invalidParameter')
          ? json['invalidParameter'] as String
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'violationType': violationType.toJson(),
      if (frame != null) 'frame': frame!.toJson(),
      if (request != null) 'request': request!.toJson(),
      if (violatingNodeId != null) 'violatingNodeId': violatingNodeId!.toJson(),
      if (invalidParameter != null) 'invalidParameter': invalidParameter,
    };
  }
}

/// Details for issues about documents in Quirks Mode
/// or Limited Quirks Mode that affects page layouting.
class QuirksModeIssueDetails {
  /// If false, it means the document's mode is "quirks"
  /// instead of "limited-quirks".
  final bool isLimitedQuirksMode;

  final dom.BackendNodeId documentNodeId;

  final String url;

  final page.FrameId frameId;

  final network.LoaderId loaderId;

  QuirksModeIssueDetails(
      {required this.isLimitedQuirksMode,
      required this.documentNodeId,
      required this.url,
      required this.frameId,
      required this.loaderId});

  factory QuirksModeIssueDetails.fromJson(Map<String, dynamic> json) {
    return QuirksModeIssueDetails(
      isLimitedQuirksMode: json['isLimitedQuirksMode'] as bool? ?? false,
      documentNodeId: dom.BackendNodeId.fromJson(json['documentNodeId'] as int),
      url: json['url'] as String,
      frameId: page.FrameId.fromJson(json['frameId'] as String),
      loaderId: network.LoaderId.fromJson(json['loaderId'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isLimitedQuirksMode': isLimitedQuirksMode,
      'documentNodeId': documentNodeId.toJson(),
      'url': url,
      'frameId': frameId.toJson(),
      'loaderId': loaderId.toJson(),
    };
  }
}

class NavigatorUserAgentIssueDetails {
  final String url;

  final SourceCodeLocation? location;

  NavigatorUserAgentIssueDetails({required this.url, this.location});

  factory NavigatorUserAgentIssueDetails.fromJson(Map<String, dynamic> json) {
    return NavigatorUserAgentIssueDetails(
      url: json['url'] as String,
      location: json.containsKey('location')
          ? SourceCodeLocation.fromJson(
              json['location'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      if (location != null) 'location': location!.toJson(),
    };
  }
}

class GenericIssueErrorType {
  static const crossOriginPortalPostMessageError =
      GenericIssueErrorType._('CrossOriginPortalPostMessageError');
  static const values = {
    'CrossOriginPortalPostMessageError': crossOriginPortalPostMessageError,
  };

  final String value;

  const GenericIssueErrorType._(this.value);

  factory GenericIssueErrorType.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is GenericIssueErrorType && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Depending on the concrete errorType, different properties are set.
class GenericIssueDetails {
  /// Issues with the same errorType are aggregated in the frontend.
  final GenericIssueErrorType errorType;

  final page.FrameId? frameId;

  GenericIssueDetails({required this.errorType, this.frameId});

  factory GenericIssueDetails.fromJson(Map<String, dynamic> json) {
    return GenericIssueDetails(
      errorType: GenericIssueErrorType.fromJson(json['errorType'] as String),
      frameId: json.containsKey('frameId')
          ? page.FrameId.fromJson(json['frameId'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'errorType': errorType.toJson(),
      if (frameId != null) 'frameId': frameId!.toJson(),
    };
  }
}

/// This issue tracks information needed to print a deprecation message.
/// The formatting is inherited from the old console.log version, see more at:
/// https://source.chromium.org/chromium/chromium/src/+/main:third_party/blink/renderer/core/frame/deprecation.cc
/// TODO(crbug.com/1264960): Re-work format to add i18n support per:
/// https://source.chromium.org/chromium/chromium/src/+/main:third_party/blink/public/devtools_protocol/README.md
class DeprecationIssueDetails {
  final AffectedFrame? affectedFrame;

  final SourceCodeLocation sourceCodeLocation;

  DeprecationIssueDetails(
      {this.affectedFrame, required this.sourceCodeLocation});

  factory DeprecationIssueDetails.fromJson(Map<String, dynamic> json) {
    return DeprecationIssueDetails(
      affectedFrame: json.containsKey('affectedFrame')
          ? AffectedFrame.fromJson(
              json['affectedFrame'] as Map<String, dynamic>)
          : null,
      sourceCodeLocation: SourceCodeLocation.fromJson(
          json['sourceCodeLocation'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceCodeLocation': sourceCodeLocation.toJson(),
      if (affectedFrame != null) 'affectedFrame': affectedFrame!.toJson(),
    };
  }
}

class ClientHintIssueReason {
  static const metaTagAllowListInvalidOrigin =
      ClientHintIssueReason._('MetaTagAllowListInvalidOrigin');
  static const metaTagModifiedHtml =
      ClientHintIssueReason._('MetaTagModifiedHTML');
  static const values = {
    'MetaTagAllowListInvalidOrigin': metaTagAllowListInvalidOrigin,
    'MetaTagModifiedHTML': metaTagModifiedHtml,
  };

  final String value;

  const ClientHintIssueReason._(this.value);

  factory ClientHintIssueReason.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ClientHintIssueReason && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class FederatedAuthRequestIssueDetails {
  final FederatedAuthRequestIssueReason federatedAuthRequestIssueReason;

  FederatedAuthRequestIssueDetails(
      {required this.federatedAuthRequestIssueReason});

  factory FederatedAuthRequestIssueDetails.fromJson(Map<String, dynamic> json) {
    return FederatedAuthRequestIssueDetails(
      federatedAuthRequestIssueReason: FederatedAuthRequestIssueReason.fromJson(
          json['federatedAuthRequestIssueReason'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'federatedAuthRequestIssueReason':
          federatedAuthRequestIssueReason.toJson(),
    };
  }
}

/// Represents the failure reason when a federated authentication reason fails.
/// Should be updated alongside RequestIdTokenStatus in
/// third_party/blink/public/mojom/devtools/inspector_issue.mojom to include
/// all cases except for success.
class FederatedAuthRequestIssueReason {
  static const approvalDeclined =
      FederatedAuthRequestIssueReason._('ApprovalDeclined');
  static const tooManyRequests =
      FederatedAuthRequestIssueReason._('TooManyRequests');
  static const manifestHttpNotFound =
      FederatedAuthRequestIssueReason._('ManifestHttpNotFound');
  static const manifestNoResponse =
      FederatedAuthRequestIssueReason._('ManifestNoResponse');
  static const manifestInvalidResponse =
      FederatedAuthRequestIssueReason._('ManifestInvalidResponse');
  static const clientMetadataHttpNotFound =
      FederatedAuthRequestIssueReason._('ClientMetadataHttpNotFound');
  static const clientMetadataNoResponse =
      FederatedAuthRequestIssueReason._('ClientMetadataNoResponse');
  static const clientMetadataInvalidResponse =
      FederatedAuthRequestIssueReason._('ClientMetadataInvalidResponse');
  static const clientMetadataMissingPrivacyPolicyUrl =
      FederatedAuthRequestIssueReason._(
          'ClientMetadataMissingPrivacyPolicyUrl');
  static const disabledInSettings =
      FederatedAuthRequestIssueReason._('DisabledInSettings');
  static const errorFetchingSignin =
      FederatedAuthRequestIssueReason._('ErrorFetchingSignin');
  static const invalidSigninResponse =
      FederatedAuthRequestIssueReason._('InvalidSigninResponse');
  static const accountsHttpNotFound =
      FederatedAuthRequestIssueReason._('AccountsHttpNotFound');
  static const accountsNoResponse =
      FederatedAuthRequestIssueReason._('AccountsNoResponse');
  static const accountsInvalidResponse =
      FederatedAuthRequestIssueReason._('AccountsInvalidResponse');
  static const idTokenHttpNotFound =
      FederatedAuthRequestIssueReason._('IdTokenHttpNotFound');
  static const idTokenNoResponse =
      FederatedAuthRequestIssueReason._('IdTokenNoResponse');
  static const idTokenInvalidResponse =
      FederatedAuthRequestIssueReason._('IdTokenInvalidResponse');
  static const idTokenInvalidRequest =
      FederatedAuthRequestIssueReason._('IdTokenInvalidRequest');
  static const errorIdToken = FederatedAuthRequestIssueReason._('ErrorIdToken');
  static const canceled = FederatedAuthRequestIssueReason._('Canceled');
  static const values = {
    'ApprovalDeclined': approvalDeclined,
    'TooManyRequests': tooManyRequests,
    'ManifestHttpNotFound': manifestHttpNotFound,
    'ManifestNoResponse': manifestNoResponse,
    'ManifestInvalidResponse': manifestInvalidResponse,
    'ClientMetadataHttpNotFound': clientMetadataHttpNotFound,
    'ClientMetadataNoResponse': clientMetadataNoResponse,
    'ClientMetadataInvalidResponse': clientMetadataInvalidResponse,
    'ClientMetadataMissingPrivacyPolicyUrl':
        clientMetadataMissingPrivacyPolicyUrl,
    'DisabledInSettings': disabledInSettings,
    'ErrorFetchingSignin': errorFetchingSignin,
    'InvalidSigninResponse': invalidSigninResponse,
    'AccountsHttpNotFound': accountsHttpNotFound,
    'AccountsNoResponse': accountsNoResponse,
    'AccountsInvalidResponse': accountsInvalidResponse,
    'IdTokenHttpNotFound': idTokenHttpNotFound,
    'IdTokenNoResponse': idTokenNoResponse,
    'IdTokenInvalidResponse': idTokenInvalidResponse,
    'IdTokenInvalidRequest': idTokenInvalidRequest,
    'ErrorIdToken': errorIdToken,
    'Canceled': canceled,
  };

  final String value;

  const FederatedAuthRequestIssueReason._(this.value);

  factory FederatedAuthRequestIssueReason.fromJson(String value) =>
      values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is FederatedAuthRequestIssueReason && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// This issue tracks client hints related issues. It's used to deprecate old
/// features, encourage the use of new ones, and provide general guidance.
class ClientHintIssueDetails {
  final SourceCodeLocation sourceCodeLocation;

  final ClientHintIssueReason clientHintIssueReason;

  ClientHintIssueDetails(
      {required this.sourceCodeLocation, required this.clientHintIssueReason});

  factory ClientHintIssueDetails.fromJson(Map<String, dynamic> json) {
    return ClientHintIssueDetails(
      sourceCodeLocation: SourceCodeLocation.fromJson(
          json['sourceCodeLocation'] as Map<String, dynamic>),
      clientHintIssueReason: ClientHintIssueReason.fromJson(
          json['clientHintIssueReason'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceCodeLocation': sourceCodeLocation.toJson(),
      'clientHintIssueReason': clientHintIssueReason.toJson(),
    };
  }
}

/// A unique identifier for the type of issue. Each type may use one of the
/// optional fields in InspectorIssueDetails to convey more specific
/// information about the kind of issue.
class InspectorIssueCode {
  static const cookieIssue = InspectorIssueCode._('CookieIssue');
  static const mixedContentIssue = InspectorIssueCode._('MixedContentIssue');
  static const blockedByResponseIssue =
      InspectorIssueCode._('BlockedByResponseIssue');
  static const heavyAdIssue = InspectorIssueCode._('HeavyAdIssue');
  static const contentSecurityPolicyIssue =
      InspectorIssueCode._('ContentSecurityPolicyIssue');
  static const sharedArrayBufferIssue =
      InspectorIssueCode._('SharedArrayBufferIssue');
  static const trustedWebActivityIssue =
      InspectorIssueCode._('TrustedWebActivityIssue');
  static const lowTextContrastIssue =
      InspectorIssueCode._('LowTextContrastIssue');
  static const corsIssue = InspectorIssueCode._('CorsIssue');
  static const attributionReportingIssue =
      InspectorIssueCode._('AttributionReportingIssue');
  static const quirksModeIssue = InspectorIssueCode._('QuirksModeIssue');
  static const navigatorUserAgentIssue =
      InspectorIssueCode._('NavigatorUserAgentIssue');
  static const genericIssue = InspectorIssueCode._('GenericIssue');
  static const deprecationIssue = InspectorIssueCode._('DeprecationIssue');
  static const clientHintIssue = InspectorIssueCode._('ClientHintIssue');
  static const federatedAuthRequestIssue =
      InspectorIssueCode._('FederatedAuthRequestIssue');
  static const values = {
    'CookieIssue': cookieIssue,
    'MixedContentIssue': mixedContentIssue,
    'BlockedByResponseIssue': blockedByResponseIssue,
    'HeavyAdIssue': heavyAdIssue,
    'ContentSecurityPolicyIssue': contentSecurityPolicyIssue,
    'SharedArrayBufferIssue': sharedArrayBufferIssue,
    'TrustedWebActivityIssue': trustedWebActivityIssue,
    'LowTextContrastIssue': lowTextContrastIssue,
    'CorsIssue': corsIssue,
    'AttributionReportingIssue': attributionReportingIssue,
    'QuirksModeIssue': quirksModeIssue,
    'NavigatorUserAgentIssue': navigatorUserAgentIssue,
    'GenericIssue': genericIssue,
    'DeprecationIssue': deprecationIssue,
    'ClientHintIssue': clientHintIssue,
    'FederatedAuthRequestIssue': federatedAuthRequestIssue,
  };

  final String value;

  const InspectorIssueCode._(this.value);

  factory InspectorIssueCode.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is InspectorIssueCode && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// This struct holds a list of optional fields with additional information
/// specific to the kind of issue. When adding a new issue code, please also
/// add a new optional field to this type.
class InspectorIssueDetails {
  final CookieIssueDetails? cookieIssueDetails;

  final MixedContentIssueDetails? mixedContentIssueDetails;

  final BlockedByResponseIssueDetails? blockedByResponseIssueDetails;

  final HeavyAdIssueDetails? heavyAdIssueDetails;

  final ContentSecurityPolicyIssueDetails? contentSecurityPolicyIssueDetails;

  final SharedArrayBufferIssueDetails? sharedArrayBufferIssueDetails;

  final TrustedWebActivityIssueDetails? twaQualityEnforcementDetails;

  final LowTextContrastIssueDetails? lowTextContrastIssueDetails;

  final CorsIssueDetails? corsIssueDetails;

  final AttributionReportingIssueDetails? attributionReportingIssueDetails;

  final QuirksModeIssueDetails? quirksModeIssueDetails;

  final NavigatorUserAgentIssueDetails? navigatorUserAgentIssueDetails;

  final GenericIssueDetails? genericIssueDetails;

  final DeprecationIssueDetails? deprecationIssueDetails;

  final ClientHintIssueDetails? clientHintIssueDetails;

  final FederatedAuthRequestIssueDetails? federatedAuthRequestIssueDetails;

  InspectorIssueDetails(
      {this.cookieIssueDetails,
      this.mixedContentIssueDetails,
      this.blockedByResponseIssueDetails,
      this.heavyAdIssueDetails,
      this.contentSecurityPolicyIssueDetails,
      this.sharedArrayBufferIssueDetails,
      this.twaQualityEnforcementDetails,
      this.lowTextContrastIssueDetails,
      this.corsIssueDetails,
      this.attributionReportingIssueDetails,
      this.quirksModeIssueDetails,
      this.navigatorUserAgentIssueDetails,
      this.genericIssueDetails,
      this.deprecationIssueDetails,
      this.clientHintIssueDetails,
      this.federatedAuthRequestIssueDetails});

  factory InspectorIssueDetails.fromJson(Map<String, dynamic> json) {
    return InspectorIssueDetails(
      cookieIssueDetails: json.containsKey('cookieIssueDetails')
          ? CookieIssueDetails.fromJson(
              json['cookieIssueDetails'] as Map<String, dynamic>)
          : null,
      mixedContentIssueDetails: json.containsKey('mixedContentIssueDetails')
          ? MixedContentIssueDetails.fromJson(
              json['mixedContentIssueDetails'] as Map<String, dynamic>)
          : null,
      blockedByResponseIssueDetails:
          json.containsKey('blockedByResponseIssueDetails')
              ? BlockedByResponseIssueDetails.fromJson(
                  json['blockedByResponseIssueDetails'] as Map<String, dynamic>)
              : null,
      heavyAdIssueDetails: json.containsKey('heavyAdIssueDetails')
          ? HeavyAdIssueDetails.fromJson(
              json['heavyAdIssueDetails'] as Map<String, dynamic>)
          : null,
      contentSecurityPolicyIssueDetails: json
              .containsKey('contentSecurityPolicyIssueDetails')
          ? ContentSecurityPolicyIssueDetails.fromJson(
              json['contentSecurityPolicyIssueDetails'] as Map<String, dynamic>)
          : null,
      sharedArrayBufferIssueDetails:
          json.containsKey('sharedArrayBufferIssueDetails')
              ? SharedArrayBufferIssueDetails.fromJson(
                  json['sharedArrayBufferIssueDetails'] as Map<String, dynamic>)
              : null,
      twaQualityEnforcementDetails:
          json.containsKey('twaQualityEnforcementDetails')
              ? TrustedWebActivityIssueDetails.fromJson(
                  json['twaQualityEnforcementDetails'] as Map<String, dynamic>)
              : null,
      lowTextContrastIssueDetails:
          json.containsKey('lowTextContrastIssueDetails')
              ? LowTextContrastIssueDetails.fromJson(
                  json['lowTextContrastIssueDetails'] as Map<String, dynamic>)
              : null,
      corsIssueDetails: json.containsKey('corsIssueDetails')
          ? CorsIssueDetails.fromJson(
              json['corsIssueDetails'] as Map<String, dynamic>)
          : null,
      attributionReportingIssueDetails: json
              .containsKey('attributionReportingIssueDetails')
          ? AttributionReportingIssueDetails.fromJson(
              json['attributionReportingIssueDetails'] as Map<String, dynamic>)
          : null,
      quirksModeIssueDetails: json.containsKey('quirksModeIssueDetails')
          ? QuirksModeIssueDetails.fromJson(
              json['quirksModeIssueDetails'] as Map<String, dynamic>)
          : null,
      navigatorUserAgentIssueDetails: json
              .containsKey('navigatorUserAgentIssueDetails')
          ? NavigatorUserAgentIssueDetails.fromJson(
              json['navigatorUserAgentIssueDetails'] as Map<String, dynamic>)
          : null,
      genericIssueDetails: json.containsKey('genericIssueDetails')
          ? GenericIssueDetails.fromJson(
              json['genericIssueDetails'] as Map<String, dynamic>)
          : null,
      deprecationIssueDetails: json.containsKey('deprecationIssueDetails')
          ? DeprecationIssueDetails.fromJson(
              json['deprecationIssueDetails'] as Map<String, dynamic>)
          : null,
      clientHintIssueDetails: json.containsKey('clientHintIssueDetails')
          ? ClientHintIssueDetails.fromJson(
              json['clientHintIssueDetails'] as Map<String, dynamic>)
          : null,
      federatedAuthRequestIssueDetails: json
              .containsKey('federatedAuthRequestIssueDetails')
          ? FederatedAuthRequestIssueDetails.fromJson(
              json['federatedAuthRequestIssueDetails'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (cookieIssueDetails != null)
        'cookieIssueDetails': cookieIssueDetails!.toJson(),
      if (mixedContentIssueDetails != null)
        'mixedContentIssueDetails': mixedContentIssueDetails!.toJson(),
      if (blockedByResponseIssueDetails != null)
        'blockedByResponseIssueDetails':
            blockedByResponseIssueDetails!.toJson(),
      if (heavyAdIssueDetails != null)
        'heavyAdIssueDetails': heavyAdIssueDetails!.toJson(),
      if (contentSecurityPolicyIssueDetails != null)
        'contentSecurityPolicyIssueDetails':
            contentSecurityPolicyIssueDetails!.toJson(),
      if (sharedArrayBufferIssueDetails != null)
        'sharedArrayBufferIssueDetails':
            sharedArrayBufferIssueDetails!.toJson(),
      if (twaQualityEnforcementDetails != null)
        'twaQualityEnforcementDetails': twaQualityEnforcementDetails!.toJson(),
      if (lowTextContrastIssueDetails != null)
        'lowTextContrastIssueDetails': lowTextContrastIssueDetails!.toJson(),
      if (corsIssueDetails != null)
        'corsIssueDetails': corsIssueDetails!.toJson(),
      if (attributionReportingIssueDetails != null)
        'attributionReportingIssueDetails':
            attributionReportingIssueDetails!.toJson(),
      if (quirksModeIssueDetails != null)
        'quirksModeIssueDetails': quirksModeIssueDetails!.toJson(),
      if (navigatorUserAgentIssueDetails != null)
        'navigatorUserAgentIssueDetails':
            navigatorUserAgentIssueDetails!.toJson(),
      if (genericIssueDetails != null)
        'genericIssueDetails': genericIssueDetails!.toJson(),
      if (deprecationIssueDetails != null)
        'deprecationIssueDetails': deprecationIssueDetails!.toJson(),
      if (clientHintIssueDetails != null)
        'clientHintIssueDetails': clientHintIssueDetails!.toJson(),
      if (federatedAuthRequestIssueDetails != null)
        'federatedAuthRequestIssueDetails':
            federatedAuthRequestIssueDetails!.toJson(),
    };
  }
}

/// A unique id for a DevTools inspector issue. Allows other entities (e.g.
/// exceptions, CDP message, console messages, etc.) to reference an issue.
class IssueId {
  final String value;

  IssueId(this.value);

  factory IssueId.fromJson(String value) => IssueId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is IssueId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// An inspector issue reported from the back-end.
class InspectorIssue {
  final InspectorIssueCode code;

  final InspectorIssueDetails details;

  /// A unique id for this issue. May be omitted if no other entity (e.g.
  /// exception, CDP message, etc.) is referencing this issue.
  final IssueId? issueId;

  InspectorIssue({required this.code, required this.details, this.issueId});

  factory InspectorIssue.fromJson(Map<String, dynamic> json) {
    return InspectorIssue(
      code: InspectorIssueCode.fromJson(json['code'] as String),
      details: InspectorIssueDetails.fromJson(
          json['details'] as Map<String, dynamic>),
      issueId: json.containsKey('issueId')
          ? IssueId.fromJson(json['issueId'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code.toJson(),
      'details': details.toJson(),
      if (issueId != null) 'issueId': issueId!.toJson(),
    };
  }
}
