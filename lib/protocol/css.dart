import 'dart:async';
import '../src/connection.dart';
import 'dom.dart' as dom;
import 'page.dart' as page;

/// This domain exposes CSS read/write operations. All CSS objects (stylesheets, rules, and styles)
/// have an associated `id` used in subsequent operations on the related object. Each object type has
/// a specific `id` structure, and those are not interchangeable between objects of different kinds.
/// CSS objects can be loaded using the `get*ForNode()` calls (which accept a DOM node id). A client
/// can also keep track of stylesheets via the `styleSheetAdded`/`styleSheetRemoved` events and
/// subsequently load the required stylesheet contents using the `getStyleSheet[Text]()` methods.
class CSSApi {
  final Client _client;

  CSSApi(this._client);

  /// Fires whenever a web font is updated.  A non-empty font parameter indicates a successfully loaded
  /// web font
  Stream<FontFace> get onFontsUpdated => _client.onEvent
      .where((event) => event.name == 'CSS.fontsUpdated')
      .map((event) =>
          FontFace.fromJson(event.parameters['font'] as Map<String, dynamic>));

  /// Fires whenever a MediaQuery result changes (for example, after a browser window has been
  /// resized.) The current implementation considers only viewport-dependent media features.
  Stream get onMediaQueryResultChanged => _client.onEvent
      .where((event) => event.name == 'CSS.mediaQueryResultChanged');

  /// Fired whenever an active document stylesheet is added.
  Stream<CSSStyleSheetHeader> get onStyleSheetAdded => _client.onEvent
      .where((event) => event.name == 'CSS.styleSheetAdded')
      .map((event) => CSSStyleSheetHeader.fromJson(
          event.parameters['header'] as Map<String, dynamic>));

  /// Fired whenever a stylesheet is changed as a result of the client operation.
  Stream<StyleSheetId> get onStyleSheetChanged => _client.onEvent
      .where((event) => event.name == 'CSS.styleSheetChanged')
      .map((event) =>
          StyleSheetId.fromJson(event.parameters['styleSheetId'] as String));

  /// Fired whenever an active document stylesheet is removed.
  Stream<StyleSheetId> get onStyleSheetRemoved => _client.onEvent
      .where((event) => event.name == 'CSS.styleSheetRemoved')
      .map((event) =>
          StyleSheetId.fromJson(event.parameters['styleSheetId'] as String));

  /// Inserts a new rule with the given `ruleText` in a stylesheet with given `styleSheetId`, at the
  /// position specified by `location`.
  /// [styleSheetId] The css style sheet identifier where a new rule should be inserted.
  /// [ruleText] The text of a new rule.
  /// [location] Text position of a new rule in the target style sheet.
  /// Returns: The newly created rule.
  Future<CSSRule> addRule(
      StyleSheetId styleSheetId, String ruleText, SourceRange location) async {
    var result = await _client.send('CSS.addRule', {
      'styleSheetId': styleSheetId,
      'ruleText': ruleText,
      'location': location,
    });
    return CSSRule.fromJson(result['rule'] as Map<String, dynamic>);
  }

  /// Returns all class names from specified stylesheet.
  /// Returns: Class name list.
  Future<List<String>> collectClassNames(StyleSheetId styleSheetId) async {
    var result = await _client.send('CSS.collectClassNames', {
      'styleSheetId': styleSheetId,
    });
    return (result['classNames'] as List).map((e) => e as String).toList();
  }

  /// Creates a new special "via-inspector" stylesheet in the frame with given `frameId`.
  /// [frameId] Identifier of the frame where "via-inspector" stylesheet should be created.
  /// Returns: Identifier of the created "via-inspector" stylesheet.
  Future<StyleSheetId> createStyleSheet(page.FrameId frameId) async {
    var result = await _client.send('CSS.createStyleSheet', {
      'frameId': frameId,
    });
    return StyleSheetId.fromJson(result['styleSheetId'] as String);
  }

  /// Disables the CSS agent for the given page.
  Future<void> disable() async {
    await _client.send('CSS.disable');
  }

  /// Enables the CSS agent for the given page. Clients should not assume that the CSS agent has been
  /// enabled until the result of this command is received.
  Future<void> enable() async {
    await _client.send('CSS.enable');
  }

  /// Ensures that the given node will have specified pseudo-classes whenever its style is computed by
  /// the browser.
  /// [nodeId] The element id for which to force the pseudo state.
  /// [forcedPseudoClasses] Element pseudo classes to force when computing the element's style.
  Future<void> forcePseudoState(
      dom.NodeId nodeId, List<String> forcedPseudoClasses) async {
    await _client.send('CSS.forcePseudoState', {
      'nodeId': nodeId,
      'forcedPseudoClasses': [...forcedPseudoClasses],
    });
  }

  /// [nodeId] Id of the node to get background colors for.
  Future<GetBackgroundColorsResult> getBackgroundColors(
      dom.NodeId nodeId) async {
    var result = await _client.send('CSS.getBackgroundColors', {
      'nodeId': nodeId,
    });
    return GetBackgroundColorsResult.fromJson(result);
  }

