import 'dart:typed_data';
import '../tg/tg.dart';
import 'client.dart';
import 'parsing.dart';

class NewMessage {
  final MtpClient client;
  final MessageObj message;
  final int chatId;
  final InputPeer peer;
  final UserObj? sender;

  NewMessage({
    required this.client,
    required this.message,
    required this.chatId,
    required this.peer,
    this.sender,
  });

  int get id => message.id;
  String get text => message.message;
  bool get isReply => message.replyTo != null;
  bool get isOutgoing => message.out;

  int get replyToMsgId {
    final reply = message.replyTo;
    if (reply is MessageReplyHeaderObj) return reply.replyToMsgId ?? 0;
    return 0;
  }

  Future<TlObject> reply(
    String text, {
    ReplyMarkup? buttons,
    String? parseMode,
    bool silent = false,
  }) => client.sendMessage(
    peer: peer,
    text: text,
    replyToMsgId: id,
    buttons: buttons,
    parseMode: parseMode,
    silent: silent,
  );

  Future<TlObject> respond(
    String text, {
    ReplyMarkup? buttons,
    String? parseMode,
    bool silent = false,
  }) => client.sendMessage(
    peer: peer,
    text: text,
    buttons: buttons,
    parseMode: parseMode,
    silent: silent,
  );

  Future<TlObject> edit(
    String text, {
    ReplyMarkup? buttons,
    String? parseMode,
  }) {
    List<MessageEntity>? entities;
    if (parseMode != null) {
      final parsed = parseText(text, parseMode);
      text = parsed.text;
      entities = parsed.entities;
    }
    return client.invoke(
      MessagesEditMessageRequest(
        peer: peer,
        id: id,
        message: text,
        replyMarkup: buttons,
        entities: entities,
      ),
    );
  }

  Future<void> delete({bool revoke = true}) async {
    if (chatId < 0) {
      await client.invoke(
        ChannelsDeleteMessagesRequest(
          channel: InputChannelObj(channelId: -chatId, accessHash: 0),
          id: [id],
        ),
      );
    } else {
      await client.invoke(
        MessagesDeleteMessagesRequest(revoke: revoke, id: [id]),
      );
    }
  }

  Future<void> markRead() async {
    if (chatId < 0) {
      await client.invoke(
        ChannelsReadHistoryRequest(
          channel: InputChannelObj(channelId: -chatId, accessHash: 0),
          maxId: id,
        ),
      );
    } else {
      await client.invoke(MessagesReadHistoryRequest(peer: peer, maxId: id));
    }
  }
}

class DeleteMessage {
  final MtpClient client;
  final int channelId;
  final List<int> messageIds;

  DeleteMessage({
    required this.client,
    required this.channelId,
    required this.messageIds,
  });
}

class InlineQuery {
  final MtpClient client;
  final UpdateBotInlineQuery update;

  InlineQuery({required this.client, required this.update});

  int get queryId => update.queryId;
  String get query => update.query;
  int get userId => update.userId;
}

class CallbackQuery {
  final MtpClient client;
  final UpdateBotCallbackQuery update;

  CallbackQuery({required this.client, required this.update});

  int get queryId => update.queryId;
  int get userId => update.userId;
  int get chatInstance => update.chatInstance;
  Uint8List? get data => update.data;

  Future<void> answer({String? message, bool alert = false}) async {
    await client.invoke(
      MessagesSetBotCallbackAnswerRequest(
        queryId: queryId,
        message: message,
        alert: alert,
        cacheTime: 0,
      ),
    );
  }
}
