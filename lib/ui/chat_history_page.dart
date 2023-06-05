import 'package:chat_to_me/constants.dart';
import 'package:chat_to_me/logic/local/chat_history_database.dart';
import 'package:chat_to_me/logic/model/chat_history.dart';
import 'package:chat_to_me/utils.dart';
import 'package:flutter/material.dart';

final _chatHistoryListKey = GlobalKey<_ChatHistoryListViewWidgetState>();

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  AlertDialog buildRemoveAllDialog(BuildContext context) => AlertDialog(
        title: const Text("Are you sure you wanna remove your all histories?"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("No"),
          ),
          TextButton(
              onPressed: () {
                _chatHistoryListKey.currentState!.removeAll().then((value) {
                  if (mounted) Navigator.pop(context);
                });
              },
              child: const Text("OK")),
        ],
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Chat History"),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(context: context, builder: buildRemoveAllDialog);
              },
              tooltip: "Clear all",
              icon: const Icon(Icons.clear_all),
            )
          ],
        ),
        body: ChatHistoryListViewWidget(key: _chatHistoryListKey),
      );
}

class ChatHistoryListViewWidget extends StatefulWidget {
  const ChatHistoryListViewWidget({required Key key}) : super(key: key);

  @override
  State<ChatHistoryListViewWidget> createState() =>
      _ChatHistoryListViewWidgetState();
}

class _ChatHistoryListViewWidgetState extends State<ChatHistoryListViewWidget> {
  _ChatHistoryListViewWidgetState() {
    BaseChatHistoryDatabase.singleton().chats.allChatHistory.then((value) {
      setState(() {
        _data = value;
      });
    });
  }

  List<ChatHistory> _data = [];

  Future<void> removeAll() async {
    await BaseChatHistoryDatabase.singleton().deleteAllChat();
    setState(() {
      _data.clear();
    });
  }

  Future<void> remove(int id, [int? index]) async {
    await BaseChatHistoryDatabase.singleton().deleteChatById(id);
    setState(() {
      if (index != null) {
        _data.removeAt(index);
      } else {
        _data.removeWhere((element) => element.id == id);
      }
    });
  }

  AlertDialog buildReloadDialog(BuildContext context, int id) => AlertDialog(
        title: const Text("Are you sure you wanna load your previous chat?"),
        content: const Text(
            "Don't worry! Your previous chat will be saved. But make sure AI has already answered."),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              BaseChatHistoryDatabase.singleton()
                  .detailed
                  .load(id)
                  .then((List<DetailedChatHistory> histories) {
                if (mounted) Navigator.pop(context); // pop dialog
                if (mounted) {
                  Navigator.pop(context, <String, dynamic>{
                    HISTORIES_TO_CHAT_PARAM: histories,
                    HISTORY_ID_TO_CHAT_PARAM: id,
                  }); // pop history
                }
              });
            },
            child: const Text("OK"),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    if (_data.isNotEmpty) {
      return ListView.builder(
        itemCount: _data.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            _data[index].content,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          subtitle: Text(
            _data[index].dateTime.localFormat(),
          ),
          leading: const Icon(Icons.chat_outlined),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            showDialog(
                context: context,
                builder: (context) =>
                    buildReloadDialog(context, _data[index].id!));
          },
        ),
      );
    } else {
      return Center(
        child: Text(
          "Nothing here...",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      );
    }
  }
}
