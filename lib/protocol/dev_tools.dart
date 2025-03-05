import '../src/connection.dart';
import 'accessibility.dart';
import 'animation.dart';
import 'audits.dart';
import 'autofill.dart';
import 'background_service.dart';
import 'bluetooth_emulation.dart';
import 'browser.dart';
import 'cache_storage.dart';
import 'cast.dart';
import 'css.dart';
import 'debugger.dart';
import 'device_access.dart';
import 'device_orientation.dart';
import 'dom.dart';
import 'dom_debugger.dart';
import 'dom_snapshot.dart';
import 'dom_storage.dart';
import 'emulation.dart';
import 'event_breakpoints.dart';
import 'extensions.dart';
import 'fed_cm.dart';
import 'fetch.dart';
import 'file_system.dart';
import 'headless_experimental.dart';
import 'heap_profiler.dart';
import 'indexed_db.dart';
import 'input.dart';
import 'inspector.dart';
import 'io.dart';
import 'layer_tree.dart';
import 'log.dart';
import 'media.dart';
import 'memory.dart';
import 'network.dart';
import 'overlay.dart';
import 'page.dart';
import 'performance.dart';
import 'performance_timeline.dart';
import 'preload.dart';
import 'profiler.dart';
import 'pwa.dart';
import 'runtime.dart';
import 'security.dart';
import 'service_worker.dart';
import 'storage.dart';
import 'system_info.dart';
import 'target.dart';
import 'tethering.dart';
import 'tracing.dart';
import 'web_audio.dart';
import 'web_authn.dart';

class DevTools {
  final Client client;

  DevTools(this.client);

  AccessibilityApi get accessibility =>
      _accessibility ??= AccessibilityApi(client);
  AccessibilityApi? _accessibility;

  AnimationApi get animation => _animation ??= AnimationApi(client);
  AnimationApi? _animation;

  /// Audits domain allows investigation of page violations and possible improvements.
  AuditsApi get audits => _audits ??= AuditsApi(client);
  AuditsApi? _audits;

  /// Defines commands and events for browser extensions.
  ExtensionsApi get extensions => _extensions ??= ExtensionsApi(client);
  ExtensionsApi? _extensions;

  /// Defines commands and events for Autofill.
  AutofillApi get autofill => _autofill ??= AutofillApi(client);
  AutofillApi? _autofill;

  /// Defines events for background web platform features.
  BackgroundServiceApi get backgroundService =>
      _backgroundService ??= BackgroundServiceApi(client);
  BackgroundServiceApi? _backgroundService;

  /// The Browser domain defines methods and events for browser managing.
  BrowserApi get browser => _browser ??= BrowserApi(client);
  BrowserApi? _browser;

  /// This domain exposes CSS read/write operations. All CSS objects (stylesheets, rules, and styles)
  /// have an associated `id` used in subsequent operations on the related object. Each object type has
  /// a specific `id` structure, and those are not interchangeable between objects of different kinds.
  /// CSS objects can be loaded using the `get*ForNode()` calls (which accept a DOM node id). A client
  /// can also keep track of stylesheets via the `styleSheetAdded`/`styleSheetRemoved` events and
  /// subsequently load the required stylesheet contents using the `getStyleSheet[Text]()` methods.
  CSSApi get css => _css ??= CSSApi(client);
  CSSApi? _css;

  CacheStorageApi get cacheStorage => _cacheStorage ??= CacheStorageApi(client);
  CacheStorageApi? _cacheStorage;

  /// A domain for interacting with Cast, Presentation API, and Remote Playback API
  /// functionalities.
  CastApi get cast => _cast ??= CastApi(client);
  CastApi? _cast;

  /// This domain exposes DOM read/write operations. Each DOM Node is represented with its mirror object
  /// that has an `id`. This `id` can be used to get additional information on the Node, resolve it into
  /// the JavaScript object wrapper, etc. It is important that client receives DOM events only for the
  /// nodes that are known to the client. Backend keeps track of the nodes that were sent to the client
  /// and never sends the same node twice. It is client's responsibility to collect information about
  /// the nodes that were sent to the client. Note that `iframe` owner elements will return
  /// corresponding document elements as their child nodes.
  DOMApi get dom => _dom ??= DOMApi(client);
  DOMApi? _dom;

  /// DOM debugging allows setting breakpoints on particular DOM operations and events. JavaScript
  /// execution will stop on these operations as if there was a regular breakpoint set.
  DOMDebuggerApi get domDebugger => _domDebugger ??= DOMDebuggerApi(client);
  DOMDebuggerApi? _domDebugger;

  /// EventBreakpoints permits setting JavaScript breakpoints on operations and events
  /// occurring in native code invoked from JavaScript. Once breakpoint is hit, it is
  /// reported through Debugger domain, similarly to regular breakpoints being hit.
  EventBreakpointsApi get eventBreakpoints =>
      _eventBreakpoints ??= EventBreakpointsApi(client);
  EventBreakpointsApi? _eventBreakpoints;

  /// This domain facilitates obtaining document snapshots with DOM, layout, and style information.
  DOMSnapshotApi get domSnapshot => _domSnapshot ??= DOMSnapshotApi(client);
  DOMSnapshotApi? _domSnapshot;

  /// Query and modify DOM storage.
  DOMStorageApi get domStorage => _domStorage ??= DOMStorageApi(client);
  DOMStorageApi? _domStorage;

  DeviceOrientationApi get deviceOrientation =>
      _deviceOrientation ??= DeviceOrientationApi(client);
  DeviceOrientationApi? _deviceOrientation;

  /// This domain emulates different environments for the page.
  EmulationApi get emulation => _emulation ??= EmulationApi(client);
  EmulationApi? _emulation;

