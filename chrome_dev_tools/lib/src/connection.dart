abstract class Client {
  Future<Map> send(String method, [Map parameters]);

  Stream<Event> get onEvent;
}

class Event {
  final String name;
  final Map parameters;

  Event(this.name, this.parameters);
}

/// An annotation to tag some API parameters with the accepted values.
/// This is purely for documentation purpose until Dart support something like
/// "String Literal Types" from TypeScript.
class Enum {
  const Enum(List<String> values);
}
