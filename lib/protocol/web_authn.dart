import 'dart:async';
import 'package:meta/meta.dart' show required;
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
      'options': options.toJson(),
    });
    return AuthenticatorId.fromJson(result['authenticatorId']);
  }

  /// Removes the given authenticator.
  Future<void> removeVirtualAuthenticator(
      AuthenticatorId authenticatorId) async {
    await _client.send('WebAuthn.removeVirtualAuthenticator', {
      'authenticatorId': authenticatorId.toJson(),
    });
  }

  /// Adds the credential to the specified authenticator.
  Future<void> addCredential(
      AuthenticatorId authenticatorId, Credential credential) async {
    await _client.send('WebAuthn.addCredential', {
      'authenticatorId': authenticatorId.toJson(),
      'credential': credential.toJson(),
    });
  }

  /// Returns a single credential stored in the given virtual authenticator that
  /// matches the credential ID.
  Future<Credential> getCredential(
      AuthenticatorId authenticatorId, String credentialId) async {
    var result = await _client.send('WebAuthn.getCredential', {
      'authenticatorId': authenticatorId.toJson(),
      'credentialId': credentialId,
    });
    return Credential.fromJson(result['credential']);
  }

  /// Returns all the credentials stored in the given virtual authenticator.
  Future<List<Credential>> getCredentials(
      AuthenticatorId authenticatorId) async {
    var result = await _client.send('WebAuthn.getCredentials', {
      'authenticatorId': authenticatorId.toJson(),
    });
    return (result['credentials'] as List)
        .map((e) => Credential.fromJson(e))
        .toList();
  }

  /// Removes a credential from the authenticator.
  Future<void> removeCredential(
      AuthenticatorId authenticatorId, String credentialId) async {
    await _client.send('WebAuthn.removeCredential', {
      'authenticatorId': authenticatorId.toJson(),
      'credentialId': credentialId,
    });
  }

  /// Clears all the credentials from the specified device.
  Future<void> clearCredentials(AuthenticatorId authenticatorId) async {
    await _client.send('WebAuthn.clearCredentials', {
      'authenticatorId': authenticatorId.toJson(),
    });
  }

  /// Sets whether User Verification succeeds or fails for an authenticator.
  /// The default is true.
  Future<void> setUserVerified(
      AuthenticatorId authenticatorId, bool isUserVerified) async {
    await _client.send('WebAuthn.setUserVerified', {
      'authenticatorId': authenticatorId.toJson(),
      'isUserVerified': isUserVerified,
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

  factory AuthenticatorProtocol.fromJson(String value) => values[value];

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

  factory AuthenticatorTransport.fromJson(String value) => values[value];

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

  final AuthenticatorTransport transport;

  final bool hasResidentKey;

  final bool hasUserVerification;

  /// If set to true, tests of user presence will succeed immediately.
  /// Otherwise, they will not be resolved. Defaults to true.
  final bool automaticPresenceSimulation;

  VirtualAuthenticatorOptions(
      {@required this.protocol,
      @required this.transport,
      @required this.hasResidentKey,
      @required this.hasUserVerification,
      this.automaticPresenceSimulation});

  factory VirtualAuthenticatorOptions.fromJson(Map<String, dynamic> json) {
    return VirtualAuthenticatorOptions(
      protocol: AuthenticatorProtocol.fromJson(json['protocol']),
      transport: AuthenticatorTransport.fromJson(json['transport']),
      hasResidentKey: json['hasResidentKey'],
      hasUserVerification: json['hasUserVerification'],
      automaticPresenceSimulation:
          json.containsKey('automaticPresenceSimulation')
              ? json['automaticPresenceSimulation']
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protocol': protocol.toJson(),
      'transport': transport.toJson(),
      'hasResidentKey': hasResidentKey,
      'hasUserVerification': hasUserVerification,
      if (automaticPresenceSimulation != null)
        'automaticPresenceSimulation': automaticPresenceSimulation,
    };
  }
}

class Credential {
  final String credentialId;

  final bool isResidentCredential;

  /// Relying Party ID the credential is scoped to. Must be set when adding a
  /// credential.
  final String rpId;

  /// The ECDSA P-256 private key in PKCS#8 format.
  final String privateKey;

  /// An opaque byte sequence with a maximum size of 64 bytes mapping the
  /// credential to a specific user.
  final String userHandle;

  /// Signature counter. This is incremented by one for each successful
  /// assertion.
  /// See https://w3c.github.io/webauthn/#signature-counter
  final int signCount;

  Credential(
      {@required this.credentialId,
      @required this.isResidentCredential,
      this.rpId,
      @required this.privateKey,
      this.userHandle,
      @required this.signCount});

  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      credentialId: json['credentialId'],
      isResidentCredential: json['isResidentCredential'],
      rpId: json.containsKey('rpId') ? json['rpId'] : null,
      privateKey: json['privateKey'],
      userHandle: json.containsKey('userHandle') ? json['userHandle'] : null,
      signCount: json['signCount'],
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
    };
  }
}
