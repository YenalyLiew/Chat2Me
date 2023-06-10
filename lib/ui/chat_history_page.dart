import 'dart:developer';

import 'package:chat_to_me/constants.dart';
import 'package:chat_to_me/ui/provider/chat_history_provider.dart';
import 'package:chat_to_me/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatHistoryPage extends StatelessWidget {
  const ChatHistoryPage({super.key});

  AlertDialog buildRemoveAllDialog(BuildContext context) => AlertDialog(
        title: const Text("Are you sure you wanna remove your all histories?"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("No"),
          ),
          TextButton(
              onPressed: () async {
                await context.read<ChatHistoryProvider>().deleteAllHistory();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("OK")),
        ],
      );

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => ChatHistoryProvider(),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Chat History"),
            actions: [
              IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (_) => buildRemoveAllDialog(context));
                },
                tooltip: "Clear all",
                icon: const Icon(Icons.clear_all),
              )
            ],
          ),
          body: const ChatHistoryListViewWidget(),
        ),
      );
}

class ChatHistoryListViewWidget extends StatefulWidget {
  const ChatHistoryListViewWidget({super.key});

  @override
  State<ChatHistoryListViewWidget> createState() =>
      _ChatHistoryListViewWidgetState();
}

class _ChatHistoryListViewWidgetState extends State<ChatHistoryListViewWidget> {
  ScaffoldMessengerState? _scaffoldMessengerState;

  @override
  void initState() {
    super.initState();
    context.read<ChatHistoryProvider>().initialize();
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
            onPressed: () async {
              final histories =
                  await context.read<ChatHistoryProvider>().loadHistoryByID(id);
              if (mounted) Navigator.pop(context); // pop dialog
              if (mounted) {
                Navigator.pop(context, <String, dynamic>{
                  HISTORIES_TO_CHAT_PARAM: histories,
                  HISTORY_ID_TO_CHAT_PARAM: id,
                }); // pop history
              }
            },
            child: const Text("OK"),
          ),
        ],
      );

  Future<bool> confirmRemoveSnackBar(
      BuildContext context, int id, int index) async {
    const snackBarDuration = Duration(seconds: 3);
    final snackBar = SnackBar(
      content: const Text("Chat deleted."),
      action: SnackBarAction(
        label: "Undo",
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
      duration: snackBarDuration,
    );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final controller = ScaffoldMessenger.of(context).showSnackBar(snackBar);
    final SnackBarClosedReason reason = await controller.closed;
    log(reason.toString(), name: "SnackBarClosedReason");
    if (reason != SnackBarClosedReason.action) {
      if (mounted) {
        await context.read<ChatHistoryProvider>().deleteHistoryByID(id, index);
      }
    }
    return reason != SnackBarClosedReason.action;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessengerState = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    _scaffoldMessengerState?.hideCurrentSnackBar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final read = context.read<ChatHistoryProvider>();
    return context.watch<ChatHistoryProvider>().data.isNotEmpty
        ? ListView.builder(
            itemCount: read.data.length,
            itemBuilder: (cxt, index) => Dismissible(
              key: Key("key_${read.data[index].id!}"),
              confirmDismiss: (direction) async {
                final id = read.data[index].id!;
                if (direction == DismissDirection.endToStart) {
                  final bool confirm =
                      await confirmRemoveSnackBar(context, id, index);
                  return confirm && mounted;
                }
                return null;
              },
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.center,
                child: const ListTile(
                  trailing: Icon(Icons.delete),
                  iconColor: Colors.white,
                ),
              ),
              child: ListTile(
                title: Text(
                  read.data[index].content,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                subtitle: Text(
                  read.data[index].dateTime.localFormat(),
                ),
                leading: const Icon(Icons.article_outlined),
                trailing: const Icon(Icons.arrow_right),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) =>
                          buildReloadDialog(context, read.data[index].id!));
                },
              ),
            ),
          )
        : Center(
            child: Text(
              "Nothing here...",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          );
  }
}
