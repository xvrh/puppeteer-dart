// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_devices.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Module _$ModuleFromJson(Map<String, dynamic> json) {
  return Module()
    ..extensions = (json['extensions'] as List<dynamic>?)
        ?.map((e) => Extension.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$ModuleToJson(Module instance) => <String, dynamic>{
      'extensions': instance.extensions,
    };

Extension _$ExtensionFromJson(Map<String, dynamic> json) {
  return Extension()
    ..type = json['type'] as String?
    ..order = json['order'] as int?
    ..device = json['device'] == null
        ? null
        : Device.fromJson(json['device'] as Map<String, dynamic>);
}

Map<String, dynamic> _$ExtensionToJson(Extension instance) => <String, dynamic>{
      'type': instance.type,
      'order': instance.order,
      'device': instance.device,
    };

Device _$DeviceFromJson(Map<String, dynamic> json) {
  return Device(
    json['title'] as String,
  )
    ..capabilities = (json['capabilities'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList()
    ..userAgent = json['user-agent'] as String?
    ..type = json['type'] as String?
    ..screen = json['screen'] == null
        ? null
        : Screen.fromJson(json['screen'] as Map<String, dynamic>);
}

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
      'title': instance.title,
      'capabilities': instance.capabilities,
      'user-agent': instance.userAgent,
      'type': instance.type,
      'screen': instance.screen,
    };

Screen _$ScreenFromJson(Map<String, dynamic> json) {
  return Screen()
    ..devicePixelRatio = json['device-pixel-ratio'] as num?
    ..horizontal = json['horizontal'] == null
        ? null
        : ScreenOrientation.fromJson(json['horizontal'] as Map<String, dynamic>)
    ..vertical = json['vertical'] == null
        ? null
        : ScreenOrientation.fromJson(json['vertical'] as Map<String, dynamic>);
}

Map<String, dynamic> _$ScreenToJson(Screen instance) => <String, dynamic>{
      'device-pixel-ratio': instance.devicePixelRatio,
      'horizontal': instance.horizontal,
      'vertical': instance.vertical,
    };

ScreenOrientation _$ScreenOrientationFromJson(Map<String, dynamic> json) {
  return ScreenOrientation()
    ..width = json['width'] as num?
    ..height = json['height'] as num?;
}

Map<String, dynamic> _$ScreenOrientationToJson(ScreenOrientation instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
    };
