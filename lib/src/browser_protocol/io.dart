/// Input/Output operations for streams produced by DevTools.

import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';
import '../runtime.dart' as runtime;

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
      parameters['offset'] = offset.toString();
    }
    if (size != null) {
      parameters['size'] = size.toString();
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

  /// Return UUID of Blob object specified by a remote object id.
  /// [objectId] Object id of a Blob object wrapper.
  /// Return: UUID of the specified Blob.
  Future<String> resolveBlob(
    runtime.RemoteObjectId objectId,
  ) async {
    Map parameters = {
      'objectId': objectId.toJson(),
    };
    await _client.send('IO.resolveBlob', parameters);
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
}

/// This is either obtained from another method or specifed as <code>blob:&lt;uuid&gt;</code> where <code>&lt;uuid&gt</code> is an UUID of a Blob.
class StreamHandle {
  final String value;

  StreamHandle(this.value);

  String toJson() => value;
}
