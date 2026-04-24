import 'dart:async';
import '../src/connection.dart';
import 'page.dart' as page;

/// This domain exposes the current state of the CrashReportContext API.
class CrashReportContextApi {
  final Client _client;

  CrashReportContextApi(this._client);

  /// Returns all entries in the CrashReportContext across all frames in the page.
  Future<List<CrashReportContextEntry>> getEntries() async {
    var result = await _client.send('CrashReportContext.getEntries');
    return (result['entries'] as List)
        .map((e) => CrashReportContextEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// Key-value pair in CrashReportContext.
class CrashReportContextEntry {
  final String key;

  final String value;

  /// The ID of the frame where the key-value pair was set.
  final page.FrameId frameId;

  CrashReportContextEntry({
    required this.key,
    required this.value,
    required this.frameId,
  });

  factory CrashReportContextEntry.fromJson(Map<String, dynamic> json) {
    return CrashReportContextEntry(
      key: json['key'] as String,
      value: json['value'] as String,
      frameId: page.FrameId.fromJson(json['frameId'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'key': key, 'value': value, 'frameId': frameId.toJson()};
  }
}
