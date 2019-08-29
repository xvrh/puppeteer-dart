import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'page.dart' as page;

class ApplicationCacheApi {
  final Client _client;

  ApplicationCacheApi(this._client);

  Stream<ApplicationCacheStatusUpdatedEvent>
      get onApplicationCacheStatusUpdated => _client.onEvent
          .where((event) =>
              event.name == 'ApplicationCache.applicationCacheStatusUpdated')
          .map((event) =>
              ApplicationCacheStatusUpdatedEvent.fromJson(event.parameters));

  Stream<bool> get onNetworkStateUpdated => _client.onEvent
      .where((event) => event.name == 'ApplicationCache.networkStateUpdated')
      .map((event) => event.parameters['isNowOnline'] as bool);

  /// Enables application cache domain notifications.
  Future<void> enable() async {
    await _client.send('ApplicationCache.enable');
  }

  /// Returns relevant application cache data for the document in given frame.
  /// [frameId] Identifier of the frame containing document whose application cache is retrieved.
  /// Returns: Relevant application cache data for the document in given frame.
  Future<ApplicationCache> getApplicationCacheForFrame(
      page.FrameId frameId) async {
    var result =
        await _client.send('ApplicationCache.getApplicationCacheForFrame', {
      'frameId': frameId.toJson(),
    });
    return ApplicationCache.fromJson(result['applicationCache']);
  }

  /// Returns array of frame identifiers with manifest urls for each frame containing a document
  /// associated with some application cache.
  /// Returns: Array of frame identifiers with manifest urls for each frame containing a document
  /// associated with some application cache.
  Future<List<FrameWithManifest>> getFramesWithManifests() async {
    var result = await _client.send('ApplicationCache.getFramesWithManifests');
    return (result['frameIds'] as List)
        .map((e) => FrameWithManifest.fromJson(e))
        .toList();
  }

  /// Returns manifest URL for document in the given frame.
  /// [frameId] Identifier of the frame containing document whose manifest is retrieved.
  /// Returns: Manifest URL for document in the given frame.
  Future<String> getManifestForFrame(page.FrameId frameId) async {
    var result = await _client.send('ApplicationCache.getManifestForFrame', {
      'frameId': frameId.toJson(),
    });
    return result['manifestURL'];
  }
}

class ApplicationCacheStatusUpdatedEvent {
  /// Identifier of the frame containing document whose application cache updated status.
  final page.FrameId frameId;

  /// Manifest URL.
  final String manifestURL;

  /// Updated application cache status.
  final int status;

  ApplicationCacheStatusUpdatedEvent(
      {@required this.frameId,
      @required this.manifestURL,
      @required this.status});

  factory ApplicationCacheStatusUpdatedEvent.fromJson(
      Map<String, dynamic> json) {
    return ApplicationCacheStatusUpdatedEvent(
      frameId: page.FrameId.fromJson(json['frameId']),
      manifestURL: json['manifestURL'],
      status: json['status'],
    );
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

  ApplicationCacheResource(
      {@required this.url, @required this.size, @required this.type});

  factory ApplicationCacheResource.fromJson(Map<String, dynamic> json) {
    return ApplicationCacheResource(
      url: json['url'],
      size: json['size'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'size': size,
      'type': type,
    };
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

  ApplicationCache(
      {@required this.manifestURL,
      @required this.size,
      @required this.creationTime,
      @required this.updateTime,
      @required this.resources});

  factory ApplicationCache.fromJson(Map<String, dynamic> json) {
    return ApplicationCache(
      manifestURL: json['manifestURL'],
      size: json['size'],
      creationTime: json['creationTime'],
      updateTime: json['updateTime'],
      resources: (json['resources'] as List)
          .map((e) => ApplicationCacheResource.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'manifestURL': manifestURL,
      'size': size,
      'creationTime': creationTime,
      'updateTime': updateTime,
      'resources': resources.map((e) => e.toJson()).toList(),
    };
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

  FrameWithManifest(
      {@required this.frameId,
      @required this.manifestURL,
      @required this.status});

  factory FrameWithManifest.fromJson(Map<String, dynamic> json) {
    return FrameWithManifest(
      frameId: page.FrameId.fromJson(json['frameId']),
      manifestURL: json['manifestURL'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frameId': frameId.toJson(),
      'manifestURL': manifestURL,
      'status': status,
    };
  }
}
