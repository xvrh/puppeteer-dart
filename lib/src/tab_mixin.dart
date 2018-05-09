import '../domains/accessibility.dart';
import '../domains/animation.dart';
import '../domains/application_cache.dart';
import '../domains/css.dart';
import '../domains/cache_storage.dart';
import '../domains/dom.dart';
import '../domains/dom_debugger.dart';
import '../domains/dom_snapshot.dart';
import '../domains/dom_storage.dart';
import '../domains/database.dart';
import '../domains/device_orientation.dart';
import '../domains/emulation.dart';
import '../domains/headless_experimental.dart';
import '../domains/indexed_db.dart';
import '../domains/input.dart';
import '../domains/inspector.dart';
import '../domains/layer_tree.dart';
import '../domains/log.dart';
import '../domains/memory.dart';
import '../domains/network.dart';
import '../domains/overlay.dart';
import '../domains/page.dart';
import '../domains/performance.dart';
import '../domains/security.dart';
import '../domains/service_worker.dart';
import '../domains/storage.dart';
import '../domains/tethering.dart';
import '../domains/tracing.dart';
import '../domains/debugger.dart';
import '../domains/heap_profiler.dart';
import '../domains/profiler.dart';
import '../domains/runtime.dart';
import 'connection.dart';

abstract class TabMixin {
  Session get session;

  AccessibilityApi get accessibility =>
      _accessibility ??= new AccessibilityApi(session);
  AccessibilityApi _accessibility;

  AnimationApi get animation => _animation ??= new AnimationApi(session);
  AnimationApi _animation;

  ApplicationCacheApi get applicationCache =>
      _applicationCache ??= new ApplicationCacheApi(session);
  ApplicationCacheApi _applicationCache;

  /// This domain exposes CSS read/write operations. All CSS objects (stylesheets, rules, and styles)
  /// have an associated `id` used in subsequent operations on the related object. Each object type has
  /// a specific `id` structure, and those are not interchangeable between objects of different kinds.
  /// CSS objects can be loaded using the `get*ForNode()` calls (which accept a DOM node id). A client
  /// can also keep track of stylesheets via the `styleSheetAdded`/`styleSheetRemoved` events and
  /// subsequently load the required stylesheet contents using the `getStyleSheet[Text]()` methods.
  CSSApi get css => _css ??= new CSSApi(session);
  CSSApi _css;

  CacheStorageApi get cacheStorage =>
      _cacheStorage ??= new CacheStorageApi(session);
  CacheStorageApi _cacheStorage;

  /// This domain exposes DOM read/write operations. Each DOM Node is represented with its mirror object
  /// that has an `id`. This `id` can be used to get additional information on the Node, resolve it into
  /// the JavaScript object wrapper, etc. It is important that client receives DOM events only for the
  /// nodes that are known to the client. Backend keeps track of the nodes that were sent to the client
  /// and never sends the same node twice. It is client's responsibility to collect information about
  /// the nodes that were sent to the client.<p>Note that `iframe` owner elements will return
  /// corresponding document elements as their child nodes.</p>
  DOMApi get dom => _dom ??= new DOMApi(session);
  DOMApi _dom;

  /// DOM debugging allows setting breakpoints on particular DOM operations and events. JavaScript
  /// execution will stop on these operations as if there was a regular breakpoint set.
  DOMDebuggerApi get domDebugger =>
      _domDebugger ??= new DOMDebuggerApi(session);
  DOMDebuggerApi _domDebugger;

  /// This domain facilitates obtaining document snapshots with DOM, layout, and style information.
  DOMSnapshotApi get domSnapshot =>
      _domSnapshot ??= new DOMSnapshotApi(session);
  DOMSnapshotApi _domSnapshot;

  /// Query and modify DOM storage.
  DOMStorageApi get domStorage => _domStorage ??= new DOMStorageApi(session);
  DOMStorageApi _domStorage;

  DatabaseApi get database => _database ??= new DatabaseApi(session);
  DatabaseApi _database;

  DeviceOrientationApi get deviceOrientation =>
      _deviceOrientation ??= new DeviceOrientationApi(session);
  DeviceOrientationApi _deviceOrientation;

  /// This domain emulates different environments for the page.
  EmulationApi get emulation => _emulation ??= new EmulationApi(session);
  EmulationApi _emulation;

  /// This domain provides experimental commands only supported in headless mode.
  HeadlessExperimentalApi get headlessExperimental =>
      _headlessExperimental ??= new HeadlessExperimentalApi(session);
  HeadlessExperimentalApi _headlessExperimental;

  IndexedDBApi get indexedDb => _indexedDb ??= new IndexedDBApi(session);
  IndexedDBApi _indexedDb;

  InputApi get input => _input ??= new InputApi(session);
  InputApi _input;

  InspectorApi get inspector => _inspector ??= new InspectorApi(session);
  InspectorApi _inspector;

  LayerTreeApi get layerTree => _layerTree ??= new LayerTreeApi(session);
  LayerTreeApi _layerTree;

  /// Provides access to log entries.
  LogApi get log => _log ??= new LogApi(session);
  LogApi _log;

  MemoryApi get memory => _memory ??= new MemoryApi(session);
  MemoryApi _memory;

  /// Network domain allows tracking network activities of the page. It exposes information about http,
  /// file, data and other requests and responses, their headers, bodies, timing, etc.
  NetworkApi get network => _network ??= new NetworkApi(session);
  NetworkApi _network;

  /// This domain provides various functionality related to drawing atop the inspected page.
  OverlayApi get overlay => _overlay ??= new OverlayApi(session);
  OverlayApi _overlay;

  /// Actions and events related to the inspected page belong to the page domain.
  PageApi get page => _page ??= new PageApi(session);
  PageApi _page;

  PerformanceApi get performance =>
      _performance ??= new PerformanceApi(session);
  PerformanceApi _performance;

  /// Security
  SecurityApi get security => _security ??= new SecurityApi(session);
  SecurityApi _security;

  ServiceWorkerApi get serviceWorker =>
      _serviceWorker ??= new ServiceWorkerApi(session);
  ServiceWorkerApi _serviceWorker;

  StorageApi get storage => _storage ??= new StorageApi(session);
  StorageApi _storage;

  /// The Tethering domain defines methods and events for browser port binding.
  TetheringApi get tethering => _tethering ??= new TetheringApi(session);
  TetheringApi _tethering;

  TracingApi get tracing => _tracing ??= new TracingApi(session);
  TracingApi _tracing;

  /// Debugger domain exposes JavaScript debugging capabilities. It allows setting and removing
  /// breakpoints, stepping through execution, exploring stack traces, etc.
  DebuggerApi get debugger => _debugger ??= new DebuggerApi(session);
  DebuggerApi _debugger;

  HeapProfilerApi get heapProfiler =>
      _heapProfiler ??= new HeapProfilerApi(session);
  HeapProfilerApi _heapProfiler;

  ProfilerApi get profiler => _profiler ??= new ProfilerApi(session);
  ProfilerApi _profiler;

  /// Runtime domain exposes JavaScript runtime by means of remote evaluation and mirror objects.
  /// Evaluation results are returned as mirror object that expose object type, string representation
  /// and unique identifier that can be used for further object reference. Original objects are
  /// maintained in memory unless they are either explicitly released or are released along with the
  /// other objects in their object group.
  RuntimeApi get runtime => _runtime ??= new RuntimeApi(session);
  RuntimeApi _runtime;
}
