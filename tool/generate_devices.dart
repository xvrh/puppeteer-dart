import 'dart:convert';
import 'dart:io';
import 'package:dart_style/dart_style.dart';
import 'package:json_annotation/json_annotation.dart';
import 'utils/split_words.dart';
import 'utils/string_helpers.dart';

part 'generate_devices.g.dart';

void main() async {
  // List extracted from https://github.com/puppeteer/puppeteer/blob/main/packages/puppeteer-core/src/common/Device.ts
  var content = await File('tool/known_devices.json').readAsString();

  var devices = (jsonDecode(content) as List<dynamic>).map(
    (e) => Device.fromJson(e as Map<String, dynamic>),
  );

  var buffer = StringBuffer();
  buffer.writeln("import 'dart:collection';");
  buffer.writeln("import 'package:collection/collection.dart';");
  buffer.writeln(
    "import 'page/emulation_manager.dart' show Device, DeviceViewport;",
  );
  buffer.writeln('class Devices with IterableMixin<Device> {');
  var allNames = <String?, String>{};
  for (var device in devices) {
    var variableName = firstLetterLower(
      splitWords(device.name).map(firstLetterUpper).join(''),
    );
    allNames[device.name] = variableName;

    buffer.writeln('final $variableName = ${device.toCode()};');
    buffer.writeln();
  }
  var allNamesMap = allNames.entries
      .map((e) => "'${e.key}': ${e.value}")
      .join(', ');
  buffer.writeln('late final Map<String, Device> _all;');
  buffer.writeln('Devices._() {');
  buffer.writeln(
    '_all = CanonicalizedMap<String, String, Device>.from({$allNamesMap,}, '
    "(key) => key.replaceAll(' ', '').toLowerCase());",
  );
  buffer.writeln('}');
  buffer.writeln();
  buffer.writeln('Device? operator[](String name) => _all[name];');
  buffer.writeln();
  buffer.writeln('@override');
  buffer.writeln('Iterator<Device> get iterator => _all.values.iterator;');
  buffer.writeln();
  buffer.writeln('}');
  buffer.writeln('final devices = Devices._();');
  File('lib/src/devices.dart').writeAsStringSync(
    DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format(buffer.toString()),
  );
}

@JsonSerializable()
class Device {
  final String name;
  final String userAgent;
  final DeviceViewport viewport;

  Device(this.name, this.userAgent, this.viewport);

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  String toCode() {
    return "Device('$name', userAgent: '$userAgent', viewport: ${viewport.toCode()})";
  }

  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}

@JsonSerializable()
class DeviceViewport {
  final int width, height;
  final num deviceScaleFactor;
  final bool isMobile;
  final bool hasTouch;
  final bool isLandscape;

  DeviceViewport(
    this.width,
    this.height,
    this.deviceScaleFactor,
    this.isMobile,
    this.hasTouch,
    this.isLandscape,
  );

  factory DeviceViewport.fromJson(Map<String, dynamic> json) =>
      _$DeviceViewportFromJson(json);

  String toCode() {
    return 'DeviceViewport(width: $width, '
        'height: $height, '
        'deviceScaleFactor: $deviceScaleFactor, '
        'isMobile: $isMobile,'
        'hasTouch: $hasTouch,'
        'isLandscape: $isLandscape'
        ')';
  }

  Map<String, dynamic> toJson() => _$DeviceViewportToJson(this);
}
