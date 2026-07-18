import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;

import '../crypto/mtproto_crypto.dart';
import '../tg/tg.dart';
import 'client.dart';
import 'dc_migrate.dart';
import 'errors.dart';

typedef ProgressCallback = void Function(int current, int total);

/// Callback invoked when a file's stored `file_reference` has expired and the
/// caller must re-resolve the [InputFileLocation]. Return the refreshed
/// location (typically by re-fetching the message that owns the file).
typedef FileReferenceRefresher =
    Future<InputFileLocation> Function(InputFileLocation stale);

const _defaultChunkSize = 512 * 1024;
const _maxDownloadChunk = 1024 * 1024;
const _bigFileThreshold = 10 * 1024 * 1024;
const _maxWorkers = 16;
const _maxRetriesPerPart = 20;
const _pipelinePerWorker = 4;

class _WorkerPool {
  final List<MtpClient> workers;
  final List<int> _load;
  final MtpClient main;
  int _rr = 0;

  _WorkerPool(this.workers, {required this.main})
    : _load = List.filled(workers.length, 0);

  Future<MtpClient> acquire() async {
    while (true) {
      var bestIdx = -1;
      var bestLoad = 1 << 30;
      for (var k = 0; k < workers.length; k++) {
        final i = (_rr + k) % workers.length;
        if (_load[i] < _pipelinePerWorker && _load[i] < bestLoad) {
          bestLoad = _load[i];
          bestIdx = i;
        }
      }
      if (bestIdx >= 0) {
        _load[bestIdx]++;
        _rr = (bestIdx + 1) % workers.length;
        return workers[bestIdx];
      }
      await Future.delayed(const Duration(milliseconds: 5));
    }
  }

  void release(MtpClient w) {
    final idx = workers.indexOf(w);
    if (idx >= 0 && _load[idx] > 0) _load[idx]--;
  }

  Future<void> closeAll() async {}
}

int _countWorkers(int parts) {
  if (parts <= 8) return 1;
  return _maxWorkers;
}

Future<_WorkerPool> _buildPool(MtpClient main, int dcId, int count) async {
  final workers = <MtpClient>[];
  final isSameDc = dcId == main.dcId;

  if (isSameDc) workers.add(main);

  final cached = main.getSendersFor(dcId);
  for (final s in cached) {
    if (workers.length >= count) break;
    if (workers.contains(s)) continue;
    workers.add(s);
  }

  while (workers.length < count) {
    try {
      final w = await main.exportToDc(dcId);
      if (!isSameDc || w != main) main.addSenderFor(dcId, w);
      workers.add(w);
    } catch (_) {
      if (workers.isEmpty && isSameDc) workers.add(main);
      break;
    }
  }

  if (workers.isEmpty) workers.add(main);
  return _WorkerPool(workers, main: main);
}

