import 'code_style/fix_absolute_import.dart' as fix_absolute_import;
import 'code_style/fix_import_order.dart' as fix_import_order;

main() {
  fix_absolute_import.main();
  fix_import_order.main();

  // TODO(xha): fix double quote to simple quote
}
