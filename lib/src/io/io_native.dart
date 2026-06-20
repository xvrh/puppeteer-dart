import 'dart:isolate';

export 'dart:io';

/// The package config URI for the running program, or `null` if unavailable.
Uri? packageConfigSync() => Isolate.packageConfigSync;
