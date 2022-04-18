import 'dart:async';
import '../src/connection.dart';
import 'dom.dart' as dom;
import 'page.dart' as page;
import 'runtime.dart' as runtime;

/// This domain exposes DOM read/write operations. Each DOM Node is represented with its mirror object
/// that has an `id`. This `id` can be used to get additional information on the Node, resolve it into
/// the JavaScript object wrapper, etc. It is important that client receives DOM events only for the
/// nodes that are known to the client. Backend keeps track of the nodes that were sent to the client
/// and never sends the same node twice. It is client's responsibility to collect information about
/// the nodes that were sent to the client.<p>Note that `iframe` owner elements will return
/// corresponding document elements as their child nodes.</p>
class DOMApi {
  final Client _client;

  DOMApi(this._client);

  /// Fired when `Element`'s attribute is modified.
  Stream<AttributeModifiedEvent> get onAttributeModified => _client.onEvent
      .where((event) => event.name == 'DOM.attributeModified')
      .map((event) => AttributeModifiedEvent.fromJson(event.parameters));

  /// Fired when `Element`'s attribute is removed.
  Stream<AttributeRemovedEvent> get onAttributeRemoved => _client.onEvent
      .where((event) => event.name == 'DOM.attributeRemoved')
      .map((event) => AttributeRemovedEvent.fromJson(event.parameters));

  /// Mirrors `DOMCharacterDataModified` event.
  Stream<CharacterDataModifiedEvent> get onCharacterDataModified => _client
      .onEvent
      .where((event) => event.name == 'DOM.characterDataModified')
      .map((event) => CharacterDataModifiedEvent.fromJson(event.parameters));

  /// Fired when `Container`'s child node count has changed.
  Stream<ChildNodeCountUpdatedEvent> get onChildNodeCountUpdated => _client
      .onEvent
      .where((event) => event.name == 'DOM.childNodeCountUpdated')
      .map((event) => ChildNodeCountUpdatedEvent.fromJson(event.parameters));

  /// Mirrors `DOMNodeInserted` event.
  Stream<ChildNodeInsertedEvent> get onChildNodeInserted => _client.onEvent
      .where((event) => event.name == 'DOM.childNodeInserted')
      .map((event) => ChildNodeInsertedEvent.fromJson(event.parameters));

  /// Mirrors `DOMNodeRemoved` event.
  Stream<ChildNodeRemovedEvent> get onChildNodeRemoved => _client.onEvent
      .where((event) => event.name == 'DOM.childNodeRemoved')
      .map((event) => ChildNodeRemovedEvent.fromJson(event.parameters));

  /// Called when distribution is changed.
  Stream<DistributedNodesUpdatedEvent> get onDistributedNodesUpdated => _client
      .onEvent
      .where((event) => event.name == 'DOM.distributedNodesUpdated')
      .map((event) => DistributedNodesUpdatedEvent.fromJson(event.parameters));

  /// Fired when `Document` has been totally updated. Node ids are no longer valid.
  Stream get onDocumentUpdated =>
      _client.onEvent.where((event) => event.name == 'DOM.documentUpdated');

  /// Fired when `Element`'s inline style is modified via a CSS property modification.
  Stream<List<NodeId>> get onInlineStyleInvalidated => _client.onEvent
      .where((event) => event.name == 'DOM.inlineStyleInvalidated')
      .map((event) => (event.parameters['nodeIds'] as List)
          .map((e) => NodeId.fromJson(e as int))
          .toList());

  /// Called when a pseudo element is added to an element.
  Stream<PseudoElementAddedEvent> get onPseudoElementAdded => _client.onEvent
      .where((event) => event.name == 'DOM.pseudoElementAdded')
      .map((event) => PseudoElementAddedEvent.fromJson(event.parameters));

  /// Called when a pseudo element is removed from an element.
  Stream<PseudoElementRemovedEvent> get onPseudoElementRemoved =>
      _client.onEvent
          .where((event) => event.name == 'DOM.pseudoElementRemoved')
          .map((event) => PseudoElementRemovedEvent.fromJson(event.parameters));

  /// Fired when backend wants to provide client with the missing DOM structure. This happens upon
  /// most of the calls requesting node ids.
  Stream<SetChildNodesEvent> get onSetChildNodes => _client.onEvent
      .where((event) => event.name == 'DOM.setChildNodes')
      .map((event) => SetChildNodesEvent.fromJson(event.parameters));

  /// Called when shadow root is popped from the element.
  Stream<ShadowRootPoppedEvent> get onShadowRootPopped => _client.onEvent
      .where((event) => event.name == 'DOM.shadowRootPopped')
      .map((event) => ShadowRootPoppedEvent.fromJson(event.parameters));

  /// Called when shadow root is pushed into the element.
  Stream<ShadowRootPushedEvent> get onShadowRootPushed => _client.onEvent
      .where((event) => event.name == 'DOM.shadowRootPushed')
      .map((event) => ShadowRootPushedEvent.fromJson(event.parameters));

  /// Collects class names for the node with given id and all of it's child nodes.
  /// [nodeId] Id of the node to collect class names.
  /// Returns: Class name list.
  Future<List<String>> collectClassNamesFromSubtree(NodeId nodeId) async {
    var result = await _client.send('DOM.collectClassNamesFromSubtree', {
      'nodeId': nodeId,
    });
    return (result['classNames'] as List).map((e) => e as String).toList();
  }

  /// Creates a deep copy of the specified node and places it into the target container before the
  /// given anchor.
  /// [nodeId] Id of the node to copy.
  /// [targetNodeId] Id of the element to drop the copy into.
  /// [insertBeforeNodeId] Drop the copy before this node (if absent, the copy becomes the last child of
  /// `targetNodeId`).
  /// Returns: Id of the node clone.
  Future<NodeId> copyTo(NodeId nodeId, NodeId targetNodeId,
      {NodeId? insertBeforeNodeId}) async {
    var result = await _client.send('DOM.copyTo', {
      'nodeId': nodeId,
      'targetNodeId': targetNodeId,
      if (insertBeforeNodeId != null) 'insertBeforeNodeId': insertBeforeNodeId,
    });
    return NodeId.fromJson(result['nodeId'] as int);
  }

