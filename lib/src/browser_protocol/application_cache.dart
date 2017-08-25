import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';
import 'page.dart' as page;

class ApplicationCacheManager {
  final Session _client;

  ApplicationCacheManager(this._client);

  /// Returns array of frame identifiers with manifest urls for each frame containing a document associated with some application cache.
  /// Return: Array of frame identifiers with manifest urls for each frame containing a document associated with some application cache.
  Future<List<FrameWithManifest>> getFramesWithManifests() async {
    await _client.send('ApplicationCache.getFramesWithManifests');
  }

  /// Enables application cache domain notifications.
  Future enable() async {
    await _client.send('ApplicationCache.enable');
  }

  /// Returns manifest URL for document in the given frame.
  /// [frameId] Identifier of the frame containing document whose manifest is retrieved.
  /// Return: Manifest URL for document in the given frame.
  Future<String> getManifestForFrame(
    page.FrameId frameId,
  ) async {
    Map parameters = {
      'frameId': frameId.toJson(),
    };
    await _client.send('ApplicationCache.getManifestForFrame', parameters);
  }

  /// Returns relevant application cache data for the document in given frame.
  /// [frameId] Identifier of the frame containing document whose application cache is retrieved.
  /// Return: Relevant application cache data for the document in given frame.
  Future<ApplicationCache> getApplicationCacheForFrame(
    page.FrameId frameId,
  ) async {
    Map parameters = {
      'frameId': frameId.toJson(),
    };
    await _client.send(
        'ApplicationCache.getApplicationCacheForFrame', parameters);
  }
}

/// Detailed application cache resource information.
class ApplicationCacheResource {
  /// Resource url.
  final String url;

  /// Resource size.
  final int size;

  /// Resource type.
  final String type;

  ApplicationCacheResource({
    @required this.url,
    @required this.size,
    @required this.type,
  });
  factory ApplicationCacheResource.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'url': url.toString(),
      'size': size.toString(),
      'type': type.toString(),
    };
    return json;
  }
}

/// Detailed application cache information.
class ApplicationCache {
  /// Manifest URL.
  final String manifestURL;

  /// Application cache size.
  final num size;

  /// Application cache creation time.
  final num creationTime;

  /// Application cache update time.
  final num updateTime;

  /// Application cache resources.
  final List<ApplicationCacheResource> resources;

  ApplicationCache({
    @required this.manifestURL,
    @required this.size,
    @required this.creationTime,
    @required this.updateTime,
    @required this.resources,
  });
  factory ApplicationCache.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'manifestURL': manifestURL.toString(),
      'size': size.toString(),
      'creationTime': creationTime.toString(),
      'updateTime': updateTime.toString(),
      'resources': resources.map((e) => e.toJson()).toList(),
    };
    return json;
  }
}

/// Frame identifier - manifest URL pair.
class FrameWithManifest {
  /// Frame identifier.
  final page.FrameId frameId;

  /// Manifest URL.
  final String manifestURL;

  /// Application cache status.
  final int status;

  FrameWithManifest({
    @required this.frameId,
    @required this.manifestURL,
    @required this.status,
  });
  factory FrameWithManifest.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'frameId': frameId.toJson(),
      'manifestURL': manifestURL.toString(),
      'status': status.toString(),
    };
    return json;
  }
}
