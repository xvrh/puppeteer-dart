/// This domain exposes CSS read/write operations. All CSS objects (stylesheets, rules, and styles) have an associated <code>id</code> used in subsequent operations on the related object. Each object type has a specific <code>id</code> structure, and those are not interchangeable between objects of different kinds. CSS objects can be loaded using the <code>get*ForNode()</code> calls (which accept a DOM node id). A client can also keep track of stylesheets via the <code>styleSheetAdded</code>/<code>styleSheetRemoved</code> events and subsequently load the required stylesheet contents using the <code>getStyleSheet[Text]()</code> methods.

import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';
import 'dom.dart' as dom;
import 'page.dart' as page;

class CSSManager {
  final Session _client;

  CSSManager(this._client);

  /// Enables the CSS agent for the given page. Clients should not assume that the CSS agent has been enabled until the result of this command is received.
  Future enable() async {
    await _client.send('CSS.enable');
  }

  /// Disables the CSS agent for the given page.
  Future disable() async {
    await _client.send('CSS.disable');
  }

  /// Returns requested styles for a DOM node identified by <code>nodeId</code>.
  Future<GetMatchedStylesForNodeResult> getMatchedStylesForNode(
    dom.NodeId nodeId,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
    };
    await _client.send('CSS.getMatchedStylesForNode', parameters);
  }

  /// Returns the styles defined inline (explicitly in the "style" attribute and implicitly, using DOM attributes) for a DOM node identified by <code>nodeId</code>.
  Future<GetInlineStylesForNodeResult> getInlineStylesForNode(
    dom.NodeId nodeId,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
    };
    await _client.send('CSS.getInlineStylesForNode', parameters);
  }

  /// Returns the computed style for a DOM node identified by <code>nodeId</code>.
  /// Return: Computed style for the specified DOM node.
  Future<List<CSSComputedStyleProperty>> getComputedStyleForNode(
    dom.NodeId nodeId,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
    };
    await _client.send('CSS.getComputedStyleForNode', parameters);
  }

  /// Requests information about platform fonts which we used to render child TextNodes in the given node.
  /// Return: Usage statistics for every employed platform font.
  Future<List<PlatformFontUsage>> getPlatformFontsForNode(
    dom.NodeId nodeId,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
    };
    await _client.send('CSS.getPlatformFontsForNode', parameters);
  }

  /// Returns the current textual content and the URL for a stylesheet.
  /// Return: The stylesheet text.
  Future<String> getStyleSheetText(
    StyleSheetId styleSheetId,
  ) async {
    Map parameters = {
      'styleSheetId': styleSheetId.toJson(),
    };
    await _client.send('CSS.getStyleSheetText', parameters);
  }

  /// Returns all class names from specified stylesheet.
  /// Return: Class name list.
  Future<List<String>> collectClassNames(
    StyleSheetId styleSheetId,
  ) async {
    Map parameters = {
      'styleSheetId': styleSheetId.toJson(),
    };
    await _client.send('CSS.collectClassNames', parameters);
  }

  /// Sets the new stylesheet text.
  /// Return: URL of source map associated with script (if any).
  Future<String> setStyleSheetText(
    StyleSheetId styleSheetId,
    String text,
  ) async {
    Map parameters = {
      'styleSheetId': styleSheetId.toJson(),
      'text': text.toString(),
    };
    await _client.send('CSS.setStyleSheetText', parameters);
  }

  /// Modifies the rule selector.
  /// Return: The resulting selector list after modification.
  Future<SelectorList> setRuleSelector(
    StyleSheetId styleSheetId,
    SourceRange range,
    String selector,
  ) async {
    Map parameters = {
      'styleSheetId': styleSheetId.toJson(),
      'range': range.toJson(),
      'selector': selector.toString(),
    };
    await _client.send('CSS.setRuleSelector', parameters);
  }

  /// Modifies the keyframe rule key text.
  /// Return: The resulting key text after modification.
  Future<Value> setKeyframeKey(
    StyleSheetId styleSheetId,
    SourceRange range,
    String keyText,
  ) async {
    Map parameters = {
      'styleSheetId': styleSheetId.toJson(),
      'range': range.toJson(),
      'keyText': keyText.toString(),
    };
    await _client.send('CSS.setKeyframeKey', parameters);
  }

  /// Applies specified style edits one after another in the given order.
  /// Return: The resulting styles after modification.
  Future<List<CSSStyle>> setStyleTexts(
    List<StyleDeclarationEdit> edits,
  ) async {
    Map parameters = {
      'edits': edits.map((e) => e.toJson()).toList(),
    };
    await _client.send('CSS.setStyleTexts', parameters);
  }

  /// Modifies the rule selector.
  /// Return: The resulting CSS media rule after modification.
  Future<CSSMedia> setMediaText(
    StyleSheetId styleSheetId,
    SourceRange range,
    String text,
  ) async {
    Map parameters = {
      'styleSheetId': styleSheetId.toJson(),
      'range': range.toJson(),
      'text': text.toString(),
    };
    await _client.send('CSS.setMediaText', parameters);
  }

  /// Creates a new special "via-inspector" stylesheet in the frame with given <code>frameId</code>.
  /// [frameId] Identifier of the frame where "via-inspector" stylesheet should be created.
  /// Return: Identifier of the created "via-inspector" stylesheet.
  Future<StyleSheetId> createStyleSheet(
    page.FrameId frameId,
  ) async {
    Map parameters = {
      'frameId': frameId.toJson(),
    };
    await _client.send('CSS.createStyleSheet', parameters);
  }

  /// Inserts a new rule with the given <code>ruleText</code> in a stylesheet with given <code>styleSheetId</code>, at the position specified by <code>location</code>.
  /// [styleSheetId] The css style sheet identifier where a new rule should be inserted.
  /// [ruleText] The text of a new rule.
  /// [location] Text position of a new rule in the target style sheet.
  /// Return: The newly created rule.
  Future<CSSRule> addRule(
    StyleSheetId styleSheetId,
    String ruleText,
    SourceRange location,
  ) async {
    Map parameters = {
      'styleSheetId': styleSheetId.toJson(),
      'ruleText': ruleText.toString(),
      'location': location.toJson(),
    };
    await _client.send('CSS.addRule', parameters);
  }

  /// Ensures that the given node will have specified pseudo-classes whenever its style is computed by the browser.
  /// [nodeId] The element id for which to force the pseudo state.
  /// [forcedPseudoClasses] Element pseudo classes to force when computing the element's style.
  Future forcePseudoState(
    dom.NodeId nodeId,
    List<String> forcedPseudoClasses,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
      'forcedPseudoClasses':
          forcedPseudoClasses.map((e) => e.toString()).toList(),
    };
    await _client.send('CSS.forcePseudoState', parameters);
  }

  /// Returns all media queries parsed by the rendering engine.
  Future<List<CSSMedia>> getMediaQueries() async {
    await _client.send('CSS.getMediaQueries');
  }

  /// Find a rule with the given active property for the given node and set the new value for this property
  /// [nodeId] The element id for which to set property.
  Future setEffectivePropertyValueForNode(
    dom.NodeId nodeId,
    String propertyName,
    String value,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
      'propertyName': propertyName.toString(),
      'value': value.toString(),
    };
    await _client.send('CSS.setEffectivePropertyValueForNode', parameters);
  }

  /// [nodeId] Id of the node to get background colors for.
  Future<GetBackgroundColorsResult> getBackgroundColors(
    dom.NodeId nodeId,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
    };
    await _client.send('CSS.getBackgroundColors', parameters);
  }

  /// Enables the selector recording.
  Future startRuleUsageTracking() async {
    await _client.send('CSS.startRuleUsageTracking');
  }

  /// Obtain list of rules that became used since last call to this method (or since start of coverage instrumentation)
  Future<List<RuleUsage>> takeCoverageDelta() async {
    await _client.send('CSS.takeCoverageDelta');
  }

  /// The list of rules with an indication of whether these were used
  Future<List<RuleUsage>> stopRuleUsageTracking() async {
    await _client.send('CSS.stopRuleUsageTracking');
  }
}

