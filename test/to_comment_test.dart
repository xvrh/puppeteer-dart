import 'package:test/test.dart';
import '../tool/generate_protocol.dart';

void main() {
  test('toComment should replace <code> to quote', () {
    var result = toComment(r'''This is <code>quoted</code> string''');
    expect(result, equals(r'/// This is `quoted` string'));
  });
}
