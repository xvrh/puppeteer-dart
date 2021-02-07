import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:test/test.dart';
import 'utils/pixel_match.dart';

void main() {
  test('pixelMatch', () {
    var img1 = decodeImage(File('test/golden/2a.png').readAsBytesSync())!;
    var img2 = decodeImage(File('test/golden/2b.png').readAsBytesSync())!;
    var diff = decodeImage(File('test/golden/2diff.png').readAsBytesSync())!;
    var output = Uint8List(img1.data.buffer.lengthInBytes);

    var count = pixelMatch(
        Uint8List.view(img1.data.buffer), Uint8List.view(img2.data.buffer),
        width: img1.width,
        height: img1.height,
        output: output,
        threshold: 0.05);
    expect(count, greaterThan(0));

    var outputImage = Image.fromBytes(img1.width, img1.height, output);

    expect(diff.data, equals(outputImage.data));
  });
}
