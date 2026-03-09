import 'dart:async';
import '../src/connection.dart';

class SmartCardEmulationApi {
  final Client _client;

  SmartCardEmulationApi(this._client);

  /// Fired when |SCardEstablishContext| is called.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#gaa1b8970169fd4883a6dc4a8f43f19b67
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardestablishcontext
  Stream<String> get onEstablishContextRequested => _client.onEvent
      .where(
        (event) => event.name == 'SmartCardEmulation.establishContextRequested',
      )
      .map((event) => event.parameters['requestId'] as String);

  /// Fired when |SCardReleaseContext| is called.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#ga6aabcba7744c5c9419fdd6404f73a934
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardreleasecontext
  Stream<ReleaseContextRequestedEvent> get onReleaseContextRequested => _client
      .onEvent
      .where(
        (event) => event.name == 'SmartCardEmulation.releaseContextRequested',
      )
      .map((event) => ReleaseContextRequestedEvent.fromJson(event.parameters));

  /// Fired when |SCardListReaders| is called.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#ga93b07815789b3cf2629d439ecf20f0d9
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardlistreadersa
  Stream<ListReadersRequestedEvent> get onListReadersRequested => _client
      .onEvent
      .where((event) => event.name == 'SmartCardEmulation.listReadersRequested')
      .map((event) => ListReadersRequestedEvent.fromJson(event.parameters));

  /// Fired when |SCardGetStatusChange| is called. Timeout is specified in milliseconds.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#ga33247d5d1257d59e55647c3bb717db24
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardgetstatuschangea
  Stream<GetStatusChangeRequestedEvent> get onGetStatusChangeRequested =>
      _client.onEvent
          .where(
            (event) =>
                event.name == 'SmartCardEmulation.getStatusChangeRequested',
          )
          .map(
            (event) => GetStatusChangeRequestedEvent.fromJson(event.parameters),
          );

  /// Fired when |SCardCancel| is called.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#gaacbbc0c6d6c0cbbeb4f4debf6fbeeee6
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardcancel
  Stream<CancelRequestedEvent> get onCancelRequested => _client.onEvent
      .where((event) => event.name == 'SmartCardEmulation.cancelRequested')
      .map((event) => CancelRequestedEvent.fromJson(event.parameters));

  /// Fired when |SCardConnect| is called.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#ga4e515829752e0a8dbc4d630696a8d6a5
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardconnecta
  Stream<ConnectRequestedEvent> get onConnectRequested => _client.onEvent
      .where((event) => event.name == 'SmartCardEmulation.connectRequested')
      .map((event) => ConnectRequestedEvent.fromJson(event.parameters));

  /// Fired when |SCardDisconnect| is called.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#ga4be198045c73ec0deb79e66c0ca1738a
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scarddisconnect
  Stream<DisconnectRequestedEvent> get onDisconnectRequested => _client.onEvent
      .where((event) => event.name == 'SmartCardEmulation.disconnectRequested')
      .map((event) => DisconnectRequestedEvent.fromJson(event.parameters));

  /// Fired when |SCardTransmit| is called.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#ga9a2d77242a271310269065e64633ab99
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardtransmit
  Stream<TransmitRequestedEvent> get onTransmitRequested => _client.onEvent
      .where((event) => event.name == 'SmartCardEmulation.transmitRequested')
      .map((event) => TransmitRequestedEvent.fromJson(event.parameters));

  /// Fired when |SCardControl| is called.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#gac3454d4657110fd7f753b2d3d8f4e32f
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardcontrol
  Stream<ControlRequestedEvent> get onControlRequested => _client.onEvent
      .where((event) => event.name == 'SmartCardEmulation.controlRequested')
      .map((event) => ControlRequestedEvent.fromJson(event.parameters));

  /// Fired when |SCardGetAttrib| is called.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#gaacfec51917255b7a25b94c5104961602
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardgetattrib
  Stream<GetAttribRequestedEvent> get onGetAttribRequested => _client.onEvent
      .where((event) => event.name == 'SmartCardEmulation.getAttribRequested')
      .map((event) => GetAttribRequestedEvent.fromJson(event.parameters));