  /// Describes node given its id, does not require domain to be enabled. Does not start tracking any
  /// objects, can be used for automation.
  /// [nodeId] Identifier of the node.
  /// [backendNodeId] Identifier of the backend node.
  /// [objectId] JavaScript object id of the node wrapper.
  /// [depth] The maximum depth at which children should be retrieved, defaults to 1. Use -1 for the
  /// entire subtree or provide an integer larger than 0.
  /// [pierce] Whether or not iframes and shadow roots should be traversed when returning the subtree
  /// (default is false).
  /// Returns: Node description.
  Future<Node> describeNode(
      {NodeId? nodeId,
      BackendNodeId? backendNodeId,
      runtime.RemoteObjectId? objectId,
      int? depth,
      bool? pierce}) async {
    var result = await _client.send('DOM.describeNode', {
      if (nodeId != null) 'nodeId': nodeId,
      if (backendNodeId != null) 'backendNodeId': backendNodeId,
      if (objectId != null) 'objectId': objectId,
      if (depth != null) 'depth': depth,
      if (pierce != null) 'pierce': pierce,
    });
    return Node.fromJson(result['node'] as Map<String, dynamic>);
  }

  /// Scrolls the specified rect of the given node into view if not already visible.
  /// Note: exactly one between nodeId, backendNodeId and objectId should be passed
  /// to identify the node.
  /// [nodeId] Identifier of the node.
  /// [backendNodeId] Identifier of the backend node.
  /// [objectId] JavaScript object id of the node wrapper.
  /// [rect] The rect to be scrolled into view, relative to the node's border box, in CSS pixels.
  /// When omitted, center of the node will be used, similar to Element.scrollIntoView.
  Future<void> scrollIntoViewIfNeeded(
      {NodeId? nodeId,
      BackendNodeId? backendNodeId,
      runtime.RemoteObjectId? objectId,
      Rect? rect}) async {
    await _client.send('DOM.scrollIntoViewIfNeeded', {
      if (nodeId != null) 'nodeId': nodeId,
      if (backendNodeId != null) 'backendNodeId': backendNodeId,
      if (objectId != null) 'objectId': objectId,
      if (rect != null) 'rect': rect,
    });
  }

  /// Disables DOM agent for the given page.
  Future<void> disable() async {
    await _client.send('DOM.disable');
  }

  /// Discards search results from the session with the given id. `getSearchResults` should no longer
  /// be called for that search.
  /// [searchId] Unique search session identifier.
  Future<void> discardSearchResults(String searchId) async {
    await _client.send('DOM.discardSearchResults', {
      'searchId': searchId,
    });
  }

  /// Enables DOM agent for the given page.
  /// [includeWhitespace] Whether to include whitespaces in the children array of returned Nodes.
  Future<void> enable(
      {@Enum(['none', 'all']) String? includeWhitespace}) async {
    assert(includeWhitespace == null ||
        const ['none', 'all'].contains(includeWhitespace));
    await _client.send('DOM.enable', {
      if (includeWhitespace != null) 'includeWhitespace': includeWhitespace,
    });
  }

  /// Focuses the given element.
  /// [nodeId] Identifier of the node.
  /// [backendNodeId] Identifier of the backend node.
  /// [objectId] JavaScript object id of the node wrapper.
  Future<void> focus(
      {NodeId? nodeId,
      BackendNodeId? backendNodeId,
      runtime.RemoteObjectId? objectId}) async {
    await _client.send('DOM.focus', {
      if (nodeId != null) 'nodeId': nodeId,
      if (backendNodeId != null) 'backendNodeId': backendNodeId,
      if (objectId != null) 'objectId': objectId,
    });
  }

  /// Returns attributes for the specified node.
  /// [nodeId] Id of the node to retrieve attibutes for.
  /// Returns: An interleaved array of node attribute names and values.
  Future<List<String>> getAttributes(NodeId nodeId) async {
    var result = await _client.send('DOM.getAttributes', {
      'nodeId': nodeId,
    });
    return (result['attributes'] as List).map((e) => e as String).toList();
  }

  /// Returns boxes for the given node.
  /// [nodeId] Identifier of the node.
  /// [backendNodeId] Identifier of the backend node.
  /// [objectId] JavaScript object id of the node wrapper.
  /// Returns: Box model for the node.
  Future<BoxModel> getBoxModel(
      {NodeId? nodeId,
      BackendNodeId? backendNodeId,
      runtime.RemoteObjectId? objectId}) async {
    var result = await _client.send('DOM.getBoxModel', {
      if (nodeId != null) 'nodeId': nodeId,
      if (backendNodeId != null) 'backendNodeId': backendNodeId,
      if (objectId != null) 'objectId': objectId,
    });
    return BoxModel.fromJson(result['model'] as Map<String, dynamic>);
  }

  /// Returns quads that describe node position on the page. This method
  /// might return multiple quads for inline nodes.
  /// [nodeId] Identifier of the node.
  /// [backendNodeId] Identifier of the backend node.
  /// [objectId] JavaScript object id of the node wrapper.
  /// Returns: Quads that describe node layout relative to viewport.
  Future<List<Quad>> getContentQuads(
      {NodeId? nodeId,
      BackendNodeId? backendNodeId,
      runtime.RemoteObjectId? objectId}) async {
    var result = await _client.send('DOM.getContentQuads', {
      if (nodeId != null) 'nodeId': nodeId,
      if (backendNodeId != null) 'backendNodeId': backendNodeId,
      if (objectId != null) 'objectId': objectId,
    });
    return (result['quads'] as List)
        .map((e) => Quad.fromJson(e as List))
        .toList();
  }

  /// Returns the root DOM node (and optionally the subtree) to the caller.
  /// [depth] The maximum depth at which children should be retrieved, defaults to 1. Use -1 for the
  /// entire subtree or provide an integer larger than 0.
  /// [pierce] Whether or not iframes and shadow roots should be traversed when returning the subtree
  /// (default is false).
  /// Returns: Resulting node.
  Future<Node> getDocument({int? depth, bool? pierce}) async {
    var result = await _client.send('DOM.getDocument', {
      if (depth != null) 'depth': depth,
      if (pierce != null) 'pierce': pierce,
    });
    return Node.fromJson(result['root'] as Map<String, dynamic>);
  }