class GetMatchedStylesForNodeResult {
  /// Inline style for the specified DOM node.
  final CSSStyle inlineStyle;

  /// Attribute-defined element style (e.g. resulting from "width=20 height=100%").
  final CSSStyle attributesStyle;

  /// CSS rules matching this node, from all applicable stylesheets.
  final List<RuleMatch> matchedCSSRules;

  /// Pseudo style matches for this node.
  final List<PseudoElementMatches> pseudoElements;

  /// A chain of inherited styles (from the immediate node parent up to the DOM tree root).
  final List<InheritedStyleEntry> inherited;

  /// A list of CSS keyframed animations matching this node.
  final List<CSSKeyframesRule> cssKeyframesRules;

  GetMatchedStylesForNodeResult({
    this.inlineStyle,
    this.attributesStyle,
    this.matchedCSSRules,
    this.pseudoElements,
    this.inherited,
    this.cssKeyframesRules,
  });
  factory GetMatchedStylesForNodeResult.fromJson(Map json) {}
}

class GetInlineStylesForNodeResult {
  /// Inline style for the specified DOM node.
  final CSSStyle inlineStyle;

  /// Attribute-defined element style (e.g. resulting from "width=20 height=100%").
  final CSSStyle attributesStyle;

  GetInlineStylesForNodeResult({
    this.inlineStyle,
    this.attributesStyle,
  });
  factory GetInlineStylesForNodeResult.fromJson(Map json) {}
}