  /// Fired when |SCardSetAttrib| is called.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#ga060f0038a4ddfd5dd2b8fadf3c3a2e4f
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardsetattrib
  Stream<SetAttribRequestedEvent> get onSetAttribRequested => _client.onEvent
      .where((event) => event.name == 'SmartCardEmulation.setAttribRequested')
      .map((event) => SetAttribRequestedEvent.fromJson(event.parameters));

  /// Fired when |SCardStatus| is called.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#gae49c3c894ad7ac12a5b896bde70d0382
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardstatusa
  Stream<StatusRequestedEvent> get onStatusRequested => _client.onEvent
      .where((event) => event.name == 'SmartCardEmulation.statusRequested')
      .map((event) => StatusRequestedEvent.fromJson(event.parameters));

  /// Fired when |SCardBeginTransaction| is called.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#gaddb835dce01a0da1d6ca02d33ee7d861
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardbegintransaction
  Stream<BeginTransactionRequestedEvent> get onBeginTransactionRequested =>
      _client.onEvent
          .where(
            (event) =>
                event.name == 'SmartCardEmulation.beginTransactionRequested',
          )
          .map(
            (event) =>
                BeginTransactionRequestedEvent.fromJson(event.parameters),
          );

  /// Fired when |SCardEndTransaction| is called.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#gae8742473b404363e5c587f570d7e2f3b
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardendtransaction
  Stream<EndTransactionRequestedEvent> get onEndTransactionRequested => _client
      .onEvent
      .where(
        (event) => event.name == 'SmartCardEmulation.endTransactionRequested',
      )
      .map((event) => EndTransactionRequestedEvent.fromJson(event.parameters));

  /// Enables the |SmartCardEmulation| domain.
  Future<void> enable() async {
    await _client.send('SmartCardEmulation.enable');
  }

  /// Disables the |SmartCardEmulation| domain.
  Future<void> disable() async {
    await _client.send('SmartCardEmulation.disable');
  }

  /// Reports the successful result of a |SCardEstablishContext| call.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#gaa1b8970169fd4883a6dc4a8f43f19b67
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardestablishcontext
  Future<void> reportEstablishContextResult(
    String requestId,
    int contextId,
  ) async {
    await _client.send('SmartCardEmulation.reportEstablishContextResult', {
      'requestId': requestId,
      'contextId': contextId,
    });
  }

  /// Reports the successful result of a |SCardReleaseContext| call.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#ga6aabcba7744c5c9419fdd6404f73a934
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardreleasecontext
  Future<void> reportReleaseContextResult(String requestId) async {
    await _client.send('SmartCardEmulation.reportReleaseContextResult', {
      'requestId': requestId,
    });
  }

  /// Reports the successful result of a |SCardListReaders| call.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#ga93b07815789b3cf2629d439ecf20f0d9
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardlistreadersa
  Future<void> reportListReadersResult(
    String requestId,
    List<String> readers,
  ) async {
    await _client.send('SmartCardEmulation.reportListReadersResult', {
      'requestId': requestId,
      'readers': [...readers],
    });
  }

  /// Reports the successful result of a |SCardGetStatusChange| call.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#ga33247d5d1257d59e55647c3bb717db24
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardgetstatuschangea
  Future<void> reportGetStatusChangeResult(
    String requestId,
    List<ReaderStateOut> readerStates,
  ) async {
    await _client.send('SmartCardEmulation.reportGetStatusChangeResult', {
      'requestId': requestId,
      'readerStates': [...readerStates],
    });
  }

  /// Reports the result of a |SCardBeginTransaction| call.
  /// On success, this creates a new transaction object.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#gaddb835dce01a0da1d6ca02d33ee7d861
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardbegintransaction
  Future<void> reportBeginTransactionResult(
    String requestId,
    int handle,
  ) async {
    await _client.send('SmartCardEmulation.reportBeginTransactionResult', {
      'requestId': requestId,
      'handle': handle,
    });
  }

