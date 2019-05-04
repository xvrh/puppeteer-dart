import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:test/test.dart';
import 'utils/pixel_match.dart';

main() {
  test('pixelMatch', () {
    var img1 = decodeImage(
        File('test/golden/mock-binary-response.png').readAsBytesSync());
    var img2 = decodeImage(
        File('test/golden/mock-binary-response.png').readAsBytesSync());
    var count = pixelMatch(
        Uint8List.view(img1.data.buffer), Uint8List.view(img2.data.buffer),
        width: img1.width, height: img1.height, threshold: 0.1);
    expect(count, equals(0));
  });
}
