import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'network.dart' as network;
import 'page.dart' as page;

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
      {num quality,
      bool sizeOnly}) async {
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
}

class GetEncodedResponseResult {
  /// The encoded body as a base64 string. Omitted if sizeOnly is true.
  final String body;

  /// Size before re-encoding.
  final int originalSize;

  /// Size after re-encoding.
  final int encodedSize;

  GetEncodedResponseResult(
      {this.body, @required this.originalSize, @required this.encodedSize});

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
      {@required this.name, @required this.path, @required this.domain});

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

  final String url;

  AffectedRequest({@required this.requestId, this.url});

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

  AffectedFrame({@required this.frameId});

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

class SameSiteCookieExclusionReason {
  static const excludeSameSiteUnspecifiedTreatedAsLax =
      SameSiteCookieExclusionReason._('ExcludeSameSiteUnspecifiedTreatedAsLax');
  static const excludeSameSiteNoneInsecure =
      SameSiteCookieExclusionReason._('ExcludeSameSiteNoneInsecure');
  static const values = {
    'ExcludeSameSiteUnspecifiedTreatedAsLax':
        excludeSameSiteUnspecifiedTreatedAsLax,
    'ExcludeSameSiteNoneInsecure': excludeSameSiteNoneInsecure,
  };

  final String value;

  const SameSiteCookieExclusionReason._(this.value);

  factory SameSiteCookieExclusionReason.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is SameSiteCookieExclusionReason && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class SameSiteCookieWarningReason {
  static const warnSameSiteUnspecifiedCrossSiteContext =
      SameSiteCookieWarningReason._('WarnSameSiteUnspecifiedCrossSiteContext');
  static const warnSameSiteNoneInsecure =
      SameSiteCookieWarningReason._('WarnSameSiteNoneInsecure');
  static const warnSameSiteUnspecifiedLaxAllowUnsafe =
      SameSiteCookieWarningReason._('WarnSameSiteUnspecifiedLaxAllowUnsafe');
  static const warnSameSiteStrictLaxDowngradeStrict =
      SameSiteCookieWarningReason._('WarnSameSiteStrictLaxDowngradeStrict');
  static const warnSameSiteStrictCrossDowngradeStrict =
      SameSiteCookieWarningReason._('WarnSameSiteStrictCrossDowngradeStrict');
  static const warnSameSiteStrictCrossDowngradeLax =
      SameSiteCookieWarningReason._('WarnSameSiteStrictCrossDowngradeLax');
  static const warnSameSiteLaxCrossDowngradeStrict =
      SameSiteCookieWarningReason._('WarnSameSiteLaxCrossDowngradeStrict');
  static const warnSameSiteLaxCrossDowngradeLax =
      SameSiteCookieWarningReason._('WarnSameSiteLaxCrossDowngradeLax');
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
  };

  final String value;

  const SameSiteCookieWarningReason._(this.value);