  /// Reports the successful result of a call that returns only a result code.
  /// Used for: |SCardCancel|, |SCardDisconnect|, |SCardSetAttrib|, |SCardEndTransaction|.
  ///
  /// This maps to:
  /// 1. SCardCancel
  ///    PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#gaacbbc0c6d6c0cbbeb4f4debf6fbeeee6
  ///    Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardcancel
  ///
  /// 2. SCardDisconnect
  ///    PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#ga4be198045c73ec0deb79e66c0ca1738a
  ///    Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scarddisconnect
  ///
  /// 3. SCardSetAttrib
  ///    PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#ga060f0038a4ddfd5dd2b8fadf3c3a2e4f
  ///    Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardsetattrib
  ///
  /// 4. SCardEndTransaction
  ///    PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#gae8742473b404363e5c587f570d7e2f3b
  ///    Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardendtransaction
  Future<void> reportPlainResult(String requestId) async {
    await _client.send('SmartCardEmulation.reportPlainResult', {
      'requestId': requestId,
    });
  }

  /// Reports the successful result of a |SCardConnect| call.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#ga4e515829752e0a8dbc4d630696a8d6a5
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardconnecta
  Future<void> reportConnectResult(
    String requestId,
    int handle, {
    Protocol? activeProtocol,
  }) async {
    await _client.send('SmartCardEmulation.reportConnectResult', {
      'requestId': requestId,
      'handle': handle,
      if (activeProtocol != null) 'activeProtocol': activeProtocol,
    });
  }

  /// Reports the successful result of a call that sends back data on success.
  /// Used for |SCardTransmit|, |SCardControl|, and |SCardGetAttrib|.
  ///
  /// This maps to:
  /// 1. SCardTransmit
  ///    PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#ga9a2d77242a271310269065e64633ab99
  ///    Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardtransmit
  ///
  /// 2. SCardControl
  ///    PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#gac3454d4657110fd7f753b2d3d8f4e32f
  ///    Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardcontrol
  ///
  /// 3. SCardGetAttrib
  ///    PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#gaacfec51917255b7a25b94c5104961602
  ///    Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardgetattrib
  Future<void> reportDataResult(String requestId, String data) async {
    await _client.send('SmartCardEmulation.reportDataResult', {
      'requestId': requestId,
      'data': data,
    });
  }

  /// Reports the successful result of a |SCardStatus| call.
  ///
  /// This maps to:
  /// PC/SC Lite: https://pcsclite.apdu.fr/api/group__API.html#gae49c3c894ad7ac12a5b896bde70d0382
  /// Microsoft: https://learn.microsoft.com/en-us/windows/win32/api/winscard/nf-winscard-scardstatusa
  Future<void> reportStatusResult(
    String requestId,
    String readerName,
    ConnectionState state,
    String atr, {
    Protocol? protocol,
  }) async {
    await _client.send('SmartCardEmulation.reportStatusResult', {
      'requestId': requestId,
      'readerName': readerName,
      'state': state,
      'atr': atr,
      if (protocol != null) 'protocol': protocol,
    });
  }

  /// Reports an error result for the given request.
  Future<void> reportError(String requestId, ResultCode resultCode) async {
    await _client.send('SmartCardEmulation.reportError', {
      'requestId': requestId,
      'resultCode': resultCode,
    });
  }
}

class ReleaseContextRequestedEvent {
  final String requestId;

  final int contextId;

  ReleaseContextRequestedEvent({
    required this.requestId,
    required this.contextId,
  });

  factory ReleaseContextRequestedEvent.fromJson(Map<String, dynamic> json) {
    return ReleaseContextRequestedEvent(
      requestId: json['requestId'] as String,
      contextId: json['contextId'] as int,
    );
  }
}

class ListReadersRequestedEvent {
  final String requestId;

  final int contextId;

  ListReadersRequestedEvent({required this.requestId, required this.contextId});

  factory ListReadersRequestedEvent.fromJson(Map<String, dynamic> json) {
    return ListReadersRequestedEvent(
      requestId: json['requestId'] as String,
      contextId: json['contextId'] as int,
    );
  }
}

class GetStatusChangeRequestedEvent {
  final String requestId;

  final int contextId;

  final List<ReaderStateIn> readerStates;

  /// in milliseconds, if absent, it means "infinite"
  final int? timeout;

  GetStatusChangeRequestedEvent({
    required this.requestId,
    required this.contextId,
    required this.readerStates,
    this.timeout,
  });

