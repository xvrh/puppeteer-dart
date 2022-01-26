import 'package:collection/collection.dart';
import '../../protocol/accessibility.dart';
import '../../protocol/dev_tools.dart';
import '../../protocol/dom.dart';
import '../../puppeteer.dart';

/// The Accessibility class provides methods for inspecting Chromium's
/// accessibility tree. The accessibility tree is used by assistive technology
/// such as [screen readers](https://en.wikipedia.org/wiki/Screen_reader) or
/// [switches](https://en.wikipedia.org/wiki/Switch_access).
///
/// Accessibility is a very platform-specific thing. On different platforms,
/// there are different screen readers that might have wildly different output.
///
/// Blink - Chrome's rendering engine - has a concept of "accessibility tree",
/// which is then translated into different platform-specific APIs.
/// Accessibility namespace gives users access to the Blink Accessibility Tree.
///
/// Most of the accessibility tree gets filtered out when converting from
/// Blink AX Tree to Platform-specific AX-Tree or by assistive technologies
/// themselves. By default, Puppeteer tries to approximate this filtering,
/// exposing only the "interesting" nodes of the tree.
class Accessibility {
  final DevTools _devTools;

  Accessibility(this._devTools);

  /// Captures the current state of the accessibility tree. The returned object
  /// represents the root accessible node of the page.
  ///
  /// > **NOTE** The Chromium accessibility tree contains nodes that go unused
  ///   on most platforms and by most screen readers. Puppeteer will discard them
  ///   as well for an easier to process tree, unless `interestingOnly` is set to `false`.
  ///
  /// An example of dumping the entire accessibility tree:
  /// ```dart
  /// var snapshot = await page.accessibility.snapshot();
  /// print(snapshot);
  /// ```
  ///
  /// An example of logging the focused node's name:
  /// ```dart
  /// AXNode? findFocusedNode(AXNode node) {
  ///   if (node.focused) return node;
  ///   for (var child in node.children) {
  ///     var foundNode = findFocusedNode(child);
  ///     return foundNode;
  ///   }
  ///   return null;
  /// }
  ///
  /// var snapshot = await page.accessibility.snapshot();
  /// var node = findFocusedNode(snapshot);
  /// print(node?.name);
  /// ```
  ///
  /// Parameters:
  ///  - `interestingOnly` Prune uninteresting nodes from the tree. Defaults to `true`.
  ///  - `root` The root DOM element for the snapshot. Defaults to the whole page.
  Future<AXNode> snapshot({bool? interestingOnly, ElementHandle? root}) async {
    interestingOnly ??= true;
    var nodes = await _devTools.accessibility.getFullAXTree();
    BackendNodeId? backendNodeId;
    if (root != null) {
      var node = await _devTools.dom
          .describeNode(objectId: root.remoteObject.objectId);
      backendNodeId = node.backendNodeId;
    }
    var defaultRoot = _AXNode.createTree(nodes);
    _AXNode? needle = defaultRoot;
    if (backendNodeId != null) {
      needle = defaultRoot
          .find((node) => node._payload.backendDOMNodeId == backendNodeId);
      if (needle == null) return AXNode.empty;
    }
    if (!interestingOnly) return _serializeTree(needle)[0];

    var interestingNodes = <_AXNode>{};
    _collectInterestingNodes(interestingNodes, defaultRoot,
        insideControl: false);
    if (!interestingNodes.contains(needle)) return AXNode.empty;
    return _serializeTree(needle, whitelistedNodes: interestingNodes)[0];
  }
}

void _collectInterestingNodes(Set<_AXNode> collection, _AXNode node,
    {required bool insideControl}) {
  if (node.isInteresting(insideControl: insideControl)) {
    collection.add(node);
  }
  if (node.isLeafNode) {
    return;
  }
  insideControl = insideControl || node.isControl;
  for (var child in node._children) {
    _collectInterestingNodes(collection, child, insideControl: insideControl);
  }
}

List<AXNode> _serializeTree(_AXNode node, {Set<_AXNode>? whitelistedNodes}) {
  var children = <AXNode>[];
  for (var child in node._children) {
    children.addAll(_serializeTree(child, whitelistedNodes: whitelistedNodes));
  }

  if (whitelistedNodes != null &&
      whitelistedNodes.isNotEmpty &&
      !whitelistedNodes.contains(node)) {
    return children;
  }

  var serializedNode = node.serialize();
  if (children.isNotEmpty) {
    serializedNode.children.addAll(children);
  }
  return [serializedNode];
}

