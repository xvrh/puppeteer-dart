

import 'package:chrome_dev_tools/src/javascript_function_parser.dart';

main() {
  var result = convertToFunctionDeclaration('''
// comment
(abc, def) => true;
''');
  print(result);
}