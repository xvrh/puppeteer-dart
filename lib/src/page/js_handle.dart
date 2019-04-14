import 'package:chrome_dev_tools/domains/runtime.dart';
import 'package:chrome_dev_tools/src/page/execution_context.dart';
import 'package:chrome_dev_tools/src/page/frame_manager.dart';
import 'package:chrome_dev_tools/src/page/helper.dart';
import 'package:chrome_dev_tools/src/page/page.dart';

class JsHandle {
  final ExecutionContext context;
  final RemoteObject remoteObject;
  bool _disposed = false;

  JsHandle(this.context, this.remoteObject);

  factory JsHandle.fromRemoteObject(ExecutionContext context,
      RemoteObject remoteObject) {
    var frame = context.frame;
    if (remoteObject.subtype == 'node' && frame != null) {
      var frameManager = context.world.frameManager;
      return ElementHandle(
          context, remoteObject, frameManager.page, frameManager);
    }
    return JsHandle(context, remoteObject);
  }

  bool get isDisposed => _disposed;

  Future<JsHandle> property(String propertyName) async {
    var objectHandle = await context.evaluateHandle('''
const result = {__proto__: null};
result[propertyName] = object[propertyName];
return result;
''', {'object': this, 'propertyName': propertyName});
    var properties = await objectHandle.properties;
    var result = properties[propertyName];
    await objectHandle.dispose();
    return result;
  }

  Future<Map<String, JsHandle>> get properties async {
    var response = await context.runtimeApi.getProperties(
        remoteObject.objectId, ownProperties: true);
    var result = <String, JsHandle>{};
    for (var property in response.result) {
      if (!property.enumerable)
        continue;
      result[property.name] = JsHandle.fromRemoteObject(context, property.value);
    }
    return result;
  }

  Future get jsonValue async {
    if (remoteObject.objectId != null) {
      var response = await context.runtimeApi.callFunctionOn('function() { return this; }', objectId: remoteObject.objectId, returnByValue: true, awaitPromise: true);

      return valueFromRemoteObject(response.result);
    }
    return valueFromRemoteObject(remoteObject);
  }

  ElementHandle get asElement => null;

  Future dispose() async {
    if (_disposed)
      return;
    _disposed = true;

    if (remoteObject.objectId != null) {
      await context.runtimeApi.releaseObject(remoteObject.objectId).catchError((_) {
        // Exceptions might happen in case of a page been navigated or closed.
        // Swallow these since they are harmless and we don't leak anything in this case.
      });
    }
  }

  @override
  String toString() {
    if (remoteObject.objectId != null) {
      var type = remoteObject.subtype ?? remoteObject.type;
      return 'JSHandle@' + type;
    }
    return 'JSHandle:' + valueFromRemoteObject(remoteObject);
  }
}

class ElementHandle extends JsHandle {
  final Page page;
  final FrameManager frameManager;

  ElementHandle(ExecutionContext context, RemoteObject remoteObject, this.page,
      this.frameManager)
      : super(context, remoteObject);

  @override
  ElementHandle get asElement => this;

  Future<List<ElementHandle>> $x(String expression) async {
    return null;
  }

  Future<ElementHandle> $(String selector) async {}

  Future<List<ElementHandle>> $$(String selector) async {}

  Future $eval(String selector, String pageFunction,
      [Map<String, dynamic> args]) async {}

  Future $$eval(String selector, String pageFunction,
      [Map<String, dynamic> args]) async {}
}
