/// This domain is deprecated.

import 'dart:async';
// ignore: unused_import
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';

class SchemaDomain {
  final Client _client;

  SchemaDomain(this._client);

  /// Returns supported domains.
  /// Return: List of supported domains.
  Future<List<Domain>> getDomains() async {
    Map result = await _client.send('Schema.getDomains');
    return (result['domains'] as List)
        .map((e) => new Domain.fromJson(e))
        .toList();
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
