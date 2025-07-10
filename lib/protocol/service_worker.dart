import 'dart:async';
import '../src/connection.dart';
import 'target.dart' as target;

class ServiceWorkerApi {
  final Client _client;

  ServiceWorkerApi(this._client);

  Stream<ServiceWorkerErrorMessage> get onWorkerErrorReported => _client.onEvent
      .where((event) => event.name == 'ServiceWorker.workerErrorReported')
      .map(
        (event) => ServiceWorkerErrorMessage.fromJson(
          event.parameters['errorMessage'] as Map<String, dynamic>,
        ),
      );

  Stream<List<ServiceWorkerRegistration>> get onWorkerRegistrationUpdated =>
      _client.onEvent
          .where(
            (event) => event.name == 'ServiceWorker.workerRegistrationUpdated',
          )
          .map(
            (event) => (event.parameters['registrations'] as List)
                .map(
                  (e) => ServiceWorkerRegistration.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList(),
          );

  Stream<List<ServiceWorkerVersion>> get onWorkerVersionUpdated => _client
      .onEvent
      .where((event) => event.name == 'ServiceWorker.workerVersionUpdated')
      .map(
        (event) => (event.parameters['versions'] as List)
            .map(
              (e) => ServiceWorkerVersion.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );

  Future<void> deliverPushMessage(
    String origin,
    RegistrationID registrationId,
    String data,
  ) async {
    await _client.send('ServiceWorker.deliverPushMessage', {
      'origin': origin,
      'registrationId': registrationId,
      'data': data,
    });
  }

  Future<void> disable() async {
    await _client.send('ServiceWorker.disable');
  }

  Future<void> dispatchSyncEvent(
    String origin,
    RegistrationID registrationId,
    String tag,
    bool lastChance,
  ) async {
    await _client.send('ServiceWorker.dispatchSyncEvent', {
      'origin': origin,
      'registrationId': registrationId,
      'tag': tag,
      'lastChance': lastChance,
    });
  }

  Future<void> dispatchPeriodicSyncEvent(
    String origin,
    RegistrationID registrationId,
    String tag,
  ) async {
    await _client.send('ServiceWorker.dispatchPeriodicSyncEvent', {
      'origin': origin,
      'registrationId': registrationId,
      'tag': tag,
    });
  }

  Future<void> enable() async {
    await _client.send('ServiceWorker.enable');
  }

  Future<void> inspectWorker(String versionId) async {
    await _client.send('ServiceWorker.inspectWorker', {'versionId': versionId});
  }

  Future<void> setForceUpdateOnPageLoad(bool forceUpdateOnPageLoad) async {
    await _client.send('ServiceWorker.setForceUpdateOnPageLoad', {
      'forceUpdateOnPageLoad': forceUpdateOnPageLoad,
    });
  }

  Future<void> skipWaiting(String scopeURL) async {
    await _client.send('ServiceWorker.skipWaiting', {'scopeURL': scopeURL});
  }

  Future<void> startWorker(String scopeURL) async {
    await _client.send('ServiceWorker.startWorker', {'scopeURL': scopeURL});
  }

  Future<void> stopAllWorkers() async {
    await _client.send('ServiceWorker.stopAllWorkers');
  }

  Future<void> stopWorker(String versionId) async {
    await _client.send('ServiceWorker.stopWorker', {'versionId': versionId});
  }

  Future<void> unregister(String scopeURL) async {
    await _client.send('ServiceWorker.unregister', {'scopeURL': scopeURL});
  }

  Future<void> updateRegistration(String scopeURL) async {
    await _client.send('ServiceWorker.updateRegistration', {
      'scopeURL': scopeURL,
    });
  }
}

extension type RegistrationID(String value) {
  factory RegistrationID.fromJson(String value) => RegistrationID(value);

  String toJson() => value;
}

/// ServiceWorker registration.
class ServiceWorkerRegistration {
  final RegistrationID registrationId;

  final String scopeURL;

  final bool isDeleted;

  ServiceWorkerRegistration({
    required this.registrationId,
    required this.scopeURL,
    required this.isDeleted,
  });

  factory ServiceWorkerRegistration.fromJson(Map<String, dynamic> json) {
    return ServiceWorkerRegistration(
      registrationId: RegistrationID.fromJson(json['registrationId'] as String),
      scopeURL: json['scopeURL'] as String,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'registrationId': registrationId.toJson(),
      'scopeURL': scopeURL,
      'isDeleted': isDeleted,
    };
  }
}

enum ServiceWorkerVersionRunningStatus {
  stopped('stopped'),
  starting('starting'),
  running('running'),
  stopping('stopping');

  final String value;

  const ServiceWorkerVersionRunningStatus(this.value);

  factory ServiceWorkerVersionRunningStatus.fromJson(String value) =>
      ServiceWorkerVersionRunningStatus.values.firstWhere(
        (e) => e.value == value,
      );

  String toJson() => value;

  @override
  String toString() => value.toString();
}

enum ServiceWorkerVersionStatus {
  new$('new'),
  installing('installing'),
  installed('installed'),
  activating('activating'),
  activated('activated'),
  redundant('redundant');

  final String value;

  const ServiceWorkerVersionStatus(this.value);

  factory ServiceWorkerVersionStatus.fromJson(String value) =>
      ServiceWorkerVersionStatus.values.firstWhere((e) => e.value == value);

  String toJson() => value;

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
  final num? scriptLastModified;

  /// The time at which the response headers of the main script were received from the server.
  /// For cached script it is the last time the cache entry was validated.
  final num? scriptResponseTime;

  final List<target.TargetID>? controlledClients;

  final target.TargetID? targetId;

  final String? routerRules;

  ServiceWorkerVersion({
    required this.versionId,
    required this.registrationId,
    required this.scriptURL,
    required this.runningStatus,
    required this.status,
    this.scriptLastModified,
    this.scriptResponseTime,
    this.controlledClients,
    this.targetId,
    this.routerRules,
  });

  factory ServiceWorkerVersion.fromJson(Map<String, dynamic> json) {
    return ServiceWorkerVersion(
      versionId: json['versionId'] as String,
      registrationId: RegistrationID.fromJson(json['registrationId'] as String),
      scriptURL: json['scriptURL'] as String,
      runningStatus: ServiceWorkerVersionRunningStatus.fromJson(
        json['runningStatus'] as String,
      ),
      status: ServiceWorkerVersionStatus.fromJson(json['status'] as String),
      scriptLastModified: json.containsKey('scriptLastModified')
          ? json['scriptLastModified'] as num
          : null,
      scriptResponseTime: json.containsKey('scriptResponseTime')
          ? json['scriptResponseTime'] as num
          : null,
      controlledClients: json.containsKey('controlledClients')
          ? (json['controlledClients'] as List)
                .map((e) => target.TargetID.fromJson(e as String))
                .toList()
          : null,
      targetId: json.containsKey('targetId')
          ? target.TargetID.fromJson(json['targetId'] as String)
          : null,
      routerRules: json.containsKey('routerRules')
          ? json['routerRules'] as String
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'versionId': versionId,
      'registrationId': registrationId.toJson(),
      'scriptURL': scriptURL,
      'runningStatus': runningStatus.toJson(),
      'status': status.toJson(),
      if (scriptLastModified != null) 'scriptLastModified': scriptLastModified,
      if (scriptResponseTime != null) 'scriptResponseTime': scriptResponseTime,
      if (controlledClients != null)
        'controlledClients': controlledClients!.map((e) => e.toJson()).toList(),
      if (targetId != null) 'targetId': targetId!.toJson(),
      if (routerRules != null) 'routerRules': routerRules,
    };
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

  ServiceWorkerErrorMessage({
    required this.errorMessage,
    required this.registrationId,
    required this.versionId,
    required this.sourceURL,
    required this.lineNumber,
    required this.columnNumber,
  });

  factory ServiceWorkerErrorMessage.fromJson(Map<String, dynamic> json) {
    return ServiceWorkerErrorMessage(
      errorMessage: json['errorMessage'] as String,
      registrationId: RegistrationID.fromJson(json['registrationId'] as String),
      versionId: json['versionId'] as String,
      sourceURL: json['sourceURL'] as String,
      lineNumber: json['lineNumber'] as int,
      columnNumber: json['columnNumber'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'errorMessage': errorMessage,
      'registrationId': registrationId.toJson(),
      'versionId': versionId,
      'sourceURL': sourceURL,
      'lineNumber': lineNumber,
      'columnNumber': columnNumber,
    };
  }
}
