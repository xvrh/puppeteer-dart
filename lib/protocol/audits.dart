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
      .map(
        (event) => InspectorIssue.fromJson(
          event.parameters['issue'] as Map<String, dynamic>,
        ),
      );

  /// Returns the response body and size if it were re-encoded with the specified settings. Only
  /// applies to images.
  /// [requestId] Identifier of the network request to get content for.
  /// [encoding] The encoding to use.
  /// [quality] The quality of the encoding (0-1). (defaults to 1)
  /// [sizeOnly] Whether to only return the size information (defaults to false).
  Future<GetEncodedResponseResult> getEncodedResponse(
    network.RequestId requestId,
    @Enum(['webp', 'jpeg', 'png']) String encoding, {
    num? quality,
    bool? sizeOnly,
  }) async {
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

  /// Runs the form issues check for the target page. Found issues are reported
  /// using Audits.issueAdded event.
  Future<List<GenericIssueDetails>> checkFormsIssues() async {
    var result = await _client.send('Audits.checkFormsIssues');
    return (result['formIssues'] as List)
        .map((e) => GenericIssueDetails.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class GetEncodedResponseResult {
  /// The encoded body as a base64 string. Omitted if sizeOnly is true.
  final String? body;

  /// Size before re-encoding.
  final int originalSize;

  /// Size after re-encoding.
  final int encodedSize;

  GetEncodedResponseResult({
    this.body,
    required this.originalSize,
    required this.encodedSize,
  });

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

  AffectedCookie({
    required this.name,
    required this.path,
    required this.domain,
  });

  factory AffectedCookie.fromJson(Map<String, dynamic> json) {
    return AffectedCookie(
      name: json['name'] as String,
      path: json['path'] as String,
      domain: json['domain'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'path': path, 'domain': domain};
  }
}

/// Information about a request that is affected by an inspector issue.
class AffectedRequest {
  /// The unique request id.
  final network.RequestId? requestId;

  final String url;

  AffectedRequest({this.requestId, required this.url});

  factory AffectedRequest.fromJson(Map<String, dynamic> json) {
    return AffectedRequest(
      requestId: json.containsKey('requestId')
          ? network.RequestId.fromJson(json['requestId'] as String)
          : null,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      if (requestId != null) 'requestId': requestId!.toJson(),
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
    return {'frameId': frameId.toJson()};
  }
}

enum CookieExclusionReason {
  excludeSameSiteUnspecifiedTreatedAsLax(
    'ExcludeSameSiteUnspecifiedTreatedAsLax',
  ),
  excludeSameSiteNoneInsecure('ExcludeSameSiteNoneInsecure'),
  excludeSameSiteLax('ExcludeSameSiteLax'),
  excludeSameSiteStrict('ExcludeSameSiteStrict'),
  excludeInvalidSameParty('ExcludeInvalidSameParty'),
  excludeSamePartyCrossPartyContext('ExcludeSamePartyCrossPartyContext'),
  excludeDomainNonAscii('ExcludeDomainNonASCII'),
  excludeThirdPartyCookieBlockedInFirstPartySet(
    'ExcludeThirdPartyCookieBlockedInFirstPartySet',
  ),
  excludeThirdPartyPhaseout('ExcludeThirdPartyPhaseout'),
  excludePortMismatch('ExcludePortMismatch'),
  excludeSchemeMismatch('ExcludeSchemeMismatch');

  final String value;

  const CookieExclusionReason(this.value);

  factory CookieExclusionReason.fromJson(String value) =>
      CookieExclusionReason.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum CookieWarningReason {
  warnSameSiteUnspecifiedCrossSiteContext(
    'WarnSameSiteUnspecifiedCrossSiteContext',
  ),
  warnSameSiteNoneInsecure('WarnSameSiteNoneInsecure'),
  warnSameSiteUnspecifiedLaxAllowUnsafe(
    'WarnSameSiteUnspecifiedLaxAllowUnsafe',
  ),
  warnSameSiteStrictLaxDowngradeStrict('WarnSameSiteStrictLaxDowngradeStrict'),
  warnSameSiteStrictCrossDowngradeStrict(
    'WarnSameSiteStrictCrossDowngradeStrict',
  ),
  warnSameSiteStrictCrossDowngradeLax('WarnSameSiteStrictCrossDowngradeLax'),
  warnSameSiteLaxCrossDowngradeStrict('WarnSameSiteLaxCrossDowngradeStrict'),
  warnSameSiteLaxCrossDowngradeLax('WarnSameSiteLaxCrossDowngradeLax'),
  warnAttributeValueExceedsMaxSize('WarnAttributeValueExceedsMaxSize'),
  warnDomainNonAscii('WarnDomainNonASCII'),
  warnThirdPartyPhaseout('WarnThirdPartyPhaseout'),
  warnCrossSiteRedirectDowngradeChangesInclusion(
    'WarnCrossSiteRedirectDowngradeChangesInclusion',
  ),
  warnDeprecationTrialMetadata('WarnDeprecationTrialMetadata'),
  warnThirdPartyCookieHeuristic('WarnThirdPartyCookieHeuristic');

  final String value;

  const CookieWarningReason(this.value);

  factory CookieWarningReason.fromJson(String value) =>
      CookieWarningReason.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum CookieOperation {
  setCookie('SetCookie'),
  readCookie('ReadCookie');

  final String value;

  const CookieOperation(this.value);

  factory CookieOperation.fromJson(String value) =>
      CookieOperation.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Represents the category of insight that a cookie issue falls under.
enum InsightType {
  gitHubResource('GitHubResource'),
  gracePeriod('GracePeriod'),
  heuristics('Heuristics');

  final String value;

  const InsightType(this.value);

  factory InsightType.fromJson(String value) =>
      InsightType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Information about the suggested solution to a cookie issue.
class CookieIssueInsight {
  final InsightType type;

  /// Link to table entry in third-party cookie migration readiness list.
  final String? tableEntryUrl;

  CookieIssueInsight({required this.type, this.tableEntryUrl});

  factory CookieIssueInsight.fromJson(Map<String, dynamic> json) {
    return CookieIssueInsight(
      type: InsightType.fromJson(json['type'] as String),
      tableEntryUrl: json.containsKey('tableEntryUrl')
          ? json['tableEntryUrl'] as String
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      if (tableEntryUrl != null) 'tableEntryUrl': tableEntryUrl,
    };
  }
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

  /// The recommended solution to the issue.
  final CookieIssueInsight? insight;

  CookieIssueDetails({
    this.cookie,
    this.rawCookieLine,
    required this.cookieWarningReasons,
    required this.cookieExclusionReasons,
    required this.operation,
    this.siteForCookies,
    this.cookieUrl,
    this.request,
    this.insight,
  });

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
      cookieUrl: json.containsKey('cookieUrl')
          ? json['cookieUrl'] as String
          : null,
      request: json.containsKey('request')
          ? AffectedRequest.fromJson(json['request'] as Map<String, dynamic>)
          : null,
      insight: json.containsKey('insight')
          ? CookieIssueInsight.fromJson(json['insight'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cookieWarningReasons': cookieWarningReasons
          .map((e) => e.toJson())
          .toList(),
      'cookieExclusionReasons': cookieExclusionReasons
          .map((e) => e.toJson())
          .toList(),
      'operation': operation.toJson(),
      if (cookie != null) 'cookie': cookie!.toJson(),
      if (rawCookieLine != null) 'rawCookieLine': rawCookieLine,
      if (siteForCookies != null) 'siteForCookies': siteForCookies,
      if (cookieUrl != null) 'cookieUrl': cookieUrl,
      if (request != null) 'request': request!.toJson(),
      if (insight != null) 'insight': insight!.toJson(),
    };
  }
}

enum MixedContentResolutionStatus {
  mixedContentBlocked('MixedContentBlocked'),
  mixedContentAutomaticallyUpgraded('MixedContentAutomaticallyUpgraded'),
  mixedContentWarning('MixedContentWarning');

  final String value;

  const MixedContentResolutionStatus(this.value);

  factory MixedContentResolutionStatus.fromJson(String value) =>
      MixedContentResolutionStatus.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum MixedContentResourceType {
  attributionSrc('AttributionSrc'),
  audio('Audio'),
  beacon('Beacon'),
  cspReport('CSPReport'),
  download('Download'),
  eventSource('EventSource'),
  favicon('Favicon'),
  font('Font'),
  form('Form'),
  frame('Frame'),
  image('Image'),
  import$('Import'),
  json('JSON'),
  manifest('Manifest'),
  ping('Ping'),
  pluginData('PluginData'),
  pluginResource('PluginResource'),
  prefetch('Prefetch'),
  resource('Resource'),
  script('Script'),
  serviceWorker('ServiceWorker'),
  sharedWorker('SharedWorker'),
  speculationRules('SpeculationRules'),
  stylesheet('Stylesheet'),
  track('Track'),
  video('Video'),
  worker('Worker'),
  xmlHttpRequest('XMLHttpRequest'),
  xslt('XSLT');

  final String value;

  const MixedContentResourceType(this.value);

  factory MixedContentResourceType.fromJson(String value) =>
      MixedContentResourceType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

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

  MixedContentIssueDetails({
    this.resourceType,
    required this.resolutionStatus,
    required this.insecureURL,
    required this.mainResourceURL,
    this.request,
    this.frame,
  });

  factory MixedContentIssueDetails.fromJson(Map<String, dynamic> json) {
    return MixedContentIssueDetails(
      resourceType: json.containsKey('resourceType')
          ? MixedContentResourceType.fromJson(json['resourceType'] as String)
          : null,
      resolutionStatus: MixedContentResolutionStatus.fromJson(
        json['resolutionStatus'] as String,
      ),
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
enum BlockedByResponseReason {
  coepFrameResourceNeedsCoepHeader('CoepFrameResourceNeedsCoepHeader'),
  coopSandboxedIFrameCannotNavigateToCoopPage(
    'CoopSandboxedIFrameCannotNavigateToCoopPage',
  ),
  corpNotSameOrigin('CorpNotSameOrigin'),
  corpNotSameOriginAfterDefaultedToSameOriginByCoep(
    'CorpNotSameOriginAfterDefaultedToSameOriginByCoep',
  ),
  corpNotSameOriginAfterDefaultedToSameOriginByDip(
    'CorpNotSameOriginAfterDefaultedToSameOriginByDip',
  ),
  corpNotSameOriginAfterDefaultedToSameOriginByCoepAndDip(
    'CorpNotSameOriginAfterDefaultedToSameOriginByCoepAndDip',
  ),
  corpNotSameSite('CorpNotSameSite'),
  sriMessageSignatureMismatch('SRIMessageSignatureMismatch');

  final String value;

  const BlockedByResponseReason(this.value);

  factory BlockedByResponseReason.fromJson(String value) =>
      BlockedByResponseReason.values.firstWhere((e) => e.value == value);

  String toJson() => value;

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

  BlockedByResponseIssueDetails({
    required this.request,
    this.parentFrame,
    this.blockedFrame,
    required this.reason,
  });

  factory BlockedByResponseIssueDetails.fromJson(Map<String, dynamic> json) {
    return BlockedByResponseIssueDetails(
      request: AffectedRequest.fromJson(
        json['request'] as Map<String, dynamic>,
      ),
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

enum HeavyAdResolutionStatus {
  heavyAdBlocked('HeavyAdBlocked'),
  heavyAdWarning('HeavyAdWarning');

  final String value;

  const HeavyAdResolutionStatus(this.value);

  factory HeavyAdResolutionStatus.fromJson(String value) =>
      HeavyAdResolutionStatus.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum HeavyAdReason {
  networkTotalLimit('NetworkTotalLimit'),
  cpuTotalLimit('CpuTotalLimit'),
  cpuPeakLimit('CpuPeakLimit');

  final String value;

  const HeavyAdReason(this.value);

  factory HeavyAdReason.fromJson(String value) =>
      HeavyAdReason.values.firstWhere((e) => e.value == value);

  String toJson() => value;

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

  HeavyAdIssueDetails({
    required this.resolution,
    required this.reason,
    required this.frame,
  });

  factory HeavyAdIssueDetails.fromJson(Map<String, dynamic> json) {
    return HeavyAdIssueDetails(
      resolution: HeavyAdResolutionStatus.fromJson(
        json['resolution'] as String,
      ),
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

enum ContentSecurityPolicyViolationType {
  kInlineViolation('kInlineViolation'),
  kEvalViolation('kEvalViolation'),
  kUrlViolation('kURLViolation'),
  kSriViolation('kSRIViolation'),
  kTrustedTypesSinkViolation('kTrustedTypesSinkViolation'),
  kTrustedTypesPolicyViolation('kTrustedTypesPolicyViolation'),
  kWasmEvalViolation('kWasmEvalViolation');

  final String value;

  const ContentSecurityPolicyViolationType(this.value);

  factory ContentSecurityPolicyViolationType.fromJson(String value) =>
      ContentSecurityPolicyViolationType.values.firstWhere(
        (e) => e.value == value,
      );

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class SourceCodeLocation {
  final runtime.ScriptId? scriptId;

  final String url;

  final int lineNumber;

  final int columnNumber;

  SourceCodeLocation({
    this.scriptId,
    required this.url,
    required this.lineNumber,
    required this.columnNumber,
  });

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

  ContentSecurityPolicyIssueDetails({
    this.blockedURL,
    required this.violatedDirective,
    required this.isReportOnly,
    required this.contentSecurityPolicyViolationType,
    this.frameAncestor,
    this.sourceCodeLocation,
    this.violatingNodeId,
  });

  factory ContentSecurityPolicyIssueDetails.fromJson(
    Map<String, dynamic> json,
  ) {
    return ContentSecurityPolicyIssueDetails(
      blockedURL: json.containsKey('blockedURL')
          ? json['blockedURL'] as String
          : null,
      violatedDirective: json['violatedDirective'] as String,
      isReportOnly: json['isReportOnly'] as bool? ?? false,
      contentSecurityPolicyViolationType:
          ContentSecurityPolicyViolationType.fromJson(
            json['contentSecurityPolicyViolationType'] as String,
          ),
      frameAncestor: json.containsKey('frameAncestor')
          ? AffectedFrame.fromJson(
              json['frameAncestor'] as Map<String, dynamic>,
            )
          : null,
      sourceCodeLocation: json.containsKey('sourceCodeLocation')
          ? SourceCodeLocation.fromJson(
              json['sourceCodeLocation'] as Map<String, dynamic>,
            )
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
      'contentSecurityPolicyViolationType': contentSecurityPolicyViolationType
          .toJson(),
      if (blockedURL != null) 'blockedURL': blockedURL,
      if (frameAncestor != null) 'frameAncestor': frameAncestor!.toJson(),
      if (sourceCodeLocation != null)
        'sourceCodeLocation': sourceCodeLocation!.toJson(),
      if (violatingNodeId != null) 'violatingNodeId': violatingNodeId!.toJson(),
    };
  }
}

enum SharedArrayBufferIssueType {
  transferIssue('TransferIssue'),
  creationIssue('CreationIssue');

  final String value;

  const SharedArrayBufferIssueType(this.value);

  factory SharedArrayBufferIssueType.fromJson(String value) =>
      SharedArrayBufferIssueType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Details for a issue arising from an SAB being instantiated in, or
/// transferred to a context that is not cross-origin isolated.
class SharedArrayBufferIssueDetails {
  final SourceCodeLocation sourceCodeLocation;

  final bool isWarning;

  final SharedArrayBufferIssueType type;

  SharedArrayBufferIssueDetails({
    required this.sourceCodeLocation,
    required this.isWarning,
    required this.type,
  });

  factory SharedArrayBufferIssueDetails.fromJson(Map<String, dynamic> json) {
    return SharedArrayBufferIssueDetails(
      sourceCodeLocation: SourceCodeLocation.fromJson(
        json['sourceCodeLocation'] as Map<String, dynamic>,
      ),
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

class LowTextContrastIssueDetails {
  final dom.BackendNodeId violatingNodeId;

  final String violatingNodeSelector;

  final num contrastRatio;

  final num thresholdAA;

  final num thresholdAAA;

  final String fontSize;

  final String fontWeight;

  LowTextContrastIssueDetails({
    required this.violatingNodeId,
    required this.violatingNodeSelector,
    required this.contrastRatio,
    required this.thresholdAA,
    required this.thresholdAAA,
    required this.fontSize,
    required this.fontWeight,
  });

  factory LowTextContrastIssueDetails.fromJson(Map<String, dynamic> json) {
    return LowTextContrastIssueDetails(
      violatingNodeId: dom.BackendNodeId.fromJson(
        json['violatingNodeId'] as int,
      ),
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

  CorsIssueDetails({
    required this.corsErrorStatus,
    required this.isWarning,
    required this.request,
    this.location,
    this.initiatorOrigin,
    this.resourceIPAddressSpace,
    this.clientSecurityState,
  });

  factory CorsIssueDetails.fromJson(Map<String, dynamic> json) {
    return CorsIssueDetails(
      corsErrorStatus: network.CorsErrorStatus.fromJson(
        json['corsErrorStatus'] as Map<String, dynamic>,
      ),
      isWarning: json['isWarning'] as bool? ?? false,
      request: AffectedRequest.fromJson(
        json['request'] as Map<String, dynamic>,
      ),
      location: json.containsKey('location')
          ? SourceCodeLocation.fromJson(
              json['location'] as Map<String, dynamic>,
            )
          : null,
      initiatorOrigin: json.containsKey('initiatorOrigin')
          ? json['initiatorOrigin'] as String
          : null,
      resourceIPAddressSpace: json.containsKey('resourceIPAddressSpace')
          ? network.IPAddressSpace.fromJson(
              json['resourceIPAddressSpace'] as String,
            )
          : null,
      clientSecurityState: json.containsKey('clientSecurityState')
          ? network.ClientSecurityState.fromJson(
              json['clientSecurityState'] as Map<String, dynamic>,
            )
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

enum AttributionReportingIssueType {
  permissionPolicyDisabled('PermissionPolicyDisabled'),
  untrustworthyReportingOrigin('UntrustworthyReportingOrigin'),
  insecureContext('InsecureContext'),
  invalidHeader('InvalidHeader'),
  invalidRegisterTriggerHeader('InvalidRegisterTriggerHeader'),
  sourceAndTriggerHeaders('SourceAndTriggerHeaders'),
  sourceIgnored('SourceIgnored'),
  triggerIgnored('TriggerIgnored'),
  osSourceIgnored('OsSourceIgnored'),
  osTriggerIgnored('OsTriggerIgnored'),
  invalidRegisterOsSourceHeader('InvalidRegisterOsSourceHeader'),
  invalidRegisterOsTriggerHeader('InvalidRegisterOsTriggerHeader'),
  webAndOsHeaders('WebAndOsHeaders'),
  noWebOrOsSupport('NoWebOrOsSupport'),
  navigationRegistrationWithoutTransientUserActivation(
    'NavigationRegistrationWithoutTransientUserActivation',
  ),
  invalidInfoHeader('InvalidInfoHeader'),
  noRegisterSourceHeader('NoRegisterSourceHeader'),
  noRegisterTriggerHeader('NoRegisterTriggerHeader'),
  noRegisterOsSourceHeader('NoRegisterOsSourceHeader'),
  noRegisterOsTriggerHeader('NoRegisterOsTriggerHeader'),
  navigationRegistrationUniqueScopeAlreadySet(
    'NavigationRegistrationUniqueScopeAlreadySet',
  );

  final String value;

  const AttributionReportingIssueType(this.value);

  factory AttributionReportingIssueType.fromJson(String value) =>
      AttributionReportingIssueType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum SharedDictionaryError {
  useErrorCrossOriginNoCorsRequest('UseErrorCrossOriginNoCorsRequest'),
  useErrorDictionaryLoadFailure('UseErrorDictionaryLoadFailure'),
  useErrorMatchingDictionaryNotUsed('UseErrorMatchingDictionaryNotUsed'),
  useErrorUnexpectedContentDictionaryHeader(
    'UseErrorUnexpectedContentDictionaryHeader',
  ),
  writeErrorCossOriginNoCorsRequest('WriteErrorCossOriginNoCorsRequest'),
  writeErrorDisallowedBySettings('WriteErrorDisallowedBySettings'),
  writeErrorExpiredResponse('WriteErrorExpiredResponse'),
  writeErrorFeatureDisabled('WriteErrorFeatureDisabled'),
  writeErrorInsufficientResources('WriteErrorInsufficientResources'),
  writeErrorInvalidMatchField('WriteErrorInvalidMatchField'),
  writeErrorInvalidStructuredHeader('WriteErrorInvalidStructuredHeader'),
  writeErrorNavigationRequest('WriteErrorNavigationRequest'),
  writeErrorNoMatchField('WriteErrorNoMatchField'),
  writeErrorNonListMatchDestField('WriteErrorNonListMatchDestField'),
  writeErrorNonSecureContext('WriteErrorNonSecureContext'),
  writeErrorNonStringIdField('WriteErrorNonStringIdField'),
  writeErrorNonStringInMatchDestList('WriteErrorNonStringInMatchDestList'),
  writeErrorNonStringMatchField('WriteErrorNonStringMatchField'),
  writeErrorNonTokenTypeField('WriteErrorNonTokenTypeField'),
  writeErrorRequestAborted('WriteErrorRequestAborted'),
  writeErrorShuttingDown('WriteErrorShuttingDown'),
  writeErrorTooLongIdField('WriteErrorTooLongIdField'),
  writeErrorUnsupportedType('WriteErrorUnsupportedType');

  final String value;

  const SharedDictionaryError(this.value);

  factory SharedDictionaryError.fromJson(String value) =>
      SharedDictionaryError.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum SRIMessageSignatureError {
  missingSignatureHeader('MissingSignatureHeader'),
  missingSignatureInputHeader('MissingSignatureInputHeader'),
  invalidSignatureHeader('InvalidSignatureHeader'),
  invalidSignatureInputHeader('InvalidSignatureInputHeader'),
  signatureHeaderValueIsNotByteSequence(
    'SignatureHeaderValueIsNotByteSequence',
  ),
  signatureHeaderValueIsParameterized('SignatureHeaderValueIsParameterized'),
  signatureHeaderValueIsIncorrectLength(
    'SignatureHeaderValueIsIncorrectLength',
  ),
  signatureInputHeaderMissingLabel('SignatureInputHeaderMissingLabel'),
  signatureInputHeaderValueNotInnerList(
    'SignatureInputHeaderValueNotInnerList',
  ),
  signatureInputHeaderValueMissingComponents(
    'SignatureInputHeaderValueMissingComponents',
  ),
  signatureInputHeaderInvalidComponentType(
    'SignatureInputHeaderInvalidComponentType',
  ),
  signatureInputHeaderInvalidComponentName(
    'SignatureInputHeaderInvalidComponentName',
  ),
  signatureInputHeaderInvalidHeaderComponentParameter(
    'SignatureInputHeaderInvalidHeaderComponentParameter',
  ),
  signatureInputHeaderInvalidDerivedComponentParameter(
    'SignatureInputHeaderInvalidDerivedComponentParameter',
  ),
  signatureInputHeaderKeyIdLength('SignatureInputHeaderKeyIdLength'),
  signatureInputHeaderInvalidParameter('SignatureInputHeaderInvalidParameter'),
  signatureInputHeaderMissingRequiredParameters(
    'SignatureInputHeaderMissingRequiredParameters',
  ),
  validationFailedSignatureExpired('ValidationFailedSignatureExpired'),
  validationFailedInvalidLength('ValidationFailedInvalidLength'),
  validationFailedSignatureMismatch('ValidationFailedSignatureMismatch'),
  validationFailedIntegrityMismatch('ValidationFailedIntegrityMismatch');

  final String value;

  const SRIMessageSignatureError(this.value);

  factory SRIMessageSignatureError.fromJson(String value) =>
      SRIMessageSignatureError.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Details for issues around "Attribution Reporting API" usage.
/// Explainer: https://github.com/WICG/attribution-reporting-api
class AttributionReportingIssueDetails {
  final AttributionReportingIssueType violationType;

  final AffectedRequest? request;

  final dom.BackendNodeId? violatingNodeId;

  final String? invalidParameter;

  AttributionReportingIssueDetails({
    required this.violationType,
    this.request,
    this.violatingNodeId,
    this.invalidParameter,
  });

  factory AttributionReportingIssueDetails.fromJson(Map<String, dynamic> json) {
    return AttributionReportingIssueDetails(
      violationType: AttributionReportingIssueType.fromJson(
        json['violationType'] as String,
      ),
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

  QuirksModeIssueDetails({
    required this.isLimitedQuirksMode,
    required this.documentNodeId,
    required this.url,
    required this.frameId,
    required this.loaderId,
  });

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
              json['location'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, if (location != null) 'location': location!.toJson()};
  }
}

class SharedDictionaryIssueDetails {
  final SharedDictionaryError sharedDictionaryError;

  final AffectedRequest request;

  SharedDictionaryIssueDetails({
    required this.sharedDictionaryError,
    required this.request,
  });

  factory SharedDictionaryIssueDetails.fromJson(Map<String, dynamic> json) {
    return SharedDictionaryIssueDetails(
      sharedDictionaryError: SharedDictionaryError.fromJson(
        json['sharedDictionaryError'] as String,
      ),
      request: AffectedRequest.fromJson(
        json['request'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sharedDictionaryError': sharedDictionaryError.toJson(),
      'request': request.toJson(),
    };
  }
}

class SRIMessageSignatureIssueDetails {
  final SRIMessageSignatureError error;

  final String signatureBase;

  final List<String> integrityAssertions;

  final AffectedRequest request;

  SRIMessageSignatureIssueDetails({
    required this.error,
    required this.signatureBase,
    required this.integrityAssertions,
    required this.request,
  });

  factory SRIMessageSignatureIssueDetails.fromJson(Map<String, dynamic> json) {
    return SRIMessageSignatureIssueDetails(
      error: SRIMessageSignatureError.fromJson(json['error'] as String),
      signatureBase: json['signatureBase'] as String,
      integrityAssertions: (json['integrityAssertions'] as List)
          .map((e) => e as String)
          .toList(),
      request: AffectedRequest.fromJson(
        json['request'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error.toJson(),
      'signatureBase': signatureBase,
      'integrityAssertions': [...integrityAssertions],
      'request': request.toJson(),
    };
  }
}

enum GenericIssueErrorType {
  formLabelForNameError('FormLabelForNameError'),
  formDuplicateIdForInputError('FormDuplicateIdForInputError'),
  formInputWithNoLabelError('FormInputWithNoLabelError'),
  formAutocompleteAttributeEmptyError('FormAutocompleteAttributeEmptyError'),
  formEmptyIdAndNameAttributesForInputError(
    'FormEmptyIdAndNameAttributesForInputError',
  ),
  formAriaLabelledByToNonExistingId('FormAriaLabelledByToNonExistingId'),
  formInputAssignedAutocompleteValueToIdOrNameAttributeError(
    'FormInputAssignedAutocompleteValueToIdOrNameAttributeError',
  ),
  formLabelHasNeitherForNorNestedInput('FormLabelHasNeitherForNorNestedInput'),
  formLabelForMatchesNonExistingIdError(
    'FormLabelForMatchesNonExistingIdError',
  ),
  formInputHasWrongButWellIntendedAutocompleteValueError(
    'FormInputHasWrongButWellIntendedAutocompleteValueError',
  ),
  responseWasBlockedByOrb('ResponseWasBlockedByORB');

  final String value;

  const GenericIssueErrorType(this.value);

  factory GenericIssueErrorType.fromJson(String value) =>
      GenericIssueErrorType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Depending on the concrete errorType, different properties are set.
class GenericIssueDetails {
  /// Issues with the same errorType are aggregated in the frontend.
  final GenericIssueErrorType errorType;

  final page.FrameId? frameId;

  final dom.BackendNodeId? violatingNodeId;

  final String? violatingNodeAttribute;

  final AffectedRequest? request;

  GenericIssueDetails({
    required this.errorType,
    this.frameId,
    this.violatingNodeId,
    this.violatingNodeAttribute,
    this.request,
  });

  factory GenericIssueDetails.fromJson(Map<String, dynamic> json) {
    return GenericIssueDetails(
      errorType: GenericIssueErrorType.fromJson(json['errorType'] as String),
      frameId: json.containsKey('frameId')
          ? page.FrameId.fromJson(json['frameId'] as String)
          : null,
      violatingNodeId: json.containsKey('violatingNodeId')
          ? dom.BackendNodeId.fromJson(json['violatingNodeId'] as int)
          : null,
      violatingNodeAttribute: json.containsKey('violatingNodeAttribute')
          ? json['violatingNodeAttribute'] as String
          : null,
      request: json.containsKey('request')
          ? AffectedRequest.fromJson(json['request'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'errorType': errorType.toJson(),
      if (frameId != null) 'frameId': frameId!.toJson(),
      if (violatingNodeId != null) 'violatingNodeId': violatingNodeId!.toJson(),
      if (violatingNodeAttribute != null)
        'violatingNodeAttribute': violatingNodeAttribute,
      if (request != null) 'request': request!.toJson(),
    };
  }
}

/// This issue tracks information needed to print a deprecation message.
/// https://source.chromium.org/chromium/chromium/src/+/main:third_party/blink/renderer/core/frame/third_party/blink/renderer/core/frame/deprecation/README.md
class DeprecationIssueDetails {
  final AffectedFrame? affectedFrame;

  final SourceCodeLocation sourceCodeLocation;

  /// One of the deprecation names from third_party/blink/renderer/core/frame/deprecation/deprecation.json5
  final String type;

  DeprecationIssueDetails({
    this.affectedFrame,
    required this.sourceCodeLocation,
    required this.type,
  });

  factory DeprecationIssueDetails.fromJson(Map<String, dynamic> json) {
    return DeprecationIssueDetails(
      affectedFrame: json.containsKey('affectedFrame')
          ? AffectedFrame.fromJson(
              json['affectedFrame'] as Map<String, dynamic>,
            )
          : null,
      sourceCodeLocation: SourceCodeLocation.fromJson(
        json['sourceCodeLocation'] as Map<String, dynamic>,
      ),
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceCodeLocation': sourceCodeLocation.toJson(),
      'type': type,
      if (affectedFrame != null) 'affectedFrame': affectedFrame!.toJson(),
    };
  }
}

/// This issue warns about sites in the redirect chain of a finished navigation
/// that may be flagged as trackers and have their state cleared if they don't
/// receive a user interaction. Note that in this context 'site' means eTLD+1.
/// For example, if the URL `https://example.test:80/bounce` was in the
/// redirect chain, the site reported would be `example.test`.
class BounceTrackingIssueDetails {
  final List<String> trackingSites;

  BounceTrackingIssueDetails({required this.trackingSites});

  factory BounceTrackingIssueDetails.fromJson(Map<String, dynamic> json) {
    return BounceTrackingIssueDetails(
      trackingSites: (json['trackingSites'] as List)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackingSites': [...trackingSites],
    };
  }
}

/// This issue warns about third-party sites that are accessing cookies on the
/// current page, and have been permitted due to having a global metadata grant.
/// Note that in this context 'site' means eTLD+1. For example, if the URL
/// `https://example.test:80/web_page` was accessing cookies, the site reported
/// would be `example.test`.
class CookieDeprecationMetadataIssueDetails {
  final List<String> allowedSites;

  final num optOutPercentage;

  final bool isOptOutTopLevel;

  final CookieOperation operation;

  CookieDeprecationMetadataIssueDetails({
    required this.allowedSites,
    required this.optOutPercentage,
    required this.isOptOutTopLevel,
    required this.operation,
  });

  factory CookieDeprecationMetadataIssueDetails.fromJson(
    Map<String, dynamic> json,
  ) {
    return CookieDeprecationMetadataIssueDetails(
      allowedSites: (json['allowedSites'] as List)
          .map((e) => e as String)
          .toList(),
      optOutPercentage: json['optOutPercentage'] as num,
      isOptOutTopLevel: json['isOptOutTopLevel'] as bool? ?? false,
      operation: CookieOperation.fromJson(json['operation'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowedSites': [...allowedSites],
      'optOutPercentage': optOutPercentage,
      'isOptOutTopLevel': isOptOutTopLevel,
      'operation': operation.toJson(),
    };
  }
}

enum ClientHintIssueReason {
  metaTagAllowListInvalidOrigin('MetaTagAllowListInvalidOrigin'),
  metaTagModifiedHtml('MetaTagModifiedHTML');

  final String value;

  const ClientHintIssueReason(this.value);

  factory ClientHintIssueReason.fromJson(String value) =>
      ClientHintIssueReason.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class FederatedAuthRequestIssueDetails {
  final FederatedAuthRequestIssueReason federatedAuthRequestIssueReason;

  FederatedAuthRequestIssueDetails({
    required this.federatedAuthRequestIssueReason,
  });

  factory FederatedAuthRequestIssueDetails.fromJson(Map<String, dynamic> json) {
    return FederatedAuthRequestIssueDetails(
      federatedAuthRequestIssueReason: FederatedAuthRequestIssueReason.fromJson(
        json['federatedAuthRequestIssueReason'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'federatedAuthRequestIssueReason': federatedAuthRequestIssueReason
          .toJson(),
    };
  }
}

/// Represents the failure reason when a federated authentication reason fails.
/// Should be updated alongside RequestIdTokenStatus in
/// third_party/blink/public/mojom/devtools/inspector_issue.mojom to include
/// all cases except for success.
enum FederatedAuthRequestIssueReason {
  shouldEmbargo('ShouldEmbargo'),
  tooManyRequests('TooManyRequests'),
  wellKnownHttpNotFound('WellKnownHttpNotFound'),
  wellKnownNoResponse('WellKnownNoResponse'),
  wellKnownInvalidResponse('WellKnownInvalidResponse'),
  wellKnownListEmpty('WellKnownListEmpty'),
  wellKnownInvalidContentType('WellKnownInvalidContentType'),
  configNotInWellKnown('ConfigNotInWellKnown'),
  wellKnownTooBig('WellKnownTooBig'),
  configHttpNotFound('ConfigHttpNotFound'),
  configNoResponse('ConfigNoResponse'),
  configInvalidResponse('ConfigInvalidResponse'),
  configInvalidContentType('ConfigInvalidContentType'),
  clientMetadataHttpNotFound('ClientMetadataHttpNotFound'),
  clientMetadataNoResponse('ClientMetadataNoResponse'),
  clientMetadataInvalidResponse('ClientMetadataInvalidResponse'),
  clientMetadataInvalidContentType('ClientMetadataInvalidContentType'),
  idpNotPotentiallyTrustworthy('IdpNotPotentiallyTrustworthy'),
  disabledInSettings('DisabledInSettings'),
  disabledInFlags('DisabledInFlags'),
  errorFetchingSignin('ErrorFetchingSignin'),
  invalidSigninResponse('InvalidSigninResponse'),
  accountsHttpNotFound('AccountsHttpNotFound'),
  accountsNoResponse('AccountsNoResponse'),
  accountsInvalidResponse('AccountsInvalidResponse'),
  accountsListEmpty('AccountsListEmpty'),
  accountsInvalidContentType('AccountsInvalidContentType'),
  idTokenHttpNotFound('IdTokenHttpNotFound'),
  idTokenNoResponse('IdTokenNoResponse'),
  idTokenInvalidResponse('IdTokenInvalidResponse'),
  idTokenIdpErrorResponse('IdTokenIdpErrorResponse'),
  idTokenCrossSiteIdpErrorResponse('IdTokenCrossSiteIdpErrorResponse'),
  idTokenInvalidRequest('IdTokenInvalidRequest'),
  idTokenInvalidContentType('IdTokenInvalidContentType'),
  errorIdToken('ErrorIdToken'),
  canceled('Canceled'),
  rpPageNotVisible('RpPageNotVisible'),
  silentMediationFailure('SilentMediationFailure'),
  thirdPartyCookiesBlocked('ThirdPartyCookiesBlocked'),
  notSignedInWithIdp('NotSignedInWithIdp'),
  missingTransientUserActivation('MissingTransientUserActivation'),
  replacedByActiveMode('ReplacedByActiveMode'),
  invalidFieldsSpecified('InvalidFieldsSpecified'),
  relyingPartyOriginIsOpaque('RelyingPartyOriginIsOpaque'),
  typeNotMatching('TypeNotMatching'),
  uiDismissedNoEmbargo('UiDismissedNoEmbargo'),
  corsError('CorsError'),
  suppressedBySegmentationPlatform('SuppressedBySegmentationPlatform');

  final String value;

  const FederatedAuthRequestIssueReason(this.value);

  factory FederatedAuthRequestIssueReason.fromJson(String value) =>
      FederatedAuthRequestIssueReason.values.firstWhere(
        (e) => e.value == value,
      );

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class FederatedAuthUserInfoRequestIssueDetails {
  final FederatedAuthUserInfoRequestIssueReason
  federatedAuthUserInfoRequestIssueReason;

  FederatedAuthUserInfoRequestIssueDetails({
    required this.federatedAuthUserInfoRequestIssueReason,
  });

  factory FederatedAuthUserInfoRequestIssueDetails.fromJson(
    Map<String, dynamic> json,
  ) {
    return FederatedAuthUserInfoRequestIssueDetails(
      federatedAuthUserInfoRequestIssueReason:
          FederatedAuthUserInfoRequestIssueReason.fromJson(
            json['federatedAuthUserInfoRequestIssueReason'] as String,
          ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'federatedAuthUserInfoRequestIssueReason':
          federatedAuthUserInfoRequestIssueReason.toJson(),
    };
  }
}

/// Represents the failure reason when a getUserInfo() call fails.
/// Should be updated alongside FederatedAuthUserInfoRequestResult in
/// third_party/blink/public/mojom/devtools/inspector_issue.mojom.
enum FederatedAuthUserInfoRequestIssueReason {
  notSameOrigin('NotSameOrigin'),
  notIframe('NotIframe'),
  notPotentiallyTrustworthy('NotPotentiallyTrustworthy'),
  noApiPermission('NoApiPermission'),
  notSignedInWithIdp('NotSignedInWithIdp'),
  noAccountSharingPermission('NoAccountSharingPermission'),
  invalidConfigOrWellKnown('InvalidConfigOrWellKnown'),
  invalidAccountsResponse('InvalidAccountsResponse'),
  noReturningUserFromFetchedAccounts('NoReturningUserFromFetchedAccounts');

  final String value;

  const FederatedAuthUserInfoRequestIssueReason(this.value);

  factory FederatedAuthUserInfoRequestIssueReason.fromJson(String value) =>
      FederatedAuthUserInfoRequestIssueReason.values.firstWhere(
        (e) => e.value == value,
      );

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// This issue tracks client hints related issues. It's used to deprecate old
/// features, encourage the use of new ones, and provide general guidance.
class ClientHintIssueDetails {
  final SourceCodeLocation sourceCodeLocation;

  final ClientHintIssueReason clientHintIssueReason;

  ClientHintIssueDetails({
    required this.sourceCodeLocation,
    required this.clientHintIssueReason,
  });

  factory ClientHintIssueDetails.fromJson(Map<String, dynamic> json) {
    return ClientHintIssueDetails(
      sourceCodeLocation: SourceCodeLocation.fromJson(
        json['sourceCodeLocation'] as Map<String, dynamic>,
      ),
      clientHintIssueReason: ClientHintIssueReason.fromJson(
        json['clientHintIssueReason'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceCodeLocation': sourceCodeLocation.toJson(),
      'clientHintIssueReason': clientHintIssueReason.toJson(),
    };
  }
}

class FailedRequestInfo {
  /// The URL that failed to load.
  final String url;

  /// The failure message for the failed request.
  final String failureMessage;

  final network.RequestId? requestId;

  FailedRequestInfo({
    required this.url,
    required this.failureMessage,
    this.requestId,
  });

  factory FailedRequestInfo.fromJson(Map<String, dynamic> json) {
    return FailedRequestInfo(
      url: json['url'] as String,
      failureMessage: json['failureMessage'] as String,
      requestId: json.containsKey('requestId')
          ? network.RequestId.fromJson(json['requestId'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'failureMessage': failureMessage,
      if (requestId != null) 'requestId': requestId!.toJson(),
    };
  }
}

enum PartitioningBlobURLInfo {
  blockedCrossPartitionFetching('BlockedCrossPartitionFetching'),
  enforceNoopenerForNavigation('EnforceNoopenerForNavigation');

  final String value;

  const PartitioningBlobURLInfo(this.value);

  factory PartitioningBlobURLInfo.fromJson(String value) =>
      PartitioningBlobURLInfo.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class PartitioningBlobURLIssueDetails {
  /// The BlobURL that failed to load.
  final String url;

  /// Additional information about the Partitioning Blob URL issue.
  final PartitioningBlobURLInfo partitioningBlobURLInfo;

  PartitioningBlobURLIssueDetails({
    required this.url,
    required this.partitioningBlobURLInfo,
  });

  factory PartitioningBlobURLIssueDetails.fromJson(Map<String, dynamic> json) {
    return PartitioningBlobURLIssueDetails(
      url: json['url'] as String,
      partitioningBlobURLInfo: PartitioningBlobURLInfo.fromJson(
        json['partitioningBlobURLInfo'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'partitioningBlobURLInfo': partitioningBlobURLInfo.toJson(),
    };
  }
}

enum SelectElementAccessibilityIssueReason {
  disallowedSelectChild('DisallowedSelectChild'),
  disallowedOptGroupChild('DisallowedOptGroupChild'),
  nonPhrasingContentOptionChild('NonPhrasingContentOptionChild'),
  interactiveContentOptionChild('InteractiveContentOptionChild'),
  interactiveContentLegendChild('InteractiveContentLegendChild');

  final String value;

  const SelectElementAccessibilityIssueReason(this.value);

  factory SelectElementAccessibilityIssueReason.fromJson(String value) =>
      SelectElementAccessibilityIssueReason.values.firstWhere(
        (e) => e.value == value,
      );

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// This issue warns about errors in the select element content model.
class SelectElementAccessibilityIssueDetails {
  final dom.BackendNodeId nodeId;

  final SelectElementAccessibilityIssueReason
  selectElementAccessibilityIssueReason;

  final bool hasDisallowedAttributes;

  SelectElementAccessibilityIssueDetails({
    required this.nodeId,
    required this.selectElementAccessibilityIssueReason,
    required this.hasDisallowedAttributes,
  });

  factory SelectElementAccessibilityIssueDetails.fromJson(
    Map<String, dynamic> json,
  ) {
    return SelectElementAccessibilityIssueDetails(
      nodeId: dom.BackendNodeId.fromJson(json['nodeId'] as int),
      selectElementAccessibilityIssueReason:
          SelectElementAccessibilityIssueReason.fromJson(
            json['selectElementAccessibilityIssueReason'] as String,
          ),
      hasDisallowedAttributes:
          json['hasDisallowedAttributes'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nodeId': nodeId.toJson(),
      'selectElementAccessibilityIssueReason':
          selectElementAccessibilityIssueReason.toJson(),
      'hasDisallowedAttributes': hasDisallowedAttributes,
    };
  }
}

enum StyleSheetLoadingIssueReason {
  lateImportRule('LateImportRule'),
  requestFailed('RequestFailed');

  final String value;

  const StyleSheetLoadingIssueReason(this.value);

  factory StyleSheetLoadingIssueReason.fromJson(String value) =>
      StyleSheetLoadingIssueReason.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// This issue warns when a referenced stylesheet couldn't be loaded.
class StylesheetLoadingIssueDetails {
  /// Source code position that referenced the failing stylesheet.
  final SourceCodeLocation sourceCodeLocation;

  /// Reason why the stylesheet couldn't be loaded.
  final StyleSheetLoadingIssueReason styleSheetLoadingIssueReason;

  /// Contains additional info when the failure was due to a request.
  final FailedRequestInfo? failedRequestInfo;

  StylesheetLoadingIssueDetails({
    required this.sourceCodeLocation,
    required this.styleSheetLoadingIssueReason,
    this.failedRequestInfo,
  });

  factory StylesheetLoadingIssueDetails.fromJson(Map<String, dynamic> json) {
    return StylesheetLoadingIssueDetails(
      sourceCodeLocation: SourceCodeLocation.fromJson(
        json['sourceCodeLocation'] as Map<String, dynamic>,
      ),
      styleSheetLoadingIssueReason: StyleSheetLoadingIssueReason.fromJson(
        json['styleSheetLoadingIssueReason'] as String,
      ),
      failedRequestInfo: json.containsKey('failedRequestInfo')
          ? FailedRequestInfo.fromJson(
              json['failedRequestInfo'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceCodeLocation': sourceCodeLocation.toJson(),
      'styleSheetLoadingIssueReason': styleSheetLoadingIssueReason.toJson(),
      if (failedRequestInfo != null)
        'failedRequestInfo': failedRequestInfo!.toJson(),
    };
  }
}

enum PropertyRuleIssueReason {
  invalidSyntax('InvalidSyntax'),
  invalidInitialValue('InvalidInitialValue'),
  invalidInherits('InvalidInherits'),
  invalidName('InvalidName');

  final String value;

  const PropertyRuleIssueReason(this.value);

  factory PropertyRuleIssueReason.fromJson(String value) =>
      PropertyRuleIssueReason.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// This issue warns about errors in property rules that lead to property
/// registrations being ignored.
class PropertyRuleIssueDetails {
  /// Source code position of the property rule.
  final SourceCodeLocation sourceCodeLocation;

  /// Reason why the property rule was discarded.
  final PropertyRuleIssueReason propertyRuleIssueReason;

  /// The value of the property rule property that failed to parse
  final String? propertyValue;

  PropertyRuleIssueDetails({
    required this.sourceCodeLocation,
    required this.propertyRuleIssueReason,
    this.propertyValue,
  });

  factory PropertyRuleIssueDetails.fromJson(Map<String, dynamic> json) {
    return PropertyRuleIssueDetails(
      sourceCodeLocation: SourceCodeLocation.fromJson(
        json['sourceCodeLocation'] as Map<String, dynamic>,
      ),
      propertyRuleIssueReason: PropertyRuleIssueReason.fromJson(
        json['propertyRuleIssueReason'] as String,
      ),
      propertyValue: json.containsKey('propertyValue')
          ? json['propertyValue'] as String
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceCodeLocation': sourceCodeLocation.toJson(),
      'propertyRuleIssueReason': propertyRuleIssueReason.toJson(),
      if (propertyValue != null) 'propertyValue': propertyValue,
    };
  }
}

enum UserReidentificationIssueType {
  blockedFrameNavigation('BlockedFrameNavigation'),
  blockedSubresource('BlockedSubresource');

  final String value;

  const UserReidentificationIssueType(this.value);

  factory UserReidentificationIssueType.fromJson(String value) =>
      UserReidentificationIssueType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// This issue warns about uses of APIs that may be considered misuse to
/// re-identify users.
class UserReidentificationIssueDetails {
  final UserReidentificationIssueType type;

  /// Applies to BlockedFrameNavigation and BlockedSubresource issue types.
  final AffectedRequest? request;

  UserReidentificationIssueDetails({required this.type, this.request});

  factory UserReidentificationIssueDetails.fromJson(Map<String, dynamic> json) {
    return UserReidentificationIssueDetails(
      type: UserReidentificationIssueType.fromJson(json['type'] as String),
      request: json.containsKey('request')
          ? AffectedRequest.fromJson(json['request'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      if (request != null) 'request': request!.toJson(),
    };
  }
}

/// A unique identifier for the type of issue. Each type may use one of the
/// optional fields in InspectorIssueDetails to convey more specific
/// information about the kind of issue.
enum InspectorIssueCode {
  cookieIssue('CookieIssue'),
  mixedContentIssue('MixedContentIssue'),
  blockedByResponseIssue('BlockedByResponseIssue'),
  heavyAdIssue('HeavyAdIssue'),
  contentSecurityPolicyIssue('ContentSecurityPolicyIssue'),
  sharedArrayBufferIssue('SharedArrayBufferIssue'),
  lowTextContrastIssue('LowTextContrastIssue'),
  corsIssue('CorsIssue'),
  attributionReportingIssue('AttributionReportingIssue'),
  quirksModeIssue('QuirksModeIssue'),
  partitioningBlobUrlIssue('PartitioningBlobURLIssue'),
  navigatorUserAgentIssue('NavigatorUserAgentIssue'),
  genericIssue('GenericIssue'),
  deprecationIssue('DeprecationIssue'),
  clientHintIssue('ClientHintIssue'),
  federatedAuthRequestIssue('FederatedAuthRequestIssue'),
  bounceTrackingIssue('BounceTrackingIssue'),
  cookieDeprecationMetadataIssue('CookieDeprecationMetadataIssue'),
  stylesheetLoadingIssue('StylesheetLoadingIssue'),
  federatedAuthUserInfoRequestIssue('FederatedAuthUserInfoRequestIssue'),
  propertyRuleIssue('PropertyRuleIssue'),
  sharedDictionaryIssue('SharedDictionaryIssue'),
  selectElementAccessibilityIssue('SelectElementAccessibilityIssue'),
  sriMessageSignatureIssue('SRIMessageSignatureIssue'),
  userReidentificationIssue('UserReidentificationIssue');

  final String value;

  const InspectorIssueCode(this.value);

  factory InspectorIssueCode.fromJson(String value) =>
      InspectorIssueCode.values.firstWhere((e) => e.value == value);

  String toJson() => value;

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

  final LowTextContrastIssueDetails? lowTextContrastIssueDetails;

  final CorsIssueDetails? corsIssueDetails;

  final AttributionReportingIssueDetails? attributionReportingIssueDetails;

  final QuirksModeIssueDetails? quirksModeIssueDetails;

  final PartitioningBlobURLIssueDetails? partitioningBlobURLIssueDetails;

  final GenericIssueDetails? genericIssueDetails;

  final DeprecationIssueDetails? deprecationIssueDetails;

  final ClientHintIssueDetails? clientHintIssueDetails;

  final FederatedAuthRequestIssueDetails? federatedAuthRequestIssueDetails;

  final BounceTrackingIssueDetails? bounceTrackingIssueDetails;

  final CookieDeprecationMetadataIssueDetails?
  cookieDeprecationMetadataIssueDetails;

  final StylesheetLoadingIssueDetails? stylesheetLoadingIssueDetails;

  final PropertyRuleIssueDetails? propertyRuleIssueDetails;

  final FederatedAuthUserInfoRequestIssueDetails?
  federatedAuthUserInfoRequestIssueDetails;

  final SharedDictionaryIssueDetails? sharedDictionaryIssueDetails;

  final SelectElementAccessibilityIssueDetails?
  selectElementAccessibilityIssueDetails;

  final SRIMessageSignatureIssueDetails? sriMessageSignatureIssueDetails;

  final UserReidentificationIssueDetails? userReidentificationIssueDetails;

  InspectorIssueDetails({
    this.cookieIssueDetails,
    this.mixedContentIssueDetails,
    this.blockedByResponseIssueDetails,
    this.heavyAdIssueDetails,
    this.contentSecurityPolicyIssueDetails,
    this.sharedArrayBufferIssueDetails,
    this.lowTextContrastIssueDetails,
    this.corsIssueDetails,
    this.attributionReportingIssueDetails,
    this.quirksModeIssueDetails,
    this.partitioningBlobURLIssueDetails,
    this.genericIssueDetails,
    this.deprecationIssueDetails,
    this.clientHintIssueDetails,
    this.federatedAuthRequestIssueDetails,
    this.bounceTrackingIssueDetails,
    this.cookieDeprecationMetadataIssueDetails,
    this.stylesheetLoadingIssueDetails,
    this.propertyRuleIssueDetails,
    this.federatedAuthUserInfoRequestIssueDetails,
    this.sharedDictionaryIssueDetails,
    this.selectElementAccessibilityIssueDetails,
    this.sriMessageSignatureIssueDetails,
    this.userReidentificationIssueDetails,
  });

  factory InspectorIssueDetails.fromJson(Map<String, dynamic> json) {
    return InspectorIssueDetails(
      cookieIssueDetails: json.containsKey('cookieIssueDetails')
          ? CookieIssueDetails.fromJson(
              json['cookieIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      mixedContentIssueDetails: json.containsKey('mixedContentIssueDetails')
          ? MixedContentIssueDetails.fromJson(
              json['mixedContentIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      blockedByResponseIssueDetails:
          json.containsKey('blockedByResponseIssueDetails')
          ? BlockedByResponseIssueDetails.fromJson(
              json['blockedByResponseIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      heavyAdIssueDetails: json.containsKey('heavyAdIssueDetails')
          ? HeavyAdIssueDetails.fromJson(
              json['heavyAdIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      contentSecurityPolicyIssueDetails:
          json.containsKey('contentSecurityPolicyIssueDetails')
          ? ContentSecurityPolicyIssueDetails.fromJson(
              json['contentSecurityPolicyIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      sharedArrayBufferIssueDetails:
          json.containsKey('sharedArrayBufferIssueDetails')
          ? SharedArrayBufferIssueDetails.fromJson(
              json['sharedArrayBufferIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      lowTextContrastIssueDetails:
          json.containsKey('lowTextContrastIssueDetails')
          ? LowTextContrastIssueDetails.fromJson(
              json['lowTextContrastIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      corsIssueDetails: json.containsKey('corsIssueDetails')
          ? CorsIssueDetails.fromJson(
              json['corsIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      attributionReportingIssueDetails:
          json.containsKey('attributionReportingIssueDetails')
          ? AttributionReportingIssueDetails.fromJson(
              json['attributionReportingIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      quirksModeIssueDetails: json.containsKey('quirksModeIssueDetails')
          ? QuirksModeIssueDetails.fromJson(
              json['quirksModeIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      partitioningBlobURLIssueDetails:
          json.containsKey('partitioningBlobURLIssueDetails')
          ? PartitioningBlobURLIssueDetails.fromJson(
              json['partitioningBlobURLIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      genericIssueDetails: json.containsKey('genericIssueDetails')
          ? GenericIssueDetails.fromJson(
              json['genericIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      deprecationIssueDetails: json.containsKey('deprecationIssueDetails')
          ? DeprecationIssueDetails.fromJson(
              json['deprecationIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      clientHintIssueDetails: json.containsKey('clientHintIssueDetails')
          ? ClientHintIssueDetails.fromJson(
              json['clientHintIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      federatedAuthRequestIssueDetails:
          json.containsKey('federatedAuthRequestIssueDetails')
          ? FederatedAuthRequestIssueDetails.fromJson(
              json['federatedAuthRequestIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      bounceTrackingIssueDetails: json.containsKey('bounceTrackingIssueDetails')
          ? BounceTrackingIssueDetails.fromJson(
              json['bounceTrackingIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      cookieDeprecationMetadataIssueDetails:
          json.containsKey('cookieDeprecationMetadataIssueDetails')
          ? CookieDeprecationMetadataIssueDetails.fromJson(
              json['cookieDeprecationMetadataIssueDetails']
                  as Map<String, dynamic>,
            )
          : null,
      stylesheetLoadingIssueDetails:
          json.containsKey('stylesheetLoadingIssueDetails')
          ? StylesheetLoadingIssueDetails.fromJson(
              json['stylesheetLoadingIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      propertyRuleIssueDetails: json.containsKey('propertyRuleIssueDetails')
          ? PropertyRuleIssueDetails.fromJson(
              json['propertyRuleIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      federatedAuthUserInfoRequestIssueDetails:
          json.containsKey('federatedAuthUserInfoRequestIssueDetails')
          ? FederatedAuthUserInfoRequestIssueDetails.fromJson(
              json['federatedAuthUserInfoRequestIssueDetails']
                  as Map<String, dynamic>,
            )
          : null,
      sharedDictionaryIssueDetails:
          json.containsKey('sharedDictionaryIssueDetails')
          ? SharedDictionaryIssueDetails.fromJson(
              json['sharedDictionaryIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      selectElementAccessibilityIssueDetails:
          json.containsKey('selectElementAccessibilityIssueDetails')
          ? SelectElementAccessibilityIssueDetails.fromJson(
              json['selectElementAccessibilityIssueDetails']
                  as Map<String, dynamic>,
            )
          : null,
      sriMessageSignatureIssueDetails:
          json.containsKey('sriMessageSignatureIssueDetails')
          ? SRIMessageSignatureIssueDetails.fromJson(
              json['sriMessageSignatureIssueDetails'] as Map<String, dynamic>,
            )
          : null,
      userReidentificationIssueDetails:
          json.containsKey('userReidentificationIssueDetails')
          ? UserReidentificationIssueDetails.fromJson(
              json['userReidentificationIssueDetails'] as Map<String, dynamic>,
            )
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
        'blockedByResponseIssueDetails': blockedByResponseIssueDetails!
            .toJson(),
      if (heavyAdIssueDetails != null)
        'heavyAdIssueDetails': heavyAdIssueDetails!.toJson(),
      if (contentSecurityPolicyIssueDetails != null)
        'contentSecurityPolicyIssueDetails': contentSecurityPolicyIssueDetails!
            .toJson(),
      if (sharedArrayBufferIssueDetails != null)
        'sharedArrayBufferIssueDetails': sharedArrayBufferIssueDetails!
            .toJson(),
      if (lowTextContrastIssueDetails != null)
        'lowTextContrastIssueDetails': lowTextContrastIssueDetails!.toJson(),
      if (corsIssueDetails != null)
        'corsIssueDetails': corsIssueDetails!.toJson(),
      if (attributionReportingIssueDetails != null)
        'attributionReportingIssueDetails': attributionReportingIssueDetails!
            .toJson(),
      if (quirksModeIssueDetails != null)
        'quirksModeIssueDetails': quirksModeIssueDetails!.toJson(),
      if (partitioningBlobURLIssueDetails != null)
        'partitioningBlobURLIssueDetails': partitioningBlobURLIssueDetails!
            .toJson(),
      if (genericIssueDetails != null)
        'genericIssueDetails': genericIssueDetails!.toJson(),
      if (deprecationIssueDetails != null)
        'deprecationIssueDetails': deprecationIssueDetails!.toJson(),
      if (clientHintIssueDetails != null)
        'clientHintIssueDetails': clientHintIssueDetails!.toJson(),
      if (federatedAuthRequestIssueDetails != null)
        'federatedAuthRequestIssueDetails': federatedAuthRequestIssueDetails!
            .toJson(),
      if (bounceTrackingIssueDetails != null)
        'bounceTrackingIssueDetails': bounceTrackingIssueDetails!.toJson(),
      if (cookieDeprecationMetadataIssueDetails != null)
        'cookieDeprecationMetadataIssueDetails':
            cookieDeprecationMetadataIssueDetails!.toJson(),
      if (stylesheetLoadingIssueDetails != null)
        'stylesheetLoadingIssueDetails': stylesheetLoadingIssueDetails!
            .toJson(),
      if (propertyRuleIssueDetails != null)
        'propertyRuleIssueDetails': propertyRuleIssueDetails!.toJson(),
      if (federatedAuthUserInfoRequestIssueDetails != null)
        'federatedAuthUserInfoRequestIssueDetails':
            federatedAuthUserInfoRequestIssueDetails!.toJson(),
      if (sharedDictionaryIssueDetails != null)
        'sharedDictionaryIssueDetails': sharedDictionaryIssueDetails!.toJson(),
      if (selectElementAccessibilityIssueDetails != null)
        'selectElementAccessibilityIssueDetails':
            selectElementAccessibilityIssueDetails!.toJson(),
      if (sriMessageSignatureIssueDetails != null)
        'sriMessageSignatureIssueDetails': sriMessageSignatureIssueDetails!
            .toJson(),
      if (userReidentificationIssueDetails != null)
        'userReidentificationIssueDetails': userReidentificationIssueDetails!
            .toJson(),
    };
  }
}

/// A unique id for a DevTools inspector issue. Allows other entities (e.g.
/// exceptions, CDP message, console messages, etc.) to reference an issue.
extension type IssueId(String value) {
  factory IssueId.fromJson(String value) => IssueId(value);

  String toJson() => value;
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
        json['details'] as Map<String, dynamic>,
      ),
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
