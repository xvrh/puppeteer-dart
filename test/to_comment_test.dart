import 'package:test/test.dart';

import '../tool/generate_domains.dart';

main() {
  test('Split comment at specified length', () {
    String result = toComment(r'''This is a long comment that should be split''', lineLength: 20);
    expect(result, equals(r'''
/// This is a long
/// comment that should
/// be split'''));
  });

  test('toComment should replace <code> to quote', () {
    String result = toComment(r'''This is <code>quoted</code> string''');
    expect(result, equals(r'/// This is `quoted` string'));
  });
}