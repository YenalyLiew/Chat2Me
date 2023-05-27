import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

extension on Random {
  int random(int startInclusive, int endExclusive) =>
      nextInt(endExclusive - startInclusive) + startInclusive;
}

extension SnackBarQuickly on BuildContext {
  void showFloatingSnackBar(String text) =>
      ScaffoldMessenger.of(this).showSnackBar(SnackBar(
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

Text setAppNameArtTitle({double? textSize, TextAlign? textAlign}) => Text.rich(
    textAlign: textAlign,
    TextSpan(
      style: TextStyle(fontSize: textSize),
      children: const <TextSpan>[
        TextSpan(
          text: "Chat",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(text: "2Me")
      ],
    ));

Future<void> openBrowserByLink(BuildContext context, String? link) async {
  if (link == null) {
    context.showFloatingSnackBar("Url is empty!");
  } else {
    final uri = Uri.parse(link);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}