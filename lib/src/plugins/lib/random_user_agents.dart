/// A dart library for generating random user agents.
library random_user_agents;

import 'dart:math';

part 'user_agents.dart';

/// Random UserAgents
class RandomUserAgents {
  /// a filtered list of user agents
  final List<String> _list;

  /// Creates a random number generator
  final Random _random = Random();

  /// Return an instance of RandomUserAgents using a private named constructor.
  /// The instance is created with a filter function and a filtered list of user agents.
  factory RandomUserAgents([bool Function(String value)? filter]) {
    if (filter == null) {
      return RandomUserAgents._internal(
        _userAgents,
      );
    }

    return RandomUserAgents._internal(
      _userAgents.where(filter).toList(),
    );
  }

  /// a private named constructor
  RandomUserAgents._internal(this._list);

  /// Return a random user agent string
  static String random() {
    Random random = Random();
    return _userAgents[random.nextInt(_userAgents.length)];
  }

  /// Return a random user agent string
  String getUserAgent() {
    return _list[_random.nextInt(_list.length)];
  }
}
