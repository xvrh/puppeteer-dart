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
      .map(
        (event) => RuleSet.fromJson(
          event.parameters['ruleSet'] as Map<String, dynamic>,
        ),
      );

  Stream<RuleSetId> get onRuleSetRemoved => _client.onEvent
      .where((event) => event.name == 'Preload.ruleSetRemoved')
      .map((event) => RuleSetId.fromJson(event.parameters['id'] as String));

  /// Fired when a preload enabled state is updated.
  Stream<PreloadEnabledStateUpdatedEvent> get onPreloadEnabledStateUpdated =>
      _client.onEvent
          .where((event) => event.name == 'Preload.preloadEnabledStateUpdated')
          .map(
            (event) =>
                PreloadEnabledStateUpdatedEvent.fromJson(event.parameters),
          );

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
      .where((event) => event.name == 'Preload.preloadingAttemptSourcesUpdated')
      .map(
        (event) =>
            PreloadingAttemptSourcesUpdatedEvent.fromJson(event.parameters),
      );

  Future<void> enable() async {
    await _client.send('Preload.enable');
  }

  Future<void> disable() async {
    await _client.send('Preload.disable');
  }
}

class PreloadEnabledStateUpdatedEvent {
  final bool disabledByPreference;

  final bool disabledByDataSaver;

  final bool disabledByBatterySaver;

  final bool disabledByHoldbackPrefetchSpeculationRules;

  final bool disabledByHoldbackPrerenderSpeculationRules;

  PreloadEnabledStateUpdatedEvent({
    required this.disabledByPreference,
    required this.disabledByDataSaver,
    required this.disabledByBatterySaver,
    required this.disabledByHoldbackPrefetchSpeculationRules,
    required this.disabledByHoldbackPrerenderSpeculationRules,
  });

  factory PreloadEnabledStateUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return PreloadEnabledStateUpdatedEvent(
      disabledByPreference: json['disabledByPreference'] as bool? ?? false,
      disabledByDataSaver: json['disabledByDataSaver'] as bool? ?? false,
      disabledByBatterySaver: json['disabledByBatterySaver'] as bool? ?? false,
      disabledByHoldbackPrefetchSpeculationRules:
          json['disabledByHoldbackPrefetchSpeculationRules'] as bool? ?? false,
      disabledByHoldbackPrerenderSpeculationRules:
          json['disabledByHoldbackPrerenderSpeculationRules'] as bool? ?? false,
    );
  }
}

class PrefetchStatusUpdatedEvent {
  final PreloadingAttemptKey key;

  final PreloadPipelineId pipelineId;

  /// The frame id of the frame initiating prefetch.
  final page.FrameId initiatingFrameId;

  final String prefetchUrl;

  final PreloadingStatus status;

  final PrefetchStatus prefetchStatus;

  final network.RequestId requestId;

  PrefetchStatusUpdatedEvent({
    required this.key,
    required this.pipelineId,
    required this.initiatingFrameId,
    required this.prefetchUrl,
    required this.status,
    required this.prefetchStatus,
    required this.requestId,
  });

  factory PrefetchStatusUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return PrefetchStatusUpdatedEvent(
      key: PreloadingAttemptKey.fromJson(json['key'] as Map<String, dynamic>),
      pipelineId: PreloadPipelineId.fromJson(json['pipelineId'] as String),
      initiatingFrameId: page.FrameId.fromJson(
        json['initiatingFrameId'] as String,
      ),
      prefetchUrl: json['prefetchUrl'] as String,
      status: PreloadingStatus.fromJson(json['status'] as String),
      prefetchStatus: PrefetchStatus.fromJson(json['prefetchStatus'] as String),
      requestId: network.RequestId.fromJson(json['requestId'] as String),
    );
  }
}

class PrerenderStatusUpdatedEvent {
  final PreloadingAttemptKey key;

  final PreloadPipelineId pipelineId;

  final PreloadingStatus status;

  final PrerenderFinalStatus? prerenderStatus;

