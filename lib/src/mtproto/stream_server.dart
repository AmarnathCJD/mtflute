import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../tg/tg.dart';
import 'client.dart';
import 'dc_migrate.dart';
import 'files.dart';
import 'media_cache.dart';

/// Serves Telegram files as byte-range HTTP URLs backed by a chunk cache and
/// parallel workers.
///
/// Two entry points:
///
/// - [publish] — you already have an `InputFileLocation` + size + dc.
/// - [publishMessage] — you have a `(peer, msgId)`; the server resolves the
///   location via [MediaLocationCache] (and re-resolves automatically when
///   `file_reference` expires).
///
/// Feed the returned URL to any HTTP-aware player (Flutter `mediakit`,
/// `video_player`, `<video>`, ExoPlayer). The server responds to `Range`
/// requests with `206 Partial Content` so seeking works out of the box.
///
/// ```dart
/// final server = TelegramFileStreamServer(client);
/// await server.start();
/// await server.warmup(dcId: 4, workers: 4); // optional
/// final url = await server.publishMessage(peer: peer, msgId: msgId);
/// // Player().open(Media(url));
/// ```
class TelegramFileStreamServer {
  final MtpClient client;
  final InternetAddress bindAddress;
  final int chunkSize;

  /// How many chunks to hold in memory per published entry. Chosen to cover
  /// typical player look-back (previous frames) + a small prefetch window.
  final int perEntryChunkCache;

  /// How many chunks to prefetch ahead of the player's current position.
  final int prefetchAhead;

  final MediaLocationCache mediaCache;

  HttpServer? _server;
  final Map<String, _Entry> _entries = {};

  TelegramFileStreamServer(
    this.client, {
    InternetAddress? bindAddress,
    this.chunkSize = 512 * 1024,
    this.perEntryChunkCache = 16,
    this.prefetchAhead = 4,
    MediaLocationCache? mediaCache,
  })  : bindAddress = bindAddress ?? InternetAddress.loopbackIPv4,
        mediaCache = mediaCache ?? client.mediaCache;

  /// The URL prefix the server is bound to, e.g. `http://127.0.0.1:5xxxx`.
  String? get baseUrl {
    final s = _server;
    if (s == null) return null;
    return 'http://${bindAddress.address}:${s.port}';
  }

  Future<void> start({int port = 0}) async {
    if (_server != null) return;
    _server = await HttpServer.bind(bindAddress, port, shared: false);
    _server!.autoCompress = false;
    unawaited(_accept());
  }

  /// Pre-opens `workers` sub-clients on [dcId] so the first request doesn't
  /// pay the exportAuth round-trip. Safe to call before or after [start].
  Future<void> warmup({required int dcId, int workers = 4}) async {
    final existing = client.getSendersFor(dcId).length;
    for (var i = existing + (dcId == client.dcId ? 1 : 0); i < workers; i++) {
      try {
        final w = await client.exportToDc(dcId);
        if (dcId != client.dcId || w != client) {
          client.addSenderFor(dcId, w);
        }
      } catch (_) {
        break;
      }
    }
  }

  Future<void> stop() async {
    final s = _server;
    _server = null;
    for (final e in _entries.values) {
      e.dispose();
    }
    _entries.clear();
    if (s != null) await s.close(force: true);
  }

  /// Registers a Telegram file for streaming and returns its URL.
  ///
  /// Prefer [publishMessage] when you have a chat+msgId — it caches the
  /// resolved media so repeated stream requests don't re-fetch the source
  /// message.
  String publish(
    InputFileLocation location, {
    required int size,
    String mime = 'application/octet-stream',
    int? dcId,
    String? fileName,
    String? id,
    FileReferenceRefresher? refreshLocation,
  }) {
    if (_server == null) {
      throw StateError('start() must be called before publish()');
    }
    final entryId = id ?? _randomId();
    _entries[entryId]?.dispose();
    _entries[entryId] = _Entry(
      client: client,
      location: location,
      size: size,
      mime: mime,
      dcId: dcId ?? 0,
      fileName: fileName,
      refreshLocation: refreshLocation,
      chunkSize: chunkSize,
      cacheCapacity: perEntryChunkCache,
      prefetchAhead: prefetchAhead,
    );
    return '$baseUrl/f/$entryId';
  }

