import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'network.dart' as network;

/// Security
class SecurityApi {
  final Client _client;

  SecurityApi(this._client);

  /// There is a certificate error. If overriding certificate errors is enabled, then it should be
  /// handled with the `handleCertificateError` command. Note: this event does not fire if the
  /// certificate error has been allowed internally. Only one client per target should override
  /// certificate errors at the same time.
  Stream<CertificateErrorEvent> get onCertificateError => _client.onEvent
      .where((event) => event.name == 'Security.certificateError')
      .map((event) => CertificateErrorEvent.fromJson(event.parameters));

  /// The security state of the page changed.
  Stream<VisibleSecurityState> get onVisibleSecurityStateChanged => _client
      .onEvent
      .where((event) => event.name == 'Security.visibleSecurityStateChanged')
      .map((event) => VisibleSecurityState.fromJson(
          event.parameters['visibleSecurityState'] as Map<String, dynamic>));

  /// The security state of the page changed.
  Stream<SecurityStateChangedEvent> get onSecurityStateChanged =>
      _client.onEvent
          .where((event) => event.name == 'Security.securityStateChanged')
          .map((event) => SecurityStateChangedEvent.fromJson(event.parameters));

  /// Disables tracking security state changes.
  Future<void> disable() async {
    await _client.send('Security.disable');
  }

  /// Enables tracking security state changes.
  Future<void> enable() async {
    await _client.send('Security.enable');
  }

  /// Enable/disable whether all certificate errors should be ignored.
  /// [ignore] If true, all certificate errors will be ignored.
  Future<void> setIgnoreCertificateErrors(bool ignore) async {
    await _client.send('Security.setIgnoreCertificateErrors', {
      'ignore': ignore,
    });
  }

  /// Handles a certificate error that fired a certificateError event.
  /// [eventId] The ID of the event.
  /// [action] The action to take on the certificate error.
  @deprecated
  Future<void> handleCertificateError(
      int eventId, CertificateErrorAction action) async {
    await _client.send('Security.handleCertificateError', {
      'eventId': eventId,
      'action': action,
    });
  }

  /// Enable/disable overriding certificate errors. If enabled, all certificate error events need to
  /// be handled by the DevTools client and should be answered with `handleCertificateError` commands.
  /// [override] If true, certificate errors will be overridden.
  @deprecated
  Future<void> setOverrideCertificateErrors(bool override) async {
    await _client.send('Security.setOverrideCertificateErrors', {
      'override': override,
    });
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
      eventId: json['eventId'] as int,
      errorType: json['errorType'] as String,
      requestURL: json['requestURL'] as String,
    );
  }
}

class SecurityStateChangedEvent {
  /// Security state.
  final SecurityState securityState;

  /// List of explanations for the security state. If the overall security state is `insecure` or
  /// `warning`, at least one corresponding explanation should be included.
  final List<SecurityStateExplanation> explanations;

  /// Overrides user-visible description of the state.
  final String summary;

  SecurityStateChangedEvent(
      {@required this.securityState,
      @required this.explanations,
      this.summary});

