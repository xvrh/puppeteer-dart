import 'dart:async';
import '../src/connection.dart';

class DatabaseApi {
  final Client _client;

  DatabaseApi(this._client);

  Stream<Database> get onAddDatabase => _client.onEvent
      .where((event) => event.name == 'Database.addDatabase')
      .map((event) => Database.fromJson(
          event.parameters['database'] as Map<String, dynamic>));

  /// Disables database tracking, prevents database events from being sent to the client.
  Future<void> disable() async {
    await _client.send('Database.disable');
  }

  /// Enables database tracking, database events will now be delivered to the client.
  Future<void> enable() async {
    await _client.send('Database.enable');
  }

  Future<ExecuteSQLResult> executeSQL(
      DatabaseId databaseId, String query) async {
    var result = await _client.send('Database.executeSQL', {
      'databaseId': databaseId,
      'query': query,
    });
    return ExecuteSQLResult.fromJson(result);
  }

  Future<List<String>> getDatabaseTableNames(DatabaseId databaseId) async {
    var result = await _client.send('Database.getDatabaseTableNames', {
      'databaseId': databaseId,
    });
    return (result['tableNames'] as List).map((e) => e as String).toList();
  }
}

class ExecuteSQLResult {
  final List<String>? columnNames;

  final List<dynamic>? values;

  final Error? sqlError;

  ExecuteSQLResult({this.columnNames, this.values, this.sqlError});

  factory ExecuteSQLResult.fromJson(Map<String, dynamic> json) {
    return ExecuteSQLResult(
      columnNames: json.containsKey('columnNames')
          ? (json['columnNames'] as List).map((e) => e as String).toList()
          : null,
      values: json.containsKey('values')
          ? (json['values'] as List).map((e) => e as dynamic).toList()
          : null,
      sqlError: json.containsKey('sqlError')
          ? Error.fromJson(json['sqlError'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Unique identifier of Database object.
class DatabaseId {
  final String value;

  DatabaseId(this.value);

  factory DatabaseId.fromJson(String value) => DatabaseId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is DatabaseId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
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

  Database(
      {required this.id,
      required this.domain,
      required this.name,
      required this.version});

  factory Database.fromJson(Map<String, dynamic> json) {
    return Database(
      id: DatabaseId.fromJson(json['id'] as String),
      domain: json['domain'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toJson(),
      'domain': domain,
      'name': name,
      'version': version,
    };
  }
}

/// Database error.
class Error {
  /// Error message.
  final String message;

  /// Error code.
  final int code;

  Error({required this.message, required this.code});

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      message: json['message'] as String,
      code: json['code'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'code': code,
    };
  }
}
