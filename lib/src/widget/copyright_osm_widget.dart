import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CopyrightOSMWidget extends StatelessWidget {
  final String badgeText;
  final Color? badgeColor;
  final Color badgeTextColor;

  const CopyrightOSMWidget(
      {super.key,
      required this.badgeText,
      required this.badgeColor,
      required this.badgeTextColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: badgeColor ?? Colors.grey[300],
      height: 20,
      padding: const EdgeInsets.all(3.0),
      child: Text.rich(
        TextSpan(
          text: "© ",
          children: [
            TextSpan(
              text: badgeText,
              style: TextStyle(
                color: badgeTextColor,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  const url = 'https://www.openstreetmap.org/copyright';
                  if (await canLaunchUrlString(url)) {
                    await launchUrlString(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
            )
          ],
        ),
        style: const TextStyle(
          fontSize: 9,
        ),
      ),
    );
  }
}
