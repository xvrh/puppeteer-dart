import 'dart:async';
import '../src/connection.dart';
import 'dom.dart' as dom;
import 'page.dart' as page;
import 'runtime.dart' as runtime;

class AccessibilityApi {
  final Client _client;

  AccessibilityApi(this._client);

  /// The loadComplete event mirrors the load complete event sent by the browser to assistive
  /// technology when the web page has finished loading.
  Stream<AXNodeData> get onLoadComplete => _client.onEvent
      .where((event) => event.name == 'Accessibility.loadComplete')
      .map((event) => AXNodeData.fromJson(
          event.parameters['root'] as Map<String, dynamic>));

  /// The nodesUpdated event is sent every time a previously requested node has changed the in tree.
  Stream<List<AXNodeData>> get onNodesUpdated => _client.onEvent
      .where((event) => event.name == 'Accessibility.nodesUpdated')
      .map((event) => (event.parameters['nodes'] as List)
          .map((e) => AXNodeData.fromJson(e as Map<String, dynamic>))
          .toList());

  /// Disables the accessibility domain.
  Future<void> disable() async {
    await _client.send('Accessibility.disable');
  }

  /// Enables the accessibility domain which causes `AXNodeId`s to remain consistent between method calls.
  /// This turns on accessibility for the page, which can impact performance until accessibility is disabled.
  Future<void> enable() async {
    await _client.send('Accessibility.enable');
  }