  /// High-level entry point: resolves a message's media through
  /// [MediaLocationCache] and publishes it. Repeated calls for the same
  /// `(peer, msgId)` return the SAME URL and reuse the same chunk cache.
  Future<String> publishMessage({
    required InputPeer peer,
    required int msgId,
    String? id,
    String? mimeOverride,
    String? fileNameOverride,
  }) async {
    if (_server == null) {
      throw StateError('start() must be called before publishMessage()');
    }

    final pid = peerIdOf(peer);
    final entryId = id ?? 'm_${pid}_$msgId';

    // Reuse an existing entry if it's still fresh — same URL, same chunk
    // cache, no re-resolve.
    final existing = _entries[entryId];
    if (existing != null && !existing.isStale) {
      existing.touch();
      return '$baseUrl/f/$entryId';
    }

    final resolved = await client.resolveMediaByMessage(
      peer: peer,
      msgId: msgId,
      cache: mediaCache,
    );
    if (resolved == null) {
      throw StateError('message $msgId on peer $pid has no downloadable media');
    }

    // Auto-refresh: if file_reference expires mid-stream, drop the cache
    // entry and re-resolve so the next chunk gets a fresh location.
    Future<InputFileLocation> refresher(InputFileLocation _) async {
      mediaCache.invalidate(pid, msgId);
      final fresh = await client.resolveMediaByMessage(
        peer: peer,
        msgId: msgId,
        cache: mediaCache,
        forceRefresh: true,
      );
      if (fresh == null) {
        throw StateError('message $msgId lost its media on refresh');
      }
      // Update the entry's inner location so subsequent chunks use it.
      final entry = _entries[entryId];
      if (entry != null) entry.updateLocation(fresh.location);
      return fresh.location;
    }

    existing?.dispose();
    _entries[entryId] = _Entry(
      client: client,
      location: resolved.location,
      size: resolved.size,
      mime: mimeOverride ?? resolved.mime,
      dcId: resolved.dcId,
      fileName: fileNameOverride ?? resolved.fileName,
      refreshLocation: refresher,
      chunkSize: chunkSize,
      cacheCapacity: perEntryChunkCache,
      prefetchAhead: prefetchAhead,
    );
    return '$baseUrl/f/$entryId';
  }

  void unpublish(String id) {
    _entries.remove(id)?.dispose();
  }

  Future<void> _accept() async {
    final srv = _server;
    if (srv == null) return;
    await for (final req in srv) {
      unawaited(_handle(req));
    }
  }

