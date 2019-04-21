import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dart_style/dart_style.dart';

import 'utils/split_words.dart';
import 'utils/string_helpers.dart';

part 'generate_devices.g.dart';

const deviceUrl =
    'https://raw.githubusercontent.com/ChromeDevTools/devtools-frontend/master/front_end/emulated_devices/module.json';

main() async {
  var content = await read(deviceUrl);

  var module = Module.fromJson(jsonDecode(content));

  var buffer = StringBuffer();
  buffer.writeln(
      "import 'src/page/emulation_manager.dart' show Device, DeviceViewport;");
  for (var emulatedDevice
      in module.extensions.where((e) => e.type == 'emulated-device')) {
    var device = emulatedDevice.device;
    var deviceName = firstLetterLower(
        splitWords(device.title).map(firstLetterUpper).join(''));

    buffer.writeln(
        'const $deviceName = ${device.toCode(viewportCode(device, device.screen.vertical))};');
    buffer.writeln();

    var landscape = device.screen.horizontal;
    if (landscape != null) {
      buffer.writeln(
          'final ${deviceName}Landscape = ${device.toCode(viewportCode(device, landscape, isLandscape: true))};');
      buffer.writeln();
    }
  }
  File('lib/devices.dart')
      .writeAsStringSync(DartFormatter().format(buffer.toString()));
}

@JsonSerializable(generateToJsonFunction: false)
class Module {
  List<Extension> extensions;

  Module();

  factory Module.fromJson(Map<String, dynamic> json) => _$ModuleFromJson(json);
}

@JsonSerializable(generateToJsonFunction: false)
class Extension {
  String type;
  int order;
  Device device;

  Extension();

  factory Extension.fromJson(Map<String, dynamic> json) =>
      _$ExtensionFromJson(json);
}

@JsonSerializable(generateToJsonFunction: false)
class Device {
  String title;
  List<String> capabilities;
  @JsonKey(name: 'user-agent')
  String userAgent;
  String type;
  Screen screen;

  Device();

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  String toCode(String viewportCode) {
    return "Device('$title', userAgent: '$userAgent', viewport: $viewportCode)";
  }
}

@JsonSerializable(generateToJsonFunction: false)
class Screen {
  @JsonKey(name: 'device-pixel-ratio')
  num devicePixelRatio;
  ScreenOrientation horizontal, vertical;

  Screen();

  factory Screen.fromJson(Map<String, dynamic> json) => _$ScreenFromJson(json);
}

@JsonSerializable(generateToJsonFunction: false)
class ScreenOrientation {
  num width, height;

  ScreenOrientation();

  factory ScreenOrientation.fromJson(Map<String, dynamic> json) =>
      _$ScreenOrientationFromJson(json);
}

String viewportCode(Device device, ScreenOrientation orientation,
    {bool isLandscape = false}) {
  return 'DeviceViewport(width: ${orientation.width}, '
      'height: ${orientation.height}, '
      'deviceScaleFactor: ${device.screen.devicePixelRatio}, '
      'isMobile: ${device.capabilities.contains('mobile')},'
      'hasTouch: ${device.capabilities.contains('touch')},'
      'isLandscape: $isLandscape'
      ')';
}
