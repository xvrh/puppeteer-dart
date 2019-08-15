import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'target.dart' as target;

class ServiceWorkerApi {
  final Client _client;

  ServiceWorkerApi(this._client);

  Stream<ServiceWorkerErrorMessage> get onWorkerErrorReported => _client.onEvent
      .where((event) => event.name == 'ServiceWorker.workerErrorReported')
      .map((event) =>
          ServiceWorkerErrorMessage.fromJson(event.parameters['errorMessage']));

  Stream<List<ServiceWorkerRegistration>> get onWorkerRegistrationUpdated =>
      _client.onEvent
          .where((event) =>
              event.name == 'ServiceWorker.workerRegistrationUpdated')
          .map((event) => (event.parameters['registrations'] as List)
              .map((e) => ServiceWorkerRegistration.fromJson(e))
              .toList());

  Stream<List<ServiceWorkerVersion>> get onWorkerVersionUpdated =>
      _client.onEvent
          .where((event) => event.name == 'ServiceWorker.workerVersionUpdated')
          .map((event) => (event.parameters['versions'] as List)
              .map((e) => ServiceWorkerVersion.fromJson(e))
              .toList());

  Future<void> deliverPushMessage(
      String origin, RegistrationID registrationId, String data) async {
    var parameters = <String, dynamic>{
      'origin': origin,
      'registrationId': registrationId.toJson(),
      'data': data,
    };
    await _client.send('ServiceWorker.deliverPushMessage', parameters);
  }

  Future<void> disable() async {
    await _client.send('ServiceWorker.disable');
  }

  Future<void> dispatchSyncEvent(String origin, RegistrationID registrationId,
      String tag, bool lastChance) async {
    var parameters = <String, dynamic>{
      'origin': origin,
      'registrationId': registrationId.toJson(),
      'tag': tag,
      'lastChance': lastChance,
    };
    await _client.send('ServiceWorker.dispatchSyncEvent', parameters);
  }

  Future<void> dispatchPeriodicSyncEvent(
      String origin, RegistrationID registrationId, String tag) async {
    var parameters = <String, dynamic>{
      'origin': origin,
      'registrationId': registrationId.toJson(),
      'tag': tag,
    };
    await _client.send('ServiceWorker.dispatchPeriodicSyncEvent', parameters);
  }

  Future<void> enable() async {
    await _client.send('ServiceWorker.enable');
  }

  Future<void> inspectWorker(String versionId) async {
    var parameters = <String, dynamic>{
      'versionId': versionId,
    };
    await _client.send('ServiceWorker.inspectWorker', parameters);
  }

  Future<void> setForceUpdateOnPageLoad(bool forceUpdateOnPageLoad) async {
    var parameters = <String, dynamic>{
      'forceUpdateOnPageLoad': forceUpdateOnPageLoad,
    };
    await _client.send('ServiceWorker.setForceUpdateOnPageLoad', parameters);
  }

  Future<void> skipWaiting(String scopeURL) async {
    var parameters = <String, dynamic>{
      'scopeURL': scopeURL,
    };
    await _client.send('ServiceWorker.skipWaiting', parameters);
  }

  Future<void> startWorker(String scopeURL) async {
    var parameters = <String, dynamic>{
      'scopeURL': scopeURL,
    };
    await _client.send('ServiceWorker.startWorker', parameters);
  }

  Future<void> stopAllWorkers() async {
    await _client.send('ServiceWorker.stopAllWorkers');
  }

  Future<void> stopWorker(String versionId) async {
    var parameters = <String, dynamic>{
      'versionId': versionId,
    };
    await _client.send('ServiceWorker.stopWorker', parameters);
  }

  Future<void> unregister(String scopeURL) async {
    var parameters = <String, dynamic>{
      'scopeURL': scopeURL,
    };
    await _client.send('ServiceWorker.unregister', parameters);
  }

  Future<void> updateRegistration(String scopeURL) async {
    var parameters = <String, dynamic>{
      'scopeURL': scopeURL,
    };
    await _client.send('ServiceWorker.updateRegistration', parameters);
  }
}

class RegistrationID {
  final String value;

  RegistrationID(this.value);

  factory RegistrationID.fromJson(String value) => RegistrationID(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is RegistrationID && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// ServiceWorker registration.
class ServiceWorkerRegistration {
  final RegistrationID registrationId;

  final String scopeURL;

  final bool isDeleted;

  ServiceWorkerRegistration(
      {@required this.registrationId,
      @required this.scopeURL,
      @required this.isDeleted});

  factory ServiceWorkerRegistration.fromJson(Map<String, dynamic> json) {
    return ServiceWorkerRegistration(
      registrationId: RegistrationID.fromJson(json['registrationId']),
      scopeURL: json['scopeURL'],
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'registrationId': registrationId.toJson(),
      'scopeURL': scopeURL,
      'isDeleted': isDeleted,
    };
    return json;
  }
}

class ServiceWorkerVersionRunningStatus {
  static const stopped = ServiceWorkerVersionRunningStatus._('stopped');
  static const starting = ServiceWorkerVersionRunningStatus._('starting');
  static const running = ServiceWorkerVersionRunningStatus._('running');
  static const stopping = ServiceWorkerVersionRunningStatus._('stopping');
  static const values = {
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
  bool operator ==(other) =>
      (other is ServiceWorkerVersionRunningStatus && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class ServiceWorkerVersionStatus {
  static const new$ = ServiceWorkerVersionStatus._('new');
  static const installing = ServiceWorkerVersionStatus._('installing');
  static const installed = ServiceWorkerVersionStatus._('installed');
  static const activating = ServiceWorkerVersionStatus._('activating');
  static const activated = ServiceWorkerVersionStatus._('activated');
  static const redundant = ServiceWorkerVersionStatus._('redundant');
  static const values = {
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
  bool operator ==(other) =>
      (other is ServiceWorkerVersionStatus && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// ServiceWorker version.
class ServiceWorkerVersion {
  final String versionId;

  final RegistrationID registrationId;

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

  ServiceWorkerVersion(
      {@required this.versionId,
      @required this.registrationId,
      @required this.scriptURL,
      @required this.runningStatus,
      @required this.status,
      this.scriptLastModified,
      this.scriptResponseTime,
      this.controlledClients,
      this.targetId});

  factory ServiceWorkerVersion.fromJson(Map<String, dynamic> json) {
    return ServiceWorkerVersion(
      versionId: json['versionId'],
      registrationId: RegistrationID.fromJson(json['registrationId']),
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
      'registrationId': registrationId.toJson(),
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

  final RegistrationID registrationId;

  final String versionId;

  final String sourceURL;

  final int lineNumber;

  final int columnNumber;

  ServiceWorkerErrorMessage(
      {@required this.errorMessage,
      @required this.registrationId,
      @required this.versionId,
      @required this.sourceURL,
      @required this.lineNumber,
      @required this.columnNumber});

  factory ServiceWorkerErrorMessage.fromJson(Map<String, dynamic> json) {
    return ServiceWorkerErrorMessage(
      errorMessage: json['errorMessage'],
      registrationId: RegistrationID.fromJson(json['registrationId']),
      versionId: json['versionId'],
      sourceURL: json['sourceURL'],
      lineNumber: json['lineNumber'],
      columnNumber: json['columnNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'errorMessage': errorMessage,
      'registrationId': registrationId.toJson(),
      'versionId': versionId,
      'sourceURL': sourceURL,
      'lineNumber': lineNumber,
      'columnNumber': columnNumber,
    };
    return json;
  }
}
