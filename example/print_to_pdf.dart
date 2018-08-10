import 'dart:convert';
import 'dart:io';
import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'utils.dart';

main() {
  chromeTab('https://www.github.com', (Tab tab) async {
    // Force the "screen" media or some CSS @media print can change the look
    await tab.emulation.setEmulatedMedia('screen');

    // A small helper to wait until the network is quiet
    await tab.waitUntilNetworkIdle();

    // Capture the PDF and convert it to a List of bytes.
    List<int> pdf = base64.decode(await tab.page.printToPDF(
        pageRanges: '1',
        landscape: true,
        printBackground: true,
        marginBottom: 0,
        marginLeft: 0,
        marginRight: 0,
        marginTop: 0));

    // Save the bytes in a file
    await File.fromUri(Platform.script.resolve('_github.pdf'))
        .writeAsBytes(pdf);
  });
}
