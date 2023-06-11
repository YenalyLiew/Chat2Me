import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/local/chat_history_database.dart';
import '../../logic/model/chat_history.dart';
import 'global_provider.dart';

class ChatHistoryProvider extends ChangeNotifier {
  final BuildContext _context;
  final GlobalProvider _globalProvider;

  ChatHistoryProvider(this._context)
      : _globalProvider = _context.read<GlobalProvider>();

  final List<ChatHistory> data = [];

  void initialize() async {
    data.addAll(await BaseChatHistoryDatabase.singleton().chats.allChatHistory);
    notifyListeners();
  }

  Future<void> deleteAllHistory() async {
    await _globalProvider.deleteAllHistory();
    data.clear();
    notifyListeners();
  }

  Future<void> deleteHistoryByID(int id, [int? index]) async {
    await _globalProvider.deleteHistoryByID(id);
    if (index != null) {
      data.removeAt(index);
    } else {
      data.removeWhere((element) => element.id == id);
    }
    // DO NOT USE notifyListeners();
  }
}
