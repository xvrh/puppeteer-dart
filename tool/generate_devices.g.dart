// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_devices.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
  json['name'] as String,
  json['userAgent'] as String,
  DeviceViewport.fromJson(json['viewport'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
  'name': instance.name,
  'userAgent': instance.userAgent,
  'viewport': instance.viewport,
};

DeviceViewport _$DeviceViewportFromJson(Map<String, dynamic> json) =>
    DeviceViewport(
      json['width'] as int,
      json['height'] as int,
      json['deviceScaleFactor'] as num,
      json['isMobile'] as bool,
      json['hasTouch'] as bool,
      json['isLandscape'] as bool,
    );

Map<String, dynamic> _$DeviceViewportToJson(DeviceViewport instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'deviceScaleFactor': instance.deviceScaleFactor,
      'isMobile': instance.isMobile,
      'hasTouch': instance.hasTouch,
      'isLandscape': instance.isLandscape,
    };