  factory SameSiteCookieWarningReason.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is SameSiteCookieWarningReason && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class SameSiteCookieOperation {
  static const setCookie = SameSiteCookieOperation._('SetCookie');
  static const readCookie = SameSiteCookieOperation._('ReadCookie');
  static const values = {
    'SetCookie': setCookie,
    'ReadCookie': readCookie,
  };

  final String value;

  const SameSiteCookieOperation._(this.value);

  factory SameSiteCookieOperation.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is SameSiteCookieOperation && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// This information is currently necessary, as the front-end has a difficult
/// time finding a specific cookie. With this, we can convey specific error
/// information without the cookie.
class SameSiteCookieIssueDetails {
  final AffectedCookie cookie;

  final List<SameSiteCookieWarningReason> cookieWarningReasons;

  final List<SameSiteCookieExclusionReason> cookieExclusionReasons;

  /// Optionally identifies the site-for-cookies and the cookie url, which
  /// may be used by the front-end as additional context.
  final SameSiteCookieOperation operation;

  final String siteForCookies;

  final String cookieUrl;

  final AffectedRequest request;

  SameSiteCookieIssueDetails(
      {@required this.cookie,
      @required this.cookieWarningReasons,
      @required this.cookieExclusionReasons,
      @required this.operation,
      this.siteForCookies,
      this.cookieUrl,
      this.request});

  factory SameSiteCookieIssueDetails.fromJson(Map<String, dynamic> json) {
    return SameSiteCookieIssueDetails(
      cookie: AffectedCookie.fromJson(json['cookie'] as Map<String, dynamic>),
      cookieWarningReasons: (json['cookieWarningReasons'] as List)
          .map((e) => SameSiteCookieWarningReason.fromJson(e as String))
          .toList(),
      cookieExclusionReasons: (json['cookieExclusionReasons'] as List)
          .map((e) => SameSiteCookieExclusionReason.fromJson(e as String))
          .toList(),
      operation: SameSiteCookieOperation.fromJson(json['operation'] as String),
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
      'cookie': cookie.toJson(),
      'cookieWarningReasons':
          cookieWarningReasons.map((e) => e.toJson()).toList(),
      'cookieExclusionReasons':
          cookieExclusionReasons.map((e) => e.toJson()).toList(),
      'operation': operation.toJson(),
      if (siteForCookies != null) 'siteForCookies': siteForCookies,
      if (cookieUrl != null) 'cookieUrl': cookieUrl,
      if (request != null) 'request': request.toJson(),
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

  factory MixedContentResolutionStatus.fromJson(String value) => values[value];

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

  factory MixedContentResourceType.fromJson(String value) => values[value];

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
  final MixedContentResourceType resourceType;

  /// The way the mixed content issue is being resolved.
  final MixedContentResolutionStatus resolutionStatus;

  /// The unsafe http url causing the mixed content issue.
  final String insecureURL;

  /// The url responsible for the call to an unsafe url.
  final String mainResourceURL;

  /// The mixed content request.
  /// Does not always exist (e.g. for unsafe form submission urls).
  final AffectedRequest request;

  /// Optional because not every mixed content issue is necessarily linked to a frame.
  final AffectedFrame frame;

  MixedContentIssueDetails(
      {this.resourceType,
      @required this.resolutionStatus,
      @required this.insecureURL,
      @required this.mainResourceURL,
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
      if (resourceType != null) 'resourceType': resourceType.toJson(),
      if (request != null) 'request': request.toJson(),
      if (frame != null) 'frame': frame.toJson(),
    };
  }
}

/// A unique identifier for the type of issue. Each type may use one of the
/// optional fields in InspectorIssueDetails to convey more specific
/// information about the kind of issue.
class InspectorIssueCode {
  static const sameSiteCookieIssue =
      InspectorIssueCode._('SameSiteCookieIssue');
  static const mixedContentIssue = InspectorIssueCode._('MixedContentIssue');
  static const values = {
    'SameSiteCookieIssue': sameSiteCookieIssue,
    'MixedContentIssue': mixedContentIssue,
  };

  final String value;

  const InspectorIssueCode._(this.value);

  factory InspectorIssueCode.fromJson(String value) => values[value];

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
  final SameSiteCookieIssueDetails sameSiteCookieIssueDetails;

  final MixedContentIssueDetails mixedContentIssueDetails;

  InspectorIssueDetails(
      {this.sameSiteCookieIssueDetails, this.mixedContentIssueDetails});

  factory InspectorIssueDetails.fromJson(Map<String, dynamic> json) {
    return InspectorIssueDetails(
      sameSiteCookieIssueDetails: json.containsKey('sameSiteCookieIssueDetails')
          ? SameSiteCookieIssueDetails.fromJson(
              json['sameSiteCookieIssueDetails'] as Map<String, dynamic>)
          : null,
      mixedContentIssueDetails: json.containsKey('mixedContentIssueDetails')
          ? MixedContentIssueDetails.fromJson(
              json['mixedContentIssueDetails'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (sameSiteCookieIssueDetails != null)
        'sameSiteCookieIssueDetails': sameSiteCookieIssueDetails.toJson(),
      if (mixedContentIssueDetails != null)
        'mixedContentIssueDetails': mixedContentIssueDetails.toJson(),
    };
  }
}

/// An inspector issue reported from the back-end.
class InspectorIssue {
  final InspectorIssueCode code;

  final InspectorIssueDetails details;

  InspectorIssue({@required this.code, @required this.details});

  factory InspectorIssue.fromJson(Map<String, dynamic> json) {
    return InspectorIssue(
      code: InspectorIssueCode.fromJson(json['code'] as String),
      details: InspectorIssueDetails.fromJson(
          json['details'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code.toJson(),
      'details': details.toJson(),
    };
  }
}
