import 'dart:async';
import '../src/connection.dart';

/// A domain for ad-related metrics and data.
class AdsApi {
  final Client _client;

  AdsApi(this._client);

  /// Retrieves ad metrics for the current page.
  Future<AdMetrics> getAdMetrics() async {
    var result = await _client.send('Ads.getAdMetrics');
    return AdMetrics.fromJson(result['metrics'] as Map<String, dynamic>);
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

  AdMetrics({
    required this.viewportAdDensityByArea,
    required this.averageViewportAdDensityByArea,
    required this.viewportAdCount,
    required this.averageViewportAdCount,
    required this.totalAdCpuTime,
    required this.totalAdNetworkBytes,
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
    };
  }
}
