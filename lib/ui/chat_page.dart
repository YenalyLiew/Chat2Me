import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../logic/model/chat_history.dart';
import '../utils.dart';
import 'chat_list_tile.dart';
import 'provider/chat_page_provider.dart';
import 'settings_page.dart';
import 'chat_history_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  Future<void> _navigateForResult(BuildContext context) async {
    final Map<String, dynamic>? result = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const ChatHistoryPage()));
    if (result != null) {
      final bool? hasDeletedAll = result[DELETE_ALL_TO_CHAT_PARAM];
      if (hasDeletedAll == true && mounted) {
        context.read<ChatPageProvider>().currentChatHistoryID = null;
        return;
      }
      final int id = result[HISTORY_ID_TO_CHAT_PARAM];
      final List<DetailedChatHistory> histories =
          result[HISTORIES_TO_CHAT_PARAM];
      if (mounted) {
        context
            .read<ChatPageProvider>()
            .loadChatFromChatHistoryPage(id, histories);
      }
    }
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => ChatPageProvider(context),
        builder: (context, child) => Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: setAppNameArtTitle(),
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  _navigateForResult(context);
                },
                tooltip: "Chat History",
                icon: const Icon(Icons.history),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()));
                },
                tooltip: "Settings",
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          body: const Column(children: <Widget>[
            Expanded(
              child: Stack(children: [
                ChatListViewWidget(),
                Padding(
                  padding: EdgeInsets.only(right: 8.0, bottom: 8.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: ChatListFabWidget(),
                  ),
                )
              ]),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: InputTextFieldWidget(),
            ),
          ]),
        ),
      );
}

class ChatListFabWidget extends StatefulWidget {
  const ChatListFabWidget({super.key});

  @override
  State<StatefulWidget> createState() => ChatListFabState();
}

class ChatListFabState extends State<ChatListFabWidget> {
  final _duration = const Duration(milliseconds: 100);

  Widget setSpacingForPlatform() => SizedBox(
        height:
            Theme.of(context).platform != TargetPlatform.android ? 8.0 : 0.0,
      );

  AlertDialog _buildRefreshDialog(BuildContext context) => AlertDialog(
          title: const Text("Are you sure you wanna start a new chat?"),
          content: const Text(
            "The previous chat will be saved in history. (Not implemented yet UwU)",
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text("No"),
            ),
            TextButton(
                onPressed: () async {
                  final int? id = await context
                      .read<ChatPageProvider>()
                      .saveMessagesToDatabase();
                  if (mounted) context.read<ChatPageProvider>().resetAllState();
                  log(id.toString(), name: "ChatCurrentId");
                  if (mounted) {
                    context.read<ChatPageProvider>().currentChatHistoryID =
                        null;
                  }
                  if (mounted) Navigator.pop(context);
                },
                child: const Text("Yes")),
          ]);

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        duration: _duration,
        opacity: context.watch<ChatPageProvider>().isFabVisible ? 1.0 : 0.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.small(
              heroTag: "scroll_to_top",
              onPressed: context.read<ChatPageProvider>().animateScrollToTop,
              child: const Icon(Icons.upload_rounded),
            ),
            setSpacingForPlatform(),
            FloatingActionButton.small(
              heroTag: "refresh",
              child: const Icon(Icons.refresh),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) => _buildRefreshDialog(
                        context)); // Don't write it as _buildXXX.
              },
            ),
          ],
        ),
      );
}

class ChatListViewWidget extends StatefulWidget {
  const ChatListViewWidget({super.key});

  @override
  State<StatefulWidget> createState() => ChatListViewState();
}

class ChatListViewState extends State<ChatListViewWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log(state.toString(), name: "ChatPageAppLifecycleState");
    if (state == AppLifecycleState.inactive) {
      context.read<ChatPageProvider>().saveMessagesToDatabase().then((id) {
        log("Saved chat messages, id = $id", name: "ChatPageLifecycleSave");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final read = context.read<ChatPageProvider>();
    return context.watch<ChatPageProvider>().chatListItem.isNotEmpty
        ? ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: read.chatListItem.length,
            controller: read.scrollController,
            itemBuilder: (context, index) => Selector<ChatPageProvider,
                    ChatListItem>(
                selector: (context, provider) => provider.chatListItem[index],
                builder: (context, item, child) => ChatListTile(item: item)),
          )
        : Center(
            child: Text(
              "Start your conversation!",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          );
  }
}

class InputTextFieldWidget extends StatefulWidget {
  const InputTextFieldWidget({super.key});

  @override
  State<StatefulWidget> createState() => InputTextFieldState();
}

class InputTextFieldState extends State<InputTextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      minLines: 1,
      maxLines: 10,
      focusNode: context.read<ChatPageProvider>().textFocusNode,
      controller: context.read<ChatPageProvider>().textController,
      decoration: InputDecoration(
          hintText: "Say something...",
          hintStyle: TextStyle(color: Colors.grey.shade600),
          suffixIcon: context.watch<ChatPageProvider>().isSending
              ? Transform.scale(
                  scale: 0.4,
                  child: const CircularProgressIndicator(),
                )
              : IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () =>
                      context.read<ChatPageProvider>().requestAIChatResponse(),
                ),
          filled: true,
          fillColor: Theme.of(context).primaryColor.withOpacity(0.05),
          contentPadding: const EdgeInsets.only(
              top: 8.0, bottom: 8.0, left: 12.0, right: 8.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(
              color: Colors.grey.shade100,
              style: BorderStyle.none,
            ),
          )),
    );
  }
}
