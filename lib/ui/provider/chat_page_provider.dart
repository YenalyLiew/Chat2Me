import 'dart:developer';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../utils.dart';
import '../../logic/local/chat_history_database.dart';
import '../../logic/model/basic_model.dart';
import '../../logic/model/chat_history.dart';
import '../../logic/model/chat_response.dart';
import '../../logic/network/openai_request.dart';
import '../chat_list_tile.dart';
import '../../logic/model/chat_message.dart';

class ChatPageProvider extends ChangeNotifier {
  final List<ChatListItem> chatListItem = [];

  void resetAllState() {
    isFabVisible = true;
    chatListItem.clear();
    textController.clear();
    if (textFocusNode.hasFocus) textFocusNode.unfocus();
    isSending = false;
    _temporaryCancelableAIChatResponse?.cancel();
    ChatMessages.singleton().clear();
  }

  // Text

  final textController = TextEditingController();
  final textFocusNode = FocusNode();

  // Fab

  bool _isFabVisible = true;

  bool get isFabVisible => _isFabVisible;

  set isFabVisible(bool value) {
    _isFabVisible = value;
    notifyListeners();
  }

  // Scroll

  final scrollController = ScrollController();
  final _scrollDuration = const Duration(milliseconds: 400);

  void animateScrollToTop() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.animateTo(scrollController.position.minScrollExtent,
          duration: _scrollDuration, curve: Curves.fastOutSlowIn);
    });
  }

  void animateScrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: _scrollDuration, curve: Curves.fastOutSlowIn);
    });
  }

  // Request

  bool _isSending = false;

  bool get isSending => _isSending;

  set isSending(bool value) {
    _isSending = value;
    notifyListeners();
  }

  CancelableOperation<AIChatResponse> _getCancelableAIChatResponse(
          {AIModel? aiModel}) =>
      CancelableOperation.fromFuture(
        getAIChatResponse(
          model: aiModel ?? AIModel.gpt3_5Turbo,
          messages: ChatMessages.singleton(),
        ),
        onCancel: () {
          log("Chat Response has been canceled.", name: "ChatResponse");
        },
      );

  CancelableOperation<AIChatResponse>? _temporaryCancelableAIChatResponse;

  Future<void> requestAIChatResponse(BuildContext context,
      {AIModel? aiModel}) async {
    final String text = textController.text;
    if (text.trim().isEmpty || !context.mounted) {
      context.showFloatingSnackBar('Message cannot be empty!');
      return;
    }
    addUser(text: text, dateTime: DateTime.timestamp());
    isSending = true;
    textFocusNode.unfocus();
    final response = await (_temporaryCancelableAIChatResponse =
            _getCancelableAIChatResponse(aiModel: aiModel))
        .valueOrCancellation();
    isSending = false;
    if (response is Success) {
      addAI(
        name: aiModel?.name ?? AIModel.gpt3_5Turbo.name,
        response: response,
        dateTime: DateTime.timestamp(),
      );
    } else if (response is Error) {
      addAI(
        name: aiModel?.name ?? AIModel.gpt3_5Turbo.name,
        error: response.toString(),
        dateTime: DateTime.timestamp(),
      );
    }
    _temporaryCancelableAIChatResponse = null;
  }

  void addUser({
    String name = "User",
    IconData? avatar,
    required String text,
    DateTime? dateTime,
  }) {
    ChatMessages.singleton().addUser(
      text,
      dateTime: dateTime,
    );
    chatListItem.add(UserChatListItem(
      text: text,
      dateTime: dateTime,
      name: name,
      avatar: avatar,
    ));
    textController.clear();
    notifyListeners();
    animateScrollToBottom();
  }

  void addAI({
    required String name,
    IconData? avatar,
    AIChatResponse? response,
    String? responseFromDatabase,
    String? error,
    DateTime? dateTime,
  }) {
    if (response is Success) {
      ChatMessages.singleton()
          .addAI(response.getFirstChoice().message.content, dateTime: dateTime);
    }
    chatListItem.add(AIChatListItem(
      name: name,
      avatar: avatar,
      response: response,
      responseFromDatabase: responseFromDatabase,
      error: error,
      dateTime: dateTime,
    ));
    notifyListeners();
    animateScrollToBottom();
  }

  // Database

  /// Current Chat ID if exists in database.
  int? currentID;

  Future<int?> saveMessagesToDatabase(BuildContext context, [int? id]) async {
    if (context.mounted && !context.hasDatabaseOnPlatform) {
      return null;
    }
    int? newID = await saveChatMessagesInDatabase(
      chatMessages: ChatMessages.singleton(),
      id: id ?? currentID,
      dateTime: DateTime.timestamp(),
    );
    return currentID = newID;
  }

  Future<int?> loadChatFromChatHistoryPage(BuildContext context, int? id,
      List<DetailedChatHistory> histories) async {
    int? newID = await saveMessagesToDatabase(context, id);
    resetAllState();
    for (final history in histories) {
      chatListItem.add(ChatListItem.fromHistory(history));
      ChatMessages.singleton().addHistory(history);
    }
    notifyListeners();
    return newID;
  }
}
