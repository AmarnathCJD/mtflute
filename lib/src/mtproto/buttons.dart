import 'dart:convert';
import 'dart:typed_data';
import '../tg/tg.dart';

class Button {
  Button._();

  static KeyboardButton text(String text) => KeyboardButtonObj(text: text);

  static KeyboardButton url(String text, String url) =>
      KeyboardButtonUrl(text: text, url: url);

  static KeyboardButton callback(String text, String data) =>
      KeyboardButtonCallback(
        text: text,
        data: Uint8List.fromList(utf8.encode(data)),
      );

  static KeyboardButton switchInline(
    String text, {
    String query = '',
    bool samePeer = false,
  }) =>
      KeyboardButtonSwitchInline(text: text, query: query, samePeer: samePeer);

  static KeyboardButton requestPhone(String text) =>
      KeyboardButtonRequestPhone(text: text);

  static KeyboardButton requestLocation(String text) =>
      KeyboardButtonRequestGeoLocation(text: text);

  static KeyboardButton game(String text) => KeyboardButtonGame(text: text);

  static KeyboardButton buy(String text) => KeyboardButtonBuy(text: text);

  static KeyboardButton userProfile(String text, int userId) =>
      KeyboardButtonUserProfile(text: text, userId: userId);

  static KeyboardButton webView(String text, String url) =>
      KeyboardButtonWebView(text: text, url: url);
}

class Keyboard {
  final List<List<KeyboardButton>> _rows = [];

  Keyboard row(List<KeyboardButton> buttons) {
    _rows.add(buttons);
    return this;
  }

  Keyboard add(KeyboardButton button) {
    if (_rows.isEmpty) _rows.add([]);
    _rows.last.add(button);
    return this;
  }

  ReplyInlineMarkup inline() => ReplyInlineMarkup(
    rows: _rows.map((r) => KeyboardButtonRowObj(buttons: r)).toList(),
  );

  ReplyKeyboardMarkup reply({
    bool resize = true,
    bool oneTime = false,
    bool selective = false,
    bool persistent = false,
  }) => ReplyKeyboardMarkup(
    resize: resize,
    singleUse: oneTime,
    selective: selective,
    persistent: persistent,
    rows: _rows.map((r) => KeyboardButtonRowObj(buttons: r)).toList(),
  );

  static ReplyInlineMarkup inlineFrom(List<List<KeyboardButton>> rows) =>
      ReplyInlineMarkup(
        rows: rows.map((r) => KeyboardButtonRowObj(buttons: r)).toList(),
      );
}

ReplyKeyboardHide removeKeyboard({bool selective = false}) =>
    ReplyKeyboardHide(selective: selective);

ReplyKeyboardForceReply forceReply({
  bool selective = false,
  String? placeholder,
  bool singleUse = false,
}) => ReplyKeyboardForceReply(
  selective: selective,
  placeholder: placeholder,
  singleUse: singleUse,
);
