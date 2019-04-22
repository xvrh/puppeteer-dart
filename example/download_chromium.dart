import 'package:puppeteer/puppeteer.dart';

main() async {
  ChromePath chromePath = await downloadChrome(
      // Specify the custom location (by default it .local-chromium)
      cachePath: null);
  print(chromePath.executablePath);
}
