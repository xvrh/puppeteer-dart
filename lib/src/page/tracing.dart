import 'dart:async';
import '../../protocol/dev_tools.dart';
import '../../protocol/io.dart';

/// You can use [tracing.start] and [tracing.stop] to create a trace file which
/// can be opened in Chrome DevTools or [timeline viewer](https://chromedevtools.github.io/timeline-viewer/).
///
/// ```dart
/// await page.tracing.start();
/// await page.goto('https://www.google.com');
/// await page.tracing.stop(File('trace.json').openWrite());
/// ```
class Tracing {
  final DevTools _devTools;
  bool _recording = false;

  Tracing(this._devTools);

  /// Only one trace can be active at a time per browser.
  ///
  ///
  /// Parameters:
  //  - `screenshots`: captures screenshots in the trace.
  //  - `categories`: specify custom categories to use instead of default.
  Future<void> start({bool? screenshots, List<String>? categories}) async {
    if (_recording) {
      throw Exception(
          'Cannot start recording trace while already recording trace.');
    }
    screenshots ??= false;

    const defaultCategories = [
      '-*',
      'devtools.timeline',
      'v8.execute',
      'disabled-by-default-devtools.timeline',
      'disabled-by-default-devtools.timeline.frame',
      'toplevel',
      'blink.console',
      'blink.user_timing',
      'latencyInfo',
      'disabled-by-default-devtools.timeline.stack',
      'disabled-by-default-v8.cpu_profiler',
      'disabled-by-default-v8.cpu_profiler.hires'
    ];

    categories ??= defaultCategories.toList();

    if (screenshots) {
      categories.add('disabled-by-default-devtools.screenshot');
    }

    _recording = true;
    await _devTools.tracing.start(
        transferMode: 'ReturnAsStream',
        //TODO(xha): use the new api
        // ignore: deprecated_member_use_from_same_package
        categories: categories.join(','));
  }

  /// Promise which resolves to buffer with trace data.
  Future<void> stop(StringSink output) async {
    var contentFuture = _devTools.tracing.onTracingComplete.first
        .then((e) => _readStream(e.stream!, output));
    await _devTools.tracing.end();

    _recording = false;
    return contentFuture;
  }

  Future<void> _readStream(StreamHandle handle, StringSink output) async {
    ReadResult result;
    do {
      result = await _devTools.io.read(handle);
      output.write(result.data);
    } while (!result.eof);
    await _devTools.io.close(handle);
  }
}
