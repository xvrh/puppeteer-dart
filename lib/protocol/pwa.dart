import 'dart:async';
import '../src/connection.dart';
import 'target.dart' as target;

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

  /// Installs the given manifest identity, optionally using the given installUrlOrBundleUrl
  ///
  /// IWA-specific install description:
  /// manifestId corresponds to isolated-app:// + web_package::SignedWebBundleId
  ///
  /// File installation mode:
  /// The installUrlOrBundleUrl can be either file:// or http(s):// pointing
  /// to a signed web bundle (.swbn). In this case SignedWebBundleId must correspond to
  /// The .swbn file's signing key.
  ///
  /// Dev proxy installation mode:
  /// installUrlOrBundleUrl must be http(s):// that serves dev mode IWA.
  /// web_package::SignedWebBundleId must be of type dev proxy.
  ///
  /// The advantage of dev proxy mode is that all changes to IWA
  /// automatically will be reflected in the running app without
  /// reinstallation.
  ///
  /// To generate bundle id for proxy mode:
  /// 1. Generate 32 random bytes.
  /// 2. Add a specific suffix 0x00 at the end.
  /// 3. Encode the entire sequence using Base32 without padding.
  ///
  /// If Chrome is not in IWA dev
  /// mode, the installation will fail, regardless of the state of the allowlist.
  /// [installUrlOrBundleUrl] The location of the app or bundle overriding the one derived from the
  /// manifestId.
  Future<void> install(
    String manifestId, {
    String? installUrlOrBundleUrl,
  }) async {
    await _client.send('PWA.install', {
      'manifestId': manifestId,
      if (installUrlOrBundleUrl != null)
        'installUrlOrBundleUrl': installUrlOrBundleUrl,
    });
  }

  /// Uninstalls the given manifest_id and closes any opened app windows.
  Future<void> uninstall(String manifestId) async {
    await _client.send('PWA.uninstall', {'manifestId': manifestId});
  }

  /// Launches the installed web app, or an url in the same web app instead of the
  /// default start url if it is provided. Returns a page Target.TargetID which
  /// can be used to attach to via Target.attachToTarget or similar APIs.
  /// Returns: ID of the tab target created as a result.
  Future<target.TargetID> launch(String manifestId, {String? url}) async {
    var result = await _client.send('PWA.launch', {
      'manifestId': manifestId,
      if (url != null) 'url': url,
    });
    return target.TargetID.fromJson(result['targetId'] as String);
  }

  /// Opens one or more local files from an installed web app identified by its
  /// manifestId. The web app needs to have file handlers registered to process
  /// the files. The API returns one or more page Target.TargetIDs which can be
  /// used to attach to via Target.attachToTarget or similar APIs.
  /// If some files in the parameters cannot be handled by the web app, they will
  /// be ignored. If none of the files can be handled, this API returns an error.
  /// If no files are provided as the parameter, this API also returns an error.
  ///
  /// According to the definition of the file handlers in the manifest file, one
  /// Target.TargetID may represent a page handling one or more files. The order
  /// of the returned Target.TargetIDs is not guaranteed.
  ///
  /// TODO(crbug.com/339454034): Check the existences of the input files.
  /// Returns: IDs of the tab targets created as the result.
  Future<List<target.TargetID>> launchFilesInApp(
    String manifestId,
    List<String> files,
  ) async {
    var result = await _client.send('PWA.launchFilesInApp', {
      'manifestId': manifestId,
      'files': [...files],
    });
    return (result['targetIds'] as List)
        .map((e) => target.TargetID.fromJson(e as String))
        .toList();
  }

  /// Opens the current page in its web app identified by the manifest id, needs
  /// to be called on a page target. This function returns immediately without
  /// waiting for the app to finish loading.
  Future<void> openCurrentPageInApp(String manifestId) async {
    await _client.send('PWA.openCurrentPageInApp', {'manifestId': manifestId});
  }

  /// Changes user settings of the web app identified by its manifestId. If the
  /// app was not installed, this command returns an error. Unset parameters will
  /// be ignored; unrecognized values will cause an error.
  ///
  /// Unlike the ones defined in the manifest files of the web apps, these
  /// settings are provided by the browser and controlled by the users, they
  /// impact the way the browser handling the web apps.
  ///
  /// See the comment of each parameter.
  /// [linkCapturing] If user allows the links clicked on by the user in the app's scope, or
  /// extended scope if the manifest has scope extensions and the flags
  /// `DesktopPWAsLinkCapturingWithScopeExtensions` and
  /// `WebAppEnableScopeExtensions` are enabled.
  ///
  /// Note, the API does not support resetting the linkCapturing to the
  /// initial value, uninstalling and installing the web app again will reset
  /// it.
  ///
  /// TODO(crbug.com/339453269): Setting this value on ChromeOS is not
  /// supported yet.
  Future<void> changeAppUserSettings(
    String manifestId, {
    bool? linkCapturing,
    DisplayMode? displayMode,
  }) async {
    await _client.send('PWA.changeAppUserSettings', {
      'manifestId': manifestId,
      if (linkCapturing != null) 'linkCapturing': linkCapturing,
      if (displayMode != null) 'displayMode': displayMode,
    });
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
      fileExtensions: (json['fileExtensions'] as List)
          .map((e) => e as String)
          .toList(),
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

  FileHandler({
    required this.action,
    required this.accepts,
    required this.displayName,
  });

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

/// If user prefers opening the app in browser or an app window.
enum DisplayMode {
  standalone('standalone'),
  browser('browser');

  final String value;

  const DisplayMode(this.value);

  factory DisplayMode.fromJson(String value) =>
      DisplayMode.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}
