import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';

/// The SystemInfo domain defines methods and events for querying low-level system information.
class SystemInfoApi {
  final Client _client;

  SystemInfoApi(this._client);

  /// Returns information about the system.
  Future<GetInfoResult> getInfo() async {
    var result = await _client.send('SystemInfo.getInfo');
    return GetInfoResult.fromJson(result);
  }

  /// Returns information about all running processes.
  /// Returns: An array of process info blocks.
  Future<List<ProcessInfo>> getProcessInfo() async {
    var result = await _client.send('SystemInfo.getProcessInfo');
    return (result['processInfo'] as List)
        .map((e) => ProcessInfo.fromJson(e))
        .toList();
  }
}

class GetInfoResult {
  /// Information about the GPUs on the system.
  final GPUInfo gpu;

  /// A platform-dependent description of the model of the machine. On Mac OS, this is, for
  /// example, 'MacBookPro'. Will be the empty string if not supported.
  final String modelName;

  /// A platform-dependent description of the version of the machine. On Mac OS, this is, for
  /// example, '10.1'. Will be the empty string if not supported.
  final String modelVersion;

  /// The command line string used to launch the browser. Will be the empty string if not
  /// supported.
  final String commandLine;

  GetInfoResult(
      {@required this.gpu,
      @required this.modelName,
      @required this.modelVersion,
      @required this.commandLine});

  factory GetInfoResult.fromJson(Map<String, dynamic> json) {
    return GetInfoResult(
      gpu: GPUInfo.fromJson(json['gpu']),
      modelName: json['modelName'],
      modelVersion: json['modelVersion'],
      commandLine: json['commandLine'],
    );
  }
}

/// Describes a single graphics processor (GPU).
class GPUDevice {
  /// PCI ID of the GPU vendor, if available; 0 otherwise.
  final num vendorId;

  /// PCI ID of the GPU device, if available; 0 otherwise.
  final num deviceId;

  /// String description of the GPU vendor, if the PCI ID is not available.
  final String vendorString;

  /// String description of the GPU device, if the PCI ID is not available.
  final String deviceString;

  /// String description of the GPU driver vendor.
  final String driverVendor;

  /// String description of the GPU driver version.
  final String driverVersion;

  GPUDevice(
      {@required this.vendorId,
      @required this.deviceId,
      @required this.vendorString,
      @required this.deviceString,
      @required this.driverVendor,
      @required this.driverVersion});

  factory GPUDevice.fromJson(Map<String, dynamic> json) {
    return GPUDevice(
      vendorId: json['vendorId'],
      deviceId: json['deviceId'],
      vendorString: json['vendorString'],
      deviceString: json['deviceString'],
      driverVendor: json['driverVendor'],
      driverVersion: json['driverVersion'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'vendorId': vendorId,
      'deviceId': deviceId,
      'vendorString': vendorString,
      'deviceString': deviceString,
      'driverVendor': driverVendor,
      'driverVersion': driverVersion,
    };
    return json;
  }
}

/// Describes the width and height dimensions of an entity.
class Size {
  /// Width in pixels.
  final int width;

  /// Height in pixels.
  final int height;

  Size({@required this.width, @required this.height});

  factory Size.fromJson(Map<String, dynamic> json) {
    return Size(
      width: json['width'],
      height: json['height'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'width': width,
      'height': height,
    };
    return json;
  }
}

/// Describes a supported video decoding profile with its associated minimum and
/// maximum resolutions.
class VideoDecodeAcceleratorCapability {
  /// Video codec profile that is supported, e.g. VP9 Profile 2.
  final String profile;

  /// Maximum video dimensions in pixels supported for this |profile|.
  final Size maxResolution;

  /// Minimum video dimensions in pixels supported for this |profile|.
  final Size minResolution;

  VideoDecodeAcceleratorCapability(
      {@required this.profile,
      @required this.maxResolution,
      @required this.minResolution});

  factory VideoDecodeAcceleratorCapability.fromJson(Map<String, dynamic> json) {
    return VideoDecodeAcceleratorCapability(
      profile: json['profile'],
      maxResolution: Size.fromJson(json['maxResolution']),
      minResolution: Size.fromJson(json['minResolution']),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'profile': profile,
      'maxResolution': maxResolution.toJson(),
      'minResolution': minResolution.toJson(),
    };
    return json;
  }
}

/// Describes a supported video encoding profile with its associated maximum
/// resolution and maximum framerate.
class VideoEncodeAcceleratorCapability {
  /// Video codec profile that is supported, e.g H264 Main.
  final String profile;

  /// Maximum video dimensions in pixels supported for this |profile|.
  final Size maxResolution;

  /// Maximum encoding framerate in frames per second supported for this
  /// |profile|, as fraction's numerator and denominator, e.g. 24/1 fps,
  /// 24000/1001 fps, etc.
  final int maxFramerateNumerator;

  final int maxFramerateDenominator;

  VideoEncodeAcceleratorCapability(
      {@required this.profile,
      @required this.maxResolution,
      @required this.maxFramerateNumerator,
      @required this.maxFramerateDenominator});

  factory VideoEncodeAcceleratorCapability.fromJson(Map<String, dynamic> json) {
    return VideoEncodeAcceleratorCapability(
      profile: json['profile'],
      maxResolution: Size.fromJson(json['maxResolution']),
      maxFramerateNumerator: json['maxFramerateNumerator'],
      maxFramerateDenominator: json['maxFramerateDenominator'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'profile': profile,
      'maxResolution': maxResolution.toJson(),
      'maxFramerateNumerator': maxFramerateNumerator,
      'maxFramerateDenominator': maxFramerateDenominator,
    };
    return json;
  }
}

/// YUV subsampling type of the pixels of a given image.
class SubsamplingFormat {
  static const yuv420 = SubsamplingFormat._('yuv420');
  static const yuv422 = SubsamplingFormat._('yuv422');
  static const yuv444 = SubsamplingFormat._('yuv444');
  static const values = {
    'yuv420': yuv420,
    'yuv422': yuv422,
    'yuv444': yuv444,
  };

