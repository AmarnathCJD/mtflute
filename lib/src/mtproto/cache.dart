import 'dart:convert';
import 'dart:io';
import '../tg/types.dart';

class PeerCache {
  final _users = <int, _CachedUser>{};
  final _channels = <int, _CachedChannel>{};
  final _chats = <int, int>{};
  final _usernames = <String, int>{};
  final _userLru = <int>[];
  final _channelLru = <int>[];

  int maxUsers = 100000;
  int maxChannels = 20000;

  void Function()? onDirty;

  void _dirty() => onDirty?.call();

  void _touchUser(int id) {
    _userLru.remove(id);
    _userLru.add(id);
    while (_userLru.length > maxUsers) {
      final evict = _userLru.removeAt(0);
      final removed = _users.remove(evict);
      if (removed?.username != null) {
        final key = removed!.username!.toLowerCase();
        if (_usernames[key] == evict) _usernames.remove(key);
      }
    }
  }

  void _touchChannel(int id) {
    _channelLru.remove(id);
    _channelLru.add(id);
    while (_channelLru.length > maxChannels) {
      final evict = _channelLru.removeAt(0);
      _channels.remove(evict);
    }
  }

  void updateUser(UserObj user) {
    final prev = _users[user.id];
    final incomingHash = user.accessHash ?? 0;
    final hash = incomingHash != 0
        ? incomingHash
        : (prev?.accessHash ?? 0);
    final username = user.username ?? prev?.username;
    final same = prev != null &&
        prev.accessHash == hash &&
        prev.username == username;
    if (prev?.username != null && prev!.username != username) {
      final prevKey = prev.username!.toLowerCase();
      if (_usernames[prevKey] == user.id) _usernames.remove(prevKey);
    }
    _users[user.id] = _CachedUser(
      id: user.id,
      accessHash: hash,
      username: username,
    );
    _touchUser(user.id);
    if (username != null) {
      _usernames[username.toLowerCase()] = user.id;
    }
    if (!same) _dirty();
  }

  void updateChannel(ChatObj chat, {int accessHash = 0}) {
    final prev = _channels[chat.id];
    final hash = accessHash != 0 ? accessHash : (prev?.accessHash ?? 0);
    _touchChannel(chat.id);
    if (prev != null && prev.accessHash == hash) return;
    _channels[chat.id] = _CachedChannel(id: chat.id, accessHash: hash);
    _dirty();
  }

  void updateChat(int chatId) {
    if (_chats[chatId] == chatId) return;
    _chats[chatId] = chatId;
    _dirty();
  }

  void updateFromUsers(List<User> users) {
    for (final u in users) {
      if (u is UserObj) updateUser(u);
    }
  }

  void updateFromChats(List<Chat> chats) {
    for (final c in chats) {
      if (c is Channel) {
        final prev = _channels[c.id];
        final incoming = c.accessHash ?? 0;
        final hash = incoming != 0 ? incoming : (prev?.accessHash ?? 0);
        final username = c.username;
        final hashSame = prev != null && prev.accessHash == hash;
        _channels[c.id] = _CachedChannel(id: c.id, accessHash: hash);
        _touchChannel(c.id);
        var usernameChanged = false;
        if (username != null) {
          final key = username.toLowerCase();
          if (_usernames[key] != c.id) {
            _usernames[key] = c.id;
            usernameChanged = true;
          }
        }
        if (!hashSame || usernameChanged) _dirty();
      } else if (c is ChatObj) {
        updateChat(c.id);
      }
    }
  }

  InputPeer getInputPeer(int id) {
    if (id > 0) {
      final user = _users[id];
      if (user != null) {
        return InputPeerUser(userId: user.id, accessHash: user.accessHash);
      }
    } else {
      final channelId = -id;
      final channel = _channels[channelId];
      if (channel != null) {
        return InputPeerChannel(
          channelId: channel.id,
          accessHash: channel.accessHash,
        );
      }
      if (_chats.containsKey(channelId)) {
        return InputPeerChat(chatId: channelId);
      }
    }
    throw StateError('Peer $id not found in cache');
  }

  InputUser getInputUser(int id) {
    final user = _users[id];
    if (user != null) {
      return InputUserObj(userId: user.id, accessHash: user.accessHash);
    }
    throw StateError('User $id not found in cache');
  }

  int? resolveUsername(String username) {
    return _usernames[username.toLowerCase().replaceFirst('@', '')];
  }

  int getUserAccessHash(int id) => _users[id]?.accessHash ?? 0;
  int getChannelAccessHash(int id) => _channels[id]?.accessHash ?? 0;

  Map<String, dynamic> toJson() => {
    'users': _users.map((k, v) => MapEntry('$k', v.toJson())),
    'channels': _channels.map((k, v) => MapEntry('$k', v.toJson())),
    'chats': _chats.keys.toList(),
    'usernames': _usernames,
  };

  void clear() {
    _users.clear();
    _channels.clear();
    _chats.clear();
    _usernames.clear();
    _userLru.clear();
    _channelLru.clear();
  }

  void loadJson(Map<String, dynamic> json) {
    final users = json['users'] as Map<String, dynamic>?;
    if (users != null) {
      for (final entry in users.entries) {
        final u = _CachedUser.fromJson(entry.value as Map<String, dynamic>);
        _users[u.id] = u;
        _userLru.add(u.id);
      }
    }
    final channels = json['channels'] as Map<String, dynamic>?;
    if (channels != null) {
      for (final entry in channels.entries) {
        final c = _CachedChannel.fromJson(entry.value as Map<String, dynamic>);
        _channels[c.id] = c;
        _channelLru.add(c.id);
      }
    }
    final chats = json['chats'];
    if (chats is List) {
      for (final id in chats) {
        if (id is int) _chats[id] = id;
      }
    }
    final usernames = json['usernames'] as Map<String, dynamic>?;
    if (usernames != null) {
      for (final entry in usernames.entries) {
        final v = entry.value;
        if (v is int) _usernames[entry.key] = v;
      }
    }
  }

  int get userCount => _users.length;
  int get channelCount => _channels.length;
  int get chatCount => _chats.length;

  void saveTo(String path) {
    File(path).writeAsStringSync(jsonEncode(toJson()));
  }

  void loadFrom(String path) {
    final file = File(path);
    if (!file.existsSync()) return;
    loadJson(jsonDecode(file.readAsStringSync()) as Map<String, dynamic>);
  }
}

class _CachedUser {
  final int id;
  final int accessHash;
  final String? username;
  _CachedUser({required this.id, required this.accessHash, this.username});

  Map<String, dynamic> toJson() => {
    'id': id,
    'ah': accessHash,
    if (username != null) 'un': username,
  };
  factory _CachedUser.fromJson(Map<String, dynamic> j) => _CachedUser(
    id: j['id'] as int,
    accessHash: j['ah'] as int,
    username: j['un'] as String?,
  );
}

class _CachedChannel {
  final int id;
  final int accessHash;
  _CachedChannel({required this.id, required this.accessHash});

  Map<String, dynamic> toJson() => {'id': id, 'ah': accessHash};
  factory _CachedChannel.fromJson(Map<String, dynamic> j) =>
      _CachedChannel(id: j['id'] as int, accessHash: j['ah'] as int);
}
