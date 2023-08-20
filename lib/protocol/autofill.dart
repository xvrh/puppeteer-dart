import 'dart:async';
import '../src/connection.dart';
import 'dom.dart' as dom;
import 'page.dart' as page;

/// Defines commands and events for Autofill.
class AutofillApi {
  final Client _client;

  AutofillApi(this._client);

  /// Trigger autofill on a form identified by the fieldId.
  /// If the field and related form cannot be autofilled, returns an error.
  /// [fieldId] Identifies a field that serves as an anchor for autofill.
  /// [frameId] Identifies the frame that field belongs to.
  /// [card] Credit card information to fill out the form. Credit card data is not saved.
  Future<void> trigger(dom.BackendNodeId fieldId, CreditCard card,
      {page.FrameId? frameId}) async {
    await _client.send('Autofill.trigger', {
      'fieldId': fieldId,
      'card': card,
      if (frameId != null) 'frameId': frameId,
    });
  }

  /// Set addresses so that developers can verify their forms implementation.
  Future<void> setAddresses(List<Address> addresses) async {
    await _client.send('Autofill.setAddresses', {
      'addresses': [...addresses],
    });
  }
}

class CreditCard {
  /// 16-digit credit card number.
  final String number;

  /// Name of the credit card owner.
  final String name;

  /// 2-digit expiry month.
  final String expiryMonth;

  /// 4-digit expiry year.
  final String expiryYear;

  /// 3-digit card verification code.
  final String cvc;

  CreditCard(
      {required this.number,
      required this.name,
      required this.expiryMonth,
      required this.expiryYear,
      required this.cvc});

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      number: json['number'] as String,
      name: json['name'] as String,
      expiryMonth: json['expiryMonth'] as String,
      expiryYear: json['expiryYear'] as String,
      cvc: json['cvc'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvc': cvc,
    };
  }
}

class AddressField {
  /// address field name, for example GIVEN_NAME.
  final String name;

  /// address field name, for example Jon Doe.
  final String value;

  AddressField({required this.name, required this.value});

  factory AddressField.fromJson(Map<String, dynamic> json) {
    return AddressField(
      name: json['name'] as String,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}

class Address {
  /// fields and values defining a test address.
  final List<AddressField> fields;

  Address({required this.fields});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      fields: (json['fields'] as List)
          .map((e) => AddressField.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fields': fields.map((e) => e.toJson()).toList(),
    };
  }
}
