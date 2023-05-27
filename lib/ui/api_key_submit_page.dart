import 'package:chat_to_me/ui/chat_page.dart';
import 'package:chat_to_me/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../logic/local/shared_preferences.dart';

final _apiKeySubmitTextFieldKey = GlobalKey<ApiKeySubmitTextFieldState>();

class ApiKeySubmitPage extends StatelessWidget {
  const ApiKeySubmitPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Please input your",
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: "OpenAI",
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                    const TextSpan(
                      text: " API Key",
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                child: ApiKeySubmitTextField(key: _apiKeySubmitTextFieldKey),
              ),
              Container(
                margin: const EdgeInsets.only(top: 36.0),
                child: FloatingActionButton(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100.0))),
                    onPressed: () {
                      final key = kDebugMode
                          ? "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"
                          : _apiKeySubmitTextFieldKey.currentState!.text;
                      if (key.isNotEmpty) {
                        // TODO: Logic
                        saveApiKey(key).then((_) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChatPage(),
                              ));
                        });
                      } else {
                        context
                            .showFloatingSnackBar("API Key cannot be empty!");
                      }
                    },
                    child: const Icon(Icons.arrow_forward)),
              )
            ],
          ),
        ),
      );
}

class ApiKeySubmitTextField extends StatefulWidget {
  const ApiKeySubmitTextField({required Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ApiKeySubmitTextFieldState();
}

class ApiKeySubmitTextFieldState extends State<ApiKeySubmitTextField> {
  late final _controller = TextEditingController();

  String get text => _controller.text;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        textInputAction: TextInputAction.go,
        maxLines: 1,
        controller: _controller,
        obscureText: true,
        decoration: InputDecoration(
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0))),
            labelText: "API Key",
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _controller.clear,
            )),
      );
}