  /// This domain provides experimental commands only supported in headless mode.
  HeadlessExperimentalApi get headlessExperimental =>
      _headlessExperimental ??= HeadlessExperimentalApi(client);
  HeadlessExperimentalApi? _headlessExperimental;

  /// Input/Output operations for streams produced by DevTools.
  IOApi get io => _io ??= IOApi(client);
  IOApi? _io;

  FileSystemApi get fileSystem => _fileSystem ??= FileSystemApi(client);
  FileSystemApi? _fileSystem;

  IndexedDBApi get indexedDb => _indexedDb ??= IndexedDBApi(client);
  IndexedDBApi? _indexedDb;

  InputApi get input => _input ??= InputApi(client);
  InputApi? _input;

  InspectorApi get inspector => _inspector ??= InspectorApi(client);
  InspectorApi? _inspector;

  LayerTreeApi get layerTree => _layerTree ??= LayerTreeApi(client);
  LayerTreeApi? _layerTree;

  /// Provides access to log entries.
  LogApi get log => _log ??= LogApi(client);
  LogApi? _log;

  MemoryApi get memory => _memory ??= MemoryApi(client);
  MemoryApi? _memory;

  /// Network domain allows tracking network activities of the page. It exposes information about http,
  /// file, data and other requests and responses, their headers, bodies, timing, etc.
  NetworkApi get network => _network ??= NetworkApi(client);
  NetworkApi? _network;

  /// This domain provides various functionality related to drawing atop the inspected page.
  OverlayApi get overlay => _overlay ??= OverlayApi(client);
  OverlayApi? _overlay;

  /// Actions and events related to the inspected page belong to the page domain.
  PageApi get page => _page ??= PageApi(client);
  PageApi? _page;

  PerformanceApi get performance => _performance ??= PerformanceApi(client);
  PerformanceApi? _performance;

  /// Reporting of performance timeline events, as specified in
  /// https://w3c.github.io/performance-timeline/#dom-performanceobserver.
  PerformanceTimelineApi get performanceTimeline =>
      _performanceTimeline ??= PerformanceTimelineApi(client);
  PerformanceTimelineApi? _performanceTimeline;

  /// Security
  SecurityApi get security => _security ??= SecurityApi(client);
  SecurityApi? _security;

  ServiceWorkerApi get serviceWorker =>
      _serviceWorker ??= ServiceWorkerApi(client);
  ServiceWorkerApi? _serviceWorker;

  StorageApi get storage => _storage ??= StorageApi(client);
  StorageApi? _storage;

  /// The SystemInfo domain defines methods and events for querying low-level system information.
  SystemInfoApi get systemInfo => _systemInfo ??= SystemInfoApi(client);
  SystemInfoApi? _systemInfo;

  /// Supports additional targets discovery and allows to attach to them.
  TargetApi get target => _target ??= TargetApi(client);
  TargetApi? _target;

  /// The Tethering domain defines methods and events for browser port binding.
  TetheringApi get tethering => _tethering ??= TetheringApi(client);
  TetheringApi? _tethering;

  TracingApi get tracing => _tracing ??= TracingApi(client);
  TracingApi? _tracing;

  /// A domain for letting clients substitute browser's network layer with client code.
  FetchApi get fetch => _fetch ??= FetchApi(client);
  FetchApi? _fetch;

  /// This domain allows inspection of Web Audio API.
  /// https://webaudio.github.io/web-audio-api/
  WebAudioApi get webAudio => _webAudio ??= WebAudioApi(client);
  WebAudioApi? _webAudio;

  /// This domain allows configuring virtual authenticators to test the WebAuthn
  /// API.
  WebAuthnApi get webAuthn => _webAuthn ??= WebAuthnApi(client);
  WebAuthnApi? _webAuthn;

  /// This domain allows detailed inspection of media elements
  MediaApi get media => _media ??= MediaApi(client);
  MediaApi? _media;

  DeviceAccessApi get deviceAccess => _deviceAccess ??= DeviceAccessApi(client);
  DeviceAccessApi? _deviceAccess;

  PreloadApi get preload => _preload ??= PreloadApi(client);
  PreloadApi? _preload;

  /// This domain allows interacting with the FedCM dialog.
  FedCmApi get fedCm => _fedCm ??= FedCmApi(client);
  FedCmApi? _fedCm;

  /// This domain allows interacting with the browser to control PWAs.
  PWAApi get pwa => _pwa ??= PWAApi(client);
  PWAApi? _pwa;

  /// This domain allows configuring virtual Bluetooth devices to test
  /// the web-bluetooth API.
  BluetoothEmulationApi get bluetoothEmulation =>
      _bluetoothEmulation ??= BluetoothEmulationApi(client);
  BluetoothEmulationApi? _bluetoothEmulation;

  /// Debugger domain exposes JavaScript debugging capabilities. It allows setting and removing
  /// breakpoints, stepping through execution, exploring stack traces, etc.
  DebuggerApi get debugger => _debugger ??= DebuggerApi(client);
  DebuggerApi? _debugger;

  HeapProfilerApi get heapProfiler => _heapProfiler ??= HeapProfilerApi(client);
  HeapProfilerApi? _heapProfiler;

  ProfilerApi get profiler => _profiler ??= ProfilerApi(client);
  ProfilerApi? _profiler;

  /// Runtime domain exposes JavaScript runtime by means of remote evaluation and mirror objects.
  /// Evaluation results are returned as mirror object that expose object type, string representation
  /// and unique identifier that can be used for further object reference. Original objects are
  /// maintained in memory unless they are either explicitly released or are released along with the
  /// other objects in their object group.
  RuntimeApi get runtime => _runtime ??= RuntimeApi(client);
  RuntimeApi? _runtime;
}
