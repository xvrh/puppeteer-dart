import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';

/// Security
class SecurityApi {
  final Client _client;

  SecurityApi(this._client);

  /// There is a certificate error. If overriding certificate errors is enabled, then it should be
  /// handled with the `handleCertificateError` command. Note: this event does not fire if the
  /// certificate error has been allowed internally. Only one client per target should override
  /// certificate errors at the same time.
  Stream<CertificateErrorEvent> get onCertificateError => _client.onEvent
      .where((Event event) => event.name == 'Security.certificateError')
      .map((Event event) => CertificateErrorEvent.fromJson(event.parameters));

  /// The security state of the page changed.
  Stream<SecurityStateChangedEvent> get onSecurityStateChanged =>
      _client.onEvent
          .where((Event event) => event.name == 'Security.securityStateChanged')
          .map((Event event) =>
              SecurityStateChangedEvent.fromJson(event.parameters));

  /// Disables tracking security state changes.
  Future disable() async {
    await _client.send('Security.disable');
  }

  /// Enables tracking security state changes.
  Future enable() async {
    await _client.send('Security.enable');
  }

  /// Enable/disable whether all certificate errors should be ignored.
  /// [ignore] If true, all certificate errors will be ignored.
  Future setIgnoreCertificateErrors(bool ignore) async {
    var parameters = <String, dynamic>{
      'ignore': ignore,
    };
    await _client.send('Security.setIgnoreCertificateErrors', parameters);
  }

  /// Handles a certificate error that fired a certificateError event.
  /// [eventId] The ID of the event.
  /// [action] The action to take on the certificate error.
  @deprecated
  Future handleCertificateError(
      int eventId, CertificateErrorAction action) async {
    var parameters = <String, dynamic>{
      'eventId': eventId,
      'action': action.toJson(),
    };
    await _client.send('Security.handleCertificateError', parameters);
  }

  /// Enable/disable overriding certificate errors. If enabled, all certificate error events need to
  /// be handled by the DevTools client and should be answered with `handleCertificateError` commands.
  /// [override] If true, certificate errors will be overridden.
  @deprecated
  Future setOverrideCertificateErrors(bool override) async {
    var parameters = <String, dynamic>{
      'override': override,
    };
    await _client.send('Security.setOverrideCertificateErrors', parameters);
  }
}

class CertificateErrorEvent {
  /// The ID of the event.
  final int eventId;

  /// The type of the error.
  final String errorType;

  /// The url that was requested.
  final String requestURL;

  CertificateErrorEvent(
      {@required this.eventId,
      @required this.errorType,
      @required this.requestURL});

  factory CertificateErrorEvent.fromJson(Map<String, dynamic> json) {
    return CertificateErrorEvent(
      eventId: json['eventId'],
      errorType: json['errorType'],
      requestURL: json['requestURL'],
    );
  }
}

class SecurityStateChangedEvent {
  /// Security state.
  final SecurityState securityState;

  /// True if the page was loaded over cryptographic transport such as HTTPS.
  final bool schemeIsCryptographic;

  /// List of explanations for the security state. If the overall security state is `insecure` or
  /// `warning`, at least one corresponding explanation should be included.
  final List<SecurityStateExplanation> explanations;

  /// Overrides user-visible description of the state.
  final String summary;

  SecurityStateChangedEvent(
      {@required this.securityState,
      @required this.schemeIsCryptographic,
      @required this.explanations,
      this.summary});

  factory SecurityStateChangedEvent.fromJson(Map<String, dynamic> json) {
    return SecurityStateChangedEvent(
      securityState: SecurityState.fromJson(json['securityState']),
      schemeIsCryptographic: json['schemeIsCryptographic'],
      explanations: (json['explanations'] as List)
          .map((e) => SecurityStateExplanation.fromJson(e))
          .toList(),
      summary: json.containsKey('summary') ? json['summary'] : null,
    );
  }
}

/// An internal certificate ID value.
class CertificateId {
  final int value;

  CertificateId(this.value);

  factory CertificateId.fromJson(int value) => CertificateId(value);

  int toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CertificateId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// A description of mixed content (HTTP resources on HTTPS pages), as defined by
/// https://www.w3.org/TR/mixed-content/#categories
class MixedContentType {
  static const MixedContentType blockable =
      const MixedContentType._('blockable');
  static const MixedContentType optionallyBlockable =
      const MixedContentType._('optionally-blockable');
  static const MixedContentType none = const MixedContentType._('none');
  static const values = const {
    'blockable': blockable,
    'optionally-blockable': optionallyBlockable,
    'none': none,
  };

  final String value;

  const MixedContentType._(this.value);