extension FileOperations on MtpClient {
  Future<InputFile> uploadFile(
    File file, {
    String? fileName,
    int chunkSize = _defaultChunkSize,
    int? threads,
    ProgressCallback? onProgress,
  }) async {
    final size = await file.length();
    if (chunkSize <= 0 ||
        chunkSize % 1024 != 0 ||
        (chunkSize & (chunkSize - 1)) != 0 ||
        (524288 % chunkSize) != 0) {
      throw ArgumentError(
        'chunkSize must be a positive power-of-2 multiple of 1024 that divides 512KB',
      );
    }
    final name = fileName ?? file.uri.pathSegments.last;
    final fileId = _randomFileId();
    final isBig = size > _bigFileThreshold;
    final totalParts = (size / chunkSize).ceil();
    if (totalParts > 4000) {
      throw ArgumentError(
        'File too large: $totalParts parts > 4000. Use a larger chunkSize.',
      );
    }
    final raf = await file.open();

    final workers =
        threads ?? (size < _bigFileThreshold ? 1 : _countWorkers(totalParts));
    final pool = await _buildPool(this, dcId, workers);

    final completed = List<bool>.filled(totalParts, false);
    final partBytes = isBig ? null : <int, Uint8List>{};
    var uploaded = 0;
    var readLock = Future.value();

    Future<Uint8List> readPart(int partNum) async {
      final offset = partNum * chunkSize;
      final remaining = size - offset;
      final readLen = remaining < chunkSize ? remaining : chunkSize;

      final prev = readLock;
      final next = Completer<void>();
      readLock = next.future;
      await prev;
      try {
        await raf.setPosition(offset);
        return await raf.read(readLen);
      } finally {
        next.complete();
      }
    }

    Future<void> uploadPart(int partNum) async {
      final data = await readPart(partNum);
      var attempts = 0;
      while (true) {
        final worker = await pool.acquire();
        try {
          if (isBig) {
            await worker.invoke(
              UploadSaveBigFilePartRequest(
                fileId: fileId,
                filePart: partNum,
                fileTotalParts: totalParts,
                bytes: data,
              ),
            );
          } else {
            await worker.invoke(
              UploadSaveFilePartRequest(
                fileId: fileId,
                filePart: partNum,
                bytes: data,
              ),
            );
            partBytes![partNum] = data;
          }
          completed[partNum] = true;
          uploaded += data.length;
          onProgress?.call(uploaded, size);
          return;
        } on TgError catch (e) {
          if (e.isFlood && e.waitDuration != null) {
            await Future.delayed(e.waitDuration!);
            attempts++;
            if (attempts >= _maxRetriesPerPart) rethrow;
            continue;
          }
          rethrow;
        } catch (_) {
          attempts++;
          if (attempts >= _maxRetriesPerPart) rethrow;
          await Future.delayed(Duration(milliseconds: 100 * (1 << attempts)));
        } finally {
          pool.release(worker);
        }
      }
    }

    var queuePos = 0;
    final queue = List.generate(totalParts, (i) => i);
    final futures = <Future<void>>[];
    for (var i = 0; i < workers; i++) {
      futures.add(() async {
        while (true) {
          final myPart = queuePos < queue.length ? queue[queuePos++] : -1;
          if (myPart < 0) return;
          await uploadPart(myPart);
        }
      }());
    }

    Object? firstError;
    final wrapped = futures.map((f) => f.catchError((e) {
      firstError ??= e;
      return null;
    })).toList();
    await Future.wait(wrapped);
    try {
      await raf.close();
    } catch (_) {}
    await pool.closeAll();
    if (firstError != null) {
      throw firstError!;
    }

    for (var i = 0; i < totalParts; i++) {
      if (!completed[i]) {
        throw StateError('Upload incomplete at part $i');
      }
    }

    if (isBig) {
      return InputFileBig(id: fileId, parts: totalParts, name: name);
    }

    final buffer = BytesBuilder();
    for (var i = 0; i < totalParts; i++) {
      buffer.add(partBytes![i]!);
    }
    final md5Hex = crypto.md5
        .convert(buffer.toBytes())
        .bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();

    return InputFileObj(
      id: fileId,
      parts: totalParts,
      name: name,
      md5Checksum: md5Hex,
    );
  }

  /// Materializes an entire file into memory. For large files prefer
  /// [downloadStream] or [downloadToFile].
  Future<Uint8List> downloadFile(
    InputFileLocation location, {
    int dcId = 0,
    int size = 0,
    int chunkSize = _defaultChunkSize,
    int? threads,
    ProgressCallback? onProgress,
    FileReferenceRefresher? refreshLocation,
  }) async {
    final buffer = BytesBuilder();
    await for (final chunk in downloadStream(
      location,
      dcId: dcId,
      size: size,
      chunkSize: chunkSize,
      threads: threads,
      onProgress: onProgress,
      refreshLocation: refreshLocation,
    )) {
      buffer.add(chunk);
    }
    return buffer.toBytes();
  }