  /// Fetches the accessibility node and partial accessibility tree for this DOM node, if it exists.
  /// [nodeId] Identifier of the node to get the partial accessibility tree for.
  /// [backendNodeId] Identifier of the backend node to get the partial accessibility tree for.
  /// [objectId] JavaScript object id of the node wrapper to get the partial accessibility tree for.
  /// [fetchRelatives] Whether to fetch this nodes ancestors, siblings and children. Defaults to true.
  /// Returns: The `Accessibility.AXNode` for this DOM node, if it exists, plus its ancestors, siblings and
  /// children, if requested.
  Future<List<AXNodeData>> getPartialAXTree(
      {dom.NodeId? nodeId,
      dom.BackendNodeId? backendNodeId,
      runtime.RemoteObjectId? objectId,
      bool? fetchRelatives}) async {
    var result = await _client.send('Accessibility.getPartialAXTree', {
      if (nodeId != null) 'nodeId': nodeId,
      if (backendNodeId != null) 'backendNodeId': backendNodeId,
      if (objectId != null) 'objectId': objectId,
      if (fetchRelatives != null) 'fetchRelatives': fetchRelatives,
    });
    return (result['nodes'] as List)
        .map((e) => AXNodeData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches the entire accessibility tree for the root Document
  /// [depth] The maximum depth at which descendants of the root node should be retrieved.
  /// If omitted, the full tree is returned.
  /// [frameId] The frame for whose document the AX tree should be retrieved.
  /// If omited, the root frame is used.
  Future<List<AXNodeData>> getFullAXTree(
      {int? depth, page.FrameId? frameId}) async {
    var result = await _client.send('Accessibility.getFullAXTree', {
      if (depth != null) 'depth': depth,
      if (frameId != null) 'frameId': frameId,
    });
    return (result['nodes'] as List)
        .map((e) => AXNodeData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches the root node.
  /// Requires `enable()` to have been called previously.
  /// [frameId] The frame in whose document the node resides.
  /// If omitted, the root frame is used.
  Future<AXNodeData> getRootAXNode({page.FrameId? frameId}) async {
    var result = await _client.send('Accessibility.getRootAXNode', {
      if (frameId != null) 'frameId': frameId,
    });
    return AXNodeData.fromJson(result['node'] as Map<String, dynamic>);
  }

  /// Fetches a node and all ancestors up to and including the root.
  /// Requires `enable()` to have been called previously.
  /// [nodeId] Identifier of the node to get.
  /// [backendNodeId] Identifier of the backend node to get.
  /// [objectId] JavaScript object id of the node wrapper to get.
  Future<List<AXNodeData>> getAXNodeAndAncestors(
      {dom.NodeId? nodeId,
      dom.BackendNodeId? backendNodeId,
      runtime.RemoteObjectId? objectId}) async {
    var result = await _client.send('Accessibility.getAXNodeAndAncestors', {
      if (nodeId != null) 'nodeId': nodeId,
      if (backendNodeId != null) 'backendNodeId': backendNodeId,
      if (objectId != null) 'objectId': objectId,
    });
    return (result['nodes'] as List)
        .map((e) => AXNodeData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a particular accessibility node by AXNodeId.
  /// Requires `enable()` to have been called previously.
  /// [frameId] The frame in whose document the node resides.
  /// If omitted, the root frame is used.
  Future<List<AXNodeData>> getChildAXNodes(AXNodeId id,
      {page.FrameId? frameId}) async {
    var result = await _client.send('Accessibility.getChildAXNodes', {
      'id': id,
      if (frameId != null) 'frameId': frameId,
    });
    return (result['nodes'] as List)
        .map((e) => AXNodeData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Query a DOM node's accessibility subtree for accessible name and role.
  /// This command computes the name and role for all nodes in the subtree, including those that are
  /// ignored for accessibility, and returns those that mactch the specified name and role. If no DOM
  /// node is specified, or the DOM node does not exist, the command returns an error. If neither
  /// `accessibleName` or `role` is specified, it returns all the accessibility nodes in the subtree.
  /// [nodeId] Identifier of the node for the root to query.
  /// [backendNodeId] Identifier of the backend node for the root to query.
  /// [objectId] JavaScript object id of the node wrapper for the root to query.
  /// [accessibleName] Find nodes with this computed name.
  /// [role] Find nodes with this computed role.
  /// Returns: A list of `Accessibility.AXNode` matching the specified attributes,
  /// including nodes that are ignored for accessibility.
  Future<List<AXNodeData>> queryAXTree(
      {dom.NodeId? nodeId,
      dom.BackendNodeId? backendNodeId,
      runtime.RemoteObjectId? objectId,
      String? accessibleName,
      String? role}) async {
    var result = await _client.send('Accessibility.queryAXTree', {
      if (nodeId != null) 'nodeId': nodeId,
      if (backendNodeId != null) 'backendNodeId': backendNodeId,
      if (objectId != null) 'objectId': objectId,
      if (accessibleName != null) 'accessibleName': accessibleName,
      if (role != null) 'role': role,
    });
    return (result['nodes'] as List)
        .map((e) => AXNodeData.fromJson(e as Map<String, dynamic>))
        .toList();
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
  static const boolean = AXValueType._('boolean');
  static const tristate = AXValueType._('tristate');
  static const booleanOrUndefined = AXValueType._('booleanOrUndefined');
  static const idref = AXValueType._('idref');
  static const idrefList = AXValueType._('idrefList');
  static const integer = AXValueType._('integer');
  static const node = AXValueType._('node');
  static const nodeList = AXValueType._('nodeList');
  static const number = AXValueType._('number');
  static const string = AXValueType._('string');
  static const computedString = AXValueType._('computedString');
  static const token = AXValueType._('token');
  static const tokenList = AXValueType._('tokenList');
  static const domRelation = AXValueType._('domRelation');
  static const role = AXValueType._('role');
  static const internalRole = AXValueType._('internalRole');
  static const valueUndefined = AXValueType._('valueUndefined');
  static const values = {
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

  factory AXValueType.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is AXValueType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Enum of possible property sources.
class AXValueSourceType {
  static const attribute = AXValueSourceType._('attribute');
  static const implicit = AXValueSourceType._('implicit');
  static const style = AXValueSourceType._('style');
  static const contents = AXValueSourceType._('contents');
  static const placeholder = AXValueSourceType._('placeholder');
  static const relatedElement = AXValueSourceType._('relatedElement');
  static const values = {
    'attribute': attribute,
    'implicit': implicit,
    'style': style,
    'contents': contents,
    'placeholder': placeholder,
    'relatedElement': relatedElement,
  };

  final String value;

  const AXValueSourceType._(this.value);

  factory AXValueSourceType.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is AXValueSourceType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Enum of possible native property sources (as a subtype of a particular AXValueSourceType).
class AXValueNativeSourceType {
  static const description = AXValueNativeSourceType._('description');
  static const figcaption = AXValueNativeSourceType._('figcaption');
  static const label = AXValueNativeSourceType._('label');
  static const labelfor = AXValueNativeSourceType._('labelfor');
  static const labelwrapped = AXValueNativeSourceType._('labelwrapped');
  static const legend = AXValueNativeSourceType._('legend');
  static const rubyannotation = AXValueNativeSourceType._('rubyannotation');
  static const tablecaption = AXValueNativeSourceType._('tablecaption');
  static const title = AXValueNativeSourceType._('title');
  static const other = AXValueNativeSourceType._('other');
  static const values = {
    'description': description,
    'figcaption': figcaption,
    'label': label,
    'labelfor': labelfor,
    'labelwrapped': labelwrapped,
    'legend': legend,
    'rubyannotation': rubyannotation,
    'tablecaption': tablecaption,
    'title': title,
    'other': other,
  };

  final String value;

  const AXValueNativeSourceType._(this.value);

  factory AXValueNativeSourceType.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is AXValueNativeSourceType && other.value == value) ||
      value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// A single source for a computed AX property.
class AXValueSource {
  /// What type of source this is.
  final AXValueSourceType type;

  /// The value of this property source.
  final AXValue? value;

  /// The name of the relevant attribute, if any.
  final String? attribute;

  /// The value of the relevant attribute, if any.
  final AXValue? attributeValue;

  /// Whether this source is superseded by a higher priority source.
  final bool? superseded;

  /// The native markup source for this value, e.g. a <label> element.
  final AXValueNativeSourceType? nativeSource;

  /// The value, such as a node or node list, of the native source.
  final AXValue? nativeSourceValue;

  /// Whether the value for this property is invalid.
  final bool? invalid;

  /// Reason for the value being invalid, if it is.
  final String? invalidReason;

  AXValueSource(
      {required this.type,
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
      type: AXValueSourceType.fromJson(json['type'] as String),
      value: json.containsKey('value')
          ? AXValue.fromJson(json['value'] as Map<String, dynamic>)
          : null,
      attribute:
          json.containsKey('attribute') ? json['attribute'] as String : null,
      attributeValue: json.containsKey('attributeValue')
          ? AXValue.fromJson(json['attributeValue'] as Map<String, dynamic>)
          : null,
      superseded:
          json.containsKey('superseded') ? json['superseded'] as bool : null,
      nativeSource: json.containsKey('nativeSource')
          ? AXValueNativeSourceType.fromJson(json['nativeSource'] as String)
          : null,
      nativeSourceValue: json.containsKey('nativeSourceValue')
          ? AXValue.fromJson(json['nativeSourceValue'] as Map<String, dynamic>)
          : null,
      invalid: json.containsKey('invalid') ? json['invalid'] as bool : null,
      invalidReason: json.containsKey('invalidReason')
          ? json['invalidReason'] as String
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      if (value != null) 'value': value!.toJson(),
      if (attribute != null) 'attribute': attribute,
      if (attributeValue != null) 'attributeValue': attributeValue!.toJson(),
      if (superseded != null) 'superseded': superseded,
      if (nativeSource != null) 'nativeSource': nativeSource!.toJson(),
      if (nativeSourceValue != null)
        'nativeSourceValue': nativeSourceValue!.toJson(),
      if (invalid != null) 'invalid': invalid,
      if (invalidReason != null) 'invalidReason': invalidReason,
    };
  }
}

class AXRelatedNode {
  /// The BackendNodeId of the related DOM node.
  final dom.BackendNodeId backendDOMNodeId;

  /// The IDRef value provided, if any.
  final String? idref;

  /// The text alternative of this node in the current context.
  final String? text;

  AXRelatedNode({required this.backendDOMNodeId, this.idref, this.text});

  factory AXRelatedNode.fromJson(Map<String, dynamic> json) {
    return AXRelatedNode(
      backendDOMNodeId:
          dom.BackendNodeId.fromJson(json['backendDOMNodeId'] as int),
      idref: json.containsKey('idref') ? json['idref'] as String : null,
      text: json.containsKey('text') ? json['text'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backendDOMNodeId': backendDOMNodeId.toJson(),
      if (idref != null) 'idref': idref,
      if (text != null) 'text': text,
    };
  }
}

class AXProperty {
  /// The name of this property.
  final AXPropertyName name;

  /// The value of this property.
  final AXValue value;

  AXProperty({required this.name, required this.value});

  factory AXProperty.fromJson(Map<String, dynamic> json) {
    return AXProperty(
      name: AXPropertyName.fromJson(json['name'] as String),
      value: AXValue.fromJson(json['value'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(),
      'value': value.toJson(),
    };
  }
}

/// A single computed AX property.
class AXValue {
  /// The type of this value.
  final AXValueType type;

  /// The computed value of this property.
  final dynamic value;

  /// One or more related nodes, if applicable.
  final List<AXRelatedNode>? relatedNodes;

  /// The sources which contributed to the computation of this property.
  final List<AXValueSource>? sources;

  AXValue({required this.type, this.value, this.relatedNodes, this.sources});

  factory AXValue.fromJson(Map<String, dynamic> json) {
    return AXValue(
      type: AXValueType.fromJson(json['type'] as String),
      value: json.containsKey('value') ? json['value'] as dynamic : null,
      relatedNodes: json.containsKey('relatedNodes')
          ? (json['relatedNodes'] as List)
              .map((e) => AXRelatedNode.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      sources: json.containsKey('sources')
          ? (json['sources'] as List)
              .map((e) => AXValueSource.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      if (value != null) 'value': value,
      if (relatedNodes != null)
        'relatedNodes': relatedNodes!.map((e) => e.toJson()).toList(),
      if (sources != null) 'sources': sources!.map((e) => e.toJson()).toList(),
    };
  }
}

/// Values of AXProperty name:
/// - from 'busy' to 'roledescription': states which apply to every AX node
/// - from 'live' to 'root': attributes which apply to nodes in live regions
/// - from 'autocomplete' to 'valuetext': attributes which apply to widgets
/// - from 'checked' to 'selected': states which apply to widgets
/// - from 'activedescendant' to 'owns' - relationships between elements other than parent/child/sibling.
class AXPropertyName {
  static const busy = AXPropertyName._('busy');
  static const disabled = AXPropertyName._('disabled');
  static const editable = AXPropertyName._('editable');
  static const focusable = AXPropertyName._('focusable');
  static const focused = AXPropertyName._('focused');
  static const hidden = AXPropertyName._('hidden');
  static const hiddenRoot = AXPropertyName._('hiddenRoot');
  static const invalid = AXPropertyName._('invalid');
  static const keyshortcuts = AXPropertyName._('keyshortcuts');
  static const settable = AXPropertyName._('settable');
  static const roledescription = AXPropertyName._('roledescription');
  static const live = AXPropertyName._('live');
  static const atomic = AXPropertyName._('atomic');
  static const relevant = AXPropertyName._('relevant');
  static const root = AXPropertyName._('root');
  static const autocomplete = AXPropertyName._('autocomplete');
  static const hasPopup = AXPropertyName._('hasPopup');
  static const level = AXPropertyName._('level');
  static const multiselectable = AXPropertyName._('multiselectable');
  static const orientation = AXPropertyName._('orientation');
  static const multiline = AXPropertyName._('multiline');
  static const readonly = AXPropertyName._('readonly');
  static const required = AXPropertyName._('required');
  static const valuemin = AXPropertyName._('valuemin');
  static const valuemax = AXPropertyName._('valuemax');
  static const valuetext = AXPropertyName._('valuetext');
  static const checked = AXPropertyName._('checked');
  static const expanded = AXPropertyName._('expanded');
  static const modal = AXPropertyName._('modal');
  static const pressed = AXPropertyName._('pressed');
  static const selected = AXPropertyName._('selected');
  static const activedescendant = AXPropertyName._('activedescendant');
  static const controls = AXPropertyName._('controls');
  static const describedby = AXPropertyName._('describedby');
  static const details = AXPropertyName._('details');
  static const errormessage = AXPropertyName._('errormessage');
  static const flowto = AXPropertyName._('flowto');
  static const labelledby = AXPropertyName._('labelledby');
  static const owns = AXPropertyName._('owns');
  static const uninteresting = AXPropertyName._('uninteresting');
  static const ariaHiddenElement = AXPropertyName._('ariaHiddenElement');
  static const ariaHiddenSubtree = AXPropertyName._('ariaHiddenSubtree');
  static const notRendered = AXPropertyName._('notRendered');
  static const values = {
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
    'uninteresting': uninteresting,
    'ariaHiddenElement': ariaHiddenElement,
    'ariaHiddenSubtree': ariaHiddenSubtree,
    'notRendered': notRendered,
  };

  final String value;

  const AXPropertyName._(this.value);

  factory AXPropertyName.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is AXPropertyName && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// A node in the accessibility tree.
class AXNodeData {
  /// Unique identifier for this node.
  final AXNodeId nodeId;

  /// Whether this node is ignored for accessibility
  final bool ignored;

  /// Collection of reasons why this node is hidden.
  final List<AXProperty>? ignoredReasons;

  /// This `Node`'s role, whether explicit or implicit.
  final AXValue? role;

  /// The accessible name for this `Node`.
  final AXValue? name;

  /// The accessible description for this `Node`.
  final AXValue? description;

  /// The value for this `Node`.
  final AXValue? value;

  /// All other properties
  final List<AXProperty>? properties;

  /// ID for this node's parent.
  final AXNodeId? parentId;

  /// IDs for each of this node's child nodes.
  final List<AXNodeId>? childIds;

  /// The backend ID for the associated DOM node, if any.
  final dom.BackendNodeId? backendDOMNodeId;

  /// The frame ID for the frame associated with this nodes document.
  final page.FrameId? frameId;

  AXNodeData(
      {required this.nodeId,
      required this.ignored,
      this.ignoredReasons,
      this.role,
      this.name,
      this.description,
      this.value,
      this.properties,
      this.parentId,
      this.childIds,
      this.backendDOMNodeId,
      this.frameId});

  factory AXNodeData.fromJson(Map<String, dynamic> json) {
    return AXNodeData(
      nodeId: AXNodeId.fromJson(json['nodeId'] as String),
      ignored: json['ignored'] as bool? ?? false,
      ignoredReasons: json.containsKey('ignoredReasons')
          ? (json['ignoredReasons'] as List)
              .map((e) => AXProperty.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      role: json.containsKey('role')
          ? AXValue.fromJson(json['role'] as Map<String, dynamic>)
          : null,
      name: json.containsKey('name')
          ? AXValue.fromJson(json['name'] as Map<String, dynamic>)
          : null,
      description: json.containsKey('description')
          ? AXValue.fromJson(json['description'] as Map<String, dynamic>)
          : null,
      value: json.containsKey('value')
          ? AXValue.fromJson(json['value'] as Map<String, dynamic>)
          : null,
      properties: json.containsKey('properties')
          ? (json['properties'] as List)
              .map((e) => AXProperty.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      parentId: json.containsKey('parentId')
          ? AXNodeId.fromJson(json['parentId'] as String)
          : null,
      childIds: json.containsKey('childIds')
          ? (json['childIds'] as List)
              .map((e) => AXNodeId.fromJson(e as String))
              .toList()
          : null,
      backendDOMNodeId: json.containsKey('backendDOMNodeId')
          ? dom.BackendNodeId.fromJson(json['backendDOMNodeId'] as int)
          : null,
      frameId: json.containsKey('frameId')
          ? page.FrameId.fromJson(json['frameId'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nodeId': nodeId.toJson(),
      'ignored': ignored,
      if (ignoredReasons != null)
        'ignoredReasons': ignoredReasons!.map((e) => e.toJson()).toList(),
      if (role != null) 'role': role!.toJson(),
      if (name != null) 'name': name!.toJson(),
      if (description != null) 'description': description!.toJson(),
      if (value != null) 'value': value!.toJson(),
      if (properties != null)
        'properties': properties!.map((e) => e.toJson()).toList(),
      if (parentId != null) 'parentId': parentId!.toJson(),
      if (childIds != null)
        'childIds': childIds!.map((e) => e.toJson()).toList(),
      if (backendDOMNodeId != null)
        'backendDOMNodeId': backendDOMNodeId!.toJson(),
      if (frameId != null) 'frameId': frameId!.toJson(),
    };
  }
}
