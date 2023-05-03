import 'dart:async';
import '../src/connection.dart';
import 'dom.dart' as dom;
import 'network.dart' as network;
import 'page.dart' as page;

class PreloadApi {
  final Client _client;

  PreloadApi(this._client);

  /// Upsert. Currently, it is only emitted when a rule set added.
  Stream<RuleSet> get onRuleSetUpdated => _client.onEvent
      .where((event) => event.name == 'Preload.ruleSetUpdated')
      .map((event) => RuleSet.fromJson(
          event.parameters['ruleSet'] as Map<String, dynamic>));

  Stream<RuleSetId> get onRuleSetRemoved => _client.onEvent
      .where((event) => event.name == 'Preload.ruleSetRemoved')
      .map((event) => RuleSetId.fromJson(event.parameters['id'] as String));

  /// Fired when a prerender attempt is completed.
  Stream<PrerenderAttemptCompletedEvent> get onPrerenderAttemptCompleted =>
      _client.onEvent
          .where((event) => event.name == 'Preload.prerenderAttemptCompleted')
          .map((event) =>
              PrerenderAttemptCompletedEvent.fromJson(event.parameters));

  /// Fired when a prefetch attempt is updated.
  Stream<PrefetchStatusUpdatedEvent> get onPrefetchStatusUpdated => _client
      .onEvent
      .where((event) => event.name == 'Preload.prefetchStatusUpdated')
      .map((event) => PrefetchStatusUpdatedEvent.fromJson(event.parameters));

  /// Fired when a prerender attempt is updated.
  Stream<PrerenderStatusUpdatedEvent> get onPrerenderStatusUpdated => _client
      .onEvent
      .where((event) => event.name == 'Preload.prerenderStatusUpdated')
      .map((event) => PrerenderStatusUpdatedEvent.fromJson(event.parameters));

  /// Send a list of sources for all preloading attempts in a document.
  Stream<PreloadingAttemptSourcesUpdatedEvent>
      get onPreloadingAttemptSourcesUpdated => _client.onEvent
          .where((event) =>
              event.name == 'Preload.preloadingAttemptSourcesUpdated')
          .map((event) =>
              PreloadingAttemptSourcesUpdatedEvent.fromJson(event.parameters));

  Future<void> enable() async {
    await _client.send('Preload.enable');
  }

  Future<void> disable() async {
    await _client.send('Preload.disable');
  }
}

class PrerenderAttemptCompletedEvent {
  final PreloadingAttemptKey key;

  /// The frame id of the frame initiating prerendering.
  final page.FrameId initiatingFrameId;

  final String prerenderingUrl;

  final PrerenderFinalStatus finalStatus;

  /// This is used to give users more information about the name of the API call
  /// that is incompatible with prerender and has caused the cancellation of the attempt
  final String? disallowedApiMethod;

  PrerenderAttemptCompletedEvent(
      {required this.key,
      required this.initiatingFrameId,
      required this.prerenderingUrl,
      required this.finalStatus,
      this.disallowedApiMethod});

  factory PrerenderAttemptCompletedEvent.fromJson(Map<String, dynamic> json) {
    return PrerenderAttemptCompletedEvent(
      key: PreloadingAttemptKey.fromJson(json['key'] as Map<String, dynamic>),
      initiatingFrameId:
          page.FrameId.fromJson(json['initiatingFrameId'] as String),
      prerenderingUrl: json['prerenderingUrl'] as String,
      finalStatus: PrerenderFinalStatus.fromJson(json['finalStatus'] as String),
      disallowedApiMethod: json.containsKey('disallowedApiMethod')
          ? json['disallowedApiMethod'] as String
          : null,
    );
  }
}

class PrefetchStatusUpdatedEvent {
  final PreloadingAttemptKey key;

  /// The frame id of the frame initiating prefetch.
  final page.FrameId initiatingFrameId;

  final String prefetchUrl;

  final PreloadingStatus status;

  PrefetchStatusUpdatedEvent(
      {required this.key,
      required this.initiatingFrameId,
      required this.prefetchUrl,
      required this.status});