/// An Accessibility Node
class AXNode {
  static final empty = AXNode();

  static final TriState stateTrue = TriState._(true, false);
  static final TriState stateFalse = TriState._(false, false);
  static final TriState stateMixed = TriState._(false, true);

  final Map<String, dynamic> _properties;

  AXNode(
      {String? role,
      String? name,
      Object? value,
      String? description,
      String? keyShortcuts,
      String? roleDescription,
      String? valueText,
      bool? disabled,
      bool? expanded,
      bool? focused,
      bool? modal,
      bool? multiLine,
      bool? multiSelectable,
      bool? readonly,
      bool? required,
      bool? selected,
      TriState? checked,
      TriState? pressed,
      num? level,
      num? valueMin,
      num? valueMax,
      String? autocomplete,
      String? hasPopup,
      String? invalid,
      String? orientation,
      List<AXNode>? children})
      : children = children ?? <AXNode>[],
        _properties = {
          'role': role,
          'name': name,
          'value': value,
          'description': description,
          'keyShortcuts': keyShortcuts,
          'roleDescription': roleDescription,
          'valueText': valueText,
          'disabled': disabled,
          'expanded': expanded,
          'focused': focused,
          'modal': modal,
          'multiLine': multiLine,
          'multiSelectable': multiSelectable,
          'readonly': readonly,
          'required': required,
          'selected': selected,
          'checked': checked,
          'pressed': pressed,
          'level': level,
          'valueMin': valueMin,
          'valueMax': valueMax,
          'autocomplete': autocomplete,
          'hasPopup': hasPopup,
          'invalid': invalid,
          'orientation': orientation,
          'children': children,
        }..removeWhere((k, v) => v == null);

  /// The [role](https://www.w3.org/TR/wai-aria/#usage_intro).
  String? get role => _properties['role'] as String?;

  /// A human readable name for the node.
  String? get name => _properties['name'] as String?;

  /// The current value of the node.
  dynamic get value => _properties['value'];

  /// An additional human readable description of the node.
  String? get description => _properties['description'] as String?;

  /// Keyboard shortcuts associated with this node.
  String? get keyShortcuts => _properties['keyShortcuts'] as String?;

  /// A human readable alternative to the role.
  String? get roleDescription => _properties['roleDescription'] as String?;

  /// A description of the current value.
  String? get valueText => _properties['valueText'] as String?;

  /// Whether the node is disabled.
  bool get disabled => _properties['disabled'] as bool? ?? false;

  /// Whether the node is expanded or collapsed.
  bool get expanded => _properties['expanded'] as bool? ?? false;

  /// Whether the node is focused.
  bool get focused => _properties['focused'] as bool? ?? false;

  /// Whether the node is [modal](https://en.wikipedia.org/wiki/Modal_window).
  bool get modal => _properties['modal'] as bool? ?? false;

  /// Whether the node text input supports multiline.
  bool get multiLine => _properties['multiLine'] as bool? ?? false;

  /// Whether more than one child can be selected.
  bool get multiSelectable => _properties['multiSelectable'] as bool? ?? false;

  /// Whether the node is read only.
  bool get readonly => _properties['readonly'] as bool? ?? false;

  /// Whether the node is required.
  bool get required => _properties['required'] as bool? ?? false;

  /// Whether the node is selected in its parent node.
  bool get selected => _properties['selected'] as bool? ?? false;

  /// Whether the checkbox is checked, or "mixed".
  TriState get checked => _properties['checked'] as TriState? ?? stateFalse;

  /// Whether the toggle button is checked, or "mixed".
  TriState get pressed => _properties['pressed'] as TriState? ?? stateFalse;

  /// The level of a heading.
  num? get level => _properties['level'] as num?;

  /// The minimum value in a node.
  num? get valueMin => _properties['valueMin'] as num?;

  /// The maximum value in a node.
  num? get valueMax => _properties['valueMax'] as num?;

  /// What kind of autocomplete is supported by a control.
  String? get autocomplete => _properties['autocomplete'] as String?;

  /// What kind of popup is currently being shown for a node.
  String? get hasPopup => _properties['hasPopup'] as String?;

