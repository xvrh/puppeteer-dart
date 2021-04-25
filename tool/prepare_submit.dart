import 'code_style/fix_absolute_import.dart' as fix_absolute_import;
import 'code_style/fix_import_order.dart' as fix_import_order;
import 'generate_api_doc.dart' as generate_api_doc;
import 'generate_readme.dart' as generate_readme;
import 'generate_test_all_file.dart' as generate_test_all_file;
import 'inject_examples_to_doc.dart' as inject_examples_to_doc;

void main() {
  generate_test_all_file.main();
  inject_examples_to_doc.main();
  generate_readme.main();
  fix_absolute_import.main();
  fix_import_order.main();
  generate_api_doc.main();

  // TODO(xha): convert double quote to simple quote
}