  /// Returns the root DOM node (and optionally the subtree) to the caller.
  /// Deprecated, as it is not designed to work well with the rest of the DOM agent.
  /// Use DOMSnapshot.captureSnapshot instead.
  /// [depth] The maximum depth at which children should be retrieved, defaults to 1. Use -1 for the
  /// entire subtree or provide an integer larger than 0.
  /// [pierce] Whether or not iframes and shadow roots should be traversed when returning the subtree
  /// (default is false).
  /// Returns: Resulting node.
  @Deprecated('Use DOMSnapshot.captureSnapshot instead')
  Future<List<Node>> getFlattenedDocument({int? depth, bool? pierce}) async {
    var result = await _client.send('DOM.getFlattenedDocument', {
      if (depth != null) 'depth': depth,
      if (pierce != null) 'pierce': pierce,
    });
    return (result['nodes'] as List)
        .map((e) => Node.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Finds nodes with a given computed style in a subtree.
  /// [nodeId] Node ID pointing to the root of a subtree.
  /// [computedStyles] The style to filter nodes by (includes nodes if any of properties matches).
  /// [pierce] Whether or not iframes and shadow roots in the same target should be traversed when returning the
  /// results (default is false).
  /// Returns: Resulting nodes.
  Future<List<NodeId>> getNodesForSubtreeByStyle(
      NodeId nodeId, List<CSSComputedStyleProperty> computedStyles,
      {bool? pierce}) async {
    var result = await _client.send('DOM.getNodesForSubtreeByStyle', {
      'nodeId': nodeId,
      'computedStyles': [...computedStyles],
      if (pierce != null) 'pierce': pierce,
    });
    return (result['nodeIds'] as List)
        .map((e) => NodeId.fromJson(e as int))
        .toList();
  }

  /// Returns node id at given location. Depending on whether DOM domain is enabled, nodeId is
  /// either returned or not.
  /// [x] X coordinate.
  /// [y] Y coordinate.
  /// [includeUserAgentShadowDOM] False to skip to the nearest non-UA shadow root ancestor (default: false).
  /// [ignorePointerEventsNone] Whether to ignore pointer-events: none on elements and hit test them.
  Future<GetNodeForLocationResult> getNodeForLocation(int x, int y,
      {bool? includeUserAgentShadowDOM, bool? ignorePointerEventsNone}) async {
    var result = await _client.send('DOM.getNodeForLocation', {
      'x': x,
      'y': y,
      if (includeUserAgentShadowDOM != null)
        'includeUserAgentShadowDOM': includeUserAgentShadowDOM,
      if (ignorePointerEventsNone != null)
        'ignorePointerEventsNone': ignorePointerEventsNone,
    });
    return GetNodeForLocationResult.fromJson(result);
  }

  /// Returns node's HTML markup.
  /// [nodeId] Identifier of the node.
  /// [backendNodeId] Identifier of the backend node.
  /// [objectId] JavaScript object id of the node wrapper.
  /// Returns: Outer HTML markup.
  Future<String> getOuterHTML(
      {NodeId? nodeId,
      BackendNodeId? backendNodeId,
      runtime.RemoteObjectId? objectId}) async {
    var result = await _client.send('DOM.getOuterHTML', {
      if (nodeId != null) 'nodeId': nodeId,
      if (backendNodeId != null) 'backendNodeId': backendNodeId,
      if (objectId != null) 'objectId': objectId,
    });
    return result['outerHTML'] as String;
  }

  /// Returns the id of the nearest ancestor that is a relayout boundary.
  /// [nodeId] Id of the node.
  /// Returns: Relayout boundary node id for the given node.
  Future<NodeId> getRelayoutBoundary(NodeId nodeId) async {
    var result = await _client.send('DOM.getRelayoutBoundary', {
      'nodeId': nodeId,
    });
    return NodeId.fromJson(result['nodeId'] as int);
  }

  /// Returns search results from given `fromIndex` to given `toIndex` from the search with the given
  /// identifier.
  /// [searchId] Unique search session identifier.
  /// [fromIndex] Start index of the search result to be returned.
  /// [toIndex] End index of the search result to be returned.
  /// Returns: Ids of the search result nodes.
  Future<List<NodeId>> getSearchResults(
      String searchId, int fromIndex, int toIndex) async {
    var result = await _client.send('DOM.getSearchResults', {
      'searchId': searchId,
      'fromIndex': fromIndex,
      'toIndex': toIndex,
    });
    return (result['nodeIds'] as List)
        .map((e) => NodeId.fromJson(e as int))
        .toList();
  }

  /// Hides any highlight.
  Future<void> hideHighlight() async {
    await _client.send('DOM.hideHighlight');
  }

  /// Highlights DOM node.
  Future<void> highlightNode() async {
    await _client.send('DOM.highlightNode');
  }

  /// Highlights given rectangle.
  Future<void> highlightRect() async {
    await _client.send('DOM.highlightRect');
  }

  /// Marks last undoable state.
  Future<void> markUndoableState() async {
    await _client.send('DOM.markUndoableState');
  }

  /// Moves node into the new container, places it before the given anchor.
  /// [nodeId] Id of the node to move.
  /// [targetNodeId] Id of the element to drop the moved node into.
  /// [insertBeforeNodeId] Drop node before this one (if absent, the moved node becomes the last child of
  /// `targetNodeId`).
  /// Returns: New id of the moved node.
  Future<NodeId> moveTo(NodeId nodeId, NodeId targetNodeId,
      {NodeId? insertBeforeNodeId}) async {
    var result = await _client.send('DOM.moveTo', {
      'nodeId': nodeId,
      'targetNodeId': targetNodeId,
      if (insertBeforeNodeId != null) 'insertBeforeNodeId': insertBeforeNodeId,
    });
    return NodeId.fromJson(result['nodeId'] as int);
  }

  /// Searches for a given string in the DOM tree. Use `getSearchResults` to access search results or
  /// `cancelSearch` to end this search session.
  /// [query] Plain text or query selector or XPath search query.
  /// [includeUserAgentShadowDOM] True to search in user agent shadow DOM.
  Future<PerformSearchResult> performSearch(String query,
      {bool? includeUserAgentShadowDOM}) async {
    var result = await _client.send('DOM.performSearch', {
      'query': query,
      if (includeUserAgentShadowDOM != null)
        'includeUserAgentShadowDOM': includeUserAgentShadowDOM,
    });
    return PerformSearchResult.fromJson(result);
  }

  /// Requests that the node is sent to the caller given its path. // FIXME, use XPath
  /// [path] Path to node in the proprietary format.
  /// Returns: Id of the node for given path.
  Future<NodeId> pushNodeByPathToFrontend(String path) async {
    var result = await _client.send('DOM.pushNodeByPathToFrontend', {
      'path': path,
    });
    return NodeId.fromJson(result['nodeId'] as int);
  }

  /// Requests that a batch of nodes is sent to the caller given their backend node ids.
  /// [backendNodeIds] The array of backend node ids.
  /// Returns: The array of ids of pushed nodes that correspond to the backend ids specified in
  /// backendNodeIds.
  Future<List<NodeId>> pushNodesByBackendIdsToFrontend(
      List<BackendNodeId> backendNodeIds) async {
    var result = await _client.send('DOM.pushNodesByBackendIdsToFrontend', {
      'backendNodeIds': [...backendNodeIds],
    });
    return (result['nodeIds'] as List)
        .map((e) => NodeId.fromJson(e as int))
        .toList();
  }

  /// Executes `querySelector` on a given node.
  /// [nodeId] Id of the node to query upon.
  /// [selector] Selector string.
  /// Returns: Query selector result.
  Future<NodeId> querySelector(NodeId nodeId, String selector) async {
    var result = await _client.send('DOM.querySelector', {
      'nodeId': nodeId,
      'selector': selector,
    });
    return NodeId.fromJson(result['nodeId'] as int);
  }

  /// Executes `querySelectorAll` on a given node.
  /// [nodeId] Id of the node to query upon.
  /// [selector] Selector string.
  /// Returns: Query selector result.
  Future<List<NodeId>> querySelectorAll(NodeId nodeId, String selector) async {
    var result = await _client.send('DOM.querySelectorAll', {
      'nodeId': nodeId,
      'selector': selector,
    });
    return (result['nodeIds'] as List)
        .map((e) => NodeId.fromJson(e as int))
        .toList();
  }

  /// Re-does the last undone action.
  Future<void> redo() async {
    await _client.send('DOM.redo');
  }

  /// Removes attribute with given name from an element with given id.
  /// [nodeId] Id of the element to remove attribute from.
  /// [name] Name of the attribute to remove.
  Future<void> removeAttribute(NodeId nodeId, String name) async {
    await _client.send('DOM.removeAttribute', {
      'nodeId': nodeId,
      'name': name,
    });
  }

  /// Removes node with given id.
  /// [nodeId] Id of the node to remove.
  Future<void> removeNode(NodeId nodeId) async {
    await _client.send('DOM.removeNode', {
      'nodeId': nodeId,
    });
  }

  /// Requests that children of the node with given id are returned to the caller in form of
  /// `setChildNodes` events where not only immediate children are retrieved, but all children down to
  /// the specified depth.
  /// [nodeId] Id of the node to get children for.
  /// [depth] The maximum depth at which children should be retrieved, defaults to 1. Use -1 for the
  /// entire subtree or provide an integer larger than 0.
  /// [pierce] Whether or not iframes and shadow roots should be traversed when returning the sub-tree
  /// (default is false).
  Future<void> requestChildNodes(NodeId nodeId,
      {int? depth, bool? pierce}) async {
    await _client.send('DOM.requestChildNodes', {
      'nodeId': nodeId,
      if (depth != null) 'depth': depth,
      if (pierce != null) 'pierce': pierce,
    });
  }

  /// Requests that the node is sent to the caller given the JavaScript node object reference. All
  /// nodes that form the path from the node to the root are also sent to the client as a series of
  /// `setChildNodes` notifications.
  /// [objectId] JavaScript object id to convert into node.
  /// Returns: Node id for given object.
  Future<NodeId> requestNode(runtime.RemoteObjectId objectId) async {
    var result = await _client.send('DOM.requestNode', {
      'objectId': objectId,
    });
    return NodeId.fromJson(result['nodeId'] as int);
  }

  /// Resolves the JavaScript node object for a given NodeId or BackendNodeId.
  /// [nodeId] Id of the node to resolve.
  /// [backendNodeId] Backend identifier of the node to resolve.
  /// [objectGroup] Symbolic group name that can be used to release multiple objects.
  /// [executionContextId] Execution context in which to resolve the node.
  /// Returns: JavaScript object wrapper for given node.
  Future<runtime.RemoteObject> resolveNode(
      {NodeId? nodeId,
      dom.BackendNodeId? backendNodeId,
      String? objectGroup,
      runtime.ExecutionContextId? executionContextId}) async {
    var result = await _client.send('DOM.resolveNode', {
      if (nodeId != null) 'nodeId': nodeId,
      if (backendNodeId != null) 'backendNodeId': backendNodeId,
      if (objectGroup != null) 'objectGroup': objectGroup,
      if (executionContextId != null) 'executionContextId': executionContextId,
    });
    return runtime.RemoteObject.fromJson(
        result['object'] as Map<String, dynamic>);
  }

  /// Sets attribute for an element with given id.
  /// [nodeId] Id of the element to set attribute for.
  /// [name] Attribute name.
  /// [value] Attribute value.
  Future<void> setAttributeValue(
      NodeId nodeId, String name, String value) async {
    await _client.send('DOM.setAttributeValue', {
      'nodeId': nodeId,
      'name': name,
      'value': value,
    });
  }

  /// Sets attributes on element with given id. This method is useful when user edits some existing
  /// attribute value and types in several attribute name/value pairs.
  /// [nodeId] Id of the element to set attributes for.
  /// [text] Text with a number of attributes. Will parse this text using HTML parser.
  /// [name] Attribute name to replace with new attributes derived from text in case text parsed
  /// successfully.
  Future<void> setAttributesAsText(NodeId nodeId, String text,
      {String? name}) async {
    await _client.send('DOM.setAttributesAsText', {
      'nodeId': nodeId,
      'text': text,
      if (name != null) 'name': name,
    });
  }

  /// Sets files for the given file input element.
  /// [files] Array of file paths to set.
  /// [nodeId] Identifier of the node.
  /// [backendNodeId] Identifier of the backend node.
  /// [objectId] JavaScript object id of the node wrapper.
  Future<void> setFileInputFiles(List<String> files,
      {NodeId? nodeId,
      BackendNodeId? backendNodeId,
      runtime.RemoteObjectId? objectId}) async {
    await _client.send('DOM.setFileInputFiles', {
      'files': [...files],
      if (nodeId != null) 'nodeId': nodeId,
      if (backendNodeId != null) 'backendNodeId': backendNodeId,
      if (objectId != null) 'objectId': objectId,
    });
  }

  /// Sets if stack traces should be captured for Nodes. See `Node.getNodeStackTraces`. Default is disabled.
  /// [enable] Enable or disable.
  Future<void> setNodeStackTracesEnabled(bool enable) async {
    await _client.send('DOM.setNodeStackTracesEnabled', {
      'enable': enable,
    });
  }

  /// Gets stack traces associated with a Node. As of now, only provides stack trace for Node creation.
  /// [nodeId] Id of the node to get stack traces for.
  /// Returns: Creation stack trace, if available.
  Future<runtime.StackTraceData> getNodeStackTraces(NodeId nodeId) async {
    var result = await _client.send('DOM.getNodeStackTraces', {
      'nodeId': nodeId,
    });
    return runtime.StackTraceData.fromJson(
        result['creation'] as Map<String, dynamic>);
  }

  /// Returns file information for the given
  /// File wrapper.
  /// [objectId] JavaScript object id of the node wrapper.
  Future<String> getFileInfo(runtime.RemoteObjectId objectId) async {
    var result = await _client.send('DOM.getFileInfo', {
      'objectId': objectId,
    });
    return result['path'] as String;
  }

  /// Enables console to refer to the node with given id via $x (see Command Line API for more details
  /// $x functions).
  /// [nodeId] DOM node id to be accessible by means of $x command line API.
  Future<void> setInspectedNode(NodeId nodeId) async {
    await _client.send('DOM.setInspectedNode', {
      'nodeId': nodeId,
    });
  }

  /// Sets node name for a node with given id.
  /// [nodeId] Id of the node to set name for.
  /// [name] New node's name.
  /// Returns: New node's id.
  Future<NodeId> setNodeName(NodeId nodeId, String name) async {
    var result = await _client.send('DOM.setNodeName', {
      'nodeId': nodeId,
      'name': name,
    });
    return NodeId.fromJson(result['nodeId'] as int);
  }

  /// Sets node value for a node with given id.
  /// [nodeId] Id of the node to set value for.
  /// [value] New node's value.
  Future<void> setNodeValue(NodeId nodeId, String value) async {
    await _client.send('DOM.setNodeValue', {
      'nodeId': nodeId,
      'value': value,
    });
  }

  /// Sets node HTML markup, returns new node id.
  /// [nodeId] Id of the node to set markup for.
  /// [outerHTML] Outer HTML markup to set.
  Future<void> setOuterHTML(NodeId nodeId, String outerHTML) async {
    await _client.send('DOM.setOuterHTML', {
      'nodeId': nodeId,
      'outerHTML': outerHTML,
    });
  }

  /// Undoes the last performed action.
  Future<void> undo() async {
    await _client.send('DOM.undo');
  }

  /// Returns iframe node that owns iframe with the given domain.
  Future<GetFrameOwnerResult> getFrameOwner(page.FrameId frameId) async {
    var result = await _client.send('DOM.getFrameOwner', {
      'frameId': frameId,
    });
    return GetFrameOwnerResult.fromJson(result);
  }

  /// Returns the container of the given node based on container query conditions.
  /// If containerName is given, it will find the nearest container with a matching name;
  /// otherwise it will find the nearest container regardless of its container name.
  /// Returns: The container node for the given node, or null if not found.
  Future<NodeId> getContainerForNode(NodeId nodeId,
      {String? containerName}) async {
    var result = await _client.send('DOM.getContainerForNode', {
      'nodeId': nodeId,
      if (containerName != null) 'containerName': containerName,
    });
    return NodeId.fromJson(result['nodeId'] as int);
  }

  /// Returns the descendants of a container query container that have
  /// container queries against this container.
  /// [nodeId] Id of the container node to find querying descendants from.
  /// Returns: Descendant nodes with container queries against the given container.
  Future<List<NodeId>> getQueryingDescendantsForContainer(NodeId nodeId) async {
    var result = await _client.send('DOM.getQueryingDescendantsForContainer', {
      'nodeId': nodeId,
    });
    return (result['nodeIds'] as List)
        .map((e) => NodeId.fromJson(e as int))
        .toList();
  }
}

class AttributeModifiedEvent {
  /// Id of the node that has changed.
  final NodeId nodeId;

  /// Attribute name.
  final String name;

  /// Attribute value.
  final String value;

  AttributeModifiedEvent(
      {required this.nodeId, required this.name, required this.value});

  factory AttributeModifiedEvent.fromJson(Map<String, dynamic> json) {
    return AttributeModifiedEvent(
      nodeId: NodeId.fromJson(json['nodeId'] as int),
      name: json['name'] as String,
      value: json['value'] as String,
    );
  }
}

class AttributeRemovedEvent {
  /// Id of the node that has changed.
  final NodeId nodeId;

  /// A ttribute name.
  final String name;

  AttributeRemovedEvent({required this.nodeId, required this.name});

  factory AttributeRemovedEvent.fromJson(Map<String, dynamic> json) {
    return AttributeRemovedEvent(
      nodeId: NodeId.fromJson(json['nodeId'] as int),
      name: json['name'] as String,
    );
  }
}

class CharacterDataModifiedEvent {
  /// Id of the node that has changed.
  final NodeId nodeId;

  /// New text value.
  final String characterData;

  CharacterDataModifiedEvent(
      {required this.nodeId, required this.characterData});

  factory CharacterDataModifiedEvent.fromJson(Map<String, dynamic> json) {
    return CharacterDataModifiedEvent(
      nodeId: NodeId.fromJson(json['nodeId'] as int),
      characterData: json['characterData'] as String,
    );
  }
}

class ChildNodeCountUpdatedEvent {
  /// Id of the node that has changed.
  final NodeId nodeId;

  /// New node count.
  final int childNodeCount;

  ChildNodeCountUpdatedEvent(
      {required this.nodeId, required this.childNodeCount});

  factory ChildNodeCountUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return ChildNodeCountUpdatedEvent(
      nodeId: NodeId.fromJson(json['nodeId'] as int),
      childNodeCount: json['childNodeCount'] as int,
    );
  }
}

class ChildNodeInsertedEvent {
  /// Id of the node that has changed.
  final NodeId parentNodeId;

