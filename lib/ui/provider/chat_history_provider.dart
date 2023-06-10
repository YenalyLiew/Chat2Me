import 'package:flutter/material.dart';

import '../../logic/local/chat_history_database.dart';
import '../../logic/model/chat_history.dart';

class ChatHistoryProvider extends ChangeNotifier {
  final List<ChatHistory> data = [];

  void initialize() async {
    data.addAll(await BaseChatHistoryDatabase.singleton().chats.allChatHistory);
    notifyListeners();
  }

  Future<void> deleteAllHistory() async {
    await BaseChatHistoryDatabase.singleton().deleteAllChat();
    data.clear();
    notifyListeners();
  }

  Future<void> deleteHistoryByID(int id, [int? index]) async {
    await BaseChatHistoryDatabase.singleton().deleteChatById(id);
    if (index != null) {
      data.removeAt(index);
    } else {
      data.removeWhere((element) => element.id == id);
    }
    // DO NOT USE notifyListeners();
  }

  Future<List<DetailedChatHistory>> loadHistoryByID(int id) async {
    return await BaseChatHistoryDatabase.singleton().detailed.load(id);
  }
}
