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

  VirtualAuthenticatorOptions(
      {@required this.protocol,
      @required this.transport,
      @required this.hasResidentKey,
      @required this.hasUserVerification});

  factory VirtualAuthenticatorOptions.fromJson(Map<String, dynamic> json) {
    return VirtualAuthenticatorOptions(
      protocol: AuthenticatorProtocol.fromJson(json['protocol']),
      transport: AuthenticatorTransport.fromJson(json['transport']),
      hasResidentKey: json['hasResidentKey'],
      hasUserVerification: json['hasUserVerification'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'protocol': protocol.toJson(),
      'transport': transport.toJson(),
      'hasResidentKey': hasResidentKey,
      'hasUserVerification': hasUserVerification,
    };
    return json;
  }
}
