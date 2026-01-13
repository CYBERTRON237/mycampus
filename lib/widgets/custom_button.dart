import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  final bool isLoading;
  final Widget? child;
  final TextStyle? textStyle;
  final Color backgroundColor;
  final Color textColor;

  const CustomButton({
    super.key,
    this.onPressed,
    this.text,
    this.isLoading = false,
    this.child,
    this.textStyle,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
  })  : assert(text != null || child != null, 'Either text or child must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: Builder(
        builder: (context) {
          if (isLoading) {
            return const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }
          
          if (child != null) return child!;
          
          return Text(
            text!,
            style: textStyle ?? theme.textTheme.labelLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }
}