  factory PrefetchStatusUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return PrefetchStatusUpdatedEvent(
      key: PreloadingAttemptKey.fromJson(json['key'] as Map<String, dynamic>),
      initiatingFrameId:
          page.FrameId.fromJson(json['initiatingFrameId'] as String),
      prefetchUrl: json['prefetchUrl'] as String,
      status: PreloadingStatus.fromJson(json['status'] as String),
    );
  }
}

class PrerenderStatusUpdatedEvent {
  final PreloadingAttemptKey key;

  /// The frame id of the frame initiating prerender.
  final page.FrameId initiatingFrameId;

  final String prerenderingUrl;

  final PreloadingStatus status;

  PrerenderStatusUpdatedEvent(
      {required this.key,
      required this.initiatingFrameId,
      required this.prerenderingUrl,
      required this.status});

  factory PrerenderStatusUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return PrerenderStatusUpdatedEvent(
      key: PreloadingAttemptKey.fromJson(json['key'] as Map<String, dynamic>),
      initiatingFrameId:
          page.FrameId.fromJson(json['initiatingFrameId'] as String),
      prerenderingUrl: json['prerenderingUrl'] as String,
      status: PreloadingStatus.fromJson(json['status'] as String),
    );
  }
}

class PreloadingAttemptSourcesUpdatedEvent {
  final network.LoaderId loaderId;

  final List<PreloadingAttemptSource> preloadingAttemptSources;

  PreloadingAttemptSourcesUpdatedEvent(
      {required this.loaderId, required this.preloadingAttemptSources});

