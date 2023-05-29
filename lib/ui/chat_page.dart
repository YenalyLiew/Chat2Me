import 'dart:developer';

import 'package:chat_to_me/logic/model/chat_request.dart' as chat_request;
import 'package:chat_to_me/logic/model/chat_response.dart' as chat_response;
import 'package:chat_to_me/logic/network/openai_request.dart';
import 'package:chat_to_me/ui/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:async/async.dart';

import '../logic/model/basic_model.dart';
import '../utils.dart';
import 'chat_list_tile.dart';

final messages = chat_request.Messages.singleton();

final _inputTextFieldKey = GlobalKey<InputTextFieldState>();
final _chatListKey = GlobalKey<ChatListViewState>();
final _chatListFabKey = GlobalKey<ChatListFabState>();

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: setAppNameArtTitle(),
          actions: <Widget>[
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
        body: Column(children: <Widget>[
          Expanded(
            child: Stack(children: [
              ChatListViewWidget(key: _chatListKey),
              Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ChatListFabWidget(key: _chatListFabKey),
                ),
              )
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InputTextFieldWidget(key: _inputTextFieldKey),
          ),
        ]),
      );
}

class ChatListFabWidget extends StatefulWidget {
  const ChatListFabWidget({required Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ChatListFabState();
}

class ChatListFabState extends State<ChatListFabWidget> {
  bool _showFab = true;
  final _duration = const Duration(milliseconds: 100);

  void showFab(bool show) {
    setState(() {
      _showFab = show;
    });
  }

  Widget setSpacingForPlatform() => SizedBox(
        height:
            Theme.of(context).platform != TargetPlatform.android ? 8.0 : 0.0,
      );

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        duration: _duration,
        opacity: _showFab ? 1.0 : 0.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.small(
              onPressed: _chatListKey.currentState!.animateScrollToTop,
              child: const Icon(Icons.upload_rounded),
            ),
            setSpacingForPlatform(),
            FloatingActionButton.small(
              child: const Icon(Icons.refresh),
              onPressed: () {
                final dialog = AlertDialog(
                    title: const Text("Are you sure to start a new chat?"),
                    content: const Text(
                      "The previous chat will be saved in history. (Not implemented yet UwU)",
                    ),
                    actions: [
                      TextButton(
                        onPressed: Navigator.of(context).pop,
                        child: const Text("No"),
                      ),
                      TextButton(
                          onPressed: () {
                            // TODO: save it in db.
                            Navigator.pop(context);
                            _chatListKey.currentState!
                                .modifyList((list) => list.clear());
                            _inputTextFieldKey.currentState!
                              ..clearText()
                              ..clearFocus()
                              ..setSendingState(false)
                              ..cancelResponse();
                            messages.clear();
                          },
                          child: const Text("Yes")),
                    ]);
                showDialog(context: context, builder: (_) => dialog);
              },
            ),
          ],
        ),
      );
}

class ChatListViewWidget extends StatefulWidget {
  const ChatListViewWidget({required Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ChatListViewState();
}

class ChatListViewState extends State<ChatListViewWidget> {
  final _scrollDuration = const Duration(milliseconds: 400);
  final _controller = ScrollController();

  final List<ChatListItem> _list = [];

  void modifyList(void Function(List<ChatListItem> list) action) {
    setState(() {
      action(_list);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _inputTextFieldKey.currentState!.clearFocus();
    });
    _controller.addListener(() {
      switch (_controller.position.userScrollDirection) {
        case ScrollDirection.forward:
          _chatListFabKey.currentState!.showFab(true);
          break;
        case ScrollDirection.reverse:
          _chatListFabKey.currentState!.showFab(false);
          break;
        default:
          break;
      }
    });
  }

  void animateScrollToTop() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.animateTo(_controller.position.minScrollExtent,
          duration: _scrollDuration, curve: Curves.fastOutSlowIn);
    });
  }

  void animateScrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.animateTo(_controller.position.maxScrollExtent,
          duration: _scrollDuration, curve: Curves.fastOutSlowIn);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) => _list.isNotEmpty
      ? ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: _list.length,
          controller: _controller,
          itemBuilder: (context, index) {
            ChatListItem item = _list[index];
            return ChatListTile(item: item);
          },
        )
      : Center(
          child: Text(
            "Start your conversation!",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
}

class InputTextFieldWidget extends StatefulWidget {
  const InputTextFieldWidget({required Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => InputTextFieldState();
}

class InputTextFieldState extends State<InputTextFieldWidget> {
  late final _controller = TextEditingController();
  late final _focusNode = FocusNode();

  CancelableOperation<chat_response.AIChatResponse?>? _cancelableResponse;
  bool _isSending = false;

  @override
  void dispose() {
    super.dispose();
    _cancelableResponse?.cancel();
    _controller.dispose();
    _focusNode.dispose();
  }

  void clearFocus() {
    if (_focusNode.hasFocus) _focusNode.unfocus();
  }

  void clearText() => _controller.clear();

  void setSendingState(bool send) => setState(() {
        _isSending = send;
      });

  void cancelResponse() => _cancelableResponse?.cancel();

  void waitSending() {
    late String text;
    setState(() {
      messages.addUser(text = _controller.text);
      _chatListKey.currentState!.modifyList((list) => list.add(UserChatListItem(
            text: text,
          )));
      clearText();
      _isSending = true;
      _chatListKey.currentState!.animateScrollToBottom();
    });
    _cancelableResponse = CancelableOperation.fromFuture(
      getAIChatResponse(
        model: AIModel.gpt3_5Turbo,
        messages: messages,
      ),
      onCancel: () {
        log("Chat Response has been canceled.", name: "ChatResponse");
      },
    );
    _cancelableResponse?.value.then((response) {
      if (response == null) return;
      if (response is chat_response.Success) {
        messages.addAI(response.getFirstChoice().message.content);
      }
      setState(() {
        _isSending = false;
        _chatListKey.currentState!.modifyList((list) {
          list.add(AIChatListItem(
              name: AIModel.gpt3_5Turbo.name, response: response));
        });
      });
      _chatListKey.currentState!.animateScrollToBottom();
    }).catchError((err) {
      setState(() {
        _isSending = false;
        _chatListKey.currentState!.modifyList((list) {
          list.add(AIChatListItem(
              name: AIModel.gpt3_5Turbo.name, error: err.toString()));
        });
      });
      _chatListKey.currentState!.animateScrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) => TextField(
        minLines: 1,
        maxLines: 10,
        focusNode: _focusNode,
        controller: _controller,
        decoration: InputDecoration(
            hintText: "Say something...",
            hintStyle: TextStyle(color: Colors.grey.shade600),
            suffixIcon: _isSending
                ? Transform.scale(
                    scale: 0.4,
                    child: const CircularProgressIndicator(),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        clearFocus();
                        waitSending();
                      } else {
                        context
                            .showFloatingSnackBar('Message cannot be empty!');
                      }
                    },
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