  /// Streams a file chunk-by-chunk in order. Ideal for wiring straight into a
  /// video player, an HTTP response, or a sink that shouldn't buffer the whole
  /// file. Uses parallel workers under the hood but yields to the consumer in
  /// order so the byte stream is coherent.
  Stream<Uint8List> downloadStream(
    InputFileLocation location, {
    int dcId = 0,
    int size = 0,
    int chunkSize = _defaultChunkSize,
    int? threads,
    ProgressCallback? onProgress,
    FileReferenceRefresher? refreshLocation,
  }) async* {
    if (chunkSize <= 0 ||
        chunkSize % 4096 != 0 ||
        chunkSize > _maxDownloadChunk ||
        (1048576 % chunkSize) != 0) {
      throw ArgumentError(
        'chunkSize must be a positive multiple of 4096 that divides 1MB (<= 1MB)',
      );
    }
    final effectiveDc = dcId == 0 ? this.dcId : dcId;
    final knownSize = size > 0;
    final totalParts = knownSize ? (size / chunkSize).ceil() : -1;

    final workers = knownSize
        ? (threads ?? _countWorkers(totalParts)).clamp(1, _maxWorkers)
        : 1;
    final pool = await _buildPool(this, effectiveDc, workers);

    var currentLocation = location;
    var activePool = pool;
    var activeDc = effectiveDc;

    Future<Uint8List> fetchChunk(int partNum) async {
      final offset = partNum * chunkSize;
      var attempts = 0;
      while (true) {
        final poolAtAcquire = activePool;
        final worker = await poolAtAcquire.acquire();
        var released = false;
        void release() {
          if (!released) {
            released = true;
            poolAtAcquire.release(worker);
          }
        }
        try {
          final result = await worker.invoke(
            UploadGetFileRequest(
              location: currentLocation,
              offset: offset,
              limit: chunkSize,
              precise: true,
            ),
          );
          if (result is UploadFileObj) return result.bytes;
          if (result is UploadFileCdnRedirect) {
            return _fetchCdnChunk(result, offset, chunkSize);
          }
          throw StateError('Unexpected download response: ${result.runtimeType}');
        } on TgError catch (e) {
          if (e.matches('FILE_REFERENCE_EXPIRED') && refreshLocation != null) {
            currentLocation = await refreshLocation(currentLocation);
            continue;
          }
          if (e.matches('FILE_MIGRATE_') && e.migrateDc != null &&
              e.migrateDc != activeDc) {
            release();
            activeDc = e.migrateDc!;
            activePool = await _buildPool(this, activeDc, workers);
            continue;
          }
          if (e.isFlood && e.waitDuration != null) {
            await Future.delayed(e.waitDuration!);
            attempts++;
            if (attempts >= _maxRetriesPerPart) rethrow;
            continue;
          }
          rethrow;
        } catch (_) {
          attempts++;
          if (attempts >= _maxRetriesPerPart) rethrow;
          final backoff = 100 * (1 << attempts.clamp(0, 6));
          await Future.delayed(Duration(milliseconds: backoff));
        } finally {
          release();
        }
      }
    }

    try {
      if (!knownSize || workers == 1) {
        var partNum = 0;
        var delivered = 0;
        while (true) {
          final chunk = await fetchChunk(partNum);
          if (chunk.isEmpty) break;
          delivered += chunk.length;
          onProgress?.call(delivered, knownSize ? size : delivered);
          yield chunk;
          if (chunk.length < chunkSize) break;
          if (knownSize && delivered >= size) break;
          partNum++;
        }
        return;
      }

      // Parallel fetch, deliver in order. Keep up to workers*pipeline chunks
      // in flight so each connection is kept busy (pipelined) rather than
      // idling between round-trips.
      final inFlightWindow = workers * _pipelinePerWorker;
      final results = List<Future<Uint8List>?>.filled(totalParts, null);
      var nextToSchedule = 0;
      var nextToYield = 0;
      var delivered = 0;

      void scheduleMore() {
        while (nextToSchedule < totalParts &&
            (nextToSchedule - nextToYield) < inFlightWindow) {
          results[nextToSchedule] = fetchChunk(nextToSchedule);
          nextToSchedule++;
        }
      }

      scheduleMore();

      while (nextToYield < totalParts) {
        final chunk = await results[nextToYield]!;
        results[nextToYield] = null;
        final isLast = nextToYield == totalParts - 1;
        nextToYield++;
        delivered += chunk.length;
        onProgress?.call(delivered, size);
        yield chunk;
        if (chunk.isEmpty) return;
        if (isLast) return;
        scheduleMore();
      }
    } finally {
      await pool.closeAll();
    }
  }

