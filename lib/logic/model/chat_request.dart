import 'dart:convert';

import 'basic_model.dart';

class Messages {
  final List<Map<String, dynamic>> _messages = [];

  List<Map<String, dynamic>> get all => _messages;

  void addSystem(String text) {
    _messages.add({
      "role": Role.system.name,
      "content": text,
    });
  }

  void addUser(String text, [String? name]) {
    _messages.add({
      "role": Role.user.name,
      "content": text,
      if (name != null) "name": name,
    });
  }

  void addAI(String text) {
    _messages.add({
      "role": Role.assistant.name,
      "content": text,
    });
  }

  String toJsonFormat() => jsonEncode(_messages);

  void clear() => _messages.clear();
}
