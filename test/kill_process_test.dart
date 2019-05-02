import 'dart:convert';
import 'dart:io';
import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';

main() {
  test('No process when closing', () async {
    var browser = await puppeteer.launch();
    print(browser.process.pid);
    expect(browser.process.pid, greaterThan(0));
    var processes = await ps();
    expect(
        processes.any((p) => p.name.contains(browser.process.pid.toString())),
        isTrue);
    expect(processes.any((p) => p.name.toLowerCase().contains('chromium')),
        isTrue);

    await browser.close();
    await Future.delayed(Duration(milliseconds: 100));

    processes = await ps();
    expect(processes.any((p) => p.name.toLowerCase().contains('chromium')),
        isFalse);
    expect(
        processes.any((p) => p.name.contains(browser.process.pid.toString())),
        isFalse);
  });

  // Avoir une méthode pour lister les process multi plateforme
  // Ce test ne peut s'exécuter que de manière non concurrente

  // - Test normal avec un close normal
  // - Test avec un arrêt brutal du browesr (kill du process)
  // - Test en lancant un script dart et en faisant un arrêt brutal du script dart.
  // - Test en lancant un script qui crash au milieu
}

Future<List<ProcessInfo>> ps() async {
  var result = await Process.run('ps', ['aux']);
  var lines = LineSplitter.split(result.stdout);

  return lines.skip(1).map(ProcessInfo.parse).toList();
}

class ProcessInfo {
  final String name;

  ProcessInfo(this.name);

  static ProcessInfo parse(String line) {
    return ProcessInfo(line);
  }

  @override
  String toString() => name;
}
