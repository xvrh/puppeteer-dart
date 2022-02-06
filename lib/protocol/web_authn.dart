import 'dart:async';
import '../src/connection.dart';

/// This domain allows configuring virtual authenticators to test the WebAuthn
/// API.
class WebAuthnApi {
  final Client _client;

  WebAuthnApi(this._client);

  /// Enable the WebAuthn domain and start intercepting credential storage and
  /// retrieval with a virtual authenticator.
  Future<void> enable() async {
    await _client.send('WebAuthn.enable');
  }

  /// Disable the WebAuthn domain.
  Future<void> disable() async {
    await _client.send('WebAuthn.disable');
  }

  /// Creates and adds a virtual authenticator.
  Future<AuthenticatorId> addVirtualAuthenticator(
      VirtualAuthenticatorOptions options) async {
    var result = await _client.send('WebAuthn.addVirtualAuthenticator', {
      'options': options,
    });
    return AuthenticatorId.fromJson(result['authenticatorId'] as String);
  }

  /// Removes the given authenticator.
  Future<void> removeVirtualAuthenticator(
      AuthenticatorId authenticatorId) async {
    await _client.send('WebAuthn.removeVirtualAuthenticator', {
      'authenticatorId': authenticatorId,
    });
  }

  /// Adds the credential to the specified authenticator.
  Future<void> addCredential(
      AuthenticatorId authenticatorId, Credential credential) async {
    await _client.send('WebAuthn.addCredential', {
      'authenticatorId': authenticatorId,
      'credential': credential,
    });
  }

  /// Returns a single credential stored in the given virtual authenticator that
  /// matches the credential ID.
  Future<Credential> getCredential(
      AuthenticatorId authenticatorId, String credentialId) async {
    var result = await _client.send('WebAuthn.getCredential', {
      'authenticatorId': authenticatorId,
      'credentialId': credentialId,
    });
    return Credential.fromJson(result['credential'] as Map<String, dynamic>);
  }

