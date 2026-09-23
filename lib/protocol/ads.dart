import 'dart:async';
import '../src/connection.dart';
import 'network.dart' as network;
import 'page.dart' as page;
import 'runtime.dart' as runtime;

/// A domain for ad-related metrics and data.
class AdsApi {
  final Client _client;

  AdsApi(this._client);

  /// Retrieves ad metrics for the current page.
  Future<AdMetrics> getAdMetrics() async {
    var result = await _client.send('Ads.getAdMetrics');
    return AdMetrics.fromJson(result['metrics'] as Map<String, dynamic>);
  }

  /// Retrieves ad scripts for the current page. To minimize payload size, this
  /// only returns the newly tracked ad scripts since the last call to
  /// getAdScripts (i.e., the delta).
  Future<List<AdScript>> getAdScripts() async {
    var result = await _client.send('Ads.getAdScripts');
    return (result['newScripts'] as List)
        .map((e) => AdScript.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// Ad frame data.
class AdFrameData {
  /// The DevTools frame token.
  final page.FrameId frameId;

  /// The initial origin of the frame. To minimize the payload size, this is
  /// only sent once per frame.
  final String? initialOrigin;

  /// The network bytes of the frame.
  final num networkBytes;

  /// The CPU time of the frame, in milliseconds.
  final num cpuTime;

  AdFrameData({
    required this.frameId,
    this.initialOrigin,
    required this.networkBytes,
    required this.cpuTime,
  });

  factory AdFrameData.fromJson(Map<String, dynamic> json) {
    return AdFrameData(
      frameId: page.FrameId.fromJson(json['frameId'] as String),
      initialOrigin: json.containsKey('initialOrigin')
          ? json['initialOrigin'] as String
          : null,
      networkBytes: json['networkBytes'] as num,
      cpuTime: json['cpuTime'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frameId': frameId.toJson(),
      'networkBytes': networkBytes,
      'cpuTime': cpuTime,
      if (initialOrigin != null) 'initialOrigin': initialOrigin,
    };
  }
}

/// Ad metrics for a page.
class AdMetrics {
  /// The viewport ad density by area, represented as a percentage (an integer
  /// between 0 and 100).
  final int viewportAdDensityByArea;

  /// The time-weighted average of the viewport ad density by area, measured
  /// across the duration of the page.
  final num averageViewportAdDensityByArea;

  /// The number of ads currently visible within the viewport.
  final int viewportAdCount;

  /// The time-weighted average of the viewport ad count, measured across the
  /// duration of the page.
  final num averageViewportAdCount;

  /// The total ad CPU usage, in milliseconds.
  final num totalAdCpuTime;

  /// The total ad network bytes.
  final num totalAdNetworkBytes;

  /// The list of ad frames that have been updated since the last event.
  final List<AdFrameData> updateAdFrames;

  /// The list of ad frame IDs that have been removed since the last event.
  final List<page.FrameId> removeAdFrames;

  AdMetrics({
    required this.viewportAdDensityByArea,
    required this.averageViewportAdDensityByArea,
    required this.viewportAdCount,
    required this.averageViewportAdCount,
    required this.totalAdCpuTime,
    required this.totalAdNetworkBytes,
    required this.updateAdFrames,
    required this.removeAdFrames,
  });

  factory AdMetrics.fromJson(Map<String, dynamic> json) {
    return AdMetrics(
      viewportAdDensityByArea: json['viewportAdDensityByArea'] as int,
      averageViewportAdDensityByArea:
          json['averageViewportAdDensityByArea'] as num,
      viewportAdCount: json['viewportAdCount'] as int,
      averageViewportAdCount: json['averageViewportAdCount'] as num,
      totalAdCpuTime: json['totalAdCpuTime'] as num,
      totalAdNetworkBytes: json['totalAdNetworkBytes'] as num,
      updateAdFrames: (json['updateAdFrames'] as List)
          .map((e) => AdFrameData.fromJson(e as Map<String, dynamic>))
          .toList(),
      removeAdFrames: (json['removeAdFrames'] as List)
          .map((e) => page.FrameId.fromJson(e as String))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'viewportAdDensityByArea': viewportAdDensityByArea,
      'averageViewportAdDensityByArea': averageViewportAdDensityByArea,
      'viewportAdCount': viewportAdCount,
      'averageViewportAdCount': averageViewportAdCount,
      'totalAdCpuTime': totalAdCpuTime,
      'totalAdNetworkBytes': totalAdNetworkBytes,
      'updateAdFrames': updateAdFrames.map((e) => e.toJson()).toList(),
      'removeAdFrames': removeAdFrames.map((e) => e.toJson()).toList(),
    };
  }
}

/// An ad script.
/// Note: when the script is a transitive ad script, we only fill in the
/// immediate ancestor script in the provenance's adScriptAncestry field (as its
/// first entry), rather than filling in the full ancestry. This saves work for
/// the backend, and the frontend can reconstruct the full ancestry if
/// necessary.
class AdScript {
  /// The script ID.
  final runtime.ScriptId scriptId;

  /// The ad provenance.
  final network.AdProvenance provenance;

  AdScript({required this.scriptId, required this.provenance});

  factory AdScript.fromJson(Map<String, dynamic> json) {
    return AdScript(
      scriptId: runtime.ScriptId.fromJson(json['scriptId'] as String),
      provenance: network.AdProvenance.fromJson(
        json['provenance'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'scriptId': scriptId.toJson(), 'provenance': provenance.toJson()};
  }
}
