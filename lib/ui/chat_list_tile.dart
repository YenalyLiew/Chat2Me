import 'package:chat_to_me/logic/model/chat_response.dart' as chat_response;
import 'package:chat_to_me/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../logic/model/basic_model.dart';
import '../logic/model/chat_history.dart';

const _markdownDecorationOpacity = 0.05;
const _markdownTextScaleFactor = 1.15;
const _avatarSize = 43.0;

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
                padding: const EdgeInsets.only(
                    right: 8.0, bottom: 8.0, left: _avatarSize),
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
                padding: const EdgeInsets.only(
                    left: 8.0, bottom: 8.0, right: _avatarSize),
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

abstract class ChatListItem {
  Widget buildAvatar(BuildContext context);

  Widget buildName(BuildContext context);

  Widget buildMessage(BuildContext context);

  Widget buildOther(BuildContext context);

  static ChatListItem fromHistory(DetailedChatHistory detailedChatHistory) {
    final role = detailedChatHistory.role;
    switch (role) {
      case Role.user:
        return UserChatListItem(
          text: detailedChatHistory.content,
          dateTime: detailedChatHistory.dateTime,
        );
      case Role.assistant:
        return AIChatListItem(
          name: AIModel.gpt3_5Turbo.name,
          responseFromDatabase: detailedChatHistory.content,
          dateTime: detailedChatHistory.dateTime,
        );
      default:
        throw StateError("Unreachable code.");
    }
  }

  MarkdownBody buildMarkdownBody(BuildContext context,
          {required String text}) =>
      MarkdownBody(
        data: text,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          textScaleFactor: _markdownTextScaleFactor,
        ),
        selectable: true,
        onTapLink: (link, href, title) => openBrowserByLink(context, href),
      );

  Widget buildTipText(String tip, {String? what}) => Text(
        what == null ? ">>> $tip" : ">>> $what: $tip",
        textAlign: TextAlign.start,
        style: const TextStyle(fontSize: 12),
      );
}

class UserChatListItem extends ChatListItem {
  String name;
  IconData? avatar;
  String text;
  DateTime? dateTime;

  UserChatListItem({
    this.name = "User",
    this.avatar,
    required this.text,
    this.dateTime,
  });

  @override
  Widget buildAvatar(BuildContext context) => SizedBox(
        width: _avatarSize,
        height: _avatarSize,
        child: CircleAvatar(
          child: Icon(avatar ?? Icons.person),
        ),
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
  Widget buildMessage(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildMarkdownBody(context, text: text),
          const SizedBox(height: 12.0),
          buildTipText((dateTime ?? DateTime.timestamp()).localFormat()),
        ],
      );
}

class AIChatListItem extends ChatListItem {
  String name;
  IconData? avatar;
  chat_response.AIChatResponse? response;
  String? responseFromDatabase;
  String? error;
  DateTime? dateTime;

  AIChatListItem({
    required this.name,
    this.avatar,
    this.response,
    this.responseFromDatabase,
    this.error,
    this.dateTime,
  });

  @override
  Widget buildAvatar(BuildContext context) => SizedBox(
        width: _avatarSize,
        height: _avatarSize,
        child: CircleAvatar(
          child: Icon(avatar ?? Icons.personal_video),
        ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildMarkdownBody(context,
                text: s.getFirstChoice().message.content),
            const SizedBox(height: 12.0),
            buildTipText(s.usage.totalTokens.toString(), what: "total tokens"),
            buildTipText(localizeFinishReason(s.getFirstChoice().finishReason)),
            buildTipText((dateTime ?? DateTime.timestamp()).localFormat()),
          ],
        );

      case chat_response.Error e:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              e.toString(),
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12.0),
            buildTipText((dateTime ?? DateTime.timestamp()).localFormat()),
          ],
        );

      default: // null
        final rfd = responseFromDatabase;
        if (rfd != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildMarkdownBody(context, text: rfd),
              const SizedBox(height: 12.0),
              buildTipText((dateTime ?? DateTime.timestamp()).localFormat()),
            ],
          );
        } else {
          return const Text(
            'You have not set API key yet, right?',
            style: TextStyle(color: Colors.red),
          );
        }
    }
  }

  String localizeFinishReason(String? text) => switch (text) {
        "stop" => "That's all UwU!",
        "length" => "Token limit UwU!",
        "content_filter" => "Something immoral UwU?",
        _ => "Incomplete or still in progress UwU!",
      };
}
