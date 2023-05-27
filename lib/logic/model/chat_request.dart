import 'dart:convert';
import 'dart:developer';

import 'package:chat_to_me/logic/local/shared_preferences.dart';

import 'basic_model.dart';

class Messages {
  void debugMessages() => log(_messages.toString(),
      time: DateTime.timestamp(), name: "ChatRequestMessage");

  static Messages? _messagesSingleton;

  Messages._() {
    globalDirective.then((String? value) {
      if (value != null) {
        addSystem(value);
      }
    });
  }

  factory Messages.singleton() => _messagesSingleton ??= Messages._();

  static void removeSingleton() => _messagesSingleton = null;

  final List<Map<String, dynamic>> _messages = [];

  List<Map<String, dynamic>> get all => _messages;

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
    debugMessages();
  }

  void removeSystem() {
    if (_messages.isNotEmpty) {
      var first = _messages[0];
      if (first["role"] == Role.system.name) {
        _messages.removeAt(0);
      }
    }
    debugMessages();
  }

  void addUser(String text, [String? name]) {
    _messages.add({
      "role": Role.user.name,
      "content": text,
      if (name != null) "name": name,
    });
    debugMessages();
  }

  void addAI(String text) {
    _messages.add({
      "role": Role.assistant.name,
      "content": text,
    });
    debugMessages();
  }

  String toJsonFormat() => jsonEncode(_messages);

  void clear() => _messages.clear();
}
