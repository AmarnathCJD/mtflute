import '../tg/tg.dart';
import 'client.dart';

extension BotHelpers on MtpClient {
  Future<TlObject> answerCallback(
    int queryId, {
    String? message,
    bool alert = false,
    String? url,
    int cacheTime = 0,
  }) => invoke(
    MessagesSetBotCallbackAnswerRequest(
      queryId: queryId,
      message: message,
      alert: alert,
      url: url,
      cacheTime: cacheTime,
    ),
  );

  Future<TlObject> answerInline(
    int queryId,
    List<InputBotInlineResult> results, {
    bool gallery = false,
    bool private = false,
    int cacheTime = 300,
    String? nextOffset,
    InlineBotSwitchPM? switchPm,
  }) => invoke(
    MessagesSetInlineBotResultsRequest(
      queryId: queryId,
      results: results,
      gallery: gallery,
      private: private,
      cacheTime: cacheTime,
      nextOffset: nextOffset,
      switchPm: switchPm,
    ),
  );

  Future<TlObject> setCommands(
    Map<String, String> commands, {
    BotCommandScope? scope,
    String langCode = '',
  }) => invoke(
    BotsSetBotCommandsRequest(
      scope: scope ?? BotCommandScopeDefault(),
      langCode: langCode,
      commands: commands.entries
          .map((e) => BotCommandObj(command: e.key, description: e.value))
          .toList(),
    ),
  );

  Future<TlObject> resetBotCommands({
    BotCommandScope? scope,
    String langCode = '',
  }) => invoke(
    BotsResetBotCommandsRequest(
      scope: scope ?? BotCommandScopeDefault(),
      langCode: langCode,
    ),
  );

  Future<List<BotCommand>> getBotCommands({
    BotCommandScope? scope,
    String langCode = '',
  }) async {
    final r = await invoke(
      BotsGetBotCommandsRequest(
        scope: scope ?? BotCommandScopeDefault(),
        langCode: langCode,
      ),
    );
    if (r is VectorResult) return r.list.whereType<BotCommand>().toList();
    return const [];
  }

  Future<TlObject> setBotMenuButton({
    required InputUser bot,
    required BotMenuButton button,
  }) => invoke(BotsSetBotMenuButtonRequest(userId: bot, button: button));

  Future<TlObject> setBotInfo({
    String? name,
    String? about,
    String? description,
    String langCode = '',
    InputUser? bot,
  }) => invoke(
    BotsSetBotInfoRequest(
      bot: bot,
      langCode: langCode,
      name: name,
      about: about,
      description: description,
    ),
  );

  Future<TlObject> sendBotTyping({required InputPeer peer}) => invoke(
    MessagesSetTypingRequest(peer: peer, action: SendMessageTypingAction()),
  );
}
