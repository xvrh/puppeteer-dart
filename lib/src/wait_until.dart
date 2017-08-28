import 'dart:async';
import 'package:chrome_dev_tools/domains/network.dart';

Future waitUntilNetworkIdle(NetworkManager networkManager) {
  List<String> requestIds = [];

  Completer completer = new Completer();
  List<StreamSubscription> subscriptions = [];
  complete() {
    for (StreamSubscription subscription in subscriptions) {
      subscription.cancel();
    }
    completer.complete();
  }

  Timer idleTimer;

  subscriptions.add(
      networkManager.onRequestWillBeSent.listen((RequestWillBeSentEvent e) {
    requestIds.add(e.requestId.value);
    idleTimer?.cancel();
    idleTimer = null;
  }));
  remove(RequestId id) {
    requestIds.remove(id.value);
    if (requestIds.isEmpty && idleTimer == null) {
      idleTimer = new Timer(const Duration(milliseconds: 1000), complete);
    }
  }

  subscriptions
      .add(networkManager.onLoadingFinished.listen((LoadingFinishedEvent e) {
    remove(e.requestId);
  }));
  subscriptions
      .add(networkManager.onLoadingFailed.listen((LoadingFailedEvent e) {
    remove(e.requestId);
  }));

  return completer.future;
}
