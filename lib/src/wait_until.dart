import 'dart:async';
import 'package:chrome_dev_tools/domains/network.dart';
import 'package:chrome_dev_tools/src/connection.dart';

Future waitUntilNetworkIdle(Session session,
    {Duration idleDuration: const Duration(milliseconds: 1000),
    int idleInflight: 2}) async {
  NetworkDomain network = new NetworkDomain(session);
  await network.enable();

  List<String> requestIds = [];

  Completer completer = new Completer();
  List<StreamSubscription> subscriptions = [];
  complete() {
    for (StreamSubscription subscription in subscriptions) {
      subscription.cancel();
    }
    completer.complete();
  }

  Timer idleTimer = new Timer(idleDuration, complete);

  subscriptions
      .add(network.onRequestWillBeSent.listen((RequestWillBeSentEvent e) {
    requestIds.add(e.requestId.value);

    if (requestIds.length > idleInflight) {
      idleTimer?.cancel();
      idleTimer = null;
    }
  }));
  remove(RequestId id) {
    requestIds.remove(id.value);
    if (requestIds.length <= idleInflight && idleTimer == null) {
      idleTimer = new Timer(idleDuration, complete);
    }
  }

  subscriptions.add(network.onLoadingFinished.listen((LoadingFinishedEvent e) {
    remove(e.requestId);
  }));
  subscriptions.add(network.onLoadingFailed.listen((LoadingFailedEvent e) {
    remove(e.requestId);
  }));

  await completer.future;
}