  /// Returns all the credentials stored in the given virtual authenticator.
  Future<List<Credential>> getCredentials(
      AuthenticatorId authenticatorId) async {
    var result = await _client.send('WebAuthn.getCredentials', {
      'authenticatorId': authenticatorId,
    });
    return (result['credentials'] as List)
        .map((e) => Credential.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Removes a credential from the authenticator.
  Future<void> removeCredential(
      AuthenticatorId authenticatorId, String credentialId) async {
    await _client.send('WebAuthn.removeCredential', {
      'authenticatorId': authenticatorId,
      'credentialId': credentialId,
    });
  }

  /// Clears all the credentials from the specified device.
  Future<void> clearCredentials(AuthenticatorId authenticatorId) async {
    await _client.send('WebAuthn.clearCredentials', {
      'authenticatorId': authenticatorId,
    });
  }

  /// Sets whether User Verification succeeds or fails for an authenticator.
  /// The default is true.
  Future<void> setUserVerified(
      AuthenticatorId authenticatorId, bool isUserVerified) async {
    await _client.send('WebAuthn.setUserVerified', {
      'authenticatorId': authenticatorId,
      'isUserVerified': isUserVerified,
    });
  }

  /// Sets whether tests of user presence will succeed immediately (if true) or fail to resolve (if false) for an authenticator.
  /// The default is true.
  Future<void> setAutomaticPresenceSimulation(
      AuthenticatorId authenticatorId, bool enabled) async {
    await _client.send('WebAuthn.setAutomaticPresenceSimulation', {
      'authenticatorId': authenticatorId,
      'enabled': enabled,
    });
  }
}

class AuthenticatorId {
  final String value;

  AuthenticatorId(this.value);

  factory AuthenticatorId.fromJson(String value) => AuthenticatorId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is AuthenticatorId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class AuthenticatorProtocol {
  static const u2f = AuthenticatorProtocol._('u2f');
  static const ctap2 = AuthenticatorProtocol._('ctap2');
  static const values = {
    'u2f': u2f,
    'ctap2': ctap2,
  };

  final String value;

  const AuthenticatorProtocol._(this.value);

  factory AuthenticatorProtocol.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is AuthenticatorProtocol && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class Ctap2Version {
  static const ctap20 = Ctap2Version._('ctap2_0');
  static const ctap21 = Ctap2Version._('ctap2_1');
  static const values = {
    'ctap2_0': ctap20,
    'ctap2_1': ctap21,
  };

  final String value;

  const Ctap2Version._(this.value);

  factory Ctap2Version.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is Ctap2Version && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class AuthenticatorTransport {
  static const usb = AuthenticatorTransport._('usb');
  static const nfc = AuthenticatorTransport._('nfc');
  static const ble = AuthenticatorTransport._('ble');
  static const cable = AuthenticatorTransport._('cable');
  static const internal = AuthenticatorTransport._('internal');
  static const values = {
    'usb': usb,
    'nfc': nfc,
    'ble': ble,
    'cable': cable,
    'internal': internal,
  };

  final String value;

  const AuthenticatorTransport._(this.value);

  factory AuthenticatorTransport.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is AuthenticatorTransport && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class VirtualAuthenticatorOptions {
  final AuthenticatorProtocol protocol;

  /// Defaults to ctap2_0. Ignored if |protocol| == u2f.
  final Ctap2Version? ctap2Version;

  final AuthenticatorTransport transport;

  /// Defaults to false.
  final bool? hasResidentKey;

  /// Defaults to false.
  final bool? hasUserVerification;

  /// If set to true, the authenticator will support the largeBlob extension.
  /// https://w3c.github.io/webauthn#largeBlob
  /// Defaults to false.
  final bool? hasLargeBlob;

  /// If set to true, the authenticator will support the credBlob extension.
  /// https://fidoalliance.org/specs/fido-v2.1-rd-20201208/fido-client-to-authenticator-protocol-v2.1-rd-20201208.html#sctn-credBlob-extension
  /// Defaults to false.
  final bool? hasCredBlob;

  /// If set to true, the authenticator will support the minPinLength extension.
  /// https://fidoalliance.org/specs/fido-v2.1-ps-20210615/fido-client-to-authenticator-protocol-v2.1-ps-20210615.html#sctn-minpinlength-extension
  /// Defaults to false.
  final bool? hasMinPinLength;

  /// If set to true, tests of user presence will succeed immediately.
  /// Otherwise, they will not be resolved. Defaults to true.
  final bool? automaticPresenceSimulation;

  /// Sets whether User Verification succeeds or fails for an authenticator.
  /// Defaults to false.
  final bool? isUserVerified;

  VirtualAuthenticatorOptions(
      {required this.protocol,
      this.ctap2Version,
      required this.transport,
      this.hasResidentKey,
      this.hasUserVerification,
      this.hasLargeBlob,
      this.hasCredBlob,
      this.hasMinPinLength,
      this.automaticPresenceSimulation,
      this.isUserVerified});

  factory VirtualAuthenticatorOptions.fromJson(Map<String, dynamic> json) {
    return VirtualAuthenticatorOptions(
      protocol: AuthenticatorProtocol.fromJson(json['protocol'] as String),
      ctap2Version: json.containsKey('ctap2Version')
          ? Ctap2Version.fromJson(json['ctap2Version'] as String)
          : null,
      transport: AuthenticatorTransport.fromJson(json['transport'] as String),
      hasResidentKey: json.containsKey('hasResidentKey')
          ? json['hasResidentKey'] as bool
          : null,
      hasUserVerification: json.containsKey('hasUserVerification')
          ? json['hasUserVerification'] as bool
          : null,
      hasLargeBlob: json.containsKey('hasLargeBlob')
          ? json['hasLargeBlob'] as bool
          : null,
      hasCredBlob:
          json.containsKey('hasCredBlob') ? json['hasCredBlob'] as bool : null,
      hasMinPinLength: json.containsKey('hasMinPinLength')
          ? json['hasMinPinLength'] as bool
          : null,
      automaticPresenceSimulation:
          json.containsKey('automaticPresenceSimulation')
              ? json['automaticPresenceSimulation'] as bool
              : null,
      isUserVerified: json.containsKey('isUserVerified')
          ? json['isUserVerified'] as bool
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protocol': protocol.toJson(),
      'transport': transport.toJson(),
      if (ctap2Version != null) 'ctap2Version': ctap2Version!.toJson(),
      if (hasResidentKey != null) 'hasResidentKey': hasResidentKey,
      if (hasUserVerification != null)
        'hasUserVerification': hasUserVerification,
      if (hasLargeBlob != null) 'hasLargeBlob': hasLargeBlob,
      if (hasCredBlob != null) 'hasCredBlob': hasCredBlob,
      if (hasMinPinLength != null) 'hasMinPinLength': hasMinPinLength,
      if (automaticPresenceSimulation != null)
        'automaticPresenceSimulation': automaticPresenceSimulation,
      if (isUserVerified != null) 'isUserVerified': isUserVerified,
    };
  }
}

class Credential {
  final String credentialId;

  final bool isResidentCredential;

  /// Relying Party ID the credential is scoped to. Must be set when adding a
  /// credential.
  final String? rpId;

  /// The ECDSA P-256 private key in PKCS#8 format.
  final String privateKey;

  /// An opaque byte sequence with a maximum size of 64 bytes mapping the
  /// credential to a specific user.
  final String? userHandle;

  /// Signature counter. This is incremented by one for each successful
  /// assertion.
  /// See https://w3c.github.io/webauthn/#signature-counter
  final int signCount;

  /// The large blob associated with the credential.
  /// See https://w3c.github.io/webauthn/#sctn-large-blob-extension
  final String? largeBlob;

  Credential(
      {required this.credentialId,
      required this.isResidentCredential,
      this.rpId,
      required this.privateKey,
      this.userHandle,
      required this.signCount,
      this.largeBlob});

  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      credentialId: json['credentialId'] as String,
      isResidentCredential: json['isResidentCredential'] as bool? ?? false,
      rpId: json.containsKey('rpId') ? json['rpId'] as String : null,
      privateKey: json['privateKey'] as String,
      userHandle:
          json.containsKey('userHandle') ? json['userHandle'] as String : null,
      signCount: json['signCount'] as int,
      largeBlob:
          json.containsKey('largeBlob') ? json['largeBlob'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'credentialId': credentialId,
      'isResidentCredential': isResidentCredential,
      'privateKey': privateKey,
      'signCount': signCount,
      if (rpId != null) 'rpId': rpId,
      if (userHandle != null) 'userHandle': userHandle,
      if (largeBlob != null) 'largeBlob': largeBlob,
    };
  }
}