  factory MixedContentType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// The security level of a page or resource.
class SecurityState {
  static const SecurityState unknown = const SecurityState._('unknown');
  static const SecurityState neutral = const SecurityState._('neutral');
  static const SecurityState insecure = const SecurityState._('insecure');
  static const SecurityState secure = const SecurityState._('secure');
  static const SecurityState info = const SecurityState._('info');
  static const values = const {
    'unknown': unknown,
    'neutral': neutral,
    'insecure': insecure,
    'secure': secure,
    'info': info,
  };

  final String value;

  const SecurityState._(this.value);

  factory SecurityState.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// An explanation of an factor contributing to the security state.
class SecurityStateExplanation {
  /// Security state representing the severity of the factor being explained.
  final SecurityState securityState;

  /// Title describing the type of factor.
  final String title;

  /// Short phrase describing the type of factor.
  final String summary;

  /// Full text explanation of the factor.
  final String description;

  /// The type of mixed content described by the explanation.
  final MixedContentType mixedContentType;

  /// Page certificate.
  final List<String> certificate;

  /// Recommendations to fix any issues.
  final List<String> recommendations;

  SecurityStateExplanation(
      {@required this.securityState,
      @required this.title,
      @required this.summary,
      @required this.description,
      @required this.mixedContentType,
      @required this.certificate,
      this.recommendations});

  factory SecurityStateExplanation.fromJson(Map<String, dynamic> json) {
    return SecurityStateExplanation(
      securityState: SecurityState.fromJson(json['securityState']),
      title: json['title'],
      summary: json['summary'],
      description: json['description'],
      mixedContentType: MixedContentType.fromJson(json['mixedContentType']),
      certificate:
          (json['certificate'] as List).map((e) => e as String).toList(),
      recommendations: json.containsKey('recommendations')
          ? (json['recommendations'] as List).map((e) => e as String).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'securityState': securityState.toJson(),
      'title': title,
      'summary': summary,
      'description': description,
      'mixedContentType': mixedContentType.toJson(),
      'certificate': certificate.map((e) => e).toList(),
    };
    if (recommendations != null) {
      json['recommendations'] = recommendations.map((e) => e).toList();
    }
    return json;
  }
}

/// Information about insecure content on the page.
class InsecureContentStatus {
  /// True if the page was loaded over HTTPS and ran mixed (HTTP) content such as scripts.
  final bool ranMixedContent;

  /// True if the page was loaded over HTTPS and displayed mixed (HTTP) content such as images.
  final bool displayedMixedContent;

  /// True if the page was loaded over HTTPS and contained a form targeting an insecure url.
  final bool containedMixedForm;

  /// True if the page was loaded over HTTPS without certificate errors, and ran content such as
  /// scripts that were loaded with certificate errors.
  final bool ranContentWithCertErrors;

  /// True if the page was loaded over HTTPS without certificate errors, and displayed content
  /// such as images that were loaded with certificate errors.
  final bool displayedContentWithCertErrors;

  /// Security state representing a page that ran insecure content.
  final SecurityState ranInsecureContentStyle;

  /// Security state representing a page that displayed insecure content.
  final SecurityState displayedInsecureContentStyle;

  InsecureContentStatus(
      {@required this.ranMixedContent,
      @required this.displayedMixedContent,
      @required this.containedMixedForm,
      @required this.ranContentWithCertErrors,
      @required this.displayedContentWithCertErrors,
      @required this.ranInsecureContentStyle,
      @required this.displayedInsecureContentStyle});

  factory InsecureContentStatus.fromJson(Map<String, dynamic> json) {
    return InsecureContentStatus(
      ranMixedContent: json['ranMixedContent'],
      displayedMixedContent: json['displayedMixedContent'],
      containedMixedForm: json['containedMixedForm'],
      ranContentWithCertErrors: json['ranContentWithCertErrors'],
      displayedContentWithCertErrors: json['displayedContentWithCertErrors'],
      ranInsecureContentStyle:
          SecurityState.fromJson(json['ranInsecureContentStyle']),
      displayedInsecureContentStyle:
          SecurityState.fromJson(json['displayedInsecureContentStyle']),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'ranMixedContent': ranMixedContent,
      'displayedMixedContent': displayedMixedContent,
      'containedMixedForm': containedMixedForm,
      'ranContentWithCertErrors': ranContentWithCertErrors,
      'displayedContentWithCertErrors': displayedContentWithCertErrors,
      'ranInsecureContentStyle': ranInsecureContentStyle.toJson(),
      'displayedInsecureContentStyle': displayedInsecureContentStyle.toJson(),
    };
    return json;
  }
}

/// The action to take when a certificate error occurs. continue will continue processing the
/// request and cancel will cancel the request.
class CertificateErrorAction {
  static const CertificateErrorAction continue$ =
      const CertificateErrorAction._('continue');
  static const CertificateErrorAction cancel =
      const CertificateErrorAction._('cancel');
  static const values = const {
    'continue': continue$,
    'cancel': cancel,
  };

  final String value;

  const CertificateErrorAction._(this.value);

  factory CertificateErrorAction.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  String toString() => value.toString();
}
