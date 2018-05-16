import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'utils.dart';

main() {
  chromeTab('https://www.google.com', (Tab tab) async {
    // A small helper to wait until the network is quiet
    await tab.waitUntilNetworkIdle();

    // Execute some javascript to serialize the document
    String pageContent =
        await tab.evaluate('document.documentElement.outerHTML');

    print(pageContent);
  });
}
