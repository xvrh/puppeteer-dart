import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'dom.dart' as dom;
import 'runtime.dart' as runtime;

class AccessibilityApi {
  final Client _client;

  AccessibilityApi(this._client);

  /// Disables the accessibility domain.
  Future disable() async {
    await _client.send('Accessibility.disable');
  }

  /// Enables the accessibility domain which causes `AXNodeId`s to remain consistent between method calls.
  /// This turns on accessibility for the page, which can impact performance until accessibility is disabled.
  Future enable() async {
    await _client.send('Accessibility.enable');
  }

  /// Fetches the accessibility node and partial accessibility tree for this DOM node, if it exists.
  /// [nodeId] Identifier of the node to get the partial accessibility tree for.
  /// [backendNodeId] Identifier of the backend node to get the partial accessibility tree for.
  /// [objectId] JavaScript object id of the node wrapper to get the partial accessibility tree for.
  /// [fetchRelatives] Whether to fetch this nodes ancestors, siblings and children. Defaults to true.
  /// Returns: The `Accessibility.AXNode` for this DOM node, if it exists, plus its ancestors, siblings and
  /// children, if requested.
  Future<List<AXNode>> getPartialAXTree(
      {dom.NodeId nodeId,
      dom.BackendNodeId backendNodeId,
      runtime.RemoteObjectId objectId,
      bool fetchRelatives}) async {
    var parameters = <String, dynamic>{};
    if (nodeId != null) {
      parameters['nodeId'] = nodeId.toJson();
    }
    if (backendNodeId != null) {
      parameters['backendNodeId'] = backendNodeId.toJson();
    }
    if (objectId != null) {
      parameters['objectId'] = objectId.toJson();
    }
    if (fetchRelatives != null) {
      parameters['fetchRelatives'] = fetchRelatives;
    }
    var result =
        await _client.send('Accessibility.getPartialAXTree', parameters);
    return (result['nodes'] as List).map((e) => AXNode.fromJson(e)).toList();
  }

  /// Fetches the entire accessibility tree
  Future<List<AXNode>> getFullAXTree() async {
    var result = await _client.send('Accessibility.getFullAXTree');
    return (result['nodes'] as List).map((e) => AXNode.fromJson(e)).toList();
  }
}

/// Unique accessibility node identifier.
class AXNodeId {
  final String value;

  AXNodeId(this.value);

