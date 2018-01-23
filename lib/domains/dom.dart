/// This domain exposes DOM read/write operations. Each DOM Node is represented with its mirror object
/// that has an `id`. This `id` can be used to get additional information on the Node, resolve it into
/// the JavaScript object wrapper, etc. It is important that client receives DOM events only for the
/// nodes that are known to the client. Backend keeps track of the nodes that were sent to the client
/// and never sends the same node twice. It is client's responsibility to collect information about
/// the nodes that were sent to the client.<p>Note that `iframe` owner elements will return
/// corresponding document elements as their child nodes.</p>

import 'dart:async';
// ignore: unused_import
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'page.dart' as page;
import 'runtime.dart' as runtime;
import 'dom.dart' as dom;

class DOMDomain {
  final Client _client;

  DOMDomain(this._client);

  /// Fired when `Element`'s attribute is modified.
  Stream<AttributeModifiedEvent> get onAttributeModified => _client.onEvent
      .where((Event event) => event.name == 'DOM.attributeModified')
      .map((Event event) =>
          new AttributeModifiedEvent.fromJson(event.parameters));

  /// Fired when `Element`'s attribute is removed.
  Stream<AttributeRemovedEvent> get onAttributeRemoved => _client.onEvent
      .where((Event event) => event.name == 'DOM.attributeRemoved')
      .map((Event event) =>
          new AttributeRemovedEvent.fromJson(event.parameters));

  /// Mirrors `DOMCharacterDataModified` event.
  Stream<CharacterDataModifiedEvent> get onCharacterDataModified =>
      _client.onEvent
          .where((Event event) => event.name == 'DOM.characterDataModified')
          .map((Event event) =>
              new CharacterDataModifiedEvent.fromJson(event.parameters));

  /// Fired when `Container`'s child node count has changed.
  Stream<ChildNodeCountUpdatedEvent> get onChildNodeCountUpdated =>
      _client.onEvent
          .where((Event event) => event.name == 'DOM.childNodeCountUpdated')
          .map((Event event) =>
              new ChildNodeCountUpdatedEvent.fromJson(event.parameters));

  /// Mirrors `DOMNodeInserted` event.
  Stream<ChildNodeInsertedEvent> get onChildNodeInserted => _client.onEvent
      .where((Event event) => event.name == 'DOM.childNodeInserted')
      .map((Event event) =>
          new ChildNodeInsertedEvent.fromJson(event.parameters));

  /// Mirrors `DOMNodeRemoved` event.
  Stream<ChildNodeRemovedEvent> get onChildNodeRemoved => _client.onEvent
      .where((Event event) => event.name == 'DOM.childNodeRemoved')
      .map((Event event) =>
          new ChildNodeRemovedEvent.fromJson(event.parameters));

  /// Called when distrubution is changed.
  Stream<DistributedNodesUpdatedEvent> get onDistributedNodesUpdated =>
      _client.onEvent
          .where((Event event) => event.name == 'DOM.distributedNodesUpdated')
          .map((Event event) =>
              new DistributedNodesUpdatedEvent.fromJson(event.parameters));

  /// Fired when `Document` has been totally updated. Node ids are no longer valid.
  Stream get onDocumentUpdated => _client.onEvent
      .where((Event event) => event.name == 'DOM.documentUpdated');

  /// Fired when `Element`'s inline style is modified via a CSS property modification.
  Stream<List<NodeId>> get onInlineStyleInvalidated => _client.onEvent
      .where((Event event) => event.name == 'DOM.inlineStyleInvalidated')
      .map((Event event) => (event.parameters['nodeIds'] as List)
          .map((e) => new NodeId.fromJson(e))
          .toList());

  /// Called when a pseudo element is added to an element.
  Stream<PseudoElementAddedEvent> get onPseudoElementAdded => _client.onEvent
      .where((Event event) => event.name == 'DOM.pseudoElementAdded')
      .map((Event event) =>
          new PseudoElementAddedEvent.fromJson(event.parameters));

  /// Called when a pseudo element is removed from an element.
  Stream<PseudoElementRemovedEvent> get onPseudoElementRemoved =>
      _client.onEvent
          .where((Event event) => event.name == 'DOM.pseudoElementRemoved')
          .map((Event event) =>
              new PseudoElementRemovedEvent.fromJson(event.parameters));

  /// Fired when backend wants to provide client with the missing DOM structure. This happens upon
  /// most of the calls requesting node ids.
  Stream<SetChildNodesEvent> get onSetChildNodes => _client.onEvent
      .where((Event event) => event.name == 'DOM.setChildNodes')
      .map((Event event) => new SetChildNodesEvent.fromJson(event.parameters));

  /// Called when shadow root is popped from the element.
  Stream<ShadowRootPoppedEvent> get onShadowRootPopped => _client.onEvent
      .where((Event event) => event.name == 'DOM.shadowRootPopped')
      .map((Event event) =>
          new ShadowRootPoppedEvent.fromJson(event.parameters));

  /// Called when shadow root is pushed into the element.
  Stream<ShadowRootPushedEvent> get onShadowRootPushed => _client.onEvent
      .where((Event event) => event.name == 'DOM.shadowRootPushed')
      .map((Event event) =>
          new ShadowRootPushedEvent.fromJson(event.parameters));

