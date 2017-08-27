import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';
import 'dom.dart' as dom;

class AccessibilityManager {
  final Session _client;

  AccessibilityManager(this._client);

  /// Fetches the accessibility node and partial accessibility tree for this DOM node, if it exists.
  /// [nodeId] ID of node to get the partial accessibility tree for.
  /// [fetchRelatives] Whether to fetch this nodes ancestors, siblings and children. Defaults to true.
  /// Return: The <code>Accessibility.AXNode</code> for this DOM node, if it exists, plus its ancestors, siblings and children, if requested.
  Future<List<AXNode>> getPartialAXTree(
    dom.NodeId nodeId, {
    bool fetchRelatives,
  }) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
    };
    if (fetchRelatives != null) {
      parameters['fetchRelatives'] = fetchRelatives;
    }
    await _client.send('Accessibility.getPartialAXTree', parameters);
  }
}

/// Unique accessibility node identifier.
class AXNodeId {
  final String value;

  AXNodeId(this.value);

  factory AXNodeId.fromJson(String value) => new AXNodeId(value);

  String toJson() => value;
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

  AXValueSource({
    @required this.type,
    this.value,
    this.attribute,
    this.attributeValue,
    this.superseded,
    this.nativeSource,
    this.nativeSourceValue,
    this.invalid,
    this.invalidReason,
  });

  factory AXValueSource.fromJson(Map json) {
    return new AXValueSource(
      type: new AXValueSourceType.fromJson(json['type']),
      value: json.containsKey('value')
          ? new AXValue.fromJson(json['value'])
          : null,
      attribute: json.containsKey('attribute') ? json['attribute'] : null,
      attributeValue: json.containsKey('attributeValue')
          ? new AXValue.fromJson(json['attributeValue'])
          : null,
      superseded: json.containsKey('superseded') ? json['superseded'] : null,
      nativeSource: json.containsKey('nativeSource')
          ? new AXValueNativeSourceType.fromJson(json['nativeSource'])
          : null,
      nativeSourceValue: json.containsKey('nativeSourceValue')
          ? new AXValue.fromJson(json['nativeSourceValue'])
          : null,
      invalid: json.containsKey('invalid') ? json['invalid'] : null,
      invalidReason:
          json.containsKey('invalidReason') ? json['invalidReason'] : null,
    );
  }