class GetBackgroundColorsResult {
  /// The range of background colors behind this element, if it contains any visible text. If no visible text is present, this will be undefined. In the case of a flat background color, this will consist of simply that color. In the case of a gradient, this will consist of each of the color stops. For anything more complicated, this will be an empty array. Images will be ignored (as if the image had failed to load).
  final List<String> backgroundColors;

  /// The computed font size for this node, as a CSS computed value string (e.g. '12px').
  final String computedFontSize;

  /// The computed font weight for this node, as a CSS computed value string (e.g. 'normal' or '100').
  final String computedFontWeight;

  /// The computed font size for the document body, as a computed CSS value string (e.g. '16px').
  final String computedBodyFontSize;

  GetBackgroundColorsResult({
    this.backgroundColors,
    this.computedFontSize,
    this.computedFontWeight,
    this.computedBodyFontSize,
  });
  factory GetBackgroundColorsResult.fromJson(Map json) {}
}

class StyleSheetId {
  final String value;

  StyleSheetId(this.value);
  factory StyleSheetId.fromJson(String value) => new StyleSheetId(value);

  String toJson() => value;
}

/// Stylesheet type: "injected" for stylesheets injected via extension, "user-agent" for user-agent stylesheets, "inspector" for stylesheets created by the inspector (i.e. those holding the "via inspector" rules), "regular" for regular stylesheets.
class StyleSheetOrigin {
  static const StyleSheetOrigin injected = const StyleSheetOrigin._('injected');
  static const StyleSheetOrigin userAgent =
      const StyleSheetOrigin._('user-agent');
  static const StyleSheetOrigin inspector =
      const StyleSheetOrigin._('inspector');
  static const StyleSheetOrigin regular = const StyleSheetOrigin._('regular');

  final String value;

  const StyleSheetOrigin._(this.value);
  factory StyleSheetOrigin.fromJson(String value) => const {}[value];

  String toJson() => value;
}

/// CSS rule collection for a single pseudo style.
class PseudoElementMatches {
  /// Pseudo element type.
  final dom.PseudoType pseudoType;

  /// Matches of CSS rules applicable to the pseudo style.
  final List<RuleMatch> matches;

  PseudoElementMatches({
    @required this.pseudoType,
    @required this.matches,
  });
  factory PseudoElementMatches.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'pseudoType': pseudoType.toJson(),
      'matches': matches.map((e) => e.toJson()).toList(),
    };
    return json;
  }
}

/// Inherited CSS rule collection from ancestor node.
class InheritedStyleEntry {
  /// The ancestor node's inline style, if any, in the style inheritance chain.
  final CSSStyle inlineStyle;

  /// Matches of CSS rules matching the ancestor node in the style inheritance chain.
  final List<RuleMatch> matchedCSSRules;

  InheritedStyleEntry({
    this.inlineStyle,
    @required this.matchedCSSRules,
  });
  factory InheritedStyleEntry.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'matchedCSSRules': matchedCSSRules.map((e) => e.toJson()).toList(),
    };
    if (inlineStyle != null) {
      json['inlineStyle'] = inlineStyle.toJson();
    }
    return json;
  }
}

/// Match data for a CSS rule.
class RuleMatch {
  /// CSS rule in the match.
  final CSSRule rule;

  /// Matching selector indices in the rule's selectorList selectors (0-based).
  final List<int> matchingSelectors;

  RuleMatch({
    @required this.rule,
    @required this.matchingSelectors,
  });
  factory RuleMatch.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'rule': rule.toJson(),
      'matchingSelectors': matchingSelectors.map((e) => e.toString()).toList(),
    };
    return json;
  }
}

/// Data for a simple selector (these are delimited by commas in a selector list).
class Value {
  /// Value text.
  final String text;

  /// Value range in the underlying resource (if available).
  final SourceRange range;

