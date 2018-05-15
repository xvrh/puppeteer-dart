import 'dart:async';
import 'package:chrome_dev_tools/domains/log.dart';

import '../domains/network.dart';

Future waitUntilNetworkIdle(NetworkApi network,
    {Duration idleDuration: const Duration(milliseconds: 1000),
    int idleInFlight: 0}) async {
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

    if (requestIds.length > idleInFlight) {
      idleTimer?.cancel();
      idleTimer = null;
    }
  }));
  remove(RequestId id) {
    requestIds.remove(id.value);
    if (requestIds.length <= idleInFlight && idleTimer == null) {
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

Future waitUntilConsoleContains(LogApi log, String text) async {
  await log.enable();
  await for (LogEntry logEntry in log.onEntryAdded) {
    if (logEntry.text.contains(text)) {
      return;
    }
  }
}
