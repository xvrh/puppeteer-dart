/// Query and modify DOM storage.

import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';

class DOMStorageManager {
  final Session _client;

  DOMStorageManager(this._client);

  final StreamController<StorageId> _domStorageItemsCleared =
      new StreamController<StorageId>.broadcast();

  Stream<StorageId> get onDomStorageItemsCleared =>
      _domStorageItemsCleared.stream;

  final StreamController<DomStorageItemRemovedResult> _domStorageItemRemoved =
      new StreamController<DomStorageItemRemovedResult>.broadcast();

  Stream<DomStorageItemRemovedResult> get onDomStorageItemRemoved =>
      _domStorageItemRemoved.stream;

  final StreamController<DomStorageItemAddedResult> _domStorageItemAdded =
      new StreamController<DomStorageItemAddedResult>.broadcast();

  Stream<DomStorageItemAddedResult> get onDomStorageItemAdded =>
      _domStorageItemAdded.stream;

  final StreamController<DomStorageItemUpdatedResult> _domStorageItemUpdated =
      new StreamController<DomStorageItemUpdatedResult>.broadcast();

  Stream<DomStorageItemUpdatedResult> get onDomStorageItemUpdated =>
      _domStorageItemUpdated.stream;

  /// Enables storage tracking, storage events will now be delivered to the client.
  Future enable() async {
    await _client.send('DOMStorage.enable');
  }

  /// Disables storage tracking, prevents storage events from being sent to the client.
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
    await _client.send('DOMStorage.getDOMStorageItems', parameters);
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

class DomStorageItemRemovedResult {
  final StorageId storageId;

  final String key;

  DomStorageItemRemovedResult({
    @required this.storageId,
    @required this.key,
  });

  factory DomStorageItemRemovedResult.fromJson(Map json) {
    return new DomStorageItemRemovedResult(
      storageId: new StorageId.fromJson(json['storageId']),
      key: json['key'],
    );
  }
}

class DomStorageItemAddedResult {
  final StorageId storageId;

  final String key;

  final String newValue;

  DomStorageItemAddedResult({
    @required this.storageId,
    @required this.key,
    @required this.newValue,
  });

  factory DomStorageItemAddedResult.fromJson(Map json) {
    return new DomStorageItemAddedResult(
      storageId: new StorageId.fromJson(json['storageId']),
      key: json['key'],
      newValue: json['newValue'],
    );
  }
}

class DomStorageItemUpdatedResult {
  final StorageId storageId;

  final String key;

  final String oldValue;

  final String newValue;

  DomStorageItemUpdatedResult({
    @required this.storageId,
    @required this.key,
    @required this.oldValue,
    @required this.newValue,
  });

  factory DomStorageItemUpdatedResult.fromJson(Map json) {
    return new DomStorageItemUpdatedResult(
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
}
