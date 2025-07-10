import 'dart:async';
import '../src/connection.dart';

/// This domain allows configuring virtual authenticators to test the WebAuthn
/// API.
class WebAuthnApi {
  final Client _client;

  WebAuthnApi(this._client);

  /// Triggered when a credential is added to an authenticator.
  Stream<CredentialAddedEvent> get onCredentialAdded => _client.onEvent
      .where((event) => event.name == 'WebAuthn.credentialAdded')
      .map((event) => CredentialAddedEvent.fromJson(event.parameters));

  /// Triggered when a credential is deleted, e.g. through
  /// PublicKeyCredential.signalUnknownCredential().
  Stream<CredentialDeletedEvent> get onCredentialDeleted => _client.onEvent
      .where((event) => event.name == 'WebAuthn.credentialDeleted')
      .map((event) => CredentialDeletedEvent.fromJson(event.parameters));

  /// Triggered when a credential is updated, e.g. through
  /// PublicKeyCredential.signalCurrentUserDetails().
  Stream<CredentialUpdatedEvent> get onCredentialUpdated => _client.onEvent
      .where((event) => event.name == 'WebAuthn.credentialUpdated')
      .map((event) => CredentialUpdatedEvent.fromJson(event.parameters));

  /// Triggered when a credential is used in a webauthn assertion.
  Stream<CredentialAssertedEvent> get onCredentialAsserted => _client.onEvent
      .where((event) => event.name == 'WebAuthn.credentialAsserted')
      .map((event) => CredentialAssertedEvent.fromJson(event.parameters));

  /// Enable the WebAuthn domain and start intercepting credential storage and
  /// retrieval with a virtual authenticator.
  /// [enableUI] Whether to enable the WebAuthn user interface. Enabling the UI is
  /// recommended for debugging and demo purposes, as it is closer to the real
  /// experience. Disabling the UI is recommended for automated testing.
  /// Supported at the embedder's discretion if UI is available.
  /// Defaults to false.
  Future<void> enable({bool? enableUI}) async {
    await _client.send('WebAuthn.enable', {
      if (enableUI != null) 'enableUI': enableUI,
    });
  }

  /// Disable the WebAuthn domain.
  Future<void> disable() async {
    await _client.send('WebAuthn.disable');
  }

  /// Creates and adds a virtual authenticator.
  Future<AuthenticatorId> addVirtualAuthenticator(
    VirtualAuthenticatorOptions options,
  ) async {
    var result = await _client.send('WebAuthn.addVirtualAuthenticator', {
      'options': options,
    });
    return AuthenticatorId.fromJson(result['authenticatorId'] as String);
  }

  /// Resets parameters isBogusSignature, isBadUV, isBadUP to false if they are not present.
  /// [isBogusSignature] If isBogusSignature is set, overrides the signature in the authenticator response to be zero.
  /// Defaults to false.
  /// [isBadUV] If isBadUV is set, overrides the UV bit in the flags in the authenticator response to
  /// be zero. Defaults to false.
  /// [isBadUP] If isBadUP is set, overrides the UP bit in the flags in the authenticator response to
  /// be zero. Defaults to false.
  Future<void> setResponseOverrideBits(
    AuthenticatorId authenticatorId, {
    bool? isBogusSignature,
    bool? isBadUV,
    bool? isBadUP,
  }) async {
    await _client.send('WebAuthn.setResponseOverrideBits', {
      'authenticatorId': authenticatorId,
      if (isBogusSignature != null) 'isBogusSignature': isBogusSignature,
      if (isBadUV != null) 'isBadUV': isBadUV,
      if (isBadUP != null) 'isBadUP': isBadUP,
    });
  }

  /// Removes the given authenticator.
  Future<void> removeVirtualAuthenticator(
    AuthenticatorId authenticatorId,
  ) async {
    await _client.send('WebAuthn.removeVirtualAuthenticator', {
      'authenticatorId': authenticatorId,
    });
  }

  /// Adds the credential to the specified authenticator.
  Future<void> addCredential(
    AuthenticatorId authenticatorId,
    Credential credential,
  ) async {
    await _client.send('WebAuthn.addCredential', {
      'authenticatorId': authenticatorId,
      'credential': credential,
    });
  }

  /// Returns a single credential stored in the given virtual authenticator that
  /// matches the credential ID.
  Future<Credential> getCredential(
    AuthenticatorId authenticatorId,
    String credentialId,
  ) async {
    var result = await _client.send('WebAuthn.getCredential', {
      'authenticatorId': authenticatorId,
      'credentialId': credentialId,
    });
    return Credential.fromJson(result['credential'] as Map<String, dynamic>);
  }

