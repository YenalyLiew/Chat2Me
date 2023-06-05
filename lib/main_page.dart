import 'package:chat_to_me/ui/api_key_submit_page.dart';
import 'package:chat_to_me/ui/chat_page.dart';
import 'package:chat_to_me/utils.dart';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'logic/local/shared_preferences.dart';

void main() => runApp(const ChatToMe());

class ChatToMe extends StatelessWidget {
  const ChatToMe({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: APP_NAME,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
            useMaterial3: true),
        home: const WelcomePage(),
      );
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<StatefulWidget> createState() => WelcomeState();
}

class WelcomeState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    apiKey.then((key) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (key == null) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const ApiKeySubmitPage()));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const ChatPage()));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
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
              const Text(
                "Welcome to",
                style: TextStyle(fontSize: 24.0),
                textAlign: TextAlign.center,
              ),
              setAppNameArtTitle(textStyle: const TextStyle(fontSize: 32.0)),
            ],
          ),
        ),
      );
}
