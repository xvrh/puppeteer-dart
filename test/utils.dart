import 'dart:io';

// In travis/docker we need the --no-sandbox flag in chrome
bool get forceNoSandboxFlag =>
    Platform.isLinux && Platform.environment['TRAVIS'] == 'true';