  /// Collects class names for the node with given id and all of it's child nodes.
  /// [nodeId] Id of the node to collect class names.
  /// Return: Class name list.
  Future<List<String>> collectClassNamesFromSubtree(
    NodeId nodeId,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
    };
    Map result =
        await _client.send('DOM.collectClassNamesFromSubtree', parameters);
    return (result['classNames'] as List).map((e) => e as String).toList();
  }

  /// Creates a deep copy of the specified node and places it into the target container before the
  /// given anchor.
  /// [nodeId] Id of the node to copy.
  /// [targetNodeId] Id of the element to drop the copy into.
  /// [insertBeforeNodeId] Drop the copy before this node (if absent, the copy becomes the last child of
  /// `targetNodeId`).
  /// Return: Id of the node clone.
  Future<NodeId> copyTo(
    NodeId nodeId,
    NodeId targetNodeId, {
    NodeId insertBeforeNodeId,
  }) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
      'targetNodeId': targetNodeId.toJson(),
    };
    if (insertBeforeNodeId != null) {
      parameters['insertBeforeNodeId'] = insertBeforeNodeId.toJson();
    }
    Map result = await _client.send('DOM.copyTo', parameters);
    return new NodeId.fromJson(result['nodeId']);
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
  /// Return: Node description.
  Future<Node> describeNode({
    NodeId nodeId,
    BackendNodeId backendNodeId,
    runtime.RemoteObjectId objectId,
    int depth,
    bool pierce,
  }) async {
    Map parameters = {};
    if (nodeId != null) {
      parameters['nodeId'] = nodeId.toJson();
    }
    if (backendNodeId != null) {
      parameters['backendNodeId'] = backendNodeId.toJson();
    }
    if (objectId != null) {
      parameters['objectId'] = objectId.toJson();
    }
    if (depth != null) {
      parameters['depth'] = depth;
    }
    if (pierce != null) {
      parameters['pierce'] = pierce;
    }
    Map result = await _client.send('DOM.describeNode', parameters);
    return new Node.fromJson(result['node']);
  }

  /// Disables DOM agent for the given page.
  Future disable() async {
    await _client.send('DOM.disable');
  }

  /// Discards search results from the session with the given id. `getSearchResults` should no longer
  /// be called for that search.
  /// [searchId] Unique search session identifier.
  Future discardSearchResults(
    String searchId,
  ) async {
    Map parameters = {
      'searchId': searchId,
    };
    await _client.send('DOM.discardSearchResults', parameters);
  }

  /// Enables DOM agent for the given page.
  Future enable() async {
    await _client.send('DOM.enable');
  }

  /// Focuses the given element.
  /// [nodeId] Identifier of the node.
  /// [backendNodeId] Identifier of the backend node.
  /// [objectId] JavaScript object id of the node wrapper.
  Future focus({
    NodeId nodeId,
    BackendNodeId backendNodeId,
    runtime.RemoteObjectId objectId,
  }) async {
    Map parameters = {};
    if (nodeId != null) {
      parameters['nodeId'] = nodeId.toJson();
    }
    if (backendNodeId != null) {
      parameters['backendNodeId'] = backendNodeId.toJson();
    }
    if (objectId != null) {
      parameters['objectId'] = objectId.toJson();
    }
    await _client.send('DOM.focus', parameters);
  }

  /// Returns attributes for the specified node.
  /// [nodeId] Id of the node to retrieve attibutes for.
  /// Return: An interleaved array of node attribute names and values.
  Future<List<String>> getAttributes(
    NodeId nodeId,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
    };
    Map result = await _client.send('DOM.getAttributes', parameters);
    return (result['attributes'] as List).map((e) => e as String).toList();
  }

  /// Returns boxes for the given node.
  /// [nodeId] Identifier of the node.
  /// [backendNodeId] Identifier of the backend node.
  /// [objectId] JavaScript object id of the node wrapper.
  /// Return: Box model for the node.
  Future<BoxModel> getBoxModel({
    NodeId nodeId,
    BackendNodeId backendNodeId,
    runtime.RemoteObjectId objectId,
  }) async {
    Map parameters = {};
    if (nodeId != null) {
      parameters['nodeId'] = nodeId.toJson();
    }
    if (backendNodeId != null) {
      parameters['backendNodeId'] = backendNodeId.toJson();
    }
    if (objectId != null) {
      parameters['objectId'] = objectId.toJson();
    }
    Map result = await _client.send('DOM.getBoxModel', parameters);
    return new BoxModel.fromJson(result['model']);
  }

  /// Returns the root DOM node (and optionally the subtree) to the caller.
  /// [depth] The maximum depth at which children should be retrieved, defaults to 1. Use -1 for the
  /// entire subtree or provide an integer larger than 0.
  /// [pierce] Whether or not iframes and shadow roots should be traversed when returning the subtree
  /// (default is false).
  /// Return: Resulting node.
  Future<Node> getDocument({
    int depth,
    bool pierce,
  }) async {
    Map parameters = {};
    if (depth != null) {
      parameters['depth'] = depth;
    }
    if (pierce != null) {
      parameters['pierce'] = pierce;
    }
    Map result = await _client.send('DOM.getDocument', parameters);
    return new Node.fromJson(result['root']);
  }

  /// Returns the root DOM node (and optionally the subtree) to the caller.
  /// [depth] The maximum depth at which children should be retrieved, defaults to 1. Use -1 for the
  /// entire subtree or provide an integer larger than 0.
  /// [pierce] Whether or not iframes and shadow roots should be traversed when returning the subtree
  /// (default is false).
  /// Return: Resulting node.
  Future<List<Node>> getFlattenedDocument({
    int depth,
    bool pierce,
  }) async {
    Map parameters = {};
    if (depth != null) {
      parameters['depth'] = depth;
    }
    if (pierce != null) {
      parameters['pierce'] = pierce;
    }
    Map result = await _client.send('DOM.getFlattenedDocument', parameters);
    return (result['nodes'] as List).map((e) => new Node.fromJson(e)).toList();
  }

  /// Returns node id at given location.
  /// [x] X coordinate.
  /// [y] Y coordinate.
  /// [includeUserAgentShadowDOM] False to skip to the nearest non-UA shadow root ancestor (default: false).
  /// Return: Id of the node at given coordinates.
  Future<NodeId> getNodeForLocation(
    int x,
    int y, {
    bool includeUserAgentShadowDOM,
  }) async {
    Map parameters = {
      'x': x,
      'y': y,
    };
    if (includeUserAgentShadowDOM != null) {
      parameters['includeUserAgentShadowDOM'] = includeUserAgentShadowDOM;
    }
    Map result = await _client.send('DOM.getNodeForLocation', parameters);
    return new NodeId.fromJson(result['nodeId']);
  }

  /// Returns node's HTML markup.
  /// [nodeId] Identifier of the node.
  /// [backendNodeId] Identifier of the backend node.
  /// [objectId] JavaScript object id of the node wrapper.
  /// Return: Outer HTML markup.
  Future<String> getOuterHTML({
    NodeId nodeId,
    BackendNodeId backendNodeId,
    runtime.RemoteObjectId objectId,
  }) async {
    Map parameters = {};
    if (nodeId != null) {
      parameters['nodeId'] = nodeId.toJson();
    }
    if (backendNodeId != null) {
      parameters['backendNodeId'] = backendNodeId.toJson();
    }
    if (objectId != null) {
      parameters['objectId'] = objectId.toJson();
    }
    Map result = await _client.send('DOM.getOuterHTML', parameters);
    return result['outerHTML'];
  }

  /// Returns the id of the nearest ancestor that is a relayout boundary.
  /// [nodeId] Id of the node.
  /// Return: Relayout boundary node id for the given node.
  Future<NodeId> getRelayoutBoundary(
    NodeId nodeId,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
    };
    Map result = await _client.send('DOM.getRelayoutBoundary', parameters);
    return new NodeId.fromJson(result['nodeId']);
  }

  /// Returns search results from given `fromIndex` to given `toIndex` from the search with the given
  /// identifier.
  /// [searchId] Unique search session identifier.
  /// [fromIndex] Start index of the search result to be returned.
  /// [toIndex] End index of the search result to be returned.
  /// Return: Ids of the search result nodes.
  Future<List<NodeId>> getSearchResults(
    String searchId,
    int fromIndex,
    int toIndex,
  ) async {
    Map parameters = {
      'searchId': searchId,
      'fromIndex': fromIndex,
      'toIndex': toIndex,
    };
    Map result = await _client.send('DOM.getSearchResults', parameters);
    return (result['nodeIds'] as List)
        .map((e) => new NodeId.fromJson(e))
        .toList();
  }

  /// Hides any highlight.
  Future hideHighlight() async {
    await _client.send('DOM.hideHighlight');
  }

  /// Highlights DOM node.
  Future highlightNode() async {
    await _client.send('DOM.highlightNode');
  }

  /// Highlights given rectangle.
  Future highlightRect() async {
    await _client.send('DOM.highlightRect');
  }

  /// Marks last undoable state.
  Future markUndoableState() async {
    await _client.send('DOM.markUndoableState');
  }

  /// Moves node into the new container, places it before the given anchor.
  /// [nodeId] Id of the node to move.
  /// [targetNodeId] Id of the element to drop the moved node into.
  /// [insertBeforeNodeId] Drop node before this one (if absent, the moved node becomes the last child of
  /// `targetNodeId`).
  /// Return: New id of the moved node.
  Future<NodeId> moveTo(
    NodeId nodeId,
    NodeId targetNodeId, {
    NodeId insertBeforeNodeId,
  }) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
      'targetNodeId': targetNodeId.toJson(),
    };
    if (insertBeforeNodeId != null) {
      parameters['insertBeforeNodeId'] = insertBeforeNodeId.toJson();
    }
    Map result = await _client.send('DOM.moveTo', parameters);
    return new NodeId.fromJson(result['nodeId']);
  }

  /// Searches for a given string in the DOM tree. Use `getSearchResults` to access search results or
  /// `cancelSearch` to end this search session.
  /// [query] Plain text or query selector or XPath search query.
  /// [includeUserAgentShadowDOM] True to search in user agent shadow DOM.
  Future<PerformSearchResult> performSearch(
    String query, {
    bool includeUserAgentShadowDOM,
  }) async {
    Map parameters = {
      'query': query,
    };
    if (includeUserAgentShadowDOM != null) {
      parameters['includeUserAgentShadowDOM'] = includeUserAgentShadowDOM;
    }
    Map result = await _client.send('DOM.performSearch', parameters);
    return new PerformSearchResult.fromJson(result);
  }

  /// Requests that the node is sent to the caller given its path. // FIXME, use XPath
  /// [path] Path to node in the proprietary format.
  /// Return: Id of the node for given path.
  Future<NodeId> pushNodeByPathToFrontend(
    String path,
  ) async {
    Map parameters = {
      'path': path,
    };
    Map result = await _client.send('DOM.pushNodeByPathToFrontend', parameters);
    return new NodeId.fromJson(result['nodeId']);
  }

  /// Requests that a batch of nodes is sent to the caller given their backend node ids.
  /// [backendNodeIds] The array of backend node ids.
  /// Return: The array of ids of pushed nodes that correspond to the backend ids specified in
  /// backendNodeIds.
  Future<List<NodeId>> pushNodesByBackendIdsToFrontend(
    List<BackendNodeId> backendNodeIds,
  ) async {
    Map parameters = {
      'backendNodeIds': backendNodeIds.map((e) => e.toJson()).toList(),
    };
    Map result =
        await _client.send('DOM.pushNodesByBackendIdsToFrontend', parameters);
    return (result['nodeIds'] as List)
        .map((e) => new NodeId.fromJson(e))
        .toList();
  }

  /// Executes `querySelector` on a given node.
  /// [nodeId] Id of the node to query upon.
  /// [selector] Selector string.
  /// Return: Query selector result.
  Future<NodeId> querySelector(
    NodeId nodeId,
    String selector,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
      'selector': selector,
    };
    Map result = await _client.send('DOM.querySelector', parameters);
    return new NodeId.fromJson(result['nodeId']);
  }

  /// Executes `querySelectorAll` on a given node.
  /// [nodeId] Id of the node to query upon.
  /// [selector] Selector string.
  /// Return: Query selector result.
  Future<List<NodeId>> querySelectorAll(
    NodeId nodeId,
    String selector,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
      'selector': selector,
    };
    Map result = await _client.send('DOM.querySelectorAll', parameters);
    return (result['nodeIds'] as List)
        .map((e) => new NodeId.fromJson(e))
        .toList();
  }

  /// Re-does the last undone action.
  Future redo() async {
    await _client.send('DOM.redo');
  }

  /// Removes attribute with given name from an element with given id.
  /// [nodeId] Id of the element to remove attribute from.
  /// [name] Name of the attribute to remove.
  Future removeAttribute(
    NodeId nodeId,
    String name,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
      'name': name,
    };
    await _client.send('DOM.removeAttribute', parameters);
  }

  /// Removes node with given id.
  /// [nodeId] Id of the node to remove.
  Future removeNode(
    NodeId nodeId,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
    };
    await _client.send('DOM.removeNode', parameters);
  }

  /// Requests that children of the node with given id are returned to the caller in form of
  /// `setChildNodes` events where not only immediate children are retrieved, but all children down to
  /// the specified depth.
  /// [nodeId] Id of the node to get children for.
  /// [depth] The maximum depth at which children should be retrieved, defaults to 1. Use -1 for the
  /// entire subtree or provide an integer larger than 0.
  /// [pierce] Whether or not iframes and shadow roots should be traversed when returning the sub-tree
  /// (default is false).
  Future requestChildNodes(
    NodeId nodeId, {
    int depth,
    bool pierce,
  }) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
    };
    if (depth != null) {
      parameters['depth'] = depth;
    }
    if (pierce != null) {
      parameters['pierce'] = pierce;
    }
    await _client.send('DOM.requestChildNodes', parameters);
  }

  /// Requests that the node is sent to the caller given the JavaScript node object reference. All
  /// nodes that form the path from the node to the root are also sent to the client as a series of
  /// `setChildNodes` notifications.
  /// [objectId] JavaScript object id to convert into node.
  /// Return: Node id for given object.
  Future<NodeId> requestNode(
    runtime.RemoteObjectId objectId,
  ) async {
    Map parameters = {
      'objectId': objectId.toJson(),
    };
    Map result = await _client.send('DOM.requestNode', parameters);
    return new NodeId.fromJson(result['nodeId']);
  }

  /// Resolves the JavaScript node object for a given NodeId or BackendNodeId.
  /// [nodeId] Id of the node to resolve.
  /// [backendNodeId] Backend identifier of the node to resolve.
  /// [objectGroup] Symbolic group name that can be used to release multiple objects.
  /// Return: JavaScript object wrapper for given node.
  Future<runtime.RemoteObject> resolveNode({
    NodeId nodeId,
    dom.BackendNodeId backendNodeId,
    String objectGroup,
  }) async {
    Map parameters = {};
    if (nodeId != null) {
      parameters['nodeId'] = nodeId.toJson();
    }
    if (backendNodeId != null) {
      parameters['backendNodeId'] = backendNodeId.toJson();
    }
    if (objectGroup != null) {
      parameters['objectGroup'] = objectGroup;
    }
    Map result = await _client.send('DOM.resolveNode', parameters);
    return new runtime.RemoteObject.fromJson(result['object']);
  }

  /// Sets attribute for an element with given id.
  /// [nodeId] Id of the element to set attribute for.
  /// [name] Attribute name.
  /// [value] Attribute value.
  Future setAttributeValue(
    NodeId nodeId,
    String name,
    String value,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
      'name': name,
      'value': value,
    };
    await _client.send('DOM.setAttributeValue', parameters);
  }

  /// Sets attributes on element with given id. This method is useful when user edits some existing
  /// attribute value and types in several attribute name/value pairs.
  /// [nodeId] Id of the element to set attributes for.
  /// [text] Text with a number of attributes. Will parse this text using HTML parser.
  /// [name] Attribute name to replace with new attributes derived from text in case text parsed
  /// successfully.
  Future setAttributesAsText(
    NodeId nodeId,
    String text, {
    String name,
  }) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
      'text': text,
    };
    if (name != null) {
      parameters['name'] = name;
    }
    await _client.send('DOM.setAttributesAsText', parameters);
  }

  /// Sets files for the given file input element.
  /// [files] Array of file paths to set.
  /// [nodeId] Identifier of the node.
  /// [backendNodeId] Identifier of the backend node.
  /// [objectId] JavaScript object id of the node wrapper.
  Future setFileInputFiles(
    List<String> files, {
    NodeId nodeId,
    BackendNodeId backendNodeId,
    runtime.RemoteObjectId objectId,
  }) async {
    Map parameters = {
      'files': files.map((e) => e).toList(),
    };
    if (nodeId != null) {
      parameters['nodeId'] = nodeId.toJson();
    }
    if (backendNodeId != null) {
      parameters['backendNodeId'] = backendNodeId.toJson();
    }
    if (objectId != null) {
      parameters['objectId'] = objectId.toJson();
    }
    await _client.send('DOM.setFileInputFiles', parameters);
  }

  /// Enables console to refer to the node with given id via $x (see Command Line API for more details
  /// $x functions).
  /// [nodeId] DOM node id to be accessible by means of $x command line API.
  Future setInspectedNode(
    NodeId nodeId,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
    };
    await _client.send('DOM.setInspectedNode', parameters);
  }

  /// Sets node name for a node with given id.
  /// [nodeId] Id of the node to set name for.
  /// [name] New node's name.
  /// Return: New node's id.
  Future<NodeId> setNodeName(
    NodeId nodeId,
    String name,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
      'name': name,
    };
    Map result = await _client.send('DOM.setNodeName', parameters);
    return new NodeId.fromJson(result['nodeId']);
  }

  /// Sets node value for a node with given id.
  /// [nodeId] Id of the node to set value for.
  /// [value] New node's value.
  Future setNodeValue(
    NodeId nodeId,
    String value,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
      'value': value,
    };
    await _client.send('DOM.setNodeValue', parameters);
  }

  /// Sets node HTML markup, returns new node id.
  /// [nodeId] Id of the node to set markup for.
  /// [outerHTML] Outer HTML markup to set.
  Future setOuterHTML(
    NodeId nodeId,
    String outerHTML,
  ) async {
    Map parameters = {
      'nodeId': nodeId.toJson(),
      'outerHTML': outerHTML,
    };
    await _client.send('DOM.setOuterHTML', parameters);
  }

  /// Undoes the last performed action.
  Future undo() async {
    await _client.send('DOM.undo');
  }

  /// Returns iframe node that owns iframe with the given domain.
  Future<NodeId> getFrameOwner(
    page.FrameId frameId,
  ) async {
    Map parameters = {
      'frameId': frameId.toJson(),
    };
    Map result = await _client.send('DOM.getFrameOwner', parameters);
    return new NodeId.fromJson(result['nodeId']);
  }
}

