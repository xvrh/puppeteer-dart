/// Provides information about the protocol schema.

import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';

class SchemaManager {
  final Session _client;

  SchemaManager(this._client);

  /// Returns supported domains.
  /// Return: List of supported domains.
  Future<List<Domain>> getDomains() async {
    await _client.send('Schema.getDomains');
  }
}

/// Description of the protocol domain.
class Domain {
  /// Domain name.
  final String name;

  /// Domain version.
  final String version;

  Domain({
    @required this.name,
    @required this.version,
  });

  factory Domain.fromJson(Map json) {
    return new Domain(
      name: json['name'],
      version: json['version'],
    );
  }

  Map toJson() {
    Map json = {
      'name': name,
      'version': version,
    };
    return json;
  }
}
