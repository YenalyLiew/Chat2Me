import 'dart:developer';

import 'package:chat_to_me/constants.dart';
import 'package:chat_to_me/logic/local/shared_preferences.dart';
import 'package:chat_to_me/ui/api_key_submit_page.dart';
import 'package:chat_to_me/utils.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../logic/model/chat_message.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
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
  double? _topP;
  int? _maxTokens;
  double? _presencePenalty;
  double? _frequencyPenalty;

  @override
  void initState() {
    updateSettings();
    super.initState();
  }

  Future<void> updateSettings() async {
    final double? ct = await chatTemperature.value;
    log(ct.toString(), name: "chatTemperature");
    final String? gd = await globalDirective.value;
    log(gd.toString(), name: "globalDirective");
    final double? tp = await topP.value;
    log(tp.toString(), name: "topP");
    final int? mt = await maxTokens.value;
    log(mt.toString(), name: "maxTokens");
    final double? pp = await presencePenalty.value;
    log(pp.toString(), name: "presencePenalty");
    final double? fp = await frequencyPenalty.value;
    log(fp.toString(), name: "frequencyPenalty");
    setState(() {
      _chatTemperature = ct;
      _globalDirective = gd;
      _topP = tp;
      _maxTokens = mt;
      _presencePenalty = pp;
      _frequencyPenalty = fp;
    });
  }

  AlertDialog _buildBaseTextFieldDialog<T>(
    BuildContext context,
    T? value, {
    required String title,
    required String content,
    int? textFieldMinLines,
    int? textFieldMaxLines,
    String? textFieldHint,
    TextInputType? textInputType,
    T? Function(String)? validator,
    Future<bool> Function()? onReset,
    Future<bool> Function(T value)? onSave,
  }) {
    final controller = TextEditingController(text: value?.toString());
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(content),
            const SizedBox(height: 16),
            TextField(
              keyboardType: textInputType,
              controller: controller,
              minLines: textFieldMinLines,
              maxLines: textFieldMaxLines,
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.0))),
                labelText: textFieldHint,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await onReset?.call();
            if (mounted) {
              updateSettings();
              Navigator.pop(context);
            }
          },
          child: const Text("Reset"),
        ),
        const SizedBox(width: 16.0),
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text("No"),
        ),
        TextButton(
          onPressed: () async {
            final T? temp = validator?.call(controller.text);
            if (temp != null) {
              await onSave?.call(temp);
              if (mounted) {
                updateSettings();
                Navigator.pop(context);
              }
            }
          },
          child: const Text("Yes"),
        ),
      ],
    );
  }

  AlertDialog buildChatTemperatureDialog(BuildContext context) =>
      _buildBaseTextFieldDialog(
        context,
        _chatTemperature,
        title: "Set Temperature",
        content: "What sampling temperature to use, "
            "between 0 and 2. "
            "Higher values like 0.8 will make the output more random, "
            "while lower values like 0.2 will make it more focused and deterministic.\n"
            "We generally recommend altering this or top_p but not both.",
        textFieldHint: "Temperature (0.0 ~ 2.0)",
        textInputType: const TextInputType.numberWithOptions(decimal: true),
        validator: (s) {
          final parse = double.tryParse(s);
          return (parse != null && parse >= 0.0 && parse <= 2.0) ? parse : null;
        },
        onReset: chatTemperature.delete,
        onSave: chatTemperature.save,
      );

  AlertDialog buildGlobalDirectiveDialog(BuildContext context) =>
      _buildBaseTextFieldDialog(
        context,
        _globalDirective,
        title: "Set Global Directive",
        content: "This is actually named \"System Role\" officially.\n"
            "In the ChatGPT API, the role \"system\" is used for system-level instructions or control. "
            "Messages with the system role are used to guide the overall behavior "
            "of the conversation or to set specific parameters of the model.",
        textFieldMinLines: 1,
        textFieldMaxLines: 5,
        textFieldHint: "Global directive",
        textInputType: TextInputType.text,
        validator: (s) => s.isNotEmpty ? s : null,
        onReset: () {
          ChatMessages.singleton().removeSystem();
          return globalDirective.delete();
        },
        onSave: (value) {
          ChatMessages.singleton().addSystem(value);
          return globalDirective.save(value);
        },
      );

  AlertDialog buildTopPDialog(BuildContext context) =>
      _buildBaseTextFieldDialog(
        context,
        _topP,
        title: "Set Top P Sampling",
        content: "An alternative to sampling with temperature, "
            "called nucleus sampling, "
            "where the model considers the results of the tokens with top_p probability mass. "
            "So 0.1 means only the tokens comprising the top 10% probability mass are considered.\n"
            "We generally recommend altering this or temperature but not both.",
        textFieldHint: "Top P (0.0 ~ 1.0)",
        textInputType: const TextInputType.numberWithOptions(decimal: true),
        validator: (s) {
          final parse = double.tryParse(s);
          return (parse != null && parse >= 0.0 && parse <= 1.0) ? parse : null;
        },
        onReset: topP.delete,
        onSave: topP.save,
      );

  AlertDialog buildMaxTokensDialog(BuildContext context) =>
      _buildBaseTextFieldDialog(
        context,
        _maxTokens,
        title: "Set Max Tokens",
        content: "The maximum number of tokens to generate. ",
        textFieldHint: "Max Tokens (0 ~ inf)",
        textInputType: TextInputType.number,
        validator: (s) {
          final parse = int.tryParse(s);
          return (parse != null && parse >= 0) ? parse : null;
        },
        onReset: maxTokens.delete,
        onSave: maxTokens.save,
      );

  AlertDialog buildPresencePenaltyDialog(BuildContext context) =>
      _buildBaseTextFieldDialog(
        context,
        _presencePenalty,
        title: "Set Presence Penalty",
        content: "Number between -2.0 and 2.0. "
            "Positive values penalize new tokens based on whether they appear in the text so far, "
            "increasing the model's likelihood to talk about new topics.",
        textFieldHint: "Presence Penalty (-2.0 ~ 2.0)",
        textInputType:
            const TextInputType.numberWithOptions(decimal: true, signed: true),
        validator: (s) {
          final parse = double.tryParse(s);
          return (parse != null && parse >= -2.0 && parse <= 2.0)
              ? parse
              : null;
        },
        onReset: presencePenalty.delete,
        onSave: presencePenalty.save,
      );

  AlertDialog buildFrequencyPenaltyDialog(BuildContext context) =>
      _buildBaseTextFieldDialog(
        context,
        _frequencyPenalty,
        title: "Set Frequency Penalty",
        content: "Number between -2.0 and 2.0. "
            "Positive values penalize new tokens based on their existing frequency in the text so far, "
            "decreasing the model's likelihood to repeat the same line verbatim.",
        textFieldHint: "Frequency Penalty (-2.0 ~ 2.0)",
        textInputType:
            const TextInputType.numberWithOptions(decimal: true, signed: true),
        validator: (s) {
          final parse = double.tryParse(s);
          return (parse != null && parse >= -2.0 && parse <= 2.0)
              ? parse
              : null;
        },
        onReset: frequencyPenalty.delete,
        onSave: frequencyPenalty.save,
      );

  AlertDialog buildClearAPIKeyDialog(BuildContext context) => AlertDialog(
          title: const Text("You are going to clear your API Key!"),
          content: const Text("Are you sure you wanna do it?"),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text("No"),
            ),
            TextButton(
                onPressed: () {
                  apiKey.delete().then((_) {
                    ChatMessages.removeSingleton();
                    if (mounted) {
                      Navigator.of(context)
                        ..pop()
                        ..pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const ApiKeySubmitPage()),
                          (route) => false,
                        );
                    }
                  });
                },
                child: const Text("Yes")),
          ]);

  @override
  Widget build(BuildContext context) => SettingsList(
          lightTheme:
              SettingsThemeData(titleTextColor: Theme.of(context).primaryColor),
          darkTheme:
              SettingsThemeData(titleTextColor: Theme.of(context).primaryColor),
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
                  leading: const Icon(Icons.directions_outlined),
                  title: const Text("Global Directive"),
                  value: Text(
                    _globalDirective ?? "None",
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: (context) {
                    showDialog(
                        context: context, builder: buildGlobalDirectiveDialog);
                  },
                ),
                SettingsTile(
                  leading: const Icon(Icons.emoji_emotions_outlined),
                  title: const Text("Temperature"),
                  value: Text("${_chatTemperature ?? "Default"}"),
                  onPressed: (context) {
                    showDialog(
                        context: context, builder: buildChatTemperatureDialog);
                  },
                ),
                SettingsTile(
                  leading: const Icon(Icons.more_horiz),
                  title: const Text("Top P Sampling"),
                  value: Text("${_topP ?? "Default"}"),
                  onPressed: (context) {
                    showDialog(context: context, builder: buildTopPDialog);
                  },
                ),
                SettingsTile(
                  leading: const Icon(Icons.vertical_align_top),
                  title: const Text("Max Tokens"),
                  value: Text("${_maxTokens ?? "Default"}"),
                  onPressed: (context) {
                    showDialog(
                        context: context, builder: buildMaxTokensDialog);
                  },
                ),
                SettingsTile(
                  leading: const Icon(Icons.repeat),
                  title: const Text("Presence Penalty"),
                  value: Text("${_presencePenalty ?? "Default"}"),
                  onPressed: (context) {
                    showDialog(
                        context: context, builder: buildPresencePenaltyDialog);
                  },
                ),
                SettingsTile(
                  leading: const Icon(Icons.loop),
                  title: const Text("Frequency Penalty"),
                  value: Text("${_frequencyPenalty ?? "Default"}"),
                  onPressed: (context) {
                    showDialog(
                        context: context, builder: buildFrequencyPenaltyDialog);
                  },
                ),
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