  factory SecurityStateChangedEvent.fromJson(Map<String, dynamic> json) {
    return SecurityStateChangedEvent(
      securityState: SecurityState.fromJson(json['securityState'] as String),
      explanations: (json['explanations'] as List)
          .map((e) =>
              SecurityStateExplanation.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: json.containsKey('summary') ? json['summary'] as String : null,
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
  static const blockable = MixedContentType._('blockable');
  static const optionallyBlockable = MixedContentType._('optionally-blockable');
  static const none = MixedContentType._('none');
  static const values = {
    'blockable': blockable,
    'optionally-blockable': optionallyBlockable,
    'none': none,
  };

  final String value;

  const MixedContentType._(this.value);

  factory MixedContentType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is MixedContentType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// The security level of a page or resource.
class SecurityState {
  static const unknown = SecurityState._('unknown');
  static const neutral = SecurityState._('neutral');
  static const insecure = SecurityState._('insecure');
  static const secure = SecurityState._('secure');
  static const info = SecurityState._('info');
  static const values = {
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
  bool operator ==(other) =>
      (other is SecurityState && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Details about the security state of the page certificate.
class CertificateSecurityState {
  /// Protocol name (e.g. "TLS 1.2" or "QUIC").
  final String protocol;

  /// Key Exchange used by the connection, or the empty string if not applicable.
  final String keyExchange;

  /// (EC)DH group used by the connection, if applicable.
  final String keyExchangeGroup;

  /// Cipher name.
  final String cipher;

  /// TLS MAC. Note that AEAD ciphers do not have separate MACs.
  final String mac;

  /// Page certificate.
  final List<String> certificate;

  /// Certificate subject name.
  final String subjectName;

  /// Name of the issuing CA.
  final String issuer;

  /// Certificate valid from date.
  final network.TimeSinceEpoch validFrom;

  /// Certificate valid to (expiration) date
  final network.TimeSinceEpoch validTo;

  /// True if the certificate uses a weak signature aglorithm.
  final bool certifcateHasWeakSignature;

  /// True if modern SSL
  final bool modernSSL;

  /// True if the connection is using an obsolete SSL protocol.
  final bool obsoleteSslProtocol;

  /// True if the connection is using an obsolete SSL key exchange.
  final bool obsoleteSslKeyExchange;

  /// True if the connection is using an obsolete SSL cipher.
  final bool obsoleteSslCipher;

  /// True if the connection is using an obsolete SSL signature.
  final bool obsoleteSslSignature;

  CertificateSecurityState(
      {@required this.protocol,
      @required this.keyExchange,
      this.keyExchangeGroup,
      @required this.cipher,
      this.mac,
      @required this.certificate,
      @required this.subjectName,
      @required this.issuer,
      @required this.validFrom,
      @required this.validTo,
      @required this.certifcateHasWeakSignature,
      @required this.modernSSL,
      @required this.obsoleteSslProtocol,
      @required this.obsoleteSslKeyExchange,
      @required this.obsoleteSslCipher,
      @required this.obsoleteSslSignature});

  factory CertificateSecurityState.fromJson(Map<String, dynamic> json) {
    return CertificateSecurityState(
      protocol: json['protocol'] as String,
      keyExchange: json['keyExchange'] as String,
      keyExchangeGroup: json.containsKey('keyExchangeGroup')
          ? json['keyExchangeGroup'] as String
          : null,
      cipher: json['cipher'] as String,
      mac: json.containsKey('mac') ? json['mac'] as String : null,
      certificate:
          (json['certificate'] as List).map((e) => e as String).toList(),
      subjectName: json['subjectName'] as String,
      issuer: json['issuer'] as String,
      validFrom: network.TimeSinceEpoch.fromJson(json['validFrom'] as num),
      validTo: network.TimeSinceEpoch.fromJson(json['validTo'] as num),
      certifcateHasWeakSignature: json['certifcateHasWeakSignature'] as bool,
      modernSSL: json['modernSSL'] as bool,
      obsoleteSslProtocol: json['obsoleteSslProtocol'] as bool,
      obsoleteSslKeyExchange: json['obsoleteSslKeyExchange'] as bool,
      obsoleteSslCipher: json['obsoleteSslCipher'] as bool,
      obsoleteSslSignature: json['obsoleteSslSignature'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protocol': protocol,
      'keyExchange': keyExchange,
      'cipher': cipher,
      'certificate': [...certificate],
      'subjectName': subjectName,
      'issuer': issuer,
      'validFrom': validFrom.toJson(),
      'validTo': validTo.toJson(),
      'certifcateHasWeakSignature': certifcateHasWeakSignature,
      'modernSSL': modernSSL,
      'obsoleteSslProtocol': obsoleteSslProtocol,
      'obsoleteSslKeyExchange': obsoleteSslKeyExchange,
      'obsoleteSslCipher': obsoleteSslCipher,
      'obsoleteSslSignature': obsoleteSslSignature,
      if (keyExchangeGroup != null) 'keyExchangeGroup': keyExchangeGroup,
      if (mac != null) 'mac': mac,
    };
  }
}

/// Security state information about the page.
class VisibleSecurityState {
  /// The security level of the page.
  final SecurityState securityState;

  /// Security state details about the page certificate.
  final CertificateSecurityState certificateSecurityState;

  /// Array of security state issues ids.
  final List<String> securityStateIssueIds;

  VisibleSecurityState(
      {@required this.securityState,
      this.certificateSecurityState,
      @required this.securityStateIssueIds});

  factory VisibleSecurityState.fromJson(Map<String, dynamic> json) {
    return VisibleSecurityState(
      securityState: SecurityState.fromJson(json['securityState'] as String),
      certificateSecurityState: json.containsKey('certificateSecurityState')
          ? CertificateSecurityState.fromJson(
              json['certificateSecurityState'] as Map<String, dynamic>)
          : null,
      securityStateIssueIds: (json['securityStateIssueIds'] as List)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'securityState': securityState.toJson(),
      'securityStateIssueIds': [...securityStateIssueIds],
      if (certificateSecurityState != null)
        'certificateSecurityState': certificateSecurityState.toJson(),
    };
  }
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
      securityState: SecurityState.fromJson(json['securityState'] as String),
      title: json['title'] as String,
      summary: json['summary'] as String,
      description: json['description'] as String,
      mixedContentType:
          MixedContentType.fromJson(json['mixedContentType'] as String),
      certificate:
          (json['certificate'] as List).map((e) => e as String).toList(),
      recommendations: json.containsKey('recommendations')
          ? (json['recommendations'] as List).map((e) => e as String).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'securityState': securityState.toJson(),
      'title': title,
      'summary': summary,
      'description': description,
      'mixedContentType': mixedContentType.toJson(),
      'certificate': [...certificate],
      if (recommendations != null) 'recommendations': [...recommendations],
    };
  }
}

/// Information about insecure content on the page.
class InsecureContentStatus {
  /// Always false.
  final bool ranMixedContent;

  /// Always false.
  final bool displayedMixedContent;

  /// Always false.
  final bool containedMixedForm;

  /// Always false.
  final bool ranContentWithCertErrors;

  /// Always false.
  final bool displayedContentWithCertErrors;

  /// Always set to unknown.
  final SecurityState ranInsecureContentStyle;

  /// Always set to unknown.
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
      ranMixedContent: json['ranMixedContent'] as bool,
      displayedMixedContent: json['displayedMixedContent'] as bool,
      containedMixedForm: json['containedMixedForm'] as bool,
      ranContentWithCertErrors: json['ranContentWithCertErrors'] as bool,
      displayedContentWithCertErrors:
          json['displayedContentWithCertErrors'] as bool,
      ranInsecureContentStyle:
          SecurityState.fromJson(json['ranInsecureContentStyle'] as String),
      displayedInsecureContentStyle: SecurityState.fromJson(
          json['displayedInsecureContentStyle'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ranMixedContent': ranMixedContent,
      'displayedMixedContent': displayedMixedContent,
      'containedMixedForm': containedMixedForm,
      'ranContentWithCertErrors': ranContentWithCertErrors,
      'displayedContentWithCertErrors': displayedContentWithCertErrors,
      'ranInsecureContentStyle': ranInsecureContentStyle.toJson(),
      'displayedInsecureContentStyle': displayedInsecureContentStyle.toJson(),
    };
  }
}

/// The action to take when a certificate error occurs. continue will continue processing the
/// request and cancel will cancel the request.
class CertificateErrorAction {
  static const continue$ = CertificateErrorAction._('continue');
  static const cancel = CertificateErrorAction._('cancel');
  static const values = {
    'continue': continue$,
    'cancel': cancel,
  };

  final String value;

  const CertificateErrorAction._(this.value);

  factory CertificateErrorAction.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CertificateErrorAction && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
