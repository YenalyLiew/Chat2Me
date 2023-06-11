import 'package:chat_to_me/ui/api_key_submit_page.dart';
import 'package:chat_to_me/ui/chat_page.dart';
import 'package:chat_to_me/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';
import '../logic/local/shared_preferences.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<StatefulWidget> createState() => WelcomeState();
}

class WelcomeState extends State<WelcomePage> {
  var _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    apiKey.value.then((key) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          _opacity = 1.0;
        });
        Future.delayed(const Duration(milliseconds: 800), () {
          if (key == null) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const ApiKeySubmitPage()));
          } else {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const ChatPage()));
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: const SizedBox(
                height: 80,
                width: 80,
                child: Image(
                  image: AssetImage(ROUND_LOGO_PATH),
                ),
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
}