  /// Returns all the credentials stored in the given virtual authenticator.
  Future<List<Credential>> getCredentials(
    AuthenticatorId authenticatorId,
  ) async {
    var result = await _client.send('WebAuthn.getCredentials', {
      'authenticatorId': authenticatorId,
    });
    return (result['credentials'] as List)
        .map((e) => Credential.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Removes a credential from the authenticator.
  Future<void> removeCredential(
    AuthenticatorId authenticatorId,
    String credentialId,
  ) async {
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
    AuthenticatorId authenticatorId,
    bool isUserVerified,
  ) async {
    await _client.send('WebAuthn.setUserVerified', {
      'authenticatorId': authenticatorId,
      'isUserVerified': isUserVerified,
    });
  }

  /// Sets whether tests of user presence will succeed immediately (if true) or fail to resolve (if false) for an authenticator.
  /// The default is true.
  Future<void> setAutomaticPresenceSimulation(
    AuthenticatorId authenticatorId,
    bool enabled,
  ) async {
    await _client.send('WebAuthn.setAutomaticPresenceSimulation', {
      'authenticatorId': authenticatorId,
      'enabled': enabled,
    });
  }

  /// Allows setting credential properties.
  /// https://w3c.github.io/webauthn/#sctn-automation-set-credential-properties
  Future<void> setCredentialProperties(
    AuthenticatorId authenticatorId,
    String credentialId, {
    bool? backupEligibility,
    bool? backupState,
  }) async {
    await _client.send('WebAuthn.setCredentialProperties', {
      'authenticatorId': authenticatorId,
      'credentialId': credentialId,
      if (backupEligibility != null) 'backupEligibility': backupEligibility,
      if (backupState != null) 'backupState': backupState,
    });
  }
}

class CredentialAddedEvent {
  final AuthenticatorId authenticatorId;

  final Credential credential;

  CredentialAddedEvent({
    required this.authenticatorId,
    required this.credential,
  });

  factory CredentialAddedEvent.fromJson(Map<String, dynamic> json) {
    return CredentialAddedEvent(
      authenticatorId: AuthenticatorId.fromJson(
        json['authenticatorId'] as String,
      ),
      credential: Credential.fromJson(
        json['credential'] as Map<String, dynamic>,
      ),
    );
  }
}

class CredentialDeletedEvent {
  final AuthenticatorId authenticatorId;

  final String credentialId;

  CredentialDeletedEvent({
    required this.authenticatorId,
    required this.credentialId,
  });

  factory CredentialDeletedEvent.fromJson(Map<String, dynamic> json) {
    return CredentialDeletedEvent(
      authenticatorId: AuthenticatorId.fromJson(
        json['authenticatorId'] as String,
      ),
      credentialId: json['credentialId'] as String,
    );
  }
}

class CredentialUpdatedEvent {
  final AuthenticatorId authenticatorId;

  final Credential credential;

  CredentialUpdatedEvent({
    required this.authenticatorId,
    required this.credential,
  });

  factory CredentialUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return CredentialUpdatedEvent(
      authenticatorId: AuthenticatorId.fromJson(
        json['authenticatorId'] as String,
      ),
      credential: Credential.fromJson(
        json['credential'] as Map<String, dynamic>,
      ),
    );
  }
}

class CredentialAssertedEvent {
  final AuthenticatorId authenticatorId;

  final Credential credential;

  CredentialAssertedEvent({
    required this.authenticatorId,
    required this.credential,
  });

  factory CredentialAssertedEvent.fromJson(Map<String, dynamic> json) {
    return CredentialAssertedEvent(
      authenticatorId: AuthenticatorId.fromJson(
        json['authenticatorId'] as String,
      ),
      credential: Credential.fromJson(
        json['credential'] as Map<String, dynamic>,
      ),
    );
  }
}

extension type AuthenticatorId(String value) {
  factory AuthenticatorId.fromJson(String value) => AuthenticatorId(value);

  String toJson() => value;
}

enum AuthenticatorProtocol {
  u2f('u2f'),
  ctap2('ctap2');

  final String value;

  const AuthenticatorProtocol(this.value);