class AttributeModifiedEvent {
  /// Id of the node that has changed.
  final NodeId nodeId;

  /// Attribute name.
  final String name;

  /// Attribute value.
  final String value;

  AttributeModifiedEvent({
    @required this.nodeId,
    @required this.name,
    @required this.value,
  });

  factory AttributeModifiedEvent.fromJson(Map json) {
    return new AttributeModifiedEvent(
      nodeId: new NodeId.fromJson(json['nodeId']),
      name: json['name'],
      value: json['value'],
    );
  }
}

class AttributeRemovedEvent {
  /// Id of the node that has changed.
  final NodeId nodeId;

  /// A ttribute name.
  final String name;

  AttributeRemovedEvent({
    @required this.nodeId,
    @required this.name,
  });

  factory AttributeRemovedEvent.fromJson(Map json) {
    return new AttributeRemovedEvent(
      nodeId: new NodeId.fromJson(json['nodeId']),
      name: json['name'],
    );
  }
}

class CharacterDataModifiedEvent {
  /// Id of the node that has changed.
  final NodeId nodeId;

  /// New text value.
  final String characterData;

  CharacterDataModifiedEvent({
    @required this.nodeId,
    @required this.characterData,
  });

  factory CharacterDataModifiedEvent.fromJson(Map json) {
    return new CharacterDataModifiedEvent(
      nodeId: new NodeId.fromJson(json['nodeId']),
      characterData: json['characterData'],
    );
  }
}

