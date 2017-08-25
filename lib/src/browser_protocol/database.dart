import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';

class DatabaseManager {
  final Session _client;

  DatabaseManager(this._client);

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
      'query': query.toString(),
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
}

/// Unique identifier of Database object.
class DatabaseId {
  final String value;

  DatabaseId(this.value);

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

  Map toJson() {
    Map json = {
      'id': id.toJson(),
      'domain': domain.toString(),
      'name': name.toString(),
      'version': version.toString(),
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

  Map toJson() {
    Map json = {
      'message': message.toString(),
      'code': code.toString(),
    };
    return json;
  }
}
