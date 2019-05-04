import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:test/test.dart';
import 'pixel_match.dart';

final bool _updateGolden =
    Platform.environment['PUPPETEER_UPDATE_GOLDEN'] ?? false;

class _GoldenMatcher extends Matcher {
  final String goldenPath;

  _GoldenMatcher(this.goldenPath);

  @override
  Description describe(Description description) {
    return description.addDescriptionOf('Golden($goldenPath)');
  }

  @override
  bool matches(item, Map matchState) {
    assert(item is List<int>);

    var goldenFile = File(goldenPath);

    if (_updateGolden) {
      goldenFile.parent.createSync(recursive: true);
      goldenFile.writeAsBytesSync(item);
      return true;
    } else {
      if (!goldenFile.existsSync()) return false;

      return _compareImages(item, goldenFile.readAsBytesSync());
    }
  }
}

_GoldenMatcher equalsGolden(String goldenPath) {
  return _GoldenMatcher(goldenPath);
}

bool _compareImages(List<int> actualBytes, List<int> expectedBytes) {
  var actual = decodeImage(actualBytes);
  var expected = decodeImage(expectedBytes);

  if (expected.width != actual.width || expected.height != actual.height) {
    return false;
  }
  var count = pixelMatch(
      Uint8List.view(expected.data.buffer), Uint8List.view(actual.data.buffer),
      width: expected.width, height: expected.height, threshold: 0.1);
  return count == 0;
}
