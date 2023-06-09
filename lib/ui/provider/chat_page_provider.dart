import 'dart:developer';

import 'package:async/async.dart';
import 'package:chat_to_me/ui/provider/global_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../logic/local/chat_history_database.dart';
import '../../utils.dart';
import '../../logic/model/basic_model.dart';
import '../../logic/model/chat_history.dart';
import '../../logic/model/chat_response.dart';
import '../../logic/network/openai_request.dart';
import '../chat_list_tile.dart';
import '../../logic/model/chat_message.dart';

class ChatPageProvider extends ChangeNotifier {
  final BuildContext _context;
  final GlobalProvider _globalProvider;

  ChatPageProvider(this._context)
      : _globalProvider = _context.read<GlobalProvider>() {
    scrollController.addListener(() {
      textFocusNode.unfocus();
      switch (scrollController.position.userScrollDirection) {
        case ScrollDirection.forward:
          isFabVisible = true;
          break;
        case ScrollDirection.reverse:
          isFabVisible = false;
          break;
        default:
          break;
      }
    });
  }

  /// Current Chat ID if exists in database.
  int? currentChatHistoryID;

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

  Future<void> requestAIChatResponse({AIModel? aiModel}) async {
    final String text = textController.text;
    if (text.trim().isEmpty || !_context.mounted) {
      _context.showFloatingSnackBar('Message cannot be empty!');
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

  Future<int?> loadChatFromChatHistoryPage(
      int? id, List<DetailedChatHistory> histories) async {
    int? newID = await saveMessagesToDatabase(id);
    resetAllState();
    for (final history in histories) {
      chatListItem.add(ChatListItem.fromHistory(history));
      ChatMessages.singleton().addHistory(history);
    }
    notifyListeners();
    return newID;
  }

  Future<int?> saveMessagesToDatabase([int? id]) async {
    if (_context.mounted && !_context.hasDatabaseOnPlatform) {
      return null;
    }
    int? newID = await saveChatMessagesInDatabase(
      chatMessages: ChatMessages.singleton(),
      id: id ?? currentChatHistoryID,
      dateTime: DateTime.timestamp(),
    );
    if (_context.mounted) {
      currentChatHistoryID = newID;
    }
    return newID;
  }
}
