
import 'package:flutter/material.dart';

import '../../logic/local/chat_history_database.dart';
import '../../logic/model/chat_history.dart';

class GlobalProvider extends ChangeNotifier {
  final BuildContext _context;

  GlobalProvider(this._context);

  Future<int> deleteHistoryByID(int id) async {
    return await BaseChatHistoryDatabase.singleton().deleteChatById(id);
  }

  Future<({int dRows, int rows})> deleteAllHistory() async {
    return await BaseChatHistoryDatabase.singleton().deleteAllChat();
  }

  Future<List<DetailedChatHistory>> loadHistoryByID(int id) async {
    return await BaseChatHistoryDatabase.singleton().detailed.load(id);
  }
}
