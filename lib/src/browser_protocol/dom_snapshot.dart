/// This domain facilitates obtaining document snapshots with DOM, layout, and style information.

import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';
import 'dom.dart' as dom;
import 'page.dart' as page;
import 'css.dart' as css;

class DOMSnapshotManager {
  final Session _client;

  DOMSnapshotManager(this._client);

  /// Returns a document snapshot, including the full DOM tree of the root node (including iframes, template contents, and imported documents) in a flattened array, as well as layout and white-listed computed style information for the nodes. Shadow DOM in the returned DOM tree is flattened.
  /// [computedStyleWhitelist] Whitelist of computed styles to return.
  Future<GetSnapshotResult> getSnapshot(
    List<String> computedStyleWhitelist,
  ) async {
    Map parameters = {
      'computedStyleWhitelist':
          computedStyleWhitelist.map((e) => e.toString()).toList(),
    };
    await _client.send('DOMSnapshot.getSnapshot', parameters);
  }
}

class GetSnapshotResult {
  /// The nodes in the DOM tree. The DOMNode at index 0 corresponds to the root document.
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
}

/// A Node in the DOM tree.
class DOMNode {
  /// <code>Node</code>'s nodeType.
  final int nodeType;

  /// <code>Node</code>'s nodeName.
  final String nodeName;

  /// <code>Node</code>'s nodeValue.
  final String nodeValue;

  /// Only set for textarea elements, contains the text value.
  final String textValue;

  /// Only set for input elements, contains the input's associated text value.
  final String inputValue;

  /// Only set for radio and checkbox input elements, indicates if the element has been checked
  final bool inputChecked;

  /// Only set for option elements, indicates if the element has been selected
  final bool optionSelected;

  /// <code>Node</code>'s id, corresponds to DOM.Node.backendNodeId.
  final dom.BackendNodeId backendNodeId;

  /// The indexes of the node's child nodes in the <code>domNodes</code> array returned by <code>getSnapshot</code>, if any.
  final List<int> childNodeIndexes;

  /// Attributes of an <code>Element</code> node.
  final List<NameValue> attributes;

  /// Indexes of pseudo elements associated with this node in the <code>domNodes</code> array returned by <code>getSnapshot</code>, if any.
  final List<int> pseudoElementIndexes;

  /// The index of the node's related layout tree node in the <code>layoutTreeNodes</code> array returned by <code>getSnapshot</code>, if any.
  final int layoutNodeIndex;

  /// Document URL that <code>Document</code> or <code>FrameOwner</code> node points to.
  final String documentURL;

  /// Base URL that <code>Document</code> or <code>FrameOwner</code> node uses for URL completion.
  final String baseURL;

  /// Only set for documents, contains the document's content language.
  final String contentLanguage;

  /// Only set for documents, contains the document's character set encoding.
  final String documentEncoding;

  /// <code>DocumentType</code> node's publicId.
  final String publicId;

  /// <code>DocumentType</code> node's systemId.
  final String systemId;

  /// Frame ID for frame owner elements and also for the document node.
  final page.FrameId frameId;

  /// The index of a frame owner element's content document in the <code>domNodes</code> array returned by <code>getSnapshot</code>, if any.
  final int contentDocumentIndex;

  /// Index of the imported document's node of a link element in the <code>domNodes</code> array returned by <code>getSnapshot</code>, if any.
  final int importedDocumentIndex;

  /// Index of the content node of a template element in the <code>domNodes</code> array returned by <code>getSnapshot</code>.
  final int templateContentIndex;

  /// Type of a pseudo element node.
  final dom.PseudoType pseudoType;

  /// Whether this DOM node responds to mouse clicks. This includes nodes that have had click event listeners attached via JavaScript as well as anchor tags that naturally navigate when clicked.
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

  Map toJson() {
    Map json = {
      'nodeType': nodeType.toString(),
      'nodeName': nodeName.toString(),
      'nodeValue': nodeValue.toString(),
      'backendNodeId': backendNodeId.toJson(),
    };
    if (textValue != null) {
      json['textValue'] = textValue.toString();
    }
    if (inputValue != null) {
      json['inputValue'] = inputValue.toString();
    }
    if (inputChecked != null) {
      json['inputChecked'] = inputChecked.toString();
    }
    if (optionSelected != null) {
      json['optionSelected'] = optionSelected.toString();
    }
    if (childNodeIndexes != null) {
      json['childNodeIndexes'] =
          childNodeIndexes.map((e) => e.toString()).toList();
    }
    if (attributes != null) {
      json['attributes'] = attributes.map((e) => e.toJson()).toList();
    }
    if (pseudoElementIndexes != null) {
      json['pseudoElementIndexes'] =
          pseudoElementIndexes.map((e) => e.toString()).toList();
    }
    if (layoutNodeIndex != null) {
      json['layoutNodeIndex'] = layoutNodeIndex.toString();
    }
    if (documentURL != null) {
      json['documentURL'] = documentURL.toString();
    }
    if (baseURL != null) {
      json['baseURL'] = baseURL.toString();
    }
    if (contentLanguage != null) {
      json['contentLanguage'] = contentLanguage.toString();
    }
    if (documentEncoding != null) {
      json['documentEncoding'] = documentEncoding.toString();
    }
    if (publicId != null) {
      json['publicId'] = publicId.toString();
    }
    if (systemId != null) {
      json['systemId'] = systemId.toString();
    }
    if (frameId != null) {
      json['frameId'] = frameId.toJson();
    }
    if (contentDocumentIndex != null) {
      json['contentDocumentIndex'] = contentDocumentIndex.toString();
    }
    if (importedDocumentIndex != null) {
      json['importedDocumentIndex'] = importedDocumentIndex.toString();
    }
    if (templateContentIndex != null) {
      json['templateContentIndex'] = templateContentIndex.toString();
    }
    if (pseudoType != null) {
      json['pseudoType'] = pseudoType.toJson();
    }
    if (isClickable != null) {
      json['isClickable'] = isClickable.toString();
    }
    return json;
  }
}

/// Details of an element in the DOM tree with a LayoutObject.
class LayoutTreeNode {
  /// The index of the related DOM node in the <code>domNodes</code> array returned by <code>getSnapshot</code>.
  final int domNodeIndex;

  /// The absolute position bounding box.
  final dom.Rect boundingBox;

  /// Contents of the LayoutText, if any.
  final String layoutText;

  /// The post-layout inline text nodes, if any.
  final List<css.InlineTextBox> inlineTextNodes;

  /// Index into the <code>computedStyles</code> array returned by <code>getSnapshot</code>.
  final int styleIndex;

  LayoutTreeNode({
    @required this.domNodeIndex,
    @required this.boundingBox,
    this.layoutText,
    this.inlineTextNodes,
    this.styleIndex,
  });

  Map toJson() {
    Map json = {
      'domNodeIndex': domNodeIndex.toString(),
      'boundingBox': boundingBox.toJson(),
    };
    if (layoutText != null) {
      json['layoutText'] = layoutText.toString();
    }
    if (inlineTextNodes != null) {
      json['inlineTextNodes'] = inlineTextNodes.map((e) => e.toJson()).toList();
    }
    if (styleIndex != null) {
      json['styleIndex'] = styleIndex.toString();
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

  Map toJson() {
    Map json = {
      'name': name.toString(),
      'value': value.toString(),
    };
    return json;
  }
}
