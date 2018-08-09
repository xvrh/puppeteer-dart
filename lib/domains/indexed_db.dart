import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'runtime.dart' as runtime;

class IndexedDBApi {
  final Client _client;

  IndexedDBApi(this._client);

  /// Clears all entries from an object store.
  /// [securityOrigin] Security origin.
  /// [databaseName] Database name.
  /// [objectStoreName] Object store name.
  Future clearObjectStore(
    String securityOrigin,
    String databaseName,
    String objectStoreName,
  ) async {
    var parameters = <String, dynamic>{
      'securityOrigin': securityOrigin,
      'databaseName': databaseName,
      'objectStoreName': objectStoreName,
    };
    await _client.send('IndexedDB.clearObjectStore', parameters);
  }

  /// Deletes a database.
  /// [securityOrigin] Security origin.
  /// [databaseName] Database name.
  Future deleteDatabase(
    String securityOrigin,
    String databaseName,
  ) async {
    var parameters = <String, dynamic>{
      'securityOrigin': securityOrigin,
      'databaseName': databaseName,
    };
    await _client.send('IndexedDB.deleteDatabase', parameters);
  }

  /// Delete a range of entries from an object store
  /// [keyRange] Range of entry keys to delete
  Future deleteObjectStoreEntries(
    String securityOrigin,
    String databaseName,
    String objectStoreName,
    KeyRange keyRange,
  ) async {
    var parameters = <String, dynamic>{
      'securityOrigin': securityOrigin,
      'databaseName': databaseName,
      'objectStoreName': objectStoreName,
      'keyRange': keyRange.toJson(),
    };
    await _client.send('IndexedDB.deleteObjectStoreEntries', parameters);
  }

  /// Disables events from backend.
  Future disable() async {
    await _client.send('IndexedDB.disable');
  }

  /// Enables events from backend.
  Future enable() async {
    await _client.send('IndexedDB.enable');
  }

  /// Requests data from object store or index.
  /// [securityOrigin] Security origin.
  /// [databaseName] Database name.
  /// [objectStoreName] Object store name.
  /// [indexName] Index name, empty string for object store data requests.
  /// [skipCount] Number of records to skip.
  /// [pageSize] Number of records to fetch.
  /// [keyRange] Key range.
  Future<RequestDataResult> requestData(
    String securityOrigin,
    String databaseName,
    String objectStoreName,
    String indexName,
    int skipCount,
    int pageSize, {
    KeyRange keyRange,
  }) async {
    var parameters = <String, dynamic>{
      'securityOrigin': securityOrigin,
      'databaseName': databaseName,
      'objectStoreName': objectStoreName,
      'indexName': indexName,
      'skipCount': skipCount,
      'pageSize': pageSize,
    };
    if (keyRange != null) {
      parameters['keyRange'] = keyRange.toJson();
    }
    var result = await _client.send('IndexedDB.requestData', parameters);
    return RequestDataResult.fromJson(result);
  }

  /// Requests database with given name in given frame.
  /// [securityOrigin] Security origin.
  /// [databaseName] Database name.
  /// Returns: Database with an array of object stores.
  Future<DatabaseWithObjectStores> requestDatabase(
    String securityOrigin,
    String databaseName,
  ) async {
    var parameters = <String, dynamic>{
      'securityOrigin': securityOrigin,
      'databaseName': databaseName,
    };
    var result = await _client.send('IndexedDB.requestDatabase', parameters);
    return DatabaseWithObjectStores.fromJson(
        result['databaseWithObjectStores']);
  }

  /// Requests database names for given security origin.
  /// [securityOrigin] Security origin.
  /// Returns: Database names for origin.
  Future<List<String>> requestDatabaseNames(
    String securityOrigin,
  ) async {
    var parameters = <String, dynamic>{
      'securityOrigin': securityOrigin,
    };
    var result =
        await _client.send('IndexedDB.requestDatabaseNames', parameters);
    return (result['databaseNames'] as List).map((e) => e as String).toList();
  }
}

class RequestDataResult {
  /// Array of object store data entries.
  final List<DataEntry> objectStoreDataEntries;

  /// If true, there are more entries to fetch in the given range.
  final bool hasMore;

  RequestDataResult({
    @required this.objectStoreDataEntries,
    @required this.hasMore,
  });

  factory RequestDataResult.fromJson(Map<String, dynamic> json) {
    return RequestDataResult(
      objectStoreDataEntries: (json['objectStoreDataEntries'] as List)
          .map((e) => DataEntry.fromJson(e))
          .toList(),
      hasMore: json['hasMore'],
    );
  }
}

/// Database with an array of object stores.
class DatabaseWithObjectStores {
  /// Database name.
  final String name;

  /// Database version.
  final int version;

  /// Object stores in this database.
  final List<ObjectStore> objectStores;

  DatabaseWithObjectStores({
    @required this.name,
    @required this.version,
    @required this.objectStores,
  });

  factory DatabaseWithObjectStores.fromJson(Map<String, dynamic> json) {
    return DatabaseWithObjectStores(
      name: json['name'],
      version: json['version'],
      objectStores: (json['objectStores'] as List)
          .map((e) => ObjectStore.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'name': name,
      'version': version,
      'objectStores': objectStores.map((e) => e.toJson()).toList(),
    };
    return json;
  }
}

/// Object store.
class ObjectStore {
  /// Object store name.
  final String name;

