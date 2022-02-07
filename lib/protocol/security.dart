import 'dart:async';
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

  /// The security state of the page changed. No longer being sent.
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
  @Deprecated('This command is deprecated')
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
  @Deprecated('This command is deprecated')
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
      {required this.eventId,
      required this.errorType,
      required this.requestURL});

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

  SecurityStateChangedEvent({required this.securityState});

  factory SecurityStateChangedEvent.fromJson(Map<String, dynamic> json) {
    return SecurityStateChangedEvent(
      securityState: SecurityState.fromJson(json['securityState'] as String),
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

  factory MixedContentType.fromJson(String value) => values[value]!;

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
  static const insecureBroken = SecurityState._('insecure-broken');
  static const values = {
    'unknown': unknown,
    'neutral': neutral,
    'insecure': insecure,
    'secure': secure,
    'info': info,
    'insecure-broken': insecureBroken,
  };

  final String value;

  const SecurityState._(this.value);

  factory SecurityState.fromJson(String value) => values[value]!;

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
  final String? keyExchangeGroup;

  /// Cipher name.
  final String cipher;

  /// TLS MAC. Note that AEAD ciphers do not have separate MACs.
  final String? mac;

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

  /// The highest priority network error code, if the certificate has an error.
  final String? certificateNetworkError;

  /// True if the certificate uses a weak signature aglorithm.
  final bool certificateHasWeakSignature;

  /// True if the certificate has a SHA1 signature in the chain.
  final bool certificateHasSha1Signature;

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
      {required this.protocol,
      required this.keyExchange,
      this.keyExchangeGroup,
      required this.cipher,
      this.mac,
      required this.certificate,
      required this.subjectName,
      required this.issuer,
      required this.validFrom,
      required this.validTo,
      this.certificateNetworkError,
      required this.certificateHasWeakSignature,
      required this.certificateHasSha1Signature,
      required this.modernSSL,
      required this.obsoleteSslProtocol,
      required this.obsoleteSslKeyExchange,
      required this.obsoleteSslCipher,
      required this.obsoleteSslSignature});

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
      certificateNetworkError: json.containsKey('certificateNetworkError')
          ? json['certificateNetworkError'] as String
          : null,
      certificateHasWeakSignature:
          json['certificateHasWeakSignature'] as bool? ?? false,
      certificateHasSha1Signature:
          json['certificateHasSha1Signature'] as bool? ?? false,
      modernSSL: json['modernSSL'] as bool? ?? false,
      obsoleteSslProtocol: json['obsoleteSslProtocol'] as bool? ?? false,
      obsoleteSslKeyExchange: json['obsoleteSslKeyExchange'] as bool? ?? false,
      obsoleteSslCipher: json['obsoleteSslCipher'] as bool? ?? false,
      obsoleteSslSignature: json['obsoleteSslSignature'] as bool? ?? false,
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
      'certificateHasWeakSignature': certificateHasWeakSignature,
      'certificateHasSha1Signature': certificateHasSha1Signature,
      'modernSSL': modernSSL,
      'obsoleteSslProtocol': obsoleteSslProtocol,
      'obsoleteSslKeyExchange': obsoleteSslKeyExchange,
      'obsoleteSslCipher': obsoleteSslCipher,
      'obsoleteSslSignature': obsoleteSslSignature,
      if (keyExchangeGroup != null) 'keyExchangeGroup': keyExchangeGroup,
      if (mac != null) 'mac': mac,
      if (certificateNetworkError != null)
        'certificateNetworkError': certificateNetworkError,
    };
  }
}

class SafetyTipStatus {
  static const badReputation = SafetyTipStatus._('badReputation');
  static const lookalike = SafetyTipStatus._('lookalike');
  static const values = {
    'badReputation': badReputation,
    'lookalike': lookalike,
  };

  final String value;

  const SafetyTipStatus._(this.value);

  factory SafetyTipStatus.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is SafetyTipStatus && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class SafetyTipInfo {
  /// Describes whether the page triggers any safety tips or reputation warnings. Default is unknown.
  final SafetyTipStatus safetyTipStatus;

  /// The URL the safety tip suggested ("Did you mean?"). Only filled in for lookalike matches.
  final String? safeUrl;

  SafetyTipInfo({required this.safetyTipStatus, this.safeUrl});

  factory SafetyTipInfo.fromJson(Map<String, dynamic> json) {
    return SafetyTipInfo(
      safetyTipStatus:
          SafetyTipStatus.fromJson(json['safetyTipStatus'] as String),
      safeUrl: json.containsKey('safeUrl') ? json['safeUrl'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'safetyTipStatus': safetyTipStatus.toJson(),
      if (safeUrl != null) 'safeUrl': safeUrl,
    };
  }
}

/// Security state information about the page.
class VisibleSecurityState {
  /// The security level of the page.
  final SecurityState securityState;

  /// Security state details about the page certificate.
  final CertificateSecurityState? certificateSecurityState;

  /// The type of Safety Tip triggered on the page. Note that this field will be set even if the Safety Tip UI was not actually shown.
  final SafetyTipInfo? safetyTipInfo;

  /// Array of security state issues ids.
  final List<String> securityStateIssueIds;

  VisibleSecurityState(
      {required this.securityState,
      this.certificateSecurityState,
      this.safetyTipInfo,
      required this.securityStateIssueIds});

  factory VisibleSecurityState.fromJson(Map<String, dynamic> json) {
    return VisibleSecurityState(
      securityState: SecurityState.fromJson(json['securityState'] as String),
      certificateSecurityState: json.containsKey('certificateSecurityState')
          ? CertificateSecurityState.fromJson(
              json['certificateSecurityState'] as Map<String, dynamic>)
          : null,
      safetyTipInfo: json.containsKey('safetyTipInfo')
          ? SafetyTipInfo.fromJson(
              json['safetyTipInfo'] as Map<String, dynamic>)
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
        'certificateSecurityState': certificateSecurityState!.toJson(),
      if (safetyTipInfo != null) 'safetyTipInfo': safetyTipInfo!.toJson(),
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
  final List<String>? recommendations;

  SecurityStateExplanation(
      {required this.securityState,
      required this.title,
      required this.summary,
      required this.description,
      required this.mixedContentType,
      required this.certificate,
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
      if (recommendations != null) 'recommendations': [...?recommendations],
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
      {required this.ranMixedContent,
      required this.displayedMixedContent,
      required this.containedMixedForm,
      required this.ranContentWithCertErrors,
      required this.displayedContentWithCertErrors,
      required this.ranInsecureContentStyle,
      required this.displayedInsecureContentStyle});

  factory InsecureContentStatus.fromJson(Map<String, dynamic> json) {
    return InsecureContentStatus(
      ranMixedContent: json['ranMixedContent'] as bool? ?? false,
      displayedMixedContent: json['displayedMixedContent'] as bool? ?? false,
      containedMixedForm: json['containedMixedForm'] as bool? ?? false,
      ranContentWithCertErrors:
          json['ranContentWithCertErrors'] as bool? ?? false,
      displayedContentWithCertErrors:
          json['displayedContentWithCertErrors'] as bool? ?? false,
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

  factory CertificateErrorAction.fromJson(String value) => values[value]!;

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