  /// Whether and in what way this node's value is invalid.
  String? get invalid => _properties['invalid'] as String?;

  /// Whether the node is oriented horizontally or vertically.
  String? get orientation => _properties['orientation'] as String?;

  /// Child [_AXNode]s of this node, if any.
  final List<AXNode> children;

  Map<String, dynamic> get _propertiesAndChildren =>
      {..._properties, 'children': children};

  @override
  String toString() {
    var serializedProperties = _propertiesAndChildren.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
    return 'AXNode($serializedProperties)';
  }

  @override
  bool operator ==(other) =>
      other is AXNode &&
      const DeepCollectionEquality.unordered()
          .equals(_propertiesAndChildren, other._propertiesAndChildren);

  @override
  int get hashCode =>
      const DeepCollectionEquality.unordered().hash(_propertiesAndChildren);
}

class TriState {
  final bool isTrue;
  final bool isMixed;

  TriState._(this.isTrue, this.isMixed);

  factory TriState._fromString(String value) {
    if (value == 'mixed') {
      return TriState._(false, true);
    } else {
      return TriState._(value == 'true', false);
    }
  }

  @override
  bool operator ==(other) =>
      other is TriState && other.isTrue == isTrue && other.isMixed == isMixed;

  @override
  int get hashCode => isTrue.hashCode + isMixed.hashCode;

  @override
  String toString() => isMixed ? 'mixed' : isTrue.toString();
}

class _AXNode {
  final AXNodeData _payload;
  final _children = <_AXNode>[];
  bool _richlyEditable = false;
  bool _editable = false;
  bool _focusable = false;
  bool _expanded = false;
  bool _hidden = false;
  final String _name, _role;
  bool? _cachedHasFocusableChild;

  _AXNode(this._payload)
      : _name = _payload.name?.value as String? ?? '',
        _role = _payload.role?.value as String? ?? 'Unknown' {
    if (_payload.properties != null) {
      for (var property in _payload.properties!) {
        if (property.name == AXPropertyName.editable) {
          _richlyEditable = property.value.value == 'richtext';
          _editable = true;
        }
        if (property.name == AXPropertyName.focusable) {
          _focusable = property.value.value as bool;
        }
        if (property.name == AXPropertyName.expanded) {
          _expanded = property.value.value as bool;
        }
        if (property.name == AXPropertyName.hidden) {
          _hidden = property.value.value as bool;
        }
      }
    }
  }

  bool get _isPlainTextField {
    if (_richlyEditable) return false;
    if (_editable) return true;
    return const ['textbox', 'ComboBox', 'searchbox'].contains(_role);
  }

  bool get _isTextOnlyObject {
    return const ['LineBreak', 'text', 'InlineTextBox'].contains(_role);
  }

  bool get _hasFocusableChild {
    if (_cachedHasFocusableChild == null) {
      _cachedHasFocusableChild = false;
      for (var child in _children) {
        if (child._focusable || child._hasFocusableChild) {
          _cachedHasFocusableChild = true;
          break;
        }
      }
    }
    return _cachedHasFocusableChild!;
  }

  _AXNode? find(bool Function(_AXNode) predicate) {
    if (predicate(this)) return this;
    for (var child in _children) {
      var result = child.find(predicate);
      if (result != null) return result;
    }
    return null;
  }

  bool get isLeafNode {
    if (_children.isEmpty) return true;

    // These types of objects may have children that we use as internal
    // implementation details, but we want to expose them as leaves to platform
    // accessibility APIs because screen readers might be confused if they find
    // any children.
    if (_isPlainTextField || _isTextOnlyObject) return true;

    // Roles whose children are only presentational according to the ARIA and
    // HTML5 Specs should be hidden from screen readers.
    // (Note that whilst ARIA buttons can have only presentational children, HTML5
    // buttons are allowed to have content.)
    switch (_role) {
      case 'doc-cover':
      case 'graphics-symbol':
      case 'img':
      case 'Meter':
      case 'scrollbar':
      case 'slider':
      case 'separator':
      case 'progressbar':
        return true;
      default:
        break;
    }

    // Here and below: Android heuristics
    if (_hasFocusableChild) return false;
    if (_focusable && _name.isNotEmpty) return true;
    if (_role == 'heading' && _name.isNotEmpty) return true;
    return false;
  }