  factory PreloadingAttemptSourcesUpdatedEvent.fromJson(
      Map<String, dynamic> json) {
    return PreloadingAttemptSourcesUpdatedEvent(
      loaderId: network.LoaderId.fromJson(json['loaderId'] as String),
      preloadingAttemptSources: (json['preloadingAttemptSources'] as List)
          .map((e) =>
              PreloadingAttemptSource.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Unique id
class RuleSetId {
  final String value;

  RuleSetId(this.value);

  factory RuleSetId.fromJson(String value) => RuleSetId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is RuleSetId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Corresponds to SpeculationRuleSet
class RuleSet {
  final RuleSetId id;

  /// Identifies a document which the rule set is associated with.
  final network.LoaderId loaderId;

  /// Source text of JSON representing the rule set. If it comes from
  /// <script> tag, it is the textContent of the node. Note that it is
  /// a JSON for valid case.
  ///
  /// See also:
  /// - https://wicg.github.io/nav-speculation/speculation-rules.html
  /// - https://github.com/WICG/nav-speculation/blob/main/triggers.md
  final String sourceText;

  /// Error information
  /// `errorMessage` is null iff `errorType` is null.
  final RuleSetErrorType? errorType;

  RuleSet(
      {required this.id,
      required this.loaderId,
      required this.sourceText,
      this.errorType});

  factory RuleSet.fromJson(Map<String, dynamic> json) {
    return RuleSet(
      id: RuleSetId.fromJson(json['id'] as String),
      loaderId: network.LoaderId.fromJson(json['loaderId'] as String),
      sourceText: json['sourceText'] as String,
      errorType: json.containsKey('errorType')
          ? RuleSetErrorType.fromJson(json['errorType'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toJson(),
      'loaderId': loaderId.toJson(),
      'sourceText': sourceText,
      if (errorType != null) 'errorType': errorType!.toJson(),
    };
  }
}

enum RuleSetErrorType {
  sourceIsNotJsonObject('SourceIsNotJsonObject'),
  invalidRulesSkipped('InvalidRulesSkipped'),
  ;

  final String value;

  const RuleSetErrorType(this.value);

  factory RuleSetErrorType.fromJson(String value) =>
      RuleSetErrorType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// The type of preloading attempted. It corresponds to
/// mojom::SpeculationAction (although PrefetchWithSubresources is omitted as it
/// isn't being used by clients).
enum SpeculationAction {
  prefetch('Prefetch'),
  prerender('Prerender'),
  ;

  final String value;

  const SpeculationAction(this.value);

  factory SpeculationAction.fromJson(String value) =>
      SpeculationAction.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Corresponds to mojom::SpeculationTargetHint.
/// See https://github.com/WICG/nav-speculation/blob/main/triggers.md#window-name-targeting-hints
enum SpeculationTargetHint {
  blank('Blank'),
  self('Self'),
  ;

  final String value;

  const SpeculationTargetHint(this.value);

  factory SpeculationTargetHint.fromJson(String value) =>
      SpeculationTargetHint.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// A key that identifies a preloading attempt.
///
/// The url used is the url specified by the trigger (i.e. the initial URL), and
/// not the final url that is navigated to. For example, prerendering allows
/// same-origin main frame navigations during the attempt, but the attempt is
/// still keyed with the initial URL.
class PreloadingAttemptKey {
  final network.LoaderId loaderId;

  final SpeculationAction action;

  final String url;

  final SpeculationTargetHint? targetHint;

  PreloadingAttemptKey(
      {required this.loaderId,
      required this.action,
      required this.url,
      this.targetHint});

  factory PreloadingAttemptKey.fromJson(Map<String, dynamic> json) {
    return PreloadingAttemptKey(
      loaderId: network.LoaderId.fromJson(json['loaderId'] as String),
      action: SpeculationAction.fromJson(json['action'] as String),
      url: json['url'] as String,
      targetHint: json.containsKey('targetHint')
          ? SpeculationTargetHint.fromJson(json['targetHint'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loaderId': loaderId.toJson(),
      'action': action.toJson(),
      'url': url,
      if (targetHint != null) 'targetHint': targetHint!.toJson(),
    };
  }
}

/// Lists sources for a preloading attempt, specifically the ids of rule sets
/// that had a speculation rule that triggered the attempt, and the
/// BackendNodeIds of <a href> or <area href> elements that triggered the
/// attempt (in the case of attempts triggered by a document rule). It is
/// possible for mulitple rule sets and links to trigger a single attempt.
class PreloadingAttemptSource {
  final PreloadingAttemptKey key;

  final List<RuleSetId> ruleSetIds;

  final List<dom.BackendNodeId> nodeIds;

  PreloadingAttemptSource(
      {required this.key, required this.ruleSetIds, required this.nodeIds});

  factory PreloadingAttemptSource.fromJson(Map<String, dynamic> json) {
    return PreloadingAttemptSource(
      key: PreloadingAttemptKey.fromJson(json['key'] as Map<String, dynamic>),
      ruleSetIds: (json['ruleSetIds'] as List)
          .map((e) => RuleSetId.fromJson(e as String))
          .toList(),
      nodeIds: (json['nodeIds'] as List)
          .map((e) => dom.BackendNodeId.fromJson(e as int))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key.toJson(),
      'ruleSetIds': ruleSetIds.map((e) => e.toJson()).toList(),
      'nodeIds': nodeIds.map((e) => e.toJson()).toList(),
    };
  }
}

/// List of FinalStatus reasons for Prerender2.
enum PrerenderFinalStatus {
  activated('Activated'),
  destroyed('Destroyed'),
  lowEndDevice('LowEndDevice'),
  invalidSchemeRedirect('InvalidSchemeRedirect'),
  invalidSchemeNavigation('InvalidSchemeNavigation'),
  inProgressNavigation('InProgressNavigation'),
  navigationRequestBlockedByCsp('NavigationRequestBlockedByCsp'),
  mainFrameNavigation('MainFrameNavigation'),
  mojoBinderPolicy('MojoBinderPolicy'),
  rendererProcessCrashed('RendererProcessCrashed'),
  rendererProcessKilled('RendererProcessKilled'),
  download('Download'),
  triggerDestroyed('TriggerDestroyed'),
  navigationNotCommitted('NavigationNotCommitted'),
  navigationBadHttpStatus('NavigationBadHttpStatus'),
  clientCertRequested('ClientCertRequested'),
  navigationRequestNetworkError('NavigationRequestNetworkError'),
  maxNumOfRunningPrerendersExceeded('MaxNumOfRunningPrerendersExceeded'),
  cancelAllHostsForTesting('CancelAllHostsForTesting'),
  didFailLoad('DidFailLoad'),
  stop('Stop'),
  sslCertificateError('SslCertificateError'),
  loginAuthRequested('LoginAuthRequested'),
  uaChangeRequiresReload('UaChangeRequiresReload'),
  blockedByClient('BlockedByClient'),
  audioOutputDeviceRequested('AudioOutputDeviceRequested'),
  mixedContent('MixedContent'),
  triggerBackgrounded('TriggerBackgrounded'),
  embedderTriggeredAndCrossOriginRedirected(
      'EmbedderTriggeredAndCrossOriginRedirected'),
  memoryLimitExceeded('MemoryLimitExceeded'),
  failToGetMemoryUsage('FailToGetMemoryUsage'),
  dataSaverEnabled('DataSaverEnabled'),
  hasEffectiveUrl('HasEffectiveUrl'),
  activatedBeforeStarted('ActivatedBeforeStarted'),
  inactivePageRestriction('InactivePageRestriction'),
  startFailed('StartFailed'),
  timeoutBackgrounded('TimeoutBackgrounded'),
  crossSiteRedirectInInitialNavigation('CrossSiteRedirectInInitialNavigation'),
  crossSiteNavigationInInitialNavigation(
      'CrossSiteNavigationInInitialNavigation'),
  sameSiteCrossOriginRedirectNotOptInInInitialNavigation(
      'SameSiteCrossOriginRedirectNotOptInInInitialNavigation'),
  sameSiteCrossOriginNavigationNotOptInInInitialNavigation(
      'SameSiteCrossOriginNavigationNotOptInInInitialNavigation'),
  activationNavigationParameterMismatch(
      'ActivationNavigationParameterMismatch'),
  activatedInBackground('ActivatedInBackground'),
  embedderHostDisallowed('EmbedderHostDisallowed'),
  activationNavigationDestroyedBeforeSuccess(
      'ActivationNavigationDestroyedBeforeSuccess'),
  tabClosedByUserGesture('TabClosedByUserGesture'),
  tabClosedWithoutUserGesture('TabClosedWithoutUserGesture'),
  primaryMainFrameRendererProcessCrashed(
      'PrimaryMainFrameRendererProcessCrashed'),
  primaryMainFrameRendererProcessKilled(
      'PrimaryMainFrameRendererProcessKilled'),
  activationFramePolicyNotCompatible('ActivationFramePolicyNotCompatible'),
  preloadingDisabled('PreloadingDisabled'),
  batterySaverEnabled('BatterySaverEnabled'),
  activatedDuringMainFrameNavigation('ActivatedDuringMainFrameNavigation'),
  preloadingUnsupportedByWebContents('PreloadingUnsupportedByWebContents'),
  crossSiteRedirectInMainFrameNavigation(
      'CrossSiteRedirectInMainFrameNavigation'),
  crossSiteNavigationInMainFrameNavigation(
      'CrossSiteNavigationInMainFrameNavigation'),
  sameSiteCrossOriginRedirectNotOptInInMainFrameNavigation(
      'SameSiteCrossOriginRedirectNotOptInInMainFrameNavigation'),
  sameSiteCrossOriginNavigationNotOptInInMainFrameNavigation(
      'SameSiteCrossOriginNavigationNotOptInInMainFrameNavigation'),
  ;

  final String value;

  const PrerenderFinalStatus(this.value);

  factory PrerenderFinalStatus.fromJson(String value) =>
      PrerenderFinalStatus.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Preloading status values, see also PreloadingTriggeringOutcome. This
/// status is shared by prefetchStatusUpdated and prerenderStatusUpdated.
enum PreloadingStatus {
  pending('Pending'),
  running('Running'),
  ready('Ready'),
  success('Success'),
  failure('Failure'),
  notSupported('NotSupported'),
  ;

  final String value;

  const PreloadingStatus(this.value);

  factory PreloadingStatus.fromJson(String value) =>
      PreloadingStatus.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}
