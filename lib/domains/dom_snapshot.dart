/// This domain facilitates obtaining document snapshots with DOM, layout, and
/// style information.

import 'dart:async';
// ignore: unused_import
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'dom.dart' as dom;
import 'page.dart' as page;

class DOMSnapshotDomain {
  final Client _client;

  DOMSnapshotDomain(this._client);

  /// Returns a document snapshot, including the full DOM tree of the root node
  /// (including iframes, template contents, and imported documents) in a
  /// flattened array, as well as layout and white-listed computed style
  /// information for the nodes. Shadow DOM in the returned DOM tree is flattened.
  ///
  /// [computedStyleWhitelist] Whitelist of computed styles to return.
  Future<GetSnapshotResult> getSnapshot(
    List<String> computedStyleWhitelist,
  ) async {
    Map parameters = {
      'computedStyleWhitelist': computedStyleWhitelist.map((e) => e).toList(),
    };
    Map result = await _client.send('DOMSnapshot.getSnapshot', parameters);
    return new GetSnapshotResult.fromJson(result);
  }
}

class GetSnapshotResult {
  /// The nodes in the DOM tree. The DOMNode at index 0 corresponds to the root
  /// document.
  final List<DOMNode> domNodes;

  /// The nodes in the layout tree.
  final List<LayoutTreeNode> layoutTreeNodes;

  /// Whitelisted ComputedStyle properties for each node in the layout tree.
  final List<ComputedStyle> computedStyles;

  GetSnapshotResult({
    @required this.domNodes,
    @required this.layoutTreeNodes,
    @required this.computedStyles,
  });

  factory GetSnapshotResult.fromJson(Map json) {
    return new GetSnapshotResult(
      domNodes: (json['domNodes'] as List)
          .map((e) => new DOMNode.fromJson(e))
          .toList(),
      layoutTreeNodes: (json['layoutTreeNodes'] as List)
          .map((e) => new LayoutTreeNode.fromJson(e))
          .toList(),
      computedStyles: (json['computedStyles'] as List)
          .map((e) => new ComputedStyle.fromJson(e))
          .toList(),
    );
  }
}

/// A Node in the DOM tree.
class DOMNode {
  /// `Node`'s nodeType.
  final int nodeType;

  /// `Node`'s nodeName.
  final String nodeName;

  /// `Node`'s nodeValue.
  final String nodeValue;

  /// Only set for textarea elements, contains the text value.
  final String textValue;

  /// Only set for input elements, contains the input's associated text value.
  final String inputValue;

  /// Only set for radio and checkbox input elements, indicates if the element has
  /// been checked
  final bool inputChecked;

  /// Only set for option elements, indicates if the element has been selected
  final bool optionSelected;

  /// `Node`'s id, corresponds to DOM.Node.backendNodeId.
  final dom.BackendNodeId backendNodeId;

  /// The indexes of the node's child nodes in the `domNodes` array returned by
  /// `getSnapshot`, if any.
  final List<int> childNodeIndexes;

  /// Attributes of an `Element` node.
  final List<NameValue> attributes;

  /// Indexes of pseudo elements associated with this node in the `domNodes` array
  /// returned by `getSnapshot`, if any.
  final List<int> pseudoElementIndexes;

  /// The index of the node's related layout tree node in the `layoutTreeNodes`
  /// array returned by `getSnapshot`, if any.
  final int layoutNodeIndex;

  /// Document URL that `Document` or `FrameOwner` node points to.
  final String documentURL;

  /// Base URL that `Document` or `FrameOwner` node uses for URL completion.
  final String baseURL;

  /// Only set for documents, contains the document's content language.
  final String contentLanguage;

  /// Only set for documents, contains the document's character set encoding.
  final String documentEncoding;

  /// `DocumentType` node's publicId.
  final String publicId;

  /// `DocumentType` node's systemId.
  final String systemId;

  /// Frame ID for frame owner elements and also for the document node.
  final page.FrameId frameId;

  /// The index of a frame owner element's content document in the `domNodes`
  /// array returned by `getSnapshot`, if any.
  final int contentDocumentIndex;

  /// Index of the imported document's node of a link element in the `domNodes`
  /// array returned by `getSnapshot`, if any.
  final int importedDocumentIndex;

  /// Index of the content node of a template element in the `domNodes` array
  /// returned by `getSnapshot`.
  final int templateContentIndex;

  /// Type of a pseudo element node.
  final dom.PseudoType pseudoType;

