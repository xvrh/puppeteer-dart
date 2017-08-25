import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';
import '../runtime.dart' as runtime;

class IndexedDBManager {
  final Session _client;

  IndexedDBManager(this._client);

  /// Enables events from backend.
  Future enable() async {
    await _client.send('IndexedDB.enable');
  }

  /// Disables events from backend.
  Future disable() async {
    await _client.send('IndexedDB.disable');
  }

  /// Requests database names for given security origin.
  /// [securityOrigin] Security origin.
  /// Return: Database names for origin.
  Future<List<String>> requestDatabaseNames(
    String securityOrigin,
  ) async {
    Map parameters = {
      'securityOrigin': securityOrigin.toString(),
    };
    await _client.send('IndexedDB.requestDatabaseNames', parameters);
  }

  /// Requests database with given name in given frame.
  /// [securityOrigin] Security origin.
  /// [databaseName] Database name.
  /// Return: Database with an array of object stores.
  Future<DatabaseWithObjectStores> requestDatabase(
    String securityOrigin,
    String databaseName,
  ) async {
    Map parameters = {
      'securityOrigin': securityOrigin.toString(),
      'databaseName': databaseName.toString(),
    };
    await _client.send('IndexedDB.requestDatabase', parameters);
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
    Map parameters = {
      'securityOrigin': securityOrigin.toString(),
      'databaseName': databaseName.toString(),
      'objectStoreName': objectStoreName.toString(),
      'indexName': indexName.toString(),
      'skipCount': skipCount.toString(),
      'pageSize': pageSize.toString(),
    };
    if (keyRange != null) {
      parameters['keyRange'] = keyRange.toJson();
    }
    await _client.send('IndexedDB.requestData', parameters);
  }

  /// Clears all entries from an object store.
  /// [securityOrigin] Security origin.
  /// [databaseName] Database name.
  /// [objectStoreName] Object store name.
  Future clearObjectStore(
    String securityOrigin,
    String databaseName,
    String objectStoreName,
  ) async {
    Map parameters = {
      'securityOrigin': securityOrigin.toString(),
      'databaseName': databaseName.toString(),
      'objectStoreName': objectStoreName.toString(),
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
    Map parameters = {
      'securityOrigin': securityOrigin.toString(),
      'databaseName': databaseName.toString(),
    };
    await _client.send('IndexedDB.deleteDatabase', parameters);
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

  Map toJson() {
    Map json = {
      'name': name.toString(),
      'version': version.toString(),
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

  Map toJson() {
    Map json = {
      'name': name.toString(),
      'keyPath': keyPath.toJson(),
      'autoIncrement': autoIncrement.toString(),
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

  Map toJson() {
    Map json = {
      'name': name.toString(),
      'keyPath': keyPath.toJson(),
      'unique': unique.toString(),
      'multiEntry': multiEntry.toString(),
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

  Map toJson() {
    Map json = {
      'type': type.toString(),
    };
    if (number != null) {
      json['number'] = number.toString();
    }
    if (string != null) {
      json['string'] = string.toString();
    }
    if (date != null) {
      json['date'] = date.toString();
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

  Map toJson() {
    Map json = {
      'lowerOpen': lowerOpen.toString(),
      'upperOpen': upperOpen.toString(),
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

  Map toJson() {
    Map json = {
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

  Map toJson() {
    Map json = {
      'type': type.toString(),
    };
    if (string != null) {
      json['string'] = string.toString();
    }
    if (array != null) {
      json['array'] = array.map((e) => e.toString()).toList();
    }
    return json;
  }
}
