import 'dart:async';
import '../src/connection.dart';

/// This domain allows interacting with the FedCM dialog.
class FedCmApi {
  final Client _client;

  FedCmApi(this._client);

  Stream<DialogShownEvent> get onDialogShown => _client.onEvent
      .where((event) => event.name == 'FedCm.dialogShown')
      .map((event) => DialogShownEvent.fromJson(event.parameters));

  /// Triggered when a dialog is closed, either by user action, JS abort,
  /// or a command below.
  Stream<String> get onDialogClosed => _client.onEvent
      .where((event) => event.name == 'FedCm.dialogClosed')
      .map((event) => event.parameters['dialogId'] as String);

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

  Future<void> clickDialogButton(
    String dialogId,
    DialogButton dialogButton,
  ) async {
    await _client.send('FedCm.clickDialogButton', {
      'dialogId': dialogId,
      'dialogButton': dialogButton,
    });
  }

  Future<void> openUrl(
    String dialogId,
    int accountIndex,
    AccountUrlType accountUrlType,
  ) async {
    await _client.send('FedCm.openUrl', {
      'dialogId': dialogId,
      'accountIndex': accountIndex,
      'accountUrlType': accountUrlType,
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

  DialogShownEvent({
    required this.dialogId,
    required this.dialogType,
    required this.accounts,
    required this.title,
    this.subtitle,
  });

  factory DialogShownEvent.fromJson(Map<String, dynamic> json) {
    return DialogShownEvent(
      dialogId: json['dialogId'] as String,
      dialogType: DialogType.fromJson(json['dialogType'] as String),
      accounts: (json['accounts'] as List)
          .map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList(),
      title: json['title'] as String,
      subtitle: json.containsKey('subtitle')
          ? json['subtitle'] as String
          : null,
    );
  }
}

/// Whether this is a sign-up or sign-in action for this account, i.e.
/// whether this account has ever been used to sign in to this RP before.
enum LoginState {
  signIn('SignIn'),
  signUp('SignUp');

  final String value;

  const LoginState(this.value);

  factory LoginState.fromJson(String value) =>
      LoginState.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// The types of FedCM dialogs.
enum DialogType {
  accountChooser('AccountChooser'),
  autoReauthn('AutoReauthn'),
  confirmIdpLogin('ConfirmIdpLogin'),
  error('Error');

  final String value;

  const DialogType(this.value);

  factory DialogType.fromJson(String value) =>
      DialogType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// The buttons on the FedCM dialog.
enum DialogButton {
  confirmIdpLoginContinue('ConfirmIdpLoginContinue'),
  errorGotIt('ErrorGotIt'),
  errorMoreDetails('ErrorMoreDetails');

  final String value;

  const DialogButton(this.value);

  factory DialogButton.fromJson(String value) =>
      DialogButton.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// The URLs that each account has
enum AccountUrlType {
  termsOfService('TermsOfService'),
  privacyPolicy('PrivacyPolicy');

  final String value;

  const AccountUrlType(this.value);

  factory AccountUrlType.fromJson(String value) =>
      AccountUrlType.values.firstWhere((e) => e.value == value);

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

  final String idpLoginUrl;

  final LoginState loginState;

  /// These two are only set if the loginState is signUp
  final String? termsOfServiceUrl;

  final String? privacyPolicyUrl;

  Account({
    required this.accountId,
    required this.email,
    required this.name,
    required this.givenName,
    required this.pictureUrl,
    required this.idpConfigUrl,
    required this.idpLoginUrl,
    required this.loginState,
    this.termsOfServiceUrl,
    this.privacyPolicyUrl,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountId: json['accountId'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      givenName: json['givenName'] as String,
      pictureUrl: json['pictureUrl'] as String,
      idpConfigUrl: json['idpConfigUrl'] as String,
      idpLoginUrl: json['idpLoginUrl'] as String,
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
      'idpLoginUrl': idpLoginUrl,
      'loginState': loginState.toJson(),
      if (termsOfServiceUrl != null) 'termsOfServiceUrl': termsOfServiceUrl,
      if (privacyPolicyUrl != null) 'privacyPolicyUrl': privacyPolicyUrl,
    };
  }
}
