/// Security

import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';

class SecurityManager {
  final Session _client;

  SecurityManager(this._client);

  /// Enables tracking security state changes.
  Future enable() async {
    await _client.send('Security.enable');
  }

  /// Disables tracking security state changes.
  Future disable() async {
    await _client.send('Security.disable');
  }

  /// Handles a certificate error that fired a certificateError event.
  /// [eventId] The ID of the event.
  /// [action] The action to take on the certificate error.
  Future handleCertificateError(
    int eventId,
    CertificateErrorAction action,
  ) async {
    Map parameters = {
      'eventId': eventId.toString(),
      'action': action.toJson(),
    };
    await _client.send('Security.handleCertificateError', parameters);
  }

  /// Enable/disable overriding certificate errors. If enabled, all certificate error events need to be handled by the DevTools client and should be answered with handleCertificateError commands.
  /// [override] If true, certificate errors will be overridden.
  Future setOverrideCertificateErrors(
    bool override,
  ) async {
    Map parameters = {
      'override': override.toString(),
    };
    await _client.send('Security.setOverrideCertificateErrors', parameters);
  }
}

/// An internal certificate ID value.
class CertificateId {
  final int value;

  CertificateId(this.value);

  int toJson() => value;
}

/// A description of mixed content (HTTP resources on HTTPS pages), as defined by https://www.w3.org/TR/mixed-content/#categories
class MixedContentType {
  static const MixedContentType blockable =
      const MixedContentType._('blockable');
  static const MixedContentType optionallyBlockable =
      const MixedContentType._('optionally-blockable');
  static const MixedContentType none = const MixedContentType._('none');

  final String value;

  const MixedContentType._(this.value);

  String toJson() => value;
}

/// The security level of a page or resource.
class SecurityState {
  static const SecurityState unknown = const SecurityState._('unknown');
  static const SecurityState neutral = const SecurityState._('neutral');
  static const SecurityState insecure = const SecurityState._('insecure');
  static const SecurityState warning = const SecurityState._('warning');
  static const SecurityState secure = const SecurityState._('secure');
  static const SecurityState info = const SecurityState._('info');

  final String value;

  const SecurityState._(this.value);

  String toJson() => value;
}

/// An explanation of an factor contributing to the security state.
class SecurityStateExplanation {
  /// Security state representing the severity of the factor being explained.
  final SecurityState securityState;

  /// Short phrase describing the type of factor.
  final String summary;

  /// Full text explanation of the factor.
  final String description;

  /// The type of mixed content described by the explanation.
  final MixedContentType mixedContentType;

  /// Page certificate.
  final List<String> certificate;

  SecurityStateExplanation({
    @required this.securityState,
    @required this.summary,
    @required this.description,
    @required this.mixedContentType,
    @required this.certificate,
  });

  Map toJson() {
    Map json = {
      'securityState': securityState.toJson(),
      'summary': summary.toString(),
      'description': description.toString(),
      'mixedContentType': mixedContentType.toJson(),
      'certificate': certificate.map((e) => e.toString()).toList(),
    };
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

  /// True if the page was loaded over HTTPS without certificate errors, and ran content such as scripts that were loaded with certificate errors.
  final bool ranContentWithCertErrors;

  /// True if the page was loaded over HTTPS without certificate errors, and displayed content such as images that were loaded with certificate errors.
  final bool displayedContentWithCertErrors;

  /// Security state representing a page that ran insecure content.
  final SecurityState ranInsecureContentStyle;

  /// Security state representing a page that displayed insecure content.
  final SecurityState displayedInsecureContentStyle;

  InsecureContentStatus({
    @required this.ranMixedContent,
    @required this.displayedMixedContent,
    @required this.containedMixedForm,
    @required this.ranContentWithCertErrors,
    @required this.displayedContentWithCertErrors,
    @required this.ranInsecureContentStyle,
    @required this.displayedInsecureContentStyle,
  });

  Map toJson() {
    Map json = {
      'ranMixedContent': ranMixedContent.toString(),
      'displayedMixedContent': displayedMixedContent.toString(),
      'containedMixedForm': containedMixedForm.toString(),
      'ranContentWithCertErrors': ranContentWithCertErrors.toString(),
      'displayedContentWithCertErrors':
          displayedContentWithCertErrors.toString(),
      'ranInsecureContentStyle': ranInsecureContentStyle.toJson(),
      'displayedInsecureContentStyle': displayedInsecureContentStyle.toJson(),
    };
    return json;
  }
}

/// The action to take when a certificate error occurs. continue will continue processing the request and cancel will cancel the request.
class CertificateErrorAction {
  static const CertificateErrorAction continue$ =
      const CertificateErrorAction._('continue');
  static const CertificateErrorAction cancel =
      const CertificateErrorAction._('cancel');

  final String value;

  const CertificateErrorAction._(this.value);

  String toJson() => value;
}
