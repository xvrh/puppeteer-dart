import 'dart:async';
import '../src/connection.dart';
import 'page.dart' as page;

/// This domain allows interacting with the Digital Credentials API for automation.
class DigitalCredentialsApi {
  final Client _client;

  DigitalCredentialsApi(this._client);

  /// Sets the behavior of the virtual wallet for digital credential requests
  /// issued from this frame.
  /// [action] The action of the virtual wallet.
  /// [protocol] The protocol identifier (e.g. "openid4vp"). Required when |action| is
  /// "respond", forbidden otherwise.
  /// [response] The response data object returned by the wallet.
  /// Required when |action| is "respond", forbidden otherwise.
  /// [frameId] The frame to scope the virtual wallet behavior to.
  Future<void> setVirtualWalletBehavior(
    VirtualWalletAction action, {
    String? protocol,
    Map<String, dynamic>? response,
    page.FrameId? frameId,
  }) async {
    await _client.send('DigitalCredentials.setVirtualWalletBehavior', {
      'action': action,
      'protocol': ?protocol,
      'response': ?response,
      'frameId': ?frameId,
    });
  }
}

/// The type of virtual wallet action.
enum VirtualWalletAction {
  respond('respond'),
  decline('decline'),
  wait('wait'),
  clear('clear');

  final String value;

  const VirtualWalletAction(this.value);

  factory VirtualWalletAction.fromJson(String value) =>
      VirtualWalletAction.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}
