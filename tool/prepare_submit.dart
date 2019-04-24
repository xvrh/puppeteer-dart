import 'code_style/fix_absolute_import.dart' as fix_absolute_import;
import 'code_style/fix_import_order.dart' as fix_import_order;
import 'generate_readme.dart' as generate_readme;

main() {
  generate_readme.main();
  fix_absolute_import.main();
  fix_import_order.main();

  // TODO(xha): convert double quote to simple quote
}
