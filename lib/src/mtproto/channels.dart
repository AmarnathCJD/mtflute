import '../tg/tg.dart';
import 'client.dart';

extension ChannelsHelpers on MtpClient {
  Future<MessagesChatFull?> getFullChannel(InputChannel channel) async {
    final r = await invoke(ChannelsGetFullChannelRequest(channel: channel));
    if (r is MessagesChatFullObj) {
      cache.updateFromUsers(r.users);
      cache.updateFromChats(r.chats);
      return r;
    }
    return null;
  }

  Future<TlObject> editChannelTitle({
    required InputChannel channel,
    required String title,
  }) => invoke(ChannelsEditTitleRequest(channel: channel, title: title));

  Future<TlObject> editChannelPhoto({
    required InputChannel channel,
    required InputChatPhoto photo,
  }) => invoke(ChannelsEditPhotoRequest(channel: channel, photo: photo));

  Future<TlObject> updateChannelUsername({
    required InputChannel channel,
    required String username,
  }) => invoke(
    ChannelsUpdateUsernameRequest(channel: channel, username: username),
  );

  Future<TlObject> inviteToChannel({
    required InputChannel channel,
    required List<InputUser> users,
  }) => invoke(ChannelsInviteToChannelRequest(channel: channel, users: users));

  Future<TlObject> deleteChannel(InputChannel channel) =>
      invoke(ChannelsDeleteChannelRequest(channel: channel));

  Future<TlObject> toggleSlowMode({
    required InputChannel channel,
    required int seconds,
  }) =>
      invoke(ChannelsToggleSlowModeRequest(channel: channel, seconds: seconds));

  Future<TlObject> togglePreHistoryHidden({
    required InputChannel channel,
    required bool enabled,
  }) => invoke(
    ChannelsTogglePreHistoryHiddenRequest(channel: channel, enabled: enabled),
  );

  Future<TlObject> promoteUser({
    required InputChannel channel,
    required InputUser user,
    String? rank,
    bool changeInfo = false,
    bool postMessages = false,
    bool editMessages = false,
    bool deleteMessages = false,
    bool banUsers = false,
    bool inviteUsers = false,
    bool pinMessages = false,
    bool addAdmins = false,
    bool anonymous = false,
    bool manageCall = false,
    bool manageTopics = false,
  }) => invoke(
    ChannelsEditAdminRequest(
      channel: channel,
      userId: user,
      rank: rank,
      adminRights: ChatAdminRightsObj(
        changeInfo: changeInfo,
        postMessages: postMessages,
        editMessages: editMessages,
        deleteMessages: deleteMessages,
        banUsers: banUsers,
        inviteUsers: inviteUsers,
        pinMessages: pinMessages,
        addAdmins: addAdmins,
        anonymous: anonymous,
        manageCall: manageCall,
        manageTopics: manageTopics,
      ),
    ),
  );

  Future<TlObject> demoteUser({
    required InputChannel channel,
    required InputUser user,
  }) => invoke(
    ChannelsEditAdminRequest(
      channel: channel,
      userId: user,
      rank: null,
      adminRights: ChatAdminRightsObj(),
    ),
  );

  Future<ExportedChatInvite?> exportInvite({
    required InputPeer peer,
    String? title,
    int? expireDate,
    int? usageLimit,
    bool requestNeeded = false,
  }) async {
    final r = await invoke(
      MessagesExportChatInviteRequest(
        peer: peer,
        title: title,
        expireDate: expireDate,
        usageLimit: usageLimit,
        requestNeeded: requestNeeded,
      ),
    );
    if (r is ExportedChatInvite) return r;
    return null;
  }

  Future<TlObject> editChatTitle({
    required int chatId,
    required String title,
  }) => invoke(MessagesEditChatTitleRequest(chatId: chatId, title: title));
}
