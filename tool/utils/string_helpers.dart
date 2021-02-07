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
