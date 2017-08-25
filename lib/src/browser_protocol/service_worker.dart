import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';
import 'target.dart' as target;

class ServiceWorkerManager {
  final Session _client;

  ServiceWorkerManager(this._client);

  Future enable() async {
    await _client.send('ServiceWorker.enable');
  }

  Future disable() async {
    await _client.send('ServiceWorker.disable');
  }

  Future unregister(
    String scopeURL,
  ) async {
    Map parameters = {
      'scopeURL': scopeURL.toString(),
    };
    await _client.send('ServiceWorker.unregister', parameters);
  }

  Future updateRegistration(
    String scopeURL,
  ) async {
    Map parameters = {
      'scopeURL': scopeURL.toString(),
    };
    await _client.send('ServiceWorker.updateRegistration', parameters);
  }

  Future startWorker(
    String scopeURL,
  ) async {
    Map parameters = {
      'scopeURL': scopeURL.toString(),
    };
    await _client.send('ServiceWorker.startWorker', parameters);
  }

  Future skipWaiting(
    String scopeURL,
  ) async {
    Map parameters = {
      'scopeURL': scopeURL.toString(),
    };
    await _client.send('ServiceWorker.skipWaiting', parameters);
  }

  Future stopWorker(
    String versionId,
  ) async {
    Map parameters = {
      'versionId': versionId.toString(),
    };
    await _client.send('ServiceWorker.stopWorker', parameters);
  }

  Future inspectWorker(
    String versionId,
  ) async {
    Map parameters = {
      'versionId': versionId.toString(),
    };
    await _client.send('ServiceWorker.inspectWorker', parameters);
  }

  Future setForceUpdateOnPageLoad(
    bool forceUpdateOnPageLoad,
  ) async {
    Map parameters = {
      'forceUpdateOnPageLoad': forceUpdateOnPageLoad.toString(),
    };
    await _client.send('ServiceWorker.setForceUpdateOnPageLoad', parameters);
  }

  Future deliverPushMessage(
    String origin,
    String registrationId,
    String data,
  ) async {
    Map parameters = {
      'origin': origin.toString(),
      'registrationId': registrationId.toString(),
      'data': data.toString(),
    };
    await _client.send('ServiceWorker.deliverPushMessage', parameters);
  }

  Future dispatchSyncEvent(
    String origin,
    String registrationId,
    String tag,
    bool lastChance,
  ) async {
    Map parameters = {
      'origin': origin.toString(),
      'registrationId': registrationId.toString(),
      'tag': tag.toString(),
      'lastChance': lastChance.toString(),
    };
    await _client.send('ServiceWorker.dispatchSyncEvent', parameters);
  }
}

/// ServiceWorker registration.
class ServiceWorkerRegistration {
  final String registrationId;

  final String scopeURL;

  final bool isDeleted;

  ServiceWorkerRegistration({
    @required this.registrationId,
    @required this.scopeURL,
    @required this.isDeleted,
  });

  Map toJson() {
    Map json = {
      'registrationId': registrationId.toString(),
      'scopeURL': scopeURL.toString(),
      'isDeleted': isDeleted.toString(),
    };
    return json;
  }
}

class ServiceWorkerVersionRunningStatus {
  static const ServiceWorkerVersionRunningStatus stopped =
      const ServiceWorkerVersionRunningStatus._('stopped');
  static const ServiceWorkerVersionRunningStatus starting =
      const ServiceWorkerVersionRunningStatus._('starting');
  static const ServiceWorkerVersionRunningStatus running =
      const ServiceWorkerVersionRunningStatus._('running');
  static const ServiceWorkerVersionRunningStatus stopping =
      const ServiceWorkerVersionRunningStatus._('stopping');

  final String value;

  const ServiceWorkerVersionRunningStatus._(this.value);

  String toJson() => value;
}

class ServiceWorkerVersionStatus {
  static const ServiceWorkerVersionStatus new$ =
      const ServiceWorkerVersionStatus._('new');
  static const ServiceWorkerVersionStatus installing =
      const ServiceWorkerVersionStatus._('installing');
  static const ServiceWorkerVersionStatus installed =
      const ServiceWorkerVersionStatus._('installed');
  static const ServiceWorkerVersionStatus activating =
      const ServiceWorkerVersionStatus._('activating');
  static const ServiceWorkerVersionStatus activated =
      const ServiceWorkerVersionStatus._('activated');
  static const ServiceWorkerVersionStatus redundant =
      const ServiceWorkerVersionStatus._('redundant');

  final String value;

  const ServiceWorkerVersionStatus._(this.value);

  String toJson() => value;
}

/// ServiceWorker version.
class ServiceWorkerVersion {
  final String versionId;

  final String registrationId;

  final String scriptURL;

  final ServiceWorkerVersionRunningStatus runningStatus;

  final ServiceWorkerVersionStatus status;

  /// The Last-Modified header value of the main script.
  final num scriptLastModified;

  /// The time at which the response headers of the main script were received from the server.  For cached script it is the last time the cache entry was validated.
  final num scriptResponseTime;

  final List<target.TargetID> controlledClients;

  final target.TargetID targetId;

  ServiceWorkerVersion({
    @required this.versionId,
    @required this.registrationId,
    @required this.scriptURL,
    @required this.runningStatus,
    @required this.status,
    this.scriptLastModified,
    this.scriptResponseTime,
    this.controlledClients,
    this.targetId,
  });

  Map toJson() {
    Map json = {
      'versionId': versionId.toString(),
      'registrationId': registrationId.toString(),
      'scriptURL': scriptURL.toString(),
      'runningStatus': runningStatus.toJson(),
      'status': status.toJson(),
    };
    if (scriptLastModified != null) {
      json['scriptLastModified'] = scriptLastModified.toString();
    }
    if (scriptResponseTime != null) {
      json['scriptResponseTime'] = scriptResponseTime.toString();
    }
    if (controlledClients != null) {
      json['controlledClients'] =
          controlledClients.map((e) => e.toJson()).toList();
    }
    if (targetId != null) {
      json['targetId'] = targetId.toJson();
    }
    return json;
  }
}

/// ServiceWorker error message.
class ServiceWorkerErrorMessage {
  final String errorMessage;

  final String registrationId;

  final String versionId;

  final String sourceURL;

  final int lineNumber;

  final int columnNumber;

  ServiceWorkerErrorMessage({
    @required this.errorMessage,
    @required this.registrationId,
    @required this.versionId,
    @required this.sourceURL,
    @required this.lineNumber,
    @required this.columnNumber,
  });

  Map toJson() {
    Map json = {
      'errorMessage': errorMessage.toString(),
      'registrationId': registrationId.toString(),
      'versionId': versionId.toString(),
      'sourceURL': sourceURL.toString(),
      'lineNumber': lineNumber.toString(),
      'columnNumber': columnNumber.toString(),
    };
    return json;
  }
}