  bool? get expanded => _expanded;

  bool get isControl {
    switch (_role) {
      case 'button':
      case 'checkbox':
      case 'ColorWell':
      case 'combobox':
      case 'DisclosureTriangle':
      case 'listbox':
      case 'menu':
      case 'menubar':
      case 'menuitem':
      case 'menuitemcheckbox':
      case 'menuitemradio':
      case 'radio':
      case 'scrollbar':
      case 'searchbox':
      case 'slider':
      case 'spinbutton':
      case 'switch':
      case 'tab':
      case 'textbox':
      case 'tree':
        return true;
      default:
        return false;
    }
  }

  bool isInteresting({required bool insideControl}) {
    var role = _role;
    if (role == 'Ignored' || _hidden) return false;

    if (_focusable || _richlyEditable) return true;

    // If it's not focusable but has a control role, then it's interesting.
    if (isControl) return true;

    // A non focusable child of a control is not interesting
    if (insideControl) return false;

    return isLeafNode && _name.isNotEmpty;
  }

  AXNode serialize() {
    AXProperty? findProperty(AXPropertyName name) =>
        _payload.properties?.firstWhereOrNull((p) => p.name == name);

    String? stringValue(AXPropertyName name) {
      var property = findProperty(name);
      if (property != null && property.value.value != null) {
        return '${property.value.value}';
      }
      return null;
    }

    bool? boolValue(AXPropertyName name) {
      var property = findProperty(name);
      if (property != null && property.value.value != null) {
        // RootWebArea's treat focus differently than other nodes. They report whether their frame  has focus,
        // not whether focus is specifically on the root node.
        if (property.name == AXPropertyName.focused && _role == 'RootWebArea') {
          return null;
        }

        if (property.value.value is bool && property.value.value as bool) {
          return true;
        }
      }

      return null;
    }

    TriState? triState(AXPropertyName name) {
      var property = findProperty(name);
      if (property != null) {
        return TriState._fromString('${property.value.value}');
      }
      return null;
    }

    num? numValue(AXPropertyName name) {
      var property = findProperty(name);
      if (property != null && property.value.value is num) {
        return property.value.value as num;
      }
      return null;
    }

    String? value(AXPropertyName name) {
      var property = findProperty(name);
      if (property != null) {
        var rawValue = property.value.value;
        if (rawValue != null && rawValue != false && rawValue != 'false') {
          return '$rawValue';
        }
      }
      return null;
    }

    return AXNode(
      role: _role,
      name: _payload.name?.value as String?,
      value: _payload.value?.value,
      description: _payload.description?.value as String?,
      keyShortcuts: stringValue(AXPropertyName.keyshortcuts),
      roleDescription: stringValue(AXPropertyName.roledescription),
      valueText: stringValue(AXPropertyName.valuetext),
      disabled: boolValue(AXPropertyName.disabled),
      expanded: boolValue(AXPropertyName.expanded),
      focused: boolValue(AXPropertyName.focused),
      modal: boolValue(AXPropertyName.modal),
      multiLine: boolValue(AXPropertyName.multiline),
      multiSelectable: boolValue(AXPropertyName.multiselectable),
      readonly: boolValue(AXPropertyName.readonly),
      required: boolValue(AXPropertyName.required),
      selected: boolValue(AXPropertyName.selected),
      checked: triState(AXPropertyName.checked),
      pressed: triState(AXPropertyName.pressed),
      level: numValue(AXPropertyName.level),
      valueMax: numValue(AXPropertyName.valuemax),
      valueMin: numValue(AXPropertyName.valuemin),
      autocomplete: value(AXPropertyName.autocomplete),
      hasPopup: value(AXPropertyName.hasPopup),
      invalid: value(AXPropertyName.invalid),
      orientation: value(AXPropertyName.orientation),
    );
  }

  static _AXNode createTree(Iterable<AXNodeData> payloads) {
    var nodeById = <String, _AXNode>{};
    for (var payload in payloads) {
      nodeById[payload.nodeId.value] = _AXNode(payload);
    }
    for (var node in nodeById.values) {
      if (node._payload.childIds != null) {
        for (var childId in node._payload.childIds!) {
          node._children.add(nodeById[childId.value]!);
        }
      }
    }
    return nodeById.values.first;
  }
}
