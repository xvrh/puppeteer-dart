import 'dart:async';
import '../src/connection.dart';

/// EventBreakpoints permits setting JavaScript breakpoints on operations and events
/// occurring in native code invoked from JavaScript. Once breakpoint is hit, it is
/// reported through Debugger domain, similarly to regular breakpoints being hit.
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

  /// Removes all breakpoints
  Future<void> disable() async {
    await _client.send('EventBreakpoints.disable');
  }
}