  factory AuthenticatorProtocol.fromJson(String value) =>
      AuthenticatorProtocol.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum Ctap2Version {
  ctap20('ctap2_0'),
  ctap21('ctap2_1');

  final String value;

  const Ctap2Version(this.value);

  factory Ctap2Version.fromJson(String value) =>
      Ctap2Version.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum AuthenticatorTransport {
  usb('usb'),
  nfc('nfc'),
  ble('ble'),
  cable('cable'),
  internal('internal');

  final String value;

  const AuthenticatorTransport(this.value);

  factory AuthenticatorTransport.fromJson(String value) =>
      AuthenticatorTransport.values.firstWhere((e) => e.value == value);

  String toJson() => value;

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

  /// If set to true, the authenticator will support the prf extension.
  /// https://w3c.github.io/webauthn/#prf-extension
  /// Defaults to false.
  final bool? hasPrf;

  /// If set to true, tests of user presence will succeed immediately.
  /// Otherwise, they will not be resolved. Defaults to true.
  final bool? automaticPresenceSimulation;

  /// Sets whether User Verification succeeds or fails for an authenticator.
  /// Defaults to false.
  final bool? isUserVerified;

  /// Credentials created by this authenticator will have the backup
  /// eligibility (BE) flag set to this value. Defaults to false.
  /// https://w3c.github.io/webauthn/#sctn-credential-backup
  final bool? defaultBackupEligibility;

  /// Credentials created by this authenticator will have the backup state
  /// (BS) flag set to this value. Defaults to false.
  /// https://w3c.github.io/webauthn/#sctn-credential-backup
  final bool? defaultBackupState;

  VirtualAuthenticatorOptions({
    required this.protocol,
    this.ctap2Version,
    required this.transport,
    this.hasResidentKey,
    this.hasUserVerification,
    this.hasLargeBlob,
    this.hasCredBlob,
    this.hasMinPinLength,
    this.hasPrf,
    this.automaticPresenceSimulation,
    this.isUserVerified,
    this.defaultBackupEligibility,
    this.defaultBackupState,
  });

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
      hasCredBlob: json.containsKey('hasCredBlob')
          ? json['hasCredBlob'] as bool
          : null,
      hasMinPinLength: json.containsKey('hasMinPinLength')
          ? json['hasMinPinLength'] as bool
          : null,
      hasPrf: json.containsKey('hasPrf') ? json['hasPrf'] as bool : null,
      automaticPresenceSimulation:
          json.containsKey('automaticPresenceSimulation')
          ? json['automaticPresenceSimulation'] as bool
          : null,
      isUserVerified: json.containsKey('isUserVerified')
          ? json['isUserVerified'] as bool
          : null,
      defaultBackupEligibility: json.containsKey('defaultBackupEligibility')
          ? json['defaultBackupEligibility'] as bool
          : null,
      defaultBackupState: json.containsKey('defaultBackupState')
          ? json['defaultBackupState'] as bool
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
      if (hasPrf != null) 'hasPrf': hasPrf,
      if (automaticPresenceSimulation != null)
        'automaticPresenceSimulation': automaticPresenceSimulation,
      if (isUserVerified != null) 'isUserVerified': isUserVerified,
      if (defaultBackupEligibility != null)
        'defaultBackupEligibility': defaultBackupEligibility,
      if (defaultBackupState != null) 'defaultBackupState': defaultBackupState,
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

  /// Assertions returned by this credential will have the backup eligibility
  /// (BE) flag set to this value. Defaults to the authenticator's
  /// defaultBackupEligibility value.
  final bool? backupEligibility;

  /// Assertions returned by this credential will have the backup state (BS)
  /// flag set to this value. Defaults to the authenticator's
  /// defaultBackupState value.
  final bool? backupState;

  /// The credential's user.name property. Equivalent to empty if not set.
  /// https://w3c.github.io/webauthn/#dom-publickeycredentialentity-name
  final String? userName;

  /// The credential's user.displayName property. Equivalent to empty if
  /// not set.
  /// https://w3c.github.io/webauthn/#dom-publickeycredentialuserentity-displayname
  final String? userDisplayName;

  Credential({
    required this.credentialId,
    required this.isResidentCredential,
    this.rpId,
    required this.privateKey,
    this.userHandle,
    required this.signCount,
    this.largeBlob,
    this.backupEligibility,
    this.backupState,
    this.userName,
    this.userDisplayName,
  });

  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      credentialId: json['credentialId'] as String,
      isResidentCredential: json['isResidentCredential'] as bool? ?? false,
      rpId: json.containsKey('rpId') ? json['rpId'] as String : null,
      privateKey: json['privateKey'] as String,
      userHandle: json.containsKey('userHandle')
          ? json['userHandle'] as String
          : null,
      signCount: json['signCount'] as int,
      largeBlob: json.containsKey('largeBlob')
          ? json['largeBlob'] as String
          : null,
      backupEligibility: json.containsKey('backupEligibility')
          ? json['backupEligibility'] as bool
          : null,
      backupState: json.containsKey('backupState')
          ? json['backupState'] as bool
          : null,
      userName: json.containsKey('userName')
          ? json['userName'] as String
          : null,
      userDisplayName: json.containsKey('userDisplayName')
          ? json['userDisplayName'] as String
          : null,
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
      if (backupEligibility != null) 'backupEligibility': backupEligibility,
      if (backupState != null) 'backupState': backupState,
      if (userName != null) 'userName': userName,
      if (userDisplayName != null) 'userDisplayName': userDisplayName,
    };
  }
}
