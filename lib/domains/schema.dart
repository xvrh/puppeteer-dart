import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';

/// This domain is deprecated.
@deprecated
class SchemaApi {
  final Client _client;

  SchemaApi(this._client);

  /// Returns supported domains.
  /// Returns: List of supported domains.
  Future<List<Domain>> getDomains() async {
    var result = await _client.send('Schema.getDomains');
    return (result['domains'] as List).map((e) => Domain.fromJson(e)).toList();
  }
}

/// Description of the protocol domain.
class Domain {
  /// Domain name.
  final String name;

  /// Domain version.
  final String version;

  Domain({@required this.name, @required this.version});

  factory Domain.fromJson(Map<String, dynamic> json) {
    return Domain(
      name: json['name'],
      version: json['version'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'name': name,
      'version': version,
    };
    return json;
  }
}