  Value({
    @required this.text,
    this.range,
  });
  factory Value.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'text': text.toString(),
    };
    if (range != null) {
      json['range'] = range.toJson();
    }
    return json;
  }
}

/// Selector list data.
class SelectorList {
  /// Selectors in the list.
  final List<Value> selectors;

  /// Rule selector text.
  final String text;

  SelectorList({
    @required this.selectors,
    @required this.text,
  });
  factory SelectorList.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'selectors': selectors.map((e) => e.toJson()).toList(),
      'text': text.toString(),
    };
    return json;
  }
}

/// CSS stylesheet metainformation.
class CSSStyleSheetHeader {
  /// The stylesheet identifier.
  final StyleSheetId styleSheetId;

  /// Owner frame identifier.
  final page.FrameId frameId;

  /// Stylesheet resource URL.
  final String sourceURL;

  /// URL of source map associated with the stylesheet (if any).
  final String sourceMapURL;

  /// Stylesheet origin.
  final StyleSheetOrigin origin;

  /// Stylesheet title.
  final String title;

  /// The backend id for the owner node of the stylesheet.
  final dom.BackendNodeId ownerNode;

  /// Denotes whether the stylesheet is disabled.
  final bool disabled;

  /// Whether the sourceURL field value comes from the sourceURL comment.
  final bool hasSourceURL;

  /// Whether this stylesheet is created for STYLE tag by parser. This flag is not set for document.written STYLE tags.
  final bool isInline;

  /// Line offset of the stylesheet within the resource (zero based).
  final num startLine;

  /// Column offset of the stylesheet within the resource (zero based).
  final num startColumn;

  /// Size of the content (in characters).
  final num length;

  CSSStyleSheetHeader({
    @required this.styleSheetId,
    @required this.frameId,
    @required this.sourceURL,
    this.sourceMapURL,
    @required this.origin,
    @required this.title,
    this.ownerNode,
    @required this.disabled,
    this.hasSourceURL,
    @required this.isInline,
    @required this.startLine,
    @required this.startColumn,
    @required this.length,
  });
  factory CSSStyleSheetHeader.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'styleSheetId': styleSheetId.toJson(),
      'frameId': frameId.toJson(),
      'sourceURL': sourceURL.toString(),
      'origin': origin.toJson(),
      'title': title.toString(),
      'disabled': disabled.toString(),
      'isInline': isInline.toString(),
      'startLine': startLine.toString(),
      'startColumn': startColumn.toString(),
      'length': length.toString(),
    };
    if (sourceMapURL != null) {
      json['sourceMapURL'] = sourceMapURL.toString();
    }
    if (ownerNode != null) {
      json['ownerNode'] = ownerNode.toJson();
    }
    if (hasSourceURL != null) {
      json['hasSourceURL'] = hasSourceURL.toString();
    }
    return json;
  }
}

/// CSS rule representation.
class CSSRule {
  /// The css style sheet identifier (absent for user agent stylesheet and user-specified stylesheet rules) this rule came from.
  final StyleSheetId styleSheetId;

  /// Rule selector data.
  final SelectorList selectorList;

  /// Parent stylesheet's origin.
  final StyleSheetOrigin origin;

  /// Associated style declaration.
  final CSSStyle style;

  /// Media list array (for rules involving media queries). The array enumerates media queries starting with the innermost one, going outwards.
  final List<CSSMedia> media;

  CSSRule({
    this.styleSheetId,
    @required this.selectorList,
    @required this.origin,
    @required this.style,
    this.media,
  });
  factory CSSRule.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'selectorList': selectorList.toJson(),
      'origin': origin.toJson(),
      'style': style.toJson(),
    };
    if (styleSheetId != null) {
      json['styleSheetId'] = styleSheetId.toJson();
    }
    if (media != null) {
      json['media'] = media.map((e) => e.toJson()).toList();
    }
    return json;
  }
}

/// CSS coverage information.
class RuleUsage {
  /// The css style sheet identifier (absent for user agent stylesheet and user-specified stylesheet rules) this rule came from.
  final StyleSheetId styleSheetId;

  /// Offset of the start of the rule (including selector) from the beginning of the stylesheet.
  final num startOffset;

  /// Offset of the end of the rule body from the beginning of the stylesheet.
  final num endOffset;

  /// Indicates whether the rule was actually used by some element in the page.
  final bool used;

