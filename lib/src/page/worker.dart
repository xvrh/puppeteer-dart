import 'package:puppeteer/protocol/runtime.dart';
import 'package:puppeteer/src/connection.dart';

class Worker {
  final Client client;
  final String url;

  Worker(this.client, this.url) {
    RuntimeApi runtimeApi = RuntimeApi(client);

    runtimeApi.onExecutionContextCreated.first.then((_) {});

    runtimeApi.enable();
  }
}