  /// Whether this DOM node responds to mouse clicks. This includes nodes that
  /// have had click event listeners attached via JavaScript as well as anchor
  /// tags that naturally navigate when clicked.
  final bool isClickable;

  DOMNode({
    @required this.nodeType,
    @required this.nodeName,
    @required this.nodeValue,
    this.textValue,
    this.inputValue,
    this.inputChecked,
    this.optionSelected,
    @required this.backendNodeId,
    this.childNodeIndexes,
    this.attributes,
    this.pseudoElementIndexes,
    this.layoutNodeIndex,
    this.documentURL,
    this.baseURL,
    this.contentLanguage,
    this.documentEncoding,
    this.publicId,
    this.systemId,
    this.frameId,
    this.contentDocumentIndex,
    this.importedDocumentIndex,
    this.templateContentIndex,
    this.pseudoType,
    this.isClickable,
  });

  factory DOMNode.fromJson(Map json) {
    return new DOMNode(
      nodeType: json['nodeType'],
      nodeName: json['nodeName'],
      nodeValue: json['nodeValue'],
      textValue: json.containsKey('textValue') ? json['textValue'] : null,
      inputValue: json.containsKey('inputValue') ? json['inputValue'] : null,
      inputChecked:
          json.containsKey('inputChecked') ? json['inputChecked'] : null,
      optionSelected:
          json.containsKey('optionSelected') ? json['optionSelected'] : null,
      backendNodeId: new dom.BackendNodeId.fromJson(json['backendNodeId']),
      childNodeIndexes: json.containsKey('childNodeIndexes')
          ? (json['childNodeIndexes'] as List).map((e) => e as int).toList()
          : null,
      attributes: json.containsKey('attributes')
          ? (json['attributes'] as List)
              .map((e) => new NameValue.fromJson(e))
              .toList()
          : null,
      pseudoElementIndexes: json.containsKey('pseudoElementIndexes')
          ? (json['pseudoElementIndexes'] as List).map((e) => e as int).toList()
          : null,
      layoutNodeIndex:
          json.containsKey('layoutNodeIndex') ? json['layoutNodeIndex'] : null,
      documentURL: json.containsKey('documentURL') ? json['documentURL'] : null,
      baseURL: json.containsKey('baseURL') ? json['baseURL'] : null,
      contentLanguage:
          json.containsKey('contentLanguage') ? json['contentLanguage'] : null,
      documentEncoding: json.containsKey('documentEncoding')
          ? json['documentEncoding']
          : null,
      publicId: json.containsKey('publicId') ? json['publicId'] : null,
      systemId: json.containsKey('systemId') ? json['systemId'] : null,
      frameId: json.containsKey('frameId')
          ? new page.FrameId.fromJson(json['frameId'])
          : null,
      contentDocumentIndex: json.containsKey('contentDocumentIndex')
          ? json['contentDocumentIndex']
          : null,
      importedDocumentIndex: json.containsKey('importedDocumentIndex')
          ? json['importedDocumentIndex']
          : null,
      templateContentIndex: json.containsKey('templateContentIndex')
          ? json['templateContentIndex']
          : null,
      pseudoType: json.containsKey('pseudoType')
          ? new dom.PseudoType.fromJson(json['pseudoType'])
          : null,
      isClickable: json.containsKey('isClickable') ? json['isClickable'] : null,
    );
  }

  Map toJson() {
    Map json = {
      'nodeType': nodeType,
      'nodeName': nodeName,
      'nodeValue': nodeValue,
      'backendNodeId': backendNodeId.toJson(),
    };
    if (textValue != null) {
      json['textValue'] = textValue;
    }
    if (inputValue != null) {
      json['inputValue'] = inputValue;
    }
    if (inputChecked != null) {
      json['inputChecked'] = inputChecked;
    }
    if (optionSelected != null) {
      json['optionSelected'] = optionSelected;
    }
    if (childNodeIndexes != null) {
      json['childNodeIndexes'] = childNodeIndexes.map((e) => e).toList();
    }
    if (attributes != null) {
      json['attributes'] = attributes.map((e) => e.toJson()).toList();
    }
    if (pseudoElementIndexes != null) {
      json['pseudoElementIndexes'] =
          pseudoElementIndexes.map((e) => e).toList();
    }
    if (layoutNodeIndex != null) {
      json['layoutNodeIndex'] = layoutNodeIndex;
    }
    if (documentURL != null) {
      json['documentURL'] = documentURL;
    }
    if (baseURL != null) {
      json['baseURL'] = baseURL;
    }
    if (contentLanguage != null) {
      json['contentLanguage'] = contentLanguage;
    }
    if (documentEncoding != null) {
      json['documentEncoding'] = documentEncoding;
    }
    if (publicId != null) {
      json['publicId'] = publicId;
    }
    if (systemId != null) {
      json['systemId'] = systemId;
    }
    if (frameId != null) {
      json['frameId'] = frameId.toJson();
    }
    if (contentDocumentIndex != null) {
      json['contentDocumentIndex'] = contentDocumentIndex;
    }
    if (importedDocumentIndex != null) {
      json['importedDocumentIndex'] = importedDocumentIndex;
    }
    if (templateContentIndex != null) {
      json['templateContentIndex'] = templateContentIndex;
    }
    if (pseudoType != null) {
      json['pseudoType'] = pseudoType.toJson();
    }
    if (isClickable != null) {
      json['isClickable'] = isClickable;
    }
    return json;
  }
}

