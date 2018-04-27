import 'dart:io';

bool get forceNoSandboxFlag =>
    Platform.isLinux && Platform.environment['TRAVIS'] == 'true';
