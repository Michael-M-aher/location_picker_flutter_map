import 'package:flutter/material.dart';

class WideButton extends StatelessWidget {
  const WideButton(
    this.text, {
    super.key,
    this.padding = 0.0,
    this.height = 45,
    this.width,
    required this.onPressed,
    this.style,
    this.textStyle = const TextStyle(fontSize: 20),
    this.leadingIcon,
  });

  final String text;
  final double padding;
  final double? height;
  final double? width;
  final ButtonStyle? style;
  final TextStyle textStyle;
  final Widget? leadingIcon;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 45,
      width: width ??
          (MediaQuery.of(context).size.width <= 500
              ? MediaQuery.of(context).size.width
              : 350),
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
                style: textStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
