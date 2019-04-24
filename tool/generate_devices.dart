import 'dart:convert';
import 'dart:io';
import 'package:dart_style/dart_style.dart';
import 'package:http/http.dart';
import 'package:json_annotation/json_annotation.dart';
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

    const deviceSplits = {
      'iPhone 6/7/8': ['iPhone 6', 'iPhone 7', 'iPhone 8'],
      'iPhone 6 Plus': ['iPhone 6 Plus', 'iPhone 7 Plus', 'iPhone 8 Plus'],
      'iPhone 5/SE': ['iPhone 5', 'iPhone SE'],
    };
    var names = deviceSplits[device.title] ?? [device.title];

    for (String name in names) {
      var deviceName =
          firstLetterLower(splitWords(name).map(firstLetterUpper).join(''));

      buffer.writeln(
          'const $deviceName = ${device.toCode(name, viewportCode(device, device.screen.vertical))};');
      buffer.writeln();

      var landscape = device.screen.horizontal;
      if (landscape != null) {
        buffer.writeln(
            'final ${deviceName}Landscape = ${device.toCode(name, viewportCode(device, landscape, isLandscape: true))};');
        buffer.writeln();
      }
    }
  }
  File('lib/devices.dart')
      .writeAsStringSync(DartFormatter().format(buffer.toString()));
}

@JsonSerializable()
class Module {
  List<Extension> extensions;

  Module();

  factory Module.fromJson(Map<String, dynamic> json) => _$ModuleFromJson(json);

  Map<String, dynamic> toJson() => _$ModuleToJson(this);
}

@JsonSerializable()
class Extension {
  String type;
  int order;
  Device device;

  Extension();

  factory Extension.fromJson(Map<String, dynamic> json) =>
      _$ExtensionFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionToJson(this);
}

@JsonSerializable()
class Device {
  String title;
  List<String> capabilities;
  @JsonKey(name: 'user-agent')
  String userAgent;
  String type;
  Screen screen;

  Device();

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  String toCode(String name, String viewportCode) {
    return "Device('$name', userAgent: '$userAgent', viewport: $viewportCode)";
  }

  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}

@JsonSerializable()
class Screen {
  @JsonKey(name: 'device-pixel-ratio')
  num devicePixelRatio;
  ScreenOrientation horizontal, vertical;

  Screen();

  factory Screen.fromJson(Map<String, dynamic> json) => _$ScreenFromJson(json);

  Map<String, dynamic> toJson() => _$ScreenToJson(this);
}

@JsonSerializable()
class ScreenOrientation {
  num width, height;

  ScreenOrientation();

  factory ScreenOrientation.fromJson(Map<String, dynamic> json) =>
      _$ScreenOrientationFromJson(json);

  Map<String, dynamic> toJson() => _$ScreenOrientationToJson(this);
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
