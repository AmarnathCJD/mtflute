import '../tg/tg.dart';
import 'client.dart';

enum ParticipantRole { creator, admin, member, restricted, banned, left }

class ParticipantInfo {
  final int userId;
  final ParticipantRole role;
  final String? rank;
  final int? joinDate;
  final int? promotedBy;
  final int? kickedBy;
  final ChatAdminRights? adminRights;
  final ChatBannedRights? bannedRights;
  final ChannelParticipant raw;

  ParticipantInfo({
    required this.userId,
    required this.role,
    required this.raw,
    this.rank,
    this.joinDate,
    this.promotedBy,
    this.kickedBy,
    this.adminRights,
    this.bannedRights,
  });

  factory ParticipantInfo.fromRaw(ChannelParticipant p) {
    if (p is ChannelParticipantCreator) {
      return ParticipantInfo(
        userId: p.userId,
        role: ParticipantRole.creator,
        rank: p.rank,
        adminRights: p.adminRights,
        raw: p,
      );
    }
    if (p is ChannelParticipantAdmin) {
      return ParticipantInfo(
        userId: p.userId,
        role: ParticipantRole.admin,
        rank: p.rank,
        joinDate: p.date,
        promotedBy: p.promotedBy,
        adminRights: p.adminRights,
        raw: p,
      );
    }
    if (p is ChannelParticipantBanned) {
      final peer = p.peer;
      final id = peer is PeerUser ? peer.userId : 0;
      return ParticipantInfo(
        userId: id,
        role: p.left ? ParticipantRole.left : ParticipantRole.banned,
        joinDate: p.date,
        kickedBy: p.kickedBy,
        bannedRights: p.bannedRights,
        raw: p,
      );
    }
    if (p is ChannelParticipantLeft) {
      final peer = p.peer;
      final id = peer is PeerUser ? peer.userId : 0;
      return ParticipantInfo(userId: id, role: ParticipantRole.left, raw: p);
    }
    if (p is ChannelParticipantSelf) {
      return ParticipantInfo(
        userId: p.userId,
        role: ParticipantRole.member,
        joinDate: p.date,
        raw: p,
      );
    }
    if (p is ChannelParticipantObj) {
      return ParticipantInfo(
        userId: p.userId,
        role: ParticipantRole.member,
        rank: p.rank,
        joinDate: p.date,
        raw: p,
      );
    }
    return ParticipantInfo(userId: 0, role: ParticipantRole.member, raw: p);
  }
}

extension ParticipantsHelpers on MtpClient {
  Stream<ParticipantInfo> iterParticipants(
    InputChannel channel, {
    ParticipantRole? filterRole,
    String? search,
    int batchSize = 200,
    int? limit,
  }) async* {
    ChannelParticipantsFilter filter;
    if (search != null && search.isNotEmpty) {
      filter = ChannelParticipantsSearch(q: search);
    } else {
      switch (filterRole) {
        case ParticipantRole.admin:
        case ParticipantRole.creator:
          filter = ChannelParticipantsAdmins();
          break;
        case ParticipantRole.banned:
          filter = ChannelParticipantsBanned(q: '');
          break;
        case ParticipantRole.restricted:
          filter = ChannelParticipantsKicked(q: '');
          break;
        default:
          filter = ChannelParticipantsRecent();
      }
    }

    var offset = 0;
    var yielded = 0;

    while (true) {
      final r = await invoke(
        ChannelsGetParticipantsRequest(
          channel: channel,
          filter: filter,
          offset: offset,
          limit: batchSize,
          hash: 0,
        ),
      );
      if (r is! ChannelsChannelParticipantsObj) return;

      cache.updateFromUsers(r.users);
      cache.updateFromChats(r.chats);

      if (r.participants.isEmpty) return;

      for (final p in r.participants) {
        final info = ParticipantInfo.fromRaw(p);
        if (filterRole != null &&
            filterRole != ParticipantRole.creator &&
            info.role != filterRole) {
          if (!(filterRole == ParticipantRole.admin &&
              info.role == ParticipantRole.creator)) {
            continue;
          }
        }
        yield info;
        yielded++;
        if (limit != null && yielded >= limit) return;
      }

      offset += r.participants.length;
      if (offset >= r.count) return;
    }
  }

  Future<List<ParticipantInfo>> getAdmins(InputChannel channel) async {
    return iterParticipants(
      channel,
      filterRole: ParticipantRole.admin,
    ).toList();
  }

  Future<List<ParticipantInfo>> getBanned(InputChannel channel) async {
    return iterParticipants(
      channel,
      filterRole: ParticipantRole.banned,
    ).toList();
  }

  Future<int> getParticipantsCount(InputChannel channel) async {
    final r = await invoke(
      ChannelsGetParticipantsRequest(
        channel: channel,
        filter: ChannelParticipantsRecent(),
        offset: 0,
        limit: 1,
        hash: 0,
      ),
    );
    if (r is ChannelsChannelParticipantsObj) return r.count;
    return 0;
  }
}
