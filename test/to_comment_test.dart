import 'package:test/test.dart';
import '../tool/generate_protocol.dart';

main() {
  test('toComment should replace <code> to quote', () {
    String result = toComment(r'''This is <code>quoted</code> string''');
    expect(result, equals(r'/// This is `quoted` string'));
  });
}