  /// If of the previous siblint.
  final NodeId previousNodeId;

  /// Inserted node data.
  final Node node;

  ChildNodeInsertedEvent(
      {required this.parentNodeId,
      required this.previousNodeId,
      required this.node});

  factory ChildNodeInsertedEvent.fromJson(Map<String, dynamic> json) {
    return ChildNodeInsertedEvent(
      parentNodeId: NodeId.fromJson(json['parentNodeId'] as int),
      previousNodeId: NodeId.fromJson(json['previousNodeId'] as int),
      node: Node.fromJson(json['node'] as Map<String, dynamic>),
    );
  }
}

class ChildNodeRemovedEvent {
  /// Parent id.
  final NodeId parentNodeId;

  /// Id of the node that has been removed.
  final NodeId nodeId;

  ChildNodeRemovedEvent({required this.parentNodeId, required this.nodeId});

  factory ChildNodeRemovedEvent.fromJson(Map<String, dynamic> json) {
    return ChildNodeRemovedEvent(
      parentNodeId: NodeId.fromJson(json['parentNodeId'] as int),
      nodeId: NodeId.fromJson(json['nodeId'] as int),
    );
  }
}

class DistributedNodesUpdatedEvent {
  /// Insertion point where distributed nodes were updated.
  final NodeId insertionPointId;

