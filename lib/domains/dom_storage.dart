import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';

/// Query and modify DOM storage.
class DOMStorageManager {
  final Client _client;

  DOMStorageManager(this._client);

  Stream<StorageId> get onDomStorageItemsCleared => _client.onEvent
      .where((Event event) => event.name == 'DOMStorage.domStorageItemsCleared')
      .map((Event event) =>
          new StorageId.fromJson(event.parameters['storageId']));

  Stream<DomStorageItemRemovedEvent> get onDomStorageItemRemoved => _client
      .onEvent
      .where((Event event) => event.name == 'DOMStorage.domStorageItemRemoved')
      .map((Event event) =>
          new DomStorageItemRemovedEvent.fromJson(event.parameters));

  Stream<DomStorageItemAddedEvent> get onDomStorageItemAdded => _client.onEvent
      .where((Event event) => event.name == 'DOMStorage.domStorageItemAdded')
      .map((Event event) =>
          new DomStorageItemAddedEvent.fromJson(event.parameters));

  Stream<DomStorageItemUpdatedEvent> get onDomStorageItemUpdated => _client
      .onEvent
      .where((Event event) => event.name == 'DOMStorage.domStorageItemUpdated')
      .map((Event event) =>
          new DomStorageItemUpdatedEvent.fromJson(event.parameters));

  /// Enables storage tracking, storage events will now be delivered to the
  /// client.
  Future enable() async {
    await _client.send('DOMStorage.enable');
  }

  /// Disables storage tracking, prevents storage events from being sent to the
  /// client.
  Future disable() async {
    await _client.send('DOMStorage.disable');
  }

  Future clear(
    StorageId storageId,
  ) async {
    Map parameters = {
      'storageId': storageId.toJson(),
    };
    await _client.send('DOMStorage.clear', parameters);
  }

  Future<List<Item>> getDOMStorageItems(
    StorageId storageId,
  ) async {
    Map parameters = {
      'storageId': storageId.toJson(),
    };
    Map result =
        await _client.send('DOMStorage.getDOMStorageItems', parameters);
    return (result['entries'] as List)
        .map((e) => new Item.fromJson(e))
        .toList();
  }

  Future setDOMStorageItem(
    StorageId storageId,
    String key,
    String value,
  ) async {
    Map parameters = {
      'storageId': storageId.toJson(),
      'key': key,
      'value': value,
    };
    await _client.send('DOMStorage.setDOMStorageItem', parameters);
  }

  Future removeDOMStorageItem(
    StorageId storageId,
    String key,
  ) async {
    Map parameters = {
      'storageId': storageId.toJson(),
      'key': key,
    };
    await _client.send('DOMStorage.removeDOMStorageItem', parameters);
  }
}

class DomStorageItemRemovedEvent {
  final StorageId storageId;

  final String key;

  DomStorageItemRemovedEvent({
    @required this.storageId,
    @required this.key,
  });

  factory DomStorageItemRemovedEvent.fromJson(Map json) {
    return new DomStorageItemRemovedEvent(
      storageId: new StorageId.fromJson(json['storageId']),
      key: json['key'],
    );
  }
}

class DomStorageItemAddedEvent {
  final StorageId storageId;

  final String key;

  final String newValue;

  DomStorageItemAddedEvent({
    @required this.storageId,
    @required this.key,
    @required this.newValue,
  });

  factory DomStorageItemAddedEvent.fromJson(Map json) {
    return new DomStorageItemAddedEvent(
      storageId: new StorageId.fromJson(json['storageId']),
      key: json['key'],
      newValue: json['newValue'],
    );
  }
}

class DomStorageItemUpdatedEvent {
  final StorageId storageId;

  final String key;

  final String oldValue;

  final String newValue;

  DomStorageItemUpdatedEvent({
    @required this.storageId,
    @required this.key,
    @required this.oldValue,
    @required this.newValue,
  });

  factory DomStorageItemUpdatedEvent.fromJson(Map json) {
    return new DomStorageItemUpdatedEvent(
      storageId: new StorageId.fromJson(json['storageId']),
      key: json['key'],
      oldValue: json['oldValue'],
      newValue: json['newValue'],
    );
  }
}

/// DOM Storage identifier.
class StorageId {
  /// Security origin for the storage.
  final String securityOrigin;

  /// Whether the storage is local storage (not session storage).
  final bool isLocalStorage;

  StorageId({
    @required this.securityOrigin,
    @required this.isLocalStorage,
  });

  factory StorageId.fromJson(Map json) {
    return new StorageId(
      securityOrigin: json['securityOrigin'],
      isLocalStorage: json['isLocalStorage'],
    );
  }

  Map toJson() {
    Map json = {
      'securityOrigin': securityOrigin,
      'isLocalStorage': isLocalStorage,
    };
    return json;
  }
}

/// DOM Storage item.
class Item {
  final List<String> value;

  Item(this.value);

  factory Item.fromJson(List<String> value) => new Item(value);

  List<String> toJson() => value;

  @override
  bool operator ==(other) => other is Item && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