  /// Returns an arbitrary byte range `[start, end)` of a file. `end` may
  /// exceed the file length; the actual returned length is what Telegram gave.
  /// Alignment is handled internally: offsets are rounded down to the nearest
  /// chunk boundary and trimmed. Used by [TelegramFileStreamServer] to serve
  /// HTTP Range requests.
  Future<Uint8List> downloadRange(
    InputFileLocation location, {
    required int start,
    required int end,
    int dcId = 0,
    int chunkSize = _defaultChunkSize,
    int? threads,
    FileReferenceRefresher? refreshLocation,
  }) async {
    if (start < 0 || end <= start) {
      throw ArgumentError('bad range [$start,$end)');
    }
    if (chunkSize <= 0 ||
        chunkSize % 4096 != 0 ||
        chunkSize > _maxDownloadChunk ||
        (1048576 % chunkSize) != 0) {
      throw ArgumentError(
        'chunkSize must be a positive multiple of 4096 that divides 1MB (<= 1MB)',
      );
    }
    final alignedStart = start - (start % chunkSize);
    final length = end - start;
    var effectiveDc = dcId == 0 ? this.dcId : dcId;
    final chunkCount = ((end - alignedStart) + chunkSize - 1) ~/ chunkSize;
    final workers = (threads ?? _countWorkers(chunkCount)).clamp(1, _maxWorkers);
    var activePool = await _buildPool(this, effectiveDc, workers);
    var currentLocation = location;
    var refreshInFlight = Future<void>.value();

    Future<Uint8List> fetchAt(int offset) async {
      var attempts = 0;
      while (true) {
        final poolAtAcquire = activePool;
        final worker = await poolAtAcquire.acquire();
        var released = false;
        void release() {
          if (!released) { released = true; poolAtAcquire.release(worker); }
        }
        try {
          final result = await worker.invoke(
            UploadGetFileRequest(
              location: currentLocation,
              offset: offset,
              limit: chunkSize,
              precise: true,
            ),
          );
          if (result is UploadFileObj) return result.bytes;
          if (result is UploadFileCdnRedirect) {
            return _fetchCdnChunk(result, offset, chunkSize);
          }
          throw StateError('unexpected: ${result.runtimeType}');
        } on TgError catch (e) {
          if (e.matches('FILE_REFERENCE_EXPIRED') && refreshLocation != null) {
            await refreshInFlight;
            final captured = currentLocation;
            refreshInFlight = () async {
              if (identical(currentLocation, captured)) {
                currentLocation = await refreshLocation(captured);
              }
            }();
            await refreshInFlight;
            continue;
          }
          if (e.matches('FILE_MIGRATE_') && e.migrateDc != null &&
              e.migrateDc != effectiveDc) {
            release();
            effectiveDc = e.migrateDc!;
            activePool = await _buildPool(this, effectiveDc, workers);
            continue;
          }
          if (e.isFlood && e.waitDuration != null) {
            await Future.delayed(e.waitDuration!);
            attempts++;
            if (attempts >= _maxRetriesPerPart) rethrow;
            continue;
          }
          rethrow;
        } on StateError catch (e) {
          final msg = e.toString();
          final retryable = msg.contains('reconnect') ||
              msg.contains('Not connected') ||
              msg.contains('invalidated') ||
              msg.contains('timed out') ||
              msg.contains('Timeout');
          if (!retryable) rethrow;
          attempts++;
          if (attempts >= _maxRetriesPerPart) rethrow;
          await Future.delayed(
              Duration(milliseconds: (150 * (1 << attempts)).clamp(150, 4000)));
        } catch (_) {
          attempts++;
          if (attempts >= _maxRetriesPerPart) rethrow;
          await Future.delayed(
              Duration(milliseconds: (150 * (1 << attempts)).clamp(150, 4000)));
        } finally {
          release();
        }
      }
    }

    try {
      final offsets = <int>[];
      for (var pos = alignedStart; pos < end; pos += chunkSize) {
        offsets.add(pos);
      }
      final chunks = await Future.wait(offsets.map(fetchAt), eagerError: false);

      final buffer = BytesBuilder();
      for (final c in chunks) {
        buffer.add(c);
        if (c.length < chunkSize) break;
      }
      final all = buffer.toBytes();
      final headTrim = start - alignedStart;
      if (all.length <= headTrim) return Uint8List(0);
      final available = all.length - headTrim;
      final take = available < length ? available : length;
      return Uint8List.sublistView(all, headTrim, headTrim + take);
    } finally {
      await activePool.closeAll();
    }
  }

