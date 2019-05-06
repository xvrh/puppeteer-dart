import '../../protocol/runtime.dart';
import '../connection.dart';

class Worker {
  final Client client;
  final String url;

  Worker(this.client, this.url) {
    RuntimeApi runtimeApi = RuntimeApi(client);

    runtimeApi.onExecutionContextCreated.first.then((_) {});

    runtimeApi.enable();
  }
}