  Future<void> _handle(HttpRequest req) async {
    try {
      _cors(req.response);
      final path = req.uri.pathSegments;
      if (req.method == 'OPTIONS') {
        req.response.statusCode = HttpStatus.noContent;
        await req.response.close();
        return;
      }
      if (path.length < 2 || path[0] != 'f') {
        req.response.statusCode = HttpStatus.notFound;
        await req.response.close();
        return;
      }
      final entry = _entries[path[1]];
      if (entry == null) {
        req.response.statusCode = HttpStatus.notFound;
        await req.response.close();
        return;
      }
      entry.touch();

      final method = req.method.toUpperCase();
      if (method != 'GET' && method != 'HEAD') {
        req.response.statusCode = HttpStatus.methodNotAllowed;
        req.response.headers.set(HttpHeaders.allowHeader, 'GET, HEAD, OPTIONS');
        await req.response.close();
        return;
      }

      final total = entry.size;
      final rangeHeader = req.headers.value(HttpHeaders.rangeHeader);
      var start = 0;
      var end = total;
      var isPartial = false;
      if (rangeHeader != null && total > 0) {
        final parsed = _parseRange(rangeHeader, total);
        if (parsed == null) {
          req.response.statusCode = HttpStatus.requestedRangeNotSatisfiable;
          req.response.headers.set(
            HttpHeaders.contentRangeHeader,
            'bytes */$total',
          );
          await req.response.close();
          return;
        }
        start = parsed.$1;
        end = parsed.$2;
        isPartial = true;
      }

      final length = end - start;
      final resp = req.response;
      resp.statusCode =
          isPartial ? HttpStatus.partialContent : HttpStatus.ok;
      resp.headers
        ..set(HttpHeaders.contentTypeHeader, entry.mime)
        ..set(HttpHeaders.acceptRangesHeader, 'bytes')
        ..set(HttpHeaders.contentLengthHeader, '$length');
      if (isPartial) {
        resp.headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes $start-${end - 1}/$total',
        );
      }
      if (entry.fileName != null) {
        resp.headers.set(
          HttpHeaders.contentDisposition,
          'inline; filename="${_headerEscape(entry.fileName!)}"',
        );
      }
      if (method == 'HEAD') {
        await resp.close();
        return;
      }

      // Stream chunks — cached chunks are handed out instantly; misses trigger
      // a fetch, and the entry pre-fetches the next N chunks in the background
      // so the player never has to wait between chunks.
      var pos = start;
      var wrote = 0;
      final wantBytes = end - start;
      var clientGone = false;
      unawaited(resp.done.then((_) {}, onError: (_) => clientGone = true));
      while (pos < end) {
        if (clientGone) return;
        Uint8List chunk;
        try {
          chunk = await entry.readChunkContaining(pos, end);
        } catch (_) {
          try { (await resp.detachSocket()).destroy(); } catch (_) {}
          return;
        }
        if (clientGone) return;
        if (chunk.isEmpty) {
          try { (await resp.detachSocket()).destroy(); } catch (_) {}
          return;
        }
        final trimmed = chunk.length + pos > end
            ? Uint8List.sublistView(chunk, 0, end - pos)
            : chunk;
        resp.add(trimmed);
        try {
          await resp.flush();
        } catch (_) {
          return;
        }
        pos += trimmed.length;
        wrote += trimmed.length;
      }
      if (wrote != wantBytes) {
        try { (await resp.detachSocket()).destroy(); } catch (_) {}
        return;
      }
      await resp.close();
    } catch (_) {
      try {
        await req.response.close();
      } catch (_) {}
    }
  }

  void _cors(HttpResponse resp) {
    resp.headers
      ..set('Access-Control-Allow-Origin', '*')
      ..set('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS')
      ..set('Access-Control-Allow-Headers', 'Range, Content-Type')
      ..set('Access-Control-Expose-Headers',
          'Content-Length, Content-Range, Accept-Ranges');
  }

  (int, int)? _parseRange(String header, int total) {
    if (!header.startsWith('bytes=')) return null;
    if (total <= 0) return null;
    final spec = header.substring(6).split(',').first.trim();
    final dash = spec.indexOf('-');
    if (dash < 0) return null;
    final startStr = spec.substring(0, dash);
    final endStr = spec.substring(dash + 1);
    int start;
    int end;
    if (startStr.isEmpty) {
      final suffix = int.tryParse(endStr);
      if (suffix == null || suffix <= 0) return null;
      start = total - suffix;
      if (start < 0) start = 0;
      end = total;
    } else {
      final s = int.tryParse(startStr);
      if (s == null || s < 0 || s >= total) return null;
      start = s;
      if (endStr.isEmpty) {
        end = total;
      } else {
        final e = int.tryParse(endStr);
        if (e == null || e < s) return null;
        end = e + 1;
        if (end > total) end = total;
      }
    }
    return (start, end);
  }

  String _headerEscape(String s) {
    return s.replaceAll('\\', r'\\').replaceAll('"', r'\"');
  }

  String _randomId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final b = List<int>.generate(12, (i) => ((now ^ (i * 131 + 7)) & 0xff));
    return base64Url.encode(b).replaceAll('=', '').substring(0, 16);
  }
}

