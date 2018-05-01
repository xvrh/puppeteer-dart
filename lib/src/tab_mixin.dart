import '../domains/inspector.dart';
import '../domains/memory.dart';
import '../domains/performance.dart';
import '../domains/page.dart';
import '../domains/overlay.dart';
import '../domains/emulation.dart';
import '../domains/security.dart';
import '../domains/network.dart';
import '../domains/database.dart';
import '../domains/indexed_db.dart';
import '../domains/cache_storage.dart';
import '../domains/dom_storage.dart';
import '../domains/application_cache.dart';
import '../domains/dom.dart';
import '../domains/css.dart';
import '../domains/dom_snapshot.dart';
import '../domains/dom_debugger.dart';
import '../domains/headless_experimental.dart';
import '../domains/service_worker.dart';
import '../domains/input.dart';
import '../domains/layer_tree.dart';
import '../domains/device_orientation.dart';
import '../domains/tracing.dart';
import '../domains/animation.dart';
import '../domains/accessibility.dart';
import '../domains/storage.dart';
import '../domains/log.dart';
import '../domains/tethering.dart';
import '../domains/debugger.dart';
import '../domains/heap_profiler.dart';
import '../domains/profiler.dart';
import '../domains/runtime.dart';
import 'connection.dart';

abstract class TabMixin {
  Session get session;

  InspectorManager get inspector =>
      _inspector ??= new InspectorManager(session);
  InspectorManager _inspector;

  MemoryManager get memory => _memory ??= new MemoryManager(session);
  MemoryManager _memory;

  PerformanceManager get performance =>
      _performance ??= new PerformanceManager(session);
  PerformanceManager _performance;

  /// Actions and events related to the inspected page belong to the page
  /// domain.
  PageManager get page => _page ??= new PageManager(session);
  PageManager _page;

  /// This domain provides various functionality related to drawing atop the
  /// inspected page.
  OverlayManager get overlay => _overlay ??= new OverlayManager(session);
  OverlayManager _overlay;

  /// This domain emulates different environments for the page.
  EmulationManager get emulation =>
      _emulation ??= new EmulationManager(session);
  EmulationManager _emulation;

  /// Security
  SecurityManager get security => _security ??= new SecurityManager(session);
  SecurityManager _security;

  /// Network domain allows tracking network activities of the page. It exposes
  /// information about http, file, data and other requests and responses, their
  /// headers, bodies, timing, etc.
  NetworkManager get network => _network ??= new NetworkManager(session);
  NetworkManager _network;

  DatabaseManager get database => _database ??= new DatabaseManager(session);
  DatabaseManager _database;

  IndexedDBManager get indexedDb =>
      _indexedDb ??= new IndexedDBManager(session);
  IndexedDBManager _indexedDb;

  CacheStorageManager get cacheStorage =>
      _cacheStorage ??= new CacheStorageManager(session);
  CacheStorageManager _cacheStorage;

  /// Query and modify DOM storage.
  DOMStorageManager get domStorage =>
      _domStorage ??= new DOMStorageManager(session);
  DOMStorageManager _domStorage;

  ApplicationCacheManager get applicationCache =>
      _applicationCache ??= new ApplicationCacheManager(session);
  ApplicationCacheManager _applicationCache;

  /// This domain exposes DOM read/write operations. Each DOM Node is
  /// represented with its mirror object that has an `id`. This `id` can be used
  /// to get additional information on the Node, resolve it into the JavaScript
  /// object wrapper, etc. It is important that client receives DOM events only
  /// for the nodes that are known to the client. Backend keeps track of the
  /// nodes that were sent to the client and never sends the same node twice. It
  /// is client's responsibility to collect information about the nodes that
  /// were sent to the client.<p>Note that `iframe` owner elements will return
  /// corresponding document elements as their child nodes.</p>
  DOMManager get dom => _dom ??= new DOMManager(session);
  DOMManager _dom;

  /// This domain exposes CSS read/write operations. All CSS objects
  /// (stylesheets, rules, and styles) have an associated `id` used in
  /// subsequent operations on the related object. Each object type has a
  /// specific `id` structure, and those are not interchangeable between objects
  /// of different kinds. CSS objects can be loaded using the `get*ForNode()`
  /// calls (which accept a DOM node id). A client can also keep track of
  /// stylesheets via the `styleSheetAdded`/`styleSheetRemoved` events and
  /// subsequently load the required stylesheet contents using the
  /// `getStyleSheet[Text]()` methods.
  CSSManager get css => _css ??= new CSSManager(session);
  CSSManager _css;

  /// This domain facilitates obtaining document snapshots with DOM, layout, and
  /// style information.
  DOMSnapshotManager get domSnapshot =>
      _domSnapshot ??= new DOMSnapshotManager(session);
  DOMSnapshotManager _domSnapshot;

  /// DOM debugging allows setting breakpoints on particular DOM operations and
  /// events. JavaScript execution will stop on these operations as if there was
  /// a regular breakpoint set.
  DOMDebuggerManager get domDebugger =>
      _domDebugger ??= new DOMDebuggerManager(session);
  DOMDebuggerManager _domDebugger;

  /// This domain provides experimental commands only supported in headless
  /// mode.
  HeadlessExperimentalManager get headlessExperimental =>
      _headlessExperimental ??= new HeadlessExperimentalManager(session);
  HeadlessExperimentalManager _headlessExperimental;

  ServiceWorkerManager get serviceWorker =>
      _serviceWorker ??= new ServiceWorkerManager(session);
  ServiceWorkerManager _serviceWorker;

  InputManager get input => _input ??= new InputManager(session);
  InputManager _input;

  LayerTreeManager get layerTree =>
      _layerTree ??= new LayerTreeManager(session);
  LayerTreeManager _layerTree;

  DeviceOrientationManager get deviceOrientation =>
      _deviceOrientation ??= new DeviceOrientationManager(session);
  DeviceOrientationManager _deviceOrientation;

  TracingManager get tracing => _tracing ??= new TracingManager(session);
  TracingManager _tracing;

  AnimationManager get animation =>
      _animation ??= new AnimationManager(session);
  AnimationManager _animation;

  AccessibilityManager get accessibility =>
      _accessibility ??= new AccessibilityManager(session);
  AccessibilityManager _accessibility;

  StorageManager get storage => _storage ??= new StorageManager(session);
  StorageManager _storage;

  /// Provides access to log entries.
  LogManager get log => _log ??= new LogManager(session);
  LogManager _log;

  /// The Tethering domain defines methods and events for browser port binding.
  TetheringManager get tethering =>
      _tethering ??= new TetheringManager(session);
  TetheringManager _tethering;

  /// Debugger domain exposes JavaScript debugging capabilities. It allows
  /// setting and removing
  /// breakpoints, stepping through execution, exploring stack traces, etc.
  DebuggerManager get debugger => _debugger ??= new DebuggerManager(session);
  DebuggerManager _debugger;

  HeapProfilerManager get heapProfiler =>
      _heapProfiler ??= new HeapProfilerManager(session);
  HeapProfilerManager _heapProfiler;

  ProfilerManager get profiler => _profiler ??= new ProfilerManager(session);
  ProfilerManager _profiler;

  /// Runtime domain exposes JavaScript runtime by means of remote evaluation
  /// and mirror objects.
  /// Evaluation results are returned as mirror object that expose object type,
  /// string representation
  /// and unique identifier that can be used for further object reference.
  /// Original objects are
  /// maintained in memory unless they are either explicitly released or are
  /// released along with the
  /// other objects in their object group.
  RuntimeManager get runtime => _runtime ??= new RuntimeManager(session);
  RuntimeManager _runtime;
}
