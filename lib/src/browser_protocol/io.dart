/// Input/Output operations for streams produced by DevTools.

import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';

class IOManager {
  final Session _client;

  IOManager(this._client);

  /// Read a chunk of the stream
  /// [handle] Handle of the stream to read.
  /// [offset] Seek to the specified offset before reading (if not specificed, proceed with offset following the last read).
  /// [size] Maximum number of bytes to read (left upon the agent discretion if not specified).
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
    await _client.send('IO.read', parameters);
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
}

class ReadResult {
  /// Data that were read.
  final String data;

  /// Set if the end-of-file condition occured while reading.
  final bool eof;

  ReadResult({
    @required this.data,
    @required this.eof,
  });

  factory ReadResult.fromJson(Map json) {
    return new ReadResult(
      data: json['data'],
      eof: json['eof'],
    );
  }
}

class StreamHandle {
  final String value;

  StreamHandle(this.value);

  factory StreamHandle.fromJson(String value) => new StreamHandle(value);

  String toJson() => value;
}
