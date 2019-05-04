import 'package:test/test.dart';
import 'browser_context_test.dart' as browser_context_test;
import 'browser_test.dart' as browser_test;
import 'click_test.dart' as click_test;
import 'dialog_test.dart' as dialog_test;
import 'doc_example_extractor_test.dart' as doc_example_extractor_test;
import 'doc_examples_test.dart' as doc_examples_test;
import 'element_handle_test.dart' as element_handle_test;
import 'emulation_test.dart' as emulation_test;
import 'evaluation_test.dart' as evaluation_test;
import 'examples_test.dart' as examples_test;
import 'frame_test.dart' as frame_test;
import 'golden_utils_test.dart' as golden_utils_test;
import 'input_file_test.dart' as input_file_test;
import 'javascript_parser_test.dart' as javascript_parser_test;
import 'js_handle_test.dart' as js_handle_test;
import 'keyboard_test.dart' as keyboard_test;
import 'mouse_test.dart' as mouse_test;
import 'navigation_test.dart' as navigation_test;
import 'page_test.dart' as page_test;
import 'query_selector_test.dart' as query_selector_test;
import 'readme_test.dart' as readme_test;
import 'request_interception_test.dart' as request_interception_test;
import 'screenshot_test.dart' as screenshot_test;
import 'target_test.dart' as target_test;
import 'to_comment_test.dart' as to_comment_test;
import 'touchscreen_test.dart' as touchscreen_test;
import 'wait_task_test.dart' as wait_task_test;

main() {
  group('request_interception_test', request_interception_test.main);
  group('touchscreen_test', touchscreen_test.main);
  group('examples_test', examples_test.main);
  group('click_test', click_test.main);
  group('doc_example_extractor_test', doc_example_extractor_test.main);
  group('target_test', target_test.main);
  group('input_file_test', input_file_test.main);
  group('doc_examples_test', doc_examples_test.main);
  group('emulation_test', emulation_test.main);
  group('to_comment_test', to_comment_test.main);
  group('frame_test', frame_test.main);
  group('screenshot_test', screenshot_test.main);
  group('query_selector_test', query_selector_test.main);
  group('javascript_parser_test', javascript_parser_test.main);
  group('evaluation_test', evaluation_test.main);
  group('readme_test', readme_test.main);
  group('page_test', page_test.main);
  group('golden_utils_test', golden_utils_test.main);
  group('wait_task_test', wait_task_test.main);
  group('browser_test', browser_test.main);
  group('mouse_test', mouse_test.main);
  group('keyboard_test', keyboard_test.main);
  group('js_handle_test', js_handle_test.main);
  group('dialog_test', dialog_test.main);
  group('navigation_test', navigation_test.main);
  group('browser_context_test', browser_context_test.main);
  group('element_handle_test', element_handle_test.main);
}
