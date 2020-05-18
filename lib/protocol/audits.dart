import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'network.dart' as network;

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

  /// Optionally identifies the site-for-cookies, which may be used by the
  /// front-end as additional context.
  final String siteForCookies;

  AffectedCookie(
      {@required this.name,
      @required this.path,
      @required this.domain,
      this.siteForCookies});

  factory AffectedCookie.fromJson(Map<String, dynamic> json) {
    return AffectedCookie(
      name: json['name'] as String,
      path: json['path'] as String,
      domain: json['domain'] as String,
      siteForCookies: json.containsKey('siteForCookies')
          ? json['siteForCookies'] as String
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'domain': domain,
      if (siteForCookies != null) 'siteForCookies': siteForCookies,
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
  static const warnSameSiteCrossSchemeSecureUrlMethodUnsafe =
      SameSiteCookieWarningReason._(
          'WarnSameSiteCrossSchemeSecureUrlMethodUnsafe');
  static const warnSameSiteCrossSchemeSecureUrlLax =
      SameSiteCookieWarningReason._('WarnSameSiteCrossSchemeSecureUrlLax');
  static const warnSameSiteCrossSchemeSecureUrlStrict =
      SameSiteCookieWarningReason._('WarnSameSiteCrossSchemeSecureUrlStrict');
  static const warnSameSiteCrossSchemeInsecureUrlMethodUnsafe =
      SameSiteCookieWarningReason._(
          'WarnSameSiteCrossSchemeInsecureUrlMethodUnsafe');
  static const warnSameSiteCrossSchemeInsecureUrlLax =
      SameSiteCookieWarningReason._('WarnSameSiteCrossSchemeInsecureUrlLax');
  static const warnSameSiteCrossSchemeInsecureUrlStrict =
      SameSiteCookieWarningReason._('WarnSameSiteCrossSchemeInsecureUrlStrict');
  static const values = {
    'WarnSameSiteUnspecifiedCrossSiteContext':
        warnSameSiteUnspecifiedCrossSiteContext,
    'WarnSameSiteNoneInsecure': warnSameSiteNoneInsecure,
    'WarnSameSiteUnspecifiedLaxAllowUnsafe':
        warnSameSiteUnspecifiedLaxAllowUnsafe,
    'WarnSameSiteCrossSchemeSecureUrlMethodUnsafe':
        warnSameSiteCrossSchemeSecureUrlMethodUnsafe,
    'WarnSameSiteCrossSchemeSecureUrlLax': warnSameSiteCrossSchemeSecureUrlLax,
    'WarnSameSiteCrossSchemeSecureUrlStrict':
        warnSameSiteCrossSchemeSecureUrlStrict,
    'WarnSameSiteCrossSchemeInsecureUrlMethodUnsafe':
        warnSameSiteCrossSchemeInsecureUrlMethodUnsafe,
    'WarnSameSiteCrossSchemeInsecureUrlLax':
        warnSameSiteCrossSchemeInsecureUrlLax,
    'WarnSameSiteCrossSchemeInsecureUrlStrict':
        warnSameSiteCrossSchemeInsecureUrlStrict,
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

/// This information is currently necessary, as the front-end has a difficult
/// time finding a specific cookie. With this, we can convey specific error
/// information without the cookie.
class SameSiteCookieIssueDetails {
  final List<SameSiteCookieWarningReason> cookieWarningReasons;

  final List<SameSiteCookieExclusionReason> cookieExclusionReasons;

  SameSiteCookieIssueDetails(
      {@required this.cookieWarningReasons,
      @required this.cookieExclusionReasons});

  factory SameSiteCookieIssueDetails.fromJson(Map<String, dynamic> json) {
    return SameSiteCookieIssueDetails(
      cookieWarningReasons: (json['cookieWarningReasons'] as List)
          .map((e) => SameSiteCookieWarningReason.fromJson(e as String))
          .toList(),
      cookieExclusionReasons: (json['cookieExclusionReasons'] as List)
          .map((e) => SameSiteCookieExclusionReason.fromJson(e as String))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cookieWarningReasons':
          cookieWarningReasons.map((e) => e.toJson()).toList(),
      'cookieExclusionReasons':
          cookieExclusionReasons.map((e) => e.toJson()).toList(),
    };
  }
}

class AffectedResources {
  final List<AffectedCookie> cookies;

  AffectedResources({this.cookies});

  factory AffectedResources.fromJson(Map<String, dynamic> json) {
    return AffectedResources(
      cookies: json.containsKey('cookies')
          ? (json['cookies'] as List)
              .map((e) => AffectedCookie.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (cookies != null) 'cookies': cookies.map((e) => e.toJson()).toList(),
    };
  }
}

/// A unique identifier for the type of issue. Each type may use one of the
/// optional fields in InspectorIssueDetails to convey more specific
/// information about the kind of issue, and AffectedResources to identify
/// resources that are affected by this issue.
class InspectorIssueCode {
  static const sameSiteCookieIssue =
      InspectorIssueCode._('SameSiteCookieIssue');
  static const values = {
    'SameSiteCookieIssue': sameSiteCookieIssue,
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
/// pertaining to the kind of issue. This is useful if there is a number of
/// very similar issues that only differ in details.
class InspectorIssueDetails {
  final SameSiteCookieIssueDetails sameSiteCookieIssueDetails;

  InspectorIssueDetails({this.sameSiteCookieIssueDetails});

  factory InspectorIssueDetails.fromJson(Map<String, dynamic> json) {
    return InspectorIssueDetails(
      sameSiteCookieIssueDetails: json.containsKey('sameSiteCookieIssueDetails')
          ? SameSiteCookieIssueDetails.fromJson(
              json['sameSiteCookieIssueDetails'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (sameSiteCookieIssueDetails != null)
        'sameSiteCookieIssueDetails': sameSiteCookieIssueDetails.toJson(),
    };
  }
}

/// An inspector issue reported from the back-end.
class InspectorIssue {
  final InspectorIssueCode code;

  final InspectorIssueDetails details;

  final AffectedResources resources;

  InspectorIssue(
      {@required this.code, @required this.details, @required this.resources});

  factory InspectorIssue.fromJson(Map<String, dynamic> json) {
    return InspectorIssue(
      code: InspectorIssueCode.fromJson(json['code'] as String),
      details: InspectorIssueDetails.fromJson(
          json['details'] as Map<String, dynamic>),
      resources:
          AffectedResources.fromJson(json['resources'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code.toJson(),
      'details': details.toJson(),
      'resources': resources.toJson(),
    };
  }
}