  /// Object store key path.
  final KeyPath keyPath;

  /// If true, object store has auto increment flag set.
  final bool autoIncrement;

  /// Indexes in this object store.
  final List<ObjectStoreIndex> indexes;

  ObjectStore({
    @required this.name,
    @required this.keyPath,
    @required this.autoIncrement,
    @required this.indexes,
  });

  factory ObjectStore.fromJson(Map<String, dynamic> json) {
    return ObjectStore(
      name: json['name'],
      keyPath: KeyPath.fromJson(json['keyPath']),
      autoIncrement: json['autoIncrement'],
      indexes: (json['indexes'] as List)
          .map((e) => ObjectStoreIndex.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'name': name,
      'keyPath': keyPath.toJson(),
      'autoIncrement': autoIncrement,
      'indexes': indexes.map((e) => e.toJson()).toList(),
    };
    return json;
  }
}

/// Object store index.
class ObjectStoreIndex {
  /// Index name.
  final String name;

  /// Index key path.
  final KeyPath keyPath;

  /// If true, index is unique.
  final bool unique;

  /// If true, index allows multiple entries for a key.
  final bool multiEntry;

  ObjectStoreIndex({
    @required this.name,
    @required this.keyPath,
    @required this.unique,
    @required this.multiEntry,
  });

  factory ObjectStoreIndex.fromJson(Map<String, dynamic> json) {
    return ObjectStoreIndex(
      name: json['name'],
      keyPath: KeyPath.fromJson(json['keyPath']),
      unique: json['unique'],
      multiEntry: json['multiEntry'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'name': name,
      'keyPath': keyPath.toJson(),
      'unique': unique,
      'multiEntry': multiEntry,
    };
    return json;
  }
}

/// Key.
class Key {
  /// Key type.
  final String type;

  /// Number value.
  final num number;

  /// String value.
  final String string;

  /// Date value.
  final num date;

  /// Array value.
  final List<Key> array;

  Key({
    @required this.type,
    this.number,
    this.string,
    this.date,
    this.array,
  });

  factory Key.fromJson(Map<String, dynamic> json) {
    return Key(
      type: json['type'],
      number: json.containsKey('number') ? json['number'] : null,
      string: json.containsKey('string') ? json['string'] : null,
      date: json.containsKey('date') ? json['date'] : null,
      array: json.containsKey('array')
          ? (json['array'] as List).map((e) => Key.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'type': type,
    };
    if (number != null) {
      json['number'] = number;
    }
    if (string != null) {
      json['string'] = string;
    }
    if (date != null) {
      json['date'] = date;
    }
    if (array != null) {
      json['array'] = array.map((e) => e.toJson()).toList();
    }
    return json;
  }
}

/// Key range.
class KeyRange {
  /// Lower bound.
  final Key lower;

  /// Upper bound.
  final Key upper;

  /// If true lower bound is open.
  final bool lowerOpen;

  /// If true upper bound is open.
  final bool upperOpen;

  KeyRange({
    this.lower,
    this.upper,
    @required this.lowerOpen,
    @required this.upperOpen,
  });

  factory KeyRange.fromJson(Map<String, dynamic> json) {
    return KeyRange(
      lower: json.containsKey('lower') ? Key.fromJson(json['lower']) : null,
      upper: json.containsKey('upper') ? Key.fromJson(json['upper']) : null,
      lowerOpen: json['lowerOpen'],
      upperOpen: json['upperOpen'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'lowerOpen': lowerOpen,
      'upperOpen': upperOpen,
    };
    if (lower != null) {
      json['lower'] = lower.toJson();
    }
    if (upper != null) {
      json['upper'] = upper.toJson();
    }
    return json;
  }
}

/// Data entry.
class DataEntry {
  /// Key object.
  final runtime.RemoteObject key;

  /// Primary key object.
  final runtime.RemoteObject primaryKey;

  /// Value object.
  final runtime.RemoteObject value;

  DataEntry({
    @required this.key,
    @required this.primaryKey,
    @required this.value,
  });

  factory DataEntry.fromJson(Map<String, dynamic> json) {
    return DataEntry(
      key: runtime.RemoteObject.fromJson(json['key']),
      primaryKey: runtime.RemoteObject.fromJson(json['primaryKey']),
      value: runtime.RemoteObject.fromJson(json['value']),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'key': key.toJson(),
      'primaryKey': primaryKey.toJson(),
      'value': value.toJson(),
    };
    return json;
  }
}

/// Key path.
class KeyPath {
  /// Key path type.
  final String type;

  /// String value.
  final String string;

  /// Array value.
  final List<String> array;

  KeyPath({
    @required this.type,
    this.string,
    this.array,
  });

  factory KeyPath.fromJson(Map<String, dynamic> json) {
    return KeyPath(
      type: json['type'],
      string: json.containsKey('string') ? json['string'] : null,
      array: json.containsKey('array')
          ? (json['array'] as List).map((e) => e as String).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'type': type,
    };
    if (string != null) {
      json['string'] = string;
    }
    if (array != null) {
      json['array'] = array.map((e) => e).toList();
    }
    return json;
  }
}
