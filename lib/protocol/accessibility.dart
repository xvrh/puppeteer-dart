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
      .map(
        (event) => AXNodeData.fromJson(
          event.parameters['root'] as Map<String, dynamic>,
        ),
      );

  /// The nodesUpdated event is sent every time a previously requested node has changed the in tree.
  Stream<List<AXNodeData>> get onNodesUpdated => _client.onEvent
      .where((event) => event.name == 'Accessibility.nodesUpdated')
      .map(
        (event) => (event.parameters['nodes'] as List)
            .map((e) => AXNodeData.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

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
  /// [fetchRelatives] Whether to fetch this node's ancestors, siblings and children. Defaults to true.
  /// Returns: The `Accessibility.AXNode` for this DOM node, if it exists, plus its ancestors, siblings and
  /// children, if requested.
  Future<List<AXNodeData>> getPartialAXTree({
    dom.NodeId? nodeId,
    dom.BackendNodeId? backendNodeId,
    runtime.RemoteObjectId? objectId,
    bool? fetchRelatives,
  }) async {
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
  /// If omitted, the root frame is used.
  Future<List<AXNodeData>> getFullAXTree({
    int? depth,
    page.FrameId? frameId,
  }) async {
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
  Future<List<AXNodeData>> getAXNodeAndAncestors({
    dom.NodeId? nodeId,
    dom.BackendNodeId? backendNodeId,
    runtime.RemoteObjectId? objectId,
  }) async {
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
  Future<List<AXNodeData>> getChildAXNodes(
    AXNodeId id, {
    page.FrameId? frameId,
  }) async {
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
  /// ignored for accessibility, and returns those that match the specified name and role. If no DOM
  /// node is specified, or the DOM node does not exist, the command returns an error. If neither
  /// `accessibleName` or `role` is specified, it returns all the accessibility nodes in the subtree.
  /// [nodeId] Identifier of the node for the root to query.
  /// [backendNodeId] Identifier of the backend node for the root to query.
  /// [objectId] JavaScript object id of the node wrapper for the root to query.
  /// [accessibleName] Find nodes with this computed name.
  /// [role] Find nodes with this computed role.
  /// Returns: A list of `Accessibility.AXNode` matching the specified attributes,
  /// including nodes that are ignored for accessibility.
  Future<List<AXNodeData>> queryAXTree({
    dom.NodeId? nodeId,
    dom.BackendNodeId? backendNodeId,
    runtime.RemoteObjectId? objectId,
    String? accessibleName,
    String? role,
  }) async {
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
extension type AXNodeId(String value) {
  factory AXNodeId.fromJson(String value) => AXNodeId(value);

  String toJson() => value;
}

/// Enum of possible property types.
enum AXValueType {
  boolean('boolean'),
  tristate('tristate'),
  booleanOrUndefined('booleanOrUndefined'),
  idref('idref'),
  idrefList('idrefList'),
  integer('integer'),
  node('node'),
  nodeList('nodeList'),
  number('number'),
  string('string'),
  computedString('computedString'),
  token('token'),
  tokenList('tokenList'),
  domRelation('domRelation'),
  role('role'),
  internalRole('internalRole'),
  valueUndefined('valueUndefined');

  final String value;

  const AXValueType(this.value);

  factory AXValueType.fromJson(String value) =>
      AXValueType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Enum of possible property sources.
enum AXValueSourceType {
  attribute('attribute'),
  implicit('implicit'),
  style('style'),
  contents('contents'),
  placeholder('placeholder'),
  relatedElement('relatedElement');

  final String value;

  const AXValueSourceType(this.value);

  factory AXValueSourceType.fromJson(String value) =>
      AXValueSourceType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value.toString();
}

/// Enum of possible native property sources (as a subtype of a particular AXValueSourceType).
enum AXValueNativeSourceType {
  description('description'),
  figcaption('figcaption'),
  label('label'),
  labelfor('labelfor'),
  labelwrapped('labelwrapped'),
  legend('legend'),
  rubyannotation('rubyannotation'),
  tablecaption('tablecaption'),
  title('title'),
  other('other');

  final String value;

  const AXValueNativeSourceType(this.value);

  factory AXValueNativeSourceType.fromJson(String value) =>
      AXValueNativeSourceType.values.firstWhere((e) => e.value == value);

  String toJson() => value;

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

  /// The native markup source for this value, e.g. a `<label>` element.
  final AXValueNativeSourceType? nativeSource;

  /// The value, such as a node or node list, of the native source.
  final AXValue? nativeSourceValue;

  /// Whether the value for this property is invalid.
  final bool? invalid;

  /// Reason for the value being invalid, if it is.
  final String? invalidReason;

  AXValueSource({
    required this.type,
    this.value,
    this.attribute,
    this.attributeValue,
    this.superseded,
    this.nativeSource,
    this.nativeSourceValue,
    this.invalid,
    this.invalidReason,
  });

  factory AXValueSource.fromJson(Map<String, dynamic> json) {
    return AXValueSource(
      type: AXValueSourceType.fromJson(json['type'] as String),
      value: json.containsKey('value')
          ? AXValue.fromJson(json['value'] as Map<String, dynamic>)
          : null,
      attribute: json.containsKey('attribute')
          ? json['attribute'] as String
          : null,
      attributeValue: json.containsKey('attributeValue')
          ? AXValue.fromJson(json['attributeValue'] as Map<String, dynamic>)
          : null,
      superseded: json.containsKey('superseded')
          ? json['superseded'] as bool
          : null,
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
      backendDOMNodeId: dom.BackendNodeId.fromJson(
        json['backendDOMNodeId'] as int,
      ),
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
    return {'name': name.toJson(), 'value': value.toJson()};
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
enum AXPropertyName {
  actions('actions'),
  busy('busy'),
  disabled('disabled'),
  editable('editable'),
  focusable('focusable'),
  focused('focused'),
  hidden('hidden'),
  hiddenRoot('hiddenRoot'),
  invalid('invalid'),
  keyshortcuts('keyshortcuts'),
  settable('settable'),
  roledescription('roledescription'),
  live('live'),
  atomic('atomic'),
  relevant('relevant'),
  root('root'),
  autocomplete('autocomplete'),
  hasPopup('hasPopup'),
  level('level'),
  multiselectable('multiselectable'),
  orientation('orientation'),
  multiline('multiline'),
  readonly('readonly'),
  required('required'),
  valuemin('valuemin'),
  valuemax('valuemax'),
  valuetext('valuetext'),
  checked('checked'),
  expanded('expanded'),
  modal('modal'),
  pressed('pressed'),
  selected('selected'),
  activedescendant('activedescendant'),
  controls('controls'),
  describedby('describedby'),
  details('details'),
  errormessage('errormessage'),
  flowto('flowto'),
  labelledby('labelledby'),
  owns('owns'),
  url('url'),
  uninteresting('uninteresting'),
  ariaHiddenElement('ariaHiddenElement'),
  ariaHiddenSubtree('ariaHiddenSubtree'),
  notRendered('notRendered'),
  notVisible('notVisible'),
  labelFor('labelFor'),
  presentationalRole('presentationalRole'),
  emptyAlt('emptyAlt');

  final String value;

  const AXPropertyName(this.value);

  factory AXPropertyName.fromJson(String value) =>
      AXPropertyName.values.firstWhere((e) => e.value == value);

  String toJson() => value;

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

  /// This `Node`'s Chrome raw role.
  final AXValue? chromeRole;

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

  AXNodeData({
    required this.nodeId,
    required this.ignored,
    this.ignoredReasons,
    this.role,
    this.chromeRole,
    this.name,
    this.description,
    this.value,
    this.properties,
    this.parentId,
    this.childIds,
    this.backendDOMNodeId,
    this.frameId,
  });

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
      chromeRole: json.containsKey('chromeRole')
          ? AXValue.fromJson(json['chromeRole'] as Map<String, dynamic>)
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
      if (chromeRole != null) 'chromeRole': chromeRole!.toJson(),
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
