import 'dart:developer';

import 'package:chat_to_me/constants.dart';
import 'package:chat_to_me/logic/local/shared_preferences.dart';
import 'package:chat_to_me/logic/model/chat_request.dart' as chat_request;
import 'package:chat_to_me/ui/api_key_submit_page.dart';
import 'package:chat_to_me/utils.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              setAppNameArtTitle(),
              const Text(" Settings"),
            ],
          ),
        ),
        body: const SettingsWidget(),
      );
}

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  double? _chatTemperature;
  String? _globalDirective;

  @override
  void initState() {
    updateSettings();
    super.initState();
  }

  Future<void> updateSettings() async {
    final double? ct = await chatTemperature;
    log(ct.toString(), name: "chatTemperature");
    final String? gd = await globalDirective;
    log(gd.toString(), name: "globalDirective");
    setState(() {
      _chatTemperature = ct;
      _globalDirective = gd;
    });
  }

  AlertDialog buildClearAPIKeyDialog(BuildContext context) =>
      AlertDialog(
          title: const Text("You are going to clear your API Key!"),
          content: const Text("Are you sure to do it?"),
          actions: [
            TextButton(
              onPressed: Navigator
                  .of(context)
                  .pop,
              child: const Text("No"),
            ),
            TextButton(
                onPressed: () {
                  deleteApiKey().then((_) {
                    chat_request.Messages.removeSingleton();
                    Navigator.of(context)
                      ..pop()
                      ..pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const ApiKeySubmitPage()),
                            (route) => false,
                      );
                  });
                },
                child: const Text("Yes")),
          ]);

  AlertDialog buildChatTemperatureDialog(BuildContext context) {
    double? validTemperature(String s) {
      var parse = double.tryParse(s);
      return (parse != null && parse >= 0.0 && parse <= 2.0) ? parse : null;
    }

    final controller = TextEditingController(text: "${_chatTemperature ?? ''}");
    return AlertDialog(
      title: const Text("Set Temperature"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("What sampling temperature to use, "
                "between 0 and 2. "
                "Higher values like 0.8 will make the output more random, "
                "while lower values like 0.2 will make it more focused and deterministic."),
            const SizedBox(
              height: 16,
            ),
            TextField(
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.0))),
                labelText: "Temperature (0.0 ~ 2.0)",
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            deleteChatTemperature().then((_) {
              updateSettings();
              Navigator.pop(context);
            });
          },
          child: const Text("Reset"),
        ),
        const SizedBox(
          width: 16.0,
        ),
        TextButton(
          onPressed: Navigator
              .of(context)
              .pop,
          child: const Text("No"),
        ),
        TextButton(
          onPressed: () {
            var temp = validTemperature(controller.text);
            if (temp != null) {
              saveChatTemperature(temp).then((_) {
                updateSettings();
                Navigator.pop(context);
              });
            }
          },
          child: const Text("Yes"),
        ),
      ],
    );
  }

  AlertDialog buildGlobalDirectiveDialog(BuildContext context) {
    final controller = TextEditingController(text: _globalDirective);
    return AlertDialog(
      title: const Text("Set Global Directive"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("This is actually named \"System Role\" officially.\n"
                "In the ChatGPT API, the role \"system\" is used for system-level instructions or control. "
                "Messages with the system role are used to guide the overall behavior "
                "of the conversation or to set specific parameters of the model."),
            const SizedBox(
              height: 16,
            ),
            TextField(
              keyboardType: TextInputType.text,
              controller: controller,
              minLines: 1,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.0))),
                labelText: "Global directive",
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            deleteGlobalDirective().then((_) {
              chat_request.Messages.singleton().removeSystem();
              updateSettings();
              Navigator.pop(context);
            });
          },
          child: const Text("Reset"),
        ),
        const SizedBox(
          width: 16.0,
        ),
        TextButton(
          onPressed: Navigator
              .of(context)
              .pop,
          child: const Text("No"),
        ),
        TextButton(
          onPressed: () {
            var text = controller.text;
            if (text.isNotEmpty) {
              saveGlobalDirective(text).then((_) {
                updateSettings();
                chat_request.Messages.singleton().addSystem(text);
                Navigator.pop(context);
              });
            }
          },
          child: const Text("Yes"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) =>
      SettingsList(
          lightTheme:
          SettingsThemeData(titleTextColor: Theme
              .of(context)
              .primaryColor),
          darkTheme:
          SettingsThemeData(titleTextColor: Theme
              .of(context)
              .primaryColor),
          sections: [
            SettingsSection(
              title: const Text("Common"),
              tiles: [
                SettingsTile(
                  leading: const Icon(Icons.clear_all),
                  title: const Text("Clear API Key"),
                  onPressed: (context) {
                    showDialog(
                        context: context, builder: buildClearAPIKeyDialog);
                  },
                ),
              ],
            ),
            SettingsSection(
              title: const Text("Chat"),
              tiles: [
                SettingsTile(
                  leading: const Icon(Icons.directions),
                  title: const Text("Global directive"),
                  value: _globalDirective != null
                      ? Text(
                    _globalDirective!,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  )
                      : null,
                  onPressed: (context) {
                    showDialog(
                        context: context, builder: buildGlobalDirectiveDialog);
                  },
                ),
                SettingsTile(
                  leading: const Icon(Icons.emoji_emotions),
                  title: const Text("Temperature"),
                  value: Text("${_chatTemperature ?? "Default"}"),
                  onPressed: (context) {
                    showDialog(
                        context: context, builder: buildChatTemperatureDialog);
                  },
                )
              ],
            ),
            SettingsSection(
              title: const Text("App"),
              tiles: [
                SettingsTile(
                  leading: const Icon(Icons.help),
                  title: const Text("About $APP_NAME"),
                  onPressed: showAboutPage,
                )
              ],
            ),
          ]);
}
