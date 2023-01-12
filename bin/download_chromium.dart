import 'package:puppeteer/puppeteer.dart';

void main() async {
  var info = await downloadChrome();
  print('Chromium ${info.revision} downloaded in ${info.folderPath}.'
      '\nExecutable: ${info.executablePath}');
}
