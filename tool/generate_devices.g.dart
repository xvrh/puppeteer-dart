// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_devices.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Module _$ModuleFromJson(Map<String, dynamic> json) {
  return Module()
    ..extensions = (json['extensions'] as List)
        ?.map((e) =>
            e == null ? null : Extension.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

abstract class _$ModuleSerializerMixin {
  List<Extension> get extensions;
  Map<String, dynamic> toJson() => <String, dynamic>{'extensions': extensions};
}

Extension _$ExtensionFromJson(Map<String, dynamic> json) {
  return Extension()
    ..type = json['type'] as String
    ..order = json['order'] as int
    ..device = json['device'] == null
        ? null
        : Device.fromJson(json['device'] as Map<String, dynamic>);
}

abstract class _$ExtensionSerializerMixin {
  String get type;
  int get order;
  Device get device;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'type': type, 'order': order, 'device': device};
}

Device _$DeviceFromJson(Map<String, dynamic> json) {
  return Device()
    ..title = json['title'] as String
    ..capabilities =
        (json['capabilities'] as List)?.map((e) => e as String)?.toList()
    ..userAgent = json['user-agent'] as String
    ..type = json['type'] as String
    ..screen = json['screen'] == null
        ? null
        : Screen.fromJson(json['screen'] as Map<String, dynamic>);
}

abstract class _$DeviceSerializerMixin {
  String get title;
  List<String> get capabilities;
  String get userAgent;
  String get type;
  Screen get screen;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'capabilities': capabilities,
        'user-agent': userAgent,
        'type': type,
        'screen': screen
      };
}

Screen _$ScreenFromJson(Map<String, dynamic> json) {
  return Screen()
    ..devicePixelRatio = json['device-pixel-ratio'] as num
    ..horizontal = json['horizontal'] == null
        ? null
        : ScreenOrientation.fromJson(json['horizontal'] as Map<String, dynamic>)
    ..vertical = json['vertical'] == null
        ? null
        : ScreenOrientation.fromJson(json['vertical'] as Map<String, dynamic>);
}

abstract class _$ScreenSerializerMixin {
  num get devicePixelRatio;
  ScreenOrientation get horizontal;
  ScreenOrientation get vertical;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'device-pixel-ratio': devicePixelRatio,
        'horizontal': horizontal,
        'vertical': vertical
      };
}

ScreenOrientation _$ScreenOrientationFromJson(Map<String, dynamic> json) {
  return ScreenOrientation()
    ..width = json['width'] as num
    ..height = json['height'] as num;
}

abstract class _$ScreenOrientationSerializerMixin {
  num get width;
  num get height;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'width': width, 'height': height};
}
