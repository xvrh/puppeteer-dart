import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:test/test.dart';
import 'utils/pixel_match.dart';

void main() {
  test('pixelMatch', () {
    Image readPng(String path) =>
        decodePng(File(path).readAsBytesSync())!.convert(numChannels: 4);

    var img1 = readPng('test/golden/2a.png');
    var img2 = readPng('test/golden/2b.png');
    var diff = readPng('test/golden/2diff.png');
    var output = Uint8List(img1.width * img2.height * 4);

    var count = pixelMatch(
      img1.getBytes(order: ChannelOrder.rgba),
      img2.getBytes(order: ChannelOrder.rgba),
      width: img1.width,
      height: img1.height,
      output: output,
      threshold: 0.05,
    );
    expect(count, greaterThan(0));

    expect(diff.getBytes(order: ChannelOrder.rgba), output);
  });
}
