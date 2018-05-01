import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'utils.dart';

main() {
  chromeTab('https://www.google.com', (Tab tab) async {
    // A small helper to wait until the network is quiet
    await tab.waitUntilNetworkIdle();

    // Execute some javascript to serialize the document
    var result = await tab.runtime
        .evaluate('document.documentElement.outerHTML;', returnByValue: true);

    String pageContent = result.result.value;
    print(pageContent);
  });
}
