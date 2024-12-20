import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:puppeteer/puppeteer.dart';

void main() async {
  var dir = Directory.systemTemp.createTempSync('user_pref');
  var userDataDir = _createUserDataDirectory(
    dir,
    preferences: {
      'devtools': {
        'preferences': {'currentDockState': jsonEncode('bottom')},
      },
    },
  );
  var browser = await puppeteer.launch(
    devTools: true,
    headless: false,
    userDataDir: userDataDir.path,
  );

  await Future.delayed(const Duration(seconds: 10)); // Do the job

  await browser.close();
  dir.deleteSync(recursive: true);
}

Directory _createUserDataDirectory(
  Directory dir, {
  Map<String, dynamic>? preferences,
}) {
  var defaultDir = Directory(p.join(dir.path, 'Default'))
    ..createSync(recursive: true);
  if (preferences != null) {
    File(
      p.join(defaultDir.path, 'Preferences'),
    ).writeAsStringSync(jsonEncode(preferences));
  }
  return dir;
}
