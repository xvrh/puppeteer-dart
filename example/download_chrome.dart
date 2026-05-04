import 'package:puppeteer/puppeteer.dart';

void main() async {
  var chromePath = await downloadChrome(
    // Specify a custom cache location. When omitted, Chrome is cached in
    // `.dart_tool/puppeteer/local-chrome/` under the current Dart project
    // (or workspace root, if any).
    cachePath: null,
  );
  print(chromePath.executablePath);
}
