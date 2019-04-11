

import 'dart:async';

import 'package:chrome_dev_tools/domains/page.dart';
import 'package:chrome_dev_tools/src/page/execution_context.dart';
import 'package:chrome_dev_tools/src/page/frame_manager.dart';

class DomWorld {
  final FrameManager frameManager;
  final Frame frame;
  final _waitTasks = <WaitTask>[];
  final _contextCompleter = Completer<ExecutionContext>();

  DomWorld(this.frameManager, this.frame) {

  }

  void setContext(ExecutionContext context) {
    if (context != null) {
      _contextCompleter.complete(context);
    } else {
      
    }
  }
}

class WaitTask {

}