  Future<String> downloadToFile(
    InputFileLocation location,
    String path, {
    int dcId = 0,
    int size = 0,
    int chunkSize = _defaultChunkSize,
    int? threads,
    ProgressCallback? onProgress,
    FileReferenceRefresher? refreshLocation,
  }) async {
    final sink = File(path).openWrite();
    try {
      await for (final chunk in downloadStream(
        location,
        dcId: dcId,
        size: size,
        chunkSize: chunkSize,
        threads: threads,
        onProgress: onProgress,
        refreshLocation: refreshLocation,
      )) {
        sink.add(chunk);
      }
    } finally {
      await sink.flush();
      await sink.close();
    }
    return path;
  }

  Future<TlObject> sendMedia({
    required InputPeer peer,
    required InputMedia media,
    String message = '',
    int? replyToMsgId,
  }) async {
    return invoke(
      MessagesSendMediaRequest(
        peer: peer,
        media: media,
        message: message,
        randomId: _randomFileId(),
      ),
    );
  }

  Future<TlObject> sendFile({
    required InputPeer peer,
    required File file,
    String? caption,
    String? fileName,
    bool forceDocument = false,
    int? threads,
    ProgressCallback? onProgress,
  }) async {
    final uploaded = await uploadFile(
      file,
      fileName: fileName,
      threads: threads,
      onProgress: onProgress,
    );
    final name = fileName ?? file.uri.pathSegments.last;
    final mime = _guessMime(name);

    InputMedia media;
    if (!forceDocument &&
        (mime.startsWith('image/') && !mime.contains('gif'))) {
      media = InputMediaUploadedPhoto(file: uploaded);
    } else {
      media = InputMediaUploadedDocument(
        file: uploaded,
        mimeType: mime,
        attributes: [DocumentAttributeFilename(fileName: name)],
      );
    }

    return sendMedia(peer: peer, media: media, message: caption ?? '');
  }

  Future<Uint8List> _fetchCdnChunk(
    UploadFileCdnRedirect redirect,
    int offset,
    int chunkSize,
  ) async {
    final cdn = await _buildPool(this, redirect.dcId, 1);
    try {
      var attempts = 0;
      while (true) {
        final worker = await cdn.acquire();
        try {
          final r = await worker.invoke(
            UploadGetCdnFileRequest(
              fileToken: redirect.fileToken,
              offset: offset,
              limit: chunkSize,
            ),
          );
          if (r is UploadCdnFileReuploadNeeded) {
            await invoke(
              UploadReuploadCdnFileRequest(
                fileToken: redirect.fileToken,
                requestToken: r.requestToken,
              ),
            );
            continue;
          }
          if (r is UploadCdnFileObj) {
            return _decryptCdn(
              r.bytes,
              redirect.encryptionKey,
              redirect.encryptionIv,
              offset,
            );
          }
          throw StateError('unexpected cdn response: ${r.runtimeType}');
        } catch (_) {
          attempts++;
          if (attempts >= _maxRetriesPerPart) rethrow;
          await Future.delayed(
              Duration(milliseconds: 100 * (1 << attempts.clamp(0, 6))));
        } finally {
          cdn.release(worker);
        }
      }
    } finally {
      await cdn.closeAll();
    }
  }