  RuleUsage({
    @required this.styleSheetId,
    @required this.startOffset,
    @required this.endOffset,
    @required this.used,
  });
  factory RuleUsage.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'styleSheetId': styleSheetId.toJson(),
      'startOffset': startOffset.toString(),
      'endOffset': endOffset.toString(),
      'used': used.toString(),
    };
    return json;
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

  SourceRange({
    @required this.startLine,
    @required this.startColumn,
    @required this.endLine,
    @required this.endColumn,
  });
  factory SourceRange.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'startLine': startLine.toString(),
      'startColumn': startColumn.toString(),
      'endLine': endLine.toString(),
      'endColumn': endColumn.toString(),
    };
    return json;
  }
}

class ShorthandEntry {
  /// Shorthand name.
  final String name;

  /// Shorthand value.
  final String value;

  /// Whether the property has "!important" annotation (implies <code>false</code> if absent).
  final bool important;

  ShorthandEntry({
    @required this.name,
    @required this.value,
    this.important,
  });
  factory ShorthandEntry.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'name': name.toString(),
      'value': value.toString(),
    };
    if (important != null) {
      json['important'] = important.toString();
    }
    return json;
  }
}

class CSSComputedStyleProperty {
  /// Computed style property name.
  final String name;

  /// Computed style property value.
  final String value;

  CSSComputedStyleProperty({
    @required this.name,
    @required this.value,
  });
  factory CSSComputedStyleProperty.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'name': name.toString(),
      'value': value.toString(),
    };
    return json;
  }
}

/// CSS style representation.
class CSSStyle {
  /// The css style sheet identifier (absent for user agent stylesheet and user-specified stylesheet rules) this rule came from.
  final StyleSheetId styleSheetId;

  /// CSS properties in the style.
  final List<CSSProperty> cssProperties;

  /// Computed values for all shorthands found in the style.
  final List<ShorthandEntry> shorthandEntries;

  /// Style declaration text (if available).
  final String cssText;

  /// Style declaration range in the enclosing stylesheet (if available).
  final SourceRange range;

  CSSStyle({
    this.styleSheetId,
    @required this.cssProperties,
    @required this.shorthandEntries,
    this.cssText,
    this.range,
  });
  factory CSSStyle.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'cssProperties': cssProperties.map((e) => e.toJson()).toList(),
      'shorthandEntries': shorthandEntries.map((e) => e.toJson()).toList(),
    };
    if (styleSheetId != null) {
      json['styleSheetId'] = styleSheetId.toJson();
    }
    if (cssText != null) {
      json['cssText'] = cssText.toString();
    }
    if (range != null) {
      json['range'] = range.toJson();
    }
    return json;
  }
}

/// CSS property declaration data.
class CSSProperty {
  /// The property name.
  final String name;

  /// The property value.
  final String value;

  /// Whether the property has "!important" annotation (implies <code>false</code> if absent).
  final bool important;

  /// Whether the property is implicit (implies <code>false</code> if absent).
  final bool implicit;

  /// The full property text as specified in the style.
  final String text;

  /// Whether the property is understood by the browser (implies <code>true</code> if absent).
  final bool parsedOk;

  /// Whether the property is disabled by the user (present for source-based properties only).
  final bool disabled;

  /// The entire property range in the enclosing style declaration (if available).
  final SourceRange range;

  CSSProperty({
    @required this.name,
    @required this.value,
    this.important,
    this.implicit,
    this.text,
    this.parsedOk,
    this.disabled,
    this.range,
  });
  factory CSSProperty.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'name': name.toString(),
      'value': value.toString(),
    };
    if (important != null) {
      json['important'] = important.toString();
    }
    if (implicit != null) {
      json['implicit'] = implicit.toString();
    }
    if (text != null) {
      json['text'] = text.toString();
    }
    if (parsedOk != null) {
      json['parsedOk'] = parsedOk.toString();
    }
    if (disabled != null) {
      json['disabled'] = disabled.toString();
    }
    if (range != null) {
      json['range'] = range.toJson();
    }
    return json;
  }
}

/// CSS media rule descriptor.
class CSSMedia {
  /// Media query text.
  final String text;

  /// Source of the media query: "mediaRule" if specified by a @media rule, "importRule" if specified by an @import rule, "linkedSheet" if specified by a "media" attribute in a linked stylesheet's LINK tag, "inlineSheet" if specified by a "media" attribute in an inline stylesheet's STYLE tag.
  final String source;

  /// URL of the document containing the media query description.
  final String sourceURL;

  /// The associated rule (@media or @import) header range in the enclosing stylesheet (if available).
  final SourceRange range;

