import '../../protocol/page.dart';
import 'page.dart';

export '../../protocol/page.dart' show DialogType;

/// Dialog objects are dispatched by page via the 'onDialog' event.
///
/// An example of using Dialog class:
///
/// ```dart
/// var browser = await puppeteer.launch();
/// var page = await browser.newPage();
/// page.onDialog.listen((dialog) async {
///   print(dialog.message);
///   await dialog.dismiss();
/// });
/// await page.evaluate("() => alert('1')");
/// await browser.close();
/// ```
class Dialog {
  final Page page;
  final JavascriptDialogOpeningEvent _openingEvent;
  bool _handled = false;

  Dialog(this.page, this._openingEvent);

  /// [promptText]: A text to enter in prompt. Does not cause any effects if
  /// the dialog's `type` is not prompt.
  ///
  /// Returns [Future] which resolves when the dialog has been accepted.
  Future<void> accept({String? promptText}) async {
    assert(!_handled, 'Cannot accept dialog which is already handled!');
    _handled = true;
    await page.devTools.page
        .handleJavaScriptDialog(true, promptText: promptText);
  }

  /// Returns [Future] which resolves when the dialog has been dismissed.
  Future<void> dismiss() async {
    assert(!_handled, 'Cannot dismiss dialog which is already handled!');
    _handled = true;
    await page.devTools.page.handleJavaScriptDialog(false);
  }

  /// A message displayed in the dialog.
  String? get message => _openingEvent.message;

  /// If dialog is prompt, returns default prompt value. Otherwise, returns
  /// empty string.
  String? get defaultValue => _openingEvent.defaultPrompt;

  /// Dialog's type, can be one of `alert`, `beforeunload`, `confirm` or `prompt`.
  DialogType get type => _openingEvent.type;
}
