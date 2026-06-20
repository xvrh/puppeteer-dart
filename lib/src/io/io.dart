/// Conditional `dart:io` shim.
///
/// On native platforms this re-exports the real `dart:io`, so the public API is
/// byte-for-byte identical (`File`, `IOSink`, `Process`, ... are the genuine
/// `dart:io` types). On the web/WASM compilation targets — where `dart:io`
/// would make the package non-WASM-compatible — it resolves to [io_stub.dart],
/// which provides the same surface but throws `UnsupportedError` for anything
/// that needs a filesystem or a process. `puppeteer.connect()` and page
/// interaction over the DevTools websocket work; `puppeteer.launch()` and the
/// `File`/`IOSink` convenience overloads do not.
library;

export 'io_native.dart' if (dart.library.js_interop) 'io_stub.dart';