  final String value;

  const SubsamplingFormat._(this.value);

  factory SubsamplingFormat.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is SubsamplingFormat && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Image format of a given image.
class ImageType {
  static const jpeg = ImageType._('jpeg');
  static const webp = ImageType._('webp');
  static const unknown = ImageType._('unknown');
  static const values = {
    'jpeg': jpeg,
    'webp': webp,
    'unknown': unknown,
  };

  final String value;

  const ImageType._(this.value);

  factory ImageType.fromJson(String value) => values[value];

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ImageType && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Describes a supported image decoding profile with its associated minimum and
/// maximum resolutions and subsampling.
class ImageDecodeAcceleratorCapability {
  /// Image coded, e.g. Jpeg.
  final ImageType imageType;

  /// Maximum supported dimensions of the image in pixels.
  final Size maxDimensions;

  /// Minimum supported dimensions of the image in pixels.
  final Size minDimensions;

  /// Optional array of supported subsampling formats, e.g. 4:2:0, if known.
  final List<SubsamplingFormat> subsamplings;

  ImageDecodeAcceleratorCapability(
      {@required this.imageType,
      @required this.maxDimensions,
      @required this.minDimensions,
      @required this.subsamplings});

  factory ImageDecodeAcceleratorCapability.fromJson(Map<String, dynamic> json) {
    return ImageDecodeAcceleratorCapability(
      imageType: ImageType.fromJson(json['imageType']),
      maxDimensions: Size.fromJson(json['maxDimensions']),
      minDimensions: Size.fromJson(json['minDimensions']),
      subsamplings: (json['subsamplings'] as List)
          .map((e) => SubsamplingFormat.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'imageType': imageType.toJson(),
      'maxDimensions': maxDimensions.toJson(),
      'minDimensions': minDimensions.toJson(),
      'subsamplings': subsamplings.map((e) => e.toJson()).toList(),
    };
    return json;
  }
}

/// Provides information about the GPU(s) on the system.
class GPUInfo {
  /// The graphics devices on the system. Element 0 is the primary GPU.
  final List<GPUDevice> devices;

  /// An optional dictionary of additional GPU related attributes.
  final Map auxAttributes;

  /// An optional dictionary of graphics features and their status.
  final Map featureStatus;

  /// An optional array of GPU driver bug workarounds.
  final List<String> driverBugWorkarounds;

  /// Supported accelerated video decoding capabilities.
  final List<VideoDecodeAcceleratorCapability> videoDecoding;

  /// Supported accelerated video encoding capabilities.
  final List<VideoEncodeAcceleratorCapability> videoEncoding;

  /// Supported accelerated image decoding capabilities.
  final List<ImageDecodeAcceleratorCapability> imageDecoding;

  GPUInfo(
      {@required this.devices,
      this.auxAttributes,
      this.featureStatus,
      @required this.driverBugWorkarounds,
      @required this.videoDecoding,
      @required this.videoEncoding,
      @required this.imageDecoding});

  factory GPUInfo.fromJson(Map<String, dynamic> json) {
    return GPUInfo(
      devices:
          (json['devices'] as List).map((e) => GPUDevice.fromJson(e)).toList(),
      auxAttributes:
          json.containsKey('auxAttributes') ? json['auxAttributes'] : null,
      featureStatus:
          json.containsKey('featureStatus') ? json['featureStatus'] : null,
      driverBugWorkarounds: (json['driverBugWorkarounds'] as List)
          .map((e) => e as String)
          .toList(),
      videoDecoding: (json['videoDecoding'] as List)
          .map((e) => VideoDecodeAcceleratorCapability.fromJson(e))
          .toList(),
      videoEncoding: (json['videoEncoding'] as List)
          .map((e) => VideoEncodeAcceleratorCapability.fromJson(e))
          .toList(),
      imageDecoding: (json['imageDecoding'] as List)
          .map((e) => ImageDecodeAcceleratorCapability.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'devices': devices.map((e) => e.toJson()).toList(),
      'driverBugWorkarounds': driverBugWorkarounds.map((e) => e).toList(),
      'videoDecoding': videoDecoding.map((e) => e.toJson()).toList(),
      'videoEncoding': videoEncoding.map((e) => e.toJson()).toList(),
      'imageDecoding': imageDecoding.map((e) => e.toJson()).toList(),
    };
    if (auxAttributes != null) {
      json['auxAttributes'] = auxAttributes;
    }
    if (featureStatus != null) {
      json['featureStatus'] = featureStatus;
    }
    return json;
  }
}

/// Represents process info.
class ProcessInfo {
  /// Specifies process type.
  final String type;

  /// Specifies process id.
  final int id;

  /// Specifies cumulative CPU usage in seconds across all threads of the
  /// process since the process start.
  final num cpuTime;

  ProcessInfo({@required this.type, @required this.id, @required this.cpuTime});

  factory ProcessInfo.fromJson(Map<String, dynamic> json) {
    return ProcessInfo(
      type: json['type'],
      id: json['id'],
      cpuTime: json['cpuTime'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'type': type,
      'id': id,
      'cpuTime': cpuTime,
    };
    return json;
  }
}
