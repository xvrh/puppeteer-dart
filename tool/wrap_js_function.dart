

main() {

}

String convert(String jsFunction) {

}

final f1 = '''
async function addStyleUrl(url) {
  const link = document.createElement('link');
  link.rel = 'stylesheet';
  link.href = url;
  const promise = new Promise((res, rej) => {
    link.onload = res;
    link.onerror = rej;
  });
  document.head.appendChild(link);
  await promise;
  return link;
}
''';

final f2 = '''
(element, values) => {
      if (element.nodeName.toLowerCase() !== 'select')
        throw new Error('Element is not a <select> element.');

      const options = Array.from(element.options);
      element.value = undefined;
      for (const option of options) {
        option.selected = values.includes(option.value);
        if (option.selected && !element.multiple)
          break;
      }
      element.dispatchEvent(new Event('input', { 'bubbles': true }));
      element.dispatchEvent(new Event('change', { 'bubbles': true }));
      return options.filter(option => option.selected).map(option => option.value);
    }
''';

final f3 = 's => !s';
final f4 = 'async (s) => !s';

final f5 = '''
function addStyleUrl(url) {

}
''';