  Map toJson() {
    Map json = {
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

  AXRelatedNode({
    @required this.backendDOMNodeId,
    this.idref,
    this.text,
  });

  factory AXRelatedNode.fromJson(Map json) {
    return new AXRelatedNode(
      backendDOMNodeId:
          new dom.BackendNodeId.fromJson(json['backendDOMNodeId']),
      idref: json.containsKey('idref') ? json['idref'] : null,
      text: json.containsKey('text') ? json['text'] : null,
    );
  }

  Map toJson() {
    Map json = {
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
  final String name;

  /// The value of this property.
  final AXValue value;

  AXProperty({
    @required this.name,
    @required this.value,
  });

  factory AXProperty.fromJson(Map json) {
    return new AXProperty(
      name: json['name'],
      value: new AXValue.fromJson(json['value']),
    );
  }

  Map toJson() {
    Map json = {
      'name': name,
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

  AXValue({
    @required this.type,
    this.value,
    this.relatedNodes,
    this.sources,
  });

  factory AXValue.fromJson(Map json) {
    return new AXValue(
      type: new AXValueType.fromJson(json['type']),
      value: json.containsKey('value') ? json['value'] : null,
      relatedNodes: json.containsKey('relatedNodes')
          ? (json['relatedNodes'] as List)
              .map((e) => new AXRelatedNode.fromJson(e))
              .toList()
          : null,
      sources: json.containsKey('sources')
          ? (json['sources'] as List)
              .map((e) => new AXValueSource.fromJson(e))
              .toList()
          : null,
    );
  }

  Map toJson() {
    Map json = {
      'type': type.toJson(),
    };
    if (value != null) {
      json['value'] = value.toJson();
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

/// States which apply to every AX node.
class AXGlobalStates {
  static const AXGlobalStates disabled = const AXGlobalStates._('disabled');
  static const AXGlobalStates hidden = const AXGlobalStates._('hidden');
  static const AXGlobalStates hiddenRoot = const AXGlobalStates._('hiddenRoot');
  static const AXGlobalStates invalid = const AXGlobalStates._('invalid');
  static const AXGlobalStates keyshortcuts =
      const AXGlobalStates._('keyshortcuts');
  static const AXGlobalStates roledescription =
      const AXGlobalStates._('roledescription');
  static const values = const {
    'disabled': disabled,
    'hidden': hidden,
    'hiddenRoot': hiddenRoot,
    'invalid': invalid,
    'keyshortcuts': keyshortcuts,
    'roledescription': roledescription,
  };

  final String value;

  const AXGlobalStates._(this.value);

  factory AXGlobalStates.fromJson(String value) => values[value];

  String toJson() => value;
}

/// Attributes which apply to nodes in live regions.
class AXLiveRegionAttributes {
  static const AXLiveRegionAttributes live =
      const AXLiveRegionAttributes._('live');
  static const AXLiveRegionAttributes atomic =
      const AXLiveRegionAttributes._('atomic');
  static const AXLiveRegionAttributes relevant =
      const AXLiveRegionAttributes._('relevant');
  static const AXLiveRegionAttributes busy =
      const AXLiveRegionAttributes._('busy');
  static const AXLiveRegionAttributes root =
      const AXLiveRegionAttributes._('root');
  static const values = const {
    'live': live,
    'atomic': atomic,
    'relevant': relevant,
    'busy': busy,
    'root': root,
  };

  final String value;

  const AXLiveRegionAttributes._(this.value);

  factory AXLiveRegionAttributes.fromJson(String value) => values[value];

  String toJson() => value;
}

/// Attributes which apply to widgets.
class AXWidgetAttributes {
  static const AXWidgetAttributes autocomplete =
      const AXWidgetAttributes._('autocomplete');
  static const AXWidgetAttributes haspopup =
      const AXWidgetAttributes._('haspopup');
  static const AXWidgetAttributes level = const AXWidgetAttributes._('level');
  static const AXWidgetAttributes multiselectable =
      const AXWidgetAttributes._('multiselectable');
  static const AXWidgetAttributes orientation =
      const AXWidgetAttributes._('orientation');
  static const AXWidgetAttributes multiline =
      const AXWidgetAttributes._('multiline');
  static const AXWidgetAttributes readonly =
      const AXWidgetAttributes._('readonly');
  static const AXWidgetAttributes required =
      const AXWidgetAttributes._('required');
  static const AXWidgetAttributes valuemin =
      const AXWidgetAttributes._('valuemin');
  static const AXWidgetAttributes valuemax =
      const AXWidgetAttributes._('valuemax');
  static const AXWidgetAttributes valuetext =
      const AXWidgetAttributes._('valuetext');
  static const values = const {
    'autocomplete': autocomplete,
    'haspopup': haspopup,
    'level': level,
    'multiselectable': multiselectable,
    'orientation': orientation,
    'multiline': multiline,
    'readonly': readonly,
    'required': required,
    'valuemin': valuemin,
    'valuemax': valuemax,
    'valuetext': valuetext,
  };

  final String value;

  const AXWidgetAttributes._(this.value);

  factory AXWidgetAttributes.fromJson(String value) => values[value];

  String toJson() => value;
}

/// States which apply to widgets.
class AXWidgetStates {
  static const AXWidgetStates checked = const AXWidgetStates._('checked');
  static const AXWidgetStates expanded = const AXWidgetStates._('expanded');
  static const AXWidgetStates modal = const AXWidgetStates._('modal');
  static const AXWidgetStates pressed = const AXWidgetStates._('pressed');
  static const AXWidgetStates selected = const AXWidgetStates._('selected');
  static const values = const {
    'checked': checked,
    'expanded': expanded,
    'modal': modal,
    'pressed': pressed,
    'selected': selected,
  };

  final String value;

  const AXWidgetStates._(this.value);

  factory AXWidgetStates.fromJson(String value) => values[value];

  String toJson() => value;
}

/// Relationships between elements other than parent/child/sibling.
class AXRelationshipAttributes {
  static const AXRelationshipAttributes activedescendant =
      const AXRelationshipAttributes._('activedescendant');
  static const AXRelationshipAttributes controls =
      const AXRelationshipAttributes._('controls');
  static const AXRelationshipAttributes describedby =
      const AXRelationshipAttributes._('describedby');
  static const AXRelationshipAttributes details =
      const AXRelationshipAttributes._('details');
  static const AXRelationshipAttributes errormessage =
      const AXRelationshipAttributes._('errormessage');
  static const AXRelationshipAttributes flowto =
      const AXRelationshipAttributes._('flowto');
  static const AXRelationshipAttributes labelledby =
      const AXRelationshipAttributes._('labelledby');
  static const AXRelationshipAttributes owns =
      const AXRelationshipAttributes._('owns');
  static const values = const {
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

  const AXRelationshipAttributes._(this.value);

  factory AXRelationshipAttributes.fromJson(String value) => values[value];

  String toJson() => value;
}

/// A node in the accessibility tree.
class AXNode {
  /// Unique identifier for this node.
  final AXNodeId nodeId;

  /// Whether this node is ignored for accessibility
  final bool ignored;

  /// Collection of reasons why this node is hidden.
  final List<AXProperty> ignoredReasons;

  /// This <code>Node</code>'s role, whether explicit or implicit.
  final AXValue role;

  /// The accessible name for this <code>Node</code>.
  final AXValue name;

  /// The accessible description for this <code>Node</code>.
  final AXValue description;

  /// The value for this <code>Node</code>.
  final AXValue value;

  /// All other properties
  final List<AXProperty> properties;

  /// IDs for each of this node's child nodes.
  final List<AXNodeId> childIds;

  /// The backend ID for the associated DOM node, if any.
  final dom.BackendNodeId backendDOMNodeId;

  AXNode({
    @required this.nodeId,
    @required this.ignored,
    this.ignoredReasons,
    this.role,
    this.name,
    this.description,
    this.value,
    this.properties,
    this.childIds,
    this.backendDOMNodeId,
  });

  factory AXNode.fromJson(Map json) {
    return new AXNode(
      nodeId: new AXNodeId.fromJson(json['nodeId']),
      ignored: json['ignored'],
      ignoredReasons: json.containsKey('ignoredReasons')
          ? (json['ignoredReasons'] as List)
              .map((e) => new AXProperty.fromJson(e))
              .toList()
          : null,
      role:
          json.containsKey('role') ? new AXValue.fromJson(json['role']) : null,
      name:
          json.containsKey('name') ? new AXValue.fromJson(json['name']) : null,
      description: json.containsKey('description')
          ? new AXValue.fromJson(json['description'])
          : null,
      value: json.containsKey('value')
          ? new AXValue.fromJson(json['value'])
          : null,
      properties: json.containsKey('properties')
          ? (json['properties'] as List)
              .map((e) => new AXProperty.fromJson(e))
              .toList()
          : null,
      childIds: json.containsKey('childIds')
          ? (json['childIds'] as List)
              .map((e) => new AXNodeId.fromJson(e))
              .toList()
          : null,
      backendDOMNodeId: json.containsKey('backendDOMNodeId')
          ? new dom.BackendNodeId.fromJson(json['backendDOMNodeId'])
          : null,
    );
  }

  Map toJson() {
    Map json = {
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