  /// Distributed nodes for given insertion point.
  final List<BackendNode> distributedNodes;

  DistributedNodesUpdatedEvent(
      {required this.insertionPointId, required this.distributedNodes});

  factory DistributedNodesUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return DistributedNodesUpdatedEvent(
      insertionPointId: NodeId.fromJson(json['insertionPointId'] as int),
      distributedNodes: (json['distributedNodes'] as List)
          .map((e) => BackendNode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PseudoElementAddedEvent {
  /// Pseudo element's parent element id.
  final NodeId parentId;

  /// The added pseudo element.
  final Node pseudoElement;

  PseudoElementAddedEvent(
      {required this.parentId, required this.pseudoElement});

  factory PseudoElementAddedEvent.fromJson(Map<String, dynamic> json) {
    return PseudoElementAddedEvent(
      parentId: NodeId.fromJson(json['parentId'] as int),
      pseudoElement:
          Node.fromJson(json['pseudoElement'] as Map<String, dynamic>),
    );
  }
}

class PseudoElementRemovedEvent {
  /// Pseudo element's parent element id.
  final NodeId parentId;

  /// The removed pseudo element id.
  final NodeId pseudoElementId;

  PseudoElementRemovedEvent(
      {required this.parentId, required this.pseudoElementId});

  factory PseudoElementRemovedEvent.fromJson(Map<String, dynamic> json) {
    return PseudoElementRemovedEvent(
      parentId: NodeId.fromJson(json['parentId'] as int),
      pseudoElementId: NodeId.fromJson(json['pseudoElementId'] as int),
    );
  }
}

class SetChildNodesEvent {
  /// Parent node id to populate with children.
  final NodeId parentId;

  /// Child nodes array.
  final List<Node> nodes;

  SetChildNodesEvent({required this.parentId, required this.nodes});

  factory SetChildNodesEvent.fromJson(Map<String, dynamic> json) {
    return SetChildNodesEvent(
      parentId: NodeId.fromJson(json['parentId'] as int),
      nodes: (json['nodes'] as List)
          .map((e) => Node.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ShadowRootPoppedEvent {
  /// Host element id.
  final NodeId hostId;

  /// Shadow root id.
  final NodeId rootId;

  ShadowRootPoppedEvent({required this.hostId, required this.rootId});

  factory ShadowRootPoppedEvent.fromJson(Map<String, dynamic> json) {
    return ShadowRootPoppedEvent(
      hostId: NodeId.fromJson(json['hostId'] as int),
      rootId: NodeId.fromJson(json['rootId'] as int),
    );
  }
}

class ShadowRootPushedEvent {
  /// Host element id.
  final NodeId hostId;

  /// Shadow root.
  final Node root;

  ShadowRootPushedEvent({required this.hostId, required this.root});

  factory ShadowRootPushedEvent.fromJson(Map<String, dynamic> json) {
    return ShadowRootPushedEvent(
      hostId: NodeId.fromJson(json['hostId'] as int),
      root: Node.fromJson(json['root'] as Map<String, dynamic>),
    );
  }
}

class GetNodeForLocationResult {
  /// Resulting node.
  final BackendNodeId backendNodeId;

  /// Frame this node belongs to.
  final page.FrameId frameId;

  /// Id of the node at given coordinates, only when enabled and requested document.
  final NodeId? nodeId;

  GetNodeForLocationResult(
      {required this.backendNodeId, required this.frameId, this.nodeId});

  factory GetNodeForLocationResult.fromJson(Map<String, dynamic> json) {
    return GetNodeForLocationResult(
      backendNodeId: BackendNodeId.fromJson(json['backendNodeId'] as int),
      frameId: page.FrameId.fromJson(json['frameId'] as String),
      nodeId: json.containsKey('nodeId')
          ? NodeId.fromJson(json['nodeId'] as int)
          : null,
    );
  }
}

class PerformSearchResult {
  /// Unique search session identifier.
  final String searchId;

  /// Number of search results.
  final int resultCount;

  PerformSearchResult({required this.searchId, required this.resultCount});

  factory PerformSearchResult.fromJson(Map<String, dynamic> json) {
    return PerformSearchResult(
      searchId: json['searchId'] as String,
      resultCount: json['resultCount'] as int,
    );
  }
}

class GetFrameOwnerResult {
  /// Resulting node.
  final BackendNodeId backendNodeId;

  /// Id of the node at given coordinates, only when enabled and requested document.
  final NodeId? nodeId;

  GetFrameOwnerResult({required this.backendNodeId, this.nodeId});

  factory GetFrameOwnerResult.fromJson(Map<String, dynamic> json) {
    return GetFrameOwnerResult(
      backendNodeId: BackendNodeId.fromJson(json['backendNodeId'] as int),
      nodeId: json.containsKey('nodeId')
          ? NodeId.fromJson(json['nodeId'] as int)
          : null,
    );
  }
}

/// Unique DOM node identifier.
class NodeId {
  final int value;

  NodeId(this.value);

  factory NodeId.fromJson(int value) => NodeId(value);

  int toJson() => value;

  @override
  bool operator ==(other) =>
      (other is NodeId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Unique DOM node identifier used to reference a node that may not have been pushed to the
/// front-end.
class BackendNodeId {
  final int value;

  BackendNodeId(this.value);

  factory BackendNodeId.fromJson(int value) => BackendNodeId(value);

  int toJson() => value;

  @override
  bool operator ==(other) =>
      (other is BackendNodeId && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Backend node with a friendly name.
class BackendNode {
  /// `Node`'s nodeType.
  final int nodeType;

  /// `Node`'s nodeName.
  final String nodeName;

  final BackendNodeId backendNodeId;

  BackendNode(
      {required this.nodeType,
      required this.nodeName,
      required this.backendNodeId});

  factory BackendNode.fromJson(Map<String, dynamic> json) {
    return BackendNode(
      nodeType: json['nodeType'] as int,
      nodeName: json['nodeName'] as String,
      backendNodeId: BackendNodeId.fromJson(json['backendNodeId'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nodeType': nodeType,
      'nodeName': nodeName,
      'backendNodeId': backendNodeId.toJson(),
    };
  }
}

/// Pseudo element type.
class PseudoType {
  static const firstLine = PseudoType._('first-line');
  static const firstLetter = PseudoType._('first-letter');
  static const before = PseudoType._('before');
  static const after = PseudoType._('after');
  static const marker = PseudoType._('marker');
  static const backdrop = PseudoType._('backdrop');
  static const selection = PseudoType._('selection');
  static const targetText = PseudoType._('target-text');
  static const spellingError = PseudoType._('spelling-error');
  static const grammarError = PseudoType._('grammar-error');
  static const highlight = PseudoType._('highlight');
  static const firstLineInherited = PseudoType._('first-line-inherited');
  static const scrollbar = PseudoType._('scrollbar');
  static const scrollbarThumb = PseudoType._('scrollbar-thumb');
  static const scrollbarButton = PseudoType._('scrollbar-button');
  static const scrollbarTrack = PseudoType._('scrollbar-track');
  static const scrollbarTrackPiece = PseudoType._('scrollbar-track-piece');
  static const scrollbarCorner = PseudoType._('scrollbar-corner');
  static const resizer = PseudoType._('resizer');
  static const inputListButton = PseudoType._('input-list-button');
  static const pageTransition = PseudoType._('page-transition');
  static const pageTransitionContainer =
      PseudoType._('page-transition-container');
  static const pageTransitionImageWrapper =
      PseudoType._('page-transition-image-wrapper');
  static const pageTransitionOutgoingImage =
      PseudoType._('page-transition-outgoing-image');
  static const pageTransitionIncomingImage =
      PseudoType._('page-transition-incoming-image');
  static const values = {
    'first-line': firstLine,
    'first-letter': firstLetter,
    'before': before,
    'after': after,
    'marker': marker,
    'backdrop': backdrop,
    'selection': selection,
    'target-text': targetText,
    'spelling-error': spellingError,
    'grammar-error': grammarError,
    'highlight': highlight,
    'first-line-inherited': firstLineInherited,
    'scrollbar': scrollbar,
    'scrollbar-thumb': scrollbarThumb,
    'scrollbar-button': scrollbarButton,
    'scrollbar-track': scrollbarTrack,
    'scrollbar-track-piece': scrollbarTrackPiece,
    'scrollbar-corner': scrollbarCorner,
    'resizer': resizer,
    'input-list-button': inputListButton,
    'page-transition': pageTransition,
    'page-transition-container': pageTransitionContainer,
    'page-transition-image-wrapper': pageTransitionImageWrapper,
    'page-transition-outgoing-image': pageTransitionOutgoingImage,
    'page-transition-incoming-image': pageTransitionIncomingImage,
  };

  final String value;

  const PseudoType._(this.value);

  factory PseudoType.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is PseudoType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Shadow root type.
class ShadowRootType {
  static const userAgent = ShadowRootType._('user-agent');
  static const open = ShadowRootType._('open');
  static const closed = ShadowRootType._('closed');
  static const values = {
    'user-agent': userAgent,
    'open': open,
    'closed': closed,
  };

  final String value;

  const ShadowRootType._(this.value);

  factory ShadowRootType.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ShadowRootType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Document compatibility mode.
class CompatibilityMode {
  static const quirksMode = CompatibilityMode._('QuirksMode');
  static const limitedQuirksMode = CompatibilityMode._('LimitedQuirksMode');
  static const noQuirksMode = CompatibilityMode._('NoQuirksMode');
  static const values = {
    'QuirksMode': quirksMode,
    'LimitedQuirksMode': limitedQuirksMode,
    'NoQuirksMode': noQuirksMode,
  };

  final String value;

  const CompatibilityMode._(this.value);

  factory CompatibilityMode.fromJson(String value) => values[value]!;

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is CompatibilityMode && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// DOM interaction is implemented in terms of mirror objects that represent the actual DOM nodes.
/// DOMNode is a base node mirror type.
class Node {
  /// Node identifier that is passed into the rest of the DOM messages as the `nodeId`. Backend
  /// will only push node with given `id` once. It is aware of all requested nodes and will only
  /// fire DOM events for nodes known to the client.
  final NodeId nodeId;

  /// The id of the parent node if any.
  final NodeId? parentId;

  /// The BackendNodeId for this node.
  final BackendNodeId backendNodeId;

  /// `Node`'s nodeType.
  final int nodeType;

  /// `Node`'s nodeName.
  final String nodeName;

  /// `Node`'s localName.
  final String localName;

  /// `Node`'s nodeValue.
  final String nodeValue;

  /// Child count for `Container` nodes.
  final int? childNodeCount;

  /// Child nodes of this node when requested with children.
  final List<Node>? children;

  /// Attributes of the `Element` node in the form of flat array `[name1, value1, name2, value2]`.
  final List<String>? attributes;

  /// Document URL that `Document` or `FrameOwner` node points to.
  final String? documentURL;

  /// Base URL that `Document` or `FrameOwner` node uses for URL completion.
  final String? baseURL;

  /// `DocumentType`'s publicId.
  final String? publicId;

  /// `DocumentType`'s systemId.
  final String? systemId;

  /// `DocumentType`'s internalSubset.
  final String? internalSubset;

  /// `Document`'s XML version in case of XML documents.
  final String? xmlVersion;

  /// `Attr`'s name.
  final String? name;

  /// `Attr`'s value.
  final String? value;

  /// Pseudo element type for this node.
  final PseudoType? pseudoType;

  /// Shadow root type.
  final ShadowRootType? shadowRootType;

  /// Frame ID for frame owner elements.
  final page.FrameId? frameId;

  /// Content document for frame owner elements.
  final Node? contentDocument;

  /// Shadow root list for given element host.
  final List<Node>? shadowRoots;

  /// Content document fragment for template elements.
  final Node? templateContent;

  /// Pseudo elements associated with this node.
  final List<Node>? pseudoElements;

  /// Distributed nodes for given insertion point.
  final List<BackendNode>? distributedNodes;

  /// Whether the node is SVG.
  final bool? isSVG;

  final CompatibilityMode? compatibilityMode;

  Node(
      {required this.nodeId,
      this.parentId,
      required this.backendNodeId,
      required this.nodeType,
      required this.nodeName,
      required this.localName,
      required this.nodeValue,
      this.childNodeCount,
      this.children,
      this.attributes,
      this.documentURL,
      this.baseURL,
      this.publicId,
      this.systemId,
      this.internalSubset,
      this.xmlVersion,
      this.name,
      this.value,
      this.pseudoType,
      this.shadowRootType,
      this.frameId,
      this.contentDocument,
      this.shadowRoots,
      this.templateContent,
      this.pseudoElements,
      this.distributedNodes,
      this.isSVG,
      this.compatibilityMode});

  factory Node.fromJson(Map<String, dynamic> json) {
    return Node(
      nodeId: NodeId.fromJson(json['nodeId'] as int),
      parentId: json.containsKey('parentId')
          ? NodeId.fromJson(json['parentId'] as int)
          : null,
      backendNodeId: BackendNodeId.fromJson(json['backendNodeId'] as int),
      nodeType: json['nodeType'] as int,
      nodeName: json['nodeName'] as String,
      localName: json['localName'] as String,
      nodeValue: json['nodeValue'] as String,
      childNodeCount: json.containsKey('childNodeCount')
          ? json['childNodeCount'] as int
          : null,
      children: json.containsKey('children')
          ? (json['children'] as List)
              .map((e) => Node.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      attributes: json.containsKey('attributes')
          ? (json['attributes'] as List).map((e) => e as String).toList()
          : null,
      documentURL: json.containsKey('documentURL')
          ? json['documentURL'] as String
          : null,
      baseURL: json.containsKey('baseURL') ? json['baseURL'] as String : null,
      publicId:
          json.containsKey('publicId') ? json['publicId'] as String : null,
      systemId:
          json.containsKey('systemId') ? json['systemId'] as String : null,
      internalSubset: json.containsKey('internalSubset')
          ? json['internalSubset'] as String
          : null,
      xmlVersion:
          json.containsKey('xmlVersion') ? json['xmlVersion'] as String : null,
      name: json.containsKey('name') ? json['name'] as String : null,
      value: json.containsKey('value') ? json['value'] as String : null,
      pseudoType: json.containsKey('pseudoType')
          ? PseudoType.fromJson(json['pseudoType'] as String)
          : null,
      shadowRootType: json.containsKey('shadowRootType')
          ? ShadowRootType.fromJson(json['shadowRootType'] as String)
          : null,
      frameId: json.containsKey('frameId')
          ? page.FrameId.fromJson(json['frameId'] as String)
          : null,
      contentDocument: json.containsKey('contentDocument')
          ? Node.fromJson(json['contentDocument'] as Map<String, dynamic>)
          : null,
      shadowRoots: json.containsKey('shadowRoots')
          ? (json['shadowRoots'] as List)
              .map((e) => Node.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      templateContent: json.containsKey('templateContent')
          ? Node.fromJson(json['templateContent'] as Map<String, dynamic>)
          : null,
      pseudoElements: json.containsKey('pseudoElements')
          ? (json['pseudoElements'] as List)
              .map((e) => Node.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      distributedNodes: json.containsKey('distributedNodes')
          ? (json['distributedNodes'] as List)
              .map((e) => BackendNode.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      isSVG: json.containsKey('isSVG') ? json['isSVG'] as bool : null,
      compatibilityMode: json.containsKey('compatibilityMode')
          ? CompatibilityMode.fromJson(json['compatibilityMode'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nodeId': nodeId.toJson(),
      'backendNodeId': backendNodeId.toJson(),
      'nodeType': nodeType,
      'nodeName': nodeName,
      'localName': localName,
      'nodeValue': nodeValue,
      if (parentId != null) 'parentId': parentId!.toJson(),
      if (childNodeCount != null) 'childNodeCount': childNodeCount,
      if (children != null)
        'children': children!.map((e) => e.toJson()).toList(),
      if (attributes != null) 'attributes': [...?attributes],
      if (documentURL != null) 'documentURL': documentURL,
      if (baseURL != null) 'baseURL': baseURL,
      if (publicId != null) 'publicId': publicId,
      if (systemId != null) 'systemId': systemId,
      if (internalSubset != null) 'internalSubset': internalSubset,
      if (xmlVersion != null) 'xmlVersion': xmlVersion,
      if (name != null) 'name': name,
      if (value != null) 'value': value,
      if (pseudoType != null) 'pseudoType': pseudoType!.toJson(),
      if (shadowRootType != null) 'shadowRootType': shadowRootType!.toJson(),
      if (frameId != null) 'frameId': frameId!.toJson(),
      if (contentDocument != null) 'contentDocument': contentDocument!.toJson(),
      if (shadowRoots != null)
        'shadowRoots': shadowRoots!.map((e) => e.toJson()).toList(),
      if (templateContent != null) 'templateContent': templateContent!.toJson(),
      if (pseudoElements != null)
        'pseudoElements': pseudoElements!.map((e) => e.toJson()).toList(),
      if (distributedNodes != null)
        'distributedNodes': distributedNodes!.map((e) => e.toJson()).toList(),
      if (isSVG != null) 'isSVG': isSVG,
      if (compatibilityMode != null)
        'compatibilityMode': compatibilityMode!.toJson(),
    };
  }
}

/// A structure holding an RGBA color.
class RGBA {
  /// The red component, in the [0-255] range.
  final int r;

  /// The green component, in the [0-255] range.
  final int g;

  /// The blue component, in the [0-255] range.
  final int b;

  /// The alpha component, in the [0-1] range (default: 1).
  final num? a;

  RGBA({required this.r, required this.g, required this.b, this.a});

  factory RGBA.fromJson(Map<String, dynamic> json) {
    return RGBA(
      r: json['r'] as int,
      g: json['g'] as int,
      b: json['b'] as int,
      a: json.containsKey('a') ? json['a'] as num : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'r': r,
      'g': g,
      'b': b,
      if (a != null) 'a': a,
    };
  }
}

/// An array of quad vertices, x immediately followed by y for each point, points clock-wise.
class Quad {
  final List<num> value;

  Quad(this.value);

  factory Quad.fromJson(List<dynamic> value) =>
      Quad(value.map((e) => e as num).toList());

  List<num> toJson() => value;

  @override
  bool operator ==(other) =>
      (other is Quad && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Box model.
class BoxModel {
  /// Content box
  final Quad content;

  /// Padding box
  final Quad padding;

  /// Border box
  final Quad border;

  /// Margin box
  final Quad margin;

  /// Node width
  final int width;

  /// Node height
  final int height;

  /// Shape outside coordinates
  final ShapeOutsideInfo? shapeOutside;

  BoxModel(
      {required this.content,
      required this.padding,
      required this.border,
      required this.margin,
      required this.width,
      required this.height,
      this.shapeOutside});

  factory BoxModel.fromJson(Map<String, dynamic> json) {
    return BoxModel(
      content: Quad.fromJson(json['content'] as List),
      padding: Quad.fromJson(json['padding'] as List),
      border: Quad.fromJson(json['border'] as List),
      margin: Quad.fromJson(json['margin'] as List),
      width: json['width'] as int,
      height: json['height'] as int,
      shapeOutside: json.containsKey('shapeOutside')
          ? ShapeOutsideInfo.fromJson(
              json['shapeOutside'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.toJson(),
      'padding': padding.toJson(),
      'border': border.toJson(),
      'margin': margin.toJson(),
      'width': width,
      'height': height,
      if (shapeOutside != null) 'shapeOutside': shapeOutside!.toJson(),
    };
  }
}

/// CSS Shape Outside details.
class ShapeOutsideInfo {
  /// Shape bounds
  final Quad bounds;

  /// Shape coordinate details
  final List<dynamic> shape;

  /// Margin shape bounds
  final List<dynamic> marginShape;

  ShapeOutsideInfo(
      {required this.bounds, required this.shape, required this.marginShape});

  factory ShapeOutsideInfo.fromJson(Map<String, dynamic> json) {
    return ShapeOutsideInfo(
      bounds: Quad.fromJson(json['bounds'] as List),
      shape: (json['shape'] as List).map((e) => e as dynamic).toList(),
      marginShape:
          (json['marginShape'] as List).map((e) => e as dynamic).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bounds': bounds.toJson(),
      'shape': [...shape],
      'marginShape': [...marginShape],
    };
  }
}

/// Rectangle.
class Rect {
  /// X coordinate
  final num x;

  /// Y coordinate
  final num y;

  /// Rectangle width
  final num width;

  /// Rectangle height
  final num height;

  Rect(
      {required this.x,
      required this.y,
      required this.width,
      required this.height});

  factory Rect.fromJson(Map<String, dynamic> json) {
    return Rect(
      x: json['x'] as num,
      y: json['y'] as num,
      width: json['width'] as num,
      height: json['height'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
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