  /// Identifier of the stylesheet containing this object (if exists).
  final StyleSheetId styleSheetId;

  /// Array of media queries.
  final List<MediaQuery> mediaList;

  CSSMedia({
    @required this.text,
    @required this.source,
    this.sourceURL,
    this.range,
    this.styleSheetId,
    this.mediaList,
  });
  factory CSSMedia.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'text': text.toString(),
      'source': source.toString(),
    };
    if (sourceURL != null) {
      json['sourceURL'] = sourceURL.toString();
    }
    if (range != null) {
      json['range'] = range.toJson();
    }
    if (styleSheetId != null) {
      json['styleSheetId'] = styleSheetId.toJson();
    }
    if (mediaList != null) {
      json['mediaList'] = mediaList.map((e) => e.toJson()).toList();
    }
    return json;
  }
}

/// Media query descriptor.
class MediaQuery {
  /// Array of media query expressions.
  final List<MediaQueryExpression> expressions;

  /// Whether the media query condition is satisfied.
  final bool active;

  MediaQuery({
    @required this.expressions,
    @required this.active,
  });
  factory MediaQuery.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'expressions': expressions.map((e) => e.toJson()).toList(),
      'active': active.toString(),
    };
    return json;
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
  final SourceRange valueRange;

  /// Computed length of media query expression (if applicable).
  final num computedLength;

  MediaQueryExpression({
    @required this.value,
    @required this.unit,
    @required this.feature,
    this.valueRange,
    this.computedLength,
  });
  factory MediaQueryExpression.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'value': value.toString(),
      'unit': unit.toString(),
      'feature': feature.toString(),
    };
    if (valueRange != null) {
      json['valueRange'] = valueRange.toJson();
    }
    if (computedLength != null) {
      json['computedLength'] = computedLength.toString();
    }
    return json;
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

  PlatformFontUsage({
    @required this.familyName,
    @required this.isCustomFont,
    @required this.glyphCount,
  });
  factory PlatformFontUsage.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'familyName': familyName.toString(),
      'isCustomFont': isCustomFont.toString(),
      'glyphCount': glyphCount.toString(),
    };
    return json;
  }
}

/// CSS keyframes rule representation.
class CSSKeyframesRule {
  /// Animation name.
  final Value animationName;

  /// List of keyframes.
  final List<CSSKeyframeRule> keyframes;

  CSSKeyframesRule({
    @required this.animationName,
    @required this.keyframes,
  });
  factory CSSKeyframesRule.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'animationName': animationName.toJson(),
      'keyframes': keyframes.map((e) => e.toJson()).toList(),
    };
    return json;
  }
}

/// CSS keyframe rule representation.
class CSSKeyframeRule {
  /// The css style sheet identifier (absent for user agent stylesheet and user-specified stylesheet rules) this rule came from.
  final StyleSheetId styleSheetId;

  /// Parent stylesheet's origin.
  final StyleSheetOrigin origin;

  /// Associated key text.
  final Value keyText;

  /// Associated style declaration.
  final CSSStyle style;

  CSSKeyframeRule({
    this.styleSheetId,
    @required this.origin,
    @required this.keyText,
    @required this.style,
  });
  factory CSSKeyframeRule.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'origin': origin.toJson(),
      'keyText': keyText.toJson(),
      'style': style.toJson(),
    };
    if (styleSheetId != null) {
      json['styleSheetId'] = styleSheetId.toJson();
    }
    return json;
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

  StyleDeclarationEdit({
    @required this.styleSheetId,
    @required this.range,
    @required this.text,
  });
  factory StyleDeclarationEdit.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'styleSheetId': styleSheetId.toJson(),
      'range': range.toJson(),
      'text': text.toString(),
    };
    return json;
  }
}

/// Details of post layout rendered text positions. The exact layout should not be regarded as stable and may change between versions.
class InlineTextBox {
  /// The absolute position bounding box.
  final dom.Rect boundingBox;

  /// The starting index in characters, for this post layout textbox substring.
  final int startCharacterIndex;

  /// The number of characters in this post layout textbox substring.
  final int numCharacters;

  InlineTextBox({
    @required this.boundingBox,
    @required this.startCharacterIndex,
    @required this.numCharacters,
  });
  factory InlineTextBox.fromJson(Map json) {}

  Map toJson() {
    Map json = {
      'boundingBox': boundingBox.toJson(),
      'startCharacterIndex': startCharacterIndex.toString(),
      'numCharacters': numCharacters.toString(),
    };
    return json;
  }
}
