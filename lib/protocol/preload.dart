import 'dart:async';
import '../src/connection.dart';
import 'network.dart' as network;

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

  Future<void> enable() async {
    await _client.send('Preload.enable');
  }

  Future<void> disable() async {
    await _client.send('Preload.disable');
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

  RuleSet({required this.id, required this.loaderId, required this.sourceText});

  factory RuleSet.fromJson(Map<String, dynamic> json) {
    return RuleSet(
      id: RuleSetId.fromJson(json['id'] as String),
      loaderId: network.LoaderId.fromJson(json['loaderId'] as String),
      sourceText: json['sourceText'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toJson(),
      'loaderId': loaderId.toJson(),
      'sourceText': sourceText,
    };
  }
}
