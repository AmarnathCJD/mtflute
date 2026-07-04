import 'dart:typed_data';
import '../crypto/mtproto_crypto.dart';
import '../tg/tg.dart';
import 'client.dart';
import 'parsing.dart';

extension HighLevelHelpers on MtpClient {
  Future<User?> getMe() async {
    final r = await invoke(UsersGetUsersRequest(id: [InputUserSelf()]));
    if (r is VectorResult) {
      final users = r.list.whereType<User>().toList();
      if (users.isNotEmpty) {
        cache.updateFromUsers(users);
        return users.first;
      }
    }
    return null;
  }

  Future<MessagesDialogs> getDialogs({
    int limit = 100,
    int offsetDate = 0,
  }) async {
    return (await invoke(
          MessagesGetDialogsRequest(
            offsetDate: offsetDate,
            offsetId: 0,
            offsetPeer: InputPeerEmpty(),
            limit: limit,
            hash: 0,
          ),
        ))
        as MessagesDialogs;
  }

  Future<MessagesMessages> getHistory({
    required InputPeer peer,
    int limit = 100,
    int offsetId = 0,
    int offsetDate = 0,
    int addOffset = 0,
  }) async {
    return (await invoke(
          MessagesGetHistoryRequest(
            peer: peer,
            offsetId: offsetId,
            offsetDate: offsetDate,
            addOffset: addOffset,
            limit: limit,
            maxId: 0,
            minId: 0,
            hash: 0,
          ),
        ))
        as MessagesMessages;
  }

  Future<MessagesMessages> getMessages({
    required InputPeer peer,
    required List<int> ids,
  }) async {
    if (peer is InputPeerChannel) {
      final inputs = ids
          .map<InputMessage>((id) => InputMessageID(id: id))
          .toList();
      return (await invoke(ChannelsGetMessagesRequest(
        channel: InputChannelObj(
          channelId: peer.channelId,
          accessHash: peer.accessHash,
        ),
        id: inputs,
      ))) as MessagesMessages;
    }
    final inputs = ids
        .map<InputMessage>((id) => InputMessageID(id: id))
        .toList();
    return (await invoke(MessagesGetMessagesRequest(id: inputs)))
        as MessagesMessages;
  }

  Future<Message?> getMessage({
    required InputPeer peer,
    required int id,
  }) async {
    final r = await getMessages(peer: peer, ids: [id]);
    List<Message> msgs = const [];
    if (r is MessagesMessagesObj) {
      msgs = r.messages;
      cache.updateFromUsers(r.users);
      cache.updateFromChats(r.chats);
    } else if (r is MessagesMessagesSlice) {
      msgs = r.messages;
      cache.updateFromUsers(r.users);
      cache.updateFromChats(r.chats);
    } else if (r is MessagesChannelMessages) {
      msgs = r.messages;
      cache.updateFromUsers(r.users);
      cache.updateFromChats(r.chats);
    }
    return msgs.isNotEmpty ? msgs.first : null;
  }

  Future<UserFull?> getFullUser(InputUser user) async {
    final r = await invoke(UsersGetFullUserRequest(id: user));
    if (r is UsersUserFullObj) {
      cache.updateFromUsers(r.users);
      cache.updateFromChats(r.chats);
      return r.fullUser;
    }
    return null;
  }

  Future<Chat?> getChat(int chatId) async {
    final r = await invoke(MessagesGetChatsRequest(id: [chatId]));
    if (r is MessagesChatsObj && r.chats.isNotEmpty) {
      cache.updateFromChats(r.chats);
      return r.chats.first;
    }
    return null;
  }

  Future<Chat?> getChannel(int channelId, int accessHash) async {
    final r = await invoke(
      ChannelsGetChannelsRequest(
        id: [InputChannelObj(channelId: channelId, accessHash: accessHash)],
      ),
    );
    if (r is MessagesChatsObj && r.chats.isNotEmpty) {
      cache.updateFromChats(r.chats);
      return r.chats.first;
    }
    return null;
  }

  Future<ContactsResolvedPeer?> resolveUsername(String username) async {
    final clean = username.replaceFirst('@', '');
    final r = await invoke(ContactsResolveUsernameRequest(username: clean));
    if (r is ContactsResolvedPeerObj) {
      cache.updateFromUsers(r.users);
      cache.updateFromChats(r.chats);
      return r;
    }
    return null;
  }

  Future<TlObject> editMessage({
    required InputPeer peer,
    required int id,
    String? text,
    ReplyMarkup? buttons,
    List<MessageEntity>? entities,
    String? parseMode,
  }) async {
    var msg = text;
    var ents = entities;
    if (msg != null && parseMode != null && ents == null) {
      final p = parseText(msg, parseMode);
      msg = p.text;
      ents = p.entities;
    }
    return invoke(
      MessagesEditMessageRequest(
        peer: peer,
        id: id,
        message: msg,
        replyMarkup: buttons,
        entities: ents,
      ),
    );
  }

