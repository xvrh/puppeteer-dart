import 'package:puppeteer/puppeteer.dart';

Future<void> main() async {
  final firefoxPath = await downloadFirefox(
      // Specify the custom location (by default it .local-chromium)
      cachePath: null);
  print(firefoxPath.executablePath);
}
