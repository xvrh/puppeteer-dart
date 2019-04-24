import '../../protocol/page.dart';
import 'page.dart';

export '../../protocol/page.dart' show DialogType;

class Dialog {
  final Page page;
  final JavascriptDialogOpeningEvent _openingEvent;
  bool _handled = false;

  Dialog(this.page, this._openingEvent);

  Future<void> accept({String promptText}) async {
    assert(!_handled, 'Cannot accept dialog which is already handled!');
    _handled = true;
    await page.devTools.page
        .handleJavaScriptDialog(true, promptText: promptText);
  }

  Future<void> dismiss() async {
    assert(!_handled, 'Cannot dismiss dialog which is already handled!');
    _handled = true;
    await page.devTools.page.handleJavaScriptDialog(false);
  }

  String get message => _openingEvent.message;

  String get defaultValue => _openingEvent.defaultPrompt;

  DialogType get type => _openingEvent.type;
}
