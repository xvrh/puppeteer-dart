import 'dart:async';
import '../src/connection.dart';

/// This domain provides commands to trigger the "Find in page" feature.
class FindInPageApi {
  final Client _client;

  FindInPageApi(this._client);

  /// Forwards `query` to the find-in-page facility, starting a new find session.
  /// Where exactly the search starts from is implementation-specific.
  Future<void> findFirst(String query) async {
    await _client.send('FindInPage.findFirst', {'query': query});
  }

  /// Moves to the next match for the query passed to the most recent
  /// findFirst() call.
  Future<void> findNext() async {
    await _client.send('FindInPage.findNext');
  }

  /// Moves to the previous match for the query passed to the most recent
  /// findFirst() call.
  Future<void> findPrev() async {
    await _client.send('FindInPage.findPrev');
  }

  /// Ends the current find session, if any, and clears its highlighting.
  Future<void> stop() async {
    await _client.send('FindInPage.stop');
  }
}