  /// This is used to give users more information about the name of Mojo interface
  /// that is incompatible with prerender and has caused the cancellation of the attempt.
  final String? disallowedMojoInterface;

  final List<PrerenderMismatchedHeaders>? mismatchedHeaders;

  PrerenderStatusUpdatedEvent({
    required this.key,
    required this.pipelineId,
    required this.status,
    this.prerenderStatus,
    this.disallowedMojoInterface,
    this.mismatchedHeaders,
  });

  factory PrerenderStatusUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return PrerenderStatusUpdatedEvent(
      key: PreloadingAttemptKey.fromJson(json['key'] as Map<String, dynamic>),
      pipelineId: PreloadPipelineId.fromJson(json['pipelineId'] as String),
      status: PreloadingStatus.fromJson(json['status'] as String),
      prerenderStatus: json.containsKey('prerenderStatus')
          ? PrerenderFinalStatus.fromJson(json['prerenderStatus'] as String)
          : null,
      disallowedMojoInterface: json.containsKey('disallowedMojoInterface')
          ? json['disallowedMojoInterface'] as String
          : null,
      mismatchedHeaders: json.containsKey('mismatchedHeaders')
          ? (json['mismatchedHeaders'] as List)
                .map(
                  (e) => PrerenderMismatchedHeaders.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : null,
    );
  }
}

class PreloadingAttemptSourcesUpdatedEvent {
  final network.LoaderId loaderId;

  final List<PreloadingAttemptSource> preloadingAttemptSources;

  PreloadingAttemptSourcesUpdatedEvent({
    required this.loaderId,
    required this.preloadingAttemptSources,
  });

  factory PreloadingAttemptSourcesUpdatedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return PreloadingAttemptSourcesUpdatedEvent(
      loaderId: network.LoaderId.fromJson(json['loaderId'] as String),
      preloadingAttemptSources: (json['preloadingAttemptSources'] as List)
          .map(
            (e) => PreloadingAttemptSource.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

/// Unique id
extension type RuleSetId(String value) {
  factory RuleSetId.fromJson(String value) => RuleSetId(value);

  String toJson() => value;
}

/// Corresponds to SpeculationRuleSet
class RuleSet {
  final RuleSetId id;

  /// Identifies a document which the rule set is associated with.
  final network.LoaderId loaderId;

  /// Source text of JSON representing the rule set. If it comes from
  /// `<script>` tag, it is the textContent of the node. Note that it is
  /// a JSON for valid case.
  ///
  /// See also:
  /// - https://wicg.github.io/nav-speculation/speculation-rules.html
  /// - https://github.com/WICG/nav-speculation/blob/main/triggers.md
  final String sourceText;

  /// A speculation rule set is either added through an inline
  /// `<script>` tag or through an external resource via the
  /// 'Speculation-Rules' HTTP header. For the first case, we include
  /// the BackendNodeId of the relevant `<script>` tag. For the second
  /// case, we include the external URL where the rule set was loaded
  /// from, and also RequestId if Network domain is enabled.
  ///
  /// See also:
  /// - https://wicg.github.io/nav-speculation/speculation-rules.html#speculation-rules-script
  /// - https://wicg.github.io/nav-speculation/speculation-rules.html#speculation-rules-header
  final dom.BackendNodeId? backendNodeId;

  final String? url;

  final network.RequestId? requestId;

  /// Error information
  /// `errorMessage` is null iff `errorType` is null.
  final RuleSetErrorType? errorType;

  RuleSet({
    required this.id,
    required this.loaderId,
    required this.sourceText,
    this.backendNodeId,
    this.url,
    this.requestId,
    this.errorType,
  });

  factory RuleSet.fromJson(Map<String, dynamic> json) {
    return RuleSet(
      id: RuleSetId.fromJson(json['id'] as String),
      loaderId: network.LoaderId.fromJson(json['loaderId'] as String),
      sourceText: json['sourceText'] as String,
      backendNodeId: json.containsKey('backendNodeId')
          ? dom.BackendNodeId.fromJson(json['backendNodeId'] as int)
          : null,
      url: json.containsKey('url') ? json['url'] as String : null,
      requestId: json.containsKey('requestId')
          ? network.RequestId.fromJson(json['requestId'] as String)
          : null,
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
      if (backendNodeId != null) 'backendNodeId': backendNodeId!.toJson(),
      if (url != null) 'url': url,
      if (requestId != null) 'requestId': requestId!.toJson(),
      if (errorType != null) 'errorType': errorType!.toJson(),
    };
  }
}

enum RuleSetErrorType {
  sourceIsNotJsonObject('SourceIsNotJsonObject'),
  invalidRulesSkipped('InvalidRulesSkipped'),
  invalidRulesetLevelTag('InvalidRulesetLevelTag');

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
  prerender('Prerender');

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
  self('Self');

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

  PreloadingAttemptKey({
    required this.loaderId,
    required this.action,
    required this.url,
    this.targetHint,
  });

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
/// possible for multiple rule sets and links to trigger a single attempt.
class PreloadingAttemptSource {
  final PreloadingAttemptKey key;

  final List<RuleSetId> ruleSetIds;

  final List<dom.BackendNodeId> nodeIds;

  PreloadingAttemptSource({
    required this.key,
    required this.ruleSetIds,
    required this.nodeIds,
  });

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

/// Chrome manages different types of preloads together using a
/// concept of preloading pipeline. For example, if a site uses a
/// SpeculationRules for prerender, Chrome first starts a prefetch and
/// then upgrades it to prerender.
///
/// CDP events for them are emitted separately but they share
/// `PreloadPipelineId`.
extension type PreloadPipelineId(String value) {
  factory PreloadPipelineId.fromJson(String value) => PreloadPipelineId(value);

  String toJson() => value;
}

/// List of FinalStatus reasons for Prerender2.
enum PrerenderFinalStatus {
  activated('Activated'),
  destroyed('Destroyed'),
  lowEndDevice('LowEndDevice'),
  invalidSchemeRedirect('InvalidSchemeRedirect'),
  invalidSchemeNavigation('InvalidSchemeNavigation'),
  navigationRequestBlockedByCsp('NavigationRequestBlockedByCsp'),
  mojoBinderPolicy('MojoBinderPolicy'),
  rendererProcessCrashed('RendererProcessCrashed'),
  rendererProcessKilled('RendererProcessKilled'),
  download('Download'),
  triggerDestroyed('TriggerDestroyed'),
  navigationNotCommitted('NavigationNotCommitted'),
  navigationBadHttpStatus('NavigationBadHttpStatus'),
  clientCertRequested('ClientCertRequested'),
  navigationRequestNetworkError('NavigationRequestNetworkError'),
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
  memoryLimitExceeded('MemoryLimitExceeded'),
  dataSaverEnabled('DataSaverEnabled'),
  triggerUrlHasEffectiveUrl('TriggerUrlHasEffectiveUrl'),
  activatedBeforeStarted('ActivatedBeforeStarted'),
  inactivePageRestriction('InactivePageRestriction'),
  startFailed('StartFailed'),
  timeoutBackgrounded('TimeoutBackgrounded'),
  crossSiteRedirectInInitialNavigation('CrossSiteRedirectInInitialNavigation'),
  crossSiteNavigationInInitialNavigation(
    'CrossSiteNavigationInInitialNavigation',
  ),
  sameSiteCrossOriginRedirectNotOptInInInitialNavigation(
    'SameSiteCrossOriginRedirectNotOptInInInitialNavigation',
  ),
  sameSiteCrossOriginNavigationNotOptInInInitialNavigation(
    'SameSiteCrossOriginNavigationNotOptInInInitialNavigation',
  ),
  activationNavigationParameterMismatch(
    'ActivationNavigationParameterMismatch',
  ),
  activatedInBackground('ActivatedInBackground'),
  embedderHostDisallowed('EmbedderHostDisallowed'),
  activationNavigationDestroyedBeforeSuccess(
    'ActivationNavigationDestroyedBeforeSuccess',
  ),
  tabClosedByUserGesture('TabClosedByUserGesture'),
  tabClosedWithoutUserGesture('TabClosedWithoutUserGesture'),
  primaryMainFrameRendererProcessCrashed(
    'PrimaryMainFrameRendererProcessCrashed',
  ),
  primaryMainFrameRendererProcessKilled(
    'PrimaryMainFrameRendererProcessKilled',
  ),
  activationFramePolicyNotCompatible('ActivationFramePolicyNotCompatible'),
  preloadingDisabled('PreloadingDisabled'),
  batterySaverEnabled('BatterySaverEnabled'),
  activatedDuringMainFrameNavigation('ActivatedDuringMainFrameNavigation'),
  preloadingUnsupportedByWebContents('PreloadingUnsupportedByWebContents'),
  crossSiteRedirectInMainFrameNavigation(
    'CrossSiteRedirectInMainFrameNavigation',
  ),
  crossSiteNavigationInMainFrameNavigation(
    'CrossSiteNavigationInMainFrameNavigation',
  ),
  sameSiteCrossOriginRedirectNotOptInInMainFrameNavigation(
    'SameSiteCrossOriginRedirectNotOptInInMainFrameNavigation',
  ),
  sameSiteCrossOriginNavigationNotOptInInMainFrameNavigation(
    'SameSiteCrossOriginNavigationNotOptInInMainFrameNavigation',
  ),
  memoryPressureOnTrigger('MemoryPressureOnTrigger'),
  memoryPressureAfterTriggered('MemoryPressureAfterTriggered'),
  prerenderingDisabledByDevTools('PrerenderingDisabledByDevTools'),
  speculationRuleRemoved('SpeculationRuleRemoved'),
  activatedWithAuxiliaryBrowsingContexts(
    'ActivatedWithAuxiliaryBrowsingContexts',
  ),
  maxNumOfRunningEagerPrerendersExceeded(
    'MaxNumOfRunningEagerPrerendersExceeded',
  ),
  maxNumOfRunningNonEagerPrerendersExceeded(
    'MaxNumOfRunningNonEagerPrerendersExceeded',
  ),
  maxNumOfRunningEmbedderPrerendersExceeded(
    'MaxNumOfRunningEmbedderPrerendersExceeded',
  ),
  prerenderingUrlHasEffectiveUrl('PrerenderingUrlHasEffectiveUrl'),
  redirectedPrerenderingUrlHasEffectiveUrl(
    'RedirectedPrerenderingUrlHasEffectiveUrl',
  ),
  activationUrlHasEffectiveUrl('ActivationUrlHasEffectiveUrl'),
  javaScriptInterfaceAdded('JavaScriptInterfaceAdded'),
  javaScriptInterfaceRemoved('JavaScriptInterfaceRemoved'),
  allPrerenderingCanceled('AllPrerenderingCanceled'),
  windowClosed('WindowClosed'),
  slowNetwork('SlowNetwork'),
  otherPrerenderedPageActivated('OtherPrerenderedPageActivated'),
  v8OptimizerDisabled('V8OptimizerDisabled'),
  prerenderFailedDuringPrefetch('PrerenderFailedDuringPrefetch'),
  browsingDataRemoved('BrowsingDataRemoved'),
  prerenderHostReused('PrerenderHostReused');

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
  notSupported('NotSupported');

  final String value;

  const PreloadingStatus(this.value);

  factory PreloadingStatus.fromJson(String value) =>
      PreloadingStatus.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// TODO(https://crbug.com/1384419): revisit the list of PrefetchStatus and
/// filter out the ones that aren't necessary to the developers.
enum PrefetchStatus {
  prefetchAllowed('PrefetchAllowed'),
  prefetchFailedIneligibleRedirect('PrefetchFailedIneligibleRedirect'),
  prefetchFailedInvalidRedirect('PrefetchFailedInvalidRedirect'),
  prefetchFailedMimeNotSupported('PrefetchFailedMIMENotSupported'),
  prefetchFailedNetError('PrefetchFailedNetError'),
  prefetchFailedNon2xx('PrefetchFailedNon2XX'),
  prefetchEvictedAfterBrowsingDataRemoved(
    'PrefetchEvictedAfterBrowsingDataRemoved',
  ),
  prefetchEvictedAfterCandidateRemoved('PrefetchEvictedAfterCandidateRemoved'),
  prefetchEvictedForNewerPrefetch('PrefetchEvictedForNewerPrefetch'),
  prefetchHeldback('PrefetchHeldback'),
  prefetchIneligibleRetryAfter('PrefetchIneligibleRetryAfter'),
  prefetchIsPrivacyDecoy('PrefetchIsPrivacyDecoy'),
  prefetchIsStale('PrefetchIsStale'),
  prefetchNotEligibleBrowserContextOffTheRecord(
    'PrefetchNotEligibleBrowserContextOffTheRecord',
  ),
  prefetchNotEligibleDataSaverEnabled('PrefetchNotEligibleDataSaverEnabled'),
  prefetchNotEligibleExistingProxy('PrefetchNotEligibleExistingProxy'),
  prefetchNotEligibleHostIsNonUnique('PrefetchNotEligibleHostIsNonUnique'),
  prefetchNotEligibleNonDefaultStoragePartition(
    'PrefetchNotEligibleNonDefaultStoragePartition',
  ),
  prefetchNotEligibleSameSiteCrossOriginPrefetchRequiredProxy(
    'PrefetchNotEligibleSameSiteCrossOriginPrefetchRequiredProxy',
  ),
  prefetchNotEligibleSchemeIsNotHttps('PrefetchNotEligibleSchemeIsNotHttps'),
  prefetchNotEligibleUserHasCookies('PrefetchNotEligibleUserHasCookies'),
  prefetchNotEligibleUserHasServiceWorker(
    'PrefetchNotEligibleUserHasServiceWorker',
  ),
  prefetchNotEligibleUserHasServiceWorkerNoFetchHandler(
    'PrefetchNotEligibleUserHasServiceWorkerNoFetchHandler',
  ),
  prefetchNotEligibleRedirectFromServiceWorker(
    'PrefetchNotEligibleRedirectFromServiceWorker',
  ),
  prefetchNotEligibleRedirectToServiceWorker(
    'PrefetchNotEligibleRedirectToServiceWorker',
  ),
  prefetchNotEligibleBatterySaverEnabled(
    'PrefetchNotEligibleBatterySaverEnabled',
  ),
  prefetchNotEligiblePreloadingDisabled(
    'PrefetchNotEligiblePreloadingDisabled',
  ),
  prefetchNotFinishedInTime('PrefetchNotFinishedInTime'),
  prefetchNotStarted('PrefetchNotStarted'),
  prefetchNotUsedCookiesChanged('PrefetchNotUsedCookiesChanged'),
  prefetchProxyNotAvailable('PrefetchProxyNotAvailable'),
  prefetchResponseUsed('PrefetchResponseUsed'),
  prefetchSuccessfulButNotUsed('PrefetchSuccessfulButNotUsed'),
  prefetchNotUsedProbeFailed('PrefetchNotUsedProbeFailed');

  final String value;

  const PrefetchStatus(this.value);

  factory PrefetchStatus.fromJson(String value) =>
      PrefetchStatus.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Information of headers to be displayed when the header mismatch occurred.
class PrerenderMismatchedHeaders {
  final String headerName;

  final String? initialValue;

  final String? activationValue;

  PrerenderMismatchedHeaders({
    required this.headerName,
    this.initialValue,
    this.activationValue,
  });

  factory PrerenderMismatchedHeaders.fromJson(Map<String, dynamic> json) {
    return PrerenderMismatchedHeaders(
      headerName: json['headerName'] as String,
      initialValue: json.containsKey('initialValue')
          ? json['initialValue'] as String
          : null,
      activationValue: json.containsKey('activationValue')
          ? json['activationValue'] as String
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headerName': headerName,
      if (initialValue != null) 'initialValue': initialValue,
      if (activationValue != null) 'activationValue': activationValue,
    };
  }
}
