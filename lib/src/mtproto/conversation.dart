import 'dart:async';
import '../tg/tg.dart';
import 'client.dart';
import 'events.dart';

class Conversation {
  final MtpClient client;
  final InputPeer peer;
  final int? fromUserId;
  final Duration timeout;
  final List<String> abortKeywords;

  NewMessage? _lastMessage;
  bool _closed = false;

  Completer<NewMessage>? _pending;
  bool Function(NewMessage)? _pendingFilter;

  void Function(NewMessage)? _routeHandler;

  Conversation({
    required this.client,
    required this.peer,
    this.fromUserId,
    this.timeout = const Duration(seconds: 60),
    this.abortKeywords = const ['/cancel', '/stop'],
  });

  NewMessage? get lastMessage => _lastMessage;
  bool get isClosed => _closed;

  void _start() {
    _routeHandler = (msg) {
      if (!_matchesPeer(msg)) return;
      if (fromUserId != null && (msg.sender?.id ?? msg.chatId) != fromUserId) {
        return;
      }
      _lastMessage = msg;
      final text = msg.text.trim();
      if (abortKeywords.contains(text)) {
        close();
        return;
      }
      final p = _pending;
      final f = _pendingFilter;
      if (p != null && !p.isCompleted) {
        if (f == null || f(msg)) {
          _pending = null;
          _pendingFilter = null;
          p.complete(msg);
        }
      }
    };
    client.onMessage(_routeHandler!);
  }

  bool _matchesPeer(NewMessage msg) {
    if (peer is InputPeerUser) {
      return msg.chatId == (peer as InputPeerUser).userId;
    }
    if (peer is InputPeerChat) {
      return msg.chatId == -(peer as InputPeerChat).chatId;
    }
    if (peer is InputPeerChannel) {
      return msg.chatId == -(peer as InputPeerChannel).channelId;
    }
    return false;
  }

  Future<NewMessage> getResponse({
    Duration? timeout,
    bool Function(NewMessage)? filter,
  }) async {
    if (_closed) throw StateError('conversation closed');
    final c = Completer<NewMessage>();
    _pending = c;
    _pendingFilter = filter;
    return c.future.timeout(
      timeout ?? this.timeout,
      onTimeout: () {
        _pending = null;
        _pendingFilter = null;
        throw TimeoutException(
          'conversation: no response within ${timeout ?? this.timeout}',
        );
      },
    );
  }

  Future<TlObject> respond(
    String text, {
    ReplyMarkup? buttons,
    String? parseMode,
  }) => client.sendMessage(
    peer: peer,
    text: text,
    buttons: buttons,
    parseMode: parseMode,
  );

  Future<TlObject> reply(
    String text, {
    ReplyMarkup? buttons,
    String? parseMode,
  }) {
    final replyTo = _lastMessage?.id;
    return client.sendMessage(
      peer: peer,
      text: text,
      replyToMsgId: replyTo,
      buttons: buttons,
      parseMode: parseMode,
    );
  }

  Future<NewMessage> ask(
    String text, {
    Duration? timeout,
    ReplyMarkup? buttons,
    String? parseMode,
  }) async {
    await respond(text, buttons: buttons, parseMode: parseMode);
    return getResponse(timeout: timeout);
  }

  void close() {
    if (_closed) return;
    _closed = true;
    final p = _pending;
    if (p != null && !p.isCompleted) {
      _pending = null;
      _pendingFilter = null;
      p.completeError(StateError('conversation closed'));
    }
    if (_routeHandler != null) {
      client.removeMessageHandler(_routeHandler!);
      _routeHandler = null;
    }
  }
}

extension ConversationExt on MtpClient {
  Conversation conversation(
    InputPeer peer, {
    int? fromUserId,
    Duration timeout = const Duration(seconds: 60),
    List<String> abortKeywords = const ['/cancel', '/stop'],
  }) {
    final conv = Conversation(
      client: this,
      peer: peer,
      fromUserId: fromUserId,
      timeout: timeout,
      abortKeywords: abortKeywords,
    );
    conv._start();
    return conv;
  }
}