  factory GetStatusChangeRequestedEvent.fromJson(Map<String, dynamic> json) {
    return GetStatusChangeRequestedEvent(
      requestId: json['requestId'] as String,
      contextId: json['contextId'] as int,
      readerStates: (json['readerStates'] as List)
          .map((e) => ReaderStateIn.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeout: json.containsKey('timeout') ? json['timeout'] as int : null,
    );
  }
}

class CancelRequestedEvent {
  final String requestId;

  final int contextId;

  CancelRequestedEvent({required this.requestId, required this.contextId});

  factory CancelRequestedEvent.fromJson(Map<String, dynamic> json) {
    return CancelRequestedEvent(
      requestId: json['requestId'] as String,
      contextId: json['contextId'] as int,
    );
  }
}

class ConnectRequestedEvent {
  final String requestId;

  final int contextId;

  final String reader;

  final ShareMode shareMode;

  final ProtocolSet preferredProtocols;

  ConnectRequestedEvent({
    required this.requestId,
    required this.contextId,
    required this.reader,
    required this.shareMode,
    required this.preferredProtocols,
  });

  factory ConnectRequestedEvent.fromJson(Map<String, dynamic> json) {
    return ConnectRequestedEvent(
      requestId: json['requestId'] as String,
      contextId: json['contextId'] as int,
      reader: json['reader'] as String,
      shareMode: ShareMode.fromJson(json['shareMode'] as String),
      preferredProtocols: ProtocolSet.fromJson(
        json['preferredProtocols'] as Map<String, dynamic>,
      ),
    );
  }
}

class DisconnectRequestedEvent {
  final String requestId;

  final int handle;

  final Disposition disposition;

  DisconnectRequestedEvent({
    required this.requestId,
    required this.handle,
    required this.disposition,
  });

  factory DisconnectRequestedEvent.fromJson(Map<String, dynamic> json) {
    return DisconnectRequestedEvent(
      requestId: json['requestId'] as String,
      handle: json['handle'] as int,
      disposition: Disposition.fromJson(json['disposition'] as String),
    );
  }
}

class TransmitRequestedEvent {
  final String requestId;

  final int handle;

  final String data;

  final Protocol? protocol;

  TransmitRequestedEvent({
    required this.requestId,
    required this.handle,
    required this.data,
    this.protocol,
  });

  factory TransmitRequestedEvent.fromJson(Map<String, dynamic> json) {
    return TransmitRequestedEvent(
      requestId: json['requestId'] as String,
      handle: json['handle'] as int,
      data: json['data'] as String,
      protocol: json.containsKey('protocol')
          ? Protocol.fromJson(json['protocol'] as String)
          : null,
    );
  }
}

class ControlRequestedEvent {
  final String requestId;

  final int handle;

  final int controlCode;

  final String data;

  ControlRequestedEvent({
    required this.requestId,
    required this.handle,
    required this.controlCode,
    required this.data,
  });

  factory ControlRequestedEvent.fromJson(Map<String, dynamic> json) {
    return ControlRequestedEvent(
      requestId: json['requestId'] as String,
      handle: json['handle'] as int,
      controlCode: json['controlCode'] as int,
      data: json['data'] as String,
    );
  }
}

class GetAttribRequestedEvent {
  final String requestId;

  final int handle;

  final int attribId;

  GetAttribRequestedEvent({
    required this.requestId,
    required this.handle,
    required this.attribId,
  });

  factory GetAttribRequestedEvent.fromJson(Map<String, dynamic> json) {
    return GetAttribRequestedEvent(
      requestId: json['requestId'] as String,
      handle: json['handle'] as int,
      attribId: json['attribId'] as int,
    );
  }
}

class SetAttribRequestedEvent {
  final String requestId;

  final int handle;

  final int attribId;

  final String data;

  SetAttribRequestedEvent({
    required this.requestId,
    required this.handle,
    required this.attribId,
    required this.data,
  });

  factory SetAttribRequestedEvent.fromJson(Map<String, dynamic> json) {
    return SetAttribRequestedEvent(
      requestId: json['requestId'] as String,
      handle: json['handle'] as int,
      attribId: json['attribId'] as int,
      data: json['data'] as String,
    );
  }
}

class StatusRequestedEvent {
  final String requestId;

