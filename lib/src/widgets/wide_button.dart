import 'package:flutter/material.dart';

class WideButton extends StatelessWidget {
  const WideButton(
    this.text, {
    Key? key,
    required,
    this.padding = 0.0,
    this.height = 45,
    required this.onPressed,
    this.style,
    this.textColor,
    this.leadingIcon,
  }) : super(key: key);

  final String text;
  final double padding;
  final double height;
  final ButtonStyle? style;
  final Color? textColor;
  final Widget? leadingIcon;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: MediaQuery.of(context).size.width <= 500
          ? MediaQuery.of(context).size.width
          : 350,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: ElevatedButton(
          style: style,
          onPressed: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                leadingIcon!,
                const SizedBox(width: 10),
              ],
              Text(
                text,
                style: TextStyle(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
