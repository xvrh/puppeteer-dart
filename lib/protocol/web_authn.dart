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
    var parameters = <String, dynamic>{
      'options': options.toJson(),
    };
    var result =
        await _client.send('WebAuthn.addVirtualAuthenticator', parameters);
    return AuthenticatorId.fromJson(result['authenticatorId']);
  }

  /// Removes the given authenticator.
  Future<void> removeVirtualAuthenticator(
      AuthenticatorId authenticatorId) async {
    var parameters = <String, dynamic>{
      'authenticatorId': authenticatorId.toJson(),
    };
    await _client.send('WebAuthn.removeVirtualAuthenticator', parameters);
  }

  /// Adds the credential to the specified authenticator.
  Future<void> addCredential(
      AuthenticatorId authenticatorId, Credential credential) async {
    var parameters = <String, dynamic>{
      'authenticatorId': authenticatorId.toJson(),
      'credential': credential.toJson(),
    };
    await _client.send('WebAuthn.addCredential', parameters);
  }

  /// Returns all the credentials stored in the given virtual authenticator.
  Future<List<Credential>> getCredentials(
      AuthenticatorId authenticatorId) async {
    var parameters = <String, dynamic>{
      'authenticatorId': authenticatorId.toJson(),
    };
    var result = await _client.send('WebAuthn.getCredentials', parameters);
    return (result['credentials'] as List)
        .map((e) => Credential.fromJson(e))
        .toList();
  }

  /// Clears all the credentials from the specified device.
  Future<void> clearCredentials(AuthenticatorId authenticatorId) async {
    var parameters = <String, dynamic>{
      'authenticatorId': authenticatorId.toJson(),
    };
    await _client.send('WebAuthn.clearCredentials', parameters);
  }

  /// Sets whether User Verification succeeds or fails for an authenticator.
  /// The default is true.
  Future<void> setUserVerified(
      AuthenticatorId authenticatorId, bool isUserVerified) async {
    var parameters = <String, dynamic>{
      'authenticatorId': authenticatorId.toJson(),
      'isUserVerified': isUserVerified,
    };
    await _client.send('WebAuthn.setUserVerified', parameters);
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
    var json = <String, dynamic>{
      'protocol': protocol.toJson(),
      'transport': transport.toJson(),
      'hasResidentKey': hasResidentKey,
      'hasUserVerification': hasUserVerification,
    };
    if (automaticPresenceSimulation != null) {
      json['automaticPresenceSimulation'] = automaticPresenceSimulation;
    }
    return json;
  }
}

class Credential {
  final String credentialId;

  /// SHA-256 hash of the Relying Party ID the credential is scoped to. Must
  /// be 32 bytes long.
  /// See https://w3c.github.io/webauthn/#rpidhash
  final String rpIdHash;

  /// The private key in PKCS#8 format.
  final String privateKey;

  /// Signature counter. This is incremented by one for each successful
  /// assertion.
  /// See https://w3c.github.io/webauthn/#signature-counter
  final int signCount;

  Credential(
      {@required this.credentialId,
      @required this.rpIdHash,
      @required this.privateKey,
      @required this.signCount});

  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      credentialId: json['credentialId'],
      rpIdHash: json['rpIdHash'],
      privateKey: json['privateKey'],
      signCount: json['signCount'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'credentialId': credentialId,
      'rpIdHash': rpIdHash,
      'privateKey': privateKey,
      'signCount': signCount,
    };
    return json;
  }
}
