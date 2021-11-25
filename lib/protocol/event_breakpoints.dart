import 'dart:async';
import '../src/connection.dart';

/// EventBreakpoints permits setting breakpoints on particular operations and
/// events in targets that run JavaScript but do not have a DOM.
/// JavaScript execution will stop on these operations as if there was a regular
/// breakpoint set.
class EventBreakpointsApi {
  final Client _client;

  EventBreakpointsApi(this._client);

  /// Sets breakpoint on particular native event.
  /// [eventName] Instrumentation name to stop on.
  Future<void> setInstrumentationBreakpoint(String eventName) async {
    await _client.send('EventBreakpoints.setInstrumentationBreakpoint', {
      'eventName': eventName,
    });
  }

  /// Removes breakpoint on particular native event.
  /// [eventName] Instrumentation name to stop on.
  Future<void> removeInstrumentationBreakpoint(String eventName) async {
    await _client.send('EventBreakpoints.removeInstrumentationBreakpoint', {
      'eventName': eventName,
    });
  }
}