  final int handle;

  StatusRequestedEvent({required this.requestId, required this.handle});

  factory StatusRequestedEvent.fromJson(Map<String, dynamic> json) {
    return StatusRequestedEvent(
      requestId: json['requestId'] as String,
      handle: json['handle'] as int,
    );
  }
}

class BeginTransactionRequestedEvent {
  final String requestId;

  final int handle;

  BeginTransactionRequestedEvent({
    required this.requestId,
    required this.handle,
  });

  factory BeginTransactionRequestedEvent.fromJson(Map<String, dynamic> json) {
    return BeginTransactionRequestedEvent(
      requestId: json['requestId'] as String,
      handle: json['handle'] as int,
    );
  }
}

class EndTransactionRequestedEvent {
  final String requestId;

  final int handle;

  final Disposition disposition;

  EndTransactionRequestedEvent({
    required this.requestId,
    required this.handle,
    required this.disposition,
  });

  factory EndTransactionRequestedEvent.fromJson(Map<String, dynamic> json) {
    return EndTransactionRequestedEvent(
      requestId: json['requestId'] as String,
      handle: json['handle'] as int,
      disposition: Disposition.fromJson(json['disposition'] as String),
    );
  }
}

/// Indicates the PC/SC error code.
///
/// This maps to:
/// PC/SC Lite: https://pcsclite.apdu.fr/api/group__ErrorCodes.html
/// Microsoft: https://learn.microsoft.com/en-us/windows/win32/secauthn/authentication-return-values
enum ResultCode {
  success('success'),
  removedCard('removed-card'),
  resetCard('reset-card'),
  unpoweredCard('unpowered-card'),
  unresponsiveCard('unresponsive-card'),
  unsupportedCard('unsupported-card'),
  readerUnavailable('reader-unavailable'),
  sharingViolation('sharing-violation'),
  notTransacted('not-transacted'),
  noSmartcard('no-smartcard'),
  protoMismatch('proto-mismatch'),
  systemCancelled('system-cancelled'),
  notReady('not-ready'),
  cancelled('cancelled'),
  insufficientBuffer('insufficient-buffer'),
  invalidHandle('invalid-handle'),
  invalidParameter('invalid-parameter'),
  invalidValue('invalid-value'),
  noMemory('no-memory'),
  timeout('timeout'),
  unknownReader('unknown-reader'),
  unsupportedFeature('unsupported-feature'),
  noReadersAvailable('no-readers-available'),
  serviceStopped('service-stopped'),
  noService('no-service'),
  commError('comm-error'),
  internalError('internal-error'),
  serverTooBusy('server-too-busy'),
  unexpected('unexpected'),
  shutdown('shutdown'),
  unknownCard('unknown-card'),
  unknown('unknown');

  final String value;

  const ResultCode(this.value);

  factory ResultCode.fromJson(String value) =>
      ResultCode.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Maps to the |SCARD_SHARE_*| values.
enum ShareMode {
  shared('shared'),
  exclusive('exclusive'),
  direct('direct');

  final String value;

  const ShareMode(this.value);

  factory ShareMode.fromJson(String value) =>
      ShareMode.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Indicates what the reader should do with the card.
enum Disposition {
  leaveCard('leave-card'),
  resetCard('reset-card'),
  unpowerCard('unpower-card'),
  ejectCard('eject-card');

  final String value;

  const Disposition(this.value);

  factory Disposition.fromJson(String value) =>
      Disposition.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Maps to |SCARD_*| connection state values.
enum ConnectionState {
  absent('absent'),
  present('present'),
  swallowed('swallowed'),
  powered('powered'),
  negotiable('negotiable'),
  specific('specific');

  final String value;

  const ConnectionState(this.value);

  factory ConnectionState.fromJson(String value) =>
      ConnectionState.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Maps to the |SCARD_STATE_*| flags.
class ReaderStateFlags {
  final bool? unaware;

  final bool? ignore;

  final bool? changed;

  final bool? unknown;

  final bool? unavailable;

  final bool? empty;

  final bool? present;

  final bool? exclusive;

  final bool? inuse;

