import 'package:puppeteer/puppeteer.dart';

void main() async {
  var chromePath = await downloadChrome(
      // Specify the custom location (by default it .local-chrome)
      cachePath: null);
  print(chromePath.executablePath);
}
