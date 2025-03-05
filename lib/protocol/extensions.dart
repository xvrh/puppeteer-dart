import 'dart:async';
import '../src/connection.dart';

/// Defines commands and events for browser extensions.
class ExtensionsApi {
  final Client _client;

  ExtensionsApi(this._client);

  /// Installs an unpacked extension from the filesystem similar to
  /// --load-extension CLI flags. Returns extension ID once the extension
  /// has been installed. Available if the client is connected using the
  /// --remote-debugging-pipe flag and the --enable-unsafe-extension-debugging
  /// flag is set.
  /// [path] Absolute file path.
  /// Returns: Extension id.
  Future<String> loadUnpacked(String path) async {
    var result = await _client.send('Extensions.loadUnpacked', {'path': path});
    return result['id'] as String;
  }

  /// Uninstalls an unpacked extension (others not supported) from the profile.
  /// Available if the client is connected using the --remote-debugging-pipe flag
  /// and the --enable-unsafe-extension-debugging.
  /// [id] Extension id.
  Future<void> uninstall(String id) async {
    await _client.send('Extensions.uninstall', {'id': id});
  }

  /// Gets data from extension storage in the given `storageArea`. If `keys` is
  /// specified, these are used to filter the result.
  /// [id] ID of extension.
  /// [storageArea] StorageArea to retrieve data from.
  /// [keys] Keys to retrieve.
  Future<Map<String, dynamic>> getStorageItems(
    String id,
    StorageArea storageArea, {
    List<String>? keys,
  }) async {
    var result = await _client.send('Extensions.getStorageItems', {
      'id': id,
      'storageArea': storageArea,
      if (keys != null) 'keys': [...keys],
    });
    return result['data'] as Map<String, dynamic>;
  }

  /// Removes `keys` from extension storage in the given `storageArea`.
  /// [id] ID of extension.
  /// [storageArea] StorageArea to remove data from.
  /// [keys] Keys to remove.
  Future<void> removeStorageItems(
    String id,
    StorageArea storageArea,
    List<String> keys,
  ) async {
    await _client.send('Extensions.removeStorageItems', {
      'id': id,
      'storageArea': storageArea,
      'keys': [...keys],
    });
  }

  /// Clears extension storage in the given `storageArea`.
  /// [id] ID of extension.
  /// [storageArea] StorageArea to remove data from.
  Future<void> clearStorageItems(String id, StorageArea storageArea) async {
    await _client.send('Extensions.clearStorageItems', {
      'id': id,
      'storageArea': storageArea,
    });
  }

  /// Sets `values` in extension storage in the given `storageArea`. The provided `values`
  /// will be merged with existing values in the storage area.
  /// [id] ID of extension.
  /// [storageArea] StorageArea to set data in.
  /// [values] Values to set.
  Future<void> setStorageItems(
    String id,
    StorageArea storageArea,
    Map<String, dynamic> values,
  ) async {
    await _client.send('Extensions.setStorageItems', {
      'id': id,
      'storageArea': storageArea,
      'values': values,
    });
  }
}

/// Storage areas.
enum StorageArea {
  session('session'),
  local('local'),
  sync$('sync'),
  managed('managed');

  final String value;

  const StorageArea(this.value);

  factory StorageArea.fromJson(String value) =>
      StorageArea.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}
