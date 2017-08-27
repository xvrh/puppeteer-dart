import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';

class DatabaseManager {
  final Session _client;

  DatabaseManager(this._client);

  final StreamController<Database> _addDatabase =
      new StreamController<Database>.broadcast();

  Stream<Database> get onAddDatabase => _addDatabase.stream;

  /// Enables database tracking, database events will now be delivered to the client.
  Future enable() async {
    await _client.send('Database.enable');
  }

  /// Disables database tracking, prevents database events from being sent to the client.
  Future disable() async {
    await _client.send('Database.disable');
  }

  Future<List<String>> getDatabaseTableNames(
    DatabaseId databaseId,
  ) async {
    Map parameters = {
      'databaseId': databaseId.toJson(),
    };
    await _client.send('Database.getDatabaseTableNames', parameters);
  }

  Future<ExecuteSQLResult> executeSQL(
    DatabaseId databaseId,
    String query,
  ) async {
    Map parameters = {
      'databaseId': databaseId.toJson(),
      'query': query,
    };
    await _client.send('Database.executeSQL', parameters);
  }
}

class ExecuteSQLResult {
  final List<String> columnNames;

  final List<dynamic> values;

  final Error sqlError;

  ExecuteSQLResult({
    this.columnNames,
    this.values,
    this.sqlError,
  });

  factory ExecuteSQLResult.fromJson(Map json) {
    return new ExecuteSQLResult(
      columnNames: json.containsKey('columnNames')
          ? (json['columnNames'] as List).map((e) => e as String).toList()
          : null,
      values: json.containsKey('values')
          ? (json['values'] as List).map((e) => e as dynamic).toList()
          : null,
      sqlError: json.containsKey('sqlError')
          ? new Error.fromJson(json['sqlError'])
          : null,
    );
  }
}

/// Unique identifier of Database object.
class DatabaseId {
  final String value;

  DatabaseId(this.value);

  factory DatabaseId.fromJson(String value) => new DatabaseId(value);

  String toJson() => value;
}

/// Database object.
class Database {
  /// Database ID.
  final DatabaseId id;

  /// Database domain.
  final String domain;

  /// Database name.
  final String name;

  /// Database version.
  final String version;

  Database({
    @required this.id,
    @required this.domain,
    @required this.name,
    @required this.version,
  });

  factory Database.fromJson(Map json) {
    return new Database(
      id: new DatabaseId.fromJson(json['id']),
      domain: json['domain'],
      name: json['name'],
      version: json['version'],
    );
  }

  Map toJson() {
    Map json = {
      'id': id.toJson(),
      'domain': domain,
      'name': name,
      'version': version,
    };
    return json;
  }
}

/// Database error.
class Error {
  /// Error message.
  final String message;

  /// Error code.
  final int code;

  Error({
    @required this.message,
    @required this.code,
  });

  factory Error.fromJson(Map json) {
    return new Error(
      message: json['message'],
      code: json['code'],
    );
  }

  Map toJson() {
    Map json = {
      'message': message,
      'code': code,
    };
    return json;
  }
}
