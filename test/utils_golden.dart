import 'dart:io';
import 'package:test/test.dart';

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

      return _areListsEqual<int>(item, goldenFile.readAsBytesSync());
    }
  }
}

_GoldenMatcher equalsGolden(String goldenPath) {
  return _GoldenMatcher(goldenPath);
}

bool _areListsEqual<T>(List<T> list1, List<T> list2) {
  if (identical(list1, list2)) {
    return true;
  }
  if (list1 == null || list2 == null) {
    return false;
  }
  final int length = list1.length;
  if (length != list2.length) {
    return false;
  }
  for (int i = 0; i < length; i++) {
    if (list1[i] != list2[i]) {
      return false;
    }
  }
  return true;
}
