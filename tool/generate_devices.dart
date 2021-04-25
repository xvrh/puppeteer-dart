import 'dart:convert';
import 'dart:io';
import 'package:dart_style/dart_style.dart';
import 'package:http/http.dart';
import 'package:json_annotation/json_annotation.dart';
import 'utils/split_words.dart';
import 'utils/string_helpers.dart';

part 'generate_devices.g.dart';

//TODO(xha): this script doesn't work anymore since the file has changed to
// typescript code (instead of json file):
// https://github.com/ChromeDevTools/devtools-frontend/blob/master/front_end/panels/emulation/EmulatedDevices.ts
const deviceUrl =
    'https://raw.githubusercontent.com/ChromeDevTools/devtools-frontend/master/front_end/emulated_devices/module.json';

void main() async {
  var content = await read(Uri.parse(deviceUrl));

  var module = Module.fromJson(jsonDecode(content) as Map<String, dynamic>);

  var buffer = StringBuffer();
  buffer.writeln("import 'dart:collection';");
  buffer.writeln("import 'package:collection/collection.dart';");
  buffer.writeln(
      "import 'page/emulation_manager.dart' show Device, DeviceViewport;");
  buffer.writeln('class Devices with IterableMixin<Device> {');
  var allNames = <String?, String>{};
  for (var emulatedDevice
      in module.extensions?.where((e) => e.type == 'emulated-device') ??
          <Extension>[]) {
    var device = emulatedDevice.device!;

    const deviceSplits = {
      'iPhone 6/7/8': ['iPhone 6', 'iPhone 7', 'iPhone 8'],
      'iPhone 6 Plus': ['iPhone 6 Plus', 'iPhone 7 Plus', 'iPhone 8 Plus'],
      'iPhone 5/SE': ['iPhone 5', 'iPhone SE'],
    };
    var names = deviceSplits[device.title] ?? [device.title];

    for (var name in names) {
      var deviceName =
          firstLetterLower(splitWords(name).map(firstLetterUpper).join(''));
      allNames[name] = deviceName;

      buffer.writeln(
          'final $deviceName = ${device.toCode(name, viewportCode(device, device.screen!.vertical!))};');
      buffer.writeln();

      var landscape = device.screen!.horizontal;
      if (landscape != null) {
        allNames['$name Landscape'] = '${deviceName}Landscape';
        buffer.writeln(
            'final ${deviceName}Landscape = ${device.toCode(name, viewportCode(device, landscape, isLandscape: true))};');
        buffer.writeln();
      }
    }
  }
  var allNamesMap =
      allNames.entries.map((e) => "'${e.key}': ${e.value}").join(', ');
  buffer.writeln('late final Map<String, Device> _all;');
  buffer.writeln('Devices._() {');
  buffer.writeln(
      '_all = CanonicalizedMap<String, String, Device>.from({$allNamesMap,}, '
      "(key) => key.replaceAll(' ', '').toLowerCase());");
  buffer.writeln('}');
  buffer.writeln();
  buffer.writeln('Device? operator[](String name) => _all[name];');
  buffer.writeln();
  buffer.writeln('@override');
  buffer.writeln('Iterator<Device> get iterator => _all.values.iterator;');
  buffer.writeln();
  buffer.writeln('}');
  buffer.writeln('final devices = Devices._();');
  File('lib/src/devices.dart')
      .writeAsStringSync(DartFormatter().format(buffer.toString()));
}

@JsonSerializable()
class Module {
  List<Extension>? extensions;

  Module();

  factory Module.fromJson(Map<String, dynamic> json) => _$ModuleFromJson(json);

  Map<String, dynamic> toJson() => _$ModuleToJson(this);
}

@JsonSerializable()
class Extension {
  String? type;
  int? order;
  Device? device;

  Extension();

  factory Extension.fromJson(Map<String, dynamic> json) =>
      _$ExtensionFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionToJson(this);
}

@JsonSerializable()
class Device {
  String title;
  List<String>? capabilities;
  @JsonKey(name: 'user-agent')
  String? userAgent;
  String? type;
  Screen? screen;

  Device(this.title);

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  String toCode(String? name, String viewportCode) {
    return "Device('$name', userAgent: '$userAgent', viewport: $viewportCode)";
  }

  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}

@JsonSerializable()
class Screen {
  @JsonKey(name: 'device-pixel-ratio')
  num? devicePixelRatio;
  ScreenOrientation? horizontal, vertical;

  Screen();

  factory Screen.fromJson(Map<String, dynamic> json) => _$ScreenFromJson(json);

  Map<String, dynamic> toJson() => _$ScreenToJson(this);
}

@JsonSerializable()
class ScreenOrientation {
  num? width, height;

  ScreenOrientation();

  factory ScreenOrientation.fromJson(Map<String, dynamic> json) =>
      _$ScreenOrientationFromJson(json);

  Map<String, dynamic> toJson() => _$ScreenOrientationToJson(this);
}

String viewportCode(Device device, ScreenOrientation orientation,
    {bool isLandscape = false}) {
  return 'DeviceViewport(width: ${orientation.width}, '
      'height: ${orientation.height}, '
      'deviceScaleFactor: ${device.screen!.devicePixelRatio}, '
      'isMobile: ${device.capabilities!.contains('mobile')},'
      'hasTouch: ${device.capabilities!.contains('touch')},'
      'isLandscape: $isLandscape'
      ')';
}
