String firstLetterUpper(String src) {
  if (src.isNotEmpty) {
    var first = src[0];

    return first.toUpperCase() + src.substring(1);
  }
  return src;
}

String firstLetterLower(String src) {
  if (src.isNotEmpty) {
    var first = src[0];

    return first.toLowerCase() + src.substring(1);
  }
  return src;
}

String lowerCamel(Iterable<String> input) {
  return _mapWithIndex<String, String>(input,
          (s, index) => index != 0 ? firstLetterUpper(s) : s.toLowerCase())
      .join('');
}

String upperCamel(Iterable<String> input) {
  return input.map((s) => firstLetterUpper(s)).join('');
}

String lowerHyphen(Iterable<String> input) {
  return input.map((s) => s.toLowerCase()).join('-');
}

String snakeCase(Iterable<String> input) {
  return input.map((s) => s.toLowerCase()).join('_');
}

Iterable<T> _mapWithIndex<E, T>(
    Iterable<E> collection, T Function(E, int) f) sync* {
  var index = 0;
  for (var element in collection) {
    yield f(element, index);
    ++index;
  }
}
