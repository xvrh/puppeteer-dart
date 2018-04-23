/// Input/Output operations for streams produced by DevTools.

import 'dart:async';
// ignore: unused_import
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'runtime.dart' as runtime;

class IODomain {
  final Client _client;

  IODomain(this._client);

  /// Read a chunk of the stream
  /// [handle] Handle of the stream to read.
  /// [offset] Seek to the specified offset before reading (if not specificed,
  /// proceed with offset following the last read).
  /// [size] Maximum number of bytes to read (left upon the agent discretion if
  /// not specified).
  Future<ReadResult> read(
    StreamHandle handle, {
    int offset,
    int size,
  }) async {
    Map parameters = {
      'handle': handle.toJson(),
    };
    if (offset != null) {
      parameters['offset'] = offset;
    }
    if (size != null) {
      parameters['size'] = size;
    }
    Map result = await _client.send('IO.read', parameters);
    return new ReadResult.fromJson(result);
  }

  /// Close the stream, discard any temporary backing storage.
  /// [handle] Handle of the stream to close.
  Future close(
    StreamHandle handle,
  ) async {
    Map parameters = {
      'handle': handle.toJson(),
    };
    await _client.send('IO.close', parameters);
  }

  /// Return UUID of Blob object specified by a remote object id.
  /// [objectId] Object id of a Blob object wrapper.
  /// Return: UUID of the specified Blob.
  Future<String> resolveBlob(
    runtime.RemoteObjectId objectId,
  ) async {
    Map parameters = {
      'objectId': objectId.toJson(),
    };
    Map result = await _client.send('IO.resolveBlob', parameters);
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

  ReadResult({
    this.base64Encoded,
    @required this.data,
    @required this.eof,
  });

  factory ReadResult.fromJson(Map json) {
    return new ReadResult(
      base64Encoded:
          json.containsKey('base64Encoded') ? json['base64Encoded'] : null,
      data: json['data'],
      eof: json['eof'],
    );
  }
}

/// This is either obtained from another method or specifed as
/// `blob:&lt;uuid&gt;` where `&lt;uuid&gt` is an UUID of a Blob.
class StreamHandle {
  final String value;

  StreamHandle(this.value);

  factory StreamHandle.fromJson(String value) => new StreamHandle(value);

  String toJson() => value;

  bool operator ==(other) => other is StreamHandle && other.value == value;

  int get hashCode => value.hashCode;

  String toString() => value.toString();
}
