import 'package:chat_to_me/constants.dart';
import 'package:chat_to_me/ui/chat_page.dart';
import 'package:chat_to_me/utils.dart';
import 'package:flutter/material.dart';

import '../logic/local/shared_preferences.dart';

final _apiKeySubmitTextFieldKey = GlobalKey<ApiKeySubmitTextFieldState>();

class ApiKeySubmitPage extends StatelessWidget {
  const ApiKeySubmitPage({super.key});

  List<List<InlineSpan>> differentTitleSpans() => [
        [
          const TextSpan(text: "Hey! This is "),
          setAppNameArtTitleTextSpan(),
          const TextSpan(text: "!"),
        ],
        [
          const TextSpan(text: "Senpai, "),
          setAppNameArtTitleTextSpan(),
          const TextSpan(text: " UwU!"),
        ],
        [
          const TextSpan(text: "Why not "),
          setAppNameArtTitleTextSpan(),
          const TextSpan(text: "?"),
        ],
        [
          setAppNameArtTitleTextSpan(),
          const TextSpan(text: ", please!"),
        ],
      ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 80,
                  width: 80,
                  child: Image(
                    image: AssetImage(ROUND_LOGO_PATH),
                  ),
                ),
                const SizedBox(height: 8.0),
                Text.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.headlineMedium,
                    children: differentTitleSpans().random(),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  child: ApiKeySubmitTextField(key: _apiKeySubmitTextFieldKey),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 36.0),
                  child: FloatingActionButton(
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(100.0))),
                      onPressed: () {
                        final key =
                            _apiKeySubmitTextFieldKey.currentState!.text;
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
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      openBrowserByLink(context,
                          "https://platform.openai.com/account/api-keys");
                    },
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text("How to apply API Key?"),
                  ),
                  TextButton(
                    onPressed: () {
                      showAboutPage(context);
                    },
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text("About $APP_NAME"),
                  ),
                ],
              ),
            )
          ]),
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
            labelText: "OpenAI API Key",
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _controller.clear,
            )),
      );
}
