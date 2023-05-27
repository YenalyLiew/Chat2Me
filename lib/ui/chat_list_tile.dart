import 'package:chat_to_me/logic/model/chat_response.dart' as chat_response;
import 'package:chat_to_me/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

const _markdownDecorationOpacity = 0.05;
const _markdownTextScaleFactor = 1.15;

class ChatListTile extends StatefulWidget {
  const ChatListTile({required this.item, super.key});

  final ChatListItem item;

  @override
  State<ChatListTile> createState() => _ChatListTileState();
}

class _ChatListTileState extends State<ChatListTile> {
  @override
  Widget build(BuildContext context) =>
      widget.item is UserChatListItem ? buildUser(context) : buildAI(context);

  Widget buildUser(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    widget.item.buildName(context),
                    Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey
                                .withOpacity(_markdownDecorationOpacity)),
                        child: widget.item.buildMessage(context)),
                  ],
                ),
              ),
            ),
            widget.item.buildAvatar(context),
          ],
        ),
      );

  Widget buildAI(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            widget.item.buildAvatar(context),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    widget.item.buildName(context),
                    Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(_markdownDecorationOpacity)),
                        child: widget.item.buildMessage(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

abstract interface class ChatListItem {
  Widget buildAvatar(BuildContext context);

  Widget buildName(BuildContext context);

  Widget buildMessage(BuildContext context);

  Widget buildOther(BuildContext context);
}

class UserChatListItem implements ChatListItem {
  String name;
  IconData? avatar;
  String? text;

  UserChatListItem({
    this.name = "User",
    this.avatar,
    this.text,
  });

  @override
  Widget buildAvatar(BuildContext context) => CircleAvatar(
        child: Icon(avatar ?? Icons.person),
      );

  @override
  Widget buildName(BuildContext context) => Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );

  @override
  Widget buildOther(BuildContext context) => Row(
        children: <Widget>[
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
        ],
      );

  @override
  Widget buildMessage(BuildContext context) => MarkdownBody(
        data: text ?? '',
        selectable: true,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          textScaleFactor: _markdownTextScaleFactor,
        ),
        onTapLink: (link, href, title) => openBrowserByLink(context, href),
      );
}

class AIChatListItem implements ChatListItem {
  String name;
  IconData? avatar;
  chat_response.AIChatResponse? response;
  String? error;

  AIChatListItem({
    required this.name,
    this.avatar,
    this.response,
    this.error,
  });

  @override
  Widget buildAvatar(BuildContext context) => CircleAvatar(
        child: Icon(avatar ?? Icons.personal_video),
      );

  @override
  Widget buildName(BuildContext context) => Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );

  @override
  Widget buildOther(BuildContext context) => Row(
        children: <Widget>[
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
        ],
      );

  @override
  Widget buildMessage(BuildContext context) {
    if (error != null) {
      return SelectableText(
        error!,
        style: const TextStyle(color: Colors.red),
      );
    }
    switch (response) {
      case chat_response.Success s:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            MarkdownBody(
              data: s.getFirstChoice().message.content,
              styleSheet:
                  MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                textScaleFactor: _markdownTextScaleFactor,
              ),
              selectable: true,
              onTapLink: (link, href, title) =>
                  openBrowserByLink(context, href),
            ),
            const SizedBox(height: 12.0),
            Text(
              ">>> Total Tokens: ${s.usage.totalTokens}",
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              ">>> ${localizeFinishReason(s.getFirstChoice().finishReason)}",
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );

      case chat_response.Error e:
        return SelectableText(
          e.toString(),
          style: const TextStyle(color: Colors.red),
        );

      default: // null
        return const Text(
          'You have not set API key yet, right?',
          style: TextStyle(color: Colors.red),
        );
    }
  }

  String localizeFinishReason(String? text) {
    switch (text) {
      case "stop":
        return "That's all UwU!";
      case "length":
        return "Token limit UwU!";
      case "content_filter":
        return "Something immoral UwU?";
      default:
        return "Incomplete or still in progress UwU!";
    }
  }
}
