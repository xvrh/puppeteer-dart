import 'dart:async';
import '../src/connection.dart';

/// Testing domain is a dumping ground for the capabilities requires for browser or app testing that do not fit other
/// domains.
class TestingApi {
  final Client _client;

  TestingApi(this._client);

  /// Generates a report for testing.
  /// [message] Message to be displayed in the report.
  /// [group] Specifies the endpoint group to deliver the report to.
  Future generateTestReport(String message, {String group}) async {
    var parameters = <String, dynamic>{
      'message': message,
    };
    if (group != null) {
      parameters['group'] = group;
    }
    await _client.send('Testing.generateTestReport', parameters);
  }
}
