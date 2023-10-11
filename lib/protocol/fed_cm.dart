import 'dart:async';
import '../src/connection.dart';

/// This domain allows interacting with the FedCM dialog.
class FedCmApi {
  final Client _client;

  FedCmApi(this._client);

  Stream<DialogShownEvent> get onDialogShown => _client.onEvent
      .where((event) => event.name == 'FedCm.dialogShown')
      .map((event) => DialogShownEvent.fromJson(event.parameters));

  /// [disableRejectionDelay] Allows callers to disable the promise rejection delay that would
  /// normally happen, if this is unimportant to what's being tested.
  /// (step 4 of https://fedidcg.github.io/FedCM/#browser-api-rp-sign-in)
  Future<void> enable({bool? disableRejectionDelay}) async {
    await _client.send('FedCm.enable', {
      if (disableRejectionDelay != null)
        'disableRejectionDelay': disableRejectionDelay,
    });
  }

  Future<void> disable() async {
    await _client.send('FedCm.disable');
  }

  Future<void> selectAccount(String dialogId, int accountIndex) async {
    await _client.send('FedCm.selectAccount', {
      'dialogId': dialogId,
      'accountIndex': accountIndex,
    });
  }

  /// Only valid if the dialog type is ConfirmIdpSignin. Acts as if the user had
  /// clicked the continue button.
  Future<void> confirmIdpSignin(String dialogId) async {
    await _client.send('FedCm.confirmIdpSignin', {
      'dialogId': dialogId,
    });
  }

  Future<void> dismissDialog(String dialogId, {bool? triggerCooldown}) async {
    await _client.send('FedCm.dismissDialog', {
      'dialogId': dialogId,
      if (triggerCooldown != null) 'triggerCooldown': triggerCooldown,
    });
  }

  /// Resets the cooldown time, if any, to allow the next FedCM call to show
  /// a dialog even if one was recently dismissed by the user.
  Future<void> resetCooldown() async {
    await _client.send('FedCm.resetCooldown');
  }
}

class DialogShownEvent {
  final String dialogId;

  final DialogType dialogType;

  final List<Account> accounts;

  /// These exist primarily so that the caller can verify the
  /// RP context was used appropriately.
  final String title;

  final String? subtitle;

  DialogShownEvent(
      {required this.dialogId,
      required this.dialogType,
      required this.accounts,
      required this.title,
      this.subtitle});

  factory DialogShownEvent.fromJson(Map<String, dynamic> json) {
    return DialogShownEvent(
      dialogId: json['dialogId'] as String,
      dialogType: DialogType.fromJson(json['dialogType'] as String),
      accounts: (json['accounts'] as List)
          .map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList(),
      title: json['title'] as String,
      subtitle:
          json.containsKey('subtitle') ? json['subtitle'] as String : null,
    );
  }
}

/// Whether this is a sign-up or sign-in action for this account, i.e.
/// whether this account has ever been used to sign in to this RP before.
enum LoginState {
  signIn('SignIn'),
  signUp('SignUp'),
  ;

  final String value;

  const LoginState(this.value);

  factory LoginState.fromJson(String value) =>
      LoginState.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Whether the dialog shown is an account chooser or an auto re-authentication dialog.
enum DialogType {
  accountChooser('AccountChooser'),
  autoReauthn('AutoReauthn'),
  confirmIdpSignin('ConfirmIdpSignin'),
  ;

  final String value;

  const DialogType(this.value);

  factory DialogType.fromJson(String value) =>
      DialogType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Corresponds to IdentityRequestAccount
class Account {
  final String accountId;

  final String email;

  final String name;

  final String givenName;

  final String pictureUrl;

  final String idpConfigUrl;

  final String idpSigninUrl;

  final LoginState loginState;

  /// These two are only set if the loginState is signUp
  final String? termsOfServiceUrl;

  final String? privacyPolicyUrl;

  Account(
      {required this.accountId,
      required this.email,
      required this.name,
      required this.givenName,
      required this.pictureUrl,
      required this.idpConfigUrl,
      required this.idpSigninUrl,
      required this.loginState,
      this.termsOfServiceUrl,
      this.privacyPolicyUrl});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountId: json['accountId'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      givenName: json['givenName'] as String,
      pictureUrl: json['pictureUrl'] as String,
      idpConfigUrl: json['idpConfigUrl'] as String,
      idpSigninUrl: json['idpSigninUrl'] as String,
      loginState: LoginState.fromJson(json['loginState'] as String),
      termsOfServiceUrl: json.containsKey('termsOfServiceUrl')
          ? json['termsOfServiceUrl'] as String
          : null,
      privacyPolicyUrl: json.containsKey('privacyPolicyUrl')
          ? json['privacyPolicyUrl'] as String
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'email': email,
      'name': name,
      'givenName': givenName,
      'pictureUrl': pictureUrl,
      'idpConfigUrl': idpConfigUrl,
      'idpSigninUrl': idpSigninUrl,
      'loginState': loginState.toJson(),
      if (termsOfServiceUrl != null) 'termsOfServiceUrl': termsOfServiceUrl,
      if (privacyPolicyUrl != null) 'privacyPolicyUrl': privacyPolicyUrl,
    };
  }
}
