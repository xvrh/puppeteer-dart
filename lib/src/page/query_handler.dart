import 'execution_context.dart';
import 'js_handle.dart';

/// Support for Puppeteer-specific ("P") selectors, ported from upstream's
/// injected query engine (src/injected/PQuerySelector.ts and friends).
///
/// On top of plain CSS this adds:
/// - `::-p-text(value)` — match by rendered text content.
/// - `::-p-xpath(value)` — match by an XPath expression.
/// - deep combinators `>>>` (descendant, pierces all shadow roots) and `>>>>`
///   (child, pierces one shadow level).
/// - the legacy `text/`, `xpath/` and `pierce/` selector prefixes.
/// - selector lists (comma) with DOM-ordered, de-duplicated results.
///
/// `::-p-aria(...)` / `aria/` and custom query handlers are not implemented yet;
/// using them throws a clear error.
///
/// Plain CSS selectors are detected by [isSpecialSelector] returning `false` and
/// keep using the existing `querySelector` fast path.

const _legacyPrefixes = ['text', 'xpath', 'pierce', 'aria'];

String? legacyKind(String selector) {
  for (var kind in _legacyPrefixes) {
    if (selector.startsWith('$kind/')) return kind;
  }
  return null;
}

/// Whether [selector] needs the custom P-selector engine rather than a plain
/// `querySelector`.
bool isSpecialSelector(String selector) {
  return legacyKind(selector) != null ||
      selector.contains('::-p-') ||
      selector.contains('>>>');
}

/// Throws if [selector] uses a P-selector feature that is not implemented yet.
void checkSelectorSupported(String selector) {
  if (selector.startsWith('aria/') || selector.contains('::-p-aria(')) {
    throw UnsupportedError(
      'ARIA selectors (::-p-aria / aria/) are not yet supported in '
      'puppeteer-dart',
    );
  }
}

/// Queries a single element matching [selector] within [root], using the
/// custom engine. Returns `null` if nothing matches.
Future<ElementHandle?> querySelectorOne(
  ElementHandle root,
  String selector,
) async {
  checkSelectorSupported(selector);
  var handle = await _runQuery(root, selector, all: false);
  var element = handle.asElement;
  if (element != null) return element;
  await handle.dispose();
  return null;
}

/// Queries all elements matching [selector] within [root], using the custom
/// engine. Results are in DOM order and de-duplicated.
Future<List<ElementHandle>> querySelectorAll(
  ElementHandle root,
  String selector,
) async {
  var arrayHandle = await querySelectorAllHandle(root, selector);
  var properties = await arrayHandle.properties;
  await arrayHandle.dispose();
  var result = <ElementHandle>[];
  for (var property in properties.values) {
    var element = property.asElement;
    if (element != null) {
      result.add(element);
    } else {
      await property.dispose();
    }
  }
  return result;
}

/// Like [querySelectorAll] but returns the in-page array handle directly, for
/// callers that want to evaluate over the result set (e.g. `$$eval`).
Future<JsHandle> querySelectorAllHandle(ElementHandle root, String selector) {
  checkSelectorSupported(selector);
  return _runQuery(root, selector, all: true);
}

Future<JsHandle> _runQuery(
  ElementHandle root,
  String selector, {
  required bool all,
}) {
  var kind = legacyKind(selector);
  if (kind != null) {
    return root.evaluateHandle(
      all ? _legacyQueryAll : _legacyQueryOne,
      args: [kind, selector.substring(kind.length + 1)],
    );
  }
  return root.evaluateHandle(all ? _pQueryAll : _pQueryOne, args: [selector]);
}

/// The JavaScript predicate body for [DomWorld.waitForSelector] when the
/// selector is a P-selector. Mirrors the contract of the plain selector
/// predicate: returns the node on success, a falsy value otherwise.
///
/// Arguments: `(selector, kind, waitForVisible, waitForHidden)` where `kind` is
/// the legacy prefix (`text`/`xpath`/`pierce`) or an empty string for modern
/// selectors.
@Language('js')
final pSelectorWaitPredicate =
    '''
function _(selector, kind, waitForVisible, waitForHidden) {
$_engine
  const node = kind
    ? legacyQueryOne(document, kind, selector)
    : pQueryOne(document, selector);
  if (!node)
    return waitForHidden;
  if (!waitForVisible && !waitForHidden)
    return node;
  const element = node.nodeType === Node.TEXT_NODE ? node.parentElement : node;
  const style = window.getComputedStyle(element);
  const isVisible = style && style.visibility !== 'hidden' && hasVisibleBoundingBox();
  const success = (waitForVisible === isVisible || waitForHidden === !isVisible);
  return success ? node : null;

  function hasVisibleBoundingBox() {
    const rect = element.getBoundingClientRect();
    return !!(rect.top || rect.bottom || rect.width || rect.height);
  }
}
''';

