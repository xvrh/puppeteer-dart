import 'dart:async';
import '../src/connection.dart';
import 'dom.dart' as dom;
import 'page.dart' as page;

/// Defines commands and events for Autofill.
class AutofillApi {
  final Client _client;

  AutofillApi(this._client);

  /// Emitted when an address form is filled.
  Stream<AddressFormFilledEvent> get onAddressFormFilled => _client.onEvent
      .where((event) => event.name == 'Autofill.addressFormFilled')
      .map((event) => AddressFormFilledEvent.fromJson(event.parameters));

  /// Trigger autofill on a form identified by the fieldId.
  /// If the field and related form cannot be autofilled, returns an error.
  /// [fieldId] Identifies a field that serves as an anchor for autofill.
  /// [frameId] Identifies the frame that field belongs to.
  /// [card] Credit card information to fill out the form. Credit card data is not saved.
  Future<void> trigger(
    dom.BackendNodeId fieldId,
    CreditCard card, {
    page.FrameId? frameId,
  }) async {
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

  /// Disables autofill domain notifications.
  Future<void> disable() async {
    await _client.send('Autofill.disable');
  }

  /// Enables autofill domain notifications.
  Future<void> enable() async {
    await _client.send('Autofill.enable');
  }
}

class AddressFormFilledEvent {
  /// Information about the fields that were filled
  final List<FilledField> filledFields;

  /// An UI representation of the address used to fill the form.
  /// Consists of a 2D array where each child represents an address/profile line.
  final AddressUI addressUi;

  AddressFormFilledEvent({required this.filledFields, required this.addressUi});

  factory AddressFormFilledEvent.fromJson(Map<String, dynamic> json) {
    return AddressFormFilledEvent(
      filledFields: (json['filledFields'] as List)
          .map((e) => FilledField.fromJson(e as Map<String, dynamic>))
          .toList(),
      addressUi: AddressUI.fromJson(json['addressUi'] as Map<String, dynamic>),
    );
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

  CreditCard({
    required this.number,
    required this.name,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvc,
  });

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

  /// address field value, for example Jon Doe.
  final String value;

  AddressField({required this.name, required this.value});

  factory AddressField.fromJson(Map<String, dynamic> json) {
    return AddressField(
      name: json['name'] as String,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'value': value};
  }
}

/// A list of address fields.
class AddressFields {
  final List<AddressField> fields;

  AddressFields({required this.fields});

  factory AddressFields.fromJson(Map<String, dynamic> json) {
    return AddressFields(
      fields: (json['fields'] as List)
          .map((e) => AddressField.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'fields': fields.map((e) => e.toJson()).toList()};
  }
}

class Address {
  /// fields and values defining an address.
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
    return {'fields': fields.map((e) => e.toJson()).toList()};
  }
}

/// Defines how an address can be displayed like in chrome://settings/addresses.
/// Address UI is a two dimensional array, each inner array is an "address information line", and when rendered in a UI surface should be displayed as such.
/// The following address UI for instance:
/// [[{name: "GIVE_NAME", value: "Jon"}, {name: "FAMILY_NAME", value: "Doe"}], [{name: "CITY", value: "Munich"}, {name: "ZIP", value: "81456"}]]
/// should allow the receiver to render:
/// Jon Doe
/// Munich 81456
class AddressUI {
  /// A two dimension array containing the representation of values from an address profile.
  final List<AddressFields> addressFields;

  AddressUI({required this.addressFields});

  factory AddressUI.fromJson(Map<String, dynamic> json) {
    return AddressUI(
      addressFields: (json['addressFields'] as List)
          .map((e) => AddressFields.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'addressFields': addressFields.map((e) => e.toJson()).toList()};
  }
}

/// Specified whether a filled field was done so by using the html autocomplete attribute or autofill heuristics.
enum FillingStrategy {
  autocompleteAttribute('autocompleteAttribute'),
  autofillInferred('autofillInferred');

  final String value;

  const FillingStrategy(this.value);

  factory FillingStrategy.fromJson(String value) =>
      FillingStrategy.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class FilledField {
  /// The type of the field, e.g text, password etc.
  final String htmlType;

  /// the html id
  final String id;

  /// the html name
  final String name;

  /// the field value
  final String value;

  /// The actual field type, e.g FAMILY_NAME
  final String autofillType;

  /// The filling strategy
  final FillingStrategy fillingStrategy;

  /// The frame the field belongs to
  final page.FrameId frameId;

  /// The form field's DOM node
  final dom.BackendNodeId fieldId;

  FilledField({
    required this.htmlType,
    required this.id,
    required this.name,
    required this.value,
    required this.autofillType,
    required this.fillingStrategy,
    required this.frameId,
    required this.fieldId,
  });

  factory FilledField.fromJson(Map<String, dynamic> json) {
    return FilledField(
      htmlType: json['htmlType'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      value: json['value'] as String,
      autofillType: json['autofillType'] as String,
      fillingStrategy: FillingStrategy.fromJson(
        json['fillingStrategy'] as String,
      ),
      frameId: page.FrameId.fromJson(json['frameId'] as String),
      fieldId: dom.BackendNodeId.fromJson(json['fieldId'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'htmlType': htmlType,
      'id': id,
      'name': name,
      'value': value,
      'autofillType': autofillType,
      'fillingStrategy': fillingStrategy.toJson(),
      'frameId': frameId.toJson(),
      'fieldId': fieldId.toJson(),
    };
  }
}