  Future<TlObject> deleteMessages({
    required InputPeer peer,
    required List<int> ids,
    bool revoke = true,
  }) async {
    if (peer is InputPeerChannel) {
      return invoke(
        ChannelsDeleteMessagesRequest(
          channel: InputChannelObj(
            channelId: peer.channelId,
            accessHash: peer.accessHash,
          ),
          id: ids,
        ),
      );
    }
    return invoke(MessagesDeleteMessagesRequest(revoke: revoke, id: ids));
  }

  Future<TlObject> forwardMessages({
    required InputPeer fromPeer,
    required InputPeer toPeer,
    required List<int> ids,
    bool silent = false,
    bool dropAuthor = false,
  }) async {
    return invoke(
      MessagesForwardMessagesRequest(
        fromPeer: fromPeer,
        toPeer: toPeer,
        id: ids,
        randomId: ids
            .map(
              (_) =>
                  randomBytes(8).buffer.asByteData().getInt64(0, Endian.little),
            )
            .toList(),
        silent: silent,
        dropAuthor: dropAuthor,
      ),
    );
  }

  Future<TlObject> pinMessage({
    required InputPeer peer,
    required int id,
    bool notify = false,
    bool unpin = false,
  }) async {
    return invoke(
      MessagesUpdatePinnedMessageRequest(
        peer: peer,
        id: id,
        silent: !notify,
        unpin: unpin,
      ),
    );
  }

  Future<TlObject> markRead({required InputPeer peer, int maxId = 0}) async {
    if (peer is InputPeerChannel) {
      return invoke(
        ChannelsReadHistoryRequest(
          channel: InputChannelObj(
            channelId: peer.channelId,
            accessHash: peer.accessHash,
          ),
          maxId: maxId,
        ),
      );
    }
    return invoke(MessagesReadHistoryRequest(peer: peer, maxId: maxId));
  }

  Future<TlObject> joinChannel(InputChannel channel) async {
    return invoke(ChannelsJoinChannelRequest(channel: channel));
  }

  Future<TlObject> leaveChannel(InputChannel channel) async {
    return invoke(ChannelsLeaveChannelRequest(channel: channel));
  }

  Future<ChannelsChannelParticipant?> getParticipant(
    InputChannel channel,
    InputPeer participant,
  ) async {
    final r = await invoke(
      ChannelsGetParticipantRequest(channel: channel, participant: participant),
    );
    if (r is ChannelsChannelParticipantObj) {
      cache.updateFromUsers(r.users);
      cache.updateFromChats(r.chats);
      return r;
    }
    return null;
  }

  Future<ChannelsChannelParticipants?> getParticipants(
    InputChannel channel, {
    int limit = 200,
    int offset = 0,
    ChannelParticipantsFilter? filter,
  }) async {
    final r = await invoke(
      ChannelsGetParticipantsRequest(
        channel: channel,
        filter: filter ?? ChannelParticipantsRecent(),
        offset: offset,
        limit: limit,
        hash: 0,
      ),
    );
    if (r is ChannelsChannelParticipantsObj) {
      cache.updateFromUsers(r.users);
      cache.updateFromChats(r.chats);
      return r;
    }
    return null;
  }

  Future<TlObject> kickUser({
    required InputChannel channel,
    required InputPeer user,
  }) async {
    return invoke(
      ChannelsEditBannedRequest(
        channel: channel,
        participant: user,
        bannedRights: ChatBannedRightsObj(
          viewMessages: true,
          untilDate: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 60,
        ),
      ),
    );
  }

  Future<TlObject> banUser({
    required InputChannel channel,
    required InputPeer user,
    Duration? duration,
  }) async {
    final until = duration == null
        ? 0
        : DateTime.now().add(duration).millisecondsSinceEpoch ~/ 1000;
    return invoke(
      ChannelsEditBannedRequest(
        channel: channel,
        participant: user,
        bannedRights: ChatBannedRightsObj(
          viewMessages: true,
          sendMessages: true,
          sendMedia: true,
          sendStickers: true,
          sendGifs: true,
          sendGames: true,
          sendInline: true,
          embedLinks: true,
          sendPolls: true,
          changeInfo: true,
          inviteUsers: true,
          pinMessages: true,
          untilDate: until,
        ),
      ),
    );
  }

  Future<TlObject> unbanUser({
    required InputChannel channel,
    required InputPeer user,
  }) async {
    return invoke(
      ChannelsEditBannedRequest(
        channel: channel,
        participant: user,
        bannedRights: ChatBannedRightsObj(untilDate: 0),
      ),
    );
  }
}
