import 'dart:async';
import 'dart:typed_data';

import '../tg/tg.dart';
import 'client.dart';
import 'files.dart';
import 'helpers.dart';

/// Resolved streaming metadata for one Telegram media message.
class ResolvedMedia {
  final InputFileLocation location;
  final int size;
  final String mime;
  final int dcId;
  final String? fileName;
  final int? duration;
  final Duration? maxAge;
  final DateTime resolvedAt;

  ResolvedMedia({
    required this.location,
    required this.size,
    required this.mime,
    required this.dcId,
    this.fileName,
    this.duration,
    this.maxAge,
  }) : resolvedAt = DateTime.now();

  bool get isExpired {
    if (maxAge == null) return false;
    return DateTime.now().difference(resolvedAt) > maxAge!;
  }
}

/// LRU cache of resolved media locations keyed by `(peerId, msgId)`.
///
/// Video streaming issues many range requests for the same file; each one
/// would otherwise re-fetch the source message (an extra round-trip and a
/// `file_reference` regeneration). This cache stores the resolved location
/// so all range requests share one lookup.
///
/// Entries expire after [defaultTtl] (~20h — under Telegram's 24h
/// `file_reference` window) and are transparently re-resolved on the next
/// call to [get].
class MediaLocationCache {
  final int capacity;
  final Duration defaultTtl;

  final _map = <String, ResolvedMedia>{};
  final _order = <String>[];

  MediaLocationCache({
    this.capacity = 512,
    this.defaultTtl = const Duration(hours: 20),
  });

  String _key(int peerId, int msgId) => '$peerId:$msgId';

  ResolvedMedia? get(int peerId, int msgId) {
    final k = _key(peerId, msgId);
    final entry = _map[k];
    if (entry == null) return null;
    if (entry.isExpired) {
      _map.remove(k);
      _order.remove(k);
      return null;
    }
    _order.remove(k);
    _order.add(k);
    return entry;
  }

  void put(int peerId, int msgId, ResolvedMedia media) {
    final k = _key(peerId, msgId);
    if (_map.containsKey(k)) _order.remove(k);
    _map[k] = media;
    _order.add(k);
    while (_map.length > capacity) {
      final evict = _order.removeAt(0);
      _map.remove(evict);
    }
  }

  void invalidate(int peerId, int msgId) {
    final k = _key(peerId, msgId);
    _map.remove(k);
    _order.remove(k);
  }

  void clear() {
    _map.clear();
    _order.clear();
  }

  int get length => _map.length;
}

/// Peer-id helper: extract a signed peer id from an [InputPeer] (matches the
/// convention used by [NewMessage.chatId]: channels/chats negative, users
/// positive) so message cache keys stay stable across sessions.
int peerIdOf(InputPeer p) {
  if (p is InputPeerUser) return p.userId;
  if (p is InputPeerChat) return -p.chatId;
  if (p is InputPeerChannel) return -p.channelId;
  if (p is InputPeerSelf) return 0;
  return 0;
}

extension MediaResolver on MtpClient {
  static final _defaultCache = MediaLocationCache();

  /// Shared per-process cache. Callers can override by passing their own
  /// [MediaLocationCache] into [resolveMediaByMessage] / streaming APIs.
  MediaLocationCache get mediaCache => _defaultCache;

  /// Resolves a [ResolvedMedia] for the given peer+msgId, using [cache] if
  /// present or fetching the message and extracting its media.
  ///
  /// Returns `null` if the message has no downloadable media (photo/document).
  Future<ResolvedMedia?> resolveMediaByMessage({
    required InputPeer peer,
    required int msgId,
    MediaLocationCache? cache,
    bool forceRefresh = false,
  }) async {
    cache ??= mediaCache;
    final pid = peerIdOf(peer);

    if (!forceRefresh) {
      final hit = cache.get(pid, msgId);
      if (hit != null) return hit;
    }

    final r = await getMessages(peer: peer, ids: [msgId]);
    Message? found;
    if (r is MessagesMessagesObj) {
      _updatePeerCache(this, r.users, r.chats);
      found = r.messages.isNotEmpty ? r.messages.first : null;
    } else if (r is MessagesMessagesSlice) {
      _updatePeerCache(this, r.users, r.chats);
      found = r.messages.isNotEmpty ? r.messages.first : null;
    } else if (r is MessagesChannelMessages) {
      _updatePeerCache(this, r.users, r.chats);
      found = r.messages.isNotEmpty ? r.messages.first : null;
    }
    if (found is! MessageObj) return null;

    final resolved = _mediaFromMessage(found);
    if (resolved != null) {
      cache.put(pid, msgId, resolved);
    }
    return resolved;
  }

