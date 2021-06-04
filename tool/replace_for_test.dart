import 'dart:io';

void main() {
  var result = File('tool/_replace_for_test_source.txt')
      .readAsStringSync()
      .replaceAll('describe(', 'group(')
      .replaceAll('describe_fails_ffox(', 'group(')
      .replaceAll('it(', 'test(')
      .replaceAll('it_fails_ffox(', 'test(')
      .replaceAll('.PREFIX', '.prefix')
      .replaceAll('.EMPTY_PAGE', '.emptyPage')
      .replaceAll('.CROSS_PROCESS_PREFIX', '.crossProcessPrefix')
      .replaceAll('const ', 'var ')
      .replaceAllMapped(RegExp(r'.evaluate\((.*=>[^\(\),]+)\)'), (m) {
        var content = m.group(1)!;
        var quote = content.contains("'") ? '"' : "'";
        return '.evaluate($quote$content$quote)';
      })
      .replaceAll(').toBe(true', ', isTrue')
      .replaceAll(').toBe(false', ', isFalse')
      .replaceAll(').toBeTruthy(', ', isNotNull')
      .replaceAllMapped(RegExp(r'\).toEqual\(([^)]+)\)'), (match) {
        return ', equals(${match.group(1)}))';
      })
      .replaceAllMapped(RegExp(r'\).toBe\(([^)]+)\)'), (match) {
        return ', equals(${match.group(1)}))';
      })
      .replaceAllMapped(RegExp(r'\).toContain\(([^)]+)\)'), (match) {
        return ', contains(${match.group(1)}))';
      })
      .replaceAll('function()', '()')
      .replaceAll('.frames()', '.frames')
      .replaceAll('.url()', '.url')
      .replaceAll('async({page, server}) =>', '() async ')
      .replaceAll('async({page, server, browser}) =>', '() async ')
      .replaceAll('async({page}) =>', '() async ')
      .replaceAll('async () => {', '() async {')
      .replaceAll('utils.attachFrame(', 'attachFrame(')
      .replaceAll('utils.detachFrame(', 'detachFrame(')
      .replaceAll('.push(', '.add(')
      .replaceAll('mainFrame()', 'mainFrame')
      .replaceAll('executionContext()', 'executionContext')
      .replaceAll('Promise.all', 'Future.wait');
  File('tool/_replace_for_test_destination.txt').writeAsStringSync(result);
}
