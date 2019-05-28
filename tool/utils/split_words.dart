List<String> splitWords(String input) {
  if (input.isEmpty) return [''];

  var words = <String>[];

  var currentWord = '';
  var lastChar = '';

  var runes = input.runes.toList();
  for (var i = 0; i < runes.length; i++) {
    var char = String.fromCharCode(runes[i]);

    if (!_isLower(char) && !_isUpper(char) && !_isNum(char)) {
      currentWord += lastChar;
      lastChar = '';
      if (currentWord.isNotEmpty) {
        words.add(currentWord);
        currentWord = '';
      }
    } else if (_isUpper(char) && _isLower(lastChar)) {
      currentWord += lastChar;
      words.add(currentWord);
      currentWord = '';
      lastChar = char;
    } else if (_isLower(char) && _isUpper(lastChar)) {
      words.add(currentWord);
      currentWord = lastChar;
      lastChar = char;
    } else if ((_isLower(char) || _isUpper(char)) && _isNum(lastChar)) {
      currentWord += lastChar;
      if (currentWord.length > 1) {
        words.add(currentWord);
        currentWord = '';
      }
      lastChar = char;
    } else if ((_isLower(lastChar) || _isUpper(lastChar)) && _isNum(char)) {
      currentWord += lastChar;
      words.add(currentWord);
      currentWord = '';
      lastChar = char;
    } else {
      currentWord += lastChar;
      lastChar = char;
    }
  }

  currentWord += lastChar;

  words
    ..add(currentWord)
    ..removeWhere((w) => w.isEmpty);

  return words;
}

final RegExp _num = RegExp(r'[0-9]');
final RegExp _lower = RegExp(r'[a-zà-ú]');
final RegExp _upper = RegExp(r'[A-ZÀ-Ú]');

bool _isNum(String char) => _num.hasMatch(char);
bool _isUpper(String char) => _upper.hasMatch(char);
bool _isLower(String char) => _lower.hasMatch(char);
