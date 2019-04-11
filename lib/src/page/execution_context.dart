
import 'package:chrome_dev_tools/domains/runtime.dart';
import 'package:chrome_dev_tools/src/connection.dart';
import 'package:chrome_dev_tools/src/page/dom_world.dart';

class ExecutionContext {
  final Client client;
  final ExecutionContextDescription context;
  final DomWorld domWorld;

  ExecutionContext(this.client, this.context, this.domWorld);
}