  Stream<Uint8List> streamMessage({
    required InputPeer peer,
    required int msgId,
    MediaLocationCache? cache,
    int chunkSize = 512 * 1024,
    int? threads,
    ProgressCallback? onProgress,
  }) async* {
    final store = cache ?? mediaCache;
    final pid = peerIdOf(peer);
    final resolved = await resolveMediaByMessage(
      peer: peer,
      msgId: msgId,
      cache: store,
    );
    if (resolved == null) {
      throw StateError('message $msgId on peer $pid has no downloadable media');
    }

    Future<InputFileLocation> refresher(InputFileLocation _) async {
      store.invalidate(pid, msgId);
      final fresh = await resolveMediaByMessage(
        peer: peer,
        msgId: msgId,
        cache: store,
        forceRefresh: true,
      );
      if (fresh == null) {
        throw StateError('message $msgId lost its media on refresh');
      }
      return fresh.location;
    }

    yield* downloadStream(
      resolved.location,
      dcId: resolved.dcId,
      size: resolved.size,
      chunkSize: chunkSize,
      threads: threads,
      onProgress: onProgress,
      refreshLocation: refresher,
    );
  }

  Future<Uint8List> downloadMessageRange({
    required InputPeer peer,
    required int msgId,
    required int start,
    required int end,
    MediaLocationCache? cache,
    int chunkSize = 512 * 1024,
    int? threads,
  }) async {
    final store = cache ?? mediaCache;
    final pid = peerIdOf(peer);
    final resolved = await resolveMediaByMessage(
      peer: peer,
      msgId: msgId,
      cache: store,
    );
    if (resolved == null) {
      throw StateError('message $msgId on peer $pid has no downloadable media');
    }
    Future<InputFileLocation> refresher(InputFileLocation _) async {
      store.invalidate(pid, msgId);
      final fresh = await resolveMediaByMessage(
        peer: peer,
        msgId: msgId,
        cache: store,
        forceRefresh: true,
      );
      if (fresh == null) {
        throw StateError('message $msgId lost its media on refresh');
      }
      return fresh.location;
    }
    return downloadRange(
      resolved.location,
      start: start,
      end: end,
      dcId: resolved.dcId,
      chunkSize: chunkSize,
      threads: threads,
      refreshLocation: refresher,
    );
  }
}

void _updatePeerCache(MtpClient c, List<User> users, List<Chat> chats) {
  c.cache.updateFromUsers(users);
  c.cache.updateFromChats(chats);
}

ResolvedMedia? _mediaFromMessage(MessageObj msg) {
  final media = msg.media;
  if (media is MessageMediaDocument) {
    final d = media.document;
    if (d is DocumentObj) {
      String? name;
      int? duration;
      var mime = d.mimeType;
      for (final a in d.attributes) {
        if (a is DocumentAttributeFilename) name ??= a.fileName;
        if (a is DocumentAttributeVideo) duration ??= a.duration.toInt();
        if (a is DocumentAttributeAudio) duration ??= a.duration.toInt();
      }
      return ResolvedMedia(
        location: InputDocumentFileLocation(
          id: d.id,
          accessHash: d.accessHash,
          fileReference: d.fileReference,
          thumbSize: '',
        ),
        size: d.size,
        mime: mime,
        dcId: d.dcId,
        fileName: name,
        duration: duration,
      );
    }
  }
  if (media is MessageMediaPhoto) {
    final p = media.photo;
    if (p is PhotoObj) {
      // Pick the largest photo size that has a byte size we can request.
      PhotoSize? best;
      for (final s in p.sizes) {
        if (s is PhotoSizeObj) {
          if (best is! PhotoSizeObj || s.size > best.size) best = s;
        }
      }
      if (best is PhotoSizeObj) {
        return ResolvedMedia(
          location: InputPhotoFileLocation(
            id: p.id,
            accessHash: p.accessHash,
            fileReference: p.fileReference,
            thumbSize: best.type,
          ),
          size: best.size,
          mime: 'image/jpeg',
          dcId: p.dcId,
          fileName: 'photo_${p.id}.jpg',
        );
      }
    }
  }
  return null;
}