  /// Returns the computed style for a DOM node identified by `nodeId`.
  /// Returns: Computed style for the specified DOM node.
  Future<List<CSSComputedStyleProperty>> getComputedStyleForNode(
      dom.NodeId nodeId) async {
    var result = await _client.send('CSS.getComputedStyleForNode', {
      'nodeId': nodeId,
    });
    return (result['computedStyle'] as List)
        .map(
            (e) => CSSComputedStyleProperty.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns the styles defined inline (explicitly in the "style" attribute and implicitly, using DOM
  /// attributes) for a DOM node identified by `nodeId`.
  Future<GetInlineStylesForNodeResult> getInlineStylesForNode(
      dom.NodeId nodeId) async {
    var result = await _client.send('CSS.getInlineStylesForNode', {
      'nodeId': nodeId,
    });
    return GetInlineStylesForNodeResult.fromJson(result);
  }

  /// Returns requested styles for a DOM node identified by `nodeId`.
  Future<GetMatchedStylesForNodeResult> getMatchedStylesForNode(
      dom.NodeId nodeId) async {
    var result = await _client.send('CSS.getMatchedStylesForNode', {
      'nodeId': nodeId,
    });
    return GetMatchedStylesForNodeResult.fromJson(result);
  }

  /// Returns all media queries parsed by the rendering engine.
  Future<List<CSSMedia>> getMediaQueries() async {
    var result = await _client.send('CSS.getMediaQueries');
    return (result['medias'] as List)
        .map((e) => CSSMedia.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Requests information about platform fonts which we used to render child TextNodes in the given
  /// node.
  /// Returns: Usage statistics for every employed platform font.
  Future<List<PlatformFontUsage>> getPlatformFontsForNode(
      dom.NodeId nodeId) async {
    var result = await _client.send('CSS.getPlatformFontsForNode', {
      'nodeId': nodeId,
    });
    return (result['fonts'] as List)
        .map((e) => PlatformFontUsage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns the current textual content for a stylesheet.
  /// Returns: The stylesheet text.
  Future<String> getStyleSheetText(StyleSheetId styleSheetId) async {
    var result = await _client.send('CSS.getStyleSheetText', {
      'styleSheetId': styleSheetId,
    });
    return result['text'] as String;
  }

  /// Returns all layers parsed by the rendering engine for the tree scope of a node.
  /// Given a DOM element identified by nodeId, getLayersForNode returns the root
  /// layer for the nearest ancestor document or shadow root. The layer root contains
  /// the full layer tree for the tree scope and their ordering.
  Future<CSSLayerData> getLayersForNode(dom.NodeId nodeId) async {
    var result = await _client.send('CSS.getLayersForNode', {
      'nodeId': nodeId,
    });
    return CSSLayerData.fromJson(result['rootLayer'] as Map<String, dynamic>);
  }

  /// Starts tracking the given computed styles for updates. The specified array of properties
  /// replaces the one previously specified. Pass empty array to disable tracking.
  /// Use takeComputedStyleUpdates to retrieve the list of nodes that had properties modified.
  /// The changes to computed style properties are only tracked for nodes pushed to the front-end
  /// by the DOM agent. If no changes to the tracked properties occur after the node has been pushed
  /// to the front-end, no updates will be issued for the node.
  Future<void> trackComputedStyleUpdates(
      List<CSSComputedStyleProperty> propertiesToTrack) async {
    await _client.send('CSS.trackComputedStyleUpdates', {
      'propertiesToTrack': [...propertiesToTrack],
    });
  }

  /// Polls the next batch of computed style updates.
  /// Returns: The list of node Ids that have their tracked computed styles updated
  Future<List<dom.NodeId>> takeComputedStyleUpdates() async {
    var result = await _client.send('CSS.takeComputedStyleUpdates');
    return (result['nodeIds'] as List)
        .map((e) => dom.NodeId.fromJson(e as int))
        .toList();
  }

  /// Find a rule with the given active property for the given node and set the new value for this
  /// property
  /// [nodeId] The element id for which to set property.
  Future<void> setEffectivePropertyValueForNode(
      dom.NodeId nodeId, String propertyName, String value) async {
    await _client.send('CSS.setEffectivePropertyValueForNode', {
      'nodeId': nodeId,
      'propertyName': propertyName,
      'value': value,
    });
  }

  /// Modifies the keyframe rule key text.
  /// Returns: The resulting key text after modification.
  Future<Value> setKeyframeKey(
      StyleSheetId styleSheetId, SourceRange range, String keyText) async {
    var result = await _client.send('CSS.setKeyframeKey', {
      'styleSheetId': styleSheetId,
      'range': range,
      'keyText': keyText,
    });
    return Value.fromJson(result['keyText'] as Map<String, dynamic>);
  }

  /// Modifies the rule selector.
  /// Returns: The resulting CSS media rule after modification.
  Future<CSSMedia> setMediaText(
      StyleSheetId styleSheetId, SourceRange range, String text) async {
    var result = await _client.send('CSS.setMediaText', {
      'styleSheetId': styleSheetId,
      'range': range,
      'text': text,
    });
    return CSSMedia.fromJson(result['media'] as Map<String, dynamic>);
  }

  /// Modifies the expression of a container query.
  /// Returns: The resulting CSS container query rule after modification.
  Future<CSSContainerQuery> setContainerQueryText(
      StyleSheetId styleSheetId, SourceRange range, String text) async {
    var result = await _client.send('CSS.setContainerQueryText', {
      'styleSheetId': styleSheetId,
      'range': range,
      'text': text,
    });
    return CSSContainerQuery.fromJson(
        result['containerQuery'] as Map<String, dynamic>);
  }

  /// Modifies the expression of a supports at-rule.
  /// Returns: The resulting CSS Supports rule after modification.
  Future<CSSSupports> setSupportsText(
      StyleSheetId styleSheetId, SourceRange range, String text) async {
    var result = await _client.send('CSS.setSupportsText', {
      'styleSheetId': styleSheetId,
      'range': range,
      'text': text,
    });
    return CSSSupports.fromJson(result['supports'] as Map<String, dynamic>);
  }

  /// Modifies the rule selector.
  /// Returns: The resulting selector list after modification.
  Future<SelectorList> setRuleSelector(
      StyleSheetId styleSheetId, SourceRange range, String selector) async {
    var result = await _client.send('CSS.setRuleSelector', {
      'styleSheetId': styleSheetId,
      'range': range,
      'selector': selector,
    });
    return SelectorList.fromJson(
        result['selectorList'] as Map<String, dynamic>);
  }

  /// Sets the new stylesheet text.
  /// Returns: URL of source map associated with script (if any).
  Future<String> setStyleSheetText(
      StyleSheetId styleSheetId, String text) async {
    var result = await _client.send('CSS.setStyleSheetText', {
      'styleSheetId': styleSheetId,
      'text': text,
    });
    return result['sourceMapURL'] as String;
  }

  /// Applies specified style edits one after another in the given order.
  /// Returns: The resulting styles after modification.
  Future<List<CSSStyle>> setStyleTexts(List<StyleDeclarationEdit> edits) async {
    var result = await _client.send('CSS.setStyleTexts', {
      'edits': [...edits],
    });
    return (result['styles'] as List)
        .map((e) => CSSStyle.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Enables the selector recording.
  Future<void> startRuleUsageTracking() async {
    await _client.send('CSS.startRuleUsageTracking');
  }

  /// Stop tracking rule usage and return the list of rules that were used since last call to
  /// `takeCoverageDelta` (or since start of coverage instrumentation)
  Future<List<RuleUsage>> stopRuleUsageTracking() async {
    var result = await _client.send('CSS.stopRuleUsageTracking');
    return (result['ruleUsage'] as List)
        .map((e) => RuleUsage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Obtain list of rules that became used since last call to this method (or since start of coverage
  /// instrumentation)
  Future<TakeCoverageDeltaResult> takeCoverageDelta() async {
    var result = await _client.send('CSS.takeCoverageDelta');
    return TakeCoverageDeltaResult.fromJson(result);
  }

  /// Enables/disables rendering of local CSS fonts (enabled by default).
  /// [enabled] Whether rendering of local fonts is enabled.
  Future<void> setLocalFontsEnabled(bool enabled) async {
    await _client.send('CSS.setLocalFontsEnabled', {
      'enabled': enabled,
    });
  }
}

class GetBackgroundColorsResult {
  /// The range of background colors behind this element, if it contains any visible text. If no
  /// visible text is present, this will be undefined. In the case of a flat background color,
  /// this will consist of simply that color. In the case of a gradient, this will consist of each
  /// of the color stops. For anything more complicated, this will be an empty array. Images will
  /// be ignored (as if the image had failed to load).
  final List<String>? backgroundColors;

  /// The computed font size for this node, as a CSS computed value string (e.g. '12px').
  final String? computedFontSize;

  /// The computed font weight for this node, as a CSS computed value string (e.g. 'normal' or
  /// '100').
  final String? computedFontWeight;

  GetBackgroundColorsResult(
      {this.backgroundColors, this.computedFontSize, this.computedFontWeight});

  factory GetBackgroundColorsResult.fromJson(Map<String, dynamic> json) {
    return GetBackgroundColorsResult(
      backgroundColors: json.containsKey('backgroundColors')
          ? (json['backgroundColors'] as List).map((e) => e as String).toList()
          : null,
      computedFontSize: json.containsKey('computedFontSize')
          ? json['computedFontSize'] as String
          : null,
      computedFontWeight: json.containsKey('computedFontWeight')
          ? json['computedFontWeight'] as String
          : null,
    );
  }
}

class GetInlineStylesForNodeResult {
  /// Inline style for the specified DOM node.
  final CSSStyle? inlineStyle;

  /// Attribute-defined element style (e.g. resulting from "width=20 height=100%").
  final CSSStyle? attributesStyle;

  GetInlineStylesForNodeResult({this.inlineStyle, this.attributesStyle});

  factory GetInlineStylesForNodeResult.fromJson(Map<String, dynamic> json) {
    return GetInlineStylesForNodeResult(
      inlineStyle: json.containsKey('inlineStyle')
          ? CSSStyle.fromJson(json['inlineStyle'] as Map<String, dynamic>)
          : null,
      attributesStyle: json.containsKey('attributesStyle')
          ? CSSStyle.fromJson(json['attributesStyle'] as Map<String, dynamic>)
          : null,
    );
  }
}

class GetMatchedStylesForNodeResult {
  /// Inline style for the specified DOM node.
  final CSSStyle? inlineStyle;

  /// Attribute-defined element style (e.g. resulting from "width=20 height=100%").
  final CSSStyle? attributesStyle;

  /// CSS rules matching this node, from all applicable stylesheets.
  final List<RuleMatch>? matchedCSSRules;

  /// Pseudo style matches for this node.
  final List<PseudoElementMatches>? pseudoElements;

  /// A chain of inherited styles (from the immediate node parent up to the DOM tree root).
  final List<InheritedStyleEntry>? inherited;

  /// A chain of inherited pseudo element styles (from the immediate node parent up to the DOM tree root).
  final List<InheritedPseudoElementMatches>? inheritedPseudoElements;

  /// A list of CSS keyframed animations matching this node.
  final List<CSSKeyframesRule>? cssKeyframesRules;

  GetMatchedStylesForNodeResult(
      {this.inlineStyle,
      this.attributesStyle,
      this.matchedCSSRules,
      this.pseudoElements,
      this.inherited,
      this.inheritedPseudoElements,
      this.cssKeyframesRules});

  factory GetMatchedStylesForNodeResult.fromJson(Map<String, dynamic> json) {
    return GetMatchedStylesForNodeResult(
      inlineStyle: json.containsKey('inlineStyle')
          ? CSSStyle.fromJson(json['inlineStyle'] as Map<String, dynamic>)
          : null,
      attributesStyle: json.containsKey('attributesStyle')
          ? CSSStyle.fromJson(json['attributesStyle'] as Map<String, dynamic>)
          : null,
      matchedCSSRules: json.containsKey('matchedCSSRules')
          ? (json['matchedCSSRules'] as List)
              .map((e) => RuleMatch.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      pseudoElements: json.containsKey('pseudoElements')
          ? (json['pseudoElements'] as List)
              .map((e) =>
                  PseudoElementMatches.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      inherited: json.containsKey('inherited')
          ? (json['inherited'] as List)
              .map((e) =>
                  InheritedStyleEntry.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      inheritedPseudoElements: json.containsKey('inheritedPseudoElements')
          ? (json['inheritedPseudoElements'] as List)
              .map((e) => InheritedPseudoElementMatches.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : null,
      cssKeyframesRules: json.containsKey('cssKeyframesRules')
          ? (json['cssKeyframesRules'] as List)
              .map((e) => CSSKeyframesRule.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class TakeCoverageDeltaResult {
  final List<RuleUsage> coverage;

  /// Monotonically increasing time, in seconds.
  final num timestamp;

  TakeCoverageDeltaResult({required this.coverage, required this.timestamp});

  factory TakeCoverageDeltaResult.fromJson(Map<String, dynamic> json) {
    return TakeCoverageDeltaResult(
      coverage: (json['coverage'] as List)
          .map((e) => RuleUsage.fromJson(e as Map<String, dynamic>))
          .toList(),
      timestamp: json['timestamp'] as num,
    );
  }
}

class StyleSheetId {
  final String value;

  StyleSheetId(this.value);

  factory StyleSheetId.fromJson(String value) => StyleSheetId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is StyleSheetId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Stylesheet type: "injected" for stylesheets injected via extension, "user-agent" for user-agent
/// stylesheets, "inspector" for stylesheets created by the inspector (i.e. those holding the "via
/// inspector" rules), "regular" for regular stylesheets.
class StyleSheetOrigin {
  static const injected = StyleSheetOrigin._('injected');
  static const userAgent = StyleSheetOrigin._('user-agent');
  static const inspector = StyleSheetOrigin._('inspector');
  static const regular = StyleSheetOrigin._('regular');
  static const values = {
    'injected': injected,
    'user-agent': userAgent,
    'inspector': inspector,
    'regular': regular,
  };

  final String value;

  const StyleSheetOrigin._(this.value);

  factory StyleSheetOrigin.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is StyleSheetOrigin && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// CSS rule collection for a single pseudo style.
class PseudoElementMatches {
  /// Pseudo element type.
  final dom.PseudoType pseudoType;

  /// Matches of CSS rules applicable to the pseudo style.
  final List<RuleMatch> matches;

  PseudoElementMatches({required this.pseudoType, required this.matches});

  factory PseudoElementMatches.fromJson(Map<String, dynamic> json) {
    return PseudoElementMatches(
      pseudoType: dom.PseudoType.fromJson(json['pseudoType'] as String),
      matches: (json['matches'] as List)
          .map((e) => RuleMatch.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pseudoType': pseudoType.toJson(),
      'matches': matches.map((e) => e.toJson()).toList(),
    };
  }
}

/// Inherited CSS rule collection from ancestor node.
class InheritedStyleEntry {
  /// The ancestor node's inline style, if any, in the style inheritance chain.
  final CSSStyle? inlineStyle;

  /// Matches of CSS rules matching the ancestor node in the style inheritance chain.
  final List<RuleMatch> matchedCSSRules;

  InheritedStyleEntry({this.inlineStyle, required this.matchedCSSRules});

  factory InheritedStyleEntry.fromJson(Map<String, dynamic> json) {
    return InheritedStyleEntry(
      inlineStyle: json.containsKey('inlineStyle')
          ? CSSStyle.fromJson(json['inlineStyle'] as Map<String, dynamic>)
          : null,
      matchedCSSRules: (json['matchedCSSRules'] as List)
          .map((e) => RuleMatch.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchedCSSRules': matchedCSSRules.map((e) => e.toJson()).toList(),
      if (inlineStyle != null) 'inlineStyle': inlineStyle!.toJson(),
    };
  }
}

/// Inherited pseudo element matches from pseudos of an ancestor node.
class InheritedPseudoElementMatches {
  /// Matches of pseudo styles from the pseudos of an ancestor node.
  final List<PseudoElementMatches> pseudoElements;

  InheritedPseudoElementMatches({required this.pseudoElements});

  factory InheritedPseudoElementMatches.fromJson(Map<String, dynamic> json) {
    return InheritedPseudoElementMatches(
      pseudoElements: (json['pseudoElements'] as List)
          .map((e) => PseudoElementMatches.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pseudoElements': pseudoElements.map((e) => e.toJson()).toList(),
    };
  }
}

/// Match data for a CSS rule.
class RuleMatch {
  /// CSS rule in the match.
  final CSSRule rule;

  /// Matching selector indices in the rule's selectorList selectors (0-based).
  final List<int> matchingSelectors;

  RuleMatch({required this.rule, required this.matchingSelectors});

  factory RuleMatch.fromJson(Map<String, dynamic> json) {
    return RuleMatch(
      rule: CSSRule.fromJson(json['rule'] as Map<String, dynamic>),
      matchingSelectors:
          (json['matchingSelectors'] as List).map((e) => e as int).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rule': rule.toJson(),
      'matchingSelectors': [...matchingSelectors],
    };
  }
}

/// Data for a simple selector (these are delimited by commas in a selector list).
class Value {
  /// Value text.
  final String text;

  /// Value range in the underlying resource (if available).
  final SourceRange? range;

  Value({required this.text, this.range});

  factory Value.fromJson(Map<String, dynamic> json) {
    return Value(
      text: json['text'] as String,
      range: json.containsKey('range')
          ? SourceRange.fromJson(json['range'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      if (range != null) 'range': range!.toJson(),
    };
  }
}

/// Selector list data.
class SelectorList {
  /// Selectors in the list.
  final List<Value> selectors;

  /// Rule selector text.
  final String text;

  SelectorList({required this.selectors, required this.text});

  factory SelectorList.fromJson(Map<String, dynamic> json) {
    return SelectorList(
      selectors: (json['selectors'] as List)
          .map((e) => Value.fromJson(e as Map<String, dynamic>))
          .toList(),
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectors': selectors.map((e) => e.toJson()).toList(),
      'text': text,
    };
  }
}

/// CSS stylesheet metainformation.
class CSSStyleSheetHeader {
  /// The stylesheet identifier.
  final StyleSheetId styleSheetId;

  /// Owner frame identifier.
  final page.FrameId frameId;

  /// Stylesheet resource URL. Empty if this is a constructed stylesheet created using
  /// new CSSStyleSheet() (but non-empty if this is a constructed sylesheet imported
  /// as a CSS module script).
  final String sourceURL;

  /// URL of source map associated with the stylesheet (if any).
  final String? sourceMapURL;

  /// Stylesheet origin.
  final StyleSheetOrigin origin;

  /// Stylesheet title.
  final String title;

  /// The backend id for the owner node of the stylesheet.
  final dom.BackendNodeId? ownerNode;

  /// Denotes whether the stylesheet is disabled.
  final bool disabled;

  /// Whether the sourceURL field value comes from the sourceURL comment.
  final bool? hasSourceURL;

  /// Whether this stylesheet is created for STYLE tag by parser. This flag is not set for
  /// document.written STYLE tags.
  final bool isInline;

  /// Whether this stylesheet is mutable. Inline stylesheets become mutable
  /// after they have been modified via CSSOM API.
  /// <link> element's stylesheets become mutable only if DevTools modifies them.
  /// Constructed stylesheets (new CSSStyleSheet()) are mutable immediately after creation.
  final bool isMutable;

  /// True if this stylesheet is created through new CSSStyleSheet() or imported as a
  /// CSS module script.
  final bool isConstructed;

  /// Line offset of the stylesheet within the resource (zero based).
  final num startLine;

  /// Column offset of the stylesheet within the resource (zero based).
  final num startColumn;

  /// Size of the content (in characters).
  final num length;

  /// Line offset of the end of the stylesheet within the resource (zero based).
  final num endLine;

  /// Column offset of the end of the stylesheet within the resource (zero based).
  final num endColumn;

  CSSStyleSheetHeader(
      {required this.styleSheetId,
      required this.frameId,
      required this.sourceURL,
      this.sourceMapURL,
      required this.origin,
      required this.title,
      this.ownerNode,
      required this.disabled,
      this.hasSourceURL,
      required this.isInline,
      required this.isMutable,
      required this.isConstructed,
      required this.startLine,
      required this.startColumn,
      required this.length,
      required this.endLine,
      required this.endColumn});

  factory CSSStyleSheetHeader.fromJson(Map<String, dynamic> json) {
    return CSSStyleSheetHeader(
      styleSheetId: StyleSheetId.fromJson(json['styleSheetId'] as String),
      frameId: page.FrameId.fromJson(json['frameId'] as String),
      sourceURL: json['sourceURL'] as String,
      sourceMapURL: json.containsKey('sourceMapURL')
          ? json['sourceMapURL'] as String
          : null,
      origin: StyleSheetOrigin.fromJson(json['origin'] as String),
      title: json['title'] as String,
      ownerNode: json.containsKey('ownerNode')
          ? dom.BackendNodeId.fromJson(json['ownerNode'] as int)
          : null,
      disabled: json['disabled'] as bool? ?? false,
      hasSourceURL: json.containsKey('hasSourceURL')
          ? json['hasSourceURL'] as bool
          : null,
      isInline: json['isInline'] as bool? ?? false,
      isMutable: json['isMutable'] as bool? ?? false,
      isConstructed: json['isConstructed'] as bool? ?? false,
      startLine: json['startLine'] as num,
      startColumn: json['startColumn'] as num,
      length: json['length'] as num,
      endLine: json['endLine'] as num,
      endColumn: json['endColumn'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'styleSheetId': styleSheetId.toJson(),
      'frameId': frameId.toJson(),
      'sourceURL': sourceURL,
      'origin': origin.toJson(),
      'title': title,
      'disabled': disabled,
      'isInline': isInline,
      'isMutable': isMutable,
      'isConstructed': isConstructed,
      'startLine': startLine,
      'startColumn': startColumn,
      'length': length,
      'endLine': endLine,
      'endColumn': endColumn,
      if (sourceMapURL != null) 'sourceMapURL': sourceMapURL,
      if (ownerNode != null) 'ownerNode': ownerNode!.toJson(),
      if (hasSourceURL != null) 'hasSourceURL': hasSourceURL,
    };
  }
}

/// CSS rule representation.
class CSSRule {
  /// The css style sheet identifier (absent for user agent stylesheet and user-specified
  /// stylesheet rules) this rule came from.
  final StyleSheetId? styleSheetId;

  /// Rule selector data.
  final SelectorList selectorList;

  /// Parent stylesheet's origin.
  final StyleSheetOrigin origin;

  /// Associated style declaration.
  final CSSStyle style;

  /// Media list array (for rules involving media queries). The array enumerates media queries
  /// starting with the innermost one, going outwards.
  final List<CSSMedia>? media;

  /// Container query list array (for rules involving container queries).
  /// The array enumerates container queries starting with the innermost one, going outwards.
  final List<CSSContainerQuery>? containerQueries;

  /// @supports CSS at-rule array.
  /// The array enumerates @supports at-rules starting with the innermost one, going outwards.
  final List<CSSSupports>? supports;

  /// Cascade layer array. Contains the layer hierarchy that this rule belongs to starting
  /// with the innermost layer and going outwards.
  final List<CSSLayer>? layers;

  CSSRule(
      {this.styleSheetId,
      required this.selectorList,
      required this.origin,
      required this.style,
      this.media,
      this.containerQueries,
      this.supports,
      this.layers});

  factory CSSRule.fromJson(Map<String, dynamic> json) {
    return CSSRule(
      styleSheetId: json.containsKey('styleSheetId')
          ? StyleSheetId.fromJson(json['styleSheetId'] as String)
          : null,
      selectorList:
          SelectorList.fromJson(json['selectorList'] as Map<String, dynamic>),
      origin: StyleSheetOrigin.fromJson(json['origin'] as String),
      style: CSSStyle.fromJson(json['style'] as Map<String, dynamic>),
      media: json.containsKey('media')
          ? (json['media'] as List)
              .map((e) => CSSMedia.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      containerQueries: json.containsKey('containerQueries')
          ? (json['containerQueries'] as List)
              .map((e) => CSSContainerQuery.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      supports: json.containsKey('supports')
          ? (json['supports'] as List)
              .map((e) => CSSSupports.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      layers: json.containsKey('layers')
          ? (json['layers'] as List)
              .map((e) => CSSLayer.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectorList': selectorList.toJson(),
      'origin': origin.toJson(),
      'style': style.toJson(),
      if (styleSheetId != null) 'styleSheetId': styleSheetId!.toJson(),
      if (media != null) 'media': media!.map((e) => e.toJson()).toList(),
      if (containerQueries != null)
        'containerQueries': containerQueries!.map((e) => e.toJson()).toList(),
      if (supports != null)
        'supports': supports!.map((e) => e.toJson()).toList(),
      if (layers != null) 'layers': layers!.map((e) => e.toJson()).toList(),
    };
  }
}

/// CSS coverage information.
class RuleUsage {
  /// The css style sheet identifier (absent for user agent stylesheet and user-specified
  /// stylesheet rules) this rule came from.
  final StyleSheetId styleSheetId;

  /// Offset of the start of the rule (including selector) from the beginning of the stylesheet.
  final num startOffset;

  /// Offset of the end of the rule body from the beginning of the stylesheet.
  final num endOffset;

  /// Indicates whether the rule was actually used by some element in the page.
  final bool used;

  RuleUsage(
      {required this.styleSheetId,
      required this.startOffset,
      required this.endOffset,
      required this.used});

  factory RuleUsage.fromJson(Map<String, dynamic> json) {
    return RuleUsage(
      styleSheetId: StyleSheetId.fromJson(json['styleSheetId'] as String),
      startOffset: json['startOffset'] as num,
      endOffset: json['endOffset'] as num,
      used: json['used'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'styleSheetId': styleSheetId.toJson(),
      'startOffset': startOffset,
      'endOffset': endOffset,
      'used': used,
    };
  }
}

/// Text range within a resource. All numbers are zero-based.
class SourceRange {
  /// Start line of range.
  final int startLine;

  /// Start column of range (inclusive).
  final int startColumn;

  /// End line of range
  final int endLine;

  /// End column of range (exclusive).
  final int endColumn;

  SourceRange(
      {required this.startLine,
      required this.startColumn,
      required this.endLine,
      required this.endColumn});

  factory SourceRange.fromJson(Map<String, dynamic> json) {
    return SourceRange(
      startLine: json['startLine'] as int,
      startColumn: json['startColumn'] as int,
      endLine: json['endLine'] as int,
      endColumn: json['endColumn'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startLine': startLine,
      'startColumn': startColumn,
      'endLine': endLine,
      'endColumn': endColumn,
    };
  }
}

class ShorthandEntry {
  /// Shorthand name.
  final String name;

  /// Shorthand value.
  final String value;

  /// Whether the property has "!important" annotation (implies `false` if absent).
  final bool? important;

  ShorthandEntry({required this.name, required this.value, this.important});

  factory ShorthandEntry.fromJson(Map<String, dynamic> json) {
    return ShorthandEntry(
      name: json['name'] as String,
      value: json['value'] as String,
      important:
          json.containsKey('important') ? json['important'] as bool : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      if (important != null) 'important': important,
    };
  }
}

class CSSComputedStyleProperty {
  /// Computed style property name.
  final String name;

  /// Computed style property value.
  final String value;

  CSSComputedStyleProperty({required this.name, required this.value});

  factory CSSComputedStyleProperty.fromJson(Map<String, dynamic> json) {
    return CSSComputedStyleProperty(
      name: json['name'] as String,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}

/// CSS style representation.
class CSSStyle {
  /// The css style sheet identifier (absent for user agent stylesheet and user-specified
  /// stylesheet rules) this rule came from.
  final StyleSheetId? styleSheetId;

  /// CSS properties in the style.
  final List<CSSProperty> cssProperties;

  /// Computed values for all shorthands found in the style.
  final List<ShorthandEntry> shorthandEntries;

  /// Style declaration text (if available).
  final String? cssText;

  /// Style declaration range in the enclosing stylesheet (if available).
  final SourceRange? range;

  CSSStyle(
      {this.styleSheetId,
      required this.cssProperties,
      required this.shorthandEntries,
      this.cssText,
      this.range});

  factory CSSStyle.fromJson(Map<String, dynamic> json) {
    return CSSStyle(
      styleSheetId: json.containsKey('styleSheetId')
          ? StyleSheetId.fromJson(json['styleSheetId'] as String)
          : null,
      cssProperties: (json['cssProperties'] as List)
          .map((e) => CSSProperty.fromJson(e as Map<String, dynamic>))
          .toList(),
      shorthandEntries: (json['shorthandEntries'] as List)
          .map((e) => ShorthandEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      cssText: json.containsKey('cssText') ? json['cssText'] as String : null,
      range: json.containsKey('range')
          ? SourceRange.fromJson(json['range'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cssProperties': cssProperties.map((e) => e.toJson()).toList(),
      'shorthandEntries': shorthandEntries.map((e) => e.toJson()).toList(),
      if (styleSheetId != null) 'styleSheetId': styleSheetId!.toJson(),
      if (cssText != null) 'cssText': cssText,
      if (range != null) 'range': range!.toJson(),
    };
  }
}

/// CSS property declaration data.
class CSSProperty {
  /// The property name.
  final String name;

  /// The property value.
  final String value;

  /// Whether the property has "!important" annotation (implies `false` if absent).
  final bool? important;

  /// Whether the property is implicit (implies `false` if absent).
  final bool? implicit;

  /// The full property text as specified in the style.
  final String? text;

  /// Whether the property is understood by the browser (implies `true` if absent).
  final bool? parsedOk;

  /// Whether the property is disabled by the user (present for source-based properties only).
  final bool? disabled;

  /// The entire property range in the enclosing style declaration (if available).
  final SourceRange? range;

  CSSProperty(
      {required this.name,
      required this.value,
      this.important,
      this.implicit,
      this.text,
      this.parsedOk,
      this.disabled,
      this.range});

  factory CSSProperty.fromJson(Map<String, dynamic> json) {
    return CSSProperty(
      name: json['name'] as String,
      value: json['value'] as String,
      important:
          json.containsKey('important') ? json['important'] as bool : null,
      implicit: json.containsKey('implicit') ? json['implicit'] as bool : null,
      text: json.containsKey('text') ? json['text'] as String : null,
      parsedOk: json.containsKey('parsedOk') ? json['parsedOk'] as bool : null,
      disabled: json.containsKey('disabled') ? json['disabled'] as bool : null,
      range: json.containsKey('range')
          ? SourceRange.fromJson(json['range'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      if (important != null) 'important': important,
      if (implicit != null) 'implicit': implicit,
      if (text != null) 'text': text,
      if (parsedOk != null) 'parsedOk': parsedOk,
      if (disabled != null) 'disabled': disabled,
      if (range != null) 'range': range!.toJson(),
    };
  }
}

/// CSS media rule descriptor.
class CSSMedia {
  /// Media query text.
  final String text;

  /// Source of the media query: "mediaRule" if specified by a @media rule, "importRule" if
  /// specified by an @import rule, "linkedSheet" if specified by a "media" attribute in a linked
  /// stylesheet's LINK tag, "inlineSheet" if specified by a "media" attribute in an inline
  /// stylesheet's STYLE tag.
  final CSSMediaSource source;

  /// URL of the document containing the media query description.
  final String? sourceURL;

  /// The associated rule (@media or @import) header range in the enclosing stylesheet (if
  /// available).
  final SourceRange? range;

  /// Identifier of the stylesheet containing this object (if exists).
  final StyleSheetId? styleSheetId;

  /// Array of media queries.
  final List<MediaQuery>? mediaList;

  CSSMedia(
      {required this.text,
      required this.source,
      this.sourceURL,
      this.range,
      this.styleSheetId,
      this.mediaList});

  factory CSSMedia.fromJson(Map<String, dynamic> json) {
    return CSSMedia(
      text: json['text'] as String,
      source: CSSMediaSource.fromJson(json['source'] as String),
      sourceURL:
          json.containsKey('sourceURL') ? json['sourceURL'] as String : null,
      range: json.containsKey('range')
          ? SourceRange.fromJson(json['range'] as Map<String, dynamic>)
          : null,
      styleSheetId: json.containsKey('styleSheetId')
          ? StyleSheetId.fromJson(json['styleSheetId'] as String)
          : null,
      mediaList: json.containsKey('mediaList')
          ? (json['mediaList'] as List)
              .map((e) => MediaQuery.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'source': source,
      if (sourceURL != null) 'sourceURL': sourceURL,
      if (range != null) 'range': range!.toJson(),
      if (styleSheetId != null) 'styleSheetId': styleSheetId!.toJson(),
      if (mediaList != null)
        'mediaList': mediaList!.map((e) => e.toJson()).toList(),
    };
  }
}

class CSSMediaSource {
  static const mediaRule = CSSMediaSource._('mediaRule');
  static const importRule = CSSMediaSource._('importRule');
  static const linkedSheet = CSSMediaSource._('linkedSheet');
  static const inlineSheet = CSSMediaSource._('inlineSheet');
  static const values = {
    'mediaRule': mediaRule,
    'importRule': importRule,
    'linkedSheet': linkedSheet,
    'inlineSheet': inlineSheet,
  };

  final String value;

  const CSSMediaSource._(this.value);

  factory CSSMediaSource.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CSSMediaSource && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Media query descriptor.
class MediaQuery {
  /// Array of media query expressions.
  final List<MediaQueryExpression> expressions;

  /// Whether the media query condition is satisfied.
  final bool active;

  MediaQuery({required this.expressions, required this.active});

  factory MediaQuery.fromJson(Map<String, dynamic> json) {
    return MediaQuery(
      expressions: (json['expressions'] as List)
          .map((e) => MediaQueryExpression.fromJson(e as Map<String, dynamic>))
          .toList(),
      active: json['active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expressions': expressions.map((e) => e.toJson()).toList(),
      'active': active,
    };
  }
}

/// Media query expression descriptor.
class MediaQueryExpression {
  /// Media query expression value.
  final num value;

  /// Media query expression units.
  final String unit;

  /// Media query expression feature.
  final String feature;

  /// The associated range of the value text in the enclosing stylesheet (if available).
  final SourceRange? valueRange;

  /// Computed length of media query expression (if applicable).
  final num? computedLength;

  MediaQueryExpression(
      {required this.value,
      required this.unit,
      required this.feature,
      this.valueRange,
      this.computedLength});

  factory MediaQueryExpression.fromJson(Map<String, dynamic> json) {
    return MediaQueryExpression(
      value: json['value'] as num,
      unit: json['unit'] as String,
      feature: json['feature'] as String,
      valueRange: json.containsKey('valueRange')
          ? SourceRange.fromJson(json['valueRange'] as Map<String, dynamic>)
          : null,
      computedLength: json.containsKey('computedLength')
          ? json['computedLength'] as num
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'unit': unit,
      'feature': feature,
      if (valueRange != null) 'valueRange': valueRange!.toJson(),
      if (computedLength != null) 'computedLength': computedLength,
    };
  }
}

/// CSS container query rule descriptor.
class CSSContainerQuery {
  /// Container query text.
  final String text;

  /// The associated rule header range in the enclosing stylesheet (if
  /// available).
  final SourceRange? range;

  /// Identifier of the stylesheet containing this object (if exists).
  final StyleSheetId? styleSheetId;

  /// Optional name for the container.
  final String? name;

  CSSContainerQuery(
      {required this.text, this.range, this.styleSheetId, this.name});

  factory CSSContainerQuery.fromJson(Map<String, dynamic> json) {
    return CSSContainerQuery(
      text: json['text'] as String,
      range: json.containsKey('range')
          ? SourceRange.fromJson(json['range'] as Map<String, dynamic>)
          : null,
      styleSheetId: json.containsKey('styleSheetId')
          ? StyleSheetId.fromJson(json['styleSheetId'] as String)
          : null,
      name: json.containsKey('name') ? json['name'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      if (range != null) 'range': range!.toJson(),
      if (styleSheetId != null) 'styleSheetId': styleSheetId!.toJson(),
      if (name != null) 'name': name,
    };
  }
}

/// CSS Supports at-rule descriptor.
class CSSSupports {
  /// Supports rule text.
  final String text;

  /// The associated rule header range in the enclosing stylesheet (if
  /// available).
  final SourceRange? range;

  /// Identifier of the stylesheet containing this object (if exists).
  final StyleSheetId? styleSheetId;

  CSSSupports({required this.text, this.range, this.styleSheetId});

  factory CSSSupports.fromJson(Map<String, dynamic> json) {
    return CSSSupports(
      text: json['text'] as String,
      range: json.containsKey('range')
          ? SourceRange.fromJson(json['range'] as Map<String, dynamic>)
          : null,
      styleSheetId: json.containsKey('styleSheetId')
          ? StyleSheetId.fromJson(json['styleSheetId'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      if (range != null) 'range': range!.toJson(),
      if (styleSheetId != null) 'styleSheetId': styleSheetId!.toJson(),
    };
  }
}

/// CSS Layer at-rule descriptor.
class CSSLayer {
  /// Layer name.
  final String text;

  /// The associated rule header range in the enclosing stylesheet (if
  /// available).
  final SourceRange? range;

  /// Identifier of the stylesheet containing this object (if exists).
  final StyleSheetId? styleSheetId;

  CSSLayer({required this.text, this.range, this.styleSheetId});

  factory CSSLayer.fromJson(Map<String, dynamic> json) {
    return CSSLayer(
      text: json['text'] as String,
      range: json.containsKey('range')
          ? SourceRange.fromJson(json['range'] as Map<String, dynamic>)
          : null,
      styleSheetId: json.containsKey('styleSheetId')
          ? StyleSheetId.fromJson(json['styleSheetId'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      if (range != null) 'range': range!.toJson(),
      if (styleSheetId != null) 'styleSheetId': styleSheetId!.toJson(),
    };
  }
}

/// CSS Layer data.
class CSSLayerData {
  /// Layer name.
  final String name;

  /// Direct sub-layers
  final List<CSSLayerData>? subLayers;

  /// Layer order. The order determines the order of the layer in the cascade order.
  /// A higher number has higher priority in the cascade order.
  final num order;

  CSSLayerData({required this.name, this.subLayers, required this.order});

  factory CSSLayerData.fromJson(Map<String, dynamic> json) {
    return CSSLayerData(
      name: json['name'] as String,
      subLayers: json.containsKey('subLayers')
          ? (json['subLayers'] as List)
              .map((e) => CSSLayerData.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      order: json['order'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'order': order,
      if (subLayers != null)
        'subLayers': subLayers!.map((e) => e.toJson()).toList(),
    };
  }
}

/// Information about amount of glyphs that were rendered with given font.
class PlatformFontUsage {
  /// Font's family name reported by platform.
  final String familyName;

  /// Indicates if the font was downloaded or resolved locally.
  final bool isCustomFont;

  /// Amount of glyphs that were rendered with this font.
  final num glyphCount;

  PlatformFontUsage(
      {required this.familyName,
      required this.isCustomFont,
      required this.glyphCount});

  factory PlatformFontUsage.fromJson(Map<String, dynamic> json) {
    return PlatformFontUsage(
      familyName: json['familyName'] as String,
      isCustomFont: json['isCustomFont'] as bool? ?? false,
      glyphCount: json['glyphCount'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'familyName': familyName,
      'isCustomFont': isCustomFont,
      'glyphCount': glyphCount,
    };
  }
}

/// Information about font variation axes for variable fonts
class FontVariationAxis {
  /// The font-variation-setting tag (a.k.a. "axis tag").
  final String tag;

  /// Human-readable variation name in the default language (normally, "en").
  final String name;

  /// The minimum value (inclusive) the font supports for this tag.
  final num minValue;

  /// The maximum value (inclusive) the font supports for this tag.
  final num maxValue;

  /// The default value.
  final num defaultValue;

  FontVariationAxis(
      {required this.tag,
      required this.name,
      required this.minValue,
      required this.maxValue,
      required this.defaultValue});

  factory FontVariationAxis.fromJson(Map<String, dynamic> json) {
    return FontVariationAxis(
      tag: json['tag'] as String,
      name: json['name'] as String,
      minValue: json['minValue'] as num,
      maxValue: json['maxValue'] as num,
      defaultValue: json['defaultValue'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'name': name,
      'minValue': minValue,
      'maxValue': maxValue,
      'defaultValue': defaultValue,
    };
  }
}

/// Properties of a web font: https://www.w3.org/TR/2008/REC-CSS2-20080411/fonts.html#font-descriptions
/// and additional information such as platformFontFamily and fontVariationAxes.
class FontFace {
  /// The font-family.
  final String fontFamily;

  /// The font-style.
  final String fontStyle;

  /// The font-variant.
  final String fontVariant;

  /// The font-weight.
  final String fontWeight;

  /// The font-stretch.
  final String fontStretch;

  /// The unicode-range.
  final String unicodeRange;

  /// The src.
  final String src;

  /// The resolved platform font family
  final String platformFontFamily;

  /// Available variation settings (a.k.a. "axes").
  final List<FontVariationAxis>? fontVariationAxes;

  FontFace(
      {required this.fontFamily,
      required this.fontStyle,
      required this.fontVariant,
      required this.fontWeight,
      required this.fontStretch,
      required this.unicodeRange,
      required this.src,
      required this.platformFontFamily,
      this.fontVariationAxes});

  factory FontFace.fromJson(Map<String, dynamic> json) {
    return FontFace(
      fontFamily: json['fontFamily'] as String,
      fontStyle: json['fontStyle'] as String,
      fontVariant: json['fontVariant'] as String,
      fontWeight: json['fontWeight'] as String,
      fontStretch: json['fontStretch'] as String,
      unicodeRange: json['unicodeRange'] as String,
      src: json['src'] as String,
      platformFontFamily: json['platformFontFamily'] as String,
      fontVariationAxes: json.containsKey('fontVariationAxes')
          ? (json['fontVariationAxes'] as List)
              .map((e) => FontVariationAxis.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontFamily': fontFamily,
      'fontStyle': fontStyle,
      'fontVariant': fontVariant,
      'fontWeight': fontWeight,
      'fontStretch': fontStretch,
      'unicodeRange': unicodeRange,
      'src': src,
      'platformFontFamily': platformFontFamily,
      if (fontVariationAxes != null)
        'fontVariationAxes': fontVariationAxes!.map((e) => e.toJson()).toList(),
    };
  }
}

/// CSS keyframes rule representation.
class CSSKeyframesRule {
  /// Animation name.
  final Value animationName;

  /// List of keyframes.
  final List<CSSKeyframeRule> keyframes;

  CSSKeyframesRule({required this.animationName, required this.keyframes});

  factory CSSKeyframesRule.fromJson(Map<String, dynamic> json) {
    return CSSKeyframesRule(
      animationName:
          Value.fromJson(json['animationName'] as Map<String, dynamic>),
      keyframes: (json['keyframes'] as List)
          .map((e) => CSSKeyframeRule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animationName': animationName.toJson(),
      'keyframes': keyframes.map((e) => e.toJson()).toList(),
    };
  }
}

/// CSS keyframe rule representation.
class CSSKeyframeRule {
  /// The css style sheet identifier (absent for user agent stylesheet and user-specified
  /// stylesheet rules) this rule came from.
  final StyleSheetId? styleSheetId;

  /// Parent stylesheet's origin.
  final StyleSheetOrigin origin;

  /// Associated key text.
  final Value keyText;

  /// Associated style declaration.
  final CSSStyle style;

  CSSKeyframeRule(
      {this.styleSheetId,
      required this.origin,
      required this.keyText,
      required this.style});

  factory CSSKeyframeRule.fromJson(Map<String, dynamic> json) {
    return CSSKeyframeRule(
      styleSheetId: json.containsKey('styleSheetId')
          ? StyleSheetId.fromJson(json['styleSheetId'] as String)
          : null,
      origin: StyleSheetOrigin.fromJson(json['origin'] as String),
      keyText: Value.fromJson(json['keyText'] as Map<String, dynamic>),
      style: CSSStyle.fromJson(json['style'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'origin': origin.toJson(),
      'keyText': keyText.toJson(),
      'style': style.toJson(),
      if (styleSheetId != null) 'styleSheetId': styleSheetId!.toJson(),
    };
  }
}

/// A descriptor of operation to mutate style declaration text.
class StyleDeclarationEdit {
  /// The css style sheet identifier.
  final StyleSheetId styleSheetId;

  /// The range of the style text in the enclosing stylesheet.
  final SourceRange range;

  /// New style text.
  final String text;

  StyleDeclarationEdit(
      {required this.styleSheetId, required this.range, required this.text});

  factory StyleDeclarationEdit.fromJson(Map<String, dynamic> json) {
    return StyleDeclarationEdit(
      styleSheetId: StyleSheetId.fromJson(json['styleSheetId'] as String),
      range: SourceRange.fromJson(json['range'] as Map<String, dynamic>),
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'styleSheetId': styleSheetId.toJson(),
      'range': range.toJson(),
      'text': text,
    };
  }
}
