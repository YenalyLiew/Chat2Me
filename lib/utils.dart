import 'dart:math';

import 'package:about/about.dart' as about;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';

extension QuickRandom on Random {
  int random(int startInclusive, int endExclusive) =>
      nextInt(endExclusive - startInclusive) + startInclusive;
}

extension ListRandom<T> on List<T> {
  T? random() => isEmpty ? null : this[Random().nextInt(length)];
}

extension QuickFormat on DateTime {
  String localFormat({String? format}) =>
      DateFormat(format ?? DATETIME_PATTERN).format(toLocal());
}

extension QuickSnackBar on BuildContext {
  void showFloatingSnackBar(String text) => ScaffoldMessenger.of(this)
    ..removeCurrentSnackBar()
    ..showSnackBar(SnackBar(
      dismissDirection: DismissDirection.none,
      backgroundColor: Theme.of(this).primaryColor.withOpacity(0.5),
      content: Text(
        text,
        textAlign: TextAlign.center,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      margin: const EdgeInsets.only(bottom: 100, right: 60, left: 60),
    ));
}

TextSpan setAppNameArtTitleTextSpan({TextStyle? textStyle}) => TextSpan(
      style: textStyle,
      children: const <TextSpan>[
        TextSpan(
          text: "Chat",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(text: "2Me")
      ],
    );

Text setAppNameArtTitle({TextStyle? textStyle, TextAlign? textAlign}) =>
    Text.rich(
      setAppNameArtTitleTextSpan(textStyle: textStyle),
      textAlign: textAlign,
    );

void showAboutPage(BuildContext context) => about.showAboutPage(
      context: context,
      applicationIcon: const SizedBox(
        width: 100,
        height: 100,
        child: Image(
          image: AssetImage(ROUND_LOGO_PATH),
        ),
      ),
      applicationLegalese: "Copyright © Yenaly Liew, 2023",
      applicationDescription: const Text(
        "An AI chat application based on OpenAI api.",
      ),
      applicationVersion: "1.0",
      children: [
        ListTile(
          leading: const Icon(Icons.link),
          title: const Text("View on Github"),
          onTap: () => openBrowserByLink(context, APP_GITHUB_LINK),
        ),
        ListTile(
          leading: const Icon(Icons.favorite_border),
          title: const Text("View open source licenses"),
          onTap: () =>
              openBrowserByLink(context, APP_GITHUB_OPEN_SOURCE_LICENSES_LINK),
        )
      ],
    );

Future<void> openBrowserByLink(BuildContext context, String? link) async {
  if (link == null) {
    context.showFloatingSnackBar("Url is empty!");
  } else {
    final uri = Uri.parse(link);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