/// One published stream. Owns a per-entry chunk cache and a prefetch queue.
///
/// The cache is an LRU keyed by chunk index (offset / chunkSize). Reads are
/// coalesced: two HTTP requests for the same chunk share a single fetch.
class _Entry {
  final MtpClient client;
  InputFileLocation location;
  final int size;
  final String mime;
  final int dcId;
  final String? fileName;
  final FileReferenceRefresher? refreshLocation;
  final int chunkSize;
  final int cacheCapacity;
  final int prefetchAhead;

  final Map<int, Uint8List> _cache = {};
  final List<int> _order = [];
  final Map<int, Future<Uint8List>> _inflight = {};
  final Set<int> _prefetchIdx = <int>{};

  DateTime lastAccess = DateTime.now();
  static const _staleAfter = Duration(hours: 2);
  bool _disposed = false;
  int _lastReadChunk = -1;

  _Entry({
    required this.client,
    required this.location,
    required this.size,
    required this.mime,
    required this.dcId,
    required this.fileName,
    required this.refreshLocation,
    required this.chunkSize,
    required this.cacheCapacity,
    required this.prefetchAhead,
  });

  bool get isStale => DateTime.now().difference(lastAccess) > _staleAfter;
  bool get isDisposed => _disposed;
  void touch() => lastAccess = DateTime.now();

  void updateLocation(InputFileLocation newLoc) {
    location = newLoc;
  }

  Future<Uint8List> readChunkContaining(int byteOffset, int end) async {
    if (_disposed) return Uint8List(0);
    final chunkIdx = byteOffset ~/ chunkSize;
    final chunkStart = chunkIdx * chunkSize;
    final offsetInChunk = byteOffset - chunkStart;

    if (_lastReadChunk >= 0 && (chunkIdx - _lastReadChunk).abs() > prefetchAhead + 2) {
      _prefetchIdx.clear();
    }
    _lastReadChunk = chunkIdx;

    final chunk = await _fetchChunk(chunkIdx);
    if (_disposed) return Uint8List(0);

    for (var i = 1; i <= prefetchAhead; i++) {
      final next = chunkIdx + i;
      if ((next * chunkSize) >= size) break;
      if (_cache.containsKey(next) || _inflight.containsKey(next)) continue;
      if (!_prefetchIdx.add(next)) continue;
      unawaited(_fetchChunk(next).catchError((_) => Uint8List(0)));
    }

    if (offsetInChunk == 0) return chunk;
    if (offsetInChunk >= chunk.length) return Uint8List(0);
    return Uint8List.sublistView(chunk, offsetInChunk);
  }

  Future<Uint8List> _fetchChunk(int chunkIdx) async {
    if (_disposed) return Uint8List(0);
    final cached = _cache[chunkIdx];
    if (cached != null) {
      _order.remove(chunkIdx);
      _order.add(chunkIdx);
      return cached;
    }
    final inflight = _inflight[chunkIdx];
    if (inflight != null) return inflight;

    final future = _reallyFetch(chunkIdx);
    _inflight[chunkIdx] = future;
    try {
      final data = await future;
      _prefetchIdx.remove(chunkIdx);
      if (!_disposed) {
        _cache[chunkIdx] = data;
        _order.add(chunkIdx);
        while (_order.length > cacheCapacity) {
          final evict = _order.removeAt(0);
          _cache.remove(evict);
        }
      }
      return data;
    } finally {
      _inflight.remove(chunkIdx);
    }
  }

  Future<Uint8List> _reallyFetch(int chunkIdx) async {
    final offset = chunkIdx * chunkSize;
    final want = (offset + chunkSize) > size ? (size - offset) : chunkSize;
    return client.downloadRange(
      location,
      start: offset,
      end: offset + want,
      dcId: dcId,
      chunkSize: chunkSize,
      refreshLocation: refreshLocation,
    );
  }

  void dispose() {
    _disposed = true;
    _prefetchIdx.clear();
    _cache.clear();
    _order.clear();
    _inflight.clear();
  }
}
