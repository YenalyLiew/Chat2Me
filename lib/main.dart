import 'package:chat_to_me/ui/provider/chat_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'logic/local/chat_history_database.dart';
import 'ui/splashscreen_page.dart';
import 'ui/provider/global_provider.dart';

void main() {
  BaseChatHistoryDatabase.initialize();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<GlobalProvider>(
        create: (context) => GlobalProvider(context),
      ),
    ],
    child: const ChatToMe(),
  ));
}

class App {
  App._();

  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext get context => _navigatorKey.currentContext!;

  static GlobalProvider get globalProvider => context.read<GlobalProvider>();
}

class ChatToMe extends StatelessWidget {
  const ChatToMe({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        navigatorKey: App._navigatorKey,
        title: APP_NAME,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
            useMaterial3: true),
        home: const WelcomePage(),
      );
}
