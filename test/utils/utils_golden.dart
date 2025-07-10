import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:test/test.dart';
import 'pixel_match.dart';

final bool _updateGolden = (() {
  var env = Platform.environment['PUPPETEER_UPDATE_GOLDEN'];
  return env != null && env != 'false';
})();

final bool _skipGoldenComparison = (() {
  var env = Platform.environment['PUPPETEER_SKIP_GOLDEN_COMPARISON'];
  return env != null && env != 'false';
})();

class _GoldenMatcher extends Matcher {
  final String goldenPath;

  _GoldenMatcher(this.goldenPath);

  @override
  Description describe(Description description) {
    return description.addDescriptionOf('Golden($goldenPath)');
  }

  @override
  bool matches(covariant Uint8List item, Map<dynamic, dynamic> matchState) {
    if (_skipGoldenComparison) return true;

    var goldenFile = File(goldenPath);

    if (_updateGolden) {
      goldenFile.parent.createSync(recursive: true);
      goldenFile.writeAsBytesSync(item);
      return true;
    } else {
      if (!goldenFile.existsSync()) return false;

      var difference = _compareImages(item, goldenFile.readAsBytesSync());
      if (difference == null) {
        return true;
      } else {
        matchState['comparison'] = difference;
        return false;
      }
    }
  }

  @override
  Description describeMismatch(
    item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    var difference = matchState['comparison'] as ImageDifference;
    mismatchDescription.replace(difference.toString());
    return mismatchDescription;
  }
}

Matcher equalsGolden(String goldenPath) {
  return _GoldenMatcher(goldenPath);
}

ImageDifference? _compareImages(
  Uint8List actualBytes,
  Uint8List expectedBytes,
) {
  var actual = decodeImage(actualBytes)!.convert(numChannels: 4);
  var expected = decodeImage(expectedBytes)!.convert(numChannels: 4);

  if (expected.width != actual.width || expected.height != actual.height) {
    return SizeDifference(
      expected.width,
      expected.height,
      actual.width,
      actual.height,
    );
  }

  var output = Uint8List(actual.buffer.lengthInBytes);

  num threshold = 0.1;
  var count = pixelMatch(
    Uint8List.view(expected.buffer),
    Uint8List.view(actual.buffer),
    width: expected.width,
    height: expected.height,
    threshold: threshold,
  );
  if (count > 0) {
    return ContentDifference(
      count,
      actualBytes,
      expectedBytes,
      PngEncoder().encode(
        Image.fromBytes(
          width: actual.width,
          height: actual.height,
          bytes: output.buffer,
        ),
      ),
      usedThreshold: threshold,
    );
  }
  return null;
}

class ImageDifference {}

class SizeDifference implements ImageDifference {
  final int expectedWidth, expectedHeight, actualWidth, actualHeight;

  SizeDifference(
    this.expectedWidth,
    this.expectedHeight,
    this.actualWidth,
    this.actualHeight,
  );

  @override
  String toString() =>
      'Size is different: expected ${expectedWidth}x$expectedHeight, actual ${actualWidth}x$actualHeight';
}

class ContentDifference implements ImageDifference {
  final int differenceCount;
  final List<int> actual, golden, diff;
  final num usedThreshold;

  ContentDifference(
    this.differenceCount,
    this.actual,
    this.golden,
    this.diff, {
    required this.usedThreshold,
  });

  static String _bytesToPng(List<int> bytes) =>
      Uri.dataFromBytes(bytes, mimeType: 'image/png').toString();

  @override
  String toString() =>
      'Image content has $differenceCount different pixels.'
      '\n\nActual: ${_bytesToPng(actual)}'
      '\n\nGolden: ${_bytesToPng(golden)}'
      '\n\nDiff: ${_bytesToPng(diff)}';
}
