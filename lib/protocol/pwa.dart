import 'dart:async';
import '../src/connection.dart';

/// This domain allows interacting with the browser to control PWAs.
class PWAApi {
  final Client _client;

  PWAApi(this._client);

  /// Returns the following OS state for the given manifest id.
  /// [manifestId] The id from the webapp's manifest file, commonly it's the url of the
  /// site installing the webapp. See
  /// https://web.dev/learn/pwa/web-app-manifest.
  Future<GetOsAppStateResult> getOsAppState(String manifestId) async {
    var result = await _client.send('PWA.getOsAppState', {
      'manifestId': manifestId,
    });
    return GetOsAppStateResult.fromJson(result);
  }
}

class GetOsAppStateResult {
  final int badgeCount;

  final List<FileHandler> fileHandlers;

  GetOsAppStateResult({required this.badgeCount, required this.fileHandlers});

  factory GetOsAppStateResult.fromJson(Map<String, dynamic> json) {
    return GetOsAppStateResult(
      badgeCount: json['badgeCount'] as int,
      fileHandlers: (json['fileHandlers'] as List)
          .map((e) => FileHandler.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// The following types are the replica of
/// https://crsrc.org/c/chrome/browser/web_applications/proto/web_app_os_integration_state.proto;drc=9910d3be894c8f142c977ba1023f30a656bc13fc;l=67
class FileHandlerAccept {
  /// New name of the mimetype according to
  /// https://www.iana.org/assignments/media-types/media-types.xhtml
  final String mediaType;

  final List<String> fileExtensions;

  FileHandlerAccept({required this.mediaType, required this.fileExtensions});

  factory FileHandlerAccept.fromJson(Map<String, dynamic> json) {
    return FileHandlerAccept(
      mediaType: json['mediaType'] as String,
      fileExtensions:
          (json['fileExtensions'] as List).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mediaType': mediaType,
      'fileExtensions': [...fileExtensions],
    };
  }
}

class FileHandler {
  final String action;

  final List<FileHandlerAccept> accepts;

  final String displayName;

  FileHandler(
      {required this.action, required this.accepts, required this.displayName});

  factory FileHandler.fromJson(Map<String, dynamic> json) {
    return FileHandler(
      action: json['action'] as String,
      accepts: (json['accepts'] as List)
          .map((e) => FileHandlerAccept.fromJson(e as Map<String, dynamic>))
          .toList(),
      displayName: json['displayName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'accepts': accepts.map((e) => e.toJson()).toList(),
      'displayName': displayName,
    };
  }
}