@Language('js')
final _pQueryOne =
    '''
function _(root, selector) {
$_engine
  return pQueryOne(root, selector);
}
''';

@Language('js')
final _pQueryAll =
    '''
function _(root, selector) {
$_engine
  return pQueryAll(root, selector);
}
''';

@Language('js')
final _legacyQueryOne =
    '''
function _(root, kind, value) {
$_engine
  return legacyQueryOne(root, kind, value);
}
''';

@Language('js')
final _legacyQueryAll =
    '''
function _(root, kind, value) {
$_engine
  const all = legacyQueryAll(root, kind, value);
  return [...all];
}
''';

/// The shared engine: parser + query selectors, embedded into each page
/// function above. Ported from upstream's injected bundle, simplified to run
/// per-call (no persistent caches/observers needed).
const _engine =
    //language=js
    r'''
  const IDENT_TOKEN_START = /[-\w\P{ASCII}*]/u;

  function* flatMap(iterable, fn) {
    for (const value of iterable) {
      yield* fn(value);
    }
  }

  // --- Text matching ---------------------------------------------------------

  function isSuitableNodeForTextMatching(node) {
    return !['SCRIPT', 'STYLE'].includes(node.nodeName) &&
        !(document.head && document.head.contains(node));
  }

  function isNonTrivialValueNode(node) {
    if (node instanceof HTMLSelectElement) return true;
    if (node instanceof HTMLTextAreaElement) return true;
    if (node instanceof HTMLInputElement &&
        !['checkbox', 'image', 'radio'].includes(node.type)) {
      return true;
    }
    return false;
  }

  function createTextContent(root) {
    if (!isSuitableNodeForTextMatching(root)) return '';
    if (isNonTrivialValueNode(root)) return root.value;
    let full = '';
    for (let child = root.firstChild; child; child = child.nextSibling) {
      if (child.nodeType === Node.TEXT_NODE) {
        full += child.nodeValue || '';
      } else if (child.nodeType === Node.ELEMENT_NODE) {
        full += createTextContent(child);
      }
    }
    if (root instanceof Element && root.shadowRoot) {
      full += createTextContent(root.shadowRoot);
    }
    return full;
  }

  function* textQuerySelectorAll(root, selector) {
    let yielded = false;
    for (const node of root.childNodes) {
      if (node instanceof Element && isSuitableNodeForTextMatching(node)) {
        const matches = node.shadowRoot
          ? textQuerySelectorAll(node.shadowRoot, selector)
          : textQuerySelectorAll(node, selector);
        for (const match of matches) {
          yield match;
          yielded = true;
        }
      }
    }
    if (yielded) return;
    if (root instanceof Element && isSuitableNodeForTextMatching(root)) {
      if (createTextContent(root).includes(selector)) {
        yield root;
      }
    }
  }

  // --- XPath -----------------------------------------------------------------

  function* xpathQuerySelectorAll(root, selector, maxResults) {
    maxResults = maxResults || -1;
    const doc = root.ownerDocument || document;
    const iterator = doc.evaluate(
      selector, root, null, XPathResult.ORDERED_NODE_ITERATOR_TYPE);
    const items = [];
    let item;
    while ((item = iterator.iterateNext())) {
      items.push(item);
      if (maxResults > 0 && items.length === maxResults) break;
    }
    for (const found of items) yield found;
  }

  // --- Pierce (shadow DOM) ---------------------------------------------------

  function pierceQuerySelectorAll(element, selector) {
    const result = [];
    const collect = (root) => {
      const iter = document.createTreeWalker(root, NodeFilter.SHOW_ELEMENT);
      do {
        const currentNode = iter.currentNode;
        if (currentNode.shadowRoot) collect(currentNode.shadowRoot);
        if (currentNode instanceof ShadowRoot) continue;
        if (currentNode !== root && currentNode.matches(selector)) {
          result.push(currentNode);
        }
      } while (iter.nextNode());
    };
    if (element instanceof Document) element = element.documentElement;
    collect(element);
    return result;
  }

  function hasShadowRoot(node) {
    return 'shadowRoot' in node && node.shadowRoot instanceof ShadowRoot;
  }

  function* pierce(root) {
    if (hasShadowRoot(root)) yield root.shadowRoot;
    else yield root;
  }

  function* pierceAll(root) {
    root = pierce(root).next().value;
    yield root;
    const walkers = [document.createTreeWalker(root, NodeFilter.SHOW_ELEMENT)];
    for (const walker of walkers) {
      let node;
      while ((node = walker.nextNode())) {
        if (!node.shadowRoot) continue;
        yield node.shadowRoot;
        walkers.push(
          document.createTreeWalker(node.shadowRoot, NodeFilter.SHOW_ELEMENT));
      }
    }
  }

  // --- DOM ordering ----------------------------------------------------------

  function calculateDepth(node) {
    const depth = [];
    while (node) {
      if (node instanceof ShadowRoot) {
        node = node.host;
        continue;
      }
      let index = 0;
      for (let sibling = node.previousSibling; sibling;
          sibling = sibling.previousSibling) {
        ++index;
      }
      depth.unshift(index);
      node = node.parentNode;
    }
    return depth;
  }

  function compareDepths(a, b) {
    const length = Math.max(a.length, b.length);
    for (let i = 0; i < length; ++i) {
      const x = i < a.length ? a[i] : -1;
      const y = i < b.length ? b[i] : -1;
      if (x !== y) return x < y ? -1 : 1;
    }
    return 0;
  }

  function domSort(elements) {
    const results = new Set();
    for (const element of elements) results.add(element);
    return [...results]
      .map(result => [result, calculateDepth(result)])
      .sort((a, b) => compareDepths(a[1], b[1]))
      .map(entry => entry[0]);
  }

  // --- Selector parsing ------------------------------------------------------

  function unquote(text) {
    if (text.length <= 1) return text;
    if ((text[0] === '"' || text[0] === "'") &&
        text[text.length - 1] === text[0]) {
      text = text.slice(1, -1);
    }
    return text.replace(/\\[\s\S]/g, match => match[1]);
  }

  function parsePSelectors(selector) {
    const selectors = [];
    let compound = [];
    let complex = [compound];
    selectors.push(complex);
    let css = '';
    const len = selector.length;
    let i = 0;

    const flush = () => {
      const trimmed = css.trim();
      if (trimmed) compound.push(trimmed);
      css = '';
    };
    const readQuoted = (quote, sink) => {
      let out = sink + quote;
      ++i;
      while (i < len) {
        const c = selector[i];
        if (c === '\\') {
          out += c + (selector[i + 1] || '');
          i += 2;
          continue;
        }
        out += c;
        ++i;
        if (c === quote) break;
      }
      return out;
    };

    while (i < len) {
      const ch = selector[i];
      if (ch === '\\') {
        css += ch + (selector[i + 1] || '');
        i += 2;
        continue;
      }
      if (ch === '"' || ch === "'") {
        css = readQuoted(ch, css);
        continue;
      }
      if (ch === '[') {
        css += ch;
        ++i;
        let depth = 1;
        while (i < len && depth > 0) {
          const c = selector[i];
          if (c === '\\') {
            css += c + (selector[i + 1] || '');
            i += 2;
            continue;
          }
          if (c === '"' || c === "'") {
            css = readQuoted(c, css);
            continue;
          }
          if (c === '[') ++depth;
          if (c === ']') --depth;
          css += c;
          ++i;
        }
        continue;
      }
      if (ch === '>') {
        if (selector.startsWith('>>>>', i)) {
          flush();
          compound = [];
          complex.push('>>>>');
          complex.push(compound);
          i += 4;
          continue;
        }
        if (selector.startsWith('>>>', i)) {
          flush();
          compound = [];
          complex.push('>>>');
          complex.push(compound);
          i += 3;
          continue;
        }
        css += ch;
        ++i;
        continue;
      }
      if (ch === ',') {
        flush();
        compound = [];
        complex = [compound];
        selectors.push(complex);
        ++i;
        continue;
      }
      if (selector.startsWith('::-p-', i)) {
        i += 5;
        let name = '';
        while (i < len && /[-\w]/.test(selector[i])) {
          name += selector[i];
          ++i;
        }
        let value = '';
        if (selector[i] === '(') {
          ++i;
          let depth = 1;
          let raw = '';
          while (i < len && depth > 0) {
            const c = selector[i];
            if (c === '\\') {
              raw += c + (selector[i + 1] || '');
              i += 2;
              continue;
            }
            if (c === '"' || c === "'") {
              raw = readQuoted(c, raw);
              continue;
            }
            if (c === '(') {
              ++depth;
              raw += c;
              ++i;
              continue;
            }
            if (c === ')') {
              --depth;
              if (depth === 0) {
                ++i;
                break;
              }
              raw += c;
              ++i;
              continue;
            }
            raw += c;
            ++i;
          }
          value = unquote(raw);
        }
        flush();
        compound.push({name: name, value: value});
        continue;
      }
      css += ch;
      ++i;
    }
    flush();
    return selectors;
  }

  // --- Query engine ----------------------------------------------------------

  function isQueryableNode(node) {
    return 'querySelectorAll' in node;
  }

  function compoundEngine(element, parts) {
    const queue = parts.slice();
    let elements = [element];

    let selector = queue.shift();
    if (typeof selector === 'string' && selector.trimStart() === ':scope') {
      selector = queue.shift();
    }

    while (selector !== undefined) {
      const current = elements;
      if (typeof selector === 'string') {
        const css = selector;
        if (css[0] && IDENT_TOKEN_START.test(css[0])) {
          elements = flatMap(current, function* (node) {
            if (isQueryableNode(node)) yield* node.querySelectorAll(css);
          });
        } else {
          elements = flatMap(current, function* (node) {
            if (!node.parentElement) {
              if (isQueryableNode(node)) yield* node.querySelectorAll(css);
              return;
            }
            let index = 0;
            for (const child of node.parentElement.children) {
              ++index;
              if (child === node) break;
            }
            yield* node.parentElement.querySelectorAll(
              ':scope>:nth-child(' + index + ')' + css);
          });
        }
      } else {
        const pseudo = selector;
        elements = flatMap(current, function* (node) {
          switch (pseudo.name) {
            case 'text':
              yield* textQuerySelectorAll(node, pseudo.value);
              break;
            case 'xpath':
              yield* xpathQuerySelectorAll(node, pseudo.value);
              break;
            default:
              throw new Error('Unknown selector type: ' + pseudo.name);
          }
        });
      }
      selector = queue.shift();
    }
    return elements;
  }

  function runComplex(root, complexSelector) {
    const queue = complexSelector.slice();
    let elements = [root];
    while (queue.length) {
      const part = queue.shift();
      if (part === '>>>>') {
        elements = flatMap(elements, pierce);
      } else if (part === '>>>') {
        elements = flatMap(elements, pierceAll);
      } else {
        // part is a compound selector; apply it within the current elements.
        const compound = part;
        elements = flatMap(elements, function* (element) {
          yield* compoundEngine(element, compound);
        });
      }
    }
    return elements;
  }

  function pQuerySelectorAll(root, selector) {
    const selectors = parsePSelectors(selector);
    const all = flatMap(selectors, function* (complexSelector) {
      yield* runComplex(root, complexSelector);
    });
    return domSort(all);
  }

  function pQueryAll(root, selector) {
    return pQuerySelectorAll(root, selector);
  }

  function pQueryOne(root, selector) {
    const all = pQuerySelectorAll(root, selector);
    return all.length ? all[0] : null;
  }

  function legacyQueryAll(root, kind, value) {
    switch (kind) {
      case 'text':
        return domSort(textQuerySelectorAll(root, value));
      case 'xpath':
        return domSort(xpathQuerySelectorAll(root, value));
      case 'pierce':
        return pierceQuerySelectorAll(root, value);
      default:
        throw new Error('Unknown selector type: ' + kind);
    }
  }

  function legacyQueryOne(root, kind, value) {
    const all = legacyQueryAll(root, kind, value);
    return all.length ? all[0] : null;
  }
''';
