import 'dart:async';
// ignore: unused_import
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'page.dart' as page;

class ApplicationCacheManager {
  final Client _client;

  ApplicationCacheManager(this._client);

  Stream<ApplicationCacheStatusUpdatedEvent>
      get onApplicationCacheStatusUpdated => _client.onEvent
          .where((Event event) =>
              event.name == 'ApplicationCache.applicationCacheStatusUpdated')
          .map((Event event) => new ApplicationCacheStatusUpdatedEvent.fromJson(
              event.parameters));

  Stream<bool> get onNetworkStateUpdated => _client.onEvent
      .where(
          (Event event) => event.name == 'ApplicationCache.networkStateUpdated')
      .map((Event event) => event.parameters['isNowOnline'] as bool);

  /// Returns array of frame identifiers with manifest urls for each frame containing a document associated with some application cache.
  /// Return: Array of frame identifiers with manifest urls for each frame containing a document associated with some application cache.
  Future<List<FrameWithManifest>> getFramesWithManifests() async {
    Map result = await _client.send('ApplicationCache.getFramesWithManifests');
    return (result['frameIds'] as List)
        .map((e) => new FrameWithManifest.fromJson(e))
        .toList();
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
    Map result =
        await _client.send('ApplicationCache.getManifestForFrame', parameters);
    return result['manifestURL'];
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
    Map result = await _client.send(
        'ApplicationCache.getApplicationCacheForFrame', parameters);
    return new ApplicationCache.fromJson(result['applicationCache']);
  }
}

class ApplicationCacheStatusUpdatedEvent {
  /// Identifier of the frame containing document whose application cache updated status.
  final page.FrameId frameId;

  /// Manifest URL.
  final String manifestURL;

  /// Updated application cache status.
  final int status;

  ApplicationCacheStatusUpdatedEvent({
    @required this.frameId,
    @required this.manifestURL,
    @required this.status,
  });

  factory ApplicationCacheStatusUpdatedEvent.fromJson(Map json) {
    return new ApplicationCacheStatusUpdatedEvent(
      frameId: new page.FrameId.fromJson(json['frameId']),
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

  ApplicationCacheResource({
    @required this.url,
    @required this.size,
    @required this.type,
  });

  factory ApplicationCacheResource.fromJson(Map json) {
    return new ApplicationCacheResource(
      url: json['url'],
      size: json['size'],
      type: json['type'],
    );
  }

  Map toJson() {
    Map json = {
      'url': url,
      'size': size,
      'type': type,
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

  factory ApplicationCache.fromJson(Map json) {
    return new ApplicationCache(
      manifestURL: json['manifestURL'],
      size: json['size'],
      creationTime: json['creationTime'],
      updateTime: json['updateTime'],
      resources: (json['resources'] as List)
          .map((e) => new ApplicationCacheResource.fromJson(e))
          .toList(),
    );
  }

  Map toJson() {
    Map json = {
      'manifestURL': manifestURL,
      'size': size,
      'creationTime': creationTime,
      'updateTime': updateTime,
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

  factory FrameWithManifest.fromJson(Map json) {
    return new FrameWithManifest(
      frameId: new page.FrameId.fromJson(json['frameId']),
      manifestURL: json['manifestURL'],
      status: json['status'],
    );
  }

  Map toJson() {
    Map json = {
      'frameId': frameId.toJson(),
      'manifestURL': manifestURL,
      'status': status,
    };
    return json;
  }
}
