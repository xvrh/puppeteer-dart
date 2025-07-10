import 'dart:async';
import '../src/connection.dart';

/// Query and modify DOM storage.
class DOMStorageApi {
  final Client _client;

  DOMStorageApi(this._client);

  Stream<DomStorageItemAddedEvent> get onDomStorageItemAdded => _client.onEvent
      .where((event) => event.name == 'DOMStorage.domStorageItemAdded')
      .map((event) => DomStorageItemAddedEvent.fromJson(event.parameters));

  Stream<DomStorageItemRemovedEvent> get onDomStorageItemRemoved => _client
      .onEvent
      .where((event) => event.name == 'DOMStorage.domStorageItemRemoved')
      .map((event) => DomStorageItemRemovedEvent.fromJson(event.parameters));

  Stream<DomStorageItemUpdatedEvent> get onDomStorageItemUpdated => _client
      .onEvent
      .where((event) => event.name == 'DOMStorage.domStorageItemUpdated')
      .map((event) => DomStorageItemUpdatedEvent.fromJson(event.parameters));

  Stream<StorageId> get onDomStorageItemsCleared => _client.onEvent
      .where((event) => event.name == 'DOMStorage.domStorageItemsCleared')
      .map(
        (event) => StorageId.fromJson(
          event.parameters['storageId'] as Map<String, dynamic>,
        ),
      );

  Future<void> clear(StorageId storageId) async {
    await _client.send('DOMStorage.clear', {'storageId': storageId});
  }

  /// Disables storage tracking, prevents storage events from being sent to the client.
  Future<void> disable() async {
    await _client.send('DOMStorage.disable');
  }

  /// Enables storage tracking, storage events will now be delivered to the client.
  Future<void> enable() async {
    await _client.send('DOMStorage.enable');
  }

  Future<List<Item>> getDOMStorageItems(StorageId storageId) async {
    var result = await _client.send('DOMStorage.getDOMStorageItems', {
      'storageId': storageId,
    });
    return (result['entries'] as List)
        .map((e) => Item.fromJson(e as List))
        .toList();
  }

  Future<void> removeDOMStorageItem(StorageId storageId, String key) async {
    await _client.send('DOMStorage.removeDOMStorageItem', {
      'storageId': storageId,
      'key': key,
    });
  }

  Future<void> setDOMStorageItem(
    StorageId storageId,
    String key,
    String value,
  ) async {
    await _client.send('DOMStorage.setDOMStorageItem', {
      'storageId': storageId,
      'key': key,
      'value': value,
    });
  }
}

class DomStorageItemAddedEvent {
  final StorageId storageId;

  final String key;

  final String newValue;

  DomStorageItemAddedEvent({
    required this.storageId,
    required this.key,
    required this.newValue,
  });

  factory DomStorageItemAddedEvent.fromJson(Map<String, dynamic> json) {
    return DomStorageItemAddedEvent(
      storageId: StorageId.fromJson(json['storageId'] as Map<String, dynamic>),
      key: json['key'] as String,
      newValue: json['newValue'] as String,
    );
  }
}

class DomStorageItemRemovedEvent {
  final StorageId storageId;

  final String key;

  DomStorageItemRemovedEvent({required this.storageId, required this.key});

  factory DomStorageItemRemovedEvent.fromJson(Map<String, dynamic> json) {
    return DomStorageItemRemovedEvent(
      storageId: StorageId.fromJson(json['storageId'] as Map<String, dynamic>),
      key: json['key'] as String,
    );
  }
}

class DomStorageItemUpdatedEvent {
  final StorageId storageId;

  final String key;

  final String oldValue;

  final String newValue;

  DomStorageItemUpdatedEvent({
    required this.storageId,
    required this.key,
    required this.oldValue,
    required this.newValue,
  });

  factory DomStorageItemUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return DomStorageItemUpdatedEvent(
      storageId: StorageId.fromJson(json['storageId'] as Map<String, dynamic>),
      key: json['key'] as String,
      oldValue: json['oldValue'] as String,
      newValue: json['newValue'] as String,
    );
  }
}

extension type SerializedStorageKey(String value) {
  factory SerializedStorageKey.fromJson(String value) =>
      SerializedStorageKey(value);

  String toJson() => value;
}

/// DOM Storage identifier.
class StorageId {
  /// Security origin for the storage.
  final String? securityOrigin;

  /// Represents a key by which DOM Storage keys its CachedStorageAreas
  final SerializedStorageKey? storageKey;

  /// Whether the storage is local storage (not session storage).
  final bool isLocalStorage;

  StorageId({
    this.securityOrigin,
    this.storageKey,
    required this.isLocalStorage,
  });

  factory StorageId.fromJson(Map<String, dynamic> json) {
    return StorageId(
      securityOrigin: json.containsKey('securityOrigin')
          ? json['securityOrigin'] as String
          : null,
      storageKey: json.containsKey('storageKey')
          ? SerializedStorageKey.fromJson(json['storageKey'] as String)
          : null,
      isLocalStorage: json['isLocalStorage'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isLocalStorage': isLocalStorage,
      if (securityOrigin != null) 'securityOrigin': securityOrigin,
      if (storageKey != null) 'storageKey': storageKey!.toJson(),
    };
  }
}

/// DOM Storage item.
extension type Item(List<String> value) {
  factory Item.fromJson(List<dynamic> value) =>
      Item(value.map((e) => e as String).toList());

  List<String> toJson() => value;
}
