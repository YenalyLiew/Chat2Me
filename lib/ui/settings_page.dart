import 'dart:developer';

import 'package:chat_to_me/constants.dart';
import 'package:chat_to_me/ui/api_key_submit_page.dart';
import 'package:chat_to_me/ui/provider/settings_page_provider.dart';
import 'package:chat_to_me/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import 'provider/chat_page_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => SettingsPageProvider(),
        child: Scaffold(
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
        ),
      );
}

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsPageProvider>().initialize();
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
    Future Function()? onReset,
    Future Function(T value)? onSave,
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
        context.read<SettingsPageProvider>().chatTemperature,
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
        onReset: () =>
            context.read<SettingsPageProvider>().setChatTemperature(null),
        onSave: context.read<SettingsPageProvider>().setChatTemperature,
      );

  AlertDialog buildGlobalDirectiveDialog(BuildContext context) =>
      _buildBaseTextFieldDialog(
        context,
        context.read<SettingsPageProvider>().globalDirective,
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
        onReset: () =>
            context.read<SettingsPageProvider>().setGlobalDirective(null),
        onSave: context.read<SettingsPageProvider>().setGlobalDirective,
      );

  AlertDialog buildTopPDialog(BuildContext context) =>
      _buildBaseTextFieldDialog(
        context,
        context.read<SettingsPageProvider>().topP,
        title: "Set Top P Sampling",
        content: "An alternative to sampling with temperature, "
            "called nucleus sampling, "
            "where the model considers the results of the tokens with top_p probability mass. "
            "So 0.1 means only the tokens comprising the top 10% probability mass are considered.\n"
            "We generally recommend altering this or temperature but not both.",
        textFieldMinLines: 1,
        textFieldMaxLines: 1,
        textFieldHint: "Top P (0.0 ~ 1.0)",
        textInputType: const TextInputType.numberWithOptions(decimal: true),
        validator: (s) {
          final parse = double.tryParse(s);
          return (parse != null && parse >= 0.0 && parse <= 1.0) ? parse : null;
        },
        onReset: () => context.read<SettingsPageProvider>().setTopP(null),
        onSave: context.read<SettingsPageProvider>().setTopP,
      );

  AlertDialog buildMaxTokensDialog(BuildContext context) =>
      _buildBaseTextFieldDialog(
        context,
        context.read<SettingsPageProvider>().maxTokens,
        title: "Set Max Tokens",
        content: "The maximum number of tokens to generate. ",
        textFieldMinLines: 1,
        textFieldMaxLines: 1,
        textFieldHint: "Max Tokens (0 ~ inf)",
        textInputType: TextInputType.number,
        validator: (s) {
          final parse = int.tryParse(s);
          return (parse != null && parse >= 0) ? parse : null;
        },
        onReset: () => context.read<SettingsPageProvider>().setMaxTokens(null),
        onSave: context.read<SettingsPageProvider>().setMaxTokens,
      );

  AlertDialog buildPresencePenaltyDialog(BuildContext context) =>
      _buildBaseTextFieldDialog(
        context,
        context.read<SettingsPageProvider>().presencePenalty,
        title: "Set Presence Penalty",
        content: "Number between -2.0 and 2.0. "
            "Positive values penalize new tokens based on whether they appear in the text so far, "
            "increasing the model's likelihood to talk about new topics.",
        textFieldMinLines: 1,
        textFieldMaxLines: 1,
        textFieldHint: "Presence Penalty (-2.0 ~ 2.0)",
        textInputType:
            const TextInputType.numberWithOptions(decimal: true, signed: true),
        validator: (s) {
          final parse = double.tryParse(s);
          return (parse != null && parse >= -2.0 && parse <= 2.0)
              ? parse
              : null;
        },
        onReset: () =>
            context.read<SettingsPageProvider>().setPresencePenalty(null),
        onSave: context.read<SettingsPageProvider>().setPresencePenalty,
      );

  AlertDialog buildFrequencyPenaltyDialog(BuildContext context) =>
      _buildBaseTextFieldDialog(
        context,
        context.read<SettingsPageProvider>().frequencyPenalty,
        title: "Set Frequency Penalty",
        content: "Number between -2.0 and 2.0. "
            "Positive values penalize new tokens based on their existing frequency in the text so far, "
            "decreasing the model's likelihood to repeat the same line verbatim.",
        textFieldMinLines: 1,
        textFieldMaxLines: 1,
        textFieldHint: "Frequency Penalty (-2.0 ~ 2.0)",
        textInputType:
            const TextInputType.numberWithOptions(decimal: true, signed: true),
        validator: (s) {
          final parse = double.tryParse(s);
          return (parse != null && parse >= -2.0 && parse <= 2.0)
              ? parse
              : null;
        },
        onReset: () =>
            context.read<SettingsPageProvider>().setFrequencyPenalty(null),
        onSave: context.read<SettingsPageProvider>().setFrequencyPenalty,
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
                onPressed: () async {
                  await context.read<SettingsPageProvider>().removeApiKey();
                  if (mounted) {
                    context.read<ChatPageProvider>().resetAllState();
                  }
                  if (mounted) {
                    Navigator.of(context)
                      ..pop()
                      ..pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const ApiKeySubmitPage()),
                        (route) => false,
                      );
                  }
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
                  onPressed: (_) {
                    showDialog(
                        context: context,
                        builder: (_) => buildClearAPIKeyDialog(context));
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
                    context.watch<SettingsPageProvider>().globalDirective ??
                        "None",
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: (_) {
                    showDialog(
                        context: context,
                        builder: (_) => buildGlobalDirectiveDialog(context));
                  },
                ),
                SettingsTile(
                  leading: const Icon(Icons.emoji_emotions_outlined),
                  title: const Text("Temperature"),
                  value: Text(
                    "${context.watch<SettingsPageProvider>().chatTemperature ?? "Default"}",
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: (_) {
                    showDialog(
                        context: context,
                        builder: (_) => buildChatTemperatureDialog(context));
                  },
                ),
                SettingsTile(
                  leading: const Icon(Icons.more_horiz),
                  title: const Text("Top P Sampling"),
                  value: Text(
                      "${context.watch<SettingsPageProvider>().topP ?? "Default"}"),
                  onPressed: (_) {
                    showDialog(
                        context: context,
                        builder: (_) => buildTopPDialog(context));
                  },
                ),
                SettingsTile(
                  leading: const Icon(Icons.vertical_align_top),
                  title: const Text("Max Tokens"),
                  value: Text(
                      "${context.watch<SettingsPageProvider>().maxTokens ?? "Default"}"),
                  onPressed: (_) {
                    showDialog(
                        context: context,
                        builder: (_) => buildMaxTokensDialog(context));
                  },
                ),
                SettingsTile(
                  leading: const Icon(Icons.repeat),
                  title: const Text("Presence Penalty"),
                  value: Text(
                      "${context.watch<SettingsPageProvider>().presencePenalty ?? "Default"}"),
                  onPressed: (_) {
                    showDialog(
                        context: context,
                        builder: (_) => buildPresencePenaltyDialog(context));
                  },
                ),
                SettingsTile(
                  leading: const Icon(Icons.loop),
                  title: const Text("Frequency Penalty"),
                  value: Text(
                      "${context.watch<SettingsPageProvider>().frequencyPenalty ?? "Default"}"),
                  onPressed: (_) {
                    showDialog(
                        context: context,
                        builder: (_) => buildFrequencyPenaltyDialog(context));
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
