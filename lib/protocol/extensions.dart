import 'dart:async';
import '../src/connection.dart';

/// Defines commands and events for browser extensions. Available if the client
/// is connected using the --remote-debugging-pipe flag and
/// the --enable-unsafe-extension-debugging flag is set.
class ExtensionsApi {
  final Client _client;

  ExtensionsApi(this._client);

  /// Installs an unpacked extension from the filesystem similar to
  /// --load-extension CLI flags. Returns extension ID once the extension
  /// has been installed.
  /// [path] Absolute file path.
  /// Returns: Extension id.
  Future<String> loadUnpacked(String path) async {
    var result = await _client.send('Extensions.loadUnpacked', {
      'path': path,
    });
    return result['id'] as String;
  }
}
