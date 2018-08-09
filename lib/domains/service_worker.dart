import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'target.dart' as target;

class ServiceWorkerApi {
  final Client _client;

  ServiceWorkerApi(this._client);

  Stream<ServiceWorkerErrorMessage> get onWorkerErrorReported => _client.onEvent
      .where((Event event) => event.name == 'ServiceWorker.workerErrorReported')
      .map((Event event) =>
          ServiceWorkerErrorMessage.fromJson(event.parameters['errorMessage']));

  Stream<List<ServiceWorkerRegistration>> get onWorkerRegistrationUpdated =>
      _client.onEvent
          .where((Event event) =>
              event.name == 'ServiceWorker.workerRegistrationUpdated')
          .map((Event event) => (event.parameters['registrations'] as List)
              .map((e) => ServiceWorkerRegistration.fromJson(e))
              .toList());

  Stream<List<ServiceWorkerVersion>> get onWorkerVersionUpdated => _client
      .onEvent
      .where(
          (Event event) => event.name == 'ServiceWorker.workerVersionUpdated')
      .map((Event event) => (event.parameters['versions'] as List)
          .map((e) => ServiceWorkerVersion.fromJson(e))
          .toList());

  Future deliverPushMessage(
    String origin,
    String registrationId,
    String data,
  ) async {
    var parameters = <String, dynamic>{
      'origin': origin,
      'registrationId': registrationId,
      'data': data,
    };
    await _client.send('ServiceWorker.deliverPushMessage', parameters);
  }

  Future disable() async {
    await _client.send('ServiceWorker.disable');
  }

  Future dispatchSyncEvent(
    String origin,
    String registrationId,
    String tag,
    bool lastChance,
  ) async {
    var parameters = <String, dynamic>{
      'origin': origin,
      'registrationId': registrationId,
      'tag': tag,
      'lastChance': lastChance,
    };
    await _client.send('ServiceWorker.dispatchSyncEvent', parameters);
  }

  Future enable() async {
    await _client.send('ServiceWorker.enable');
  }

  Future inspectWorker(
    String versionId,
  ) async {
    var parameters = <String, dynamic>{
      'versionId': versionId,
    };
    await _client.send('ServiceWorker.inspectWorker', parameters);
  }

  Future setForceUpdateOnPageLoad(
    bool forceUpdateOnPageLoad,
  ) async {
    var parameters = <String, dynamic>{
      'forceUpdateOnPageLoad': forceUpdateOnPageLoad,
    };
    await _client.send('ServiceWorker.setForceUpdateOnPageLoad', parameters);
  }

  Future skipWaiting(
    String scopeURL,
  ) async {
    var parameters = <String, dynamic>{
      'scopeURL': scopeURL,
    };
    await _client.send('ServiceWorker.skipWaiting', parameters);
  }

  Future startWorker(
    String scopeURL,
  ) async {
    var parameters = <String, dynamic>{
      'scopeURL': scopeURL,
    };
    await _client.send('ServiceWorker.startWorker', parameters);
  }

  Future stopAllWorkers() async {
    await _client.send('ServiceWorker.stopAllWorkers');
  }

  Future stopWorker(
    String versionId,
  ) async {
    var parameters = <String, dynamic>{
      'versionId': versionId,
    };
    await _client.send('ServiceWorker.stopWorker', parameters);
  }

  Future unregister(
    String scopeURL,
  ) async {
    var parameters = <String, dynamic>{
      'scopeURL': scopeURL,
    };
    await _client.send('ServiceWorker.unregister', parameters);
  }

  Future updateRegistration(
    String scopeURL,
  ) async {
    var parameters = <String, dynamic>{
      'scopeURL': scopeURL,
    };
    await _client.send('ServiceWorker.updateRegistration', parameters);
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

  factory ServiceWorkerRegistration.fromJson(Map<String, dynamic> json) {
    return ServiceWorkerRegistration(
      registrationId: json['registrationId'],
      scopeURL: json['scopeURL'],
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'registrationId': registrationId,
      'scopeURL': scopeURL,
      'isDeleted': isDeleted,
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
  static const values = const {
    'stopped': stopped,
    'starting': starting,
    'running': running,
    'stopping': stopping,
  };

  final String value;

  const ServiceWorkerVersionRunningStatus._(this.value);

  factory ServiceWorkerVersionRunningStatus.fromJson(String value) =>
      values[value];

  String toJson() => value;

  @override
  String toString() => value.toString();
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
  static const values = const {
    'new': new$,
    'installing': installing,
    'installed': installed,
    'activating': activating,
    'activated': activated,
    'redundant': redundant,
  };

  final String value;

  const ServiceWorkerVersionStatus._(this.value);

  factory ServiceWorkerVersionStatus.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  String toString() => value.toString();
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

  /// The time at which the response headers of the main script were received from the server.
  /// For cached script it is the last time the cache entry was validated.
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

  factory ServiceWorkerVersion.fromJson(Map<String, dynamic> json) {
    return ServiceWorkerVersion(
      versionId: json['versionId'],
      registrationId: json['registrationId'],
      scriptURL: json['scriptURL'],
      runningStatus:
          ServiceWorkerVersionRunningStatus.fromJson(json['runningStatus']),
      status: ServiceWorkerVersionStatus.fromJson(json['status']),
      scriptLastModified: json.containsKey('scriptLastModified')
          ? json['scriptLastModified']
          : null,
      scriptResponseTime: json.containsKey('scriptResponseTime')
          ? json['scriptResponseTime']
          : null,
      controlledClients: json.containsKey('controlledClients')
          ? (json['controlledClients'] as List)
              .map((e) => target.TargetID.fromJson(e))
              .toList()
          : null,
      targetId: json.containsKey('targetId')
          ? target.TargetID.fromJson(json['targetId'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'versionId': versionId,
      'registrationId': registrationId,
      'scriptURL': scriptURL,
      'runningStatus': runningStatus.toJson(),
      'status': status.toJson(),
    };
    if (scriptLastModified != null) {
      json['scriptLastModified'] = scriptLastModified;
    }
    if (scriptResponseTime != null) {
      json['scriptResponseTime'] = scriptResponseTime;
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

  factory ServiceWorkerErrorMessage.fromJson(Map<String, dynamic> json) {
    return ServiceWorkerErrorMessage(
      errorMessage: json['errorMessage'],
      registrationId: json['registrationId'],
      versionId: json['versionId'],
      sourceURL: json['sourceURL'],
      lineNumber: json['lineNumber'],
      columnNumber: json['columnNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'errorMessage': errorMessage,
      'registrationId': registrationId,
      'versionId': versionId,
      'sourceURL': sourceURL,
      'lineNumber': lineNumber,
      'columnNumber': columnNumber,
    };
    return json;
  }
}