  factory AXNodeId.fromJson(String value) => AXNodeId(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is AXNodeId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Enum of possible property types.
class AXValueType {
  static const AXValueType boolean = const AXValueType._('boolean');
  static const AXValueType tristate = const AXValueType._('tristate');
  static const AXValueType booleanOrUndefined =
      const AXValueType._('booleanOrUndefined');
  static const AXValueType idref = const AXValueType._('idref');
  static const AXValueType idrefList = const AXValueType._('idrefList');
  static const AXValueType integer = const AXValueType._('integer');
  static const AXValueType node = const AXValueType._('node');
  static const AXValueType nodeList = const AXValueType._('nodeList');
  static const AXValueType number = const AXValueType._('number');
  static const AXValueType string = const AXValueType._('string');
  static const AXValueType computedString =
      const AXValueType._('computedString');
  static const AXValueType token = const AXValueType._('token');
  static const AXValueType tokenList = const AXValueType._('tokenList');
  static const AXValueType domRelation = const AXValueType._('domRelation');
  static const AXValueType role = const AXValueType._('role');
  static const AXValueType internalRole = const AXValueType._('internalRole');
  static const AXValueType valueUndefined =
      const AXValueType._('valueUndefined');
  static const values = const {
    'boolean': boolean,
    'tristate': tristate,
    'booleanOrUndefined': booleanOrUndefined,
    'idref': idref,
    'idrefList': idrefList,
    'integer': integer,
    'node': node,
    'nodeList': nodeList,
    'number': number,
    'string': string,
    'computedString': computedString,
    'token': token,
    'tokenList': tokenList,
    'domRelation': domRelation,
    'role': role,
    'internalRole': internalRole,
    'valueUndefined': valueUndefined,
  };

  final String value;

  const AXValueType._(this.value);

  factory AXValueType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Enum of possible property sources.
class AXValueSourceType {
  static const AXValueSourceType attribute =
      const AXValueSourceType._('attribute');
  static const AXValueSourceType implicit =
      const AXValueSourceType._('implicit');
  static const AXValueSourceType style = const AXValueSourceType._('style');
  static const AXValueSourceType contents =
      const AXValueSourceType._('contents');
  static const AXValueSourceType placeholder =
      const AXValueSourceType._('placeholder');
  static const AXValueSourceType relatedElement =
      const AXValueSourceType._('relatedElement');
  static const values = const {
    'attribute': attribute,
    'implicit': implicit,
    'style': style,
    'contents': contents,
    'placeholder': placeholder,
    'relatedElement': relatedElement,
  };

  final String value;

  const AXValueSourceType._(this.value);

  factory AXValueSourceType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Enum of possible native property sources (as a subtype of a particular AXValueSourceType).
class AXValueNativeSourceType {
  static const AXValueNativeSourceType figcaption =
      const AXValueNativeSourceType._('figcaption');
  static const AXValueNativeSourceType label =
      const AXValueNativeSourceType._('label');
  static const AXValueNativeSourceType labelfor =
      const AXValueNativeSourceType._('labelfor');
  static const AXValueNativeSourceType labelwrapped =
      const AXValueNativeSourceType._('labelwrapped');
  static const AXValueNativeSourceType legend =
      const AXValueNativeSourceType._('legend');
  static const AXValueNativeSourceType tablecaption =
      const AXValueNativeSourceType._('tablecaption');
  static const AXValueNativeSourceType title =
      const AXValueNativeSourceType._('title');
  static const AXValueNativeSourceType other =
      const AXValueNativeSourceType._('other');
  static const values = const {
    'figcaption': figcaption,
    'label': label,
    'labelfor': labelfor,
    'labelwrapped': labelwrapped,
    'legend': legend,
    'tablecaption': tablecaption,
    'title': title,
    'other': other,
  };

  final String value;

  const AXValueNativeSourceType._(this.value);

  factory AXValueNativeSourceType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// A single source for a computed AX property.
class AXValueSource {
  /// What type of source this is.
  final AXValueSourceType type;

  /// The value of this property source.
  final AXValue value;

  /// The name of the relevant attribute, if any.
  final String attribute;

  /// The value of the relevant attribute, if any.
  final AXValue attributeValue;

  /// Whether this source is superseded by a higher priority source.
  final bool superseded;

  /// The native markup source for this value, e.g. a <label> element.
  final AXValueNativeSourceType nativeSource;

  /// The value, such as a node or node list, of the native source.
  final AXValue nativeSourceValue;

  /// Whether the value for this property is invalid.
  final bool invalid;

  /// Reason for the value being invalid, if it is.
  final String invalidReason;

  AXValueSource(
      {@required this.type,
      this.value,
      this.attribute,
      this.attributeValue,
      this.superseded,
      this.nativeSource,
      this.nativeSourceValue,
      this.invalid,
      this.invalidReason});

  factory AXValueSource.fromJson(Map<String, dynamic> json) {
    return AXValueSource(
      type: AXValueSourceType.fromJson(json['type']),
      value: json.containsKey('value') ? AXValue.fromJson(json['value']) : null,
      attribute: json.containsKey('attribute') ? json['attribute'] : null,
      attributeValue: json.containsKey('attributeValue')
          ? AXValue.fromJson(json['attributeValue'])
          : null,
      superseded: json.containsKey('superseded') ? json['superseded'] : null,
      nativeSource: json.containsKey('nativeSource')
          ? AXValueNativeSourceType.fromJson(json['nativeSource'])
          : null,
      nativeSourceValue: json.containsKey('nativeSourceValue')
          ? AXValue.fromJson(json['nativeSourceValue'])
          : null,
      invalid: json.containsKey('invalid') ? json['invalid'] : null,
      invalidReason:
          json.containsKey('invalidReason') ? json['invalidReason'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'type': type.toJson(),
    };
    if (value != null) {
      json['value'] = value.toJson();
    }
    if (attribute != null) {
      json['attribute'] = attribute;
    }
    if (attributeValue != null) {
      json['attributeValue'] = attributeValue.toJson();
    }
    if (superseded != null) {
      json['superseded'] = superseded;
    }
    if (nativeSource != null) {
      json['nativeSource'] = nativeSource.toJson();
    }
    if (nativeSourceValue != null) {
      json['nativeSourceValue'] = nativeSourceValue.toJson();
    }
    if (invalid != null) {
      json['invalid'] = invalid;
    }
    if (invalidReason != null) {
      json['invalidReason'] = invalidReason;
    }
    return json;
  }
}

class AXRelatedNode {
  /// The BackendNodeId of the related DOM node.
  final dom.BackendNodeId backendDOMNodeId;

  /// The IDRef value provided, if any.
  final String idref;

  /// The text alternative of this node in the current context.
  final String text;

  AXRelatedNode({@required this.backendDOMNodeId, this.idref, this.text});

  factory AXRelatedNode.fromJson(Map<String, dynamic> json) {
    return AXRelatedNode(
      backendDOMNodeId: dom.BackendNodeId.fromJson(json['backendDOMNodeId']),
      idref: json.containsKey('idref') ? json['idref'] : null,
      text: json.containsKey('text') ? json['text'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'backendDOMNodeId': backendDOMNodeId.toJson(),
    };
    if (idref != null) {
      json['idref'] = idref;
    }
    if (text != null) {
      json['text'] = text;
    }
    return json;
  }
}

class AXProperty {
  /// The name of this property.
  final AXPropertyName name;

  /// The value of this property.
  final AXValue value;

  AXProperty({@required this.name, @required this.value});

  factory AXProperty.fromJson(Map<String, dynamic> json) {
    return AXProperty(
      name: AXPropertyName.fromJson(json['name']),
      value: AXValue.fromJson(json['value']),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'name': name.toJson(),
      'value': value.toJson(),
    };
    return json;
  }
}

/// A single computed AX property.
class AXValue {
  /// The type of this value.
  final AXValueType type;

  /// The computed value of this property.
  final dynamic value;

  /// One or more related nodes, if applicable.
  final List<AXRelatedNode> relatedNodes;

  /// The sources which contributed to the computation of this property.
  final List<AXValueSource> sources;

  AXValue({@required this.type, this.value, this.relatedNodes, this.sources});

  factory AXValue.fromJson(Map<String, dynamic> json) {
    return AXValue(
      type: AXValueType.fromJson(json['type']),
      value: json.containsKey('value') ? json['value'] : null,
      relatedNodes: json.containsKey('relatedNodes')
          ? (json['relatedNodes'] as List)
              .map((e) => AXRelatedNode.fromJson(e))
              .toList()
          : null,
      sources: json.containsKey('sources')
          ? (json['sources'] as List)
              .map((e) => AXValueSource.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'type': type.toJson(),
    };
    if (value != null) {
      json['value'] = value;
    }
    if (relatedNodes != null) {
      json['relatedNodes'] = relatedNodes.map((e) => e.toJson()).toList();
    }
    if (sources != null) {
      json['sources'] = sources.map((e) => e.toJson()).toList();
    }
    return json;
  }
}

/// Values of AXProperty name:
/// - from 'busy' to 'roledescription': states which apply to every AX node
/// - from 'live' to 'root': attributes which apply to nodes in live regions
/// - from 'autocomplete' to 'valuetext': attributes which apply to widgets
/// - from 'checked' to 'selected': states which apply to widgets
/// - from 'activedescendant' to 'owns' - relationships between elements other than parent/child/sibling.
class AXPropertyName {
  static const AXPropertyName busy = const AXPropertyName._('busy');
  static const AXPropertyName disabled = const AXPropertyName._('disabled');
  static const AXPropertyName editable = const AXPropertyName._('editable');
  static const AXPropertyName focusable = const AXPropertyName._('focusable');
  static const AXPropertyName focused = const AXPropertyName._('focused');
  static const AXPropertyName hidden = const AXPropertyName._('hidden');
  static const AXPropertyName hiddenRoot = const AXPropertyName._('hiddenRoot');
  static const AXPropertyName invalid = const AXPropertyName._('invalid');
  static const AXPropertyName keyshortcuts =
      const AXPropertyName._('keyshortcuts');
  static const AXPropertyName settable = const AXPropertyName._('settable');
  static const AXPropertyName roledescription =
      const AXPropertyName._('roledescription');
  static const AXPropertyName live = const AXPropertyName._('live');
  static const AXPropertyName atomic = const AXPropertyName._('atomic');
  static const AXPropertyName relevant = const AXPropertyName._('relevant');
  static const AXPropertyName root = const AXPropertyName._('root');
  static const AXPropertyName autocomplete =
      const AXPropertyName._('autocomplete');
  static const AXPropertyName hasPopup = const AXPropertyName._('hasPopup');
  static const AXPropertyName level = const AXPropertyName._('level');
  static const AXPropertyName multiselectable =
      const AXPropertyName._('multiselectable');
  static const AXPropertyName orientation =
      const AXPropertyName._('orientation');
  static const AXPropertyName multiline = const AXPropertyName._('multiline');
  static const AXPropertyName readonly = const AXPropertyName._('readonly');
  static const AXPropertyName required = const AXPropertyName._('required');
  static const AXPropertyName valuemin = const AXPropertyName._('valuemin');
  static const AXPropertyName valuemax = const AXPropertyName._('valuemax');
  static const AXPropertyName valuetext = const AXPropertyName._('valuetext');
  static const AXPropertyName checked = const AXPropertyName._('checked');
  static const AXPropertyName expanded = const AXPropertyName._('expanded');
  static const AXPropertyName modal = const AXPropertyName._('modal');
  static const AXPropertyName pressed = const AXPropertyName._('pressed');
  static const AXPropertyName selected = const AXPropertyName._('selected');
  static const AXPropertyName activedescendant =
      const AXPropertyName._('activedescendant');
  static const AXPropertyName controls = const AXPropertyName._('controls');
  static const AXPropertyName describedby =
      const AXPropertyName._('describedby');
  static const AXPropertyName details = const AXPropertyName._('details');
  static const AXPropertyName errormessage =
      const AXPropertyName._('errormessage');
  static const AXPropertyName flowto = const AXPropertyName._('flowto');
  static const AXPropertyName labelledby = const AXPropertyName._('labelledby');
  static const AXPropertyName owns = const AXPropertyName._('owns');
  static const values = const {
    'busy': busy,
    'disabled': disabled,
    'editable': editable,
    'focusable': focusable,
    'focused': focused,
    'hidden': hidden,
    'hiddenRoot': hiddenRoot,
    'invalid': invalid,
    'keyshortcuts': keyshortcuts,
    'settable': settable,
    'roledescription': roledescription,
    'live': live,
    'atomic': atomic,
    'relevant': relevant,
    'root': root,
    'autocomplete': autocomplete,
    'hasPopup': hasPopup,
    'level': level,
    'multiselectable': multiselectable,
    'orientation': orientation,
    'multiline': multiline,
    'readonly': readonly,
    'required': required,
    'valuemin': valuemin,
    'valuemax': valuemax,
    'valuetext': valuetext,
    'checked': checked,
    'expanded': expanded,
    'modal': modal,
    'pressed': pressed,
    'selected': selected,
    'activedescendant': activedescendant,
    'controls': controls,
    'describedby': describedby,
    'details': details,
    'errormessage': errormessage,
    'flowto': flowto,
    'labelledby': labelledby,
    'owns': owns,
  };

  final String value;

  const AXPropertyName._(this.value);

  factory AXPropertyName.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// A node in the accessibility tree.
class AXNode {
  /// Unique identifier for this node.
  final AXNodeId nodeId;

  /// Whether this node is ignored for accessibility
  final bool ignored;

  /// Collection of reasons why this node is hidden.
  final List<AXProperty> ignoredReasons;

  /// This `Node`'s role, whether explicit or implicit.
  final AXValue role;

  /// The accessible name for this `Node`.
  final AXValue name;

  /// The accessible description for this `Node`.
  final AXValue description;

  /// The value for this `Node`.
  final AXValue value;

  /// All other properties
  final List<AXProperty> properties;

  /// IDs for each of this node's child nodes.
  final List<AXNodeId> childIds;

  /// The backend ID for the associated DOM node, if any.
  final dom.BackendNodeId backendDOMNodeId;

  AXNode(
      {@required this.nodeId,
      @required this.ignored,
      this.ignoredReasons,
      this.role,
      this.name,
      this.description,
      this.value,
      this.properties,
      this.childIds,
      this.backendDOMNodeId});

  factory AXNode.fromJson(Map<String, dynamic> json) {
    return AXNode(
      nodeId: AXNodeId.fromJson(json['nodeId']),
      ignored: json['ignored'],
      ignoredReasons: json.containsKey('ignoredReasons')
          ? (json['ignoredReasons'] as List)
              .map((e) => AXProperty.fromJson(e))
              .toList()
          : null,
      role: json.containsKey('role') ? AXValue.fromJson(json['role']) : null,
      name: json.containsKey('name') ? AXValue.fromJson(json['name']) : null,
      description: json.containsKey('description')
          ? AXValue.fromJson(json['description'])
          : null,
      value: json.containsKey('value') ? AXValue.fromJson(json['value']) : null,
      properties: json.containsKey('properties')
          ? (json['properties'] as List)
              .map((e) => AXProperty.fromJson(e))
              .toList()
          : null,
      childIds: json.containsKey('childIds')
          ? (json['childIds'] as List).map((e) => AXNodeId.fromJson(e)).toList()
          : null,
      backendDOMNodeId: json.containsKey('backendDOMNodeId')
          ? dom.BackendNodeId.fromJson(json['backendDOMNodeId'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'nodeId': nodeId.toJson(),
      'ignored': ignored,
    };
    if (ignoredReasons != null) {
      json['ignoredReasons'] = ignoredReasons.map((e) => e.toJson()).toList();
    }
    if (role != null) {
      json['role'] = role.toJson();
    }
    if (name != null) {
      json['name'] = name.toJson();
    }
    if (description != null) {
      json['description'] = description.toJson();
    }
    if (value != null) {
      json['value'] = value.toJson();
    }
    if (properties != null) {
      json['properties'] = properties.map((e) => e.toJson()).toList();
    }
    if (childIds != null) {
      json['childIds'] = childIds.map((e) => e.toJson()).toList();
    }
    if (backendDOMNodeId != null) {
      json['backendDOMNodeId'] = backendDOMNodeId.toJson();
    }
    return json;
  }
}
