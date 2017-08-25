/// Query and modify DOM storage.

import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';

class DOMStorageManager {
  final Session _client;

  DOMStorageManager(this._client);

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
      'key': key.toString(),
      'value': value.toString(),
    };
    await _client.send('DOMStorage.setDOMStorageItem', parameters);
  }

  Future removeDOMStorageItem(
    StorageId storageId,
    String key,
  ) async {
    Map parameters = {
      'storageId': storageId.toJson(),
      'key': key.toString(),
    };
    await _client.send('DOMStorage.removeDOMStorageItem', parameters);
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

  Map toJson() {
    Map json = {
      'securityOrigin': securityOrigin.toString(),
      'isLocalStorage': isLocalStorage.toString(),
    };
    return json;
  }
}

/// DOM Storage item.
class Item {
  final List<String> value;

  Item(this.value);

  List<String> toJson() => value;
}
