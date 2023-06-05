import 'dart:developer';

import 'package:chat_to_me/logic/local/shared_preferences.dart';
import 'package:chat_to_me/logic/model/chat_history.dart';

import 'basic_model.dart';

/// Two functions:
///
/// 1. Save chat messages for request. [_messages]
/// 2. Save chat messages to database. [_messagesForDatabase]
///
/// Use different list to save because they are a bit different.
class ChatMessages {
  // Singleton

  static const _debug = true;

  void _debugMessages() {
    if (_debug) {
      log(_messages.toString(), name: "ChatRequestMessage");
      log(_messagesForDatabase.toString(), name: "ChatMessageForDB");
    }
  }

  static ChatMessages? _messagesSingleton;

  ChatMessages._() {
    globalDirective.then((String? value) {
      if (value != null) {
        addSystem(value);
      }
    });
  }

  factory ChatMessages.singleton() => _messagesSingleton ??= ChatMessages._();

  static void removeSingleton() => _messagesSingleton = null;

  // List

  final List<Map<String, dynamic>> _messages = [];

  final List<DetailedChatHistory> _messagesForDatabase = [];

  bool _hasSystem = false;

  List<Map<String, dynamic>> get all => _messages;

  List<DetailedChatHistory> get allForDatabase => _messagesForDatabase;

  // Operation

  String? get firstUserMessage {
    try {
      return _messages.firstWhere(
        (element) => element["role"] == Role.user.name,
      )["content"];
    } catch (_) {
      return null;
    }
  }

  void addSystem(String text) {
    if (_messages.isNotEmpty) {
      var first = _messages[0];
      if (first["role"] == Role.system.name) {
        first["content"] = text;
      } else {
        _messages.insert(0, {
          "role": Role.system.name,
          "content": text,
        });
      }
    } else {
      _messages.insert(0, {
        "role": Role.system.name,
        "content": text,
      });
    }
    _hasSystem = true;
    _debugMessages();
  }

  void removeSystem() {
    if (_messages.isNotEmpty) {
      var first = _messages[0];
      if (first["role"] == Role.system.name) {
        _messages.removeAt(0);
      }
    }
    _hasSystem = false;
    _debugMessages();
  }

  void addUser(String text, {String? name, DateTime? dateTime}) {
    _messages.add({
      "role": Role.user.name,
      "content": text,
      if (name != null) "name": name,
    });
    _messagesForDatabase.add(DetailedChatHistory(
      role: Role.user,
      content: text,
      dateTime: dateTime ?? DateTime.timestamp(),
    ));
    _debugMessages();
  }

  void addAI(String text, {DateTime? dateTime}) {
    _messages.add({
      "role": Role.assistant.name,
      "content": text,
    });
    _messagesForDatabase.add(DetailedChatHistory(
      role: Role.assistant,
      content: text,
      dateTime: dateTime ?? DateTime.timestamp(),
    ));
    _debugMessages();
  }

  void addHistory(DetailedChatHistory detailedChatHistory) {
    final role = detailedChatHistory.role;
    switch (role) {
      case Role.user:
        addUser(detailedChatHistory.content,
            dateTime: detailedChatHistory.dateTime);
        break;
      case Role.assistant:
        addAI(detailedChatHistory.content,
            dateTime: detailedChatHistory.dateTime);
      default:
        throw StateError("Unreachable code.");
    }
  }

  void clear() {
    if (_hasSystem) {
      _messages.removeRange(1, _messages.length);
    } else {
      _messages.clear();
    }
    _messagesForDatabase.clear();
  }
}
