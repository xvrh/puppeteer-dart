import 'dart:async';

import 'package:meta/meta.dart' show required;

import '../src/connection.dart';
import 'runtime.dart' as runtime;

/// Input/Output operations for streams produced by DevTools.
class IOApi {
  final Client _client;

  IOApi(this._client);

  /// Close the stream, discard any temporary backing storage.
  /// [handle] Handle of the stream to close.
  Future<void> close(StreamHandle handle) async {
    var parameters = <String, dynamic>{
      'handle': handle.toJson(),
    };
    await _client.send('IO.close', parameters);
  }

  /// Read a chunk of the stream
  /// [handle] Handle of the stream to read.
  /// [offset] Seek to the specified offset before reading (if not specificed, proceed with offset
  /// following the last read). Some types of streams may only support sequential reads.
  /// [size] Maximum number of bytes to read (left upon the agent discretion if not specified).
  Future<ReadResult> read(StreamHandle handle, {int offset, int size}) async {
    var parameters = <String, dynamic>{
      'handle': handle.toJson(),
    };
    if (offset != null) {
      parameters['offset'] = offset;
    }
    if (size != null) {
      parameters['size'] = size;
    }
    var result = await _client.send('IO.read', parameters);
    return ReadResult.fromJson(result);
  }

  /// Return UUID of Blob object specified by a remote object id.
  /// [objectId] Object id of a Blob object wrapper.
  /// Returns: UUID of the specified Blob.
  Future<String> resolveBlob(runtime.RemoteObjectId objectId) async {
    var parameters = <String, dynamic>{
      'objectId': objectId.toJson(),
    };
    var result = await _client.send('IO.resolveBlob', parameters);
    return result['uuid'];
  }
}

class ReadResult {
  /// Set if the data is base64-encoded
  final bool base64Encoded;

  /// Data that were read.
  final String data;

  /// Set if the end-of-file condition occured while reading.
  final bool eof;

  ReadResult({this.base64Encoded, @required this.data, @required this.eof});

  factory ReadResult.fromJson(Map<String, dynamic> json) {
    return ReadResult(
      base64Encoded:
          json.containsKey('base64Encoded') ? json['base64Encoded'] : null,
      data: json['data'],
      eof: json['eof'],
    );
  }
}

/// This is either obtained from another method or specifed as `blob:&lt;uuid&gt;` where
/// `&lt;uuid&gt` is an UUID of a Blob.
class StreamHandle {
  final String value;

  StreamHandle(this.value);

  factory StreamHandle.fromJson(String value) => StreamHandle(value);

  String toJson() => value;

  @override
  bool operator ==(other) =>
      (other is StreamHandle && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