class ChildNodeCountUpdatedEvent {
  /// Id of the node that has changed.
  final NodeId nodeId;

  /// New node count.
  final int childNodeCount;

  ChildNodeCountUpdatedEvent({
    @required this.nodeId,
    @required this.childNodeCount,
  });

  factory ChildNodeCountUpdatedEvent.fromJson(Map json) {
    return new ChildNodeCountUpdatedEvent(
      nodeId: new NodeId.fromJson(json['nodeId']),
      childNodeCount: json['childNodeCount'],
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

  ChildNodeInsertedEvent({
    @required this.parentNodeId,
    @required this.previousNodeId,
    @required this.node,
  });

  factory ChildNodeInsertedEvent.fromJson(Map json) {
    return new ChildNodeInsertedEvent(
      parentNodeId: new NodeId.fromJson(json['parentNodeId']),
      previousNodeId: new NodeId.fromJson(json['previousNodeId']),
      node: new Node.fromJson(json['node']),
    );
  }
}

class ChildNodeRemovedEvent {
  /// Parent id.
  final NodeId parentNodeId;

  /// Id of the node that has been removed.
  final NodeId nodeId;

  ChildNodeRemovedEvent({
    @required this.parentNodeId,
    @required this.nodeId,
  });

  factory ChildNodeRemovedEvent.fromJson(Map json) {
    return new ChildNodeRemovedEvent(
      parentNodeId: new NodeId.fromJson(json['parentNodeId']),
      nodeId: new NodeId.fromJson(json['nodeId']),
    );
  }
}

class DistributedNodesUpdatedEvent {
  /// Insertion point where distrubuted nodes were updated.
  final NodeId insertionPointId;

  /// Distributed nodes for given insertion point.
  final List<BackendNode> distributedNodes;

  DistributedNodesUpdatedEvent({
    @required this.insertionPointId,
    @required this.distributedNodes,
  });

  factory DistributedNodesUpdatedEvent.fromJson(Map json) {
    return new DistributedNodesUpdatedEvent(
      insertionPointId: new NodeId.fromJson(json['insertionPointId']),
      distributedNodes: (json['distributedNodes'] as List)
          .map((e) => new BackendNode.fromJson(e))
          .toList(),
    );
  }
}

class PseudoElementAddedEvent {
  /// Pseudo element's parent element id.
  final NodeId parentId;

  /// The added pseudo element.
  final Node pseudoElement;

  PseudoElementAddedEvent({
    @required this.parentId,
    @required this.pseudoElement,
  });

  factory PseudoElementAddedEvent.fromJson(Map json) {
    return new PseudoElementAddedEvent(
      parentId: new NodeId.fromJson(json['parentId']),
      pseudoElement: new Node.fromJson(json['pseudoElement']),
    );
  }
}

class PseudoElementRemovedEvent {
  /// Pseudo element's parent element id.
  final NodeId parentId;

  /// The removed pseudo element id.
  final NodeId pseudoElementId;

  PseudoElementRemovedEvent({
    @required this.parentId,
    @required this.pseudoElementId,
  });

  factory PseudoElementRemovedEvent.fromJson(Map json) {
    return new PseudoElementRemovedEvent(
      parentId: new NodeId.fromJson(json['parentId']),
      pseudoElementId: new NodeId.fromJson(json['pseudoElementId']),
    );
  }
}

class SetChildNodesEvent {
  /// Parent node id to populate with children.
  final NodeId parentId;

  /// Child nodes array.
  final List<Node> nodes;

  SetChildNodesEvent({
    @required this.parentId,
    @required this.nodes,
  });

  factory SetChildNodesEvent.fromJson(Map json) {
    return new SetChildNodesEvent(
      parentId: new NodeId.fromJson(json['parentId']),
      nodes: (json['nodes'] as List).map((e) => new Node.fromJson(e)).toList(),
    );
  }
}

class ShadowRootPoppedEvent {
  /// Host element id.
  final NodeId hostId;

  /// Shadow root id.
  final NodeId rootId;

  ShadowRootPoppedEvent({
    @required this.hostId,
    @required this.rootId,
  });

  factory ShadowRootPoppedEvent.fromJson(Map json) {
    return new ShadowRootPoppedEvent(
      hostId: new NodeId.fromJson(json['hostId']),
      rootId: new NodeId.fromJson(json['rootId']),
    );
  }
}

class ShadowRootPushedEvent {
  /// Host element id.
  final NodeId hostId;

  /// Shadow root.
  final Node root;

  ShadowRootPushedEvent({
    @required this.hostId,
    @required this.root,
  });

  factory ShadowRootPushedEvent.fromJson(Map json) {
    return new ShadowRootPushedEvent(
      hostId: new NodeId.fromJson(json['hostId']),
      root: new Node.fromJson(json['root']),
    );
  }
}

class PerformSearchResult {
  /// Unique search session identifier.
  final String searchId;

  /// Number of search results.
  final int resultCount;

  PerformSearchResult({
    @required this.searchId,
    @required this.resultCount,
  });

  factory PerformSearchResult.fromJson(Map json) {
    return new PerformSearchResult(
      searchId: json['searchId'],
      resultCount: json['resultCount'],
    );
  }
}

/// Unique DOM node identifier.
class NodeId {
  final int value;

  NodeId(this.value);

  factory NodeId.fromJson(int value) => new NodeId(value);

  int toJson() => value;

  bool operator ==(other) => other is NodeId && other.value == value;

  int get hashCode => value.hashCode;

  String toString() => value.toString();
}

/// Unique DOM node identifier used to reference a node that may not have been pushed to the
/// front-end.
class BackendNodeId {
  final int value;

  BackendNodeId(this.value);

  factory BackendNodeId.fromJson(int value) => new BackendNodeId(value);

  int toJson() => value;

  bool operator ==(other) => other is BackendNodeId && other.value == value;

  int get hashCode => value.hashCode;

  String toString() => value.toString();
}

/// Backend node with a friendly name.
class BackendNode {
  /// `Node`'s nodeType.
  final int nodeType;

  /// `Node`'s nodeName.
  final String nodeName;

  final BackendNodeId backendNodeId;

  BackendNode({
    @required this.nodeType,
    @required this.nodeName,
    @required this.backendNodeId,
  });

  factory BackendNode.fromJson(Map json) {
    return new BackendNode(
      nodeType: json['nodeType'],
      nodeName: json['nodeName'],
      backendNodeId: new BackendNodeId.fromJson(json['backendNodeId']),
    );
  }

  Map toJson() {
    Map json = {
      'nodeType': nodeType,
      'nodeName': nodeName,
      'backendNodeId': backendNodeId.toJson(),
    };
    return json;
  }
}

/// Pseudo element type.
class PseudoType {
  static const PseudoType firstLine = const PseudoType._('first-line');
  static const PseudoType firstLetter = const PseudoType._('first-letter');
  static const PseudoType before = const PseudoType._('before');
  static const PseudoType after = const PseudoType._('after');
  static const PseudoType backdrop = const PseudoType._('backdrop');
  static const PseudoType selection = const PseudoType._('selection');
  static const PseudoType firstLineInherited =
      const PseudoType._('first-line-inherited');
  static const PseudoType scrollbar = const PseudoType._('scrollbar');
  static const PseudoType scrollbarThumb =
      const PseudoType._('scrollbar-thumb');
  static const PseudoType scrollbarButton =
      const PseudoType._('scrollbar-button');
  static const PseudoType scrollbarTrack =
      const PseudoType._('scrollbar-track');
  static const PseudoType scrollbarTrackPiece =
      const PseudoType._('scrollbar-track-piece');
  static const PseudoType scrollbarCorner =
      const PseudoType._('scrollbar-corner');
  static const PseudoType resizer = const PseudoType._('resizer');
  static const PseudoType inputListButton =
      const PseudoType._('input-list-button');
  static const values = const {
    'first-line': firstLine,
    'first-letter': firstLetter,
    'before': before,
    'after': after,
    'backdrop': backdrop,
    'selection': selection,
    'first-line-inherited': firstLineInherited,
    'scrollbar': scrollbar,
    'scrollbar-thumb': scrollbarThumb,
    'scrollbar-button': scrollbarButton,
    'scrollbar-track': scrollbarTrack,
    'scrollbar-track-piece': scrollbarTrackPiece,
    'scrollbar-corner': scrollbarCorner,
    'resizer': resizer,
    'input-list-button': inputListButton,
  };

  final String value;

  const PseudoType._(this.value);

  factory PseudoType.fromJson(String value) => values[value];

  String toJson() => value;

  String toString() => value.toString();
}

/// Shadow root type.
class ShadowRootType {
  static const ShadowRootType userAgent = const ShadowRootType._('user-agent');
  static const ShadowRootType open = const ShadowRootType._('open');
  static const ShadowRootType closed = const ShadowRootType._('closed');
  static const values = const {
    'user-agent': userAgent,
    'open': open,
    'closed': closed,
  };

  final String value;

  const ShadowRootType._(this.value);

  factory ShadowRootType.fromJson(String value) => values[value];

  String toJson() => value;

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
  final NodeId parentId;

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
  final int childNodeCount;

  /// Child nodes of this node when requested with children.
  final List<Node> children;

  /// Attributes of the `Element` node in the form of flat array `[name1, value1, name2, value2]`.
  final List<String> attributes;

  /// Document URL that `Document` or `FrameOwner` node points to.
  final String documentURL;

  /// Base URL that `Document` or `FrameOwner` node uses for URL completion.
  final String baseURL;

  /// `DocumentType`'s publicId.
  final String publicId;

  /// `DocumentType`'s systemId.
  final String systemId;

  /// `DocumentType`'s internalSubset.
  final String internalSubset;

  /// `Document`'s XML version in case of XML documents.
  final String xmlVersion;

  /// `Attr`'s name.
  final String name;

  /// `Attr`'s value.
  final String value;

  /// Pseudo element type for this node.
  final PseudoType pseudoType;

  /// Shadow root type.
  final ShadowRootType shadowRootType;

  /// Frame ID for frame owner elements.
  final page.FrameId frameId;

  /// Content document for frame owner elements.
  final Node contentDocument;

  /// Shadow root list for given element host.
  final List<Node> shadowRoots;

  /// Content document fragment for template elements.
  final Node templateContent;

  /// Pseudo elements associated with this node.
  final List<Node> pseudoElements;

  /// Import document for the HTMLImport links.
  final Node importedDocument;

  /// Distributed nodes for given insertion point.
  final List<BackendNode> distributedNodes;

  /// Whether the node is SVG.
  final bool isSVG;

  Node({
    @required this.nodeId,
    this.parentId,
    @required this.backendNodeId,
    @required this.nodeType,
    @required this.nodeName,
    @required this.localName,
    @required this.nodeValue,
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
    this.importedDocument,
    this.distributedNodes,
    this.isSVG,
  });

  factory Node.fromJson(Map json) {
    return new Node(
      nodeId: new NodeId.fromJson(json['nodeId']),
      parentId: json.containsKey('parentId')
          ? new NodeId.fromJson(json['parentId'])
          : null,
      backendNodeId: new BackendNodeId.fromJson(json['backendNodeId']),
      nodeType: json['nodeType'],
      nodeName: json['nodeName'],
      localName: json['localName'],
      nodeValue: json['nodeValue'],
      childNodeCount:
          json.containsKey('childNodeCount') ? json['childNodeCount'] : null,
      children: json.containsKey('children')
          ? (json['children'] as List).map((e) => new Node.fromJson(e)).toList()
          : null,
      attributes: json.containsKey('attributes')
          ? (json['attributes'] as List).map((e) => e as String).toList()
          : null,
      documentURL: json.containsKey('documentURL') ? json['documentURL'] : null,
      baseURL: json.containsKey('baseURL') ? json['baseURL'] : null,
      publicId: json.containsKey('publicId') ? json['publicId'] : null,
      systemId: json.containsKey('systemId') ? json['systemId'] : null,
      internalSubset:
          json.containsKey('internalSubset') ? json['internalSubset'] : null,
      xmlVersion: json.containsKey('xmlVersion') ? json['xmlVersion'] : null,
      name: json.containsKey('name') ? json['name'] : null,
      value: json.containsKey('value') ? json['value'] : null,
      pseudoType: json.containsKey('pseudoType')
          ? new PseudoType.fromJson(json['pseudoType'])
          : null,
      shadowRootType: json.containsKey('shadowRootType')
          ? new ShadowRootType.fromJson(json['shadowRootType'])
          : null,
      frameId: json.containsKey('frameId')
          ? new page.FrameId.fromJson(json['frameId'])
          : null,
      contentDocument: json.containsKey('contentDocument')
          ? new Node.fromJson(json['contentDocument'])
          : null,
      shadowRoots: json.containsKey('shadowRoots')
          ? (json['shadowRoots'] as List)
              .map((e) => new Node.fromJson(e))
              .toList()
          : null,
      templateContent: json.containsKey('templateContent')
          ? new Node.fromJson(json['templateContent'])
          : null,
      pseudoElements: json.containsKey('pseudoElements')
          ? (json['pseudoElements'] as List)
              .map((e) => new Node.fromJson(e))
              .toList()
          : null,
      importedDocument: json.containsKey('importedDocument')
          ? new Node.fromJson(json['importedDocument'])
          : null,
      distributedNodes: json.containsKey('distributedNodes')
          ? (json['distributedNodes'] as List)
              .map((e) => new BackendNode.fromJson(e))
              .toList()
          : null,
      isSVG: json.containsKey('isSVG') ? json['isSVG'] : null,
    );
  }

  Map toJson() {
    Map json = {
      'nodeId': nodeId.toJson(),
      'backendNodeId': backendNodeId.toJson(),
      'nodeType': nodeType,
      'nodeName': nodeName,
      'localName': localName,
      'nodeValue': nodeValue,
    };
    if (parentId != null) {
      json['parentId'] = parentId.toJson();
    }
    if (childNodeCount != null) {
      json['childNodeCount'] = childNodeCount;
    }
    if (children != null) {
      json['children'] = children.map((e) => e.toJson()).toList();
    }
    if (attributes != null) {
      json['attributes'] = attributes.map((e) => e).toList();
    }
    if (documentURL != null) {
      json['documentURL'] = documentURL;
    }
    if (baseURL != null) {
      json['baseURL'] = baseURL;
    }
    if (publicId != null) {
      json['publicId'] = publicId;
    }
    if (systemId != null) {
      json['systemId'] = systemId;
    }
    if (internalSubset != null) {
      json['internalSubset'] = internalSubset;
    }
    if (xmlVersion != null) {
      json['xmlVersion'] = xmlVersion;
    }
    if (name != null) {
      json['name'] = name;
    }
    if (value != null) {
      json['value'] = value;
    }
    if (pseudoType != null) {
      json['pseudoType'] = pseudoType.toJson();
    }
    if (shadowRootType != null) {
      json['shadowRootType'] = shadowRootType.toJson();
    }
    if (frameId != null) {
      json['frameId'] = frameId.toJson();
    }
    if (contentDocument != null) {
      json['contentDocument'] = contentDocument.toJson();
    }
    if (shadowRoots != null) {
      json['shadowRoots'] = shadowRoots.map((e) => e.toJson()).toList();
    }
    if (templateContent != null) {
      json['templateContent'] = templateContent.toJson();
    }
    if (pseudoElements != null) {
      json['pseudoElements'] = pseudoElements.map((e) => e.toJson()).toList();
    }
    if (importedDocument != null) {
      json['importedDocument'] = importedDocument.toJson();
    }
    if (distributedNodes != null) {
      json['distributedNodes'] =
          distributedNodes.map((e) => e.toJson()).toList();
    }
    if (isSVG != null) {
      json['isSVG'] = isSVG;
    }
    return json;
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
  final num a;

  RGBA({
    @required this.r,
    @required this.g,
    @required this.b,
    this.a,
  });

  factory RGBA.fromJson(Map json) {
    return new RGBA(
      r: json['r'],
      g: json['g'],
      b: json['b'],
      a: json.containsKey('a') ? json['a'] : null,
    );
  }

  Map toJson() {
    Map json = {
      'r': r,
      'g': g,
      'b': b,
    };
    if (a != null) {
      json['a'] = a;
    }
    return json;
  }
}

/// An array of quad vertices, x immediately followed by y for each point, points clock-wise.
class Quad {
  final List<num> value;

  Quad(this.value);

  factory Quad.fromJson(List<num> value) => new Quad(value);

  List<num> toJson() => value;

  bool operator ==(other) => other is Quad && other.value == value;

  int get hashCode => value.hashCode;

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
  final ShapeOutsideInfo shapeOutside;

  BoxModel({
    @required this.content,
    @required this.padding,
    @required this.border,
    @required this.margin,
    @required this.width,
    @required this.height,
    this.shapeOutside,
  });

  factory BoxModel.fromJson(Map json) {
    return new BoxModel(
      content: new Quad.fromJson(json['content']),
      padding: new Quad.fromJson(json['padding']),
      border: new Quad.fromJson(json['border']),
      margin: new Quad.fromJson(json['margin']),
      width: json['width'],
      height: json['height'],
      shapeOutside: json.containsKey('shapeOutside')
          ? new ShapeOutsideInfo.fromJson(json['shapeOutside'])
          : null,
    );
  }

  Map toJson() {
    Map json = {
      'content': content.toJson(),
      'padding': padding.toJson(),
      'border': border.toJson(),
      'margin': margin.toJson(),
      'width': width,
      'height': height,
    };
    if (shapeOutside != null) {
      json['shapeOutside'] = shapeOutside.toJson();
    }
    return json;
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

  ShapeOutsideInfo({
    @required this.bounds,
    @required this.shape,
    @required this.marginShape,
  });

  factory ShapeOutsideInfo.fromJson(Map json) {
    return new ShapeOutsideInfo(
      bounds: new Quad.fromJson(json['bounds']),
      shape: (json['shape'] as List).map((e) => e as dynamic).toList(),
      marginShape:
          (json['marginShape'] as List).map((e) => e as dynamic).toList(),
    );
  }

  Map toJson() {
    Map json = {
      'bounds': bounds.toJson(),
      'shape': shape.map((e) => e.toJson()).toList(),
      'marginShape': marginShape.map((e) => e.toJson()).toList(),
    };
    return json;
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

  Rect({
    @required this.x,
    @required this.y,
    @required this.width,
    @required this.height,
  });

  factory Rect.fromJson(Map json) {
    return new Rect(
      x: json['x'],
      y: json['y'],
      width: json['width'],
      height: json['height'],
    );
  }

  Map toJson() {
    Map json = {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
    return json;
  }
}