  Uint8List _decryptCdn(
    Uint8List data,
    Uint8List key,
    Uint8List iv,
    int offset,
  ) {
    final ctr = Uint8List.fromList(iv);
    var counter = offset ~/ 16;
    for (var i = 15; i >= 12; i--) {
      ctr[i] = counter & 0xff;
      counter >>= 8;
    }
    return aesCtrDecrypt(data, key, ctr);
  }
}

int _randomFileId() {
  return randomBytes(8).buffer.asByteData().getInt64(0, Endian.little);
}

String _guessMime(String name) {
  final ext = name.split('.').last.toLowerCase();
  return switch (ext) {
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'gif' => 'image/gif',
    'webp' => 'image/webp',
    'bmp' => 'image/bmp',
    'svg' => 'image/svg+xml',
    'heic' => 'image/heic',
    'mp4' || 'm4v' => 'video/mp4',
    'mkv' => 'video/x-matroska',
    'mov' => 'video/quicktime',
    'webm' => 'video/webm',
    'avi' => 'video/x-msvideo',
    'flv' => 'video/x-flv',
    '3gp' => 'video/3gpp',
    'ts' => 'video/mp2t',
    'wmv' => 'video/x-ms-wmv',
    'mp3' => 'audio/mpeg',
    'm4a' => 'audio/mp4',
    'ogg' || 'oga' => 'audio/ogg',
    'opus' => 'audio/opus',
    'wav' => 'audio/wav',
    'flac' => 'audio/flac',
    'aac' => 'audio/aac',
    'pdf' => 'application/pdf',
    'zip' => 'application/zip',
    'rar' => 'application/vnd.rar',
    '7z' => 'application/x-7z-compressed',
    'gz' => 'application/gzip',
    'tar' => 'application/x-tar',
    'txt' => 'text/plain',
    'json' => 'application/json',
    _ => 'application/octet-stream',
  };
}

/// Reconstructs a full JPEG from a Telegram stripped-size thumbnail
/// (`photoStrippedSize.bytes`, which begins with 0x01). Telegram omits the
/// standard JPEG header and quantization/Huffman tables; this splices them
/// back in, patching the width/height bytes from the stripped payload.
Uint8List inflateStrippedThumb(Uint8List stripped) {
  if (stripped.length < 3 || stripped[0] != 0x01) {
    return stripped;
  }
  final header = Uint8List.fromList(_jpegStrippedHeader);
  header[164] = stripped[1];
  header[166] = stripped[2];
  final out = BytesBuilder();
  out.add(header);
  out.add(stripped.sublist(3));
  out.add(_jpegStrippedFooter);
  return out.toBytes();
}