  final bool? mute;

  final bool? unpowered;

  ReaderStateFlags({
    this.unaware,
    this.ignore,
    this.changed,
    this.unknown,
    this.unavailable,
    this.empty,
    this.present,
    this.exclusive,
    this.inuse,
    this.mute,
    this.unpowered,
  });

  factory ReaderStateFlags.fromJson(Map<String, dynamic> json) {
    return ReaderStateFlags(
      unaware: json.containsKey('unaware') ? json['unaware'] as bool : null,
      ignore: json.containsKey('ignore') ? json['ignore'] as bool : null,
      changed: json.containsKey('changed') ? json['changed'] as bool : null,
      unknown: json.containsKey('unknown') ? json['unknown'] as bool : null,
      unavailable: json.containsKey('unavailable')
          ? json['unavailable'] as bool
          : null,
      empty: json.containsKey('empty') ? json['empty'] as bool : null,
      present: json.containsKey('present') ? json['present'] as bool : null,
      exclusive: json.containsKey('exclusive')
          ? json['exclusive'] as bool
          : null,
      inuse: json.containsKey('inuse') ? json['inuse'] as bool : null,
      mute: json.containsKey('mute') ? json['mute'] as bool : null,
      unpowered: json.containsKey('unpowered')
          ? json['unpowered'] as bool
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (unaware != null) 'unaware': unaware,
      if (ignore != null) 'ignore': ignore,
      if (changed != null) 'changed': changed,
      if (unknown != null) 'unknown': unknown,
      if (unavailable != null) 'unavailable': unavailable,
      if (empty != null) 'empty': empty,
      if (present != null) 'present': present,
      if (exclusive != null) 'exclusive': exclusive,
      if (inuse != null) 'inuse': inuse,
      if (mute != null) 'mute': mute,
      if (unpowered != null) 'unpowered': unpowered,
    };
  }
}

/// Maps to the |SCARD_PROTOCOL_*| flags.
class ProtocolSet {
  final bool? t0;

  final bool? t1;

  final bool? raw;

  ProtocolSet({this.t0, this.t1, this.raw});

  factory ProtocolSet.fromJson(Map<String, dynamic> json) {
    return ProtocolSet(
      t0: json.containsKey('t0') ? json['t0'] as bool : null,
      t1: json.containsKey('t1') ? json['t1'] as bool : null,
      raw: json.containsKey('raw') ? json['raw'] as bool : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (t0 != null) 't0': t0,
      if (t1 != null) 't1': t1,
      if (raw != null) 'raw': raw,
    };
  }
}

/// Maps to the |SCARD_PROTOCOL_*| values.
enum Protocol {
  t0('t0'),
  t1('t1'),
  raw('raw');

  final String value;

  const Protocol(this.value);

  factory Protocol.fromJson(String value) =>
      Protocol.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

class ReaderStateIn {
  final String reader;

  final ReaderStateFlags currentState;

  final int currentInsertionCount;

  ReaderStateIn({
    required this.reader,
    required this.currentState,
    required this.currentInsertionCount,
  });

  factory ReaderStateIn.fromJson(Map<String, dynamic> json) {
    return ReaderStateIn(
      reader: json['reader'] as String,
      currentState: ReaderStateFlags.fromJson(
        json['currentState'] as Map<String, dynamic>,
      ),
      currentInsertionCount: json['currentInsertionCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reader': reader,
      'currentState': currentState.toJson(),
      'currentInsertionCount': currentInsertionCount,
    };
  }
}

class ReaderStateOut {
  final String reader;

  final ReaderStateFlags eventState;

  final int eventCount;

  final String atr;

  ReaderStateOut({
    required this.reader,
    required this.eventState,
    required this.eventCount,
    required this.atr,
  });

  factory ReaderStateOut.fromJson(Map<String, dynamic> json) {
    return ReaderStateOut(
      reader: json['reader'] as String,
      eventState: ReaderStateFlags.fromJson(
        json['eventState'] as Map<String, dynamic>,
      ),
      eventCount: json['eventCount'] as int,
      atr: json['atr'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reader': reader,
      'eventState': eventState.toJson(),
      'eventCount': eventCount,
      'atr': atr,
    };
  }
}
