import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:chat_to_me/constants.dart';
import 'package:chat_to_me/ui/chat_page.dart';
import 'package:chat_to_me/utils.dart';
import 'package:flutter/material.dart';

import '../logic/local/shared_preferences.dart';

final _apiKeySubmitTextFieldKey = GlobalKey<ApiKeySubmitTextFieldState>();

class ApiKeySubmitPage extends StatelessWidget {
  const ApiKeySubmitPage({super.key});

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
                const ApiKeySubmitTitleWidget(),
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

class ApiKeySubmitTitleWidget extends StatefulWidget {
  const ApiKeySubmitTitleWidget({super.key});

  @override
  State<ApiKeySubmitTitleWidget> createState() =>
      _ApiKeySubmitTitleWidgetState();
}

class _ApiKeySubmitTitleWidgetState extends State<ApiKeySubmitTitleWidget> {
  bool _isVisible = true;
  late Timer _timer;

  static final List<List<InlineSpan>> _differentTitleSpans = [
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

  final _timerDuration = const Duration(seconds: 1);
  final _animationDuration = const Duration(seconds: 1);
  final _textSwitchingTime = const Duration(seconds: 10);

  int _titleIndex = Random().nextInt(_differentTitleSpans.length);

  List<InlineSpan> get _randomTitleSpan => _differentTitleSpans[_titleIndex];

  @override
  void initState() {
    super.initState();
    final animateDurationSeconds = _animationDuration.inSeconds;
    final lastSwitchingSeconds =
        (_textSwitchingTime - _animationDuration).inSeconds;
    final textSwitchingSeconds = _textSwitchingTime.inSeconds;
    _timer = Timer.periodic(_timerDuration, (timer) {
      int period = periodFromTick(timer.tick, textSwitchingSeconds);
      dev.log(period.toString(), name: "period");
      if (period == textSwitchingSeconds) {
        dev.log("_isVisible = true", name: "Title");
        setState(() {
          _titleIndex = (_titleIndex + 1) % _differentTitleSpans.length;
          _isVisible = true;
        });
      } else if (period == lastSwitchingSeconds) {
        dev.log("_isVisible = false", name: "Title");
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  int periodFromTick(int tick, int switchingTime) =>
      tick - switchingTime * ((tick - 1) / switchingTime).floor();

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: _animationDuration,
      curve: Curves.fastEaseInToSlowEaseOut,
      child: Text.rich(
        TextSpan(
          style: Theme.of(context).textTheme.headlineMedium,
          children: _randomTitleSpan,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
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