const _jpegStrippedHeader = <int>[
  0xff, 0xd8, 0xff, 0xe0, 0x00, 0x10, 0x4a, 0x46, 0x49, 0x46, 0x00, 0x01,
  0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0xff, 0xdb, 0x00, 0x43,
  0x00, 0x28, 0x1c, 0x1e, 0x23, 0x1e, 0x19, 0x28, 0x23, 0x21, 0x23, 0x2d,
  0x2b, 0x28, 0x30, 0x3c, 0x64, 0x41, 0x3c, 0x37, 0x37, 0x3c, 0x7b, 0x58,
  0x5d, 0x49, 0x64, 0x91, 0x80, 0x99, 0x96, 0x8f, 0x80, 0x8c, 0x8a, 0xa0,
  0xb4, 0xe6, 0xc3, 0xa0, 0xaa, 0xda, 0xad, 0x8a, 0x8c, 0xc8, 0xff, 0xcb,
  0xda, 0xee, 0xf5, 0xff, 0xff, 0xff, 0x9b, 0xc1, 0xff, 0xff, 0xff, 0xfa,
  0xff, 0xe6, 0xfd, 0xff, 0xf8, 0xff, 0xdb, 0x00, 0x43, 0x01, 0x2b, 0x2d,
  0x2d, 0x3c, 0x35, 0x3c, 0x76, 0x41, 0x41, 0x76, 0xf8, 0xa5, 0x8c, 0xa5,
  0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8,
  0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8,
  0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8,
  0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8, 0xf8,
  0xf8, 0xf8, 0xf8, 0xf8, 0xff, 0xc0, 0x00, 0x11, 0x08, 0x00, 0x00, 0x00,
  0x00, 0x03, 0x01, 0x22, 0x00, 0x02, 0x11, 0x01, 0x03, 0x11, 0x01, 0xff,
  0xc4, 0x00, 0x1f, 0x00, 0x00, 0x01, 0x05, 0x01, 0x01, 0x01, 0x01, 0x01,
  0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03,
  0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0xff, 0xc4, 0x00, 0xb5,
  0x10, 0x00, 0x02, 0x01, 0x03, 0x03, 0x02, 0x04, 0x03, 0x05, 0x05, 0x04,
  0x04, 0x00, 0x00, 0x01, 0x7d, 0x01, 0x02, 0x03, 0x00, 0x04, 0x11, 0x05,
  0x12, 0x21, 0x31, 0x41, 0x06, 0x13, 0x51, 0x61, 0x07, 0x22, 0x71, 0x14,
  0x32, 0x81, 0x91, 0xa1, 0x08, 0x23, 0x42, 0xb1, 0xc1, 0x15, 0x52, 0xd1,
  0xf0, 0x24, 0x33, 0x62, 0x72, 0x82, 0x09, 0x0a, 0x16, 0x17, 0x18, 0x19,
  0x1a, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x34, 0x35, 0x36, 0x37, 0x38,
  0x39, 0x3a, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x53, 0x54,
  0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68,
  0x69, 0x6a, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x83, 0x84,
  0x85, 0x86, 0x87, 0x88, 0x89, 0x8a, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97,
  0x98, 0x99, 0x9a, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa,
  0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xc2, 0xc3, 0xc4,
  0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7,
  0xd8, 0xd9, 0xda, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9,
  0xea, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa, 0xff,
  0xc4, 0x00, 0x1f, 0x01, 0x00, 0x03, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
  0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03,
  0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0xff, 0xc4, 0x00, 0xb5,
  0x11, 0x00, 0x02, 0x01, 0x02, 0x04, 0x04, 0x03, 0x04, 0x07, 0x05, 0x04,
  0x04, 0x00, 0x01, 0x02, 0x77, 0x00, 0x01, 0x02, 0x03, 0x11, 0x04, 0x05,
  0x21, 0x31, 0x06, 0x12, 0x41, 0x51, 0x07, 0x61, 0x71, 0x13, 0x22, 0x32,
  0x81, 0x08, 0x14, 0x42, 0x91, 0xa1, 0xb1, 0xc1, 0x09, 0x23, 0x33, 0x52,
  0xf0, 0x15, 0x62, 0x72, 0xd1, 0x0a, 0x16, 0x24, 0x34, 0xe1, 0x25, 0xf1,
  0x17, 0x18, 0x19, 0x1a, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x35, 0x36, 0x37,
  0x38, 0x39, 0x3a, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x53,
  0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x63, 0x64, 0x65, 0x66, 0x67,
  0x68, 0x69, 0x6a, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x82,
  0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a, 0x92, 0x93, 0x94, 0x95,
  0x96, 0x97, 0x98, 0x99, 0x9a, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8,
  0xa9, 0xaa, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xc2,
  0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xd2, 0xd3, 0xd4, 0xd5,
  0xd6, 0xd7, 0xd8, 0xd9, 0xda, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8,
  0xe9, 0xea, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa, 0xff,
  0xda, 0x00, 0x0c, 0x03, 0x01, 0x00, 0x02, 0x11, 0x03, 0x11, 0x00, 0x3f,
  0x00,
];

const _jpegStrippedFooter = <int>[0xff, 0xd9];