/// Details of post layout rendered text positions. The exact layout should not
/// be regarded as stable and may change between versions.
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

  factory InlineTextBox.fromJson(Map json) {
    return new InlineTextBox(
      boundingBox: new dom.Rect.fromJson(json['boundingBox']),
      startCharacterIndex: json['startCharacterIndex'],
      numCharacters: json['numCharacters'],
    );
  }

  Map toJson() {
    Map json = {
      'boundingBox': boundingBox.toJson(),
      'startCharacterIndex': startCharacterIndex,
      'numCharacters': numCharacters,
    };
    return json;
  }
}

/// Details of an element in the DOM tree with a LayoutObject.
class LayoutTreeNode {
  /// The index of the related DOM node in the `domNodes` array returned by
  /// `getSnapshot`.
  final int domNodeIndex;

  /// The absolute position bounding box.
  final dom.Rect boundingBox;

  /// Contents of the LayoutText, if any.
  final String layoutText;

  /// The post-layout inline text nodes, if any.
  final List<InlineTextBox> inlineTextNodes;

  /// Index into the `computedStyles` array returned by `getSnapshot`.
  final int styleIndex;

  LayoutTreeNode({
    @required this.domNodeIndex,
    @required this.boundingBox,
    this.layoutText,
    this.inlineTextNodes,
    this.styleIndex,
  });

  factory LayoutTreeNode.fromJson(Map json) {
    return new LayoutTreeNode(
      domNodeIndex: json['domNodeIndex'],
      boundingBox: new dom.Rect.fromJson(json['boundingBox']),
      layoutText: json.containsKey('layoutText') ? json['layoutText'] : null,
      inlineTextNodes: json.containsKey('inlineTextNodes')
          ? (json['inlineTextNodes'] as List)
              .map((e) => new InlineTextBox.fromJson(e))
              .toList()
          : null,
      styleIndex: json.containsKey('styleIndex') ? json['styleIndex'] : null,
    );
  }

  Map toJson() {
    Map json = {
      'domNodeIndex': domNodeIndex,
      'boundingBox': boundingBox.toJson(),
    };
    if (layoutText != null) {
      json['layoutText'] = layoutText;
    }
    if (inlineTextNodes != null) {
      json['inlineTextNodes'] = inlineTextNodes.map((e) => e.toJson()).toList();
    }
    if (styleIndex != null) {
      json['styleIndex'] = styleIndex;
    }
    return json;
  }
}

/// A subset of the full ComputedStyle as defined by the request whitelist.
class ComputedStyle {
  /// Name/value pairs of computed style properties.
  final List<NameValue> properties;

  ComputedStyle({
    @required this.properties,
  });

  factory ComputedStyle.fromJson(Map json) {
    return new ComputedStyle(
      properties: (json['properties'] as List)
          .map((e) => new NameValue.fromJson(e))
          .toList(),
    );
  }

  Map toJson() {
    Map json = {
      'properties': properties.map((e) => e.toJson()).toList(),
    };
    return json;
  }
}

/// A name/value pair.
class NameValue {
  /// Attribute/property name.
  final String name;

  /// Attribute/property value.
  final String value;

  NameValue({
    @required this.name,
    @required this.value,
  });

  factory NameValue.fromJson(Map json) {
    return new NameValue(
      name: json['name'],
      value: json['value'],
    );
  }

  Map toJson() {
    Map json = {
      'name': name,
      'value': value,
    };
    return json;
  }
}
