import 'dart:async';
import 'package:meta/meta.dart' show required;
import 'src/connection.dart';

class DatabaseApi {
  final Client _client;

  DatabaseApi(this._client);

  Stream<Database> get onAddDatabase => _client.onEvent
      .where((Event event) => event.name == 'Database.addDatabase')
      .map((Event event) => Database.fromJson(event.parameters['database']));

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
    var parameters = <String, dynamic>{
      'databaseId': databaseId.toJson(),
      'query': query,
    };
    var result = await _client.send('Database.executeSQL', parameters);
    return ExecuteSQLResult.fromJson(result);
  }

  Future<List<String>> getDatabaseTableNames(DatabaseId databaseId) async {
    var parameters = <String, dynamic>{
      'databaseId': databaseId.toJson(),
    };
    var result =
        await _client.send('Database.getDatabaseTableNames', parameters);
    return (result['tableNames'] as List).map((e) => e as String).toList();
  }
}

class ExecuteSQLResult {
  final List<String> columnNames;

  final List<dynamic> values;

  final Error sqlError;

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
          ? Error.fromJson(json['sqlError'])
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
      {@required this.id,
      @required this.domain,
      @required this.name,
      @required this.version});

  factory Database.fromJson(Map<String, dynamic> json) {
    return Database(
      id: DatabaseId.fromJson(json['id']),
      domain: json['domain'],
      name: json['name'],
      version: json['version'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
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

  Error({@required this.message, @required this.code});

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      message: json['message'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'message': message,
      'code': code,
    };
    return json;
  }
}
